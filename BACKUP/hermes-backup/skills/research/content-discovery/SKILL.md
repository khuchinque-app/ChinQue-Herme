---
name: content-discovery
description: "Search and discover academic papers, blog posts, prediction markets, and other web content. Umbrella for arXiv paper search, blog/RSS monitoring, Polymarket prediction market queries, and deep research orchestration via parallel web extraction."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [research, discovery, arxiv, papers, blogs, rss, polymarket, prediction-markets]
    related_skills: [research-paper-writing, youtube-content]
---

# Content Discovery

Search and retrieve content from multiple sources. Three subsystems:

| Subsystem | What | Auth Required |
|-----------|------|--------------|
| **arXiv** | Academic papers | None |
| **BlogWatcher** | RSS/Atom blog feeds | None (local CLI) |
| **Polymarket** | Prediction market data | None (read-only) |

---

## Section 1: arXiv Paper Search

Use when the user asks to search for academic papers, find research by topic, or fetch paper metadata.

### Quick Reference

```bash
# Search (returns Atom XML — parse with python3)
curl -s "https://export.arxiv.org/api/query?search_query=all:transformer+attention&max_results=5"

# Get specific paper
curl -s "https://export.arxiv.org/api/query?id_list=2402.03300"

# Read abstract
web_extract(urls=["https://arxiv.org/abs/2402.03300"])

# Read PDF
web_extract(urls=["https://arxiv.org/pdf/2402.03300"])
```

### Clean Output via Python

```bash
curl -s "https://export.arxiv.org/api/query?search_query=all:QUERY&max_results=5&sortBy=submittedDate&sortOrder=descending" | python3 -c "
import sys, xml.etree.ElementTree as ET
ns = {'a': 'http://www.w3.org/2005/Atom'}
root = ET.parse(sys.stdin).getroot()
for i, entry in enumerate(root.findall('a:entry', ns)):
    title = entry.find('a:title', ns).text.strip().replace('\n', ' ')
    arxiv_id = entry.find('a:id', ns).text.strip().split('/abs/')[-1]
    published = entry.find('a:published', ns).text[:10]
    authors = ', '.join(a.find('a:name', ns).text for a in entry.findall('a:author', ns))
    summary = entry.find('a:summary', ns).text.strip()[:200]
    print(f'{i+1}. [{arxiv_id}] {title}')
    print(f'   Authors: {authors} | Published: {published}')
    print(f'   Abstract: {summary}...')
"
```

### Search Query Syntax

| Prefix | Field | Example |
|--------|-------|---------|
| `all:` | All | `all:transformer+attention` |
| `ti:` | Title | `ti:large+language+models` |
| `au:` | Author | `au:vaswani` |
| `abs:` | Abstract | `abs:reinforcement+learning` |
| `cat:` | Category | `cat:cs.AI` |

**Boolean:** AND (default `+`), OR, ANDNOT, exact phrase `"chain+of+thought"`.

### Semantic Scholar (Citations & Related)

```bash
# Citation count
curl -s "https://api.semanticscholar.org/graph/v1/paper/arXiv:2402.03300?fields=citationCount,influentialCitationCount"

# Who cited it
curl -s "https://api.semanticscholar.org/graph/v1/paper/arXiv:2402.03300/citations?fields=title,authors,year&limit=10"
```

### Helper Script

```bash
python3 ~/.hermes/skills/research/content-discovery/scripts/search_arxiv.py "GRPO reinforcement learning"
python3 ~/.hermes/skills/research/content-discovery/scripts/search_arxiv.py --id 2402.03300
```

### Rate Limits

| API | Rate | Auth |
|-----|------|------|
| arXiv | ~1 req / 3 sec | None |
| Semantic Scholar | 1 req / sec | None (100/sec with key) |

---

## Section 2: Blog/RSS Monitoring (BlogWatcher)

Use when the user asks to track blog updates, monitor RSS feeds, import OPML, or scan for new articles.

### Installation

```bash
go install github.com/JulienTant/blogwatcher-cli/cmd/blogwatcher-cli@latest
```

### Common Commands

```bash
blogwatcher-cli add "My Blog" https://example.com
blogwatcher-cli add "My Blog" https://example.com --feed-url https://example.com/feed.xml
blogwatcher-cli blogs
blogwatcher-cli scan
blogwatcher-cli articles
blogwatcher-cli articles --blog "My Blog"
blogwatcher-cli read 1
blogwatcher-cli import subscriptions.opml
```

### Environment

Database at `~/.blogwatcher-cli/blogwatcher-cli.db`. Use `BLOGWATCHER_DB` to override.

---

## Section 3: Prediction Markets (Polymarket)

Use when the user asks about prediction market odds, event probabilities, or Polymarket data.

### Key Concepts

- **Events** contain one or more **Markets** (1:many)
- **Markets** are binary Yes/No with prices 0.00 to 1.00 = probabilities
- `outcomePrices` field is JSON-encoded: `["0.652", "0.348"]` → "Yes: 65.2%"
- Volume in USDC (dollars)

### Three APIs (read-only, no auth)

1. **Gamma** (`gamma-api.polymarket.com`) — discovery, search, browsing
2. **CLOB** (`clob.polymarket.com`) — real-time prices, orderbooks
3. **Data** (`data-api.polymarket.com`) — trades, open interest

### Typical Workflow

```bash
# Search
curl -s "https://gamma-api.polymarket.com/events?tag=prediction&limit=5"

# Get event with nested markets
curl -s "https://gamma-api.polymarket.com/events?slug=will-bitcoin-hit-100k"

# Get price for a market (using conditionId)
curl -s "https://clob.polymarket.com/price?conditionId=0x..."

# Format as: "Will X happen?" — 65.2% Yes ($1.2M volume)
```

**Parsing:** `outcomePrices`, `outcomes`, and `clobTokenIds` are double-encoded JSON strings. Use `json.loads(market['outcomePrices'])`.

### Helper Script

```bash
python3 ~/.hermes/skills/research/content-discovery/scripts/polymarket.py search "will trump"
python3 ~/.hermes/skills/research/content-discovery/scripts/polymarket.py market --id 0x...
```

### Limitations

- Read-only — does not support placing trades
- Geographic restrictions apply to trading (data is globally accessible)

---

## References

| File | Contents |
|------|----------|
| `references/polymarket-api-endpoints.md` | Full Polymarket API endpoint reference with curl examples |
| `references/deep-research-methodology.md` | Deep research orchestration using parallel web_extract — methodology, failure handling, output structure |

## Pitfalls

- **arXiv returns Atom XML** (not JSON) — use the Python parsing snippet or helper script
- **Semantic Scholar rate limit:** 1 req/sec without key; 100/sec with free API key
- **arXiv IDs:** old format (`hep-th/0601001`) vs new (`2402.03300`); use version suffix for citations
- **Withdrawn papers:** check `<summary>` for withdrawal/retraction notices before treating as valid
- **BlogWatcher database persistence:** Docker users must mount a volume for the DB
- **Polymarket double-encoded fields:** `outcomePrices` is JSON-string-inside-JSON — parse with `json.loads()`
- **New Polymarket markets** may have empty price history
- **All three are read-only** — no write/transaction support in this skill