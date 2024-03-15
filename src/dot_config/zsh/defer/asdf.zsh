local asdf_sh="$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh"
local site_functions="$HOMEBREW_PREFIX/opt/asdf/share/zsh/site-functions"
local java_sh="$HOME/.asdf/plugins/java/set-java-home.zsh"

zsh-defer source_if_exists $asdf_sh

if [ -d "$site_functions" ]; then
  fpath=(
    $site_functions
    $fpath
  )
fi

zsh-defer source_if_exists $java_sh
