# CLAUDE.md

## Project Overview

Dotfiles managed with [chezmoi](https://www.chezmoi.io/). Source directory: `src/` (via `.chezmoiroot`). All managed files live under `src/` and are applied to `$HOME`.

## Working with Chezmoi

- Edit files in `src/`, never in target paths (`~/.config/` etc.) — `chezmoi apply` overwrites targets.
- Use chezmoi prefixes when adding files: `dot_` (→ `.`), `private_` (restricted perms), `executable_` (→ +x), `symlink_` (→ symlink).
- Append `.tmpl` for Go text/template files. Data sources: `.chezmoi.os`, `.chezmoi.homeDir`, custom data in `.chezmoi.toml.tmpl`.
- **Do NOT run** `chezmoi apply` or `chezmoi init` — user runs these manually. `chezmoi diff` for preview is OK.

## Target-Owned Files

Some managed files are written directly by their applications, so the deployed copy in `$HOME` — not `src/` — is the source of truth. They are listed in `CHEZMOI_TARGET_OWNED_FILES` in `src/private_dot_config/zsh/defer/functions.zsh`. Currently:

- `~/.claude/settings.json` — Claude Code writes it directly (`/model`, `/config`, permission prompts).

Rules for these files:

- Do NOT edit the `src/` copy by hand. Change the target side (or let the app do it), then sync back with `chezmoi_sync` (abbr: `chs`), which runs `chezmoi re-add` on the listed files.
- Keep them non-template — `chezmoi re-add` skips templates, which breaks the sync. Use `~/`-style paths instead of `{{ .chezmoi.homeDir }}`.
- If both sides changed (e.g. after pulling source changes from another machine), resolve with `chezmoi merge <file>` instead of re-add.

## Commands

- **Preview diff**: `chezmoi diff`
