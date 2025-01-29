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
  local ghq_root=$(ghq root)
  local target_dir=$(ghq list | fzf \
    --height 50% \
    --reverse \
    --prompt='CHANGE DIRECTORY > ' \
    --preview="tree $ghq_root/{} -aCFl -L 1 --dirsfirst --noreport" \
  )
  if [ -n "$target_dir" ]; then
    local path=$ghq_root/$target_dir
    echo "cd $path"
    cd "$path"
  fi
}

awsp() {
  local profile=$(
    aws configure list-profiles |
    fzf --ansi --no-sort --reverse --tiebreak=index \
      --height 20% \
      --prompt='SWITCH AWS PROFILE > '
  )

  if [ ! -z "$profile" ]; then
    export AWS_PROFILE="$profile"
    echo "export AWS_PROFILE=\"$profile\""
  else
    unset AWS_PROFILE
    echo "unset AWS_PROFILE"
  fi
}

update_plugins() {
  if [ -x "$(command -v chezmoi)" ]; then
    chezmoi upgrade
  fi

  if [ -x "$(command -v brew)" ]; then
    brew bundle
    brew update
  fi
}
