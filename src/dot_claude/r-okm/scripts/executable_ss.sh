#!/usr/bin/env bash
set -euo pipefail

# Emit absolute paths of Windows screenshots selected by newest-first index.
# Args: bare indices and/or ranges (e.g. `1 3`, `2-4`, `1 3-5`). No args = latest 1.
# Path conversion is unnecessary: /mnt/c/... paths are readable as-is.

# Resolve the screenshot directory. SS_DIR wins; otherwise ask Windows for the
# Pictures known folder (follows OneDrive redirection) and append /Screenshots.
resolve_dir() {
  if [[ -n "${SS_DIR:-}" ]]; then
    printf '%s' "$SS_DIR"
    return
  fi

  local powershell="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
  if [[ ! -x "$powershell" ]]; then
    echo "ss: powershell.exe not found; set SS_DIR to the screenshot dir" >&2
    exit 1
  fi
  local win_pics
  win_pics=$("$powershell" -NoProfile -NonInteractive \
    -Command "[Environment]::GetFolderPath('MyPictures')" 2>/dev/null | tr -d '\r')
  if [[ -z "$win_pics" ]]; then
    echo "ss: could not resolve Windows Pictures folder; set SS_DIR" >&2
    exit 1
  fi
  printf '%s/Screenshots' "$(wslpath "$win_pics")"
}

dir=$(resolve_dir)
if [[ ! -d "$dir" ]]; then
  echo "ss: screenshot dir not found: $dir (set SS_DIR to override)" >&2
  exit 1
fi

# Newest-first list of image files. The extension OR-group MUST be parenthesized
# and each term given -iname; without \( \) the -printf action suppresses the
# implicit -print on the left branch and PNGs never emit.
mapfile -t files < <(
  find "$dir" -maxdepth 1 -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
       -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \) \
    -printf '%T@\t%p\n' \
    | sort -rn | cut -f2-
)

count=${#files[@]}
if (( count == 0 )); then
  echo "ss: no screenshots in $dir" >&2
  exit 1
fi

# Expand args into 1-based indices, preserving requested order.
idx=()
if (( $# == 0 )); then
  idx=(1)
else
  for tok in "$@"; do
    if [[ "$tok" =~ ^([0-9]+)-([0-9]+)$ ]]; then
      # 10# forces base-10; otherwise leading-zero tokens (08, 09) are parsed
      # as invalid octal and abort the script under set -e.
      a=$((10#${BASH_REMATCH[1]}))
      b=$((10#${BASH_REMATCH[2]}))
      if (( a <= b )); then
        for (( i = a; i <= b; i++ )); do idx+=("$i"); done
      else
        for (( i = a; i >= b; i-- )); do idx+=("$i"); done
      fi
    elif [[ "$tok" =~ ^[0-9]+$ ]]; then
      idx+=("$((10#$tok))")
    else
      echo "ss: invalid argument: $tok" >&2
      exit 1
    fi
  done
fi

for i in "${idx[@]}"; do
  if (( i < 1 || i > count )); then
    echo "ss: index out of range (1-$count): $i" >&2
    continue
  fi
  printf '%s\n' "${files[$((i - 1))]}"
done

# vim: set ft=sh:
