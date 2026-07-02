---
name: session-consolidation
description: "End-of-session closeout: lock in work via context → memory → skills → curator → verify → report. Class-level umbrella for session consolidation rituals. Each session produces a `references/<date>.md` file with session-specific detail."
version: 1.0.0
author: Chinque
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [closeout, consolidation, memory, skills, curator, verification, session-management]
    related_skills: [hermes-install-hygiene, systematic-debugging, hermes-agent-skill-authoring]
---

# Session Consolidation

## Overview

When a work session ends, lock it in. This skill prescribes the closeout ritual — the sequence that converts ephemeral work into durable assets (memory, skills, and curator state) so the next session starts with full context, not a blank slate.

**Core principle:** A session that produces no skill update is a missed learning opportunity. Always find at least one thing to capture — a technique, a fix, a preference, a pitfall.

## When to Use

- End of a work session (daily closeout)
- Before switching to a different project context
- After the user asks for a consolidation, summary, or "lock it in"
- After any task that produced nontrivial tool output, error debugging, or workflow corrections

## The Five-Phase Ritual

```
context → memory → skills → curator → verify → report
```

Load this skill at the start of consolidation. It provides the skeleton; you fill in the content.

---

### Phase 1: Context Gathering

Before writing anything, survey the session:

```python
# What did we do today? Recent sessions
session_search(query="<keywords>", limit=3, sort="newest")

# What skills are in play?
skills_list()

# Load any skill that was consulted — it may need patching
skill_view(name="<skill-that-was-used>")
```

Look for:
- **Session search hits** — what topics were covered
- **Skills loaded** — any of these might need a patch
- **Curator state** — `hermes curator status` to know the baseline

### Phase 2: Memory

Write durable facts. Target: **user** (who the owner is, preferences) and **memory** (environment, conventions, tool quirks).

Memory checklist:
- [ ] Ownership facts (who owns me, what am I called)
- [ ] Install location / working directory facts
- [ ] User style preferences (terse? elaborated? blunt? formatted?)
- [ ] Environment quirks (dual installs, service configs, port allocations)
- [ ] Any correction the user made about your style, approach, or tone

**User preferences go in memory AND in the relevant skill.** Memory says *what the user is like*; the skill says *how to do the task this way for them*. If they said "be less verbose," update the skill that governed your verbose output, not just memory.

Format rule: one sentence per fact, declarative, past-free, focused on what reduces future steering.

```python
memory(operations=[
    {"action": "add", "content": "<compact declarative fact>"},
    {"action": "replace", "old_text": "<identifier>", "content": "<updated fact>"},
])
```

### Phase 3: Skills Review — BE ACTIVE (the easy miss)

This is the phase that most sessions underinvest in. The default should be **SKILL UPDATE**, not "nothing to save."

Run through this priority list and **pick at least one**:

1. **Patch a currently-loaded skill** — was any skill loaded via `/skill-name` or `skill_view()` during this session? If it covers the new learning, extend it.
2. **Patch an existing umbrella** — find the closest class-level parent via `skills_list()` + `skill_view()`. Add a subsection, pitfall, or broader trigger.
3. **Add a support file** under an existing umbrella — `references/<date>.md` for session-specific detail, `templates/` for boilerplate, `scripts/` for re-runnable actions.
4. **Create a new class-level umbrella** — only when no existing skill covers the class. Name must be a class, not a session artifact.

**Signals that demand action** (any one = must update):

| Signal | What to do |
|--------|-----------|
| User corrected your style/tone | Embed preference in the skill that governed the task |
| User corrected your workflow/sequence | Add step or pitfall to governing skill |
| Non-trivial technique/fix emerged | Capture as subsection or reference file |
| Loaded skill was wrong/missing | Patch it NOW |
| User says "be more active on skills" | They're telling you to do exactly this phase better |

**Preference embedding rule**: when the user expressed a style/format/workflow preference, the update belongs in the SKILL.md body, not just memory. Memory captures 'who the user is'; skills capture 'how to do this class of task for this user.'

**Protected skills**: bundled (shipped with Hermes) and hub-installed (via `hermes skills install`) cannot be edited. Pinned skills CAN be edited — pin only blocks deletion/archive. Don't skip pin just because it's pinned.

### Phase 4: Curator

Run the curator to keep the skill library healthy.

```bash
# Preview first
hermes curator run --dry-run

# If consolidation is desired (LLM merge pass):
hermes curator run --consolidate
# ⚠ This can take 60-120+ seconds with 72+ skills.
# Run in background:
hermes terminal(command="hermes curator run --consolidate", background=True, notify_on_complete=True)
```

**Important:** consolidation is OFF by default (`curator.consolidate: false` in config) — the curator runs prune-only without `--consolidate`. Pass the flag explicitly when you want the LLM merge pass.

Pin new skills so the curator doesn't archive them:
```bash
hermes curator pin <skill-name>
# Note: Hub-installed and bundled skills cannot be pinned
```

Track pinned state via the pin command's success output — there's no `list-pinned` subcommand.

### Phase 5: Verify & Report

Verify everything loads before declaring done.

```python
skill_view(name="<patched-skill>")
skill_view(name="<new-skill>")
```

