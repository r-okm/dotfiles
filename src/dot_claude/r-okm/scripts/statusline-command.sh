#!/bin/bash
# Claude Code status line, one line, pipe-separated:
#   model + effort | context usage bar + used/total tokens | prompt cache | 5h rate-limit bar + reset time | 7d rate-limit bar + reset time
# Configured by the statusline-setup agent. Use that agent again to make further changes.

input=$(cat)

# One jq pass, since refreshInterval re-runs this every few seconds. Fields are
# joined on US (0x1f), not a whitespace IFS character, so read keeps empty
# fields in place. null and false become empty.
IFS=$'\x1f' read -r model effort ctx ctx_used ctx_size five five_reset week week_reset \
  cache_hit cache_warm cache_at cache_resend cache_ttl session_id <<<"$(jq -r '[
    .model.display_name, .effort.level,
    .context_window.used_percentage, .context_window.total_input_tokens,
    .context_window.context_window_size,
    .rate_limits.five_hour.used_percentage, .rate_limits.five_hour.resets_at,
    .rate_limits.seven_day.used_percentage, .rate_limits.seven_day.resets_at,
    (.prompt_cache.hit_ratio | if . == null then null else . * 100 | floor end),
    .prompt_cache.warm, .prompt_cache.expires_at, .prompt_cache.recache_tokens_if_cold,
    .prompt_cache.ttl, .session_id
  ] | map(. // "" | tostring) | join("\u001f")' <<<"$input")"

# Labels are dimmed (SGR 2 = faint) so they read as secondary, while the bar
# fill uses a bright color so the indicator stays legible.
GRAY=$'\033[2;37m'
FILL=$'\033[92m'  # bright green: filled segments
TRACK=$'\033[90m' # bright-black (gray): empty segments
YELLOW=$'\033[33m' # prompt-cache warnings
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

# Format a duration in seconds as 1h12m, 1h or 38m (minutes rounded up).
span() {
  local m=$((($1 + 59) / 60))
  if ((m >= 60 && m % 60)); then
    echo "$((m / 60))h$((m % 60))m"
  elif ((m >= 60)); then
    echo "$((m / 60))h"
  else
    echo "${m}m"
  fi
}

# Format an epoch-seconds reset time; empty if unavailable.
reset_at() {
  local epoch=$1 fmt=$2
  [ -n "$epoch" ] && date -d "@$epoch" +"$fmt" 2>/dev/null
}

# Toast once per cache expiry that the prompt cache is about to go cold,
# through the WSL herdr plugin wsl-notify (absent elsewhere, so a no-op there).
# A state file per session holds the expires_at already notified; a later
# response moves expires_at and arms the next notification. Only for the 1h
# TTL: a 5m write starts inside the warning window, so every response would
# toast.
notify_cache_expiring() {
  local plugin=~/.local/share/r-okm/herdr-plugins/wsl-notify/wsl-notify.py
  local dir=${XDG_STATE_HOME:-$HOME/.local/state}/claude-cache-notify notified=""
  [ "$cache_ttl" = 1h ] || return
  [ -n "${HERDR_PANE_ID:-}" ] && [ -f "$plugin" ] || return
  [[ "$session_id" =~ ^[A-Za-z0-9-]+$ ]] || return
  read -r notified 2>/dev/null <"$dir/$session_id"
  [ "$notified" = "$cache_at" ] && return
  # The plugin forks and returns at once, so the status line does not wait. It
  # exits non-zero when it cannot start (no python3, a malformed pane ID); the
  # expiry is recorded only after a clean start, so a failure retries next run.
  python3 -I -B "$plugin" cache-expiring "$HERDR_PANE_ID" "$cache_at" </dev/null >/dev/null 2>&1 || return
  mkdir -p "$dir" && printf '%s\n' "$cache_at" >"$dir/$session_id"
  find "$dir" -type f -mtime +7 -delete 2>/dev/null
}

segments=()

# model + effort (effort is absent for models without effort support)
if [ -n "$model" ]; then
  seg="${GRAY}${model}${RESET}"
  [ -n "$effort" ] && seg="${seg} ${GRAY}${effort}${RESET}"
  segments+=("$seg")
fi

# context usage bar + used/total tokens
if [ -n "$ctx" ]; then
  seg="${GRAY}Ctx${RESET} $(bar "$ctx")"
  if [ -n "$ctx_used" ] && [ -n "$ctx_size" ]; then
    seg="${seg} ${GRAY}$(kfmt "$ctx_used")/$(kfmt "$ctx_size")${RESET}"
  fi
  segments+=("$seg")
fi

# Prompt cache, after localixai/tokendoctor's status line: how long it stays
# warm, the hit rate only when it is low, a warning in its last five minutes,
# and once cold, how many tokens the next message re-sends. The countdown only
# moves while idle because settings.json sets statusLine.refreshInterval. The
# warning also raises a toast through herdr (notify_cache_expiring).
if [ -n "$cache_hit" ]; then
  printf -v now '%(%s)T' -1
  left=$(( ${cache_at:-0} - now ))
  low=""
  [ "$cache_hit" -lt 80 ] && low=" ${YELLOW}${cache_hit}% hit${RESET}"
  if [ "$cache_warm" != true ]; then
    seg="${YELLOW}Cache cold, resend $(kfmt "${cache_resend:-${ctx_used:-0}}")${RESET}"
  elif [ "$left" -gt 300 ]; then
    seg="${GRAY}Cache $(span "$left")${RESET}${low}"
  elif [ "$left" -gt 0 ]; then
    seg="${YELLOW}Cache cold in $(span "$left")${RESET}${low}"
    notify_cache_expiring
  else
    seg="${GRAY}Cache${RESET}${low}"
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
