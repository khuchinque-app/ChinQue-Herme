---
name: note-taking-and-knowledge-management
description: "Unified interface for note-taking and knowledge bases: Obsidian vault operations, Notion API, and LLM Wiki (Karpathy-style markdown KB)."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [note-taking, knowledge-base, obsidian, notion, llm-wiki, markdown, wiki]
    related_skills: [google-workspace]
---

# Note-Taking & Knowledge Management

Three note-taking/knowledge-base systems, one skill. Load the subsystem you need.

## Reference files

- `references/obsidian.md` — Read, search, create, edit notes in the Obsidian vault
- `references/notion.md` — Notion API via ntn CLI or curl: pages, databases, markdown, Workers
- `references/llm-wiki.md` — Karpathy's LLM Wiki: build/query interlinked markdown KB
- `references/notion-block-types.md` — Notion block type reference (creating and reading blocks)

---

## Obsidian Vault

Load `skill_view(name="note-taking-and-knowledge-management", file_path="references/obsidian.md")` for full reference.

### Quick start

Vault path from `OBSIDIAN_VAULT_PATH` env var, or default `~/Documents/Obsidian Vault`. Resolve to an absolute path before calling file tools — file tools don't expand `$` variables.

- **Read a note:** `read_file("<vault-path>/<note>.md")`
- **List notes:** `search_files("*.md", target="files", path="<vault-path>")`
- **Search content:** `search_files("<pattern>", file_glob="*.md", path="<vault-path>")`
- **Create note:** `write_file("<vault-path>/<note>.md", "<content>")`
- **Edit note:** `patch` with stable anchor context
- **Wikilinks:** Use `[[Note Name]]` syntax for inter-note links

### Rules

- Always resolve `OBSIDIAN_VAULT_PATH` to an absolute concrete path before using file tools.
- Vault paths may contain spaces — prefer file tools over shell commands.
- `terminal` is acceptable only for resolving the vault path or checking if the fallback exists.

---

## Notion

Load `skill_view(name="note-taking-and-knowledge-management", file_path="references/notion.md")` for full reference.

### Quick start

Two paths: `ntn` CLI (preferred, macOS/Linux) or HTTP+curl (cross-platform, Windows). Same Notion integration token works for both.

**Setup:**
1. Create integration at https://notion.so/my-integrations → copy API key (`ntn_` or `secret_`)
2. Store as `NOTION_API_KEY` in `${HERMES_HOME:-~/.hermes}/.env`
3. Share target pages/databases with integration (page menu → Connect to → your integration)
4. Install `ntn` if available: `curl -fsSL https://ntn.dev | bash`

**Read page as Markdown (agent-friendly):**
```bash
ntn api v1/pages/{page_id}/markdown
```

**Search:**
```bash
ntn api v1/search query="page title"
```

**Create page from Markdown:**
```bash
ntn api v1/pages parent[page_id]=xxx properties[title][0][text][content]="Notes" markdown="# Content"
```

### API Version 2025-09-03 notes
- Databases are called "data sources" in the API.
- Two IDs per database: `database_id` (when creating pages) and `data_source_id` (when querying).
- File uploads: 3-step HTTP flow, or `ntn files create < file` (one-liner).

---

## LLM Wiki (Karpathy Pattern)

Load `skill_view(name="note-taking-and-knowledge-management", file_path="references/llm-wiki.md")` for full reference.

### Quick start

Wiki path from `WIKI_PATH` env var, default `~/wiki`. Just a directory of markdown files — works as an Obsidian vault.

**Orientation (every session):**
```bash
WIKI="${WIKI_PATH:-$HOME/wiki}"
read_file "$WIKI/SCHEMA.md"
read_file "$WIKI/index.md"
read_file "$WIKI/log.md" offset=<last 30>
```

**Architecture:**
```
wiki/
├── SCHEMA.md        # Conventions, tag taxonomy, domain config
├── index.md         # Sectioned content catalog
├── log.md           # Chronological action log
├── raw/             # Immutable source material (articles, papers, transcripts)
├── entities/        # Entity pages (people, orgs, products, models)
├── concepts/        # Concept/topic pages
├── comparisons/     # Side-by-side analyses
└── queries/         # Filed query results
```

### Lint checklist
- Orphan pages (no inbound [[wikilinks]])
- Broken wikilinks
- Index completeness (every page listed in index.md)
- Frontmatter validation (title, created, updated, type, tags, sources)
- Stale content (updated >90 days)
- Contradictions between related pages
- Source drift (raw/ sha256 mismatches)
- Page size >200 lines
- Tag audit (only tags from SCHEMA.md taxonomy)
