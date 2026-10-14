import math
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OX = 46
W, H = 360 + OX * 2, 326
SS = 4
TRANS = (1, 1, 1)
EDGE_BASE = (16, 11, 18)

CARD = (22 + OX, 14, 338 + OX, 318)
CARD_RADIUS = 18
ROW_X0, ROW_X1 = 36 + OX, 324 + OX
ROW_Y0, ROW_STEP, ROW_H = 72, 26, 22
ROW_ACCENTS = [(64, 214, 186), (255, 138, 168), (255, 209, 102), (255, 157, 0), (90, 170, 255)]
DIVIDER_Y = 64
START_BTN = (36 + OX, 226, 324 + OX, 258)
MODE_SEG = (36 + OX, 266, 216 + OX, 290)
SETUP_BTN = (224 + OX, 266, 324 + OX, 290)

HAIR = np.array([246, 112, 140], dtype=np.float32)
HAIR_DEEP = np.array([214, 74, 112], dtype=np.float32)
TEAL = np.array([52, 214, 184], dtype=np.float32)
SKY = np.array([86, 160, 255], dtype=np.float32)
PIN_BLACK = (13, 12, 18, 255)
PIN_FOLD = (34, 36, 46, 255)


def s(v):
    return int(round(v * SS))


def box(b):
    return [s(b[0]), s(b[1]), s(b[2]) - 1, s(b[3]) - 1]


def layer():
    return Image.new("RGBA", (W * SS, H * SS), (0, 0, 0, 0))


def vertical_gradient(stops):
    arr = np.zeros((H * SS, W * SS, 4), dtype=np.float32)
    ys = np.linspace(0, 1, H * SS)
    positions = [p for p, _ in stops]
    for c in range(4):
        arr[:, :, c] = np.interp(ys, positions, [col[c] for _, col in stops])[:, None]
    return arr


def horizontal_gradient(x0, x1, c0, c1):
    xs = np.clip((np.arange(W * SS) - s(x0)) / max(1, s(x1) - s(x0)), 0, 1)
    arr = np.zeros((H * SS, W * SS, 3), dtype=np.float32)
    for c in range(3):
        arr[:, :, c] = (c0[c] * (1 - xs) + c1[c] * xs)[None, :]
    return arr


def masked(rgb_or_rgba, mask, alpha=1.0):
    arr = np.asarray(rgb_or_rgba, dtype=np.float32)
    if arr.shape[2] == 3:
        arr = np.dstack([arr, np.full(arr.shape[:2], 255, dtype=np.float32)])
    m = np.asarray(mask, dtype=np.float32) / 255.0
    arr[:, :, 3] = arr[:, :, 3] * m * alpha
    return Image.fromarray(arr.clip(0, 255).astype(np.uint8), "RGBA")


def rounded_mask(b, radius, inset=0):
    m = Image.new("L", (W * SS, H * SS), 0)
    ImageDraw.Draw(m).rounded_rectangle(
        [s(b[0] + inset), s(b[1] + inset), s(b[2] - inset) - 1, s(b[3] - inset) - 1],
        radius=s(radius - inset), fill=255)
    return m


def ring_mask(b, radius, width):
    outer = np.asarray(rounded_mask(b, radius), dtype=np.int16)
    inner = np.asarray(rounded_mask(b, radius, width), dtype=np.int16)
    return Image.fromarray((outer - inner).clip(0, 255).astype(np.uint8), "L")


