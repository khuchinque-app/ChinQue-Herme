# MCP Browser Automation Landscape — 2026-07-02

## Researched Servers

### 1. Microsoft Playwright MCP
- **Repo:** github.com/microsoft/playwright-mcp
- **Stars:** 34.6k
- **Type:** Local browser via Playwright
- **Install:** `npx @playwright/mcp`
- **Mobile:** `--device "iPhone 14"`, `--device "Pixel 7"` etc (full Playwright device list)
- **Auth:** None
- **Status:** Actively maintained, latest v0.0.77 (Jun 29 2026)
- **Best for:** Free local testing, device emulation, screenshot-based guidance

### 2. Browserbase MCP
- **Repo:** github.com/browserbase/mcp-server-browserbase
- **Stars:** 3.4k
- **Type:** Cloud headless with Stagehand automation
- **Install:** `npx @browserbasehq/mcp`
- **Mobile:** `--browserWidth 375 --browserHeight 812` (manual)
- **Auth:** `BROWSERBASE_API_KEY` + `BROWSERBASE_PROJECT_ID`
- **Model default:** Google Gemini 2.5 Flash Lite (hosts pay LLM costs)
- **Status:** Actively maintained, v3.0.0 (Mar 31 2026)
- **Best for:** Stealth IP, persistent sessions, production load

### 3. Steel MCP Server
- **Repo:** github.com/steel-dev/steel-mcp-server
- **Stars:** 47
- **Type:** Self-hosted via Docker
- **Install:** Clone + build + run Steel browser Docker
- **Mobile:** Manual viewport config via CDP
- **Auth:** None (self-hosted)
- **Status:** Last commit Feb 16 2025 (stale-ish)
- **Best for:** Air-gapped, on-prem control

## Key Finding

None attach to the user's existing browser session. All launch fresh instances. For guiding a user through their current view, require screenshots or a remote desktop stream.

## Verified Commands (tested on this VPS)

```bash
# Check if Hermes has browser tools
hermes status | grep -i browser
# Output: Browser Use [key not set], Browserbase [key not set]

# No local browser MCP toolset available natively in Hermes
```

## Multi-Agent Notes

- Browserbase natively supports concurrent sessions via its cloud API
- Playwright MCP is single-session per process; run multiple processes for multi-agent
- Steel is single-session per Docker container
