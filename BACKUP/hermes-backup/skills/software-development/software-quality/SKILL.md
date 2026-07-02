---
name: software-quality
description: "Class-level umbrella for code quality lifecycle: test-first (TDD) → root-cause debugging → pre-commit verification. Subsections cover each phase with labeled workflows, plus integration patterns for chaining them together."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [software-quality, testing, tdd, debugging, code-review, verification]
    related_skills: [multi-agent-code-sprint, plan]
---

# Software Quality Lifecycle

Three complementary phases that form a complete quality pipeline:

| Phase | Skill | When | Core principle |
|-------|-------|------|----------------|
| **Test-First** | TDD | Before writing any production code | If you didn't watch the test fail, you don't know it tests the right thing |
| **Debug** | Systematic debugging | When a bug surfaces | NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST |
| **Verify** | Code review | Before commit / push | No agent should verify its own work |

Each phase has a strong "iron law" — respect the phase boundary. Do not debug during TDD. Do not commit without verification.

---

## Section A: Test-Driven Development

**Trigger:** User asks to implement a new feature, fix a bug, or refactor in a way that should have tests.

**Iron law:** `NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST`

### Core cycle: RED → GREEN → REFACTOR

**RED** — Write one minimal failing test showing what should happen:
- One behavior per test
- Clear descriptive name (no "and" in the name — split into two tests)
- Test real code, not mocks (unless truly unavoidable)
- Name describes behavior, not implementation

**Verify RED** — Run the specific test. Confirm:
- Test fails (not errors from typos)
- Failure message is expected
- Fails because feature is missing
- Test passes immediately? You're testing existing behavior. Fix the test.

**GREEN** — Write minimal code to pass:
- Cheating is OK in GREEN: hardcode return values, copy-paste, duplicate code
- We'll fix it in REFACTOR
- Don't add logging, edge case handling, or "improvements" beyond what the test demands

**Verify GREEN** — Run the specific test, then ALL tests:
```
pytest tests/test_feature.py::test_specific_behavior -v
pytest tests/ -q
```

**REFACTOR** — Clean up while keeping tests green:
- Remove duplication, improve names, extract helpers
- If tests fail during refactor: undo immediately, take smaller steps

**Repeat** — Next failing test for next behavior. One cycle at a time.

### Avoid horizontal slices

Do NOT write all tests first and then all implementation. Use vertical tracer bullets:

```
WRONG:  RED: test1,test2,test3 → GREEN: impl1,impl2,impl3
RIGHT:  RED→GREEN: test1→impl1 → RED→GREEN: test2→impl2
```

### Using with delegate_task

When dispatching subagents for implementation, enforce TDD in the goal:

```python
delegate_task(
    goal="Implement [feature] using strict TDD",
    context="""Follow TDD: write failing test FIRST, verify RED, write minimal code, verify GREEN. 
    Project test command: pytest tests/ -q
    Project structure: [describe relevant files]""",
    toolsets=['terminal', 'file']
)
```

### Verification checklist

- Every new function/method has a test
- Watched each test fail before implementing
- Each test failed for expected reason (feature missing, not typo)
- Wrote minimal code to pass each test
- All tests pass
- Edge cases and errors covered

### Common rationalizations to reject

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Test takes 30 seconds |
| "I'll test after" | Tests-after pass immediately — prove nothing |
| "Already manually tested" | Ad-hoc ≠ systematic |
| "Deleting X hours is wasteful" | Sunk cost fallacy |
| "TDD will slow me down" | TDD is faster than debugging |

### When stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write the wished-for API. Write the assertion first. |
| Test too complicated | Design too complicated. Simplify the interface. |
| Must mock everything | Code too coupled. Use dependency injection. |
| Test setup huge | Extract helpers. Still complex? Simplify the design. |

---

## Section B: Systematic Debugging

**Trigger:** Any test failure, bug, unexpected behavior, performance problem, build failure, or integration issue.

**Iron law:** `NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST`

### The Four Phases — complete each before proceeding

#### Phase 1: Root Cause Investigation

1. **Read error messages carefully** — stack traces, line numbers, file paths, error codes
2. **Build a tight feedback loop** — a command that goes RED on the exact symptom and goes GREEN when fixed:
   - Failing test → HTTP script → CLI invocation → headless browser → replay trace → throwaway harness → bisection
   - Tighten: make faster, sharpen signal, make more deterministic
   - For flaky bugs: raise reproduction rate (100x runs, add stress, narrow timing)
3. **Check recent changes** — `git log --oneline -10`, `git diff`, check for dependency/config changes
4. **Gather evidence in multi-component systems** — log what enters/exits each component boundary
5. **Trace data flow** — start from the error and trace upstream to the source

**Phase 1 completion criteria:**
- Error messages fully read and understood
- Tight loop command exists, has been run, goes RED on the exact symptom
- Loop is deterministic (or flake has high enough reproduction rate)
- Recent changes identified and reviewed
- Problem isolated to specific component/code
- Root cause hypotheses stated

