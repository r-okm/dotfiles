# vim: set ft=sh:

FUNCTIONS_IN_THIS_FILE=(
  'fzf_command_history'
  'fzf_cd'
  'fzf_cd_ghq'
  'fzf_cd_worktree'
  'fzf_git_log'
  'awsp'
  'completions_generate'
)

autoload -Uz edit-command-line
edit-command-line2() {
  EDITOR="${EDITOR_EDIT_COMMAND_LINE:-$EDITOR}" edit-command-line
}
zle -N edit-command-line2
bindkey "^e" edit-command-line2

fzf_functions() {
  local fn=$(
    print -l -- "${FUNCTIONS_IN_THIS_FILE[@]}" |
      fzf \
        --height 50% \
        --reverse \
        --prompt='FUNCTIONS > ' \
        --query "$LBUFFER"
  )
  [[ -n "$fn" ]] && _update_prompt "$fn"
}
zle -N fzf_functions
bindkey '^f' fzf_functions

fzf_command_history() {
  local command=$(
    history -n -r 1 |
      awk '!seen[$0]++ && !/^(ls|eza|fzf_cd)/' |
      fzf \
        --height 50% \
        --reverse \
        --prompt='HISTORY > ' \
        --query "$LBUFFER"
  )
  [[ -n "$command" ]] && _update_prompt "$command"
}
zle -N fzf_command_history
bindkey '^r' fzf_command_history

fzf_cd() {
  local fd_args=(--type directory --exclude node_modules)

  # Check if --hidden flag is passed
  if [[ "$@" =~ "--hidden" ]]; then
    fd_args+=(--hidden --no-ignore)
  fi

  local target_dir=$(fd "${fd_args[@]}" . $@ | fzf --height 90% --reverse --prompt='CHANGE DIRECTORY > ')
  if [[ -n "$target_dir" ]]; then
    target_dir=$(realpath "$target_dir")
    _execute_prompt "cd $target_dir"
  fi
}

fzf_cd_ghq() {
  local result=$(
    ghq list | fzf \
      --height 50% \
      --reverse \
      --prompt='CHANGE DIRECTORY > ' \
      --header='| cd: <cr> | tmux session: <C-s> |' \
      --expect=ctrl-s \
      --preview="ghq list --full-path --exact {} | xargs -I {} eza-tree {} --git-ignore"
  )

  if [[ -n "$result" ]]; then
    local key=$(echo "$result" | head -1)
    local repo=$(echo "$result" | tail -1)

    if [[ -n "$repo" ]]; then
      local full_path=$(ghq list --full-path --exact "$repo")

      if [[ "$key" == "ctrl-s" ]]; then
        echo "tmux_cwd_session $full_path"
        tmux_cwd_session "$full_path"
      else
        echo "cd $full_path"
        _execute_prompt "cd $full_path"
      fi
    fi
  fi
}

fzf_cd_worktree() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: Not in a git repository" >&2
    return 1
  fi

  local all_worktrees
  all_worktrees=$(git worktree list --porcelain | awk '/^worktree / { print substr($0, 10) }')

  local main_repo_root=$(echo "$all_worktrees" | head -1)
  local project_name=$(basename "$main_repo_root")
  local worktree_paths=$(echo "$all_worktrees" | tail -n +2)

  if [[ -z "$worktree_paths" ]]; then
    echo "No worktrees found"
    return 0
  fi

  local result=$(
    echo "$worktree_paths" |
    while read -r dir; do basename "$dir"; done |
    fzf \
      --height 50% \
      --reverse \
      --prompt='WORKTREE > ' \
      --header='| cd: <cr> | tmux session: <C-s> | delete: <C-d> |' \
      --expect=ctrl-s,ctrl-d \
      --preview="git -C ${main_repo_root}/.worktree/{} pretty-log"
  )

  if [[ -n "$result" ]]; then
    local key=$(echo "$result" | head -1)
    local selected=$(echo "$result" | tail -1)

    if [[ -n "$selected" ]]; then
      local full_path="${main_repo_root}/.worktree/${selected}"
      local session_name="${project_name}+${selected}"
      session_name="${session_name//./_}"

      if [[ "$key" == "ctrl-d" ]]; then
        echo "Removing: ${session_name}"
        git worktree remove --force "$full_path"
        tmux kill-session -t "$session_name" 2>/dev/null
      elif [[ "$key" == "ctrl-s" ]]; then
        echo "tmux session: ${session_name}"
        tmux_cwd_session "$full_path" "$session_name"
      else
        echo "cd: ${session_name}"
        _execute_prompt "cd $full_path"
      fi
    fi
  fi
}

