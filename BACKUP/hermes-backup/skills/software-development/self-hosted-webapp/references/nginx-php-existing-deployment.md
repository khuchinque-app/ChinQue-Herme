# Working with Existing nginx + PHP Deployments

## Use case
User has a live site at `tittil.cloud` served by nginx reverse-proxying to a PHP dev server. They ask you to modify pages under a subpath (e.g. `/aseng/`). You must find the existing files, edit them, and verify — not build from scratch.

## Step 1: Find the nginx config

```bash
# Find which nginx site block serves the domain
grep -r "domain.com" /etc/nginx/sites-enabled/

# Read the config
cat /etc/nginx/sites-available/domain
```

Common patterns:
- **Reverse proxy**: `proxy_pass http://127.0.0.1:PORT;` — the actual app runs on that port
- **Static root**: `root /path/to/docroot;` — files served directly by nginx
- **PHP-FPM**: `fastcgi_pass unix:/run/php/...` — PHP handled by FPM

## Step 2: Find the backend process

Once you know the port from the nginx config, find the process:

```bash
# Find what's listening on that port
ps aux | grep PORT
# Or
lsof -i :PORT

# Find its working directory (document root)
readlink /proc/PID/cwd
```

Common setups:
- `php -S 0.0.0.0:7500 -t . router.php` — PHP built-in dev server
- `gunicorn ...` — Python/Flask
- `node server.js` — Node.js

## Step 3: Locate existing files for the subpath

```bash
# Check if the subpath directory already exists
ls -la /path/to/docroot/aseng/

# If it exists, READ the existing files — do NOT overwrite them
# If the user has both index.html and index.php, they're likely identical
```

## Step 4: THE GOLDEN RULE — MODIFY, DON'T REBUILD

**This is the most important rule.** When the user has an existing site with working files:

> **DO NOT** create a new replacement page from scratch.
> **DO NOT** build a parallel version in a different directory.
> **EDIT** the existing files in place.

The user's existing site may have:
- Working JavaScript (cart, search, chat)
- Real menu data loaded dynamically
- Custom theme variables and CSS architecture
- Backend PHP integration

A fresh rebuild throws all of this away. The user will be (rightfully) furious.

## Step 5: Edit both copies if duplicate

If `index.html` and `index.php` are identical (check with `diff`):

```bash
diff index.html index.php
# If no output, they're identical — edit index.html, then cp to index.php
```

```bash
cp index.html index.php
```

## Step 6: Verify live

```bash
# Check key changes are live
curl -s https://domain.com/aseng/ | grep "expected text"
```

## Step 7: Screenshot for proof

```bash
chromium-browser --headless --no-sandbox --disable-gpu \
  --screenshot=/path/to/screenshot.png \
  --window-size=430,932 \
  https://domain.com/aseng/
```

## Common pitfalls

- **User has both index.html and index.php for the same page.** Edit both (or cp one to the other after editing). The PHP router may serve either.
- **Router.php may have custom routing logic.** Read it before deploying. If it handles directory paths by looking for `index.php` then `index.html`, both file types work.
- **Existing assets may reference different files.** If the site references `assets/logo.png` but your logo is a `.jpg`, save it with the expected name. `cp logo.jpg assets/logo.png && cp logo.jpg assets/logo.jpg`.
- **Don't kill the existing PHP/nginx process** — it's serving production traffic. Just modify the static files.
- **CSS architecture**: The site may have a split design — `style.css` (base layout) and `theme.css` (dark mode overrides). Missing base styles in `style.css` cause broken layout even when `theme.css` has working overrides. Always check BOTH files.
- **Headless Chromium screenshots from snap** must use `http://localhost:PORT/` not `file:///` — the snap sandbox blocks local file access. Output must go to a directory the user owns, not `/tmp/`.
