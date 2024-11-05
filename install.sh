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
  [[ ! -d "$BIN_DIR" ]] && mkdir -p "$BIN_DIR"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN_DIR"
  CHEZMOI_EXECUTABLE="$BIN_DIR/chezmoi"

  # Install dotfiles using chezmoi
  SOURCE_DIR="${XDG_SHARE_HOME:-$HOME/.local/share}/chezmoi"
  if [[ -d "$SOURCE_DIR" ]]; then
    $CHEZMOI_EXECUTABLE apply
  else
    GITHUB_USERNAME='r-okm'
    $CHEZMOI_EXECUTABLE init $GITHUB_USERNAME --apply
  fi

  # Install neovim config if needed
  [[ $INSTALL_NVIM_CONFIG -eq 1 ]] && install_nvim_config
}

main
