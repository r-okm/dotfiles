#!/usr/bin/env python3
"""Rebuild UDEV Gothic with U+2460-24FF drawn at half width.

Windows Terminal gives every East Asian Ambiguous character one cell with no
per-font override, and tmux, glibc wcwidth() and Claude Code all agree, so the
enclosed alphanumerics (①⑳ ⑴⒇ ⒜⒵ ⒶⓏ ⓐⓩ ⓪ ⓿) line up only if the glyphs
themselves are half width.

Fonts land in the freedesktop user font directory, so Linux picks them up and
Windows has a stable folder to install from by hand.

The output directory is written to stdout; everything else goes to stderr.
"""

import argparse
import os
import shutil
import subprocess
import sys
import urllib.request
import venv
import zipfile
from pathlib import Path

UPSTREAM_VERSION = "v2.2.0"
UPSTREAM_URL = (
    "https://github.com/yuru7/udev-gothic/releases/download/"
    "{version}/UDEVGothic_NF_{version}.zip"
)
VARIANT = "UDEVGothic35NF"
SUFFIX = "EAW"
VENV_MARKER = "UDEV_GOTHIC_EAW_VENV"

# Enclosed Alphanumerics; other ambiguous-width glyphs are left alone.
TARGET_RANGE = range(0x2460, 0x2500)

XDG_CACHE = Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache")
XDG_DATA = Path(os.environ.get("XDG_DATA_HOME") or Path.home() / ".local/share")

CACHE_DIR = XDG_CACHE / "udev-gothic-eaw"
# fontconfig picks up anything under this path.
OUTPUT_DIR = XDG_DATA / "fonts/udev-gothic-eaw"


def die(message):
    sys.exit(f"{Path(sys.argv[0]).name}: {message}")


def log(message=""):
    print(message, file=sys.stderr)


def reexec_in_venv():
    """Re-run under a private venv holding fontTools."""
    try:
        import fontTools  # noqa: F401

        return
    except ImportError:
        pass

    venv_dir = CACHE_DIR / "venv"
    # An interrupted install leaves the interpreter behind without fontTools,
    # and exec'ing back into it would spin forever.
    if os.environ.get(VENV_MARKER):
        die(f"fontTools is missing from {venv_dir} -- delete it and run again")

    python = venv_dir / "bin/python3"
    if not python.exists():
        log("installing fontTools into a private venv...")
        venv.create(venv_dir, with_pip=True, clear=True)
        subprocess.run(
            [str(python), "-m", "pip", "install", "--quiet", "fonttools"], check=True
        )

    os.environ[VENV_MARKER] = "1"
    os.execv(str(python), [str(python), os.path.abspath(__file__), *sys.argv[1:]])


def download(version):
    url = UPSTREAM_URL.format(version=version)
    archive = CACHE_DIR / f"UDEVGothic_NF_{version}.zip"
    if archive.exists():
        return archive

    log(f"downloading {url}")
    archive.parent.mkdir(parents=True, exist_ok=True)
    partial = archive.with_suffix(".zip.part")
    with urllib.request.urlopen(url) as response, partial.open("wb") as out:
        shutil.copyfileobj(response, out)
    partial.rename(archive)
    return archive


def extract(archive, variant):
    dest = CACHE_DIR / "src" / archive.stem
    faces = []
    with zipfile.ZipFile(archive) as zf:
        for info in zf.infolist():
            name = Path(info.filename).name
            if not name.startswith(f"{variant}-") or not name.endswith(".ttf"):
                continue
            target = dest / name
            if not target.exists():
                target.parent.mkdir(parents=True, exist_ok=True)
                # Rename last, so an interrupt cannot leave a truncated ttf
                # that later runs would treat as already extracted.
                partial = target.with_suffix(".ttf.part")
                with zf.open(info) as src, partial.open("wb") as out:
                    shutil.copyfileobj(src, out)
                partial.rename(target)
            faces.append(target)
    if not faces:
        die(f"no {variant}-*.ttf inside {archive.name}")
    return sorted(faces)


def rename_family(font, suffix):
    """Give the patched font its own family so it sits beside the original."""
    name_table = font["name"]
    family = name_table.getDebugName(16) or name_table.getDebugName(1)
    if not family:
        die("font has no family name")

    bare = family.replace(" ", "")
    spaced, compact = f"{family} {suffix}", bare + suffix
    for record in name_table.names:
        text = record.toUnicode()
        patched = text.replace(family, spaced)
        # Skipped when the family has no space of its own to lose, or the
        # second pass would match what the first one just wrote.
        if bare != family:
            patched = patched.replace(bare, compact)
        if patched != text:
            record.string = patched
    return compact


