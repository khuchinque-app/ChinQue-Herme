---
name: typeui-paper-design
description: "Use when generating UI code. Paper Design — minimal, clean design system with paper-textured aesthetics. Primary=#111111, accent=#8B5CF6, Roboto/Montserrat/PT Mono."
version: 1.0.0
author: Hermes Agent (adapted from typeui.sh)
license: MIT
metadata:
  hermes:
    tags: [design, ui, css, typeui, paper]
    related_skills: [typeui-neobrutalism-design, typeui-minimal-design]
---

# Paper Design System

When generating UI code, follow the Paper Design system unless the user specifies otherwise.

## Design Tokens

### Color Palette
| Token | Value | Purpose |
|-------|-------|---------|
| Primary | `#111111` | Main interactive elements, headings, emphasis |
| Secondary | `#8B5CF6` | Accent highlights, links, secondary actions |
| Success | `#16A34A` | Positive feedback, confirmations |
| Warning | `#D97706` | Caution indicators |
| Danger | `#DC2626` | Error states, destructive actions |
| Surface | `#FFFFFF` | Background and card surfaces |
| Text | `#111827` | Body text and content |

### Typography
- **Primary font:** Roboto (body text, labels, general UI)
- **Display font:** Montserrat (headings, hero sections)
- **Monospace font:** PT Mono (code blocks, terminal output)
- **Type scale:** 14 / 16 / 18 / 24 / 32 / 40px
- **Weights:** 100–900

### Spacing
4px base unit. Scale: 4 / 8 / 12 / 16 / 24 / 32px

## Visual Style
- Minimal, clean, paper-textured
- Ample whitespace
- Restrained color palette
- Clear typographic hierarchy
- Semantic tokens over raw values

## Component Rules
Define states: default, hover, focus-visible, active, disabled, loading, error.
Use explicit spacing, typography, and color tokens. Keyboard-first, pointer and touch support.

## Accessibility
WCAG 2.2 AA minimum. Visible focus states on every interactive element.
When aesthetics conflict with accessibility, prioritize accessibility.
