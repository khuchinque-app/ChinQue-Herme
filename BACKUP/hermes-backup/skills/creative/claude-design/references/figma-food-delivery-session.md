# Session Reference: Food Delivery Figma URL Extraction

Date: 2026-07-02
Source: Figma community file 1024793417351086962

## Figma File Metadata Extracted

| Field | Value |
|---|---|
| Title | Food Delivery \| Mobile app Design |
| Author | Anna Virenko (figma.com/@anna_virenko) |
| License | CC BY 4.0 |
| Tags | app design, delivery, delivery app, eat, food, food app, food delivery, mobile app, mobile design |
| Category | Visual assets > Device mockups |
| Age | 5 years old |
| Users | 2.9k |
| Cover URL | `https://s3-alpha.figma.com/hub/file/1165372441/70ca6b19-978d-45ac-885a-80a4b95b7f98-cover.png` |
| Download | Originally from Dribbble (shot 15026863 — now 404) |

## Alternative Source Found

`https://figma-free.com/food-delivery-mobile-app-design-figma-free/`
→ Cover image: `https://figma-free.com/wp-content/uploads/2021/06/8-9.png`
→ Download via `curl -s -o /tmp/preview.png <url>`
→ Result: 747x547 PNG (235 KB)

## What Worked

1. `web_extract(urls=["figma.com/community/file/..."])` → title, tags, comments, cover URL
2. `curl` download of figma-free.com's mirror → PNG retrieved
3. `file` command confirmed image format and dimensions

## What Did NOT Work

1. Direct `curl` to s3-alpha.figma.com → CloudFront 403 (always)
2. `web_extract` on image/png URL → "cannot process binary files"
3. Dribbble shot URL → 404 (stale after 5 years)

## Key Lesson

When a user shares a Figma community file, ALWAYS expect the S3 cover image
to be CloudFront-blocked. Go immediately to figma-free.com or Google Image
search as the fallback, rather than retrying the S3 URL.
