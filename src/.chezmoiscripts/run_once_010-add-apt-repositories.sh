#!/usr/bin/env bash
set -euxo pipefail

repositories=(
  'ppa:git-core/ppa'
)

main() {
  echo 'Adding apt repositories...'

  for repo in "${repositories[@]}"; do
    sudo add-apt-repository -y "$repo"
  done

  echo 'Upgrading packages...'
  sudo apt update && sudo apt upgrade -y
}

main
