# Flask/Gunicorn Web App in Docker — Deployment Reference

Pattern for running a Python Flask web application inside a Docker container
with Gunicorn, SQLite, and UFW. Built for the Chinque Cloud project.

## Container Structure

```
project/
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── app/
│   ├── main.py            # create_app() factory
│   ├── config.py          # Config class (allowed extensions, upload limit)
│   ├── auth.py            # Login/logout/password change blueprint
│   ├── files.py           # File CRUD + folder ops blueprint
│   ├── notes.py           # Notes CRUD blueprint
│   ├── models.py          # SQLAlchemy models (User, File, Note)
│   ├── templates/         # Jinja2 HTML
│   └── static/            # CSS, JS
└── data/                  # Docker volume — DB + uploads
    ├── uploads/
    └── db/
```

## File Upload Whitelist Pattern (Double Validation)

Use both an allowlist and a blocklist for defense-in-depth:

```python
ALLOWED_EXTENSIONS = {'pdf', 'txt', 'jpg', 'jpeg', 'png', 'gif', 'webp', 'svg',
                      'mp4', 'mov', 'webm', 'html', 'htm', 'js', 'css'}
BLOCKED_EXTENSIONS = {'php', 'php3', 'php4', 'php5', 'php6', 'php7', 'php8',
                      'phtml', 'py', 'pyc', 'exe', 'msi', 'bin', 'sh', 'bash',
                      'cgi', 'pl', 'pm', 'jar', 'war', 'dll', 'so', 'dmg',
                      'pkg', 'deb', 'rpm', 'apk', 'asp', 'aspx', 'jsp'}

def allowed_file(filename):
    ext = filename.rsplit('.', 1)[-1].lower() if '.' in filename else ''
    if ext in BLOCKED_EXTENSIONS:
        return False
    return ext in ALLOWED_EXTENSIONS
```

**Why double validation:** The blocklist catches dangerous types even if someone later widens the allowlist. The allowlist ensures only known-safe types get through even if the blocklist misses an extension.

## Folder Navigation API Pattern

Standard REST endpoints for folder-based file management:

```python
# GET /api/browse?folder=/path — list folder contents (folders + files)
# POST /api/mkdir — create a new folder ({name, folder})
# POST /api/upload — upload file to a folder (multipart, includes folder path)
# GET /api/download/<id> — download a single file
# POST /api/download-folder — download entire folder as ZIP
# DELETE /api/delete/<id> — delete a file
# POST /api/delete-folder — delete a folder + contents

# Breadcrumb generation:
parts = [p for p in folder.split('/') if p]
crumbs = [{'name': 'My Files', 'path': '/'}]
path_so_far = ''
for p in parts:
    path_so_far = f'{path_so_far}/{p}'
    crumbs.append({'name': p, 'path': path_so_far})

# Parent folder:
parent = '/' + '/'.join(parts[:-1]) if parts else '/'
```

## Mobile-First UI Patterns

### Cloud Storage UI Layout (Google Drive style)

```
┌──────────────────────────────────────────────┐
│ ☰ ☁️ Chinque Cloud        ↑ Upload  📁       │  ← Topbar
├──────────┬───────────────────────────────────┤
│ 📁 Files │  My Files > Folder                 │  ← Breadcrumb
│ 📝 Notes │  ┌──────────────────────────────┐  │
│ ⚙️ Settings│  │ 📁 Folder name              │  │
│ 🚪 Logout │  │ 📄 file.pdf                 │  │  ← Single-column
│          │  │ 🖼️ photo.jpg                │  │     table rows
│          │  └──────────────────────────────┘  │
├──────────┴───────────────────────────────────┤
│ 3 files · 2.4 MB used                        │
└──────────────────────────────────────────────┘
```

Key layout decisions:
- **Left sidebar** with navigation (Files, Notes, Settings, Logout) — hidden on mobile, slides in via hamburger
- **Single-column table** with colspan="3" — just file icon + name, no size/date columns on mobile
- **Breadcrumb** in topbar center (hidden on mobile)
- **".." parent row** at top of file list for navigation
- **Upload button** in topbar right
- **New Folder** button (📁) in topbar right

### Hamburger Menu (CSS-only bars)

```html
<button class="btn-icon sidebar-toggle" id="sidebar-toggle" type="button">
  <div class="hamburger"><span></span><span></span><span></span></div>
</button>
```

```css
.hamburger { pointer-events: none; }          /* Let clicks through to button */
.hamburger span { pointer-events: none; }     /* Each bar doesn't intercept */
.sidebar-toggle { touch-action: manipulation; } /* No 300ms delay */
```

**Critical: `pointer-events: none` on child spans** — without this, Android browsers intercept the tap on the `<span>` elements inside the button, and the button's `click` event never fires.

Sidebar toggle JS (reliable for both click and touch):
```javascript
sidebarToggle.onclick = function(e) {
  e.stopPropagation();
  sidebar.classList.toggle('open');
};
```

