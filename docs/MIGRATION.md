# Migration Notes

## Status

`v0.6.0` is the current published release. It **removes the `density` option
and changes every class's layout defaults** — see
[Upgrading to `v0.6.0`](#upgrading-to-v060) below.

The unreleased `v0.7.0` renames public design tokens, adds new ones beside
them, and retunes the calibrated vertical-rhythm ratios. Renamed tokens need a
source edit only if a document reads or sets them by name; the retune reflows
every document — see [`[0.7.0]`](#070---unreleased) below. This release was
numbered `v0.6.1` until 2026-08-01.

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

The measure changes too. Counting characters including spaces on full lines of
running prose in TeX Gyre Termes on US Letter:

| Class | `v0.6.0` default | Characters per line |
|---|---|---|
| résumé | `11pt`, `narrow` | 118–127 |
| CV | `12pt`, `normal` | 93–101 |
| letter | `12pt`, `normal` | 93–101 |
| statement | `12pt`, `normal` | 93–101 |

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

Tagged output is a tested preview for the four fixture profiles only and carries
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

## [0.7.0] - unreleased

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
| `\CDossierHeaderAboveSkip` | `\CDossierSharedHeaderAboveSkip` |
| `\CDossierHeaderNameGapSkip` | `\CDossierSharedHeaderNameGapSkip` |
| `\CDossierHeaderMetaGapSkip` | `\CDossierSharedHeaderMetaGapSkip` |
| `\CDossierHeaderBelowSkip` | `\CDossierSharedHeaderBelowSkip` |
| `\CDossierSectionAboveSkip` | `\CDossierRecordSectionAboveSkip` |
| `\CDossierSectionRuleSkip` | `\CDossierRecordSectionRuleGapSkip` |
| `\CDossierSectionBelowSkip` | `\CDossierRecordSectionBelowSkip` |
| `\CDossierEntryAboveSkip` | `\CDossierRecordEntryAboveSkip` |
| `\CDossierEntryGapSkip` | `\CDossierRecordEntryGapSkip` |
| `\CDossierEntryBelowSkip` | `\CDossierRecordEntryBelowSkip` |
| `\CDossierListEdgeSkip` | `\CDossierRecordListEdgeAboveSkip` **and** `\CDossierRecordListEdgeBelowSkip` (split — see below) |
| `\CDossierItemSepSkip` | `\CDossierRecordItemSepSkip` |
| `\CDossierParSkip` | `\CDossierRecordParSkip` |
| `\CDossierAfterHeaderBlockSkip` | `\CDossierLetterheadBelowSkip` |
| `\CDossierBlockSkip` | `\CDossierLetterBlockSkip` |
| `\CDossierAfterSalutationSkip` | `\CDossierLetterBodyAboveSkip` |
| `\CDossierSignatureSkip` | `\CDossierLetterSignatureGapSkip` |

Unchanged: `\CDossierProseSectionAboveSkip`, `\CDossierProseSectionBelowSkip`,
`\CDossierProseSubsectionAboveSkip`, `\CDossierProseSubsectionBelowSkip`, and
`\CDossierProseParSkip`.

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

This is a rename only. Every token keeps its calibrated ratio, all eleven
supported examples render with identical word coordinates before and after,
and no class, option, key, command, or environment changed.

`\CDossierLetterBlockSkip` is expected to be superseded: it currently serves
four distinct letter boundaries, and splitting it into one token per boundary
is tracked separately as
[#204](https://github.com/amirhs1/CareerDossierTeX/issues/204).

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
