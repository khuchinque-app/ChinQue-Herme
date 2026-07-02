# 2026-06-30 — Container1 root1 Debug Session

## Goal
Debug port mapping failure on container1 (root1) and create 4 more container
setups (root2-5) for multi-container deployment.

## Environment
- VPS: Ubuntu 24.04, Docker 24+, UFW active, single public IP 187.127.178.20
- container1: Ubuntu 22.04 with Hermes WebUI, SSH on port 2201, webui on 3001
- Hermes Agent v0.17.0 on host (not inside containers)

## What was fixed
1. Orphan bridge `br-428809d5f289` on same subnet as active `br-a1a65659fa4b`
   (both `172.26.1.0/24`) — deleted the orphan
2. UFW `deny (routed)` blocking Docker FORWARD traffic — added route allow
3. Also cleaned orphan bridges `br-69b3e856498d` (172.26.2.0/24)

## File layout created
```
/container1/   — root1 (running, debugged)
/container2/   — root2, SSH 2202, App 3002, subnet 172.26.2.0/24
/container3/   — root3, SSH 2203, App 3003, subnet 172.26.3.0/24
/container4/   — root4, SSH 2204, App 3004, subnet 172.26.4.0/24
/container5/   — root5, SSH 2205, App 3005, subnet 172.26.5.0/24
/root/bug-install-container.md — full bug report
/root/bootstrap-all-containers.sh — bring-up script
```

## Key user preferences
- Containers must be isolated: no outbound network, no agent software inside
- "what inside there cannot be out" — container isolation is a hard requirement
- Scripts should be ready-to-run; the user will bring them online
