"""
Script de génération des assets du widget Liquid Glass Nakano Nino (FAA Macro)
Génère widget_full.bmp avec le dégradé continu et les rubans papillons latéraux.
"""
from PIL import Image, ImageDraw, ImageFilter
import numpy as np, math, os

def generate_widget_assets():
    CARD_W, CARD_H = 280, 190
    RIBBON_W = 55
    TOTAL_W = CARD_W + RIBBON_W * 2
    TOTAL_H = CARD_H + 10

    CARD_X0 = RIBBON_W
    CARD_Y0 = 8
    CARD_X1 = CARD_X0 + CARD_W
    CARD_Y1 = CARD_Y0 + CARD_H

    NINO = (153, 102, 150)
    DARK_TOP = (54, 32, 56)       # Reflet doux violet en haut
    DARK_MID = (26, 16, 33)       # Corps verre sombre
    DARK_BOT = (18, 12, 24)       # Base verre sombre
    CYAN = (46, 229, 192)
    BORDER_TOP = (153, 102, 150)   # Couleur signature Nino #996696
    BORDER_BOT = (60, 140, 130)    # Teinte subtile cyan en bas
    TRANS = (1, 1, 1)

    SCALE = 4
    SW, SH = CARD_W * SCALE, CARD_H * SCALE
    RADIUS = 16 * SCALE

    # 1. Dégradé continu 2D sur toute la hauteur
    grad_arr = np.zeros((SH, SW, 3), dtype=np.float32)
    for y in range(SH):
        yf = y / SH
        if yf < 0.30:
            t = yf / 0.30
            blend = 0.5 * (1 - math.cos(t * math.pi))
            col = (1 - blend) * np.array(DARK_TOP) + blend * np.array(DARK_MID)
        else:
            t = (yf - 0.30) / 0.70
            blend = 0.5 * (1 - math.cos(t * math.pi))
            col = (1 - blend) * np.array(DARK_MID) + blend * np.array(DARK_BOT)
        grad_arr[y, :] = col

    grad_img = Image.fromarray(grad_arr.astype(np.uint8), mode='RGB')

    # 2. Masque arrondi de la carte
    mask = Image.new('L', (SW, SH), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, SW - 1, SH - 1], radius=RADIUS, fill=255)

    card_rgba = Image.new('RGBA', (SW, SH), (0, 0, 0, 0))
    card_rgba.paste(grad_img, (0, 0), mask)

    # 3. Liseré spéculaire discret au sommet
    rim = Image.new('RGBA', (SW, SH), (0, 0, 0, 0))
    rim_draw = ImageDraw.Draw(rim)
    rim_draw.rounded_rectangle([SCALE, SCALE, SW - 1 - SCALE, SH - 1 - SCALE], radius=RADIUS - SCALE, outline=(220, 175, 215, 110), width=SCALE)
    rim_arr = np.array(rim)
    for y in range(SH):
        factor = max(0.0, 1.0 - (y / (SH * 0.18))) ** 1.5
        rim_arr[y, :, 3] = (rim_arr[y, :, 3] * factor).astype(np.uint8)
    card_rgba = Image.alpha_composite(card_rgba, Image.fromarray(rim_arr, mode='RGBA'))

    # 4. Bordure anti-aliasée
    border = Image.new('RGBA', (SW, SH), (0, 0, 0, 0))
    b_draw = ImageDraw.Draw(border)
    b_draw.rounded_rectangle([0, 0, SW - 1, SH - 1], radius=RADIUS, outline=(255, 255, 255, 255), width=int(2.0 * SCALE))
    b_arr = np.array(border)
    for y in range(SH):
        yf = y / SH
        if yf < 0.75:
            fade = 1.0 - (yf / 0.75) * 0.4
            c = np.array(BORDER_TOP) * fade
        else:
            t = (yf - 0.75) / 0.25
            c = (1 - t) * (np.array(BORDER_TOP) * 0.6) + t * np.array(BORDER_BOT)
        mask_row = b_arr[y, :, 3] > 0
        b_arr[y, mask_row, :3] = c.astype(np.uint8)
    card_rgba = Image.alpha_composite(card_rgba, Image.fromarray(b_arr, mode='RGBA'))

    # Redimensionnement vers la taille cible
    card_final = card_rgba.resize((CARD_W, CARD_H), Image.Resampling.LANCZOS)

    # Création du canevas complet avec TransColor
    canvas = Image.new('RGB', (TOTAL_W, TOTAL_H), TRANS)
    alpha_mask = card_final.split()[3].point(lambda p: 255 if p > 80 else 0)
    canvas.paste(card_final.convert('RGB'), (CARD_X0, CARD_Y0), alpha_mask)

    # 5. Rubans papillons latéraux
    draw = ImageDraw.Draw(canvas)

    def draw_side_ribbon(draw, pin_x, pin_y, side='left'):
        flip = 1 if side == 'left' else -1
        segments = 6
        wing_len = 28
        for i in range(segments):
            angle_up = math.radians(140 + i*12) if side == 'left' else math.radians(40 - i*12)
            ex = pin_x + int(wing_len * math.cos(angle_up))
            ey = pin_y + int(wing_len * 0.6 * math.sin(angle_up)) - 3
            for t in range(-2, 3):
                draw.line([(pin_x, pin_y+t), (ex, ey+t)], fill=CYAN, width=1)
            draw.line([(pin_x, pin_y), (ex, ey)], fill=(15, 10, 20), width=1)
        
        draw.ellipse([pin_x-5, pin_y-5, pin_x+5, pin_y+5], fill=(15, 10, 20), outline=CYAN)
        draw.ellipse([pin_x-3, pin_y-3, pin_x+3, pin_y+3], fill=(25, 18, 32))
        
        streamer_len = 120
        for s_offset in [-3, 3]:
            for dy in range(streamer_len):
                sway = int(8 * math.sin(dy * 0.04) * flip)
                fade = max(0, 1 - dy / streamer_len)
                w = max(1, int(4 * fade))
                x = pin_x + s_offset * flip + sway
                y = pin_y + 8 + dy
                if y < TOTAL_H:
                    for wx in range(-w, w+1):
                        if abs(wx) == w:
                            c = tuple(int(CYAN[j] * fade * 0.5) for j in range(3))
                        else:
                            c = tuple(max(1, int(20 * fade + 5)) for _ in range(3))
                        if 0 <= x+wx < TOTAL_W:
                            px = canvas.getpixel((x+wx, y))
                            if px == TRANS:
                                draw.point((x+wx, y), fill=c)

    draw_side_ribbon(draw, CARD_X0 - 12, CARD_Y0 + 12, 'left')
    draw_side_ribbon(draw, CARD_X1 + 12, CARD_Y0 + 12, 'right')

    assets_dir = os.path.join(os.path.dirname(__file__), 'assets')
    os.makedirs(assets_dir, exist_ok=True)
    canvas.save(os.path.join(assets_dir, 'widget_full.bmp'), 'BMP')
    canvas.save(os.path.join(assets_dir, 'widget_full_preview.png'), 'PNG')
    print('Génération terminée avec succès !')

if __name__ == '__main__':
    generate_widget_assets()
