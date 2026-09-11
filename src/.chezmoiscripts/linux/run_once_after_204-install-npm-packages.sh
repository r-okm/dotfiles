#!/usr/bin/env -S zsh -l
set -euxo pipefail

packages=(
  'sfw'
)

main() {
  echo 'Installing npm packages...'

  npm install -g --force "${packages[@]}"

  asdf reshim
}

main
