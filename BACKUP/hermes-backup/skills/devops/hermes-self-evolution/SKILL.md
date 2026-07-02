---
name: hermes-self-evolution
description: "Run the Hermes Agent self-evolution pipeline using DSPy + GEPA to auto-optimize skills."
version: 0.4.1
author: Hermes
platforms: [linux]
metadata:
  hermes:
    tags: [Evolution, Self-Improvement, DSPy, GEPA, Optimization]
---

# Hermes Agent Self-Evolution

Hermes Agent Self-Evolution is an evolutionary self-improvement pipeline that optimizes skills, prompts, tool descriptions, and code using DSPy + GEPA (Genetic-Pareto Prompt Evolution). It operates ON hermes-agent from a standalone repo — no GPU needed, everything via API calls.

## What It Does NOT Do

- It does not evolve model weights (only prompts / instructions / code text).
- It does not auto-deploy changes — all improvements go through human PR review.
- It does not run without an API key for the optimizer LLM.

## When to Use

- You want to auto-optimize a skill that performs poorly or inconsistently.
- You want to evolve tool descriptions so the agent picks the right tool more reliably.
- You want systematic improvement of system prompt sections.
- You want a "night self-evolution" cron job that improves skills while you sleep.

## Prerequisites

- Python 3.10+ with `sqlite3` FTS5 support.
- API key for the optimizer model (OpenAI, OpenRouter, or compatible).
- The repo cloned locally (not inside hermes-agent itself).
- Target skill exists under `~/.hermes/skills/` or a designated hermes-agent repo.

## How to Run

1. Clone and install:
```bash
cd /home/khuchinque
git clone https://github.com/NousResearch/hermes-agent-self-evolution.git
cd hermes-agent-self-evolution
python3 -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
```
2. Run evolution (dry-run first, use venv python directly — do NOT use `source .venv/bin/activate` in agent sessions):
```bash
/home/khuchinque/hermes-agent-self-evolution/.venv/bin/python -m evolution.skills.evolve_skill \
  --skill docker-container-ops \
  --iterations 10 \
  --hermes-repo /home/khuchinque/.hermes \
  --dry-run
```
3. Run for real:
```bash
/home/khuchinque/hermes-agent-self-evolution/.venv/bin/python -m evolution.skills.evolve_skill \
  --skill docker-container-ops \
  --iterations 10 \
  --hermes-repo /home/khuchinque/.hermes \
  --eval-source synthetic
```

## Quick Reference

| Phase | Target | Engine | Status |
|---|---|---|---|
| Phase 1 | SKILL.md files | DSPy + GEPA | ✅ Implemented |
| Phase 2 | Tool descriptions | DSPy + GEPA | 🔲 Planned |
| Phase 3 | System prompt sections | DSPy + GEPA | 🔲 Planned |
| Phase 4 | Tool implementation code | Darwinian Evolver | 🔲 Planned |
| Phase 5 | Continuous improvement loop | Automated pipeline | 🔲 Planned |

**Engines:**
- **DSPy + GEPA**: Reflective prompt evolution (reads execution traces, proposes targeted mutations). MIT.
- **Darwinian Evolver**: Code evolution with Git-based organisms. AGPL v3 (external CLI only).

## Procedure

1. **Install the pipeline.** Use `terminal` to clone the repo, create a venv, and `pip install -e ".[dev]"`.
2. **Verify setup.** Run `pytest tests/ -q` inside the venv. Expect ~145 passes.
3. **Find the skill to evolve.** Skills live in `~/.hermes/skills/<category>/<skill-name>/SKILL.md`. Note the exact skill name (from the YAML frontmatter `name:` field).
4. **Dry-run evolution.** Use `evolution.skills.evolve_skill --skill <name> --hermes-repo /home/khuchinque/.hermes --dry-run` to validate it finds the skill.
5. **Run optimization.** Remove `--dry-run`. The pipeline:
   - Loads the skill and parses frontmatter/body.
   - Generates synthetic eval dataset (or mines from session history with `--eval-source sessiondb`).
   - Validates baseline constraints (size, structure).
   - Runs GEPA optimizer (or MIPROv2 fallback).
   - Evaluates evolved vs baseline on holdout set.
   - Validates evolved constraints.
   - Saves results to `output/<skill-name>/<timestamp>/`.
6. **Review the diff.** Check `output/<skill-name>/<timestamp>/evolved_skill.md` vs `baseline_skill.md`.
7. **Deploy manually.** If improvement > 0 and constraints pass, copy the evolved skill back to `~/.hermes/skills/`. Future: the tool will auto-create PRs.

