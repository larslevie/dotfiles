---
name: write-issue
description: Writing and maintaining GitHub issues. Use when creating new issues, editing issue titles/bodies, triaging issues, or cleaning up issue metadata (types, labels).
---

# Writing and maintaining GitHub issues

Standards for writing and maintaining GitHub issues.

## Defaults

This skill expects the following defaults to be provided (e.g. via project CLAUDE.md or skill invocation context):

- **Default label** - the label to apply to new issues (e.g. `needs-triage`)
- **Default issue type** - the issue type to set when none is specified (e.g. `Task`)
- **Default project** - the GitHub project to add issues to (e.g. project number `7`)

If defaults are not provided, ask the user before proceeding.

## Setup script

After creating an issue, run the setup script to apply standard configuration:

```bash
./setup-issue.sh <issue-url-or-number> [--type <type>] [--label <label>]... [--repo <owner/repo>]
```

The script:

- Applies the specified labels (falls back to the default label if none provided)
- Sets the issue type (uses the provided default if not overridden)
- Adds the issue to the default GitHub project

## Title standards

- **Sentence case** - Capitalize only the first word and proper nouns
- **No type prefixes** - Use GitHub issue types, not `Bug:`, `Feature:`, `[Bug]`, etc.
- **Imperative mood for enhancements** - "Add padding option" not "Adding padding option"
- **Descriptive for bugs** - Describe the symptom: "Arrow bindings break with rotated shapes"
- **Specific** - Readable without opening the issue body

### Good titles

- `Arrow bindings break with rotated shapes`
- `Add padding option to zoomToFit method`
- `Pinch zoom resets selection on Safari`

### Bad titles

- `Bug: arrow bug` (prefix, vague)
- `[Feature] Add new feature` (prefix, vague)
- `Not working` (vague)

### Title cleanup transformations

1. Remove prefixes: `Bug: X` → `X`
2. Fix capitalization: `Add Padding Option` → `Add padding option`
3. Use imperative: `Adding feature X` → `Add feature X`
4. Be specific: `Problem` → `[Describe the actual problem]`
5. Translate non-English titles to English

## Issue types

Set via the GitHub GraphQL API after creating the issue (the `--type` flag is not reliably supported). If no explicit type is specified, use the provided default issue type.

## Labels

Use sparingly (1-2 per issue) for metadata, not categorization.

Before labeling, run `gh label list` to discover the repo's available labels. Apply labels from that list that match the issue's content. Do not invent labels that don't exist in the repo.

## Issue body standards

### Bug reports

1. Clear description of what's wrong
2. Steps to reproduce
3. Expected vs actual behavior
4. Environment details (browser, OS, version) when relevant
5. Screenshots/recordings when applicable

### Feature requests

1. Problem statement - What problem does this solve?
2. Proposed solution - How should it work?
3. Alternatives considered
4. Use cases

## Triage workflow

### New issues

1. Verify sufficient information to act on
2. Clean up title if needed
3. Run `./setup-issue.sh <url> --type <type>` to add label, set type, and add to project
4. Add `underspecified` label and comment if details missing

### Stale issues

1. Review if still relevant
2. Close if no longer applicable
3. Add `keep` label if should remain open
4. Request updates if waiting on information

## Important

- Never include "Generated with Claude Code" unless the PR directly relates to Claude Code
- Never use title case for descriptions - use sentence case
