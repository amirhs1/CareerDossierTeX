# CareerDossierTeX Architecture

## Purpose

CareerDossierTeX is a modular LuaLaTeX toolkit for producing related career documents from shared profile data.

The architecture separates:

- user metadata;
- document content;
- reusable components;
- calibrated layout tokens;
- typography;
- visual theme;
- language labels;
- document-specific page layout;
- build and test automation.

This separation allows the résumé and cover letter to share identity and contact behavior without forcing them to share the same geometry or content model.

## Architectural goals

1. Keep the public API small and explicit.
2. Separate content from presentation.
3. Reuse profile metadata across document types.
4. Make optional fields safe and predictable.
5. Keep document classes focused on page-level behavior.
6. Use semantic typography and theme roles.
7. Leave extension points for academic and multilingual releases.
8. Reject unsupported configurations rather than silently ignoring them.
9. Keep source order logical for text selection and extraction.
10. Make supported examples reproducible locally and in CI.

## Phase 1 module graph

```text
careerdossier-resume.cls
        │
        ├── careerdossier-tokens.sty
        ├── careerdossier-components.sty
        ├── careerdossier-typography.sty
        ├── careerdossier-theme.sty
        └── careerdossier-base.sty

careerdossier-letter.cls
        │
        ├── careerdossier-tokens.sty
        ├── careerdossier-components.sty
        ├── careerdossier-typography.sty
        ├── careerdossier-theme.sty
        └── careerdossier-base.sty
```

The exact package-loading order may differ when implementation requires it, but dependency direction should remain one-way. Shared packages must not depend on the résumé or letter classes.

## Phase 2 module graph

The academic CV class, optional bibliography integration, and academic letter
family were released in `v0.2.0`. These additions do not
change the Phase 1 dependency direction:

```text
careerdossier-cv.cls
        │
        ├── careerdossier-tokens.sty
        ├── careerdossier-components.sty
        ├── careerdossier-typography.sty
        ├── careerdossier-theme.sty
        └── careerdossier-base.sty

careerdossier-biblatex.sty  ──optional──▶  biblatex / Biber
        │
        ├── semantic typography and theme roles
        └── shared list tokens when the host class provides them

careerdossier-letter.cls
        └── family=industry|academic
```

`careerdossier-cv.cls` must not load `careerdossier-biblatex.sty` or `biblatex`.
That separation is the architectural enforcement for the supported no-BibLaTeX
CV path. The integration package may be loaded by a CV document, but neither it
nor the external bibliography toolchain becomes a dependency of the shared
profile or the other document classes.

## `v0.5.0` statement module graph

One statement class defaults to `interest` and implements six other explicit
type values approved in issue #103:

```text
careerdossier-statement.cls
        │
        ├── careerdossier-tokens.sty
        ├── careerdossier-components.sty
        ├── careerdossier-typography.sty
        ├── careerdossier-theme.sty
        └── careerdossier-base.sty

careerdossier-statement.cls
        └── type=interest|research|teaching|teaching-philosophy|diversity|artist|purpose
```

All statement types share geometry and a prose document model. The default
interest type has no extra required-field contract; another explicit type
changes the default title, continuation-page identification, displayed contact
set, and, where applicable, required fields. This does not justify duplicate
classes or hard-coded narrative schemas. Shared packages remain independent of
the new class.

## Data flow

```text
profile file
    │
    ▼
\CDossierSetup
    │
    ▼
careerdossier-base.sty
    │
    ├── validation
    ├── field lookup
    └── presence tests
            │
            ▼
careerdossier-components.sty
    │
    ├── identity block
    ├── contact line
    ├── links
    └── entry primitives
            │
            ▼
document class
    │
    ├── résumé geometry and spacing
    └── letter geometry and prose flow
            │
            ▼
PDF output
```

Letter-specific metadata follows the same pattern:

```text
\CDossierLetterSetup
    │
    ▼
letter metadata storage
    │
    ▼
recipient block, subject, salutation, closing
    │
    ▼
careerdossier-letter.cls
```

## File responsibilities

### `careerdossier-tokens.sty`

Owns the shared, calibrated design scale.

Responsibilities:

- resolve `fontsize=10pt|11pt|12pt` into the body size and complete type scale;
- derive structural vertical rhythm from the body baseline;
- own rule thickness and flush-left list metrics;
- resolve `margin=normal|narrow` to one-inch or half-inch margins; and
- provide the only shared body-size and `geometry` application primitives.

It must not own colours, font files, semantic typography roles, rendered
components, document metadata, or paper selection. The document classes choose
their defaults and paper size, then pass those inputs into this package.

#### Ownership boundary

Three packages are easy to confuse because all three are described as owning
"tokens". They are separated by the question each one answers:

| Package | Answers | Owns | Does not own |
|---|---|---|---|
| `careerdossier-tokens` | *How big, and how far apart?* | body size, type scale, vertical rhythm, rule thickness, list metrics, margin presets | any colour, any font file, any named text role |
| `careerdossier-typography` | *In which typeface and role?* | engine guard, font loading, semantic roles such as section and muted text | the point sizes and gaps those roles are set at |
| `careerdossier-theme` | *In which colour?* | semantic monochrome colour, rule colour, link colour | every dimension |

A semantic role therefore asks `careerdossier-tokens` for its size and asks
`careerdossier-theme` for its colour; neither of those packages knows the role
exists.

#### Dependency direction

`careerdossier-tokens` sits at the bottom of the project's own graph. It
requires only `l3keys2e` and `geometry` and loads no other CareerDossierTeX
module, so nothing it owns can depend on fonts, colour, validation, or rendered
output. `careerdossier-components` and all four document classes require it.
The direction is one-way: the tokens package never learns which class loaded
it.

