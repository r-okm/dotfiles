#!/usr/bin/env bash
set -euo pipefail

# Every tmux session in this setup keeps its long-running nvim in window 2.
NVIM_WINDOW=2

prog=$(basename "$0")

usage() {
  cat <<EOF
Usage: $prog [-s|--switch] [--] <path>[:line[:col]]
       $prog --print-pane

Open an existing file (or a directory, in nvim's file browser) in the nvim
running in the active pane of window $NVIM_WINDOW of the current tmux session,
over its RPC socket.

When that pane sits at a shell prompt instead, nvim is started there first
with no arguments, in the working directory of the calling pane. Any other
program in that pane, or a missing window $NVIM_WINDOW, fails without sending
keys or opening anything. Windows are never created or moved.

  -s, --switch      also switch the tmux client to window $NVIM_WINDOW
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
# is simply there in window 2. A caller reading stdout -- an agent -- cannot see
# that window and needs to be told what happened.
report() {
  [[ -t 1 ]] && return 0
  printf '%s: %s\n' "$prog" "$1"
  printf '%s: %s\n' "$prog" \
    "tell the user the file is open in window $NVIM_WINDOW (and that nvim was started, if it was); if it is not, say so rather than retrying"
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

current_session() {
  [[ -n ${TMUX:-} ]] ||
    die "not inside tmux -- there is no session whose window $NVIM_WINDOW to look at"
  # Without a pane to anchor on, tmux answers for the attached client's current
  # session, which is the wrong one whenever the user is looking elsewhere.
  if [[ -n ${TMUX_PANE:-} ]]; then
    tmux display-message -p -t "$TMUX_PANE" '#{session_name}'
  else
    tmux display-message -p '#{session_name}'
  fi
}

# Sets target_pane, target_pid, target_in_mode and target_command for the
# active pane of window 2
find_target_pane() {
  local session=$1 info

  # Not display-message: on a missing window it silently answers for the
  # current pane instead of failing.
  info=$(tmux list-panes -t "=${session}:${NVIM_WINDOW}" \
    -F '#{pane_active} #{pane_id} #{pane_pid} #{pane_in_mode} #{pane_current_command}' \
    2>/dev/null) ||
    die "window $NVIM_WINDOW not found in session '$session'" \
      "the nvim window is missing -- tell the user, and read the file some other way"
  info=$(sed -n 's/^1 //p' <<<"$info")
  [[ -n $info ]] || die "no active pane in window $NVIM_WINDOW of session '$session'"
  read -r target_pane target_pid target_in_mode target_command <<<"$info"
}

# nvim's default server socket is $XDG_RUNTIME_DIR/nvim.<pid>.<n>, and the nvim
# process still carries the TMUX_PANE it was started in -- so the pane, not the
# window name or the process tree, is what ties a socket to window 2.
lookup_nvim() {
  local pane_wanted=$1
  local runtime=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
  local sock pid env pane

  [[ -n $pane_wanted ]] || return 1
  for sock in "$runtime"/nvim.*; do
    [[ -S $sock ]] || continue
    pid=${sock##*/nvim.}
    pid=${pid%%.*}
    [[ $pid =~ ^[0-9]+$ ]] || continue
    [[ -r /proc/$pid/environ ]] || continue

    # The process can exit between the check above and this read
    env=$(tr '\0' '\n' </proc/"$pid"/environ) || continue
    # $NVIM marks an nvim started from inside another nvim's :terminal, which
    # inherits TMUX_PANE and would otherwise shadow the real one.
    grep -q '^NVIM=' <<<"$env" && continue

    pane=$(sed -n 's/^TMUX_PANE=//p' <<<"$env" | head -n1)
    [[ $pane == "$pane_wanted" ]] || continue

    nvim_socket=$sock
    nvim_pane=$pane
    return 0
  done
  return 1
}

find_nvim() {
  local session=$1
  find_target_pane "$session"
  lookup_nvim "$target_pane" ||
    die "no nvim listening in window $NVIM_WINDOW of session '$session'" \
      "start nvim there first, or read the file some other way"
}

# #{pane_current_command} names the foreground process, and a bash script
# running in the pane is called bash as well. The shell is at its prompt only
# when the pane's own process -- the shell tmux started -- holds the terminal's
# foreground. zsh and bash only: they both read the $'...' that %q may produce.
shell_at_prompt() {
  local stat tpgid

  case "$target_command" in
    zsh | bash) ;;
    *) return 1 ;;
  esac
  stat=$(<"/proc/$target_pid/stat") || return 1
  # Fields after "pid (comm) ": state ppid pgrp session tty_nr tpgid
  read -r _ _ _ _ _ tpgid _ <<<"${stat##*) }"
  [[ $tpgid == "$target_pid" ]]
}

# The pane the agent runs in: the Bash tool's cwd may have drifted into a
# subdirectory, the agent process itself has not.
caller_dir() {
  if [[ -n ${TMUX_PANE:-} ]]; then
    tmux display-message -p -t "$TMUX_PANE" '#{pane_current_path}'
  else
    pwd
  fi
}

# Typed into the user's interactive shell rather than run as the pane command,
# so nvim gets the same environment as when started by hand and the shell is
# still there after :q. C-u (kill-whole-line under bindkey -e) clears anything
# half-typed; it stays in the kill ring for C-y.
start_nvim() {
  local session=$1 dir quoted

  find_target_pane "$session"
  if lookup_nvim "$target_pane"; then
    nvim_started=false
    return 0
  fi
  [[ $target_command != nvim ]] ||
    die "window $NVIM_WINDOW of session '$session' runs nvim, but no socket of it was found" \
      "no keys were sent -- tell the user, and read the file some other way"
  shell_at_prompt ||
    die "window $NVIM_WINDOW of session '$session' is running '$target_command', not nvim or a shell at its prompt" \
      "no keys were sent -- tell the user, and read the file some other way"

  # In copy-mode the keys below would run as copy-mode commands
  if [[ $target_in_mode == 1 ]]; then
    tmux send-keys -t "$target_pane" -X cancel
  fi

  dir=$(caller_dir)
  printf -v quoted '%q' "$dir"
  # Two command lines, not `cd ... && nvim`: zsh's preexec titles the pane
  # after the first word of each line, and it should read nvim.
  tmux send-keys -t "$target_pane" C-u \; \
    send-keys -t "$target_pane" -l "cd -- $quoted" \; \
    send-keys -t "$target_pane" Enter \; \
    send-keys -t "$target_pane" -l nvim \; \
    send-keys -t "$target_pane" Enter

  # nvim creates its socket before running init.lua, and answers nothing until
  # startup is over, so the socket alone does not mean it is ready.
  local deadline=$((SECONDS + 10)) cmd
  while ((SECONDS < deadline)); do
    cmd=$(tmux display-message -p -t "$target_pane" '#{pane_current_command}')
    if [[ $cmd == nvim ]] && lookup_nvim "$target_pane" &&
      [[ $(timeout 1 nvim --server "$nvim_socket" --remote-expr 'v:vim_did_enter' 2>/dev/null) == 1 ]]; then
      nvim_started=true
      return 0
    fi
    sleep 0.2
  done
  die "started nvim in window $NVIM_WINDOW of session '$session', but it was not ready within 10s" \
    "check window $NVIM_WINDOW -- tell the user, and read the file some other way"
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
      "it is busy or waiting on a prompt -- deal with it in window $NVIM_WINDOW first"
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

  local session
  session=$(current_session)
  [[ -n $session ]] || die "could not tell which tmux session this runs in"

  if [[ $print_pane == true ]]; then
    find_nvim "$session"
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

  local nvim_started
  start_nvim "$session"

  normalize_mode
  remote_expr "execute('drop ' . fnameescape($(vim_str "$abs")))"
  if [[ -n $line ]]; then
    remote_expr "[cursor($line, ${col:-1}), execute('normal! zz')]"
  fi

  local where="window $NVIM_WINDOW of session '$session'"
  local started=""
  [[ $nvim_started == true ]] && started=" (nvim was not running there, so it was started first)"
  if [[ $switch == true ]]; then
    tmux select-window -t "=${session}:${NVIM_WINDOW}"
    report "opened $abs${line:+ at line $line} in nvim and switched to $where$started"
  else
    report "opened $abs${line:+ at line $line} in the nvim in $where$started (the user has to switch there to see it)"
  fi
}

main "$@"

# vim: set ft=sh:
