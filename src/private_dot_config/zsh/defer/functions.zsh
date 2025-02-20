# vim: set ft=sh:

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

completions_generate() {
  local completions_dir="$ZDOTDIR/completions"
  if [[ ! -d "$completions_dir" ]]; then
    mkdir -p "$completions_dir"
  fi

  chezmoi completion zsh --output="${completions_dir}/_chezmoi.zsh"
  deno completions zsh >"${completions_dir}/_deno.zsh"
  asdf completion zsh >"${completions_dir}/_asdf.zsh"
}
