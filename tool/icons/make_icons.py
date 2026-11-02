"""Draws the Kadra icon (a film frame with a play triangle) and writes the
    python3 tool/icons/make_icons.py
Needs Pillow."""
from PIL import Image, ImageDraw

S = 1024


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def draw(size=S, tray=False):
    big = size * 4 if size < 256 else size
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    k = big / S
    # Diagonal gradient (deep violet → coral) in a rounded square.
    grad = Image.new('RGBA', (big, big))
    gp = grad.load()
    c1, c2 = (0x4A, 0x2C, 0xC9), (0xF0, 0x5A, 0x7E)
    for y in range(big):
        for x in range(0, big):
            gp[x, y] = lerp(c1, c2, (x + y) / (2 * big)) + (255,)
    mask = Image.new('L', (big, big), 0)
    m = int(64 * k) if not tray else int(16 * k)
    ImageDraw.Draw(mask).rounded_rectangle([m, m, big - m, big - m], radius=int(220 * k), fill=255)
    img.paste(grad, (0, 0), mask)
    d = ImageDraw.Draw(img)
    white = (255, 255, 255, 255)
    # Film frame: outline with sprocket holes on both sides.
    fx0, fy0, fx1, fy1 = 232 * k, 262 * k, 792 * k, 762 * k
    d.rounded_rectangle([fx0, fy0, fx1, fy1], radius=int(70 * k), outline=white, width=int(44 * k))
    if not tray:
        for i in range(4):
            y = (318 + i * 112) * k
            for x in (268 * k, 728 * k):
                d.rounded_rectangle([x, y, x + 28 * k, y + 52 * k], radius=int(8 * k), fill=white)
    # Play triangle.
    cx, cy = 524 * k, 512 * k
    r = 150 * k if not tray else 175 * k
    d.polygon([(cx - r * 0.75, cy - r), (cx - r * 0.75, cy + r), (cx + r * 1.05, cy)], fill=white)
    return img.resize((size, size), Image.LANCZOS) if big != size else img


app = draw()
app.resize((512, 512), Image.LANCZOS).save('assets/icons/kadra.png')
app.save('windows/runner/resources/app_icon.ico', sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
app.resize((256, 256), Image.LANCZOS).save('linux/packaging/kadra.png')
tray = draw(256, tray=True)
tray.resize((64, 64), Image.LANCZOS).save('assets/icons/tray.png')
print('ok')
