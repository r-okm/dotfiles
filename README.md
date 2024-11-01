# dotfiles

## Apply dotfiles

- dotfiles only

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/r-okm/dotfiles/main/install.sh)"
```

- dotfiles and nvim-config (git required)

```sh
INSTALL_NVIM_CONFIG=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/r-okm/dotfiles/main/install.sh)"
```

## Change login shell

```sh
zsh_bin='/home/linuxbrew/.linuxbrew/bin/zsh'
echo $zsh_bin | sudo tee -a /etc/shells
chsh -s $zsh_bin
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

## Install linuxbrew and packages

```sh
# install linuxbrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# restore brew bundle
export HOMEBREW_BUNDLE_FILE="$HOME/.config/homebrew/.Brewfile"
/home/linuxbrew/.linuxbrew/bin/brew bundle
```

## Install docker

```sh
sudo apt-get update
sudo apt-get install -y \
  ca-certificates \
  gnupg \
  lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-compose-plugin

sudo usermod -aG docker "$USER"
```
