# Jira issue workflow

This ZIP contains one portable Agent Skill. Its `SKILL.md`, example configuration, and PowerShell helper are shared across the installation options below. Customize a copy for your Jira environment; keep credentials outside the skill folder.

The `agents/openai.yaml` file supplies optional Codex display metadata. Claude uses `SKILL.md` and the supporting files; it does not need that metadata file.

## Install the skill

- **Codex:** Extract the ZIP and place `jira-issue-workflow/` in `~/.codex/skills/` for personal use or in a repository's `.codex/skills/` for that project.
- **Claude Code:** Extract the same ZIP and place `jira-issue-workflow/` in `~/.claude/skills/` for personal use or in a repository's `.claude/skills/` for that project.
- **Claude chat or Desktop:** In **Customize → Skills**, upload the ZIP as a custom skill. This makes the instructions available to Claude; it does not guarantee that Claude's hosted environment can run the included PowerShell helper or reach a private Jira site. Use an authorized Jira connection when available.

## Configure the local helper

1. Copy `config.example.json` to a private path such as `~/.config/jira-issue-workflow/config.json`, then set your own Jira site, authentication scheme, and project defaults. Never save a configured copy in the ZIP or a public repository.
2. Set `JIRA_API_TOKEN` in the local process environment. The helper reads the neutral path above by default; `-ConfigPath` or `JIRA_SKILL_CONFIG` overrides it.
3. With PowerShell available, run `scripts/jira.ps1 -Operation help` before making a network request. Check that your Jira site supports the helper's REST API v2 request shape.

The workflow can also use an authorized Jira connection instead of the helper. The helper passed isolated local fixture tests; live Jira and hosted Claude execution were not validated for this public copy.
