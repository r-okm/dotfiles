---
name: fetch-pr-context
description: Fetch code review context (inline comments, verdicts, threads)
allowed-tools: Bash(gh *), Bash(gh-pr-review-threads *)
argument-hint: "<PR number>"
---

# Fetch PR Context

Review context for pull request $ARGUMENTS.

## Review Verdicts

!`gh api '/repos/{owner}/{repo}/pulls/$ARGUMENTS/reviews' \
  --jq '[.[] | select(.body | length > 0) | {author: .user.login, state, body}]'`

## Inline Review Comments

!`gh api '/repos/{owner}/{repo}/pulls/$ARGUMENTS/comments' --paginate \
  --jq '[.[] | {id, path, line, author: .user.login, body: .body[0:200], in_reply_to_id}]'`

## Unresolved Review Threads

!`gh-pr-review-threads $ARGUMENTS`
