#!/usr/bin/env bash
set -euo pipefail

window_name="_toggle"

current_window=$(tmux display-message -p '#{window_name}')
if [ "$current_window" = "$window_name" ]; then
  tmux last-window
else
  tmux select-window -t "$window_name" || tmux new-window -n "$window_name"
fi

# vim: set ft=sh:
