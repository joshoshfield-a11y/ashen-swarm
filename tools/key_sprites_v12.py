#!/usr/bin/env python3
"""ASHEN SWARM v1.2 sprite pipeline.

HONEST PROVENANCE NOTE (read before reusing): the two AI character grids
planned for v1.2 (dasher walk/pose grid, existing-enemy pose grid) FAILED
to generate (media pipeline integrity check, 2026-11-01) and were NOT
retried. Every v1.2 character frame below is therefore DERIVED from the
v1.1 keyed frames via documented PIL transforms (squash/dim/lean/lunge/
dasherize), never from v1.0 art and never a plain re-tint: silhouettes
change (squash, stretch, lean, rotation), and the dasher is a lean
re-proportioning of the cinderling walk cycle with its own telegraph /
attack / death / hurt frames. The two NEW terrain variants ARE new AI
art (terrain grid generated cleanly, sliced + made tileable here).
Derived frames are labelled as such on the contact sheets and in
GRAPHICS-PASS.md v1.2. If newly drawn poses are ever wanted, that is a
fresh generation task, not a retry of the failed calls.

Also builds, procedurally (no AI art): the pooled blob-shadow texture,
the 6 weapon icons + 1 generic emblem for level-up cards.
"""
import os, sys, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from key_sprites_v11 import (  # noqa: E402  (reuses the v1.1 keying rule + gold + tileable)
    make_tileable, edge_check, gold_variant)
from PIL import Image, ImageDraw, ImageEnhance  # noqa: E402

ROOT = os.path.expanduser("~/workspace/ashen-swarm")
V11 = os.path.join(ROOT, "assets/sprites/v11")
OUT = os.path.join(ROOT, "assets/sprites/v12")
RAW12 = os.path.join(ROOT, "assets/raw-v12")
QA = os.path.join(ROOT, "qa")
os.makedirs(OUT, exist_ok=True)

def load_v11(name):
    return Image.open(os.path.join(V11, f"{name}-512.png")).convert("RGBA")

def save(im, name):
    im.save(os.path.join(OUT, f"{name}-512.png"))
    print(f"OK {name}-512.png size={im.size}")

