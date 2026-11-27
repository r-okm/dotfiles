#!/usr/bin/env bash
set -euxo pipefail

# https://learn.microsoft.com/dotnet/core/tools/dotnet-install-script
CHANNEL='10.0'
INSTALL_DIR="$HOME/.dotnet"

main() {
  if ! ldconfig -p 2>/dev/null | grep 'libicuuc\.so' >/dev/null; then
    echo 'WARNING: libicu is not installed. .NET needs it at runtime; install it with apt (e.g. libicu70 on Ubuntu 22.04).' >&2
  fi

  if "$INSTALL_DIR/dotnet" --list-runtimes 2>/dev/null | grep "^Microsoft\.NETCore\.App ${CHANNEL//./\\.}\." >/dev/null; then
    echo ".NET runtime ${CHANNEL} is already installed: $("$INSTALL_DIR/dotnet" --list-runtimes)"
    return
  fi

  curl -fsSL https://dot.net/v1/dotnet-install.sh |
    bash -s -- --channel "$CHANNEL" --runtime dotnet --install-dir "$INSTALL_DIR" --no-path
  "$INSTALL_DIR/dotnet" --list-runtimes
}

main
