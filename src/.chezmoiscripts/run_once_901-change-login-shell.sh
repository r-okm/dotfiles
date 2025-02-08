#!/usr/bin/env bash
set -euxo pipefail

shell_name='zsh'

main() {
  local shell_bin
  shell_bin=$(command -v "${shell_name}")

  if ! grep -q "${shell_bin}" /etc/shells; then
    echo "${shell_bin} is not in /etc/shells"
    echo "$shell_bin" | sudo tee -a /etc/shells
  else
    echo "${shell_bin} is already in /etc/shells"
  fi

  sudo chsh -s "$shell_bin" "$USER"
}

main
