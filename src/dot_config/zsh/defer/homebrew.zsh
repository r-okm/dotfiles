if type 'brew' > /dev/null 2>&1; then
  fpath=(
    $HOMEBREW_PREFIX/share/zsh/site-functions
    $fpath
  )
fi
