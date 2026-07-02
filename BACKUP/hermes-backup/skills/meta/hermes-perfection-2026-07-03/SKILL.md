---
name: hermes-perfection-2026-07-03
description: Full Hermes system state snapshot from 2026-07-03.
version: 0.1.0
author: Hermes
metadata:
  hermes:
    tags: [Snapshot, State, Perfection, Manifest]
---

# Hermes Perfection — 2026-07-03

## System State

| Property | Value |
|----------|-------|
| Hermes Version | v0.18.0 (2026.7.1) |
| Python | 3.11.15 |
| Uptime | 14h+ gateway |
| Primary Provider | Nous (`deepseek/deepseek-v4-flash`) |
| Fallback Provider | OpenRouter (340 models available) |
| Memory | Built-in SQLite (always active). Honcho plugin installed (needs API key). |
| Terminal Backend | Local |
| Working Directory | `/home/khuchinque/hermes-pipeline` |
| Profiles | `default` (active) + `telegram2` |

## Skills Inventory

- **Total: 72 enabled, 0 disabled**
- Built-in: 31 | Local: 37 | Hub: 4 | Community (URL): 3

### Core Stack (5/5)
- `youtube-full` — YouTube transcripts
- `web-search-plus` — Multi-provider search (Firecrawl active via Nous sub)
- `grill-me` — Interview before coding
- `tdd` — Red-green-refactor TDD
- `caveman-hermes-skill` — 75% token reduction

### 3 Important Skills (Evolved)
- `honcho-memory` v1.1.1
- `hermes-self-evolution` v0.4.1
- `async-delegation-master` v1.0.0

### Builder & Debug
- `diagnose` — Disciplined debug loop
- `systematic-debugging` — 4-phase root cause
- `subagent-driven-development` — Plan → delegate → review → build
- `zero-hesitation-protocol` — Silent reasoning, instant execution
- `debug-delegation-protocol` — Subagent-first debugging
- `stack-manifest-2026-07-03-builder-master` — Stack status display

### Deprecated
- `eagle-eye-routing` v0.4.1 — replaced by async-delegation-master

## Active Toolsets

- web, browser, terminal, file, code_execution, vision, skills, **delegation**
- Disabled: video, image_gen, video_gen, x_search, tts, todo, memory, context_engine, session_search, clarify, cronjob, homeassistant, spotify, yuanbao, computer_use

## External Services

| Service | Status |
|---------|--------|
| Mission Control | ✅ Running on `:3000` |
| Ollama | `ornith:9b` (5.6GB) + `gemma:2b` (1.7GB) available |
| Containers | 8 — root1 + chynx 1-5 + telegram2-sandbox + chinque-cloud |
| Plugins | `web-search-plus` at `~/.hermes/plugins/` |
| MCP | None configured |
| Disk | 193G total, 84G used (44%), 110G free |

## Auth & Keys

- Nous: ✅ OAuth (active)
- OpenRouter: ✅ Key set (unused credits)
- Anthropic: ❌ Not set
- Firecrawl: ✅ Via Nous subscription
- OpenAI, FAL, Exa, Tavily, Browserbase: ❌ Not set

## Error Status

- `error.log` — does not exist (zero errors)
- All 72 skills enabled, 0 conflicts
- Gateway PID 209826 — stable for 14h

## Key Insights

- `delegate_task` is inherently async in v0.18+ — no background flag needed
- Fallback chain: Nous → OpenRouter (340 models)
- To add Honcho: set `HONCHO_API_KEY` in `.env`
- To add MCP: `hermes mcp add <name> --command npx --args <package>`
- To add more providers: `hermes auth add <provider>`
