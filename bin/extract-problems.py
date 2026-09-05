#!/usr/bin/env python3
"""Extract problem metadata from the PSC LaTeX sources into _data/sets.yml.

Every problem in the sets is already a structured record:

    \begin{challenge}{Title}{Topic / Difficulty}{Source}

Some sets suppress fields 2 and 3 when rendering the PDF, but the metadata is
in the source either way. This reads it back out so the site can show a hint
layer (topic, difficulty, attribution) without publishing solutions.

Run from the repo root:  python3 bin/extract-problems.py
Re-run whenever a .tex file changes.
"""

from __future__ import annotations

import os
import pathlib
import re
import sys

SRC = pathlib.Path(
    os.environ.get(
        "PSC_SRC",
        pathlib.Path.home() / "repos/teaching/ProblemSolving/ProblemSetsPSC",
    )
).expanduser()

# Override with --out to write elsewhere. bin/check-build.sh uses that to
# compare against the committed file without touching the working tree: a
# check that rewrites the files it is checking is not a check.
OUT = pathlib.Path(__file__).resolve().parent.parent / "_data" / "sets.yml"
if "--out" in sys.argv:
    OUT = pathlib.Path(sys.argv[sys.argv.index("--out") + 1])

# Order here is the order on /problems/. Newest term first.
SETS = [
    dict(slug="geometry", source="geometry-problems.tex",
         title="Geometry", term="Spring 2026", date="2026-04-21",
         blurb="Thirty problems in three parts: the basic facts, training "
               "exercises, and competition-level geometry. The most developed "
               "set in the archive."),
    dict(slug="assorted-classics", source="youtube-favorites.tex",
         title="Assorted Classic Problems", term="Spring 2026", date="2026-04-15",
         blurb="Well-travelled problems that reward a second look."),
    dict(slug="linear-algebra", source="LinAlgProblems.tex",
         title="Linear Algebra", term="Spring 2026", date="2026-03-31",
         blurb="Matrix and linear-algebra problems in the competition style.",
         epigraph="No one shall expel us from the paradise that Cantor has created.",
         epigraph_by="David Hilbert"),
    dict(slug="five-minute-gems", source="five_minute_gems.tex",
         title="Five-Minute Gems", term="Spring 2026", date="2026-03-24",
         blurb="Short problems with a clean idea at the centre. Each is meant "
               "to be stated, attacked, and resolved inside one sitting.",
         epigraph="It is not enough to have a good mind; the main thing is to use it well.",
         epigraph_by="René Descartes"),
    dict(slug="games-and-strategy", source="GamesProblems.tex",
         title="Games and Strategy", term="Spring 2026", date="2026-03-03",
         blurb="Combinatorial games, invariants, and winning strategies.",
         epigraph="Every battle is won before it is ever fought.",
         epigraph_by="Sun Tzu"),
    dict(slug="spring-2026-intro", source="UTSAPSC_spring2026_problems.tex",
         title="Opening Set", term="Spring 2026", date="2026-02-11",
         blurb="The set the club opened Spring 2026 with — the round table, "
               "the monk on the mountain, the pigeonholes, the broken stick.",
         epigraph="Mathematics is not a spectator sport.",
         epigraph_by="George Pólya"),
    dict(slug="all-time-favorites", source="UTSA_PSC_favorites.tex",
         title="All-Time Favorites", term="Since 2022", date="2022-09-14",
         blurb="Problems the club keeps coming back to.",
         env="question"),
]

# \begin{challenge}{A}{B}{C} — brace-aware, so a nested group such as
# {Menelaus of Alexandria ($\sim$100\,AD)} does not truncate the field.
CHALLENGE = re.compile(r"\\begin\{challenge\}")
# \begin{question}[name=Title]
QUESTION = re.compile(r"\\begin\{question\}\[name=([^\]]*)\]")


def read_group(text: str, i: int) -> tuple[str, int]:
    """Read a balanced {...} group starting at text[i] == '{'."""
    assert text[i] == "{", f"expected {{ at {i}"
    depth, j = 0, i
    while j < len(text):
        c = text[j]
        if c == "\\":
            j += 2
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                return text[i + 1:j], j + 1
        j += 1
    raise ValueError("unbalanced braces")


MATH = re.compile(r"\$[^$]*\$")


def strip_tex(s: str) -> str:
    """Reduce a LaTeX fragment to text for a web listing, preserving math.

    Titles are rendered through KaTeX on the site, so `$\\mathrm{GL}_2(\\mathbb{Z})$`
    must survive verbatim. Only the prose *around* math spans is flattened;
    stripping macros inside them would silently turn it into `$GL_2(Z)$`.
    """
    held: list[str] = []

    def hold(m: re.Match) -> str:
        held.append(m.group(0))
        return f"\x00{len(held) - 1}\x00"

    s = MATH.sub(hold, s)

    s = re.sub(r"\\[,;!]", " ", s)                     # thin spaces
    s = s.replace("~", " ").replace("\\ ", " ")
    s = re.sub(r"\\(emph|textbf|textit|text|mbox)\{([^}]*)\}", r"\2", s)
    s = re.sub(r"\\\$", "$", s)
    s = re.sub(r"\\[a-zA-Z]+", "", s)                  # any remaining macro
    s = s.replace("{", "").replace("}", "")
    s = re.sub(r"^\s*\d+\.\s*", "", s)                 # leading "7. " in titles
    s = re.sub(r"\s+", " ", s).strip()

    # Emit \( ... \) rather than $ ... $. The site's KaTeX auto-render is
    # configured for the delimiters used across these sites, and enabling a
    # bare `$` there would make any stray dollar sign in prose start a math
    # span. Titles are rendered by Liquid straight into HTML, so no Markdown
    # processor sees these backslashes.
    def unhold(m: re.Match) -> str:
        span = held[int(m.group(1))]
        return "\\(" + span[1:-1].strip() + "\\)"

    return re.sub(r"\x00(\d+)\x00", unhold, s)


