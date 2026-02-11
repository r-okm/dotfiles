#!/usr/bin/env bash
set -euo pipefail

pane_id="$1"

tmux set-environment TMUX_PROMPT_PANE "$pane_id"
tmux display-popup -E -w 80% -h 60% \
  'prompts_dir="${XDG_CONFIG_HOME:-$HOME/.config}/prompts" && \
   selected=$(fd . "$prompts_dir" --type f --max-depth 1 | \
     xargs -n1 basename | \
     fzf --reverse --prompt="PROMPT > " --preview="cat $prompts_dir/{}") && \
   if [ -n "$selected" ]; then \
     target=$(tmux show-environment TMUX_PROMPT_PANE | cut -d= -f2) && \
     tmux load-buffer "$prompts_dir/$selected" && tmux paste-buffer -t "$target" -r; \
   fi'

# vim: set ft=sh:
