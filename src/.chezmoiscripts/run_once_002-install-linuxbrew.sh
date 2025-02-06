#!/usr/bin/env bash
set -euxo pipefail

main() {
  # install linuxbrew
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # restore brew bundle
  export HOMEBREW_BUNDLE_FILE="$HOME/.config/homebrew/.Brewfile"
  /home/linuxbrew/.linuxbrew/bin/brew bundle
}

# main
