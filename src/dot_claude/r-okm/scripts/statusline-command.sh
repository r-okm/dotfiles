#!/bin/bash
# Claude Code status line
# Shows: model name | context usage/remaining | rate limit usage
# Configured by the statusline-setup agent. Use that agent again to make further changes.

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Dimmed ANSI colors (SGR 2 = faint), so the status line reads as secondary.
CYAN=$'\033[2;36m'
YELLOW=$'\033[2;33m'
MAGENTA=$'\033[2;35m'
GRAY=$'\033[2;37m'
RESET=$'\033[0m'

segments=()

if [ -n "$model" ]; then
  segments+=("${CYAN}${model}${RESET}")
fi

if [ -n "$used" ]; then
  if [ -n "$remaining" ]; then
    ctx=$(printf 'Ctx %.0f%% used (%.0f%% left)' "$used" "$remaining")
  else
    ctx=$(printf 'Ctx %.0f%% used' "$used")
  fi
  segments+=("${YELLOW}${ctx}${RESET}")
fi

rl=""
if [ -n "$five" ]; then
  rl="5h:$(printf '%.0f' "$five")%"
fi
if [ -n "$week" ]; then
  if [ -n "$rl" ]; then
    rl="${rl} 7d:$(printf '%.0f' "$week")%"
  else
    rl="7d:$(printf '%.0f' "$week")%"
  fi
fi
if [ -n "$rl" ]; then
  segments+=("${MAGENTA}${rl}${RESET}")
fi

sep="${GRAY} | ${RESET}"
out=""
for s in "${segments[@]}"; do
  if [ -z "$out" ]; then
    out="$s"
  else
    out="${out}${sep}${s}"
  fi
done

printf '%s' "$out"
