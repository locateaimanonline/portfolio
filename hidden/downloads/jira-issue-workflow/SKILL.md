---
name: jira-issue-workflow
description: Search, inspect, and create issues in a configured Jira site when a user asks for Jira work. Use a connected Jira tool when available or the included REST API v2 helper on compatible sites.
---

# Jira issue workflow

This is a customizable copy of a documentation team's Jira workflow. It contains no site, account, project, assignee, release, or credential from its source environment.

## Setup

1. Copy `config.example.json` to a private location such as `~/.config/jira-issue-workflow/config.json` and replace the example site and project values. Do not put the configured file inside this downloadable skill or a public repository.
2. Supply an API token through the `JIRA_API_TOKEN` environment variable for the process that runs the helper. Do not paste tokens into chat, issue descriptions, commands, or logs.
3. Select `Bearer` or `Basic` in the configuration according to the destination Jira site's authentication requirements. Basic authentication also needs the configured email. The helper targets Jira REST API v2; check compatibility with the destination site before use.

The included PowerShell helper is `scripts/jira.ps1`. Run it with `-Operation help` to see commands without making a network request. Use `-ConfigPath` or `JIRA_SKILL_CONFIG` to choose a different private configuration file. The helper needs a local PowerShell runtime, network access to a compatible Jira site, and the token in that process's environment. In a hosted assistant without those capabilities, use an authorized Jira connection instead of assuming the helper can run.

## Work

Prefer a connected Jira tool when it can perform the requested action. Otherwise, use the helper for:

```powershell
./scripts/jira.ps1 -Operation my-open
./scripts/jira.ps1 -Operation created -MaxResults 10
./scripts/jira.ps1 -Operation search -Jql 'project = EXAMPLE ORDER BY updated DESC'
./scripts/jira.ps1 -Operation get -Key EXAMPLE-123
./scripts/jira.ps1 -Operation create -Project EXAMPLE -IssueType Task -Summary 'Clarify setup steps' -Description 'What needs to change and why.'
```

For issue creation, use the project, issue type, priority, labels, assignee, and version the user specified or configured for their site. Do not invent a team's defaults. Create an issue only when the user requests it. Read the created issue back and report its key, URL, type, priority, status, version, labels, assignee, and reporter. If a configuration is missing, ask for the missing nonsecret value.

Search results should show key, URL, summary, status, priority, and dates. If the helper cannot reach the site or the site does not support its API shape, explain the concrete failure and use an available connected tool. Never display the token or authorization header.
