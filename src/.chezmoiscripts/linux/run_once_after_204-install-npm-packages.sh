#!/usr/bin/env -S zsh -l
set -euxo pipefail

packages=(
  'yarn'
)

main() {
  echo 'Installing npm packages...'

  npm install -g "${packages[@]}"

  asdf reshim
}

main