def draw_card(img):
    body = vertical_gradient([
        (0.0, (48, 24, 38, 250)),
        (0.25, (28, 17, 28, 250)),
        (1.0, (14, 12, 20, 250)),
    ])
    img.alpha_composite(masked(body, rounded_mask(CARD, CARD_RADIUS)))

    glow = layer()
    gd = ImageDraw.Draw(glow)
    gd.ellipse([s(CARD[0] - 60), s(-80), s(CARD[0] + 190), s(110)], fill=(*HAIR.astype(int), 52))
    gd.ellipse([s(CARD[2] - 150), s(210), s(CARD[2] + 60), s(390)], fill=(*TEAL.astype(int), 22))
    glow = glow.filter(ImageFilter.GaussianBlur(s(28)))
    img.alpha_composite(masked(glow, rounded_mask(CARD, CARD_RADIUS)))

    border = vertical_gradient([
        (0.0, (*HAIR, 255)),
        (0.6, (*HAIR_DEEP, 220)),
        (1.0, (*TEAL, 210)),
    ])
    img.alpha_composite(masked(border, ring_mask(CARD, CARD_RADIUS, 1.5)))

    rim = vertical_gradient([(0.0, (255, 214, 224, 70)), (0.18, (255, 214, 224, 0)), (1.0, (255, 214, 224, 0))])
    img.alpha_composite(masked(rim, ring_mask((CARD[0] + 1.5, CARD[1] + 1.5, CARD[2] - 1.5, CARD[3] - 1.5), CARD_RADIUS - 1.5, 1)))


def draw_divider(img):
    xs = np.linspace(0, 1, s(ROW_X1 - ROW_X0))
    fade = np.sin(xs * math.pi) ** 0.8
    arr = np.array(layer(), dtype=np.float32)
    y0, y1 = s(DIVIDER_Y), s(DIVIDER_Y + 1)
    for c in range(3):
        arr[y0:y1, s(ROW_X0):s(ROW_X0) + len(xs), c] = (HAIR[c] * (1 - xs) + TEAL[c] * xs)[None, :]
    arr[y0:y1, s(ROW_X0):s(ROW_X0) + len(xs), 3] = (fade * 170)[None, :]
    img.alpha_composite(Image.fromarray(arr.astype(np.uint8), "RGBA"))


def draw_rows(img):
    d = ImageDraw.Draw(img)
    for i, accent in enumerate(ROW_ACCENTS):
        y = ROW_Y0 + i * ROW_STEP
        pill = layer()
        ImageDraw.Draw(pill).rounded_rectangle(box((ROW_X0, y, ROW_X1, y + ROW_H)), radius=s(8), fill=(255, 255, 255, 12), outline=(255, 255, 255, 20), width=s(1))
        img.alpha_composite(pill)
        cx, cy = ROW_X0 + 10, y + ROW_H / 2
        halo = layer()
        ImageDraw.Draw(halo).ellipse([s(cx - 6), s(cy - 6), s(cx + 6), s(cy + 6)], fill=(*accent, 70))
        img.alpha_composite(halo.filter(ImageFilter.GaussianBlur(s(2.5))))
        d.ellipse([s(cx - 3), s(cy - 3), s(cx + 3), s(cy + 3)], fill=(*accent, 255))


def draw_start_button(img):
    b = START_BTN
    shadow = layer()
    ImageDraw.Draw(shadow).rounded_rectangle(box((b[0] + 2, b[1] + 4, b[2] - 2, b[3] + 4)), radius=s(12), fill=(*HAIR.astype(int), 70))
    img.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(s(5))))
    img.alpha_composite(masked(horizontal_gradient(b[0], b[2], HAIR, HAIR_DEEP), rounded_mask(b, 12)))
    shine = vertical_gradient([(0.0, (255, 255, 255, 0)), (b[1] / H, (255, 255, 255, 64)), ((b[1] + (b[3] - b[1]) * 0.5) / H, (255, 255, 255, 8)), (1.0, (255, 255, 255, 0))])
    img.alpha_composite(masked(shine, rounded_mask(b, 12, 1)))
    img.alpha_composite(masked(np.full((H * SS, W * SS, 3), 255, dtype=np.float32), ring_mask(b, 12, 1), 0.28))


