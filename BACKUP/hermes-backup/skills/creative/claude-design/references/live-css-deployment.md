# Live CSS Deployment — Replacing Styles on Existing PHP Projects

Date: 2026-07-02
Project: Tittil storefront (tittil.cloud/tittil/)
Framework: PHP restaurant ordering system

## Context

User asked to redesign their live Tittil restaurant storefront using the
Food Delivery Mobile App Figma design (file 1024793417351086962) as
inspiration, with a green → silver → white gradient color scheme.

## Workflow

### 1. Inspect the live site

```bash
curl -s "https://domain.com/tittil/" | head -50
```

Extract: HTML structure, CSS class names, JS function names, variable names.
The redesign MUST use the same HTML classes so JS continues to work.

### 2. Read the existing CSS

```bash
curl -s "https://domain.com/tittil/assets/style.css"
```

Note all class names, CSS variables, breakpoints. The redesign replaces
values, not structure.

### 3. Find local project files

Search the user's home directory for the project:

```bash
find /home/khuchinque -name "style.css" -path "*/tittil/*"
```

Common location pattern: `/home/khuchinque/barang-pindahan/restaurat-ordering-php/`

### 4. Create the redesign CSS

- Keep ALL the same class names and HTML structure
- Change only colors, gradients, shadows, fonts, animations
- Use CSS custom properties (`:root` variables) for easy future changes
- Keep responsive breakpoints identical

### 5. Backup before replacing

```bash
cp /path/to/style.css /path/to/style.css.bak
```

### 6. Handle root-owned files

Check ownership first:

```bash
ls -la /path/to/style.css
# If root:root, use sudo:
sudo cp /path/to/new-style.css /path/to/style.css
```

### 7. Verify deployment

```bash
# Confirm file was written correctly
head -5 /path/to/style.css

# Confirm live site serves the new CSS
curl -s "https://domain.com/tittil/assets/style.css" | head -5

# Optional: extract live HTML to verify classes still match
curl -s "https://domain.com/tittil/" | grep -o 'class="[^"]*"' | sort -u
```

## Key Caveats

- **Do NOT change HTML classes** unless the user explicitly asks — JS depends on them
- **Do NOT remove CSS variables** the HTML references — check `var(--xxx)` usage in the old CSS first
- **Root ownership** is common in production PHP deployments — always check with `ls -la`
- **Backup is mandatory** — one `sudo cp` mistake and the site is down

## Color Scheme Example (Green → Silver → White)

```css
:root {
  --green-dark: #047857;
  --green: #059669;
  --green-mid: #10B981;
  --green-light: #6EE7B7;
  --green-pale: #D1FAE5;
  --silver: #D1D5DB;
  --silver-light: #E5E7EB;
  --silver-pale: #F3F4F6;
  --white: #FFFFFF;
  --off-white: #F9FBF9;
}
```

Use a gradient for header/hero:
```css
--green-grad: linear-gradient(135deg, var(--green-dark) 0%, var(--green) 40%, var(--silver) 85%, var(--white) 100%);
```
