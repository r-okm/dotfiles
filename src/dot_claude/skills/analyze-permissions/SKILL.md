---
name: analyze-permissions
description: パーミッション申請ログを分析し、allow ルールの最適化案を提示する
allowed-tools: Bash(~/.claude/r-okm/scripts/analyze-permissions.py *)
argument-hint: "[--since YYYY-MM-DD | --all]"
---

# /analyze-permissions - パーミッション分析

パーミッションプロンプトのログを分析し、`settings.json.tmpl` の `permissions.allow` ルールの最適化案を3つの観点から提示する。

## 分析データ

!`~/.claude/r-okm/scripts/analyze-permissions.py --json $ARGUMENTS`

## 指示

上記の JSON データを以下の3観点で分析し、結果を出力する。
データが `"No permission requests found in logs."` の場合は、前回分析以降に新しいパーミッション申請がなかった旨を伝えて終了する。`--all` フラグでの再分析を提案してもよい。

### 観点1: ルール最適化

`suggestions` の各エントリについて：

1. `actual_inputs` を確認し、実際に実行されたコマンドのパターンから適切なワイルドカード粒度を判断する
2. `wildcard_groups` を参照し、複数ルールをまとめられるか検討する。ただし `risk_level: "high"` のワイルドカードは採用しない
3. `existing_rules.allow` を確認し、既存ルールの統合（例: 個別ルール3件を `gh api *` 1件に統合し、元の3件を削除）を検討する
4. `status: "ALLOWED"` のルールは既に対応済みのため提案に含めない
5. `first_seen` / `last_seen` を考慮し、一度きりのデバッグ用コマンドは提案から除外する

各ルールを「追加推奨」または「追加を推奨しない」のいずれかに分類する。曖昧な「検討」カテゴリは使わない。

### 観点2: セキュリティレビュー

1. `risk_level: "high"` のワイルドカードグループ（インタプリタ + 任意引数など）を警告する
2. 観点1で「追加推奨」としたルールについて、過度に広くないか評価する（基準: `risk_level` が `high` のもの、コマンド名のみでワイルドカードが続くパターン）
3. `actual_inputs` から、提案ルールがカバーする範囲に想定外の危険なパターンが含まれないか確認する
4. 提案ルールが `existing_rules.deny` のルールと矛盾しないか確認する（Claude Code は deny → allow の順で評価するため、deny が優先される。ただし deny をバイパスする意図しない許可がないかチェックする）

### 観点3: settings.json.tmpl 変更案

観点1・2の結論に基づき、`dotfiles/src/dot_claude/settings.json.tmpl` の `permissions.allow` に対する具体的な変更案を提示する：

- 追加するルール
- 統合により不要になる既存ルール（削除候補）

## 出力フォーマット

以下の形式で出力する。

```markdown
## ルール最適化分析

### 追加推奨
| ルール | 理由 |
|--------|------|

### 追加を推奨しないもの
| ルール候補 | 不採用理由 |
|-----------|-----------|

### 既存ルールの整理
（統合・削除可能なルールがあれば提示）

## セキュリティレビュー

- risk_level: high のワイルドカードに対する所見
- 推奨ルールのリスク評価
- deny ルールとの整合性確認

## settings.json.tmpl 変更案

permissions.allow に追加:
（JSON 配列）

permissions.allow から削除（統合により不要）:
（JSON 配列。該当なしの場合は省略）
```

## 注意事項

- 応答は日本語で行う
- 判断に迷う場合は安全側（不採用）に倒す
- ルール候補の全件について判断を示し、未評価のまま残さない
