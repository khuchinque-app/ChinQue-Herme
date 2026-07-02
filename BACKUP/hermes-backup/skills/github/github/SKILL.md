---
name: github
description: "GitHub CLI operations: auth, code review, issues, PR workflow, repo management, codebase inspection. Umbrella for all GitHub interactions via gh CLI or git+curl fallback."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [GitHub, git, auth, PR, issues, code-review, repos, automation]
    related_skills: [plan, systematic-debugging]
---

# GitHub CLI Operations

Umbrella skill for all GitHub interactions. Covers authentication, PR review, issue management, PR workflow, repository management, and codebase inspection. Each section shows the `gh` CLI path first, then the `curl` + `git` fallback.

## Quick Auth Detection

The key setup block used across sections:

```bash
if command -v gh &>/dev/null && gh auth status &>/dev/null; then
  AUTH="gh"
  GH_USER=$(gh api user --jq '.login')
else
  AUTH="curl"
  if [ -z "$GITHUB_TOKEN" ]; then
    if _f="${HERMES_HOME:-$HOME/.hermes}/.env"; [ -f "$_f" ] && grep -q "^GITHUB_TOKEN=" "$_f"; then
      GITHUB_TOKEN=$(grep "^GITHUB_TOKEN=" "$_f" | head -1 | cut -d= -f2 | tr -d '\n\r')
    elif grep -q "github.com" ~/.git-credentials 2>/dev/null; then
      GITHUB_TOKEN=$(grep "github.com" ~/.git-credentials 2>/dev/null | head -1 | sed 's|https://[^:]*:\([^@]*\)@.*|\1|')
    fi
  fi
  GH_USER=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | python3 -c "import sys,json; print(json.load(sys.stdin)['login'])")
fi

REMOTE_URL=$(git remote get-url origin 2>/dev/null)
OWNER_REPO=$(echo "$REMOTE_URL" | sed -E 's|.*github\.com[:/]||; s|\.git$||')
OWNER=$(echo "$OWNER_REPO" | cut -d/ -f1)
REPO=$(echo "$OWNER_REPO" | cut -d/ -f2)
```

---

## Section 1: Authentication Setup

Full setup reference at `skill_view(name="github", file_path="references/auth.md")`.

### Git-Only Auth (no gh, no sudo)

HTTPS with personal access token:
```bash
git config --global credential.helper store
git ls-remote https://github.com/<user>/<repo>.git  # prompts once
git config --global user.name "Your Name"
git config --global user.email "email@example.com"
```

SSH key auth:
```bash
ssh-keygen -t ed25519 -C "email@example.com" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub  # add to github.com/settings/keys
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

### gh CLI Auth

```bash
gh auth login                                # interactive browser
echo "TOKEN" | gh auth login --with-token   # headless
gh auth setup-git
gh auth status
```

### Helper: Extract token from git credentials for API calls

```bash
export GITHUB_TOKEN=$(grep "github.com" ~/.git-credentials 2>/dev/null | head -1 | sed 's|https://[^:]*:\([^@]*\)@.*|\1|')
```

---

## Section 2: Code Review

### Reviewing Local Changes (Pre-Push)

```bash
git diff main...HEAD --stat          # scope
git diff main...HEAD                  # full diff
git diff main...HEAD -- file.py       # per-file
```

Checklist: debug leftovers, large files, secrets, merge conflicts.

### Reviewing a Pull Request

```bash
gh pr view 123
gh pr diff 123
gh pr checkout 123
# or with curl:
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER/files
git fetch origin pull/$PR_NUMBER/head:pr-$PR_NUMBER
git checkout pr-$PR_NUMBER
```

### Submitting a Review

```bash
gh pr review $PR_NUMBER --approve --body "LGTM!"
gh pr review $PR_NUMBER --request-changes --body "See inline comments."
# Or with curl (atomic review with inline comments):
HEAD_SHA=$(curl -s -H "AUTHORIZATION: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['head']['sha'])")
curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$OWNER/$REPO/pulls/$PR_NUMBER/reviews \
  -d '{"commit_id":"'"$HEAD_SHA"'","event":"COMMENT","body":"Review","comments":[...]}'
```

### Review Checklist

Systematically check: correctness, security (no hardcoded secrets, SQL injection, XSS), code quality (naming, DRY, single responsibility), testing (happy path + edge cases), performance (N+1 queries, blocking async), documentation.

---

## Section 3: Issues Management

### Viewing Issues

```bash
gh issue list                         # all open
gh issue list --state open --label bug
gh issue list --assignee @me
gh issue view 42
```

### Creating Issues

```bash
gh issue create --title "Bug: ..." --body "## Description\n..." --label "bug" --assignee user
```

### Managing Issues

```bash
gh issue edit 42 --add-label "priority:high" --add-assignee username
gh issue comment 42 --body "Working on a fix."
gh issue close 42 --reason "completed"
gh issue reopen 42
```

### Issue Triage Workflow

1. List untriaged: `gh issue list --label "needs-triage"`
2. Read and categorize each
3. Apply labels and priority
4. Assign
5. Comment with triage notes

---

## Section 4: PR Workflow

### Branch + Commit

```bash
git fetch origin
git checkout main && git pull origin main
git checkout -b feat/description
# ... make changes with file tools ...
git add <files>
git commit -m "feat: description
Longer explanation if needed."
git push -u origin HEAD
```

Branch naming: `feat/`, `fix/`, `refactor/`, `docs/`, `ci/`.

### Create PR

```bash
gh pr create --title "feat: ..." --body "## Summary\n..." --label "enhancement"
```

### Monitor CI

```bash
gh pr checks --watch
# or curl polling:
SHA=$(git rev-parse HEAD)
for i in $(seq 1 20); do
  STATUS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/repos/$OWNER/$REPO/commits/$SHA/status \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['state'])")
  [ "$STATUS" = "success" ] || [ "$STATUS" = "failure" ] && break
  sleep 30
