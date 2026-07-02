# Fresh Editor Installation Log

**Status:** Installed on this VPS
**When:** 2026-07-02 14:19 UTC
**Version:** 0.4.2
**Binary:** /usr/bin/fresh
**Architecture:** amd64 (amd64)
**Source:** GitHub releases — sinelaw/fresh
**Install method:** `dpkg -i`
**Install command used:**
```bash
ARCH=$(dpkg --print-architecture)
DL_URL=$(curl -s https://api.github.com/repos/sinelaw/fresh/releases/latest | grep "browser_download_url.*_${ARCH}\.deb" | cut -d '"' -f 4)
curl -sL "$DL_URL" -o /tmp/fresh-editor.deb
sudo dpkg -i /tmp/fresh-editor.deb
rm /tmp/fresh-editor.deb
```

**What it is:** Fresh is a modern terminal-based code editor (similar to Helix/Kakoune style modal editing).

---
**Last verified:** 2026-07-02
**Installed by:** Hermes Agent (Chinque)
