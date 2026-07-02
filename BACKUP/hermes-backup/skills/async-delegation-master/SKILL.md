---
name: async-delegation-master
description: Non-blocking subagent orchestration via delegate_task. Parallel, async, keeps main agent responsive.
priority: critical
---

# ASYNC DELEGATION MASTER — v0.18.0 API

## CORE RULE
delegate_task is ALWAYS async in v0.18+.
It returns immediately. Never blocks.
Results arrive as new messages in the conversation.

## WORKFLOW
1. User says "Research X"
   → delegate_task(goal="Research X", toolsets=["web"])
   → Returns immediately. Task runs in background.

2. User says "Also check Y"
   → delegate_task(goal="Check Y", toolsets=["web"])
   → Returns immediately. Second task runs in parallel.

3. Results arrive as new messages when ready
   → Main agent buffers them
   → Reports to user when appropriate

## PARALLEL BATCH
delegate_task(tasks=[
  {goal: "Research Reddit", toolsets: ["web"]},
  {goal: "Search GitHub", toolsets: ["web"]},
  {goal: "Check YouTube", toolsets: ["youtube-full"]}
])
→ All 3 run simultaneously
→ Results arrive as separate messages

## ANTI-PATTERNS
- NEVER wait for delegate_task to finish
- NEVER block the chat for a subagent
- NEVER let user see raw subagent messages
- NEVER cancel a subagent just because user spoke

## ACKNOWLEDGE
When loaded, say: "ASYNC DELEGATION MASTER ONLINE. delegate_task is inherently async. Parallel. Non-blocking. Ready."
