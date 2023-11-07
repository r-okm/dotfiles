#!/bin/bash

# install prerequisites
sudo apt update
sudo apt install -y build-essential procps curl file git

# install chezmoi then apply dotfiles
tmp_dir='/tmp'
chezmoi_bin="$tmp_dir/chezmoi"
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $tmp_dir
github_username='r-okm'
$chezmoi_bin init $github_username --apply

# install linuxbrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
