#!/usr/bin/env bash
set -euo pipefail

# Print the directory where Claude keeps files worth keeping past the session
# for the current project and session. The directory is not created here.

usage() {
  cat <<'EOF'
Usage: claude-ai-dir.sh

Print the per-session AI work directory of the current Claude Code session:
  <git_root>/.ignore/ai/<CLAUDE_CODE_SESSION_ID>

Fails outside a git repository or outside a Claude Code session.
EOF
}

die() {
  echo "claude-ai-dir: $*" >&2
  exit 1
}

case "${1:-}" in
  -h | --help)
    usage
    exit 0
    ;;
  "") ;;
  *)
    usage >&2
    exit 2
    ;;
esac

[[ -n "${CLAUDE_CODE_SESSION_ID:-}" ]] || die "CLAUDE_CODE_SESSION_ID is not set (not in a Claude Code session)"
git_root=$(git rev-parse --show-toplevel 2>/dev/null) || die "not inside a git repository"

echo "$git_root/.ignore/ai/$CLAUDE_CODE_SESSION_ID"
