# Communication

- Always respond in Japanese.
- The Japanese rule applies to conversation only, not to file content. When editing a file, follow the language already used in that file (or in the repository's similar files). When creating a new file with no precedent, default to English.

# Planning

- Before presenting a plan to the user, always run the `plan-review` skill. It drives the review loop (plan-reviewer agent → apply fixes → record `## レビュー履歴`) until the plan passes; skip conditions are defined in the skill.

# Project Structure

- `<project_root>/.ignore` directory is globally gitignored. When you (the AI) create a temporary file — scratch notes, investigation memos, generated artifacts, intermediate working files — place it under `<project_root>/.ignore/ai/**`.
- The harness scratchpad is fine for session-scoped throwaway files; anything worth keeping past the session (investigation memos, results, generated assets) goes under `<project_root>/.ignore/ai/**`.

# Gitignored Per-Project Config

- `CLAUDE.local.md` and other gitignored per-project config files may be symlinks into the project-ignores repo (`~/src/github.com/r-okm/project-ignores`). To edit one, resolve the symlink (`readlink -f`) and edit the real target file in that repo.

# Worktrees

- Always create worktrees with `git-worktree-tmux` (in `~/.local/bin`), never with a bare `git worktree add`. It also symlinks the gitignored per-project files (`.ignore`, `CLAUDE.local.md`, `.claude/settings.local.json`, `.claude/local`) from the original repository and opens a tmux session for the worktree.
  - `git-worktree-tmux -b <branch_name>` — check out an existing branch
  - `git-worktree-tmux -p <pr_number>` — check out the head branch of a pull request
  - `git-worktree-tmux -c [<branch_suffix>]` — create a new branch named `<git user.name>/<branch_suffix>` from the remote HEAD (suffix defaults to `wip-<epoch>`)
- Always pass `-d`/`--detach` when you (the AI) run it. Without it the command attaches or switches the user's tmux client to the new session, which yanks their view away. With `-d` the session is only created in the background and the worktree path is printed on the last line of stdout — use that as the working directory.
- Run it from inside the repository — running it from a linked worktree is fine, the new worktree is always created under the main worktree without nesting. `-c` leaves the HEAD of the current worktree untouched, so it is safe to run mid-work.
- Worktrees are created at `<project_root>/.worktree/<branch_name>` (`/` in the branch name replaced with `-`). When CWD is inside a worktree, run git commands directly in that directory. Never use `git -C <project_root>` from a worktree.
