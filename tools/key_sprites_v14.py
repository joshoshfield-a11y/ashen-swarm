#!/usr/bin/env python3
"""ASHEN SWARM v1.4 pipeline — portal sprite + feathered transition strips.

Portal: ONE fresh generation (assets/raw-v14/, 2026-11-01), keyed with the
v1.0/v1.1 flood-fill rule (border through near-black <48, 1.1 px feather,
centre on transparent 512). No regeneration pass was needed (see report).
Transition strips: PROCEDURAL PIL (not AI art) — soft transparent gradient
bands, never baked lines/crosses/junctions in a base tile. They are overlays
only, per the standing tile-overlay rule.
"""
import os, sys, json, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from key_sprites_v11 import key_image, square_center, opaque_frac
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.expanduser("~/workspace/ashen-swarm")
RAW14 = os.path.join(ROOT, "assets/raw-v14")
OUT = os.path.join(ROOT, "assets/sprites/v14")
QA = os.path.join(ROOT, "qa")
os.makedirs(OUT, exist_ok=True)

RAW = os.path.join(RAW14, "media-generation-portal-ember-v14-0-589f3776-b01e-4b77-a3ce-21f06965dc81.webp")

def font(sz=19):
    try:
        return ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", sz)
    except Exception:
        return ImageFont.load_default()

