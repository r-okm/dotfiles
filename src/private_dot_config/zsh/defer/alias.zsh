if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'
alias eza-ls='eza -ahlmM -F=always --color=always --icons=always --group-directories-first --time-style=relative'
# force zsh to show the complete history
alias history="history 0"
