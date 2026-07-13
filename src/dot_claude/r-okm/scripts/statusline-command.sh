#!/bin/bash
# Claude Code status line, one line, pipe-separated:
#   model | context usage bar + used/total tokens | 5h rate-limit bar + reset time | 7d rate-limit bar + reset time
# Configured by the statusline-setup agent. Use that agent again to make further changes.

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // empty')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_used=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Labels are dimmed (SGR 2 = faint) so they read as secondary, while the bar
# fill uses a bright color so the indicator stays legible.
GRAY=$'\033[2;37m'
FILL=$'\033[92m'  # bright green: filled segments
TRACK=$'\033[90m' # bright-black (gray): empty segments
RESET=$'\033[0m'

BAR_WIDTH=10

# Repeat a character N times (N may be 0).
repeat() {
  local n=$1 ch=$2 out='' i
  for ((i = 0; i < n; i++)); do out+="$ch"; done
  printf '%s' "$out"
}

# Render a 10-segment bar for a percentage: "▮▮▮▮▯▯▯▯▯▯".
bar() {
  local pct=$1
  local filled empty
  filled=$(awk -v p="$pct" -v w="$BAR_WIDTH" 'BEGIN { f = int(p / 100 * w + 0.5); if (f > w) f = w; if (f < 0) f = 0; print f }')
  empty=$((BAR_WIDTH - filled))
  printf '%s%s%s%s%s' \
    "$FILL" "$(repeat "$filled" '▮')" \
    "$TRACK" "$(repeat "$empty" '▯')" "$RESET"
}

# Format a token count as thousands or millions: 87432 -> "87k", 1000000 -> "1m".
kfmt() {
  awk -v t="$1" 'BEGIN {
    k = int(t / 1000 + 0.5)
    if (k >= 1000) printf "%gm", int(t / 1000000 * 10 + 0.5) / 10
    else printf "%dk", k
  }'
}

# Format an epoch-seconds reset time; empty if unavailable.
reset_at() {
  local epoch=$1 fmt=$2
  [ -n "$epoch" ] && date -d "@$epoch" +"$fmt" 2>/dev/null
}

segments=()

# model
[ -n "$model" ] && segments+=("${GRAY}${model}${RESET}")

# context usage bar + used/total tokens
if [ -n "$ctx" ]; then
  seg="${GRAY}Ctx${RESET} $(bar "$ctx")"
  if [ -n "$ctx_used" ] && [ -n "$ctx_size" ]; then
    seg="${seg} ${GRAY}$(kfmt "$ctx_used")/$(kfmt "$ctx_size")${RESET}"
  fi
  segments+=("$seg")
fi

# 5h rate limit
if [ -n "$five" ]; then
  seg="${GRAY}5h${RESET} $(bar "$five")"
  r=$(reset_at "$five_reset" '%H:%M')
  [ -n "$r" ] && seg="${seg} ${GRAY}${r}${RESET}"
  segments+=("$seg")
fi

# 7d rate limit
if [ -n "$week" ]; then
  seg="${GRAY}7d${RESET} $(bar "$week")"
  r=$(reset_at "$week_reset" '%-m/%-d %H:%M')
  [ -n "$r" ] && seg="${seg} ${GRAY}${r}${RESET}"
  segments+=("$seg")
fi

# Join all segments on one line, separated by a dim pipe.
sep="${GRAY} | ${RESET}"
out=""
for s in "${segments[@]}"; do
  if [ -z "$out" ]; then out="$s"; else out="${out}${sep}${s}"; fi
done
printf '%s' "$out"
