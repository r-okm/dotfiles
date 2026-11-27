---
name: worktree
description: git worktree を作る・一覧する・開く・削除する。「別ブランチで並行作業したい」「PR をチェックアウトして確認したい」「今の作業を汚さずに別ブランチを見たい」「worktree を作って」「worktree の一覧を見せて」「あの worktree のセッションを開いて」「worktree を消して/片付けて」「ワークスペースで claude を起動して依頼して」と言われたとき、および自分の作業のために worktree が必要になったときや、自分が作った worktree での作業を終えるときに使う。
allowed-tools: Bash(git-worktree-herdr *), Bash(herdr pane list *), Bash(herdr pane process-info *), Bash(herdr pane read *), Bash(herdr pane wait-output *)
---

# worktree - git worktree を作る・片付ける

worktree の操作は PATH 上の `git-worktree-herdr` で行う。Linux では `~/.local/bin`、Windows では
`%LOCALAPPDATA%\r-okm\bin` にある。

このスクリプトは worktree と herdr のワークスペースを対で管理する。作成時は gitignore された
per-project 設定（`.ignore` / `CLAUDE.local.md` / `.claude/settings.local.json` / `.claude/local`）を
元リポジトリから symlink し、submodule を初期化し、その worktree のワークスペースを herdr に開く。
herdr はそのとき、リポジトリ本体（ルート）のワークスペースも一緒に開く。削除時は対応する
ワークスペースも閉じる。Windows で symlink を作る権限がないときは、警告を出してその設定を
リンクせずに続ける。

ユーザーも herdr の ghq ピッカーで同じ仕組みを使っている（ctrl-t で作成、ctrl-d で削除）。

## 使い方

```bash
# 既存ブランチをチェックアウトする
git-worktree-herdr -b <branch_name>

# PR の head ブランチをチェックアウトする
git-worktree-herdr -p <pr_number>

# リモート HEAD から新しいブランチを切る
# ブランチ名は <git config user.name>/<branch_suffix>。suffix 省略時は wip-<epoch>
git-worktree-herdr -c [<branch_suffix>]

# worktree を一覧する（1 行 1 件、タブ区切りで <worktree_name> <branch> <ワークスペース ID or -> <worktree のパス>）
git-worktree-herdr -l

# 既存の worktree のワークスペースを開く（無ければ作る）
git-worktree-herdr -o <worktree_name>

# worktree を削除し、ワークスペースを閉じる（ブランチは残る）
git-worktree-herdr -r <worktree_name>
```

他のオプションが必要になったら `git-worktree-herdr --help` を実行して確認する。

`<worktree_name>` はブランチ名の `/` を `-` に置き換えたもの（例: `r-okm/fix-foo` → `r-okm-fix-foo`）。
迷ったら `-l` の 1 列目を使う。

## `--focus` は付けない

**AI が `-b` / `-p` / `-c` / `-o` を実行するときは `--focus` を付けない。** 付けると、ユーザーの
見ている画面が新しいワークスペースに切り替わる。付けなければ、ワークスペースはバックグラウンドで
開くだけになる。

**worktree のパスは stdout の最終行に出力される。** これを以降の作業ディレクトリに使う。
herdr が動いていないときも、worktree は作られてパスが出力される（ワークスペースは開かない）。

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

**EnterWorktree ツールは呼ばない。** このスクリプトが作った worktree に EnterWorktree の `path` で入ると、
セッションが worktree 隔離モードになり、次の操作が拒否される。

- `{ ...; } | ...` のような複合コマンド。git を含まないコマンドも、構文を検証できなければ拒否される
- Write / Edit ツールでの、symlink 経由で main checkout に着地する書き込み。このスクリプトが
  symlink した `.ignore` などが当たる

worktree で作業するときは、以降のコマンドで worktree の絶対パスを使う。すでに隔離モードに入っていたら、
ExitWorktree を `action: "keep"` で呼んで抜ける。

## worktree で Claude を起動して最初の依頼を渡す

「ワークスペースで claude を起動して依頼して。以降は自分がやりとりする」と頼まれたときの手順。
ユーザーがやりとりする対話セッションに最初の依頼を渡すためのもので、ワーカーとして動かすとき
（`claude --bg` と SendMessage）の手順とは別になる。Linux（ペインのシェルが zsh）でだけ確かめている。

