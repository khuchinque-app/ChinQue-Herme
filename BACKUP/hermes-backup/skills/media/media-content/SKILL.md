---
name: media-content
description: "Fetch and process media content from social platforms: GIF search via Tenor API and YouTube transcript extraction. Use when finding reaction GIFs or summarizing/transcribing videos."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [media, gif, tenor, youtube, transcript, content]
---

# Media Content

Fetch and process media content from social platforms. Two subsystems:

| Subsystem | What | Auth Required |
|-----------|------|--------------|
| **GIF Search (Tenor)** | Search and download reaction GIFs | Tenor API key (free) |
| **YouTube Transcripts** | Fetch video transcripts → summaries, threads, blogs | None |

---

## Section 1: GIF Search (Tenor API)

Use when the user asks for reaction GIFs, visual content for chat, or GIF downloads.

### Setup

Set `TENOR_API_KEY` in `.env`. Get a free key at https://developers.google.com/tenor/guides/quickstart.

### Search

```bash
curl -s "https://tenor.googleapis.com/v2/search?q=thumbs+up&limit=5&key=${TENOR_API_KEY}" | jq -r '.results[].media_formats.gif.url'
```

### Download

```bash
URL=$(curl -s "https://tenor.googleapis.com/v2/search?q=celebration&limit=1&key=${TENOR_API_KEY}" | jq -r '.results[0].media_formats.gif.url')
curl -sL "$URL" -o celebration.gif
```

### API Parameters

| Parameter | Description |
|-----------|-------------|
| `q` | Search query (URL-encode spaces as `+`) |
| `limit` | Max results (1-50) |
| `contentfilter` | Safety: `off`, `low`, `medium`, `high` |
| `media_filter` | Filter: `gif`, `tinygif`, `mp4`, `tinymp4`, `webm` |

### Media Formats

| Format | Use |
|--------|-----|
| `gif` | Full quality |
| `tinygif` | Small preview (use for chat) |
| `mp4` | Video version (smaller file) |

---

## Section 2: YouTube Transcripts

Use when the user shares a YouTube URL and asks to summarize, transcribe, or extract content from the video.

### Setup

```bash
uv pip install youtube-transcript-api
```

### Fetch Transcript

```bash
SKILL_DIR=~/.hermes/skills/media/media-content
uv run python3 $SKILL_DIR/scripts/fetch_transcript.py "https://youtube.com/watch?v=VIDEO_ID"
uv run python3 $SKILL_DIR/scripts/fetch_transcript.py "URL" --text-only --timestamps
uv run python3 $SKILL_DIR/scripts/fetch_transcript.py "URL" --language tr,en
```

Accepts any YouTube URL format: short links (youtu.be), shorts, embeds, live links, or raw 11-char video ID.

### Output Formats (choose based on user request)

| Format | Description |
|--------|-------------|
| **Chapters** | Timestamped chapter list grouped by topic shifts |
| **Summary** | 5-10 sentence overview |
| **Chapter summaries** | Chapters + short paragraph each |
| **Thread** | Twitter/X numbered posts, each under 280 chars |
| **Blog post** | Full article with title, sections, takeaways |
| **Quotes** | Notable quotes with timestamps |

### Error Handling

- **Transcript disabled:** tell the user; suggest checking subtitles on the video page
- **No matching language:** retry without `--language` to fetch any available transcript
- **Chunk if large:** if transcript >50K chars, split into 40K-chunks with 2K overlap, summarize each, then merge

---

## Pitfalls

- **Tenor API key required** — get from Google Cloud Console Tenor API (free tier, generous limits)
- **YouTube transcripts not always available** — some videos have subtitles disabled
- **Transcript language fallback:** without `--language` flag, the API returns the default (usually English) regardless of video language
- **Large transcripts** need chunking before summarization (threshold: ~50K chars)
- **GIF URLs can be used in markdown:** `![alt](url)`