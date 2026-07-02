---
name: docker-container-ops
description: "Docker container setup, debugging, networking, and multi-container orchestration. Covers the full container lifecycle: Dockerfiles, docker-compose, SSH access, port mapping troubleshooting, UFW routing, Python portable installs, and bootstrap scripting."
version: 1.0.0
author: Chinque
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [docker, container, infrastructure, devops, networking, ssh]
    related_skills: [systematic-debugging, plan]
---

# Docker Container Ops

## Scope

Setting up, debugging, and orchestrating Docker containers for development
environments. This skill covers:

- Container project structure (Dockerfile + docker-compose + setup.sh)
- SSH access configuration (root login, password auth)
- Port mapping troubleshooting (orphan bridges, UFW)
- Multi-container planning (unique subnets, non-conflicting ports)
- Network isolation (no outbound from container)
- Python installs in network-restricted containers

---

## Container Project Template

Every container project follows this structure:

```
/container<N>/
├── Dockerfile          # Ubuntu 22.04 base image
├── docker-compose.yml  # Service definition, ports, networks, volumes
├── setup.sh           # Build + start + print connection info
├── root/              # Bind-mounted to /root/data
└── hermes/            # Bind-mounted to /root/hermes
```

### Dockerfile Pattern (Ubuntu 22.04 + SSH + dev tools)

```dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get install -y \
    curl wget git vim nano htop tmux tree \
    python3 python3-pip python3-venv python3-dev \
    nodejs npm \
    openssh-server \
    ca-certificates software-properties-common \
    build-essential libssl-dev \
    net-tools iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel

RUN mkdir -p /var/run/sshd \
    && echo 'root:hermes123' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

RUN mkdir -p /root/hermes /root/data

WORKDIR /root/hermes
EXPOSE 22 3000
CMD ["/usr/sbin/sshd", "-D"]
```

### docker-compose.yml Pattern

```yaml
version: '3.8'

services:
  rootN:
    build: .
    image: hermes-rootN:latest
    container_name: rootN
    hostname: rootN
    restart: unless-stopped
    deploy:
      resources:
        limits: { cpus: '1.0', memory: 4G }
        reservations: { cpus: '0.5', memory: 2G }
    ports:
      - "220N:22"
      - "300N:3000"
    volumes:
      - ./root:/root/data
      - ./hermes:/root/hermes
    networks:
      - rootN_net
    stdin_open: true
    tty: true
    command: /usr/sbin/sshd -D

networks:
  rootN_net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.26.N.0/24
```

### setup.sh Pattern

```bash
#!/bin/bash
set -e
# Detect compose command (new plugin vs old standalone)
if docker compose version &> /dev/null; then COMPOSE_CMD="docker compose"
elif docker-compose version &> /dev/null; then COMPOSE_CMD="docker-compose"
else COMPOSE_CMD=""; fi

# Install Docker if missing
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker; systemctl start docker
fi

mkdir -p root hermes; chmod 755 root hermes
$COMPOSE_CMD build && $COMPOSE_CMD up -d
$COMPOSE_CMD ps
```

---

## Multi-Container Port/Subnet Planning

Assign unique ports and subnets per container to avoid conflicts.
Follow the same `N` throughout a project.

| Container | SSH Port | App Port | Subnet        |
|-----------|----------|----------|---------------|
| rootN     | 220N     | 300N     | 172.26.N.0/24 |

Example: root2 → SSH 2202, App 3002, subnet 172.26.2.0/24

**Always verify before bringing up a new container:**
```bash
# Check for subnet conflicts
ip route show | grep 172.26.<N>

# Check for port conflicts
ss -tlnp | grep ":220<N>\|:300<N>"
```

---

## SSH Automation Functions

For quick container access from local terminal or VPS, use the functions
in `templates/ssh-functions.sh`. Source the file in your shell rc:

```bash
source /path/to/ssh-functions.sh

sshc 3    # local terminal → VPS → container root3
sshcv 4   # inside VPS → container root4 (via loopback)
sshd 2    # docker exec into root2
```

The template handles all 5 containers (root1-root5) with the standard
port mapping: container N → SSH 220N, App 300N.

---

## Container Config Database

Keep all container metadata, bugs, port maps, and access commands in a
SQLite database. See `references/flask-webapp-deployment.md` for the complete Flask+Gunicorn web application container pattern (upload limits, file type whitelist, folder navigation API, session auth, password change, mobile UI patterns including long-press context menu and hamburger menu with pointer-events fix, UFW rules, and volume mount strategy).

See `references/container-config-db.md` for the full
schema and query examples.

```bash
sqlite3 containers.db "SELECT * FROM v_summary;"
sqlite3 containers.db "SELECT * FROM v_bugs;"
```

---

## BUG: Docker Port Mapping Broken (Connection Reset)

