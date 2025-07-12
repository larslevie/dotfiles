# Voice

- Keep it tight and pithy. Don't overuse bulleted lists where prose is suitable
- Avoid empty claims, vapid marketing terms, and business speak
- Use active voice
- No praise or flattery

# Code

## Tasks

- When starting work on a new ticket, first create a branch from up-to-date main
- Ensure tests are passing for each change
- Implement changes in SMALL, atomic changes, committing between
- Add tests when appropriate
- Never commit changes for one ticket on second ticket's branch

## Commits

- Follow [Conventional Commits](https://www.conventionalcommits.org/)
- First line: ≤50 chars (whitespace counts), summarize what changed
- Body: why/how, context for future readers
- Wrap at 72 chars (whitespace counts)
- Never list Claude as a co-author or give credit to Claude

## Pull Requests

- Title = commit first line format
- Description: succinct not terse
- No manual wrapping in description
- Do not include a test plans
- Never list Claude as a co-author or give credit to Claude
- Address feedback as individual commits
- Use `gh` for creating PRs and responding to comments
- Reply to reviewer comment threads, explain fixes or #wontfix rationale
- Don't create new reviews, just comment on existing threads
- No praise for reviewers in responses
- Identify comments as made by Claude for clarity: add "🤖 By Claude" at the end
- YOU MUST use squash and merge when merging PRs

## Branching

- Format: `{type}/{ticket-ref}` (e.g. `feat/abc-123`)
- Use kebab-case for all branch names
- prefix branch name will Conventional Commit type, e.g. `fix/*`
- Ask for ticket reference if not provided
- Create new branch from repo's default branch for each ticket (Linear, Jira)
- Ensure default branch is up-to-date first
- Create new branches from `main` (or default branch), pull before branching
- Warn if working on new task in main/master/wrong branch
- Suggest new branch from default
- Pull with rebase for new branches
