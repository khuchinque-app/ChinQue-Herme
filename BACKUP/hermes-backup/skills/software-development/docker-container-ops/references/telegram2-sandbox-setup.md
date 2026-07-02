# Telegram2 Sandbox — Worked Example

**Session:** 2026-07-01  
**Goal:** Isolate a forex trading bot (Hermes profile `telegram2`) in a Docker sandbox so it can only read/write to `/sandbox/`  
**Bot:** @JrvsMine_Bot (token 8605457287)  
**Allowed user:** 8742787851

## Architecture

```
Telegram user → Hermes Gateway (telegram2 profile)
    → Docker terminal backend → python:3.11-slim container
        → /sandbox/   (writable, bound to host workspace/)
        → /tmp/       (tmpfs, wiped on restart)
        → Everything else read-only
```

## Files Created

| Path | Purpose |
|------|---------|
| `~/telegram2-sandbox/docker-compose.yml` | Sandbox container (python:3.11-slim, tail -f /dev/null) |
| `~/telegram2-sandbox/workspace/` | The ONLY writable directory (mounted as /sandbox) |
| `~/telegram2-sandbox/data/` | Reserved for future persistent data |
| `~/.hermes/profiles/telegram2/config.yaml` | Docker backend config + disabled toolsets |
| `~/.hermes/profiles/telegram2/SOUL.md` | Sandbox rules enforced via agent identity |

## Profile Config

```yaml
model:
  provider: nous
  default: deepseek/deepseek-v4-flash
terminal:
  backend: docker
  cwd: /sandbox
  docker_image: python:3.11-slim
  docker_extra_args: "--cap-drop=ALL --security-opt=no-new-privileges:true -v /home/khuchinque/telegram2-sandbox/workspace:/sandbox:rw"
agent:
  disabled_toolsets:
    - browser
    - computer_use
    - delegation
    - cronjob
    - kanban
    - discord
    - x_search
```

## SOUL.md Sandbox Section

```markdown
## ⛔ Sandbox Rules (WAJIB)
1. Hanya bisa baca/tulis file di /sandbox/
2. Semua command jalan di dalam Docker container
3. Dilarang install software tambahan
4. Dilarang akses jaringan internal
5. Data persisten hanya di /sandbox/
6. Jika diminta akses di luar /sandbox/, tolak dengan sopan
```

## Gotchas Hit

1. **alpine image fails with exit 99** — using `alpine:latest` with `apk add` in command caused restart loop. Root cause: `read_only: true` + missing user/group. Fixed: use `python:3.11-slim` with no package installs needed.
2. **cap-drop=ALL and user directive** — alpine doesn't have user `1000:1000` by default. Using `python:3.11-slim` without `user:` directive works because it runs as root by default (internally safe because cap-drop=ALL).
3. **Gateway runs on host, not in sandbox** — only `terminal` tool commands execute inside the Docker container. Hermes' `read_file`/`write_file`/`search_files`/`patch` tools still access the host filesystem through the Hermes process. Document this limitation in SOUL.md and disable file tools if full isolation is required.
4. **Polling conflict after gateway restart** — killing gateway then immediately starting a new one causes Telegram polling conflict ("terminated by other getUpdates request"). Telegram servers hold the session open for ~20s. The conflict retry mechanism (5 retries with escalating delays) resolves it automatically.
