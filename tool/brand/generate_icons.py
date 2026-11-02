"""Generate every launcher / store / splash / notification bitmap from one
geometric definition of the Hisn al-Muslim mark.

The mark ("the luminous fortress"): an eight-pointed khatam star (the
fortress wall) drawn as a muted-gold line, a warm ivory pointed arch (the
gate / mihrab) inside it and a small point of light within the arch.
The same geometry is implemented in Dart (lib/core/widgets/brand_mark.dart)
so the in-app logo stays vector-sharp.

Usage:  python tool/brand/generate_icons.py
"""

import json
import math
import os

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")
IOS = os.path.join(ROOT, "ios", "Runner", "Assets.xcassets")
STORE = os.path.join(ROOT, "docs", "release", "store_assets")
BRAND = os.path.join(ROOT, "assets", "brand")

# Brand tokens (keep in sync with lib/app/theme/app_colors.dart).
EMERALD = (14, 77, 58)          # #0E4D3A
EMERALD_DEEP = (9, 54, 41)      # #093629
EMERALD_SOFT = (22, 96, 73)     # #166049
GOLD = (201, 168, 106)          # #C9A86A
IVORY = (247, 241, 227)         # #F7F1E3
WHITE = (255, 255, 255)

SS = 4  # supersampling factor


def star_points(cx, cy, outer, rotation=0.0):
    """Eight-pointed star made of two overlapping squares (khatam)."""
    inner = outer * math.cos(math.pi / 4) / math.cos(math.pi / 8)
    pts = []
    for k in range(16):
        r = outer if k % 2 == 0 else inner
        a = rotation - math.pi / 2 + k * math.pi / 8
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def arch_points(cx, cy, R, steps=64):
    """Pointed (two-centred) arch, relative to the star's outer radius R."""
    a = 0.30 * R          # half span
    base = cy + 0.47 * R
    spring = cy - 0.02 * R
    apex = cy - 0.50 * R
    h = spring - apex
    radius = (a * a + h * h) / (2 * a)
    left_c = (cx - a + radius, spring)
    right_c = (cx + a - radius, spring)
    a_start = math.pi
    a_end = math.atan2(apex - spring, cx - left_c[0])
    if a_end < 0:
        a_end += 2 * math.pi
    left = []
    for i in range(steps + 1):
        t = a_start + (a_end - a_start) * i / steps
        left.append((left_c[0] + radius * math.cos(t), left_c[1] + radius * math.sin(t)))
    right = [(2 * cx - x, y) for (x, y) in reversed(left)]
    del right_c
    return [(cx - a, base)] + left + right[1:] + [(cx + a, base)]


