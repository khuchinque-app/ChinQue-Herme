#!/bin/bash
# Check tittil.cloud — silent on success, alert on failure
SITE="https://tittil.cloud"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$SITE" --max-time 15)

if [ "$HTTP_CODE" != "200" ]; then
    # Only output on failure — stdout gets delivered by cron --no-agent
    echo "🚨 tittil.cloud DOWN — HTTP $HTTP_CODE"
    echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
    
    if pgrep -f "php -S 0.0.0.0:7500" > /dev/null; then
        echo "PHP process: ALIVE on 7500"
    else
        echo "PHP process: DEAD on 7500"
    fi
    
    # Check firewall
    if sudo ufw status | grep -q "443.*ALLOW"; then
        echo "Firewall: port 443 open"
    else
        echo "Firewall: port 443 BLOCKED"
    fi
fi
# Silent on success = no delivery
