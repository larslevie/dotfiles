#!/usr/bin/env python3
"""Helpers for summarizing voice memos and meeting transcripts into subject-based notes.

  segment <from> <to> <folder>… [--relative-to DIR]   print sources with numbered paragraphs and citation labels
  refs <note.md>                                       regenerate the note's reference definitions
  verify <note.md> [<note.md>…]                        check citations, quotes, coverage and links

Voice memos are `YYYY-MM-DD-slug.md`; meetings are `YYYY-MM-DD_HH-MM-slug-<meeting id>.md` with a
`## Summary` and a `## Transcript` of `**[HH:MM:SS] Name:** text` lines.
"""
import argparse
import os
import re
import sys
from collections import Counter
from pathlib import Path

# A citation `[10-23 ¶5][1023-thinking-about]`, `[10-23 ¶5-7][…]`, or for a meeting transcript
# `[10-14 @00:12:34][…]` / `[10-14 @00:12:34-00:13:10][…]`, optionally right after a double-quoted
# excerpt it vouches for.
CITE_RE = re.compile(
    r'(?:["“](?P<quote>[^"”\n]+)["”][\s—–-]*)?'
    r"\[(?P<date>\d\d-\d\d) (?:¶(?P<a>\d+)(?:-(?P<b>\d+))?|@(?P<t1>\d\d:\d\d:\d\d)(?:-(?P<t2>\d\d:\d\d:\d\d))?)\]"
    r"\[(?P<key>[^\]\s]+)\]"
)
STEM_RE = re.compile(r"(\d{4})-(\d\d)-(\d\d)(?:_(\d\d)-(\d\d))?-(.*?)(?:-\d{9,})?$")
LINE_RE = re.compile(r"^\*\*\[(\d\d:\d\d:\d\d)\] ([^:*]+):\*\* ?(.*)$", re.M)
INLINE_LINK_RE = re.compile(r"\]\(([^)\s]+)\)")
REF_LINK_RE = re.compile(r"\]\[([^\]\s]+)\]")
ANCHOR_RE = re.compile(r'<a id="([^"]+)"></a>')
REFS_RE = re.compile(r"\n*<!-- refs -->.*?<!-- /refs -->\n*", re.S)
REF_DEF_RE = re.compile(r"^\[([^\]]+)\]:\s*<?([^<>\n]+?)>?\s*$", re.M)
MAX_QUOTE_WORDS = 50


def split_frontmatter(text):
    m = re.match(r"---\n(.*?)\n---\n?", text, re.S)
    return (m.group(1), text[m.end():]) if m else ("", text)


def paragraphs(body):
    return [p.strip() for p in re.split(r"\n\s*\n", body.strip()) if p.strip()]


def source_paragraphs(path):
    return paragraphs(split_frontmatter(Path(path).read_text())[1])


def split_meeting(body):
    """(summary part, transcript part); transcript is empty for voice memos."""
    head, sep, transcript = body.partition("\n## Transcript")
    return (head, transcript) if sep else (body, "")


def transcript_lines(path):
    """[(timestamp, speaker, text)] for a meeting transcript."""
    return LINE_RE.findall(split_meeting(split_frontmatter(Path(path).read_text())[1])[1])


def is_empty_meeting(body):
    head, transcript = split_meeting(body)
    return bool(transcript) and not LINE_RE.search(transcript) and "_No summary content._" in head


def frontmatter_list(frontmatter, key):
    m = re.search(rf"^{key}:\s*\n((?:[ \t]+-.*\n?)+)", frontmatter, re.M)
    if not m:
        return []
    return [re.sub(r'^\s*-\s*["\']?|["\']?\s*$', "", line) for line in m.group(1).splitlines()]


def source_key(path):
    """Citation label: `MMDD-` plus the fewest slug words unique among same-day sources in the folder;
    meetings that still collide (e.g. two "zoom-meeting"s) get their start time: `1016-1327-zoom-meeting`."""
    path = Path(path)
    _, mm, dd, hh, mi, slug = STEM_RE.match(path.stem).groups()
    words = slug.split("-")
    siblings = [STEM_RE.match(p.stem).group(6).split("-")
                for p in path.parent.glob(f"{path.name[:10]}[-_]*.md") if p.name != path.name and STEM_RE.match(p.stem)]
    n = next((n for n in range(2, len(words) + 1) if all(s[:n] != words[:n] for s in siblings)), None)
    if n is None:
        return f"{mm}{dd}-{hh}{mi}-{'-'.join(words[:2])}" if hh else f"{mm}{dd}-{slug}"
    return f"{mm}{dd}-{'-'.join(words[:n])}"


