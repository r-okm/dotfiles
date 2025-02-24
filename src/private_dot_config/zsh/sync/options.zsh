# bindkey
bindkey -e
bindkey "^[[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

fzf_command_history() {
  BUFFER=$(history -n -r 1 | awk '!a[$0]++{print}' | grep -v "ls" | grep -v "cd" | fzf --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle reset-prompt
}

zle -N fzf_command_history
bindkey '^r' fzf_command_history

# zstyle
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# fpath
fpath=(
  $ZDOTDIR/completions(N-/)
  $fpath
)
