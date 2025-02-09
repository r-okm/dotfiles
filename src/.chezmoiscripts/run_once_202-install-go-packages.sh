#!/usr/bin/env zsh
set -euxo pipefail

packages=(
  'asdf-vm/asdf/cmd/asdf@v0.16.0'
  'junegunn/fzf@latest'
  'x-motemen/ghq@latest'
  'jesseduffield/lazygit@latest'
)

main() {
  echo 'Installing Go packages...'

  for p in "${packages[@]}"; do
    go install "github.com/${p}"

    # Check if bin is installed
    local bin
    bin=$(echo "$p" | awk -F '[/@]' '{print $(NF-1)}')
    command -v "$bin"
  done
}

main
