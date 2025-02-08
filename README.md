# dotfiles

dotfiles managed by chezmoi

## Requirements

- curl

## Apply dotfiles

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply r-okm
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

## Related repositories

- [r-okm/nvim-config](https://github.com/r-okm/nvim-config)
