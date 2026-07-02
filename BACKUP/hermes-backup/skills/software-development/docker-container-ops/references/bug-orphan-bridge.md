# Orphan Bridge & UFW Bug — Reproduction Recipe

## Environment
- Host: Ubuntu 24.04, Docker 24+, UFW active
- Container: Ubuntu 22.04 with SSH (port 22) + web app (port 3000)
- Docker compose network: bridge, custom subnet

## Reproduce

```bash
# 1. Create a docker-compose project with custom subnet
# docker-compose.yml:
#   networks:
#     mynet:
#       driver: bridge
#       ipam:
#         config:
#           - subnet: 172.26.1.0/24

# 2. docker compose up -d
# 3. docker compose down   (NOT docker compose down -v — network survives)
# 4. Create another project or recreate with the same subnet

# The OLD bridge still exists:
br-428809d5f289    172.26.1.0/24    DOWN (orphan)

# The NEW bridge:
br-a1a65659fa4b    172.26.1.0/24    UP (active)

# ip route shows:
# 172.26.1.0/24 dev br-428809d5f289 ... linkdown
# 172.26.1.0/24 dev br-a1a65659fa4b ... src 172.26.1.1
```

## Fix

```bash
sudo ip link delete br-428809d5f289
```

## Prevention

- Use `docker compose down -v` to also remove the network
- Or always check `ip route show | grep 172.26` before starting a new project
- Docker network prune removes all unused networks: `docker network prune`
