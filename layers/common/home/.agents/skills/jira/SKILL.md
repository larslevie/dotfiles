---
name: jira
description: Create and manage Jira tickets using Atlassian CLI (acli). Use when user asks to create Jira tickets, search issues, update tickets, transition status, add comments, or manage work items. Handles ADF formatting for rich descriptions. Default project is PLATFORM.
---

# Jira

Manage Jira tickets via `acli` CLI. Always use `--from-json` with ADF for descriptions to preserve formatting.

## Quick Reference

```bash
# Create ticket
acli jira workitem create --from-json ticket.json

# View ticket
acli jira workitem view KEY-123 --json

# Search tickets
acli jira workitem search --jql "project = PLATFORM" --json

# Edit ticket
acli jira workitem edit --key KEY-123 --summary "New title" --yes

# Transition status
acli jira workitem transition --key KEY-123 --status "In Progress" --yes

# Add comment
acli jira workitem comment create --key KEY-123 --body "Comment text"

# List projects
acli jira project list
```

## Creating Tickets

Always use `--from-json` with ADF-formatted description for proper formatting.

1. Create a temporary JSON file with the ticket definition
2. Run `acli jira workitem create --from-json /path/to/ticket.json`
3. Clean up the temp file

### JSON Structure

```json
{
  "projectKey": "PLATFORM",
  "summary": "Ticket title",
  "type": "Task",
  "description": {
    "version": 1,
    "type": "doc",
    "content": []
  }
}
```

Optional fields: `assignee`, `labels` (array), `parent` (for subtasks).

For ADF node types and examples, see [references/adf.md](references/adf.md).

## Searching

Use JQL for queries:

```bash
# By project
acli jira workitem search --jql "project = PLATFORM" --limit 20 --json

# By assignee
acli jira workitem search --jql "assignee = currentUser()" --json

# By status
acli jira workitem search --jql "project = PLATFORM AND status = 'In Progress'" --json

# By text
acli jira workitem search --jql "project = PLATFORM AND text ~ 'search term'" --json

# Recent items
acli jira workitem search --jql "project = PLATFORM ORDER BY created DESC" --limit 10 --json
```

Custom fields: `--fields "key,summary,assignee,status,priority"`

## Editing

```bash
# Update summary
acli jira workitem edit --key KEY-123 --summary "New title" --yes

# Update assignee
acli jira workitem edit --key KEY-123 --assignee "user@example.com" --yes

# Update labels
acli jira workitem edit --key KEY-123 --labels "label1,label2" --yes

# Update description (use --from-json for rich formatting)
acli jira workitem edit --from-json edit.json
```

## Transitions

```bash
acli jira workitem transition --key KEY-123 --status "Done" --yes
```

Common statuses: `To Do`, `In Progress`, `In Review`, `Done`

## Comments

```bash
# Add comment
acli jira workitem comment create --key KEY-123 --body "Comment text"

# List comments
acli jira workitem comment list --key KEY-123

# Update last comment
acli jira workitem comment create --key KEY-123 --body "Updated" --edit-last
```
