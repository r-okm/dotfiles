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

if [[ -f "$ZDOTDIR/plugins/manual/git-prompt.sh" ]]; then
  source "$ZDOTDIR/plugins/manual/git-prompt.sh"
  export GIT_PS1_ENABLE=1
  export GIT_PS1_SHOWDIRTYSTATE=1
fi

precmd() {
  if [[ "$GIT_PS1_ENABLE" = '1' ]]; then
    __git_ps1 "
%F{yellow}%~%f " "[%?]
%F{green}❯%f " "󰘬 %s "
  else
    PS1="
%F{yellow}%~%f [%?]
%F{green}❯%f "
  fi
}
