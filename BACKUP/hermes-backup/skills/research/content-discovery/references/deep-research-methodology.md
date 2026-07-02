# Deep Research via Parallel Web Extraction

A reusable methodology for orchestrating deep research using parallel `web_extract` calls instead of delegating to subagents. Use when the user wants a comprehensive research document covering multiple sources and angles.

## When to Use This

- User asks for "deep research" on a topic
- Multiple sources/angles needed (docs, papers, forums, GitHub)
- Deliverable is a structured `.md` file, not a chat answer

## Methodology

### Phase 1: Identify Source Categories

Identify 4-5 source categories. Typical split:

1. **Framework docs / official docs** — the authoritative source
2. **Community discussions** — Reddit (r/LocalLLaMA, r/AI_Agents), HN, GitHub Discussions
3. **Papers** — arXiv, Semantic Scholar
4. **YouTube / talks** — transcripts (if accessible)
5. **Running examples** — your own system (Hermes, containers, etc.)

### Phase 2: Parallel Fetch

Batch all `web_extract` calls in a single turn. Independent URLs go in one batch.

```python
from hermes_tools import web_extract

# Batch 1: framework docs
web_extract(urls=["https://docs.example.com/page1",
                   "https://docs.example.com/page2"])

# Batch 2: community
web_extract(urls=["https://news.ycombinator.com/item?id=...",
                   "https://github.com/org/repo/discussions"])

# Batch 3: papers
web_extract(urls=["https://arxiv.org/abs/..."])
```

**Timing:** Each batch is one round-trip. 3-4 batches covers most topics.

### Phase 3: Handle Failures

Common failures and how to handle them — DO NOT retry the same URL with the same tool:

| Error | Likely Cause | Action |
|-------|-------------|--------|
| `Status code 504` / `fetch_timeout` | Firecrawl upstream timeout | Skip or try direct curl |
| `Website Not Supported` | Firecrawl blocks Reddit/Discord | Note as thin signal area in output |
| `403 / This video isn't available` | YouTube blocks scraping | Note as thin signal area |
| `404 / Page not found` | URL wrong or moved | Try alternate URL or direct source |
| `UPSTREAM_ERROR` | Firecrawl timeout | Lower `char_limit` or skip |

**Rule:** Never fabricate a citation. If a source couldn't be loaded, note "Could not be directly scraped — findings synthesized from cross-referenced content" or "Signal thin — recommend manual reading."

### Phase 4: Process & Classify

For each successfully fetched page, classify what you got:

- **Framework doc** — architecture, API, patterns, pros/cons
- **Community post** — war stories, gotchas, pitfall descriptions
- **Paper** — formal method, evaluation results, claims
- **Running system** — real-world validation of specific claims

Cross-check claims across sources. Mark as:
- **Verified** — confirmed by multiple sources or running system
- **Plausible, limited eval** — only tested in narrow setting
- **Disputed** — conflicting claims across sources

### Phase 5: Write Structured Output

Create a `.md` file with this structure:

```markdown
# Title

**Date:** ...
**Scope:** ...
**Methodology:** ...

## 1. Overview
What the topic is, the main approaches, a summary table of categories.

## 2. Architecture Patterns
Detailed patterns with how-they-work descriptions, code snippets, pros/cons.

## 3. Comparison / Framework Table
Feature-by-feature comparison matrix with a legend for ✅/❌/⚠️.

## 4. Real-World Lessons & Pitfalls
Sourced from community discussions and running experience.

## 5. Key Sources
Numbered list with links. Group by category (Framework Docs, Papers, Community, etc.).

## 6. Thin Signal Areas
Honest disclosure of what couldn't be scraped and recommendations for follow-up.

## 7. Architectural Verdicts
Table of specific claims with sources and verdicts (Verified / Plausible / Disputed).
```

### Phase 6: Report

End with:
- The file path
- A 10-line summary (bullet points)
- Total source count
- Flag any thin signal areas

## Pitfalls

- **Firecrawl timeout on large docs:** Lower `char_limit` to 8000-10000 for big pages. Full text is saved to cache.
- **Reddit not accessible:** Note and move on. Don't waste retries.
- **YouTube 403:** Always happens with web_extract. Use transcript APIs if available, otherwise flag as thin.
- **Google Scholar / login-gated pages:** Blocked. Skip and flag.
- **Wikipedia:** Works fine but is secondary — prefer primary sources.
- **arXiv abstracts load, PDFs may not:** Use the abstract page URL (`/abs/...`) not the PDF URL.

## Example outputs

This methodology produced:
- `pi-agents-meta-agents-2026-07-01.md` — 15 sources, 356 lines, $0 research costs (all web_extract, no API calls)
