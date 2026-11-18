#!/usr/bin/env -S python3 -I -B
"""Create, list, open, or remove git worktrees, each opened as a herdr workspace.

The herdr front-end of git_worktree_core, which does the git side and keeps the
worktrees under <repository>/.worktree/. herdr-ghq.py, the ghq picker,
imports this. Python with only the standard library, so that it also runs on native
Windows. Progress goes to stderr, results to stdout.

The repository's own workspace is the base: `herdr worktree open` opens it next
to every linked worktree, and a worktree is removed from there. Removing the
worktree of the workspace this runs in is refused, because closing that
workspace would kill the caller (herdr has nothing like tmux's
destroy-unattached to defer it).
"""

import json
import os
import shutil
import socket
import subprocess
import sys

# python -I leaves the script's directory off sys.path; core sits next to this file
sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
import git_worktree_core as core  # noqa: E402

PROG = os.path.basename(sys.argv[0])

HELP = f"""\
Usage: {PROG} [OPTIONS] [<branch_name|pr_number|branch_suffix|worktree_name>]

Create, list, open, or remove git worktrees under <repository>/.worktree/, each
opened as a herdr workspace. The git side is done by git_worktree_core.

Options:
  -b, --branch        Create worktree from branch name
  -p, --pull-request  Create worktree from pull request number
  -c, --create-branch Create a new branch from the remote HEAD in a new worktree
                      (branch_suffix is optional)
  -o, --open          Open the workspace of an existing worktree
                      These four print the worktree path on the last line of
                      stdout. An existing worktree is returned as is, without
                      fetching, creating symlinks or initializing submodules.
      --focus         With the four above, switch to the workspace. Without
                      it, the workspace opens in the background.
  -l, --list          List worktrees under .worktree/, one per line as
                      <worktree_name> TAB <branch> TAB <workspace_id|-> TAB
                      <worktree_path>
  -r, --remove        Remove a worktree and close its workspace. The branch is
                      kept. Refuses when the worktree has uncommitted changes,
                      untracked files, or a detached HEAD with commits on no
                      branch, unless -f is given. Always refuses when the
                      worktree's workspace is the one this runs in: run it
                      from the repository's workspace instead.
  -f, --force         With -r, skip the checks on the worktree's contents
  -h, --help          Display this help message

Without herdr (not installed or its server not running), the worktree is still
created and its path printed; only the workspace is skipped.

Worktree name: the branch name with '/' replaced by '-'
Worktree path: <repository>/.worktree/<worktree_name>

Examples:
  {PROG} -b feature/new-feature
  {PROG} -p 123
  {PROG} -c new-feature --focus
  {PROG} -l
  {PROG} -o feature-new-feature
  {PROG} -r feature-new-feature
"""

MODES = {
    "-b": "branch",
    "--branch": "branch",
    "-p": "pr",
    "--pull-request": "pr",
    "-c": "create",
    "--create-branch": "create",
    "-o": "open",
    "--open": "open",
    "-l": "list",
    "--list": "list",
    "-r": "remove",
    "--remove": "remove",
}


