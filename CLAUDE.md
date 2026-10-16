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

Some managed files are written directly by their applications, so the deployed copy in `$HOME` — not `src/` — is the source of truth. They are listed in `target_owned_files` in `src/dot_local/bin/executable_chezmoi-sync`. Currently:

- `~/.claude/settings.json` — Claude Code writes it directly (`/model`, `/config`, permission prompts).

Rules for these files:

- Changes that originate on the target side (the app writing the file, or the user editing it) are synced back with `chezmoi-sync` (abbr: `chs`), which runs `chezmoi re-add` on the listed files. Do not re-create such changes in `src/` by hand.
- When Claude changes one of these files, it edits the `src/` copy instead: first confirm `chezmoi status` shows no drift for the file (run `chezmoi-sync` if it does), then edit `src/`, then the user runs `chezmoi apply`. The Bash sandbox blocks writes to `~/.claude/settings.json`, and `src/` gives a reviewable diff before the change takes effect.
- Keep them non-template — `chezmoi re-add` skips templates, which breaks the sync. Use `~/`-style paths instead of `{{ .chezmoi.homeDir }}`.
- If both sides changed (e.g. after pulling source changes from another machine), resolve with `chezmoi merge <file>` instead of re-add.

## Windows-Owned Files

The files in the `windows-sync` target list — the Windows Terminal `settings.json` and the Alacritty configs under `src/AppData/**` — are written by their Windows applications; the Windows Terminal settings UI writes its `settings.json` directly. For these, the copy under `%USERPROFILE%` is the source of truth, and changes come back into the source one way only: `windows-sync`, run in WSL, reads Windows and never writes to it. That is what keeps the two copies from drifting apart in both directions at once.

Rules for these files:

- Do not hand-edit them in `src/` to change Windows behavior. Change it in the Windows application, then run `windows-sync` in WSL to pull the result in.
- `windows-sync` copies byte for byte and refuses to run while `src/AppData` has uncommitted changes. It does not commit — review the diff and write the message yourself, explaining what changed on the Windows side and why the file also came back reformatted, if it did.
- The target list is hardcoded in `src/dot_local/bin/executable_windows-sync.tmpl`. One path there names both the Windows file (relative to `%USERPROFILE%`) and its copy in the source, so these files keep their plain names — no `dot_`, `private_` or `.tmpl` prefixes.
- On Linux, `AppData` is ignored, so `chezmoi status` never lists these files and `git status` after `windows-sync` is the only signal.
- Any other file under `AppData` is source-owned like the rest of `src/` and takes the usual chezmoi prefixes. Examples include the `dot_editorconfig` next to the Windows Terminal `settings.json` and `src/AppData/Local/r-okm/ghub-tools/` (G HUB helper scripts run by Task Scheduler; see its README).

Applying on Windows:

- Windows-only scripts in `src/.chezmoiscripts/windows` (such as the one that applies `src/.chezmoidata/windows.toml`) run only on an apply without target arguments. After changing them or the data they read, tell the user to run a full `chezmoi apply`, not one scoped to a directory.
- A full apply on Windows also writes the Windows-owned files above, which chezmoi does manage there. Have the user run `chezmoi status` first; if one of them is listed, pull it in with `windows-sync` and commit before applying, or the apply overwrites the change made in the Windows application.

## Repo Tooling

`tools/` holds standalone maintenance scripts. They sit outside `src/`, so chezmoi never deploys them — run them from the repo root.

Each script documents itself in its module docstring and `--help`, which is why they are not listed here. Look there before writing a new one-off script.

## Commands

- **Preview diff**: `chezmoi diff`
