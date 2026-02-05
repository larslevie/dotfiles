# GitHub Simple Issue Workflow

Implement {issue-url}

## Setup

- Use a git worktree _only if asked_
- Pull `main` before branching
- Branch naming: `gh-{issue-number}-human-readable-description`

## Process

1. **Plan first**: Produce an implementation plan and ask for approval before proceeding (do not commit the plan)
2. **Atomic commits**: Make logical, atomic commits as you progress
3. **Quality gates**: Before each commit, run all checks, tests, linters, and formatters — all must pass green
4. **Use skills**: Use the git commit skill and git PR skill for those actions

## Guidelines

Abide by the following project documentation:

- `@.specify/memory/constitution.md`
- `@CLAUDE.md`
- `@README.md`
- `@docs/`

## Post-Implementation

After completing the fix, review the README and docs for any updates relevant to your change.
