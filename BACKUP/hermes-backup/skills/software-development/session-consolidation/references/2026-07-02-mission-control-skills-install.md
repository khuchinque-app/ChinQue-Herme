# 2026-07-02 — Mission Control + Skills Install Session

## What was done

- **Mission Control** installed at `~/mission-control/`, dashboard on `:3000`
- **pnpm workaround**: `npm install -g pnpm` fails EACCES → `npm config set prefix ~/.npm-global && npm install -g pnpm` to install user-local
- **12 agents registered** via API: 7 Hermes pipeline (Chinque, Scout, Repo, Dev, BugBounty, Tracker) + 3 Pi agents (Pi-Planner, Pi-Worker, Pi-Reviewer) + 3 auto-discovered
- **youtube-full** skill installed from skills.sh ✅
- **web-search-plus** FAILED — repo exists on GitHub but has no `SKILL.md`, it's a Python package
- **Mattpocock bundle** REQUIRES MANUAL SELECTION — `npx skills@latest add mattpocock/skills` shows interactive picker; `caveman` not found in that repo, only `grill-me` and `tdd` exist
- **3 important skills updated**: honcho-memory (v1.1.0), hermes-self-evolution (v0.4.0), eagle-eye-routing (v0.4.0)

## Key discoveries

### Mission Control agent registration rules
- POST to `/api/agents/register` with `x-api-key` header
- Valid roles only: `coder`, `reviewer`, `tester`, `devops`, `researcher`, `assistant`, `agent`
- Agent names: alphanumeric + dots/hyphens/underscores only, no spaces
- Rate-limited: ~3 attempts/second, then waits 20-30s
- Setup page at `/setup` creates admin account; auto-generated creds in `.data/.auto-generated`

### skills.sh install quirks
- Some repos listed on skills.sh have no `SKILL.md` — `hermes skills install` fetches the listing page metadata but can't install a skill that doesn't exist
- Direct GitHub raw URL install works when skills.sh path fails
- Interactive install guard needs `yes |` pipe

### Node.js global install on shared systems
- `npm install -g` fails EACCES → set `npm config set prefix ~/.npm-global`
- Standalone curl|sh installers land in `~/.local/share/` but don't add to PATH
- `npx skills@latest add` launches an interactive picker, not scriptable

### Skills updated

| Skill | Ver. | Change |
|-------|------|--------|
| honcho-memory | 1.0.2→1.1.0 | Added `hermes memory setup` wizard section, `--verbose` diagnostics, provider-switch data loss warning |
| hermes-self-evolution | 0.3.0→0.4.0 | Version bump |
| eagle-eye-routing | 0.3.0→0.4.0 | Added install-path detection for user-local vs system-wide Hermes installs |
