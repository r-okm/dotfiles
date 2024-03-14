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

fzf_cd_cdpath() {
  local search_dirs=$(for p ($cdpath) ls -1 $p)
  local target_dir=$(echo $search_dirs | fzf --height 50% --reverse --prompt='CHANGE DIRECTORY > ') &&
  if [ -n "$target_dir" ]; then
    echo "cd $target_dir"
    cd "$target_dir"
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
  delete_branch="$get_branch_name | xargs git branch -D"
  checkout_branch="$get_branch_name | xargs git checkout"

  echo $target_brs |
  fzf --ansi --no-sort --reverse --tiebreak=index \
    --height 50% \
    --prompt='CHECKOUT BRANCH > '  \
    --header='ENTER to checkout, CTRL-d to delete' \
    --preview-window='right,65%' \
    --preview="$get_branch_name | xargs -I % sh -c 'git lg %'" \
    --bind "enter:become:$checkout_branch" \
    --bind "ctrl-d:become:$delete_branch"
}

fzf_git_log() {
  local log_line_to_hash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs -I % sh -c 'echo -n %'"
  local preview_commit="$log_line_to_hash | xargs -I % sh -c 'git show -m % | delta --features=fzf_git_log'"
  local show_commit="$log_line_to_hash | xargs -I % sh -c 'git show -m % | delta --features=git --paging=always'"
  local checkout_commit="$log_line_to_hash | xargs -I % sh -c 'git switch -d %'"
  local copy_commit_hash="$log_line_to_hash | $YANK_COMMAND"

  git lga | \
    fzf --ansi --no-sort --reverse --tiebreak=index \
      --preview=$preview_commit \
      --header='ENTER to view, CTRL-x to checkout, CTRL-y to copy hash, q to exit' \
      --bind='j:down,k:up,d:half-page-down,u:half-page-up,q:abort' \
      --bind "enter:execute:$show_commit" \
      --bind "ctrl-x:become:$checkout_commit" \
      --bind "ctrl-y:execute-silent:$copy_commit_hash"
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

custom_nvim() {
  # 引数が有る場合は、引数を指定して nvim を起動する
  if [ $# -gt 0 ]; then
    nvim $@
  # セッションファイルが存在する場合は、セッションファイルを読み込んで nvim を起動する
  elif [ -f $NEOVIM_SESSION_FILE_NAME ]; then
    nvim -S $NEOVIM_SESSION_FILE_NAME
  else
    nvim
  fi
}

# local-ssl-proxy
local_ssl_proxy() {
  local source=${1:-8081}
  local target=${2:-8080}

  npx local-ssl-proxy --key ~/pem/localhost-key.pem --cert ~/pem/localhost.pem --source $source --target $target
}

update_plugins() {
  if [ -x "$(command -v brew)" ]; then
    brew bundle
    brew update
  fi

  if [ -x "$(command -v apt)" ]; then
    sudo apt update
    sudo apt upgrade -y
  fi

  if [ -x "$(command -v scoop)" ]; then
    scoop update
    scoop status
  fi
}
