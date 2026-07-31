#!/usr/bin/env bash
set -euo pipefail

# Extract still frames from a video so an agent can read them with the Read tool
# (which handles images but not video containers).
#
# Modes: uniform (evenly spaced), scene (scene-change cuts), all (every frame).
# Writes PNG/JPEG frames plus a frames.tsv index, and optionally a tiled contact
# sheet that packs many frames into one readable image.

readonly DEFAULT_MAX_FRAMES=24
readonly DEFAULT_WIDTH=960
readonly DEFAULT_SCENE_THRESHOLD=0.3
readonly DEFAULT_GRID=3x3
# Claude downsamples images whose long edge exceeds ~1568px, and that shrinks
# the burnt-in labels along with everything else. Bound both edges: a portrait
# source would otherwise blow past the limit vertically no matter the width.
readonly SHEET_MAX_WIDTH=1536
readonly SHEET_MAX_HEIGHT=1536
# Beyond this many frames the stdout listing is elided; frames.tsv keeps all.
readonly MAX_LISTED_FRAMES=12
readonly LIST_CONTEXT=5

usage() {
  cat <<'EOF'
Usage: video-frames.sh [options] <video>

Options:
  -m, --mode <uniform|scene|all>  Sampling mode (default: uniform).
  -i, --interval <sec>            uniform: seconds between frames.
  -f, --fps <n>                   uniform: frames per second (overrides --interval).
  -t, --threshold <0..1>          scene: scene-change score threshold (default: 0.3).
  -n, --max <n>                   Cap on emitted frames (default: 24). 0 = no cap.
  -s, --start <ts>                Skip to this position (seconds or HH:MM:SS).
  -e, --end <ts>                  Stop at this position.
  -w, --width <px>                Frame width, aspect preserved (default: 960).
      --crop <W:H:X:Y>            Crop to this region (source pixels) first.
  -c, --contact-sheet [CxR]       Also write tiled sheets (default grid: 3x3).
  -o, --out <dir>                 Output directory.
      --jpeg                      Write JPEG instead of PNG.
      --info                      Print video metadata only, extract nothing.
  -h, --help                      Show this help.

Default output directory: <git_root>/.ignore/ai/video-frames/<video_stem>
(falls back to ~/.cache/claude/video-frames/<video_stem> outside a repo).
EOF
}

die() {
  echo "video-frames: $*" >&2
  exit 1
}

# Without a passthrough mode the image2 muxer resamples to a constant rate,
# duplicating or dropping frames whenever `select` emits them unevenly. ffmpeg
# 5.0 renamed -vsync to -fps_mode, so ask the binary which one it takes.
detect_passthrough_args() {
  if [[ $(ffmpeg -hide_banner -h full | grep -c -- '-fps_mode') -gt 0 ]]; then
    passthrough_args=(-fps_mode passthrough)
  else
    passthrough_args=(-vsync passthrough)
  fi
}

probe() {
  ffprobe -v error -select_streams v:0 -show_entries "$1" \
    -of default=noprint_wrappers=1:nokey=1 "$video" | head -1
}

# ffprobe reports rates as fractions, and a container can advertise a nominal
# rate far above the frames it actually carries (120fps tagged onto 30fps of
# footage). Report what is really there: planning intervals off the nominal
# rate produces windows with a quarter of the expected frames.
format_fps() {
  python3 -c "
import sys

numerator, _, denominator = sys.argv[1].partition('/')
try:
    rate = float(numerator) / float(denominator or 1)
except (ValueError, ZeroDivisionError):
    rate = 0.0
print(f'{rate:.4g}' if rate else '?')
" "$1"
}

mode=uniform
interval=
fps=
threshold="$DEFAULT_SCENE_THRESHOLD"
max_frames="$DEFAULT_MAX_FRAMES"
start=
end=
width="$DEFAULT_WIDTH"
crop=
contact_sheet=
grid="$DEFAULT_GRID"
out_dir=
extension=png
info_only=
video=
passthrough_args=()

