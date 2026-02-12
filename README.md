# dotfiles [![CI](https://github.com/r-okm/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/r-okm/dotfiles/actions/workflows/ci.yml)

r-okm's dotfiles managed with chezmoi.

## Installation

```sh
git clone https://github.com/r-okm/dotfiles.git
./install.sh
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
