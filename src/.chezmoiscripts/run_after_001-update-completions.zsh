#! /usr/bin/env zsh

local completions_dir="${ZDOTDIR:-${HOME}/zsh}/fpath"
if [[ ! -d "$completions_dir" ]]; then
  mkdir -p "$completions_dir"
fi

chezmoi completion zsh --output="${completions_dir}/_chezmoi"

npm completion > "${ZDOTDIR:-${HOME}/zsh}/defer/npm-completion"
