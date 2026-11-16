#!/usr/bin/env bash
# SessionStart hook: report the repository name of the session's directory to herdr as the
# pane token $repo, which the claude row of [ui.sidebar.agents.rows_by_agent] in herdr's config.toml shows.
# Linked worktrees (.worktree/<name>, .claude/worktrees/<name>) report their main repository.
# Outside a git repository the directory name is reported instead.
set -uo pipefail

[[ -n "${HERDR_PANE_ID:-}" ]] || exit 0
command -v herdr >/dev/null 2>&1 || exit 0

# Windows: jq.exe prints CRLF and a native path, which basename would not split
cwd=$(jq -r '.cwd // empty' 2>/dev/null | tr -d '\r')
cwd=${cwd:-$PWD}
cwd=${cwd//\\//}

if common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
  if [[ "$(basename "$common")" == ".git" ]]; then
    repo=$(basename "$(dirname "$common")")
  else
    repo=$(basename "$common" .git) # bare repository
  fi
else
  repo=$(basename "$cwd")
fi

# display only, so the session does not wait for herdr
timeout 5 herdr pane report-metadata "$HERDR_PANE_ID" \
  --source claude-repo --token "repo=$repo" >/dev/null 2>&1 &
exit 0
