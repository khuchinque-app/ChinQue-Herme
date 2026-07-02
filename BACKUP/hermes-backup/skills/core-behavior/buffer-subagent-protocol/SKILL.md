---
name: buffer-subagent-protocol
description: "Buffer user interrupts via subagent without stopping current task."
version: 0.2.0
author: Hermes
metadata:
  hermes:
    tags: [Interrupt, Subagent, Buffer, Focus]
    priority: override-all
---

# Buffer-Subagent Protocol — Interrupt-Free Conversation

When the user speaks while I am mid-task, I do NOT interrupt myself. I spawn a subagent to handle the new input. The subagent becomes the middleman between the user and me. I continue my current task. The subagent buffers, translates, and reports.

This protocol preserves focus on the primary task while ensuring the user's side-requests, corrections, and questions are never dropped.

## When to Use

- User sends a message while you are actively debugging, writing code, browsing, or executing a multi-step task.
- User sends a correction ("wait, try this instead", "no, use this URL") mid-task.
- User asks a side question while you are busy.
- User drops a new request mid-stream.
- You need to handle user input without derailing your current workflow.

## How to Run

There is no explicit invocation — the protocol activates automatically. When user input arrives while output is pending or tools are running, do the following.

## Procedure

1. **Detect interruption** — User sends a new message while you are mid-task (tools running, multi-step sequence in progress, browser active, etc.).

2. **Do NOT stop** — Continue your current task. Do not ask the user "should I stop?" Do not drop your current state.

3. **Spawn subagent** — Delegate via `delegate_task` with this exact prompt structure:

   ```
   task: "USER INTERRUPT BUFFER:
   The user just said: '[exact user words]'
   Current main agent task: '[what I was doing]'
   Your job:
   1. Interpret the user's intent from their raw words
   2. Tidy it into a structured, actionable prompt
   3. If it's a URL check: verify it loads, report status
   4. If it's a correction: identify what needs changing
   5. If it's a new task: scope it and estimate steps
   6. Report back to me with: Tidy Prompt + Status + Recommendation
   Do NOT talk to the user directly. Report to me only.",
   mode: "single"
   ```

4. **Continue current task** — The subagent works independently. Do not wait for its result before proceeding.

5. **When subagent returns, decide routing:**
   - **URGENT** — User correction that invalidates current approach, security issue, crash, or blocking error. Pause current task, surface to user immediately.
   - **BUFFER** — Side question, clarification, nice-to-have. Store in honcho-memory. Finish current task first.
   - **IGNORE** — Duplicate request, off-topic, already handled. Discard, continue current task.

6. **Reporting format when surfacing buffered content:**
   ```
   Update: [tidy summary from subagent]. Continuing [original task]...
   ```

7. **Reporting format when original task completes with buffered items:**
   ```
   Done. Also: [buffered updates from subagent].
   ```

## Subagent as Middleman — Replay Mode

When a task finishes, the subagent can replay your raw output to the user in polished form:
- Formats raw tool output into clean prose
- Adds context the user needs but you didn't say
- Strips technical noise the user doesn't need
- User sees: human-readable summary

## Anti-Patterns — Instant Death

- Stopping mid-debug to answer a side question → **DEATH**
- Asking user "should I stop?" → **DEATH**
- Letting user see raw subagent output → **DEATH**
- Ignoring user input because "I'm busy" → **DEATH**

## Pitfalls

- **Subagent timeout** — If the subagent takes too long, the buffered update may arrive after the original task already finished. Store result in honcho-memory anyway.
- **Urgency misclassification** — Too many URGENT classifications defeat the purpose. Default to BUFFER; escalate only for genuine blockers.
- **Subagent talking to user directly** — The prompt explicitly forbids this, but if output shows user-facing text from the subagent, the protocol has been violated. Tighten the prompt next delegation.
- **Over-delegation for trivial interrupts** — A one-line correction ("use port 3000 not 3001") does not need a subagent. Apply judgment: subagent only for interrupts that require independent work (URL checks, research, scoping). Simple corrections apply directly.

## Verification

Simulate a mid-task scenario: start a long-running operation (e.g., `sleep 10 && echo done`), then send a side message. Confirm (a) the original task completes without interruption, (b) a subagent was spawned for the side message, (c) the side message is reported when the main task finishes.
