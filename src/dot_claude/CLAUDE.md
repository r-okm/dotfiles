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

# Investigation Strategy

When investigating, prefer the following delegation to keep the main context clean:

- **Web research** (docs, articles, API refs): Delegate to the `copilot-web-researcher` subagent (auto-selected by description match, or invoke explicitly).
- **Codebase exploration**: Use the built-in Explore subagent.
- **GitHub data** (issues, PRs, reviews): Use the `gh` CLI directly.
