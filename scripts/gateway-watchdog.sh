#!/bin/bash
# Gateway health check — auto-recover if dead (user service)
GATEWAY_PID=$(pgrep -u khuchinque -f "hermes_cli.main gateway run" 2>/dev/null)
if [ -z "$GATEWAY_PID" ]; then
    logger -t hermes-watchdog "Gateway not running (khuchinque). Restarting..."
    systemctl --user restart hermes-gateway.service
    exit 1
fi
# Check if gateway is responsive
if ! ss -tlnp | grep -q ":8642"; then
    logger -t hermes-watchdog "Gateway port 8642 not listening. Restarting..."
    systemctl --user restart hermes-gateway.service
    exit 1
fi
exit 0
