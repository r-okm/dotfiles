# setopt
setopt nobeep
setopt nolistbeep
setopt correct
setopt auto_cd

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=2500
SAVEHIST=2000
setopt hist_ignore_all_dups   # keep only the newest copy of a command
setopt hist_expire_dups_first # delete duplicates first when trimming history
setopt hist_reduce_blanks     # strip superfluous blanks before saving
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt inc_append_history     # write each command as it is entered
setopt hist_fcntl_lock        # lock with fcntl so a killed shell leaves no stale lock
