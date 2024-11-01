#!/usr/bin/env bash
set -euxo pipefail

main() {
  this_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  cd "$this_dir"
  INSTALL_NVIM_CONFIG=1 source ./install.sh
}

main
