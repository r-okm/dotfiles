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

# wsl-vpnkit
if [ -n "$WSL_DISTRO_NAME" ]; then
  # https://github.com/sakai135/wsl-vpnkit
  sudo apt install -y iproute2 iptables iputils-ping dnsutils wget
  VERSION=v0.4.1
  WSL_VPNKIT_DIR="$HOME/wsl-vpnkit.d"
  mkdir -p $WSL_VPNKIT_DIR
  cd $WSL_VPNKIT_DIR

  wget https://github.com/sakai135/wsl-vpnkit/releases/download/$VERSION/wsl-vpnkit.tar.gz
  tar --strip-components=1 -xf wsl-vpnkit.tar.gz \
      app/wsl-vpnkit \
      app/wsl-gvproxy.exe \
      app/wsl-vm
  rm wsl-vpnkit.tar.gz

  sudo cp ./wsl-vpnkit.service /etc/systemd/system/
fi
