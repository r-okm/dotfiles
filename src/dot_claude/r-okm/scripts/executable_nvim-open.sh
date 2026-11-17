#!/usr/bin/env bash
set -euo pipefail

# The long-running nvim of a herdr workspace usually lives in its second tab.
NVIM_TAB=2

prog=$(basename "$0")

usage() {
  cat <<EOF
Usage: $prog [-s|--switch] [--] <path>[:line[:col]]
       $prog --print-pane

Open an existing file (or a directory, in nvim's file browser) in the nvim
running in the current herdr workspace, over its RPC socket.

That nvim is the one listening in this workspace, leaving out nvims started
with -u (git's editor, the prompt editor) and nvims inside another nvim. When
there are several, the one in tab $NVIM_TAB wins; when none of them is there,
nothing is opened.

When the workspace has no nvim, nvim is started in the active pane of tab
$NVIM_TAB if that pane sits at a shell prompt, with no arguments, in the
working directory of the calling pane. Any other program in that pane, or a
missing tab $NVIM_TAB, fails without sending keys or opening anything. Tabs
and panes are never created or moved.

  -s, --switch      also switch the herdr client to the tab of that nvim
      --print-pane  print the pane id of that nvim and exit, opening nothing
                    and starting nothing
  -h, --help        show this help

A trailing :line[:col] (grep/rg style) is honoured unless the path exists
verbatim. Use -- before a path that starts with a dash.
EOF
}

die() {
  local line
  for line in "$@"; do
    printf '%s: %s\n' "$prog" "$line" >&2
  done
  exit 1
}

# Nothing is printed on success for a human watching their own screen: the file
# is simply there. A caller reading stdout -- an agent -- cannot see that tab and
# needs to be told what happened.
report() {
  [[ -t 1 ]] && return 0
  printf '%s: %s\n' "$prog" "$1"
  printf '%s: %s\n' "$prog" \
    "tell the user the file is open in nvim in $nvim_where (and that nvim was started, if it was); if it is not, say so rather than retrying"
}

# A path that exists as given wins: a colon is a legal filename character.
split_line_col() {
  file=$1
  line=""
  col=""

  [[ -e $file ]] && return 0

  if [[ $file =~ ^(.+):([0-9]+):([0-9]+):?$ ]] && [[ -e ${BASH_REMATCH[1]} ]]; then
    file=${BASH_REMATCH[1]}
    line=${BASH_REMATCH[2]}
    col=${BASH_REMATCH[3]}
  elif [[ $file =~ ^(.+):([0-9]+):?$ ]] && [[ -e ${BASH_REMATCH[1]} ]]; then
    file=${BASH_REMATCH[1]}
    line=${BASH_REMATCH[2]}
  fi
}

herdr_json() {
  local out
  out=$(herdr "$@" 2>&1) || die "herdr $1 $2 failed: $out"
  printf '%s\n' "$out"
}

# Sets workspace, panes_json (pane_id TAB tab_id per line) and tab_ids (in
# sidebar order) for the workspace this runs in
load_workspace() {
  workspace=${HERDR_WORKSPACE_ID:-}
  [[ -n $workspace ]] ||
    die "not inside herdr -- there is no workspace to look for nvim in"
  panes_json=$(herdr_json pane list --workspace "$workspace" |
    jq -r '.result.panes[] | [.pane_id, .tab_id] | @tsv')
  mapfile -t tab_ids < <(herdr_json tab list --workspace "$workspace" |
    jq -r '.result.tabs[].tab_id')
}

tab_of_pane() {
  awk -F '\t' -v p="$1" '$1 == p {print $2}' <<<"$panes_json"
}

# 1-based position of a tab in the sidebar, as the user counts tabs
tab_position() {
  local i
  for i in "${!tab_ids[@]}"; do
    [[ ${tab_ids[$i]} == "$1" ]] && { echo $((i + 1)); return 0; }
  done
  echo "?"
}

nvim_tab_id() {
  ((${#tab_ids[@]} >= NVIM_TAB)) && echo "${tab_ids[$((NVIM_TAB - 1))]}"
}

# The pane of the tab that has focus within it, like tmux's active pane
active_pane_of_tab() {
  local tab=$1 any
  any=$(awk -F '\t' -v t="$tab" '$2 == t {print $1; exit}' <<<"$panes_json")
  [[ -n $any ]] || return 1
  herdr_json pane layout --pane "$any" | jq -r '.result.layout.focused_pane_id'
}

# The command line of an nvim with -u is one of the lightweight inits.
started_with_u() {
  local pid=$1 arg
  [[ -r /proc/$pid/cmdline ]] || return 1
  while IFS= read -r -d '' arg; do
    [[ $arg == -u ]] && return 0
  done </proc/"$pid"/cmdline
  return 1
}

# nvim's default server socket is $XDG_RUNTIME_DIR/nvim.<pid>.<n>, and the nvim
# process still carries the HERDR_WORKSPACE_ID and HERDR_PANE_ID of the pane it
# was started in. The pane is checked against herdr as well: it may have been
# closed or moved since. Prints socket TAB pane per nvim found.
list_nvims() {
  local runtime=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
  local sock pid ppid env ws pane

  for sock in "$runtime"/nvim.*; do
    [[ -S $sock ]] || continue
    pid=${sock##*/nvim.}
    pid=${pid%%.*}
    [[ $pid =~ ^[0-9]+$ ]] || continue
    [[ -r /proc/$pid/environ ]] || continue

    # The process can exit between the check above and this read
    env=$(tr '\0' '\n' </proc/"$pid"/environ) || continue
    # $NVIM marks an nvim started from inside another nvim's :terminal, which
    # inherits the pane variables and would otherwise shadow the real one.
    grep -q '^NVIM=' <<<"$env" && continue
    ws=$(sed -n 's/^HERDR_WORKSPACE_ID=//p' <<<"$env" | head -n1)
    [[ $ws == "$workspace" ]] || continue
    pane=$(sed -n 's/^HERDR_PANE_ID=//p' <<<"$env" | head -n1)
    [[ -n $(tab_of_pane "$pane") ]] || continue

    # The socket belongs to the `nvim --embed` server; -u is on its parent, the
    # TUI the user started.
    ppid=$(awk '/^PPid:/ {print $2}' /proc/"$pid"/status 2>/dev/null) || continue
    started_with_u "$pid" && continue
    [[ -n $ppid ]] && started_with_u "$ppid" && continue

    printf '%s\t%s\n' "$sock" "$pane"
  done
}

# Sets nvim_socket and nvim_pane, or returns 1 when the workspace has no nvim
find_nvim() {
  local found count tab2 in_tab2 active sock pane
  found=$(list_nvims)
  [[ -n $found ]] || return 1
  count=$(wc -l <<<"$found")
  if ((count > 1)); then
    tab2=$(nvim_tab_id) || tab2=""
    in_tab2=$(while IFS=$'\t' read -r sock pane; do
      [[ -n $tab2 && $(tab_of_pane "$pane") == "$tab2" ]] && printf '%s\t%s\n' "$sock" "$pane"
    done <<<"$found")
    if [[ $(grep -c . <<<"$in_tab2") -gt 1 ]]; then
      active=$(active_pane_of_tab "$tab2")
      in_tab2=$(awk -F '\t' -v p="$active" '$2 == p' <<<"$in_tab2")
    fi
    [[ $(grep -c . <<<"$in_tab2") -eq 1 ]] ||
      die "found $count nvims in workspace $workspace, none of them alone in tab $NVIM_TAB:" \
        "$(cut -f2 <<<"$found" | while read -r p; do echo "  pane $p in tab $(tab_position "$(tab_of_pane "$p")")"; done)" \
        "tell the user which nvims there are, and read the file some other way"
    found=$in_tab2
  fi
  IFS=$'\t' read -r nvim_socket nvim_pane <<<"$found"
}

# The shell is at its prompt when it holds the terminal's foreground itself.
# zsh and bash only: they both read the $'...' that %q may produce.
shell_at_prompt() {
  local info
  info=$(herdr_json pane process-info --pane "$target_pane" | jq -r '
    .result.process_info as $i
    | [$i.shell_pid, $i.foreground_process_group_id,
       ([$i.foreground_processes[]?.name] | join(","))] | @tsv')
  IFS=$'\t' read -r target_shell_pid target_fg_pgid target_command <<<"$info"
  case "$target_command" in
    zsh | bash) ;;
    *) return 1 ;;
  esac
  [[ $target_fg_pgid == "$target_shell_pid" ]]
}

# The pane the agent runs in: the Bash tool's cwd may have drifted into a
# subdirectory, the agent process itself has not.
caller_dir() {
  local dir=""
  if [[ -n ${HERDR_PANE_ID:-} ]]; then
    dir=$(herdr pane get "$HERDR_PANE_ID" 2>/dev/null |
      jq -r '.result.pane.foreground_cwd // .result.pane.cwd // empty') || dir=""
  fi
  if [[ -n $dir ]]; then
    echo "$dir"
  else
    pwd
  fi
}

# Typed into the user's interactive shell rather than run as the pane command,
# so nvim gets the same environment as when started by hand and the shell is
# still there after :q. C-u (kill-whole-line under bindkey -e) clears anything
# half-typed; it stays in the kill ring for C-y.
start_nvim() {
  local tab dir quoted found

  if find_nvim; then
    nvim_started=false
    return 0
  fi
  tab=$(nvim_tab_id) ||
    die "tab $NVIM_TAB not found in workspace $workspace, and no nvim runs in the workspace" \
      "the nvim tab is missing -- tell the user, and read the file some other way"
  target_pane=$(active_pane_of_tab "$tab") ||
    die "no pane in tab $NVIM_TAB of workspace $workspace"
  shell_at_prompt ||
    die "tab $NVIM_TAB of workspace $workspace is running '${target_command:-?}', not nvim or a shell at its prompt" \
      "no keys were sent -- tell the user, and read the file some other way"

  dir=$(caller_dir)
  printf -v quoted '%q' "$dir"
  # Two command lines, not `cd ... && nvim`: zsh's preexec titles the pane
  # after the first word of each line, and it should read nvim.
  herdr_json pane send-keys "$target_pane" ctrl+u >/dev/null
  herdr_json pane send-text "$target_pane" "cd -- $quoted" >/dev/null
  herdr_json pane send-keys "$target_pane" enter >/dev/null
  herdr_json pane send-text "$target_pane" nvim >/dev/null
  herdr_json pane send-keys "$target_pane" enter >/dev/null

  # nvim creates its socket before running init.lua, and answers nothing until
  # startup is over, so the socket alone does not mean it is ready.
  local deadline=$((SECONDS + 10))
  while ((SECONDS < deadline)); do
    found=$(list_nvims | awk -F '\t' -v p="$target_pane" '$2 == p' | head -n1)
    if [[ -n $found ]]; then
      IFS=$'\t' read -r nvim_socket nvim_pane <<<"$found"
      if [[ $(timeout 1 nvim --server "$nvim_socket" --remote-expr 'v:vim_did_enter' 2>/dev/null) == 1 ]]; then
        nvim_started=true
        return 0
      fi
    fi
    sleep 0.2
  done
  die "started nvim in tab $NVIM_TAB of workspace $workspace, but it was not ready within 10s" \
    "check tab $NVIM_TAB -- tell the user, and read the file some other way"
}

# Vim string literal: doubling is the only escape a '...' literal has.
vim_str() {
  printf "'%s'" "${1//\'/\'\'}"
}

# nvim answers --remote-expr from its main loop, so an nvim sitting on a
# hit-enter prompt never answers at all. --remote-send goes through nvim_input,
# which is delivered even while the editor is blocked: it dismisses that prompt,
# and leaves insert/visual/terminal mode so the user's next keystrokes do not
# land in the file we are about to open.
normalize_mode() {
  timeout 5 nvim --server "$nvim_socket" --remote-send '<C-\><C-N>' >/dev/null 2>&1 || true
}

remote_expr() {
  local expr=$1 rc=0
  timeout 5 nvim --server "$nvim_socket" --remote-expr "$expr" >/dev/null || rc=$?
  ((rc == 0)) && return 0
  ((rc == 124)) &&
    die "nvim did not answer within 5s (socket $nvim_socket)" \
      "it is busy or waiting on a prompt -- deal with it in $nvim_where first"
  die "nvim rejected the request (socket $nvim_socket)"
}

main() {
  local switch=false print_pane=false
  local operands=()

  while (($# > 0)); do
    case "$1" in
      --)
        shift
        operands+=("$@")
        break
        ;;
      -s | --switch) switch=true ;;
      --print-pane) print_pane=true ;;
      -h | --help)
        usage
        exit 0
        ;;
      -*)
        echo "$prog: unknown option: $1" >&2
        echo "$prog: if that is a path, pass it after --: $prog -- '$1'" >&2
        usage >&2
        exit 1
        ;;
      *) operands+=("$1") ;;
    esac
    shift
  done

  local workspace panes_json tab_ids nvim_socket nvim_pane nvim_where="tab $NVIM_TAB"
  load_workspace

  if [[ $print_pane == true ]]; then
    find_nvim ||
      die "no nvim listening in workspace $workspace" \
        "start nvim in tab $NVIM_TAB first, or read the file some other way"
    echo "$nvim_pane"
    return 0
  fi

  ((${#operands[@]} > 0)) ||
    die "no path given" "pass the one file the user should look at"
  ((${#operands[@]} == 1)) ||
    die "expected a single path, got ${#operands[@]}" \
      "pass the one file the user should look at, not every file you touched"

  local file line col
  split_line_col "${operands[0]}"

  [[ -e $file ]] ||
    die "no such path: $file" "the file must already exist -- create it before showing it"
  [[ -r $file ]] ||
    die "cannot read: $file" "check the permissions -- nvim would open an empty buffer"
  if [[ -f $file ]]; then
    if [[ -s $file ]] && ! LC_ALL=C grep -qI '' -- "$file"; then
      die "looks like a binary file: $file -- nvim is for text"
    fi
  elif [[ ! -d $file ]]; then
    # A directory is fine: nvim's file browser takes it from here
    die "neither a file nor a directory: $file" "this opens things in an editor"
  fi

  # -s keeps symlinks in the path: a repo reached through one is the path the
  # user knows, and the buffer name should say so.
  local abs
  abs=$(realpath -s -- "$file")

  local target_pane target_shell_pid target_fg_pgid target_command nvim_started
  start_nvim

  local nvim_tab
  nvim_tab=$(tab_of_pane "$nvim_pane")
  nvim_where="tab $(tab_position "$nvim_tab") of workspace $workspace"

  normalize_mode
  remote_expr "execute('drop ' . fnameescape($(vim_str "$abs")))"
  if [[ -n $line ]]; then
    remote_expr "[cursor($line, ${col:-1}), execute('normal! zz')]"
  fi

  local started=""
  [[ $nvim_started == true ]] && started=" (nvim was not running there, so it was started first)"
  if [[ $switch == true ]]; then
    herdr_json tab focus "$nvim_tab" >/dev/null
    report "opened $abs${line:+ at line $line} in nvim and switched to $nvim_where$started"
  else
    report "opened $abs${line:+ at line $line} in the nvim in $nvim_where$started (the user has to switch there to see it)"
  fi
}

main "$@"

# vim: set ft=sh:
