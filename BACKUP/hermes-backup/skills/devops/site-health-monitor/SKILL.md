---
name: site-health-monitor
description: "Use when diagnosing a web service that's unreachable from outside, or setting up recurring uptime monitoring via cron. Covers local process checks, firewall/UFW, Nginx, SSL, DNS, and no-agent watchdog cron jobs."
version: 1.0.0
author: Chinque
tags: [devops, monitoring, cron, ufw, nginx, ssl, watchdog]
related_skills: [hermes-health-check]
---

# Site Health Monitor

Diagnose why a site is unreachable and set up automatic recurring checks.

## Diagnosis Flow

When a user says "my site/domain is down" or "check my site", follow this order:

### 1. Local process check
```bash
ss -tlnp | grep <PORT>
ps aux | grep <PID from above>
curl -s -o /dev/null -w "HTTP %{http_code}" http://localhost:<PORT>/ --max-time 10
```
- Is the process listening on the port?
- Is the process alive? (was it started recently, is it still running?)
- Does it respond locally with HTTP 200?

### 2. Nginx/Proxy check
```bash
ls /etc/nginx/sites-enabled/
read_file /etc/nginx/sites-enabled/<config>
sudo nginx -t
```
- Does the domain `server_name` match what the user expects?
- Is the `proxy_pass` target matching the local port?
- Does Nginx config pass syntax check?

### 3. Firewall check
```bash
sudo ufw status verbose
```
- Are ports 80 and 443 open? (and any non-standard ports the app uses)
- **This is the most common cause** — site runs fine on localhost but is invisible from outside

### 4. DNS check
```bash
dig +short <domain>
```
- Does it resolve to the server's public IP?

### 5. SSL check
```bash
openssl s_client -connect <domain>:443 -servername <domain> </dev/null 2>&1 | openssl x509 -noout -dates -subject -issuer
```
- Certificate not expired?
- Issued by a trusted CA (Let's Encrypt, etc.)?
- Subject matches the domain?

### 6. External reachability
```bash
curl -s -o /dev/null -w "HTTP %{http_code}  %{time_total}s\n" https://<domain>/ --max-time 15
curl -s -o /dev/null -w "HTTP %{http_code}" http://<domain>/ --max-time 10
```
- HTTPS should return 200 or a redirect (301/302)
- HTTP should return 301 (redirect to HTTPS) or 200
- Response time should be reasonable (< 2s)

### 7. Deliverable verification (CRITICAL — do not skip)

**Before telling the user a site is accessible, verify it yourself from outside.**

Failure mode: you fix a port, restart a server, or deploy a change, then tell the user "it's live at URL" without checking externally. The user opens a dead/broken URL and gets frustrated. You must do the testing — don't make the user do it.

Correct sequence:

1. **Local check:** `curl -s -o /dev/null -w "%{http_code}" http://localhost:<PORT>/path`
2. **External check from public IP** (localhost can succeed while UFW blocks the port):
   `curl -s -o /dev/null -w "%{http_code}" http://<PUBLIC_IP>:<PORT>/path`
3. If external access fails → check UFW, nginx proxy_pass, container port mapping
4. **Take a real browser screenshot** showing the rendered page:
   ```bash
   mkdir -p /tmp/playwright && cd /tmp/playwright
   npm init -y --silent 2>/dev/null
   npm install playwright 2>&1 | tail -1
   node -e "
   const {chromium} = require('playwright');
   (async () => {
     const b = await chromium.launch({headless:true});
     const p = await b.newPage({viewport:{width:430,height:932}});
     await p.goto('https://DOMAIN/PATH', {waitUntil:'networkidle',timeout:30000});
     await p.screenshot({path:'/path/to/screenshot.png'});
     await b.close();
   })();
   "
   ```
5. **Deliver both together** in one message — URL + screenshot:
   **URL:** https://full-domain/path
   MEDIA:/path/to/screenshot.png
6. Never give a URL you haven't personally verified returns HTTP 200 from an external IP.

Pitfall: use the public IP for curl tests when DNS doesn't resolve to this server yet. curl from localhost can return 200 while the port is UFW-blocked externally.

## Fixing common issues

| Problem | Fix |
|---------|-----|
| UFW blocking ports 80/443 | `sudo ufw allow 80/tcp && sudo ufw allow 443/tcp` |
| PHP dev server dead | `nohup php -S 0.0.0.0:<PORT> &` |
| Nginx config error | `sudo nginx -t` to diagnose, fix syntax |
| SSL cert expired | Either wait for auto-renewal, or manually renew with certbot |
| DNS not pointing here | Update A record at your DNS provider |

## Setting up recurring monitoring

Use Hermes cron with `--no-agent` mode (script-only watchdog — no LLM cost per run).

### 1. Create the watchdog script in ~/.hermes/scripts/

Pattern: **silent on success, alert on failure**. The script should:
- Check HTTP status
- Output NOTHING on success (prevents spam every cycle)
- Output diagnostic details only on failure
- Check related infrastructure (process alive, firewall open, etc.)

```bash
#!/bin/bash
SITE="https://<domain>"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$SITE" --max-time 15)

if [ "$HTTP_CODE" != "200" ]; then
    echo "🚨 <domain> DOWN — HTTP $HTTP_CODE"
    echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
    # Add process check, firewall check, etc. here
fi
# Silent on success = no delivery
```

### 2. Register the cron job
```bash
hermes cron create '<SCHEDULE>' \
  --name "<descriptive-name>" \
  --script <script-filename.sh> \
  --no-agent \
  --deliver origin \
  --repeat -1
```

- `--no-agent`: runs the script directly without an LLM — zero token cost
- `--repeat -1`: infinite repeats
- `--deliver origin`: delivers stdout to the current Telegram chat
- Silent script = no delivery (no spam)

### 3. Verify
```bash
hermes cron list
```
Check that `Repeat: ∞` and `Mode: no-agent`.

## Pitfalls

- **Always check UFW first** when a site works locally but not from outside. `sudo ufw status verbose` reveals blocked ports immediately.
- **Scripts must live in ~/.hermes/scripts/** — `hermes cron create --script` only accepts relative filenames under that directory.
- **No-agent mode** means the script's stdout IS the delivery. Empty stdout = no notification. This is the correct silent-on-success pattern.
- **Repeat defaults to 1 run** — always pass `--repeat -1` for permanent monitoring jobs. Use `hermes cron edit <ID> --repeat -1` to fix existing jobs.
- **Cron jobs survive gateway restarts** — they're durable and process-independent.
- **Multiple cron jobs can share the same script** — just create separate jobs with different schedules or names.
