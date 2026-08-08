# Atlassian Document Format (ADF) Reference

ADF is a JSON-based format for rich text in Jira descriptions and comments.

## Document Structure

Every ADF document has this wrapper:

```json
{
  "version": 1,
  "type": "doc",
  "content": []
}
```

## Node Types

### Text

Basic text node (always inside a paragraph or other block):

```json
{ "type": "text", "text": "Plain text" }
```

With marks (bold, italic, code, link):

```json
{ "type": "text", "text": "Bold text", "marks": [{ "type": "strong" }] }
{ "type": "text", "text": "Italic text", "marks": [{ "type": "em" }] }
{ "type": "text", "text": "Code text", "marks": [{ "type": "code" }] }
{ "type": "text", "text": "Link text", "marks": [{ "type": "link", "attrs": { "href": "https://example.com" } }] }
```

### Paragraph

```json
{
  "type": "paragraph",
  "content": [{ "type": "text", "text": "Paragraph text." }]
}
```

### Headings

```json
{
  "type": "heading",
  "attrs": { "level": 2 },
  "content": [{ "type": "text", "text": "Heading Text" }]
}
```

Levels 1-6 supported.

### Bullet List

```json
{
  "type": "bulletList",
  "content": [
    {
      "type": "listItem",
      "content": [
        {
          "type": "paragraph",
          "content": [{ "type": "text", "text": "First item" }]
        }
      ]
    },
    {
      "type": "listItem",
      "content": [
        {
          "type": "paragraph",
          "content": [{ "type": "text", "text": "Second item" }]
        }
      ]
    }
  ]
}
```

### Ordered List

```json
{
  "type": "orderedList",
  "content": [
    {
      "type": "listItem",
      "content": [
        {
          "type": "paragraph",
          "content": [{ "type": "text", "text": "Step 1" }]
        }
      ]
    }
  ]
}
```

### Code Block

```json
{
  "type": "codeBlock",
  "attrs": { "language": "python" },
  "content": [{ "type": "text", "text": "def hello():\n    print('Hello')" }]
}
```

### Blockquote

```json
{
  "type": "blockquote",
  "content": [
    {
      "type": "paragraph",
      "content": [{ "type": "text", "text": "Quoted text" }]
    }
  ]
}
```

### Rule (Horizontal Line)

```json
{ "type": "rule" }
```

### Panel (Info/Warning/Error boxes)

```json
{
  "type": "panel",
  "attrs": { "panelType": "info" },
  "content": [
    {
      "type": "paragraph",
      "content": [{ "type": "text", "text": "Info panel content" }]
    }
  ]
}
```

Panel types: `info`, `note`, `warning`, `error`, `success`

## Complete Example

```json
{
  "projectKey": "PLATFORM",
  "summary": "Implement user authentication",
  "type": "Task",
  "description": {
    "version": 1,
    "type": "doc",
    "content": [
      {
        "type": "heading",
        "attrs": { "level": 2 },
        "content": [{ "type": "text", "text": "Summary" }]
      },
      {
        "type": "paragraph",
        "content": [
          {
            "type": "text",
            "text": "Add OAuth2 authentication to the API gateway."
          }
        ]
      },
      {
        "type": "heading",
        "attrs": { "level": 2 },
        "content": [{ "type": "text", "text": "Requirements" }]
      },
      {
        "type": "bulletList",
        "content": [
          {
            "type": "listItem",
            "content": [
              {
                "type": "paragraph",
                "content": [{ "type": "text", "text": "Support Google OAuth" }]
              }
            ]
          },
          {
            "type": "listItem",
            "content": [
              {
                "type": "paragraph",
                "content": [{ "type": "text", "text": "Support GitHub OAuth" }]
              }
            ]
          }
        ]
      },
      {
        "type": "heading",
        "attrs": { "level": 2 },
        "content": [{ "type": "text", "text": "Acceptance Criteria" }]
      },
      {
        "type": "orderedList",
        "content": [
          {
            "type": "listItem",
            "content": [
              {
                "type": "paragraph",
                "content": [
                  { "type": "text", "text": "Users can sign in with Google" }
                ]
              }
            ]
          },
          {
            "type": "listItem",
            "content": [
              {
                "type": "paragraph",
                "content": [
                  { "type": "text", "text": "Users can sign in with GitHub" }
                ]
              }
            ]
          }
        ]
      }
    ]
  }
}
```

## Key Rules

1. Every text must be inside a `text` node
2. Every `text` node must be inside a block (paragraph, heading, listItem, etc.)
3. Lists require: list → listItem → paragraph → text
4. No plain text outside of structured nodes
5. Use separate paragraph nodes for line breaks
