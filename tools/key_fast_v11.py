#!/usr/bin/env python3
"""Fast v1.1 keyer: same rule as key_sprites_v11 (border flood-fill through
near-black <48, 1.1px feather, trim, centre on 512 square) but vectorised
via scipy connected-components, so a full grid slices in seconds.
Run with the ml-stack python (scipy present there)."""
import sys, os
sys.path.insert(0, os.path.join(os.path.expanduser("~/workspace/ashen-swarm"), "tools"))
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage
from key_sprites_v11 import square_center, contact_sheet, gold_variant, opaque_frac

ROOT = os.path.expanduser("~/workspace/ashen-swarm")
RAW = os.path.join(ROOT, "assets/raw-v11")
OUT = os.path.join(ROOT, "assets/sprites/v11")

def key_cell(cell):
    rgba = cell.convert("RGBA")
    arr = np.asarray(rgba).astype(np.int16)
    near_black = (arr[..., 0] < 48) & (arr[..., 1] < 48) & (arr[..., 2] < 48)
    lab, n = ndimage.label(near_black, structure=np.array([[0, 1, 0], [1, 1, 1], [0, 1, 0]]))
    border_labels = set(np.unique(np.concatenate([lab[0, :], lab[-1, :], lab[:, 0], lab[:, -1]]))) - {0}
    bg = np.isin(lab, list(border_labels))
    alpha = np.where(bg, 0, 255).astype(np.uint8)
    alpha_img = Image.fromarray(alpha, "L").filter(ImageFilter.GaussianBlur(1.1))
    rgba.putalpha(alpha_img)
    bbox = alpha_img.getbbox()
    assert bbox, "keying failed (all transparent)"
    return rgba.crop(bbox)

def slice_fast(sheet_path, rows, cols, names):
    sheet = Image.open(sheet_path).convert("RGB")
    W, H = sheet.size
    cw, ch = W // cols, H // rows
    res = {}
    for idx, name in enumerate(names):
        r, c = divmod(idx, cols)
        cell = sheet.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))
        keyed = key_cell(cell)
        sq = square_center(keyed, 512, pad=12)
        sq.save(os.path.join(OUT, f"{name}-512.png"))
        keyed.save(os.path.join(OUT, f"{name}.png"))
        res[name] = {"trimmed": keyed.size, "opaque_frac": round(opaque_frac(sq), 4)}
        print(f"OK {name}: cell {cell.size} -> trimmed {keyed.size} opaque {res[name]['opaque_frac']}")
    return res

if __name__ == "__main__":
    enemies = []
    for kind in ["cinderling", "brute", "spitter"]:
        enemies += [f"{kind}-walk-{i}" for i in range(4)]
    r1 = slice_fast(os.path.join(RAW, "media-generation-v11-enemies-walk-grid-0-a46c7967-fcbd-46ee-a33a-53f313578c0d.webp"),
                    3, 4, enemies)
    boss = [f"boss-walk-{i}" for i in range(4)] + ["boss-telegraph", "boss-death"]
    r2 = slice_fast(os.path.join(RAW, "media-generation-v11-boss-walk-grid-0-d921c420-fb5d-4ddc-bffd-77b2246d0e81.webp"),
                    2, 3, boss)
    # gold elite variants of the NEW enemy frames
    for kind in ["cinderling", "brute", "spitter"]:
        for i in range(4):
            g = gold_variant(os.path.join(OUT, f"{kind}-walk-{i}-512.png"))
            g.save(os.path.join(OUT, f"{kind}-gold-{i}-512.png"))
            print(f"OK {kind}-gold-{i}-512.png")
    contact_sheet([f"hero-walk-{i}" for i in range(4)], os.path.join(ROOT, "qa/v11-hero-sheet.png"))
    contact_sheet(enemies, os.path.join(ROOT, "qa/v11-enemies-sheet.png"), cols=4)
    contact_sheet(boss, os.path.join(ROOT, "qa/v11-boss-sheet.png"), cols=3)
    contact_sheet(["terrain-ash-powder", "terrain-ember-cracks", "terrain-scorch-drifts", "terrain-gravel-flecks"],
                  os.path.join(ROOT, "qa/v11-terrain-sheet.png"), cols=2)
    import json
    json.dump({"enemies": r1, "boss": r2}, open(os.path.join(ROOT, "qa/v11-slice-report.json"), "w"), indent=1)
    print("DONE")
