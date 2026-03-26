#!/usr/bin/env bash
set -euxo pipefail

main() {
  if command -v rustup &>/dev/null; then
    echo "Rust is already installed: $(rustup --version)"
    return
  fi

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --no-update-default-toolchain --no-modify-path
}

main
