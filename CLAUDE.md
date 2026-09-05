# CLAUDE.md

## Project Overview

Dotfiles managed with [chezmoi](https://www.chezmoi.io/). Source directory: `src/` (via `.chezmoiroot`). All managed files live under `src/` and are applied to `$HOME`.

## Working with Chezmoi

- Edit files in `src/`, never in target paths (`~/.config/` etc.) — `chezmoi apply` overwrites targets.
- Use chezmoi prefixes when adding files: `dot_` (→ `.`), `private_` (restricted perms), `executable_` (→ +x), `symlink_` (→ symlink).
- Append `.tmpl` for Go text/template files. Data sources: `.chezmoi.os`, `.chezmoi.homeDir`, custom data in `.chezmoi.toml.tmpl`.
- **Do NOT run** `chezmoi apply` or `chezmoi init` — user runs these manually. `chezmoi diff` for preview is OK.

## Target-Owned Files

Some managed files are written directly by their applications, so the deployed copy in `$HOME` — not `src/` — is the source of truth. They are listed in `target_owned_files` in `src/dot_local/bin/executable_chezmoi-sync`. Currently:

- `~/.claude/settings.json` — Claude Code writes it directly (`/model`, `/config`, permission prompts).

Rules for these files:

- Changes that originate on the target side (the app writing the file, or the user editing it) are synced back with `chezmoi-sync` (abbr: `chs`), which runs `chezmoi re-add` on the listed files. Do not re-create such changes in `src/` by hand.
- When Claude changes one of these files, it edits the `src/` copy instead: first confirm `chezmoi status` shows no drift for the file (run `chezmoi-sync` if it does), then edit `src/`, then the user runs `chezmoi apply`. The Bash sandbox blocks writes to `~/.claude/settings.json`, and `src/` gives a reviewable diff before the change takes effect.
- Keep them non-template — `chezmoi re-add` skips templates, which breaks the sync. Use `~/`-style paths instead of `{{ .chezmoi.homeDir }}`.
- If both sides changed (e.g. after pulling source changes from another machine), resolve with `chezmoi merge <file>` instead of re-add.

## Windows-Owned Files

`src/AppData/**` mirrors configuration that Windows applications own — the Windows Terminal settings UI writes its `settings.json` directly. The copy under `%USERPROFILE%` is the source of truth, and the automated flow is one-way: WSL reads Windows, never the reverse. That is what keeps the two copies from drifting apart in both directions at once.

Rules for these files:

- Do not hand-edit `src/AppData/**` to change Windows behavior. Change it in the Windows application, then run `windows-sync` to pull the result in.
- `windows-sync` copies byte for byte and refuses to run while `src/AppData` has uncommitted changes. It does not commit — review the diff and write the message yourself, explaining what changed on the Windows side and why the file also came back reformatted, if it did.
- The target list is hardcoded in `src/dot_local/bin/executable_windows-sync.tmpl`. One path there names both the Windows file (relative to `%USERPROFILE%`) and its copy in the source, so files under `AppData` keep their plain names — no `dot_`, `private_` or `.tmpl` prefixes.
- `chezmoi status` never reports drift for these files: `AppData` is ignored on Linux, so chezmoi does not track them on this side at all. `git status` is the only signal.
- Applying to Windows is still possible — `chezmoi apply` on that machine — but it is a manual escape hatch for setting up a new PC, not part of the routine.

## Commands

- **Preview diff**: `chezmoi diff`
