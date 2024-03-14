local asdf_sh="$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh"
local site_functions="$HOMEBREW_PREFIX/opt/asdf/share/zsh/site-functions"
local java_sh="$HOME/.asdf/plugins/java/set-java-home.zsh"

if [ -e "$asdf_sh" ]; then
  source $asdf_sh
fi

if [ -d "$site_functions" ]; then
  fpath=(
    $site_functions
    $fpath
  )
fi

if [ -e "$java_sh" ]; then
  source $java_sh
fi
