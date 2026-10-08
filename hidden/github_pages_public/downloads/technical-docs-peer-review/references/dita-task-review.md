# DITA task review

Use this checklist only for DITA task topics. Compare with the repository's own DITA template, specialization, map, and publishing output. Treat examples as prompts for review, not universal requirements.

- **Title and short description:** State the activity and outcome. Follow the project's title convention and use the short description only when it adds useful context.
- **Prerequisites (`prereq`):** Name required permissions, settings, devices, versions, accounts, or prior tasks. Link to a setup task where needed.
- **Context (`context`):** Explain when and why the reader performs the task. Avoid repeating the title or using an empty “Use this procedure to…” opening.
- **Steps (`steps`, `cmd`):** Start commands with an action, separate navigation from configuration when that helps, identify optional or alternative paths, and check that UI labels match the product.
- **Supporting content:** Put outcomes in `stepresult`, explanatory material in `info`, branches in appropriate substeps or choices, and warnings where the reader needs them.
- **Result and next action:** Describe the end state and how to confirm it. Use `result` and `postreq` where the workflow requires them.
- **Links and media:** Resolve `xref`, `link`, `image`, `conref`, and `keyref` in the applicable map/build context. Check image quality and alt text. Confirm that the topic is in the intended map and context-help mapping if the project uses one.
- **Structure:** Check well-formed XML and the project's DITA validity. A generic XML parser catches malformed markup but does not prove DITA validity or correct rendered output.

If a section is absent, explain the reader need it would satisfy before asking for it. Do not require a fixed number of steps or related links.
