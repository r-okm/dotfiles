---
name: fetch-pr-context
description: Fetch code review context (inline comments, verdicts, threads)
allowed-tools: Bash(gh-pr-fetch-reviews *), Bash(gh-pr-fetch-comments *), Bash(gh-pr-review-threads *)
argument-hint: "<PR number | GitHub PR URL>"
---

# Fetch PR Context

Review context for pull request $ARGUMENTS.

## Review Verdicts

!`gh-pr-fetch-reviews $ARGUMENTS`

## Inline Review Comments

!`gh-pr-fetch-comments $ARGUMENTS`

## Unresolved Review Threads

!`gh-pr-review-threads $ARGUMENTS`
