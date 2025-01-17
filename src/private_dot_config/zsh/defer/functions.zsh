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
    --preview="bat --color=always --style=auto $ghq_root/{}/README.md" \
  )
  if [ -n "$target_dir" ]; then
    local path=$ghq_root/$target_dir
    echo "cd $path"
    cd "$path"
  fi
}

fzf_fd_file() {
  local target_dir="."
  if [ -n "$1" ]; then
    target_dir="$1"
  fi

  local target_file=$(
    fd --type file \
      --hidden \
      --exclude .git \
      $target_dir \
    | fzf \
    --reverse \
    --prompt='GREP FILE > ' \
    --header='ENTER to edit' \
    --preview="bat --color=always --style=auto {}"
  )

  if [ -n "$target_file" ]; then
    $EDITOR "$target_file"
  fi
}

fzf_git_branch() {
  local_brs=$(git branch | sort -r | sed -e 's/^ *//') && \
  local_brs_trim=$(git branch | sed -e 's/\*//' | sed -e 's/ //g') && \
  remote_brs=$(git branch -r | grep -v HEAD | sed -e 's/^.* //g') && \

  remote_brs_trim=$(echo $remote_brs | sed -e 's/^.*\///')
  local_remote_brs=$(echo $local_brs_trim\\n$remote_brs_trim | sort | uniq -D)
  remote_only_brs=$(echo $local_remote_brs\\n$remote_brs_trim | sort | uniq -u)
  target_brs=$(echo $local_brs\\n$remote_brs\\n$remote_only_brs)

  get_branch_name="echo {} | tr -d ' *'"
  checkout_branch="$get_branch_name | xargs git checkout"
  delete_branch="$get_branch_name | xargs git branch -D"
  view_diff="$get_branch_name | xargs git diff"

  echo $target_brs |
  fzf --ansi --no-sort --reverse --tiebreak=index \
    --height 50% \
    --prompt='CHECKOUT BRANCH > '  \
    --header='ENTER to checkout, CTRL-d to view diff, CTRL-x to delete' \
    --preview-window='right,65%' \
    --preview="$get_branch_name | xargs -I % sh -c 'git fzf-log %'" \
    --bind "enter:become:$checkout_branch" \
    --bind "ctrl-x:become:$delete_branch" \
    --bind "ctrl-d:execute:$view_diff" \
}

fzf_git_log() {
  local command="git fzf-log"
  if [ "$1" = "--all" ]; then
    command="git fzf-log $1"
  fi

  local log_line_to_hash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % sh -c 'echo -n %'"
  local preview_commit="$log_line_to_hash | xargs -I % sh -c 'git show -m % | delta --features=fzf_git_log'"
  local show_commit="$log_line_to_hash | xargs -I % sh -c 'git show -m % | delta --features=git --paging=always'"
  local checkout_commit="$log_line_to_hash | xargs -I % sh -c 'git switch -d %'"
  local copy_commit_hash="$log_line_to_hash | xclip -selection clipboard"

  local result=$(
    eval "$command" | \
      fzf --ansi --no-sort --reverse --tiebreak=index \
        --preview=$preview_commit \
        --header='ENTER to view, CTRL-x to checkout, CTRL-y to copy hash, q to exit' \
        --bind='j:down,k:up,d:half-page-down,u:half-page-up,q:abort' \
        --bind "enter:execute:$show_commit" \
        --bind "ctrl-x:become:$checkout_commit" \
        --bind "ctrl-y:execute-silent:$copy_commit_hash"
  )
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

# local-ssl-proxy
local_ssl_proxy() {
  local source=${1:-8081}
  local target=${2:-8080}

  npx local-ssl-proxy --key ~/pem/localhost-key.pem --cert ~/pem/localhost.pem --source $source --target $target
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
