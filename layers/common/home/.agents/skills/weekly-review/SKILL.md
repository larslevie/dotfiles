---
name: weekly-review
description: |
  Review weekly notes, tasks, and meetings to surface items at risk of being dropped.
  Use when user requests a weekly review, uses /weekly-review, or asks to review a specific week.
  Invocation: /weekly-review [date|week-number]
  Examples: /weekly-review, /weekly-review 2025-03-12, /weekly-review 2025-W12
---

# Weekly Review

Analyze daily notes, weekly planning notes, and meeting summaries to identify incomplete tasks, unresolved commitments, and recurring issues that need attention.

## Invocation

- `/weekly-review` → Previous week (Monday-Sunday before today)
- `/weekly-review 2025-03-12` → Week containing that date
- `/weekly-review 2025-W12` → ISO week 12 of 2025

## Data Sources

For the target week (Monday-Sunday):

1. **Daily notes**: `_Daily/YYYY-QN/YYYY-MM-DD*.md`
2. **Weekly planning note**: `0 - Weekly/YYYY-MM-DD - Week Of.md` (Monday's date)
3. **Meeting summaries**: `99 - Zoom Meeting Summaries/*` dated within the week
4. **Prior weekly reviews**: `0 - Weekly/YYYY-MM-DD - Weekly Review.md` (for carryover context, up to 4 weeks back)

## Process

1. **Determine target week**

   - Default: previous Monday-Sunday, use CLI to determine dates
   - If date provided: find containing Monday-Sunday
   - If ISO week provided: calculate Monday-Sunday for that week

2. **Gather notes**

   - Read daily notes for each day of target week
   - Read weekly planning note if exists
   - Read meeting summaries dated within target week
   - Read up to 4 prior weekly reviews for carryover context

3. **Extract and analyze**

   - Incomplete tasks (`- [ ]`) from daily notes
   - Tasks marked under `## Priority` sections
   - Action items and commitments from meeting summaries
   - Items appearing in prior weekly reviews that remain unresolved

4. **Categorize findings**

   - **Requires Attention**: Important items at risk of being dropped
   - **Carried Forward**: Tasks from this week still open
   - **Meeting Commitments**: Action items from meetings
   - **Unresolved from Previous Weeks**: Items from prior reviews still open
   - **Themes**: Recurring topics or blockers

5. **Write review**
   - Output to `0 - Weekly/YYYY-MM-DD - Weekly Review.md`
   - Overwrite if exists (re-run is intentional)

## Output Template

```markdown
# Weekly Review: [Monday Date] - [Sunday Date]

## Requires Attention

Items that are important and at risk of being dropped.

| Item | Source | Why Flagged |
| ---- | ------ | ----------- |
| ...  | ...    | ...         |

## Carried Forward

Incomplete tasks from this week.

| Item | Source | Notes |
| ---- | ------ | ----- |
| ...  | ...    | ...   |

## Meeting Commitments

Action items and commitments from this week's meetings.

| Commitment | Meeting | Date |
| ---------- | ------- | ---- |
| ...        | ...     | ...  |

## Unresolved from Previous Weeks

Items from prior weekly reviews still lacking resolution.

| Item | First Appeared | Age (weeks) |
| ---- | -------------- | ----------- |
| ...  | ...            | ...         |

## Themes

Recurring topics or blockers worth noting.

- ...

## Recommended Actions

Concrete next steps for the coming week.

1. ...
```

## Determining Importance

Flag items as "Requires Attention" when:

- Marked under `## Priority` in daily notes
- Noted with a double-bag `!!`
- Mentioned in multiple daily notes without completion
- Explicit deadline mentioned
- Blocking other work
- External commitment (from meeting, to another person)
- Carried forward from 2+ prior weeks

## Backfill Usage

When processing historical weeks, run in chronological order so each review can reference prior reviews for accurate carryover tracking.

Example sequence for backfilling January 2025:

```
/weekly-review 2025-W01
/weekly-review 2025-W02
/weekly-review 2025-W03
/weekly-review 2025-W04
```
