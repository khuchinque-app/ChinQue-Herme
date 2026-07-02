---
name: self-hosted-webapp
description: Build and deploy self-hosted web applications with Flask, Docker, SQLite, and dark-theme UI. Covers auth, file management, notes CRUD, file-type whitelisting, table-based UIs, mobile responsiveness, and UFW firewall setup.
version: 1.1.0
author: Hermes Agent
license: MIT
tags: [flask, docker, webapp, self-hosted, file-manager, auth, sqlite, ufw, responsive]
related_skills: [docker-container-ops, plan, design-md, popular-web-designs]
platforms: [linux]
---

# Self-Hosted Web Application Builder

Use when the user wants a self-hosted web app — file storage, note-taking tool, dashboard, or admin panel — built with Python Flask, Docker, SQLite, and a dark-theme UI.

## Architecture Pattern

```
project/
├── docker-compose.yml        # Single container, volume mount for live reload
├── Dockerfile                # Python 3.11-slim, Gunicorn
├── requirements.txt
├── .dockerignore
├── app/
│   ├── main.py               # Flask entry point + app factory
│   ├── config.py             # Config + extension whitelist
│   ├── models.py             # SQLAlchemy models
│   ├── auth.py               # Login/logout/password change blueprint
│   ├── files.py              # File CRUD + folder ops blueprint
│   ├── notes.py              # Notes CRUD blueprint (optional)
│   ├── templates/
│   │   ├── login.html
│   │   ├── dashboard.html
│   │   └── settings.html
│   └── static/
│       ├── css/style.css
│       └── js/app.js
└── data/                     # Docker volume — persists uploads + DB
    ├── uploads/
    └── db/
```

## Step-by-Step Build

### 1. Backend — Flask Structure

**main.py** — app factory with blueprint registration, DB init, and default admin user creation:

```python
from flask import Flask
from flask_login import LoginManager
from config import Config
from models import db, User

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    db.init_app(app)
    login_manager = LoginManager()
    login_manager.init_app(app)
    login_manager.login_view = 'auth.login'

    @login_manager.user_loader
    def load_user(user_id):
        return db.session.get(User, int(user_id))

    from auth import auth_bp
    from files import files_bp
    from notes import notes_bp
    app.register_blueprint(auth_bp)
    app.register_blueprint(files_bp)
    app.register_blueprint(notes_bp)

    with app.app_context():
        db.create_all()
        if not User.query.filter_by(username='admin').first():
            admin = User(username='admin')
            admin.set_password('admin1')
            db.session.add(admin)
            db.session.commit()

    return app
```

**config.py** — file type whitelist + blocklist:
```python
ALLOWED_EXTENSIONS = {'pdf', 'txt', 'jpg', 'png', 'gif', 'webp', 'svg', 'mp4', 'mov', 'html', 'js', 'css'}
BLOCKED_EXTENSIONS = {'php', 'phtml', 'php3-8', 'py', 'exe', 'bin', 'sh', 'cgi', 'pl'}
MAX_CONTENT_LENGTH = 5 * 1024 * 1024 * 1024  # 5GB
```

**models.py** — User (bcrypt passwords), File, Note:
```python
import bcrypt
class User(UserMixin, db.Model):
    def set_password(self, password):
        self.password_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
    def check_password(self, password):
        return bcrypt.checkpw(password.encode(), self.password_hash.encode())

class File(db.Model):
    filename       # stored name (timestamped)
    original_name  # user-visible name
    file_size      # BigInteger for large files
    mime_type
    folder_path    # e.g. '/Documents/Photos'
    user_id

class Note(db.Model):
    title, content, user_id, timestamps
```

### 2. File Management API

**Key endpoints:**
- `GET /api/browse?folder=/` — list files + subfolders (scandir for dirs, DB query for files), breadcrumbs, parent path
- `POST /api/mkdir` — create folder with `{"name":"...", "folder":"/"}`
- `POST /api/upload` — multipart upload, validate extension, save to disk, DB record
- `GET /api/download/<id>` — single file download
- `POST /api/download-folder` — zip entire folder and stream
- `DELETE /api/delete/<id>` — remove file record + disk file
- `POST /api/delete-folder` — `shutil.rmtree()` the folder
- `POST /api/rename` — rename file or folder. File: `{"type":"file","file_id":N,"new_name":"new"}` (strips/re-adds extension). Folder: `{"type":"folder","path":"/old","new_name":"new"}` (updates all child DB records)
- `POST /api/move` — move file/folder to another folder. Payload: `{"type":"file|folder","file_id":N|"path":"/src","destination":"/target"}`
- `POST /api/copy` — copy file/folder recursively. Same payload shape as move. Uses shutil.copy2/copytree + new DB records

