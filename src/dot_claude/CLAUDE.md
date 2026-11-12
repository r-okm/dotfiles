# Communication

- Always respond in Japanese.
- The Japanese rule applies to conversation only, not to file content. When editing a file, follow the language already used in that file (or in the repository's similar files). When creating a new file with no precedent, default to English.

# Project Structure

- `<project_root>/.ignore` directory is globally gitignored. When you (the AI) create a file worth keeping past the session — investigation memos, results, generated assets, intermediate working files — place it under the per-session directory printed by `~/.claude/r-okm/scripts/claude-ai-dir.sh`; if the script fails, use the harness scratchpad instead. Create the directory only when you first write to it.
- Paths fixed by a setting or a script (e.g. a skill's default output directory) keep their own location.
- The harness scratchpad is fine for session-scoped throwaway files.
- When a subagent should write such files, put the absolute directory path in its brief.

# Gitignored Per-Project Config

- `CLAUDE.local.md` and other gitignored per-project config files may be symlinks into the project-ignores repo (`~/src/github.com/r-okm/project-ignores`). To edit one, resolve the symlink (`readlink -f`) and edit the real target file in that repo.

# WSL

- To open a URL in the user's browser, use `xdg-open <url>` — `~/.config/mimeapps.list` routes http/https to the Windows-side Vivaldi (`$BROWSER` in `~/.profile` when neither `DISPLAY` nor `WAYLAND_DISPLAY` is set). Don't look for `explorer.exe` or `wslview`.

# review-wizard

- When you have a preferred answer to a review-wizard question, list that option first and append "(Recommended)" to its label — the same convention AskUserQuestion uses — and say why in its description.
