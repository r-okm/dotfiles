# dotfiles

## Prerequisites

- curl
- git

## Install

```sh
git clone https://github.com/r-okm/dotfiles.git ~/.local/share/chezmoi
sh ~/.local/share/chezmoi/install.sh
```

## Change login shell

```sh
chsh -s $(which zsh)
```

## Configure machine specific data

edit data file

```sh
$EDITOR ~/.config/chezmoi/chezmoi.toml
```

apply edited data

```sh
chezmoi apply
```
