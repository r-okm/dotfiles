#!/usr/bin/env bash

completions_dir="${ZDOTDIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/zsh}/fpath"
if [[ ! -d "$completions_dir" ]]; then
  mkdir -p "$completions_dir"
fi

chezmoi completion zsh --output="${completions_dir}/_chezmoi"
