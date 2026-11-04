#!/usr/bin/env bash
set -euxo pipefail

main() {
  if command -v uv &>/dev/null; then
    echo "uv is already installed: $(uv --version)"
    return
  fi

  curl --proto '=https' --tlsv1.2 -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
  "$HOME/.local/bin/uv" --version
}

main
