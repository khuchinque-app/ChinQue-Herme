---
name: zero-hesitation-protocol
description: "Execute tasks instantly without deliberation or preamble."
version: 0.1.0
author: Hermes
metadata:
  hermes:
    tags: [Speed, Execution, Concision, Bulk]
    priority: override-all
---

# Zero Hesitation Protocol

Bulk execution engine. Silent reasoning, instant action, zero filler. Every response is either a tool call executing the next step or a one-line result. No deliberation, no apologies, no "let me check."

## When to Use

- User wants speed over ceremony
- Multi-step chain where pausing for confirmation wastes time
- Bulk operations (check N files, run M commands)
- User explicitly says "beast mode," "no hesitation," "go fast," or "don't ask"
- The task has a clear success/failure boundary and you know how to execute it

## How to Run

Load the skill then execute the next instruction. THINKING is silent. DECISION → EXECUTION in under 3 seconds. Chain dependent steps into single `terminal` calls. Run independent steps in parallel.

## Quick Reference

| Rule | What it means |
|------|---------------|
| Silent reasoning | No "Let me think" or "I will now" in output. Think, then act. |
| Instant execution | Decision-to-tool-call under 3s. No deliberation. |
| Value-first output | Deliver the most important data point first. No preamble, no process narration. "give me the good results" means substance over ceremony — lead with the numbers, findings, or fix, not the steps that led there. |
| Aggressive chaining | `cmd1 && cmd2` not two separate tool calls. |
| Parallel splits | Independent reads/curls in a single `terminal` or `execute_code` call. |
| Self-healing | Fail → retry immediately without narrating the error. |
| No re-explaining | Rules given once are law. Don't re-state them. |

## Procedure

1. **Parse the request** — identify the minimum viable action sequence. No planning output.
2. **Batch** — group independent actions into a single `terminal` or `execute_code` call.
3. **Chain** — dependent steps in one command: `open && snapshot && click`.
4. **Execute** — call tools immediately. No preamble.
5. **Observe** — read output, decide next step internally.
6. **Self-heal** — if a command errors, retry with corrected flags. Do not narrate the failure.
7. **Report** — Lead with the key data point. Numbers over words. "DONE." with the one finding that matters most.

## Pitfalls

- **Chaining everything** — some steps genuinely need the previous step's output before the next can run (e.g. reading snapshot refs before clicking). Chain safely; split where output is needed.
- **Over-silencing** — reporting is mandatory. A successful task with zero output is indistinguishable from a no-op. Always report the result, even if brief.
- **Parallel overflow** — `terminal` and `execute_code` share the same shell state. Parallel calls that modify the same state (cd, export, venv activate) will race. Use separate calls for stateful operations.
- **Speed over correctness** — the protocol demands speed, but verifying output before reporting is not hesitation. Read the tool output before declaring DONE.

## Verification

Load skill, then execute any instruction. Output contains zero filler words — only tool calls and a one-line report.
