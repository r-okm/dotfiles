# Local Instructions

If `CLAUDE.local.md` exists in the repository root, read and follow the instructions in it.

# Communication

- Always respond in Japanese.

# Planning

- When creating a plan, always launch the `plan-reviewer` agent via the Agent tool to review it before presenting to the user. Only present plans that have been reviewed by plan-reviewer.
- You may skip plan-reviewer in the following cases:
  - The user explicitly says review is not needed
  - Re-presenting a plan that has already been reviewed by plan-reviewer

# Project Structure

- `<project_root>/.ignore` directory is globally gitignored. It can be used as a place for temporary files or local-only working files.
- Worktrees are created at `<project_root>/.worktree/<branch_name>`. When CWD is inside a worktree, run git commands directly in that directory. Never use `git -C <project_root>` from a worktree.