def patch(path, out_dir):
    from fontTools.pens.boundsPen import BoundsPen
    from fontTools.pens.recordingPen import DecomposingRecordingPen
    from fontTools.pens.transformPen import TransformPen
    from fontTools.pens.ttGlyphPen import TTGlyphPen
    from fontTools.misc.transform import Transform
    from fontTools.ttLib import TTFont

    font = TTFont(path)
    cmap, glyf, hmtx = font.getBestCmap(), font["glyf"], font["hmtx"]
    glyph_set = font.getGlyphSet()

    for probe in (0x3042, 0x0041):
        if probe not in cmap:
            die(f"{path.name} has no {chr(probe)} to measure against")
    full = hmtx[cmap[0x3042]][0]
    half = hmtx[cmap[0x0041]][0]

    targets = {cmap[cp] for cp in TARGET_RANGE if cp in cmap and hmtx[cmap[cp]][0] == full}

    # Shrinking a glyph in place would corrupt any composite built from it.
    for name in glyf.keys():
        glyph = glyf[name]
        if name not in targets and glyph.isComposite():
            for component in glyph.components:
                if component.glyphName in targets:
                    die(f"{name} references {component.glyphName} as a component")

    # Read every outline before writing any, so that a target assembled from
    # another target cannot come out scaled twice depending on the order.
    originals = {}
    for name in sorted(targets):
        bounds = BoundsPen(glyph_set)
        glyph_set[name].draw(bounds)
        if bounds.bounds is None:
            continue
        recording = DecomposingRecordingPen(glyph_set)
        glyph_set[name].draw(recording)
        originals[name] = (bounds.bounds, recording)

    reference = BoundsPen(glyph_set)
    glyph_set[cmap[0x3042]].draw(reference)
    widest = max((x1 - x0 for (x0, _, x1, _), _ in originals.values()), default=1)
    tallest = max((y1 - y0 for (_, y0, _, y1), _ in originals.values()), default=1)
    # Only the width is constrained -- one cell -- so the height is spent on
    # matching a full-width glyph instead. The circles come out as ovals, which
    # reads better at 11pt than shrinking them evenly on both axes.
    scale_x = half / widest
    scale_y = (reference.bounds[3] - reference.bounds[1]) / tallest

    for name, (box, recording) in originals.items():
        x_min, y_min, x_max, y_max = box
        centre_x, centre_y = (x_min + x_max) / 2, (y_min + y_max) / 2

        # Keep the vertical centre fixed so the digits don't drop to the baseline.
        transform = Transform().translate(
            half / 2 - scale_x * centre_x, centre_y - scale_y * centre_y
        ).scale(scale_x, scale_y)

        pen = TTGlyphPen(None)
        recording.replay(TransformPen(pen, transform))

        glyph = pen.glyph()
        glyph.recalcBounds(glyf)
        glyf[name] = glyph
        hmtx[name] = (half, glyph.xMin if glyph.numberOfContours else 0)

    # Rescaled outlines invalidate the per-size metric caches.
    for table in ("hdmx", "LTSH", "VDMX"):
        if table in font:
            del font[table]
    font["maxp"].recalc(font)

    stem = rename_family(font, SUFFIX)
    out_path = out_dir / f"{stem}-{path.stem.split('-', 1)[1]}.ttf"
    font.save(out_path)
    return out_path, len(originals)


def main():
    parser = argparse.ArgumentParser(
        description=__doc__.splitlines()[0],
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument("--version", default=UPSTREAM_VERSION, help="upstream release tag")
    parser.add_argument("--variant", default=VARIANT, help="font file prefix to patch")
    parser.add_argument(
        "-o", "--output", type=Path, default=OUTPUT_DIR, help="where to write the fonts"
    )
    args = parser.parse_args()

    out_dir = args.output
    out_dir.mkdir(parents=True, exist_ok=True)

    # Fetched first: clearing the installed fonts before a download that then
    # fails would leave the terminal with neither the old nor the new ones.
    faces = extract(download(args.version), args.variant)

    # --output may be a font directory holding someone else's files too, so
    # the pattern carries the variant rather than just the suffix.
    for stale in out_dir.glob(f"{args.variant}{SUFFIX}-*.ttf"):
        stale.unlink()

    for face in faces:
        out_path, count = patch(face, out_dir)
        log(f"patched {count:3d} glyphs  {out_path.name}")

    if shutil.which("fc-cache"):
        subprocess.run(
            ["fc-cache", "--force", str(out_dir)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )

    install_from = out_dir
    if shutil.which("wslpath"):
        windows_path = subprocess.run(
            ["wslpath", "-w", str(out_dir)], capture_output=True, text=True
        )
        install_from = windows_path.stdout.strip() or out_dir

    log()
    log(f"{len(faces)} fonts written. On Windows, install them from")
    log(f"    {install_from}")
    log("then point the terminal font at the new family.")

    print(out_dir)


if __name__ == "__main__":
    reexec_in_venv()
    main()