### Symptom
TCP connects to `127.0.0.1:<host_port>` but immediately gets `Connection reset by peer`.
Inside the container, services listen correctly. Docker-proxy processes are running.

### Root Cause 1 — Orphan Bridge on Same Subnet
A previous `docker compose down` left an orphan bridge on the same subnet as the
active container's network. The kernel routing table lists the DOWN bridge first,
so return packets hit it and get dropped.

**Diagnose:**
```bash
ip -4 route show | grep <your_subnet>
```
If two routes on the same subnet, one shows `linkdown` — that's the orphan.

**Fix:**
```bash
sudo ip link delete br-<orphan_id>
```

### Root Cause 2 — UFW Blocks Docker Forwarded Traffic
UFW's default `deny (routed)` policy applies to all docker bridge traffic
passing through the FORWARD chain. Even though docker-proxy handles the
inbound connection, the return packets go through iptables FORWARD.

**Diagnose:**
```bash
sudo ufw status verbose | grep "deny (routed)"
```
If `Default: deny (routed)` is present, Docker container routing is blocked.

**Fix:**
```bash
# Find the bridge interface for the container's network
NETWORK_NAME="container<N>_root<N>_net"
BRIDGE_ID=$(docker network inspect "$NETWORK_NAME" --format '{{.Id}}' | cut -c1-12)
BRIDGE="br-${BRIDGE_ID}"

sudo ufw route allow in on "$BRIDGE" out on "$BRIDGE"
```

**Prevention** (add to bootstrap script):
1. Check `ip route show` for subnet conflicts before `docker compose up`
2. Check `ss -tlnp` for port conflicts before `docker compose up`
3. Add the UFW route rule immediately after `docker compose up -d`

---

## Container Isolation ("What inside cannot be out")

For containers that should have **no outbound network access**:

1. UFW `deny (routed)` already blocks container outbound by default
2. Do NOT add a MASQUERADE rule for the container's bridge
3. The container can still receive inbound connections via port mapping
4. Do NOT install unnecessary packages or agent software inside
5. Keep the container minimal — only what debugging requires

**Check isolation:**
```bash
# Inside container — should hang/fail
ping -c 1 8.8.8.8
curl -s http://example.com
```

---

## Hermes Profile Sandboxing (Docker Terminal Backend)

Isolate a Hermes Agent profile by running all its shell commands inside a restricted Docker container. Use for untrusted bots or profiles that need filesystem jail.

### Architecture

```
Telegram user → Hermes Gateway (profile: telegram2)
    → Docker terminal backend → container (read-only rootfs)
        → /sandbox/   (writable, bound to host dir)
        → /tmp/       (tmpfs, wiped on restart)
```

### Step 1 — Create the Sandbox Container

```yaml
# docker-compose.yml
services:
  telegram2-sandbox:
    image: python:3.11-slim        # Any image with python3 + bash
    container_name: telegram2-sandbox
    restart: unless-stopped
    stdin_open: true
    tty: true
    working_dir: /sandbox
    volumes:
      - ./workspace:/sandbox:rw     # The ONLY writable path
    tmpfs:
      - /tmp:size=100M
    environment:
      - HOME=/tmp
      - TERM=xterm
    command: tail -f /dev/null
```

Key restrictions:
- **`volumes`** — only the sandbox workspace is writable; nothing else on the host
- **`tmpfs`** — `/tmp` is ephemeral; data gone on restart
- **No `cap_add`** — container gets Docker's default restricted capabilities
- **No `privileged`** — standard security

### Step 2 — Configure Hermes Profile

```bash
hermes -p <profile> config set terminal.backend docker
hermes -p <profile> config set terminal.cwd /sandbox
hermes -p <profile> config set terminal.docker_image python:3.11-slim
```

For hardened sandbox with **capability drops and extra volume mounts**, use `docker_extra_args`:

```bash
hermes -p <profile> config set terminal.docker_extra_args \
  "--cap-drop=ALL --security-opt=no-new-privileges:true \
   -v /home/user/telegram2-sandbox/workspace:/sandbox:rw"
```

⚠️ **`docker_extra_args` quoting:** The value is passed directly to the Docker CLI, not through a shell. If it contains spaces, wrap the entire value in quotes. Use a single pair of double quotes around the whole string. Do not use `-v` shorthand for `--volume`.

### Step 2.5 — Verify YAML is Well-Formed

After `hermes config set`, the resulting `config.yaml` may contain broken YAML:
```yaml
# BROKEN — `hermes config set agent.disabled_toolsets [...]` produces:
agent:
  disabled_toolsets: '[''browser'',''delegation'']'

# FIX — manually edit to proper YAML list:
agent:
  disabled_toolsets:
    - browser
    - delegation
```
The `hermes config set` command stores Python repr of the list, which YAML parsers choke on. Always verify after setting list values.

