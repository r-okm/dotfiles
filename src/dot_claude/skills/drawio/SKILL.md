---
name: "drawio"
description: "ユーザーが図・フローチャート・アーキテクチャ図・ER図・シーケンス図・クラス図・ネットワーク図・モックアップ・ワイヤーフレーム・UIスケッチの作成・生成・描画・設計を求めたとき、または draw.io、drawio、drawoi、.drawio ファイル、PNG/SVG/PDF への図の書き出しに触れたときは、必ずこのスキルを使う。利用者の情報（図の中身など）を外部に送らないよう、draw.io MCP サーバーの create_diagram ツールや app.diagrams.net は使わず、ローカルの .drawio ファイルと draw.io デスクトップ版の CLI だけで図を作る。"
---

<!--
jgraph/drawio-mcp plugins/claude-code/skills/drawio/SKILL.md の日本語訳から、利用者の情報を外部に送る指示を削ったもの。
原文：コミット 1feb159ae0b1d047d2a2a4c874afef10c0072a8d（2026-10-26）、プラグイン v1.2.6、Apache License 2.0
削った箇所：create_diagram（ホスト版 MCP）の優先、app.diagrams.net の URL 出力、GitHub からの手順書の取得（references/ に同梱）、scripts/find-shapes.js
詳細は references/NOTICE。
-->

# Draw.io 図スキル

draw.io の図を、ネイティブの `.drawio` ファイルとして生成する。各図は **Mermaid**（draw.io デスクトップ版の CLI が変換・自動配置する簡潔なテキスト）か、**draw.io XML** の直接記述のどちらかで作る。必要に応じて、XML で作った図を **ELK** で自動配置する、図の XML を埋め込んだ PNG/SVG/PDF に書き出す（書き出したファイルを draw.io で再編集できる）、といったこともできる。

**利用者の情報を外部に送らない。** 図の中身や、図の内容から作った検索語などを外部のサービスに送らない。draw.io MCP サーバーの `create_diagram` などのツールが使える環境でも呼ばない。`app.diagrams.net` の URL を作ったり開いたりしない。手順書は同梱の `references/` を読む。ユーザーがブラウザ版での表示や URL を求めたら、図が社外に出る経路になるので対応せず、`.drawio` ファイルを draw.io デスクトップ版で開くよう案内する。利用者の情報を含まない取得（Google Fonts のフォントなど）は構わない。

## 作り方：Mermaid か XML か

デスクトップ版の CLI は Mermaid をネイティブの `.drawio` ファイルに変換し、自動で配置する。XML でセルを手作業で配置するよりはるかに確実である。

| 作り方 | 向いている用途 | デスクトップ版 CLI が必要か |
|-----------|----------|--------------------|
| **Mermaid** | フローチャート、シーケンス図、クラス図、状態遷移図、ER図、ガントチャート、マインドマップ、タイムライン、ユーザージャーニー、象限図、C4、Git グラフ、円グラフなどの標準的な図 | 必要（`.drawio` への変換に使う） |
| **XML** | 独自のスタイル、正確な／手作業での配置、特定の図形ライブラリ（AWS、Azure、ネットワーク、詳細な UML など）、デスクトップ版 CLI が入っていない場合 | 不要（任意の ELK `--layout` には CLI が必要） |

- デスクトップ版 CLI が使え、依頼が上記の標準的な図であれば **Mermaid を優先する**。
- 正確に制御したいとき、または汎用の代替手段として **XML を使う**。XML は CLI が不要なので、デスクトップ版が入っていないときの唯一の手段になる（`.drawio` ファイルで渡す）。XML の場合は、座標を自分で計算する代わりに CLI で ELK 自動配置（「XML 向けの ELK 配置」を参照）をかけることもできる。

デスクトップ版 CLI があるか分からない場合は、先に検出する（「CLI の場所を特定する」を参照）。

## 処理の流れ

Mermaid で作っても XML で作っても、すべての図はまずネイティブの `.drawio` ファイルになり、その後、求められた出力形式で渡される。

1. **作成 → `.drawio`**
   - **Mermaid**：Mermaid を `.mmd` ファイルに書き、CLI で変換する。
     ```bash
     drawio -x -f xml -o diagram.drawio diagram.mmd
     ```
     変換後は `.mmd` を削除する。成果物は `.drawio` である。
   - **XML**：mxGraphModel の XML を `diagram.drawio` に書き（「XML 形式」を参照）、その上で「修復処理」をかける。必要に応じて「XML 向けの ELK 配置」をかける。
