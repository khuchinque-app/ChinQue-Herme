# Static Preview Serving — Session Reference

## User workflow established in session 2026-07-02

### The correction
User tried to open `http://187.127.178.20:8888/` twice and got connection refused. Root cause: **UFW firewall blocked port 8888** — it only had rules for SSH, Hermes API, and Docker container ports.

The user explicitly stated:
> "write this! before you give me the url YOU MUST web search first! screenshot that real life then sent to me complete url and the screen shot as report. this priority 1"

And also:
> "print with full like thihttp://187.127.178.20:8888/pempek-aseng-revision.html"

### Correct sequence (what SHOULD have happened)

1. **Start server** from the correct directory:
   ```bash
   cd /home/khuchinque/hermes-pipeline/pempek-storefront
   python3 -m http.server 8888 &
   ```

2. **Check UFW** before giving URL:
   ```bash
   sudo ufw status | grep 8888
   ```
   If missing, add rule:
   ```bash
   sudo ufw allow 8888/tcp comment 'Chinque preview server'
   sudo ufw reload
   ```

3. **Verify external access**:
   ```bash
   curl -s -o /dev/null -w "%{http_code}" http://187.127.178.20:8888/index.html
   # Must return 200
   ```

4. **Screenshot in real browser**:
   ```bash
   chromium-browser --headless --no-sandbox --disable-gpu \
     --screenshot=/path/to/screenshot.png \
     --window-size=1280,900 \
     http://localhost:8888/index.html
   ```
   Note: use `http://localhost:PORT/` not `file:///` — Chromium snap sandbox blocks local file access.

5. **Deliver**:
   - Full URL: `http://187.127.178.20:8888/index.html`
   - Screenshot: `MEDIA:/path/to/screenshot.png`

### Brand asset preference (same session)

User provided a PEMPEK ASENG brand logo as the sole reference image. Corrections made:

| What I did wrong | What they wanted |
|---|---|
| Generated SVG badge art with "100% ASLI TENGIRI" text | Use the actual logo image directly — no re-creation |
| Had no icon in cards | Logo image as icon in every section (menu, delivery, contact, nav) |
| Nav link text | Keep simple: Menu, Tentang, Delivery, Pesan Sekarang |
| Greeting | "hai customer" — short, direct |
| "Free Delivery" | Just "Delivery" |

Key lesson: **when a user sends you a brand logo, use THAT image as every icon placeholder. Do not generate SVG decorations or use emoji as substitutes.**
