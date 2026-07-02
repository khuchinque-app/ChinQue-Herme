---
name: mcp-browser-automation
description: "Evaluate, install, and configure MCP browser automation servers for agent-guided web interaction."
version: 0.1.0
author: Hermes
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [mcp, browser, automation, playwright, browserbase, steel, puppeteer, web]
    related_skills: [dogfood, site-health-monitor, self-hosted-webapp]
---

# MCP Browser Automation

Evaluate, install, and configure MCP servers that give LLM agents browser control — clicking, typing, screenshots, navigation, and device emulation.

## What It Does NOT Do

- It does NOT attach to the user's already-open browser tab. All current MCP browser tools launch fresh browser instances.
- It does NOT replace the built-in `browser_*` toolset where available — it complements it for persistent sessions and remote/cloud browsers.

## When to Use

- User asks "can you see my browser?" or "guide me through this website"
- Need to test a site from multiple device viewports (mobile vs desktop)
- Need persistent browser sessions across multiple agent turns
- Cloud/off-VPS browsing required (stealth IP, geolocation, etc.)
- The built-in browser toolset is unavailable or insufficient

## Landscape (as of 2026-07-02)

| Server | Type | Device Emulation | Auth/API Key | Best For |
|--------|------|-----------------|-------------|----------|
| **Microsoft Playwright MCP** (`@playwright/mcp`) | Local | ✅ `--device` flag (iPhone, Pixel, Galaxy, etc.) | None | Local testing, fastest setup, free |
| **Browserbase MCP** (`@browserbasehq/mcp`) | Cloud | ✅ `--browserWidth/Height` flags | `BROWSERBASE_API_KEY` + `PROJECT_ID` | Stealth browsing, persistent sessions, production scale |
| **Steel MCP Server** (`@steel-dev/steel-mcp`) | Self-hosted Docker | ⚠️ Manual viewport config | None (self-hosted) | On-prem/air-gapped, full local control |

## Critical Finding

**No MCP server attaches to the user's existing browser session.** All launch fresh instances. To see what the user is actively viewing, use one of these instead:
- **Screenshots** pasted/uploaded by the user
- **Browser extension** streaming DOM/screenshots (not MCP-based)
- **Remote desktop/VNC** session the agent can observe

## How to Install

### Microsoft Playwright MCP (Recommended for local)
```bash
npx @playwright/mcp --help
```
In MCP client config:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp"]
    }
  }
}
```
Toggle mobile mode:
```bash
npx @playwright/mcp --device "iPhone 14"
```

### Browserbase MCP (Cloud)
Requires Browserbase account. In MCP client config:
```json
{
  "mcpServers": {
    "browserbase": {
      "command": "npx",
      "args": ["@browserbasehq/mcp", "--browserWidth", "375", "--browserHeight", "812"],
      "env": {
        "BROWSERBASE_API_KEY": "",
        "BROWSERBASE_PROJECT_ID": ""
      }
    }
  }
}
```

### Steel MCP Server (Self-hosted)
```bash
git clone https://github.com/steel-dev/steel-mcp-server.git
cd steel-mcp-server
npm install && npm run build
docker run -d -p 3000:3000 steel-browser  # or local Steel instance
```
Then point MCP client at the local server.

## Multi-Agent Integration

- Each agent can have its own browser MCP server instance
- Cloud providers (Browserbase) natively support concurrent sessions
- Local servers (Playwright/Steel) are single-session unless run behind a session manager

## Verification

```bash
# Verify Playwright MCP is reachable
curl -s http://localhost:PORT/mcp  # if using HTTP transport
# Or check MCP client connection status
```

## Pitfalls

- **"Attach to my browser" is impossible via MCP.** Set expectations immediately: MCP browser tools launch fresh instances. Ask the user to upload screenshots if they need guidance on their current view.
- **Config key format matters.** Hermes uses `plugins.enabled: ['eagle-eye']` (flat array), NOT `plugins.eagle_eye.enabled: true`. Other MCP clients have their own config schemas — always check the server's README.
- **Mobile mode is per-session.** Switching between desktop and mobile requires a new browser context, not just resizing. Use `--device` (Playwright) or restart with new dimensions (Browserbase).
- **Self-hosted Steel needs Docker.** The Steel MCP server depends on a running Steel browser instance. Without Docker or a local Steel server, it won't start.
- **Browserbase costs money.** Free tier exists but has session limits. Warn the user before enabling.

## References

- `references/mcp-browser-landscape.md` — Full comparison with install logs, version numbers, and tested commands

## Working with Playwright directly (not MCP)

When you need to visually verify a deployed site but the built-in browser tools are unavailable and setting up the full MCP server is overkill, use Playwright as a Node.js library directly.

### Quick setup (no root, no snap)
```bash
mkdir -p /tmp/playwright && cd /tmp/playwright
npm init -y --silent 2>/dev/null
npm install playwright 2>&1 | tail -1
```

### Take a mobile screenshot
```javascript
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 430, height: 932 } });
  await page.goto('https://target.site/path', { waitUntil: 'networkidle', timeout: 30000 });
  await page.screenshot({ path: '/path/to/output.png' });
  await browser.close();
})();
```

### Inspect rendered DOM state (beyond HTML source)
```javascript
const info = await page.evaluate(() => {
  const grid = document.getElementById('menu-grid');
  return {
    cardCount: grid?.querySelectorAll('.menu-card').length,
    firstCardText: grid?.querySelector('.card-name')?.textContent,
    gridCSS: getComputedStyle(grid).gridTemplateColumns,
  };
});
```

### Full-page screenshot
```javascript
await page.screenshot({ path: '/path/to/full.png', fullPage: true });
```

### Capture JS errors
```javascript
page.on('pageerror', err => console.log('JS ERROR:', err.message));
page.on('console', msg => console.log('CONSOLE:', msg.type(), msg.text()));
```

### Pitfalls for direct Playwright usage
- **Snap chromium-browser does NOT work** for headless screenshots — AppArmor sandbox restrictions block file writes. The snap produces 0-byte files silently. Always use `npm install playwright` instead.
- Always set `waitUntil: 'networkidle'` AND a post-load timeout (3s+) for SPAs or sites with splash screens.
- Set viewport to match the user's device: `{width: 430, height: 932}` for mobile, `{width: 1280, height: 720}` for desktop.
- Full-page screenshots (`fullPage: true`) capture content below the fold — crucial for menu grids, long product lists.
- Use `page.evaluate()` to check actual rendered CSS values, not just HTML source — theme overrides and JS-applied styles only show up in computed styles.
