# vim: set ft=sh:

FUNCTIONS_IN_THIS_FILE=(
  'fzf_command_history'
  'fzf_cd'
  'fzf_cd_ghq'
  'fzf_git_log'
  'fzf_nvim_delete_sessions'
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

fzf_git_log() {
  local command="git pretty-log"
  [[ "$#" -gt 0 ]] && command="git pretty-log $1"

  local input_commit_hash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
  local preview_commit="$input_commit_hash | xargs -I % git show -m % | delta --features=fzf_git_log"
  local show_commit="$input_commit_hash | xargs -I % git show -m % | delta --features=git --paging=always"
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

fzf_nvim_delete_sessions() {
  local sessions_dir="$XDG_STATE_HOME/nvim/sessions"
  local session_file=$(
    fd . $sessions_dir \
      --type f \
      --extension vim |
      fzf --height 90% --reverse --prompt='DELETE SESSION > '
  )
  if [[ -n "$session_file" ]]; then
    echo "rm $session_file"
    rm "$session_file"
  fi
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
  local session_name=$(basename "$target_dir")

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
