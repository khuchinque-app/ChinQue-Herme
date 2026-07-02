---
name: healthcheck-script-debugging
description: Debug health-check scripts whose warnings stem from stale paths or broken subcommand invocations.
version: 0.1.0
author: Hermes
platforms: [linux]
metadata:
  hermes:
    tags: [Debugging, Scripts, Healthcheck, Path, CLI]
---

# Debug Health-Check Script Warnings

Quickly diagnose health-check / alignment scripts that report warnings but no failures. The root cause is often a stale hardcoded binary path or a silently failing subcommand invocation. The key to finding it is understanding how each check determines its output: many verify by calling a CLI tool (e.g., `hermes`, `kubectl`, `systemctl`) and looking for a specific string in stdout/stderr. If the binary path is wrong or the subcommand errors, the check silently falls into the `warn` branch. This skill focuses on tracing each warning back to the exact shell logic that produced it.

## When to Use

- A script prints warnings (⚠) but no failures — especially when the reported issue "shouldn't happen."
- Multiple unrelated-looking warnings appear from the same script (often a shared binary path problem).
- The script hardcodes a binary path like `/usr/local/bin/<tool>` or `~/.local/bin/<tool>` but the tool is installed elsewhere.
- You're told to "fix this" on a health-check script and need to know where to look first.

## Prerequisites

- The health-check script is readable (Bash, Python, or similar).
- You have shell access to run the script and the commands it calls.

## How to Run

1. `read_file` on the health-check script.
2. For each warning, locate the exact check logic (usually a conditional or command substitution).
3. Run the underlying subcommand independently via `terminal` to confirm the silent failure.
4. `patch` or `write_file` to fix the root cause.
5. Re-run the script with `terminal` and verify warnings are gone.

## Quick Reference

| Check | Common pitfall |
|-------|----------------|
| `which <binary>` vs hardcoded path | Binary moved by package manager or install method changed. |
| `$(<cmd> 2>/dev/null \| grep "pattern")` | If cmd fails entirely, grep gets nothing → false negative. |
| `&& ok "..." \|\| wn "..."` | The `warn` path is a catch-all for *any* non-ok outcome. |
| `config show`, `dump`, `status` subcommands | These are often silent when the binary path is wrong. |

## Procedure

1. **Load the script.** Use `read_file` on the health-check script (e.g., `~/hermes-check.sh`). Look at each warning-producing line.
2. **Identify the command chain.** Most checks follow this pattern:
   ```bash
   "$HBIN" config show 2>/dev/null | grep -q "$PIPE" && ok "..." || wn "..."
   ```
   Note the binary variable (`$HBIN`), the subcommand (`config show`), the grep target (`$PIPE`), and the `2>/dev/null` silence.
3. **Test the binary path independently.** Run in `terminal`:
   ```bash
   which <binary>
   echo $?
   ```
   If the hardcoded path doesn't match `which`, that's the root cause for every warning using that variable.
4. **Test the subcommand independently.**
   ```bash
   /usr/local/bin/<binary> config show 2>&1 | head
   /usr/local/bin/<binary> dump 2>&1 | head
   ```
   Confirm the subcommand actually returns expected output.
5. **Apply the fix.** Usually one of:
   - Change the hardcoded path to `$(which <binary> 2>/dev/null || echo /fallback/path)`.
   - Or update the script's `$PATH` initialization.
   Use `patch` on the specific line.
6. **Re-run and verify.** Use `terminal` to execute the script again. All warnings should now pass.

## Pitfalls

- `2>/dev/null` hides CLI failure messages. When debugging, temporarily run commands without stderr suppression (`2>&1`) to see what actually breaks.
- Multiple warnings can stem from a **single** root cause (one broken binary path). Don't try to fix each warning individually until you've confirmed they're independent.
- `hermes config dump` and `hermes dump` are different commands. The script may use one while your intuition uses the other.
- The `|| wn "..."` branch is a catch-all: it triggers on exit code non-zero, empty pipe output, or unset variables. Always test the left side of the `&&` independently.
- If the binary lives at `/usr/local/bin/<tool>` but the script points to `~/.local/bin/<tool>`, symlinking might seem easier, but changing the script to resolve dynamically is more robust across reinstalls.
- **`source .venv/bin/activate` blocked in agent sessions:** Hermes execution guards may reject `source` commands. When verifying or testing a tool that requires a venv, always call the venv python directly — `/path/to/.venv/bin/python -c "..."` instead of `source .venv/bin/activate && python -c "..."`.
- **Ad-hoc verification scripts:** Create focused one-off scripts under `/tmp/hermes-verify-<name>.py` (or `.sh`) to test specific behaviors, run them via `terminal`, then delete. This is cleaner than long inline terminal commands and provides reproducible verification.

## Verification

```bash
bash ~/hermes-check.sh
```

Expected: `pass:22  warn:0  fail:0` — or the equivalent for your script.
