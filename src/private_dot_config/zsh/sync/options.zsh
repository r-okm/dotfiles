# bindkey
bindkey -e
bindkey "^[[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# zstyle
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# fpath
fpath=(
  $ZDOTDIR/completions(N-/)
  $fpath
)
