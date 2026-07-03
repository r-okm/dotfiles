# Local Instructions

If `CLAUDE.local.md` exists in the repository root, read and follow the instructions in it.

`CLAUDE.local.md` and other gitignored per-project config files may be symlinks into the project-ignores repo (`~/src/github.com/r-okm/project-ignores`). To edit one, resolve the symlink (`readlink -f`) and edit the real target file in that repo.

# Communication

- Always respond in Japanese.
- The Japanese rule applies to conversation only, not to file content. When editing a file, follow the language already used in that file (or in the repository's similar files). When creating a new file with no precedent, default to English.

# Credentials

- Never read the contents of credential files (e.g. `.credentials.json`, token files, private keys), even for investigation. When inspecting MCP, plugin, or tool configuration, read only the config files (`settings.json`, `.mcp.json`, etc.).

# Planning

- When creating a plan, always launch the `plan-reviewer` agent via the Agent tool to review it before presenting to the user. Only present plans that have been reviewed by plan-reviewer.
- plan-reviewer is a subagent and lacks conversation context, so some of its suggestions may be off-target. After receiving its feedback, evaluate each suggestion against the full conversation context and only incorporate those that are valid. Briefly share any rejected suggestions and the reasoning with the user.
- You may skip plan-reviewer in the following cases:
  - The user explicitly says review is not needed
  - Re-presenting a plan that has already been reviewed by plan-reviewer

# Project Structure

- `<project_root>/.ignore` directory is globally gitignored. When you (the AI) create a temporary file — scratch notes, investigation memos, generated artifacts, intermediate working files — place it under `<project_root>/.ignore/ai/**`.
- Worktrees are created at `<project_root>/.worktree/<branch_name>`. When CWD is inside a worktree, run git commands directly in that directory. Never use `git -C <project_root>` from a worktree.
