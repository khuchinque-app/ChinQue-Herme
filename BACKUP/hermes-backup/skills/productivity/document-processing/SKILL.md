---
name: document-processing
description: "Process documents: PDF extraction/OCR (pymupdf, marker-pdf), PDF editing (nano-pdf), and DOCX parsing. Umbrella for all document-format operations except PowerPoint (see related skill)."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [PDF, documents, OCR, extraction, editing, markdown, DOCX, text]
    related_skills: [powerpoint, arxiv]
---

# Document Processing

Umbrella for PDF, DOCX, and scanned-document operations. Covers text extraction, OCR, PDF editing, and format conversions. For PowerPoint (.pptx), use the `powerpoint` skill.

## Quick Reference

| Task | Tool | See |
|------|------|-----|
| Text-based PDF extraction | pymupdf | § PDF Extraction below |
| Scanned PDF / OCR | marker-pdf | § PDF Extraction below |
| PDF text editing (nano-pdf) | nano-pdf CLI | § PDF Editing below |
| Word documents | python-docx | § Word Documents below |
| URL-based documents | web_extract | § § Remote Documents below |

---

## Remote Documents (always try first)

If the document is at a URL, always try `web_extract` before local tools:

```
web_extract(urls=["https://arxiv.org/pdf/2402.03300"])
web_extract(urls=["https://example.com/report.pdf"])
```

This handles PDF-to-markdown conversion with no local dependencies.

---

## PDF Extraction

### pymupdf (lightweight, text-based PDFs)

Fast and works everywhere. ~25MB install.

```bash
pip install pymupdf pymupdf4llm
```

Via helper script:
```bash
python3 scripts/extract_pymupdf.py document.pdf              # Plain text
python3 scripts/extract_pymupdf.py document.pdf --markdown    # Markdown
python3 scripts/extract_pymupdf.py document.pdf --tables      # Tables
python3 scripts/extract_pymupdf.py document.pdf --images out/ # Extract images
python3 scripts/extract_pymupdf.py document.pdf --metadata    # Title, author, pages
python3 scripts/extract_pymupdf.py document.pdf --pages 0-4   # Specific pages
```

Inline:
```bash
python3 -c "
import pymupdf
doc = pymupdf.open('document.pdf')
for page in doc:
    print(page.get_text())
"
```

### marker-pdf (OCR, scanned docs, complex layouts)

Higher quality but heavy (~3-5GB with PyTorch models). Use when pymupdf isn't enough.

```bash
pip install marker-pdf
python3 scripts/extract_marker.py document.pdf              # Markdown
python3 scripts/extract_marker.py document.pdf --json       # JSON with metadata
python3 scripts/extract_marker.py document.pdf --use_llm    # LLM-boosted accuracy
```

CLI (installed with marker-pdf):
```bash
marker_single document.pdf --output_dir ./output
marker /path/to/folder --workers 4     # Batch
```

### Decision Table

| Feature | pymupdf (~25MB) | marker-pdf (~3-5GB) |
|---------|-----------------|---------------------|
| Text-based PDF | ✅ | ✅ |
| Scanned PDF (OCR) | ❌ | ✅ (90+ languages) |
| Tables | ✅ (basic) | ✅ (high accuracy) |
| Equations / LaTeX | ❌ | ✅ |
| Markdown output | ✅ (via pymupdf4llm) | ✅ (native, higher quality) |
| Install size | ~25MB | ~3-5GB (PyTorch + models) |
| Speed | Instant | ~1-14s/page (CPU), ~0.2s/page (GPU) |

---

## PDF Editing (nano-pdf)

Edit PDFs using natural-language instructions.

### Setup

```bash
uv pip install nano-pdf
```

### Usage

```bash
nano-pdf edit <file.pdf> <page_number> "<instruction>"
```

### Examples

```bash
nano-pdf edit deck.pdf 1 "Change the title to 'Q3 Results' and fix the typo in the subtitle"
nano-pdf edit report.pdf 3 "Update the date from January to February 2026"
nano-pdf edit contract.pdf 2 "Change the client name from 'Acme Corp' to 'Acme Industries'"
```

### Notes

- Page numbers may be 0-based or 1-based depending on version — if the edit hits the wrong page, retry with ±1.
- Always verify the output PDF after editing.
- The tool uses an LLM under the hood — requires an API key.
- Works well for text changes; complex layout modifications may need a different approach.

---

## Split, Merge & Search PDFs

pymupdf handles these natively:

### Split

```python
import pymupdf
doc = pymupdf.open("report.pdf")
new = pymupdf.open()
for i in range(5):
    new.insert_pdf(doc, from_page=i, to_page=i)
new.save("pages_1-5.pdf")
```

### Merge

```python
result = pymupdf.open()
for path in ["a.pdf", "b.pdf", "c.pdf"]:
    result.insert_pdf(pymupdf.open(path))
result.save("merged.pdf")
```

### Search

```python
doc = pymupdf.open("report.pdf")
for i, page in enumerate(doc):
    results = page.search_for("revenue")
    if results:
        print(f"Page {i+1}: {len(results)} match(es)")
```

---

## Word Documents (DOCX)

For DOCX, use `python-docx` (parses actual document structure, better than any PDF approach):

```bash
pip install python-docx
```

```python
from docx import Document
doc = Document("file.docx")
for para in doc.paragraphs:
    print(para.text)
```

For batch conversion of DOCX to markdown:
```bash
pip install "markitdown[all]"
python -m markitdown file.docx
```

---

## Pitfalls

1. **URL first.** Always try `web_extract` before installing local tools — it's free and works for any URL-accessible document.
2. **marker-pdf is heavy.** It downloads ~2.5GB of models to `~/.cache/huggingface/` on first use. Only install when pymupdf isn't enough.
3. **nano-pdf LLM dependency.** Requires an API key — it uses an LLM under the hood to interpret edit instructions.
4. **pymupdf for scanned docs.** pymupdf cannot OCR scanned pages. If the PDF is scanned, use marker-pdf.
5. **DOCX ≠ PDF.** Different tools for different formats. `python-docx` is for Word files; pymupdf/marker-pdf are for PDFs.
6. **Check disk space for marker-pdf.** If the system lacks ~5GB free, use pymupdf (text PDFs) or provide a URL for web_extract.
