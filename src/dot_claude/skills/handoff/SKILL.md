---
name: handoff
description: Generate a session handoff document for continuing work in another session
disable-model-invocation: true
allowed-tools: Bash(date *), Read, Write
argument-hint: "[output path]"
---

# Session Handoff

Generate a structured handoff document that captures the current session's
context so another agent (or a future session) can continue the work.

## Instructions

1. Review the full conversation to identify:
   - The overall objective
   - What was completed
   - What remains to be done
   - Key decisions and their rationale
   - Important files touched or referenced
   - Blockers, constraints, and non-obvious observations

2. Write the handoff document in **English** using the template below.
   Keep it under ~2,000 tokens. Be specific and actionable — an unfamiliar
   agent should be able to resume work from this document alone.

3. Save the file:
   - If `$ARGUMENTS` is a path, use that.
   - Otherwise: `.ignore/handoffs/<YYYYMMDD_HHMMSS>.md`
     (use `date +%Y%m%d_%H%M%S` to generate the timestamp).
   - Use the Write tool directly; do not run `mkdir`.

## Template

```markdown
# Session Handoff - <YYYY-MM-DD HH:MM>

## Objective
[One-line description of the overall goal]

## Status
[in_progress | blocked | needs_review | completed]

## Completed
Record what was done. Decisions and their rationale belong in
"Decisions Made"; do not duplicate them here.
- [x] Task 1 with enough detail for an unfamiliar agent
- [x] Task 2

## Pending / Next Steps
- [ ] [HIGH] Actionable next step 1
- [ ] [MEDIUM] Actionable next step 2

## Key Files
Only list files the next agent will need to read or modify.
- `path/to/file.ts` -- relevance note
- `path/to/other.ts:42-60` -- relevance note with line range

## Decisions Made
- Decision 1: rationale (prevents re-litigating in next session)
- Decision 2: rationale

## Blockers / Constraints
- Discovered issues or constraints

## Context Notes
- Observations, rejected approaches, gotchas
```

Omit any section that has no content. Do not add sections beyond those listed.
