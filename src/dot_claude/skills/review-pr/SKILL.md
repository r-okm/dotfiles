---
name: review-pr
description: Review a pull request on the current branch
disable-model-invocation: true
allowed-tools: Bash(gh *), Bash(git *), Read, Grep, Glob, Write
---

# Pull Request Review

## Context

- Branch: !`git branch --show-current`
- PR metadata:

!`gh pr view --json number,title,body`

If a PR number is provided as an argument ($ARGUMENTS), use that instead.

## Steps

1. Retrieve the PR diff with `gh pr diff <number>`.
2. Retrieve review comments with `gh api '/repos/{owner}/{repo}/pulls/<number>/comments'`.
3. Read the changed files to understand context beyond the diff.

## Review Checklist

- Logic errors, edge cases, off-by-one errors
- Security concerns (injection, auth, data exposure)
- Error handling adequacy
- Naming clarity and code readability
- Dead code and orphaned references introduced by the changes
  - Deleted files may leave behind unused imports, type definitions, routes, or assets. Trace references transitively until no more orphans are found.
- Test coverage for changed behavior
- Consistency with existing codebase patterns

## Project-specific Checklist

!`cat .ignore/prompts/review-checklist.md 2>/dev/null`

## Output

Save the review to `.ignore/reviews/<number>_<branch>/<YYYYMMDD>_<seq>.md`.
- Use the Write tool directly; do not run `mkdir`.
- Replace `/` in branch names with `_`.
- If a file with the same name exists, increment `<seq>` (2-digit, zero-padded).
- Example: `.ignore/reviews/123_feature_add-auth/20240401_00.md`
