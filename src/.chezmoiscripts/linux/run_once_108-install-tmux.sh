#!/usr/bin/env bash
set -euxo pipefail

TMUX_VERSION="3.5a"

main() {
  echo "Installing tmux ${TMUX_VERSION} from source..."
  local workdir
  workdir=$(mktemp -d)
  cd "$workdir"

  curl -fsSL -o tmux.tar.gz \
    "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz"
  tar xzf tmux.tar.gz
  cd "tmux-${TMUX_VERSION}"

  ./configure --prefix=/usr/local
  make
  sudo make install

  rm -rf "$workdir"
  echo "tmux $(tmux -V) installed."
}

main