2. **渡す**（どちらで作った場合も同じ）
   - *（形式の指定なし）* → `diagram.drawio` をそのまま残して開く。
   - **png / svg / pdf** → `.drawio` から XML を埋め込んで書き出し、元の `.drawio` を削除する。
     ```bash
     drawio -x -f png -e -b 10 -o diagram.drawio.png diagram.drawio
     ```
3. **結果を開く** — 書き出したファイル、または `.drawio` を開く（「結果を開く」を参照）。開くコマンドが失敗したら、ユーザーが手で開けるよう絶対パスを表示する。

**Mermaid は必ず先に `.drawio` に変換してから書き出す。** 現行の draw.io デスクトップ版では、Mermaid から `-e` 付きで PNG に直接書き出す処理が壊れている（XML の埋め込み段階でクラッシュする）。2段階で処理すれば確実で、再編集できる埋め込みも得られる。

Mermaid を求められたがデスクトップ版 CLI がない場合は、同じ図を XML で作る。

## XML 向けの ELK 配置

CLI の `--layout` 処理は、XML で作った図を ELK で自動配置する。エディタの *配置 ▸ レイアウト* メニューと同じ ELK レイアウトである。セルの位置はおおよそ（`0,0` でもよい）で生成し、図の*構造*（ノードとエッジ）を正しく作ることに集中する。流れのある図には `verticalFlow` / `horizontalFlow`、ネットワークには `organic` を使う。Mermaid で作った図はすでに配置済みなので、`--layout` を足さない。

ファイルを書いた後にその場で配置するか（同じパスの読み込みと上書きに対応している）、配置と書き出しを1回の呼び出しでまとめて行う。

```bash
drawio -x -f xml --layout verticalFlow -o diagram.drawio diagram.drawio
drawio -x -f png -e -b 10 --layout verticalFlow -o diagram.drawio.png diagram.drawio
```

### 配置のプリセット

| 名前 | 配置 |
|------|--------|
| `verticalFlow` | 階層型、上から下 — フローチャート、パイプライン |
| `horizontalFlow` | 階層型、左から右 |
| `verticalTree` | ツリー、上から下 — 階層構造、組織図 |
| `horizontalTree` | ツリー、左から右 |
| `radialTree` | 放射状ツリー |
| `organic` | 力学モデル — ネットワーク、マインドマップ風の図 |

### 独自の配置 JSON

より細かく制御するには、プリセット名の代わりに JSON の**配列**（`[` で始まる）を渡す。エディタの独自レイアウトのダイアログと同じ形式である。

```bash
drawio -x -f xml --layout '[{"layout":"elkLayered","config":{"elk.direction":"RIGHT"}}]' -o diagram.drawio diagram.drawio
```

各要素は `{"layout": <アルゴリズム>, "config": { … }}` の形である。アルゴリズムは `elkLayered`、`elkTree`、`elkRadial`、`elkOrganic`、`elkStress`、`elkBox`。`elk.` で始まる config の項目は ELK のオプションで、たとえば `elk.direction`（`UP` / `DOWN` / `LEFT` / `RIGHT`）、`elk.spacing.nodeNode`、`elk.layered.spacing.nodeNodeBetweenLayers` がある。`edgeStyle`（例：`orthogonal`）と `corners`（例：`rounded`）は線の描き方を決める。

### 直交のエッジ経路

`--layout libavoid` は、図形を一切動かさずに、**エッジ**を図形を避ける直交経路に引き直す（*配置 ▸ レイアウト ▸ 直交ルーティング*）。線が図形を横切っている手作業配置の XML に、その場でかける。flow / tree のプリセットはすでにエッジの経路を引いているので、その後にはかけない。

```bash
drawio -x -f xml --layout libavoid -o diagram.drawio diagram.drawio
```

## Mermaid 構文リファレンス

Mermaid で作るときは、このスキルのフォルダにある `references/mermaid-reference.md`（対応するすべての図の種類と、フローチャートのスタイル指定 — `style`、`classDef`、`linkStyle`）を読み、それに従う。このファイルは draw.io MCP サーバー向けにも書かれている。`postLayout` についての記述は MCP サーバーの機能なので無視する。

図のラベルの言語は、ユーザーの言語に合わせる。

## 出力形式の選び方

ユーザーの依頼に形式の指定があるか確認する。例：

