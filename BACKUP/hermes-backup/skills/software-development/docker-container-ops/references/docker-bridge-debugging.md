# Docker Bridge Debugging — root1 Reproduction Recipe

**Date:** 2026-06-30
**System:** Ubuntu 24.04 (host) → Docker container (Ubuntu 22.04)
**Container:** `root1` — `/container1/` on host, bridge `container1_root1_net` (172.26.1.0/24)

## Symptoms

- `curl http://127.0.0.1:3001/health` — TCP connects, sends GET, then `Connection reset by peer`
- `curl http://127.0.0.1:2201` — same behavior (SSH port)
- Inside container: `curl http://127.0.0.1:3000/health` — works fine
- `sudo docker exec root1 ...` — works fine (bypasses port mapping)

## Phase 1: Verify the obvious

```bash
sudo docker ps --filter name=root1 --format "{{.Names}} {{.Status}} {{.Ports}}"
# → root1 Up 16 hours 0.0.0.0:2201->22/tcp, 0.0.0.0:3001->3000/tcp

ps aux | grep docker-proxy | grep 3001
# → docker-proxy -host-port 3001 -container-ip 172.26.1.2 -container-port 3000 ✓

sudo iptables -t nat -L DOCKER -n | grep 3001
# → DNAT tcp dpt:3001 to:172.26.1.2:3000 ✓

sudo iptables -L DOCKER -n | grep 172.26.1.2
# → ACCEPT tcp dpt:3000 ✓
```

All infrastructure present. Problem is at a lower level.

## Phase 2: Test via Docker bridge IP directly

```bash
curl http://172.26.1.2:3000
# → No route to host ✗
```

Direct bridge access also fails — the host can't reach the container even on the bridge network. This rules out a docker-proxy-specific issue and points to kernel routing or firewall.

## Phase 3: Identify the routing conflict

```bash
ip route show | grep 172.26
# → 172.26.1.0/24 dev br-428809d5f289 proto kernel scope link src 172.26.1.1 linkdown
# → 172.26.1.0/24 dev br-a1a65659fa4b proto kernel scope link src 172.26.1.1
```

**Two bridges on the same subnet!** `br-428809d5f289` (the orphan) appears first in the routing table. Even though it's `linkdown`, the kernel uses it for the first-hop route. Packets to 172.26.1.2 go to the orphan bridge → dropped.

**Check which Docker networks these belong to:**

```bash
sudo docker network inspect container1_root1_net --format '{{.Id}}'
# → a1a65659fa4b → br-a1a65659fa4b (correct, active)

# The orphan (br-428809d5f289) has no matching Docker network.
# It was likely leftover from a deleted or failed docker-compose up.
```

**Fix:**
```bash
sudo ip link delete br-428809d5f289
```

After fix:
```bash
curl http://172.26.1.2:3000
# → {...health response...} ✓
curl http://127.0.0.1:3001/health
# → Still fails? Move to Phase 4.
```

## Phase 4: UFW blocking routed traffic

```bash
sudo ufw status verbose
# → Status: active
# → Default: deny (incoming), allow (outgoing), deny (routed)
```

`deny (routed)` is the Docker killer. UFW's FORWARD policy drops all bridging traffic. Even with correct iptables NAT rules, the FORWARD chain DROPs packets.

**Check FORWARD chain:**
```bash
sudo iptables -L FORWARD -n -v
# → policy DROP
# → ufw-before-forward chain has REL ATED,ESTABLISHED accept only
```

**Fix — add a route allow for the container's bridge:**
```bash
sudo ufw route allow in on br-a1a65659fa4b out on br-a1a65659fa4b
```

**Verify:**
```bash
curl -s http://127.0.0.1:3001/health
# → {"status":"ok",...} ✓
```

## Cleanup

Also delete any other orphan bridges from the routing table:
```bash
# Check for other linkdown bridges
ip link show | grep "state DOWN"
# Delete each orphan
sudo ip link delete br-XXXXX
```

## Summary

| Layer | Problem | Fix |
|-------|---------|-----|
| L3 routing | Orphan bridge on same subnet as active bridge | `sudo ip link delete br-ORPHAN` |
| L4 firewall | UFW `deny (routed)` drops Docker FORWARD traffic | `sudo ufw route allow in on br-ACTIVE out on br-ACTIVE` |
