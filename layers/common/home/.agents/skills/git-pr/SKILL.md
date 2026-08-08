---
name: git-pr
description: Open a GitHub Pull Request for the current branch with quality checks. Delegates to git-pr-expert agent.
disable-model-invocation: true
argument-hint: --skip-checks
---

## Pre-PR Quality Gate

Unless the user passed `--skip-checks` in their arguments ($ARGUMENTS), spawn a `quality-check` agent using the Task tool (`subagent_type: "quality-check"`) before opening the PR.

- All checks passed or none found: proceed to open PR.
- Any check failed: report the summary to the user and do NOT open the PR. Ask whether they want to fix the issues or bypass.

## Pull Request

Spawn a `git-pr-expert` agent using the Task tool (`subagent_type: "git-pr-expert"`) to analyze the current branch's changes and open a GitHub Pull Request.
