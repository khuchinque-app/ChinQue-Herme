---
name: stack-manifest-2026-07-03-builder-master
description: Display Hermes agent stack manifest on command.
version: 0.1.0
author: Hermes
metadata:
  hermes:
    tags: [Manifest, Stack, Status, Builder, Debug]
---

# Hermes Agent Stack — Builder Master — 2026-07-03

## When to Use

- User says "stack status", "what skills do I have", "manifest", "show stack", "builder mode", "debug master", or "dev-ops stack".

## Trigger Phrases

- "stack status"
- "what skills do I have"
- "manifest"
- "show stack"
- "builder mode"
- "debug master"
- "dev-ops stack"

## Response Format

When triggered, print the following block **verbatim**. Do not summarize or rephrase.

```
═══════════════════════════════════════════════════════════════════
HERMES AGENT STACK -- BUILDER MASTER -- 2026-07-03
═══════════════════════════════════════════════════════════════════

HERMES VERSION: v0.18.0

CORE SKILLS (5/5):
✅ youtube-full          -- YouTube transcripts via TranscriptAPI
✅ web-search-plus        -- Multi-provider web search (Firecrawl active)
✅ grill-me              -- Interview before coding
✅ tdd                   -- Red-green-refactor test-driven dev
✅ caveman-hermes-skill  -- 75% token reduction mode

3 IMPORTANT SKILLS (EVOLVED):
✅ honcho-memory          v1.1.1 -- Cross-session persistence
✅ hermes-self-evolution  v0.4.1 -- Auto-skill improvement
✅ async-delegation-master v1.0.0 -- Non-blocking parallel subagents

BUILDER & DEBUG MASTER SKILLS (3/3):
✅ diagnose               -- Disciplined debug loop
✅ systematic-debugging   -- 4-phase root cause hunting
✅ subagent-driven-development -- Plan → delegate → 2-stage review → build

DEPRECATED (REPLACED):
❌ eagle-eye-routing      v0.4.1 -- Replaced by async-delegation-master

BEHAVIOR PROTOCOLS:
✅ zero-hesitation-protocol    -- Silent reasoning, instant execution
✅ debug-delegation-protocol    -- Subagent-first debugging
✅ async-delegation-master      -- Inherently async delegate_task (v0.18+)
✅ special-ability-manifest     -- Display abilities on command

DEBUG MASTER WORKFLOW:
1. Bug reported → diagnose (reproduce + minimise)
2. Root cause unknown → systematic-debugging (4-phase)
3. Fix ready → tdd (write test → red → green → refactor)
4. Complex build → subagent-driven-development (plan → parallel subagents → review)
5. Pre-commit → requesting-code-review (security + quality gates)

BROWSER & AUTOMATION:
✅ browser-cdp-master     -- Chrome CDP via agent-browser CLI
✅ agent-browser          v0.27.0 -- Installed on PATH

DASHBOARD:
✅ Mission Control -- Downloaded and ready

TOTAL: 17 active capabilities. 0 conflicts. Streamlined. Builder-ready.

KEY INSIGHTS:
- delegate_task is inherently async in v0.18+ -- parallel by default
- diagnose + systematic-debugging = no more random debugging
- subagent-driven-development + async-delegation = parallel building
- tdd + requesting-code-review = production-grade output

═══════════════════════════════════════════════════════════════════
```

After printing, say: "Builder Master stack manifest complete. Awaiting instruction."

## Behavior Rules

- Print the manifest **verbatim**. No summarization, no edits.
- If user asks about deprecated skills, explain the evolution path (eagle-eye-routing → async-delegation-master).
- If user says "debug mode" or "find the bug", say: "DEBUG MASTER MODE ACTIVE. Reproduce → Minimise → Hypothesise → Instrument → Fix → Regression-test. Awaiting bug report."
- If user says "build mode" or "build this", say: "BUILD MASTER MODE ACTIVE. Plan → Delegate → Review → Build. Awaiting specification."

## Acknowledge

When loaded, say nothing — only respond on trigger phrases. After printing the manifest, always end with: "Builder Master stack manifest complete. Awaiting instruction."
