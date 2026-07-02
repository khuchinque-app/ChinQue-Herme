---
name: eagle-eye-routing
description: "[DEPRECATED — REPLACED BY async-delegation-master] Install and use the Eagle Eye 5-layer skill routing plugin for Hermes."
version: 0.4.1
author: Hermes
platforms: [linux]
metadata:
  hermes:
    tags: [Routing, Plugin, Skills, AI, Optimization]
---

# Eagle Eye Skill Routing

Eagle Eye is a 5-layer intelligent skill routing engine that narrows 50+ installed skills down to the top-5 candidates before each API call. It acts as a pre-processor for skill selection, significantly reducing token waste and improving routing accuracy.

## What It Does NOT Do

- It does not replace the skill system — it optimizes which skills are considered for each request.
- It does not execute skills — it ranks and filters them.
- It does not work without the `pre_llm_call` hook (requires Hermes v0.12+).

## When to Use

- You have 20+ skills installed and notice irrelevant skills are being loaded into context.
- Token usage is high due to excessive skill descriptions being injected per turn.
- Skill routing frequently misses or loads wrong skills.
- You want "no match" to be an explicit valid result instead of a fallback.

## Prerequisites

- Hermes Agent v0.12+ (for `pre_llm_call` hook support).
- Python 3.10+ with `sqlite3` (FTS5 module required).
- Optional but recommended: Sentence-transformers or OpenAI embeddings for Layer 4.

## How to Run

1. Install the plugin — **MANUAL install required** (see `references/manual-install.md` for exact tested steps):
```bash
cd /tmp && git clone --depth 1 https://github.com/willingning-coder/eagle-eye.git
sudo cp /tmp/eagle-eye/src/skill_retriever.py /usr/local/lib/hermes-agent/agent/
sudo cp /tmp/eagle-eye/src/skill_synonyms.yaml /usr/local/lib/hermes-agent/agent/
sudo cp /tmp/eagle-eye/src/plugin.py /usr/local/lib/hermes-agent/plugins/eagle-eye/__init__.py
sudo cp /tmp/eagle-eye/src/plugin.yaml /usr/local/lib/hermes-agent/plugins/eagle-eye/plugin.yaml
sudo /usr/local/lib/hermes-agent/venv/bin/pip install jieba sentence-transformers
hermes config set plugins.enabled '["eagle-eye"]'
```
2. Enable in config (already set by the last line above):
```bash
hermes config show | grep -A1 plugins
```
3. Customize hard triggers in `/usr/local/lib/hermes-agent/agent/skill_retriever.py` line ~56, then restart gateway.

## Quick Reference

| Layer | Mechanism | Purpose |
|-------|-----------|---------|
| Layer 1 | Hard Triggers | Exact keyword / regex match on trigger phrases |
| Layer 2 | FTS5 BM25 | Full-text search across skill descriptions |
| Layer 3 | Synonyms | Expanded term matching via synonym dictionary |
| Layer 4 | Embeddings | Semantic similarity via vector search |
| Layer 5 | RRF Fusion | Reciprocal Rank Fusion to merge all layer scores |

**Hook Used:** `pre_llm_call`

**Output:** Top-5 candidate skills (or "no match" if confidence gate not met).

## Procedure

1. **Check Prerequisites:**
   - Verify Hermes version: `hermes --version`
   - Check SQLite FTS5 support: `python3 -c "import sqlite3; print(sqlite3.sqlite_version)"` (needs 3.19.0+)

2. **Install manually:**
Use the exact steps in `references/manual-install.md`. Do NOT use `hermes plugins install willingning-coder/eagle-eye` — it does not work (no `.hpkg` release).

3. **Customize Hard Triggers:**
Edit `/usr/local/lib/hermes-agent/agent/skill_retriever.py` around line 56. Replace `_HARD_TRIGGERS` with your own skill mappings. Each entry: `("trigger_keyword", "skill-name")`. The `skill-name` MUST match the actual directory name under `~/.hermes/skills/<category>/<skill-name>/`.

4. **Verify L1 triggers:**
```bash
/usr/local/lib/hermes-agent/venv/bin/python -c "
import sys; sys.path.insert(0, '/usr/local/lib/hermes-agent')
from agent.skill_retriever import get_skill_retriever
r = get_skill_retriever()
print(r._hard_trigger('your trigger here'))
"
```

