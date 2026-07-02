# Notion Block Types

Reference for creating and reading all common Notion block types via the API.

## Creating blocks

Use `PATCH /v1/blocks/{page_id}/children` with a `children` array. Each block follows:

```json
{"object": "block", "type": "<type>", "<type>": { ... }}
```

### Paragraph
```json
{"type": "paragraph", "paragraph": {"rich_text": [{"text": {"content": "Hello world"}}]}}
```

### Headings
```json
{"type": "heading_1", "heading_1": {"rich_text": [{"text": {"content": "Title"}}]}}
{"type": "heading_2", "heading_2": {"rich_text": [{"text": {"content": "Section"}}]}}
{"type": "heading_3", "heading_3": {"rich_text": [{"text": {"content": "Subsection"}}]}}
```

### Bulleted / Numbered list
```json
{"type": "bulleted_list_item", "bulleted_list_item": {"rich_text": [{"text": {"content": "Item"}}]}}
{"type": "numbered_list_item", "numbered_list_item": {"rich_text": [{"text": {"content": "Step 1"}}]}}
```

### To-do / Quote / Callout
```json
{"type": "to_do", "to_do": {"rich_text": [{"text": {"content": "Task"}}], "checked": false}}
{"type": "quote", "quote": {"rich_text": [{"text": {"content": "Something wise"}}]}}
{"type": "callout", "callout": {"rich_text": [{"text": {"content": "Note"}}], "icon": {"emoji": "💡"}}}
```

### Code / Toggle / Divider
```json
{"type": "code", "code": {"rich_text": [{"text": {"content": "print('hello')"}}], "language": "python"}}
{"type": "toggle", "toggle": {"rich_text": [{"text": {"content": "Click to expand"}}]}}
{"type": "divider", "divider": {}}
```

### Bookmark / Image (external)
```json
{"type": "bookmark", "bookmark": {"url": "https://example.com"}}
{"type": "image", "image": {"type": "external", "external": {"url": "https://example.com/photo.png"}}}
```

## Reading blocks

When reading from `GET /v1/blocks/{page_id}/children`:

| Type | Text location | Extra |
|------|--------------|-------|
| paragraph | `.paragraph.rich_text` | — |
| heading_1/2/3 | `.heading_N.rich_text` | — |
| bulleted_list_item | `.bulleted_list_item.rich_text` | — |
| numbered_list_item | `.numbered_list_item.rich_text` | — |
| to_do | `.to_do.rich_text` | `.to_do.checked` |
| toggle | `.toggle.rich_text` | has children |
| code | `.code.rich_text` | `.code.language` |
| quote | `.quote.rich_text` | — |
| callout | `.callout.rich_text` | `.callout.icon.emoji` |
| divider | — | — |
| image | `.image.caption` | `.image.file.url` or `.image.external.url` |
| bookmark | `.bookmark.caption` | `.bookmark.url` |
| child_page | — | `.child_page.title` |
| child_database | — | `.child_database.title` |

Rich text arrays contain objects with `.plain_text` — concatenate for readable output.

---

*Contributed by [@dogiladeveloper](https://github.com/dogiladeveloper)*
