# Hermes Self-Audit — Complete Diagnostic Commands

Run these in order for a full-system snapshot. Each command covers a distinct subsystem; gaps between them reveal what's missing.

## Identity & Model

```bash
hermes dump
```

Reports: version, OS, Python, profile, hermes_home, model, provider, terminal backend, all API key statuses, features (memory provider, gateway status, platforms, cron, skills count), config overrides.

## Tools

```bash
hermes tools
```

*Requires interactive terminal* — lists every active toolset and tool grouped by category. Falls back to the tool definitions in the system prompt if running non-interactively.

## Skills

```bash
hermes skills list       # full table: name, category, source, trust, status
hermes curator status    # curator health, stale/archive counts, most/least active skills
```

Curator status shows:
- Whether curator is ENABLED
- Last run time and result
- Consolidation mode (prune-only or merge)
- Top 5 least-active skills (candidates for pruning)
- Top 5 most-active skills
- Agent-created skill counts (active / stale / archived)

> **Check:** If curator is ENABLED but `last run` says "deferred first run", it was seeded but hasn't hit its first interval yet. That's normal — just means it hasn't cycled yet.

## Memory

```bash
hermes memory status
```

Reports: built-in (always active), provider (e.g. honcho), plugin availability, missing env vars, and all installed memory plugins.

> **Check:** If provider is set but shows "not available" with a missing API key, that key needs to be configured at the provider's dashboard.

## Profiles

```bash
hermes profile list
```

Outputs a table with: Profile name, Model, Gateway status, Alias, Distribution. Multiple profiles mean separate skill/plugin/cron environments.

> **Check:** The active profile is marked with `◆`. All others are dormant.

## Automation

```bash
hermes cron list         # every scheduled job + schedule
```

> **Check:** 0 jobs is valid — cron is opt-in.

## Plugins & MCP

```bash
hermes plugins list
hermes mcp list
```

Plugins are opt-in by default. `not enabled` is the normal state — the plugin is available but inactive.

> **Check:** `hermes plugins list --plain --no-bundled` for a compact view if the full table is too large.

## Gateway Health

```bash
hermes gateway status
```

Reports: systemd service status, uptime, platform connections, recent errors (e.g. Slack token issues), and any dual-install warnings (user + system).

> **Check:** If Slack shows `not_allowed_token_type`, the token type needs re-auth. If "Both user and system gateway services are installed", run `sudo hermes gateway uninstall --system` to clean up.

## Update / Self-Heal

```bash
# Check if hermes is an editable install
pip show hermes-agent 2>/dev/null | grep -i "editable\|location"

# If editable, check git remote
cd $(pip show hermes-agent 2>/dev/null | grep "Location" | head -1 | cut -d: -f2)
git remote -v
git fetch --dry-run 2>&1 | head -5

# If SSH fails, switch to HTTPS
git remote set-url origin https://github.com/NousResearch/hermes-agent.git
git pull --ff-only
/path/to/venv/bin/pip install -e .
```

## Quick reference checklist

| Subsystem | Command | Valid signal |
|-----------|---------|-------------|
| Version/Model | `hermes dump` | model set, provider set |
| Gateway | `hermes gateway status` | "active (running)" |
| Platforms | `hermes gateway status` | telegram/slack/discord listed |
| Memory | `hermes memory status` | provider shows "available" |
| Curator | `hermes curator status` | ENABLED, recent run |
| Skills | `hermes skills list` | all needed skills enabled |
| Disk | `df -h /` | < 80% used |
| Git | `git fetch --dry-run` | no errors |
