---
name: hermes-install-hygiene
description: "Discipline of always checking whoami first, operating from the khuchinque user install, never running gateway as root, and verifying with ~/hermes-check.sh."
version: 1.0.0
author: Chinque
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [hermes, install, hygiene, gateway, dual-install, root]
    related_skills: [hermes-agent, systematic-debugging]
---

# Hermes Install Hygiene

## Overview

Hermes can be installed under any user. A dual install (e.g. root + khuchinque) creates **two gateways competing for the same port**, two sets of configs, two cron timers, and confusion about which config is the real one.

**Core principle:** One install, one user, single source of truth. Always verify before acting.

## The First Rule

```bash
whoami
# NOT root — should be khuchinque
```

If you're root, ALL commands you run operate on root's `.hermes`, not the user's. Pipeline files, skills, config — everything lives under the owner's user.

## Install Location Reference

| User | Hermes Path | Gateway | Status |
|------|-------------|---------|--------|
| **khuchinque** | `/home/khuchinque/.hermes` | `systemctl --user hermes-gateway` | **ACTIVE — use this** |
| root | `/root/.hermes` | `systemctl --user hermes-gateway` (or manual) | **REMOVED — masked** |

## Dual-Install Symptoms

- Two `hermes_cli.main gateway run` processes (one as root, one as khuchinque)
- Port 8642 shows a listener but `hermes config show` returns unexpected values
- Skills or cron jobs created in one session don't appear in another
- `hermes-check.sh` reports "a gateway is running as ROOT"
- `~/hermes-check.sh` reports failures that `sudo hermes-check.sh` passes (or vice versa)

## Prevention

### Before Any Hermes Operation

```bash
# 1. Confirm user
whoami
# → khuchinque ✓   → root ✗ STOP

# 2. Confirm the right .hermes
ls -la ~/.hermes/
# Ensure you're looking at /home/khuchinque/.hermes, not /root/.hermes

# 3. Quick health check
~/hermes-check.sh
# All greens? Proceed. Any red? Investigate before changing anything.
```

### Before Gateway Operations

```bash
# Check who owns running gateway processes
ps aux | grep hermes_cli

# If any line starts with root, kill it
sudo kill <pid>

# Verify no root systemd user service survives
sudo ls /root/.config/systemd/user/hermes-gateway.service* 2>/dev/null \
  && echo "ROOT SERVICE STILL EXISTS — remove it" \
  || echo "clean"
```

## When You Find a Dual Install

If you discover root also has Hermes installed:

1. **Stop the root gateway** — `sudo systemctl --user stop hermes-gateway` (run as root)
2. **Disable the root service** — `sudo systemctl --user disable hermes-gateway`
3. **Mask it** to prevent re-activation:
   ```bash
   sudo rm -f /root/.config/systemd/user/hermes-gateway.service*
   sudo rm -f /root/.config/systemd/user/hermes-gateway.service.d/override.conf
   systemctl --user daemon-reload
   # SIGHUP systemd --user to reload
   ```
4. **Verify** — `~/hermes-check.sh` should show no root-owned gateway
5. **Operate from khuchinque only** from this point forward

## Verification

Always end with `~/hermes-check.sh` and confirm:
- `✓ running as khuchinque`
- `✓ no root-owned gateway running`
- `✓ user service active`
- `✓ listening on 8642`

## Hermes Agent Integration

This skill is activated by context: whenever responding to a command about gateway, install, or config operations, check `whoami` first and confirm you're operating from the khuchinque user's `.hermes` directory (default working dir is `/home/khuchinque/hermes-pipeline`).
