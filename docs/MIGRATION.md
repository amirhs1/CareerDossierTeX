# Migration Notes

For people with documents built on an earlier release: what changed between
versions, which changes need a source edit, and which only change how a document
renders. Read it before upgrading. It records the *differences* — the current
interface itself is in [`API.md`](API.md).

## Status

`v0.7.0` is the current published release. It renames public design tokens, adds
new ones beside them, **retires three**, and retunes the calibrated
vertical-rhythm ratios. Renamed tokens need a source edit only if a document
reads or sets them by name, and all three retired tokens rendered nothing at the
`v0.6.0` defaults — but three mechanism changes do move the page: letter and
statement headers tighten, the gap above a bullet list inside an entry tightens,
and a document with no `headline` gains a little space below the name. **The
retune then reflows every document.** It also makes three undocumented
class-to-package primitives private, which changes no output and affects no
supported document. See [`[0.7.0]`](#070---2026-08-04) below. This release was
numbered `v0.6.1` until 2026-08-01.

`v0.6.0` **removes the `density` option and changes every class's layout
defaults** — see [Upgrading to `v0.6.0`](#upgrading-to-v060) below. A document
coming from `v0.5.x` or earlier needs that section as well as the `v0.7.0` one.

`v0.4.0` **changes the supported engine from XeLaTeX to LuaLaTeX** — see
[Upgrading to `v0.4.0`](#upgrading-to-v040-xelatex--lualatex) below.

No released public command, key, class option, or default has been renamed or
removed in `v0.5.0`. Its statement class, A4 paper, sans body font, affiliation
key, and contact labels are additive and opt-in; existing documents need no
source edit. The `v0.4.0` break is in the toolchain, not the document API. Two
documents do render differently — the academic CV's folio and the academic
letter's page furniture — and neither requires a source edit; see step 5.

## Upgrading to `v0.6.0`

`v0.6.0` adds `fontsize=12pt` and
`margin=normal|narrow` consistently across all four document classes. The
résumé now defaults to `fontsize=11pt,margin=narrow`; the CV, letter, and
statement classes default to `fontsize=12pt,margin=normal`. `normal` is one
inch and `narrow` is half an inch.

**Every existing document reflows.** This is not a caveat about unusual
documents: type sizes, every structural gap, the section rule, and the list
metrics are all newly derived from `fontsize`, and every class's default body
size or margin has changed. A document that took two pages may now take three,
or one. No source edit is required unless you pass `density`, but do not ship
an upgraded document without looking at it.

The measure changes too. The résumé defaults to `11pt` at `margin=narrow`, and
the CV, letter, and statement classes to `12pt` at `margin=normal`; the measured
characters per line for every combination are tabulated in
[`ARCHITECTURE.md`](ARCHITECTURE.md#careerdossier-tokenssty).

The résumé's default is the longest measure in the project, kept deliberately
for one-page capacity; see [`API.md`](API.md) for when to override it.

On US Letter paper, `margin=narrow` increases the physical text block from the
v0.5.0 résumé's 72.27 in² to 75.00 in² (about 3.8%) and provides about 28.2%
more printable area than `margin=normal`. After accounting for the change from
10pt/12pt body size and leading to 11pt/13.6pt, estimated line-and-page capacity
is about 16.8% lower than v0.5.0, compared with about 35.1% lower for
`fontsize=11pt,margin=normal`.

The résumé and CV no longer accept `density=compact|standard`; their vertical
rhythm is derived from `fontsize`. Remove the option and select the intended
size and margin directly:

```latex
% Before
\documentclass[fontsize=11pt,density=compact]{careerdossier-resume}

% After
\documentclass[fontsize=11pt,margin=narrow]{careerdossier-resume}
```

For the CV:

```latex
% Before
\documentclass[fontsize=12pt,density=standard]{careerdossier-cv}

% After
\documentclass[fontsize=12pt,margin=normal]{careerdossier-cv}
```

Passing `density` to either class now stops with that class's actionable
unknown-option error. The CV's former roomier `standard` spacing is intentionally
retired: the CV and résumé now share proportional rhythm, while the CV remains
roomier by default because its body size is larger. The manual publication
list's label separation also moves from `0.6em` to the shared list token.

To preserve a released class's previous body-size choice, set it explicitly in
the document class options. The old per-class physical margins do not map
exactly to both new presets; choose the closest preset and review the result.

Users who need dimensions beyond the two supported presets may call
`\geometry{...}` after `\documentclass`, because the classes already load the
package through `careerdossier-tokens`:

```latex
\documentclass[margin=normal]{careerdossier-letter}
\geometry{left=1.15in,right=1.15in,top=0.9in,bottom=0.9in}
```

Do not add another `\usepackage[...]{geometry}` call; reloading an already
loaded package with new options can produce an option clash. Custom geometry
bypasses the tested `normal` and `narrow` presets.

The industry and academic letter families now share the same geometry and
token-derived prose rhythm. `family=academic` no longer selects the former
family-specific spacing; it changes document-type metadata only, while both
families use the shared `Cover Letter` continuation label. The letterhead,
salutation, closing, and paragraph gaps now scale with `fontsize`. Existing
letters require no source edit, but their vertical spacing and pagination may
change and should be reviewed.

Statement headers and paragraph gaps now scale from the same calibrated tokens.
In particular, the name uses the `fontsize`-specific name step instead of
LaTeX's fixed 24.88 pt `\Huge`, so 10 pt, 11 pt, and 12 pt statements now have
19 pt, 21 pt, and 23 pt names respectively. The seven `type` values, their full
display titles and short continuation titles, validation rules, contact sets,
and optional-field behavior are unchanged. Existing statement sources require
no edit, but their header spacing, line breaks, and pagination should be
reviewed.

Statement headings change with them. `\section*` and `\subsection*` were
`article`'s: `\Large` — 17.28 pt under this class's 12 pt default, outside the
project's type scale — set in whichever family `bodyfont` selected, with
`article`'s own display skips. They now use the shared sans heading role, the
`\CDossierSizeSection` and `\CDossierSizeBody` steps, and the prose heading
rhythm, so a statement heading matches the section heading in every other
class. Existing statements need no source edit and keep working, but headings
are smaller, sans, and more tightly bound to the text under them, so pagination
should be reviewed. `\CDossierSection` and `\CDossierSubsection` are added as
the class's own names for the same two levels and are the preferred spelling
going forward.

### Build twice, and ignore the first pass

All four classes now suppress the folio on a single-page document and print
`Page N of M` on a multi-page one. Both decisions need the document's final
page count, which LaTeX only knows from the auxiliary file written by the
previous run. The résumé and CV page-break policy also records list lengths
there.

A first build from a clean tree therefore shows a folio on a one-page document
and provisional breaks, and settles on the next run. This is not a regression
to report; it is the same second pass that cross-references and `Page N of M`
have always needed. `latexmk` and the repository `make` targets already rerun.
A single bare `lualatex` invocation does not — if you script your own build,
run it twice.

## Upgrading to `v0.4.0`: XeLaTeX → LuaLaTeX

`v0.4.0` makes LuaLaTeX the sole supported engine. XeLaTeX and pdfLaTeX now stop
with a fatal error from `careerdossier-typography`:

```text
CareerDossierTeX requires LuaLaTeX.
Compile with lualatex, not xelatex or pdflatex.
```

There is no compatibility mode and no option to bypass the guard. Stay on
`v0.2.1` if you cannot move to LuaLaTeX.

### What does not change

Classes, class options, profile keys, public commands, environments, paper size,
and theme are unchanged. An existing document that does not contain
XeTeX-specific preamble code needs no edit beyond the build command.

Two exceptions to "page design is unchanged": the academic CV's folio and the
academic letter's running header and footer both changed, so those two documents
render slightly differently. Neither needs a source edit. See step 5.

### 1. Change the build command

Before:

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex
```

After:

```bash
latexmk -lualatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex
```

Update editor and CI configuration too. In TeXShop, TeXworks, VS Code
(LaTeX Workshop), or Overleaf, select LuaLaTeX as the typesetting engine. A
stale `latexmkrc`, `.vscode/settings.json`, or CI workflow still passing
`-xelatex` is the most common cause of the engine error after upgrading.

Reason: LuaHBTeX writes real interword spaces into the PDF text layer and
supports the LaTeX kernel tagging pipeline. XeTeX supports neither, which capped
both extraction reliability (see `v0.2.1` and issue #72) and tagged output.

### 2. Remove XeTeX-only preamble code

`\XeTeXgenerateactualtext` and other `\XeTeX…` primitives do not exist under
LuaTeX and raise "undefined control sequence".

Before:

```latex
\XeTeXgenerateactualtext=1
```

After:

```latex
% Delete it. CareerDossierTeX never enabled this from v0.2.1 onward, and
% LuaHBTeX does not need it: interword spaces are real in the text layer.
```

Guards of the form `\ifXeTeX … \fi` should be deleted or inverted to
`\ifLuaTeX`. `iftex` still provides both.

Reason: the primitive is engine-specific. Under XeTeX it also wrapped every word
in its own `/ActualText` span, which made PDFKit-based readers merge adjacent
words — the bug fixed in `v0.2.1`.

### 3. Check fonts if you overrode them

CareerDossierTeX resolves TeX Gyre Termes and TeX Gyre Heros **by file name**
through `luaotfload`, so the default build does not depend on OS-installed
fonts. Documents that called `\setmainfont` with a system font *name* that
resolved through fontconfig under XeLaTeX may resolve differently under
`luaotfload`.

If you override fonts, recompile and check the log for font substitutions and
missing glyphs before trusting the output.

### 4. Re-check pagination

LuaHBTeX's line breaking is not byte-identical to XeTeX's. Page breaks can shift
by a line in long documents. Review multi-page CVs and two-page résumés after
upgrading rather than assuming identical pagination.

### 5. Review the academic CV and letter page furniture

`v0.4.0` changes the running headers and folios of two documents so that a CV
and an academic cover letter sent together look like one set. **No source edit
is required** — this is rendered output only, and no class, option, key, or
command changed.

Affects `careerdossier-cv` and `careerdossier-letter` with `family=academic`.
The industry letter and the résumé are **unaffected**: the industry letter keeps
its `v0.1` empty page style, and the résumé still prints no folio.

| | Before (`v0.2.x`) | After (`v0.4.0`) |
| --- | --- | --- |
| CV folio | `Page 2` | `Page 2 of 2` |
| CV running header (page 2+) | `Name — Curriculum Vitae` | unchanged |
| Academic letter running header | *none* | `Name — Cover Letter` from page 2 |
| Academic letter folio | `Name` at left, `Page 2 of 2` at right | centered `Page 2 of 2` |

Reasons, in short: a bare `Page 2` cannot tell a reader holding a loose sheet
whether the document ended, and the two classes previously disagreed on every
aspect of their page furniture. The letter adopted the CV's pattern rather than
the reverse, because a running header naming the person and document type on
continuation pages is the stronger convention for both academic CVs and formal
multi-page correspondence.

The academic letter's name has moved, not disappeared: it is in the running
header from page two, and the letterhead and signature block already carried it
on page one. On a single-page letter the old footer was a third occurrence.

**What to check after upgrading:**

- Multi-page academic CVs and letters, to confirm the new furniture looks right
  with your own name and content lengths. A long name in the running header is
  the case most worth a glance.
- Any tooling that parsed your PDFs' footer text.

  A **CV** footer extracted as `Page 1` and now extracts as `Page 1 of 2`.

  An **academic letter** footer used to contain the name as well as the folio,
  and now contains only `Page 1 of 2`. How that name appeared in extracted text
  varied with the extractor, the name's length, and the resulting gap: some
  fixtures extracted `Ada Lovelace Page 1 of 1` as a single line, others put the
  name on its own line above the folio. Either way the name is no longer in the
  footer, so a script keying on it will need updating.

  This is the same class of breakage as the `doi:` → `DOI:` extraction change in
  `v0.2.1`.

If you enable tagged structure (step 6), both the running header and the folio
are marked as layout artifacts, so screen readers skip them rather than reading
page furniture into the document's prose. Untagged output is unaffected, since
it carries no structure tree either way.

### 6. Optional: enable tagged structure

`v0.4.0` adds opt-in tagged semantic structure. It is off by default and
requires no migration. To try it, add `\DocumentMetadata` before
`\documentclass`:

```latex
\DocumentMetadata{lang=en, tagging=on}
\documentclass{careerdossier-resume}
```

Tagged output is a tested preview for the five fixture profiles only and carries
no PDF/UA, WCAG, or ATS conformance claim. See [`API.md`](API.md) for scope.

## Purpose

This file records migration paths for incompatible public changes once
implementation begins, per the stability policy in [`docs/API.md`](API.md).

Before `v1.0.0`, breaking changes are allowed but must be documented here and in
[`CHANGELOG.md`](../CHANGELOG.md) in the same pull request that introduces the
change.

## Entry format

When a public command, key, or option is renamed, changed, or removed, add an
entry using this shape:

```text
## [0.x.0] - YYYY-MM-DD

### `\OldCommand` renamed to `\NewCommand`

Before:

\OldCommand{...}

After:

\NewCommand{...}

Reason: <why the change was necessary>
```

The `v0.4.0` engine change is a toolchain break rather than an API rename and
is documented in
[Upgrading to `v0.4.0`](#upgrading-to-v040-xelatex--lualatex) above rather than
in this format.

## [0.7.0] - 2026-08-04

### The vertical-rhythm ratios are retuned

**Every document reflows.** No name is added, removed, or renamed by this change
and no source edit is required — only the calibrated values move. Seventeen of
the twenty-five tokens end this release at a different ratio from the one their
boundary carried in `v0.6.0`, and eight are unchanged. The type scale, the
margin presets, and the page geometry do not move at all, and none of the 24
supported class × `fontsize` × `margin` combinations changes its page count.

What moves, and why:

- **Statements tighten.** The paragraph gap halves and the section and
  subsection gaps come down with it, so a statement fits more argument on a
  page.
- **Every heading pair becomes asymmetric by at least 2:1**, above to below, so
  a heading binds to the text it introduces instead of floating between two
  blocks.
- **Two relations the tokens named but the page never showed now hold**: a
  bullet list sits closer to the entry that owns it than to the next one, and
  the letter's body is framed by a gap visibly wider than an ordinary paragraph
  break — previously it was identical to one.

A document that already overrode one of these tokens keeps its own value and is
unaffected by the change to that token.

To restore the `v0.6.0` spacing exactly, set the changed tokens back after
`\documentclass`. The names are the `v0.7.0` ones; use the rename table below to
find what each was called in `v0.6.0`.

| Token | `v0.6.0` | `v0.7.0` |
|---|---:|---:|
| `\CDossierRecordHeaderBelowSkip` | 0.8125 | 0.9375 |
| `\CDossierProseHeaderBelowSkip` | 0.8125 | 0.9375 |
| `\CDossierLetterHeaderBelowSkip` | 0.8125 | 0.9375 |
| `\CDossierRecordSectionAboveSkip` | 0.6875 | 0.875 |
| `\CDossierRecordSectionBelowSkip` | 0.375 | 0.4375 |
| `\CDossierRecordEntryAboveSkip` | 0.25 | 0.3125 |
| `\CDossierRecordListEdgeAboveSkip` | 0.3125 | 0.25 |
| `\CDossierRecordListEdgeBelowSkip` | 0.3125 | 0.50 |
| `\CDossierProseSectionAboveSkip` | 1.50 | 0.875 |
| `\CDossierProseSectionBelowSkip` | 0.75 | 0.375 |
| `\CDossierProseSubsectionAboveSkip` | 1.00 | 0.625 |
| `\CDossierProseSubsectionBelowSkip` | 0.625 | 0.3125 |
| `\CDossierProseParSkip` | 0.50 | 0.25 |
| `\CDossierLetterParSkip` | 0.50, as `\CDossierProseParSkip` | 0.25 |
| `\CDossierLetterBodyAboveSkip` | 0.50 | 0.625 |
| `\CDossierLetterBodyBelowSkip` | 0.50, borrowed from `\CDossierLetterBlockSkip` | 0.625 |
| `\CDossierLetterSignatureGapSkip` | 2.25 | 2.00 |

The remaining eight tokens keep their `v0.6.0` ratio. A ratio is a multiple of
the body baseline, so restoring one means setting the token to that multiple of
the leading for the size in use — 12.0 pt at `10pt`, 13.6 pt at `11pt`, and
14.5 pt at `12pt`. The resolved values at each size are tabulated in
[`ARCHITECTURE.md`](ARCHITECTURE.md#vertical-rhythm).

Restoring the whole set is rarely what you want. The retune exists because
several of these tokens could not previously render the relation they named, so
a full restore reinstates those defects along with the spacing.

### Three vertical-spacing tokens retired, two added

Every vertical boundary is now owned by exactly one token.

Removed — **none of them rendered anything at the released defaults**, so
removing them changes no output:

| Removed | Use instead | Why it never rendered |
|---|---|---|
| `\CDossierRecordEntryBelowSkip` | `\CDossierRecordEntryAboveSkip` | Block boundaries compose with `\addvspace`, which takes the maximum of the adjacent claims, never their sum. At 0.125 this token lost to `\CDossierRecordEntryAboveSkip` (0.25) between two entries and to `\CDossierRecordSectionAboveSkip` (0.6875) at the end of a section — every boundary it appeared at. |
| `\CDossierLetterheadBelowSkip` | `\CDossierLetterHeaderBelowSkip` | It claimed the header → date boundary immediately after `\MakeCDossierHeader` had already claimed it, at a smaller value (0.75 against 0.8125), so the maximum discarded it. |
| `\CDossierHeaderAboveSkip`, renamed `\CDossierSharedHeaderAboveSkip` earlier in this release | nothing — the boundary does not exist | It claimed the boundary *above* the first header line. Every class renders its header as the first material in the document, and TeX discards glue at the top of a page, so the token rendered nothing at `0.00` or at any other value. |

A document that sets any of these names will now get an
undefined-control-sequence error. Delete the setting
(`\CDossierRecordEntryBelowSkip`, `\CDossierHeaderAboveSkip`) or move it to
`\CDossierLetterHeaderBelowSkip` (`\CDossierLetterheadBelowSkip`), which owns
the letter's header → date boundary and, since the split below, affects no
other class.

Added:

| Added | Boundary | Default |
|---|---|---|
| `\CDossierLetterRecipientLineGapSkip` | between two lines of the letter's recipient block | `0.00` |
| `\CDossierLetterBodyBelowSkip` | letter body → closing | `0.625`. It was added at `0.50`, the value the boundary already had; [#206](https://github.com/amirhs1/CareerDossierTeX/issues/206) then retuned it with the rest of the scale |

`\CDossierLetterBodyBelowSkip` is the pair of `\CDossierLetterBodyAboveSkip`.
The boundary previously borrowed `\CDossierLetterBlockSkip`, which names the
boundaries *between letterhead blocks*; a document that set
`\CDossierLetterBlockSkip` to change the space above its closing must now set
`\CDossierLetterBodyBelowSkip` instead.

`\CDossierLetterRecipientLineGapSkip` replaces a bare `\\` between recipient
lines, which was plain `\baselineskip` — the one vertical distance in the letter
no token expressed. At `0.00` it reproduces that spacing exactly.

Reason: `\addvspace` takes the maximum of the claims at a boundary, so where two
tokens met, the smaller was unreachable — a maintainer who lowered it saw no
change and no diagnostic. Giving each boundary exactly one token is a
prerequisite for retuning the ratios ([#206](https://github.com/amirhs1/CareerDossierTeX/issues/206)).

### Header spacing no longer floored by `\parskip`

`careerdossier-letter` and `careerdossier-statement` set `\parskip` to
`\CDossierProseParSkip` document-wide. Every header line is its own paragraph,
so that paragraph gap landed in every header boundary on top of the header
token, and `\addvspace` could not absorb it: `\parskip` is inserted at the next
paragraph's start, after `\addvspace` has already read `\lastskip`, so the two
always add.

The header block now zeroes `\parskip` for its own scope, so the header gap
tokens name the rendered gap in all four classes. That zero is fixed, not a
token: an intermediate revision of this release exposed it as
`\CDossierSharedHeaderParSkip`, but the value cancelled itself — the stack
emits every gap as `token − \parskip` and the following header line then
contributes `\parskip` again — so no value of it changed anything. It is not
part of the released API.

**Letters and statements reflow.** Each header boundary tightens by the prose
paragraph gap as it stood before the retune above — 0.50 of a line, 7.25 pt at
`fontsize=12pt`. The figures below isolate *this* change; the retune then moves
the same boundaries again. Measured on the shipped examples at 12 pt:
`letter-industry` and `letter-academic` reclaim 21.7 pt, `artist-statement`
36.1 pt, and `research-statement` 43.3 pt on page one. No example changes its
page count, but a statement fits more body text on page one than before. Résumé
and CV are unaffected, because `\CDossierRecordParSkip` is already `0.00`.

To keep the previous letter or statement header spacing, add back what the old
`\parskip` floor contributed — 0.50 of a line — after `\documentclass`:

```latex
\makeatletter\ExplSyntaxOn
\skip_add:Nn \CDossierSharedHeaderNameGapSkip { 7.25pt }
\skip_add:Nn \CDossierSharedHeaderMetaGapSkip { 7.25pt }
\ExplSyntaxOff\makeatother
```

That figure is for `fontsize=12pt`; use `6.8pt` at `11pt` and `6pt` at `10pt`.
It is written out rather than expressed as `\CDossierProseParSkip` because the
retune above halves that token, so reading it here would add only half the
floor. At `12pt` this restores the name gap to 10.875 pt and every later header
gap to 9.96875 pt. Do not apply it in the résumé or CV, which never had the
floor.

### `\CDossierRecordEntryGapSkip` became a floor rather than added space

The entry heading → body gap is now contributed with `\addvspace` instead of
`\vspace`. A `\vspace` appends a zero glue after its own skip, so the following
block's `\addvspace` saw `\lastskip = 0` and the two *added*; the gap above a
bullet list was `\CDossierRecordEntryGapSkip` **plus**
`\CDossierRecordListEdgeAboveSkip`. It is now the larger of the two.

**Résumés and CVs reflow slightly.** The gap above every bullet list inside an
entry tightens by `\CDossierRecordEntryGapSkip` — 0.85 pt at `fontsize=11pt`,
0.91 pt at `12pt`. An entry whose body is ordinary prose is unchanged. The
shipped `resume-english` example reclaims 4.2 pt over its five lists;
`cv-academic` 0.9 pt. Neither changes page count.

Reason: with the closing edge already a maximum and the opening edge a sum, the
design intent that a bullet list belongs to the entry above it was
inexpressible — at the released values the list sat 5.10 pt from the entry that
owns it and 4.25 pt from the next one, inverting the intent. Both ends are now
maxima, so the relation follows from the ratios alone.

### The gap below the name no longer depends on `headline`

The résumé, CV, and letter identity block and the statement header now emit
their lines and gaps from one shared helper. Position decides which token
guards a boundary, not presence: the boundary below the name is always
`\CDossierSharedHeaderNameGapSkip`.

**A résumé, CV, or letter with no `headline` reflows.** That boundary
previously fell through to `\CDossierSharedHeaderMetaGapSkip` (0.1875), so it
now gains `0.0625` of a line — 0.85 pt at `fontsize=11pt`. A document that sets
`headline` is unaffected.

### Vertical-spacing design tokens renamed onto one convention

Every public vertical-spacing token now has the shape
`\CDossier<Family><Scope><Position>Skip`:

- **Family** — which documents the token affects. `Shared` (all four classes),
  `Record` (the entry-structured classes: résumé and CV), `Prose` (the
  continuous-prose classes: letter and statement), or `Letter`.
- **Scope** — the block being spaced (`Header`, `Section`, `Entry`,
  `ListEdge`, `Salutation`, `Signature`, …).
- **Position** — `Above` or `Below` the block, or `Gap` between two parts of
  one block.

Seventeen of the twenty-two tokens released in `v0.6.0` are renamed. This
affects a document only if it reads or sets a token by name; **no value
changes**, so nothing reflows.

Before → after:

| `v0.6.0` | `v0.7.0` |
|---|---|
| `\CDossierHeaderAboveSkip` | `\CDossierSharedHeaderAboveSkip` — then **retired** in the same release; see “Three vertical-spacing tokens retired, two added” above |
| `\CDossierHeaderNameGapSkip` | `\CDossierSharedHeaderNameGapSkip` |
| `\CDossierHeaderMetaGapSkip` | `\CDossierSharedHeaderMetaGapSkip` |
| `\CDossierHeaderBelowSkip` | `\CDossierRecordHeaderBelowSkip`, `\CDossierProseHeaderBelowSkip`, **and** `\CDossierLetterHeaderBelowSkip` (split — see below) |
| `\CDossierSectionAboveSkip` | `\CDossierRecordSectionAboveSkip` |
| `\CDossierSectionRuleSkip` | `\CDossierRecordSectionRuleGapSkip` |
| `\CDossierSectionBelowSkip` | `\CDossierRecordSectionBelowSkip` |
| `\CDossierEntryAboveSkip` | `\CDossierRecordEntryAboveSkip` |
| `\CDossierEntryGapSkip` | `\CDossierRecordEntryGapSkip` |
| `\CDossierEntryBelowSkip` | `\CDossierRecordEntryBelowSkip` — then **retired** in the same release; see “Three vertical-spacing tokens retired, two added” above |
| `\CDossierListEdgeSkip` | `\CDossierRecordListEdgeAboveSkip` **and** `\CDossierRecordListEdgeBelowSkip` (split — see below) |
| `\CDossierItemSepSkip` | `\CDossierRecordItemSepSkip` |
| `\CDossierParSkip` | `\CDossierRecordParSkip` |
| `\CDossierAfterHeaderBlockSkip` | `\CDossierLetterheadBelowSkip` — then **retired** in the same release; see “Three vertical-spacing tokens retired, two added” above |
| `\CDossierBlockSkip` | `\CDossierLetterBlockSkip` |
| `\CDossierAfterSalutationSkip` | `\CDossierLetterBodyAboveSkip` |
| `\CDossierSignatureSkip` | `\CDossierLetterSignatureGapSkip` |

Unchanged: `\CDossierProseSectionAboveSkip`, `\CDossierProseSectionBelowSkip`,
`\CDossierProseSubsectionAboveSkip`, and `\CDossierProseSubsectionBelowSkip`.
`\CDossierProseParSkip` is unchanged for `careerdossier-statement`, but no
longer sets `\parskip` in `careerdossier-letter` — see the split below.

Two of these are more than a spelling change:

- `\CDossierAfterSalutationSkip` → `\CDossierLetterBodyAboveSkip`. The token is
  named for the boundary it opens — the top of the letter body — rather than
  for the block that happens to precede it. The gap it produces is unchanged.
- `\CDossierSignatureSkip` → `\CDossierLetterSignatureGapSkip`, not
  `…AboveSkip`. This is the blank space reserved *for* a handwritten signature
  between the closing and the typed name, so it is a `Gap` between two parts of
  the closing block, not the space above a block.

Reason: one idea — the gap on a given side of a block — was spelled three
ways. Ten tokens used `Above`/`Below` before `Skip`, the list-edge pair used
`Before`/`After` after `Skip`, two more used `After` with no matching
`Before`, and five carried no positional word at all. An unprefixed name also
meant either "shared by every class" or "résumé and CV only", with nothing in
the name to distinguish them. A reader of [`API.md`](API.md) could not predict
a token's name from its role, which is the point of a semantic token system.

This particular change is a rename only. Every token keeps its calibrated
ratio, all eleven supported examples render with identical word coordinates
before and after, and no class, option, key, command, or environment changed.
The other `0.7.0` entries above do move rendered output; read them separately.

`\CDossierLetterBlockSkip` no longer serves the letter body's closing edge —
that boundary is now `\CDossierLetterBodyBelowSkip` (see above). It still
serves the boundaries between the letterhead's own blocks.

### `\CDossierListEdgeSkip` split into two tokens

Before:

\CDossierListEdgeSkip

After:

\CDossierRecordListEdgeAboveSkip   % the gap above a list
\CDossierRecordListEdgeBelowSkip   % the gap below a list

Reason: LaTeX has a single `topsep` and spends it at both ends of a list, so
one token could not give the space above a list and the space below it
different values. Both new tokens keep the old token's calibrated value, so no
document reflows and no example or class option changes; only source that reads
or sets the token by name needs the edit. Read
`\CDossierRecordListEdgeAboveSkip` wherever the old name appeared, and set both
when overriding the list edge as a whole.

### `\CDossierProseParSkip` split for `careerdossier-letter`

Before:

\CDossierProseParSkip   % set \parskip in both careerdossier-letter and
                        % careerdossier-statement

After:

\CDossierLetterParSkip  % sets \parskip in careerdossier-letter
\CDossierProseParSkip   % unchanged: sets \parskip in careerdossier-statement

Reason: both classes set `\parindent = 0pt`, so this token was the only thing
separating one paragraph from the next in either class, but the two classes
pull it in opposite directions. The statement's heading below-tokens must stay
strictly greater than it — `\@xsect` reads a non-positive after-skip as a
request for a run-in heading — so the token is a floor under the statement's
entire heading scale. The letter has no heading scale to bound it and would
prefer a more generous paragraph gap for its unindented block paragraphs. A
single shared token meant retuning either class's paragraph gap was decided for
the other as a side effect. `\CDossierLetterParSkip` ships at the same `0.50`
ratio as `\CDossierProseParSkip`, so the split renders no document differently;
only source that reads or sets the letter's paragraph gap by name needs the
edit.

### `\CDossierHeaderBelowSkip` split into one token per family

Before:

\CDossierHeaderBelowSkip   % v0.6.0: the gap below the header block in all
                           % four classes

After:

\CDossierRecordHeaderBelowSkip   % careerdossier-resume, careerdossier-cv
\CDossierProseHeaderBelowSkip    % careerdossier-statement
\CDossierLetterHeaderBelowSkip   % careerdossier-letter

Reason: the two gaps *inside* the header block are genuinely shared — every
class stacks the same lines in the same order, and the block zeroes `\parskip`
for its own scope, so one ratio renders one gap everywhere. The gap *below* the
block is not shared in that sense: it is a boundary against whatever the class
puts next, and that neighbour differs per family — a ruled `\CDossierSection`
in the record classes, a prose section heading in the statement, and the date
line (`\CDossierLetterBlockSkip`, `0.50`) in the letter. One token therefore had
to clear whichever of those was largest in *any* class, so raising the
statement's section gap spent vertical space in the résumé and the CV, and the
letter carried a floor set by a section boundary it does not have.

All three ship at the `0.8125` ratio the single token carried, so the split
renders no document differently; only source that reads or sets the gap below a
header by name needs the edit. Replace `\CDossierHeaderBelowSkip` with the
token for the class being styled, and set all three when styling every class
from one shared preamble. Retuning any of them is tracked separately under
issue #206.

Note the intermediate name. Earlier in this same unreleased release the token
was renamed `\CDossierSharedHeaderBelowSkip`; that name is superseded here and
was never released, so `v0.6.0` source migrates straight from
`\CDossierHeaderBelowSkip` to the three tokens above.

### `careerdossier-tokens` no longer reads global `\documentclass` options

Before:

```latex
\documentclass[fontsize=10pt]{article}   % some non-CareerDossierTeX class
\usepackage{careerdossier-tokens}        % picked `fontsize' up from above
```

After:

```latex
\documentclass{article}
\usepackage[fontsize=10pt]{careerdossier-tokens}
```

Reason: `fontsize` and `margin` are public *class* options, owned and validated
by the four document classes, which forward the resolved value with
`\PassOptionsToPackage`. Reading the global option list as well made
`careerdossier-tokens` re-validate the raw class option on its own account, so a
rejected value was reported twice — the second time under a package name that
appears in no `\usepackage` line a class user writes (see
[`CHANGELOG.md`](../CHANGELOG.md), #232).

No CareerDossierTeX class or example is affected, because all four forward
explicitly; this applies only to a document that loads `careerdossier-tokens`
directly under some other class *and* sets `fontsize=` or `margin=` as an option
to that class. Passing the option to `\usepackage`, or with
`\PassOptionsToPackage`, works exactly as before, and an unsupported value is
still rejected with the accepted values named.

### Three class-to-package primitives made private

Three names carried the public `CDossier` / `MakeCDossier` prefix without being
part of the author-facing interface. Each is called once, by a document class,
in its own preamble, to apply something the shared package had already computed.
They now carry the private form `AGENTS.md` reserves for internal names:

| Before | After |
|---|---|
| `\CDossierApplyBodySize` | `\__cdossier_tokens_apply_body_size:` |
| `\CDossierApplyGeometry:n` | `\__cdossier_tokens_apply_geometry:n` |
| `\MakeCDossierPageFurniture` | `\__cdossier_components_apply_page_furniture:` |

**No document reflows and no supported document needs an edit.** None of the
three was ever documented in [`API.md`](API.md), and no example, fixture, or
class option calls them by the old name; the three renames are internal to the
package-to-class boundary. Source that called one of the old names now gets an
undefined-control-sequence error.

Calling the new names is possible but unsupported, and the spelling is stricter:
an expl3 private name only tokenises as one control sequence inside
`\ExplSyntaxOn`, because outside it the `_` is a subscript character. Written in
a plain preamble the name silently splits into `\_` plus ordinary text and the
command never runs — no error, just a document missing its page furniture or its
body size.

Reason: each name promised an author-facing command that does not exist.
`\CDossierApplyBodySize` and `\CDossierApplyGeometry:n` transport a resolved
load-time option — one held in a package-private variable — from
`careerdossier-tokens` into `\normalsize` and `geometry`; neither does anything
useful when called a second time, and `\CDossierApplyGeometry:n` was in addition
the only name in the codebase that mixed the public prefix with an expl3
argument signature, a form `AGENTS.md` reserves for private names.
`\MakeCDossierPageFurniture` shared the `Make…` prefix with
`\MakeCDossierHeader`, `\MakeCDossierLetterhead`, `\MakeCDossierClosing`, and
`\MakeCDossierStatementHeader` without sharing what makes them a family: each of
those emits document material where the author calls it, while this one emits
nothing at all — it selects a `\pagestyle` and queues an `\AtBeginDocument`
hook, so by the time a document body could call it the hook has already run.
All three sit beside private siblings that do the same job, such as
`\__cdossier_components_headerbelow:N`.

`v1.0.0` freezes the public interface, so a name that still carries a public
prefix then is supported whether or not it is documented. See
[#242](https://github.com/amirhs1/CareerDossierTeX/issues/242) for the
classification of the full public-prefixed name surface; the other fifteen names
it reviewed were confirmed public and keep their names.

## [0.6.0] - 2026-07-30

### `density=compact|standard` removed from `careerdossier-resume` and `careerdossier-cv`

Before:

\documentclass[fontsize=11pt,density=compact]{careerdossier-resume}

After:

\documentclass[fontsize=11pt,margin=narrow]{careerdossier-resume}

Reason: vertical rhythm is now derived entirely from `fontsize`; a separate
density axis would have permitted combinations such as 12pt-compact that
work against the calibrated proportional design. See
[Upgrading to `v0.6.0`](#upgrading-to-v060) above for the full set of layout
changes in this release.
