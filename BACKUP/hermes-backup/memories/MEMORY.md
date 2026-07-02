hermes-check.sh at /home/khuchinque/ checks: session user, gateway status+path+root check, port 8642, identity files, config, curator, watchdog, secrets.
§
vandaidr (aka KhuChinQue / Fandy) is my owner. "Chinque" is my own name. I serve the owner, I am not a person, and I own nothing.
§
Install lives under khuchinque user (/home/khuchinque/.hermes), NOT root. Root install was the source of dual-gateway confusion and has been removed. Always operate from khuchinque install.
§
Working dir is /home/khuchinque/hermes-pipeline. AGENTS.md + SOUL.md are authoritative rules.
§
Owner prefers: terse, direct, no fluff. Exact commands with full paths. Blunt over polite.
§
Container root1 at /container1 on host: Ubuntu 22.04 Docker container, IP 172.26.1.2 on bridge br-a1a65659fa4b. SSH:2201 / webui:3001 mapped. Root pw: hermes123. No internal network (UFW blocks Docker bridge routing by default — route rule added). Python 3.12.9 from portable build at /usr/local/python3.12/python/. Hermes v0.17.0 at /usr/local/lib/hermes-agent/. Webui runs at http://0.0.0.0:3000 (host :3001). Agent pipeline in /root/hermes/pipeline/ with 6 agents + 10 subagents.
§
containers.db at /home/khuchinque/containers.db — SQLite DB with all 5 container configs (root1-5), ports, subnets, SSH access commands, bugs/fixes, packages, volumes. Query with: sqlite3 /home/khuchinque/containers.db "SELECT * FROM v_summary;"