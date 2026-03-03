# Local Instructions

If `CLAUDE.local.md` exists in the repository root, read and follow the instructions in it.

# Communication

- Always respond in Japanese.

# Project Structure

- `<project_root>/.ignore` directory is globally gitignored. It can be used as a place for temporary files or local-only working files.
- Always create plan files in `<project_root>/.ignore/ai/plans/`. Name each file in kebab-case that summarizes the plan content (e.g., `refactor-auth-flow.md`).
- Worktrees are created at `<project_root>/.worktree/<branch_name>`. When CWD is inside a worktree, run git commands directly in that directory. Never use `git -C <project_root>` from a worktree.
