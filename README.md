# dotfiles

## Install

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/r-okm/dotfiles/main/install.sh)"
```

## Change login shell

```sh
zsh_bin='/home/linuxbrew/.linuxbrew/bin/zsh'
echo $zsh_bin | sudo tee -a /etc/shells
chsh -s $(echo $zsh_bin)
```

## Insert value to chezmoi data file

edit data file

```sh
$EDITOR ~/.config/chezmoi/chezmoi.toml
```

apply edited data

```sh
chezmoi apply
```
