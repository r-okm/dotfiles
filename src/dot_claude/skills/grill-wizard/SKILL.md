---
name: grill-wizard
description: 計画・決定・アイデアについてユーザーを徹底的に問い詰め、共通理解に至るまでラウンドを重ねる(grilling)。質問はチャットに書かず review-wizard のブラウザウィザードで出す。「grill」「grilling」「問い詰めて」「この計画を叩いて」と言われたとき、またはユーザーが自分の考えをストレステストしたいときに使う。
---

# grill-wizard - review-wizard で grilling する

## 手法

`~/.claude/r-okm/external/grilling.md` を Read し、そこに書かれた手法に従う。design tree、
round、frontier、各問への推奨回答、事実は自分で調べる、frontier が空になるまで続ける、
ユーザーが共通理解に達したと確認するまで着手しない、のすべてがそのまま適用される。
このファイルは上流(mattpocock/skills)の原文で、改変しない。

差し替えるのは出力形式だけ。ラウンドの質問をチャットのプレーンテキストで書く代わりに、
review-wizard の質問 JSON に変換してブラウザで提示する。ラウンドごとに新しいウィザードを
起動する。

## ラウンドの出し方

1. `review-wizard:review-wizard` スキルを読み込む。質問 JSON のスキーマと起動コマンドは
   そちらが正。
2. 質問 JSON を書く。grilling の Q1..Qn がそのまま 1 問ずつになる。`header` に
   「Q1 <題>」、`question` に本文。推奨回答は `options` の先頭に置き、label の末尾に
   「(Recommended)」を付け、`description` に理由を書く。自由回答が本命の問いでも
   `options` は 2 件以上必要なので、推奨案と対案を並べ、自由記述は自動で付く
   「その他」欄に任せる。比較が要る問いには `detail` に表を付ける。
3. node を `run_in_background` で起動し、完了通知を待つ。応答には URL を書いておく
   (ブラウザが開かなかったときの手動用)。
4. 回答 JSON を読む。`selected` と `other` を settled として frontier を再計算し、
   次のラウンドへ。

## 注意(実測で踏んだもの)

- 質問 JSON と回答 JSON は `$CLAUDE_TMPDIR` 配下に書く。`$TMPDIR` は使わない。
  - TODO: node の起動は `excludedCommands` に該当し、その Bash 呼び出し全体が sandbox 外で
    走る。sandbox 外のコマンドはホストの `TMPDIR`(Linux では未設定)を継承するので
    `$TMPDIR` が空になる(公式仕様。anthropics/claude-code#48541, #81157)。Claude Code が
    unsandboxed 実行にも `TMPDIR` を渡すようになったら `$TMPDIR` に戻す。
- node コマンドの後ろに `; echo "exit=$?"` などを繋げない。終了コード(0 回答受領 /
  1 入力エラー / 2 タイムアウト / 130 中断)が task notification にそのまま届く。
