# dotfiles

## Install

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/r-okm/dotfiles/main/install.sh)"
```

## Change login shell

```sh
which zsh | sudo tee -a /etc/shells
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
