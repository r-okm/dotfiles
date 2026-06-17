pwd_tab_title() {
  local short_path="${PWD/#$HOME/~}"
  local parts=("${(@s:/:)short_path}")
  local abbreviated=""
  local total=${#parts[@]}
  # 末尾ディレクトリ名の最大表示文字数（… を含む）
  local max_last=20

  # 最後のディレクトリ以外は頭文字のみに短縮
  for ((i=1; i<total+1; i++)); do
    if [[ -n "${parts[$i]}" ]]; then
      # 最後のディレクトリのみフル表示（長い場合は先頭を…で省略）
      if [[ $i -eq $total ]]; then
        local last="${parts[$i]}"
        if (( ${#last} > max_last )); then
          last="…${last: -$((max_last - 1))}"
        fi
        abbreviated+="/${last}"
      else
        # それ以外は先頭1文字（.で始まる場合は2文字）
        if [[ "${parts[$i]}" == .* ]]; then
          abbreviated+="/${parts[$i]:0:2}"
        else
          abbreviated+="/${parts[$i]:0:1}"
        fi
      fi
    fi
  done

  # Remove leading slash if path starts with ~
  if [[ "$short_path" == "~"* ]]; then
    abbreviated="~${abbreviated#/~}"
  fi

  print -Pn -- "\e]2;${abbreviated}\a"
}

current_cmd_tab_title() {
  print -Pn -- "\e]2;${1%% *}\a"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd pwd_tab_title
add-zsh-hook preexec current_cmd_tab_title

SUCCESS=$'\n[%F{magenta}%D{%H:%M:%S}%f] %F{yellow}%~%f [%F{reset}%?%f]\n%F{green}❯%f '
FAILURE=$'\n[%F{magenta}%D{%H:%M:%S}%f] %F{yellow}%~%f [%F{red}%?%f]\n%F{red}❯%f '
PROMPT=%(?.$SUCCESS.$FAILURE)

unset SUCCESS FAILURE
