---
name: ss
description: 最新のスクリーンショットを番号指定で読み込む（引数なしで最新1枚）
disable-model-invocation: true
allowed-tools: Bash(~/.claude/r-okm/scripts/ss.sh), Bash(~/.claude/r-okm/scripts/ss.sh *), Read
argument-hint: "[n | n-m] ..."
---

# /ss - スクリーンショット読み込み

Windows のスクリーンショット保存フォルダから、新しい順で指定した画像を読み込む。
番号は新しいものを 1 とする。引数なしは最新 1 枚。`1 3`（個別）、`2-4`（範囲）、`1 3-5`（混在）が使える。

## 対象ファイル

!`~/.claude/r-okm/scripts/ss.sh $ARGUMENTS`

## 指示

上に出力された各パスを `Read` ツールで読み込み、画像として取り込む。
パスが 1 件も無い、またはエラーメッセージのみの場合は、その内容をユーザーに伝えて終了する
（勝手に別の番号で読み込み直さない）。