def uncommented(text: str) -> str:
    """Blank out commented-out lines so retired problems are not extracted.

    Several sets keep problems in reserve behind a leading %. Those must not
    appear on the site: they were pulled deliberately (duplicates of another
    set, or held back for a future meeting).
    """
    out = []
    for line in text.splitlines():
        stripped = line.lstrip()
        out.append("" if stripped.startswith("%") else line)
    return "\n".join(out)


def parse(path: pathlib.Path, env: str) -> list[dict]:
    raw = uncommented(path.read_text(encoding="utf-8"))
    problems: list[dict] = []

    if env == "question":
        for m in QUESTION.finditer(raw):
            problems.append({"title": strip_tex(m.group(1))})
        return problems

    for m in CHALLENGE.finditer(raw):
        i = m.end()
        fields = []
        for _ in range(3):
            while i < len(raw) and raw[i] in " \t\n":
                i += 1
            if i >= len(raw) or raw[i] != "{":
                break
            body, i = read_group(raw, i)
            fields.append(strip_tex(body))
        if not fields:
            continue
        # Two problems in LinAlgProblems.tex carry an empty title and topic and
        # are identified only by their citation ({}{}{Putnam 1990 B3}). Promote
        # the source to the title rather than rendering a blank listing row.
        title = fields[0]
        if not title and len(fields) > 2 and fields[2]:
            title = fields[2]
        rec: dict = {"title": title}
        # Field 2 is "Topic / Difficulty" or just a topic. Split only on the
        # last slash-separated part when it names a difficulty; otherwise the
        # whole field is the topic ("Euclidean / Vector Geometry" is one topic).
        if len(fields) > 1 and fields[1]:
            topic = fields[1]
            # Difficulty appears two ways across the sets: trailing after a
            # slash ("Logic / Invariants / Easy") and parenthesised
            # ("Eigenvalues/vectors (Medium)"). Handle both, and leave the
            # topic whole otherwise -- "Euclidean / Vector Geometry" is one
            # topic, not a topic plus a difficulty.
            m2 = re.search(r"\((easy|medium|hard)\)\s*$", topic, re.I)
            if m2:
                rec["difficulty"] = m2.group(1).capitalize()
                topic = topic[: m2.start()].strip()
            else:
                parts = [p.strip() for p in topic.split("/")]
                if len(parts) > 1 and parts[-1].lower() in {"easy", "medium", "hard"}:
                    rec["difficulty"] = parts[-1].capitalize()
                    topic = " / ".join(parts[:-1])
            if topic:
                rec["topic"] = topic
        if len(fields) > 2 and fields[2]:
            rec["source"] = fields[2]
        problems.append(rec)
    return problems


def yaml_str(s: str) -> str:
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main() -> int:
    if not SRC.is_dir():
        print(f"error: source directory not found: {SRC}", file=sys.stderr)
        print("set PSC_SRC to the ProblemSetsPSC directory", file=sys.stderr)
        return 1

    lines = [
        "# GENERATED by bin/extract-problems.py — do not edit by hand.",
        f"# Source: {SRC}",
        "# Re-run the script after changing any .tex file.",
        "",
    ]
    total = 0
    for spec in SETS:
        path = SRC / spec["source"]
        if not path.exists():
            print(f"error: missing {path}", file=sys.stderr)
            return 1
        problems = parse(path, spec.get("env", "challenge"))
        total += len(problems)
        print(f"{spec['slug']:<20} {len(problems):>3} problems  ({spec['source']})")

        lines.append(f"- slug: {spec['slug']}")
        lines.append(f"  title: {yaml_str(spec['title'])}")
        lines.append(f"  term: {yaml_str(spec['term'])}")
        # Quoted deliberately: an unquoted YAML date becomes a Date object,
        # which every strict YAML loader then has to be told to permit.
        lines.append(f"  date: {yaml_str(spec['date'])}")
        lines.append(f"  source_tex: {yaml_str(spec['source'])}")
        lines.append(f"  count: {len(problems)}")
        lines.append(f"  blurb: {yaml_str(spec['blurb'])}")
        if spec.get("epigraph"):
            lines.append(f"  epigraph: {yaml_str(spec['epigraph'])}")
            lines.append(f"  epigraph_by: {yaml_str(spec['epigraph_by'])}")
        lines.append("  problems:")
        for p in problems:
            lines.append(f"    - title: {yaml_str(p['title'])}")
            for key in ("topic", "difficulty", "source"):
                if p.get(key):
                    lines.append(f"      {key}: {yaml_str(p[key])}")
        lines.append("")

    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"\nwrote {OUT.relative_to(OUT.parent.parent)} — "
          f"{len(SETS)} sets, {total} problems")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
