#!/usr/bin/env bash
set -euxo pipefail

main() {
  sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply r-okm
}

main