done
```

### Auto-Fix CI Failures

1. Get failure details: `gh run list --branch $(git branch --show-current)` then `gh run view <ID> --log-failed`
2. Fix code with file tools
3. `git commit -m "fix: ..." && git push`
4. Re-check CI. Repeat up to 3 attempts.

### Merge

```bash
gh pr merge --squash --delete-branch
git checkout main && git pull origin main
git branch -d <branch>
```

---

## Section 5: Repository Management

### Cloning

```bash
git clone https://github.com/owner/repo.git
gh repo clone owner/repo
```

### Creating Repos

```bash
gh repo create my-project --public --clone --license MIT --description "A useful tool"
```

### Forking

```bash
gh repo fork owner/repo --clone
git remote add upstream https://github.com/owner/repo.git
```

### Keep Fork in Sync

```bash
git fetch upstream
git checkout main && git merge upstream/main && git push origin main
gh repo sync $GH_USER/repo  # shortcut
```

### Repo Information

```bash
gh repo view owner/repo
gh repo list --limit 20
gh search repos "topic" --language python --sort stars
```

### Repo Settings

```bash
gh repo edit --description "..." --visibility public --enable-wiki=false
```

### Branch Protection

```bash
curl -s -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$OWNER/$REPO/branches/main/protection \
  -d '{"required_status_checks":{"strict":true,"contexts":["ci/test"]},"enforce_admins":false,"required_pull_request_reviews":{"required_approving_review_count":1},"restrictions":null}'
```

### Secrets Management

```bash
gh secret set API_KEY --body "your-secret"
gh secret list
```

### Releases

```bash
gh release create v1.0.0 --title "v1.0.0" --generate-notes
gh release create v1.0.0 ./dist/binary --title "v1.0.0" --notes "Release notes"
```

### Gists

```bash
gh gist create script.py --public --desc "Useful script"
```

---

## Section 6: CI Workflows (Actions)

```bash
gh workflow list
gh run list --limit 10
gh run view <ID> --log-failed
gh run rerun <ID> --failed
gh workflow run ci.yml --ref main
```

---

## Section 7: Codebase Inspection (LOC Metrics)

Analyze repository size and language breakdown with `pygount`:

```bash
pip install --break-system-packages pygount 2>/dev/null || pip install pygount
pygount --format=summary \
  --folders-to-skip=".git,node_modules,venv,.venv,__pycache__,.cache,dist,build,.next,.tox" \
  .
```

### Common Folder Exclusions

| Project type | --folders-to-skip |
|---|---|
| Python | `.git,venv,.venv,__pycache__,.cache,dist,build,.tox,.eggs,.mypy_cache` |
| JS/TS | `.git,node_modules,dist,build,.next,.cache,.turbo,coverage` |
| General | `.git,node_modules,venv,.venv,__pycache__,.cache,dist,build,.next,.tox,vendor,third_party` |

### Filter by Language

```bash
pygount --suffix=py --format=summary .
pygount --suffix=py,yaml,yml --format=summary .
```

### Output Formats

```bash
pygount --format=summary .     # table
pygount --format=json .        # JSON
```

### Interpreting Results

Columns: Language, Files, Code, Comment, %. Special pseudo-languages: `__empty__`, `__binary__`, `__generated__`, `__duplicate__`, `__unknown__`.

### Pitfalls

- Always exclude .git, node_modules, venv — without it pygount can hang on large dependency trees.
- Markdown shows 0 code lines (all content classified as comments).
- For large monorepos, use `--suffix` to target specific languages.

---

## Pitfalls

1. **Auth detection first.** Every workflow starts with the detection block above — don't guess which method works.
2. **Inline secrets.** Never pass tokens/api keys in command arguments. Use env vars or credential helpers.
3. **SSH vs HTTPS.** Check what remote URLs the repo uses. `gh` handles both; `git` + `curl` works best with HTTPS.
4. **`gh` not installed.** Use curl + git fallbacks — no `gh` needed for core operations.
5. **Permission denied.** Token must have `repo` scope (full repo access) for write operations.
6. **CI poll timeout.** Don't hardcode sleep; use the loop with break conditions shown in Section 4.
7. **pygount folder exclusions.** Always set `--folders-to-skip` or scan may take minutes.