def draw_mark(draw, cx, cy, R, *, mono=None):
    """Draw the mark centred at (cx, cy) with star outer radius R (pixels)."""
    stroke = max(1, int(round(0.06 * R)))
    star = star_points(cx, cy, R)
    if mono:
        draw.line(star + [star[0]], fill=mono, width=stroke, joint="curve")
        draw.polygon(arch_points(cx, cy, R), fill=mono)
        return
    draw.polygon(star, fill=EMERALD_SOFT)
    draw.line(star + [star[0]], fill=GOLD, width=stroke, joint="curve")
    inner = star_points(cx, cy, R * 0.86)
    draw.line(inner + [inner[0]], fill=GOLD + (90,), width=max(1, stroke // 3), joint="curve")
    draw.polygon(arch_points(cx, cy, R), fill=IVORY)
    draw.polygon(star_points(cx, cy - 0.17 * R, 0.10 * R), fill=GOLD)


def radial_background(size, centre, edge):
    """Very soft radial light — the only gradient in the identity."""
    img = Image.new("RGB", (size, size), edge)
    glow = Image.new("L", (size, size), 0)
    g = ImageDraw.Draw(glow)
    g.ellipse([size * 0.1, size * 0.05, size * 0.9, size * 0.85], fill=255)
    glow = glow.filter(ImageFilter.GaussianBlur(size * 0.18))
    img.paste(Image.new("RGB", (size, size), centre), mask=glow)
    return img


def render(size, *, background=True, rounded=None, circle=False, mark_ratio=0.36,
           mono=None, transparent=False):
    big = size * SS
    if transparent or mono:
        img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    else:
        img = radial_background(big, EMERALD_SOFT, EMERALD_DEEP).convert("RGBA") if background \
            else Image.new("RGBA", (big, big), EMERALD + (255,))
    layer = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    draw_mark(ImageDraw.Draw(layer, "RGBA"), big / 2, big / 2, big * mark_ratio, mono=mono)
    img = Image.alpha_composite(img, layer)
    if rounded or circle:
        mask = Image.new("L", (big, big), 0)
        m = ImageDraw.Draw(mask)
        if circle:
            m.ellipse([0, 0, big - 1, big - 1], fill=255)
        else:
            m.rounded_rectangle([0, 0, big - 1, big - 1], radius=int(big * rounded), fill=255)
        out = Image.new("RGBA", (big, big), (0, 0, 0, 0))
        out.paste(img, mask=mask)
        img = out
    return img.resize((size, size), Image.LANCZOS)


def save(img, path, *, rgb=False):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    (img.convert("RGB") if rgb else img).save(path, optimize=True)


DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}


def android():
    for d, f in DENSITIES.items():
        legacy = int(48 * f)
        save(render(legacy, rounded=0.22), f"{RES}/mipmap-{d}/ic_launcher.png")
        save(render(legacy, circle=True), f"{RES}/mipmap-{d}/ic_launcher_round.png")
        fg = int(108 * f)
        # Adaptive layers: the mark must stay inside the 66dp safe circle.
        save(render(fg, transparent=True, mark_ratio=0.25), f"{RES}/mipmap-{d}/ic_launcher_foreground.png")
        save(render(fg, mono=WHITE, mark_ratio=0.25), f"{RES}/mipmap-{d}/ic_launcher_monochrome.png")
        # Notification icon: white silhouette, 24dp.
        save(render(int(24 * f), mono=WHITE, mark_ratio=0.46), f"{RES}/drawable-{d}/ic_stat_hisn.png")
        # Android 12+ splash icon: 288dp canvas, content within the 192dp circle.
        save(render(int(288 * f), transparent=True, mark_ratio=0.22), f"{RES}/drawable-{d}/splash_icon.png")
        # Pre-Android-12 splash bitmap (centred on the brand colour).
        save(render(int(160 * f), transparent=True, mark_ratio=0.40), f"{RES}/drawable-{d}/splash_logo.png")

    os.makedirs(f"{RES}/mipmap-anydpi-v26", exist_ok=True)
    adaptive = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
    <monochrome android:drawable="@mipmap/ic_launcher_monochrome" />
</adaptive-icon>
"""
    for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
        with open(f"{RES}/mipmap-anydpi-v26/{name}", "w", encoding="utf-8") as fh:
            fh.write(adaptive)


def ios():
    icon_dir = f"{IOS}/AppIcon.appiconset"
    with open(f"{icon_dir}/Contents.json", encoding="utf-8") as fh:
        contents = json.load(fh)
    for image in contents["images"]:
        if "filename" not in image:
            continue
        points = float(image["size"].split("x")[0])
        scale = int(image["scale"].replace("x", ""))
        px = int(round(points * scale))
        # App Store icons must be opaque and square (iOS applies the mask).
        save(render(px), f"{icon_dir}/{image['filename']}", rgb=True)
    launch = f"{IOS}/LaunchImage.imageset"
    for name, f in (("LaunchImage.png", 1), ("LaunchImage@2x.png", 2), ("LaunchImage@3x.png", 3)):
        save(render(int(160 * f), transparent=True, mark_ratio=0.40), f"{launch}/{name}")


def store_and_brand():
    save(render(512), f"{STORE}/play_store_icon_512.png", rgb=True)
    save(render(1024), f"{BRAND}/app_icon_1024.png", rgb=True)
    save(render(1024, transparent=True, mark_ratio=0.46), f"{BRAND}/mark_1024.png")
    save(render(1024, mono=EMERALD + (255,), mark_ratio=0.46), f"{BRAND}/mark_mono_emerald_1024.png")


if __name__ == "__main__":
    android()
    ios()
    store_and_brand()
    print("icons generated")