while (($# > 0)); do
  case "$1" in
    -m | --mode | -i | --interval | -f | --fps | -t | --threshold | -n | --max | \
      -s | --start | -e | --end | -w | --width | --crop | -o | --out)
      (($# >= 2)) || die "missing value for $1"
      ;;
  esac

  case "$1" in
    -m | --mode)
      mode="$2"
      shift 2
      ;;
    -i | --interval)
      interval="$2"
      shift 2
      ;;
    -f | --fps)
      fps="$2"
      shift 2
      ;;
    -t | --threshold)
      threshold="$2"
      shift 2
      ;;
    -n | --max)
      max_frames="$2"
      shift 2
      ;;
    -s | --start)
      start="$2"
      shift 2
      ;;
    -e | --end)
      end="$2"
      shift 2
      ;;
    -w | --width)
      width="$2"
      shift 2
      ;;
    --crop)
      crop="$2"
      shift 2
      ;;
    -c | --contact-sheet)
      contact_sheet=1
      # The grid is optional, so only consume the next token when it looks like one.
      if [[ "${2:-}" =~ ^[0-9]+x[0-9]+$ ]]; then
        grid="$2"
        shift
      fi
      shift
      ;;
    -o | --out)
      out_dir="$2"
      shift 2
      ;;
    --jpeg)
      extension=jpg
      shift
      ;;
    --info)
      info_only=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      die "unknown option: $1"
      ;;
    *)
      [[ -n "$video" ]] && die "more than one video given: $video, $1"
      video="$1"
      shift
      ;;
  esac
done

[[ -n "$video" ]] || {
  usage >&2
  exit 1
}
[[ -f "$video" ]] || die "no such file: $video"
video=$(readlink -f "$video")

# Catch bad numbers here rather than as an arithmetic error mid-extraction.
[[ "$max_frames" =~ ^[0-9]+$ ]] || die "--max needs a non-negative integer: $max_frames"
[[ "$width" =~ ^[0-9]+$ ]] || die "--width needs a positive integer: $width"
((width > 0)) || die "--width needs a positive integer: $width"
positive_number() { [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]] && [[ "$1" != 0 && ! "$1" =~ ^0+\.0+$ ]]; }
if [[ -n "$interval" ]]; then
  positive_number "$interval" || die "--interval needs a positive number of seconds: $interval"
fi
if [[ -n "$fps" ]]; then
  positive_number "$fps" || die "--fps needs a positive number: $fps"
fi
[[ "$threshold" =~ ^[0-9]+(\.[0-9]+)?$ ]] || die "--threshold needs a number in 0..1: $threshold"
for bound in "$start" "$end"; do
  [[ -z "$bound" || "$bound" =~ ^[0-9]+(:[0-9]+)*(\.[0-9]+)?$ ]] \
    || die "--start/--end need seconds or HH:MM:SS: $bound"
done
columns="${grid%x*}"
rows="${grid#*x}"
((columns > 0 && rows > 0)) || die "--contact-sheet needs a grid like 4x3, got: $grid"
crop_filter=
if [[ -n "$crop" ]]; then
  [[ "$crop" =~ ^[0-9]+:[0-9]+:[0-9]+:[0-9]+$ ]] || die "--crop needs W:H:X:Y in source pixels, got: $crop"
  crop_filter="crop=${crop},"
fi

detect_passthrough_args

duration=$(ffprobe -v error -show_entries format=duration \
  -of default=noprint_wrappers=1:nokey=1 "$video")
[[ -n "$duration" && "$duration" != "N/A" ]] || die "could not read duration: $video"
source_width=$(probe stream=width)
source_height=$(probe stream=height)
source_fps=$(probe stream=avg_frame_rate)
fps_note=
if [[ -z "$source_fps" || "$source_fps" == "0/0" ]]; then
  # Say so: the nominal rate is exactly what the effective one guards against.
  source_fps=$(probe stream=r_frame_rate)
  fps_note=" (nominal)"
