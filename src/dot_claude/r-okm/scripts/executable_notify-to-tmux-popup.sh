#!/usr/bin/env bash
set -euo pipefail

# Get the session and window where this script is invoked (using $TMUX_PANE
# to resolve the pane that spawned the process, not the currently active one)
claude_session_name=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}')
claude_window_index=$(tmux display-message -p -t "$TMUX_PANE" '#{window_index}')
target_session_id="${claude_session_name}:${claude_window_index}"

# Check if the user is already on this window
active_session_id=$(tmux display-message -p '#{session_name}:#{window_index}')

if [ "$target_session_id" = "$active_session_id" ]; then
  exit 0
fi

# Truncate long session names for display
display_session="$claude_session_name"
if [ ${#display_session} -gt 10 ]; then
  display_session="$(printf '%.9s~' "$claude_session_name")"
fi

tmux display-popup -E -w 30 -h 7 "\
  echo ''; \
  printf '%*s\n' $(((29+24)/2)) 'Claude notification in ${display_session}:${claude_window_index}'; \
  echo ''; \
  printf '%*s' $(((29+20)/2)) 'Go to window? (y/n) '; \
  read answer; \
  if [ \"\$answer\" = 'y' ]; then \
    tmux switch-client -t '${target_session_id}'; \
  fi"

# vim: set ft=sh:
