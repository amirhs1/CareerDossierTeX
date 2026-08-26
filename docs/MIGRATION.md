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

`v0.9.0` is the current published release. **It changes how letters and
statements render in one place:** the gap below the header stack no longer adds
`\parskip` on top of the token that names it, so the header-to-body gap tightens
by one `\parskip` — 3.625 pt at `fontsize=12pt` — once per document. No source
edit is required; the recipe below restores the previous gap. No public name is
added, renamed, or removed. `CDossierPublications` gains an optional `numbering`
key whose default is the shipped behaviour, so no existing document moves.
Résumé and CV are unaffected. See [`[0.9.0]`](#090---2026-08-26) below.

`v0.8.0` was the previous release. **It changes how every existing
document renders in one place:** an entry's dates and location, and a statement's
application-context line, were italic and are now upright black body text. No
source edit is required for that; `muted=italic` restores the previous
appearance in any of the four classes. Two public names change and need a source
edit only in a document that used them by name — `\CDossierSizeTitle` is renamed
to `\CDossierSizeDocumentTitle`, and `\CDossierPrimaryColor` is removed in favour
of the identical `\CDossierTextColor`. One further change is invisible in
ordinary use: `CDossierEntry` now reads its body as an argument, so
catcode-sensitive content such as `\verb` no longer works directly inside an
entry. See [`[0.8.0]`](#080---2026-08-12) below.

`v0.7.0` renames public design tokens, adds new ones beside them, **retires
three**, and retunes the calibrated vertical-rhythm ratios. Renamed tokens need a
source edit only if a document reads or sets them by name, and all three retired
tokens rendered nothing at the `v0.6.0` defaults — but three mechanism changes
do move the page: letter and statement headers tighten, the gap above a bullet
list inside an entry tightens,
and a document with no `headline` gains a little space below the name. **The
retune then reflows every document.** It also makes three undocumented
class-to-package primitives private, which changes no output and affects no
supported document. See [`[0.7.0]`](#070---2026-08-04) below. This release was
numbered `v0.6.1` until 2026-08-01.

`v0.6.0` **removes the `density` option and changes every class's layout
defaults** — see [Upgrading to `v0.6.0`](#upgrading-to-v060) below. A document
coming from `v0.5.x` or earlier needs that section as well as the `v0.7.0` and
`v0.8.0` ones.

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
for one-page capacity; see the manual for when to override it.

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
no PDF/UA, WCAG, or ATS conformance claim. See the manual for scope.

## [0.9.0] - 2026-08-26

### The gap below the header stack no longer adds `\parskip`

`v0.7.0` zeroed `\parskip` for the header block's own scope, so the gaps
*between* header lines render their token in all four classes — see
[Header spacing no longer floored by `\parskip`](#header-spacing-no-longer-floored-by-parskip)
below. The boundary *below* the stack was left out of that fix: it is emitted
after the block's scope ends, where `careerdossier-letter` and
`careerdossier-statement` have restored their document-wide `\parskip`, and the
first body paragraph then contributed that `\parskip` on top of the token.
`\CDossierProseHeaderBelowSkip` and `\CDossierLetterHeaderBelowSkip` therefore
named a gap narrower than the one a reader measured — by 3.00 pt at `10pt`,
3.40 pt at `11pt`, and 3.625 pt at `12pt`, or 27% of the token's value.

That boundary now routes through the same `token − \parskip` emission the
between-line boundaries already used, so all three header tokens name the
rendered gap in all four classes. No public command, class option, key, or token
value changes.

**Letters and statements reflow.** The header-to-body gap tightens by exactly
one `\parskip` — 3.625 pt at `fontsize=12pt` — once per document. Measured on
the shipped examples and on the size/margin matrix, no example and no
class × margin × size combination changes its page count, but a letter or
statement fits marginally more body text on page one. Résumé and CV are
unaffected, because `\CDossierRecordParSkip` is `0.00` and the subtraction was
already a no-op there.

To keep the previous letter or statement header-to-body gap, add the paragraph
gap back after `\documentclass`:

```latex
\makeatletter\ExplSyntaxOn
\skip_add:Nn \CDossierLetterHeaderBelowSkip { \CDossierLetterParSkip }
\ExplSyntaxOff\makeatother
```

Use `\CDossierProseHeaderBelowSkip` with `\CDossierProseParSkip` in
`careerdossier-statement`. Unlike the `v0.7.0` note above, the token may be read
here rather than written out, because no retune accompanies this change. Do not
apply it in the résumé or CV, whose gap never moved.

## [0.8.0] - 2026-08-12

Each entry states what changed and what to type; the reasoning behind it is in
[`CHANGELOG.md`](../CHANGELOG.md#080---2026-08-12) and the issue each entry
names.

### `CDossierEntry` reads its body as an argument

No source edit is required unless an entry body contains catcode-sensitive
content. Nothing renders differently, and no vertical token changed.

`CDossierEntry` now takes its body as a `+b` argument in both the résumé and the
CV class. The consequence is the usual one for an environment that grabs its
body: characters are tokenized when the body is read, so anything that depends
on rescanning them no longer works directly inside an entry.

Before, this typeset:

    \begin{CDossierEntry}[title = {Tooling}]
      Maintains \verb|make check| across the suite.
    \end{CDossierEntry}

After, define the fragment outside the entry and use it inside:

    \newcommand\makecheck{\texttt{make check}}
    \begin{CDossierEntry}[title = {Tooling}]
      Maintains \makecheck{} across the suite.
    \end{CDossierEntry}

This affects `\verb`, `listings` environments, and anything else built on
rescanning. Ordinary prose, `\texttt`, `\CDossierLink`, and `CDossierItemize`
are unaffected; no example or template in this repository used a form that
breaks.

Reading the body is what lets the environment test whether it is empty — an
entry with no body was emitting a keep-with-next penalty with nothing to bind
to, which made every following inter-entry boundary illegal to break at
([#332](https://github.com/amirhs1/CareerDossierTeX/issues/332)).

### `\CDossierSizeTitle` renamed to `\CDossierSizeDocumentTitle`

A source edit is required only in a document that reads or sets this token by
name. Nothing renders differently: the rename moves no value, and no other token
changes.

Before:

    \CDossierSizeTitle

After:

    \CDossierSizeDocumentTitle

`\CDossierEntryTitleStyle` is **not** renamed, and neither is any other size or
style token; `\CDossierSizeSection` was not a candidate either, being a distinct
1.12 step
([#269](https://github.com/amirhs1/CareerDossierTeX/issues/269)). The renamed
token keeps its 1.50 ratio and its 15 / 17, 16 / 18, and 18 / 20 pt values at
`fontsize=10pt`, `11pt`, and `12pt` — see the type scale in
[`ARCHITECTURE.md`](ARCHITECTURE.md#careerdossier-tokenssty).

Reason: `Title` meant two unrelated things in one vocabulary. This token is a
step of the type scale sizing a statement's document title;
`\CDossierEntryTitleStyle` is a semantic role for the heading of one job,
degree, or project. They sit at different levels and are never composed.

### `\CDossierPrimaryColor` removed

No source edit is required unless a document called `\CDossierPrimaryColor`
directly — no CareerDossierTeX component, class, or example ever did.

Before:

    {\CDossierPrimaryColor ...}

After:

    {\CDossierTextColor ...}

`\CDossierTextColor` is a drop-in replacement with no visual change: the
underlying `cdossier-primary` was `gray 0`, the same value as `cdossier-text`,
differing only in name
([#270](https://github.com/amirhs1/CareerDossierTeX/issues/270)).

### Entry metadata is no longer italic by default

**This changes rendered output in every existing document.** An entry's dates
and location in the résumé and CV, and the statement's application-context
line, were italic; they are now upright black body text. No source edit is
required, no command, option, or key is renamed, and the text layer and reading
order are unchanged — but a document that wants the previous appearance must now
ask for it:

Before:

    \documentclass{careerdossier-resume}

After:

    \documentclass[muted=italic]{careerdossier-resume}

The same one-word addition restores it in `careerdossier-cv`,
`careerdossier-letter`, and `careerdossier-statement`, which all default to
`muted=plain` as well.

Reason: `muted=plain` applies no de-emphasis at all, and is the only one of the
four values that cannot fail a contrast floor — italic at small sizes is harder
to read for low-vision and dyslexic readers, and a gray level is what disappears
on a fax or a 1-bit print. What it drops is a redundant signal: the dates are
still identified by position and content, and under `entrymeta=inline` by the
separator. See the manual's `muted` section.

### `\CDossierMutedStyle` is published by `careerdossier-components`

No source edit is required in any document that uses a CareerDossierTeX class.

Before, the role was defined by `careerdossier-typography` and was fixed at
`\rmfamily \itshape`. It is now defined by `careerdossier-components` and
resolved by the `muted=italic|gray|both|plain` class option, whose default is
`plain` — see the entry above for the rendered change that follows from it.

Every document class loads `careerdossier-components`, so `\CDossierMutedStyle`
is available in all of them as it always was. The one case that changes is a
document that loads the typography package on its own:

Before:

    \usepackage{careerdossier-typography}
    ... \CDossierMutedStyle ...

After:

    \usepackage{careerdossier-components}   % loads careerdossier-typography
    ... \CDossierMutedStyle ...

Reason: `muted=gray` and `muted=both` resolve the role to a colour, and
`careerdossier-typography` owns no colour — only `careerdossier-components` may
combine a typography shape role with a theme colour token. See
[`ARCHITECTURE.md`](ARCHITECTURE.md#careerdossier-componentssty).

## [0.7.0] - 2026-08-04

Each entry states what changed and what to type; the calibration reasoning is in
[`CHANGELOG.md`](../CHANGELOG.md#070---2026-08-04) and the issue each entry
names. Where an entry renames or splits a token, the new names carry the old
one's value, so nothing reflows and only source that names the token needs the
edit.

### The vertical-rhythm ratios are retuned

**Every document reflows.** No name changes and no source edit is required —
only the calibrated values move, seventeen of the twenty-five. The type scale,
the margin presets, and the page geometry do not move, and no supported class ×
`fontsize` × `margin` combination changes its page count. A document that
already overrode one of these tokens keeps its own value.

To restore the `v0.6.0` spacing, set the changed tokens back after
`\documentclass`. The names below are the `v0.7.0` ones; the rename table gives
what each was called in `v0.6.0`.

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

The remaining eight keep their `v0.6.0` ratio. A ratio is a multiple of the body
baseline — 12.0 pt at `10pt`, 13.6 pt at `11pt`, 14.5 pt at `12pt` — and the
resolved values are tabulated in
[`ARCHITECTURE.md`](ARCHITECTURE.md#vertical-rhythm).

Restoring the whole set is rarely what you want: several of these tokens could
not previously render the relation they named, so a full restore reinstates
those defects too.

### Three vertical-spacing tokens retired, two added

Every vertical boundary is now owned by exactly one token. Removed — **none of
them rendered anything at the released defaults**, each having lost its boundary
to a larger token or claimed one that does not exist
([#206](https://github.com/amirhs1/CareerDossierTeX/issues/206)):

| Removed | Use instead |
|---|---|
| `\CDossierRecordEntryBelowSkip` | `\CDossierRecordEntryAboveSkip` |
| `\CDossierLetterheadBelowSkip` | `\CDossierLetterHeaderBelowSkip` |
| `\CDossierHeaderAboveSkip`, renamed `\CDossierSharedHeaderAboveSkip` earlier in this release | nothing — the boundary does not exist |

A document that sets any of these names now gets an undefined-control-sequence
error: delete the setting, or move it to the replacement named above.

Added:

| Added | Boundary | Default |
|---|---|---|
| `\CDossierLetterRecipientLineGapSkip` | between two lines of the letter's recipient block | `0.00`, reproducing the plain `\baselineskip` of the bare `\\` it replaces |
| `\CDossierLetterBodyBelowSkip` | letter body → closing | `0.625` |

The letter body's closing edge previously borrowed `\CDossierLetterBlockSkip`,
which names the boundaries *between letterhead blocks*; a document that set that
token to change the space above its closing must now set
`\CDossierLetterBodyBelowSkip` instead.

Why one token per boundary is necessary is derived under
[“Boundary ownership” in `ARCHITECTURE.md`](ARCHITECTURE.md#boundary-ownership).

### Header spacing no longer floored by `\parskip`

No source edit is required. The header block now zeroes `\parskip` for its own
scope, so the letter's and statement's document-wide paragraph gap no longer
lands in every header boundary on top of the header token.

**Letters and statements reflow.** Each header boundary tightens by 0.50 of a
line — 7.25 pt at `fontsize=12pt`. No example changes page count. Résumé and CV
are unaffected: `\CDossierRecordParSkip` is already `0.00`.

To keep the previous letter or statement header spacing, add back what the old
`\parskip` floor contributed — 0.50 of a line — after `\documentclass`:

```latex
\makeatletter\ExplSyntaxOn
\skip_add:Nn \CDossierSharedHeaderNameGapSkip { 7.25pt }
\skip_add:Nn \CDossierSharedHeaderMetaGapSkip { 7.25pt }
\ExplSyntaxOff\makeatother
```

That figure is for `fontsize=12pt`; use `6.8pt` at `11pt` and `6pt` at `10pt`.
Write it out rather than reading `\CDossierProseParSkip`, which the retune above
halves. Do not apply it in the résumé or CV.

### `\CDossierRecordEntryGapSkip` became a floor rather than added space

No source edit is required. The entry heading → body gap is now contributed with
`\addvspace`, so the gap above a bullet list was `\CDossierRecordEntryGapSkip`
**plus** `\CDossierRecordListEdgeAboveSkip` and is now the larger of the two.

**Résumés and CVs reflow slightly.** That gap tightens by
`\CDossierRecordEntryGapSkip` — 0.85 pt at `fontsize=11pt`, 0.91 pt at `12pt`.
An entry whose body is ordinary prose is unchanged, and no example changes page
count. Why a `\vspace` made the two add is under
[“Boundary ownership” in `ARCHITECTURE.md`](ARCHITECTURE.md#boundary-ownership).

### The gap below the name no longer depends on `headline`

No source edit is required. Position now decides which token guards a boundary,
not presence: the gap below the name is always
`\CDossierSharedHeaderNameGapSkip`.

**A résumé, CV, or letter with no `headline` reflows.** That boundary previously
fell through to `\CDossierSharedHeaderMetaGapSkip` (0.1875), so it gains
`0.0625` of a line — 0.85 pt at `fontsize=11pt`. Setting `headline` is
unaffected.

### Vertical-spacing design tokens renamed onto one convention

Every public vertical-spacing token now has the shape
`\CDossier<Family><Scope><Position>Skip`, whose families and members are
tabulated under "Design tokens" in the PDF manual,
[`../doc/careerdossier.tex`](../doc/careerdossier.tex). Seventeen of the
twenty-two tokens released in `v0.6.0` are renamed; **no value changes**.

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
`\CDossierProseParSkip` keeps its name but no longer sets `\parskip` in
`careerdossier-letter`, and `\CDossierLetterBlockSkip` keeps its name but no
longer serves the letter body's closing edge — see the splits below.

### `\CDossierListEdgeSkip` split into two tokens

Before:

\CDossierListEdgeSkip

After:

\CDossierRecordListEdgeAboveSkip   % the gap above a list
\CDossierRecordListEdgeBelowSkip   % the gap below a list

Read `\CDossierRecordListEdgeAboveSkip` wherever the old name appeared, and set
both when overriding the list edge as a whole. One token could not give the two
ends different values, because LaTeX spends a single `topsep` at both.

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
That floor is what the letter needed its own token to escape, and is derived
under [“Vertical rhythm” in `ARCHITECTURE.md`](ARCHITECTURE.md#vertical-rhythm).

### `\CDossierHeaderBelowSkip` split into one token per family

Before:

\CDossierHeaderBelowSkip   % v0.6.0: the gap below the header block in all
                           % four classes

After:

\CDossierRecordHeaderBelowSkip   % careerdossier-resume, careerdossier-cv
\CDossierProseHeaderBelowSkip    % careerdossier-statement
\CDossierLetterHeaderBelowSkip   % careerdossier-letter

Replace `\CDossierHeaderBelowSkip` with the token for the class being styled,
and set all three when styling every class from one shared preamble; their
retuned ratios are in the table above. Earlier in this same
release the token was renamed `\CDossierSharedHeaderBelowSkip`, which is
superseded here and was never released, so `v0.6.0` source migrates straight to
the three tokens above. Why the gap *below* the header is per-family while the
gaps inside it are shared is under
[“Boundary ownership” in `ARCHITECTURE.md`](ARCHITECTURE.md#boundary-ownership).

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

No CareerDossierTeX class or example is affected, because all four forward
`fontsize` and `margin` explicitly. This applies only to a document that loads
`careerdossier-tokens` directly under some other class *and* passes `fontsize=`
or `margin=` to that class; `\usepackage` and `\PassOptionsToPackage` work as
before. Why reading the global list reported a rejected value twice is in
[`CHANGELOG.md`](../CHANGELOG.md#070---2026-08-04), #232.

### Three class-to-package primitives made private

Three names carried a public prefix without being part of the author-facing
interface. They now carry the private form reserved for internal names:

| Before | After |
|---|---|
| `\CDossierApplyBodySize` | `\__cdossier_tokens_apply_body_size:` |
| `\CDossierApplyGeometry:n` | `\__cdossier_tokens_apply_geometry:n` |
| `\MakeCDossierPageFurniture` | `\__cdossier_components_apply_page_furniture:` |

**No document reflows and no supported document needs an edit.** None of the
three was documented in the interface reference, and no example, fixture, or
class option calls them by the old name. Source that called an old name now gets
an undefined-control-sequence error.

Calling the new names is possible but unsupported, and the spelling is stricter:
an expl3 private name tokenises as one control sequence only inside
`\ExplSyntaxOn`. In a plain preamble it silently splits into `\_` plus ordinary
text and never runs — no error, just a document missing its page furniture.

Why each old name promised a command that does not exist is in
[`CHANGELOG.md`](../CHANGELOG.md#070---2026-08-04);
[#242](https://github.com/amirhs1/CareerDossierTeX/issues/242) carries the
classification of the whole public-prefixed name surface, whose other fifteen
names were confirmed public and keep their names.

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
