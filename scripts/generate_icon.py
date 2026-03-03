#!/usr/bin/env python3
"""Generate Portside app icon - dark rounded square with a stylized port/network symbol."""

from PIL import Image, ImageDraw, ImageFont
import math
import os

SIZE = 1024
CENTER = SIZE // 2
OUTPUT = os.path.join(os.path.dirname(__file__), "..", "Resources", "AppIcon.png")


def draw_rounded_rect(draw, xy, radius, fill):
    x0, y0, x1, y1 = xy
    draw.rounded_rectangle(xy, radius=radius, fill=fill)


def draw_circle(draw, cx, cy, r, **kwargs):
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], **kwargs)


def draw_ring(draw, cx, cy, r, width, fill):
    draw_circle(draw, cx, cy, r, outline=fill, width=width)


def draw_line(draw, x0, y0, x1, y1, width, fill):
    draw.line([(x0, y0), (x1, y1)], fill=fill, width=width)


def main():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Background - dark navy/charcoal with slight blue tint
    bg_color = (28, 32, 42)
    corner_r = int(SIZE * 0.22)
    draw_rounded_rect(draw, [0, 0, SIZE - 1, SIZE - 1], corner_r, bg_color)

    # Subtle inner glow / lighter border
    for i in range(3):
        offset = i + 1
        alpha = 25 - i * 8
        glow_color = (60, 70, 90, alpha)
        draw.rounded_rectangle(
            [offset, offset, SIZE - 1 - offset, SIZE - 1 - offset],
            radius=corner_r - offset,
            outline=glow_color,
            width=1,
        )

    # --- Port/network symbol ---
    # Outer ring (represents the globe/network)
    ring_color = (120, 140, 170)  # muted steel blue
    accent_color = (90, 200, 160)  # teal/sea green accent
    bright_color = (200, 215, 235)  # bright nodes

    ring_cy = CENTER
    ring_r = 250

    # Outer ring
    draw_ring(draw, CENTER, ring_cy, ring_r, width=18, fill=ring_color)

    # Horizontal line through ring (equator)
    draw_line(
        draw,
        CENTER - ring_r + 10,
        ring_cy,
        CENTER + ring_r - 10,
        ring_cy,
        width=14,
        fill=ring_color,
    )

    # Vertical ellipse (longitude line)
    ellipse_w = 110
    draw.ellipse(
        [CENTER - ellipse_w, ring_cy - ring_r + 10, CENTER + ellipse_w, ring_cy + ring_r - 10],
        outline=ring_color,
        width=14,
    )

    # Accent nodes at cardinal points
    node_r = 22
    node_positions = [
        (CENTER, ring_cy - ring_r),  # top
        (CENTER, ring_cy + ring_r),  # bottom
        (CENTER - ring_r, ring_cy),  # left
        (CENTER + ring_r, ring_cy),  # right
    ]

    for nx, ny in node_positions:
        draw_circle(draw, nx, ny, node_r, fill=accent_color)
        draw_circle(draw, nx, ny, node_r - 8, fill=bright_color)

    # Center dot
    draw_circle(draw, CENTER, ring_cy, 28, fill=accent_color)
    draw_circle(draw, CENTER, ring_cy, 16, fill=bright_color)

    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    img.save(OUTPUT, "PNG")
    print(f"Saved {OUTPUT}")


if __name__ == "__main__":
    main()
