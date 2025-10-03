---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git diff:*), Bash(git commit:*)
argument-hint: [type] [staged|all]
description: Create conventional commit with proper message and description
model: claude-sonnet-4-20250514
---

You are helping create a git commit following Conventional Commits specification.

## Instructions

1. **Determine Scope**: Use "staged" to commit only staged changes, "all" (default) to stage and commit all changes
2. **Analyze Changes**: First examine the git status and diff to understand what changes are being committed
3. **Select Commit Type**: Choose appropriate conventional commit type based on changes:
   - `feat:` - New features
   - `fix:` - Bug fixes
   - `docs:` - Documentation changes
   - `style:` - Code formatting, no logic changes
   - `refactor:` - Code restructuring without feature/bug changes
   - `perf:` - Performance improvements
   - `test:` - Adding or modifying tests
   - `build:` - Build system changes
   - `ci:` - CI/CD changes
   - `chore:` - Maintenance tasks

## Arguments

- `$1` (optional): Override commit type (e.g., "feat", "fix")
- `$2` (optional): "staged" to commit only staged changes, "all" to stage and commit everything (default: "all")

## Commit Message Format

- **Subject**: ≤50 characters, format: `type: description`
- **Body**: Explain why/how, context for future readers
- **Line wrapping**: 72 characters max
- Do not include these:
  - 🤖 Generated with [Claude Code](https://claude.ai/code)
  - Co-Authored-By: Claude <noreply@anthropic.com>

## Process

1. Check git status and diff to understand changes
2. If scope is "all", stage all changes; if "staged", work only with staged changes
3. Select appropriate conventional commit type (use $1 if provided)
4. Create concise, descriptive commit message
5. Execute the commit

Arguments: $ARGUMENTS