#### Phase 2: Pattern Analysis

1. **Minimize reproduction** — shrink input/caller/config/data one step at a time
2. **Find working examples** in the same codebase
3. **Compare against references** — read the reference implementation completely
4. **Identify differences** — every difference, however small
5. **Understand dependencies** — what does this need that could be wrong?

#### Phase 3: Hypothesis and Testing

1. **Form 3-5 ranked falsifiable hypotheses** — each with a testable prediction
2. **Show ranked list to user if present** — they may have domain knowledge
3. **Test highest-ranked hypothesis with smallest probe**
4. **Change ONE variable at a time**
5. If user is present, show the ranked list before testing

#### Phase 4: Implementation

1. **Create failing test case** first (simplest possible reproduction)
2. **Implement single fix** — ONE change at a time, no "while I'm here" improvements
3. **Verify fix** — run regression test, then full suite
4. **Rule of Three** — if 3+ fixes failed, STOP and question the architecture

### Debugging tools reference

| Language | Tool | Start here |
|----------|------|------------|
| Python | `breakpoint()` + pdb | Add in source, run normally |
| Python | `python -m pdb` | No source edits |
| Python | debugpy | Remote/headless |
| Python | remote-pdb | Agent-friendly telnet REPL |
| Node.js | `node inspect` | Built-in, zero install |
| Node.js | `--inspect-brk` | Pause on line 1 |

Full pdb/node debugging reference: `skill_view(name="software-quality", file_path="references/python-debugpy.md")` and `references/node-inspect-debugger.md`.

### Red flags — STOP and follow process

- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "I don't fully understand but this might work"
- Proposing solutions before tracing data flow

---

## Section C: Pre-Commit Code Verification

**Trigger:** After implementing a feature or bug fix, before `git commit` or `git push`. User says "commit", "push", "ship", "done", "verify".

**Iron law:** No agent should verify its own work. Fresh context finds what you miss.

### Step 1 — Get the diff
```bash
git diff --cached   # if empty, try git diff, then git diff HEAD~1 HEAD
```

### Step 2 — Static security scan
```bash
git diff --cached | grep "^+" | grep -iE "(api_key|secret|password|token|passwd)\s*=\s*['\"][^'\"]{6,}['\"]"
```
Also check: shell injection (`os.system`, `shell=True`), `eval()/exec()`, `pickle.loads()`, SQL injection via string formatting.

### Step 3 — Baseline tests and linting
Detect project language, stash changes, run baseline to get `baseline_failures`, pop, run again. Only NEW failures block the commit.

### Step 4 — Self-review checklist
- No hardcoded secrets
- Input validation on user-provided data
- SQL queries use parameterized statements
- File operations validate paths
- External calls have error handling
- No debug prints, no commented-out code
- New code has tests (if suite exists)

### Step 5 — Independent reviewer subagent
Use `delegate_task` with the diff and static scan results. Fresh context, no shared history with implementer.

The reviewer returns JSON verdict: `{"passed": bool, "security_concerns": [], "logic_errors": [], "suggestions": [], "summary": "..."}`

Fail-closed: unparseable response = fail. Non-empty security_concerns or logic_errors = fail.

### Step 6 — Evaluate results
All passed → commit. Any failures → auto-fix loop (max 2 cycles).

### Step 7 — Auto-fix loop
Spawn a THIRD agent (not you, not the reviewer) that fixes ONLY the reported issues. Re-verify after each cycle. Escalate to user after 2 failed cycles.

### Step 8 — Commit
```bash
git add -A && git commit -m "[verified] <description>"
```

### Pre-implementation exploration (Code Spikes / UI Sketches)

Before committing to a real build — when user says "spike", "is this possible?", "compare A vs B":

**Code spike:** decompose → research → build → verdict. One directory per spike under `spikes/NNN-descriptive-name/`. Each closes with VALIDATED | PARTIAL | INVALIDATED verdict.

**UI sketch:** intake → 2-3 variants (different design stances) → head-to-head comparison → pick winner. Each variant is a standalone HTML file. Always ask about brand colors.

### Post-implementation simplification

After pre-commit verification passes, or when user says "simplify" / "clean up":

Run 3 parallel reviewer subagents (Code Reuse, Code Quality, Efficiency) — each with the complete diff. Apply fixes by risk tier: SAFE first (auto-apply), CAREFUL next (verify), RISKY (flag for human).

---

## Integration: Chaining the Three Phases

For a complete quality workflow:

1. **TDD** — Write test first, implement, see it pass
2. **Systematic debugging** — If TDD fails and you can't figure out why, switch to debugging mode
3. **Code review** — Before committing, run the verification pipeline

When fixing bugs: TDD creates the regression test → debugging finds root cause → verification prevents regressions.

---

## References

- `references/python-debugpy.md` — Python debugger setup (pdb, debugpy, remote-pdb)
- `references/node-inspect-debugger.md` — Node.js debugger setup (node inspect, CDP)
