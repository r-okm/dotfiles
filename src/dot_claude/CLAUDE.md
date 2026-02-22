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

# Plan Review Protocol

When generating a plan in plan mode, follow this review cycle before
presenting it to the user. Maximum 2 review rounds (initial + 1
re-review).

## Flow

1. Generate the plan and write it to the plan file.
2. Call the `plan-reviewer` subagent via the Task tool, passing the
   plan file path.
3. Display the reviewer's full feedback to the user — do not
   summarize or hide it.
4. Evaluate each feedback item as the reviewee (see Reviewee
   Guidelines below).
5. Edit the plan file with accepted corrections. For each item,
   record your accept/reject decision and reasoning in a
   `## Review Notes` section at the bottom of the plan file.
6. If the initial review contained any 🔴 Critical or 🟡 Concern
   items, call `plan-reviewer` again for re-review (round 2),
   including the previous review output in the prompt so the
   reviewer can produce a Resolution Tracking table. If the initial
   review was all 🟢 Good, skip the re-review.
7. Display the re-review results to the user.
8. Exit plan mode.

If the automatic review cycle does not trigger as expected, prompt
the user to manually request a review after plan mode.

## Reviewee Guidelines

The reviewer is a high-capability model and is generally accurate,
but can produce false positives. You MUST NOT blindly accept all
feedback. For each item:

- **Evaluate independently** — does the issue have concrete evidence
  and sound reasoning?
- **Reject if**: the issue lacks specific justification, is based on
  incorrect assumptions about the codebase, or would weaken the
  plan's core approach without clear benefit.
- **Accept if**: the issue identifies a genuine gap, inconsistency,
  or risk, supported by evidence.
- **Document reasoning** — write a one-line rationale for each
  accept/reject in the Review Notes section.

Do not apply cosmetic changes that add no substance. Do not reverse
well-justified design decisions just because the reviewer questioned
them.

# Investigation Strategy

When investigating, prefer the following delegation to keep the main context clean:

- **Web research** (docs, articles, API refs): Delegate to the `copilot-web-researcher` subagent (auto-selected by description match, or invoke explicitly).
- **Codebase exploration**: Use the built-in Explore subagent.
- **GitHub data** (issues, PRs, reviews): Use the `gh` CLI directly.
- **Plan review** (plan mode): After writing a plan, the `plan-reviewer` subagent is automatically invoked per the Plan Review Protocol above.
