# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dotfiles managed with [chezmoi](https://www.chezmoi.io/). The chezmoi source directory is `src/` (set via `.chezmoiroot`). All managed files live under `src/` and are applied to `$HOME`.

## Commands

- **Bootstrap**: `./install.sh` (installs chezmoi if missing, then runs `chezmoi init --apply`)
- **Apply changes**: `chezmoi apply` (user runs this manually — do not execute)
- **Preview diff**: `chezmoi diff`
- **CI**: Runs `install.sh` then sources `.zshrc` on Ubuntu 24.04/22.04

## Architecture

### Chezmoi Source Layout (`src/`)

- `.chezmoi.toml.tmpl` — Chezmoi config with machine-specific data (work git hosts, GitHub orgs)
- `.chezmoiexternal.toml.tmpl` — 30+ external dependencies (zsh plugins, tmux themes, completions) fetched weekly
- `.chezmoiignore` — OS-conditional exclusions (Linux vs Windows)
- `.chezmoiscripts/` — Numbered run_once scripts: 001-010 (apt), 101-108 (language runtimes), 201-204 (packages), 301 (nvim config), 901 (login shell)

### Key Directories

| Source path | Target | Contents |
|---|---|---|
| `private_dot_config/zsh/` | `~/.config/zsh/` | Modular zsh config: `sync/` (critical), `defer/` (lazy-loaded via zsh-defer), `depend/` (plugins) |
| `private_dot_config/git/` | `~/.config/git/` | Templated git config with conditional work/personal includes |
| `private_dot_config/tmux/` | `~/.config/tmux/` | Tmux config + helper scripts |
| `dot_claude/` | `~/.claude/` | Claude Code settings, skills, scripts |
| `dot_local/bin/` | `~/.local/bin/` | Custom scripts (git-ai-commit, clipboard, etc.) |
| `AppData/` | `~/AppData/` | Windows-only: Windows Terminal, Alacritty configs |

### Templating

Files ending in `.tmpl` use Go text/template with chezmoi data. Key data sources:
- `.chezmoi.os` — OS-conditional logic
- `.chezmoi.homeDir` — Home directory path
- `.work.*` — Work-specific git settings (hosts, orgs, credentials)

### Naming Conventions (chezmoi prefixes)

- `dot_` → `.` (dotfiles)
- `private_` → restricted permissions
- `executable_` → chmod +x
- `symlink_` → symlink (target in file content)
- `run_once_` / `run_once_after_` → idempotent setup scripts
