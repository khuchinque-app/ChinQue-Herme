# Dark Glassmorphism Theme Reference

Extracted from user mockup image. Use this CSS as a drop-in `theme.css` file that overrides the light forest-green theme on aseng/tittil storefronts.

## Design Tokens

| Token | Value | Usage |
|-------|-------|-------|
| `--glass-bg` | `rgba(28, 28, 30, 0.72)` | Backdrop blur surface |
| `--glass-bg-solid` | `#1C1C1E` | Solid dark bg fallback |
| `--glass-surface` | `rgba(44, 44, 46, 0.90)` | Card surfaces |
| `--glass-border` | `rgba(255, 255, 255, 0.12)` | Card borders |
| `--glass-border-light` | `rgba(255, 255, 255, 0.06)` | Subtle dividers |
| `--accent-amber` | `#FF9F0A` | Primary CTA, price, active states |
| `--accent-amber-hover` | `#FFB340` | CTA hover |
| `--accent-coral` | `#FF453A` | Stock warnings, hearts |
| `--text-primary` | `#FFFFFF` | Headings, primary text |
| `--text-secondary` | `rgba(255,255,255,0.65)` | Body, descriptions |
| `--text-muted` | `rgba(255,255,255,0.40)` | Placeholders, hints |
| `--shadow-glass` | `0 8px 32px rgba(0,0,0,0.45)` | Card shadow |
| `--shadow-float` | `0 12px 40px rgba(0,0,0,0.55)` | Elevated elements |

## Key Layout Rules

1. **Body**: `background: #0B0B0B` — pure black page background.
2. **Header**: `backdrop-filter: blur(20px) saturate(180%)`, translucent dark, `border-bottom: 1px solid rgba(255,255,255,0.12)`.
3. **Hero**: Solid `#1C1C1E` background, Playfair Display serif headings in white, amber accent for highlight span.
4. **Cards**: `background: rgba(44,44,46,0.90)`, `border-radius: 24px`, `border: 1px solid rgba(255,255,255,0.12)`, `box-shadow: 0 8px 32px rgba(0,0,0,0.45)`.
5. **Category tabs**: Frosted glass rounded squares, `backdrop-filter: blur(12px)`, `border-radius: 14px`. Active = solid black.
6. **Add-to-cart button**: Black pill, `border-radius: 999px`, white circular `+` icon inside. `padding: 0.5rem 1rem 0.5rem 1.2rem`.
7. **Floating widgets** (cart, chat): Black squircles, `border-radius: 14–18px`, `box-shadow: 0 12px 30px rgba(0,0,0,0.35)`.
8. **Bottom nav** (mobile): Pill-shaped fixed bar at bottom, `border-radius: 999px`, 4 icon buttons: Home (highlighted), Cart, Chat, Profile.
9. **Modal / drawer**: Dark glass surface, `border-radius: 24px`, same border/shadow as cards.
10. **Form inputs**: `background: rgba(0,0,0,0.4)`, `border: 1px solid rgba(255,255,255,0.12)`, focus border = amber.

## How to Apply

```bash
# 1. Place theme.css in target brand assets/
write_file path=<brand>/assets/theme.css

# 2. Link in index.html head AFTER style.css
# <link rel="stylesheet" href="assets/style.css">
# <link rel="stylesheet" href="assets/theme.css">

# 3. Sync index.html → index.php
# cp <brand>/index.html <brand>/index.php

# 4. Verify dark theme is served
# curl -s http://127.0.0.1:7500/<brand>/ | grep theme.css
```

## Fonts Used

- **Display**: Playfair Display 600, 700, 800 (already in base theme)
- **Body**: Inter 400, 500, 600, 700 (already in base theme)
- **Optional**: Poppins 400, 500, 600, 700 for CTAs if you want to differentiate primary buttons.

## Responsive Notes

- Bottom nav only on mobile (`@media (max-width: 767px)`)
- Adjust `.float-cart`, `.chat-bubble` `bottom` to `90px` on mobile to clear the bottom nav bar.
- On desktop (`@media (min-width: 768px)`), hide `.bottom-nav`.
