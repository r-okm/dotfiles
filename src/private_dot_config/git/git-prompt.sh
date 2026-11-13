# Git for Windows: /etc/profile.d/git-prompt.sh sources this file instead of
# building its own prompt when it exists.
# The stock prompt runs `git --exec-path` at startup (~80ms) and `__git_ps1`
# in a subshell on every prompt (~130ms), because each process start is slow
# under MSYS2. This prompt leaves out the branch to avoid both.

PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]' # set window title
PS1="$PS1"'\n'                 # new line
PS1="$PS1"'\[\033[32m\]'       # change to green
PS1="$PS1"'\u@\h '             # user@host<space>
PS1="$PS1"'\[\033[35m\]'       # change to purple
PS1="$PS1"'$MSYSTEM '          # show MSYSTEM
PS1="$PS1"'\[\033[33m\]'       # change to brownish yellow
PS1="$PS1"'\w'                 # current working directory
PS1="$PS1"'\[\033[0m\]'        # change color
PS1="$PS1"'\n'                 # new line
PS1="$PS1"'$ '                 # prompt: always $

# The stock prompt finds git-completion.bash through `git --exec-path`;
# /etc/msystem sets MINGW_PREFIX to the same prefix (e.g. /ucrt64) for free.
if test -n "$BASH_VERSION" && test -f "$MINGW_PREFIX/share/git/completion/git-completion.bash"
then
	. "$MINGW_PREFIX/share/git/completion/git-completion.bash"
fi
