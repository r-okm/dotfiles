#!/usr/bin/env zsh
set -euxo pipefail

packages=(
  'bat'
  'fd-find'
  'git-delta'
  'ripgrep'
)

main() {
  echo 'Installing Rust packages...'

  cargo install --locked "${packages[@]}"
}

main