fi
frame_total=$(probe stream=nb_frames)
[[ -n "$frame_total" && "$frame_total" != "N/A" ]] || frame_total="?"
codec=$(probe stream=codec_name)

echo "file:     $video"
echo "duration: ${duration}s"
echo "stream:   ${source_width}x${source_height} @ $(format_fps "$source_fps") fps${fps_note}, ${frame_total} frames ($codec)"

if [[ -n "$info_only" ]]; then
  exit 0
fi

if [[ -z "$out_dir" ]]; then
  stem=$(basename "$video")
  stem="${stem%.*}"
  if git_root=$(git rev-parse --show-toplevel 2>/dev/null); then
    out_dir="$git_root/.ignore/ai/video-frames/$stem"
  else
    out_dir="$HOME/.cache/claude/video-frames/$stem"
  fi
fi
mkdir -p "$out_dir"
# Every path this script prints ends up in a Read tool call, which rejects
# relative ones -- and --out is documented with a relative example. Keep the
# logical path though: .ignore is often a symlink into a per-project store, and
# resolving it drags the output somewhere the caller never asked for.
out_dir=$(realpath -s "$out_dir")

# Window duration drives the automatic uniform interval.
window="$duration"
if [[ -n "$start" || -n "$end" ]]; then
  window=$(python3 -c "
import sys


def seconds(value):
    parts = [float(part) for part in value.split(':')]
    total = 0.0
    for part in parts:
        total = total * 60 + part
    return total


duration, start, end = sys.argv[1:4]
begin = seconds(start) if start else 0.0
finish = seconds(end) if end else float(duration)
print(max(finish - begin, 0.0))
" "$duration" "$start" "$end")
fi

case "$mode" in
  uniform)
    if [[ -z "$fps" ]]; then
      if [[ -z "$interval" ]]; then
        (("$max_frames" > 0)) || die "--mode uniform needs --interval, --fps, or --max > 0"
        interval=$(python3 -c "
import sys

window, count = float(sys.argv[1]), int(sys.argv[2])
print(max(window / count, 1e-6))
" "$window" "$max_frames")
      fi
      fps=$(python3 -c "
import sys

print(1.0 / float(sys.argv[1]))
" "$interval")
    fi
    select_filter="fps=$fps"
    ;;
  scene)
    # The first frame never has a scene score, so keep it explicitly: it is the
    # baseline every later cut is judged against.
    select_filter="select='eq(n\,0)+gt(scene\,$threshold)'"
    ;;
  all)
    select_filter="null"
    ;;
  *)
    die "unknown mode: $mode (expected uniform, scene, or all)"
    ;;
esac

seek_args=()
[[ -n "$start" ]] && seek_args+=(-ss "$start")
[[ -n "$end" ]] && seek_args+=(-to "$end")

frame_limit_args=()
if (("$max_frames" > 0)); then
  frame_limit_args+=(-frames:v "$max_frames")
fi

# Everything is built in a private directory and moved in only once it is
# complete, so a run that dies partway leaves the previous output untouched.
# Concurrent runs sharing one --out are still last-writer-wins: use separate
# --out directories rather than relying on the move being atomic.
staging="$out_dir/.staging.$$"
rm -rf "$staging"
mkdir -p "$staging"
trap 'rm -rf "$staging"' EXIT

# A SIGKILL skips the trap. Reap those leftovers, but only where the owning
# process is gone -- a live sibling run is using its own staging directory.
shopt -s nullglob
for abandoned in "$out_dir"/.staging.*; do
  owner="${abandoned##*.}"
  [[ "$owner" =~ ^[0-9]+$ ]] || continue
  kill -0 "$owner" 2>/dev/null || rm -rf "$abandoned"
done
shopt -u nullglob

