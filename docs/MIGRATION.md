# Migration Notes

For people with documents built on an earlier release: what changed between
versions, which changes need a source edit, and which only change how a document
renders. Read it before upgrading. It records the *differences* — the current
interface itself is in the PDF manual,
[`../doc/careerdossier.tex`](../doc/careerdossier.tex).

Adding an entry rather than reading one?
[`CONTRIBUTING.md`](../CONTRIBUTING.md#update-migrationmd-when) states when an
entry is required and the shape it takes; the stability policy it serves is in
[`API.md`](API.md#stability-policy).

## Status

`v0.10.0` is the current published release. Each line says whether a release
needs a source edit and whether documents reflow; its section has the detail
and the recipes. A document coming from `v0.5.x` or earlier needs every section
from `v0.6.0` up.

- [`v0.10.0`](#0100---2026-11-06): no source edit. A resume's PDF `/Title` and
  running page label read `Resume`. An entry of three or fewer bullets can now
  break across a page, so a document in which such an entry moved whole to the
  next page paginates differently.
- [`v0.9.0`](#090---2026-08-26): no source edit. Letters and statements reflow
  slightly: the header-to-body gap tightens by one `\parskip`.
- [`v0.8.0`](#080---2026-08-12): a source edit only where a document names
  `\CDossierSizeTitle` or `\CDossierPrimaryColor`, or puts `\verb` inside an
  entry. Every document renders differently: entry metadata is no longer
  italic.
- [`v0.7.0`](#070---2026-08-04): a source edit only where a document names a
  renamed, split, retired, or now-private token. Every document reflows. This
  release was numbered `v0.6.1` until 2026-08-01.
- [`v0.6.0`](#upgrading-to-v060): a source edit where a document passes
  `density`. Every document reflows.
- `v0.5.0`: no source edit and no reflow; everything it added is opt-in.
- [`v0.4.0`](#upgrading-to-v040-xelatex--lualatex): the engine changes from
  XeLaTeX to LuaLaTeX, so the build command changes. The academic CV's and
  letter's page furniture render differently, with no source edit.

## Upgrading to `v0.6.0`

`v0.6.0` adds `fontsize=12pt` and
`margin=normal|narrow` consistently across all four document classes. The
resume now defaults to `fontsize=11pt,margin=narrow`; the CV, letter, and
statement classes default to `fontsize=12pt,margin=normal`. `normal` is one
inch and `narrow` is half an inch.

**Every existing document reflows.** This is not a caveat about unusual
documents: type sizes, every structural gap, the section rule, and the list
metrics are all newly derived from `fontsize`, and every class's default body
size or margin has changed. A document that took two pages may now take three,
or one. No source edit is required unless you pass `density`, but do not ship
an upgraded document without looking at it.

The measured characters per line for every combination are tabulated in
[`ARCHITECTURE.md`](ARCHITECTURE.md#careerdossier-tokenssty), and the manual
says when to override the resume's deliberately long one.

On US Letter paper, `margin=narrow` increases the physical text block from the
v0.5.0 resume's 72.27 in² to 75.00 in² (about 3.8%) and provides about 28.2%
more printable area than `margin=normal`. After accounting for the change from
10pt/12pt body size and leading to 11pt/13.6pt, estimated line-and-page capacity
is about 16.8% lower than v0.5.0, compared with about 35.1% lower for
`fontsize=11pt,margin=normal`.

The resume and CV no longer accept `density=compact|standard`; their vertical
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
retired: the CV and resume now share proportional rhythm, while the CV remains
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
previous run. The resume and CV page-break policy also records list lengths
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
XeTeX-specific preamble code needs no edit beyond the build command. The one
exception to "page design is unchanged" is step 5.

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

Why the engine changed: [#75](https://github.com/amirhs1/CareerDossierTeX/issues/75) and
[#76](https://github.com/amirhs1/CareerDossierTeX/issues/76).

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
by a line in long documents. Review multi-page CVs and two-page resumes after
upgrading rather than assuming identical pagination.

### 5. Review the academic CV and letter page furniture

`v0.4.0` changes the running headers and folios of two documents so that a CV
and an academic cover letter sent together look like one set. **No source edit
is required**; only rendered output changes.

Affects `careerdossier-cv` and `careerdossier-letter` with `family=academic`.
The industry letter and the resume are **unaffected**: the industry letter keeps
its `v0.1` empty page style, and the resume still prints no folio.

| | Before (`v0.2.x`) | After (`v0.4.0`) |
| --- | --- | --- |
| CV folio | `Page 2` | `Page 2 of 2` |
| CV running header (page 2+) | `Name — Curriculum Vitae` | unchanged |
| Academic letter running header | *none* | `Name — Cover Letter` from page 2 |
| Academic letter folio | `Name` at left, `Page 2 of 2` at right | centered `Page 2 of 2` |

The reasons are in [#91](https://github.com/amirhs1/CareerDossierTeX/issues/91) and
[#98](https://github.com/amirhs1/CareerDossierTeX/issues/98).

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
no PDF/UA, WCAG, or ATS conformance claim. See the manual for scope.

## [Unreleased]

### `medium` defaults to `screen`

**This changes rendered output in every document that passes no `medium`
option.** It now renders as `medium=screen`: no page carries the `Page N of M`
folio or the running header, and the anchor text of a link written with `\href`
is underlined ([#327](https://github.com/amirhs1/CareerDossierTeX/issues/327)).
No source edit is required, and nothing reflows, because `medium` never moves
the text block. A document meant to be printed restores the previous output
with one option:

Before:

    \documentclass{careerdossier-resume}

After:

    \documentclass[medium=print]{careerdossier-resume}

The same one-word addition restores it in `careerdossier-cv`,
`careerdossier-letter`, and `careerdossier-statement`, and a document that loads
`careerdossier-components` without a class passes the same option to the
package.

Reason: documents are sent as PDFs now, so reading on screen is the common case
and is what an author gets without asking.

## [0.10.0] - 2026-11-06

### The resume `/Title` and running page label are spelled `Resume`

`careerdossier-resume` spelled the document type in its PDF `/Title` and in the
running page label with an acute accent on both vowels. Both strings are now
`Resume`, in ASCII
([#543](https://github.com/amirhs1/CareerDossierTeX/issues/543)).

**No source edit is required, and nothing reflows.** No example and no
class × margin × size combination changes its page count. Only the resume class
is affected.

Tooling that matches the PDF `/Title` by string should now expect `Resume`. A
`/Title` set explicitly by the document still wins, so a document that needs the
previous spelling can ask for it:

```latex
\hypersetup{ pdftitle = {R\'esum\'e -- Ada Lovelace} }
```

The running page label has no public interface and cannot be overridden the same
way. If you need it, say so on
[#543](https://github.com/amirhs1/CareerDossierTeX/issues/543) and it can be
published as a key.

## [0.9.0] - 2026-08-26

### The gap below the header stack no longer adds `\parskip`

In `careerdossier-letter` and `careerdossier-statement`, the first body
paragraph added the document-wide `\parskip` on top of the token below the
header stack. That boundary now subtracts `\parskip` as the boundaries between
header lines already did — see
[Header spacing no longer floored by `\parskip`](#header-spacing-no-longer-floored-by-parskip)
below — so `\CDossierProseHeaderBelowSkip` and `\CDossierLetterHeaderBelowSkip`
name the rendered gap. No public command, class option, key, or token value
changes ([#419](https://github.com/amirhs1/CareerDossierTeX/issues/419)).

**Letters and statements reflow.** The header-to-body gap tightens by exactly
one `\parskip` — 3.00 pt at `10pt`, 3.40 pt at `11pt`, 3.625 pt at `12pt` — once
per document. No example and no class × margin × size combination changes its
page count. Resume and CV are unaffected, because `\CDossierRecordParSkip` is
`0.00`.

To keep the previous letter or statement header-to-body gap, add the paragraph
gap back after `\documentclass`:

```latex
\makeatletter\ExplSyntaxOn
\skip_add:Nn \CDossierLetterHeaderBelowSkip { \CDossierLetterParSkip }
\ExplSyntaxOff\makeatother
```

Use `\CDossierProseHeaderBelowSkip` with `\CDossierProseParSkip` in
`careerdossier-statement`. Do not apply it in the resume or CV, whose gap never
moved.

## [0.8.0] - 2026-08-12

Each entry states what changed and what to type; the reasoning behind it is in
[`CHANGELOG.md`](../CHANGELOG.md#080---2026-08-12) and the issue each entry
names.

### `CDossierEntry` reads its body as an argument

No source edit is required unless an entry body contains catcode-sensitive
content, such as `\verb` or a `listings` environment. Nothing renders
differently. `CDossierEntry` now reads its body as a `+b` argument in the resume
and the CV, so anything that rescans its characters no longer works directly
inside an entry ([#332](https://github.com/amirhs1/CareerDossierTeX/issues/332)).

Before, this typeset:

    \begin{CDossierEntry}[title = {Tooling}]
      Maintains \verb|make check| across the suite.
    \end{CDossierEntry}

After, define the fragment outside the entry and use it inside:

    \newcommand\makecheck{\texttt{make check}}
    \begin{CDossierEntry}[title = {Tooling}]
      Maintains \makecheck{} across the suite.
    \end{CDossierEntry}

Ordinary prose, `\texttt`, `\CDossierLink`, and `CDossierItemize` are
unaffected.

### `\CDossierSizeTitle` renamed to `\CDossierSizeDocumentTitle`

A source edit is required only in a document that reads or sets this token by
name. The rename moves no value — see the type scale in
[`ARCHITECTURE.md`](ARCHITECTURE.md#careerdossier-tokenssty) — and
`\CDossierEntryTitleStyle` and every other size or style token keep their names
([#269](https://github.com/amirhs1/CareerDossierTeX/issues/269)).

Before:

    \CDossierSizeTitle

After:

    \CDossierSizeDocumentTitle

### `\CDossierPrimaryColor` removed

No source edit is required unless a document called `\CDossierPrimaryColor`
directly — no CareerDossierTeX component, class, or example ever did.
`\CDossierTextColor` replaces it with no visual change: both were `gray 0`
([#270](https://github.com/amirhs1/CareerDossierTeX/issues/270)).

Before:

    {\CDossierPrimaryColor ...}

After:

    {\CDossierTextColor ...}

### Entry metadata is no longer italic by default

**This changes rendered output in every existing document.** An entry's dates
and location in the resume and CV, and the statement's application-context
line, were italic; they are now upright black body text. No source edit is
required, and the text layer and reading order are unchanged, but a document
that wants the previous appearance must now ask for it:

Before:

    \documentclass{careerdossier-resume}

After:

    \documentclass[muted=italic]{careerdossier-resume}

The same one-word addition restores it in `careerdossier-cv`,
`careerdossier-letter`, and `careerdossier-statement`. Why `plain` is the
default is in the manual's `muted` section and
[#324](https://github.com/amirhs1/CareerDossierTeX/issues/324).

### `\CDossierMutedStyle` is published by `careerdossier-components`

No source edit is required in any document that uses a CareerDossierTeX class:
every class loads `careerdossier-components`, which now defines the role that
`careerdossier-typography` used to fix at `\rmfamily \itshape`. Only a document
that loads the typography package on its own changes:

Before:

    \usepackage{careerdossier-typography}
    ... \CDossierMutedStyle ...

After:

    \usepackage{careerdossier-components}   % loads careerdossier-typography
    ... \CDossierMutedStyle ...

Why the role moved is in
[`ARCHITECTURE.md`](ARCHITECTURE.md#careerdossier-componentssty).

## [0.7.0] - 2026-08-04

Each entry states what changed and what to type; the calibration reasoning is in
[`CHANGELOG.md`](../CHANGELOG.md#070---2026-08-04) and the issue each entry
names.

### The vertical-rhythm ratios are retuned

**Every document reflows.** No source edit is required: seventeen of the
twenty-five calibrated ratios move, and no supported class × `fontsize` ×
`margin` combination changes its page count. A document that already overrode
one of these tokens keeps its own value.

To restore the `v0.6.0` spacing, set the changed tokens back after
`\documentclass`; the rename table below maps these `v0.7.0` names to their
`v0.6.0` ones.

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

The resolved values are in
[`ARCHITECTURE.md`](ARCHITECTURE.md#vertical-rhythm). A full restore also
restores defects that several of these tokens had.

### Three vertical-spacing tokens retired, two added

Removed — **none of them rendered anything at the released defaults**
([#206](https://github.com/amirhs1/CareerDossierTeX/issues/206)):

| Removed | Use instead |
|---|---|
| `\CDossierRecordEntryBelowSkip` | `\CDossierRecordEntryAboveSkip` |
| `\CDossierLetterheadBelowSkip` | `\CDossierLetterHeaderBelowSkip` |
| `\CDossierHeaderAboveSkip`, renamed `\CDossierSharedHeaderAboveSkip` earlier in this release | nothing — the boundary does not exist |

Setting one of these names is now an undefined-control-sequence error: delete
the setting, or move it to its replacement.

Added:

| Added | Boundary | Default |
|---|---|---|
| `\CDossierLetterRecipientLineGapSkip` | between two lines of the letter's recipient block | `0.00`, reproducing the plain `\baselineskip` of the bare `\\` it replaces |
| `\CDossierLetterBodyBelowSkip` | letter body → closing | `0.625` |

A document that set `\CDossierLetterBlockSkip` to change the space above its
closing must now set `\CDossierLetterBodyBelowSkip` instead.

### Header spacing no longer floored by `\parskip`

No source edit is required. The header block now zeroes `\parskip` for its own
scope, so the paragraph gap no longer lands in every header boundary.

**Letters and statements reflow.** Each header boundary tightens by 0.50 of a
line — 7.25 pt at `fontsize=12pt`. No example changes page count. Resume and CV
are unaffected.

To keep the previous spacing, add the 0.50 of a line back after
`\documentclass`:

```latex
\makeatletter\ExplSyntaxOn
\skip_add:Nn \CDossierSharedHeaderNameGapSkip { 7.25pt }
\skip_add:Nn \CDossierSharedHeaderMetaGapSkip { 7.25pt }
\ExplSyntaxOff\makeatother
```

That figure is for `fontsize=12pt`; use `6.8pt` at `11pt` and `6pt` at `10pt`.
Write it out rather than reading `\CDossierProseParSkip`, which the retune above
halves. Do not apply it in the resume or CV.

### `\CDossierRecordEntryGapSkip` became a floor rather than added space

No source edit is required. The gap above a bullet list inside an entry was
`\CDossierRecordEntryGapSkip` **plus** `\CDossierRecordListEdgeAboveSkip`, and
is now the larger of the two
([#204](https://github.com/amirhs1/CareerDossierTeX/issues/204)).

**Resumes and CVs reflow slightly.** That gap tightens by
`\CDossierRecordEntryGapSkip` — 0.85 pt at `fontsize=11pt`, 0.91 pt at `12pt`.
An entry whose body is prose is unchanged; no example changes page count.

### The gap below the name no longer depends on `headline`

No source edit is required. The gap below the name is always
`\CDossierSharedHeaderNameGapSkip`.

**A resume, CV, or letter with no `headline` reflows.** That gap gains `0.0625`
of a line — 0.85 pt at `fontsize=11pt`. Setting `headline` is unaffected.

### Vertical-spacing design tokens renamed onto one convention

Every public vertical-spacing token now has the shape
`\CDossier<Family><Scope><Position>Skip`, tabulated under "Design tokens" in the
PDF manual. Seventeen of the twenty-two `v0.6.0` tokens are renamed; **no value
changes**.

| `v0.6.0` | `v0.7.0` |
|---|---|
| `\CDossierHeaderAboveSkip` | `\CDossierSharedHeaderAboveSkip`, then **retired**; see above |
| `\CDossierHeaderNameGapSkip` | `\CDossierSharedHeaderNameGapSkip` |
| `\CDossierHeaderMetaGapSkip` | `\CDossierSharedHeaderMetaGapSkip` |
| `\CDossierHeaderBelowSkip` | split three ways; see below |
| `\CDossierSectionAboveSkip` | `\CDossierRecordSectionAboveSkip` |
| `\CDossierSectionRuleSkip` | `\CDossierRecordSectionRuleGapSkip` |
| `\CDossierSectionBelowSkip` | `\CDossierRecordSectionBelowSkip` |
| `\CDossierEntryAboveSkip` | `\CDossierRecordEntryAboveSkip` |
| `\CDossierEntryGapSkip` | `\CDossierRecordEntryGapSkip` |
| `\CDossierEntryBelowSkip` | `\CDossierRecordEntryBelowSkip`, then **retired**; see above |
| `\CDossierListEdgeSkip` | split in two; see below |
| `\CDossierItemSepSkip` | `\CDossierRecordItemSepSkip` |
| `\CDossierParSkip` | `\CDossierRecordParSkip` |
| `\CDossierAfterHeaderBlockSkip` | `\CDossierLetterheadBelowSkip`, then **retired**; see above |
| `\CDossierBlockSkip` | `\CDossierLetterBlockSkip` |
| `\CDossierAfterSalutationSkip` | `\CDossierLetterBodyAboveSkip` |
| `\CDossierSignatureSkip` | `\CDossierLetterSignatureGapSkip` |

The four prose section and subsection tokens keep their names. So do
`\CDossierProseParSkip`, which no longer sets the letter's `\parskip`, and
`\CDossierLetterBlockSkip`, which no longer serves the letter body's closing.

### `\CDossierListEdgeSkip` split into two tokens

Before:

\CDossierListEdgeSkip

After:

\CDossierRecordListEdgeAboveSkip   % the gap above a list
\CDossierRecordListEdgeBelowSkip   % the gap below a list

Read `\CDossierRecordListEdgeAboveSkip` wherever the old name appeared, and set
both when overriding the list edge as a whole.

### `\CDossierProseParSkip` split for `careerdossier-letter`

Before:

\CDossierProseParSkip   % set \parskip in both careerdossier-letter and
                        % careerdossier-statement

After:

\CDossierLetterParSkip  % sets \parskip in careerdossier-letter
\CDossierProseParSkip   % unchanged: sets \parskip in careerdossier-statement

**If you override `\CDossierProseParSkip`,** keep every statement heading
below-token strictly greater than the value you set: a statement heading whose
after-skip reaches zero silently becomes a run-in heading rather than erroring.

### `\CDossierHeaderBelowSkip` split into one token per family

Before:

\CDossierHeaderBelowSkip   % v0.6.0: the gap below the header block in all
                           % four classes

After:

\CDossierRecordHeaderBelowSkip   % careerdossier-resume, careerdossier-cv
\CDossierProseHeaderBelowSkip    % careerdossier-statement
\CDossierLetterHeaderBelowSkip   % careerdossier-letter

Replace `\CDossierHeaderBelowSkip` with the token for the class being styled,
and set all three when styling every class from one shared preamble.

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

This affects only a document that loads `careerdossier-tokens` directly under
some other class *and* passes `fontsize=` or `margin=` to that class; no
CareerDossierTeX class or example does
([#232](https://github.com/amirhs1/CareerDossierTeX/issues/232)).

### Three class-to-package primitives made private

Three public-prefixed names that were never part of the author-facing
interface are now private:

| Before | After |
|---|---|
| `\CDossierApplyBodySize` | `\__cdossier_tokens_apply_body_size:` |
| `\CDossierApplyGeometry:n` | `\__cdossier_tokens_apply_geometry:n` |
| `\MakeCDossierPageFurniture` | `\__cdossier_components_apply_page_furniture:` |

**No document reflows and no supported document needs an edit.** Source that
called an old name now gets an undefined-control-sequence error. Calling the
new names is unsupported: outside `\ExplSyntaxOn` a private name splits into
`\_` plus ordinary text and never runs, with no error
([#242](https://github.com/amirhs1/CareerDossierTeX/issues/242)).

## [0.6.0] - 2026-07-30

### `density=compact|standard` removed from `careerdossier-resume` and `careerdossier-cv`

Remove the option and choose the size and margin directly: the before-and-after
for both classes, and the release's other layout changes, are in
[Upgrading to `v0.6.0`](#upgrading-to-v060) above.