### Step 3 — Restrict Tools

Disable tools that could escape the sandbox or access the host directly.
Only tool-based operations that go through the Docker `terminal` backend are contained.
Hermes' `read_file`, `write_file`, `search_files`, and `patch` tools still access the **host** filesystem through the Hermes process — NOT the container:

```bash
hermes -p <profile> config set agent.disabled_toolsets "['browser','computer_use','delegation','cronjob','kanban','discord']"
```

**Safe to keep enabled:** `web`, `web_extract`, `vision`, `image_gen`, `memory`, `session_search` — these either only make HTTP calls or operate within the Hermes profile's own database, not the host filesystem.

**Dangerous tools that MUST be disabled for sandbox:**
- `browser` — runs Chromium on the host, can access localhost
- `computer_use` — full desktop access
- `delegation` — can spawn subprocesses that escape the container
- `cronjob` — creates persistent jobs on the host
- `kanban` — multi-agent coordination tool

### Step 3.5 — Gateway vs Docker Backend Gotcha

The **gateway process itself** runs on the host, not inside the sandbox container. Only commands invoked through Hermes' `terminal` tool are executed inside the Docker container. This means:

- `terminal()` calls → Docker container ✅
- `read_file()` / `write_file()` / `search_files()` / `patch()` → host filesystem ❌
- `web_extract()` → host network ❌

For complete isolation, either:
1. Disable `file` tools entirely via `disabled_toolsets` and let the profile only use terminal-based file operations
2. Accept that the Hermes profile itself has access to `~/.hermes/` and restrict only shell commands

### Step 4 — SOUL.md Enforcement

Add sandbox rules to the profile's `SOUL.md` so the agent itself knows its boundaries:
```markdown
## ⛔ Sandbox Rules (WAJIB)
Kamu berjalan dalam sandbox terisolasi. Aturan ketat:
1. Hanya bisa baca/tulis file di /sandbox/
2. Semua command jalan di dalam Docker container
3. Dilarang install software tambahan tanpa izin
4. Dilarang akses jaringan internal
5. Data persisten hanya di /sandbox/
6. Jika diminta akses di luar /sandbox/, tolak dengan sopan
```

### What This Protects Against

| Threat | Mitigation |
|--------|-----------|
| Agent runs `rm -rf /` | Read-only rootfs — can't modify system files |
| Agent writes to host | Only `/sandbox` is mounted; everything else is isolated |
| Agent installs malware | `cap-drop=ALL` + no outbound by default |
| Agent accesses other profiles | Hermes `~/.hermes/` is NOT mounted in container |
| Agent survives restart | Only `/sandbox/workspace/` persists |

### Pitfalls

- **Gateways and Docker backends:** The gateway process itself runs on the host (not inside the sandbox). Only the `terminal` tool commands execute inside the container. Hermes' `read_file`, `write_file`, `search_files`, and `patch` tools still access the host filesystem through the Hermes process — not the container. For full isolation, also restrict those tools via the profile's config (disabled toolsets or filesystem permissions).
- **`docker_extra_args` quoting:** When passing paths with spaces or special characters in `docker_extra_args`, wrap the entire value in quotes. The value is passed to the Docker CLI, not a shell.
- **Container must be running before gateway starts:** Hermes' Docker backend creates its own container if one doesn't exist, but uses different settings. Pre-create the sandbox container with `docker compose up -d` and let Hermes reuse it (or let Hermes create one and accept its defaults).
- **Image selection:** `python:3.11-slim` works for most cases. If the agent needs `curl`, `git`, or `node`, use `nikolaik/python-nodejs:python3.11-nodejs20` or custom-build with those tools pre-installed.
- **Permission denied inside container:** If the container runs as `root` (default), files written to the bound volume will be owned by `root`. If the host user needs to access those files, set `user: "${UID:-1000}:${GID:-1000}"` in docker-compose or use `chown` after writing.

---

## Python Install in Network-Restricted Containers

When a container has no outbound internet and Hermes/WebUI needs Python ≥3.11
(container has 3.10):

### Staging packages from the host (air-gapped containers)

When a container has no outbound internet access, stage packages from the host:

```bash
# Host: download wheel for the container's Python version + platform
pip3 download PACKAGE_NAME --python-version 3.10 --platform manylinux2014_x86_64 --no-deps -d /tmp/wheels/

# Copy wheel into container
sudo docker cp /tmp/wheels/PACKAGE.whl rootN:/tmp/

# Container: install with --no-index to skip network
sudo docker exec rootN pip3 install /tmp/PACKAGE.whl --no-index
```

**Pitfall:** `--no-index` is critical — without it pip still queries PyPI (hangs forever with no network).

### Apt packages

