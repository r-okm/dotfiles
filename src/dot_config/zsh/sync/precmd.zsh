# vim: set ft=sh:

prompt_format() {
  local branch=$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null) && \
    local commit=$(git rev-parse --short HEAD 2>/dev/null)
  local git=''
  if [ -n "${branch}" ]; then
    git="($branch) "
  elif [ -n "${commit}" ]; then
    git="($commit) "
  fi

  PROMPT="
%F{yellow}%3/%f ${git}%# "
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_format