The one-way direction extends to how options arrive. Like
`careerdossier-typography` and `careerdossier-components`, this package uses
`\ProcessKeysPackageOptions`, which reads local package options only and never
the global `\documentclass` list. `fontsize` and `margin` are public *class*
options: each class validates its own value and forwards the resolved one with
`\PassOptionsToPackage`, so a value reaches this package only after the class
that owns the public surface has accepted it. Reading the global list here
would make this package re-validate the raw class option on its own account and
report a rejected value a second time, under a package name that appears in no
`\usepackage` line the class user wrote (#232). A direct `\usepackage` user
still gets the full validation contract through the package's own option list.

#### Type scale

The ratio column is design intent and does not ship; the point columns ship.
Each value is the type size over its leading. Every size is snapped to a whole
number of points, so `10pt`, `11pt`, and `12pt` are one design at three scales
rather than three separately tuned designs.

| Role | Selector | Ratio | `10pt` | `11pt` | `12pt` |
|---|---|---:|---:|---:|---:|
| Name | `\CDossierSizeName` | 1.90 | 19 / 21 | 21 / 23 | 23 / 25 |
| Statement title | `\CDossierSizeTitle` | 1.50 | 15 / 17 | 16 / 18 | 18 / 20 |
| Headline, subtitle | `\CDossierSizeHeadline` | 1.20 | 12 / 14 | 13 / 15 | 14 / 16 |
| Section heading | `\CDossierSizeSection` | 1.12 | 11 / 13 | 12 / 14 | 13 / 15 |
| Entry title, body, bullets, dates | `\CDossierSizeBody` | 1.00 | 10 / 12 | 11 / 13.6 | 12 / 14.5 |
| Contact line | `\CDossierSizeSmall` | 0.92 | 9 / 11 | 10 / 12 | 11 / 13 |
| Running header, folio | `\CDossierSizeFurniture` | 0.85 | 8 / 10 | 9 / 11 | 10 / 12 |

Body leading keeps `article`'s own values so pagination stays predictable.
`article`'s `11pt` option actually sets 10.95 pt, so `\CDossierApplyBodySize`
re-pins `\normalsize` to a whole 11 pt while leaving the class option honoured
for leading and display skips.

#### Vertical rhythm

Every structural gap is a multiple of one sixteenth of the body baseline, so
the whole rhythm rescales with `fontsize` without a second tuning pass while
retaining a small, inspectable spacing vocabulary.

| Token | Ratio | `10pt` | `11pt` | `12pt` |
|---|---:|---:|---:|---:|
| `\CDossierSharedHeaderNameGapSkip` | 0.25 | 3.0 pt | 3.4 pt | 3.625 pt |
| `\CDossierSharedHeaderMetaGapSkip` | 0.1875 | 2.25 pt | 2.55 pt | 2.71875 pt |
| `\CDossierSharedHeaderBelowSkip` | 0.8125 | 9.75 pt | 11.05 pt | 11.78125 pt |
| `\CDossierRecordSectionAboveSkip` | 0.6875 | 8.25 pt | 9.35 pt | 9.96875 pt |
| `\CDossierRecordSectionRuleGapSkip` | 0.3125 | 3.75 pt | 4.25 pt | 4.53125 pt |
| `\CDossierRecordSectionBelowSkip` | 0.375 | 4.5 pt | 5.1 pt | 5.4375 pt |
| `\CDossierProseSectionAboveSkip` | 1.50 | 18.0 pt | 20.4 pt | 21.75 pt |
| `\CDossierProseSectionBelowSkip` | 0.75 | 9.0 pt | 10.2 pt | 10.875 pt |
| `\CDossierProseSubsectionAboveSkip` | 1.00 | 12.0 pt | 13.6 pt | 14.5 pt |
| `\CDossierProseSubsectionBelowSkip` | 0.625 | 7.5 pt | 8.5 pt | 9.0625 pt |
| `\CDossierRecordEntryAboveSkip` | 0.25 | 3.0 pt | 3.4 pt | 3.625 pt |
| `\CDossierRecordEntryGapSkip` | 0.0625 | 0.75 pt | 0.85 pt | 0.90625 pt |
| `\CDossierRecordListEdgeAboveSkip` | 0.3125 | 3.75 pt | 4.25 pt | 4.53125 pt |
| `\CDossierRecordListEdgeBelowSkip` | 0.3125 | 3.75 pt | 4.25 pt | 4.53125 pt |
| `\CDossierRecordItemSepSkip` | 0.00 | 0.0 pt | 0.0 pt | 0.0 pt |
| `\CDossierRecordParSkip` | 0.00 | 0.0 pt | 0.0 pt | 0.0 pt |
| `\CDossierProseParSkip` | 0.50 | 6.0 pt | 6.8 pt | 7.25 pt |
| `\CDossierLetterParSkip` | 0.50 | 6.0 pt | 6.8 pt | 7.25 pt |
| `\CDossierLetterRecipientLineGapSkip` | 0.00 | 0.0 pt | 0.0 pt | 0.0 pt |
| `\CDossierLetterBlockSkip` | 0.50 | 6.0 pt | 6.8 pt | 7.25 pt |
| `\CDossierLetterBodyAboveSkip` | 0.50 | 6.0 pt | 6.8 pt | 7.25 pt |
| `\CDossierLetterBodyBelowSkip` | 0.50 | 6.0 pt | 6.8 pt | 7.25 pt |
| `\CDossierLetterSignatureGapSkip` | 2.25 | 27.0 pt | 30.6 pt | 32.625 pt |

`\CDossierRecordSectionRuleGapSkip` is the one token whose ratio is **not** a
visible gap. Since #169 it is measured from the section heading's baseline, so
it spends the heading's own depth — about 0.20 line at every supported size —
before the rule is reached. Its raw 0.3125 is therefore not comparable with
the other numbers in the table; the gap a reader sees is roughly 0.11 line
(1.63 pt at 11 pt). 0.3125 is the smallest sixteenth that clears the
descender, which is why the normalized scale keeps it instead of stepping
further down.

Compared that way, the heading-to-rule gap is still deliberately the smallest
visible structural gap in the project, and must stay unambiguously smaller than
the rule-to-content gap (0.375) — about 1:3.1. A rule belongs to the heading
above it; at 1:2 it starts to read as a divider floating between two blocks. A
retune may move both numbers, but not their order, and may not take the rule
skip below the heading's depth. These two tokens own the complete vertical
space on either side of the rule: the shared component suppresses TeX's
automatic interline glue before and after the rule rather than allowing a
separate rule paragraph to add hidden baseline spacing.

The two list-edge tokens own the complete distance between a list and the
content around it, and the table's numbers are those distances. Keeping that
true costs an extra setting: LaTeX's `\list` adds `\partopsep` on top of
`topsep` whenever a list opens a new paragraph, and the `article` default is
3 pt plus stretch: a quantity no token owns and that does not rescale with
`fontsize`. Every list built on the shared tokens therefore sets
`partopsep = 0pt` alongside its `topsep` (#176).

The ratio absorbed that 3 pt rather than discarding it, so the rendered edge
is materially the one #166 tuned. Before #176 the real gap was 4.5 pt at
`10pt`, 4.7 pt at `11pt`, and 4.81 pt at `12pt` — an effective ratio drifting
from 0.375 down to 0.332 of a line as the body size grew, because only part of
it scaled. At 0.3125 the edge is 3.75 / 4.25 / 4.53 pt and the whole of it
scales. The ratio stays below `\CDossierRecordSectionBelowSkip` (0.375)
deliberately: a list edge that equalled the gap opening a section would
flatten the distinction between entering a section and entering a list inside
one.

`\CDossierRecordListEdgeAboveSkip` and `\CDossierRecordListEdgeBelowSkip` are
two tokens rather than one (#191) because LaTeX offers a single `topsep` and
spends it at both ends of a list, so one token could not express a different
value above and below. The opening edge is `topsep`; the closing edge is
`\@topsepadd`, the register `\@trivlist` loads from `topsep` (+ `\partopsep`)
on entry and `\@endparenv` contributes as the list's closing `\addvspace`.
Every list environment reassigns that register from the closing token
immediately before it ends — the assignment is local to the list's group —
which is what `\__cdossier_components_listedge_after:` does. Adding a separate
skip after the list instead would not collapse with the following block's own
`\addvspace` the way one list-owned skip does, and would reintroduce exactly
the additive gap
#168 removed after section rules.

`\CDossierRecordListEdgeAboveSkip` carries one constraint that does not come
from the type scale at all: a floor of 0.25, below which the entry heading's
right-hand dates column stops extracting with its entry (#219). Poppler orders
text by glyph geometry, and once the list closes up against the heading it reads
the entry as the left column of a two-column page and emits the dates last. The
component cannot own this, because the trigger is a page-level property of how
the blocks group rather than anything `\__cdossier_components_entryhead:nnnn`
emits; the gap below the heading is the only lever, so this token holds the
bound. `tokens-invariants` states it and the `*-entry-dates-*` extraction
fixtures enforce it. See `ATS-EXTRACTION.md` section 3.4 for the measurements.

The split is a mechanism change alone: both ratios start at the single value
#176 calibrated, so the rendered edge is unchanged at every supported size.
Retuning either ratio is deliberately out of scope until specific values are
proposed against the calibrated type scale.

The tagged path reaches the same closing edge by a different route (#193). Under
`\DocumentMetadata{tagging=on}` LaTeX Lab replaces LaTeX's list internals with
its own block templates, and `\@topsepadd` measures 0 pt inside a tagged list,
so the mechanism above cannot reach that path at all. Its block template does
expose the closing edge, as two keys — `end-vspace`, the counterpart of
`topsep`, and `end-extra-vspace`, the counterpart of `partopsep` — and LaTeX
Lab's enumitem emulation maps the two opening keys but nothing to that pair, so
a list that sets `partopsep = 0pt` still closed with the interface default of
`end-extra-vspace`: `\partopsep` as `article` left it, a fixed 3 pt that no
token owns. `careerdossier-components.sty` therefore declares one
CDossier-owned key, `cdossier-closing-edge`, that sets both, and the tagged
branch of each list environment names that key instead of calling
`\__cdossier_components_listedge_after:`. Keeping the LaTeX Lab key names in one
place also keeps the classes free of a testphase interface. If a later LaTeX Lab
withdraws those keys, the CDossier key becomes a no-op that still consumes its
value, so a tagged build warns once and keeps LaTeX Lab's own closing spacing
instead of stopping at an unknown-key error.

Until #193 that divergence rendered LaTeX Lab's own gap below a list — 12 pt at
the résumé default against the token's 4.25 pt — which was enough to move the
last line of the one-page résumé example 13 pt down the page relative to the
untagged build of the same source. It was not introduced by #191; it was present
with a single shared list-edge token too.

The four `Prose…` heading tokens exist because the entry-structured section
tokens above them cannot be reused in a continuous-prose class (#177). Those
are calibrated for a ruled heading in a document whose paragraphs are
separated by nothing at all: `\CDossierRecordParSkip` is 0. A statement
separates its paragraphs by `\CDossierProseParSkip` (0.50), so a heading gap
has to clear that ratio before it separates anything — at
`\CDossierRecordSectionBelowSkip` (0.375) the space opening a section would be
*narrower* than the space between two paragraphs inside it.

The prose pair is therefore stated against the paragraph gap rather than
against the ruled section: 1.50 above is three times it, 0.75 below is one and
a half times it, and the 2:1 ratio between the two binds a heading to the text
it introduces instead of leaving it suspended between two blocks. The
subsection pair repeats that shape one step down (1.00 / 0.625) — still clear
of the paragraph gap, unambiguously tighter than the section containing it.

Like the list-edge tokens, each of the four is the complete gap, and keeping
that true costs a setting. A heading is a paragraph and so is the text beneath
it, so TeX contributes `\parskip` on each side over and above the skip the
sectioning command asks for. The statement class subtracts `\parskip` from both
skips it passes to `\@startsection`, which is why the table's numbers are the
gaps a reader measures. That subtraction has a floor: `\@xsect` reads a
non-positive after-skip as a request for a run-in heading, so both below-tokens
must stay strictly greater than `\CDossierProseParSkip` (0.50) or every
statement heading would quietly become run-in.

#### Boundary ownership

Two composition rules decide which token a reader actually sees at a boundary,
and both are consequences of how the gap is contributed rather than of any
token's value.

1. **Blocks compose with `\addvspace`, which takes the maximum and never the
   sum** (#168). Where two tokens meet at one boundary, only the larger renders;
   the smaller is unreachable, and changing it produces neither a movement nor a
   diagnostic. #204 therefore gives every boundary exactly one owning token and
   retires the two that never won a maximum — `\CDossierRecordEntryBelowSkip`
   (entry → entry, always beaten by `\CDossierRecordEntryAboveSkip`, and entry →
   section, always beaten by `\CDossierRecordSectionAboveSkip`) and
   `\CDossierLetterheadBelowSkip` (header → date, always beaten by
   `\CDossierSharedHeaderBelowSkip`, which the shared header has already
   contributed at the same point).

   A gap that must *not* participate in a maximum has to be a `\vspace`, and one
   that must has to be an `\addvspace`. `\CDossierRecordEntryGapSkip` was the
   former and is now the latter: as a `\vspace` it appended a zero glue after
   its own skip, so the following block's `\addvspace` saw `\lastskip = 0` and
   the two added. It is now the floor for the entry heading → body boundary,
   which a bullet list overrides with `\CDossierRecordListEdgeAboveSkip`. That
   makes both ends of a list maxima, so "a list belongs to the entry above it"
   becomes expressible by the ratios alone.

2. **A paragraph boundary also contributes `\parskip`, and `\addvspace` cannot
   absorb it.** `\parskip` is inserted at the *next* paragraph's start, after
   `\addvspace` has already read `\lastskip`, so the two always add. A token at
   such a boundary is therefore emitted as `\addvspace{token − \parskip}`, which
   is why the table's numbers are gaps a reader measures. `careerdossier-
   statement.cls` does this for its headings; the shared header stack does it for
   every header line.

   Every header line is its own paragraph, so before #204 the prose classes'
   document-wide `\parskip` (0.50) landed in every header boundary on top of the
   header token, and the header tokens could not express a gap below that floor.
   The header group now zeroes `\parskip` for its own scope, so the three header
   gap tokens govern header spacing identically in all four classes.

   That zero is deliberately not a token. #204 exposed it as
   `\CDossierSharedHeaderParSkip`, but the value cancelled itself: the stack
   emitted every gap as `token − \parskip` and the following header line then
   contributed `\parskip` again, so the rendered gap was `token` for every
   value. It was retired in #220 along with `\CDossierSharedHeaderAboveSkip`,
   which claimed the boundary *above* the first header line — always the first
   material on page 1, where TeX discards the glue, so it too rendered nothing
   at any value. A knob that cannot move the page is not a knob; see
   [`MIGRATION.md`](MIGRATION.md#070---unreleased).

Not every token is read at the boundary it names. `\CDossierRecordParSkip`,
`\CDossierProseParSkip`, and `\CDossierLetterParSkip` are copied into `\parskip`
with `\setlength` when the class loads rather than read at each boundary, so
changing them after `\documentclass` has no effect.

`\CDossierProseParSkip` and `\CDossierLetterParSkip` are a deliberate split
(#222). Both set `\parindent = 0pt`, so the paragraph gap is the only thing
separating paragraphs in either class, but the two pull in opposite
directions: the statement's heading below-tokens must stay strictly greater
than its paragraph gap (see below), which pins `\CDossierProseParSkip` to the
bottom of the statement's heading scale, while the letter has no heading scale
to bound it and can prefer a more generous gap between its unindented block
paragraphs. A single shared token made retuning either class a side effect on
the other. Both ship at the same 0.50 ratio so the split itself does not move
any rendered gap; retuning either is a separate, independently reviewable
decision.

`tests/regression/tokens-invariants.lvt` records the ordering relations these
rules imply, one line per relation, at all three supported sizes. The baseline is
the assertion: a ratio change that makes a token unreachable, or that repairs
one, shows up there as a reviewable diff. Five relations are recorded as
`violated` at the v0.7.0 defaults — #204 made them expressible, and #206 assigns
the ratios that satisfy them.

#### Derived metrics

| Token | Derivation | `10pt` | `11pt` | `12pt` |
|---|---|---:|---:|---:|
| `\CDossierRuleThickness` | 0.04 × body size | 0.4 pt | 0.44 pt | 0.48 pt |
| `\CDossierListLabelSep` | 0.50 × body size | 5.0 pt | 5.5 pt | 6.0 pt |
| `\CDossierFurnitureLeading` | leading of `\CDossierSizeFurniture` | 10 pt | 11 pt | 12 pt |

`\CDossierPageMargin` is 72.27 pt (1 in) for `margin=normal` and 36.135 pt
(0.5 in) for `margin=narrow`, independent of `fontsize`.

#### Page-furniture placement

The running header and the folio are the only components positioned by the page
geometry rather than by the vertical rhythm, so `careerdossier-tokens` derives
their placement inside `\CDossierApplyGeometry:n` from the resolved margin `M`
and the furniture line height `H` (`\CDossierFurnitureLeading`):

| `geometry` key | Derivation |
|---|---|
| `headheight` | `H` |
| `headsep` | `M / 2 − 0.2 × H` |
| `footskip` | `M / 2 + 0.2 × H` |

Both `headsep` and `footskip` resolve to a *baseline*, not to a box edge, so
both have to split the line box the way the kernel's own strut does: 0.7
height, 0.3 depth. Centring a furniture line of height `H` in a margin `M`
therefore puts its baseline `(M − H) / 2 + 0.7 H = M / 2 + 0.2 H` from the
outer edge of that margin.

`footskip` is measured from the text block's bottom — the margin's inner edge —
so it takes that value directly. `headsep` is measured from the head box to the
text block, so it is the mirror, `M / 2 − 0.2 H`. That the header's measurement
also lands on a baseline is not obvious: the kernel builds the head as
`\vbox to \headheight {\vfil <head>}` and then forces the box depth to zero
(`\@outputpage` in `latex.ltx`), which pins the head *baseline* to the bottom
edge of the `headheight` box. Deriving `headsep` from that box edge instead —
`(M − H) / 2`, centring the head *box* rather than the line inside it — renders
2.05 pt low at `11pt` and 2.77 pt low at `10pt`, measured against the ink of the
rendered page, and breaks the mirror symmetry with the folio.

Placement is deliberately derived from the nominal line box rather than from
the ink of the particular string, so where the furniture sits does not depend on
whether a name happens to contain a descender. The residual, measured at 300 dpi
against the rendered ink, is under 1.5 pt: a running head with no descender
(`Ada Lovelace – Résumé`) reads about 1.1 pt high at `11pt`, while one with a
descender lands within 0.2 pt. The distance from the paper edge to the first ink
is identical top and bottom in every combination.

Because neither `includehead` nor `includefoot` is set, the head and foot live
inside the margin and `\textheight`/`\textwidth` do not depend on these three
values: the resulting text block is identical to v0.6.0 at every
`fontsize` × `margin` × paper combination.

All four gaps around the two nominal line boxes are equal at a given
combination — the header and the folio are exact mirrors of each other:

| `11pt` | `normal` (72.27 pt) | `narrow` (36.135 pt) |
|---|---:|---:|
| paper edge to head box | 30.635 pt | 12.5675 pt |
| head box to text block | 30.635 pt | 12.5675 pt |
| text block to foot box | 30.635 pt | 12.5675 pt |
| foot box to paper edge | 30.635 pt | 12.5675 pt |

Before issue #183 all three keys kept `geometry`'s defaults — 12 pt, 25 pt and
30 pt at every combination — which left the header 1 pt above the paper edge and
the folio about 6 pt from it at `margin=narrow`, inside most printers'
unprintable region. The placement is pinned by
`tests/regression/tokens-furniture-geometry.tlg`, which also asserts the text
block did not move.

Every number in the three tables above is pinned by
`tests/regression/tokens-scale.tlg`. That baseline is the assertion: regenerate
it only for an intended design change, and review the diff.

#### Measure, and why the prose classes default to 12 pt

The type scale sets size; the margin preset sets measure. The two interact, so
the per-class defaults are chosen from measured line length rather than from a
single project-wide preference.

Measured in TeX Gyre Termes on US Letter, counting characters including spaces
on full lines of running prose:

| `fontsize` | `margin` | `\textwidth` | Characters per line |
|---|---|---:|---|
| `10pt` | `normal` | 6.5 in | 110–120 (mean ≈ 116) |
| `10pt` | `narrow` | 7.5 in | 130–140 (mean ≈ 136) |
| `11pt` | `normal` | 6.5 in | 102–113 (mean ≈ 106) |
| `11pt` | `narrow` | 7.5 in | 118–127 (mean ≈ 122) |
| `12pt` | `normal` | 6.5 in | 93–101 (mean ≈ 97) |
| `12pt` | `narrow` | 7.5 in | 108–117 (mean ≈ 113) |

The ranges come from two different prose samples typeset at each combination
and counted from extracted text. Character count varies with the words on the
page, so treat these as a measured band rather than a constant.

This is why the letter, statement, and CV classes default to `12pt` at
`margin=normal` and **should not be quietly moved back to `11pt`**: 12 pt is
the only body size that brings a full-measure paragraph at a conventional
one-inch margin near the 45–90 range Butterick gives, and within sight of the
45–75 Bringhurst prefers. At 11 pt the same margin yields about 106 characters
per line, which is outside both.

Capping `\textwidth` from a target measure instead of raising the body size was
considered and rejected for this release. Reaching roughly 80 characters per
line at 11 pt requires side margins near 1.68 in, which no career-services
guidance endorses for an application document, and which would make the page
look padded rather than composed.

The résumé is the deliberate exception: it defaults to `11pt` at
`margin=narrow`, the longest measure in the project, because a résumé is judged
on one-page capacity and that capacity was judged worth more than the measure.
The trade is bounded — `\hfill`-split entry lines and short bullets never
approach the full measure — but it is real in a full-width Summary paragraph,
and it was accepted knowing that. Do not narrow the résumé's default measure
without revisiting the capacity argument; it is an accepted limitation, not an
oversight to correct. The measured figures, and the advice on when an author
should override it, are in `docs/API.md`.

#### Page-break penalties

`careerdossier-tokens.sty` also owns the named typographic page-break
penalties (issue #171): `\CDossierBrokenPenalty`, `\CDossierClubPenalty`, and
`\CDossierWidowPenalty`, applied through `\CDossierApplyPageBreakPenalties`.
These sit alongside the structural keep-together penalties (issue #145,
`\CDossierHeadingKeepPenalty` and `\CDossierListOrphanPenalty`) that only the
résumé and CV use; the typographic penalties are shared by all four classes,
each calling `\CDossierApplyPageBreakPenalties` once in its preamble.

All three default to `10000`, uniformly across families — there is no
per-family split, despite the structural penalties being résumé/CV-specific.
An earlier design discounted the club and widow values for the
continuous-prose classes (letter, statement) on the theory that a page-break
policy strict enough to survive a lone stranded line should also leave room to
break inside a paragraph that cannot otherwise fit; measuring against the
committed letter fixtures showed the discounted value still let a club line
through, while the full value did not, with no overfull `\vbox` anywhere in
the two-page corpus. `\raggedbottom` on all four classes is what makes the
full-strength value safe: forbidding the club/widow break only removes the
first and last line of a paragraph as legal break points, and every interior
line break is still available, so an over-long paragraph still paginates
rather than overflows.

### `careerdossier-base.sty`

Owns shared state and validation.

Responsibilities:

- define `\CDossierSetup`;
- store profile fields;
- expose supported field access;
- test whether fields are present;
- validate required fields;
- report actionable errors and warnings;
- provide shared key-value infrastructure.

It must not define:

- résumé margins;
- letter margins;
- résumé section spacing;
- document-specific page styles;
- final visual typography values.

This package is analogous to a small data model or configuration module. It stores values and enforces basic rules but does not decide how a document page looks.

### English strings and the absence of a language module

CareerDossierTeX is English-only and has no language-abstraction module and no
`\CDossierLabel` command. This is a settled design decision, not a gap: Farsi,
bilingual, and RTL support is dropped (see `docs/ROADMAP.md`), and a label
indirection layer earns its keep only once a second language exists.

The letter's English defaults (`Dear Hiring Manager,` and `Sincerely,`) are
therefore defined inline in `careerdossier-letter.cls`, which owns letter
prose structure. They are defaults, not fixed strings — `\CDossierLetterSetup`
exposes `salutation` and `closing` keys, so a user overrides them per document
without any language machinery:

```latex
\CDossierLetterSetup{
  salutation = {Dear Dr. Chen,},
  closing    = {Best regards,}
}
```

If multilingual support is ever revived, the label table belongs in a new shared
module rather than in either class, so the classes are not duplicated per
language.

### `careerdossier-typography.sty`

Owns engine checks and semantic text roles.

Responsibilities:

- require LuaLaTeX and fail fatally under any other engine;
- load `fontspec`;
- select the portable default fonts and the opt-in sans body family;
- define semantic styles such as name, headline, section, entry title, body, and muted text;
- own the cross-class `bodyfont=serif|sans` selection forwarded by each class;
- provide extension points for future named font combinations;
- apply the Latin ligature-suppression and lining-numbers defaults;
- resolve the default fonts by file name through `luaotfload` (for example
  `texgyretermes` with `Extension = .otf` and explicit face suffixes), so the
  build depends on the TeX Live font tree rather than on OS-installed fonts;
- record the tested font version for reproducibility.

The XeTeX-only `\XeTeXgenerateactualtext` primitive is gone with the engine.
LuaHBTeX emits real interword spaces in the text layer, so no per-word
`/ActualText` workaround is needed or available; see the ATS guide, section 4.5,
for the history.

Typography commands should express meaning:

```latex
\CDossierSectionStyle
```

not a specific implementation:

```latex
\Large\bfseries
```

The semantic layer allows fonts and sizes to change without rewriting every component.

### `careerdossier-theme.sty`

Owns visual tokens that are not page geometry.

Responsibilities:

- monochrome colors;
- rule colors;
- link appearance;
- print-safe contrast;
- future theme extension points.

The theme package should use semantic tokens such as:

```latex
\CDossierTextColor
\CDossierMutedColor
\CDossierRuleColor
\CDossierLinkColor
```

It must not determine résumé margins or letter paragraph spacing.

### `careerdossier-components.sty`

Owns reusable rendered pieces.

Responsibilities:

- identity block, including its token-sized text and baseline-derived spacing;
- shared page-style pair, single-page suppression, running header, and folio;
- the `medium=print|screen` decision of whether any furniture is emitted;
- shared CV/résumé section rule, including token-owned vertical spacing and
  tagged layout-artifact treatment;
- contact line;
- optional-field separator handling;
- hyperlink wrappers;
- common entry-heading primitives;
- date and location primitives;
- shared letterhead pieces that do not impose full page geometry;
- PDF document metadata derived from the profile.

The component layer also owns the shared bullet-list page-break and
trailing-space policy. Closing a list discards the space that ends its final
item, because readable source places the closing tag on its own line and that
newline is a space token at the end of the item's paragraph. Left in place, it is
carried onto a line of its own whenever the item's last line already fills the
measure — an invisible line that no `\addvspace` can see past, so the next
structural gap silently grows by a whole line.

The component layer consumes the calibrated type and spacing values from
`careerdossier-tokens.sty`; it does not derive sizes or structural gaps from
base-class environments. In particular, the shared identity block owns its
centering and vertical rhythm, the shared section-rule primitive prevents
paragraph line spacing from inflating its calibrated gaps, measures
`\CDossierRecordSectionRuleGapSkip` from the heading's baseline rather than
from the bottom of its line box so the rule's height does not follow the
heading's glyphs, and emits its rule-to-content gap so that LaTeX's collapsing
rule applies — the gap is the larger of `\CDossierRecordSectionBelowSkip` and
the following block's own leading space, never their sum, so entry-led,
list-led, and prose-led sections share one gap — and shared page furniture
owns its typography and auxiliary-file page-count decision, while leaving page
geometry and the document-specific running label to the document classes.

#### One header stack for both headers

The résumé/CV/letter identity block and the statement header are the same shape
— a name, a run of optional lines, and a contact line — and until #204 each
emitted its own gaps: once here, and four more times in
`careerdossier-statement.cls`. Both attached every gap as a *leading* skip on the
optional block that followed it, which is the "separator attached to the item"
shape this project forbids everywhere else, and which hid a defect: which token
guarded the boundary below the name depended on whether an optional field two
lines further down happened to be present. With no `headline`, the gap below the
name silently became `\CDossierSharedHeaderMetaGapSkip` instead of
`\CDossierSharedHeaderNameGapSkip`.

The shared stack takes the present lines as a sequence and interleaves the gaps,
so position decides the token rather than presence: the boundary below the name
is always the name gap, every later boundary is the meta gap, and an absent
optional field leaves nothing behind. It also owns the header's own `\parskip`
(zeroed for the group; see #220 above) and the boundary below the stack, so a
class states only which lines it prints, in reading order.

#### Why the `medium` option resolves here

`medium=print|screen` is a public *class* option, but the thing it decides —
whether page furniture is emitted at all — is owned by this module. The four
classes therefore validate the value and forward it with
`\PassOptionsToPackage`; this module holds the resolved boolean and
`\MakeCDossierPageFurniture` acts on it. Putting the decision in the classes
would replicate one policy four times, and a direct user of
`careerdossier-components` would get no say at all.

The forwarding direction matters: `\ProcessKeysPackageOptions` reads local
package options only, never the global `\documentclass` list, so a value
reaches this module only after the class that owns the public surface has
validated it.

`medium` deliberately does not reuse the vocabulary of `theme`. `theme` names
the (fixed) colour decision, and whether a folio is emitted is unrelated to
colour; `medium` names the output context, which is what actually drives the
decision. Widening it beyond page furniture is an explicit non-goal of this
release (see [`ROADMAP.md`](ROADMAP.md)).

#### Why PDF metadata lives here

`/Title`, `/Author`, and `/Lang` are derived from profile data this module
already owns, and both classes need them identically, so putting them in either
class would duplicate the logic and duplicate it again for every class added
later. The classes contribute only the one thing they own that components cannot
know: what kind of document they produce, declared through
`\__cdossier_components_doctype:n`, so a résumé and a letter built from one
profile do not receive identical titles.

Two constraints shape the implementation:

- **Timing.** The values cannot be applied when the class loads `hyperref`,
  because `\CDossierSetup` has not run yet and the profile is still empty. They
  are applied at `\begin{document}` instead.
- **Precedence.** Because they are applied late, a blind write would silently
  discard a user's own `\hypersetup` — including the one the ATS guide's own
  template places *before* `\CDossierSetup`. Each field is therefore written
  only when the document has not already set it.

This module does not load `hyperref` (the classes own it), so the entry point is
guarded and the package still loads without it, matching how the link wrappers
already degrade.

A critical invariant is:

```text
email | phone | website
```

becoming:

```text
email | website
```

when `phone` is absent.

The component layer should collect present fields first and insert separators only between rendered items. It should not print a separator after every potential field and then try to remove extras.

### `careerdossier-resume.cls`

Owns résumé-specific document behavior.

Responsibilities:

- load an appropriate base class;
- select Letter or A4 paper and delegate geometry to the shared token package;
- process `fontsize`, `margin`, `paper`, `bodyfont`, and `medium` class
  options, forwarding `medium` to the components module that owns the
  furniture decision;
- register the `Résumé` running label and enable shared page furniture;
- render résumé sections, entries, and lists from the shared type, rhythm, rule,
  and list tokens;
- preserve logical source and extraction order.

The résumé class may call shared components, but reusable contact or identity logic should not be implemented directly inside the class.

### `careerdossier-letter.cls`

Owns industry and academic cover-letter behavior.

Responsibilities:

- select Letter or A4 paper and delegate geometry to the shared token package;
- process `fontsize=10pt|11pt|12pt` and `margin=normal|narrow`, preserving
  `12pt,normal` as the prose-oriented defaults;
- derive paragraph, letterhead-block, salutation, and signature rhythm from the
  shared token package;
- define prose-friendly page-breaking behavior;
- render date and recipient blocks;
- render an optional subject;
- render salutation and closing;
- reuse the shared sender identity;
- process `family=industry|academic` as a label- and metadata-only choice while
  preserving `industry` as the default;
- process `paper=letter|a4` while preserving Letter as the default;
- process `medium=print|screen`, forwarding it to the components module that
  owns the furniture decision;
- register the `Cover Letter` running label and enable shared page furniture;
- support one-page and multi-page letters without résumé-specific compression.

The letter class should not reuse résumé geometry merely because both documents
share a header, and the family choice should not introduce family-conditional
geometry or spacing.

### `careerdossier-statement.cls` (`v0.5.0`, calibrated in `v0.6.0`)

Owns the shared statement document model approved in issue #103.

Responsibilities:

- require one of the seven documented `type` values and select its default title;
- process `fontsize=10pt|11pt|12pt` and `margin=normal|narrow`, preserving
  `12pt,normal` as the prose-oriented defaults;
- select Letter or A4 paper and delegate geometry to the shared token package;
- store statement-scoped title, running-title, subtitle, application-context,
  and application-ID metadata;
- validate `name` and `email` for every type, research affiliation, and artist
  website at the point the statement header renders;
- arrange the centered first-page identity block in logical source order;
- keep the full meaningful title in the page-one body and PDF metadata while a
  separately bounded running title identifies continuation pages;
- register that short running title with the shared page-furniture component,
  and forward `medium=print|screen` to it;
- reuse component-owned link normalization and separator-safe contact output;
- derive every header size and gap plus prose paragraph rhythm from the shared
  token package;
- restyle the two inherited unnumbered heading levels onto the shared semantic
  heading role, type scale, and prose heading tokens, and offer
  `\CDossierSection` and `\CDossierSubsection` as the class's own names for
  them;
- keep running page furniture out of tagged structure; and
- allow ordinary prose and standard LaTeX sectioning without imposing a
  type-specific narrative schema.

The heading levels are restyled rather than replaced (#177). `\@startsection`
is where the kernel's tagging support hooks in: with tagging active, an
unnumbered heading opens a `Sect` division enclosing the heading and the
content it introduces, and records the heading text as that element's title. A
heading hand-built on the shared display primitive — the mechanism the résumé
and CV use, because their ruled heading needs it — emits a bare heading element
with neither. Keeping the mechanism and replacing only its four visual
arguments buys the tokens without paying for them in structure, so
`\CDossierSection` in this class is a wrapper over the restyled `\section*`
rather than a second renderer. A statement heading carries no decorative rule:
the rule is entry-structured section furniture, not prose furniture. Heading
levels below `\subsection` are not part of the calibrated design; a statement is
not expected to need them.

The class owns the choice of which shared profile fields are relevant to each
statement type. Its filtered contact line delegates privately to
`careerdossier-components.sty`, where shared link normalization and
separator insertion remain owned.

Current `affiliation` is reusable identity data and therefore extends the
shared profile in `careerdossier-base.sty`; the statement class decides when it
is required or displayed. In contrast, `application-context` and
`application-id` describe one application document and remain class-scoped.
The shared profile is intentionally allowed to contain fields such as
`linkedin`, `github`, or `location` that a statement does not render; this is
normal cross-document reuse and must not generate warnings.

Paper size and body-font selection are cross-class concerns: every class
implements the same `paper=letter|a4` contract from issue #105 and
`bodyfont=serif|sans` contract from issue #119; Letter and serif remain the
defaults.
The statement class must not introduce statement-only option names or fallback
behavior. Broader named or per-role font combinations remain design work in
issue #120.

### `careerdossier-cv.cls` (Phase 2, released in `v0.2.0`)

Owns academic-CV document behavior.

Responsibilities:

- select Letter or A4 paper and delegate geometry to the shared token package;
- process the documented `fontsize`, `margin`, `paper`, `bodyfont`, and
  `medium` options, forwarding `medium` to the components module that owns the
  furniture decision;
- render the first-page identity in the body;
- register the `Curriculum Vitae` running label and enable shared page
  furniture without making contact details running-only content;
- render the generic section, entry, and item-list interfaces from shared type,
  rhythm, rule, and list tokens;
- own the manual-publication list and its source-order numbering while using
  shared list metrics;
- keep entries together across page breaks where practical without boxing an
  entire long entry; and
- preserve logical source and extraction order.

The CV class must not own shared metadata, contact-link normalization,
bibliography formatting, or font selection. A kernel page style is preferred to
reviving the prototypes' `fancyhdr`/`lastpage` dependency solely for
`Page n of m`; `v0.2.0` requires a page number, not a total-page count.

### `careerdossier-biblatex.sty` (Phase 2, optional)

Owns the supported BibLaTeX interoperability profile.

Responsibilities:

- load `biblatex` only when the user opts into this package;
- configure the fixed numeric, Biber-backed, year-descending profile documented
  in `docs/API.md`;
- expose repeatable author-highlighting declarations;
- implement DOI, then e-print, then URL display precedence;
- reuse semantic monochrome typography and link tokens;
- inherit the shared list-item rhythm token, `\CDossierRecordItemSepSkip`,
  when the
  host class provides it, and fall back to a fixed value when it does not, so
  the profile never owns a competing spacing value; and
- report an actionable optional-dependency error when BibLaTeX is unavailable.

It must not:

- be loaded by `careerdossier-cv.cls`;
- change the generic entry, list, section, or page-layout APIs;
- make Biber necessary for manual publications or a CV without publications;
- offer undocumented citation-style pass-through options; or
- infer an author's bibliographic identity from the display-oriented `name`
  profile field.

Standard BibLaTeX commands continue to own resource selection, `\nocite`, and
bibliography printing. CareerDossierTeX owns only the dossier-specific profile
and author-emphasis extension.

## Public versus internal API

### Public API

Public commands, options, keys, and environments are documented in `docs/API.md`.

Examples include:

```latex
\CDossierSetup
\CDossierLetterSetup
\MakeCDossierHeader
\MakeCDossierLetterhead
\MakeCDossierClosing
\CDossierSection
\begin{CDossierEntry}
\begin{CDossierItemize}
```

A command becomes public only when it is:

1. intentionally named and documented;
2. used by a supported example;
3. covered by a repeatable test;
4. included in release notes when introduced.

### Internal API

Internal implementation commands should use a clearly private naming convention.

Recommended `expl3` pattern:

```latex
\__cdossier_<module>_<action>:<signature>
```

Examples:

```latex
\__cdossier_base_validate_name:
\__cdossier_components_print_contact_line:
```

Internal commands:

- may change without migration notes;
- should not appear in examples;
- should not be described as supported;
- should remain scoped to the package that owns them when practical.

## Key-value design

Prefer `expl3` and `l3keys2e` or an equivalent modern LaTeX3 key-value interface for:

- class options;
- profile metadata;
- letter metadata;
- validation;
- controlled defaults.

Key families should be separated by responsibility, for example:

```text
cdossier/profile
cdossier/letter
cdossier/resume
cdossier/cv
cdossier/entry
cdossier/publication
cdossier/biblatex
```

Avoid one global key family that mixes profile fields, typography, page geometry, and future language settings.

## State and grouping

Metadata is persistent document state. Local visual changes should remain grouped.

General rule:

- profile and letter setup values are global for the document;
- temporary formatting changes are local to their component or environment;
- entry and list environments must not leak spacing or font changes into following content.

This is one place where LaTeX differs from ordinary object-oriented code: grouping controls scope, expansion timing matters, and assignments may be local or global depending on how they are made.

## Language strategy

### Phase 1

- English labels only;
- no RTL claims;
- no separate English-specific classes;
- user-provided content remains the user's responsibility.

### Dropped design sketch: Farsi and bilingual support

> **Status:** dropped 2026-07-16, not scheduled (see `docs/ROADMAP.md`). Kept
> as a design record only — none of this is implemented or committed scope.

If Farsi/bilingual support is ever revived:

```text
language=english|farsi|bilingual
main-language=english|farsi
```

The same classes should support different languages through shared abstractions.

Preferred:

```latex
\documentclass[language=farsi]{careerdossier-cv}
```

Avoid:

```latex
\documentclass{careerdossier-cv-farsi}
```

unless a future document model is genuinely different rather than merely translated or mirrored.

Mixed-direction fields such as email addresses, URLs, ORCID identifiers, and Latin numbers must remain LTR inside RTL documents.

## Typography strategy

The project should ship with fonts available in a normal TeX Live installation.

Custom presets such as Merriweather or Neuton belong to a later release after:

- the public API is stable enough;
- fallbacks are documented;
- examples are tested on a clean environment.

Typography should be controlled through semantic roles rather than repeated font commands in classes and components.

## Theme strategy

Phase 1 includes one monochrome theme.

Future themes should replace semantic tokens rather than rewrite components. Components ask for a meaning such as "muted text" or "rule color"; the active theme provides the value.

Page geometry is not a theme responsibility.

## Optional-field rendering

Optional metadata must be handled structurally.

Recommended approach:

1. inspect fields in desired display order;
2. append each present field to a sequence;
3. render the sequence with a separator;
4. omit the entire line when the sequence is empty.

This avoids output such as:

```text
email | | website
```

The same principle applies to recipient blocks, subject lines, dates, and entry metadata.

## Error and warning strategy

Errors should be:

- early when possible;
- specific;
- actionable;
- tied to a public command or key.

Example structure:

```text
CareerDossierTeX error:
Required profile field 'name' is missing.

Add:
\CDossierSetup{name={Your Name}}
before \MakeCDossierHeader.
```

Warnings should identify:

- what was unusual;
- what output may be affected;
- what the user can change.

Do not expose raw low-level TeX errors when the package can detect the problem first.

## Text extraction and accessibility

The source order should follow reading order.

Avoid layout techniques that visually position content in an order different from the underlying PDF text when a simpler structure is available.

Phase 1 acceptance checks should include:

```bash
make resume

pdftotext build/examples/resume-english.pdf \
  build/resume-english.txt
```

The extracted text should remain understandable and follow the visible document order.

### Font and text-layer policy

The generated PDF's text layer is a first-class deliverable, owned jointly by
`careerdossier-typography.sty` (how glyphs map back to characters) and the
classes (reading order). The policy, with rationale and tests, lives in
[`docs/ATS-EXTRACTION.md`](ATS-EXTRACTION.md). In summary:

- compile with LuaLaTeX: LuaHBTeX writes real interword spaces, so extraction
  does not depend on per-word `/ActualText` spans (the XeTeX workaround that
  made PDFKit-class consumers merge adjacent words);
- disable common/contextual/discretionary/historic ligatures in the Latin
  default so `ffi`/`ffl` sequences extract as separate letters;
- treat each font file, version, and OpenType-feature combination as testable
  code; record the tested font version;
- keep meaningful content in source (reading) order; never rely on visual
  repositioning that a parser must undo.

### Tagged PDF (status)

The XeTeX interword-space limitation that previously blocked tagging no longer
applies: LuaLaTeX supports the kernel tagging pipeline. As of `v0.4.0` the
classes emit tagged semantic structure when a document opts in with
`\DocumentMetadata{tagging=on}`.

Ownership: `careerdossier-typography` owns the engine check and the tagging
helpers; the classes own reading order and decide which page furniture is a
layout artifact. Tagging is off by default, and the untagged path must stay
byte-identical when tagging code changes — the fixtures under `tests/tagging/`
assert this.

No PDF/UA or WCAG conformance is asserted. Fixture coverage checks that a
structure tree exists and that headings, links, and artifacts are classified as
intended for five named profiles, with list checks on the résumé and CV. All
five automated fixtures have independent validator and three-extractor results;
the four `v0.4.0` profiles also have a macOS VoiceOver pass, while the statement
fixture and Windows/NVDA remain screen-reader-unverified. See the guide's
tagging section before adding any tagging-related dependency.

## Repository layout

At the end of `v0.1.0`:

```text
CareerDossierTeX/
├── careerdossier-base.sty
├── careerdossier-typography.sty
├── careerdossier-theme.sty
├── careerdossier-components.sty
├── careerdossier-resume.cls
├── careerdossier-letter.cls
├── examples/
│   ├── profiles/
│   │   └── profile-english.tex
│   └── industry/
│       ├── resume-english.tex
│       └── letter-industry.tex
├── docs/
│   ├── API.md
│   ├── ARCHITECTURE.md
│   ├── ATS-EXTRACTION.md
│   ├── MIGRATION.md
│   └── ROADMAP.md
├── tests/
│   ├── regression/
│   ├── smoke/
│   ├── layout/
│   └── extraction/
│       ├── extraction-torture.tex
│       ├── extraction-torture.expected.txt
│       └── run.sh
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── workflows/
│   │   └── build.yml
│   └── pull_request_template.md
├── build.lua
├── Makefile
├── manifest.txt
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── .gitignore
```

Do not create empty placeholder classes for future releases.

## Example and profile separation

Profile files contain personal metadata only:

```latex
\CDossierSetup{
  name     = {Amir Sadeghi},
  headline = {Data Scientist},
  email    = {name@example.com}
}
```

Document files contain document-specific content:

```latex
\input{examples/profiles/profile-english.tex}
```

This gives the repository a reusable data layer and prevents the same contact information from being copied across every example.

## Build pipeline

The local build pipeline is:

```text
source files
    │
    ▼
focused tests under tests/
    │
    ▼
latexmk -lualatex / l3build / suite runner
    │
    ▼
LuaLaTeX passes
    │
    ▼
PDF and log
    │
    ├── visual inspection
    ├── log inspection
    └── text extraction
```

The Phase 1 CI pipeline should:

1. check out the repository;
2. provide a tested LuaLaTeX environment;
3. run the committed regression, smoke, layout, and extraction tests that exist;
4. build the résumé example;
5. build the letter example;
6. fail on test or compilation errors;
7. upload PDFs and logs as artifacts.

CI answers two main questions:

```text
Does the committed behavior still satisfy its focused tests?
Can the supported examples compile from a clean runner?
```

## Testing strategy

### Continuous test development

Tests are designed and committed with the behavior they protect. When practical,
write a focused failing test before implementation, then make it pass. If the
target file or public interface does not exist yet, add the fixture alongside the
first usable implementation and record why a pre-implementation failure was not
run.

All automated test material belongs under `tests/`:

- `tests/regression/` — stable API behavior, options, diagnostics, load order,
  and fixed bugs;
- `tests/smoke/` — supported document builds and required failure paths;
- `tests/extraction/` — expected text, Unicode mapping, and reading order;
- `tests/layout/` — long fields, multi-page content, and page-break stress; and
- `tests/bibliography/` — Biber-backed sorting and rendered identifier
  precedence.

User examples remain under `examples/`. CI should build them, but they are not a
substitute for focused tests. A milestone release reruns the accumulated suite;
it does not introduce tests that were already known to be required.

The test type follows the module's concern. Logic-bearing modules — metadata and
separator logic in `careerdossier-base.sty`, and the engine-check and
role-dispatch logic in `careerdossier-typography.sty` — expose behavior that a
log diff can assert, so they take `l3build` regression tests (`.lvt` sources
with saved `.tlg` baselines) in `tests/regression/`. Layout classes —
`careerdossier-resume.cls` and `careerdossier-letter.cls` — own visual results
that no log diff fully captures, so they rely on smoke, extraction, and reviewed
reference PDFs, with final layout correctness confirmed by human inspection. A
saved baseline is the assertion: regenerate one only for an intended, reviewed
output change.

### Phase 1 coverage

- valid résumé;
- valid cover letter;
- missing required name;
- missing optional phone;
- missing optional website;
- long LinkedIn or website field;
- two-page résumé stress example;
- text extraction.

Already-merged Phase 1 modules have test debt because their local verification
fixtures were not committed. Backfill that coverage before or alongside the next
production feature.

### Regression harness

Adopt `l3build` during active Phase 1 work and point its test directory at
`tests/regression/`. Add each regression when its behavior is introduced or a
bug is fixed; do not wait for academic CV and bibliography work to start the
suite. Verify the exact configuration variables against the current `l3build`
manual when the harness is implemented.

Because a `.lvt` test cannot run without the harness, the harness precedes the
tests that depend on it: land `build.lua` before — or in the same change as — the
first module that relies on `l3build` coverage, rather than accumulating `.lvt`
sources no runner can execute. Regressions owed before the harness lands are
tracked as explicit test debt.

Tests should focus on stable behavior, not every line break or font metric before the design settles.

### Visual verification

When layout changes:

- compile the affected examples;
- inspect PDFs;
- inspect logs for overfull boxes and missing glyphs;
- attach or link a preview in the pull request.

## Generated files policy

Normally ignore:

```text
*.aux
*.bbl
*.bcf
*.blg
*.fdb_latexmk
*.fls
*.log
*.out
*.run.xml
*.synctex.gz
*.toc
```

Recommended policy:

- source files are authoritative;
- CI PDFs and logs are temporary artifacts;
- selected example PDFs are release assets;
- small preview PNGs may be committed under `docs/assets/`.

## Release principles

A feature enters a release only when:

1. its public behavior is defined;
2. a minimal example exists;
3. documentation is updated;
4. a repeatable test was committed with the behavior under `tests/`;
5. the repository does not claim unsupported configurations.

Before tagging a release:

- affected examples compile locally;
- CI passes on `main`;
- `docs/API.md` matches implementation;
- `CHANGELOG.md` is updated;
- version strings are correct;
- the working tree is clean.

## Extension path

### `v0.2.0`

Add:

```text
careerdossier-cv.cls
careerdossier-biblatex.sty
```

The CV class reuses profile, typography, theme, and components while owning
multi-page academic layout and the no-BibLaTeX manual-publication path. The
letter class gains its academic family without a duplicate class. Bibliography
support remains an explicit optional package so a CV without BibLaTeX still
builds.

### `v0.3.0` — dropped, 2026-07-16

Farsi, bilingual, and RTL support is dropped, not scheduled (see
`docs/ROADMAP.md`). If it is ever revived, extend the existing typography,
component, résumé, CV, and letter modules and add a shared label module. Do
not duplicate the class hierarchy by language.

### `v0.5.0`

Add one statement class with an interest default and six other explicit types,
A4 paper, and an opt-in sans body family through documented extension points.
Color themes, named font combinations, and optional icons were deferred by the
maintainer on 2026-07-22.

### `v0.6.0`

Add:

```text
careerdossier-tokens.sty
```

One calibrated design-token module becomes the single source of truth for the
type scale, vertical rhythm, rule weight, list metrics, and page geometry
across all four classes, replacing the mixture of per-class settings and
inherited `article` defaults. Every type size and structural gap is now a
ratio of the `fontsize` body size or baseline. The résumé and CV classes drop
`density=compact|standard`, which the proportional rhythm makes redundant.

### `v1.0.0`

Stabilize the public API, document deprecation policy, validate an Overleaf-ready package, and test every supported configuration.

## Explicit Phase 1 non-goals

Phase 1 does not include:

- academic CVs;
- bibliography or Biber;
- Farsi;
- bilingual layout;
- RTL support;
- statement classes;
- A4 paper;
- color themes;
- icon sets;
- CTAN packaging;
- full visual regression testing.

These exclusions protect the first release from architecture and documentation claims that cannot yet be verified.