def herdr(*args):
    """Run herdr and return the CompletedProcess, or None when it is not installed."""
    try:
        return subprocess.run(
            ["herdr", *args],
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
    except OSError:
        return None


def key(path):
    return os.path.normcase(os.path.normpath(path))


def list_workspaces():
    """Return herdr's workspaces in sidebar order, or [] without herdr."""
    proc = herdr("workspace", "list")
    try:
        return json.loads(proc.stdout)["result"]["workspaces"]
    except (AttributeError, ValueError, KeyError, TypeError):
        return []


def workspaces_by_checkout():
    """Map each checkout open in herdr to its workspace ID."""
    return {
        key(w["worktree"]["checkout_path"]): w["workspace_id"]
        for w in list_workspaces()
        if (w.get("worktree") or {}).get("checkout_path")
    }


def api_request(method, params):
    """Send one request to the herdr socket API, for methods the CLI does not expose.

    The socket is a Unix domain socket on Unix and a named pipe on Windows.
    """
    path = os.environ.get("HERDR_SOCKET_PATH")
    if not path:
        if os.name == "nt":
            return  # the default pipe name is not documented
        path = os.path.expanduser("~/.config/herdr/herdr.sock")
    line = (json.dumps({"id": "git-worktree-herdr", "method": method, "params": params}) + "\n").encode()
    if os.name == "nt":
        with open(path, "r+b", buffering=0) as pipe:
            pipe.write(line)
            pipe.readline()
    else:
        with socket.socket(socket.AF_UNIX) as sock:
            sock.connect(path)
            sock.sendall(line)
            sock.makefile("rb").readline()


def group_with_repository(path):
    """Move the workspace for path next to the other workspaces of its repository.

    herdr appends a new workspace to the end. The sidebar still shows it under its
    repository, but goto lists workspaces in their actual order, so this moves the
    repository's workspaces together, the main checkout first, at the position of
    the first of them.
    """
    workspaces = list_workspaces()
    ids = [w["workspace_id"] for w in workspaces]
    trees = {w["workspace_id"]: w.get("worktree") or {} for w in workspaces}
    target = next(
        (i for i in ids if trees[i].get("checkout_path") and key(trees[i]["checkout_path"]) == key(path)),
        None,
    )
    repo_key = target and trees[target].get("repo_key")
    if not repo_key:
        return
    group = [i for i in ids if trees[i].get("repo_key") == repo_key]
    if len(group) < 2:
        return
    start = ids.index(group[0])
    before = next((i for i in ids[start:] if i not in group), None)
    group.sort(key=lambda i: bool(trees[i].get("is_linked_worktree")))
    try:
        api_request(
            "workspace.move_block", {"workspace_ids": group, "before_workspace_id": before}
        )
    except OSError:
        pass  # the order is cosmetic


def open_workspace(path, repo, focus):
    """Open (or focus) the workspace of a checkout. Return an error message, or None.

    herdr also opens the repository's workspace when it is closed; it is left
    open as the place to remove worktrees from.
    """
    opened = workspaces_by_checkout()
    proc = herdr(
        "worktree", "open", "--cwd", repo, "--path", path,
        "--focus" if focus else "--no-focus",
    )
    if proc is None:
        return "herdr is not installed"
    if proc.returncode != 0:
        return (proc.stderr or proc.stdout).strip()
    if key(path) not in opened:
        group_with_repository(path)
    return None


def remove_worktree(worktree_name, force):
    """Remove a worktree of the repository at the current directory and close its workspace."""
    path = core.resolve_worktree_dir(worktree_name)
    workspace = workspaces_by_checkout().get(key(path))
    if workspace and workspace == os.environ.get("HERDR_WORKSPACE_ID"):
        core.log(f"Error: {path} is open in the workspace this runs in ({workspace})")
        core.fail("Run this from the repository's workspace, which herdr opens next to it")

    if workspace:
        # Closed before the removal: on Windows a shell whose cwd is in the
        # worktree keeps git from deleting the directory
        if not force:
            core.check_removable(path)
        core.log(f"Closing herdr workspace: {workspace}")
        proc = herdr("workspace", "close", workspace)
        if proc is None or proc.returncode != 0:
            detail = proc and (proc.stderr or proc.stdout).strip()
            core.log(f"Warning: could not close workspace {workspace}{f': {detail}' if detail else ''}")

    core.remove_worktree(worktree_name, force)


def list_rows():
    opened = workspaces_by_checkout()
    for name, branch, path in core.list_worktrees():
        yield name, branch, opened.get(key(path), "-"), path


def run(argv):
    mode = None
    target = ""
    force = False
    focus = False

    for arg in argv:
        if arg in MODES:
            mode = MODES[arg]
        elif arg in ("-f", "--force"):
            force = True
        elif arg == "--focus":
            focus = True
        elif arg in ("-h", "--help"):
            print(HELP, end="")
            return
        elif arg.startswith("-"):
            core.log(f"Unknown option: {arg}")
            core.log(HELP.rstrip("\n"))
            raise core.Fail()
        else:
            target = arg

    if mode is None:
        core.log("Error: Please specify one of -b, -p, -c, -o, -l or -r")
        core.log(HELP.rstrip("\n"))
        raise core.Fail()
    if force and mode != "remove":
        core.fail("Error: -f/--force only applies to -r/--remove")
    if focus and mode in ("list", "remove"):
        core.fail("Error: --focus only applies to -b, -p, -c and -o")
    if not target and mode not in ("create", "list"):
        core.log("Error: Please specify a branch name, PR number or worktree name")
        core.log(HELP.rstrip("\n"))
        raise core.Fail()

    if subprocess.run(
        ["git", "rev-parse", "--git-dir"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    ).returncode != 0:
        core.fail("Error: Not in a git repository")

    if mode == "list":
        for row in list_rows():
            print("\t".join(row))
        return
    if mode == "remove":
        remove_worktree(target, force)
        return

    if mode == "branch":
        path = core.create_worktree(target)
    elif mode == "pr":
        path = core.create_from_pr(target)
    elif mode == "create":
        path = core.create_new_branch(target)
    else:  # open
        path = core.resolve_worktree_dir(target)

    if shutil.which("herdr") is None:
        core.log("Warning: herdr is not installed; no workspace opened")
    else:
        error = open_workspace(path, core.get_repo_root(), focus)
        if error:
            core.log(f"Warning: herdr worktree open failed; no workspace opened: {error}")
    print(path, flush=True)


def main():
    try:
        run(sys.argv[1:])
    except core.Fail as e:
        sys.exit(e.status)
    except BrokenPipeError:
        sys.exit(1)


if __name__ == "__main__":
    main()
