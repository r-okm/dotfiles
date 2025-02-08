#!/usr/bin/env bash
set -euxo pipefail

main() {
  echo 'Installing the HashiCorp GPG key...'
  wget -O- https://apt.releases.hashicorp.com/gpg |
    gpg --dearmor |
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null

  echo "Verify the key's fingerprint..."
  gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

  echo 'Adding the HashiCorp apt repository...'
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
    sudo tee /etc/apt/sources.list.d/hashicorp.list

  echo 'Installing Terraform...'
  sudo apt update && sudo apt install terraform
}

main
