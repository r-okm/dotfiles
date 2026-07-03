#!/usr/bin/env bash
set -euo pipefail

claude_session_name=$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}')
claude_window_index=$(tmux display-message -p -t "$TMUX_PANE" '#{window_index}')
target_session_id="${claude_session_name}:${claude_window_index}"

active_session_id=$(tmux display-message -p '#{session_name}:#{window_index}')

if [ "$target_session_id" = "$active_session_id" ]; then
  exit 0
fi

input=$(cat)
hook_event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty')

# Prevent infinite loop when Stop hook triggers continuation (exit code 2)
if [[ "$hook_event" == "Stop" ]]; then
  stop_hook_active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false')
  if [[ "$stop_hook_active" == "true" ]]; then
    exit 0
  fi
fi

MAX_BODY_LENGTH=200

body=""
case "$hook_event" in
  Stop)
    transcript_path=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
    if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
      prev_uuid=$(tac "$transcript_path" \
        | jq -r 'select(.type == "assistant") | .uuid' | head -1)
      delay=0.05
      for _ in {1..10}; do
        sleep "$delay"
        body=$(tail -20 "$transcript_path" \
          | jq -rs --arg prev "$prev_uuid" \
            '([.[] | select(.type == "assistant")] | last) as $msg |
             if $msg and $msg.uuid != $prev then
               [$msg.message.content[]? | select(.type == "text") | .text] | join("\n")
             else empty end' \
          2>/dev/null)
        if [[ -n "$body" ]]; then break; fi
        delay=$(awk "BEGIN{d=$delay*2; print (d>1?1:d)}")
      done
    fi
    ;;
  Notification)
    body=$(printf '%s' "$input" | jq -r '.message // empty')
    ;;
esac
body="${body:0:$MAX_BODY_LENGTH}"

title="Claude Code [${claude_session_name}:${claude_window_index}]"
desktop-notify "$title" "$body"

# vim: set ft=sh:
