#!/usr/bin/env bash
set -euxo pipefail

main() {
  for pkg in \
    docker.io \
    docker-doc \
    docker-compose \
    docker-compose-v2 \
    podman-docker \
    containerd \
    runc; do sudo apt remove $pkg; done
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh ./get-docker.sh
  sudo usermod -aG docker "$USER"
  rm get-docker.sh
}

main
