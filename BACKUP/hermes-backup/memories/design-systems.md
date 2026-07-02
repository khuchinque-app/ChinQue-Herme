# Design Systems (TypeUI)

Adopted from https://www.typeui.sh/design-skills — a registry of 77 design system skill files
that define color tokens, typography, spacing, component behaviors, and accessibility rules
for AI-generated UI.

## Active Design Systems
1. **Paper Design** — typeui-paper-design skill. Minimal, clean, paper-textured.
   - Primary=#111111, accent=#8B5CF6, surface=#FFFFFF
   - Roboto (body), Montserrat (display), PT Mono (code)
   - Scale: 14/16/18/24/32/40px
   
2. **Neobrutalism** — typeui-neobrutalism-design skill. Bold, hard shadows, thick borders.
   - Primary=#FDC800, secondary=#432DD7, surface=#FBFBF9
   - Inter (all text), JetBrains Mono (code)
   - Scale: 13/15/17/21/27/35px
   
3. **Minimal** — typeui-minimal-design skill. Stripped-back, whitespace-heavy.
   - Primary=#0C0C09, secondary=#312C85, surface=#F4F4F1
   - Open Sans (body), Inter (display), Inconsolata (code)

Each skill has: color palette (semantic tokens), typography (fonts/sizes/weights),
spacing scale (4px base), component rules (40+ families), WCAG 2.2 AA accessibility.

## Default
When no design preference is stated, use Paper Design.

## Builder Pipeline
Builder agent (BuilderAgent001Bot on Telegram) has researcher and planner sub-agents.
Workflow: research → plan → implement → test → return.

## TypeUI MCP
TypeUI MCP server at https://mcp.typeui.sh can be added for live design system integration:
  claude mcp add --transport http typeui https://mcp.typeui.sh
