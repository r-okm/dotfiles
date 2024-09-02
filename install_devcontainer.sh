#!/usr/bin/env bash

set -euxo pipefail

# install chezmoi then apply dotfiles
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
PATH="$BIN_DIR:$PATH"

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN_DIR"
chezmoi apply

# install linuxbrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install tools with brew
/home/linuxbrew/.linuxbrew/bin/brew install \
  bat \
  fd \
  fzf \
  git-delta \
  lazygit \
  neovim \
  ripgrep \
  zsh
