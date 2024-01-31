#!/bin/sh

export WSL_INTEROP=
for socket in $(ls /run/WSL|sort -n); do
   if ss -elx | grep "$socket"; then
      export WSL_INTEROP=/run/WSL/$socket
   else
      rm $socket
   fi
done

# also start wsl-vpnkit
/mnt/c/Windows/system32/wsl.exe -d wsl-vpnkit --cd /app wsl-vpnkit
