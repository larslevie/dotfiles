---
name: daily-note
description: Create VP-level daily notes with quarter progress tracking and leadership-focused structure. Use when user asks to create a daily note, start the day, or invokes /daily. Generates notes in _Daily/ with Radar (issues tracking), Teams sections, and minimal task lists. Automatically analyzes the note for anti-patterns after creation.
---

# Daily Note

Create a daily note for VP-level leadership work—focused on detection and delegation, not execution.

## Workflow

1. Get date: `date +"%Y-%m-%d %A"`
2. Calculate quarter progress (see below)
3. Pull due follow-ups from `_Followups.md` (see below)
4. Find previous day's note in `_Daily/`
5. Create new note with carryover items and follow-ups
6. Analyze for anti-patterns and append recommendations

## Quarter Progress Bar

Calculate and render an 80-character progress bar:

```python
import datetime
today = datetime.date.today()
quarter = (today.month - 1) // 3 + 1
q_start = datetime.date(today.year, (quarter - 1) * 3 + 1, 1)
q_end = datetime.date(today.year, quarter * 3 + 1, 1) if quarter < 4 else datetime.date(today.year + 1, 1, 1)
progress = (today - q_start).days / (q_end - q_start).days
filled = int(progress * 80)
bar = '▓' * filled + '░' * (80 - filled)
caret = ' ' * filled + '^'
print(f"Q{quarter} {today.year}  {bar}  {int(progress * 100)}%")
print(f"         {caret}")
```

## Follow-ups

Read `_Followups.md` (markdown table format) and extract rows where:
- Date <= today's date
- Status = `pending`

Table format:
```markdown
| Date | Description | Status |
|------|-------------|--------|
| 2025-12-20 | Check deployment status | pending |
```

Parse by splitting on `|` and trimming whitespace. Skip header rows.

After pulling follow-ups into the daily note, update their status to `done` in `_Followups.md`.

## Note Structure

```markdown
# YYYY-MM-DD Day
```

QN YYYY ▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ XX%
^

```

# Radar

## 🔴 Needs Attention

## 🟡 Watching

## 🟢 On Track

# Teams

## Platform & Infrastructure

## AI Platform & Research

## Internal Applications

# Tasks

## Today

- [ ] FU : [follow-up items due today, one per line]

## Later

- [ ]

# Notes

```

## File Location

- Folder: `_Daily/` (quarter folders are used for archiving after the quarter ends)
- Filename: `YYYY-MM-DD Day.md` (e.g., `2025-12-20 Friday.md`)

## Carryover Rules

From previous day's note, carry forward:

- All 🔴 Needs Attention items (until resolved)
- All 🟡 Watching items (until resolved or promoted to 🔴)
- Incomplete tasks with links to original context: `[[2025-12-19 Thursday#Topic]]`
- Team observations still relevant

Do NOT carry over:

- 🟢 On Track items (these are positive signals, not persistent)
- Completed tasks

## Anti-Pattern Analysis

After creating the note, analyze and append a `# Review` section with findings:

### Check for these anti-patterns:

**Task overload**

- More than 5 items in Today → Flag: "Heavy task list. Which require you specifically?"
- Execution tasks (coding, fixing, building, writing) → Flag: "Execution work. Who should own this?"

**Stale Radar items**
Read previous 3-5 daily notes:

- 🟡 item present 3+ days → Flag: "🟡 for N days. Escalate or resolve."
- 🔴 item present 2+ days → Flag: "🔴 aging. What's blocking?"

**Missing signals**

- Empty Team sections → Flag: "No observations for [Team]. Connected to what's happening?"
- Team items that read like tasks → Flag: "Reads like a task. Who owns it?"

**Empty Radar**

- All three sections empty → Flag: "Empty Radar. Things perfect or not looking?"

### Review section format

```markdown
# Review

**X anti-patterns detected**

- [specific callout with quoted text and recommendation]
- ...

**Reflection:** [one key question based on findings]
```

If no anti-patterns found, write:

```markdown
# Review

No anti-patterns detected.
```

## Radar Semantics

- 🔴 Needs Attention: Requires your intervention—blockers, escalations, coordination failures, unclear priorities, resource gaps
- 🟡 Watching: Potential issues—slipping timelines, team friction, unclear requirements, dependency risks
- 🟢 On Track: Positive signals—milestones hit, good coordination, problems resolved
