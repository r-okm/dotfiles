#!/usr/bin/env bash
set -euxo pipefail

main() {
  # Install chezmoi executable
  BIN_DIR="$HOME/.local/bin"
  [[ ! -d "$BIN_DIR" ]] && mkdir -p "$BIN_DIR"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN_DIR"
  CHEZMOI_BIN="$BIN_DIR/chezmoi"

  # Install dotfiles using chezmoi
  CHEZMOI_SOURCE_DIR="${XDG_SHARE_HOME:-$HOME/.local/share}/chezmoi"
  if [[ -d "$CHEZMOI_SOURCE_DIR" ]]; then
    $CHEZMOI_BIN apply
  else
    $CHEZMOI_BIN init r-okm --apply
  fi
}

main