- `/drawio create a flowchart` → Mermaid → `flowchart.drawio`
- `/drawio png flowchart for login` → Mermaid → `login-flow.drawio.png`
- `/drawio svg: ER diagram` → Mermaid → `er-diagram.drawio.svg`
- `/drawio pdf AWS architecture overview` → XML（AWS の図形が必要なため）→ `architecture-overview.drawio.pdf`

形式の指定がなければ、`.drawio` ファイルを作って開く。書き出しは後からユーザーが頼める。

PNG、SVG、PDF は `-e`（`--embed-diagram`）付きで書き出す。ファイルに図の XML 全体が入るので、draw.io で開けば編集可能な図に戻せる。`jpg` は非可逆で、XML を埋め込めない。

## draw.io CLI

draw.io デスクトップアプリのコマンドラインインターフェースは、**Mermaid の変換**（`.drawio` へ）、**ELK 配置**（`--layout`）、PNG/SVG/PDF への**書き出し**を行う。3つともデスクトップアプリのインストールが必要である。

### CLI の場所を特定する

まず環境を判定し、次に CLI の場所を特定する。Windows（ネイティブ・WSL2 とも）では、インストーラーが draw.io を PATH に**追加せず**、インストール先もユーザーが選べる。CLI がないと結論づける前に、代替手段を最後まで順に試す。

#### WSL2（Windows Subsystem for Linux）

`/proc/version` に `microsoft` か `WSL` が含まれていれば WSL2 と判定する。

```bash
grep -qi microsoft /proc/version 2>/dev/null && echo "WSL2"
```

WSL2 では、`/mnt/c/...` 経由で Windows 版 draw.io デスクトップの実行ファイルを使う。ただし先に PATH を確認する。`/etc/wsl.conf` の `appendWindowsPath` が有効な環境や、ユーザーが実行ファイルへのリンクを `~/.local/bin` などに置いている環境では、これで見つかる。

```bash
command -v draw.io.exe
```

PATH になければ、既定のインストール先を使う。

```bash
DRAWIO_CMD="/mnt/c/Program Files/draw.io/draw.io.exe"
```

`Program Files` の空白がパスの一部として残るよう、パスはダブルクォートで囲む。バッククォートでは囲ま**ない**。bash ではコマンド置換になり、パスを保存するのではなく実行ファイルを*実行*してしまう。

draw.io が既定以外の場所にインストールされている場合は、よくある別の場所を確認する。

```bash
# Default install path
"/mnt/c/Program Files/draw.io/draw.io.exe"

# Per-user install (if the above does not exist)
ls /mnt/c/Users/*/AppData/Local/Programs/draw.io/draw.io.exe 2>/dev/null | head -1
```

どちらもなければ、別のドライブか独自のディレクトリ、または scoop でインストールされている。マウントされている他のドライブと scoop のインストール先を調べ、次にレジストリに問い合わせる。scoop はレジストリにインストール先を記録しないので、レジストリだけでは見つからない。

```bash
# Program Files on the other drives (D:, E:, …)
ls /mnt/*/Program\ Files/draw.io/draw.io.exe 2>/dev/null | head -1

# scoop (custom root such as C:\scoop, or the default under the user profile)
ls /mnt/*/scoop/apps/draw.io/current/draw.io.exe /mnt/c/Users/*/scoop/apps/draw.io/current/draw.io.exe 2>/dev/null | head -1

# Registry — the installer records the directory the user picked
for REG_PATH in 'HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall' \
                'HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall' \
                'HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'; do
  WIN_DIR=$(reg.exe query "$REG_PATH" /s /v InstallLocation 2>/dev/null |
            grep -i 'REG_SZ.*draw\.io' | head -1 |
            sed 's/.*REG_SZ[[:space:]]*//' | tr -d '\r')
  [ -n "$WIN_DIR" ] && DRAWIO_CMD="$(wslpath -u "${WIN_DIR%\\}")/draw.io.exe" && break
done
```

#### macOS と Linux

- **Linux（ネイティブ）**：`drawio`。通常は snap/apt/flatpak で PATH に入っている。`which drawio` で確認する。
- **macOS**：次のコマンドは、PATH 上の `drawio`（Homebrew）、`/Applications`、ユーザー単位の `~/Applications`、Spotlight の順で最初に見つかったものを表示する。draw.io がなければ何も表示しない。

```bash
{ command -v drawio; ls /Applications/draw.io.app/Contents/MacOS/draw.io ~/Applications/draw.io.app/Contents/MacOS/draw.io
  mdfind "kMDItemCFBundleIdentifier == 'com.jgraph.drawio.desktop'" | sed 's|$|/Contents/MacOS/draw.io|'; } 2>/dev/null | head -1
```

