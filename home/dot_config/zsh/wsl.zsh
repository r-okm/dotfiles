# alias
alias clip='/mnt/c/Windows/system32/clip.exe'
alias explorer='/mnt/c/Windows/explorer.exe'

# Completion
fpath=(
  $(brew --prefix)/share/zsh/site-functions
  $(brew --prefix asdf)/etc/bash_completion.d
  ${fpath}
)

# Application specific settings
# asdf
source $(brew --prefix)/opt/asdf/libexec/asdf.sh
# direnv
eval "$(direnv hook zsh)"

# ========================== zsh-hooks ==========================
precmd() {
  # 前回のコマンドの終了コードを記録
  export PREVIOUS_EXIT_CODE=$?

  # git の状態を環境変数に記録
  save-git-status-to-env

  # Promptの更新
  PROMPT=`prompt-format`

  # 初回起動時以外､改行する
  if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
      NEW_LINE_BEFORE_PROMPT=1
  elif [ "$NEW_LINE_BEFORE_PROMPT" -eq 1 ]; then
      echo ""
  fi
}

# ========================== functions ==========================
# Prompt
prompt-format() {
  local reset='%{\e[0m%}' # reset

  if [ $PWD = $HOME ]; then
    local dir_symbol='⟰'
  else
    local dir_symbol='🖿'
  fi
  local result="%F{yellow}${dir_symbol}  %~%f "

  # git管理されているかどうか
  if [ $IS_GIT_DIR -ne 0 ]; then
    if [ -n "$CUR_BRANCH_NAME" ]; then
      local branch_symbol="\ue0a0"
      local output="${branch_symbol} ${CUR_BRANCH_NAME}"
    else
      local detached_symbol="➦"
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
  result+="[${color}${PREVIOUS_EXIT_CODE}${reset}]\n%# "

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

# node_modules 以下の bin を PATH に追加するための direnv 設定ファイルを作成する
nodepath() {
  echo 'export PATH="$(npm bin):$PATH"' >> .envrc
  direnv allow
}

