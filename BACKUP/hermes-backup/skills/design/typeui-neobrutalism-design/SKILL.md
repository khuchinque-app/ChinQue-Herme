---
name: typeui-neobrutalism-design
description: "Use when generating bold, high-contrast UI. Neobrutalism — thick borders, hard shadows, vivid yellow (#FDC800) + violet (#432DD7), Inter font."
version: 1.0.0
author: Hermes Agent (adapted from typeui.sh)
license: MIT
metadata:
  hermes:
    tags: [design, ui, css, typeui, neobrutalism]
    related_skills: [typeui-paper-design, typeui-minimal-design]
---

# Neobrutalism Design System

When generating bold, high-impact UI, use the Neobrutalism design system.

## Design Tokens

### Color Palette
| Token | Value | Purpose |
|-------|-------|---------|
| Primary | `#FDC800` | Primary actions, highlighted surfaces, accent blocks |
| Secondary | `#432DD7` | Supporting actions, links, complementary accents |
| Success | `#16A34A` | Positive feedback |
| Warning | `#D97706` | Caution indicators |
| Danger | `#DC2626` | Error states |
| Surface | `#FBFBF9` | Background surfaces (off-white) |
| Text | `#1C293C` | Body text (deep navy-black) |

### Typography
- **Primary + Display font:** Inter (all text)
- **Monospace font:** JetBrains Mono (code, technical content)
- **Type scale:** 13 / 15 / 17 / 21 / 27 / 35px (odd-number progression)
- **Weights:** 100–900 (headings at 700–900)

### Spacing
4px base unit. Scale: 4 / 8 / 12 / 16 / 24 / 32px

## Signature Visual Treatments
- **Hard shadows** — solid, offset box shadows (4–6px offset, no blur). Paper-cutout effect
- **Thick borders** — 2–3px solid black borders on interactive elements and containers
- **Flat surfaces** — no gradients, no transparency, no glassmorphism
- **High contrast** — sharp contrast between text and backgrounds
- **Bold interactive states** — hover shifts shadows, active compresses them, focus uses thick outlines

## Component Rules
40+ component families. Each with explicit state behavior for default/hover/focus-visible/active/disabled/loading/error. Keyboard, pointer, and touch interaction patterns.

## Accessibility
WCAG 2.2 AA. The bold visual style naturally aids accessibility (prominent focus states, high contrast). When neobrutalist aesthetic conflicts with accessibility, prioritize accessibility.