`.app` の中にあるバイナリを呼ぶ。`.app` の外に置いたコピーやシンボリックリンクは `Unable to find helper app` で終了する。

#### Windows（ネイティブ、WSL2 以外）

次の順に確認する。PATH に入っていないことや C: 以外のドライブへのインストールはよくあることで、draw.io がない証拠ではない。

1. **PATH**：`where.exe draw.io`（ドットに注意。実行ファイルは `drawio.exe` ではなく `draw.io.exe`）
2. **既定のインストール先**：`C:\Program Files\draw.io\draw.io.exe`、次にユーザー単位のインストール先 `%LOCALAPPDATA%\Programs\draw.io\draw.io.exe`
3. **レジストリ**のアンインストール情報（ユーザーが選んだディレクトリが記録されている）
4. **他のドライブ**：`D:`、`E:` などの `Program Files\draw.io\draw.io.exe`

得られたパスは、ほぼ必ず空白を含むので、呼び出すたびにダブルクォートで囲む。次の書き方は bash でも cmd でも使える。

```
"D:\Program Files\draw.io\draw.io.exe" -x -f xml -o diagram.drawio diagram.mmd
```

すべての手順で何も見つからなかったときに初めて、CLI がないものとして扱い、XML で作って `.drawio` ファイルで出力する方式に切り替える。PATH の外で見つかった場合は、そのフォルダ（例：`D:\Program Files\draw.io`）を PATH に追加すると次回から見つけやすくなることを伝える。

### 書き出しコマンド

```bash
drawio -x -f <format> -e -b 10 -o "<output>" "<input.drawio>"
```

WSL2 では Windows の実行ファイルを呼ぶ。例：`"/mnt/c/Program Files/draw.io/draw.io.exe" -x -f png -e -b 10 -o "diagram.drawio.png" "diagram.drawio"`。変換と配置のコマンドは「処理の流れ」と「XML 向けの ELK 配置」にある。

主なフラグ：
- `-x` / `--export`：書き出しモード（Mermaid の変換や配置にも使う）
- `-f` / `--format`：出力形式（`xml`、png、svg、pdf、jpg）。Mermaid や配置から `.drawio` を作るときは `xml` を使う
- `--layout`：出力前に配置をかける。ELK のプリセット名、`libavoid` のエッジ経路、または独自配置の JSON 配列
- `--mermaid-image 1`：Mermaid を、編集可能な図ではなく1つの静的な SVG 画像セルに変換する（Mermaid のソースは再編集用にセルに残る）。ユーザーが編集不可の画像セルを明示的に求めたときだけ使う
- `-e` / `--embed-diagram`：出力に図の XML を埋め込む（PNG、SVG、PDF のみ）
- `-o` / `--output`：出力ファイルのパス
- `-b` / `--border`：図の周囲の余白の幅（既定：0）
- `-t` / `--transparent`：背景を透明にする（PNG のみ）
- `-s` / `--scale`：図の大きさを拡大縮小する
- `--width` / `--height`：指定した寸法に収める（縦横比は保つ）
- `-a` / `--all-pages`：全ページを書き出す（PDF のみ）
- `-p` / `--page-index`：特定のページを選ぶ（1始まり）
- `--disable-gpu`：GPU の初期化を省く。コマンドが `GPU process isn't usable` で終了するとき（Windows のリモートデスクトップ、VM、CI ランナー）に付ける。変換・配置・書き出しのどれも GPU は不要

### 結果を開く

結果のファイルは、次のプラットフォームのコマンドで開く。

| 環境 | コマンド |
|-------------|---------|
| macOS | `open <file>` |
| Linux（ネイティブ） | `xdg-open <file>` |
| WSL2 | `cmd.exe /c start "" "$(wslpath -w <file>)"` |
| Windows | `start <file>` |

WSL2 では、`cmd.exe` が `/mnt/c/...` を解決できないので、`wslpath -w` でパスを Windows のパスに変える。空の `""` は、`start` がファイル名をウィンドウタイトルとして読むのを防ぐ。

## ファイル名の付け方

- 内容に基づいた、説明的で小文字・ハイフン区切りの名前を使う（例：`login-flow`、`database-schema`）
- 書き出したファイルは二重拡張子にする — `name.drawio.png`、`name.drawio.svg`、`name.drawio.pdf` — 図の XML が埋め込まれていることを示すため

## XML 形式

