#!/usr/bin/env python3
"""ASHEN SWARM v1.3 sprite pipeline — DRAWN dasher only.

Fresh generation task (NOT a retry of the failed v1.2 grids):
- Dasher grid generated cleanly 2026-11-01 (assets/raw-v13/):
  a NEW lean ember hound-wraith quadruped (elongated snout, ribbed
  charcoal flanks, molten spine ridge, ember tail) — a wholly new
  silhouette, not a re-proportioned cinderling. Sliced 3x3, keyed
  with the v1.0/v1.1 flood-fill rule (border through near-black <48,
  1.1 px feather, trim + centre on transparent 512).
- Poses grid (cinderling/brute/spitter/hero death+hurt+attack) FAILED
  to generate (media pipeline integrity check, 2026-11-01) and was
  deliberately NOT retried: those classes keep the v1.2 DERIVED
  frames as fallback (see GRAPHICS-PASS.md v1.3 provenance table).
  This script never re-derives them; it only slices the dasher grid
  and builds its gold elite variants.

Cell map (row-major, 3x3) of the dasher grid:
  (0,0) walk-0  (0,1) walk-1  (0,2) walk-2
  (1,0) telegraph (crouched, spine flaring)  (1,1) attack (lunging, jaws open)
  (1,2) stalk idle (unused spare)
  (2,0) death (slumped, dim)  (2,1) hurt (rearing flinch)  (2,2) walk-3
"""
import os, sys, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from key_sprites_v11 import (  # noqa: E402
    key_image, square_center, gold_variant, opaque_frac)
from PIL import Image, ImageDraw  # noqa: E402

ROOT = os.path.expanduser("~/workspace/ashen-swarm")
RAW13 = os.path.join(ROOT, "assets/raw-v13")
OUT = os.path.join(ROOT, "assets/sprites/v13")
QA = os.path.join(ROOT, "qa")
os.makedirs(OUT, exist_ok=True)

GRID = os.path.join(
    RAW13,
    "media-generation-v13-dasher-grid-0-a73917a0-25ad-4064-aa6b-919738398582.webp")

# (row, col) -> output name
CELLS = {
    (0, 0): "dasher-walk-0",
    (0, 1): "dasher-walk-1",
    (0, 2): "dasher-walk-2",
    (2, 2): "dasher-walk-3",
    (1, 0): "dasher-telegraph",
    (1, 1): "dasher-attack",
    (2, 0): "dasher-death",
    (2, 1): "dasher-hurt",
}


def slice_and_key():
    sheet = Image.open(GRID).convert("RGB")
    W, H = sheet.size
    print(f"grid size={sheet.size}")
    cw, ch = W // 3, H // 3
    report = {}
    for (r, c), name in sorted(CELLS.items()):
        # 1% inset per cell edge to avoid neighbour bleed
        x0 = int(c * cw + cw * 0.01)
        y0 = int(r * ch + ch * 0.01)
        x1 = int((c + 1) * cw - cw * 0.01)
        y1 = int((r + 1) * ch - ch * 0.01)
        cell = sheet.crop((x0, y0, x1, y1))
        keyed, _alpha = key_image(cell)
        sq = square_center(keyed, 512, 12)
        sq.save(os.path.join(OUT, f"{name}-512.png"))
        # gold elite variant (same transform discipline as v1.1/v1.2)
        g = gold_variant(os.path.join(OUT, f"{name}-512.png"))
        g.save(os.path.join(OUT, f"{name}-gold-512.png"))
        a = sq.split()[3]
        corners = [a.getpixel((0, 0)), a.getpixel((511, 0)),
                   a.getpixel((0, 511)), a.getpixel((511, 511))]
        report[name] = {
            "cell": [r, c],
            "opaque_frac": round(opaque_frac(sq), 4),
            "corners_transparent": all(v < 10 for v in corners),
        }
        print(f"OK {name}-512.png opaque={report[name]['opaque_frac']} "
              f"corners_ok={report[name]['corners_transparent']}")
    return report


def sheet(paths_labels, out_path, cols=4, cell=340):
    """Labeled contact sheet on a dark backdrop (v11 helper is v11-dir
    bound, so v13 builds its own from explicit paths)."""
    rows = (len(paths_labels) + cols - 1) // cols
    canvas = Image.new("RGB", (cols * cell, rows * (cell + 30)), (24, 18, 14))
    try:
        from PIL import ImageFont
        font = ImageFont.truetype(
            "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 19)
    except Exception:
        from PIL import ImageFont
        font = ImageFont.load_default()
    sd = ImageDraw.Draw(canvas)
    for i, (p, label) in enumerate(paths_labels):
        im = Image.open(p).convert("RGBA").resize((300, 300), Image.LANCZOS)
        x, y = (i % cols) * cell + 20, (i // cols) * (cell + 30) + 5
        canvas.paste(im, (x, y), im)
        sd.text((x, y + 305), label, fill=(255, 220, 170), font=font)
    canvas.save(out_path)
    print(f"OK sheet {canvas.size} -> {out_path}")


def main():
    report = slice_and_key()
    flagged = [k for k, v in report.items()
               if not v["corners_transparent"] or v["opaque_frac"] < 0.02]
    print("FLAGGED:", flagged)
    with open(os.path.join(QA, "v13-slice-report.json"), "w") as f:
        json.dump(report, f, indent=1)
    # contact sheets (dark backdrops) from the -512 game copies
    names = [f"dasher-walk-{i}-512" for i in range(4)] + [
        "dasher-telegraph-512", "dasher-attack-512",
        "dasher-death-512", "dasher-hurt-512"]
    sheet([(os.path.join(OUT, n + ".png"), n) for n in names],
          os.path.join(QA, "v13-dasher-sheet.png"), cols=4)
    sheet([(os.path.join(OUT, n.replace("-512", "-gold-512") + ".png"),
            n.replace("-512", "-gold-512")) for n in names],
          os.path.join(QA, "v13-dasher-gold-sheet.png"), cols=4)
    print("sheets: qa/v13-dasher-sheet.png qa/v13-dasher-gold-sheet.png")


if __name__ == "__main__":
    main()