# showinfo prints each surviving frame's pts_time on stderr, which is the only
# way to recover real timestamps when `select` drops frames non-uniformly.
showinfo_log="$staging/.showinfo.log"
# Output names are always relative to a cd into the target directory: the image2
# muxer expands % in the *whole* output path, so a single % in some parent
# directory (a per-project store keyed by a URL, say) breaks every write.
(
  cd "$staging" || exit 1
  ffmpeg -hide_banner -nostdin -y \
    "${seek_args[@]}" -i "$video" \
    -vf "${select_filter},${crop_filter}scale='min(iw,${width})':-2:flags=lanczos,showinfo" \
    "${passthrough_args[@]}" -an \
    "${frame_limit_args[@]}" \
    "frame_%06d.$extension" \
    2>"$showinfo_log"
)

# %06d, not %04d: the glob below orders lexicographically, so an overflow to a
# wider number would sort frame_10000 ahead of frame_9999 and pair every later
# frame with the wrong timestamp.
shopt -s nullglob
frames=("$staging"/frame_*."$extension")
shopt -u nullglob
frame_count=${#frames[@]}
((frame_count > 0)) || {
  tail -20 "$showinfo_log" >&2
  die "no frames extracted"
}

# Offset the showinfo timestamps by --start: with -ss before -i, pts_time is
# relative to the seek point, not the start of the file.
start_offset=0
if [[ -n "$start" ]]; then
  start_offset=$(python3 -c "
import sys

total = 0.0
for part in sys.argv[1].split(':'):
    total = total * 60 + float(part)
print(total)
" "$start")
fi

# One entry per showinfo line, including the unparsable ones: dropping a bad
# value would shift every later frame onto its neighbour's timestamp.
mapfile -t timestamps < <(
  grep -o 'pts_time:[^ ]*' "$showinfo_log" \
    | cut -d: -f2 \
    | python3 -c "
import sys

offset = float(sys.argv[1])
for line in sys.stdin:
    try:
        print(f'{float(line.strip()) + offset:.3f}')
    except ValueError:
        print('?')
" "$start_offset"
)
rm -f "$showinfo_log"

# Paths as they will read once the staging directory is swapped in.
final_frames=()
for frame in "${frames[@]}"; do
  final_frames+=("$out_dir/$(basename "$frame")")
done

if [[ -n "$contact_sheet" ]]; then
  # Fit each frame inside a cell instead of scaling to the cell width: a 9:16
  # source at 3x3 would otherwise stack to ~2700px tall and get downsampled.
  tile_width=$((SHEET_MAX_WIDTH / columns))
  tile_height=$((SHEET_MAX_HEIGHT / rows))
  tile_fit="scale=w=${tile_width}:h=${tile_height}:force_original_aspect_ratio=decrease:force_divisible_by=2:flags=lanczos"

  labelled=".labelled"
  mkdir -p "$staging/$labelled"
  font=$(fc-match --format='%{file}' 'DejaVu Sans:style=Bold' 2>/dev/null || true)
  if [[ -z "$font" || ! -f "$font" ]]; then
    # Unlabelled tiles cannot be mapped back to a timestamp, so do not let that
    # pass as a normal sheet.
    echo "warning:  no font found (install fontconfig); sheet tiles will have no labels" >&2
  fi
  # Every ffmpeg path here is relative to $staging: the image2 demuxer expands
  # %d in an input path just as the muxer does in an output path, and a glob
  # input additionally treats [ ] in parent directories as pattern characters.
  for i in "${!frames[@]}"; do
    label="#$((i + 1)) t=${timestamps[$i]:-?}s"
    label_filter=
    if [[ -n "$font" && -f "$font" ]]; then
      label_filter=",drawtext=fontfile='$font':text='$label':x=6:y=4:fontsize=20:fontcolor=yellow:box=1:boxcolor=black@0.7:boxborderw=4"
    fi
    (
      cd "$staging" || exit 1
      ffmpeg -hide_banner -loglevel error -nostdin -y \
        -i "$(basename "${frames[$i]}")" \
        -vf "${tile_fit}${label_filter}" \
        "$(printf '%s/tile_%06d.png' "$labelled" "$((i + 1))")"
    )
  done

  (
    cd "$staging" || exit 1
    ffmpeg -hide_banner -loglevel error -nostdin -y \
      -framerate 1 -pattern_type glob -i "$labelled/tile_*.png" \
      -vf "tile=${columns}x${rows}:padding=4:margin=4:color=0x101010" \
      "${passthrough_args[@]}" \
      "sheet_%02d.png"
  )
  rm -rf "${staging:?}/$labelled"
fi

# Commit. Only now are the previous run's artifacts removed, and only the ones
# this script produces -- --out may point at a directory holding other work.
rm -f "$out_dir"/frame_*.png "$out_dir"/frame_*.jpg \
  "$out_dir"/sheet_*.png "$out_dir"/sheet_*.jpg "$out_dir"/frames.tsv
mv "$staging"/frame_* "$out_dir"/
shopt -s nullglob
sheets=("$staging"/sheet_*.png)
shopt -u nullglob
((${#sheets[@]} == 0)) || mv "$staging"/sheet_*.png "$out_dir"/
rm -rf "$staging"
trap - EXIT

index_file="$out_dir/frames.tsv"
# Two videos can share a basename and therefore this directory; record which
# one these frames came from so a stale directory is recognisable as stale.
printf '# source: %s\n' "$video" >"$index_file"
printf 'index\ttime_sec\tpath\n' >>"$index_file"
for i in "${!final_frames[@]}"; do
  printf '%d\t%s\t%s\n' "$((i + 1))" "${timestamps[$i]:-?}" "${final_frames[$i]}" >>"$index_file"
done

echo
echo "frames:   $frame_count (mode=$mode) -> $out_dir"
echo "index:    $index_file"

# Hitting --max mid-window means the tail of the video was never sampled, and a
# plain frame list gives no hint of that. Frames that merely stop one interval
# short of the end are normal, so only flag a gap well past the usual spacing.
if ((max_frames > 0 && frame_count == max_frames && frame_count > 1)); then
  warning=$(python3 -c "
import sys

try:
    first, last, window, offset, count = (float(value) for value in sys.argv[1:6])
except ValueError:  # an unparsable timestamp; nothing to compare against
    raise SystemExit
end = offset + window
spacing = (last - first) / (count - 1)
if end - last > 2 * spacing:
    print(f'warning:  capped at {int(count)} frames; covered {first:.3f}-{last:.3f}s '
          f'of {offset:.3f}-{end:.3f}s. Narrow the range or raise --max.')
" "${timestamps[0]:-0}" "${timestamps[$((frame_count - 1))]:-0}" "$window" "$start_offset" "$frame_count")
  if [[ -n "$warning" ]]; then
    echo "$warning" >&2
  fi
fi

echo
printf '%s\n' "#	time	path"
for i in "${!final_frames[@]}"; do
  if ((frame_count > MAX_LISTED_FRAMES)); then
    if ((i == LIST_CONTEXT)); then
      printf '...\t(%d more, see frames.tsv)\n' "$((frame_count - 2 * LIST_CONTEXT))"
    fi
    if ((i >= LIST_CONTEXT && i < frame_count - LIST_CONTEXT)); then
      continue
    fi
  fi
  printf '%d\t%ss\t%s\n' "$((i + 1))" "${timestamps[$i]:-?}" "${final_frames[$i]}"
done

if [[ -n "$contact_sheet" ]]; then
  echo
  echo "contact sheets (grid=$grid, tiles fit in ${tile_width}x${tile_height}px):"
  for sheet in "$out_dir"/sheet_*.png; do
    echo "  $sheet"
  done
fi

# vim: set ft=sh:
