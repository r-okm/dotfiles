# dotfiles

## Apply dotfiles

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/r-okm/dotfiles/main/install.sh)"
```

## Update machine-specific settings using chezmoi data

1. edit chezmoi data file

   ```sh
   vi ~/.config/chezmoi/chezmoi.toml
   ```

1. apply edited data

   ```sh
   chezmoi apply
   ```

## Change login shell

```sh
zsh_bin='/home/linuxbrew/.linuxbrew/bin/zsh'
echo $zsh_bin | sudo tee -a /etc/shells
chsh -s $zsh_bin
```

## Related repositories

- [r-okm/nvim-config](https://github.com/r-okm/nvim-config)