## Session Learnings (2026-07-02 Aseng/Tittil fix)

Key patterns discovered for storefront fixes that should be preserved in evolution:

1. **Emoji → logo replacement**: When replacing emoji icons with brand images, ALWAYS rename the file (e.g., `logo-icon.png`) to bust browser cache. The old `logo.png` name stays cached on mobile devices.

2. **Base CSS first**: Layout classes like `cat-bar`, `section-header`, and `section-more` need BASE STYLES in `style.css` (display: flex, sizing, gap). Theme.css only handles colors. Without base CSS, these sections have NO layout.

3. **Mobile hero wave**: The SVG wave between hero and delivery creates a visible gap line on mobile. Hide it with `display: none` on small viewports and add `margin-top: -1px` on the delivery banner.

4. **Splash screen timeout**: The splash screen uses `setTimeout(() => ...remove(), 1800)` in JS. If testing with headless browsers, wait 3s before screenshotting to let it finish.

5. **Hero text for Indonesian food brands**: Use authentic Palembang/Indonesian seller language (e.g., "Wong Kito Galo", "Dijamin Merem Melek", "Cuko hitam kental pedes manis asam seger") instead of generic English like "Asian Vibes" or "Street Food."

6. **Cashier DB persistence**: When data isn't persisting to the database, check:
   - API calls must send ALL fields (plainText, htmlContent, notes) not just orderNo/total
   - Always use `item.dataset.*` not `item.querySelector('.class')?.textContent` — querySelector returns null if the class doesn't exist
   - Bulk delete functions must call `archiveDeletedItem(item)` for EACH item to save full receipt to DB before removal
   - `save_finished_order` API must receive `plainText` and `htmlContent` so history.php can display receipts on any device

## Pitfalls

- **API cost:** Each optimization run costs ~$2-10 depending on iterations and model choice.
- **GEPA unavailable:** If `dspy.GEPA` is missing in your DSPy version, it falls back to `MIPROv2` automatically. Check output for the fallback message.
- **Skill size limit:** Baseline skills over 15KB trigger constraint warnings. The evolved skill must stay under this limit.
- **Session DB mining:** `--eval-source sessiondb` requires mining ~.claude/history.jsonl, ~/.copilot/events.jsonl, and Hermes state. May yield zero examples if no relevant history exists.
- **No auto-deploy:** Even when evolution succeeds, the tool only writes to `output/`. Human review and manual copy (or future PR automation) is required.
- **Hermes repo path:** The tool auto-discovers `~/.hermes/hermes-agent`, `~/.hermes`, or accepts `--hermes-repo` explicitly. If your skills are at a non-standard path, always pass `--hermes-repo`.
- **.env in venv vs Hermes:** The evolution pipeline reads API keys from its own `.env` or env vars, NOT from `~/.hermes/.env`. Set `OPENAI_API_KEY` or configure `dspy.LM()` manually.
- **`source .venv/bin/activate` blocked:** When running evolution inside an automated Hermes session, shell `source` may be blocked by execution guards. **Always use the venv python directly** — `/home/khuchinque/hermes-agent-self-evolution/.venv/bin/python -m evolution.skills.evolve_skill ...` instead of `source .venv/bin/activate && python ...`. This is the only reliable invocation path inside agent sessions.
- **Skill lookup depends on `--hermes-repo`:** If you pass a path that lacks the standard `skills/<category>/<skill-name>/SKILL.md` layout, the tool silently fails to find the skill. Always verify with `--dry-run` first.

## Verification

Use the venv python directly (do NOT `source .venv/bin/activate` in agent sessions):
```bash
cd /home/khuchinque/hermes-agent-self-evolution
.venv/bin/pytest tests/ -q
```
Expected: `145 passed, 11 warnings`.

Dry-run a real skill:
```bash
.venv/bin/python -m evolution.skills.evolve_skill \
  --skill docker-container-ops \
  --hermes-repo /home/khuchinque/.hermes \
  --dry-run
```

Expected: "DRY RUN — setup validated successfully."

## MCP Browser Automation Context
When searching for browser-attached MCP tools concurrently with this evolution setup, the space is:
- **Microsoft playwright-mcp**: 34.6k stars, local browser agent with device emulation
- **Browserbase MCP**: Cloud headless with Stagehand, viewport/resolution flags
- **Steel MCP Server**: Self-hosted Voyager via Steel local browser
None attach to the user's *existing* browser session — all launch fresh instances.