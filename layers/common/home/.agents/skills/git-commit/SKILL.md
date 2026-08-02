---
name: git-commit
description: Commit staged and unstaged changes with quality checks. Delegates to git-commit-expert agent.
disable-model-invocation: true
argument-hint: --skip-checks
---

## Pre-Commit Quality Gate

Unless the user passed `--skip-checks` in their arguments ($ARGUMENTS), spawn a `quality-check` agent using the Task tool (`subagent_type: "quality-check"`) before committing.

- All checks passed or none found: proceed to commit.
- Any check failed: report the summary to the user and do NOT commit. Ask whether they want to fix the issues or bypass.

## Commit

Spawn a `git-commit-expert` agent using the Task tool (`subagent_type: "git-commit-expert"`) to analyze changes and create commits.