def draw_glass_button(img, b, radius=9):
    g = layer()
    ImageDraw.Draw(g).rounded_rectangle(box(b), radius=s(radius), fill=(255, 255, 255, 14), outline=(255, 255, 255, 34), width=s(1))
    img.alpha_composite(g)


def draw_bottom_controls(img):
    draw_glass_button(img, MODE_SEG)
    mid = (MODE_SEG[0] + MODE_SEG[2]) / 2
    ImageDraw.Draw(img).line([s(mid), s(MODE_SEG[1] + 5), s(mid), s(MODE_SEG[3] - 5)], fill=(255, 255, 255, 40), width=s(1))
    draw_glass_button(img, SETUP_BTN)


def bezier(p0, p1, p2, p3, n=28):
    pts = []
    for i in range(n + 1):
        t = i / n
        a, b, c, d = (1 - t) ** 3, 3 * (1 - t) ** 2 * t, 3 * (1 - t) * t ** 2, t ** 3
        pts.append((a * p0[0] + b * p1[0] + c * p2[0] + d * p3[0], a * p0[1] + b * p1[1] + c * p2[1] + d * p3[1]))
    return pts


def fan_outline(length, half):
    top = bezier((0, -3), (-length * 0.35, -half * 0.35), (-length * 0.7, -half * 0.9), (-length, -half))
    edge = bezier((-length, -half), (-length - 5, -half * 0.35), (-length - 5, half * 0.35), (-length, half))
    bottom = bezier((-length, half), (-length * 0.7, half * 0.9), (-length * 0.35, half * 0.35), (0, 3))
    return top + edge[1:] + bottom[1:]


def teardrop(cx, cy, length, radius, n=18):
    pts = [(cx + length, cy)]
    for i in range(n + 1):
        a = math.pi / 2 + math.pi * i / n
        pts.append((cx + radius * math.cos(a), cy - radius * math.sin(a)))
    return pts


def draw_nino_pin(img, kx, ky, side, length=33, half=21, tilt=-32):
    flip = 1 if side == "left" else -1
    a = math.radians(tilt * flip)
    ca, sa = math.cos(a), math.sin(a)

    def tr(pts):
        return [(s(kx + (x * flip) * ca - y * sa), s(ky + (x * flip) * sa + y * ca)) for x, y in pts]

    tails = layer()
    td = ImageDraw.Draw(tails)
    for k, (dx, ln, phase) in enumerate([(-11, 132, 0.0), (-5, 112, 1.6)]):
        left_edge, right_edge = [], []
        for i in range(0, ln + 1, 2):
            sway = 4.5 * math.sin(i * 0.045 + phase) * flip
            w = 2.6 - 0.8 * (i / ln)
            x = kx + dx * flip + sway
            y = ky + 4 + i
            left_edge.append((s(x - w), s(y)))
            right_edge.append((s(x + w), s(y)))
        end_y = ky + 4 + ln
        notch = (s(kx + dx * flip + 4.5 * math.sin(ln * 0.045 + phase) * flip), s(end_y - 3))
        td.polygon(left_edge + [notch] + right_edge[::-1], fill=PIN_BLACK, outline=(70, 80, 96, 255), width=s(0.7))
    img.alpha_composite(tails)

    shadow = layer()
    ImageDraw.Draw(shadow).polygon([(x + s(1.5), y + s(2.5)) for x, y in tr(fan_outline(length, half))], fill=(0, 0, 0, 130))
    img.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(s(2))))

    fan_mask = Image.new("L", (W * SS, H * SS), 0)
    ImageDraw.Draw(fan_mask).polygon(tr(fan_outline(length, half)), fill=255)
    fan = layer()
    ImageDraw.Draw(fan).polygon(tr(fan_outline(length, half)), fill=PIN_BLACK)
    fd = ImageDraw.Draw(fan)
    fd.line(tr([(0, 0), (-length - 3, 0)]), fill=PIN_FOLD, width=s(1.2))
    for frac in (-0.55, 0.55):
        fd.line(tr([(0, frac * 3), (-length - 2, frac * half * 0.95)]), fill=(26, 27, 36, 255), width=s(0.8))

    teeth = layer()
    tdraw = ImageDraw.Draw(teeth)
    count = 8
    for i in range(count):
        t = (i + 0.5) / count
        cy = -half * 1.02 + t * half * 2.04
        edge_x = -length - 4.2 * (1 - (2 * t - 1) ** 2)
        tooth_len = 8.5 if i % 2 == 0 else 6.5
        col = TEAL * (1 - t) + SKY * t
        poly = teardrop(edge_x + 3.6, cy, tooth_len, 1.9)
        tdraw.polygon(tr(poly), fill=(*col.astype(int), 255))
    fan.alpha_composite(masked(teeth, fan_mask))
    outline = tr(fan_outline(length, half))
    ImageDraw.Draw(fan).line(outline + [outline[0]], fill=(92, 104, 122, 255), width=s(0.9), joint="curve")
    img.alpha_composite(fan)

    d = ImageDraw.Draw(img)
    knot = tr([(-2.5, -5), (3, -4), (3, 4), (-2.5, 5)])
    d.polygon(knot, fill=PIN_FOLD)
    for spread in (-1, 1):
        ant = bezier((0, -4), (2 * flip * 0 + 3, -12), (6 + spread * 3, -18), (2 + spread * 6, -24), 16)
        pts = tr(ant)
        d.line(pts, fill=(20, 20, 26, 255), width=s(0.9), joint="curve")
        ex, ey = pts[-1]
        d.ellipse([ex - s(1.3), ey - s(1.3), ex + s(1.3), ey + s(1.3)], fill=(20, 20, 26, 255))


