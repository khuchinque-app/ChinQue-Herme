---
name: web-search-plus
description: "Enhanced web search using multi-provider engine + Hermes built-in Firecrawl (Nous subscription). Use when user asks for web search, research, or content extraction."
version: 1.0.0
author: vandaidr/hermes
metadata:
  hermes:
    tags: [web, search, research, firecrawl, multi-provider]
    related_skills: [content-discovery]
---

# Web Search Plus

Hermes has two web search paths available on this system.

## Path 1: Built-in (Firecrawl — Nous Subscription) — ✅ Active

No setup needed. The `web_search` and `web_extract` tools already use Firecrawl
backed by your Nous subscription. Use them directly:

```
web_search(query="your search query", limit=5)
web_extract(urls=["https://example.com"])
```

This is the default and requires no API key.

## Path 2: Multi-Provider Plugin (web-search-plus) — ⚡ Requires API Key

A Hermes plugin at `~/.hermes/plugins/web-search-plus/` provides:
- `web_search_plus` — search with 14 providers
- `web_extract_plus` — URL content extraction

To activate, add at least one API key to `~/.hermes/.env`:

| Provider | Env Var | Free Tier? | Register |
|----------|---------|-----------|----------|
| Serper | `SERPER_API_KEY` | ✅ 2,500 free/mo | serper.dev |
| Brave | `BRAVE_API_KEY` | ✅ 2,000 free/mo | brave.com/search |
| Tavily | `TAVILY_API_KEY` | ✅ 1,000 free/mo | tavily.com |
| You.com | `YOU_API_KEY` | ✅ 20 free queries/mo | api.you.com |
| Linkup | `LINKUP_API_KEY` | ✅ €5 free credit | linkup.so |

Once configured, enable the plugin's tools via:
```bash
hermes tools enable web_search_plus
```

## Usage

Default (Firecrawl, no config needed):
```bash
web_search(query="...")
web_extract(urls=["..."])
```

Multi-provider (after API key setup):
```bash
# Via the plugin's search.py directly
python ~/.hermes/plugins/web-search-plus/search.py --query "..." --quality-report

# Or use the built-in setup wizard
python ~/.hermes/plugins/web-search-plus/setup.py setup
python ~/.hermes/plugins/web-search-plus/setup.py status
```

## Verification

```bash
# Test built-in Firecrawl search
web_search(query="test hermes agent") should return results

# Check plugin status
python ~/.hermes/plugins/web-search-plus/setup.py status
```
