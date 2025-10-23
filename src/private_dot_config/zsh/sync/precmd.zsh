SUCCESS=$'\n[%F{magenta}%D{%H:%M:%S}%f] %F{yellow}%~%f [%F{reset}%?%f]\n%F{green}❯%f '
FAILURE=$'\n[%F{magenta}%D{%H:%M:%S}%f] %F{yellow}%~%f [%F{red}%?%f]\n%F{red}❯%f '
PROMPT=%(?.$SUCCESS.$FAILURE)

unset SUCCESS FAILURE
