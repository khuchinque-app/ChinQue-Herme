# GitHub Authentication Full Reference

## Git-Only: HTTPS with PAT (recommended, no sudo)

1. Create token at https://github.com/settings/tokens (scopes: `repo`, `workflow`, `read:org`)
2. Configure git:
```bash
git config --global credential.helper store
git config --global user.name "Your Name"
git config --global user.email "email@example.com"
# Trigger auth prompt
git ls-remote https://github.com/<user>/<repo>.git
# Enter username + token as password
```

Alternative: embed token in remote URL (per-repo):
```bash
git remote set-url origin https://<user>:<token>@github.com/<owner>/<repo>.git
```

## Git-Only: SSH Key Auth

```bash
ssh-keygen -t ed25519 -C "email@example.com" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub  # add to github.com/settings/keys
ssh -T git@github.com       # test
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

## gh CLI Auth

```bash
gh auth login              # browser
echo "TOKEN" | gh auth login --with-token  # headless
gh auth setup-git
gh auth status
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `git push` asks for password | GitHub disabled password auth. Use PAT or SSH. |
| `Permission to X denied` | Token lacks `repo` scope |
| `fatal: Authentication failed` | Stale cached credentials: `git credential reject` then re-auth |
| SSH port 22 blocked | Add `Host github.com` with `Port 443` / `Hostname ssh.github.com` to `~/.ssh/config` |
| Multiple accounts | Use SSH with different keys per host alias in `~/.ssh/config` |
