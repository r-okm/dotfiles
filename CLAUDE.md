# CLAUDE.md

## プロジェクト概要

[chezmoi](https://www.chezmoi.io/) で管理する dotfiles。ソースディレクトリは `src/`(`.chezmoiroot` で指定)。管理するファイルはすべて `src/` に置き、`$HOME` に適用する。

## chezmoi での作業

- `chezmoi apply` がターゲットを上書きするので、ファイルは `src/` で編集し、ターゲットのパス(`~/.config/` など)では編集しない。
- ファイルを追加するときは chezmoi のプレフィックス `dot_`(→ `.`)、`private_`(権限を絞る)、`executable_`(→ +x)、`symlink_`(→ シンボリックリンク)を使う。
- Go の text/template を使うファイルには `.tmpl` を付ける。データ源は `.chezmoi.os`、`.chezmoi.homeDir`、`.chezmoi.toml.tmpl` のカスタムデータ。
- `chezmoi apply` と `chezmoi init` は**実行しない**。ユーザーが手で実行する。差分の確認に `chezmoi diff` を実行するのはよい。
- `src/` からファイルを消しても(`.chezmoiexternal.toml.tmpl` からエントリーを消しても)、`chezmoi apply` は管理から外れたターゲットを削除しないので、配置済みのファイルは残る。代わりにターゲットのパスを `src/.chezmoiremove` に追加する。ただし、一度もコミットしていないファイルは追加しない。配置されているのはコミット前に apply したマシンだけなので、そのマシンでターゲットを手で削除する。すべてのマシンで削除が適用済みかどうかは git から分からないので、`.chezmoiremove` のエントリーは消さない。書くのは単一のターゲットだけにする。`.config` や `*` のようなパターンは管理中のディレクトリにもマッチし、apply が中断する。

## ターゲット側が正のファイル

管理しているファイルの中には、アプリケーションが直接書き込むものがある。これらは `src/` ではなく配置先のファイルが正になる。現在は次のとおり。

- `~/.claude/settings.json`: Claude Code が直接書き込む(`/model`、`/config`、権限確認のプロンプト)。
- `~/AppData/Local/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json`: Windows Terminal の設定 UI が直接書き込む。Linux の chezmoi は `AppData` を無視するので、このファイルを扱うのは Windows の chezmoi だけ。
- `~/AppData/Roaming/herdr/config.toml`: herdr が設定画面とオンボーディングで書き込む。同じ理由で Windows だけ。

これらのファイルは次のように扱う。

- ターゲット側で起きた変更(アプリケーションの書き込みやユーザーの編集)は、変更が起きたマシンで `chezmoi re-add <target>` を実行してソースに戻す。同じ変更を `src/` に手で作り直さない。
- `chezmoi re-add` はバイト単位でコピーし、git を見ずにソース側を上書きするので、先にソース側の未コミットの編集をコミットするか破棄しておく。re-add はコミットまではしない。diff を確認し、コミットメッセージは自分で書く。メッセージには、ターゲット側で何が変わったかと、整形し直されて戻ってきた場合はその理由を書く。
- ユーザーが `chezmoi apply` を実行する前に、`chezmoi status` を実行してもらう。これらのファイルが出てきたら、先に re-add してコミットする。そうしないと apply がアプリケーションの書き込んだ変更を上書きする。
- Claude がこれらのファイルを変更するときは、ターゲットではなく `src/` 側を編集する。まず `chezmoi status` でそのファイルに drift(ずれ)がないことを確かめ、drift があれば re-add する。次に `src/` を編集し、最後にユーザーが `chezmoi apply` を実行する。`src/` で編集すれば、変更が反映される前に diff を確認できる。
- テンプレートにしない。`chezmoi re-add` はテンプレートを対象にしないので、同期できなくなる。`{{ .chezmoi.homeDir }}` ではなく `~/` 形式のパスを使う。
- 両側が変わったとき(別のマシンでのソース側の変更を pull したあとなど)は、re-add ではなく `chezmoi merge <file>` で解決する。

## Windows

- `src/AppData` の下にあるファイルのうち、上記のターゲット側が正のファイル以外は、`src/` のほかのファイルと同じくソース側が正で、通常の chezmoi のプレフィックスを使う。たとえば Windows Terminal の `settings.json` の隣にある `dot_editorconfig` や、`src/AppData/Local/r-okm/ghub-tools/`(タスクスケジューラーが実行する G HUB の補助スクリプト。README を参照)がこれに当たる。
- `src/.chezmoiscripts/windows` にある Windows 専用のスクリプト(`src/.chezmoidata/windows.toml` を適用するものなど)は、ターゲットを引数に取らない apply でしか実行されない。これらのスクリプトや、スクリプトが読むデータを変えたときは、ディレクトリを指定した apply ではなく、引数なしの `chezmoi apply` を実行するようユーザーに伝える。

## リポジトリのツール

`tools/` には単体で動く保守用スクリプトを置いている。`src/` の外にあるので chezmoi は配置しない。リポジトリのルートから実行する。

各スクリプトの説明はモジュールの docstring と `--help` にあるので、ここには一覧を載せない。使い捨てのスクリプトを新しく書く前に、そちらを確認する。

## コマンド

- **diff の確認**: `chezmoi diff`
