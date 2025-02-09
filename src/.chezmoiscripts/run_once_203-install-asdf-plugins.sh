#!/usr/bin/env zsh
set -euo pipefail

main() {
  echo 'Installing asdf plugins...'

  local tool_versions installed_plugins
  tool_versions=$(cat ~/.local/share/chezmoi/src/symlink/asdf/dot_tool-versions)
  installed_plugins=$(asdf plugin list)

  # tool_versions を改行区切りで while ループで回す
  while IFS= read -r line; do
    local plugin version
    plugin=$(echo "$line" | cut -d ' ' -f 1)
    version=$(echo "$line" | cut -d ' ' -f 2)

    if echo "$installed_plugins" | grep -q "$plugin"; then
      echo "Plugin '$plugin' is already installed."
    else
      echo "Installing 'plugin:$plugin'"
      asdf plugin add "$plugin"
    fi

    if asdf list "$plugin" | grep -q "$version"; then
      echo "Version '$plugin:$version' is already installed."
    else
      echo "Installing '$plugin:$version'"
      asdf install "$plugin" "$version"
    fi
  done <<< "$tool_versions"
}

main
