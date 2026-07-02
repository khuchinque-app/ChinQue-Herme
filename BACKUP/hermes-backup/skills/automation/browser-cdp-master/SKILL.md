---
name: browser-cdp-master
description: "Control a headless Chrome via CDP using agent-browser CLI."
version: 0.1.0
author: Hermes
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Browser, CDP, Chrome, Automation, agent-browser]
    related_skills: [site-health-monitor, dogfood]
---

# Browser CDP Master

Drive a live Chrome instance through Chrome DevTools Protocol (CDP) using the `agent-browser` CLI tool. Runs headless via `--remote-debugging-port=9222`. All commands execute through the `terminal` tool — no built-in browser toolset required.

## When to Use

- "Go to this URL and tell me what it says"
- "Find the top story / search results / price"
- "Click that button and report what happens"
- "Take a screenshot of this page"
- "Fill out this form and submit it"
- The built-in `browser_*` toolset is unavailable or insufficient

## Prerequisites

- Chrome/Chromium running on CDP port 9222. Launch if not running:
  ```bash
  pkill -f chromium; pkill -f chrome
  chromium-browser --remote-debugging-port=9222 --remote-allow-origins='*' --no-sandbox --headless=new --disable-setuid-sandbox --disable-dev-shm-usage --user-data-dir=/tmp/chrome-cdp-profile https://example.com &
  ```
- `agent-browser` CLI on PATH (verify: `which agent-browser`)
- `curl` available for CDP health check

## How to Run

Verify CDP is live first:
```bash
curl -s http://localhost:9222/json/version | grep "Browser"
```
Then chain commands through `agent-browser --cdp 9222 <command>`.

## Quick Reference

| Action | Command |
|--------|---------|
| Verify CDP | `curl -s http://localhost:9222/json/version` |
| Navigate | `agent-browser --cdp 9222 open <url>` |
| Snapshot | `agent-browser --cdp 9222 snapshot -i` |
| Click | `agent-browser --cdp 9222 click @eN` |
| Fill input | `agent-browser --cdp 9222 fill @eN "text"` |
| Press key | `agent-browser --cdp 9222 press Enter` |
| Read text | `agent-browser --cdp 9222 get text @eN` |
| Get title | `agent-browser --cdp 9222 get title` |
| Get URL | `agent-browser --cdp 9222 get url` |
| Screenshot | `agent-browser --cdp 9222 screenshot` |
| Scroll | `agent-browser --cdp 9222 scroll down 500` |

## Procedure

1. **Verify CDP** — `curl -s http://localhost:9222/json/version` must return a Browser string.
2. **Navigate** — `agent-browser --cdp 9222 open <url>` loads the page.
3. **Read the page** — `agent-browser --cdp 9222 snapshot -i` lists interactive elements with `@e1`, `@e2`, etc refs.
4. **Interact** — click, fill, press keys using the `@eN` refs from snapshot.
5. **Extract content** — use `get text @eN` for element text, or `get title`/`get url` for page identity.
6. **Persist state** — track current URL, title, and last known @refs between steps. Always re-snapshot after navigation.
7. **Report** — summarize findings. For article content, extract via `get text` or fall back to `curl` + HTML stripping for full body text.

## Pitfalls

- **Chrome crashes** — relaunch with the full flags above. Container/snap environments need `--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage`.
- **ECONNREFUSED** — Chrome isn't listening. Verify with `curl http://localhost:9222/json/version`.
- **"No interactive elements"** — the page loaded but has no interactive content (blank page, PDF, image). Run `open <url>` first, then snapshot again.
- **Stale @ref** — page changed after navigation. Re-run snapshot before clicking.
- **No paragraph text in snapshot** — `snapshot -i` only shows interactive elements. Use `get text @eN` on the heading, or fall back to `curl <url> \| python3` to strip HTML for article body text.
- **Stale CDP session** — if Chrome was started without `--remote-allow-origins='*'` and `--remote-debugging-port=9222`, it won't accept CDP connections.

## Verification

```bash
curl -s http://localhost:9222/json/version | grep -q "Chrome" && echo "CDP CONNECTED" || echo "CDP FAILED"
```
