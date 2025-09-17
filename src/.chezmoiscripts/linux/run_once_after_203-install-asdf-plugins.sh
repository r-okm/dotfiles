#!/usr/bin/env -S zsh -l
set -euo pipefail

TOOL_VERSIONS_FILE=${TOOL_VERSIONS_FILE:-"$HOME/.tool-versions"}

main() {
  echo 'Installing asdf plugins...'

  local installed_plugins
  installed_plugins=$(asdf plugin list)

  # Process tool_versions line by line
  while IFS= read -r line; do
    local plugin version
    read -r plugin version <<< "$line"

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
  done < "$TOOL_VERSIONS_FILE"
}

main
