# OpenCode CLI — Full Reference

> This is archived supplementary content from the former standalone `opencode` skill.
> Its content has been absorbed into the `claude-code` umbrella as a reference.

## Overview

Use [OpenCode](https://opencode.ai) as an autonomous coding worker orchestrated by Hermes terminal/process tools. OpenCode is a provider-agnostic, open-source AI coding agent with a TUI and CLI.

## When to Use

- User explicitly asks to use OpenCode
- You want an external coding agent to implement/refactor/review code
- You need long-running coding sessions with progress checks
- You want parallel task execution in isolated workdirs/worktrees

## Prerequisites

- OpenCode installed: `npm i -g opencode-ai@latest` or `brew install anomalyco/tap/opencode`
- Auth configured: `opencode auth login` or set provider env vars
- Git repository for code tasks (recommended)

## Binary Resolution

```
terminal(command="which -a opencode")
terminal(command="opencode --version")
```

If needed, pin an explicit binary path: `$HOME/.opencode/bin/opencode`

## One-Shot Tasks

Use `opencode run` for bounded, non-interactive tasks (no pty needed):

```
terminal(command="opencode run 'Add retry logic to API calls'", workdir="~/project")
```

Attach context files with `-f`:

```
terminal(command="opencode run 'Review config for security issues' -f config.yaml", workdir="~/project")
```

## Interactive Sessions (Background)

```
terminal(command="opencode", workdir="~/project", background=true, pty=true)
process(action="submit", session_id="<id>", data="Implement OAuth refresh flow")
process(action="poll", session_id="<id>")
process(action="log", session_id="<id>")
process(action="write", session_id="<id>", data="\x03")  # Ctrl+C to exit
```

**Do NOT use `/exit`** — it opens an agent selector. Use Ctrl+C or `kill`.

## Common Flags

| Flag | Use |
|------|-----|
| `run 'prompt'` | One-shot execution and exit |
| `--continue` / `-c` | Continue the last session |
| `--session <id>` / `-s` | Continue a specific session |
| `--agent <name>` | Choose agent (build or plan) |
| `--model provider/model` | Force specific model |
| `--format json` | Machine-readable output |
| `--file <path>` / `-f` | Attach file(s) |
| `--thinking` | Show model thinking blocks |
| `--variant <level>` | Reasoning effort (high, max, minimal) |

## Session & Cost Management

```
opencode session list
opencode stats
opencode stats --days 7 --models anthropic/claude-sonnet-4
```

## Pitfalls

- Interactive TUI sessions require `pty=true`. `opencode run` does NOT need pty.
- `/exit` is NOT a valid command — use Ctrl+C.
- PATH mismatch can select the wrong binary.
- Avoid sharing one working directory across parallel sessions.
- Enter may need to be pressed twice in TUI.

## Verification

```
terminal(command="opencode run 'Respond with exactly: OPENCODE_SMOKE_OK'")
```

Success: output includes `OPENCODE_SMOKE_OK`.
