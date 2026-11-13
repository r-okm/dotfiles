"""Pick a ghq repository or one of its linked worktrees and focus its herdr workspace.

Python, not a shell script: a Git Bash script spent most of a second starting
processes (bash -l, ghq, jq, awk, sort), each about 100ms through MSYS2's fork
emulation against about 30ms from here. This
starts fzf first so the window appears at once, and fills the list from one
`git config` and one `herdr workspace list` run in parallel with a walk of the
ghq roots done in-process. It uses only the standard library and fzf and has
nothing Windows-specific, but chezmoi deploys it only on Windows so far.

Rows are repositories sorted by name, each followed by its linked worktrees one
level indented; ● marks checkouts that already have a herdr workspace. Enter
runs `herdr worktree open --focus`, which focuses that workspace or creates
one. `--preview PATH` prints the preview pane for PATH; fzf calls it.
"""

import json
import os
import subprocess
import sys
import threading
from concurrent.futures import ThreadPoolExecutor

ACCENT = "\x1b[38;2;166;209;137m"
DIM = "\x1b[38;2;115;121;148m"
ERROR = "\x1b[38;2;231;130;132m"
RESET = "\x1b[0m"

# ghq's VCS markers; a .git file counts too (linked worktrees, --separate-git-dir)
REPO_MARKERS = (".git", ".hg", ".svn", ".bzr", "_darcs", ".fslckout", "_FOSSIL_")
SKIP_DIRS = {"node_modules"}

FZF_COLORS = (
    "bg+:#414559,hl:#a6d189,hl+:#a6d189,pointer:#a6d189,prompt:#a6d189,"
    "header:#737994,border:#737994,label:#a6d189"
)


def run(args, cwd=None):
    proc = subprocess.run(
        args, cwd=cwd, capture_output=True, text=True, encoding="utf-8", errors="replace"
    )
    return proc.stdout


def try_run(args, cwd=None):
    """run(), with a missing command or directory giving empty output."""
    try:
        return run(args, cwd)
    except OSError:
        return ""


def key(path):
    return os.path.normcase(os.path.normpath(path))


def ghq_roots():
    env = os.environ.get("GHQ_ROOT")
    if env:
        return env.split(os.pathsep)
    roots = run(["git", "config", "--path", "--get-all", "ghq.root"]).splitlines()
    return [os.path.expanduser(r) for r in roots if r] or [os.path.expanduser("~/ghq")]


def opened_checkouts():
    # without herdr the list still works, just without the ● marks
    try:
        workspaces = json.loads(run(["herdr", "workspace", "list"]))["result"]["workspaces"]
    except (OSError, ValueError, KeyError, TypeError):
        return set()
    return {
        key(w["worktree"]["checkout_path"])
        for w in workspaces
        if (w.get("worktree") or {}).get("checkout_path")
    }


def find_repos(root):
    """Return repository roots under root, like `ghq list -p`.

    Unlike ghq, hidden directories and node_modules are not searched, which
    keeps the walk short. Symlinked directories are followed, once each.
    """
    repos, stack, seen = [], [os.path.normpath(root)], set()
    while stack:
        path = stack.pop()
        real = os.path.realpath(path)
        if real in seen:
            continue
        seen.add(real)
        if any(os.path.exists(os.path.join(path, m)) for m in REPO_MARKERS):
            repos.append(path)
            continue
        try:
            entries = list(os.scandir(path))
        except OSError:
            continue
        stack.extend(
            e.path
            for e in entries
            if not e.name.startswith(".")
            and e.name not in SKIP_DIRS
            and e.is_dir()  # follows symlinks
        )
    return repos


