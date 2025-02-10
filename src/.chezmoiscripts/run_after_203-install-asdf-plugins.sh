#!/usr/bin/env -S zsh -l
set -euo pipefail

main() {
  echo 'Installing asdf plugins...'

  local tool_versions installed_plugins
  tool_versions=$(cat ~/.local/share/chezmoi/src/symlink/asdf/dot_tool-versions)
  installed_plugins=$(asdf plugin list)

  # Process tool_versions line by line
  while IFS= read -r line; do
    local plugin version
    plugin=$(echo "$line" | awk '{print $1}')
    version=$(echo "$line" | awk '{print $2}')

    if echo "$installed_plugins" | grep -Fq "$plugin"; then
      echo "Plugin '$plugin' is already installed."
    else
      echo "Installing 'plugin:$plugin'"
      asdf plugin add "$plugin"
    fi

    if asdf list "$plugin" | grep -Fq "$version"; then
      echo "Version '$plugin:$version' is already installed."
    else
      echo "Installing '$plugin:$version'"
      asdf install "$plugin" "$version"
    fi
  done <<< "$tool_versions"
}

main