def codebook_section(note, heading):
    frontmatter, _ = split_frontmatter(note.read_text())
    m = re.search(r"^codebook:\s*(\S+)", frontmatter, re.M)
    path = note.parent / (m.group(1) if m else "codebook.md")
    if not path.exists():
        return ""
    section = re.search(rf"^## {heading}\n(.*?)(?=^## |\Z)", path.read_text(), re.M | re.S)
    return section.group(1) if section else ""


def table_regex(cell):
    # Table cells escape alternation pipes as `\|`.
    return re.compile(cell.replace(r"\|", "|"))


def load_corrections(note):
    """(pattern, "[replacement]") pairs from the codebook's Corrections table (`regex` | Means | …)."""
    rows = re.findall(r"^\|\s*`([^`]+)`\s*\|\s*([^|]+?)\s*\|", codebook_section(note, "Corrections"), re.M)
    return [(table_regex(pattern), f"[{means}]") for pattern, means in rows]


def load_separate_topics(note):
    """(file suffix, pattern) pairs from the codebook's Separate notes table (Topic | `-suffix` | `regex` | …)."""
    rows = re.findall(r"^\|[^|]*\|\s*`(-[^`]+)`\s*\|\s*`([^`]+)`\s*\|", codebook_section(note, "Separate notes"), re.M)
    return [(suffix, table_regex(pattern)) for suffix, pattern in rows]


def correct(text, corrections):
    for pattern, replacement in corrections:
        text = pattern.sub(replacement, text)
    return text


def normalize(s):
    return " ".join(s.replace("’", "'").replace("‘", "'").split()).lower()


def quote_found(quote, text):
    """True if each `…`-separated fragment of the quote occurs in text, in order."""
    hay, pos = normalize(text), 0
    for frag in re.split(r"…|\.\.\.", quote):
        frag = normalize(frag).strip(" .,;:!?")
        if not frag:
            continue
        i = hay.find(frag, pos)
        if i < 0:
            return False
        pos = i + len(frag)
    return True


def in_range(path, start, end):
    return re.match(r"\d{4}-\d{2}-\d{2}", path.name) and start <= path.name[:10] <= end


def segment(args):
    """Voice memos print in full. Meetings print their summary paragraphs and a transcript outline;
    read transcript passages from the file itself."""
    files = sorted((p for folder in args.folders for p in Path(folder).glob("*.md") if in_range(p, args.start, args.end)),
                   key=lambda p: p.name)
    for path in files:
        frontmatter, body = split_frontmatter(path.read_text())
        if is_empty_meeting(body):
            print(f"<!-- skipped empty meeting {path.name} -->", file=sys.stderr)
            continue
        field = lambda k: (re.search(rf'^{k}:\s*"?(.*?)"?\s*$', frontmatter, re.M) or [None, ""])[1]
        head, transcript = split_meeting(body)
        rel = os.path.relpath(path, args.relative_to)
        ref = "@HH:MM:SS" if transcript else "¶N"
        print(f"## {path.stem}\nsrc: {rel}\ncite: [{path.name[5:10]} {ref}][{source_key(path)}]\ntitle: {field('title')}")
        if transcript:
            lines = LINE_RE.findall(transcript)
            print(f"participants: {field('participants')}\nsummary cite: [{path.name[5:10]} ¶N][{source_key(path)}]")
            if lines:
                print(f"transcript: {len(lines)} lines, {lines[0][0]}–{lines[-1][0]}")
        print()
        for i, para in enumerate(paragraphs(head), 1):
            print(f"[p{i:02d}] {para}\n")
    print(f"<!-- {len(files)} sources -->", file=sys.stderr)


def render_refs(note, text):
    """Reference definitions for every listed source and every anchor in the note."""
    frontmatter, _ = split_frontmatter(text)
    sources = frontmatter_list(frontmatter, "sources")
    defs = {source_key(note.parent / src): src for src in sources}
    if len(defs) != len(sources):
        sys.exit("citation label collision among sources")
    defs |= {a: f"#{a}" for a in ANCHOR_RE.findall(text)}
    lines = "\n".join(f"[{k}]: <{v}>" if " " in v else f"[{k}]: {v}" for k, v in defs.items())
    return f"\n\n<!-- refs -->\n\n{lines}\n\n<!-- /refs -->\n"


def refs(args):
    note = Path(args.note)
    text = REFS_RE.sub("\n", note.read_text()).rstrip() + "\n"
    note.write_text(text.rstrip() + render_refs(note, text))
    print(f"wrote references for {note}")


