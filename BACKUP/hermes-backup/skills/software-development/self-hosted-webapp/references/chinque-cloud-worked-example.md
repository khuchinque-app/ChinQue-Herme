# Chinque Cloud — Worked Example

**Session:** 2026-07-01
**Goal:** Self-hosted file manager + notes app called "Chinque Cloud"
**URL:** `http://187.127.178.20:8443/`
**Login:** `admin` / `admin1`

## Architecture

Single Docker container serving a Flask app behind Gunicorn on port 8443. SQLite database. File storage mounted as Docker volume.

## Key Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Port 8443:5000, volume mounts for data persistence + live code reload |
| `Dockerfile` | Python 3.11-slim, Gunicorn with 600s timeout for 5GB uploads |
| `app/main.py` | Flask app factory, blueprint registration, auto-creates admin user |
| `app/config.py` | ALLOWED_EXTENSIONS whitelist, BLOCKED_EXTENSIONS blacklist, 5GB limit |
| `app/models.py` | User (bcrypt passwords), File (timestamped stored names), Note |
| `app/auth.py` | Login/logout/password change with flash messages |
| `app/files.py` | Browse (scandir + DB query), upload, download, mkdir, delete, folder-zip, rename, move, copy |
| `app/notes.py` | Full CRUD, sorted by updated_at desc |
| `app/templates/dashboard.html` | Sidebar + file table + notes panel, hamburger with CSS spans, dialog modal |
| `app/static/css/style.css` | 13.8KB dark theme, Google Drive-style layout, mobile breakpoint at 768px |
| `app/static/js/app.js` | Async browse/render, touch+click events, drag-drop upload, notes |

## UFW Rules
```
22/tcp   ALLOW IN    # SSH
8443/tcp ALLOW IN    # Chinque Cloud
```

## Gotchas Hit
1. **Docker group** — needed `sudo usermod -aG docker khuchinque` + `sg docker` for current session
2. **Python module cache** — new Flask routes need `docker compose restart`, CSS/JS don't
3. **Mobile hamburger** — `☰` unicode not reliable on Android; replaced with CSS spans + `pointer-events: none`
4. **Template caching** — Jinja2 templates cached in Gunicorn prod mode; restart required after edits
5. **requirements.txt** — was written via `cat > file << 'EOF'` which failed silently; use `write_file` instead
6. **Hamburger still not clickable** — even with CSS spans, needed `pointer-events: none` on child `<span>` elements AND `button.onclick` instead of `addEventListener` for reliable Android tap handling
7. **Context menu positioning** — on mobile, must clamp `left`/`top` to viewport bounds (`Math.min(x, innerWidth - 220)`) so menu doesn't overflow screen edge
8. **Rename extension handling** — for files, strip extension from pre-filled name in modal; backend re-adds it from stored `original_name`
9. **Desktop right-click vs mobile long-press** — use `contextmenu` event (immediate) for desktop, `touchstart` + 500ms timer for mobile. Do NOT use `mousedown` timer for desktop (that makes right-click slow)
10. **`hermes config set` YAML corruption** — setting `agent.disabled_toolsets` via CLI produces broken YAML (`'[''item'']'` string literal instead of YAML list). After setting, manually verify and fix the config file
11. **Gateway + Docker backend warning** — only `terminal` tool runs inside Docker; Hermes' `read_file`/`write_file` tools still hit the host filesystem. Disable file toolsets if full isolation is needed
12. **Paste in empty area** — register `contextmenu` event on drop zone, show only Paste item (when clipboard non-null). This requires scrolling the menu items: hide download/rename/cut/copy/delete, show only paste
