---
name: open-in-nvim
description: ユーザーに読ませたいテキストファイルを、ユーザーの nvim で開く。行が特定できるときはその行にカーソルを置く。ファイルや特定の箇所を「開いて」「見せて」「出して」「どこ？」と言われたら、コードを応答に貼る代わりにこれを使う。
allowed-tools: Bash(~/.claude/r-okm/scripts/nvim-open.sh), Bash(~/.claude/r-okm/scripts/nvim-open.sh *)
argument-hint: "[--switch] <ファイルのパス>[:行[:桁]]"
---

# open-in-nvim - テキストファイルをユーザーに見せる

ユーザーはこの tmux セッションの **window 2 に nvim を常駐**させている。読んでほしいファイルが
あるとき、長いパスを応答に書いて手で開いてもらうのではなく、その nvim に直接開く。

```bash
# ファイルを開く（バッファに開くだけ。ユーザーは自分で window 2 に移る）
~/.claude/r-okm/scripts/nvim-open.sh <path>

# 行（と桁）を指定して、そこにカーソルを置く
~/.claude/r-okm/scripts/nvim-open.sh <path>:<line>
~/.claude/r-okm/scripts/nvim-open.sh <path>:<line>:<col>

# 開いたうえで tmux の表示を window 2 に切り替える
~/.claude/r-okm/scripts/nvim-open.sh --switch <path>
```

渡せるパスは **1 つだけ**。他のフラグが必要になったら `~/.claude/r-okm/scripts/nvim-open.sh --help` を実行して確認する。

## 使うとき

- ファイルを「開いて」と言われたとき
- コードや設定の**特定の箇所**を「見せて」「どこ？」と聞かれたとき — 調べて行を突き止めたら、
  その行を開く。調べた結果を説明して終わりにしない
- 自分が見つけた行をユーザーに読んでほしいとき

## 例

| ユーザーの依頼 | 実行するコマンド |
| --- | --- |
| 「この設定ファイル開いて」 | `~/.claude/r-okm/scripts/nvim-open.sh src/config.ts` |
| 「エラーが出てる箇所を見せて」 | `~/.claude/r-okm/scripts/nvim-open.sh src/api.ts:142` |
| 「URL 判定してるとこどこ？」→ grep で 22 行目と判明 | `~/.claude/r-okm/scripts/nvim-open.sh script.sh:22` |
| 「書いたテストを見せて」 | `~/.claude/r-okm/scripts/nvim-open.sh tests/user_test.go` |
| 「今すぐ見たいから移動して」 | `~/.claude/r-okm/scripts/nvim-open.sh --switch src/config.ts` |
| 「このスクショ見せて」 | **使わない**（nvim はテキスト用） |
| 調査のために作った中間メモを読んだ | **実行しない**（中間生成物） |

## 何を渡すか

**ユーザーに読んでほしい 1 ファイル。** 触ったファイルを全部開くのではなく、話の中心にある
ファイルを 1 つ選ぶ。

**箇所を特定できたなら必ず `:<line>` を付ける。** ユーザーが自分でジャンプ先を探さずに済む。
行番号やコードを応答に書くのは、開いたうえでの補足に留める。

## 開かないもの

- **自分が読むために作った中間生成物。** ユーザーが知りたいのは答えであって、Claude が答えを
  出すために作ったファイルではない。
- **画像・動画・バイナリ。** nvim はテキスト用。
- ユーザーが既に開いているもの、見る必要のないもの

「開かなくていい」と言われたら、単に開かない。それだけ。

## タイミングと切り替え

**応答を返す直前に一度だけ。** 1 つのタスクにつき 1 回まで。

既定では **tmux の表示は切り替えない**。ユーザーは Claude の応答を読んでから自分で window 2 に
移る。`--switch` を付けるのは「すぐ見たい」「そっちに移して」と明示されたときだけ — 切り替えると
応答文が画面から消える。

## 失敗したとき

window 2 に nvim が起動していないと、このコマンドは**何も開かずにエラーで終わる**。その場合は
起動を試みたりリトライしたりせず、応答にパスを書いてユーザーに伝える。
