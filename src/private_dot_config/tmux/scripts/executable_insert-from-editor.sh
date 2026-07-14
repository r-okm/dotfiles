#!/usr/bin/env bash
set -euo pipefail

# Inner mode: runs inside the split pane created below. The draft lives at a
# fixed path in ~/.cache so an edit interrupted by a crash (autowriteall) or
# cancelled with :cq reopens right where it left off; a sent draft is kept as
# last-sent.md for recovery.
if [ "${1:-}" = "--edit" ]; then
  pane_id="$2"
  dir="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-edit"
  draft="$dir/draft.md"
  mkdir -p "$dir"
  nvim -u "$XDG_CONFIG_HOME/nvim/init.tmux_edit.lua" "$draft"
  if [ -s "$draft" ]; then
    tmux load-buffer "$draft"
    tmux paste-buffer -t "$pane_id" -r
    mv "$draft" "$dir/last-sent.md"
  fi
  exit 0
fi

pane_id="$1"
pane_path="$2"

tmux split-window -v -l 15 -c "$pane_path" -t "$pane_id" "'$0' --edit '$pane_id'"

# vim: set ft=sh:
