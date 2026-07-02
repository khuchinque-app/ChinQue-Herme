# Worked Example: tittil.cloud Watchdog

Real-world setup from the conversation history.

## Background

A PHP Restaurant Ordering System running on port 7500 via `php -S 0.0.0.0:7500`, proxied through Nginx at `tittil.cloud`. The site returned HTTP 200 locally but was unreachable from the internet.

## Root cause

UFW only had ports 22, 8443, and 8642 open. Ports 80 and 443 were missing. Nginx receives traffic → proxies to port 7500 → process responds 200. But the firewall drops incoming packets before they reach Nginx.

## Fix applied

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

## Watchdog script (`~/.hermes/scripts/check-tittil.sh`)

```bash
#!/bin/bash
SITE="https://tittil.cloud"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$SITE" --max-time 15)

if [ "$HTTP_CODE" != "200" ]; then
    echo "🚨 tittil.cloud DOWN — HTTP $HTTP_CODE"
    echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
    if pgrep -f "php -S 0.0.0.0:7500" > /dev/null; then
        echo "PHP process: ALIVE on 7500"
    else
        echo "PHP process: DEAD on 7500"
    fi
    if sudo ufw status | grep -q "443.*ALLOW"; then
        echo "Firewall: port 443 open"
    else
        echo "Firewall: port 443 BLOCKED"
    fi
fi
```

## Cron job registration

```bash
hermes cron create '30m' \
  --name "tittil-health-check" \
  --script check-tittil.sh \
  --no-agent \
  --deliver origin \
  --repeat -1
```

## Cron job verification

```bash
$ hermes cron list
# Shows: Name: tittil-health-check, Schedule: once in 30m, Repeat: ∞, Mode: no-agent
```

## Key learning

The site was fully functional — PHP process alive, Nginx configured correctly, SSL valid, DNS resolving. Only the firewall was missing. Always check UFW before digging into application-level issues.