`.drawio` ファイルはネイティブの mxGraphModel XML で、CLI が Mermaid を変換したときと同じ形式である。

### 基本構造

すべての図は次の構造を持たなければならない。

```xml
<mxGraphModel adaptiveColors="auto">
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
  </root>
</mxGraphModel>
```

- セル `id="0"` はルートレイヤー
- セル `id="1"` は既定の親レイヤー
- 複数レイヤーを使わない限り、図のすべての要素は `parent="1"` にする
- **コンテナ内のセル**は `parent="<コンテナの id>"` にし、座標はそのコンテナからの相対座標にする
- **エッジは、両端を含む最も内側のコンテナに属する** — 両端が同じコンテナ内（入れ子の深さは問わない）ならそのコンテナの id、片端がどのコンテナの外にもあれば `parent="1"`。自動配置はエッジの座標を親の座標系で読むので、両端より外側に置かれたエッジは誤った場所に配置される

### 重要：XML の整形式

- **出力に XML コメント（`<!-- -->`）を一切含めてはならない。** XML コメントは厳禁である。トークンを浪費し、解析エラーの原因になり、何の役にも立たない。
- 属性値の特殊文字はエスケープする：`&amp;`、`&lt;`、`&gt;`、`&quot;`
- 各 `mxCell` の `id` は必ず一意にする
- すべてのエッジに子要素 `<mxGeometry relative="1" as="geometry" />` が必要。自己終了タグのエッジ `mxCell` は描画されない

### 修復処理

XML を `.drawio` ファイルに書いた直後、配置・書き出しのどの処理よりも前に、これを実行する。draw.io が図を受け付けなくなる機械的なミスを直す。対象は、図の前後の余計なテキスト（コードフェンス、文、はぐれた閉じタグ）、属性値の中の `<` やはぐれた `&`（エスケープされていない HTML ラベル、「R&D」、`&nbsp;`）、既定レイヤーが自分自身を親にしている記述（`<mxCell id="1" parent="1"/>`。これがあるとすべてが非表示になる）である。整形式のファイルには何も変更を加えない。必要なのは Node.js だけである（`node` が入っていなければ省略する）。`DIAGRAM.drawio` は実際のファイル名に置き換える。

```bash
node -e '
const fs = require("fs");
const file = process.argv[1];
let xml = fs.readFileSync(file, "utf8");
const diagram = xml.match(/<mxfile[\s\S]*?<\/mxfile>|<mxGraphModel[\s\S]*?<\/mxGraphModel>/);
if (diagram && xml.trim() !== diagram[0]) xml = diagram[0];
xml = xml.replace(/="([^"]*)"/g, function(m, v)
{
  return "=\"" + v.replace(/</g, "&lt;").replace(/&(?!(?:amp|lt|gt|quot|apos|#[0-9]+|#x[0-9a-fA-F]+);)/g, "&amp;") + "\"";
});
xml = xml.replace(/<mxCell id="([^"]+)" parent="\1"\s*\/>/g, "<mxCell id=\"$1\" parent=\"0\"/>");
fs.writeFileSync(file, xml);
' "DIAGRAM.drawio"
```

## XML リファレンス

XML で作る前に、次の要約版の XML ルール（骨組み、頂点とエッジのテンプレート、ラベル、図形、配置グリッド、コンテナ、スイムレーン、エッジのスタイル）に従う。原文（`shared/xml-essentials.md`）のまま載せる。

```
XML rules:
- Skeleton: <mxGraphModel adaptiveColors="auto"><root><mxCell id="0"/><mxCell id="1" parent="0"/>…</root></mxGraphModel>. Unique ids. No XML comments.
- Vertex: <mxCell id="a" value="Label" style="rounded=1;whiteSpace=wrap;html=1;" vertex="1" parent="1"><mxGeometry x="40" y="40" width="140" height="60" as="geometry"/></mxCell>
- Edge: <mxCell id="e1" style="edgeStyle=orthogonalEdgeStyle;rounded=1;html=1;defaultLabelBackgroundColor=page;" edge="1" source="a" target="b" parent="1"><mxGeometry relative="1" as="geometry"/></mxCell>. Never self-closing. No waypoints or exitX/entryX.
- Labels: html=1 in every style; escape HTML in values (&lt;b&gt;Name&lt;/b&gt;&lt;br&gt;detail); line break &lt;br&gt;, never \n.
- Shapes: rhombus (decision), ellipse, shape=cylinder3 (database), text.
- Grid, no layout math: x=col*180+40, y=row*120+40, one node per cell; 140×60 boxes, 140×80 diamonds.
- Containers: swimlane;startSize=24; (titled) or group; (invisible); children set parent="<id>" with coordinates relative to it. An edge's parent is the innermost container holding both its ends, else "1".
- Lanes: swimlane;horizontal=0;startSize=110; at x=0, y=lane*150, height 150; nodes inside at x=120+col*180, y=45.
- Edges: orthogonal; entityRelationEdgeStyle for ER; labels 1-3 words; dashed=1 for one meaning, with a legend.
```

