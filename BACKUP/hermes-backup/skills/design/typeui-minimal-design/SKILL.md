---
name: typeui-minimal-design
description: "Use when generating clean, whitespace-heavy UI. Minimal Design — stripped-back, Open Sans/Inter, primary=#0C0C09, surface=#F4F4F1."
version: 1.0.0
author: Hermes Agent (adapted from typeui.sh)
license: MIT
metadata:
  hermes:
    tags: [design, ui, css, typeui, minimal]
    related_skills: [typeui-paper-design, typeui-neobrutalism-design]
---

# Minimal Design System

When generating clean, focused UI with maximum clarity, use the Minimal design system.

## Design Tokens

### Color Palette
| Token | Value | Purpose |
|-------|-------|---------|
| Primary | `#0C0C09` | Main interactive elements, headings |
| Secondary | `#312C85` | Accent highlights, links |
| Success | `#16A34A` | Positive feedback |
| Warning | `#D97706` | Caution indicators |
| Danger | `#DC2626` | Error states |
| Surface | `#F4F4F1` | Background surfaces (warm off-white) |
| Text | `#0C0C09` | Body text |

### Typography
- **Primary font:** Open Sans (body text, labels)
- **Display font:** Inter (headings, hero)
- **Monospace font:** Inconsolata (code)
- **Type scale:** Desktop-first expressive scale
- **Weights:** 100–900

### Spacing
4px base unit. Scale: 4 / 8 / 12 / 16 / 24 / 32px

## Visual Style
- Stripped-back, maximal whitespace
- Clean typography as primary visual element
- Restrained color — let content breathe
- Bold when needed, invisible when not

## Component Rules
Define states: default, hover, focus-visible, active, disabled, loading, error. Explicit token usage for spacing, typography, color. Responsive behavior and edge cases included.

## Accessibility
WCAG 2.2 AA. Keyboard-first interactions with visible focus states. Semantic HTML and ARIA attributes throughout. Testable acceptance criteria for every requirement.
