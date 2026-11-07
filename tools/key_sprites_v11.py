#!/usr/bin/env python3
"""ASHEN SWARM v1.1 sprite pipeline.
Slices generated grid sheets into per-frame sprites, keys black to
transparency (border flood-fill through near-black <48, 1.1px feather,
trim + centre on transparent 512 square, LANCZOS), builds gold elite
variants of the NEW enemy frames, procedural ground overlays, and
tileable terrain variants. Never edits raws in place; v1.0 files untouched.
"""
import os, sys, json, math
from collections import deque
from PIL import Image, ImageFilter, ImageDraw

ROOT = os.path.expanduser("~/workspace/ashen-swarm")
RAW = os.path.join(ROOT, "assets/raw-v11")
OUT = os.path.join(ROOT, "assets/sprites/v11")
QA = os.path.join(ROOT, "qa")
os.makedirs(OUT, exist_ok=True)
os.makedirs(QA, exist_ok=True)

def key_image(im):
    im = im.convert("RGBA")
    w, h = im.size
    px = im.load()
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
        for nx, ny in ((x+1, y), (x-1, y), (x, y+1), (x, y-1)):
            if 0 <= nx < w and 0 <= ny < h:
                push(nx, ny)
    alpha = Image.new("L", (w, h), 255)
    ap = alpha.load()
    for y in range(h):
        for x in range(w):
            if visited[y * w + x]:
                ap[x, y] = 0
    alpha = alpha.filter(ImageFilter.GaussianBlur(1.1))
    im.putalpha(alpha)
    bbox = alpha.getbbox()
    if bbox is None:
        raise SystemExit("keying failed (all transparent)")
    return im.crop(bbox), alpha

def square_center(im, size=512, pad=12):
    tw, th = im.size
    scale = min((size - 2 * pad) / tw, (size - 2 * pad) / th)
    nw, nh = max(1, int(tw * scale)), max(1, int(th * scale))
    small = im.resize((nw, nh), Image.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    canvas.paste(small, ((size - nw) // 2, (size - nh) // 2), small)
    return canvas

def opaque_frac(im512):
    a = im512.split()[3]
    px = list(a.getdata())
    return sum(1 for v in px if v > 10) / len(px)

def slice_sheet(sheet_path, rows, cols, names, inset=0.0):
    """Slice a grid sheet. inset = fraction shaved off each cell edge to
    avoid divider bleed (cells are separated by black gaps anyway)."""
    sheet = Image.open(sheet_path).convert("RGB")
    W, H = sheet.size
    cw, ch = W // cols, H // rows
    results = {}
    for idx, name in enumerate(names):
        r, c = divmod(idx, cols)
        x0 = int(c * cw + cw * inset); y0 = int(r * ch + ch * inset)
        x1 = int((c + 1) * cw - cw * inset); y1 = int((r + 1) * ch - ch * inset)
        cell = sheet.crop((x0, y0, x1, y1))
        keyed, _alpha = key_image(cell)
        sq = square_center(keyed, 512, pad=12)
        sq.save(os.path.join(OUT, f"{name}-512.png"))
        keyed.save(os.path.join(OUT, f"{name}.png"))
        results[name] = {"trimmed": keyed.size, "opaque_frac": round(opaque_frac(sq), 4)}
        print(f"OK {name}: cell {cell.size} -> trimmed {keyed.size} opaque {results[name]['opaque_frac']}")
    return results

def contact_sheet(names, out_path, cols=4, cell=340, backdrop=(24, 18, 14)):
    rows = (len(names) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * cell, rows * (cell + 30)), backdrop)
    try:
        from PIL import ImageFont
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 19)
    except Exception:
        font = ImageFont.load_default()
    sd = ImageDraw.Draw(sheet)
    for i, nm in enumerate(names):
        p = os.path.join(OUT, f"{nm}-512.png")
        if not os.path.exists(p):
            continue
        im = Image.open(p).convert("RGBA").resize((300, 300), Image.LANCZOS)
        x, y = (i % cols) * cell + 20, (i // cols) * (cell + 30) + 5
        sheet.paste(im, (x, y), im)
        sd.text((x, y + 305), nm, fill=(255, 220, 170), font=font)
    sheet.save(out_path)
    print(f"OK sheet {sheet.size} -> {out_path}")

def make_tileable(im, band=48):
    """Force edge continuity with an exact guarantee: after this,
    column 0 == column W-1 and row 0 == row H-1 (MAD 0), with the blend
    ramped to zero at `band` px so the interior is untouched. Method:
    horizontal edge-average ramp, then vertical edge-average ramp, then
    a final horizontal re-average (which provably preserves the vertical
    equality at the corner columns)."""
    im = im.convert("RGB")
    W, H = im.size
    out = im.copy()
    op = out.load()
    for y in range(H):
        avg = tuple((im.getpixel((0, y))[c] + im.getpixel((W - 1, y))[c]) // 2 for c in range(3))
        for x in range(band):
            t = 1.0 - x / band
            for rx, src in ((x, im.getpixel((x, y))), (W - 1 - x, im.getpixel((W - 1 - x, y)))):
                op[rx, y] = tuple(int(src[c] * (1 - t) + avg[c] * t) for c in range(3))
    for x in range(W):
        avg = tuple((out.getpixel((x, 0))[c] + out.getpixel((x, H - 1))[c]) // 2 for c in range(3))
        for y in range(band):
            t = 1.0 - y / band
            for ry, src in ((y, out.getpixel((x, y))), (H - 1 - y, out.getpixel((x, H - 1 - y)))):
                op[x, ry] = tuple(int(src[c] * (1 - t) + avg[c] * t) for c in range(3))
    for y in range(H):
        avg = tuple((out.getpixel((0, y))[c] + out.getpixel((W - 1, y))[c]) // 2 for c in range(3))
        op[0, y] = avg
        op[W - 1, y] = avg
    return out

def edge_check(im):
    """Mean abs diff between opposite edges (0 = perfectly continuous)."""
    im = im.convert("RGB")
    W, H = im.size
    def mad(pairs):
        return sum(abs(im.getpixel(a)[c] - im.getpixel(b)[c]) for a, b in pairs for c in range(3)) / (len(pairs) * 3)
    lr = [((0, y), (W - 1, y)) for y in range(H)]
    tb = [((x, 0), (x, H - 1)) for x in range(W)]
    return {"left_right_mad": round(mad(lr), 2), "top_bottom_mad": round(mad(tb), 2)}

def gold_variant(src512):
    """Gold elite variant of a NEW frame: shift hues toward gold, boost
    warm highlights. Deterministic PIL transform, no v1.0 art involved."""
    im = Image.open(src512).convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 10:
                continue
            # warm gold mapping: lift red, push green toward gold ratio, cut blue
            nr = min(255, int(r * 1.15 + 30))
            ng = min(255, int(g * 0.95 + 18))
            nb = min(255, int(b * 0.45))
            # keep very dark ash dark so silhouette survives
            if r < 40 and g < 40 and b < 40:
                nr, ng, nb = min(255, r + 25), min(255, g + 18), b
            px[x, y] = (nr, ng, nb, a)
    return im

if __name__ == "__main__":
    print("pipeline module loaded; run stages via --stage flags (see BUILD-LOG v1.1)")
