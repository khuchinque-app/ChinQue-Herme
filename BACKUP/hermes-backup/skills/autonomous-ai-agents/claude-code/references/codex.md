# Codex CLI — Full Reference

> This is archived supplementary content from the former standalone `codex` skill.
> Its content has been absorbed into the `claude-code` umbrella as a reference.

## Overview

Delegate coding tasks to [Codex](https://github.com/openai/codex) (OpenAI's autonomous coding agent CLI) via the Hermes terminal.

## When to use

- Building features
- Refactoring
- PR reviews
- Batch issue fixing

Requires the codex CLI and a git repository.

## Prerequisites

- Codex installed: `npm install -g @openai/codex`
- OpenAI auth configured: either `OPENAI_API_KEY` or Codex OAuth credentials
- **Must run inside a git repository** — Codex refuses to run outside one
- Use `pty=true` in terminal calls — Codex is an interactive terminal app

## One-Shot Tasks

```
terminal(command="codex exec 'Add dark mode toggle to settings'", workdir="~/project", pty=true)
```

For scratch work:
```
terminal(command="cd $(mktemp -d) && git init && codex exec 'Build a snake game in Python'", pty=true)
```

## Background Mode (Long Tasks)

```
terminal(command="codex exec --full-auto 'Refactor the auth module'", workdir="~/project", background=true, pty=true)
process(action="poll", session_id="<id>")
process(action="log", session_id="<id>")
process(action="submit", session_id="<id>", data="yes")
process(action="kill", session_id="<id>")
```

## Key Flags

| Flag | Effect |
|------|--------|
| `exec "prompt"` | One-shot execution, exits when done |
| `--full-auto` | Sandboxed but auto-approves file changes in workspace |
| `--yolo` | No sandbox, no approvals (fastest, most dangerous) |
| `--sandbox danger-full-access` | No Codex sandbox; useful when bubblewrap fails |

## Hermes Gateway Caveat

When invoking Codex from a Hermes gateway context (Telegram-driven sessions), bubblewrap/user-namespace may fail. Use:

```
codex exec --sandbox danger-full-access "<task>"
```

## PR Reviews

```
terminal(command="REVIEW=$(mktemp -d) && git clone https://github.com/user/repo.git $REVIEW && cd $REVIEW && gh pr checkout 42 && codex review --base origin/main", pty=true)
```

## Parallel Issue Fixing with Worktrees

```
terminal(command="git worktree add -b fix/issue-78 /tmp/issue-78 main")
terminal(command="codex --yolo exec 'Fix issue #78'", workdir="/tmp/issue-78", background=true, pty=true)
terminal(command="git worktree add -b fix/issue-99 /tmp/issue-99 main")
terminal(command="codex --yolo exec 'Fix issue #99'", workdir="/tmp/issue-99", background=true, pty=true)
process(action="list")
terminal(command="cd /tmp/issue-78 && git push -u origin fix/issue-78")
terminal(command="git worktree remove /tmp/issue-78")
```

## Rules

1. **Always use `pty=true`** — Codex hangs without a PTY
2. **Git repo required** — use `mktemp -d && git init` for scratch
3. **Use `exec` for one-shots** — runs and exits cleanly
4. **`--full-auto` for building** — auto-approves changes within sandbox
5. **Background for long tasks** — use `background=true` + `process` tool
6. **Parallel is fine** — run multiple Codex processes at once
