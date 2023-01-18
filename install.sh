#!/bin/sh

cd `dirname $0`

chezmoi_data_file="$HOME/.config/chezmoi/chezmoi.toml"
if [ ! -f $chezmoi_data_file ]; then
  mkdir -p $(dirname $chezmoi_data_file)
  cat ./templates/chezmoi.toml > $chezmoi_data_file
fi

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
$HOME/.local/bin/chezmoi init --apply -S .
