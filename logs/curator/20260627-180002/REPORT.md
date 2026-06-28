# Curator run — 2026-06-27T18:00:02.108809+00:00

Model: `deepseek/deepseek-v4-flash` via `nous`  ·  Duration: 6m 49s  ·  Agent-created skills: 71 → 58 (-13)

## Auto-transitions (pure, no LLM)

- checked: 71
- marked stale: 0
- archived (no LLM, pure time-based staleness): 0
- reactivated: 0

## LLM consolidation pass

- tool calls: **108** (by name: patch=6, skill_manage=8, skill_view=74, terminal=12, todo=8)
- consolidated into umbrellas: **10**
- pruned (archived for staleness): **4**
- new skills this run: **1**
- state transitions (active ↔ stale ↔ archived): **0**

### Consolidated into umbrella skills (10)

_These skills were **absorbed into another skill** during this run — their content still lives, just under a different name. The original directory was moved to `~/.hermes/skills/.archive/` for safety and can be restored via `hermes curator restore <name>` if the consolidation was wrong._

- `audiocraft-audio-generation` → merged into `audio-and-music` — AudioCraft text-to-music/sound absorbed as Section 1 of the new audio-and-music class-level umbrella
- `design-md` → merged into `claude-design` — Formal DESIGN.md token spec authoring absorbed as labeled section within the design umbrella
- `excalidraw` → merged into `architecture-diagram` — Hand-drawn JSON diagram approach absorbed as labeled section within the diagramming umbrella
- `heartmula` → merged into `audio-and-music` — Open-source song generation absorbed as Section 2 of the audio-and-music umbrella
- `node-inspect-debugger` → merged into `systematic-debugging` — Language-specific debugging tool guide absorbed as section within the class-level debugging methodology skill
- `python-debugpy` → merged into `systematic-debugging` — Language-specific debugging tool guide absorbed as section within the class-level debugging methodology skill
- `simplify-code` → merged into `requesting-code-review` — Parallel-3-agent code cleanup approach absorbed as a labeled section within the pre-commit verification umbrella
- `sketch` → merged into `claude-design` — Throwaway HTML mockup workflow absorbed as labeled section within the design artifact umbrella
- `songsee` → merged into `audio-and-music` — Audio visualization/spectrograms absorbed as Section 4 of the audio-and-music umbrella
- `songwriting-and-ai-music` → merged into `audio-and-music` — Songwriting craft and Suno prompting absorbed as Section 3 of the audio-and-music umbrella

### Pruned — archived for staleness (4)

_These skills were archived without being merged into an umbrella (e.g. stale, unused, or judged irrelevant). Directories live under `~/.hermes/skills/.archive/`. Restore any via `hermes curator restore <name>`._

- `apple-notes` — Platform-locked macOS/iOS built-in skill, unsupported on Linux
- `apple-reminders` — Platform-locked macOS/iOS built-in skill, unsupported on Linux
- `findmy` — Platform-locked macOS/iOS built-in skill, unsupported on Linux
- `imessage` — Platform-locked macOS/iOS built-in skill, unsupported on Linux

### New skills this run (1)

_Usually these are new class-level umbrellas created via `skill_manage action=create`._

- `audio-and-music`

## LLM final summary

## Human Summary

Completed a 6-cluster consolidation pass across 71 candidate skills, archiving 16 and creating 1 new umbrella:

**Cluster 1: Apple platform skills (pruning)**
Archived `apple-notes`, `apple-reminders`, `findmy`, `imessage` — all marked unsupported on Linux. Platform-locked built-ins with zero utility on this machine.

**Cluster 2: Debugging tools → `systematic-debugging`**
Python debugging (pdb/debugpy) and Node.js debugging (node inspect/CDP) were narrow tool-specific siblings of the methodology skill. Added labeled sections with quick-reference tables for both language runtimes, including Hermes-specific recipes for debugging the gateway, `tui_gateway`, and `_SlashWorker` subprocesses.

**Cluster 3: Code cleanup → `requesting-code-review`**
`simplify-code` was a narrow parallel-3-agent review approach that belongs as a labeled section under the pre-commit verification pipeline. Added "Parallel 3-Agent Code Cleanup (Simplify)" section with risk-tiered fix application.

**Cluster 4: Audio & music → new `audio-and-music` umbrella**
Four sibling skills (AudioCraft, HeartMuLa, songwriting/Suno guides, SongSee spectrograms) all serve audio production. Created a single class-level skill with four labeled sections: MusicGen/AudioCraft, HeartMuLa song generation, Songwriting & Suno prompting, and Audio visualization with SongSee.

**Cluster 5: Diagrams → `architecture-diagram`**
Three diagramming approaches (educational SVG via concept-diagrams, hand-drawn JSON via excalidraw, draw.io MCP) now live as labeled sections under the existing architecture diagram umbrella. Each section provides the key design rules, workflow, and output format.

**Cluster 6: Design workflow → `claude-design`**
Two absorbed siblings: `sketch` (throwaway HTML mockup variant comparison) and `design-md` (Google's DESIGN.md token spec format). Both are now labeled sections under claude-design, which already had the decision table routing between them.

## Structured summary (required)
```yaml
consolidations:
  - from: python-debugpy
    into: systematic-debugging
    reason: Language-specific debugging tool guide absorbed as section within the class-level debugging methodology skill
  - from: node-inspect-debugger
    into: systematic-debugging
    reason: Language-specific debugging tool guide absorbed as section within the class-level debugging methodology skill
  - from: simplify-code
    into: requesting-code-review
    reason: Parallel-3-agent code cleanup approach absorbed as a labeled section within the pre-commit verification umbrella
  - from: audiocraft-audio-generation
    into: audio-and-music
    reason: AudioCraft text-to-music/sound absorbed as Section 1 of the new audio-and-music class-level umbrella
  - from: heartmula
    into: audio-and-music
    reason: Open-source song generation absorbed as Section 2 of the audio-and-music umbrella
  - from: songwriting-and-ai-music
    into: audio-and-music
    reason: Songwriting craft and Suno prompting absorbed as Section 3 of the audio-and-music umbrella
  - from: songsee
    into: audio-and-music
    reason: Audio visualization/spectrograms absorbed as Section 4 of the audio-and-music umbrella
  - from: concept-diagrams
    into: architecture-diagram
    reason: Educational SVG diagram approach absorbed as labeled section within the broader diagramming umbrella
  - from: excalidraw
    into: architecture-diagram
    reason: Hand-drawn JSON diagram approach absorbed as labeled section within the diagramming umbrella
  - from: drawio-skill
    into: architecture-diagram
    reason: MCP-based draw.io diagram approach absorbed as labeled section within the diagramming umbrella
  - from: sketch
    into: claude-design
    reason: Throwaway HTML mockup workflow absorbed as labeled section within the design artifact umbrella
  - from: design-md
    into: claude-design
    reason: Formal DESIGN.md token spec authoring absorbed as labeled section within the design umbrella
prunings:
  - name: apple-notes
    reason: Platform-locked macOS/iOS built-in skill, unsupported on Linux
  - name: apple-reminders
    reason: Platform-locked macOS/iOS built-in skill, unsupported on Linux
  - name: findmy
    reason: Platform-locked macOS/iOS built-in skill, unsupported on Linux
  - name: imessage
    reason: Platform-locked macOS/iOS built-in skill, unsupported on Linux
```

## Recovery

- Restore an archived skill: `hermes curator restore <name>`
- All archives live under `~/.hermes/skills/.archive/` and are recoverable by `mv`
- See `run.json` in this directory for the full machine-readable record.
