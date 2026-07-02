# Notion API Reference

## Setup

1. Create integration at https://notion.so/my-integrations → copy API key (`ntn_` or `secret_`)
2. Store as `NOTION_API_KEY` in `${HERMES_HOME:-~/.hermes}/.env`
3. Share target pages/databases with integration (page menu → Connect to → your integration)
4. Install `ntn` (preferred, macOS/Linux): `curl -fsSL https://ntn.dev | bash`
   - Skip `ntn login` — use integration token: `export NOTION_API_TOKEN=$NOTION_API_KEY` + `export NOTION_KEYRING=0`

## Choose path

```bash
if command -v ntn >/dev/null 2>&1; then
  # use ntn
else
  # fall back to curl
fi
```

## Path A: ntn CLI (preferred, macOS/Linux)

### Read page as Markdown
```bash
ntn api v1/pages/{page_id}/markdown
```

### Search
```bash
ntn api v1/search query="page title"
```

### Read page metadata
```bash
ntn api v1/pages/{page_id}
```

### Create page from Markdown
```bash
ntn api v1/pages \
  parent[page_id]=xxx \
  properties[title][0][text][content]="Notes from meeting" \
  markdown="# Agenda\n\n- Q3 roadmap\n- Hiring"
```

### Patch page with Markdown
```bash
ntn api v1/pages/{page_id}/markdown -X PATCH markdown="## Update\n\nShipped the prototype."
```

### Query database (data source)
```bash
ntn api v1/data_sources/{id}/query -X POST \
  filter[property]=Status filter[select][equals]=Active
```

### File upload (one-liner)
```bash
ntn files create < photo.png
ntn files create --external-url https://example.com/photo.png
```

### Useful env vars
| Var | Effect |
|---|---|
| `NOTION_API_TOKEN` | Auth token (set this to your integration token) |
| `NOTION_KEYRING=0` | File-based creds instead of OS keychain |
| `NOTION_WORKSPACE_ID` | Skip workspace picker |

## Path B: HTTP + curl (cross-platform)

All requests share:
```bash
curl -s -X GET "https://api.notion.com/v1/..." \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json"
```

### Search
```bash
curl -s -X POST "https://api.notion.com/v1/search" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"query": "page title"}'
```

### Read page as Markdown
```bash
curl -s "https://api.notion.com/v1/pages/{page_id}/markdown" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03"
```

### Create page from Markdown
```bash
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"parent": {"page_id": "xxx"}, "properties": {"title": [{"text": {"content": "Notes"}}]}, "markdown": "# Content"}'
```

### Create page in database
```bash
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"parent": {"database_id": "xxx"}, "properties": {"Name": {"title": [{"text": {"content": "New Item"}}]}, "Status": {"select": {"name": "Todo"}}}}'
```

### Query database
```bash
curl -s -X POST "https://api.notion.com/v1/data_sources/{id}/query" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"filter": {"property": "Status", "select": {"equals": "Active"}}, "sorts": [{"property": "Date", "direction": "descending"}]}'
```

### Update page properties
```bash
curl -s -X PATCH "https://api.notion.com/v1/pages/{page_id}" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"properties": {"Status": {"select": {"name": "Done"}}}}'
```

## Common property types
- **Title:** `{"title": [{"text": {"content": "..."}}]}`
- **Rich text:** `{"rich_text": [{"text": {"content": "..."}}]}`
- **Select:** `{"select": {"name": "Option"}}`
- **Multi-select:** `{"multi_select": [{"name": "A"}, {"name": "B"}]}`
- **Date:** `{"date": {"start": "2026-01-15"}}`
- **Checkbox:** `{"checkbox": true}`
- **Number:** `{"number": 42}`
- **URL:** `{"url": "https://..."}`
- **Relation:** `{"relation": [{"id": "page_id"}]}`

## API Version 2025-09-03 notes
- Databases are called "data sources" in the API. Use `/data_sources/` for queries.
- Two IDs per database: `database_id` (creating pages) and `data_source_id` (querying).
- Page/database IDs are UUIDs (dashes optional).
- Rate limit: ~3 requests/second average.

## Notion Workers (advanced, requires ntn + Business/Enterprise plan)
- Workers = TypeScript programs hosted by Notion (syncs, tools, webhooks).
- Scaffold: `ntn workers new my-worker`, edit `src/index.ts`, deploy: `ntn workers deploy`.
- Lifecycle: `ntn workers list`, `ntn workers exec <key>`, `ntn workers runs list`, `ntn workers runs logs <run-id>`.
- Webhooks: `ntn workers webhooks list` after deploy for the URL.
- Plan gating: Deploying Workers requires Business or Enterprise.

## Notion-Flavored Markdown
Standard CommonMark plus XML-like tags for Notion blocks:
```xml
<callout icon="🎯" color="blue_bg">text</callout>
<details color="gray"><summary>Toggle</summary>Content</details>
<columns><column>Left</column><column>Right</column></columns>
```
Use tabs for indentation. Mentions: `<mention-user url="..."/>`, `<mention-page url="...">Title</mention-page>`.
