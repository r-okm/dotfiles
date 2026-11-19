#!/usr/bin/env -S zsh -l
set -euxo pipefail

packages=(
  'asdf-vm/asdf/cmd/asdf@v0.20.0'
  'junegunn/fzf@latest'
  'x-motemen/ghq@latest'
  'jesseduffield/lazygit@latest'
  'zricethezav/gitleaks/v8@latest'
  # fork に残る upstream のタグ(v0.9.x)はモジュールパスが chrishrb/go-grip のままで、@latest では入らない。
  # @main では入れた時点の main に固定されて更新されないので、コミットを指定する。上げるときはここを書き換えると再実行される
  'r-okm/go-grip@7556c6a4f3d0d086a9e930834fd1d49443179b81'
)

main() {
  echo 'Installing Go packages...'

  for p in "${packages[@]}"; do
    go install "github.com/${p}"
  done
}

main
