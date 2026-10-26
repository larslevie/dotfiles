---
name: organize-transcripts
description: Summarize voice-memo transcripts from a date range into one subject-based Markdown note — per-subject summaries with short verbatim quotes, to-dos and open questions, every claim linked back to the source transcript and paragraph. Use when the user asks to organize, sort, process, summarize or make notes from their transcripts or voice memos for a period (e.g. "organize this week's voice memos").
---

Turn a date range of transcripts into one note that a reader can skim in a few minutes. The note is
**processed**: written summaries by subject, with a few short verbatim quotes where the speaker's own
words matter. It does not reproduce the transcripts — it points into them. Every claim, quote and to-do
cites the transcript paragraph it came from, so the reader can always go back to the original. The
transcripts are the record: never edit them.

## Inputs

- **Folder** of transcripts (`YYYY-MM-DD-*.md`, YAML frontmatter, paragraphs separated by blank lines).
- **Range** `from`–`to`, inclusive, matched on the filename date. Ask if not given.
- **Output**: `organized/<from>_<to>.md` in the folder's parent (a sibling of the transcripts folder),
  unless the user names another path.
- **Codebook**: `organized/codebook.md`, shared across runs. Create it on the first run.

The helper is `scripts/vmnotes.py` (in this skill's directory); run it with `python3`.

## Process

1. **Read.** `vmnotes.py segment <folder> <from> <to> --relative-to <output dir>` prints every transcript
   in range as numbered paragraphs (`[p03] …`), with its `src` path and its citation label
   (`cite: [10-23 ¶N][1023-thinking-about]`). Read all of it, and the codebook.
2. **Find subjects bottom-up.** Note what each memo is about, paragraph by paragraph. Memos are run-ons
   that jump between topics, so one memo often feeds several subjects. Group by shared meaning and name
   the groups last; don't start from a preset category list. Small leftovers go under **Miscellaneous**.
3. **Write the note** (template below). For each subject: a short summary, cited; a few key quotes;
   open questions and decisions. Then the summary, to-dos, people and memo list.
4. **Link and verify.** `vmnotes.py refs <note>` writes the reference definitions. Then
   `vmnotes.py verify <note> [<note>…]` (every note for the range together) must print `OK`. Fix what it
   reports and re-run both.
5. **Update the codebook** with new entities, aliases and corrections. Keep existing keys stable.

## Citations

A citation is a reference link whose text is the memo date and paragraph(s), and whose label is the
transcript's citation label from `segment`:

```markdown
The PDS mostly exists to authorize the [Work] API [10-24 ¶1-2][1024-so-back].
```

Cite every claim in a summary, every quote and every to-do. Cite the narrowest paragraph range that
supports it. `refs` defines each label as the transcript's path, so the link opens the original.

## Quotes

Quote sparingly, for what a paraphrase would lose: a decision in the speaker's words, a vivid framing,
an exact question to ask someone. One to three per subject; often none. A quote is a double-quoted
excerpt immediately followed by its citation, inline or as a blockquote line:

```markdown
> "The links in the composition service exist for the Empire platform." [10-25 ¶7][1025-possible-mental]
```

- Copy the words exactly; mark omissions with `…`. Use single quotes for any quote inside a quote.
- At most 50 words. `verify` checks each quote against the cited paragraphs.
- Apply the codebook's **Corrections** in brackets, exactly as the table says: "[Acme] Core".

## Links

Reference-style only, so the raw Markdown reads cleanly: `[text][label]`, never `[text](target)`.
`verify` rejects inline links. `refs` regenerates the `<!-- refs -->` block at the end of the note; a
hand-written definition outside that block survives (e.g. `[week-note]: 2026-10-19_2026-10-25.md`).
Anchor a heading or list item with `<a id="…"></a>` to link to it within the note: `[PDS][s-pds]`.

## Separate notes

Some topics get their own note for the same range, `organized/<from>_<to>-<topic>.md`. The codebook's
**Separate notes** table says which, and the user may ask for more. Assign whole memos: each source
belongs to exactly one note's `sources`. A memo mixing topics stays in the main note. Each note has its
own Summary, To-dos, Subjects, People and Memos. Other notes never mention a separated topic — no links,
quotes or asides — and `verify` rejects any match of its pattern. The topic note may link back to the
main note with `[week-note]`.

## Codebook

- **Corrections**: systematic mishearings — a regex, what it means, notes (escape `|` as `\|`). Use the
  corrected form everywhere in the note: summaries, to-dos, names, and (in brackets) quotes. `verify`
  rejects any uncorrected match. When the user corrects a name, add a row, and check the pattern can't
  hit unrelated words (e.g. the verb "sync").
- **Separate notes**: topic, file suffix, a regex that recognizes a mention, cues.
- **Entities**: people, systems, initiatives, questions and decisions, with aliases for transcription
  variants. Use the codebook's label when naming an entity in the note, so names stay consistent across
  weeks.

## Note template

```markdown
---
range: 2026-10-19_2026-10-25
generated: 2026-10-25
codebook: codebook.md
sources:
  - ../transcripts/2026-10-24-so-back-to-this-pds.md
  - ../transcripts/2026-10-25-write-a-skill-to-process.md
---

# Voice memos 2026-10-19 – 2026-10-25

## Summary

Three to six bullets: the week's main threads and where they landed, each cited and linked to its
subject ([PDS][s-pds]).

## To-dos

- [ ] Write the specific questions for [name], [name] and [name] before Monday [10-25 ¶2][1025-ask-the]

## Subjects

### <a id="s-pds"></a>Product definition service (PDS)

A short summary — a paragraph or two, or bullets — citing as it goes. Report what the speaker said
and where their thinking ended up; when it changed across the week, say so in date order.

> "…" [10-24 ¶2][1024-so-back]

**Open questions:** what the speaker left unresolved, cited.

**Decisions:** what was settled, cited. Omit either heading if empty.

**Commentary:** optional, Claude's own observations, clearly marked. Usually omit.

### Miscellaneous

## People

- **[name]** — composition-service design; questions on link direction [10-25 ¶1][1025-question-on]

## Memos

One line per memo, in date order: what it covers and which subjects it feeds.

- [10-25 · Write a skill to process transcripts][1025-write-a] — a skill that organizes transcripts by subject → [Transcript skill][s-transcript-skill]
```

## Rules

- **Processed, not transcribed.** Write in your own words; quote only what earns it. A subject's
  summary should be much shorter than the paragraphs it draws on.
- **Everything cited.** No claim without a citation. Report; don't editorialize outside
  **Commentary**.
- **Nothing dropped.** Every memo appears under **Memos** and is cited at least once (`verify` checks).
  Asides that fit no subject go under Miscellaneous.
- **To-dos** are GFM task items for things the speaker intends to do or asked to have done, in
  imperative form, each cited. Group them by subject if there are many.
- **Re-running** a range overwrites its note.
- Don't create files inside the transcripts folder.
