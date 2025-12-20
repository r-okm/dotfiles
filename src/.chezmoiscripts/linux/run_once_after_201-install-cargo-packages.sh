#!/usr/bin/env -S zsh -l
set -euo pipefail

# Define packages with their versions (no @ needed for latest)
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
}

main
