# Communication

- Always respond in Japanese.
- The Japanese rule applies to conversation only, not to file content. When editing a file, follow the language already used in that file (or in the repository's similar files). When creating a new file with no precedent, default to English.

# Project Structure

- `<project_root>/.ignore` directory is globally gitignored. When you (the AI) create a temporary file — scratch notes, investigation memos, generated artifacts, intermediate working files — place it under `<project_root>/.ignore/ai/**`.
- The harness scratchpad is fine for session-scoped throwaway files; anything worth keeping past the session (investigation memos, results, generated assets) goes under `<project_root>/.ignore/ai/**`.

# Gitignored Per-Project Config

- `CLAUDE.local.md` and other gitignored per-project config files may be symlinks into the project-ignores repo (`~/src/github.com/r-okm/project-ignores`). To edit one, resolve the symlink (`readlink -f`) and edit the real target file in that repo.

# Worktrees

- Never run `git worktree add` or `git-worktree-tmux` directly — creating a worktree (a new branch, an existing branch, or a PR checkout) goes through the `worktree` skill. Invoke it first.
- When CWD is inside a worktree, run git commands directly in that directory. Never use `git -C <project_root>` from a worktree — that operates on the original repository, not the branch you are working on.

# WSL

- To open a URL in the user's browser, use `xdg-open <url>` — `$BROWSER` in `~/.profile` routes it to the Windows-side browser. Don't look for `explorer.exe` or `wslview`.
