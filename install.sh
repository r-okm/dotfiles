#!/bin/sh

cd `dirname $0`

# generate chezmoi config file
chezmoi_data_file="$HOME/.config/chezmoi/chezmoi.toml"
if [ ! -f $chezmoi_data_file ]; then
  mkdir -p $(dirname $chezmoi_data_file)
  cat ./templates/chezmoi.toml > $chezmoi_data_file
fi

# install chezmoi then apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
$HOME/.local/bin/chezmoi init --apply -S .

# install apps via apt
sudo apt update

sudo apt-get install -y fzf
sudo apt-get install -y jq
sudo apt-get install -y ripgrep
sudo apt-get install -y zsh

# bat
sudo apt-get install -y bat
# apt 経由でインストールすると､パッケージ名衝突を防ぐために､ batcat という名前でインストールされることがある
if type "batcat" > /dev/null 2>&1; then
  ln -s $(which  batcat) ~/.local/bin/bat
fi

# gh
type -p curl >/dev/null || sudo apt install curl -y
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt-get install -y gh

# neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
./squashfs-root/AppRun --version
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
rm -r nvim.appimage
