window.BENCHMARK_DATA = {
  "lastUpdate": 1774927021609,
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
      }
    ]
  }
}