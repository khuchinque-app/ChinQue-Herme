# Curator Run: 2026-06-30

## Discovery: Bundled/Local Distinction

During this consolidation pass it was discovered that the curator tool blocks ALL of these operations on skills it identifies as "bundled" (shipped with the Hermes package):

- **patch** — refused ("Refusing background curator patch for bundled skill 'X'")
- **write_file** — refused ("Refusing background curator write_file for bundled skill 'X'")
- **delete** (archive) — refused ("Refusing background curator delete for bundled skill 'X'")
- **create** — still works (new skills are local by default)

Even with PRUNE-BUILTINS mode active in the prompt (which says bundled skills MAY be archived), the tool-level guard still blocks archiving bundled skills. This is a tool implementation detail, not a prompt-level override.

### Skills confirmed as local (editable)

- session-consolidation — explicitly created by user Chinque
- multi-agent-code-sprint — explicitly agent-created, not in the shipping package

### Skills confirmed as bundled (read-only)

All others (62 of 64). Includes: all github-*, all creative/*, all software-development/* (except the two above), all research/*, all mlops/*, all productivity/*, all media/*, all note-taking/*, etc.

## Consolidation Strategy for Future Runs

When the majority of skills are bundled/read-only, the curator's consolidation options narrow to:

1. **Create new umbrella skills** that serve as orientation/discovery layers (cannot absorb bundled siblings but can reference them)
2. **Patch local-only skills** (session-consolidation, multi-agent-code-sprint)
3. **Add reference/template/script files** under local-only skills
4. **Improve documentation** of the bundled/local architecture to help future passes

The note-taking-and-knowledge-management umbrella was created as a test of this pattern: it provides unified decision guidance across obsidian, notion, and llm-wiki, with condensed reference files under references/. The bundled originals remain active alongside it.

## Skill Library Snapshot

- Total skills: 64 (on disk)
- Bundled (read-only): ~62
- Local (editable): ~2
- Newly created this pass: 1 (note-taking-and-knowledge-management)

This is the baseline for future consolidation passes.
