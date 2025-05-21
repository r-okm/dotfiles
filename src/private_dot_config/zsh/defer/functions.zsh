# vim: set ft=sh:

FUNCTIONS_IN_THIS_FILE=(
  'fzf_command_history'
  'fzf_cd'
  'fzf_cd_hidden'
  'fzf_cd_ghq'
  'fzf_git_log'
  'fzf_nvim_delete_sessions'
  'awsp'
  'completions_generate'
)

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^e" edit-command-line

fzf_functions() {
  BUFFER=$(
    print -l -- "${FUNCTIONS_IN_THIS_FILE[@]}" \
      | fzf \
        --height 50% \
        --reverse \
        --prompt='FUNCTIONS > ' \
        --query "$LBUFFER"
  )
  CURSOR=${#BUFFER}
  zle reset-prompt
}

zle -N fzf_functions
bindkey '^f' fzf_functions

fzf_command_history() {
  local commands=$(
    history -n -r 1 \
      | awk '!seen[$0]++ && !/^(ls|eza)/' \
      | fzf \
        --height 50% \
        --reverse \
        --prompt='HISTORY > ' \
        --query "$LBUFFER"
  )
  BUFFER=$commands
  CURSOR=${#BUFFER}
  zle reset-prompt
}

zle -N fzf_command_history
bindkey '^r' fzf_command_history

fzf_cd() {
  local target_dir=$(fd --type directory \
    --exclude node_modules \
    . $@ | fzf --height 90% --reverse --prompt='CHANGE DIRECTORY > ') &&
    if [ -n "$target_dir" ]; then
      echo "cd $target_dir"
      cd "$target_dir"
    fi
}

fzf_cd_hidden() {
  local target_dir=$(fd --type directory \
    --exclude node_modules \
    --hidden \
    --no-ignore \
    . $@ | fzf --height 90% --reverse --prompt='CHANGE DIRECTORY > ') &&
    if [ -n "$target_dir" ]; then
      echo "cd $target_dir"
      cd "$target_dir"
    fi
}

fzf_cd_ghq() {
  local repo=$(
    ghq list | fzf \
      --height 50% \
      --reverse \
      --prompt='CHANGE DIRECTORY > ' \
      --preview="ghq list --full-path --exact {} | xargs -I {} eza-tree {} --git-ignore"
  )
  if [ -n "$repo" ]; then
    repo=$(ghq list --full-path --exact $repo)
    echo "cd $repo"
    cd "$repo"
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

  eval "$command" | \
    fzf --ansi --no-sort --reverse --tiebreak=index \
      --preview="$preview_commit" \
      --header='| show: <cr> | checkout: <C-x> | yank: <C-y> |' \
      --bind='j:down+down,k:up+up,d:half-page-down,u:half-page-up,q:accept,esc:accept,change:clear-query' \
      --bind "enter:execute:$show_commit" \
      --bind "ctrl-x:become:$checkout_commit" \
      --bind "ctrl-y:execute:$copy_commit_hash" \
      > /dev/null
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

eza_ls() {
  eza \
    -ahlmM \
    -F=always \
    --color=always \
    --icons=always \
    --group-directories-first \
    --time-style=relative \
    "$@"
}

eza_tree() {
  eza \
    -amMT \
    -L 2 \
    -F=always \
    --color=always \
    --icons=always \
    --group-directories-first \
    "$@"
}
