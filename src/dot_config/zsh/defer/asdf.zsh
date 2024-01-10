if [ -e "$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh" ]; then
  zsh-defer source $HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh

  if type 'brew' > /dev/null 2>&1; then
  fpath=(
    $(brew --prefix asdf)/etc/bash_completion.d
    $fpath
  )
  fi
fi

if [ -e "$HOME/.asdf/plugins/java/set-java-home.zsh" ]; then
  zsh-defer source $HOME/.asdf/plugins/java/set-java-home.zsh
fi
