#!/usr/bin/env bash
set -euxo pipefail

main() {
  local nvim_config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/nvim"
  if [[ ! -d $nvim_config_dir ]]; then
    git clone https://github.com/r-okm/nvim-config.git "$nvim_config_dir"
  fi
}

main
