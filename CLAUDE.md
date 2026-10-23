# CLAUDE.md

## Project Overview

Dotfiles managed with [chezmoi](https://www.chezmoi.io/). Source directory: `src/` (via `.chezmoiroot`). All managed files live under `src/` and are applied to `$HOME`.

## Working with Chezmoi

- Edit files in `src/`, never in target paths (`~/.config/` etc.) — `chezmoi apply` overwrites targets.
- Use chezmoi prefixes when adding files: `dot_` (→ `.`), `private_` (restricted perms), `executable_` (→ +x), `symlink_` (→ symlink).
- Append `.tmpl` for Go text/template files. Data sources: `.chezmoi.os`, `.chezmoi.homeDir`, custom data in `.chezmoi.toml.tmpl`.
- **Do NOT run** `chezmoi apply` or `chezmoi init` — user runs these manually. `chezmoi diff` for preview is OK.
- Removing a file from `src/` (or an entry from `.chezmoiexternal.toml.tmpl`) does not remove the deployed copy — `chezmoi apply` never deletes a target it no longer manages. Add the target path to `src/.chezmoiremove` instead, and never delete entries from it: whether every machine has already applied a removal is not observable from git. List single targets only; a pattern like `.config` or `*` also matches managed directories and aborts the apply.

## Target-Owned Files

Some managed files are written directly by their applications, so the deployed copy — not `src/` — is the source of truth. Currently:

- `~/.claude/settings.json` — Claude Code writes it directly (`/model`, `/config`, permission prompts).
- `~/AppData/Local/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json` — the Windows Terminal settings UI writes it directly. `AppData` is ignored on Linux, so only chezmoi on Windows sees this one.

Rules for these files:

- Changes that originate on the target side (the app writing the file, or the user editing it) are synced back with `chezmoi re-add <target>`, run on the machine where the change happened. Do not re-create such changes in `src/` by hand.
- `chezmoi re-add` copies byte for byte and overwrites the source copy without looking at git, so commit or discard any uncommitted edit to it first. It does not commit — review the diff and write the message yourself, explaining what changed on the target side and why the file also came back reformatted, if it did.
- Before the user runs `chezmoi apply`, have them run `chezmoi status`; if one of these files is listed, re-add it and commit first, or the apply overwrites the change the application made.
- When Claude changes one of these files, it edits the `src/` copy instead: first confirm `chezmoi status` shows no drift for the file (re-add it if it does), then edit `src/`, then the user runs `chezmoi apply`. Editing `src/` gives a reviewable diff before the change takes effect.
- Keep them non-template — `chezmoi re-add` skips templates, which breaks the sync. Use `~/`-style paths instead of `{{ .chezmoi.homeDir }}`.
- If both sides changed (e.g. after pulling source changes from another machine), resolve with `chezmoi merge <file>` instead of re-add.

## Windows

- Files under `src/AppData` other than the target-owned one above are source-owned like the rest of `src/` and take the usual chezmoi prefixes. Examples include the `dot_editorconfig` next to the Windows Terminal `settings.json` and `src/AppData/Local/r-okm/ghub-tools/` (G HUB helper scripts run by Task Scheduler; see its README).
- Windows-only scripts in `src/.chezmoiscripts/windows` (such as the one that applies `src/.chezmoidata/windows.toml`) run only on an apply without target arguments. After changing them or the data they read, tell the user to run a full `chezmoi apply`, not one scoped to a directory.

## Repo Tooling

`tools/` holds standalone maintenance scripts. They sit outside `src/`, so chezmoi never deploys them — run them from the repo root.

Each script documents itself in its module docstring and `--help`, which is why they are not listed here. Look there before writing a new one-off script.

## Commands

- **Preview diff**: `chezmoi diff`
