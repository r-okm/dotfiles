#!/usr/bin/env python3
"""Diff two JSON documents by meaning rather than by text.

Applications that own their own config rewrite it in whatever order they
like. Windows Terminal in particular reorders `keybindings` and reflows
arrays every time its settings UI saves, which buries the one line that
actually changed under a hundred lines of churn. This compares parsed
documents instead: object key order never registers, and an array whose
elements were only shuffled is reported as one REORDER line.

Input may be JSONC -- `//` comments and trailing commas are tolerated,
since that is what these files are written in.

Exit status is 0 when the documents mean the same thing and 1 when they
differ, so it can gate a commit.
"""

import argparse
import json
import re
import subprocess
import sys


def strip_jsonc(text):
    """Remove // comments and trailing commas so json.loads accepts the text."""
    # Only whole-line comments are stripped: a // inside a string literal
    # (a URL, a Windows path) must survive, and these files keep their
    # comments on their own lines.
    text = re.sub(r"^\s*//.*$", "", text, flags=re.M)
    return re.sub(r",(\s*[}\]])", r"\1", text)


def load_file(path):
    """Parse a JSON/JSONC file, tolerating a UTF-8 BOM."""
    with open(path, encoding="utf-8-sig") as f:
        return json.loads(strip_jsonc(f.read()))


def load_rev(rev, path):
    """Parse the version of `path` recorded at git revision `rev`."""
    try:
        blob = subprocess.run(
            ["git", "show", f"{rev}:{path}"],
            check=True, capture_output=True, text=True,
        ).stdout
    except subprocess.CalledProcessError as e:
        sys.exit(f"json-semantic-diff: git show {rev}:{path} failed: {e.stderr.strip()}")
    return json.loads(strip_jsonc(blob.lstrip("﻿")))


def canonical(value):
    """Return a stable string for a value, so elements can be compared as a set."""
    return json.dumps(value, sort_keys=True, ensure_ascii=False)


def fmt(value):
    return json.dumps(value, ensure_ascii=False)


def walk(old, new, path, out):
    """Collect the semantic differences between two parsed values."""
    if type(old) is not type(new):
        out.append(f"TYPE     {path}: {fmt(old)} -> {fmt(new)}")
        return

    if isinstance(old, dict):
        for key in sorted(set(old) | set(new)):
            # Keys may themselves contain dots (Windows Terminal writes
            # "compatibility.enableUnfocusedAcrylic" as one flat key), so the
            # separator is / to keep a real nesting level distinguishable.
            child = f"{path}/{key}"
            if key not in old:
                out.append(f"ADDED    {child} = {fmt(new[key])}")
            elif key not in new:
                out.append(f"REMOVED  {child} = {fmt(old[key])}")
            else:
                walk(old[key], new[key], child, out)
        return

    if isinstance(old, list):
        walk_list(old, new, path, out)
        return

    if old != new:
        out.append(f"VALUE    {path}: {fmt(old)} -> {fmt(new)}")


def walk_list(old, new, path, out):
    """Report an array, treating a pure reordering as a single finding."""
    old_canon = sorted(canonical(x) for x in old)
    new_canon = sorted(canonical(x) for x in new)

    if old_canon == new_canon:
        if [canonical(x) for x in old] != [canonical(x) for x in new]:
            out.append(f"REORDER  {path} ({len(old)} entries, same set)")
        return

    # The element sets differ, so report what entered and left. Positional
    # recursion would describe a shuffle-plus-edit as a cascade of unrelated
    # changes, which is exactly the noise this tool exists to remove.
    added = subtract(new_canon, old_canon)
    removed = subtract(old_canon, new_canon)
    for item in removed:
        out.append(f"LIST-OUT {path} - {item}")
    for item in added:
        out.append(f"LIST-IN  {path} + {item}")


def subtract(items, other):
    """Return `items` minus one occurrence of each element of `other`."""
    remaining = list(other)
    result = []
    for item in items:
        if item in remaining:
            remaining.remove(item)
        else:
            result.append(item)
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Diff two JSON documents by meaning, ignoring key order "
                    "and reporting reordered arrays as a single line.",
    )
    parser.add_argument(
        "paths", nargs="+", metavar="PATH",
        help="one file to compare against its committed version, or two files",
    )
    parser.add_argument(
        "--rev", default="HEAD", metavar="REV",
        help="git revision to compare a single file against (default: HEAD)",
    )
    args = parser.parse_args()

    if len(args.paths) == 1:
        path = args.paths[0]
        old, new = load_rev(args.rev, path), load_file(path)
        old_label, new_label = f"{args.rev}:{path}", path
    elif len(args.paths) == 2:
        old_label, new_label = args.paths
        old, new = load_file(old_label), load_file(new_label)
    else:
        parser.error("give one file (compared against --rev) or two files")

    out = []
    walk(old, new, "", out)

    print(f"old: {old_label}")
    print(f"new: {new_label}")
    if not out:
        print("no semantic difference")
        return 0
    print()
    for line in out:
        print(line)
    return 1


if __name__ == "__main__":
    sys.exit(main())
