#!/usr/bin/env bash

set -euxo pipefail

# install prerequisites
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  procps \
  curl \
  file \
  git \
  unzip

# install chezmoi then apply dotfiles
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
PATH="$BIN_DIR:$PATH"
GITHUB_USERNAME='r-okm'

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $BIN_DIR
chezmoi init $GITHUB_USERNAME --apply

# install linuxbrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# restore brew bundle
export HOMEBREW_BUNDLE_FILE="$HOME/.config/homebrew/.Brewfile"
/home/linuxbrew/.linuxbrew/bin/brew bundle

# change locale
LOCALE_JA='/usr/share/i18n/locales/ja_JP'
if [ -e "$LOCALE_JA" ]; then
  sudo localedef -i $LOCALE_JA -f UTF-8 /usr/lib/locale/ja_JP.UTF-8
  sudo localedef --add-to-archive /usr/lib/locale/ja_JP.UTF-8
  sudo localectl set-locale LANG=ja_JP.UTF-8
fi

# install docker
sudo apt-get install -y \
  ca-certificates \
  gnupg \
  lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-compose-plugin

sudo usermod -aG docker $USER
