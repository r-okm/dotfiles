#!/usr/bin/env bash
set -euo pipefail

pane_id="$1"
pane_path="$2"

tmux set-environment TMUX_EDIT_PANE "$pane_id"
tmux split-window -v -l 15 -c "$pane_path" \
  'tmpfile=$(mktemp /tmp/tmux-edit-XXXXXX) && \
   nvim -u "$XDG_CONFIG_HOME/nvim/init.tmux_edit.lua" "$tmpfile" && \
   if [ -s "$tmpfile" ]; then \
     target=$(tmux show-environment TMUX_EDIT_PANE | cut -d= -f2) && \
     tmux load-buffer "$tmpfile" && tmux paste-buffer -t "$target" -r; \
   fi; \
   rm -f "$tmpfile"'

# vim: set ft=sh:
