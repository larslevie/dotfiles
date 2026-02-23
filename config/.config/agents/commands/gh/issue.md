---
description: Create a GitHub issue through interview
---

Create a GitHub issue. Supports two modes depending on audience.

**IMPORTANT: Do NOT create issues directly with `gh issue create` or any other
method. You MUST use the Skill tool with `skill: "write-issue"` to create the
issue. The skill handles labeling, type assignment, and project placement via a
setup script that manual creation skips.**

## Modes

### Standard (default)

For human readers. Capture the problem, context, and desired outcome — the _why_
and _what_. Omit implementation details, specific code paths, and step-by-step
instructions. A competent engineer should be able to read the issue and decide
_how_ to solve it themselves.

Interview should be brief: clarify the problem, who it affects, and what success
looks like. One or two rounds of questions at most.

### Detailed

For AI agents or highly prescriptive work. Include implementation details,
specific behaviors, edge cases, error handling, acceptance criteria, and
technical constraints. The reader should be able to implement without further
clarification.

Interview should be thorough: ask about technical approach, UI/UX
considerations, tradeoffs, dependencies, and non-obvious edge cases. Continue
until you have enough detail to write a comprehensive issue.

## Workflow

1. **Determine mode.** Ask which mode to use via AskUserQuestion:
   - **Standard** (default) — problem and context only
   - **Detailed** — full implementation specification

2. **Resolve defaults.** Check the project's CLAUDE.md (and any other context)
   for these values:
   - **Default label** (e.g. `needs-triage`)
   - **Default issue type** (e.g. `Task`)
   - **Default project number** (e.g. `7`)

   If any are missing, ask the user using AskUserQuestion.

3. **Interview.** Adjust depth to the selected mode:
   - **Standard**: Focus on the problem, who it affects, and desired outcome.
     Keep it to 1–2 rounds.
   - **Detailed**: Dig into technical details, edge cases, error handling,
     dependencies, and tradeoffs. Continue until comprehensive.

4. **Create the issue.** Call the Skill tool with `skill: "write-issue"`. Do NOT
   use `gh issue create`, `gh api`, or any other method to create the issue. The
   `write-issue` skill runs a setup script that applies labels, sets the issue
   type, and adds the issue to the project — these steps are lost if you skip
   the skill. Pass the resolved defaults (label, issue type, project number) and
   the selected mode as context.

## Writing

Standard issues should read as a clear problem statement with enough context to
act on. Detailed issues should read as a specification.

In both modes, follow the title and body standards from the `write-issue` skill.
Apply the writing style and voice guidelines from CLAUDE.md to all issue
content.
