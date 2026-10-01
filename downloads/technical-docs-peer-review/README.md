# Technical documentation peer review

This ZIP contains one portable Agent Skill. Its `SKILL.md` and reference files are the same across Codex and Claude. Adapt the references to your product, documentation format, and style guide.

The `agents/openai.yaml` file supplies optional Codex display metadata. Claude uses `SKILL.md` and the reference files; it does not need that metadata file.

## Install the skill

- **Codex:** Extract the ZIP and place `technical-docs-peer-review/` in `~/.codex/skills/` for personal use or in a repository's `.codex/skills/` for that project.
- **Claude Code:** Extract the same ZIP and place `technical-docs-peer-review/` in `~/.claude/skills/` for personal use or in a repository's `.claude/skills/` for that project.
- **Claude chat or Desktop:** In **Customize → Skills**, upload the ZIP as a custom skill. Supply the document or an authorized connection when you ask for a review; uploading the skill alone does not give Claude access to your local files or private issue tracker.

Read `SKILL.md` for the review flow. Keep `references/` beside it so its linked guidance remains available. The skill structure and package were validated locally; review accuracy in a particular team's environment was not scored.
