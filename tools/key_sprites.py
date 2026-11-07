#!/usr/bin/env python3
"""Key AI sprites (black bg) to transparency via border flood-fill.
Preserves dark interior detail: only black connected to the border is removed.
Then soft-feather, trim, centre on square canvas, emit full + 512 copies.
Arena full-bleed tile is copied through untouched.
"""
import os, sys
from collections import deque
from PIL import Image, ImageFilter, ImageDraw

ROOT = os.path.expanduser("~/workspace/ashen-swarm")
RAW = os.path.join(ROOT, "assets/raw")
OUT = os.path.join(ROOT, "assets/sprites")
os.makedirs(OUT, exist_ok=True)

MAPPING = {
    "hero-ember-warden": "media-generation-hero-ember-warden-0-3e535f95-283e-4c7d-99a0-45d17085e5eb.png",
    "enemy-cinderling": "media-generation-enemy-cinderling-0-13b688c8-a429-4b99-9770-7692cf608872.png",
    "enemy-ash-brute": "media-generation-enemy-ash-brute-0-ca408879-b6be-41c9-966b-a6db1cac48d7.png",
    "enemy-ember-spitter": "media-generation-enemy-ember-spitter-0-03ff9264-cf4a-4539-9ca0-91db1e0baee9.png",
    "boss-ember-matriarch": "media-generation-boss-ember-matriarch-0-e3fbbf83-88c7-411a-ac27-d42bfbd406d3.png",
}

def key_image(src_path):
    im = Image.open(src_path).convert("RGBA")
    w, h = im.size
    px = im.load()
    # flood from borders through near-black pixels (all channels < 48)
    visited = bytearray(w * h)
    dq = deque()
    def push(x, y):
        i = y * w + x
        if visited[i]:
            return
        r, g, b, _a = px[x, y]
        if max(r, g, b) < 48:
            visited[i] = 1
            dq.append((x, y))
    for x in range(w):
        push(x, 0); push(x, h - 1)
    for y in range(h):
        push(0, y); push(w - 1, y)
    while dq:
        x, y = dq.popleft()
        for nx, ny in ((x+1,y),(x-1,y),(x,y+1),(x,y-1)):
            if 0 <= nx < w and 0 <= ny < h:
                push(nx, ny)
    alpha = Image.new("L", (w, h), 255)
    ap = alpha.load()
    for y in range(h):
        for x in range(w):
            if visited[y * w + x]:
                ap[x, y] = 0
    # soft 1px feather so edges don't halo
    alpha = alpha.filter(ImageFilter.GaussianBlur(1.1))
    im.putalpha(alpha)
    bbox = alpha.getbbox()
    if bbox is None:
        raise SystemExit(f"keying failed (all transparent): {src_path}")
    im = im.crop(bbox)
    return im

def square_center(im, size, pad=10):
    # fit inside size-pad*2 preserving aspect, centre on transparent square
    tw, th = im.size
    scale = min((size - 2*pad) / tw, (size - 2*pad) / th)
    nw, nh = max(1, int(tw*scale)), max(1, int(th*scale))
    small = im.resize((nw, nh), Image.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    canvas.paste(small, ((size-nw)//2, (size-nh)//2), small)
    return canvas

for name, fname in MAPPING.items():
    src = os.path.join(RAW, fname)
    if not os.path.exists(src):
        print(f"SKIP missing {src}"); continue
    keyed = key_image(src)
    keyed.save(os.path.join(OUT, f"{name}.png"))
    sq = square_center(keyed, 512, pad=12)
    sq.save(os.path.join(OUT, f"{name}-512.png"))
    print(f"OK {name}: raw {Image.open(src).size} -> trimmed {keyed.size} -> 512 square; opaque px approx")

# Arena: full-bleed, copy untouched at 1024
arena_src = os.path.join(RAW, "media-generation-arena-ash-dusk-0-a953ebdc-a8b4-4f0f-9299-a1a15fce6fb4.png")
if os.path.exists(arena_src):
    a = Image.open(arena_src).convert("RGB")
    a.resize((1024, 1024), Image.LANCZOS).save(os.path.join(OUT, "arena-ash-dusk-1024.png"))
    a.resize((512, 512), Image.LANCZOS).save(os.path.join(OUT, "arena-ash-dusk-512.png"))
    print(f"OK arena {a.size}")

# Glow radial texture (additive particles / projectiles / lights)
for nm, col in [("glow-orange", (255, 140, 40)), ("glow-blue", (90, 180, 255)),
                ("glow-green", (120, 255, 150)), ("glow-purple", (200, 120, 255)),
                ("glow-white", (255, 240, 220))]:
    s = 256
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx = cy = s // 2
    for r in range(s//2, 0, -1):
        t = r / (s//2)
        alpha = int(255 * (1-t) ** 2.2)
        d.ellipse([cx-r, cy-r, cx+r, cy+r], fill=col + (alpha,))
    img.save(os.path.join(OUT, f"{nm}.png"))
    print(f"OK {nm}")

# Gem pickup: small faceted diamond with glow halo baked in
for nm, col in [("gem-ember", (255, 120, 30)), ("gem-frost", (90, 200, 255)), ("gem-life", (80, 255, 140))]:
    s = 128
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([8, 8, s-8, s-8], fill=col + (60,))
    d.polygon([(64, 18), (100, 58), (64, 110), (28, 58)], fill=col + (255,))
    d.polygon([(64, 18), (100, 58), (64, 58)], fill=(255, 255, 255, 140))
    d.polygon([(28, 58), (64, 58), (64, 110)], fill=(0, 0, 0, 70))
    img.save(os.path.join(OUT, f"{nm}.png"))
    print(f"OK {nm}")

# Contact sheet on dark backdrop
names = list(MAPPING.keys())
cols = 3
cell = 340
rows = (len(names) + cols - 1) // cols
sheet = Image.new("RGB", (cols*cell, rows*(cell+30)), (24, 18, 14))
from PIL import ImageFont
try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 20)
except Exception:
    font = ImageFont.load_default()
sd = ImageDraw.Draw(sheet)
for i, nm in enumerate(names):
    p = os.path.join(OUT, f"{nm}-512.png")
    if not os.path.exists(p):
        continue
    im = Image.open(p).convert("RGBA").resize((300, 300), Image.LANCZOS)
    x, y = (i % cols)*cell + 20, (i // cols)*(cell+30) + 5
    sheet.paste(im, (x, y), im)
    sd.text((x, y+305), nm, fill=(255, 220, 170), font=font)
sheet.save(os.path.join(ROOT, "qa", "sprite-sheet.png"))
print(f"OK contact sheet {sheet.size} -> qa/sprite-sheet.png")
