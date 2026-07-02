# 2026-07-02 Fix Mission — Completing the Skill Stack

## Gaps resolved

- **caveman-hermes-skill** found at `cangyueshi/caveman-hermes-skill` — port of mattpocock's caveman concept, installed via direct GitHub raw URL
- **grill-me** and **tdd** installed directly from mattpocock/skills GitHub raw URLs (bypassing the interactive npx picker)
- **web-search-plus** confirmed unfindable — both WuKavin and robbyczgw-cla repos lack a SKILL.md

**STACK STATUS: 4/5** — youtube-full ✅, grill-me ✅, tdd ✅, caveman ✅, web-search-plus ❌

## Automated skill install from URL (the `printf` pattern)

```
printf '\ny\n' | hermes skills install "https://raw.githubusercontent.com/..."
```

This handles **two** interactive prompts in one shot:
1. (empty Enter) → category prompt → selects flat install (no category)
2. (y) → disclaimer confirmation → accepts install

The simpler `yes |` pipes "y" to the category prompt, which installs under a category literally named "y". Always use `printf '\ny\n'` when you want flat install.

## Fixing a wrong-category install

When a skill gets installed under a bad category dir (e.g. `skills/y/caveman-hermes-skill/`):
```bash
mv ~/.hermes/skills/y/caveman-hermes-skill ~/.hermes/skills/caveman-hermes-skill
rm -rf ~/.hermes/skills/y/
```

## GitHub API for skill discovery

- `GET /repos/<owner>/<repo>/git/trees/main?recursive=1` lists all SKILL.md files in a repo
- `GET /repos/<owner>/<repo>/contents/` lists root directory — use to check if a repo has SKILL.md directly
- `GET search/repositories?q=<query>` — broad search for skill repos

## Skills updated this session

| Skill | Ver. | Change |
|-------|------|--------|
| honcho-memory | 1.0.2→1.1.0 | Added `hermes memory setup` wizard section, `--verbose` diagnostics, provider-switch data loss warning |
| hermes-self-evolution | 0.3.0→0.4.0 | Version bump |
| eagle-eye-routing | 0.3.0→0.4.0 | Added install-path detection for user-local vs system-wide Hermes installs |
