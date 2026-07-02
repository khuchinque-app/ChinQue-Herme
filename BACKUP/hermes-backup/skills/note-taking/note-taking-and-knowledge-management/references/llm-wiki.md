# LLM Wiki — Karpathy Pattern

Build and maintain a persistent, compounding knowledge base as interlinked markdown files. Based on Andrej Karpathy's LLM Wiki pattern.

## Wiki Location

Set via `WIKI_PATH` env var (e.g. in `${HERMES_HOME:-~/.hermes}/.env`). Default: `~/wiki`.

```bash
WIKI="${WIKI_PATH:-$HOME/wiki}"
```

## Architecture

```
wiki/
├── SCHEMA.md           # Conventions, structure rules, domain config
├── index.md            # Sectioned content catalog with one-line summaries
├── log.md              # Chronological action log (append-only, rotated yearly)
├── raw/                # Layer 1: Immutable source material
│   ├── articles/       # Web articles, clippings
│   ├── papers/         # PDFs, arxiv papers
│   ├── transcripts/    # Meeting notes, interviews
│   └── assets/         # Images, diagrams referenced by sources
├── entities/           # Layer 2: Entity pages (people, orgs, products, models)
├── concepts/           # Layer 2: Concept/topic pages
├── comparisons/        # Layer 2: Side-by-side analyses
└── queries/            # Layer 2: Filed query results worth keeping
```

## Resuming (do this every session)

```bash
read_file "$WIKI/SCHEMA.md"
read_file "$WIKI/index.md"
read_file "$WIKI/log.md" offset=<last 30 lines>
```

## Core operations

### Ingest a source

1. Capture raw source (web_extract for URLs, read for files) → save to `raw/`
2. Add frontmatter: `source_url`, `ingested` date, `sha256` of body
3. Check existing wiki pages for entities/concepts mentioned
4. Create or update entity/concept pages
5. Every new/updated page must link to 2+ other pages via `[[wikilinks]]`
6. Update index.md and log.md

### Query the wiki

1. Read index.md to find relevant pages
2. For 100+ page wikis, search_files across all .md files
3. Synthesize answer citing wiki pages
4. File valuable answers back as queries/ pages

### Lint checklist

- Orphan pages (no inbound [[wikilinks]])
- Broken wikilinks
- Index completeness
- Frontmatter validation
- Stale content (updated >90 days)
- Contradictions (pages with contested frontmatter)
- Source drift (sha256 mismatches in raw/)
- Page size >200 lines
- Tag audit (only tags from SCHEMA.md taxonomy)

## SCHEMA.md template

```markdown
# Wiki Schema

## Domain
[What this wiki covers]

## Conventions
- File names: lowercase, hyphens, no spaces
- Use [[wikilinks]] between pages (minimum 2 per page)
- Every action appended to log.md

## Frontmatter
  ---
  title: Page Title
  created: YYYY-MM-DD
  updated: YYYY-MM-DD
  type: entity | concept | comparison | query | summary
  tags: [from taxonomy]
  sources: [raw/articles/source-name.md]
  ---

## Tag Taxonomy
[Define 10-20 top-level tags]

## Page Thresholds
- Create page when entity/concept appears in 2+ sources
- Split pages >200 lines
- Archive fully superseded content to _archive/
```

For page threshold guidance: create when entity appears in 2+ sources, split when >200 lines, archive when fully superseded.

## Obsidian Integration
The wiki directory works as an Obsidian vault out of the box. `[[wikilinks]]` render as clickable links, YAML frontmatter powers Dataview queries.

## Pitfalls
- Never modify files in raw/ — sources are immutable
- Always update index.md and log.md
- Don't create pages for passing mentions
- Tags must come from the taxonomy
- Handle contradictions explicitly (don't silently overwrite)
