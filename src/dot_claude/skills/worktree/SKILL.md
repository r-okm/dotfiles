---
name: worktree
description: git worktree を作る。「別ブランチで並行作業したい」「PR をチェックアウトして確認したい」「今の作業を汚さずに別ブランチを見たい」「worktree を作って」と言われたとき、および自分の作業のために worktree が必要になったときに使う。素の `git worktree add` を叩く前に必ずこれを読む。
allowed-tools: Bash(git-worktree-tmux *)
argument-hint: "[-b <branch_name> | -p <pr_number> | -c [<branch_suffix>]]"
---

# worktree - git worktree を作る

worktree は `~/.local/bin/git-worktree-tmux` で作る。**素の `git worktree add` は使わない。**

このスクリプトは worktree を作るだけでなく、gitignore された per-project 設定
（`.ignore` / `CLAUDE.local.md` / `.claude/settings.local.json` / `.claude/local`）を元リポジトリ
から symlink し、その worktree 用の tmux セッションを開き、submodule を初期化する。
素の `git worktree add` はこれらを全部落とすので、設定が無いまま作業を始めることになる。

## 使い方

```bash
# 既存ブランチをチェックアウトする
git-worktree-tmux -d -b <branch_name>

# PR の head ブランチをチェックアウトする
git-worktree-tmux -d -p <pr_number>

# リモート HEAD から新しいブランチを切る
# ブランチ名は <git config user.name>/<branch_suffix>。suffix 省略時は wip-<epoch>
git-worktree-tmux -d -c [<branch_suffix>]
```

上記 3 つで足りる。他のオプションが必要になったら `git-worktree-tmux --help` を実行して確認する。

## `-d` を必ず付ける

**AI が実行するときは常に `-d`/`--detach` を付ける。** 付けないと、コマンドがユーザーの tmux
クライアントを新しいセッションに attach / switch し、ユーザーの見ている画面を奪う。

`-d` を付けたときの挙動:

- tmux セッションはバックグラウンドで作られるだけで、表示は切り替わらない
- **worktree のパスが stdout の最終行に出力される。** これを以降の作業ディレクトリに使う

## 実行する場所

**リポジトリの中から実行する。** linked worktree の中から実行してもよい —
worktree は常に main worktree の下に作られ、入れ子にはならない。

`-c` は今いる worktree の HEAD を触らないので、作業の途中で実行しても安全。

## 既にある worktree を指定したとき

同名の worktree が既にあるときは **それをそのまま返す。`git fetch` も symlink の作成も
submodule の初期化も走らない**（スクリプトはこの 3 つをまとめて「ディレクトリが無いとき」の
分岐に置いているため）。

つまり **前回の状態のまま返ってくる。** `-p` で PR を取り直したつもりでも、その worktree が
残っていれば古い head を読むことになる。最新のコードが要るなら、返ってきた worktree で自分で
fetch / reset すること。

## 作られた worktree で作業する

worktree は `<project_root>/.worktree/<branch_name>` に作られる（ブランチ名の `/` は `-` に置換）。

**cwd が worktree の中にあるときは、git コマンドをその場で実行する。**
`git -C <project_root>` は使わない — 元リポジトリの方を操作してしまう。
