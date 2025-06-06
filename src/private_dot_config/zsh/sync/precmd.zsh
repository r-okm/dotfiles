windows_terminal_osc_9_9() {
  # Inform Terminal about shell current working directory
  # see: https://github.com/microsoft/terminal/issues/8166
  printf '\e]9;9;%s\e\' "$(wslpath -w "$(pwd)")"
}

windows_terminal_tab_title() {
  local current_dir=$(basename $PWD)
  echo -ne '\033]0;'"[$WSL_DISTRO_NAME] $current_dir"'\a'
}

if [[ -n "$WSL_DISTRO_NAME" ]] && [[ -x "$(command -v wslpath)" ]]; then
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd windows_terminal_osc_9_9
  add-zsh-hook precmd windows_terminal_tab_title
fi

SUCCESS=$'\n[%F{magenta}%D{%H:%M:%S}%f] %F{yellow}%~%f [%F{reset}%?%f]\n%F{green}❯%f '
FAILURE=$'\n[%F{magenta}%D{%H:%M:%S}%f] %F{yellow}%~%f [%F{red}%?%f]\n%F{red}❯%f '
PROMPT=%(?.$SUCCESS.$FAILURE)

unset SUCCESS FAILURE
