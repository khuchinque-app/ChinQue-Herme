---
name: architecture-diagram
description: "Dark-themed SVG architecture/cloud/infra diagrams as HTML."
version: 1.0.0
author: Cocoon AI (hello@cocoon-ai.com), ported by Hermes Agent
license: MIT
dependencies: []
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [architecture, diagrams, SVG, HTML, visualization, infrastructure, cloud]
    related_skills: [concept-diagrams, excalidraw]
---

# Architecture Diagram Skill

Generate professional, dark-themed technical architecture diagrams as standalone HTML files with inline SVG graphics. No external tools, no API keys, no rendering libraries — just write the HTML file and open it in a browser.

## Scope

**Best suited for:**
- Software system architecture (frontend / backend / database layers)
- Cloud infrastructure (VPC, regions, subnets, managed services)
- Microservice / service-mesh topology
- Database + API map, deployment diagrams
- Anything with a tech-infra subject that fits a dark, grid-backed aesthetic

**Look elsewhere first for:**
- Physics, chemistry, math, biology, or other scientific subjects
- Physical objects (vehicles, hardware, anatomy, cross-sections)
- Floor plans, narrative journeys, educational / textbook-style visuals
- Hand-drawn whiteboard sketches (consider `excalidraw`)
- Animated explainers (consider an animation skill)

If a more specialized skill is available for the subject, prefer that. If none fits, this skill can also serve as a general SVG diagram fallback — the output will just carry the dark tech aesthetic described below.

Based on [Cocoon AI's architecture-diagram-generator](https://github.com/Cocoon-AI/architecture-diagram-generator) (MIT).

## Workflow

1. User describes their system architecture (components, connections, technologies)
2. Generate the HTML file following the design system below
3. Save with `write_file` to a `.html` file (e.g. `~/architecture-diagram.html`)
4. User opens in any browser — works offline, no dependencies

### Output Location

Save diagrams to a user-specified path, or default to the current working directory:
```
./[project-name]-architecture.html
```

### Preview

After saving, suggest the user open it:
```bash
# macOS
open ./my-architecture.html
# Linux
xdg-open ./my-architecture.html
```

## Design System & Visual Language

### Color Palette (Semantic Mapping)

Use specific `rgba` fills and hex strokes to categorize components:

| Component Type | Fill (rgba) | Stroke (Hex) |
| :--- | :--- | :--- |
| **Frontend** | `rgba(8, 51, 68, 0.4)` | `#22d3ee` (cyan-400) |
| **Backend** | `rgba(6, 78, 59, 0.4)` | `#34d399` (emerald-400) |
| **Database** | `rgba(76, 29, 149, 0.4)` | `#a78bfa` (violet-400) |
| **AWS/Cloud** | `rgba(120, 53, 15, 0.3)` | `#fbbf24` (amber-400) |
| **Security** | `rgba(136, 19, 55, 0.4)` | `#fb7185` (rose-400) |
| **Message Bus** | `rgba(251, 146, 60, 0.3)` | `#fb923c` (orange-400) |
| **External** | `rgba(30, 41, 59, 0.5)` | `#94a3b8` (slate-400) |

### Typography & Background
- **Font:** JetBrains Mono (Monospace), loaded from Google Fonts
- **Sizes:** 12px (Names), 9px (Sublabels), 8px (Annotations), 7px (Tiny labels)
- **Background:** Slate-950 (`#020617`) with a subtle 40px grid pattern

```svg
<!-- Background Grid Pattern -->
<pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
  <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#1e293b" stroke-width="0.5"/>
</pattern>
```

## Technical Implementation Details

### Component Rendering
Components are rounded rectangles (`rx="6"`) with 1.5px strokes. To prevent arrows from showing through semi-transparent fills, use a **double-rect masking technique**:
1. Draw an opaque background rect (`#0f172a`)
2. Draw the semi-transparent styled rect on top

### Connection Rules
- **Z-Order:** Draw arrows *early* in the SVG (after the grid) so they render behind component boxes
- **Arrowheads:** Defined via SVG markers
- **Security Flows:** Use dashed lines in rose color (`#fb7185`)
- **Boundaries:**
  - *Security Groups:* Dashed (`4,4`), rose color
  - *Regions:* Large dashed (`8,4`), amber color, `rx="12"`

### Spacing & Layout Logic
- **Standard Height:** 60px (Services); 80-120px (Large components)
- **Vertical Gap:** Minimum 40px between components
- **Message Buses:** Must be placed *in the gap* between services, not overlapping them
- **Legend Placement:** **CRITICAL.** Must be placed outside all boundary boxes. Calculate the lowest Y-coordinate of all boundaries and place the legend at least 20px below it.

## Document Structure

The generated HTML file follows a four-part layout:
1. **Header:** Title with a pulsing dot indicator and subtitle
2. **Main SVG:** The diagram contained within a rounded border card
3. **Summary Cards:** A grid of three cards below the diagram for high-level details
4. **Footer:** Minimal metadata

### Info Card Pattern
```html
<div class="card">
  <div class="card-header">
    <div class="card-dot cyan"></div>
    <h3>Title</h3>
  </div>
  <ul>
    <li>• Item one</li>
    <li>• Item two</li>
  </ul>
</div>
```

## Output Requirements
- **Single File:** One self-contained `.html` file
- **No External Dependencies:** All CSS and SVG must be inline (except Google Fonts)
- **No JavaScript:** Use pure CSS for any animations (like pulsing dots)
- **Compatibility:** Must render correctly in any modern web browser

## Section: Concept Diagrams (Educational/Physical SVG)

For educational, textbook-style diagrams — physics, chemistry, biology, physical objects, floor plans, narrative journeys. Uses a unified flat, minimal design system with 9 semantic color ramps, automatic dark mode, and sentence-case typography.

### Design System

- **9 color ramps** (purple, teal, coral, pink, gray, blue, green, amber, red) each with 7 stops
- **Typography:** 14px (th) for titles, 12px (ts) for subtitles. Sentence case only.
- **Spacing:** ViewBox width 680px, safe area x=40-640, 60px minimum gap between boxes
- **Stroke:** 0.5px on all node borders, `rx="8"` rect rounding
- **No gradients, shadows, glow, or blur effects**

### Workflow

1. Decide diagram type (flowchart, structural/containment, physical, hub-spoke, UI mockup)
2. Lay out components using the design system
3. Write full HTML page using `architecture-diagram`'s template (load with `skill_view`) as the wrapper
4. Save as standalone HTML file — works offline, no dependencies

For full details on physical shape cookbook, infrastructure patterns, and dashboard patterns, see the archived `concept-diagrams` skill's references files.

## Section: Excalidraw — Hand-Drawn JSON Diagrams

Create hand-drawn style diagrams as standard Excalidraw JSON, saved as `.excalidraw` files. Open at excalidraw.com or upload for shareable links.

**Envelope format:**
```json
{ "type": "excalidraw", "version": 2, "source": "hermes-agent", "elements": [...],
  "appState": { "viewBackgroundColor": "#ffffff" } }
```

**Key rules:**
- Labeled shapes use container binding (`boundElements`/`containerId`) — NOT `"label"` property
- Drawing order = array order (first = back, last = front). Emit progressively: shape → text → arrow
- Minimum fontSize: 16 body / 20 titles. Minimum shape: 120x60
- Colors: `#a5d8ff` (blue), `#b2f2bb` (green), `#ffd8a8` (orange), `#d0bfff` (purple), `#ffc9c9` (red)
- Upload: `python scripts/upload.py diagram.excalidraw` (needs `cryptography`)

Excalidraw uses a hand-drawn visual style (roughness 1, Virgil font) — best for whiteboard-style diagrams, concept maps, and informal sketches.

## Section: draw.io — MCP-Based Diagrams

Create and edit draw.io diagrams through the configured `drawio` MCP server. Requires the server to be configured.

**Workflow:**
1. Call `start_session` before any create or edit
2. Use `create_new_diagram` with complete `mxGraphModel` XML
3. Always `get_diagram` before `edit_diagram` — never guess cell IDs
4. Export `.drawio` (editable source) + `.svg` (shareable)

**Architecture rules:** Identify layers (clients, edge, services, data, external), draw trust zone boundaries, use directional arrows with protocol labels, use containers for service groups.

**ML diagram rules:** Show main flow input→output, use repeated blocks for model structure, color-code semantically (inputs, hidden states, attention, residual).

**Animated connectors:** `dashed=1;dashPattern=8 4;flowAnimation=1;` — export to `.svg` to preserve.

## Template Reference

Load the full HTML template for the exact structure, CSS, and SVG component examples:

```
skill_view(name="architecture-diagram", file_path="templates/template.html")
```

The template contains working examples of every component type (frontend, backend, database, cloud, security), arrow styles (standard, dashed, curved), security groups, region boundaries, and the legend — use it as your structural reference when generating diagrams.
