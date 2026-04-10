# Permission Optimization System

Logs every Claude Code permission prompt and suggests `allow` rules based on frequency.

## How It Works

```
Tool call → Permission evaluation → PermissionRequest hook fires
                                        ↓
                              log-permission-request.sh
                                        ↓
                              ~/.claude/r-okm/logs/permission-requests.jsonl
                                        ↓
                              analyze-permissions.py → suggested rules
```

A `PermissionRequest` hook (`settings.json`) triggers `log-permission-request.sh` on every permission prompt. The script records the tool name, input summary, and Claude Code's suggested rules as JSONL. Run `analyze-permissions.py` to aggregate the logs and surface candidates for `settings.json` `permissions.allow`.

## Usage

### Workflow

```sh
# 1. Scan table overview
analyze-permissions.py

# 2. LLM analysis (via skill)
/analyze-permissions

# 3. Paste approved rules into settings.json
analyze-permissions.py --settings
```

### CLI options

```sh
# Default: top 20 suggestions, table format
analyze-permissions.py

# Filter by date
analyze-permissions.py --since 2025-06-01

# Show top 10
analyze-permissions.py --top 10

# Rich JSON for LLM analysis (used by /analyze-permissions skill)
analyze-permissions.py --json

# Flat JSON array for settings.json permissions.allow (wildcards applied)
analyze-permissions.py --settings
```

### Table output

```
Permission Request Analysis
======================================================================
  Total log entries : 142
  Unique suggestions: 28

  Count  Behavior  Rule                              Status
  -----  ------    --------------------------------  ------
     34  allow     Bash(npm test *)                  NEW
     21  allow     Bash(docker compose *)            NEW
      8  allow     Edit(src/**)                      ALLOWED
      5  deny      Bash(rm -rf *)                    DENIED
```

- **NEW** — not in current allow/deny lists; candidate for addition
- **ALLOWED** — already in `permissions.allow`
- **DENIED** — already in `permissions.deny`

Wildcard suggestions with risk labels are shown when rules share a common prefix:

```
Suggested wildcard rules:
--------------------------------------------------
  Bash(~/.claude/r-okm/scripts/*)                  (2 rules)
    - ~/.claude/r-okm/scripts/analyze-permissions.py
    - ~/.claude/r-okm/scripts/log-permission-request.sh
  Bash(python3 *)                                  (5 rules) [RISK:HIGH]
    - python3 --version
    - python3 ~/.claude/r-okm/scripts/analyze-permissions.py
    ...
```

### LLM analysis skill

Run `/analyze-permissions` in Claude Code to automatically analyze logs from 3 perspectives:

1. **Rule optimization** — recommends allow rules with appropriate wildcard granularity
2. **Security review** — flags high-risk wildcards and checks deny rule consistency
3. **settings.json.tmpl changes** — provides copy-paste additions and deletions

### Apply suggestions

```sh
# Get copy-paste ready JSON (NEW allow rules only, wildcards applied)
analyze-permissions.py --settings
```

Add the output entries to `permissions.allow` in `dotfiles/src/dot_claude/settings.json.tmpl`, then run `chezmoi apply`.

## Files

| File | Purpose |
|------|---------|
| `scripts/log-permission-request.sh` | PermissionRequest hook — logs prompts to JSONL |
| `scripts/analyze-permissions.py` | Aggregates logs and suggests allow rules |
| `logs/permission-requests.jsonl` | Log data (auto-created, not in version control) |
| `~/.claude/skills/analyze-permissions/` | `/analyze-permissions` skill for LLM-driven analysis |

## Log Format

Each JSONL line contains:

```json
{
  "timestamp": "2025-06-01T12:00:00Z",
  "session_id": "abc123",
  "tool_name": "Bash",
  "tool_input_summary": { "command": "npm test" },
  "permission_suggestions": [
    {
      "type": "addRules",
      "rules": [{ "toolName": "Bash", "ruleContent": "npm test" }],
      "behavior": "allow",
      "destination": "localSettings"
    }
  ],
  "cwd": "/home/user/project",
  "permission_mode": "default"
}
```

Sensitive values in Bash commands (`--password`, `--token`, `--secret`, `--key`, `Bearer`, `token=`, `password=`, `secret=`, `Authorization:`) are masked with `***`.

## Log Rotation

When `permission-requests.jsonl` exceeds 10 MB, it is renamed to `permission-requests.<timestamp>.bak.jsonl` and a new file is started.
