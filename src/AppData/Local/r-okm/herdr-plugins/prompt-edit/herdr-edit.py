"""herdr のエージェントのペインに送るプロンプトを、すぐ下に分割したペインの nvim で書く。

tmux の insert-from-editor.sh(tmux.conf で C-e に割り当て)の herdr 版。herdr の
キーから type = "shell" で起動され、キーを押したペインを HERDR_ACTIVE_PANE_ID
で受け取る。type = "pane" のほうが簡単だが、コマンドを最大化して開くので、
返事を書きたい出力が隠れてしまう。`herdr pane split` には起動するコマンドを
渡せず、分割したペインでは既定のシェルが先に立ち上がって見える。そこで
エディターは、このディレクトリのプラグイン(herdr-plugin.toml)のペインとして
開く。プラグインのペインは herdr がシェルを通さずに起動し、コマンドが終わると
閉じる。

herdr は manifest の写しを自分で持つので、herdr-plugin.toml が変わるたびに
chezmoi がプラグインを登録し直す(run_onchange_after_303-link-herdr-plugins)。
このスクリプトが登録するのは、apply のときに herdr のサーバーが動いていなかった
マシンのように、herdr がプラグインをまったく知らないときだけ。

エージェントのいないペインでは何もしない。bracketed paste の印が、それを
求めていないプログラムにキー入力として届いてしまうため。tmux の割り当ても、
claude のペインでだけエディターを開いていた。

--edit はプラグインのペインで動くコマンド。init.tmux_edit.lua(autowriteall、
<C-CR> で終了)で決まった場所の下書きを編集するので、クラッシュや :cq で
中断しても、次に開くと続きから書ける。普通に終了すると、下書きを bracketed
paste として送り先のペインに入れる。送信はされず、そちらで Enter を押すまで
待つ。`herdr pane send-text` だけで送ると tmux の `paste-buffer -r` と同じく
キー入力として届き、改行は LF のまま残るが、Claude Code がタブをキーとして
扱って消してしまう。送った下書きは復元用に last-sent.md として残す。下書きは
%LOCALAPPDATA%/r-okm/herdr-edit に置く。

どちらの側の出力も誰にも見えない(type = "shell" のコマンドには端末がなく、
プラグインのペインはこのスクリプトが終わると閉じる)。そのため、起動側は
エラーを herdr の通知で知らせ、エディター側は Enter を押すまでペインを残す。

--target PANE_ID は、手で実行するときに HERDR_ACTIVE_PANE_ID の代わりに使う。
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

PLUGIN_ID = "r-okm.prompt-edit"
# herdr はプラグインのペインを半分に分割し、比率を指定できない。開いたあとで送り先に高さを返す。
SHRINK_EDITOR = "0.2"


class HerdrError(Exception):
    pass


def herdr(*args, check=True):
    proc = subprocess.run(
        ["herdr", *args], capture_output=True, text=True, encoding="utf-8", errors="replace"
    )
    if check and proc.returncode != 0:
        detail = proc.stderr.strip() or proc.stdout.strip()
        raise HerdrError(f"herdr {' '.join(args[:2])} failed: {detail}")
    return proc


def error_code(proc):
    try:
        return json.loads(proc.stdout)["error"]["code"]
    except (ValueError, KeyError, TypeError):
        return None


def draft_dir():
    return Path(os.environ["LOCALAPPDATA"]) / "r-okm" / "herdr-edit"


def nvim_init():
    config = os.environ.get("XDG_CONFIG_HOME") or os.environ["LOCALAPPDATA"]
    return Path(config) / "nvim" / "init.tmux_edit.lua"


def open_editor(target):
    pane = json.loads(herdr("pane", "get", target).stdout)["result"]["pane"]
    if not pane.get("agent"):
        return
    open_args = [
        "plugin", "pane", "open", "--plugin", PLUGIN_ID, "--entrypoint", "editor",
        "--placement", "split", "--target-pane", target, "--direction", "down", "--focus",
        "--env", f"HERDR_EDIT_TARGET={target}", "--env", f"HERDR_EDIT_CWD={pane.get('cwd') or ''}",
    ]
    opened = herdr(*open_args, check=False)
    if error_code(opened) == "plugin_not_found":
        herdr("plugin", "link", str(Path(__file__).resolve().parent))
        opened = herdr(*open_args, check=False)
    if opened.returncode != 0:
        raise HerdrError(f"herdr plugin pane open failed: {opened.stderr.strip() or opened.stdout.strip()}")
    editor = json.loads(opened.stdout)["result"]["plugin_pane"]["pane"]["pane_id"]
    herdr("pane", "resize", "--pane", editor, "--direction", "down", "--amount", SHRINK_EDITOR)


def enter_cwd():
    # プラグインのペインはプラグインのディレクトリで起動する。nvim は送り先と同じディレクトリで
    # 開きたいが、削除した worktree のようにそのディレクトリが消えていればホームで開く。
    try:
        os.chdir(os.environ.get("HERDR_EDIT_CWD") or Path.home())
    except OSError:
        os.chdir(Path.home())


def edit():
    target = os.environ["HERDR_EDIT_TARGET"]
    enter_cwd()
    directory = draft_dir()
    directory.mkdir(parents=True, exist_ok=True)
    draft = directory / "draft.md"
    # :cq は 0 以外で終わる。そのときは送らずに下書きを残す
    cancelled = subprocess.run(["nvim", "-u", str(nvim_init()), str(draft)]).returncode != 0
    if not cancelled and draft.exists():
        # Windows の nvim は CRLF で保存する。CR が Enter として届くと 1 行目だけ送信されてしまう。
        text = draft.read_text(encoding="utf-8").replace("\r\n", "\n").rstrip("\n")
        if text.strip():
            herdr("pane", "send-text", target, f"\x1b[200~{text}\x1b[201~")
            draft.replace(directory / "last-sent.md")
    # このペインが閉じると、herdr は上の送り先とは限らない別の隣のペインにフォーカスを移す。
    herdr("pane", "focus", "--pane", os.environ["HERDR_PANE_ID"], "--direction", "up")


def run_edit():
    try:
        edit()
    except Exception as e:  # ペインが閉じるとトレースバックも消える
        draft = draft_dir() / "draft.md"
        print(f"{type(e).__name__}: {e}")
        if draft.exists():
            print(f"\nThe draft was not sent and is kept in {draft}")
        input("\nPress Enter to close this pane.")


def run_launcher(target):
    try:
        open_editor(target)
    except Exception as e:  # type = "shell" のコマンドには出力先の端末がない
        herdr("notification", "show", "prompt-edit failed", "--body", str(e)[:500], check=False)
        raise


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--target", help="pane to send the prompt to (default: HERDR_ACTIVE_PANE_ID)")
    parser.add_argument("--edit", action="store_true", help=argparse.SUPPRESS)
    args = parser.parse_args()
    if args.edit:
        run_edit()
        return
    target = args.target or os.environ.get("HERDR_ACTIVE_PANE_ID")
    if not target:
        sys.exit("no target pane: pass --target or run from a herdr key binding")
    run_launcher(target)


if __name__ == "__main__":
    main()