fzf_git_log() {
  local command="git pretty-log"
  [[ "$#" -gt 0 ]] && command="git pretty-log $1"

  local input_commit_hash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
  local preview_commit="$input_commit_hash | xargs -I % git show -m % | DELTA_FEATURES='single-column' delta"
  local show_commit="$input_commit_hash | xargs -I % git show -m % | delta --paging=always"
  local checkout_commit="$input_commit_hash | xargs -I % git switch -d %"
  local copy_commit_hash="$input_commit_hash | clipboard --yank"

  eval "$command" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
      --preview="$preview_commit" \
      --header='| show: <cr> | checkout: <C-x> | yank: <C-y> |' \
      --bind='j:down+down,k:up+up,d:half-page-down,u:half-page-up,q:accept,esc:accept,change:clear-query' \
      --bind "enter:execute:$show_commit" \
      --bind "ctrl-x:become:$checkout_commit" \
      --bind "ctrl-y:execute:$copy_commit_hash" \
      >/dev/null
}

awsp() {
  local profile
  profile=$(
    aws configure list-profiles |
      fzf --ansi --no-sort --reverse --tiebreak=index \
        --height 20% \
        --prompt='SWITCH AWS PROFILE > '
  )

  if [[ -n "$profile" ]]; then
    export AWS_PROFILE="$profile"
    echo "export AWS_PROFILE=\"$profile\""
  else
    unset AWS_PROFILE
    echo "unset AWS_PROFILE"
  fi
}

completions_generate() {
  local completions_dir="$ZDOTDIR/completions"
  if [[ ! -d "$completions_dir" ]]; then
    mkdir -p "$completions_dir"
  fi

  chezmoi completion zsh --output="${completions_dir}/_chezmoi"
  deno completions zsh >"${completions_dir}/_deno"
  asdf completion zsh >"${completions_dir}/_asdf"
  gh completion -s zsh >"${completions_dir}/_gh"
}

tmux_cwd_session() {
  local target_dir="${1:-$PWD}"
  local session_name="${2:-$(basename "$target_dir")}"

  if [[ -z "$TMUX" ]]; then
    # Outside tmux: create a new session or attach to an existing one
    tmux new -s "$session_name" -c "$target_dir" 2>/dev/null || tmux attach -t "$session_name"
  else
    # Inside tmux: create a new session and switch to it
    if tmux has-session -t "$session_name" 2>/dev/null; then
      tmux switch-client -t "$session_name"
    else
      tmux new-session -d -s "$session_name" -c "$target_dir"
      tmux switch-client -t "$session_name"
    fi
  fi
}

_update_prompt() {
  local cmd="$1"

  if [[ -n "$WIDGET" ]]; then
    BUFFER="$cmd"
    CURSOR=${#BUFFER}
    zle reset-prompt
  else
    print -z "$cmd"
  fi
}

_execute_prompt() {
  local cmd="$1"

  if [[ -n "$WIDGET" ]]; then
    BUFFER="$cmd"
    CURSOR=${#BUFFER}
    zle accept-line
  else
    print -s "$cmd"
    echo "$cmd"
    eval "$cmd"
  fi
}