**Validation pattern:**
```python
def allowed_file(filename):
    ext = filename.rsplit('.', 1)[-1].lower() if '.' in filename else ''
    if ext in Config.BLOCKED_EXTENSIONS: return False
    return ext in Config.ALLOWED_EXTENSIONS
```

### 3. Frontend — Table-Based UI (Google Drive Style)

**Layout structure:**
```
┌────────────────────────────────────────────┐
│ ☰ ☁️ Chinque Cloud   [breadcrumb]  ↑ ⬇️ 📁 │
├──────────┬─────────────────────────────────┤
│ 📁 Files │ Name           Size   Date   ⚙️ │
│ 📝 Notes │ 📄 doc.pdf    2 MB   Today  ⬇️🗑️ │
│ ⚙️ Settings│ 📁 Photos      —     Today      │
├──────────┴─────────────────────────────────┤
│ 3 files · 4.2 MB used                      │
└────────────────────────────────────────────┘
```

**Key CSS patterns:**
- `table-layout: fixed` on file table for consistent column widths
- Breadcrumbs rendered as `<span>` items with clickable segments separated by `›`
- Sidebar at 220px fixed width, hidden on mobile with hamburger toggle
- Notes panel at 320px, slides in from right
- `touch-action: manipulation` + `-webkit-tap-highlight-color: transparent` for mobile buttons
- CSS hamburger icon: 3 `<span>` elements stacked with `flex-direction: column`

**Key JS patterns:**
- Async `browse(folder)` loads folder contents + breadcrumbs
- `renderTable(folders, files)` builds table rows with clickable folders
- Each row has long-press (hold 500ms) → floating context menu with up to 6 items
- `clipboard` global variable stores cut/copy state: `{action:'cut'|'copy', type:'file'|'folder', fileId, path, name}`
- Context menu shows **Paste** item only when clipboard is non-null; Paste button text includes the item name
- Context menu calls `/api/rename`, `/api/move`, `/api/copy`, or `/api/delete` depending on action
- Rename opens a `<dialog>` modal with pre-filled name (extension stripped for files)
- `addLongPress(el, type, folderPath, fileId)` attaches dual `mousedown` + `touchstart` timers, shows context menu at touch point via `showContextMenu(e, type, folderPath, fileId)`
- Context menu is a hidden `<div>` positioned with `position: fixed` at touch coordinates, clamped to viewport bounds
- Context menu hides on click/touch outside with document-level listener
- Drag-and-drop upload on the drop zone
- Modal `<dialog>` element for folder creation + rename

**Long-press context menu implementation:**
```javascript
function addLongPress(el, type, folderPath, fileId) {
  let longPressTimer = null;
  function start(e) {
    longPressTimer = setTimeout(() => showContextMenu(e, type, folderPath, fileId), 500);
  }
  function cancel() { clearTimeout(longPressTimer); }
  el.addEventListener('mousedown', start);
  el.addEventListener('mouseup', cancel);
  el.addEventListener('touchstart', start, { passive: true });
  el.addEventListener('touchend', (e) => {
    if (triggered) e.preventDefault();
    cancel();
  });
  el.addEventListener('touchmove', cancel);
}
```

**Context menu HTML:** `<div class="context-menu" id="context-menu" hidden>` with `.context-item` children for Download, Download ZIP, Rename, Cut, Copy, Paste (shown only when clipboard is non-null), and Delete. Use `contextTarget` object to track which file/folder was long-pressed. Paste visibility toggled via `hidden` attribute.

**Context menu HTML structure (placed before the new-folder dialog):**
```html
<div class="context-menu" id="context-menu" hidden>
  <div class="context-item" id="ctx-download">⬇️ Download</div>
  <div class="context-item" id="ctx-download-folder">📦 Download ZIP</div>
  <div class="context-divider"></div>
  <div class="context-item" id="ctx-rename">✏️ Rename</div>
  <div class="context-item" id="ctx-cut">✂️ Cut</div>
  <div class="context-item" id="ctx-copy">📋 Copy</div>
  <div class="context-divider" id="ctx-paste-divider" hidden></div>
  <div class="context-item" id="ctx-paste" hidden>📌 Paste</div>
  <div class="context-divider"></div>
  <div class="context-item danger" id="ctx-delete">🗑️ Delete</div>
</div>
```

