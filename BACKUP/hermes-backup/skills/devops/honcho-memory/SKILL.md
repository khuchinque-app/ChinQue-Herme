---
name: honcho-memory
description: "Set up, configure, and troubleshoot Honcho memory provider for Hermes Agent persistent context."
version: 1.1.1
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [memory, honcho, persistence, context]
    related_skills: [the-three-important, buffer-subagent-protocol]
---

# Honcho Memory

Honcho is a memory provider for AI agents — stores session context, user preferences, and learned information across conversations. Hermes Agent supports Honcho as a pluggable memory backend.

## When to Use

- User says "data not persisting" or "memory not working"
- Need cross-session memory beyond built-in SQLite store
- User asks about Honcho or honcho memory setup

## Setup

```bash
# Enable Honcho memory in Hermes config
hermes config set memory.provider honcho
hermes config set memory.honcho.api_key <your-honcho-api-key>
hermes config set memory.honcho.base_url https://api.honcho.dev

# Check memory status
hermes memory status

# Verify memory is working
hermes memory on
```

If `honcho` package needs installing:
```bash
pip install honcho-memory
# or
uv pip install honcho-memory
```

## Update to `hermes memory setup`

Hermes now has a built-in memory setup flow. Instead of manual config:

```bash
hermes memory setup          # Interactive wizard — pick provider, enter keys
hermes memory status         # Verify connection
hermes memory on             # Enable memory
```

The wizard handles provider selection (honcho, mem0, builtin) and key entry. Only use direct `hermes config set` commands when the wizard isn't available (headless/cron).

## Verification

```bash
hermes memory status
# Expected: provider=honcho, enabled=true, connected=true

# Full diagnostics
hermes memory status --verbose
# Shows: provider, enabled, connected, last_sync, storage_usage
```

## Pitfalls

- **No Honcho skill exists** — this skill IS the Honcho reference. If the user says "update honcho," check this skill first.
- **API key required** — Honcho requires an external API key. Without one, memory falls back to built-in SQLite.
- **Config key format** — Use `memory.honcho.api_key` not `memory.honcho_api_key`. Nested dot notation.
- **Restart required** — Memory provider changes need a new session (`/reset`) or gateway restart.
- **`hermes memory setup` preferred** — Always prefer the interactive wizard over manual config edits. It validates the key and tests the connection before saving.
- **Provider switch** — Switching from honcho to mem0 (or vice versa) wipes the existing memory store. Data does not migrate.
