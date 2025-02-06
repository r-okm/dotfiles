#!/usr/bin/env bash
set -euxo pipefail

main() {
  # install linuxbrew
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # restore brew bundle
  brew_bin='/home/linuxbrew/.linuxbrew/bin/brew'
  HOMEBREW_BUNDLE_FILE="$HOME/.config/homebrew/.Brewfile" $brew_bin bundle
}

main
