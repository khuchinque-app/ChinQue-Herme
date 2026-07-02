# Brand-Swap Checklist — Restaurant Storefront Redesign

Use this when copying Tittil's design to a new brand.

## 1. Title block (exact replacement — avoid chained-replace doubling)
Replace the FULL `HTML title` element, not just the brand name string inside it.
```html
<title>FROM_BRAND — FROM_TAGLINE</title>
→
<title>TO_BRAND — TO_TAGLINE</title>
```

## 2. Hero h1 block (multi-line — whitespace sensitive)
```html
        <h1>
            <span class="hero-line">FROM_LINE_1</span>
            <span class="hero-line highlight">FROM_HIGHLIGHT</span>
        </h1>
→
        <h1>
            <span class="hero-line">TO_LINE_1</span>
            <span class="hero-line highlight">TO_HIGHLIGHT</span>
        </h1>
```
Use exact indentation from source. Best done by reading source lines around `hero-line highlight` and passing the exact block to `patch`.

## 3. Splash screen
- `splash-text`: brand name (uppercase)
- `splash-tagline`: one-liner tagline

## 4. Header logo
- `alt="FROM" → alt="TO"` on logo img
- `logo-text` span content

## 5. Hero badge text
- Replace the text inside `<span class="hero-badge-pulse"></span>` sibling span

## 6. Hero paragraph (`hero-desc`)
- Replace brand-specific description

## 7. Footer
- Copyright line: `© 2026 FROM → © 2026 TO`

## 8. Paths
- `href="/from/" → href="/to/"` (all occurrences including header link)
- `src="/from/" → src="/to/"`
- JS: `fetch('/from/api/...')` → `fetch('/to/api/...')`

## 9. JS strings (Indonesian → English)
- See `indonesian-strings.md` for full mapping. Common leak points:
  - `Keranjang kosong` → `Your cart is empty`
  - `Pesanan Terkirim! ✅` → `Order Placed! ✅`
  - `Pesanan masih kosong` → `Your cart is empty`
  - `Pesanan` → `Your Cart` / `Order`
  - `Kembali` → `Continue Browsing` / `Back`
  - `Tambah` → `Add`
  - `Hapus` → `Remove`
  - `Chat dengan` → `Chat with`
  - `Stok tidak mencukupi` → `Stock not sufficient`

## 10. Order confirmation modal
- Telegram chat link URL
- Order button CTA text

## 11. Meta description
- `<meta name="description" content="...">` → target-appropriate blurb

## 12. index.php mirror
- If `index.php` exists alongside `index.html`, **write both** identically. PHP server router serves `.php` for directory requests.
