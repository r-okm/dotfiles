window.BENCHMARK_DATA = {
  "lastUpdate": 1786858397134,
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
          "id": "74a909f686c779f54eef129dc21ba1649f599d88",
          "message": "explorer: replace powershell launcher with script\n\n- Add ~/.local/bin/explorer that converts the target directory with\n  wslpath -w and launches /mnt/c/Windows/explorer.exe directly on WSL\n  (falling back to xdg-open on other systems), defaulting to the\n  current directory and ignoring explorer.exe's always-1 exit status\n- Remove the powershell-based explorer.desktop and its\n  inode/directory entry in mimeapps.list, superseded by the script\n- Add `x` as a shorthand for explorer to both bash_aliases and\n  zsh-abbr user-abbreviations",
          "timestamp": "2026-06-04T18:00:29+09:00",
          "tree_id": "bacdb42d3d2fdf9661611c6337074fb67ace8c4e",
          "url": "https://github.com/r-okm/dotfiles/commit/74a909f686c779f54eef129dc21ba1649f599d88"
        },
        "date": 1780564174774,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 27.7,
            "range": "0.6",
            "unit": "ms",
            "extra": "min: 27.5ms, max: 28.1ms, median: 27.5ms (10 runs)"
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
          "id": "8849b732c77e880f2af8ebb9ab83c0381043c484",
          "message": "claude: switch worktree symlink and ignore to .claude/local\n\n- Replace the .claude/hooks symlink target with .claude/local in\n  git-worktree-tmux, so each worktree shares a single local-only\n  .claude/local directory with the original repo instead of just\n  hooks, broadening it to any uncommitted local Claude files\n- Add **/.claude/local to the global git ignore alongside the\n  existing settings.local.json and CLAUDE.local.md entries, keeping\n  the directory out of version control while still shared via symlink",
          "timestamp": "2026-06-10T13:50:00+09:00",
          "tree_id": "4c60f24ef9c96ef5129874321a97cfdbf5bacf51",
          "url": "https://github.com/r-okm/dotfiles/commit/8849b732c77e880f2af8ebb9ab83c0381043c484"
        },
        "date": 1781067751728,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 31.6,
            "range": "9.8",
            "unit": "ms",
            "extra": "min: 27.3ms, max: 37.0ms, median: 32.0ms (10 runs)"
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
          "id": "ccf88505eb142ff2b6625231adac6ad5e36a535d",
          "message": "zsh: shorten tab title to last dir only, truncate if long\n\n- Show only the final directory in full instead of the last two,\n  collapsing the second-to-last (e.g. .worktree) to its initial like\n  the other ancestors, since the parent dir rarely aids disambiguation\n- Truncate the final directory to max_last (20) chars when longer,\n  keeping the tail and prefixing … so long worktree branch names no\n  longer blow up the terminal/tmux window title while the abbreviated\n  path structure stays intact",
          "timestamp": "2026-06-17T10:59:00+09:00",
          "tree_id": "6239d44cbbd00deafc0e84ac455a728c661ca039",
          "url": "https://github.com/r-okm/dotfiles/commit/ccf88505eb142ff2b6625231adac6ad5e36a535d"
        },
        "date": 1781662108939,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 25.8,
            "range": "0.5",
            "unit": "ms",
            "extra": "min: 25.6ms, max: 26.1ms, median: 25.8ms (10 runs)"
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
          "id": "a28bad07cd5d67503790ee5937764b681e42a5fa",
          "message": "tmux: rebind window navigation to Ctrl-PgDn/PgUp\n\n- Replace M-l/M-h with C-PgDn/C-PgUp for next/previous window,\n  matching the conventional terminal tab-switching shortcuts",
          "timestamp": "2026-06-17T13:13:14+09:00",
          "tree_id": "b0add60417198157b8f83ff4602781c352b811c6",
          "url": "https://github.com/r-okm/dotfiles/commit/a28bad07cd5d67503790ee5937764b681e42a5fa"
        },
        "date": 1781670020231,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 24,
            "range": "6.8",
            "unit": "ms",
            "extra": "min: 21.3ms, max: 28.1ms, median: 21.9ms (10 runs)"
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
          "id": "08616a889fe2f8a2bbeeffcb648a603051256fa5",
          "message": "claude: remove git add from deny list\n\n- `git add` is a safe local operation and does not need to be in the\n  deny list alongside `git push`; removing it reduces unnecessary\n  permission prompts without any security trade-off",
          "timestamp": "2026-06-23T16:45:10+09:00",
          "tree_id": "dafd6269d7341e2f81f6bd35025c547803372fb4",
          "url": "https://github.com/r-okm/dotfiles/commit/08616a889fe2f8a2bbeeffcb648a603051256fa5"
        },
        "date": 1782201185519,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 18.2,
            "range": "0.3",
            "unit": "ms",
            "extra": "min: 18.2ms, max: 18.4ms, median: 18.2ms (10 runs)"
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
          "id": "0b86272adf242bb4955a0b1205a16df9406c7bbc",
          "message": "claude: set fullscreen TUI and default model to Opus 4.6\n\n- Set `tui` to fullscreen for a full-terminal Claude Code interface\n- Set `model` to claude-opus-4-6 as the default model",
          "timestamp": "2026-06-30T13:08:25+09:00",
          "tree_id": "a3fddf0dd5838a92d3db7a9e5d7b43188430589c",
          "url": "https://github.com/r-okm/dotfiles/commit/0b86272adf242bb4955a0b1205a16df9406c7bbc"
        },
        "date": 1782793303441,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 25.5,
            "range": "1.3",
            "unit": "ms",
            "extra": "min: 24.9ms, max: 26.2ms, median: 25.5ms (10 runs)"
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
          "id": "73e60814d248609a697b65579935487b13306edb",
          "message": "lazygit: disable git autoFetch\n\nPrevent background fetches from lazygit interfering with manual fetch/pull timing.",
          "timestamp": "2026-07-01T09:45:49+09:00",
          "tree_id": "b7d0077c204614ec317f028727c25fbd291b250e",
          "url": "https://github.com/r-okm/dotfiles/commit/73e60814d248609a697b65579935487b13306edb"
        },
        "date": 1782867214069,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 27,
            "range": "0.4",
            "unit": "ms",
            "extra": "min: 26.8ms, max: 27.3ms, median: 27.1ms (10 runs)"
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
          "id": "9921efce4a14ede6b092891a6ecffc4b0288492b",
          "message": "claude: switch model from `opus-4-6` to `opus-4-6[1m]`",
          "timestamp": "2026-07-01T16:38:34+09:00",
          "tree_id": "3120fbe7e2c4cba91d0421459c125e754c3be186",
          "url": "https://github.com/r-okm/dotfiles/commit/9921efce4a14ede6b092891a6ecffc4b0288492b"
        },
        "date": 1782892113198,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 26.2,
            "range": "5.8",
            "unit": "ms",
            "extra": "min: 24.7ms, max: 30.5ms, median: 25.4ms (10 runs)"
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
          "id": "28f6b2475f5cf6970c98568c2d99f9d5767b5aaf",
          "message": "notification: replace tmux popup with desktop notifications\n\nReplace tmux display-popup notifications with desktop-notify, a\ncross-platform desktop notification command using Windows toast\n(WinRT API) on WSL, notify-send on Linux, and osascript on macOS.\n\n- Add desktop-notify to ~/.local/bin as a generic notification tool\n- Add notify-claude-activity.sh for Claude Code Stop/Notification hooks\n  with transcript polling (exponential backoff) for response text\n- Update tmux alert-bell hook to use desktop-notify\n- Remove old notify-to-tmux-popup.sh",
          "timestamp": "2026-07-03T13:53:03+09:00",
          "tree_id": "e0fda57857cff86af1c09039aff92dd0b37d33f8",
          "url": "https://github.com/r-okm/dotfiles/commit/28f6b2475f5cf6970c98568c2d99f9d5767b5aaf"
        },
        "date": 1783054848079,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 29,
            "range": "11.4",
            "unit": "ms",
            "extra": "min: 25.2ms, max: 36.7ms, median: 26.1ms (10 runs)"
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
          "id": "7d71aaeef83dda8aae20e70929df748fc09616e1",
          "message": "notification: fix Stop hook failing with SIGPIPE on long transcripts\n\n- Replace `tac | jq | head -1` with `jq | tail -1`: head's early exit\n  killed the pipeline (exit 141) under pipefail once the transcript grew\n- Skip notification when launched outside tmux instead of dying on\n  unbound TMUX_PANE",
          "timestamp": "2026-07-03T19:28:48+09:00",
          "tree_id": "ecf325fde5c85e54c5fe57fad87bf8cef03eea42",
          "url": "https://github.com/r-okm/dotfiles/commit/7d71aaeef83dda8aae20e70929df748fc09616e1"
        },
        "date": 1783075223206,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 26.1,
            "range": "4.0",
            "unit": "ms",
            "extra": "min: 25.1ms, max: 29.1ms, median: 25.6ms (10 runs)"
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
          "id": "73b5b9335d42dff3b24883cc4e492d49f2a06cd8",
          "message": "claude: add disable-model-invocation to address and analyze-permissions skills\n\n- Add `disable-model-invocation: true` to address/SKILL.md and\n  analyze-permissions/SKILL.md to prevent auto-invocation by the model",
          "timestamp": "2026-07-09T09:29:34+09:00",
          "tree_id": "8721bcb26e5a4a8e2dc2f511396a52625ad63ff8",
          "url": "https://github.com/r-okm/dotfiles/commit/73b5b9335d42dff3b24883cc4e492d49f2a06cd8"
        },
        "date": 1783557516414,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 25.8,
            "range": "6.2",
            "unit": "ms",
            "extra": "min: 24.4ms, max: 30.7ms, median: 25.1ms (10 runs)"
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
          "id": "3a05c7b94401d280d071fe9d9aaafec1c0470ba7",
          "message": "claude: dim status line colors with SGR faint attribute",
          "timestamp": "2026-07-09T13:29:11+09:00",
          "tree_id": "32bed2980518d01bfa28b67ce9fba8c7d03ed602",
          "url": "https://github.com/r-okm/dotfiles/commit/3a05c7b94401d280d071fe9d9aaafec1c0470ba7"
        },
        "date": 1783571930181,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 25.4,
            "range": "3.9",
            "unit": "ms",
            "extra": "min: 24.7ms, max: 28.5ms, median: 24.9ms (10 runs)"
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
          "id": "dcc4186ddd20c72490110e294483c6aec2d1b6b5",
          "message": "claude: redesign status line with a single-line segmented indicator\n\nShow model, context, and 5h/7d rate limits on one pipe-separated line.\nRate limits use a 10-segment ▮/▯ bar (bright green fill, gray track) plus\ntheir reset time; the 7d reset is formatted as M/d HH:MM.",
          "timestamp": "2026-07-10T10:49:11+09:00",
          "tree_id": "ecc1ccda57a3b0ec6abfa60389c2e9ef407a4597",
          "url": "https://github.com/r-okm/dotfiles/commit/dcc4186ddd20c72490110e294483c6aec2d1b6b5"
        },
        "date": 1783649050152,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 27.5,
            "range": "0.8",
            "unit": "ms",
            "extra": "min: 27.2ms, max: 28.0ms, median: 27.4ms (10 runs)"
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
          "id": "46bdbdea587aa692edd10147bc49de951a0b70dc",
          "message": "claude: turn chezmoi_sync into a standalone chezmoi-sync script\n\nMove the zsh function into ~/.local/bin/chezmoi-sync so it is callable\nfrom non-interactive shells (incl. Claude Code Bash), and rename it to\nhyphenated form per the bin/ naming convention. Update the chs abbr and\nCLAUDE.md references accordingly.",
          "timestamp": "2026-07-10T14:11:25+09:00",
          "tree_id": "795f06474667da9f3034cd61dfd51f1a0011955d",
          "url": "https://github.com/r-okm/dotfiles/commit/46bdbdea587aa692edd10147bc49de951a0b70dc"
        },
        "date": 1783660811720,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 25,
            "range": "1.2",
            "unit": "ms",
            "extra": "min: 24.5ms, max: 25.7ms, median: 24.9ms (10 runs)"
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
          "id": "1e3d6497dd6d7bf85490b5c647afd5d175ed9477",
          "message": "claude: enable compact-plus plugin from u-ichi/compact-plus marketplace",
          "timestamp": "2026-07-13T16:38:24+09:00",
          "tree_id": "4ff8a0683ccf8b5c082863f93ff6e5ba56ae32bc",
          "url": "https://github.com/r-okm/dotfiles/commit/1e3d6497dd6d7bf85490b5c647afd5d175ed9477"
        },
        "date": 1783928804987,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 24.6,
            "range": "1.7",
            "unit": "ms",
            "extra": "min: 24.1ms, max: 25.8ms, median: 24.6ms (10 runs)"
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
          "id": "76c005b976b8ca54ce61d8e30f7c2314b384b9bc",
          "message": "claude: show used/total tokens next to context usage bar",
          "timestamp": "2026-07-13T17:14:35+09:00",
          "tree_id": "66a79777a06000ad6aee2d7826f430b60420467e",
          "url": "https://github.com/r-okm/dotfiles/commit/76c005b976b8ca54ce61d8e30f7c2314b384b9bc"
        },
        "date": 1783930997772,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 24.8,
            "range": "0.5",
            "unit": "ms",
            "extra": "min: 24.6ms, max: 25.1ms, median: 24.7ms (10 runs)"
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
          "id": "eb0574112123359101afb43d5ba5c2c63c66d761",
          "message": "claude: notify unless a focused client shows the claude window\n\nTargetless `tmux display-message` resolves via $TMUX to claude's own\nsession, so viewing another session was misdetected as viewing the\nclaude window and the notification was suppressed. Check attached\nclients' displayed window and focused flag via list-clients instead,\nand enable focus-events so the focused flag reflects terminal focus.",
          "timestamp": "2026-07-14T16:36:48+09:00",
          "tree_id": "2ef1d4bc937cd40a5e081f011fedda6aa78512ce",
          "url": "https://github.com/r-okm/dotfiles/commit/eb0574112123359101afb43d5ba5c2c63c66d761"
        },
        "date": 1784015107544,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 19.4,
            "range": "1.2",
            "unit": "ms",
            "extra": "min: 19.1ms, max: 20.3ms, median: 19.3ms (10 runs)"
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
          "id": "cf69a0d5243db75876362f853b01248d1a0e24ca",
          "message": "claude: split plan review into skill and agent\n\nThe plan-reviewer agent's self-managed review loop fabricated\nconvergence (history recorded clean rounds that never ran) and hit\nmaxTurns mid-report in half of observed runs. Make the agent a\nread-only single-round reviewer returning CONFIRMED/PLAUSIBLE\nverdicts with concrete failure scenarios, capped at 10 findings,\nwith a gap-sweep mode from round 2. Add a plan-review skill that\ndrives the loop instead: launch the reviewer, apply fixes, and\nrecord one review-history round per launch so the history stays\nverifiable against actual agent runs. Shrink the CLAUDE.md Planning\nsection to a pointer to the skill. The layout mirrors the built-in\ncode-review skill (skill orchestrates, subagent reviews).\n\nAlso switch the agent from pinned sonnet to inherit and drop\nmaxTurns, which the single-round design no longer needs.",
          "timestamp": "2026-07-17T13:28:48+09:00",
          "tree_id": "d365376310cbc2f6faeb10ea15efa84cc7f613ad",
          "url": "https://github.com/r-okm/dotfiles/commit/cf69a0d5243db75876362f853b01248d1a0e24ca"
        },
        "date": 1784263009496,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 25.4,
            "range": "3.4",
            "unit": "ms",
            "extra": "min: 24.8ms, max: 28.3ms, median: 25.1ms (10 runs)"
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
          "id": "0c70f46c9c90d3725cc1c8e90dd7df1b43f57f33",
          "message": "claude: add /ss skill to load Windows screenshots by index\n\nWSL screenshots have Japanese/space filenames that are awkward to @-reference.\n/ss returns newest-first screenshot paths (no arg = latest 1; supports\nindividual indices and ranges like '1 3' / '2-4' / '1 3-5') and reads them\nas images. Directory auto-detected via powershell GetFolderPath('MyPictures'),\noverridable with SS_DIR. /mnt/c paths need no conversion.",
          "timestamp": "2026-07-23T14:30:09+09:00",
          "tree_id": "4fde4cfe042c61eefdbb362eca8ba6a4607ce461",
          "url": "https://github.com/r-okm/dotfiles/commit/0c70f46c9c90d3725cc1c8e90dd7df1b43f57f33"
        },
        "date": 1784785177554,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 25,
            "range": "1.1",
            "unit": "ms",
            "extra": "min: 24.6ms, max: 25.7ms, median: 24.9ms (10 runs)"
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
          "id": "a3a6d4cafabb7b41c115c025e0211a779e4c4ba3",
          "message": "claude: fix /ss octal index abort and no-arg permission match\n\nCode review on 0c70f46 found two issues:\n- Leading-zero indices/ranges (08, 1-09) were parsed as invalid octal in\n  arithmetic contexts, aborting under set -e. Normalize with 10# at parse.\n- Bare /ss (no args) may not match the 'ss.sh *' allow-rule; add a\n  no-arg allow pattern so the default case never prompts.",
          "timestamp": "2026-07-23T14:52:58+09:00",
          "tree_id": "ff8506872d94b242e1ea71f945725570e6b1d603",
          "url": "https://github.com/r-okm/dotfiles/commit/a3a6d4cafabb7b41c115c025e0211a779e4c4ba3"
        },
        "date": 1784861131334,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 28.1,
            "range": "0.7",
            "unit": "ms",
            "extra": "min: 27.8ms, max: 28.4ms, median: 28.2ms (10 runs)"
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
          "id": "a6e187ea6388ec319b85ebd8c47ff7377916c609",
          "message": "worktree: add -c to create a branch in a new worktree\n\n`git-worktree-tmux -c [<suffix>]` creates `<user.name>/<suffix>` (defaulting\nto `wip-<epoch>`) from the remote HEAD as part of `git worktree add`, so the\nHEAD of the worktree the command is run from stays untouched.\n\nAlso resolve paths from the main worktree instead of `--show-toplevel`, which\nnested new worktrees under the current one when run from a linked worktree.",
          "timestamp": "2026-07-30T15:34:14+09:00",
          "tree_id": "8d64e3ccbb450895ebf1b776555396a18cdb6798",
          "url": "https://github.com/r-okm/dotfiles/commit/a6e187ea6388ec319b85ebd8c47ff7377916c609"
        },
        "date": 1785393815477,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 28.3,
            "range": "0.8",
            "unit": "ms",
            "extra": "min: 27.8ms, max: 28.5ms, median: 28.1ms (10 runs)"
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
          "id": "f62942d2fe6eb398a5469b43653ab40f0d8865f9",
          "message": "worktree: add -d to keep the tmux session detached\n\nOnly the attach/switch-client step is disruptive, so `-d` skips it and creates\nthe session in the background instead, printing the worktree path on the last\nline of stdout. This makes the command safe for the AI to run itself.\n\nMatch tmux session names exactly with `-t \"=<name>\"`; a bare target also\nmatches by prefix, which made `has-session` report an unrelated session as\nthis one whenever a branch name was a prefix of another.",
          "timestamp": "2026-07-30T16:00:55+09:00",
          "tree_id": "75771be1342b34afdfe2f8502071a7c17c617f5b",
          "url": "https://github.com/r-okm/dotfiles/commit/f62942d2fe6eb398a5469b43653ab40f0d8865f9"
        },
        "date": 1785395381427,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 21.5,
            "range": "2.0",
            "unit": "ms",
            "extra": "min: 21.1ms, max: 23.1ms, median: 21.3ms (10 runs)"
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
          "id": "f046bddee62689f39290c91d3905e5555b1fc094",
          "message": "claude: harden permission rules\n\n- deny reads of credential files (.credentials.json, *.pem, id_rsa*)\n  instead of relying on a CLAUDE.md instruction\n- drop allow rules that were effectively write/exec: cat/head/grep/find,\n  tmux send-keys, gh api (POST/DELETE passes through), echo,\n  git pull/clone/lfs pull\n- ask before edits under ~/.claude/r-okm/scripts to close the\n  write-then-run loophole of the exec allow rules\n- fix broken path syntax: absolute paths need //, and settings-relative\n  ./ rules never matched project files (.env, secrets) — use **/ instead\n- allow git grep, npx eslint, qiita.com, and //tmp reads based on\n  permission-prompt log analysis",
          "timestamp": "2026-07-30T17:24:30+09:00",
          "tree_id": "0a3ca541ee81e490d49d0b7c4d5a2925b7dac783",
          "url": "https://github.com/r-okm/dotfiles/commit/f046bddee62689f39290c91d3905e5555b1fc094"
        },
        "date": 1785400436843,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 27.5,
            "range": "0.9",
            "unit": "ms",
            "extra": "min: 27.2ms, max: 28.0ms, median: 27.3ms (10 runs)"
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
          "id": "9f2c5c26fd74c5533ff8eabb9e3cdbd3769db6ad",
          "message": "zsh: zcompile .zcompdump to speed up startup",
          "timestamp": "2026-07-31T10:04:13+09:00",
          "tree_id": "1820d09e30da60572582486f09f162850e33ec57",
          "url": "https://github.com/r-okm/dotfiles/commit/9f2c5c26fd74c5533ff8eabb9e3cdbd3769db6ad"
        },
        "date": 1785460386509,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 22.5,
            "range": "1.0",
            "unit": "ms",
            "extra": "min: 22.1ms, max: 23.1ms, median: 22.5ms (10 runs)"
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
          "id": "371b00df73e95c8a4b8b30ed0f4cd5c8c01db17d",
          "message": "zsh: use compinit -C unconditionally, drop the GITHUB_ACTIONS branch\n\nThe branch was added in #50 to avoid compaudit's \"insecure\ndirectories\" error on CI runners by passing -u. compinit -C skips\nthe compaudit security check entirely (in addition to the dump\nfreshness check), so -C avoids the same error and the branch is\nunnecessary.\n\nThis also makes the CI benchmark measure the exact code path users\nrun locally (compinit -C sourcing the zcompiled dump), so it can now\ndetect regressions in the .zwc fast path. Dump regeneration is owned\nby the run_onchange rebuild script.",
          "timestamp": "2026-07-31T10:32:39+09:00",
          "tree_id": "8205e49c6a039883fcf2b573ce16e3e36d11cbac",
          "url": "https://github.com/r-okm/dotfiles/commit/371b00df73e95c8a4b8b30ed0f4cd5c8c01db17d"
        },
        "date": 1785462192983,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 10.6,
            "range": "0.3",
            "unit": "ms",
            "extra": "min: 10.5ms, max: 10.8ms, median: 10.6ms (10 runs)"
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
          "id": "9cfa0ca39962c648f2da536b9575dd7fbb060696",
          "message": "claude: make /ss copy screenshots out of /mnt\n\n- the Read(//mnt/**) deny broke /ss once f046bdd fixed the rule's path\n  syntax and made it effective; a deny rule cannot carry an allowlist\n  exception, so the screenshot folder cannot be re-opened selectively\n- copy the selection into $XDG_CACHE_HOME/ss and emit those paths, and\n  allow Read there, instead of enumerating what to keep denied under\n  /mnt/c — that list would be open-ended and hard to maintain\n- number the copies in requested order: original names carry spaces\n  and non-ASCII, and only the order matters to the caller",
          "timestamp": "2026-07-31T16:49:39+09:00",
          "tree_id": "4c47639b5688cdd36c81d358230ed3954ea74308",
          "url": "https://github.com/r-okm/dotfiles/commit/9cfa0ca39962c648f2da536b9575dd7fbb060696"
        },
        "date": 1785484777521,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 9.9,
            "range": "0.3",
            "unit": "ms",
            "extra": "min: 9.8ms, max: 10.0ms, median: 9.9ms (10 runs)"
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
          "id": "8287fb5ee955f8b687141ce9086d906ae93cc79c",
          "message": "claude: add video-frames skill for reading videos as frames\n\nThe Read tool handles images and PDFs but not video containers, so a\nscreen recording attached to an investigation could not be inspected at\nall. This extracts frames with ffmpeg and packs them into labelled\ncontact sheets that Read can consume.\n\nffmpeg comes from apt rather than the PyPI ffmpeg-binaries wheel the\nfirst version bootstrapped into ~/.local/bin. That wheel was a\nworkaround for an environment where sudo and curl were blocked, and\npreparing the machine belongs to its owner, not to the script.\nfontconfig is listed explicitly because fc-match locates the font\ndrawtext burns frame labels with, and ffmpeg only pulls in\nlibfontconfig1, not the CLI.\n\nsettings.json needs Skill(video-frames) of its own: the existing\nBash(~/.claude/r-okm/scripts/*) rule permits running the script but not\ninvoking the skill that wraps it, so without it every use starts with a\npermission prompt.\n\nDetails that needed measuring rather than guessing:\n\n- -fps_mode is detected, not assumed. It replaced -vsync in ffmpeg 5.0\n  and Ubuntu 22.04 still ships 4.4. Without a passthrough mode the\n  image2 muxer resamples to a constant rate and silently duplicates or\n  drops frames whenever select emits them unevenly.\n- Every ffmpeg path is relative to a cd into the directory holding it.\n  The image2 muxer expands % in the whole output path and the demuxer\n  expands %d in an input path, while .ignore is a symlink into a\n  per-project store whose directory name contains %.\n- --out is made absolute without resolving symlinks, so output stays\n  where the caller asked for it instead of landing in that store.\n- Frames are numbered %06d because the glob that collects them orders\n  lexicographically. An overflow to a wider number would sort\n  frame_10000 ahead of frame_9999 and pair every later frame with the\n  wrong timestamp.\n- Unparsable showinfo timestamps become '?' rather than being dropped,\n  which would shift every later frame onto its neighbour's time.\n- Frames are never upscaled. The point of the skill is context economy,\n  and enlarging a small source multiplies tokens without adding detail.\n- Contact sheet tiles fit inside a grid cell instead of filling its\n  width. A 9:16 source at 3x3 would otherwise stack past the 1568px\n  edge where images get downsampled, shrinking the burnt-in labels\n  below readability.\n- Frames are built in a staging directory and moved in only on success,\n  so a failed run leaves the previous output intact. Concurrent runs\n  sharing one output directory are still last-writer-wins: the move is\n  several steps, not an atomic swap.\n- --info reports the effective frame rate. A container can advertise\n  120fps while carrying 30fps of frames, which misleads interval\n  planning.\n- --crop exists because agents needing to inspect a region rebuilt the\n  whole label-and-tile pipeline in raw ffmpeg, losing the\n  index-to-timestamp mapping in the process.",
          "timestamp": "2026-07-31T17:31:04+09:00",
          "tree_id": "9353728a04cb88a4d2d5430c1b37a2950b29cc26",
          "url": "https://github.com/r-okm/dotfiles/commit/8287fb5ee955f8b687141ce9086d906ae93cc79c"
        },
        "date": 1785487215842,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 10.9,
            "range": "0.4",
            "unit": "ms",
            "extra": "min: 10.7ms, max: 11.1ms, median: 10.9ms (10 runs)"
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
          "id": "54ff98515b6b34b7107fb9e8650a8a37db55a31c",
          "message": "worktree: initialize submodules in a new worktree\n\nA fresh worktree of a superproject has empty submodule directories, since\ngit worktree add does not recurse into them. Initialize them when\n.gitmodules is present.\n\n--filter=blob:none rather than --depth 1: a submodule is usually pinned\nto a commit behind its branch tip, and a shallow fetch of that\nunadvertised object is refused by some servers, leaving the submodule\nuninitialized. A blobless clone keeps the whole commit graph, so the\npinned commit always resolves, and a server without partial clone support\ndegrades to a full fetch -- slow, not broken.\n\nFailures warn instead of aborting; the worktree is already created by\nthen, and dying here would skip the tmux session.\n\nNote that git worktree remove now needs --force for these repositories\n(documented in git-worktree(1)). The Ctrl-D path of fzf_cd_worktree\nalready passes it.",
          "timestamp": "2026-08-04T10:13:43+09:00",
          "tree_id": "07ebf90cab511cc3d60948cbe2e128f2ebd3789a",
          "url": "https://github.com/r-okm/dotfiles/commit/54ff98515b6b34b7107fb9e8650a8a37db55a31c"
        },
        "date": 1785806588728,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 10.9,
            "range": "0.1",
            "unit": "ms",
            "extra": "min: 10.9ms, max: 11.1ms, median: 10.9ms (10 runs)"
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
          "id": "4d271e0a135aa148831f85c0346e593aeacb70f3",
          "message": "claude: add open-in-explorer skill for showing images to the user\n\nClaude can Read an image, but that image never reaches the user's terminal.\nUntil now the only way to let them see a generated chart or screenshot was to\nhand over a \\\\wsl.localhost\\... path and ask them to open it by hand. The\nskill points at the existing `explorer` command instead.\n\nIt fires only when the user has shown they want to look at something: they\nasked, or they asked for the artifact itself. Images produced as a means to an\nend are excluded -- the frames extracted to read a video are for Claude, not\nfor the user, and opening them buries the answer under a folder of stubs.\nThat distinction was wrong in the first draft and is the one part of the skill\nworth protecting.\n\nAllow Bash(explorer *) and Skill(open-in-explorer) so both the invocation and\nthe command it runs go through without a prompt. Skill() entries are needed\nhere: fetch-pr-context has one for the same reason.\n\nScoped to Opus and Sonnet, both verified to trigger it correctly and to leave\nintermediate artifacts alone. Haiku reads the image and answers \"it is\ndisplayed\" without ever calling the skill; it is out of scope rather than a\nreason to pad the description.",
          "timestamp": "2026-08-04T12:04:21+09:00",
          "tree_id": "45f0db66caa206f2333ab9f892013b2e86985bdd",
          "url": "https://github.com/r-okm/dotfiles/commit/4d271e0a135aa148831f85c0346e593aeacb70f3"
        },
        "date": 1785813187942,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 8.2,
            "range": "0.1",
            "unit": "ms",
            "extra": "min: 8.1ms, max: 8.2ms, median: 8.2ms (10 runs)"
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
          "id": "dcd67d7b60aa088f22028bf24d048f7688056cea",
          "message": "claude: turn off the unused handoff skill and drop the removed LSP plugins\n\nhandoff has not been invoked once since it was added, so switch it off\nthrough skillOverrides instead of deleting the skill itself.\n\nlua-lsp and rust-analyzer-lsp were uninstalled with /plugin, so their\ndisabled entries in enabledPlugins no longer point at anything.",
          "timestamp": "2026-08-06T16:36:10+09:00",
          "tree_id": "9ee9e4a55981fc959f5c22bd16e59ce7dd34ab46",
          "url": "https://github.com/r-okm/dotfiles/commit/dcd67d7b60aa088f22028bf24d048f7688056cea"
        },
        "date": 1786002407408,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 10,
            "range": "0.3",
            "unit": "ms",
            "extra": "min: 9.8ms, max: 10.2ms, median: 9.9ms (10 runs)"
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
          "id": "4c56622ba5d6000b98e479646d925a23071962e2",
          "message": "tmux: drop the extrakto nvim dispatcher\n\n@extrakto_open_tool pointed at a script that sent a selected file path\nto the nvim in window 2. Its reason to exist was opening paths Claude\nhad printed into the pane; the open-in-nvim skill now opens those files\nitself, without a selection step.\n\nWhat is left of the script is what extrakto already does on its own, so\nthe setting goes away with it and @extrakto_open_tool returns to auto --\nxdg-open on this machine. Selecting a file path and opening it now hands\nthe path to xdg-open rather than to nvim, as it did before the script.",
          "timestamp": "2026-08-07T09:35:08+09:00",
          "tree_id": "6c5fc2ead39fb05db1fc0ea77be2e1a0f094cc7b",
          "url": "https://github.com/r-okm/dotfiles/commit/4c56622ba5d6000b98e479646d925a23071962e2"
        },
        "date": 1786064074312,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 6.8,
            "range": "0.4",
            "unit": "ms",
            "extra": "min: 6.7ms, max: 7.1ms, median: 6.8ms (10 runs)"
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
          "id": "774431bf9f68e78c1b7e07e0797e4961f90381d1",
          "message": "git: keep submodule.recurse out of checkout-remote-head\n\ngit switch honors submodule.recurse=true, and git clone --recurse-submodules\nwrites submodule.active=. into the clone, which marks even a submodule that has\nnever been cloned as active. So when the remote head adds a new submodule, the\nswitch tries to reset a submodule index whose gitdir does not exist yet and dies\nwith \"fatal: could not reset submodule index\" (exit 128) -- leaving HEAD unmoved\nwhile the working tree has already advanced to the target commit, which mixes\ninto any uncommitted work.\n\nThis is by design and will not be fixed: checkout and switch only update the\ncontent of already active submodules, and git submodule update --init is the\nonly command that clones new ones. The same failure was reported to the git\nmailing list in June 2018 and still reproduces. GitLab Runner sets\nsubmodule.recurse=false explicitly for the same reason and drives submodules\nitself.\n\n- Run the switch with -c submodule.recurse=false so a new submodule cannot\n  abort it\n- Chain git submodule update --init --recursive after the switch; running it\n  before HEAD moves is a no-op because the new submodule is not in the old index\n- Drop the unused new-branch alias together with its gnb alias and abbreviation\n- Drop the git new-branch references left in git-worktree-tmux, which builds the\n  branch name itself",
          "timestamp": "2026-08-10T10:06:35+09:00",
          "tree_id": "8a3b4bb0ce0f9361623a600d9c24989991f73a70",
          "url": "https://github.com/r-okm/dotfiles/commit/774431bf9f68e78c1b7e07e0797e4961f90381d1"
        },
        "date": 1786324538261,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 10.1,
            "range": "0.5",
            "unit": "ms",
            "extra": "min: 9.8ms, max: 10.3ms, median: 10.0ms (10 runs)"
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
          "id": "b3d471c652e64b497ff1e114ac830af4bc9b73a4",
          "message": "claude: use xdg-open for URLs on WSL\n\nAn agent that did not know about this setup benchmarked candidate\ncommands and ended up invoking /mnt/c/Windows/explorer.exe by absolute\npath, then reported success without evidence (explorer.exe can exit\nnon-zero even when it works). $BROWSER is already wired to a Windows-side\nVivaldi wrapper in ~/.profile, so xdg-open honours it for URLs; the rule\nexists to stop that detour from being rediscovered per session.",
          "timestamp": "2026-08-13T10:23:20+09:00",
          "tree_id": "449f519429b7a888a7209f37ece1126046f1d184",
          "url": "https://github.com/r-okm/dotfiles/commit/b3d471c652e64b497ff1e114ac830af4bc9b73a4"
        },
        "date": 1786584867395,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 10.1,
            "range": "0.6",
            "unit": "ms",
            "extra": "min: 10.0ms, max: 10.5ms, median: 10.1ms (10 runs)"
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
          "id": "a02efb8ebd654e5360db16a519750d0b158b756c",
          "message": "claude: add yt skill for YouTube video summaries\n\n/yt takes a video URL and produces a translated summary in a fixed\nformat, with the transcript as the body and video info, description and\ncomments as supporting material. yt-fetch.py does the retrieval and\nrenders index/meta/transcript/comments Markdown; the skill reads those\nand writes summary.md next to them.\n\nThe subtitle track is chosen from a metadata probe and then requested by\nname. YouTube machine-translates any track into any language on demand,\nso a --sub-langs pattern asks for every combination that matches: seven\ndownloads for a video with two real tracks, and a later run that hit\nHTTP 429 and left no info.json at all, since yt-dlp writes it last.\nDeciding first costs a second extraction but holds the fetch to one\nsubtitle request. The spoken language outranks manual-vs-auto when\nranking candidates -- a hand-written track in another language is\nsomebody's translation, and the summary needs the original hedging,\nirony and idiom.\n\nComments are fetched 300 deep but only the top 50 are listed, under a\n50KB ceiling. Tracing which comments a real summary drew on, the top 50\ncost ~4KB per distinct point it used and everything past them 17-22KB,\nwith two 30KB stretches contributing nothing at all. Bytes per comment\nswing 4.5x between videos, so a count alone cannot keep the file inside\nwhat one Read returns -- measured at ~64KB, from a read that came back\ntruncated mid-file. Pinned and uploader comments are never dropped:\n7.6KB of them carried every correction the summary reported.\n\nReplies are flattened per top-level comment. YouTube nests deeper than\none level, and rendering only the direct children dropped 18% of a real\n300-comment fetch while the header still counted them.\n\nAuto-generated captions restate the previous line in every cue, so a\nline matching any of the last few emitted is dropped. Manual tracks get\na one-line window instead, where the only duplicates to remove are\ngenuine consecutive repeats.\n\nraw/ is merged rather than replaced after a fetch. --ignore-errors is on\nso that a subtitle 429 does not also cost the metadata and comments,\nwhich means \"info.json exists\" is not \"the run was complete\" -- and\nreplacing would throw away a track kept from an earlier run.\n\nyt-dlp comes from a chezmoi external rather than apt or a run_once\nscript. The distro package is pinned to whatever shipped with the\nrelease and stops working as soon as YouTube changes; the external\nrefreshes weekly on its own. Updating is chezmoi apply\n--refresh-externals, not yt-dlp -U, which the next refresh rolls back.",
          "timestamp": "2026-08-16T14:24:10+09:00",
          "tree_id": "0b72807b407fb09f238562a962f36a8a88a9d340",
          "url": "https://github.com/r-okm/dotfiles/commit/a02efb8ebd654e5360db16a519750d0b158b756c"
        },
        "date": 1786858396591,
        "tool": "customSmallerIsBetter",
        "benches": [
          {
            "name": "zsh startup (mean)",
            "value": 10.9,
            "range": "0.2",
            "unit": "ms",
            "extra": "min: 10.9ms, max: 11.1ms, median: 10.9ms (10 runs)"
          }
        ]
      }
    ]
  }
}