When a container needs a missing apt package:
```bash
# Copy .deb from host
dpkg -L PACKAGE | head        # Check if already on host
apt-get download PACKAGE      # Download .deb on host
sudo docker cp /tmp/PACKAGE.deb rootN:/tmp/
sudo docker exec rootN dpkg -i /tmp/PACKAGE.deb
```

---

### Option 1 — Portable Python Build (recommended)

Download a manylinux-compatible standalone Python from
`python-build-standalone` (Astral): compiled against glibc 2.17+.

```bash
# On host (has network)
cd /tmp
wget "https://github.com/astral-sh/python-build-standalone/releases/download/\
20250317/cpython-3.12.9+20250317-x86_64-unknown-linux-gnu-install_only.tar.gz"

# Copy into container
sudo docker cp /tmp/python3.12-portable.tar.gz rootN:/tmp/

# Extract in container
sudo docker exec rootN bash -c '
mkdir -p /usr/local/python3.12
cd /usr/local/python3.12 && tar -xzf /tmp/python3.12-portable.tar.gz
/usr/local/python3.12/python/bin/python3.12 --version
'
```

The portable build ships its own `libpython3.12.so` and links against the
system glibc. Works across Ubuntu 22.04 → 24.04 as long as glibc is ≥2.17.

### Option 2 — Build from Source (slow, needs glibc compat)
```bash
wget https://www.python.org/ftp/python/3.12.9/Python-3.12.9.tar.xz
sudo docker cp Python-3.12.9.tar.xz rootN:/tmp/
sudo docker exec rootN bash -c '
cd /tmp && tar -xf Python-3.12.9.tar.xz && cd Python-3.12.9
./configure --prefix=/usr/local/python3.12 --with-ensurepip=install
make -j$(nproc) && make install
'
```
Note: `--enable-optimizations` adds PGO (profile-guided optimization) that
doubles build time — skip it in containers unless you need maximum perf.

---

## Master Bootstrap Script Pattern

For deploying N containers at once:

```bash
#!/bin/bash
set -euo pipefail
CONTAINERS=(2 3 4 5)
PORTS_SSH=(2202 2203 2204 2205)
PORTS_APP=(3002 3003 3004 3005)
SUBNETS=(172.26.2.0/24 172.26.3.0/24 172.26.4.0/24 172.26.5.0/24)
NAMES=(root2 root3 root4 root5)

# 1. Pre-flight: check subnet/port conflicts
# 2. Open UFW ports
# 3. Build & start each
# 4. Wait for SSH
# 5. Add UFW route rules per bridge
# 6. Print summary
```

See `templates/bootstrap-all.sh` for the full example.

---

## Pitfalls

- **Docker permission denied.** If `docker compose` or `docker ps` says "permission denied while trying to connect to the Docker API socket," the user is not in the `docker` group. Fix: `sudo usermod -aG docker $USER`, then use `sg docker -c "command"` for the current session (no re-login needed). Do not run Docker commands with `sudo` — it changes the runtime context and can break volume mounts.
- **Scope creep.** When the user says "write this one file only" or "don't implement anywhere else," obey strictly. Make the edit to the single requested file and stop. Testing is fine — implementation outside the requested scope is not. If you catch yourself planning additional files, stop and re-read the user's scope instruction.
- **Orphan bridge subnet conflict.** A leftover docker-compose network on the same subnet as a new one will silently break port mapping. Always `ip route show | grep <subnet>` before bringing up a new container.
- **UFW deny routed.** Adding `ufw route allow` for every new container bridge is mandatory — without it, bridged traffic is silently dropped. The docker-proxy makes it look like it should work, but return packets hit the FORWARD chain.
- **Python version mismatch.** Ubuntu 22.04 ships Python 3.10. Hermes requires 3.11+. Don't try to `pip install` hermes-agent — it won't work. Use the portable build (see Python section).
- **Build from source in containers.** Docker containers may not allow executing compiled programs depending on the seccomp profile and mount options. The portable build avoids this entirely.
- **UFW opening ports on the VPS.** When adding new container ports, open them in UFW too, or external SSH will hang/timed out.
- **Gunicorn timeout for large uploads.** Flask's `MAX_CONTENT_LENGTH` alone isn't enough — Gunicorn's worker timeout (default 30s) kills the worker mid-upload. Set `--timeout 600` (or higher) in the CMD. See `references/flask-webapp-deployment.md` for the full pattern.

---

## Verification Checklist

After creating container setup files:

- [ ] Dockerfile syntax: `bash -n`, content checks
- [ ] docker-compose.yml: `python3 -c "import yaml; yaml.safe_load(open(...))"`
- [ ] setup.sh syntax: `bash -n`
- [ ] Unique subnet per container
- [ ] Unique ports per container (no overlaps)
- [ ] SSH password matches (all `hermes123`)
- [ ] WORKDIR and EXPOSE correct
- [ ] UFW route rule documented/addable
- [ ] Orphan bridge check run before bring-up
