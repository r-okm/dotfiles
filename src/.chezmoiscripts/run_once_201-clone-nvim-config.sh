#!/usr/bin/env bash
set -euxo pipefail

main() {
  git clone https://github.com/r-okm/nvim-config.git "$HOME/.config/nvim"
}

main
