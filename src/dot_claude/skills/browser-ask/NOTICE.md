# NOTICE

このスキルは [uehaj/review-wizard](https://github.com/uehaj/review-wizard)
(commit `1e84cda4223591ea281ca0bb09199be12fec2891`)を取り込んだもの。
MIT License、Copyright (c) 2026 Junji UEHARA。全文は同じディレクトリの `LICENSE` にある。

## 上流から変えた点

- スキル名を review-wizard から browser-ask に変更した。
- `scripts/review_wizard.ts`: Windows では `explorer.exe` でブラウザを開く分岐を追加した。冒頭のコメントに取り込み元を書いた。
- `SKILL.md`: 起動コマンドのパスを `${CLAUDE_SKILL_DIR}` にし、推奨の選択肢の書き方、JSON の置き場所、`run_in_background`、node のあとに何も繋げないこと、URL を応答に書くことを追記した。