**Context menu CSS:**
```css
.context-menu {
  position: fixed; z-index: 100;
  background: var(--bg-secondary);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 6px;
  min-width: 180px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.5);
  animation: fadeIn 0.1s ease;
}
.context-item {
  padding: 10px 12px;
  border-radius: var(--radius-sm);
  font-size: 13px;
  cursor: pointer;
  transition: background 0.1s;
  user-select: none;
  -webkit-tap-highlight-color: transparent;
}
.context-item:hover { background: var(--bg-hover); }
.context-item:active { background: var(--bg-tertiary); }
.context-item.danger { color: var(--danger); }
.context-divider { height: 1px; background: var(--border); margin: 4px 0; }
@keyframes fadeIn { from { opacity: 0; transform: scale(0.95); } to { opacity: 1; transform: scale(1); } }
```

**Clipboard state management (global variable):**
```javascript
let clipboard = null; // { action: 'cut'|'copy', type: 'file'|'folder', fileId, path, name }
```

**showContextMenu — controls which items are visible:**
```javascript
function showContextMenu(e, type, folderPath, fileId) {
  contextTarget = { type, folderPath, fileId };
  document.getElementById('ctx-download').hidden = (type !== 'file');
  document.getElementById('ctx-download-folder').hidden = (type !== 'folder');
  const hasClip = clipboard !== null;
  document.getElementById('ctx-paste').hidden = !hasClip;
  document.getElementById('ctx-paste-divider').hidden = !hasClip;
  if (hasClip) document.getElementById('ctx-paste').textContent = `📌 Paste ${clipboard.name}`;
  // Position at touch/click coords, clamped to viewport
}
```

**Rename modal — strips extensions for files:**
```javascript
document.getElementById('ctx-rename')?.addEventListener('click', () => {
  const currentName = contextTarget.type === 'file'
    ? (document.querySelector(`.file-row[data-id="${contextTarget.fileId}"] .file-label`)?.textContent || '')
    : (contextTarget.folderPath?.split('/').pop() || '');
  // Strip extension for files
  if (contextTarget.type === 'file') {
    const dot = currentName.lastIndexOf('.');
    rInput.value = dot > 0 ? currentName.substring(0, dot) : currentName;
  } else {
    rInput.value = currentName;
  }
  rModal.showModal();
});
```

**Cut/Copy handler — sets clipboard then navigates:**
```javascript
document.getElementById('ctx-cut')?.addEventListener('click', () => {
  clipboard = { action: 'cut', type, fileId, path, name };
  toast(`✂️ Cut ${name} — navigate to destination and use Paste`);
  hideContextMenu();
});
```

**CSS Hamburger (reliable on all Android):**
```html
<button class="btn-icon" id="sidebar-toggle">
  <div class="hamburger"><span></span><span></span><span></span></div>
</button>
```
```css
.hamburger { display: flex; flex-direction: column; align-items: center;
  justify-content: center; gap: 3px; width: 36px; height: 36px;
  pointer-events: none; }
.hamburger span { display: block; width: 18px; height: 2px;
  background: var(--text-secondary); border-radius: 1px;
  pointer-events: none; }
```
The `pointer-events: none` on hamburger spans is critical — without it, some Android browsers intercept the tap on the `<span>` elements and never fire the button's click listener.

**Pitfall — mobile hamburger not clickable:** On some Android browsers unicode `☰` does not render as a clickable element. Replace with CSS spans + `pointer-events: none`. Add `touch-action: manipulation` to the button to eliminate 300ms tap delay. Use `button.onclick = handler` instead of `addEventListener('click', handler)` — the onclick property is more reliably invoked on mobile browsers.

**Pitfall — context menu positioning on mobile:** Position the floating context menu at the touch (`e.touches[0]`) or click (`e.clientX/Y`) coordinates. Clamp to viewport: `Math.min(x, window.innerWidth - 220)`. Keep a `contextTarget` object `{type, folderPath, fileId}` to track which file/folder invoked the menu.