**ラベルまわりの属性は自分で付ける。** draw.io MCP サーバーは次の属性を図に自動で足すが、CLI は足さない。付けないと、エッジが図形の外に置いたラベルを貫いたり、水平なエッジの線がラベルに重なったりする（draw.io デスクトップ版 32.6.1 の書き出しで確認済み）。
- 図形の外にラベルを置く頂点（`verticalLabelPosition=bottom` など）：`labelPerimeter=1;`
- すべてのエッジ：`labelBackgroundColor=default;defaultLabelBackgroundColor=page;`（上のテンプレートには後者しかない）
- ラベルのあるエッジ：`labelPlacement=auto;`。ただしラベルの位置や `verticalAlign` を自分で指定したエッジには付けない

ほとんどの図はこれで足りる。図にレイヤー、タグ、メタデータとプレースホルダー、表、部門横断のグリッド、ダークモードの色が必要なときだけ、このスキルのフォルダにある完全版の `references/xml-reference.md` も読む（これは draw.io MCP サーバー向けの説明になっている。そこにある `search_shapes` ツールは使えないので「図形とアイコン」に従い、`postLayout` / `routing` の代わりには CLI の `--layout` を使う）。

### 図形とアイコン

図にクラウド・ネットワーク・ブランドのアイコン（AWS、Azure、GCP、Cisco、Kubernetes、GitHub、Slack など）が必要なときも、`mxgraph.*` の名前を推測してはならない。図形の検索は図の内容から作った検索語を外部のサービスに送るので、このスキルでは行わない。代わりに次のようにする。

- 基本図形（四角形、`shape=cylinder3`、`ellipse` など）にサービス名や機器名のラベルを付けて描く。
- 本物のアイコンが要る場合は、ユーザーに伝え、draw.io デスクトップ版の図形ライブラリ（*その他の図形* から AWS、Azure、Cisco などを有効にする）で差し替えてもらう。

## トラブルシューティング

| 問題 | 原因 | 対処 |
|---------|-------|----------|
| draw.io CLI が見つからない | デスクトップアプリが入っていない、または PATH にない | 「CLI の場所を特定する」を順に試す。本当にない場合は XML で作って `.drawio` ファイルで渡し、draw.io デスクトップアプリを入れれば Mermaid の変換・配置・画像の書き出しが使えるようになるとユーザーに伝える |
| Mermaid → PNG の書き出しでクラッシュする | 現行の draw.io デスクトップ版では、`.mmd` から `-e` 付きで PNG に直接書き出す処理が壊れている | Mermaid を先に `.drawio` に変換し（`-f xml`）、その `.drawio` を書き出す |
| Mermaid から空の図ができる | 図の種類のキーワードの綴り誤り、または構文エラー（不正なノード ID、クォートされていないラベル） | `references/mermaid-reference.md` を確認する。ディレクティブ以外の最初の行のキーワードで図の種類が決まる |
| 配置が効かない／エラーになる | 不明なプリセット名、独自 JSON が配列でない、またはデスクトップ版が古く `--layout` や `.mmd` の入力に対応していない | 「配置のプリセット」の名前か `[` で始まる JSON 配列を使う。デスクトップ版が古い場合は、XML で座標を明示して作り、draw.io デスクトップ版を更新すれば Mermaid の変換と配置が使えるとユーザーに伝える |
| 書き出したファイルが空・壊れている、または図が空に見える | XML が不正、またはルートセル `id="0"` と `id="1"` がない | 「修復処理」を実行し、「基本構造」を確認する |
| 変換・配置・書き出し中に `GPU process isn't usable. Goodbye.` が出る | Electron が GPU プロセスを起動できない。Windows のリモートデスクトップ、VM、CI ランナーでよく起きる。その前に出る `os_crypt` / `Failed to decrypt` の行は無関係 | 同じコマンドに `--disable-gpu` を付けて再実行する。draw.io デスクトップ版自身の `--disable-acceleration` スイッチでも同じ効果がある |