def draw_sparkle(img, cx, cy, r, alpha):
    d = layer()
    pts = []
    for i in range(8):
        ang = i * math.pi / 4 - math.pi / 2
        rad = r if i % 2 == 0 else r * 0.28
        pts.append((s(cx + rad * math.cos(ang)), s(cy + rad * math.sin(ang))))
    ImageDraw.Draw(d).polygon(pts, fill=(255, 220, 228, alpha))
    img.alpha_composite(d.filter(ImageFilter.GaussianBlur(s(0.6))))
    img.alpha_composite(d)


def flatten(img):
    small = img.resize((W, H), Image.Resampling.LANCZOS)
    arr = np.asarray(small, dtype=np.float32)
    alpha = arr[:, :, 3:4] / 255.0
    rgb = arr[:, :, :3] * alpha + np.array(EDGE_BASE, dtype=np.float32) * (1 - alpha)
    out = np.where(alpha >= 0.45, rgb, np.array(TRANS, dtype=np.float32)).round().astype(np.uint8)
    keyed = (out == np.array(TRANS, dtype=np.uint8)).all(axis=2) & (alpha[:, :, 0] >= 0.45)
    out[keyed] = (2, 2, 2)
    return Image.fromarray(out, "RGB")


def generate_widget_assets():
    img = layer()
    draw_card(img)
    draw_divider(img)
    draw_rows(img)
    draw_start_button(img)
    draw_bottom_controls(img)
    draw_sparkle(img, CARD[0] + 34, 31, 4.5, 200)
    draw_sparkle(img, CARD[2] - 44, 50, 3, 150)
    draw_nino_pin(img, CARD[0] - 1, 44, "left")
    draw_nino_pin(img, CARD[2] + 1, 44, "right")
    final = flatten(img)

    assets_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")
    os.makedirs(assets_dir, exist_ok=True)
    final.save(os.path.join(assets_dir, "widget_full.bmp"), "BMP")
    final.save(os.path.join(assets_dir, "widget_full_preview.png"), "PNG")
    print(f"widget_full.bmp generated ({W}x{H})")


if __name__ == "__main__":
    generate_widget_assets()
