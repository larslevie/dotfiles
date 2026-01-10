---
name: pr-review-workflow
description: Process AI-generated pull request review comments interactively. Use when an engineer wants to address PR review comments from automated code review agents. Given a PR link or repo/PR number, fetches unresolved comment threads, analyzes each comment's validity and severity, presents recommendations, implements approved fixes, commits changes, and resolves threads via GitHub API.
---

# PR Review Workflow

Process AI code review comments on pull requests interactively, one comment at a time.

## Prerequisites

- `gh` CLI authenticated with repo access
- Git repository cloned locally with the PR branch checked out

## Workflow Overview

1. Parse PR input (URL or owner/repo + PR number)
2. Fetch unresolved review comment threads
3. For each thread: analyze → recommend → (fix or skip) → reply → resolve
4. Repeat until all threads processed

## Step 1: Parse PR Input

Accept either format:
- Full URL: `https://github.com/owner/repo/pull/123`
- Components: `owner/repo` and PR number `123`

Extract `owner`, `repo`, and `pr_number` for API calls.

## Step 2: Fetch Unresolved Comment Threads

Run the fetch script to get all review comment threads:

```bash
./scripts/fetch_pr_comments.sh owner repo pr_number
```

This returns JSON with comment threads. Filter for threads where `isResolved: false`.

Each thread contains:
- `id`: Thread ID (for GraphQL mutations)
- `path`: File path
- `line`/`startLine`: Line number(s)
- `body`: Comment text
- `comments`: Array of replies in thread

## Step 3: Process Each Thread

For each unresolved thread, follow this cycle:

### 3a. Analyze the Comment

1. Read the comment body and understand what issue is raised
2. Examine the referenced code using the file path and line numbers
3. Evaluate:
   - **Correctness**: Is the identified issue actually a problem?
   - **Validity**: Does the suggested fix (if any) make sense?
   - **Severity**: Critical / Major / Minor / Nitpick

### 3b. Present Analysis to Engineer

Present findings clearly:

```
## Comment Analysis

**File:** path/to/file.py (lines 42-45)
**Issue:** [Brief description of what the reviewer flagged]
**Reviewer's suggestion:** [If provided]

### Evaluation
- **Correctness:** [Yes/Partial/No] - [Reasoning]
- **Severity:** [Critical/Major/Minor/Nitpick]
- **Validity of suggested fix:** [If applicable]

### Recommendation
[Address / Skip] - [Reasoning]

Do you want to fix this issue? (yes/no/skip)
```

### 3c. Handle Engineer's Decision

**If engineer says YES (fix the issue):**

1. Analyze possible solutions
2. Present solution options with trade-offs:
   ```
   ## Proposed Solutions
   
   **Option 1:** [Description]
   - Pros: ...
   - Cons: ...
   
   **Option 2:** [Description]
   - Pros: ...
   - Cons: ...
   
   Which solution do you prefer? (1/2/other)
   ```
3. Implement the chosen solution
4. Show the engineer the diff for approval
5. Once approved, commit the fix (use git subagent or available commit skills)
6. Reply to thread explaining the fix:
   ```bash
   ./scripts/reply_to_thread.sh owner repo comment_id "Fixed in [commit]. [Explanation of fix]."
   ```
7. Resolve the thread:
   ```bash
   ./scripts/resolve_thread.sh thread_id
   ```

**If engineer says NO or SKIP:**

1. Ask for optional reason (for the reply)
2. Reply to thread:
   ```bash
   ./scripts/reply_to_thread.sh owner repo comment_id "Acknowledged. [Reason for not addressing, if provided]."
   ```
3. Resolve the thread:
   ```bash
   ./scripts/resolve_thread.sh thread_id
   ```

## Step 4: Continue to Next Thread

After resolving a thread, move to the next unresolved thread and repeat Step 3.

When all threads are processed, summarize:
- Total threads processed
- Threads fixed
- Threads skipped
- Commits made

## Script Reference

### fetch_pr_comments.sh

Fetches all review comment threads for a PR. See `scripts/fetch_pr_comments.sh`.

### reply_to_thread.sh

Posts a reply to a review comment. See `scripts/reply_to_thread.sh`.

### resolve_thread.sh

Resolves a review thread using GitHub GraphQL API. See `scripts/resolve_thread.sh`.

## Error Handling

- If `gh` CLI fails, verify authentication: `gh auth status`
- If GraphQL mutation fails, check thread ID format (should be GraphQL node ID)
- If file/line not found, the PR branch may need to be rebased
