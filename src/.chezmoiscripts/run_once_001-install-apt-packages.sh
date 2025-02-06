#!/usr/bin/env bash
set -euxo pipefail

apt_packages=(
  # basic tools
  'curl'
  'wget'
  'unzip'
  'make'
  'tree'
  'ca-certificates'
  # runtime
  'python3'
  # neovim build
  'ninja-build'
  'gettext'
  'cmake'
  'build-essential'
  'gcc'
  # wsl-ssh-agent
  'socat'
)

main() {
  echo 'Checking prerequisite apt packages...'
  sudo apt-get update -y

  missing_packages=()
  for package in "${apt_packages[@]}"; do
    if ! dpkg -l | grep -w "${package}" | awk "/${package}/ {print \$2}" | grep -w "^${package}$"; then
      missing_packages+=("${package}")
    fi
  done

  if [ ${#missing_packages[@]} -gt 0 ]; then
    echo "Installing missing packages: ${missing_packages[*]}"
    sudo apt-get install -y --no-install-recommends "${missing_packages[@]}"
    echo 'Finished installing missing packages.'
  else
    echo 'All packages are already installed.'
  fi
}

main
