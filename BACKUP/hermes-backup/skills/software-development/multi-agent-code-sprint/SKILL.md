---
name: multi-agent-code-sprint
description: "Orchestrate parallel subagents to execute a batch of independent code patches driven by a manifest."
version: 1.1.0
tags: [pipeline, delegation, parallel, subagent, patch, sprint, manifest, orchestration]
related_skills: [simplify-code, plan, systematic-debugging, requesting-code-review]
---

# Multi-Agent Code Sprint — Manifest-Driven Parallel Patching

Execute a batch of independent code changes (bug fixes, features, or updates across multiple modules/cycles) by dispatching parallel subagents, then deploying, verifying, and tracking results.

**Core principle:** When work items are **independent** (no shared state, no ordering dependency), parallel dispatch beats sequential. One wave of N subagents costs roughly the wall-clock time of one — the latency of the slowest agent, not the sum.

This skill covers the full lifecycle: manifest analysis → wave sizing → dispatch → deployment → verification → tracking.

## When to Use

Trigger when the user signals a batch of independent work:

- "finish all the updates in this section"
- "call all your agents and subagents"
- "patch everything in this file / cycle / PR"
- "apply all the bug fixes from the reports"
- The user hands you a JSON manifest, YAML config, or structured list of pending tasks with clear work units.

