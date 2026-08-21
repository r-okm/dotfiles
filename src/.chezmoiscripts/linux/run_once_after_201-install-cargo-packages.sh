#!/usr/bin/env -S zsh -l
set -euo pipefail

packages=(
  'bat'
  'eza'
  'fd-find'
  'git-delta'
  'oxker@0.9.0'
  'ripgrep'
)

source_packages=(
  # prebuilt binaries require a newer glibc than Ubuntu 22.04 provides
  'tree-sitter-cli'
)

install_from_source() {
  local package="$1"
  shift
  if [[ "$package" == *@* ]]; then
    local name="${package%@*}"
    local version="${package#*@}"
    echo "Installing $name version $version from source..."
    cargo install --locked "$@" "$name" --version "$version"
  else
    echo "Installing $package latest version from source..."
    cargo install --locked "$@" "$package"
  fi
}

main() {
  echo 'Installing cargo packages...'

  if command -v cargo-binstall &>/dev/null; then
    echo 'Using cargo-binstall (prebuilt binaries)...'
    cargo binstall --no-confirm --locked "${packages[@]}"
  else
    echo 'cargo-binstall not found, falling back to cargo install...'
    for package in "${packages[@]}"; do
      install_from_source "$package"
    done
  fi

  echo 'Installing source-only cargo packages...'
  for package in "${source_packages[@]}"; do
    # --force: a broken prebuilt still counts as installed, so plain install skips it
    install_from_source "$package" --force
  done
}

main