**Pitfall — paste only shown when clipboard is non-null:** The Paste context item and its divider must start `hidden` and only show when `clipboard !== null`. Update the Paste button text to include the item name: `` `📌 Paste ${clipboard.name}` ``.

**Pitfall — template caching:** Flask caches Jinja2 templates in production (Gunicorn). After editing HTML templates, restart the container. Static files (CSS, JS) are served from disk and don't need a restart.

**Pitfall — context menu on empty area:** Register a `contextmenu` event listener on the drop zone that prevents default and shows only the Paste item (when clipboard is non-null). This lets users right-click/long-press in white space to paste, rather than always targeting a file/folder row.

**Pitfall — notes panel shows on load:** The notes panel `<aside>` MUST have both the HTML `hidden` attribute AND `display: none` in CSS. Some browsers don't respect `hidden` on flex containers. Use `.notes-panel[hidden] { display: none; }` as the CSS rule.

**Pitfall — `hermes config set agent.disabled_toolsets` YAML format:** The `hermes config set` command stores list values as Python string literals (`'[''item1'',''item2'']'`) which produces broken YAML. After setting, manually verify the config file and fix to proper YAML list format:
```yaml
agent:
  disabled_toolsets:
    - item1
    - item2
```

**UX preference — desktop right-click, mobile long-press:** On desktop, right-click should immediately show the context menu via the `contextmenu` event. On mobile, use `touchstart` with a 500ms timer. Do NOT use `mousedown` with a timer for desktop (that simulates long-press on desktop which is wrong). Register `contextmenu` event for desktop + `touchstart` timer for mobile.

### 4. Docker Container

**Dockerfile:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ ./app/
RUN mkdir -p /app/data/uploads /app/data/db
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2",
     "--timeout", "600", "--max-requests", "1000",
     "--chdir", "/app", "app.main:create_app()"]
```

**docker-compose.yml:**
```yaml
services:
  webapp:
    build: .
    container_name: chinque-cloud
    restart: unless-stopped
    ports:
      - "8443:5000"
    volumes:
      - ./data:/app/data       # persistent storage
      - ./app:/app/app         # live reload for development
    tmpfs:
      - /tmp
