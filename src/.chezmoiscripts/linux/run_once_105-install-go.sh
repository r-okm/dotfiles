#!/usr/bin/env bash
set -euxo pipefail

VERSIONS_JSON_URL='https://raw.githubusercontent.com/docker-library/golang/refs/heads/master/versions.json'
VERSION_KEY='1.25'
ARCH='amd64'

main() {
  echo "Fetching Go versions JSON from ${VERSIONS_JSON_URL}..."
  local versions_json url sha256
  versions_json=$(curl -fsSL "${VERSIONS_JSON_URL}")
  url=$(jq -r ".\"${VERSION_KEY}\".arches.${ARCH}.url" <<<"${versions_json}")
  sha256=$(jq -r ".\"${VERSION_KEY}\".arches.${ARCH}.sha256" <<<"${versions_json}")

  wget -O go.tgz.asc "$url.asc"
  wget -O go.tgz "$url" --progress=dot:giga
  echo "$sha256 *go.tgz" | sha256sum -c -

  # https://github.com/golang/go/issues/14739#issuecomment-324767697
  GNUPGHOME="$(mktemp -d)"
  export GNUPGHOME
  # https://www.google.com/linuxrepositories/
  gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC  EC91 7721 F63B D38B 4796'
  # let's also fetch the specific subkey of that key explicitly that we expect "go.tgz.asc" to be signed by, just to make sure we definitely have it
  gpg --batch --keyserver keyserver.ubuntu.com --recv-keys '2F52 8D36 D67B 69ED F998  D857 78BD 6547 3CB3 BD13'
  gpg --batch --verify go.tgz.asc go.tgz
  gpgconf --kill all
  rm -rf "$GNUPGHOME" go.tgz.asc

  sudo tar -C /usr/local -xzf go.tgz
  rm go.tgz
}

main
