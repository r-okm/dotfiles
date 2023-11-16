#!/bin/bash
set -e
set -x

# install prerequisites
sudo apt update
sudo apt install -y build-essential procps curl file git

# install chezmoi then apply dotfiles
TMP_DIR='/tmp'
CHEZMOI_BIN="$TMP_DIR/chezmoi"
GITHUB_USERNAME='r-okm'

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $TMP_DIR
$CHEZMOI_BIN init $GITHUB_USERNAME --apply

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
