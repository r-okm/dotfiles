#!/usr/bin/env bash
set -euxo pipefail

main() {
  if command -v deno &>/dev/null; then
    echo "Deno is already installed: $(deno --version | head -1)"
    return
  fi

  curl -fsSL https://deno.land/install.sh | sh -s -- -y --no-modify-path
}

main
