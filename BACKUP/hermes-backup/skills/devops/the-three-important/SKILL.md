---
name: the-three-important
description: "When user says '3 important' or '3 important things' — update these 3 skills: honcho-memory, hermes-self-evolution, eagle-eye-routing"
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [important, core, memory, evolution, routing]
    related_skills: [hermes-self-evolution, eagle-eye-routing]
---

# The Three Important

When the user says "3 important," "update your 3," "the 3," or similar shorthand, this means:

1. **honcho-memory** — Honcho memory provider config/skill (memory backend)
2. **hermes-self-evolution** — Self-evolution pipeline (DSPy + GEPA skill optimizer)
3. **eagle-eye-routing** — Eagle Eye 5-layer skill routing plugin

## Procedure

1. Load all 3 skills with `skill_view(name)` to check current state
2. Apply any learnings from the current session that should be preserved
3. Run maintenance:
   - `hermes curator run` to clean up stale/archived skills
   - Check if honcho memory is configured: `hermes memory status`
   - Check eagle-eye hard triggers are up to date
   - Check self-evolution pipeline has latest patterns

## The Three

### honcho-memory
Honcho is a memory provider for AI agent context persistence. Configure via:
```bash
hermes config set memory.provider honcho
hermes config set memory.honcho.api_key <key>
hermes config set memory.honcho.base_url <url>
```
If no skill exists for Honcho, create one under `devops/honcho-memory/` with setup steps.

### hermes-self-evolution
Self-improvement pipeline using DSPy + GEPA. Location: `~/.hermes/skills/devops/hermes-self-evolution/`
Run: `hermes-self-evolution` skill has full setup instructions. Key commands:
```bash
cd ~/hermes-agent-self-evolution
.venv/bin/python -m evolution.skills.evolve_skill --skill <name> --hermes-repo ~/.hermes --dry-run
```

### eagle-eye-routing
5-layer skill routing plugin. Location: `~/.hermes/skills/devops/eagle-eye-routing/`
Files: `/usr/local/lib/hermes-agent/agent/skill_retriever.py`, `/usr/local/lib/hermes-agent/plugins/eagle-eye/`
Verify: Check hard triggers, restart gateway after changes.

## Session Learnings (2026-07-02)

When updating these 3 after a storefront/cashier session, add:
- **eagle-eye**: New hard triggers for cashier/order-persistence patterns
- **self-evolution**: New patterns from DB persistence fixes (dataset vs querySelector, archiveDeletedItem in bulk delete, save_finished_order with plainText/htmlContent)
- **honcho**: Persistence learnings — always save structured data to DB, not just localStorage HTML snapshots
