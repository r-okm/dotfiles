# alias
alias yank='/mnt/c/scoop/shims/win32yank.exe -i'
alias explorer='/mnt/c/Windows/explorer.exe'
alias code='/mnt/c/Program\ Files/Microsoft\ VS\ Code/bin/code'

# ========================== zsh-hooks ==========================
precmd() {
  # 前回のコマンドの終了コードを記録
  export PREVIOUS_EXIT_CODE=$?

  # git の状態を環境変数に記録
  save-git-status-to-env

  # Promptの更新
  PROMPT=`prompt-format`
}

# ========================== functions ==========================
# Prompt
prompt-format() {
  local reset='%{\e[0m%}' # reset

  local result='
%F{yellow}'
  if [ $PWD = $HOME ]; then
    local home_symbol='\uf015'
    result+="${home_symbol} "
  else
    local folder_symbol='\uf07c'
    result+="${folder_symbol}  %~"
  fi
  result+='%f '

  # git管理されているかどうか
  if [ $IS_GIT_DIR -ne 0 ]; then
    if [ -n "$CUR_BRANCH_NAME" ]; then
      local branch_symbol="\ufb2b"
      local output="${branch_symbol} ${CUR_BRANCH_NAME}"
    else
      local detached_symbol="\uf417"
      local output="${detached_symbol} ${CUR_COMMIT_HASH}"
    fi
    result+="on %F{magenta}${output}${GIT_STATUS}%f "
  fi

  # 前回の終了コードが0の場合
  if [ $PREVIOUS_EXIT_CODE -eq 0 ]; then
    local color="${reset}"
  else
    local color="%F{red}"
  fi
  result+="[${color}${PREVIOUS_EXIT_CODE}${reset}]\n$ "

  echo $result
}

# git の状態を環境変数に記録
save-git-status-to-env() {
  # git管理されていないかどうか
  git status --porcelain >/dev/null 2>&1
  if [ $? -ne 0 ];then
    export IS_GIT_DIR=0
    export CUR_BRANCH_NAME=""
    export CUR_COMMIT_HASH=""
    export GIT_STATUS=""
  else
    export IS_GIT_DIR=1
    export CUR_BRANCH_NAME=$(git branch --show-current 2>/dev/null)
    export CUR_COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null)
    if [ -n "$(git status --short 2>/dev/null)" ]; then
      export GIT_STATUS="*"
    else
      export GIT_STATUS=""
    fi
  fi
}
