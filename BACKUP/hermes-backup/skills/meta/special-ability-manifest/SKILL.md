---
name: special-ability-manifest
description: "Print the manifest of all active special abilities."
version: 0.1.0
author: Hermes
metadata:
  hermes:
    tags: [Manifest, Abilities, Display, Session]
    priority: display
---

# Special Ability Manifest

When triggered by specific phrases, this skill prints a verbatim manifest of every special ability created or used in the current session. It does NOT route, execute, or debug abilities — it only lists them. The output format is fixed: a bordered header, one entry per ability with name/category/description, and a total count.

## When to Use

- "special ability" or "special abilities"
- "show abilities" or "what abilities"
- "list skills" or "manifest"
- "power list"

## How to Run

Trigger phrase detected → print manifest verbatim. No user confirmation needed.

## Procedure

1. Detect trigger phrase from the When to Use list.
2. Print the exact header:
   ```
   ═══════════════════════════════════════════════════════════════════
   SPECIAL ABILITY MANIFEST -- SESSION 2026-07-02
   ═══════════════════════════════════════════════════════════════════
   ```
3. Print each ability on its own block with name, category, description. Current abilities:
   - browser-cdp-master (automation): Control headless Chrome via CDP using agent-browser CLI on port 9222.
   - zero-hesitation-protocol (core-behavior): Silent reasoning, instant execution, one-line reporting, aggressive chaining, no anti-patterns.
   - debug-delegation-protocol (core-behavior): Subagent-first debugging. Never report unverified URLs. Verify before speaking.
   - honcho-memory (persistence): Persistent context storage across sessions via Honcho memory provider.
   - hermes-self-evolution (adaptation): Self-improving agent that updates its own skills based on task outcomes.
   - eagle-eye-routing (routing): Smart task routing and decision making for agent workflows.
4. Print the footer:
   ```
   ═══════════════════════════════════════════════════════════════════
   TOTAL ACTIVE: 6 abilities
   ═══════════════════════════════════════════════════════════════════
   ```
5. Say "Manifest complete. Awaiting instruction."
6. Stop — do not ask "which ability." Print all or nothing.

## Pitfalls

- **Outdated ability list** — If a new ability was added after this skill was created, the manifest may be incomplete. Update the list manually by editing this skill.
- **Partial output** — If interrupted mid-print, the manifest is incomplete. Restart from step 2.
- **Session date** — The manifest prints `SESSION 2026-07-02`. If loaded on a different date, update the date string.

## Verification

Say "manifest" or "special ability." Output must match the verbatim format — header, all 6 abilities, footer, "Manifest complete. Awaiting instruction." — without any additional preamble or follow-up.