Use `onclick` (not `addEventListener`) — simpler, less prone to event duplication on mobile.

### Long-Press Context Menu

Replace hover-reveal action buttons (which don't work on touch) with a long-press context menu:

```javascript
function addLongPress(el, type, folderPath, fileId) {
  let triggered = false;
  let timer = null;

  function start(e) {
    triggered = false;
    timer = setTimeout(() => {
      triggered = true;
      showContextMenu(e, type, folderPath, fileId);
    }, 500);  // 500ms = standard long-press delay
  }
  function cancel() {
    if (timer) clearTimeout(timer);
  }

  el.addEventListener('mousedown', start);
  el.addEventListener('mouseup', cancel);
  el.addEventListener('mouseleave', cancel);
  el.addEventListener('touchstart', start, { passive: true });
  el.addEventListener('touchend', (e) => { if (triggered) e.preventDefault(); cancel(); });
  el.addEventListener('touchmove', cancel);
}
```

Context menu position clamped to viewport:
```javascript
menu.style.left = Math.min(x, window.innerWidth - 200) + 'px';
menu.style.top = Math.min(y, window.innerHeight - 150) + 'px';
```

### Mobile CSS Breakpoints

```css
@media (max-width: 768px) {
  .sidebar { display: none; }                           /* Hidden by default */
  .sidebar.open { display: flex; }                      /* Toggle on */
  .sidebar-toggle { background: var(--bg-tertiary); }   /* Visible button */
  .topbar-center { display: none; }                     /* Hide breadcrumb */
  .notes-panel { position: fixed; width: 100%; z-index: 20; }  /* Full screen */
}
```

### Common Mobile Bugs & Fixes

| Symptom | Root Cause | Fix |
|---------|-----------|-----|
| Hamburger not tappable | `<span>` children intercept touch | `pointer-events: none` on spans |
| Double menu on tap | `click` + `touchend` both fire | Use `onclick` instead of `addEventListener` |
| Long-press triggers scroll | `touchmove` not cancelled | Add `touchmove` cancel handler |
| Notes panel visible on load | HTML `hidden` attribute not respected by CSS | Add CSS `display: none` + `.notes-panel[hidden] { display: none }` |
| Inputs auto-zoom on iOS | Font size < 16px | Set `font-size: 16px` on inputs |
| 300ms tap delay | Default touch behavior | `touch-action: manipulation` |

## Session Auth with Flask-Login

```python
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required

login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'auth.login'

@login_manager.user_loader
def load_user(user_id):
    return db.session.get(User, int(user_id))

# Default admin user created on first run:
if not User.query.filter_by(username='admin').first():
    admin = User(username='admin')
    admin.set_password('admin1')
    db.session.add(admin)
    db.session.commit()
```

### Password Change Flow

```python
# POST /settings
current_password = request.form.get('current_password')
new_password = request.form.get('new_password')
confirm_password = request.form.get('confirm_password')

if not current_user.check_password(current_password):
    flash('Current password is incorrect', 'error')
elif len(new_password) < 4:
    flash('New password must be at least 4 characters', 'error')
elif new_password != confirm_password:
    flash('Passwords do not match', 'error')
else:
    current_user.set_password(new_password)
    db.session.commit()
    flash('Password changed successfully', 'success')
```

### Logout Placement

Always add a visible logout option **inside the sidebar navigation**, not just via URL:
```html
<a href="/logout" class="sidebar-item">
  <span class="sidebar-icon">🚪</span>
  <span style="color:var(--danger)">Logout</span>
</a>
```

Mobile users need explicit navigation — they can't type `/logout` in the URL bar.

### Right-Click (Desktop) + Long-Press (Mobile) Context Menu

Replace hover-reveal action buttons with a dual-input context menu system:

```javascript
function addContextMenu(el, type, folderPath, fileId) {
  // Desktop: right-click into immediate
  el.addEventListener('contextmenu', (e) => {
    e.preventDefault();
    e.stopPropagation();
    showContextMenu(e, type, folderPath, fileId);
  });
  // Mobile: long-press into 500ms delay
  let triggered = false, timer = null;
  function start(e) {
    triggered = false;
    timer = setTimeout(() => { triggered = true; showContextMenu(e, type, folderPath, fileId); }, 500);
  }
  function cancel() { if (timer) clearTimeout(timer); }
  el.addEventListener('touchstart', start, { passive: true });
  el.addEventListener('touchend', (e) => { if (triggered) e.preventDefault(); cancel(); });
  el.addEventListener('touchmove', cancel);
}
```

**No `mousedown` timer** — desktop uses `contextmenu` (right-click) directly. Mobile uses the timer. Both call `showContextMenu()`.

Context menu items by target:
```html
<!-- Files: Download | Rename | Cut | Copy | Delete -->
<!-- Folders: Download ZIP | Rename | Cut | Copy | Delete -->
<!-- Empty area: Paste (only when clipboard has content) -->
```

### Clipboard / Cut-Copy-Paste Pattern

```javascript
let clipboard = null; // { action: 'cut'|'copy', type: 'file'|'folder', fileId, path, name }
```

Backend endpoints:
```
POST /api/move   — { type, file_id|path, destination }
POST /api/copy   — { type, file_id|path, destination }
POST /api/rename — { type, file_id|path, new_name }
```

File rename auto-preserves extension by stripping it from the input:
```javascript
if (contextTarget.type === 'file') {
  const dot = currentName.lastIndexOf('.');
  rInput.value = dot > 0 ? currentName.substring(0, dot) : currentName;
}
```

Folder rename updates all child File records via SQL `LIKE` query on `folder_path`.

### Empty-Area Context Menu (Paste Target)

On right-click/long-press in empty space, show only Paste (when clipboard is non-null):
```javascript
document.getElementById('drop-zone')?.addEventListener('contextmenu', (e) => {
  if (!e.target.closest('.file-row')) {
    e.preventDefault();
    ctxDownload.hidden = true; ctxDownloadFolder.hidden = true;
    ctxRename.hidden = true; ctxCut.hidden = true; ctxCopy.hidden = true;
    ctxPaste.hidden = !clipboard; ctxPasteDivider.hidden = !clipboard;
    ctxDelete.hidden = true;
    if (clipboard) ctxPaste.textContent = `📌 Paste ${clipboard.name}`;
    // Position at click point
    menu.style.left = Math.min(e.clientX, window.innerWidth - 220) + 'px';
    menu.style.top = Math.min(e.clientY, window.innerHeight - 120) + 'px';
    menu.hidden = false;
  }
});
```

## Gunicorn Config for Large Uploads

```dockerfile
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2",
     "--timeout", "600", "--max-requests", "1000",
     "--chdir", "/app", "app.main:create_app()"]
```

| Flag | Value | Why |
|------|-------|-----|
| `--timeout` | 600 | Required for uploads >= 100MB (default 30s kills worker mid-upload) |
| `--max-requests` | 1000 | Prevents memory leak from long-running workers |
| `--workers` | 2 | Enough for personal server; 1 blocks during upload |
| `--chdir` | /app | Required when factory lives in `app/main.py` |

**Pitfall:** Gunicorn caches Jinja2 templates in production mode. Changes to `.html` files require a container restart. Static files (CSS, JS) are served directly from disk and are live-reloaded via volume mount.

## Volume Mount Strategy

```yaml
volumes:
  - ./data:/app/data     # Persistent DB + uploads (survives rebuilds)
  - ./app:/app/app       # Dev: live CSS/JS reload (no restart needed)
```

| File type | Restart needed? | Reason |
|-----------|----------------|--------|
| `.css`, `.js` | ❌ No | Served directly from filesystem |
| `.html` (Jinja2) | ✅ Yes | Gunicorn caches compiled templates |
| `.py` (routes) | ✅ Yes | Python module cache |

## UFW Rules for Web Apps

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 8443/tcp comment 'Web App'
sudo ufw --force enable
```

## Docker Permission Fix

When `docker compose` fails with "permission denied while trying to connect to the Docker API socket":

```bash
# Fix group membership
sudo usermod -aG docker $USER

# Use for current session (no re-login needed)
sg docker -c "docker compose up -d"
```

**Never use `sudo docker`** — it changes the runtime context and can break volume mounts with permission mismatches.

## Verification Checklist

- [ ] `docker compose build` succeeds
- [ ] `docker compose up -d` → container shows `Up` status
- [ ] Login page: `curl -o /dev/null -w '%{http_code}' http://localhost:<port>/login` → 200
- [ ] Login with admin/admin1 → 302 redirect to dashboard
- [ ] Dashboard: `curl -b cookies http://localhost:<port>/` → 200
- [ ] Browse API: `curl -b cookies 'http://localhost:<port>/api/browse?folder=/'` → JSON with files/folders
- [ ] Upload file: `curl -b cookies -F 'file=@test.txt' http://localhost:<port>/api/upload` → success
- [ ] Block PHP: `curl -b cookies -F 'file=@test.php' http://localhost:<port>/api/upload` → error
- [ ] Create folder: `curl -b cookies -X POST -H 'Content-Type: application/json' -d '{"name":"Test","folder":"/"}' http://localhost:<port>/api/mkdir` → success
- [ ] Static CSS: `curl -o /dev/null -w '%{http_code}' http://localhost:<port>/static/css/style.css` → 200
- [ ] Settings page: `curl -b cookies http://localhost:<port>/settings` → 200
- [ ] Password change: POST to `/settings` with old+new passwords → success
- [ ] UFW: `sudo ufw status numbered` shows only ports 22 + 8443
