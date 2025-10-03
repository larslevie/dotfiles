---
description: Instructions for creating properly formatted Jira tickets using Atlassian CLI
argument-hint: "[project-key] [summary] [issue-type]"
allowed-tools: Bash(acli:*), Write(*)
---

# Make Jira Ticket

Instructions for creating properly formatted Jira tickets using Atlassian CLI (acli).

## Prerequisites

- Ensure `acli` is installed and authenticated
- Know the project key (e.g., "PLATFORM")
- Know the issue type (e.g., "Task", "Bug", "Story")

## Process

### 1. Create ADF JSON File

Create a JSON file with proper Atlassian Document Format (ADF) structure:

```json
{
  "projectKey": "PROJECT_KEY",
  "summary": "Ticket Title",
  "type": "Task",
  "description": {
    "version": 1,
    "type": "doc",
    "content": [
      {
        "type": "heading",
        "attrs": { "level": 2 },
        "content": [{ "type": "text", "text": "Section Heading" }]
      },
      {
        "type": "paragraph",
        "content": [{ "type": "text", "text": "Paragraph text content." }]
      },
      {
        "type": "bulletList",
        "content": [
          {
            "type": "listItem",
            "content": [
              {
                "type": "paragraph",
                "content": [{ "type": "text", "text": "Bullet point item" }]
              }
            ]
          }
        ]
      },
      {
        "type": "orderedList",
        "content": [
          {
            "type": "listItem",
            "content": [
              {
                "type": "paragraph",
                "content": [{ "type": "text", "text": "Numbered list item" }]
              }
            ]
          }
        ]
      }
    ]
  }
}
```

### 2. ADF Node Types Reference

- **Headings**: `{ "type": "heading", "attrs": { "level": 1-6 }, "content": [...] }`
- **Paragraphs**: `{ "type": "paragraph", "content": [...] }`
- **Bullet Lists**: `{ "type": "bulletList", "content": [...] }`
- **Ordered Lists**: `{ "type": "orderedList", "content": [...] }`
- **List Items**: `{ "type": "listItem", "content": [...] }`
- **Text**: `{ "type": "text", "text": "content" }`

### 3. Create Ticket

Use the `--from-json` flag:

```bash
acli jira workitem create --from-json /path/to/ticket.json
```

## Important Notes

- **Every element must be a structured node** - no plain text outside of text nodes
- **Line breaks are created by separate nodes** - use multiple paragraph nodes or heading nodes for visual separation
- **Lists require nested structure** - listItem → paragraph → text
- **DO NOT use** plain text descriptions with `--description` flag as they don't preserve formatting
- **DO NOT use** wiki markup or markdown - only ADF JSON structure works properly

## Generation Template

To generate a JSON template for reference:

```bash
acli jira workitem create --generate-json --project PROJECT_KEY --type Task
```
