#!/usr/bin/env bash
set -euxo pipefail

# https://herdr.dev/tui/docs/install/
main() {
  if command -v herdr &>/dev/null; then
    echo "herdr is already installed: $(herdr --version)"
    return
  fi

  curl -fsSL https://herdr.dev/install.sh | sh
  "$HOME/.local/bin/herdr" --version
}

main
