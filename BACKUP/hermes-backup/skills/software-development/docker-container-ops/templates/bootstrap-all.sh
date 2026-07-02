#!/bin/bash
# Master bootstrap template — copy and customize for your container fleet
set -euo pipefail

# ── Configuration ──────────────────────────────────────────────────────────
# Edit these arrays for your fleet
CONTAINERS=(2 3 4)

PORTS_SSH=(2202 2203 2204)
PORTS_APP=(3002 3003 3004)
SUBNETS=(172.26.2.0/24 172.26.3.0/24 172.26.4.0/24)
NAMES=(root2 root3 root4)
BASE_DIR="/container"

# ── Pre-flight ─────────────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then echo "Please run as root"; exit 1; fi

echo "=== Checking subnet conflicts ==="
for subnet in "${SUBNETS[@]}"; do
    if ip route show | grep -q "${subnet%/*}"; then
        echo "[!!] SUBNET CONFLICT: $subnet — run: ip route show | grep ${subnet%/*}"
        exit 1
    fi
done
echo "[ok] All subnets clear."

echo "=== Checking port conflicts ==="
for port in "${PORTS_SSH[@]}" "${PORTS_APP[@]}"; do
    if ss -tlnp | grep -q ":$port "; then
        echo "[!!] Port $port in use"; exit 1
    fi
done
echo "[ok] All ports free."

# ── Build & Start ──────────────────────────────────────────────────────────
echo "=== Building & starting containers ==="
for i in "${!CONTAINERS[@]}"; do
    c="${CONTAINERS[$i]}"
    dir="${BASE_DIR}${c}"
    name="${NAMES[$i]}"
    echo "--- ${name} (${dir}) ---"
    cd "$dir"
    mkdir -p root hermes; chmod 755 root hermes
    docker compose build -q && docker compose up -d

    # Wait for SSH
    for attempt in $(seq 1 10); do
        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 \
            -p "${PORTS_SSH[$i]}" root@127.0.0.1 'echo ready' 2>/dev/null \
            && echo "  [ok] SSH up" && break
        [ "$attempt" -eq 10 ] && echo "  [!!] SSH not responding"
        sleep 2
    done
done

# ── UFW Route Rules ────────────────────────────────────────────────────────
echo "=== Adding UFW route rules ==="
for i in "${!CONTAINERS[@]}"; do
    c="${CONTAINERS[$i]}"
    name="${NAMES[$i]}"
    net="container${c}_${name}_net"
    bridge_id=$(docker network inspect "$net" --format '{{.Id}}' 2>/dev/null | cut -c1-12)
    [ -z "$bridge_id" ] && echo "  [!!] Network $net not found" && continue
    bridge="br-${bridge_id}"
    echo "  ${name} -> ${bridge}"
    ufw route allow in on "$bridge" out on "$bridge" 2>/dev/null \
        && echo "    [ok]" || echo "    [=] exists"
done

# ── Summary ────────────────────────────────────────────────────────────────
echo ""
docker ps --filter "name=root" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
for i in "${!CONTAINERS[@]}"; do
    echo "  ssh root@<VPS_IP> -p ${PORTS_SSH[$i]}  # ${NAMES[$i]} (App: :${PORTS_APP[$i]})"
done
echo "  Password: hermes123"