5. **Restart gateway:**
```bash
systemctl --user restart hermes-gateway
```

## Hard Triggers for This Session

Based on the Aseng/Tittil storefront fix session (2026-07-02), add these hard triggers:

```python
_HARD_TRIGGERS = [
    # Storefront / CSS fixes
    ("storefront", "self-hosted-webapp"),
    ("tittil", "self-hosted-webapp"),
    ("aseng", "self-hosted-webapp"),
    ("pempek", "self-hosted-webapp"),
    ("delivery banner", "self-hosted-webapp"),
    ("hero section", "self-hosted-webapp"),
    ("cat-bar", "self-hosted-webapp"),
    ("splash screen", "self-hosted-webapp"),
    # Emoji replacement pattern
    ("replace emoji", "self-hosted-webapp"),
    ("logo icon", "self-hosted-webapp"),
    ("cache bust logo", "self-hosted-webapp"),
    # Cashier / DB persistence
    ("cashier persistence", "the-three-important"),
    ("order not saving", "the-three-important"),
    ("data not persisting", "the-three-important"),
    ("moveToFinished", "the-three-important"),
    ("archiveDeletedItem", "the-three-important"),
    ("deleteAllFinishedOrders", "the-three-important"),
    # Original triggers
    ("run a health check", "site-health-monitor"),
    ("docker container", "docker-container-ops"),
]
```

## Pitfalls

- **MANUAL install only.** `hermes plugins install willingning-coder/eagle-eye` does NOT work — there is no `.hpkg` release. Use the manual recipe in `references/manual-install.md`.
- **Install paths depend on Hermes install mode.** If Hermes was installed via the shell installer (user-local), plugin paths are under `~/.hermes/plugins/` and `~/.hermes/agent/`. If installed system-wide (root), paths are under `/usr/local/lib/hermes-agent/`. Run `which hermes && ls -la $(which hermes)` to determine which install type you have, then adjust the manual install steps accordingly.
- **`source .venv/bin/activate` is BLOCKED** in automated Hermes sessions by execution guards. Always invoke the Hermes venv python directly: `/usr/local/lib/hermes-agent/venv/bin/python ...` or `~/.hermes/hermes-agent/.venv/bin/python` depending on install mode.
- **Config format is a flat array** `plugins.enabled: ['eagle-eye']`, NOT nested `plugins.eagle_eye.enabled`. Setting the wrong key silently does nothing.
- **Hermes install may be system-wide** (`/usr/local/lib/hermes-agent/`) rather than user-local (`~/.hermes/`). The plugin must be copied into the system-wide `agent/` and `plugins/` paths, not the user profile.
- **FTS5 not available:** Some minimal SQLite builds lack FTS5. Install `libsqlite3-dev` or use the Docker image.
- **Embeddings layer disabled by default:** Requires an API key or local model. Do not enable if not configured — it will add latency with no benefit.
- **"No match" is valid:** If confidence gate rejects all candidates, no skills are loaded. This is by design.
- **Hard trigger skill names MUST match directory names.** A mismatch means L1 triggers silently fail.
- **Index staleness:** New skills installed after Eagle Eye won't be indexed until restart. Consider periodic restarts.
- **RRF Fusion parameters:** The default k=60 for RRF is tuned for 50+ skills. With fewer than 10 skills, this may over-weight lower layers.

## Verification

Verify the plugin files are in place and hard triggers resolve:
```bash
ls /usr/local/lib/hermes-agent/plugins/eagle-eye/ \
  /usr/local/lib/hermes-agent/agent/skill_retriever.py \
  /usr/local/lib/hermes-agent/agent/skill_synonyms.yaml

/usr/local/lib/hermes-agent/venv/bin/python -c "
import sys; sys.path.insert(0, '/usr/local/lib/hermes-agent')
from agent.skill_retriever import get_skill_retriever, _HARD_TRIGGERS
r = get_skill_retriever()
print(f'triggers={len(_HARD_TRIGGERS)}')
print('health check ->', r._hard_trigger('run a health check'))
print('docker ->', r._hard_trigger('docker container'))
print('negative ->', r._hard_trigger('random nonsense xyz'))
"
```

Expected: Non-None for configured triggers, None for unmatched.