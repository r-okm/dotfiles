#!/bin/sh

cd `dirname $0`

chezmoi_data_file="$HOME/.config/chezmoi/chezmoi.toml"
if [ ! -f $chezmoi_data_file ]; then
  mkdir -p $(dirname $chezmoi_data_file)
  cat << EOF > $chezmoi_data_file
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
fi

sh -c "$(curl -fsLS chezmoi.io/get)" -- init --apply -S .
