#!/usr/bin/env -S zsh -l
set -euo pipefail

packages=(
  'bat'
  'eza'
  'fd-find'
  'git-delta'
  'oxker@0.9.0'
  'ripgrep'
  'tree-sitter-cli'
)

main() {
  echo 'Installing cargo packages...'

  if command -v cargo-binstall &>/dev/null; then
    echo 'Using cargo-binstall (prebuilt binaries)...'
    cargo binstall --no-confirm "${packages[@]}"
  else
    echo 'cargo-binstall not found, falling back to cargo install...'
    for package in "${packages[@]}"; do
      if [[ "$package" == *@* ]]; then
        name="${package%@*}"
        version="${package#*@}"
        echo "Installing $name version $version..."
        cargo install --locked "$name" --version "$version"
      else
        echo "Installing $package latest version..."
        cargo install --locked "$package"
      fi
    done
  fi
}

main
