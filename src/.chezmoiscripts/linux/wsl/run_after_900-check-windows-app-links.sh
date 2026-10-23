#!/usr/bin/env bash
set -euo pipefail

# The Windows executables WSL calls go through symlinks in ~/.local/bin, made
# by hand on each machine because where the installer puts them is the
# machine's business. A Windows-side update can move the target and leave the
# link dangling, so check them on every apply rather than at the next use.

links_dir="$HOME/.local/bin"

# <link name>|<what calls it>
links=(
  'git-credential-manager.exe|credential.helper in ~/.config/git/config'
  'gh.exe|the gh wrapper in ~/.local/bin'
  'npiperelay.exe|ssh-agent-relay.service'
  'vivaldi.exe|vivaldi.desktop and BROWSER in ~/.profile'
)

failed=0
for entry in "${links[@]}"; do
  name="${entry%%|*}"
  used_by="${entry#*|}"
  link="$links_dir/$name"

  if [[ -x "$link" ]]; then
    continue
  fi

  failed=1
  if [[ -L "$link" ]]; then
    echo "[ERROR] $link is dangling: $(readlink -- "$link") does not exist" >&2
  elif [[ -e "$link" ]]; then
    echo "[ERROR] $link exists but is not executable" >&2
  else
    echo "[ERROR] $link is missing" >&2
  fi
  echo "        used by $used_by; relink it: ln -sf <Windows-side $name> '$link'" >&2
done

exit "$failed"
