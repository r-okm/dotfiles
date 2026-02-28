# Local Instructions

If `CLAUDE.local.md` exists in the repository root, read and follow the instructions in it.

# Communication

- Always respond in Japanese.

# Commit Message

When generating commit messages, strictly follow the format of recent commit history in the repository.

Rules:
- Subject: max 50 chars
- Blank line after subject
- Body: bulleted list with `-`, each line max 72 chars

# Session Handoff

On session start, check `.ignore/ai/handoffs/` for recent handoff files (< 24h).
If a file matches the current tmux pane (`$TMUX_PANE`), TTY, or branch
and has `status: active`, read it and briefly report the previous session's context.
After reading, update the file's `status` from `active` to `consumed`.

When ending a work session, write session state to
`.ignore/ai/handoffs/copilot-<UNIX_TIMESTAMP>.md` in the following format:

```
---
session_id: copilot-<UNIX_TIMESTAMP>
agent: copilot-cli
timestamp: <ISO 8601>
branch: <current git branch>
tmux_pane: <$TMUX_PANE or null>
tty: <output of tty command, or null>
status: active
---

## Objective
[current task objective]

## Last Actions
[what was just done]

## Modified Files
- `path/to/file`

## Next Steps
- [ ] next actionable step
```
