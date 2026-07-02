---
name: apple-integrations
description: "MacOS Apple ecosystem tools: Notes, Reminders, FindMy, iMessage automation from terminal."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [macos]
metadata:
  hermes:
    tags: [apple, macOS, notes, reminders, findmy, imessage, automation]
---

# Apple Integrations

macOS-only tools for managing Apple ecosystem apps from the terminal. These skills
require a macOS host with the respective Apple apps installed, signed in, and with
appropriate automation/accessibility permissions granted.

> **⚠️ Platform note:** These tools only work on macOS. On Linux (the current host),
> they are unavailable. They are preserved here for documentation and macOS session reference.

## Available Tools

| Tool | Purpose | CLI | Command |
|------|---------|-----|---------|
| **Apple Notes** | Create/search/edit notes | `memo` | `brew install antoniorodr/memo/memo` |
| **Apple Reminders** | Add/list/complete reminders | `remindctl` | `brew install steipete/tap/remindctl` |
| **Find My** | Track devices/AirTags | AppleScript + peekaboo | `brew install steipete/tap/peekaboo` |
| **iMessage** | Send/receive iMessages/SMS | `imsg` | `brew install steipete/tap/imsg` |

## Quick Reference by Use Case

### Notes (Apple Notes.app)

```
memo notes                         # List all notes
memo notes -f "Folder Name"        # Filter by folder
memo notes -s "query"              # Search
memo notes -a "Title"              # Quick add
memo notes -ex                     # Export to HTML/Markdown
```

**Full reference:** `skill_view(name="apple-integrations", file_path="references/apple-notes.md")`

### Reminders (Apple Reminders.app)

```
remindctl                          # Today's reminders
remindctl add "Buy milk"           # Quick add
remindctl add --title "Call" --list Personal --due tomorrow
remindctl complete 1 2 3           # Complete by ID
remindctl today --json             # JSON output
```

**Full reference:** `skill_view(name="apple-integrations", file_path="references/apple-reminders.md")`

### Find My (FindMy.app)

```
osascript -e 'tell application "FindMy" to activate'
sleep 3
screencapture -w -o /tmp/findmy.png
# Then use vision_analyze to read locations
```

Or with `peekaboo`:
```
peekaboo see --app "FindMy" --annotate --path /tmp/findmy-ui.png
peekaboo click --on B3 --app "FindMy"
```

**Full reference:** `skill_view(name="apple-integrations", file_path="references/findmy.md")`

### iMessage (Messages.app)

```
imsg chats --limit 10 --json
imsg send --to "+14155551212" --text "Hello!"
imsg history --chat-id 1 --limit 20 --json
imsg watch --chat-id 1 --attachments
```

**Full reference:** `skill_view(name="apple-integrations", file_path="references/imessage.md")`

## Permissions Checklist

For any of these tools to work, the user must grant permissions in macOS System Settings:

- **Automation** (Privacy → Automation) — for scripting the respective app
- **Full Disk Access** (Privacy → Full Disk Access) — for `imsg`
- **Screen Recording** (Privacy → Screen Recording) — for `findmy` (screencapture)
- **Accessibility** (Privacy → Accessibility) — for `peekaboo`

## Rules

1. **Always confirm** before sending messages (iMessage) — never send to unknown numbers
2. **Apple Notes** is for cross-device sync (iPhone/iPad/Mac); use `memory` tool for agent-only notes
3. **AirTags** only update location while the FindMy page is actively displayed
4. **Reminders**: when user says "remind me", clarify: Apple Reminders vs agent cronjob alert