```

**Gunicorn timeout:** For large uploads (5GB), set `--timeout 600` (10 min). Combine with Flask `MAX_CONTENT_LENGTH` on the app side.

### 5. UFW Firewall

After building and testing locally, lock down the server:
```bash
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 8443/tcp comment 'Web App'
sudo ufw --force enable
sudo ufw status numbered
```

## Common Pitfalls

- **Docker permission denied:** User must be in `docker` group. Fix: `sudo usermod -aG docker $USER`, then use `sg docker -c "docker compose ..."` in the current session.
- **Flask route 404 after adding new endpoints:** Python caches imported modules. Must restart container (`docker compose restart`). Volume-mounting `./app:/app/app` does NOT auto-reload Python modules.
- **Mobile hamburger not clickable:** Likely unicode rendering issue on Android. Replace `☰` with CSS hamburger (3 `<span>` elements) WITH `pointer-events: none` on each span. Add `touch-action: manipulation` and use `button.onclick` instead of `addEventListener` for reliability.
- **Large upload timeout:** Two places to configure: Flask `MAX_CONTENT_LENGTH` in config AND Gunicorn `--timeout` seconds.
- **File extension case sensitivity:** Always normalize to lowercase with `ext.lower()`.
- **Table column overflow on mobile:** Use `table-layout: fixed` with explicit column widths. Hide less important columns (`col-date`) on small screens with media queries. When removing action buttons, flatten to single-column table with `colspan="3"` on each row.
- **requirements.txt created via heredoc may fail silently:** Use `write_file` for requirements.txt instead of `cat > file << 'EOF'` in terminal — heredocs can produce empty files when stdin is non-interactive.
- **rename modal — strip extension for files:** When opening the rename modal for a file, pre-fill the name WITHOUT the extension so the user renames the base name, not the extension. The backend re-adds the extension from the stored original_name.
- **cut/copy/paste clipboard is JS-only (not persisted):** On page refresh, clipboard state is lost. This is intentional for a single-user app — no server-side cut state needed.
- **MODIFY existing files, do NOT rebuild from scratch:** When the user has a live site with working files (JS cart, dynamic menu, chat widget, real data), editing those files in place is the only acceptable approach. Building a parallel replacement page destroys working functionality and will anger the user. Read the existing file first, then use targeted patches. Always `diff` before assuming two files are identical (e.g. `index.html` vs `index.php`).
- **Existing PHP/nginx deployments — find before you build:** When a user references a domain (`tittil.cloud/aseng`), find the nginx config first (`grep -r "domain" /etc/nginx/sites-enabled/`). The backend may be a `php -S` dev server, PHP-FPM, gunicorn, or node. Find the doc root with `readlink /proc/PID/cwd`. See `references/nginx-php-existing-deployment.md` for the full workflow.
- **Missing base CSS in existing projects:** Some sites split layout (style.css) from theme overrides (theme.css). If a component has no base styles in style.css (e.g. `.cat-bar`, `.section-header` exist only as `!important` overrides in theme.css), the layout will be broken. Add the base flex/grid/positioning to style.css, not as more overrides.
- **Authentic copy research:** When writing content for a specific business type (e.g., pempek seller, warung, restaurant), search the internet for how real sellers talk in that context before writing. Use Google search for e.g., "contoh kata kata pempek seller indonesia asli palembang jualan" to find authentic phrasing, dialect, and tone. Do not default to generic English.

## Cashier Persistence Reference

For debugging order data not persisting in PHP/SQLite cashier systems with hybrid localStorage+API architecture, see:
`references/cashier-persistence-debugging.md` — covers diagnostic steps, common bugs, the fix pattern, and verification.

## Critical Workflow: Read Before You Touch

When asked to fix an existing site (especially one with JS cart, dynamic menus, chat widgets, and real data):

**1. READ ALL THE FILES FIRST.** Not just the HTML — also the CSS, JS, PHP, and any API endpoints. Understand the architecture before making any changes.

**2. Identify the data flow.** Trace through: where is data created? Where is it saved? Where is it displayed? A missing API parameter in one function can break the entire persistence chain.

**3. Check for dual-file patterns.** If both `index.html` and `index.php` exist, they're likely identical. `diff` them, edit one, then copy to the other.

**4. Use the `data-*` attributes.** DOM elements created by JS often store data as `dataset.*` properties. Always read from `item.dataset.fieldName` not `item.querySelector('.class-name')?.textContent` — the selector approach silently returns empty strings when the class doesn't exist.

**5. Check BOTH style.css AND theme.css.** The site may split base layout (flexbox, grid, sizing) from theme overrides (colors, backgrounds, shadows). If you only look at one, you'll miss missing base styles that break the layout.

**6. Check the SQLite DB directly.** When menu item images are null, the assets may already exist on disk. Query `MenuItem.image` and cross-reference against `assets/images/` directories. Fix with targeted SQL UPDATEs by category.

## PHP Restaurant Image Wiring

When wiring food photos to a PHP/SQLite restaurant menu (items show 🍲 placeholder but photos exist on disk):

See `references/php-restaurant-image-wiring.md` for the full pattern — SQL by-category image assignment, image directory layout, and the cart footer spacing fix for sibling sites.

## Static Preview Serving

Use when serving a static HTML page (storefront, prototype, single-page app preview) to a remote user via a dev server. The user is on the same VPS but accessing from a browser — they need verified reachability.

### Workflow: verify → screenshot → deliver

**DO NOT give the user a URL until you have completed all checks.** Running a server and assuming it's reachable is the #1 failure mode.

```bash
# 1. Start the server from the correct directory
cd /path/to/project && python3 -m http.server 8888 &

# 2. Check UFW — port must be open before testing
sudo ufw status | grep 8888
# If missing: sudo ufw allow 8888/tcp comment 'preview server'

# 3. Test LOCAL access first
curl -s -o /dev/null -w "%{http_code}" http://localhost:8888/index.html

# 4. Test EXTERNAL access from the public IP
curl -s -o /dev/null -w "%{http_code}" http://[VPS_IP]:8888/index.html

# 5. Screenshot from headless browser as proof
chromium-browser --headless --no-sandbox --disable-gpu \
  --screenshot=/path/to/screenshot.png \
  --window-size=1280,900 \
  http://localhost:8888/index.html

