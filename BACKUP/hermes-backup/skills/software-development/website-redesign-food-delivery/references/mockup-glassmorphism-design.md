# Mockup-Accurate Glassmorphism Design Reference

Design root image placed at `tittil/asset-img/design-root.jpg`.

## Design Language

- **Background**: Warm beige `#F5F0EB` (tittil) / Pure black `#0B0B0B` (aseng)
- **Glassmorphism**: Cards at `rgba(255,255,255,0.82)` with `backdrop-filter: blur(20px)`
- **Accent**: `#FFC700` gold (tittil) / `#FF9F0A` amber (aseng)
- **Radius**: 24px cards, 999px pills, 52px category circles
- **Bottom Nav**: Pill-shaped floating frosted bar, centered

## New HTML Elements

| Element | Purpose |
|---------|---------|
| `.greeting-bar` | "Hi Zesan" greeting + profile avatar |
| `.cat-bar` | Horizontal scrollable icon circles |
| `.section-header` | "Recommended" with "See All" link |
| `.card-fav` | Heart icon overlay on menu card images |

## Implementation

1. Save design image to `tittil/asset-img/design-root.jpg`
2. Create `theme.css` overlay — never modify `style.css`
3. Add HTML elements to BOTH `index.html` AND `index.php`
4. Add `.card-fav` button to `app.js` `renderItems()` function
5. Verify: curly title, curl assets, 0 Indonesian strings
