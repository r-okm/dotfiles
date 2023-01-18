#!/bin/sh

if [ ! -d "~/.config/chezmoi"]; then
  mkdir -p ~/.config/chezmoi
fi

cat << EOF > ~/.config/chezmoi/chezmoi.toml
[merge]
  command = "nvim"
  args = ["-d", "{{ .Destination }}", "{{ .Source }}"]
[data]
  name_home = ""
  email_home = ""
  name_work = ""
  email_work = ""
  openai_api_key = ""
EOF
