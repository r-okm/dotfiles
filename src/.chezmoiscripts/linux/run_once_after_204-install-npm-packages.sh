#!/usr/bin/env -S zsh -l
set -euxo pipefail

packages=(
  'copilot'
  'sfw'
  'yarn'
)

main() {
  echo 'Installing npm packages...'

  npm install -g --force "${packages[@]}"

  asdf reshim
}

main
