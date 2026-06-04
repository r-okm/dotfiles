window.BENCHMARK_DATA = {
  "lastUpdate": 1780557838483,
  "repoUrl": "https://github.com/r-okm/dotfiles",
  "entries": {
    "zsh startup time": [
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "86ab80b25064cb5adc8e20801a50c37b91288a59",
          "message": "ci: add zsh startup benchmark to CI workflow (#59)\n\n- Add benchmark step using zsh-startuptime --json on ubuntu-22.04 only\n- Store results via github-action-benchmark with auto-push to gh-pages\non main branch\n- Add contents/deployments write permissions for gh-pages push",
          "timestamp": "2026-03-20T15:39:06+09:00",
          "tree_id": "8ae08e053523885785fa27e7b862ee60c126a6ad",
          "url": "https://github.com/r-okm/dotfiles/commit/86ab80b25064cb5adc8e20801a50c37b91288a59"
        },
        "date": 1773989697598,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 28.1,
            "range": "9.2",
            "unit": "ms",
            "extra": "min: 21.9ms, max: 31.2ms, median: 30.9ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "be163407b1f777c6f7244b0d5c15080abfef94b4",
          "message": "claude: expand gh permissions for CI and pr checks\n\n- Generalize `head` permission from `/usr/bin/head` to `head`\n- Add `gh pr checks`, `gh run view`, `gh run list` permissions",
          "timestamp": "2026-03-20T16:01:49+09:00",
          "tree_id": "4241fd4dc61faf03d3c8ea1182b1b22f53ef1801",
          "url": "https://github.com/r-okm/dotfiles/commit/be163407b1f777c6f7244b0d5c15080abfef94b4"
        },
        "date": 1773991176489,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 20.9,
            "range": "9.3",
            "unit": "ms",
            "extra": "min: 18.5ms, max: 27.8ms, median: 18.9ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "51204f19277b028094655983dd16aa776d23ce3d",
          "message": "claude: add tmux read permissions to global settings\n\n- Add `tmux list-windows`, `capture-pane`, `display-message`,\n  `send-keys`, `list-panes` to allowed Bash tools",
          "timestamp": "2026-03-24T17:29:51+09:00",
          "tree_id": "3000cdadf14a9256c4c97a5fc70e61c39ab48ec3",
          "url": "https://github.com/r-okm/dotfiles/commit/51204f19277b028094655983dd16aa776d23ce3d"
        },
        "date": 1774341965892,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 23.5,
            "range": "9.3",
            "unit": "ms",
            "extra": "min: 21.9ms, max: 31.2ms, median: 22.5ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "d0316df25479e6794eae0208147d3fead858b90c",
          "message": "config: add claude-cli URL handler to mimeapps.list\n\n- Register x-scheme-handler/claude-cli to claude-code-url-handler.desktop",
          "timestamp": "2026-03-26T14:39:40+09:00",
          "tree_id": "59e5b368f1e3000a65b8c2cfb7afcfb9c6696b4e",
          "url": "https://github.com/r-okm/dotfiles/commit/d0316df25479e6794eae0208147d3fead858b90c"
        },
        "date": 1774504578985,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 22.9,
            "range": "5.8",
            "unit": "ms",
            "extra": "min: 21.6ms, max: 27.4ms, median: 22.0ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "02676427b7361c36e076dfbd30a02a1ea7e49f63",
          "message": "ci: use cargo-binstall for prebuilt binaries to speed up CI (#60)\n\n- Add run_once_after_109 to install cargo-binstall v1.17.8 from GitHub\nReleases with arch auto-detection (x86_64/aarch64)\n- Switch run_once_after_201 to use cargo binstall for downloading\nprebuilt binaries instead of compiling from source, with cargo install\nfallback\n- Remove cargo registry cache step from CI workflow as binstall does not\nrequire source compilation",
          "timestamp": "2026-03-26T16:13:02+09:00",
          "tree_id": "7189aaf8c7874768ffbb11dbf2d6044a1b15934c",
          "url": "https://github.com/r-okm/dotfiles/commit/02676427b7361c36e076dfbd30a02a1ea7e49f63"
        },
        "date": 1774510903376,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 22.2,
            "range": "1.3",
            "unit": "ms",
            "extra": "min: 21.7ms, max: 23.0ms, median: 22.0ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "df5e0f56e09e09f7a41446acf8be3116d0c572a6",
          "message": "ci: skip install when tools are already present (#61)\n\n- Add command -v checks to 1xx install scripts (rust, deno, docker,\nterraform, go, awscli, gh, cargo-binstall) to skip installation if the\ntool is already available on the system\n- Speeds up CI on GitHub Actions runners where docker, go, gh, and rust\nare pre-installed",
          "timestamp": "2026-03-26T16:55:14+09:00",
          "tree_id": "fe3c64992c68d34d3b4b9c8fe91176d57e863775",
          "url": "https://github.com/r-okm/dotfiles/commit/df5e0f56e09e09f7a41446acf8be3116d0c572a6"
        },
        "date": 1774512240208,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 18.4,
            "range": "0.2",
            "unit": "ms",
            "extra": "min: 18.3ms, max: 18.5ms, median: 18.4ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "75eb959c6e13e3aa68d8583470daf19a66f31056",
          "message": "claude: auto-launch plan-reviewer for plans\n\n- Add Planning section to global CLAUDE.md requiring plan-reviewer\n  agent launch before presenting plans to user, with skip conditions\n  for explicit opt-out and already-reviewed plans\n- Simplify plan-reviewer step 1 to review-only (remove plan creation\n  case) and track read file path as review history write target\n- Replace generic \"plan.md\" references with \"plan file identified in\n  step 1\" for reliable review history recording",
          "timestamp": "2026-03-26T17:52:11+09:00",
          "tree_id": "f02ef098e8307e051e2d0299c22b97b18209ab0f",
          "url": "https://github.com/r-okm/dotfiles/commit/75eb959c6e13e3aa68d8583470daf19a66f31056"
        },
        "date": 1774568703978,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 18.7,
            "range": "0.6",
            "unit": "ms",
            "extra": "min: 18.5ms, max: 19.1ms, median: 18.7ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "841c585a19c52e1b420b4b916b74204d762b0c99",
          "message": "claude: extract gh api calls into wrapper scripts for skill\n\n- Add gh-pr-fetch-reviews and gh-pr-fetch-comments scripts that\n  wrap gh-pr-parse + gh api to avoid $() command substitution\n  in skill ! backtick commands, which Claude Code rejects\n- Update fetch-pr-context skill to call wrapper scripts instead of\n  inline gh api with $(), and narrow allowed-tools accordingly\n- Add gh-pr-* script permissions to global settings.json",
          "timestamp": "2026-03-27T19:08:21+09:00",
          "tree_id": "858dc63ae517791d0aa3a0498d7712aa1d95feac",
          "url": "https://github.com/r-okm/dotfiles/commit/841c585a19c52e1b420b4b916b74204d762b0c99"
        },
        "date": 1774606671852,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 22.2,
            "range": "0.6",
            "unit": "ms",
            "extra": "min: 21.9ms, max: 22.5ms, median: 22.1ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "0e208388a720b5889aec136ec5c82baa7fdd1497",
          "message": "config: add VPN DNS auto-routing via systemd-resolved\n\n- Add chezmoi data.vpn section (dns_servers, ip_pattern, domain)\n  with empty defaults for public repo safety\n- Add run_onchange_after_302 script that deploys vpn-dns-monitor\n  service to auto-configure per-link DNS on VPN interface via\n  ip monitor address, with startup check for existing connections\n- Switch resolv.conf to systemd-resolved stub resolver and set\n  global DNS to 8.8.8.8, enabling domain-based routing (~ksc.local)\n- Remove templates/etc/resolv.conf containing hardcoded VPN DNS IPs",
          "timestamp": "2026-03-31T12:07:32+09:00",
          "tree_id": "02329c1cbd25d9ddcd7081995041b502f4b290e1",
          "url": "https://github.com/r-okm/dotfiles/commit/0e208388a720b5889aec136ec5c82baa7fdd1497"
        },
        "date": 1774927021140,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 24.3,
            "range": "1.1",
            "unit": "ms",
            "extra": "min: 23.9ms, max: 25.0ms, median: 24.4ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "e95737139721006356a8ec8532c8695da28e9e0f",
          "message": "config: use WSL2 dnsTunneling instead of custom DNS monitor\n\n- Remove vpn-dns-monitor systemd service and chezmoi data.vpn\n  section, replaced by WSL2 built-in dnsTunneling which routes\n  DNS queries through Windows virtualization layer\n- Switch generateResolvConf to true so WSL auto-generates\n  resolv.conf with the dnsTunneling endpoint (10.255.255.254)\n- VPN DNS resolution now handled by Windows side automatically,\n  eliminating VPN disconnect DNS timeout (9.8s → 1.8s SSH)",
          "timestamp": "2026-03-31T14:31:36+09:00",
          "tree_id": "b3f468ae179d56f12a864fb8c549d9bb0dc5ad10",
          "url": "https://github.com/r-okm/dotfiles/commit/e95737139721006356a8ec8532c8695da28e9e0f"
        },
        "date": 1774935661547,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 24.3,
            "range": "8.6",
            "unit": "ms",
            "extra": "min: 22.0ms, max: 30.6ms, median: 22.0ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "c5e1f3bfcc449235221da960c5cf16521e847dde",
          "message": "claude: add pr-description and review-pr skills\n\n- Add pr-description skill to generate PR title and description\n  from current branch diff or an existing PR number, with rules\n  for title format, summary section, and output (no commit/save)\n- Add review-pr skill (opus model) to review PRs with checklist\n  covering logic, security, naming, dead code, and PR title format\n- review-pr includes v3_gui-specific checks: i18n key consistency,\n  stale resource detection (pages, atoms, images), and useLoading\n  pattern (skip stopLoading on success+navigation paths)\n- Both skills use disable-model-invocation with gh/git tool access",
          "timestamp": "2026-04-06T09:03:57+09:00",
          "tree_id": "33b5d07d36787b22b5bedacde2936901172a764a",
          "url": "https://github.com/r-okm/dotfiles/commit/c5e1f3bfcc449235221da960c5cf16521e847dde"
        },
        "date": 1775434459788,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 24.4,
            "range": "11.8",
            "unit": "ms",
            "extra": "min: 22.2ms, max: 34.0ms, median: 22.9ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "3491735fc7bad0400f2e37dd25a7481a25b82083",
          "message": "config: show COPY indicator in tmux status-left during copy mode\n\n- Add pane_in_mode conditional to status-left, displaying yellow\n  \"COPY\" label when in copy mode, mirroring the existing cyan\n  \"PREFIX\" indicator style",
          "timestamp": "2026-04-09T11:55:17+09:00",
          "tree_id": "0cc100a10b6e6c67e36d74b659fbd19fd0c7768f",
          "url": "https://github.com/r-okm/dotfiles/commit/3491735fc7bad0400f2e37dd25a7481a25b82083"
        },
        "date": 1775703831968,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 18.9,
            "range": "0.6",
            "unit": "ms",
            "extra": "min: 18.6ms, max: 19.2ms, median: 18.9ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "6c5e6bfcd334d6cea907d5ca7780fd09ddda245c",
          "message": "claude: expand allowed Bash command patterns\n\n- Add `Bash(gh api repos/*)` wildcard covering general repos API calls\n- Add `Bash(~/.claude/r-okm/scripts/*)` for direct script execution\n  without python3 prefix requirement\n- Add `Bash(python3 --version)` for runtime version checks",
          "timestamp": "2026-04-10T13:05:59+09:00",
          "tree_id": "c3233ed27457e3f900f15b5bed15ae72b3038b62",
          "url": "https://github.com/r-okm/dotfiles/commit/6c5e6bfcd334d6cea907d5ca7780fd09ddda245c"
        },
        "date": 1775794534839,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 22,
            "range": "0.8",
            "unit": "ms",
            "extra": "min: 21.8ms, max: 22.6ms, median: 22.0ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "9c929021f560ab704e85fcd48d4709370013f4d0",
          "message": "claude: allow WebFetch for zenn.dev, neovim.io, vimhelp.org\n\n- Add zenn.dev, neovim.io, and vimhelp.org to WebFetch allow rules\n  in settings.json.tmpl",
          "timestamp": "2026-04-11T13:35:55+09:00",
          "tree_id": "96cf35ed925f11cbc8c0ea03b87eb4d76e756f17",
          "url": "https://github.com/r-okm/dotfiles/commit/9c929021f560ab704e85fcd48d4709370013f4d0"
        },
        "date": 1775882653319,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 22.1,
            "range": "1.9",
            "unit": "ms",
            "extra": "min: 21.5ms, max: 23.5ms, median: 22.0ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "be106d8fc9c1d373fdc186c05324d3090274821d",
          "message": "claude: enable skipAutoPermissionPrompt setting\n\n- Set skipAutoPermissionPrompt to true in settings.json.tmpl",
          "timestamp": "2026-04-21T08:30:40+09:00",
          "tree_id": "e0dd035f59f10c9f2706dc6a74e63704348ade91",
          "url": "https://github.com/r-okm/dotfiles/commit/be106d8fc9c1d373fdc186c05324d3090274821d"
        },
        "date": 1776728388996,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 22.1,
            "range": "2.1",
            "unit": "ms",
            "extra": "min: 21.6ms, max: 23.6ms, median: 21.9ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "634aa0ea420985140d4cbc527beb617bc77f14b4",
          "message": "claude: refine permission rules based on log analysis\n\n- Add git fetch/pull/clone, gh search, npm help, python3 -m json.tool,\n  and Read(~/.claude/**) to cover read-only operations observed in\n  permission request logs\n- Add quoted variants `gh api 'repos/*` and `gh api \"repos/*` to match\n  commands where URLs are shell-quoted for query strings\n- Add WebFetch for docs.npmjs.com\n- Remove dead `gh api '/repos/{owner}/{repo}/pulls/*/...' rules with\n  literal `{owner}/{repo}` placeholders and leading slash that never\n  matched actual invocations",
          "timestamp": "2026-04-23T12:04:53+09:00",
          "tree_id": "8fced8b9b96f94219f343a4d136ecf2f15af5596",
          "url": "https://github.com/r-okm/dotfiles/commit/634aa0ea420985140d4cbc527beb617bc77f14b4"
        },
        "date": 1776914092918,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 27.8,
            "range": "8.9",
            "unit": "ms",
            "extra": "min: 24.9ms, max: 33.8ms, median: 25.5ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "49a0bb9454986980c34282727f3b39615715109a",
          "message": "claude: set theme to dark-ansi\n\n- Replace skipAutoPermissionPrompt with theme setting, applying dark-ansi",
          "timestamp": "2026-05-07T08:52:32+09:00",
          "tree_id": "2c24752a9d466dab99d1011610120c5d72450e90",
          "url": "https://github.com/r-okm/dotfiles/commit/49a0bb9454986980c34282727f3b39615715109a"
        },
        "date": 1778112184126,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 19.6,
            "range": "6.9",
            "unit": "ms",
            "extra": "min: 18.6ms, max: 25.6ms, median: 18.8ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "078f0c3e1398df9206f36bf9228a0a36d6468043",
          "message": "git: switch sshCommand identity to public key for 1Password agent\n\n- Reference .pub files instead of private keys in personal and work\n  gitconfig sshCommand, letting the 1Password SSH agent supply the\n  matching private key from the vault",
          "timestamp": "2026-05-23T14:09:01+09:00",
          "tree_id": "689d00679f476dd4d05884843c772e151ec6475f",
          "url": "https://github.com/r-okm/dotfiles/commit/078f0c3e1398df9206f36bf9228a0a36d6468043"
        },
        "date": 1779513418805,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 21.3,
            "range": "0.9",
            "unit": "ms",
            "extra": "min: 21.0ms, max: 21.9ms, median: 21.3ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "aba096debdc786d1c14bb39ddf86d55e27feb031",
          "message": "config: pin git completion to installed git version tag\n\n- Replace master with the installed git version tag in the _git\n  external URL, resolved via the git --version output at apply time,\n  so the completion script matches the git binary and avoids errors\n  from options that only exist on unreleased master (e.g. git help\n  --aliases-for-completion)",
          "timestamp": "2026-05-28T10:19:45+09:00",
          "tree_id": "7c481aaa80f6bed3ec6b982a9daf19fbce1691ea",
          "url": "https://github.com/r-okm/dotfiles/commit/aba096debdc786d1c14bb39ddf86d55e27feb031"
        },
        "date": 1779931646380,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 24.6,
            "range": "1.7",
            "unit": "ms",
            "extra": "min: 24.2ms, max: 25.9ms, median: 24.4ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "bb065dd546a7134badaf0bcde0dc5ba7238ec7e6",
          "message": "tmux: open paths from extrakto in running nvim\n\n- Add extrakto-open.sh dispatcher wired as @extrakto_open_tool:\n  URL-like selections still go to xdg-open, while file paths are\n  opened in the nvim that runs in window 2 of the current session\n  via send-keys (:edit + :call cursor for :line[:col] suffixes)\n- Guard the send by checking window 2's window_name from\n  list-windows, since display-message -t silently falls back to\n  the current window when the target index is missing\n- Skip <CR> when realpath -m points at a missing file so :edit\n  stays on the nvim cmdline for manual correction, and use\n  display-message -d 0 so error notices persist until dismissed\n- Add `bind f` to launch extrakto with the path filter, mirroring\n  the existing `bind u` url-filter binding",
          "timestamp": "2026-05-28T11:32:00+09:00",
          "tree_id": "278e5e8e4463aaeb3d934e6835951b883195aa71",
          "url": "https://github.com/r-okm/dotfiles/commit/bb065dd546a7134badaf0bcde0dc5ba7238ec7e6"
        },
        "date": 1779936005691,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 25,
            "range": "1.2",
            "unit": "ms",
            "extra": "min: 24.6ms, max: 25.8ms, median: 24.9ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "05c49ed6c192d733c4da908dcae7270d86c5a19b",
          "message": "claude: refine permission rules based on log analysis\n\n- Add git ls-remote, git lfs ls-files/pull (push intentionally\n  excluded to keep the git push deny effective), gh api /repos/*\n  for the leading-slash variant, and Read rules for /tmp,\n  ~/.config/zsh/completions, ~/.config/tmux/plugins to cover\n  read-only operations observed in permission request logs\n- Add WebFetch for www.1password.dev to allow reading 1Password\n  SSH agent documentation",
          "timestamp": "2026-05-28T15:58:12+09:00",
          "tree_id": "2edfcb9ed463b8a3ed3cc81ce1b4cb3e423a15e9",
          "url": "https://github.com/r-okm/dotfiles/commit/05c49ed6c192d733c4da908dcae7270d86c5a19b"
        },
        "date": 1779952017841,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 25.2,
            "range": "1.7",
            "unit": "ms",
            "extra": "min: 24.5ms, max: 26.2ms, median: 25.1ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "dbd825fecf702229e30ca7f2d118fa89fb91cf0d",
          "message": "tmux: add Alt key bindings for window navigation and editor insert\n\n- Bind M-l/M-h to next/previous window for quick navigation without prefix\n- Bind M-k to enter copy mode\n- Bind M-j to insert-from-editor.sh, mirroring the prefix-i binding\n- Bind M-m to select-window -t 1, mirroring the prefix-m binding",
          "timestamp": "2026-05-28T18:18:15+09:00",
          "tree_id": "25b79a3d4c9edfb43214a964249f08f12db54dd5",
          "url": "https://github.com/r-okm/dotfiles/commit/dbd825fecf702229e30ca7f2d118fa89fb91cf0d"
        },
        "date": 1779960349799,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 18.6,
            "range": "0.5",
            "unit": "ms",
            "extra": "min: 18.3ms, max: 18.8ms, median: 18.6ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "6f01d5da13c096a5b40a66fc1c40082f7c665b9c",
          "message": "claude: clarify .ignore usage for AI temporary files\n\n- Replace the vague \"temporary files or local-only working files\"\n  description with a directive to place AI-created temporary files\n  (scratch notes, memos, generated artifacts, intermediate working\n  files) under .ignore/ai/**, giving a clear placement rule instead\n  of leaving the destination ambiguous",
          "timestamp": "2026-05-29T10:35:56+09:00",
          "tree_id": "d9d5e344998231ef5f4a94ead5961cc51a4bf367",
          "url": "https://github.com/r-okm/dotfiles/commit/6f01d5da13c096a5b40a66fc1c40082f7c665b9c"
        },
        "date": 1780019037199,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 28.1,
            "range": "10.5",
            "unit": "ms",
            "extra": "min: 24.4ms, max: 34.9ms, median: 26.8ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "053ec213c346d9253a247fb1ef0839bc269648f1",
          "message": "worktree: symlink .claude subpaths instead of whole dir\n\n- Replace the full .claude symlink with .claude/settings.local.json\n  and .claude/hooks so each worktree keeps its own .claude directory\n  while sharing only the settings and hooks with the original repo;\n  create_symlinks already mkdir -p's the parent, so the nested\n  .claude/ is created in the worktree before the symlinks are placed",
          "timestamp": "2026-06-02T14:35:12+09:00",
          "tree_id": "a5f48f1c603a91acb82513125149503f141a22fa",
          "url": "https://github.com/r-okm/dotfiles/commit/053ec213c346d9253a247fb1ef0839bc269648f1"
        },
        "date": 1780379026349,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 29.5,
            "range": "8.7",
            "unit": "ms",
            "extra": "min: 27.7ms, max: 36.4ms, median: 28.0ms (10 runs)"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "committer": {
            "email": "65703649+r-okm@users.noreply.github.com",
            "name": "r-okm",
            "username": "r-okm"
          },
          "distinct": true,
          "id": "72ce7978b562279ce4de7437c7187b8565fc5dcf",
          "message": "aliases: add gc alias for git commit\n\n- Add `gc` as a shorthand for `git commit` to both bash_aliases and\n  zsh-abbr user-abbreviations, consistent with the existing git alias set",
          "timestamp": "2026-06-04T16:15:20+09:00",
          "tree_id": "1f7b3024fd8b86e1cee26c3d6f109da90267886c",
          "url": "https://github.com/r-okm/dotfiles/commit/72ce7978b562279ce4de7437c7187b8565fc5dcf"
        },
        "date": 1780557838160,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 27.8,
            "range": "1.4",
            "unit": "ms",
            "extra": "min: 27.6ms, max: 29.0ms, median: 27.7ms (10 runs)"
          }
        ]
      }
    ]
  }
}