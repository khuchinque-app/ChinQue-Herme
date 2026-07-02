---
name: node-js-toolchain-setup
description: >-
  Install and configure npm/pnpm/Node.js tooling as a non-root user on a VPS
  or shared environment. Covers the three canonical install strategies,
  PATH integration, and the common EACCES failure modes that block
  `npm install -g` and corepack.
version: 1.1.0
author: Chinque
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [node, npm, pnpm, toolchain, non-root, vps, permissions, EACCES]
    related_skills: [self-hosted-webapp, hermes-install-hygiene]
---

# Node.js Toolchain Setup (Non-Root)

## Overview

On many VPS setups Node.js is installed globally (via distro or nvm) but
`npm install -g` fails with `EACCES` because `/usr/lib/node_modules/` is
owned by root. Corepack similarly fails when it tries to create a symlink
at `/usr/bin/pnpm`.

This skill covers three strategies to get a working `pnpm` (or any global
JS tool) without sudo — and how to choose between them.

## The Three Strategies

### Strategy A — npm user prefix (simplest, works every time)

```bash
mkdir -p ~/.npm-global
npm config set prefix ~/.npm-global
export PATH="$HOME/.npm-global/bin:$PATH"

# Now install anything globally:
npm install -g pnpm
pnpm --version            # "10.29.3"
```

**Persist the PATH** by adding to `~/.bashrc` or `~/.profile`:
```bash
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
```

**Pros:** One-time, works for every npm global tool, no external download.
**Cons:** Only covers npm-originated tools; corepack-driven installs (like
pnpm via `corepack enable`) still try `/usr/bin/`.

### Strategy B — Standalone pnpm installer

```bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

Installs to `~/.local/share/pnpm/` and automatically adds it to PATH
via shell config. **But** this only works if `~/.local/share/pnpm/` is
already in PATH — the installer prints a warning and exits 1 if not.

**Fix when installer complains about PATH:**
```bash
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# then re-run the installer, OR just curl the binary directly:
curl -fsSL https://get.pnpm.io/install.sh | PNPM_HOME="$HOME/.local/share/pnpm" sh -
```

**Pros:** Canonical install, auto-updates via `pnpm self-update`.
**Cons:** The PATH hoops; occasional permission issues.

### Strategy C — nvm (Node Version Manager)

If you need multiple Node versions or a fresh Node install owned by your user:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
# reload shell or:
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install 22
nvm use 22
npm install -g pnpm     # now works without EACCES
```

**Pros:** Clean per-user Node install, no system Node dependency.
**Cons:** Heavier than needed if Node is already globally installed.

## What NOT to do

| Approach | Why not |
|----------|---------|
| `sudo npm install -g` | Creates root-owned symlinks; `pnpm` later tries to write to `/root/.npm/` and fails for non-root |
| `sudo chown -R $(whoami) /usr/lib/node_modules/` | Breaks for other users, not portable, fragile across package manager updates |
| `corepack enable` + ignore EACCES | corepack's symlink target is hardcoded to `/usr/bin/` — `EACCES` is unavoidable without sudo |

## Common Failure: "pnpm: command not found" after install

### Symptom
```
install.sh: line 239: pnpm: command not found
```

The install script ran `corepack enable` which output `[OK] pnpm installed`
even though the symlink creation failed — the exit code was swallowed.
pnpm was never actually placed on PATH.

### Diagnosis
```bash
which pnpm         # not found
ls ~/.npm-global/bin/pnpm   # exists? → PATH not set
ls ~/.local/share/pnpm/bin/pnpm  # exists? → wrong install strategy
```

### Fix
Apply Strategy A, then re-run the install script that failed:
```bash
export PATH="$HOME/.npm-global/bin:$PATH"
bash install.sh --local   # or the script that needs pnpm
```

## Mission Control Agent Registration

When registering agents with Mission Control (http://localhost:3000):

**Prerequisites:** Visit `/setup` in a browser first to create the admin
account. The API is locked until that's done.

**API key:** Generated at `/setup` time, stored in `.data/.auto-generated`.

**Registration constraints:**
| Constraint | Details |
|------------|---------|
| Valid roles | `coder`, `reviewer`, `tester`, `devops`, `researcher`, `assistant`, `agent` |
| Name rules | 1-63 alphanumeric, dots, hyphens, underscores. **No spaces.** |
| Rate limit | ~8 registrations per minute; then `429 Too many attempts` — wait 30-60s |

**Register via API:**
```bash
curl -X POST "$MC_URL/api/agents/register" \
  -H "x-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name":"AgentName","role":"coder","description":"..."}'
```

## Verification

After any strategy, confirm:
```bash
node --version
npm --version
pnpm --version
which pnpm
```
