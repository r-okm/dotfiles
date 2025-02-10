#!/usr/bin/env -S zsh -l
set -euxo pipefail

packages=(
  'asdf-vm/asdf/cmd/asdf@v0.16.0'
  'junegunn/fzf@latest'
  'x-motemen/ghq@latest'
  'jesseduffield/lazygit@latest'
)

main() {
  echo 'Installing Go packages...'

  source ~/.zprofile
  env

  for p in "${packages[@]}"; do
    go install "github.com/${p}"
  done
}

main
