---
name: review-pr
description: Review a pull request (optionally specify a PR number)
disable-model-invocation: true
allowed-tools: Bash(gh *), Bash(git *), Read, Grep, Glob, Write
model: opus
---

# Pull Request Review

## Context

- PR metadata ($ARGUMENTS: PR number, or empty for current branch):

!`gh pr view $ARGUMENTS --json number,title,body,headRefName`

## Steps

1. Retrieve the PR diff with `gh pr diff <number>`.
2. Retrieve review context by invoking the `fetch-pr-context` skill (Fetch code review context) with the PR number.
3. Read the changed files to understand context beyond the diff.

## Review Checklist

### Existing Comments

- Retrieve existing review comments via `fetch-pr-context`.
- Critically evaluate each comment: is it correct, misleading, or based on a misunderstanding?
- For valid comments, incorporate their points into your review findings.
- For incorrect or questionable comments, refute them with evidence from the code.

### General

- Logic errors, edge cases, off-by-one errors
- Security concerns (injection, auth, data exposure)
- Error handling adequacy
- Naming clarity and code readability
- Dead code and orphaned references introduced by the changes
  - Deleted files may leave behind unused imports, type definitions, routes, or assets. Trace references transitively until no more orphans are found.
- Test coverage for changed behavior
- Consistency with existing codebase patterns

### PR Title

Format: `[package_name] Concise description starting with an imperative verb`

- Prefix with `[v3_gui]` (or the relevant package). May omit if the change spans multiple packages.
- Start with an imperative verb: Add, Fix, Update, Remove, Support, Optimize, etc. Past tense or noun phrases are not acceptable.
- Keep the title within 50 characters (including the package prefix).
- Describe the intent or purpose of the change, not just what was touched. A reader should understand the scope without opening the PR.
  - Bad: `[v3_gui] Fix settings slider` — what changed and why is unclear.
  - Good: `[v3_gui] Fix slider gRPC call queue buildup` — conveys the problem being solved.
  - Good: `[v3_gui] Throttle brightness slider gRPC calls` — conveys the behavioral change.

### v3_gui (apply only when the PR touches `packages/v3_gui`)

#### i18n

- Confirm that translation keys in `packages/v3_gui/src/types/const/translation/en.ts` are consistent with any UI text added or removed in the PR. Flag missing or orphaned keys.
- Verify that translated phrases are natural and contextually appropriate. Keys are referenced via `t()` from `useTranslation()`.

#### Stale Resources

Starting from files deleted or modified in the PR, recursively identify resources that are no longer referenced.

Targets:
- **pages/** — Delete if no longer referenced by `router.push` or similar navigation calls.
- **Type definitions, Recoil atoms, Recoil keys** — Delete if no longer imported.
- **Images (`packages/v3_gui/public/`)** — Delete if no longer referenced by `<Image src="...">`. Note: `src="/..."` resolves to `public/`.

#### useLoading

The `useLoading` hook follows a specific pattern for page transitions:

- **Success + navigation**: Do NOT call `stopLoading()` — the loading modal closes automatically when the component unmounts. This is intentional to prevent flickering during the transition.
- **Error or staying on the same page**: Call `stopLoading()` explicitly.

Do not flag missing `stopLoading()` calls on success paths that end with `router.push()`.

## Output

Save the review to `.ignore/ai/reviews/<number>_<branch>/<YYYYMMDD>_<seq>.md`.
- Use the Write tool directly; do not run `mkdir`.
- `<number>` and `<branch>` are taken from the `number` and `headRefName` fields in the PR metadata fetched above.
- Replace `/` in branch names with `_`.
- If a file with the same name exists, increment `<seq>` (2-digit, zero-padded).
- Example: `.ignore/ai/reviews/123_feature_add-auth/20240401_00.md`
