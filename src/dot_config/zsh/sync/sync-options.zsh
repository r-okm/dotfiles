# vim: set ft=sh:

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
