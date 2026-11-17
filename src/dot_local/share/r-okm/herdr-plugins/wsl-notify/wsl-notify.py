"""WSL の herdr の通知を Windows のトーストで出し、クリックされたらそのペインに移る。

herdr の `ui.toast.delivery = "system"` は WSL では notify-send を呼ぶだけで、ペインの ID を
渡さない。そこで WSL では delivery を "off" にし、このプラグインが通知を出す。

notify: pane.agent_status_changed のフックとして herdr から起動される。状態が blocked か
    done になったら、herdr の delay_seconds(既定 1 秒)と同じだけ待つ。まだ同じ状態の
    ときだけ、herdr 本体と同じ文面で toast.ps1 を呼ぶ。herdr が動いている Windows Terminal
    の WSL タブが前面にあるときは、toast.ps1 が通知を出さない。
focus <uri>: トーストのクリックで開く herdr-wsl:focus?pane=<id> の URI を受け取る。
    URI スキームは run_onchange_after_304-register-herdr-wsl-uri が登録する。
    ペインにフォーカスし、focus-terminal.ps1 で WSL タブを前面に出す。
"""

import base64
import json
import os
import re
import shutil
import subprocess
import sys
import time
import traceback
import urllib.parse
from pathlib import Path

HERE = Path(__file__).resolve().parent
POWERSHELL = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
DELAY_SECONDS = 1
EVENT_TEXT = {"blocked": "needs attention", "done": "finished"}
# herdr のペイン ID("w1:p3"、"wK:pP" など)。URI はどのアプリからでも開けるので、形を確かめる
PANE_ID = re.compile(r"w[0-9A-Za-z]+:p[0-9A-Za-z]+")
LOG = Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state") / "herdr-wsl-notify.log"


def herdr_bin() -> str:
    # URI ハンドラーは wsl.exe --exec から起動され、PATH に ~/.local/bin が入らない
    return (
        os.environ.get("HERDR_BIN_PATH")
        or shutil.which("herdr")
        or str(Path.home() / ".local/bin/herdr")
    )


class HerdrError(Exception):
    def __init__(self, code: str, message: str) -> None:
        super().__init__(f"{code}: {message}")
        self.code = code


def herdr(*args: str) -> dict:
    # 失敗すると終了コード 1 で、stderr に {"error": {"code", "message"}} を書く
    proc = subprocess.run([herdr_bin(), *args], capture_output=True, text=True)
    try:
        response = json.loads(proc.stdout if proc.returncode == 0 else proc.stderr)
    except json.JSONDecodeError:
        raise RuntimeError(f"herdr {' '.join(args)} exited with {proc.returncode}: {proc.stderr}")
    if "error" in response:
        raise HerdrError(response["error"]["code"], response["error"]["message"])
    return response["result"]


def powershell(script: str, *args: str) -> None:
    win_path = subprocess.run(
        ["wslpath", "-w", str(HERE / script)], check=True, capture_output=True, text=True
    ).stdout.strip()
    result = subprocess.run(
        [POWERSHELL, "-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass",
         "-File", win_path, *args],
        capture_output=True,
    )
    if result.returncode != 0:
        # Windows PowerShell 5.1 はエラーを ANSI コードページで書く
        stderr = result.stderr.decode("cp932", "replace")
        raise RuntimeError(f"{script} exited with {result.returncode}: {stderr}")


def notify(event: dict) -> None:
    pane_id = event["pane_id"]
    status = event["agent_status"]
    time.sleep(DELAY_SECONDS)
    try:
        agent = herdr("agent", "get", pane_id)["agent"]
    except HerdrError as e:
        # 待つ間にペインが閉じたりエージェントが終わったりするのは、よくあること
        if e.code == "agent_not_found":
            return
        raise
    if agent["agent_status"] != status:
        return

    workspace = herdr("workspace", "get", agent["workspace_id"])["workspace"]
    # herdr 本体の notification_context と同じ "<workspace> · <番号> · <tab>"(tab は 2 つ以上のとき)
    body = f"{workspace['label']} · {workspace['number']}"
    if workspace["tab_count"] > 1:
        body += f" · {herdr('tab', 'get', agent['tab_id'])['tab']['label']}"
    label = event.get("display_agent") or event.get("agent") or agent.get("agent") or "agent"
    payload = {
        "title": f"{label} {EVENT_TEXT[status]}",
        "body": body,
        "launch": "herdr-wsl:focus?" + urllib.parse.urlencode({"pane": pane_id}),
        # ToastNotification.Tag は 64 文字まで
        "tag": pane_id[:64],
    }
    encoded = base64.b64encode(json.dumps(payload).encode()).decode()
    powershell("toast.ps1", encoded)


def focus(uri: str) -> None:
    pane_id = urllib.parse.parse_qs(urllib.parse.urlsplit(uri).query).get("pane", [""])[0]
    if not PANE_ID.fullmatch(pane_id):
        raise ValueError(f"not a herdr pane id: {pane_id!r}")
    try:
        herdr("agent", "focus", pane_id)
    except HerdrError as e:
        # ペインが閉じていても、herdr の画面は前に出す
        if e.code != "agent_not_found":
            raise
    finally:
        powershell("focus-terminal.ps1")


def run_logged(fn, *args) -> None:
    try:
        fn(*args)
    except Exception:
        LOG.parent.mkdir(parents=True, exist_ok=True)
        with LOG.open("a") as f:
            f.write(f"{time.strftime('%F %T')} {fn.__name__} {args!r}\n{traceback.format_exc()}")


def run_detached(fn, *args) -> None:
    # herdr のフックを待たせないよう、子プロセスに切り離してから待つ
    if os.fork() > 0:
        return
    os.setsid()
    # herdr がフックの出力を待っていても、ここで手放す
    devnull = os.open(os.devnull, os.O_RDWR)
    for fd in (0, 1, 2):
        os.dup2(devnull, fd)
    try:
        run_logged(fn, *args)
    finally:
        os._exit(0)


def main() -> None:
    command = sys.argv[1] if len(sys.argv) > 1 else ""
    if command == "notify":
        event = json.loads(os.environ["HERDR_PLUGIN_EVENT_JSON"])
        # フックには {"event": ..., "data": {...}} の形で届く
        data = event.get("data", event)
        if data.get("agent_status") in EVENT_TEXT:
            run_detached(notify, data)
    elif command == "focus" and len(sys.argv) == 3:
        # 切り離さない。前面を取る権利は、トーストのクリックで起動された wsl.exe の側にある
        run_logged(focus, sys.argv[2])
    else:
        sys.exit("usage: wsl-notify.py notify | focus <uri>")


if __name__ == "__main__":
    main()