def read_first_line(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            return f.readline().strip()
    except OSError:
        return ""


def git_dir(repo):
    """Return the repository's git directory, following a .git file."""
    dot_git = os.path.join(repo, ".git")
    if os.path.isdir(dot_git):
        return dot_git
    line = read_first_line(dot_git)
    if line.startswith("gitdir: "):
        return os.path.normpath(os.path.join(repo, line[len("gitdir: ") :]))
    return None  # not git


def linked_worktrees(repo):
    """Return (path, branch) for each linked worktree that still exists.

    Reads <git dir>/worktrees/<name>/{gitdir,HEAD} instead of running git once
    per repository.
    """
    gitdir = git_dir(repo)
    if not gitdir:
        return []
    admin_root = os.path.join(gitdir, "worktrees")
    try:
        names = sorted(os.listdir(admin_root))
    except OSError:
        return []
    result = []
    for name in names:
        admin = os.path.join(admin_root, name)
        wt_gitdir = read_first_line(os.path.join(admin, "gitdir"))
        if not wt_gitdir:
            continue
        path = os.path.dirname(os.path.normpath(os.path.join(admin, wt_gitdir)))
        if not os.path.isdir(path):
            continue  # prunable
        head = read_first_line(os.path.join(admin, "HEAD"))
        if head.startswith("ref: refs/heads/"):
            branch = head[len("ref: refs/heads/") :]
        else:
            branch = f"(detached {head[:7]})"
        result.append((path, branch))
    return result


def rows(roots, opened_future):
    """Yield fzf rows: display <TAB> checkout path <TAB> main repository path.

    Takes the `herdr workspace list` result as a future so the walk overlaps it.
    """
    repos = [repo for root in roots for repo in find_repos(root)]
    opened = opened_future.result()

    def mark(path):
        return f"{ACCENT}●{RESET}" if key(path) in opened else " "

    for repo in sorted(repos, key=lambda p: (os.path.basename(p).lower(), p)):
        yield f"{mark(repo)} {os.path.basename(repo)}\t{repo}\t{repo}"
        for path, branch in linked_worktrees(repo):
            name = os.path.basename(path)
            yield f"{mark(path)}   {branch}  {DIM}{name}{RESET}\t{path}\t{repo}"


def preview(path):
    print(f"path:   {path}")
    if not os.path.isdir(path):
        print("(directory not found)")
        return
    # three git runs in parallel: each costs ~100ms of process startup on Windows
    with ThreadPoolExecutor() as ex:
        branch = ex.submit(try_run, ["git", "branch", "--show-current"], path)
        last = ex.submit(
            try_run, ["git", "log", "-1", "--format=%h %ad %s", "--date=short"], path
        )
        status = ex.submit(try_run, ["git", "status", "--short"], path)
        print(f"branch: {branch.result().strip()}")
        print(f"last:   {last.result().strip()}")
        print("".join(status.result().splitlines(keepends=True)[:10]))
    readme = os.path.join(path, "README.md")
    try:
        with open(readme, encoding="utf-8", errors="replace") as f:
            print("".join(f.readlines()[:50]), end="")
            return
    except OSError:
        pass
    try:
        entries = sorted(os.scandir(path), key=lambda e: e.name)[:50]
    except OSError as e:
        print(e)
        return
    for entry in entries:
        print(entry.name + ("/" if entry.is_dir() else ""))


def fzf_command():
    script = os.path.abspath(__file__).replace("\\", "/")
    python = sys.executable.replace("\\", "/")
    preview_cmd = f'"{python}" -I -B "{script}" --preview ' + "{2}"
    return [
        "fzf",
        "--ansi",
        "--no-sort",
        "--layout=reverse",
        "--border=rounded",
        "--border-label= repositories ",
        "--delimiter=\t",
        "--with-nth=1",
        "--prompt=> ",
        "--header=enter: open · esc: close · ● open in herdr",
        f"--preview={preview_cmd}",
        "--preview-window=right,50%,border-left",
        f"--color={FZF_COLORS}",
    ]


def pick():
    # start fzf before the list exists so its window shows at once. Bytes, not
    # text mode, which would turn LF into CRLF on Windows.
    fzf = subprocess.Popen(fzf_command(), stdin=subprocess.PIPE, stdout=subprocess.PIPE)

    def write(line):
        fzf.stdin.write((line + "\n").encode())

    def feed():
        try:
            with ThreadPoolExecutor() as ex:
                opened = ex.submit(opened_checkouts)
                for row in rows(ghq_roots(), opened):
                    write(row)
        except BrokenPipeError:
            pass  # fzf closed before the list was complete
        except Exception as e:
            # an unselectable row: main() ignores a row with an empty path
            write(f"{ERROR}! {type(e).__name__}: {e}{RESET}\t\t")
        finally:
            try:
                fzf.stdin.close()  # fzf waits for EOF, so this must always run
            except OSError:
                pass

    threading.Thread(target=feed, daemon=True).start()
    # not communicate(): it would close stdin before feed() writes
    selected = fzf.stdout.read().decode("utf-8", "replace")
    return selected if fzf.wait() == 0 else None


def open_workspace(path, repo):
    """Return an error message, or None once the workspace is focused."""
    try:
        proc = subprocess.run(
            ["herdr", "worktree", "open", "--cwd", repo, "--path", path, "--focus"],
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
    except OSError as e:
        return str(e)
    return None if proc.returncode == 0 else proc.stderr or proc.stdout


def main():
    if len(sys.argv) == 3 and sys.argv[1] == "--preview":
        sys.stdout.reconfigure(encoding="utf-8")
        preview(sys.argv[2])
        return

    selected = pick()
    if not selected:
        return
    _, path, repo = selected.rstrip("\r\n").split("\t")
    if not path:
        return  # the error row
    error = open_workspace(path, repo)
    if error:
        # the popup closes when this exits, so wait until the message is read
        print(f"herdr worktree open failed:\n{error}")
        input("Press Enter to close.")


if __name__ == "__main__":
    main()
