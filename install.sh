#!/usr/bin/env bash
set -euxo pipefail

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
}

main
