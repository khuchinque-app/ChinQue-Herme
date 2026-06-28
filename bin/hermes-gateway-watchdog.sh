#!/usr/bin/env bash
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔒 Hermes Gateway Watchdog (user-level)
# Auto-recovery script — checks gateway + Telegram every 60s
# Runs via user-level systemd timer
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

HERMES_HOME="/home/khuchinque/.hermes"
LOGFILE="$HERMES_HOME/logs/watchdog.log"
LOCKFILE="$HERMES_HOME/.watchdog.lock"
GATEWAY_SERVICE="hermes-gateway.service"
TELEGRAM_BOT="8883263036:AAHCj3inHpH44b1OCIAJtAngv8L8onRPEVA"

mkdir -p "$HERMES_HOME/logs"

log() { echo "[$(date -Iseconds)] $*" >> "$LOGFILE"; }

notify() {
    curl -fsS --max-time 10 "https://api.telegram.org/bot${TELEGRAM_BOT}/sendMessage" \
        -d "chat_id=7281341176" -d "text=🛡️ Watchdog: $1" >/dev/null 2>&1 || true
}

# Lock
if [ -f "$LOCKFILE" ]; then
    age=$(( $(date +%s) - $(stat -c %Y "$LOCKFILE" 2>/dev/null || echo 0) ))
    [ "$age" -lt 120 ] && exit 0
    rm -f "$LOCKFILE"
fi
touch "$LOCKFILE"; trap 'rm -f "$LOCKFILE"' EXIT

if ! pgrep -f 'hermes_cli.main gateway run' >/dev/null 2>&1; then
    log "❌ Gateway down! Attempting restart..."
    notify "⚠️ Gateway down! Restarting..."
    systemctl restart "$GATEWAY_SERVICE" 2>/dev/null || \
        sudo systemctl restart "$GATEWAY_SERVICE" 2>/dev/null || \
        nohup "$HERMES_HOME/hermes-agent/venv/bin/python3" -m hermes_cli.main gateway run \
            > "$HERMES_HOME/logs/gateway-crash.log" 2>&1 &
    sleep 5
    if pgrep -f 'hermes_cli.main gateway run' >/dev/null 2>&1; then
        log "✅ Restarted OK (PID: $(pgrep -f 'hermes_cli.main gateway run' | head -1))"
        notify "✅ Gateway restarted OK"
    else
        log "❌ RESTART FAILED!"
        notify "🚨 Gateway restart FAILED!"
    fi
elif ! curl -fsS --max-time 10 "https://api.telegram.org/bot${TELEGRAM_BOT}/getMe" >/dev/null 2>&1; then
    PID=$(pgrep -f 'hermes_cli.main gateway run' | head -1)
    log "⚠️ PID $PID running but Telegram unreachable — restarting"
    kill "$PID" 2>/dev/null || true
    sleep 2
    systemctl restart "$GATEWAY_SERVICE" 2>/dev/null || true
    notify "⚠️ Telegram unreachable — gateway restarted"
else
    log "✅ OK — PID $(pgrep -f 'hermes_cli.main gateway run' | head -1), Telegram reachable"
fi
