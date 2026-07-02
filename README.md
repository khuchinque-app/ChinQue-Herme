# ChinQue Hermes — Backup Repository

Hermes Agent v0.18.0 configuration backup. Contains skills, plugins, configs, and system state snapshots.

## 2026-07-03 Perfection State

| Property | Value |
|----------|-------|
| **Hermes Version** | v0.18.0 (2026.7.1) |
| **Total Skills** | 72 enabled (31 builtin, 37 local, 4 hub, 3 URL) |
| **Primary Provider** | Nous (`deepseek/deepseek-v4-flash`) |
| **Fallback Provider** | OpenRouter (340 models) |

### 3 Important Skills
- `honcho-memory` v1.1.1 — Cross-session persistence
- `hermes-self-evolution` v0.4.1 — Auto-skill improvement pipeline
- `async-delegation-master` v1.0.0 — Non-blocking parallel subagents

### Builder & Debug Skills
- `diagnose` — Disciplined debug loop
- `systematic-debugging` — 4-phase root cause hunting
- `subagent-driven-development` — Plan → delegate → review → build
- `zero-hesitation-protocol` — Silent reasoning, instant execution
- `debug-delegation-protocol` — Subagent-first debugging
- `stack-manifest-2026-07-03-builder-master` — On-demand stack display

### Core Stack (5/5)
- `youtube-full` — YouTube transcripts via TranscriptAPI
- `web-search-plus` — Multi-provider web search (Firecrawl active)
- `grill-me` — Interview before coding
- `tdd` — Red-green-refactor test-driven dev
- `caveman-hermes-skill` — 75% token reduction mode

### Ollama
| Model | Size | Status |
|-------|------|--------|
| `ornith:9b` | 5.6 GB | Installed |
| `gemma:2b` | 1.7 GB | Installed |

### External Services
| Service | Status |
|---------|--------|
| **Mission Control** | Running on port 3000 |
| **Telegram Gateway** | Running (PID 209826) |
| **Docker Containers** | 8 active (root1, chynx 1-5, telegram2-sandbox, chinque-cloud) |

### Profiles
- `default` — Active, Chinque orchestrator
- `telegram2` — Forex trader bot

### Auth Status
| Provider | Key |
|----------|-----|
| Nous | ✅ OAuth (active) |
| OpenRouter | ✅ Key set |
| Anthropic | ❌ Not set |
| Firecrawl | ✅ Via Nous subscription |

### Error Status
Zero errors — no `error.log` exists. Gateway stable for 14h+.

---

## Backup Contents

```
BACKUP/
├── hermes-backup/       # ~/.hermes/ sync (skills, configs, plugins)
├── ollama-models.txt    # Installed Ollama models
├── ollama-config.json   # Ollama integration config
├── hermes-config-current.txt  # Full Hermes config dump
├── pi-models.json       # Pi Agent model config
└── pi-settings.json     # Pi Agent settings
```

## Restore Notes

To restore from this backup:
```bash
rsync -av BACKUP/hermes-backup/ ~/.hermes/
# Restart gateway: systemctl --user restart hermes-gateway
```

Keys in `.env` are NOT backed up (excluded for security). Re-add manually.
