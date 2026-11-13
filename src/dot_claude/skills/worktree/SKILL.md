---
name: worktree
description: git worktree を作る・一覧する・開く・削除する。「別ブランチで並行作業したい」「PR をチェックアウトして確認したい」「今の作業を汚さずに別ブランチを見たい」「worktree を作って」「worktree の一覧を見せて」「あの worktree のセッションを開いて」「worktree を消して/片付けて」と言われたとき、および自分の作業のために worktree が必要になったときや、自分が作った worktree での作業を終えるときに使う。
allowed-tools: Bash(git-worktree-tmux *)
---

# worktree - git worktree を作る・片付ける

worktree の操作は `~/.local/bin/git-worktree-tmux` で行う。

このスクリプトは worktree と tmux セッションを対で管理する。作成時は gitignore された
per-project 設定（`.ignore` / `CLAUDE.local.md` / `.claude/settings.local.json` / `.claude/local`）を
元リポジトリから symlink し、その worktree 用の tmux セッションを開き、submodule を初期化する。
削除時は対応する tmux セッションも閉じる。

ユーザーも端末の `ccw`（`fzf_cd_worktree`）から同じスクリプトを使っている。

## 使い方

```bash
# 既存ブランチをチェックアウトする
git-worktree-tmux -d -b <branch_name>

# PR の head ブランチをチェックアウトする
git-worktree-tmux -d -p <pr_number>

# リモート HEAD から新しいブランチを切る
# ブランチ名は <git config user.name>/<branch_suffix>。suffix 省略時は wip-<epoch>
git-worktree-tmux -d -c [<branch_suffix>]

# worktree を一覧する（1 行 1 件、タブ区切りで <worktree_name> <branch> <tmux セッション名 or -> <worktree のパス>）
git-worktree-tmux -l

# 既存の worktree の tmux セッションを開く（無ければ作る）
git-worktree-tmux -d -o <worktree_name>

# worktree を削除し、tmux セッションを閉じる（ブランチは残る）
git-worktree-tmux -r <worktree_name>
```

他のオプションが必要になったら `git-worktree-tmux --help` を実行して確認する。

`<worktree_name>` はブランチ名の `/` を `-` に置き換えたもの（例: `r-okm/fix-foo` → `r-okm-fix-foo`）。
迷ったら `-l` の 1 列目を使う。

## `-d` を必ず付ける

**AI が `-b` / `-p` / `-c` / `-o` を実行するときは常に `-d`/`--detach` を付ける。** 付けないと、
コマンドがユーザーの tmux クライアントを新しいセッションに attach / switch し、ユーザーの見ている
画面を奪う。

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

worktree は `<project_root>/.worktree/<worktree_name>` に作られる。

## 作業を終えたら（削除）

自分が作った worktree での作業が終わったら、**削除してよいかユーザーに確認する。**
確認なしに削除しない。確認が取れたら `-r` で削除する。

- **削除対象は、このセッションで自分が作った worktree だけ。** それ以外はユーザーに
  明示的に頼まれたときだけ削除する。
- **`-f`/`--force` は付けない。** `-r` は未コミットの変更や untracked ファイルがあると拒否する。
  拒否されたら何が残っているかをユーザーに報告して判断を仰ぐ。ユーザーがその場で「強制で消して」と
  言ったときだけ `-f` を付ける。`-f` は tmux セッションを即座に閉じるので、自分の動いている
  worktree に付けると返答の途中で自分が終了する。
- **削除前に cwd を worktree の外（`<project_root>` など）に移す。** Bash ツールの cwd は
  コマンド間で引き継がれるので、消したディレクトリに居残ると以降のコマンドがすべて壊れる。
- 削除されるのは worktree と tmux セッションだけで、**ブランチは残る。** ブランチも消すかは別途
  ユーザーに確認する。
- 削除対象が自分の動いている worktree のときも `-r` をそのまま使う。スクリプトはこのセッションを
  即座には閉じず、ユーザーが別のセッションへ移るか detach した時点で閉じるよう設定する
  （`Deferred tmux session` と出力される）。誰も attach していないセッションでは、ユーザーが一度
  そのセッションに入って離れるまで閉じない（出力に `no client is on it` と出る）。
  - `sleep` と `kill-session` などで自前の時間差 kill を仕込まない。ユーザーが報告を読む前に
    セッションが消える。
  - 報告では、出力に合わせていつ閉じるかを伝え、同じセッションの他の window（nvim など）も
    一緒に終わることを伝える。
