# Oxygen XML comments

Use this only when the user requests in-file Oxygen review comments and the file is local and writable. Comments are XML processing instructions. They must not break the document or cross element boundaries incorrectly.

```xml
<?oxy_comment_start author="reviewer" timestamp="20260101T120000+0000" comment="Could this step name the required permission?"?>target text<?oxy_comment_end?>
```

Replace `reviewer` and the timestamp with the current reviewer's actual configured username and current timestamp, including the timezone offset. Escape XML attribute characters in comment text: `&quot;`, `&apos;`, `&lt;`, `&gt;`, and `&amp;`. Anchor the smallest meaningful text span or a complete element. For a whole element, place the start PI immediately before its opening tag and the end PI immediately after its closing tag.

When replying to an existing comment, use the file's established `parentID` and reply convention. Do not invent comment IDs. Do not introduce tracked-change instructions such as `oxy_insert`, `oxy_delete`, or `track_changes="on"` unless the user explicitly requests tracked changes. A proposed rewrite can be stated in the comment itself.

Preserve surrounding content and whitespace as far as practical. After inserting comments, reparse the XML and inspect the affected span. A successful parse does not by itself prove the Oxygen review layer or DITA build is correct; use the available authoring or publishing preview when that matters.
