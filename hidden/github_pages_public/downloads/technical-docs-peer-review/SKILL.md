---
name: technical-docs-peer-review
description: Review technical documentation for factual support, task flow, structure, links, accessibility, and language. Use for a requested documentation review; use the DITA and Oxygen references only for those formats.
---

# Technical documentation peer review

Review the material for what could mislead or block a reader, then for clarity and editorial quality. This public skill is adapted from a documentation review workflow; it has no company-specific product rules, reviewer identities, repository paths, or ticket prefixes.

## Choose the review mode

- Follow the user's requested scope and output. A report is the default. Add comments inside a local file only when the user requests in-file feedback or has established that as the review workflow.
- Read [review-framework.md](references/review-framework.md) for every review.
- For a DITA task, also read [dita-task-review.md](references/dita-task-review.md). Check nearby topics and maps only as needed for navigation or consistency.
- Before inserting Oxygen comments, read [oxygen-comments.md](references/oxygen-comments.md). Preserve the topic's structure and verify that it still parses.
- If the request is tied to an issue, read [ticket-context.md](references/ticket-context.md). Use the available ticket connection or ask for the relevant issue content when it is unavailable.

## Review

1. Establish the explicit target files or pages and the change being reviewed. When a diff is available, identify the author's contribution rather than attributing all existing content to them.
2. Check the evidence for product or API behaviour, prerequisites, permissions, version scope, and the reader's end state. Use the issue, product artefacts, screenshots, tests, and nearby documentation where available. Ask a focused question when a fact cannot be verified.
3. Check structure and publishing risks: broken links, images, conditional content, map placement, leftover comments, malformed markup, and accessibility. Apply only the project's actual template and style rules.
4. Review task flow and language, including direct openings, action order, terminology, active voice, repetition, grammar, and concise rewrites. Include this pass unless the user requests blockers only or the scope requires a stated sampling approach.
5. Order findings by impact. Give a location, why the issue matters, and a concrete suggestion or question. Identify what was not checked. Re-read files before delivering if another process could have changed them.

For AI-assisted findings, separate a verified fact from an inference. Do not present an untested product behaviour as a fact. Do not claim a review comment was accepted simply because it appears in a review file.

## Output

Use concise `P1` (publication or task blocker), `P2` (reader or structure problem), and `P3` (language and polish) findings when priorities help. A useful report gives `file:line`, the issue, reader impact, and an actionable rewrite or question. If no actionable finding remains, say so and state the review limits.

When inserting comments, prefer comments to unrequested content changes. Use the current reviewer's configured identity, not an identity found in an example. Do not post findings to a ticket or send them to someone else unless the user asks.