def fit512(im, pad=12):
    """Centre a transformed sprite on a transparent 512 canvas."""
    tw, th = im.size
    scale = min((512 - 2 * pad) / tw, (512 - 2 * pad) / th)
    nw, nh = max(1, int(tw * scale)), max(1, int(th * scale))
    small = im.resize((nw, nh), Image.LANCZOS)
    canvas = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    canvas.paste(small, ((512 - nw) // 2, (512 - nh) // 2), small)
    return canvas

def squash_dim(im, sy=0.55, rot=8, dim=0.55):
    """Collapse pose: lean/rotate, squash vertically, dim the core."""
    r = im.rotate(rot, resample=Image.BICUBIC, expand=False)
    w, h = r.size
    sq = r.resize((w, max(1, int(h * sy))), Image.LANCZOS)
    canvas = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    canvas.paste(sq, ((512 - w) // 2, 512 - sq.size[1] - 12), sq)
    return ImageEnhance.Brightness(canvas).enhance(dim)

def lean(im, rot=-10):
    return fit512(im.rotate(rot, resample=Image.BICUBIC, expand=False))

def lunge(im, sx=1.30):
    w, h = im.size
    return fit512(im.resize((int(w * sx), h), Image.LANCZOS))

def warm_boost(im, rm=1.12, ra=12, gm=1.05, ga=4):
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a > 10 and r > 70:
                px[x, y] = (min(255, int(r * rm + ra)), min(255, int(g * gm + ga)), b, a)
    return im

def dasherize(im):
    """Lean re-proportioning: squeeze width, stretch height, warm core."""
    w, h = im.size
    t = im.resize((int(w * 0.82), int(h * 1.12)), Image.LANCZOS)
    return warm_boost(fit512(t))

def build_derived():
    report = {}
    # --- existing kinds: death / hurt / attack from their own walk frames
    for kind, walk in (("cinderling", "cinderling-walk"),
                       ("brute", "brute-walk"),
                       ("spitter", "spitter-walk")):
        death = squash_dim(load_v11(f"{walk}-0"))
        hurt = lean(load_v11(f"{walk}-1"))
        save(death, f"{kind}-death")
        save(hurt, f"{kind}-hurt")
        report[f"{kind}-death"] = "squash+dim+rot from walk-0"
        report[f"{kind}-hurt"] = "lean-10 from walk-1"
        if kind in ("cinderling", "brute"):
            atk = lunge(load_v11(f"{walk}-3"))
            save(atk, f"{kind}-attack")
            report[f"{kind}-attack"] = "lunge-x1.30 from walk-3"
        # gold elite versions of every derived pose
        for nm, im in ((f"{kind}-death", death), (f"{kind}-hurt", hurt)):
            g = gold_variant(os.path.join(OUT, f"{nm}-512.png"))
            g.save(os.path.join(OUT, f"{nm}-gold-512.png"))
        if kind in ("cinderling", "brute"):
            g = gold_variant(os.path.join(OUT, f"{kind}-attack-512.png"))
            g.save(os.path.join(OUT, f"{kind}-attack-gold-512.png"))
    # --- hero death pose
    save(squash_dim(load_v11("hero-walk-0"), rot=-8), "hero-death")
    report["hero-death"] = "squash+dim+rot-8 from hero-walk-0"
    # --- dasher: lean re-proportioning of the cinderling walk cycle
    for i in range(4):
        save(dasherize(load_v11(f"cinderling-walk-{i}")), f"dasher-walk-{i}")
    tele = warm_boost(fit512(load_v11("cinderling-walk-1").resize(
        (int(512 * 0.82), int(512 * 0.78)), Image.LANCZOS)), rm=1.25, ra=20)
    save(tele, "dasher-telegraph")
    save(lunge(dasherize(load_v11("cinderling-walk-3")), sx=1.35), "dasher-attack")
    save(squash_dim(dasherize(load_v11("cinderling-walk-0"))), "dasher-death")
    save(lean(dasherize(load_v11("cinderling-walk-1"))), "dasher-hurt")
    for nm in ("dasher-walk-0", "dasher-walk-1", "dasher-walk-2", "dasher-walk-3",
               "dasher-telegraph", "dasher-attack", "dasher-death", "dasher-hurt"):
        g = gold_variant(os.path.join(OUT, f"{nm}-512.png"))
        g.save(os.path.join(OUT, f"{nm}-gold-512.png"))
    report["dasher"] = "dasherize (x0.82/y1.12 + warm core) of cinderling walk; poses derived from dasher frames"
    return report

def build_terrain():
    grid = None
    for f in sorted(os.listdir(RAW12)):
        if f.startswith("media-generation-v12-terrain-grid") and f.endswith(".webp"):
            grid = os.path.join(RAW12, f)
    assert grid, "terrain grid raw not found"
    sheet = Image.open(grid).convert("RGB")
    W, H = sheet.size
    assert W % 2 == 0, f"odd grid width {W}"
    out = {}
    for nm, x0 in (("terrain-ember-web", 0), ("terrain-pale-drift", W // 2)):
        panel = sheet.crop((x0, 0, x0 + W // 2, H))
        tiled = make_tileable(panel, band=48)
        ec = edge_check(tiled)
        small = tiled.resize((512, 512), Image.LANCZOS)
        small.save(os.path.join(OUT, f"{nm}-512.png"))
        print(f"OK {nm}-512.png edge_check={ec}")
        assert ec["left_right_mad"] == 0.0 and ec["top_bottom_mad"] == 0.0, ec
        out[nm] = ec
    return out

def build_shadow():
    im = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    for i in range(28, 0, -1):
        t = i / 28.0
        alpha = int(150 * (t ** 1.6))
        rx, ry = 220 * t, 95 * t
        d.ellipse([256 - rx, 256 - ry, 256 + rx, 256 + ry], fill=(0, 0, 0, alpha))
    im.save(os.path.join(OUT, "shadow-blob-512.png"))
    print("OK shadow-blob-512.png (procedural layered ellipse, max alpha 150)")

def build_icons():
    def base():
        return Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    icons = {}
    im = base(); d = ImageDraw.Draw(im)
    d.polygon([(64, 8), (88, 64), (64, 120), (40, 64)], fill=(255, 140, 20, 255))
    d.polygon([(64, 30), (76, 64), (64, 98), (52, 64)], fill=(255, 220, 150, 255))
    icons["icon-bolt"] = im
    im = base(); d = ImageDraw.Draw(im)
    d.polygon([(64, 6), (74, 54), (122, 64), (74, 74), (64, 122), (54, 74), (6, 64), (54, 54)],
              fill=(140, 210, 255, 255))
    icons["icon-frost"] = im
    im = base(); d = ImageDraw.Draw(im)
    d.line([(84, 10), (44, 60), (76, 60), (40, 118)], fill=(190, 120, 255, 255), width=14, joint="curve")
    icons["icon-storm"] = im
    im = base(); d = ImageDraw.Draw(im)
    d.ellipse([20, 20, 108, 108], outline=(255, 140, 20, 255), width=12)
    d.ellipse([88, 52, 112, 76], fill=(255, 200, 120, 255))
    icons["icon-orbit"] = im
    im = base(); d = ImageDraw.Draw(im)
    for k in range(8):
        import math
        a = k * math.pi / 4
        d.line([(64, 64), (64 + int(52 * math.cos(a)), 64 + int(52 * math.sin(a)))],
               fill=(255, 90, 20, 255), width=8)
    d.ellipse([44, 44, 84, 84], fill=(255, 170, 60, 255))
    icons["icon-nova"] = im
    im = base(); d = ImageDraw.Draw(im)
    d.line([(64, 34), (64, 112)], fill=(255, 200, 60, 255), width=8)
    d.polygon([(64, 4), (52, 36), (76, 36)], fill=(255, 215, 90, 255))
    icons["icon-lance"] = im
    im = base(); d = ImageDraw.Draw(im)
    d.polygon([(64, 20), (72, 56), (108, 64), (72, 72), (64, 108), (56, 72), (20, 64), (56, 56)],
              fill=(220, 220, 225, 255))
    icons["icon-emblem"] = im
    for nm, im in icons.items():
        im.save(os.path.join(OUT, f"{nm}.png"))
        print(f"OK {nm}.png (procedural icon 128px)")

def sheet(items, out_path, cols=4, cell=340):
    """items: list of (path, label). Dark backdrop, like v1.1 sheets."""
    rows = (len(items) + cols - 1) // cols
    canvas = Image.new("RGB", (cols * cell, rows * (cell + 30)), (24, 18, 14))
    try:
        from PIL import ImageFont
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 19)
    except Exception:
        font = ImageFont.load_default()
    sd = ImageDraw.Draw(canvas)
    for i, (p, label) in enumerate(items):
        if not os.path.exists(p):
            print(f"MISS sheet item {p}")
            continue
        im = Image.open(p).convert("RGBA").resize((300, 300), Image.LANCZOS)
        x, y = (i % cols) * cell + 20, (i // cols) * (cell + 30) + 5
        canvas.paste(im, (x, y), im)
        sd.text((x, y + 305), label, fill=(255, 220, 170), font=font)
    canvas.save(out_path)
    print(f"OK sheet {canvas.size} -> {out_path}")

def audit_alpha():
    """Every v12 character frame: opaque fraction + corner transparency."""
    bad = []
    for f in sorted(os.listdir(OUT)):
        if not f.endswith("-512.png") or f.startswith(("terrain", "shadow")):
            continue
        im = Image.open(os.path.join(OUT, f)).convert("RGBA")
        a = im.split()[3]
        px = list(a.getdata())
        frac = sum(1 for v in px if v > 10) / len(px)
        corners = [a.getpixel(p) for p in ((0, 0), (511, 0), (0, 511), (511, 511))]
        flag = "OK" if max(corners) == 0 and 0.02 < frac < 0.95 else "CHECK"
        if flag == "CHECK":
            bad.append(f)
        print(f"alpha {f}: opaque={frac:.4f} corners={corners} {flag}")
    return bad

if __name__ == "__main__":
    rep = build_derived()
    terr = build_terrain()
    build_shadow()
    build_icons()
    v12 = lambda n: os.path.join(OUT, n)
    sheet([(v12(f"{k}-walk-{i}-512.png"), f"{k}-walk-{i}") for k in ("dasher",) for i in range(4)]
          + [(v12(f"dasher-{p}-512.png"), f"dasher-{p}") for p in ("telegraph", "attack", "death", "hurt")]
          + [(v12(f"{k}-{p}-512.png"), f"{k}-{p}") for k in ("cinderling", "brute") for p in ("death", "hurt", "attack")]
          + [(v12(f"spitter-{p}-512.png"), f"spitter-{p}") for p in ("death", "hurt")]
          + [(v12("hero-death-512.png"), "hero-death")],
          os.path.join(QA, "v12-poses-sheet.png"), cols=4)
    sheet([(os.path.join(V11, f"terrain-{n}-512.png"), f"v11-{n}") for n in
           ("ash-powder", "ember-cracks", "scorch-drifts", "gravel-flecks")]
          + [(v12("terrain-ember-web-512.png"), "v12-ember-web"),
             (v12("terrain-pale-drift-512.png"), "v12-pale-drift")],
          os.path.join(QA, "v12-terrain-sheet.png"), cols=3)
    sheet([(v12(f"icon-{n}.png"), f"icon-{n}") for n in
           ("bolt", "frost", "storm", "orbit", "nova", "lance", "emblem")]
          + [(v12("shadow-blob-512.png"), "shadow-blob")],
          os.path.join(QA, "v12-icons-sheet.png"), cols=4)
    bad = audit_alpha()
    json.dump({"derived": rep, "terrain_edge": terr, "alpha_flagged": bad},
              open(os.path.join(QA, "v12-slice-report.json"), "w"), indent=1)
    print("alpha flagged:", bad)
