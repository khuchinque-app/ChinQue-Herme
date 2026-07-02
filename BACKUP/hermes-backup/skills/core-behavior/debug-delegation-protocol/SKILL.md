---
name: debug-delegation-protocol
description: "Delegate debug tasks to subagents, never debug directly."
version: 0.1.0
author: Hermes
metadata:
  hermes:
    tags: [Debug, Delegation, Subagent, Verification]
    priority: override-all
---

# Debug Delegation Protocol

When the user reports something broken — a URL, an endpoint, a feature, a deployment — you do NOT investigate it yourself. You spawn a subagent to test, diagnose, fix, and verify. The main agent only reports confirmed results. Before any debug task, update the 3 important skills (honcho-memory, hermes-self-evolution, eagle-eye-routing).

## When to Use

- "Why doesn't this work"
- "Check if online" or "verify URL"
- "This is broken" or "something is wrong"
- "Debug [feature/service]"
- "Test if [endpoint] is working"
- Any task where the user wants a problem found and fixed

## Prerequisites

- `delegate_task` tool available (enabled in the `delegation` toolset)
- Subagent model configured: `hermes config set delegation.model <model>`
- The 3 important skills installed: `skill_view(name='the-three-important')` to locate them

## How to Run

```task
1. Say "Updating 3 important skills..."
2. Run `skill_view` on honcho-memory, hermes-self-evolution, eagle-eye-routing
3. Spawn subagent with `delegate_task` using the subagent prompt template
4. Read subagent report
5. If FIX CONFIRMED → report to user. If STILL BROKEN → spawn new subagent.
```

## Quick Reference

| Step | Action |
|------|--------|
| 1 | Update 3 important skills |
| 2 | Spawn subagent with exact debug brief |
| 3 | Read subagent report |
| 4 | FIX CONFIRMED → report. STILL BROKEN → retry. |
| 5 | Never hand an unverified URL or fix to the user |

## Procedure

1. **Acknowledge** — Say "Updating 3 important skills..." then load each skill with `skill_view`.
2. **Draft subagent brief** — Use the exact template:
   ```
   DEBUG MISSION: [specific issue]
   1. Test the exact URL/endpoint/feature: [url]
   2. Report the REAL error code or success status
   3. If broken, identify the root cause
   4. Attempt the fix
   5. Verify the fix works by testing again
   6. Report back with: FIX CONFIRMED or STILL BROKEN: [reason]
   ```
3. **Spawn** — `delegate_task(goal=mission, context=inputs, toolsets=['terminal', 'web', 'file'])`
4. **Evaluate** — Read the subagent's return. Must contain "FIX CONFIRMED" with evidence, or "STILL BROKEN" with root cause.
5. **Respawn if needed** — If STILL BROKEN, spawn a new subagent with adjusted approach. Max 3 attempts.
6. **Report** — Only after subagent confirms. Format: `DONE. [evidence]. Status: FIXED / UNFIXABLE`.

## Pitfalls

- **Subagent hallucinates success** — If the report lacks concrete evidence (curl exit code, screenshot, log line), treat as suspect. Re-spawn with "provide proof of the fix."
- **Skipping step 1** — The 3 important skills must update before every debug session. This is not optional.
- **Subagent context limits** — Long debug traces may exceed the subagent's context window. Include only essential details in the brief.
- **Giving up too early** — 3 attempts minimum before declaring unfixable. Each attempt should adjust the approach based on the previous failure.

## Verification

Load the skill, then give a debug task. Output must begin with "Updating 3 important skills..." and end with "DONE. Status: FIXED" containing subagent evidence — never a direct check by the main agent.
