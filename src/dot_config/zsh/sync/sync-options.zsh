# precmd
autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_format_2
add-zsh-hook precmd windows_terminal_tab_title
add-zsh-hook precmd _windows_terminal_osc_9_9

# setopt
setopt nobeep
setopt nolistbeep
setopt correct
setopt auto_cd

# cdpath
cdpath=(
  $PROJECT_DIR
  $cdpath
)

# fpath
fpath=(
  $ZDOTDIR/fpath(N-/)
  $fpath
)
