#!/usr/bin/env bash
set -euxo pipefail

main() {
  curl -fsSL https://deno.land/install.sh | sh -s -- -y --no-modify-path
}

main