**Do NOT use** when:
- Tasks have ordering or data dependencies (e.g., task B needs task A's output). Serialize those with `delegate_task` one at a time.
- Tasks all touch the same file. Serialize to avoid merge conflicts.
- The work is creative/exploratory (use `spike` instead).

## The Process

### Phase 1 — Manifest analysis

Read the structured list of pending work. Common formats:

- JSON array (e.g., `next_session_priorities` from an operation manifest)
- Markdown checklist (`- [ ] Task`)
- Directory listing of cycles/tickets/modules that need work

For each item, classify:
- **Code patch** — edit existing file(s) → delegate to `Dev` role agent
- **Create** — new file(s) from scratch → delegate to `Scout+Repo+Dev` chain
- **Test** — run existing tests against a skill → delegate to `Dev+BugBounty`
- **Tracker** — update manifest, evolutions, status files → do yourself (takes seconds)

Group items into **independent waves** — items that can run simultaneously with no shared file writes.

### Phase 2 — Wave dispatch

**Wave sizing rules:**
- Up to 3 tasks per `delegate_task` batch for this user (configured via `delegation.max_concurrent_children`).
- If you have 4+ independent items, dispatch in waves: first 3 in batch, next batch after those complete, etc. The user's parallel budget applies per batch, not per session.
- Use `delegate_task` **batch mode** (`tasks=[...]`) for items in the same wave so they run concurrently.

**Context contract for each task:**
Every delegated task MUST include:

1. **Exact file paths** — absolute paths to every file the subagent needs to read and write.
2. **Bug/spec source** — what file contains the spec (bug report, design doc, ticket). Say "Read the bug report at <path>" so they don't guess.
3. **Exact deliverable** — what constitutes success: "Patch file X with all fixes from bug report Y, verify Z, return a summary."
4. **Constraints** — "Python stdlib only", "single-file", "preserve exit code convention", "no pip installs."
5. **Verification command** — the exact command to run to confirm it works (e.g., syntax check, targeted test).

**Toolsets for code-patch tasks:** `terminal`, `file`, `coding`, `search` — enough to read files, patch, verify.

### Phase 3 — Permission & deployment handling

Subagents often cannot write to root-owned or permission-restricted target directories. This is the **most common blocking issue**.

**Detection:** If a subagent reports "Permission denied" on write, the file at the target path has restricted ownership/permissions.

**Fix:** Change ownership of the pipeline/work directory once, not file-by-file:
```bash
sudo chown -R $USER:$USER /path/to/pipeline/
```

**Temp-file pattern:** Some subagents write patched content to `/tmp/` when blocked. After fixing permissions, deploy from temp:
```bash
cp /tmp/patched-file.py /target/path/patched-file.py
```
Then verify the deployed file.

### Phase 4 — Verification

For each patch, verify in this order:

1. **Syntax check** (Python): `python3 -c "import ast; ast.parse(open('file.py').read()); print('SYNTAX OK')"`
2. **Targeted verification** — run the verification script the subagent left at `/tmp/verify-*.py`
3. **Structural check** — `wc -l` to confirm size change is plausible (not a zero-byte write)
4. **Tracker consistency** — verify evolutions.json and manifest JSON are valid and consistent

### Phase 5 — Tracker update

After all patches are deployed and verified:

1. Update `evolutions.json` in each cycle directory with new version and metrics
2. Update the phase/operation manifest with:
   - Which patches were applied
   - Bug counts
   - Verification status per patch
   - Agent status
3. Verify the tracker files: `python3 -c "import json; json.load(open('file.json')); print('OK')"`

## Wave-ordering heuristics

When you have a mix of work types, order waves for maximum parallel throughput:

| Work type | Wave priority | Reason |
|---|---|---|
| Independent code patches | Wave 1 | No dependencies, full parallel |
| Skill creation (multi-file) | Wave 1 or 2 | Independent of patches |
| HONCHO / integration tests | Wave 2 | Needs patches deployed first |
| Tracker/manifest updates | Wave 3 | Needs all results to report |

## Example: Full sprint lifecycle

```
1. Read manifest → identify 6 independent patch items + 1 creation + 1 test
2. Wave 1: dispatch 3 code patches in parallel (delegate_task batch)
3. Wave 2: dispatch remaining 3 patches + creation task in parallel
4. Detect permission block: sudo chown -R user pipeline/
5. Deploy temp files to target directories
6. Verify all 7 deliverables (syntax + targeted checks)
7. Wave 3: run HONCHO integration test
8. Update all evolutions.json + manifest
9. Verify tracker consistency (JSON validation)
```

## Pitfalls

- **Permission blindness:** Subagents don't know the target dir is root-owned until they try to write. Fix ownership early (step 0) to avoid wasting subagent cycles on retries. After fixing, check `/tmp/` for orphaned patched files that subagents left behind when they couldn't write to the target.

- **Editable install SSH remote:** Hermes or any other editable (`pip install -e`) package may have its git `origin` set to SSH (`git@github.com:...`). If the server has no SSH key loaded, `git pull` fails with `Permission denied (publickey)`. Fix: switch remote to HTTPS (`git remote set-url origin https://github.com/org/repo.git`), then `git pull && venv/bin/pip install -e .`.
- **Over-fanning:** Max 3 concurrent subagents per batch. If you have 6 items, use 2 waves. Don't squeeze 6 into one `tasks` array — it gets silently trimmed or rejected.
- **Stale temp files:** A subagent that finished but couldn't deploy leaves a patched file at `/tmp/`. Check for these before re-dispatching the same task.
- **Missing dependencies:** A task that looks independent but reads a file another task is patching = merge conflict. Check for overlapping file paths before batching.
- **Verification scripts at /tmp:** Subagents write verification at `/tmp/verify-*.py`. Run them; they test the specific bugs the subagent fixed. Don't skip this step.
- **Manifest drift:** If a subagent fails to complete, mark the item as `cancelled` with a reason in the manifest rather than omitting it. Gaps are visible data; silence looks like nothing happened.
- **Naming evolutions.json:** Each cycle/ticket gets its own evolutions.json with skill name, version, change directive (CREATE/PATCH/DELETE), and metrics (effectiveness/usability/freshness each 1–10).

## Related

- `simplify-code` — parallel code review/cleanup of recent changes (run AFTER a sprint)
- `plan` — write an actionable plan before executing a sprint
- `systematic-debugging` — single-bug root cause analysis (when a sprint item needs investigation)

## References

A worked example (22 bugs across 5 cycles, 6 subagent dispatches) is at `references/operation-blacksmith-patch-sprint.md`. Load with:

```
skill_view(name='multi-agent-code-sprint', file_path='references/operation-blacksmith-patch-sprint.md')
```

The full hermes self-audit diagnostic checklist is at `references/hermes-self-audit.md`. Load with:

```
skill_view(name='multi-agent-code-sprint', file_path='references/hermes-self-audit.md')
```
