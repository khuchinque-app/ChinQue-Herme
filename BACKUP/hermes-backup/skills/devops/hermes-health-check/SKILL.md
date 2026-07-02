---
name: hermes-health-check
description: "Run /home/khuchinque/hermes-check.sh every 3 hours via cron. If failures or warnings found, diagnose and fix immediately."
version: 1.1.0
author: Chinque
tags: [hermes, health-check, monitoring, cron, devops]
---

# Hermes Health Check

Run `/home/khuchinque/hermes-check.sh` on schedule (every 3 hours).

## If failures or warnings found

1. Review each ✗ and ⚠ line in the output
2. Determine the root cause
3. Fix it (restart gateway, fix UFW, update script, restore SOUL.md, etc.)
4. Re-run the script to confirm fix
5. Report: what was broken, what was fixed, new pass/fail/warn count

## Known failure modes

| Symptom | Fix |
|---------|-----|
| Gateway not active | `systemctl --user restart hermes-gateway` |
| Port 8642 not listening | Gateway down — start it |
| UFW missing port | `sudo ufw allow 8642/tcp` |
| SOUL.md missing owner | Add `vandaidr` reference |
| Curator not enabled | `hermes config set curator.enabled true` |
| Secrets permissions wrong | `chmod 600 ~/.hermes/.env` |
| **Config/Curator checks silently fail (⚠)** | Script hardcodes `~/.local/bin/hermes`; if Hermes binary is elsewhere (common), `hermes config show`, `hermes dump`, and `hermes curator status` return empty, producing false-positive warnings. Resolve with `HBIN="$(which hermes 2>/dev/null || echo /usr/local/bin/hermes)"`. See `references/hermes-check-migration.md` |

## Cron job

Created via: `hermes cron create "every 3 hours" "..." --name hermes-health-check --deliver origin`
