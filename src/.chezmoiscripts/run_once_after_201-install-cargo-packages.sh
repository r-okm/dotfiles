#!/usr/bin/env -S zsh -l
set -euxo pipefail

packages=(
  'bat'
  'eza'
  'fd-find'
  'git-delta'
  'oxker'
  'ripgrep'
)

main() {
  echo 'Installing cargo packages...'

  cargo install --locked "${packages[@]}"
}

main
