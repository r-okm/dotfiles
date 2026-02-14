---
name: commit
description: Generate and apply a commit message for staged changes
disable-model-invocation: true
allowed-tools: Bash(git *)
---

Generate a commit message for the staged changes.
Follow the style of recent commits.
Use the conversation context to understand the intent of the changes.

Format:
- Subject: max 50 chars, imperative mood
- Body: bulleted list with `-`, each line max 72 chars

## Recent commits

!`git log --format='---%n%s%+b' -10`

## Staged files

!`git diff --cached --stat`

Generate the commit message, then run `git commit` with it.
