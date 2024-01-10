# bindkey
bindkey -e
bindkey "^[[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

zle -N fzf_command_history
bindkey '^r' fzf_command_history

# zstyle
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
