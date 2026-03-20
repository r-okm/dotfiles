window.BENCHMARK_DATA = {
  "lastUpdate": 1773989697908,
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
      }
    ]
  }
}