# 6. Deliver: full URL + screenshot file (MEDIA:/path/screenshot.png)
```

**Pitfall — UFW blocks new ports:** When you start a dev server on a port not in the UFW allow list, the server binds locally but external `curl` returns `000` or connection refused. Always check `sudo ufw status` before giving the URL. Add with `sudo ufw allow PORT/tcp comment 'description'`, then reload.

**Pitfall — giving partial URLs:** Always give the full URL including IP and port: `http://187.127.178.20:8888/index.html` not just `:8888/index.html`. The user is on the same VPS but accessing from a browser, not your shell.

**Pitfall — background server on wrong directory:** Restart the server after changing working directories. `pkill -f "http.server 8888"` then re-launch from the correct directory.

**Pitfall — screenshot from file:// vs http://:** Use `http://localhost:PORT/` not `file:///path/` for the screenshot URL — Chromium snap sandbox blocks local file access.

**Pitfall — can't see what the site looks like? Install tools to see.** When the user reports a visual issue (logo wrong, layout broken, colors off) and you can't diagnose from code alone, don't keep guessing at the HTML. Install and use a headless browser to take an actual screenshot:

```bash
# Quick setup
mkdir -p /tmp/playwright && cd /tmp/playwright
npm init -y --silent 2>/dev/null
npm install playwright
node -e "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 430, height: 932 } });
  await page.goto('https://yoursite.com/path/', { waitUntil: 'networkidle' });
  await page.waitForTimeout(3000); // let splash/JS animations finish
  await page.screenshot({ path: '/tmp/screenshot.png' });
  await browser.close();
  console.log('Done');
})();
"
```

Then deliver the screenshot via `MEDIA:/tmp/screenshot.png` so the user can see what you see. If the page uses a splash screen with a fade timer, wait 3+ seconds for it.

Also use Playwright's `page.evaluate()` to inspect computed styles, DOM state, and console errors — this is faster than guessing from static file reads. Enable `hermes tools enable browser` and `hermes tools enable vision` in new sessions for built-in browser + vision tools, or use npx/npm for one-off Playwright sessions.

### Brand Asset Usage (storefronts, landings, menus)

When the user provides a brand logo/image as reference for what a business sells:

- **Use the actual image as every icon.** Replace ALL decorative SVG icons, emoji placeholders (`📞`, `🚚`, `⭐`, etc.), and generated badge artwork with the provided logo image (`<img src="assets/logo.jpg" class="icon">`). The logo is the identity — every card header, contact item, and section icon should use it.
- **Greeting:** Use short, direct phrasing matching the brand's voice. "hai customer" not "Welcome to our store dear valued customers".
- **Labels:** Be concise. "Delivery" not "Free Delivery", "Pickup" not "Free Pickup".
- **No generated badge art:** If the logo itself contains a badge/stamp (e.g. "100% ASLI TENGIRI"), display the raw image — don't re-create it as SVG text.
- **Favicon:** Copy the logo to `favicon.ico` and set `<link rel="icon" type="image/jpeg" href="assets/favicon.ico">`.

## Verification Checklist

- [ ] `docker compose build` succeeds
- [ ] `docker compose up -d` starts clean
- [ ] Login page at port 8443 loads with dark theme + JetBrains font
- [ ] Login with default admin/admin1 redirects to dashboard
- [ ] Upload a .txt file — appears in table, size/date correct
- [ ] Upload a .php file — rejected with error message
- [ ] Create folder via modal — appears in table as clickable folder
- [ ] Click folder to navigate — breadcrumbs update, parent link works
- [ ] Download folder as ZIP — downloads valid archive
- [ ] Delete file — removed from table and disk
- [ ] Long-press file — context menu shows Download / Rename / Cut / Copy / Delete
- [ ] Long-press folder — context menu shows Download ZIP / Rename / Cut / Copy / Delete
- [ ] Rename file — modal opens with extension stripped, rename works
- [ ] Cut + navigate + Paste — file moved to new folder
- [ ] Copy + navigate + Paste — file duplicated in new folder
- [ ] Notes CRUD — create, save, edit, delete via sidebar
- [ ] Settings — change password, re-login with new password
- [ ] UFW status shows only port 22 + 8443
- [ ] Mobile viewport — hamburger menu works, table scrolls, columns collapse
- [ ] **Static preview:** UFW allows the port, local + external curl returns 200, screenshot taken, full URL delivered
