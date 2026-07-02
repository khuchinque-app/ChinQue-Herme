---
name: website-redesign-food-delivery
description: Copy existing polished restaurant web design to sibling brand pages.
version: 0.3.0
author: Hermes
platforms: [linux]
metadata:
  hermes:
    tags: [Web, CSS, Food-Delivery, Design, Branding]
---

# Multi-Brand Food Delivery Website Redesign

Copy a polished base restaurant storefront (HTML+CSS+JS) across sibling brand subdirectories, swapping brand name, tagline, emoji, hero copy, and any brand-specific API endpoints or links while preserving the shared design system.

## When to Use

- "Redesign the aseng/p2p/bell storefront to match tittil"
- "Copy tittil's new design to the other restaurant brands"
- "Apply the forest-green theme to all sub-brand pages"
- "Unify the restaurant family design"
- "Revise/modify the aseng storefront" — modify existing, don't rebuild from scratch

## First Step — Locate Existing Code

When the user asks to modify an existing storefront (not copy to a new brand):
1. Check what's running: `ps aux | grep php` or `ss -tlnp | grep <PORT>` 
2. Read the process CWD: `readlink /proc/<PID>/cwd` — this IS the project root
3. The existing aseng storefront lives at `/home/khuchinque/barang-pindahan/restaurat-ordering-php/aseng/`
4. Served by PHP dev server on port 7500, reverse-proxied by nginx at tittil.cloud
5. `index.html` and `index.php` must stay in sync (they're identical copies)

## Preparation — When User Sends a Logo

When the user sends a logo image to use as icon across the storefront:

1. **Crop the brand mark, not the full seal.** Full circular seals with text ("PEMPEK ASENG SIHANOUKVILLE CAMBODIA", phone numbers, badge) look terrible at 36×36 or 48×48. Instead:
   - Scan the image with PIL to find the central icon element (green circle with bridge icon, leaf mark, etc.)
   - Crop a square around just that icon area (usually 120-200px from the source)
   - Make it circular with a transparent background
   - Add a thin colored border ring if it helps visibility
   - Save as 120×120 PNG
   - Save the original full logo separately (e.g. `logo-full.jpg`) for reference
2. **Set the cropped icon as both `logo.png` and `favicon.ico`**.
3. **All icon slots** in the HTML (nav, splash, cat-bar, delivery, chat, footer, etc.) reference `assets/logo.png` — no random emoji fallbacks, no SVG-generated badges.

## Prerequisites

- Source brand already has a polished `index.html` + `style.css` + `app.js` under `/<brand>/assets/`.
- PHP built-in server (`php -S 0.0.0.0:PORT router.php`) or nginx is serving each brand on a known port/path.
- `tittil.cloud` (or equivalent) domain configured with nginx reverse-proxy, SSL certs in place.
- Sibling brand directories exist at same level as source (e.g. `/aseng/`, `/p2p/`, `/bell/`).

## How to Run

1. Read the source brand's new design files with `read_file` to capture exact markup and CSS tokens.
2. Create the target brand directory if missing.
3. Copy the source files into target's `assets/` and root `index.html` via `write_file`.
4. Use regex/string replacement to swap brand identity (name, tagline, emoji, hero copy, footer, API base path if any).
5. Verify by curling `http://127.0.0.1:<port>/<target>/` and `http://127.0.0.1:<port>/<target>/assets/style.css`.

## Quick Reference

| Task | Command |
|------|---------|
| View source design | `read_file` on `/<src>/index.html`, `/<src>/assets/style.css` |
| Check target exists | `ls -la /<base>/<target>/` via `terminal` |
| Deploy new design | `write_file` to `/<target>/index.html`, `/<target>/assets/style.css`, `/<target>/assets/app.js` |
| Verify page | `curl -s http://127.0.0.1:<port>/<target>/ \| head -30` via `terminal` |
| Verify CSS | `curl -s http://127.0.0.1:<port>/<target>/assets/style.css \| wc -c` |
| Test on mobile | Browse via forwarded port on phone or use browser devtools mobile emulation |

## Procedure

### Light-theme brand-swap (copy existing light theme across brands)

1. **Confirm source design is live**
   - `curl -s http://127.0.0.1:<port>/<src>/ | head -20`
   - Check it returns the new design markup (hero section, new CSS classes like `.splash`, `.site-header`, etc.).

2. **Read source files**
   - Read `/<src>/index.html` to capture full HTML.
   - Read `/<src>/assets/style.css` to capture the design system.
   - Read `/<src>/assets/app.js` if JS needs brand-specific changes.

3. **Create target structure**
   - `mkdir -p /<base>/<target>/assets/`
   - `cp /<src>/assets/favicon.ico /<target>/assets/favicon.ico` (or use target's own)

4. **Write target `index.html`**
   - Copy source HTML as base.
   - Replace:
     - Brand name, tagline, emoji/icon, page title, hero copy, footer, Telegram links
   - Keep identical structure: splash, header, hero, toolbar, menu grid, cart drawer, chat widget, modals.

5. **Write target `assets/style.css`**
   - Copy source CSS exactly for unified family look.

6. **Write target `assets/app.js`**
   - Copy source JS, then change `RESTAURANT_SLUG` and any brand-specific strings.

7. **Restart PHP server if needed**
   - `php -S` auto-picks up changes; nginx needs `sudo systemctl reload nginx`.

8. **Verify`
   - Title, hero h1, no doubled brand names, no Indonesian leaks in JS.

9. **Commit**

### Dark-theme overlay (create `theme.css` for glassmorphism look)

Use this when the user wants a completely different visual identity from the base light theme, without touching the base CSS.

1. **Read base `index.html` and `style.css`** to understand existing class names.
2. **Create `/<brand>/assets/theme.css`** with `!important` overrides for:
   - Color palette (dark glassmorphism or other mood)
   - Card styles (radius, border, shadow)
   - Button styles (pill shape, black/amber variants)
   - Floating widget styles (squircles vs circles)
   - Bottom nav bar (mobile-only pill nav)
   - Form/drawer/modal dark surfaces
3. **Link `theme.css` in `index.html` AFTER `style.css`**:
   ```html
   <link rel="stylesheet" href="assets/style.css">
   <link rel="stylesheet" href="assets/theme.css">
   ```
4. **Add new HTML elements** (bottom-nav, new icon sets) inside `index.html`.
5. **Sync `index.html` → `index.php`** (they must be identical).
6. **Verify** with `curl` and browser dev tools.
7. **Commit**.

See `references/dark-glassmorphism-theme.md` for the exact design tokens and CSS patterns used in the aseng dark theme deployment.

## Verification

## Pitfalls

- **NEVER build a new page when the user says "revise" or "modify"** — find and edit the existing code. Building a new page when they wanted edits is a major source of frustration.
- **Emoji → brand logo replacement**: The user prefers ALL emoji icons in the storefront (🍜 🛵 🍔 🥟 🧋 🛒 👤 🎉 👋 etc.) replaced with the brand logo image as icon. Pattern:
  ```html
  <img src="assets/logo.png" alt="" style="width:20px;height:20px;border-radius:50%;object-fit:cover">
  ```
  Use consistent sizing per context (nav:36px, menu:44px, cat-bar:20px, delivery:40-48px, hero-badge-inline:16px).
- **Greeting preference**: "hai customer" — not "Hi Zesan", not "Halo", not any other variant.
- **Delivery text**: "Delivery" not "Free Delivery" — the user explicitly wants "free" removed.
- **Logo cache-busting by renaming**: When replacing logo.png with a new version, browsers cache the old file aggressively (especially on mobile). Overwriting the same filename may not work for hours. Solution: rename the file completely (logo.png -> logo-icon.png?v=2) and update ALL HTML/JS references, rather than writing to the same path. This forces every browser to fetch the fresh version as a new resource.
- **CSS base vs theme split**: Many storefronts split base layout (style.css) from theme overrides (theme.css). If a component like `.cat-bar`, `.section-header`, or `.section-more` only has styles in theme.css (as `!important` overrides) but NO base styles in style.css, it will have ZERO layout — no display, no flexbox, no sizing. Always check BOTH files and add missing base styles to style.css (display: flex, width/height, padding, gap). Theme.css handles colors/borders only.
- **Mobile hero wave gap**: The hero section often ends with an SVG wave that creates a visible white gap line between hero and delivery banner on mobile. Fix: hide wave on small viewports, overlap the delivery banner:
  ```css
  @media (max-width: 480px) {
    .hero-wave { display: none !important; }
    .delivery-banner { margin-top: -1px !important; }
  }
  ```
- **Splash screen timeout in headless screenshots**: The splash fades via JS `setTimeout(() => ..., 1800)`. When using Playwright/Chromium headless, wait 3+ seconds (`page.waitForTimeout(3000)`) before screenshotting, or the splash will still cover the content.
- **Never create non-existent brands**: If a brand name the user mentions does not exist in the database, ask before creating directories or DB records. The user may have said "delete" or "p2p/bell are not real" — respect that absolutely. Always verify `SELECT slug FROM Restaurant` before assuming a brand should exist.
- **PHP server CWD matters**: The `php -S` server must run from the same directory that holds `config.php` and `data/restaurant.db`. If the server is running from `backup/` while you are editing `restaurat-ordering-php/`, the live site will serve stale code with a stale DB. Check `readlink /proc/<PID>/cwd` to confirm the server's working directory.
- **Missing database = 500 errors on API**: If `/api/menu/categories.php` returns `HTTP 500`, the SQLite DB file is likely missing or in the wrong path. Copy `data/restaurant.db` from the live working directory, verify `DB_PATH` in `config.php` matches, and restart the PHP server from the correct directory.
- **index.php and index.html must be kept in sync**: `router.php` serves `index.php` for directory requests. If you update `index.html` but not `index.php`, the old PHP file (with old markup, old CSS links, old JS strings) will still be served to browsers. Write both identically or hardlink them.
- **CSS caching flies under the radar**: Browsers cache CSS aggressively. A new `theme.css` file may not load if the old `style.css` is cached. Append cache-busting query strings (`?v=2`, `?v=3`) or rename files. Verify new CSS is actually served: `curl -s .../assets/theme.css | head -3`.
- **Hero copy must use authentic local language**: For Indonesian food businesses (pempek, etc.), generic English hero copy ("Asian Vibes", "Experience the taste of tradition") feels wrong. Instead, research how real street vendors talk and use:
  - Palembang dialect: "wong kito galo", "pempek kito"
  - Authentic food-seller phrases: "dijamin merem melek!", "ikannya berasa banget di lidah"
  - Direct references: "cuko hitam kental — pedes, manis, asam, seger"
  - Emphasize authenticity: "resep turun-temurun", "tanpa pengawet, tanpa galau"
  - Call to action in Indonesian: "langsung goreng, langsung kirim"
  Search the web for real pempek seller copywriting examples before writing.
- **Verify external access before giving URL**: Never hand the user a URL until you've confirmed it actually works:
  1. `sudo ufw status | grep <PORT>` — add rule if missing (`sudo ufw allow <PORT>/tcp`)
  2. `curl -s -o /dev/null -w "%{http_code}" http://localhost:<PORT>/<path>` — local check
  3. `curl -s -o /dev/null -w "%{http_code}" http://<PUBLIC_IP>:<PORT>/<path>` — external check
  4. Take a real browser screenshot (Playwright headless) to visually verify
  5. THEN deliver the URL + screenshot together
- **Install tools when unable to see**: If you can't visually inspect a page (missing browser/vision tools):
  - `hermes tools enable vision && hermes tools enable browser` — enable toolsets
  - `cd /tmp && npm init -y && npm install playwright && npx playwright install chromium` — install Playwright locally
  - Use Playwright Node.js API to take screenshots, read DOM, check console errors
- **Missing assets**: If source uses `assets/logo.png` or `assets/favicon.ico`, ensure target has them or the `onerror` fallbacks in HTML will hide them.
- **Absolute paths in JS**: If `app.js` has hardcoded `fetch('/tittil/api/...')`, change to `fetch('/<target>/api/...')`.
- **Nginx config**: If brands are served on separate subdomains (e.g. `aseng.cloud`), you need a new nginx server block + cert. If served as subpaths under same domain (`tittil.cloud/aseng/`), the existing config works.
- **Router bites**: `router.php` may route `/aseng/` correctly but fail on `/aseng` without trailing slash. Ensure links use trailing slashes.
- **PHP server already running**: Check `ss -tlnp | grep 7500` — if a server is already on the port, new files are served automatically.
- **Title double-duplicate from chained replaces**: If the source `<title>` already contains the brand name (e.g. `<title>Tittil — Pempek ...</title>`), replacing `Tittil → P2P` on the full file will also hit the title text, AND a separate title-template replace may compound it into `<title>P2P — P2P — ...</title>`. Replace the exact `<title>...</title>` snippet as a whole, not the brand token alone inside it.
- **Multi-line hero h1 needs exact block replacement**: The hero h1 often uses nested `<span class="hero-line">...</span>` blocks across multiple lines. A simple `html.replace("Pempek &<br>You'll Crave", "Street Food<br>Done Right")` fails because the actual source has whitespace/newlines between elements. Use exact multi-line string matching (including indentation) or read+rewrite the title block with a targeted snippet replacement.
- **JS language strings**: The copied `app.js` may contain Indonesian strings (`Keranjang kosong`, `Pesanan Terkirim! ✅`, `Kembali`, `Tambah`, `Hapus`, `Stok`) even when the HTML is English. Scan the JS for these after deployment and translate or they will leak into the UI. See `references/brand-swap-checklist.md` for the common Indonesian→English mapping.
- **index.php stale content**: If the source uses `index.php` alongside `index.html`, the PHP file is what `router.php` actually serves for directory requests. Always write both `index.html` AND `index.php`, or delete the old `.php` first, or the old design will still be served.

## Verification

```bash
# 1. Title
curl -s http://127.0.0.1:7500/<target>/ | grep -oP '(?<=<title>).*?(?=</title>)'
# Expected: "<Target> — <Tagline>" (NOT doubled like "P2P — P2P — ...")

# 2. Hero h1
curl -s http://127.0.0.1:7500/<target>/ | grep -oP 'class="hero-line highlight"\s*\u003e\s*\K[^<]+'
# Expected: new tagline highlight text (e.g. "Done Right", not "Indonesian Food")

# 3. No leaked Indonesian strings in app.js
curl -s http://127.0.0.1:7500/<target>/assets/app.js | grep -ciE "Keranjang|Pesanan|Hapus|Tambah|Kembali|Kosongkan|Stok tidak mencukupi|Catatan|Instruksi"
# Expected: 0
```

## References

- `references/brand-swap-checklist.md` — text-replacement checklist (title, hero, footer, paths, JS strings, Indonesian→English dictionary)
- `references/indonesian-strings.md` — common Indonesian UI strings found in the JS and their English equivalents
