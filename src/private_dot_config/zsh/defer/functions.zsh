# vim: set ft=sh:

FUNCTIONS_IN_THIS_FILE=(
  'fzf_cd'
  'fzf_cd_hidden'
  'fzf_cd_ghq'
  'fzf_nvim_delete_sessions'
  'completions_generate'
)

fzf_functions() {
  BUFFER=$(
    print -l -- "${FUNCTIONS_IN_THIS_FILE[@]}" | fzf \
      --height 50% \
      --reverse \
      --prompt='FUNCTIONS > ' \
      --query "$LBUFFER"
  )
  CURSOR=$#BUFFER
  zle reset-prompt
}

zle -N fzf_functions
bindkey '^f' fzf_functions

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
