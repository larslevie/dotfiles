---
description: Create a well-specified GitHub issue through detailed interview
---

Create a well-specified GitHub issue through a detailed interview.

## Workflow

1. **Resolve defaults.** Check the project's CLAUDE.md (and any other context) for
   these values:
   - **Default label** (e.g. `needs-triage`)
   - **Default issue type** (e.g. `Task`)
   - **Default project number** (e.g. `7`)

   If any are missing, ask the user for them using the AskUserQuestion tool
   before proceeding.

2. **Interview.** Ask me in depth using the AskUserQuestion tool. Ask about
   technical implementation details, UI/UX considerations, concerns, tradeoffs,
   edge cases, error handling, dependencies, and anything else relevant. Don't
   ask obvious questions—dig into the non-obvious aspects that would make the
   difference between a vague issue and a well-specified one.

3. Continue the interview until you have enough detail to write a comprehensive
   issue.

4. **Create the issue.** Invoke the `write-issue` skill using the Skill tool.
   You MUST use the Skill tool with `skill: "write-issue"` — do not create the
   issue manually. Pass the resolved defaults (label, issue type, project
   number) as context so the skill can forward them to the setup script.
