#!/usr/bin/env bash
set -euxo pipefail

# Used by chrome-devtools-mcp (see run_onchange_after_205-register-claude-mcp-servers.sh.tmpl).
# https://www.google.com/linuxrepositories/
key_url='https://dl.google.com/linux/linux_signing_key.pub'
keyring='/etc/apt/keyrings/google-chrome.gpg'
list='/etc/apt/sources.list.d/google-chrome.list'
list_line="deb [arch=amd64 signed-by=$keyring] https://dl.google.com/linux/chrome/deb/ stable main"
# Written by the package's postinst, which also removes the bootstrap list above.
package_sources='/etc/apt/sources.list.d/google-chrome.sources'

remove_bootstrap_repository() {
  [ -f "$package_sources" ] || return 0

  if [ -f "$list" ]; then
    if [ "$(grep -v -E '^[[:space:]]*(#|$)' "$list")" != "$list_line" ]; then
      echo "Leaving $list alone: it has entries other than the Google Chrome one."
      return 0
    fi
    sudo rm -f "$list"
  fi

  if grep -rqF "$keyring" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
    echo "Leaving $keyring alone: another apt source still references it."
    return 0
  fi
  sudo rm -f "$keyring"
}

main() {
  if command -v google-chrome-stable &>/dev/null; then
    echo "Google Chrome is already installed: $(google-chrome-stable --version)"
    remove_bootstrap_repository
    return
  fi

  echo 'Installing Google Chrome...'
  sudo mkdir -p -m 755 /etc/apt/keyrings
  curl -fsSL "$key_url" | sudo gpg --dearmor --yes -o "$keyring"
  sudo chmod go+r "$keyring"
  echo "$list_line" | sudo tee "$list" >/dev/null
  sudo apt-get update
  sudo apt-get install -y google-chrome-stable

  remove_bootstrap_repository

  # Verify installation
  google-chrome-stable --version
}

main
