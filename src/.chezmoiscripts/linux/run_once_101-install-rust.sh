#!/usr/bin/env bash
set -euxo pipefail

main() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --no-update-default-toolchain --no-modify-path
}

main