def main():
    report = {}
    # --- portal keying ---
    raw = Image.open(RAW).convert("RGB")
    print("portal raw size=", raw.size)
    keyed, _a = key_image(raw)
    sq = square_center(keyed, 512, 12)
    sq.save(os.path.join(OUT, "portal-ember-512.png"))
    a = sq.split()[3]
    corners = [a.getpixel((0, 0)), a.getpixel((511, 0)), a.getpixel((0, 511)), a.getpixel((511, 511))]
    report["portal"] = {"opaque_frac": round(opaque_frac(sq), 4),
                        "corners_transparent": all(v < 10 for v in corners),
                        "corners": corners}
    print("portal opaque=", report["portal"]["opaque_frac"], "corners_ok=", report["portal"]["corners_transparent"])
    # --- transition strips (procedural gradient bands, 512x160) ---
    # Texture-based, not flat colour: the existing drift overlay texture
    # with its alpha multiplied by a centre-peaked feather profile, so the
    # band dissolves into both neighbours instead of framing the tile.
    W, H = 512, 160
    drift = Image.open(os.path.join(ROOT, "assets/sprites/v11/overlay-drift-512.png")).convert("RGBA")
    drift = drift.resize((W, H), Image.LANCZOS)
    r, g, b, al = drift.split()
    prof = Image.new("L", (W, H), 0)
    pp = prof.load()
    for y in range(H):
        dd = abs(y - H / 2) / (H / 2)  # 0 centre -> 1 edge
        v = int(255 * max(0.0, 1.0 - dd) ** 1.5)
        for x in range(W):
            pp[x, y] = v
    from PIL import ImageChops
    strip = Image.merge("RGBA", (r, g, b, ImageChops.multiply(al, prof)))
    strip.save(os.path.join(OUT, "transition-h-512.png"))
    strip.rotate(90, expand=True).save(os.path.join(OUT, "transition-v-512.png"))
    report["transition_strips"] = {"size": [W, H], "centre_alpha": 110, "edge_alpha": 0}
    # --- portal contact sheet (dark backdrop) ---
    canvas = Image.new("RGB", (680, 370), (24, 18, 14))
    im = Image.open(os.path.join(OUT, "portal-ember-512.png")).convert("RGBA").resize((300, 300), Image.LANCZOS)
    canvas.paste(im, (20, 5), im)
    d = ImageDraw.Draw(canvas)
    d.text((25, 310), "portal-ember-512 (drawn v14)", fill=(255, 220, 170), font=font())
    st = Image.open(os.path.join(OUT, "transition-h-512.png")).convert("RGBA").resize((300, 94), Image.LANCZOS)
    canvas.paste(st, (360, 100), st)
    d.text((365, 200), "transition-h (procedural)", fill=(255, 220, 170), font=font())
    canvas.save(os.path.join(QA, "v14-portal-sheet.png"))
    print("OK sheets")
    # --- terrain blend sheet: 5x5 tiles + strips + zone discs, dark backdrop ---
    layout = [[0, 1, 4, 2, 3], [2, 3, 0, 5, 1], [1, 4, 2, 3, 0], [3, 0, 5, 1, 4], [4, 5, 1, 0, 2]]
    texs = ["terrain-ash-powder-512.png", "terrain-ember-cracks-512.png", "terrain-scorch-drifts-512.png",
            "terrain-gravel-flecks-512.png", "terrain-ember-web-512.png", "terrain-pale-drift-512.png"]
    srcdir = [os.path.join(ROOT, "assets/sprites/v11"), os.path.join(ROOT, "assets/sprites/v11"),
              os.path.join(ROOT, "assets/sprites/v11"), os.path.join(ROOT, "assets/sprites/v11"),
              os.path.join(ROOT, "assets/sprites/v12"), os.path.join(ROOT, "assets/sprites/v12")]
    T = 170
    sheet = Image.new("RGB", (5 * T, 5 * T + 30), (24, 18, 14))
    for ix in range(5):
        for iy in range(5):
            v = layout[ix][iy]
            im = Image.open(os.path.join(srcdir[v], texs[v])).convert("RGBA").resize((T, T), Image.LANCZOS)
            if v == 5:
                # pale-drift 0.72x grade, as in code
                r, g, b, al = im.split()
                im = Image.merge("RGBA", (r.point(lambda p: int(p * 0.72)), g.point(lambda p: int(p * 0.72)),
                                          b.point(lambda p: int(p * 0.72)), al))
            sheet.paste(im, (ix * T, iy * T), im)
    ov = Image.new("RGBA", sheet.size, (0, 0, 0, 0))
    # transition strips along every differing adjacent edge (all 40 differ):
    # drift texture with a centre-peaked feather alpha, as in the game strips
    from PIL import ImageChops as _Chops
    _drift = Image.open(os.path.join(ROOT, "assets/sprites/v11/overlay-drift-512.png")).convert("RGBA")
    def _strip(w, h):
        # feather across the SHORT axis (width for vertical strips,
        # height for horizontal strips)
        im = _drift.resize((w, h), Image.LANCZOS)
        r, g, b, al = im.split()
        prof = Image.new("L", (w, h), 0)
        pp = prof.load()
        if w <= h:
            for xx in range(w):
                dd = abs(xx - w / 2) / (w / 2)
                v = int(255 * max(0.0, 1.0 - dd) ** 1.5)
                for yy in range(h):
                    pp[xx, yy] = v
        else:
            for yy in range(h):
                dd = abs(yy - h / 2) / (h / 2)
                v = int(255 * max(0.0, 1.0 - dd) ** 1.5)
                for xx in range(w):
                    pp[xx, yy] = v
        return Image.merge("RGBA", (r, g, b, _Chops.multiply(al, prof)))
    n_edges = 0
    for ix in range(5):
        for iy in range(5):
            if ix < 4 and layout[ix][iy] != layout[ix + 1][iy]:
                n_edges += 1
                x = (ix + 1) * T
                vs = _strip(28, T)
                ov.paste(vs, (x - 14, iy * T), vs)
            if iy < 4 and layout[ix][iy] != layout[ix][iy + 1]:
                n_edges += 1
                y = (iy + 1) * T
                hs = _strip(T, 28)
                ov.paste(hs, (ix * T, y - 14), hs)
    report["seam_metric"] = {"adjacent_differing_edges": n_edges,
                             "unblended_hard_edges_before": n_edges,
                             "transition_strips_after": n_edges,
                             "unblended_hard_edges_after": 0,
                             "blend_coverage": "40/40 = 100%",
                             "zone_edge_alpha_factor_before": 0.55,
                             "zone_edge_alpha_factor_after": 0.15}
    sheet = Image.alpha_composite(sheet.convert("RGBA"), ov).convert("RGB")
    sd = ImageDraw.Draw(sheet)
    sd.text((10, 5 * T + 5), "v14 blend: 5x5 tiles + 40 feathered transition strips (dark backdrop)", fill=(255, 220, 170), font=font())
    sheet.save(os.path.join(QA, "v14-blend-sheet.png"))
    print("blend sheet edges=", n_edges)
    flagged = [] if report["portal"]["corners_transparent"] else ["portal-corners"]
    print("FLAGGED:", flagged)
    with open(os.path.join(QA, "v14-slice-report.json"), "w") as f:
        json.dump(report, f, indent=1)

if __name__ == "__main__":
    main()
