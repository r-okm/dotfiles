#!/usr/bin/env -S zsh -l
set -euo pipefail

CARGO_BINSTALL_VERSION="1.17.8"

main() {
  echo "Installing cargo-binstall v${CARGO_BINSTALL_VERSION}..."

  local arch
  arch=$(uname -m)
  case "$arch" in
    x86_64)  arch="x86_64" ;;
    aarch64) arch="aarch64" ;;
    *) echo "Unsupported architecture: $arch" >&2; exit 1 ;;
  esac

  local url="https://github.com/cargo-bins/cargo-binstall/releases/download/v${CARGO_BINSTALL_VERSION}/cargo-binstall-${arch}-unknown-linux-musl.tgz"
  curl -L --proto '=https' --tlsv1.2 -sSf "$url" | tar xzf - -C "$HOME/.cargo/bin"

  echo "cargo-binstall v${CARGO_BINSTALL_VERSION} installed."
}

main
