#!/usr/bin/env bash
set -euxo pipefail

install_nvim_config() {
  local NVIM_CONFIG_DIR="$HOME/.config/nvim"
  local REPO_URL='https://github.com/r-okm/nvim-config.git'

  git clone "$REPO_URL" "$NVIM_CONFIG_DIR"
}

main() {
  BIN_DIR="$HOME/.local/bin"
  mkdir -p "$BIN_DIR"
  PATH="$BIN_DIR:$PATH"

  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN_DIR"
  chezmoi apply

  [[ $INSTALL_NVIM_CONFIG -eq 1 ]] && install_nvim_config
}

main "$@"