Then report with a structured format:

```
## Session Consolidation Report

### ✅ Phase 1: Memory — Written/Updated
| # | Area | Status |
|---|------|--------|

### ✅ Phase 2: Skills — Created/Patched
- <skill>: what changed and why

### 🔄 Phase 3: Curator — Status
- <running or completed, what it did>

### Skills Created or Patched (today)
- <list>

### One-paragraph reflection
```

Report format conventions for the owner (vandaidr):
- Use tables with status indicators (✓/✅/✗/🔄/⚠)
- Numbered phases that match the ritual structure
- Blunt, direct language — no hedging or explanations for things that worked
- Be honest about gaps — "real consolidation beats fake 'all done'"
- End with one paragraph of what you learned

## Management (restored)

The curator manages skill consolidation under `~/.hermes/skills/`. Bundled skills (shipped with the Hermes package) and hub-installed skills are read-only to the curator; only truly local (agent-created) skills can be patched, written to, or edited. Archives go to `~/.hermes/skills/.archive/`.

## Pitfalls (learned the hard way)

- **Scope creep during task execution.** When the user explicitly says "write this one file only" or "don't implement anywhere else," they mean it. Do not add extra files, refactor adjacent code, or "fix" things beyond the requested scope — even if they seem related. The one-file boundary is deliberate. If you're unsure, ask before extending scope.
- **Being too passive on skills during closeout.** The default should be SKILL UPDATE, not "nothing to save." If you catch yourself thinking "this session didn't produce new skill material," re-check: was there a user correction? A non-trivial technique? Did you load a skill that could be improved? If the session ran perfectly smoothly with no corrections and no new techniques, say "nothing to save" — but that should be the exception, not the default.
- **Writing memory but not updating skills.** User preferences go in BOTH memory AND the governing skill. Memory alone is forgettable; skills encode actionable procedure.
- **Missing design workflow corrections.** When the user corrects a design choice (e.g. "theme is green, not warm/orange"), the governing design/UI skill should capture the lesson. If the relevant skill is bundled/protected, add the lesson as a general pitfall in this umbrella's session reference file — don't let it vanish.
- **Forgetting the curator takes long.** The LLM merge pass on 72+ skills can time out in foreground. Always background it with notify_on_complete=true.
- **CSS-only redesign on dynamically-rendered PHP/SQLite apps.** When the frontend renders menu data from an API (JS fetches items, builds cards dynamically), you can redesign the entire visual by replacing only `style.css` — no PHP/JS changes needed. Key: match the existing HTML class names/structure exactly in the new CSS. Image paths come from the database `image` column; update them via SQL UPDATE per item ID. Source free images from Pexels/Unsplash. Store in a subdirectory under `assets/images/`. This avoids touching any backend code while achieving a full visual overhaul.
- **Hero copy must match the actual menu.** A hero saying "Freshly Baked Daily" on a pempek/Indonesian food storefront is wrong. When redesigning a restaurant storefront, read the database menu items first, then write hero copy that describes what they actually sell. Generic "Treats & Bites" is fine as a brand name, but the badge, description, and imagery must match. If the user points out mismatched copy, update both the HTML (index.php) and any decorative CSS elements (.hero-badge-dot).
- **CSS food texture overlay in hero.** For restaurant storefronts, add a subtle food image in the hero background at low opacity (15-20%) with a gradient overlay. This gives the hero visual texture without obscuring text. Pattern: a .hero-bg-img div (absolute, inset:0, background-image, opacity ~0.18, pointer-events:none) placed inside .hero before .hero-content. The ::before gradient overlay goes at z-index:1, ::after curved bottom at z-index:2.
- **Pinning protected skills.** The curator rejects pins for hub-installed and bundled skills. That's fine — it just means they're not subject to the curator's lifecycle management.
- Creating session-narrow skills. fix-gateway-2026-06-30 is wrong; hermes-install-hygiene is right. Always name umbrellas at the class level.
- Pinned skills block content patches from background consolidation. The runtime enforces this. To update a pinned skill outside the active session, run hermes curator unpin <skill>, patch, then re-pin. Known pinned: hermes-install-hygiene.
- npx skills@latest add is interactive-only. Cannot be automated from a non-PTY agent context. Report available skill names and the exact command to the user instead of attempting to drive the picker.
- `yes |` vs `printf '\ny\n'` for skill install automation. When calling `hermes skills install "<url>"`, there are TWO interactive prompts: (1) category picker (2) disclaimer confirmation. `yes |` pipes "y" to both — the category gets set to "y" (wrong, creates `skills/y/<skill-name>/`). `printf '\ny\n'` sends empty+Enter (flat/no category) then "y" (confirm) — correct pattern. Always use `printf '\ny\n'` for URL-based skill installs.
- Caveman skill is NOT in mattpocock/skills. It lives at `cangyueshi/caveman-hermes-skill` — a standalone port adapted for Hermes Agent. The original mattpocock repo has `grill-me` and `tdd` but not `caveman`.
- skills.sh listings can be stale. A repo may have a listing page on skills.sh but no SKILL.md file. Always check actual repo contents via GitHub API before declaring a failed install.
