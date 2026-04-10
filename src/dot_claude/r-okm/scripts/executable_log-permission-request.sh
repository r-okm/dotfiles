#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${HOME}/.claude/r-okm/logs"
LOG_FILE="${LOG_DIR}/permission-requests.jsonl"
MAX_LOG_SIZE=$((10 * 1024 * 1024)) # 10MB

mkdir -p "$LOG_DIR"

input=$(cat)

# Log rotation: rename when exceeding max size
if [[ -f "$LOG_FILE" ]]; then
  file_size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
  if ((file_size > MAX_LOG_SIZE)); then
    mv "$LOG_FILE" "${LOG_FILE%.jsonl}.$(date -u +%Y%m%dT%H%M%SZ).bak.jsonl"
  fi
fi

# Extract fields and append as JSONL (no stdout — passthrough)
jq -c --arg cwd "${PWD}" '{
  timestamp: (now | todate),
  session_id: .session_id,
  tool_name: .tool_name,
  tool_input_summary: (
    if .tool_name == "Bash" then
      {command: (.tool_input.command // "" | .[0:500]
        | gsub("(?<pfx>--password[= ]|--token[= ]|--secret[= ]|--key[= ]|Bearer |token=|password=|secret=|Authorization: ?)(?<val>[^ ]+)"; "\(.pfx)***"; "i"))}
    elif (.tool_name == "Read" or .tool_name == "Edit" or .tool_name == "Write") then
      {file_path: .tool_input.file_path}
    elif .tool_name == "Glob" then
      {pattern: .tool_input.pattern, path: .tool_input.path}
    elif .tool_name == "Grep" then
      {pattern: .tool_input.pattern, path: .tool_input.path}
    elif .tool_name == "WebFetch" then
      {url: .tool_input.url}
    elif .tool_name == "WebSearch" then
      {query: .tool_input.query}
    else
      {raw: (.tool_input | tostring | .[0:200])}
    end
  ),
  permission_suggestions: .permission_suggestions,
  cwd: (.cwd // $cwd),
  permission_mode: .permission_mode
}' <<< "$input" >> "$LOG_FILE" 2>/dev/null || true