def verify(args):
    """Check one or more notes; each source belongs to exactly one note and is cited there."""
    errors, sources = [], {}
    for note in map(Path, args.notes):
        errors += [f"{note.name}: {e}" for e in verify_note(note, sources)]
    for e in errors:
        print(f"✗ {e}")
    print(f"{'FAIL' if errors else 'OK'}: {len(sources)} sources in {len(args.notes)} note(s), {len(errors)} problems")
    return 1 if errors else 0


def added_text(body):
    """The note as a reader sees it: no reference definitions, link labels or anchor ids."""
    text = REFS_RE.sub("\n", body)
    text = REF_DEF_RE.sub("", text)
    text = REF_LINK_RE.sub("]", text)
    return ANCHOR_RE.sub("", text)


def verify_note(note, sources):
    base = note.parent
    corrections = load_corrections(note)
    frontmatter, body = split_frontmatter(note.read_text())
    listed = {(base / src).resolve(): src for src in frontmatter_list(frontmatter, "sources")}
    errors = [] if listed else ["frontmatter has no `sources:` list"]
    for path, src in listed.items():
        if path in sources:
            errors.append(f"source listed in more than one note: {src}")
        sources[path] = src

    defs = dict(REF_DEF_RE.findall(body))
    cited = Counter()
    for m in CITE_RE.finditer(body):
        where = m.group(0)[m.group(0).index("[" + m["date"]):]
        target = defs.get(m["key"])
        path = (base / target).resolve() if target else None
        if path not in listed:
            errors.append(f"{where}: label is not a listed source (run refs)")
            continue
        cited[path] += 1
        if path.name[5:10] != m["date"]:
            errors.append(f"{where}: date doesn't match {path.name}")
        if m["t1"]:
            t1, t2 = m["t1"], m["t2"] or m["t1"]
            lines = transcript_lines(path)
            if not any(t == t1 for t, _, _ in lines):
                errors.append(f"{where}: no transcript line at {t1}")
                continue
            cited_text = " ".join(f"{text}" for t, _, text in lines if t1 <= t <= t2)
        else:
            source = paragraphs(split_meeting(split_frontmatter(path.read_text())[1])[0])
            a, b = int(m["a"]), int(m["b"] or m["a"])
            if not 1 <= a <= b <= len(source):
                errors.append(f"{where}: source has {len(source)} paragraphs")
                continue
            cited_text = " ".join(source[a - 1:b])
        if m["quote"]:
            if len(m["quote"].split()) > MAX_QUOTE_WORDS:
                errors.append(f"{where}: quote over {MAX_QUOTE_WORDS} words; trim it with …")
            if not quote_found(m["quote"], correct(cited_text, corrections)):
                errors.append(f'{where}: quote not in source: "{m["quote"][:60]}"')

    errors += [f"source never cited: {src}" for path, src in listed.items() if not cited[path]]
    anchors = Counter(ANCHOR_RE.findall(body))
    errors += [f"duplicate anchor #{a}" for a, n in anchors.items() if n > 1]
    errors += [f"inline link ({t}); use a reference link" for t in sorted(set(INLINE_LINK_RE.findall(body)))]
    errors += [f"undefined reference [{k}] (run refs)" for k in sorted(set(REF_LINK_RE.findall(body))) if k not in defs]
    errors += [f"reference [{k}] points to missing anchor {v}" for k, v in defs.items()
               if v.startswith("#") and v[1:] not in anchors]
    errors += [f"reference [{k}] points to missing file {v}" for k, v in defs.items()
               if not v.startswith("#") and not (base / v.split("#")[0]).exists()]

    text = added_text(body)
    errors += [f'uncorrected "{hit}" (codebook says [{means.strip("[]")}])'
               for pattern, means in corrections for hit in sorted(set(pattern.findall(text)))]
    errors += [f'mentions "{hit}", which belongs only in the *{suffix}.md note'
               for suffix, pattern in load_separate_topics(note) if not note.stem.endswith(suffix)
               for hit in sorted(set(pattern.findall(text)))]
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("segment")
    s.add_argument("start", help="YYYY-MM-DD, inclusive")
    s.add_argument("end", help="YYYY-MM-DD, inclusive")
    s.add_argument("folders", nargs="+", help="voice-memo and meeting folders")
    s.add_argument("--relative-to", default=".", help="directory the note will live in")
    s.set_defaults(fn=segment)
    r = sub.add_parser("refs")
    r.add_argument("note")
    r.set_defaults(fn=refs)
    v = sub.add_parser("verify")
    v.add_argument("notes", nargs="+", help="all notes covering one range, checked together")
    v.set_defaults(fn=verify)
    args = parser.parse_args()
    sys.exit(args.fn(args) or 0)


if __name__ == "__main__":
    main()
