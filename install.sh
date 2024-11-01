#!/usr/bin/env bash
set -euxo pipefail

install_nvim_config() {
  local NVIM_CONFIG_DIR="$HOME/.config/nvim"
  local REPO_URL='https://github.com/r-okm/nvim-config.git'

  git clone "$REPO_URL" "$NVIM_CONFIG_DIR"
}

main() {
  # Install chezmoi executable
  BIN_DIR="$HOME/.local/bin"
  mkdir -p "$BIN_DIR"
  PATH="$BIN_DIR:$PATH"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN_DIR"

  # Install dotfiles using chezmoi
  SOURCE_DIR="${XDG_SHARE_HOME:-$HOME/.local/share}/chezmoi"
  if [[ -d "$SOURCE_DIR" ]]; then
    chezmoi apply
  else
    GITHUB_USERNAME='r-okm'
    chezmoi init $GITHUB_USERNAME --apply
  fi

  [[ $INSTALL_NVIM_CONFIG -eq 1 ]] && install_nvim_config
}

main
