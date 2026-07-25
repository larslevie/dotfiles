# CLAUDE.md

## Software Dev Lifecycle

### General

- Prefer functional over object oriented programming

### Code Comments

Comment code judiciously; explain only its non-obvious aspects. Comments must
provide timeless context, avoid temporary/incidental explication; be as succint
as practicable.

Never reference issue/spec/section/phases in committed code.

### Commits and PRs

Commit headers and PR titles should succinctly describe "what"; sacrifice
grammar when needed. Use conventional commit style for both. Explain the what
and not the why

Commit bodies should succinctly describe why, not what: the motivation, context
the diff can't show, trade-offs considered. If linking to issues or other
resources can avoid recapitulating context, do that.

### Git

- Prefix branch name with Conventional Commit type, e.g. `fix/*`
- Format: `{type}/{system}-{issue-number}-{human-readable-short-description}`
  (e.g. `feat/gh-78-automate-homebrew-tap`)
- Use kebab-case
- Create new branch from repo's default branch for each ticket
- Pull with rebase for new branches
- Warn if working on new task in the wrong branch
- Put all worktrees in the project's `.claude/worktrees`

### Tasks

- Ensure tests are passing for each change
- Make atomic, logical changes, committing between
- Make sure to commit changes to ticket's branch