1. 依頼文を `~/.claude/r-okm/scripts/claude-ai-dir.sh` が出力するディレクトリのファイルに
   Write ツールで書く（ディレクトリが無くても Write ツールが作る）。スクリプトが失敗したら、
   ハーネスのスクラッチパッドに書く。依頼文は `-` で始めない。`claude` がオプションとして読む。
2. 送り先のペインを調べる。`-l` の 3 列目のワークスペース ID を使って
   `herdr pane list --workspace <ID>` を実行する。3 列目が `-` なら、先に `-o` でワークスペースを
   開いてから `-l` をやり直す。
3. cwd が worktree のペインのうち、シェルがプロンプトで待っているものを選ぶ。
   `herdr pane process-info --pane <pane_id>` で `foreground_process_group_id` が `shell_pid` と
   同じなら、シェルが前面にいる。nvim や Claude が前面にいるペインに送ると、コマンドがそのアプリへの
   入力になる。該当するペインが無いときや 2 つ以上あるときは、送らずにユーザーに聞く。
4. 待つときに照合する文字列を決める。依頼文から、ペインの幅に収まる短い一部（10〜20 文字ほど）を選ぶ。
   `wait-output` はペインにすでに出ている出力にも即座に一致するので、
   `herdr pane read <pane_id> --source recent-unwrapped` の出力に含まれないものにする。
5. 打ちかけの入力を消してから、シェルのコマンドとして起動する。依頼文は引数で渡す。打ちかけの文字が
   残っていると、送ったコマンドがその後ろにつながって実行される。`ctrl+u` で消した文字は zsh の
   kill ring に残り、ユーザーが `ctrl+y` で戻せる。

   ```bash
   herdr pane send-keys <pane_id> ctrl+u
   herdr pane run <pane_id> 'claude "$(cat "<依頼文のファイル>")"'
   ```

6. `herdr pane wait-output <pane_id> --match '<4 で決めた文字列>' --source recent-unwrapped --timeout 30000`
   で、依頼文が表示されるのを待つ。`--source recent-unwrapped` を付けないと、文字列が折り返しを
   またいだときに一致しない。`sleep` で待たない。表示されたら `herdr pane read <pane_id>` で
   入力欄が空になっていることを確かめる。タイムアウトしたときや、フォルダーの信頼の確認などの画面で
   止まっているときは、キーを送らず、画面の状態をユーザーに伝えて任せる。

依頼文をコマンドに直接書かない。`'`、`$`、バッククォートを含むと壊れる。

**起動済みの Claude に `herdr agent prompt` や Enter で送らない。** ユーザーの
keybindings.json では Enter が改行で、送信は Ctrl+Enter に割り当てられている。そのため依頼が入力欄に
残ったままになる。

## 作業を終えたら（削除）

自分が作った worktree での作業が終わったら、**削除してよいかユーザーに確認する。**
確認なしに削除しない。確認が取れたら `-r` で削除する。

- **削除対象は、このセッションで自分が作った worktree だけ。** それ以外はユーザーに
  明示的に頼まれたときだけ削除する。
- **`-f`/`--force` は付けない。** `-r` は未コミットの変更や untracked ファイルがあると拒否する。
  拒否されたら何が残っているかをユーザーに報告して判断を仰ぐ。ユーザーがその場で「強制で消して」と
  言ったときだけ `-f` を付ける。
- **削除前に cwd を worktree の外（`<project_root>` など）に移す。** Bash ツールの cwd は
  コマンド間で引き継がれるので、消したディレクトリに居残ると以降のコマンドがすべて壊れる。
- 削除されるのは worktree とそのワークスペースだけで、**ブランチは残る。** ブランチも消すかは別途
  ユーザーに確認する。
- **削除は削除対象の worktree のワークスペースの外（ルートのワークスペースなど）から行う。**
  ワークスペースを閉じると中で動いているものも一緒に終了するので、削除対象のワークスペースの中で
  `-r` を実行すると、スクリプトは worktree も消さずに拒否する。
  自分の動いている worktree を消したいときは、自分では消さず、ルートのワークスペースか
  ghq ピッカー（ctrl-d）から消すようユーザーに伝える。
  - `herdr workspace close` などでワークスペースを自分で閉じない。
