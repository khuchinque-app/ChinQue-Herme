---
name: diagrams
description: "Generate visual diagrams of systems, architectures, and flows. Two output formats: dark-themed SVG/HTML (Cocoon style) for tech/infra diagrams, or hand-drawn Excalidraw JSON files for organic/whiteboard-style diagrams."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [diagrams, architecture, excalidraw, svg, visualization, infrastructure, flowcharts]
    related_skills: [baoyu-infographic, claude-design]
---

# Diagrams — System Architecture & Flow Visualization

Two output formats for different diagramming needs:

| Format | Style | Best for | Opens in |
|--------|-------|----------|----------|
| **SVG/HTML** (Cocoon) | Dark theme, grid background, color-coded layers, tech aesthetic | Cloud infra, microservices, backend architecture, deployment topology | Any browser |
| **Excalidraw JSON** | Hand-drawn, organic, whiteboard feel | Flowcharts, concept maps, sequence diagrams, architecture sketches | excalidraw.com |

---

## Section A: SVG Architecture Diagrams (Cocoon style)

**Use when:** User asks for a technical architecture diagram, cloud infrastructure map, microservice topology, or system visualization. Output is a single self-contained `.html` file with inline SVG.

### Color palette (semantic)

| Component | Fill | Stroke |
|-----------|------|--------|
| Frontend | `rgba(8, 51, 68, 0.4)` | `#22d3ee` (cyan) |
| Backend | `rgba(6, 78, 59, 0.4)` | `#34d399` (emerald) |
| Database | `rgba(76, 29, 149, 0.4)` | `#a78bfa` (violet) |
| AWS/Cloud | `rgba(120, 53, 15, 0.3)` | `#fbbf24` (amber) |
| Security | `rgba(136, 19, 55, 0.4)` | `#fb7185` (rose) |
| Message Bus | `rgba(251, 146, 60, 0.3)` | `#fb923c` (orange) |
| External | `rgba(30, 41, 59, 0.5)` | `#94a3b8` (slate) |

### Layout rules

- Background: Slate-950 (`#020617`) with 40px grid pattern
- Components: rounded rects (`rx="6"`), 60px standard height, 1.5px strokes
- Double-rect masking: opaque `#0f172a` background behind each component
- Arrowheads via SVG markers; security flows get dashed rose lines
- Boundaries: security groups (`4,4` dashed rose), regions (`8,4` dashed amber)
- Legend must be placed outside ALL boundary boxes (lowest Y + 20px)
- Info cards: 3-card grid below the diagram for summary details

### Template

Load the full HTML template for structure, CSS, and SVG component examples:
```
skill_view(name="diagrams", file_path="templates/template.html")
```

Based on [Cocoon AI's architecture-diagram-generator](https://github.com/Cocoon-AI/architecture-diagram-generator) (MIT).

---

## Section B: Excalidraw Diagrams

**Use when:** User wants hand-drawn/whiteboard-style diagrams, flowcharts, sequence diagrams, or concept maps. Output is a `.excalidraw` JSON file that can be drag-and-dropped onto excalidraw.com.

### File format

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "hermes-agent",
  "elements": [ ... ],
  "appState": { "viewBackgroundColor": "#ffffff" }
}
```

### Elements reference

**Shapes:** `rectangle`, `ellipse`, `diamond`, `arrow`, `text`
- Each shape needs `type`, `id`, `x`, `y`, `width`, `height`
- Use `roundness: { type: 3 }` for rounded corners
- Defaults applied: `strokeColor: #1e1e1e`, `backgroundColor: transparent`, `roughness: 1`

**Container binding (labels inside shapes):**
```json
{ "type": "rectangle", "id": "r1", "x": 100, "y": 100, "width": 200, "height": 80,
  "boundElements": [{ "id": "t_r1", "type": "text" }] },
{ "type": "text", "id": "t_r1", "x": 105, "y": 110, "width": 190, "height": 25,
  "text": "Hello", "fontSize": 20, "fontFamily": 1, "strokeColor": "#1e1e1e",
  "textAlign": "center", "verticalAlign": "middle",
  "containerId": "r1", "originalText": "Hello", "autoResize": true }
```

**Arrow connections:** Bind arrows to shapes via `startBinding` / `endBinding`:
```json
{ "type": "arrow", "id": "a1", "x": 300, "y": 150, "width": 150, "height": 0,
  "points": [[0,0],[150,0]], "endArrowhead": "arrow",
  "startBinding": { "elementId": "r1", "fixedPoint": [1, 0.5] },
  "endBinding": { "elementId": "r2", "fixedPoint": [0, 0.5] } }
```

### Drawing order (z-order)
Array order = z-order. Always emit: background zone → shape → its bound text → its arrows → next shape. Place bound text immediately after its container.

### Sizing
- Minimum font: 16 for body, 20 for titles, 14 for annotations (sparingly)
- Minimum shape: 120x60 for labeled elements
- 20-30px gaps between elements

### Color palette

| Use | Fill |
|-----|------|
| Input/Primary | `#a5d8ff` |
| Output/Success | `#b2f2bb` |
| External/Warning | `#ffd8a8` |
| Processing | `#d0bfff` |
| Error/Critical | `#ffc9c9` |
| Notes/Decisions | `#fff3bf` |
| Storage/Data | `#c3fae8` |

### Upload for shareable link
```bash
python ~/.hermes/skills/creative/diagrams/scripts/upload.py ~/diagram.excalidraw
```
Requires `cryptography` pip package.

### References

- `references/excalidraw-examples.md` — Larger Excalidraw diagram examples
- `references/excalidraw-dark-mode.md` — Dark mode diagrams
- `references/excalidraw-colors.md` — Full color tables

---

## Choosing between SVG and Excalidraw

| Criterion | SVG/HTML | Excalidraw |
|-----------|----------|------------|
| Look | Polished, dark, professional | Sketchy, hand-drawn, informal |
| Editability | Manual HTML editing | drag-and-drop on excalidraw.com |
| Shareability | Open in any browser | Upload to excalidraw.com for URL |
| Best for | Cloud infra, deployment, microservices | Whiteboard sessions, brainstorming, flowcharts |
