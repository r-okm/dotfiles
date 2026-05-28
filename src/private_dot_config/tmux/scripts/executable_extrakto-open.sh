#!/bin/sh
# extrakto "open" action dispatcher (set as @extrakto_open_tool).
#
# extrakto runs:  tmux run-shell -b "cd -- $PWD; <this script> <selected text>"
#   - URL-like text -> hand off to xdg-open (the previous default behaviour)
#   - otherwise     -> treat as a file path and open it in the running nvim
#                      that lives in window 2 of the current tmux session.
#
# The cwd is the source pane's directory (set by extrakto via `cd -- $PWD`), so
# relative paths resolve correctly. Supports an optional :line[:col] suffix on
# file paths (e.g. file.py:42 / file.py:42:5).

set -eu

# extrakto does not quote the selection; rejoin the rest as one value. Values
# with spaces collapse to single spaces (same limitation as the default tool).
target=$*
[ -n "$target" ] || exit 0

# URLs / remote refs keep the original xdg-open behaviour. Patterns mirror
# extrakto's [url] filter (https?://, git@, git://, ssh://, (s)ftp://, file://).
case "$target" in
http://* | https://* | ftp://* | sftp://* | ssh://* | git://* | git@* | file://*)
	exec xdg-open "$target" >/dev/null 2>&1
	;;
esac

# --- file path: open in the running nvim (window 2) -------------------------

# Peel an optional :line[:col] suffix off the path.
file=$target
line=""
col=""
file=${file%:} # drop a stray trailing colon (e.g. grep's "file:42:")
if expr "$file" : '.*:[0-9][0-9]*:[0-9][0-9]*$' >/dev/null 2>&1; then
	col=${file##*:}
	file=${file%:*}
fi
if expr "$file" : '.*:[0-9][0-9]*$' >/dev/null 2>&1; then
	line=${file##*:}
	file=${file%:*}
fi

# Resolve to an absolute path. `-m` tolerates non-existent paths and skips
# symlink resolution; the cwd is the source pane's directory (set by extrakto).
abs=$(realpath -m -- "$file" 2>/dev/null) || abs=$file

# Target the nvim that lives in window 2 of the current session. tmux's
# automatic-rename sets the window name to the running command's name, so the
# window is considered ready only when index 2 exists AND its name is "nvim".
# Note: `display-message -t :2` silently falls back to the current window when
# index 2 is missing, so existence is verified via list-windows first.
session=$(tmux display-message -p '#{session_name}')
target_pane="${session}:2"
win_name=$(tmux list-windows -t "$session" -F '#{window_index} #{window_name}' 2>/dev/null \
	| awk '$1 == 2 { sub(/^2 /, ""); print; exit }')
if [ -z "$win_name" ]; then
	tmux display-message -d 0 "extrakto-open: window 2 not found in session '$session'"
	exit 1
fi
if [ "$win_name" != "nvim" ]; then
	tmux display-message -d 0 "extrakto-open: window 2 is not running nvim (window_name='$win_name')"
	exit 1
fi

# Escape characters that are special on vim's command line.
esc=$(printf '%s' "$abs" | sed 's/[\\ #%|]/\\&/g')

# C-\ C-n returns nvim to normal mode from insert/visual/cmdline/terminal mode.
tmux send-keys -t "$target_pane" C-\\ C-n
tmux send-keys -t "$target_pane" -l ":edit $esc"
if [ -e "$abs" ]; then
	# File exists: confirm the :edit, then jump to the requested line/col.
	tmux send-keys -t "$target_pane" Enter
	if [ -n "$line" ]; then
		tmux send-keys -t "$target_pane" -l ":call cursor($line,${col:-1})"
		tmux send-keys -t "$target_pane" Enter
	fi
else
	# File missing: leave the :edit command on the cmdline (no Enter) so the
	# user can fix the path manually before pressing <CR>.
	tmux display-message -d 0 "extrakto-open: file not found, left on nvim cmdline: $abs"
fi

tmux select-window -t "$target_pane"
