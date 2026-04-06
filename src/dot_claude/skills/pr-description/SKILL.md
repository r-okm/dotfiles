---
name: pr-description
description: 現在のブランチの変更からPRタイトルと概要を生成する
disable-model-invocation: true
allowed-tools: Bash(gh *), Bash(git *)
argument-hint: "[PR number]"
---

# /pr-description - PR概要生成

現在のブランチの変更内容からPRタイトルと概要セクションを生成する。

## 引数

- `$ARGUMENTS`: $ARGUMENTS

## 動作フロー

### Step 1: 参照データの取得

以下を並列で実行する:
- `gh pr list -R smilerobotics/v3 --state merged --limit 10 --json title --jq '.[].title'`
- `git show HEAD:.github/PULL_REQUEST_TEMPLATE.md`

### Step 2: 差分の取得

`$ARGUMENTS` の値に応じて **どちらか一方のみ** 実行する。

- **空の場合（無引数）**: 以下の git コマンドを順に実行する
  1. `git log origin/main..HEAD --format='---%n%s%+b'`
  2. `git diff origin/main...HEAD --stat`
  3. `git diff origin/main...HEAD -- . ':!*lock*' ':!*.lock' | head -c 80000`

- **非空の場合（PR番号）**: 以下の gh コマンドを順に実行する
  1. `gh pr view -R smilerobotics/v3 $ARGUMENTS --json title,body,commits`
  2. `gh pr diff -R smilerobotics/v3 $ARGUMENTS | head -c 80000`

### Step 3: 生成

1. 取得した差分データを分析する
2. 変更されたファイルのパスからパッケージ名を特定する（`packages/<name>/` の部分）
3. PRタイトルと概要セクションを生成する

## 生成ルール

### PRタイトル

- 形式: `[package_name] 命令形動詞で始まる簡潔な説明`
- `[v3_gui]`, `[v3_ros2_bringup]` などの関連パッケージ名を接頭辞にする。複数パッケージにまたがる場合は省略可。
- 命令形の動詞で始める: Add, Fix, Update, Remove, Support, Optimize など
- 接頭辞を含めて50文字以内に収める
- 変更の意図・目的を伝える（何を触ったかではなく、なぜ変えたかを書く）
- 言語は Step 1 で取得したマージ済みPRタイトルに合わせる

### 概要セクション

- 上記「PRテンプレート」の `# 概要` 直下の `-` を生成内容で置換する
- 変更の目的・背景を日本語で簡潔に説明する
- 箇条書き（`-`）で主要な変更点を列挙する
- 技術的な詳細よりも「なぜこの変更が必要か」を優先する
- 会話コンテキスト（直前の作業内容・意図）があれば反映する
- 「関連するPR」「Jiraカード」「ブロックしているPR」はデフォルトで「なし」とし、会話コンテキストに情報があれば反映する

## 出力形式

1. タイトルを `**タイトル**: \`...\`` で提示する
2. テンプレートの `# 概要` セクションを埋めた完成形を出力する
3. コードブロックやマークダウン形式では囲まない（そのままコピー可能にする）
4. PR作成やファイル保存は行わない

## エラーハンドリング

- diff が空（コミットなし）の場合はユーザーに通知して終了する
- バイナリファイルのみの変更や差分が巨大な場合は stat 情報を優先して判断する
