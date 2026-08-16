# CareerDossierTeX Architecture

For people changing the code: which module owns which concern, why the
boundaries fall where they do, and how the pieces load. It is the reference for
deciding *where* a change belongs. What each public name does belongs in
[`API.md`](API.md); this file does not restate it.

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
    ├── entry primitives
    └── page furniture
            │
            ▼
document class  (resume / letter / cv / statement)
    │
    ├── chooses paper and class options
    ├── passes fontsize + margin  ─────▶ careerdossier-tokens.sty
    │                                       ├── type scale
    │                                       ├── vertical rhythm
    │                                       └── page geometry
    ├── passes bodyfont           ─────▶ careerdossier-typography.sty
    │                                       ├── engine guard
    │                                       └── fonts, semantic roles
    ├── passes medium, muted,     ─────▶ careerdossier-components.sty
    │           entrymeta                   ├── furniture on / off
    │                                       ├── de-emphasis role
    │                                       └── entry-metadata placement
    ├── colour and rule tokens    ─────▶ careerdossier-theme.sty
    └── owns document structure and the running label
            │
            ▼
PDF output
```

The class is not where geometry lives. It selects paper and options and hands
each one to the package that owns the behavior, using `\PassOptionsToPackage`
before `\LoadClass`, so an option's values are validated once by its owner
rather than separately by each class. `careerdossier-biblatex.sty` sits outside
this flow: it is opt-in, loaded by the document rather than by a class, and
`careerdossier-cv.cls` must not load it.

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
| `careerdossier-typography` | *In which typeface and role?* | engine guard, font loading, semantic roles such as name, section, entry title, and body | the point sizes and gaps those roles are set at, and any colour — which is why the de-emphasis role is component-owned |
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
| Document title | `\CDossierSizeDocumentTitle` | 1.50 | 15 / 17 | 16 / 18 | 18 / 20 |
| Headline, subtitle | `\CDossierSizeHeadline` | 1.20 | 12 / 14 | 13 / 15 | 14 / 16 |
| Section heading | `\CDossierSizeSection` | 1.12 | 11 / 13 | 12 / 14 | 13 / 15 |
| Entry title, body, bullets, dates | `\CDossierSizeBody` | 1.00 | 10 / 12 | 11 / 13.6 | 12 / 14.5 |
| Contact line | `\CDossierSizeSmall` | 0.92 | 9 / 11 | 10 / 12 | 11 / 13 |
| Running header, folio | `\CDossierSizeFurniture` | 0.85 | 8 / 10 | 9 / 11 | 10 / 12 |

Body leading keeps `article`'s own values so pagination stays predictable.
`article`'s `11pt` option actually sets 10.95 pt, so
`\__cdossier_tokens_apply_body_size:` re-pins `\normalsize` to a whole 11 pt
while leaving the class option honoured for leading and display skips.

#### Vertical rhythm

Every structural gap is a multiple of one sixteenth of the body baseline, so
the whole rhythm rescales with `fontsize` without a second tuning pass while
retaining a small, inspectable spacing vocabulary.

| Token | Ratio | `10pt` | `11pt` | `12pt` |
|---|---:|---:|---:|---:|
| `\CDossierSharedHeaderNameGapSkip` | 0.25 | 3.0 pt | 3.4 pt | 3.625 pt |
| `\CDossierSharedHeaderMetaGapSkip` | 0.1875 | 2.25 pt | 2.55 pt | 2.71875 pt |
| `\CDossierRecordHeaderBelowSkip` | 0.9375 | 11.25 pt | 12.75 pt | 13.59375 pt |
| `\CDossierProseHeaderBelowSkip` | 0.9375 | 11.25 pt | 12.75 pt | 13.59375 pt |
| `\CDossierLetterHeaderBelowSkip` | 0.9375 | 11.25 pt | 12.75 pt | 13.59375 pt |
| `\CDossierRecordSectionAboveSkip` | 0.875 | 10.5 pt | 11.9 pt | 12.6875 pt |
| `\CDossierRecordSectionRuleGapSkip` | 0.3125 | 3.75 pt | 4.25 pt | 4.53125 pt |
| `\CDossierRecordSectionBelowSkip` | 0.4375 | 5.25 pt | 5.95 pt | 6.34375 pt |
| `\CDossierRecordSubsectionAboveSkip` | 0.75 | 9.0 pt | 10.2 pt | 10.875 pt |
| `\CDossierRecordSubsectionBelowSkip` | 0.375 | 4.5 pt | 5.1 pt | 5.4375 pt |
| `\CDossierProseSectionAboveSkip` | 0.875 | 10.5 pt | 11.9 pt | 12.6875 pt |
| `\CDossierProseSectionBelowSkip` | 0.375 | 4.5 pt | 5.1 pt | 5.4375 pt |
| `\CDossierProseSubsectionAboveSkip` | 0.625 | 7.5 pt | 8.5 pt | 9.0625 pt |
| `\CDossierProseSubsectionBelowSkip` | 0.3125 | 3.75 pt | 4.25 pt | 4.53125 pt |
| `\CDossierRecordEntryAboveSkip` | 0.3125 | 3.75 pt | 4.25 pt | 4.53125 pt |
| `\CDossierRecordEntryGapSkip` | 0.0625 | 0.75 pt | 0.85 pt | 0.90625 pt |
| `\CDossierRecordListEdgeAboveSkip` | 0.25 | 3.0 pt | 3.4 pt | 3.625 pt |
| `\CDossierRecordListEdgeBelowSkip` | 0.50 | 6.0 pt | 6.8 pt | 7.25 pt |
| `\CDossierRecordItemSepSkip` | 0.00 | 0.0 pt | 0.0 pt | 0.0 pt |
| `\CDossierRecordParSkip` | 0.00 | 0.0 pt | 0.0 pt | 0.0 pt |
| `\CDossierProseParSkip` | 0.25 | 3.0 pt | 3.4 pt | 3.625 pt |
| `\CDossierLetterParSkip` | 0.25 | 3.0 pt | 3.4 pt | 3.625 pt |
| `\CDossierLetterRecipientLineGapSkip` | 0.00 | 0.0 pt | 0.0 pt | 0.0 pt |
| `\CDossierLetterBlockSkip` | 0.50 | 6.0 pt | 6.8 pt | 7.25 pt |
| `\CDossierLetterBodyAboveSkip` | 0.625 | 7.5 pt | 8.5 pt | 9.0625 pt |
| `\CDossierLetterBodyBelowSkip` | 0.625 | 7.5 pt | 8.5 pt | 9.0625 pt |
| `\CDossierLetterSignatureGapSkip` | 2.00 | 24.0 pt | 27.2 pt | 29.0 pt |

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
the rule-to-content gap (0.4375) — about 1:4. A rule belongs to the heading
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
it scaled. #176 restated the whole edge as a single scaling 0.3125; #206 later
split the two ends apart, to 0.25 above and 0.50 below. Both stay below
`\CDossierRecordSectionBelowSkip` (0.4375) deliberately: a list edge that
equalled the gap opening a section would flatten the distinction between
entering a section and entering a list inside one.

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
Since #206 the token ships *at* that floor rather than above it, so a further
tightening of the list's opening edge is not available without first solving the
extraction fault the floor stands in for.

#230 solved it for a document willing to give up the column. `entrymeta=inline`
sets the dates and location on the heading lines themselves, which leaves no
two-column region for Poppler to find, so the floor has nothing to protect and
does not apply. This does *not* move the token: the default is still `column`,
the committed 0.25 is unchanged, and `tokens-invariants` still guards it. What
changed is that a per-document escape now exists, and the
`*-entry-inline-*` extraction fixtures hold the escape open by setting the token
to 0.125 — half the floor — and asserting correct reading order there. Owning
the option in the component rather than the token package is the same boundary
as before: the component owns where the cells go, and the token package owns
the gap. #230 changes the first, which is why the second is untouched.

The split itself was a mechanism change alone: both ratios started at the single
value #176 calibrated, so no list moved when #191 landed. #206 then retuned them
apart, to 0.25 above and 0.50 below, which is what makes a list sit nearer the
entry that owns it than the next one — the relation the single token could state
but never render.

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
separates its paragraphs by `\CDossierProseParSkip`, so a prose heading gap has
to clear that ratio before it separates anything. When #177 made the case the
two numbers were 0.50 against `\CDossierRecordSectionBelowSkip`'s 0.375, so
reusing the record token would have opened a section *more narrowly* than the
gap between two paragraphs inside it. #206 has since moved both — 0.25 and
0.4375 — but the constraint is structural rather than a property of those two
values: one pair is calibrated against a zero paragraph gap and the other
against a non-zero one, so neither can serve both classes.

The prose pair is therefore stated against the paragraph gap rather than
against the ruled section: 0.875 above is three and a half times it, 0.375
below is one and a half times it, and the 2.33:1 asymmetry between the two
binds a heading to the text it introduces instead of leaving it suspended
between two blocks. The subsection pair repeats that shape one step down
(0.625 / 0.3125, exactly 2:1) — still clear of the paragraph gap, unambiguously
tighter than the section containing it.

Like the list-edge tokens, each of the four is the complete gap, and keeping
that true costs a setting. A heading is a paragraph and so is the text beneath
it, so TeX contributes `\parskip` on each side over and above the skip the
sectioning command asks for. The statement class subtracts `\parskip` from both
skips it passes to `\@startsection`, which is why the table's numbers are the
gaps a reader measures. That subtraction has a floor: `\@xsect` reads a
non-positive after-skip as a request for a run-in heading, so both below-tokens
must stay strictly greater than `\CDossierProseParSkip` (0.25) or every
statement heading would quietly become run-in.

#### Boundary ownership

This chapter is the one place in `docs/` that derives the composition rules
below, the per-family header below-gap that follows from them, and the `\@xsect`
run-in floor under the statement's heading scale. `docs/API.md` states what each
rule costs an author overriding a token, and `docs/MIGRATION.md` states what a
particular release requires of a document; both link here rather than repeat the
reasoning. That matters because the reasoning quotes calibrated ratios and the
ratios move: #206 retuned them, PR #254 updated the ratio table above, and the
prose copies that existed elsewhere at the time went stale with no test and no
reviewer catching it (#185, #259). Keeping the derivation adjacent to the table
it quotes is what makes a retune a single reviewable diff.

Two other kinds of statement are deliberate and stay. `CHANGELOG.md` is a
point-in-time record whose entries are correct as of their own release, so
rewriting one to reference this moving section would make it less accurate. That
governs *rewriting* an entry, not adding context around one, and the two are
different acts: an annotation placed outside the entries — a note under the
version heading naming them — leaves every entry's own text, category, order,
and citations intact, so it records how a later rule relates to a shipped
section without making the section less accurate. `[0.7.0]` carries one such
note, marking the five entries a later `CHANGELOG.md` scope boundary would not
have produced (#260, #410); `CONTRIBUTING.md` states that boundary. And
`careerdossier-tokens.sty`, `careerdossier-components.sty`, and the classes
state each rule in a comment at the point of implementation, where someone
editing that code needs it without the documentation open. What those comments
must not carry is a *calibrated ratio belonging to another token* — nothing
updates such a literal when the other token moves, which is the same defect in a
`.sty` file that #185 repaired in prose. They name the token and defer the value
to the table above.

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
   `\CDossierLetterheadBelowSkip` (header → date, always beaten by the header
   stack's own below-token — since #223 `\CDossierLetterHeaderBelowSkip` — which
   the shared header has already contributed at the same point).

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
   every header line, and — since #419 — for the boundary below the stack too.
   That boundary sits outside the group that zeroes `\parskip` for the lines
   above it, so in the two prose classes it previously rendered one `\parskip`
   wider than its token; the fix routes it through the same
   `token − \parskip` emission the between-line boundaries already used.

   Every header line is its own paragraph, so before #204 the prose classes'
   document-wide `\parskip` — 0.50 at the time — landed in every header
   boundary on top of the header token, and the header tokens could not express
   a gap below that floor.
   The header group now zeroes `\parskip` for its own scope, so the two shared
   header gap tokens govern header spacing identically in all four classes.

   That zero is deliberately not a token. #204 exposed it as
   `\CDossierSharedHeaderParSkip`, but the value cancelled itself: the stack
   emitted every gap as `token − \parskip` and the following header line then
   contributed `\parskip` again, so the rendered gap was `token` for every
   value. It was retired in #220 along with `\CDossierSharedHeaderAboveSkip`,
   which claimed the boundary *above* the first header line — always the first
   material on page 1, where TeX discards the glue, so it too rendered nothing
   at any value. A knob that cannot move the page is not a knob; see
   [`MIGRATION.md`](MIGRATION.md#070---2026-08-04).

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
the other. Both were introduced at the same 0.50 ratio, so the split itself
moved no rendered gap; #206 then retuned both together to 0.25. Moving one
without the other is now an independently reviewable decision, which is the
point of the split.

`\CDossierRecordHeaderBelowSkip`, `\CDossierProseHeaderBelowSkip`, and
`\CDossierLetterHeaderBelowSkip` are the same kind of split (#223), one step
further out. The two gaps *inside* the header stack are genuinely shared — every
class stacks the same shape, and the group-local `\parskip` zero above makes one
ratio render one gap everywhere — but the gap *below* the stack is a boundary
against whatever the class puts next, and that neighbour differs per family: a
ruled `\CDossierSection` in the record classes, a prose section heading in the
statement, and the date line (`\CDossierLetterBlockSkip`) in the letter. The
single `\CDossierSharedHeaderBelowSkip` therefore had to clear whichever of
those was largest in *any* class, so raising the statement's section gap spent
vertical space in the résumé and the CV, and the letter carried a floor set by a
section boundary it does not have. `careerdossier-components` no longer names
the token itself: each class declares its own with
`\__cdossier_components_headerbelow:N` when it loads, and the header stack emits
that. All three were introduced at the `0.8125` ratio the shared token carried,
so the split moved nothing; #206 then raised all three together to 0.9375.

`tests/regression/tokens-invariants.lvt` records the ordering relations these
rules imply, one line per relation, at all three supported sizes. The baseline is
the assertion: a ratio change that makes a token unreachable, or that repairs
one, shows up there as a reviewable diff. All twenty-three relations hold, at
`10pt`, `11pt`, and `12pt` alike — #204 made them expressible, #206 assigned the
ratios that satisfy the first eighteen, and #337 added five for the record
subsection pair, so the baseline's remaining job is to catch a later ratio change
that breaks one. Three of the twenty-three hold with no margin at all:
`RecordSectionAboveSkip` is exactly twice `RecordSectionBelowSkip`,
`RecordSubsectionAboveSkip` is exactly twice `RecordSubsectionBelowSkip`, and
`RecordListEdgeAboveSkip` sits exactly on its extraction floor.

The record subsection pair is where those relations decided a value rather than
recording one (#337). Its below-ratio is pinned from both sides: it must exceed
both claims a subsection can meet below it — `RecordEntryAboveSkip` (0.3125) for
an entry run and `RecordListEdgeAboveSkip` (0.25) for the CV's publication
list — or `\addvspace` would never let it reach the page, and it must stay under
`RecordSectionBelowSkip` (0.4375) to read as tighter than its section. On the
sixteenth grid that leaves exactly 0.375, which is also why one pair serves both
groupings: neither neighbour owns the boundary in either case. The above-ratio is
then 0.75 rather than the prose pair's 0.625, because 0.625 against a pinned
0.375 is 1.67:1 and would have been the first heading pair to fail the
`above >= 2 x below` floor.

#### Derived metrics

| Token | Derivation | `10pt` | `11pt` | `12pt` |
|---|---|---:|---:|---:|
| `\CDossierRuleThickness` | 0.04 × body size | 0.4 pt | 0.44 pt | 0.48 pt |
| `\CDossierListLabelSep` | 0.50 × body size | 5.0 pt | 5.5 pt | 6.0 pt |
| `\CDossierEmergencyStretch` | 2.00 × body size | 20 pt | 22 pt | 24 pt |
| `\CDossierFurnitureLeading` | leading of `\CDossierSizeFurniture` | 10 pt | 11 pt | 12 pt |

`\CDossierPageMargin` is 72.27 pt (1 in) for `margin=normal` and 36.135 pt
(0.5 in) for `margin=narrow`, independent of `fontsize`.

`\CDossierEmergencyStretch` is the one `\emergencystretch` policy, and all four
classes apply it unconditionally (#272). It derives from the body size rather
than the body leading because emergency stretch is distributed among a line's
interword glue: it is a horizontal quantity, and the horizontal unit of the type
scale is the body size. Before #272 the letter and the statement each wrote
`2em`, the CV wrote `2em` at `a4paper` only, and the résumé wrote nothing — four
classes holding three policies, none of which stated why it differed from the
others. The `2.00` ratio reproduces the rendered value exactly, because
`\fontdimen6` equals the design size for both supported body fonts, so the
change is mechanism-only wherever the setting already applied. Extending it to
the résumé and to the letter-paper CV cannot loosen a paragraph that already
sets: TeX consults `\emergencystretch` only in a third line-breaking pass,
reached only when the second finds no feasible breakpoints within `\tolerance`.

The alternative derivation — a fraction of the measure, the form most other
implementations use — was measured against this one and rejected. #272 chose
`2.00` to preserve the value the classes already rendered; #310 asked whether
the body size was the right quantity at all, since a pool is spent on a line and
a line has a length. Holding a fixture, its text, and its body size fixed and
varying only the measure in 8 pt steps from 400 pt to 560 pt, the smallest pool
that clears every overfull box shows no trend: the résumé Summary prose needs
1.00 pt at a 440 pt measure, 11.25 pt at 520 pt, and nothing at 528 pt, while
the bullet path needs 33.75 pt at 416 pt and 0.75 pt at 512 pt. Across the two
paths the correlation between measure and required pool comes out at `+0.417`
and `−0.568` — opposite signs. The requirement is set by where one paragraph's
break points happen to fall, and neither candidate predicts that.

Only the magnitude is left to choose, and the two forms are indistinguishable
wherever the magnitudes match. Swept over every layout fixture at all three body
sizes and both margins, `1.50 ×` body size and `0.040 ×` measure leave the same
five overfull boxes in the same five cells, and `2.50 ×` body size and
`0.050 ×` measure leave the same two:

| Derivation | Pool at `11pt` | Overfull boxes | Third pass |
|---|---:|---:|---:|
| `0` (negative control) | 0 pt | 60 | 0 |
| `1.50 ×` body size | 16.5 pt | 5 | 51 |
| `2.00 ×` body size (shipped) | 22 pt | 5 | 51 |
| `2.50 ×` body size | 27.5 pt | 2 | 51 |
| `0.030 ×` measure | 14.1 / 16.3 pt | 7 | 51 |
| `0.035 ×` measure | 16.4 / 19.0 pt | 6 | 51 |
| `0.040 ×` measure | 18.8 / 21.7 pt | 5 | 51 |
| `0.045 ×` measure | 21.1 / 24.4 pt | 3 | 51 |
| `0.050 ×` measure | 23.5 / 27.1 pt | 2 | 51 |

Measure-derived pools are given at `margin=normal` / `margin=narrow`; a
body-size-derived pool is the same at both. 216 cells per arm — 36 discovered
fixtures at three body sizes and both margins.

"The same five cells" is meant literally, and is checked rather than inferred
from the counts matching. At `1.50 ×` body size and at `0.040 ×` measure the
overflowing cells are the same five: `resume-long-fields` at `12pt/normal` and
at `12pt/narrow`, `resume-emergency-stretch` at `11pt/narrow` and `12pt/narrow`,
and `letter-long-fields` at `12pt/narrow`. At `2.50 ×` and `0.050 ×` they are
the same two, both `resume-long-fields` at `12pt`. Two derivations that agree on
a count could still disagree on which paragraph they rescue; these do not.

The tie therefore breaks on the one criterion that does separate the forms: a
measure-derived token would be the only entry in the derived-metrics table above
not on the type scale, where `\CDossierRuleThickness` and
`\CDossierListLabelSep` already sit. The ratio stays at `2.00`.

Raising it is not free. 51 paragraphs in that sweep reach the third pass and set
successfully within it, and a larger pool re-breaks those, so a rescue bought
for an off-design stress fixture is paid for by reflowing documents that already
set. That count is `51` at every non-zero pool and `0` at none, which is also
why third-pass frequency, measured alongside the box counts, discriminates
nothing between the candidates: the pool's size decides whether a paragraph
succeeds in the third pass, never whether it enters one.

Every figure above is reproducible with `make review-linebreak` (#316), the
committed instrument this measurement was extracted into:

```bash
make review-linebreak SWEEP_ARGS="--corpus fixtures --param emergencystretch --values '0pt 1.50\CDossierBodySize 2.00\CDossierBodySize 2.50\CDossierBodySize 0.030\textwidth 0.035\textwidth 0.040\textwidth 0.045\textwidth 0.050\textwidth'"
```

Expressing an arm as a length register rather than a fixed dimension is what
makes the comparison statable at all: both candidates vary per body size and
margin, so neither can be swept as a constant. The per-document rows the
instrument writes under `build/linebreak-sweep/` are what the same-cells check
above reads.

The residue the table cannot reach is a property of the fixtures, not of the
token. Every remaining box belongs to a deliberately extreme stress fixture run
at a size and margin it is not committed at; the worst, `resume-long-fields` at
`fontsize=12pt, margin=normal`, needs an 83 pt pool — `3.46 ×` its body size, or
`0.177 ×` its measure. At the combination each fixture is committed at, the
suite is clean at the shipped ratio, which is what `make layout` asserts.

#### Page-furniture placement

The running header and the folio are the only components positioned by the page
geometry rather than by the vertical rhythm, so `careerdossier-tokens` derives
their placement inside `\__cdossier_tokens_apply_geometry:n` from the resolved
margin `M` and the furniture line height `H` (`\CDossierFurnitureLeading`):

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
rather than overflows. Nothing in the toolkit sets that `\raggedbottom`: it is
inherited from `article.cls`, which selects it for a one-side, one-column
document and `\flushbottom` otherwise. Because a penalty calibration depends on
it, the four `tokens-*-defaults` regressions assert the effective bottom-fill
state per class rather than leaving the assumption to prose (#335).

That inherited `\raggedbottom` also decides the *shape* of the club and widow
values, not merely their safety (#342). A page under construction has no stretch
to be judged on, so every candidate short of the goal scores badness `10000` and
cost `deplorable`; they all tie, the last one that fits wins, and the penalty's
magnitude is never consulted. The parameter is therefore binary — `10000`
forbids, every other value permits — and a sweep over
`10000, 4000, 1000, 300, 150, 50, 0` produces exactly two distinct paginations,
with `9999` matching `0`. Under `\flushbottom` badness would vary with the fill
and intermediate values would genuinely trade off; this conclusion is downstream
of the state #335 guards.

The trade-off was then measured on the committed corpus. Forbidding costs 13.1%
of page one on `statement-two-page` and 2.4–3.1% on the two letter fixtures that
respond; permitting recovers all of it and introduces one club line and two widow
lines, one per fixture recovered. Because the two move together with no value in
between, the choice is the rule itself rather than its strength, and the project
keeps the white space. A `\raggedbottom` document ending a page short is the
posture the toolkit already takes everywhere else.

**The conditional rule, and why it is declined.** The alternative that would
dominate both — fill the page unless doing so strands a line — was specified,
built, and measured (#351). It is declined, and the reasoning is recorded here
because the change is one line long and will be proposed again.

Two things it does *not* need. It does not need a new primitive: eTeX's
`\clubpenalties` and `\widowpenalties` take a count and that many per-line
values and both work under LuaTeX, though on their own they can only state a
*stricter* minimum, which fills less rather than more. And it does not need a
stretchable vertical token. The stretch the page builder is missing has a
simpler source: LaTeX's `\raggedbottom` leaves `\topskip` rigid and puts its
`plus .0001fil` in `\@textbottom`, which the output routine inserts when the
column is shipped, so the builder never sees it. Plain TeX's `\raggedbottom` is
`\topskip 10pt plus 60pt` — the same ragged bottom, with the tolerance where the
builder *does* see it, and invisible on the page either way because the fil in
`\@textbottom` still absorbs the whole shortfall at `\vpack` time.

Supplied that way, the mechanism works exactly as the issue predicted. Page
badness becomes finite — the 85.51pt hole on `statement-two-page` scores `b=4518`
at 24pt of tolerance against `b=10000` with none — and the club and widow values
become a genuine dial, whose policy is *strand a line only when refusing would
leave more than* `S · (p/100)^⅓` *points blank*. Three measurements then decide
against it.

**One — the tolerance buys nothing by itself.** With the pair still at `10000`
it never gains a page a single point of fill. Across all twenty committed
two-page layout fixtures and the shipped examples, nothing fills more than it
does today, and `statement-two-page` and the two letter fixtures are
byte-identical. That is structural rather than a tuning result: the set of legal
breakpoints is unchanged, and the fullest legal break already wins. Tolerance
only changes how the builder *scores* breaks it was already choosing between, so
every point of fill still has to be bought by permitting the break — the
one-for-one trade above, now behind a threshold instead of a switch.

**Two — the tolerance is not free elsewhere.** It also makes `\@secpenalty` live.
LaTeX puts that `-300` before every `\section`, and under constant badness it is
inert, because a bonus cannot break a tie in which every candidate already costs
`deplorable`. Live, it wins whenever the hole it opens scores under badness
`300`, which is up to `1.44 · S` points. Measured at `S = 60pt`: the shipped
`artist-statement` and `teaching-philosophy-statement` fall from 98.9% of page
one to **87.1%**, turning a 7.38pt hole into an 84.01pt one — the same defect the
route exists to remove, introduced into two user-facing documents. Rescuing it
means also setting `\@secpenalty` to `0`, so the classes stop preferring a
section boundary as a page break: a second, unrelated behaviour change bought to
pay for the first.

**Three — what survives buys one fixture.** With `\@secpenalty` neutralised and
the threshold at roughly three lines (`S = 60pt`, `p = 30`), across the eight
documents measured that way exactly one moves: `statement-two-page` goes from
86.9% of page one to 98.6%, closing 85.51pt of blank to 8.88pt — and gains the
widow line the rule exists to prevent, reported by the same
`page-break-check.awk` that `make layout` asserts with. The other seven —
`letter-two-page`, `letter-a4-two-page`, `statement-a4-two-page`,
`letter-academic-two-page`, and the `research`, `artist` and
`teaching-philosophy` statement examples — are byte-identical. That is the
conditionality working: the guarantee is kept where refusing is cheap and traded
where it is expensive.

That is the whole gain, and it points the other way once the corpus is read
properly. On the eleven shipped examples the club/widow rule costs **nothing** —
permitting the break everywhere leaves every one of them byte-identical. The
13.1% is a property of a stress fixture built to produce it, not of any document
the toolkit ships. So the route does not keep the guarantee and stop paying for
it; it prices the guarantee, and the price list is one stress fixture trading
white space for a stranded line, against a second behaviour change and two
coupled parameters neither of which means anything alone.

The toolkit keeps the white space. It is visible, an author can close it
deliberately with a `\newpage` or a reworded sentence, and it is already guarded
by a declared page-fill floor; a stranded line is none of those, and the detector
that would catch it was blind for most of its life (#348). Conditionality would
also dissolve the negative controls that made it honest: a shipped `\clubpenalty`
of `30` and a control that sets `0` are the same policy, so the control stops
being one. The `tokens-*-defaults` baselines now record `\topskip` and
`\@secpenalty` beside the bottom-fill state, so a package that supplies either
fails a baseline rather than switching this calibration on in silence.

**One structural keep lives outside this module**, in `careerdossier-letter.cls`
rather than here: the `\nobreak` that `\MakeCDossierClosing` emits between the
closing text and the signature name (#421). The club and widow parameters cannot
reach that boundary — the two are separate one-line paragraphs, not the first
and last line of one — and the `\vspace` between them contributes glue after a
box, which is an ordinary legal breakpoint. It is not a token, for the reason
the paragraphs above establish for the parameters it sits beside: the penalty
here is binary, so there is no value to choose and a named integer would
advertise a dial the page builder never consults. It is not shared either,
because the boundary is not shared: no other class emits two one-line paragraphs
that have to paginate as one. `docs/API.md` states it as a contract of
`\MakeCDossierClosing`.

#### Hyphenation

`\hyphenpenalty` and `\exhyphenpenalty` are **deliberately left at TeX's
defaults of `50`**, in all four families, and there is no token for them
(issue #309). This is a decision, not the absence of one: the four
`tokens-*-defaults` baselines record both values, so a later change — including
one that sets them indirectly by loading a language package — has to argue with
a reviewable diff rather than pass unnoticed.

The case for raising the penalty was that a résumé bullet is scanned rather
than read, so a hyphen at the end of a short line costs more there than in
continuous prose. Measurement did not support it, and located the hyphenation
somewhere else entirely. Across the committed examples at their shipped
settings:

| `\hyphenpenalty` | Hyphenated line ends | Lines looser than badness 99 | Worst badness | Overfull |
|---:|---:|---:|---:|---:|
| `50` (shipped) | 56 | 2 | 232 | 0 |
| `200` | 42 | 8 | 232 | 0 |
| `500` | 38 | 12 | 232 | 0 |
| `1000` | 38 | 12 | 232 | 0 |
| `10000` | 0 | 72 | 2452 | 1 |

Three things decide it. First, the motivating case is not where the
hyphenation is: **48 of those 56 hyphens are in the statements**, which are
continuous prose, while the whole committed résumé has one and the CV one. On
the realistic two-page record fixtures, raising the penalty to `500` removes
about half a hyphen per rendered document — `resume-two-page` goes from 19
hyphens to 15 across its six size/margin combinations, `cv-two-page` from 21 to
19. Second, the trade is roughly one for one against: `50 → 500` removes 18
hyphens from the examples and creates 10 lines looser than badness 99. The
worst badness does not move, so the new loose lines sit in the same quality
band, but they are a real cost paid to fix a problem the record classes do not
have. Third, there is nothing to tune inside the safe band — `500` and `1000`
give identical output, both in the examples and across the 216-cell stress
sweep.

Forbidding hyphenation outright is decisively wrong, and worth recording so it
is not revisited: `10000` produces 68 overfull boxes across the stress sweep,
one even in the committed examples, 72 loose lines, and a worst badness of
2452. That is the failure the issue anticipated — removing break points is what
sends a paragraph to the third line-breaking pass and then past the margin.

One worry did not materialise and is worth stating, because it is the cost that
would have mattered most: no committed example changes page count at any of the
five values, `10000` included. A career document does not grow a page from this
setting.

Every figure above is reproducible with `make review-linebreak` (#316), the
committed instrument this measurement was extracted into:

```bash
make review-linebreak SWEEP_ARGS="--param hyphenation --values '50 200 500 1000 10000'"
```

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
- define the six semantic styles: name, headline, section, entry title, letter
  subject, and body. The subject and entry-title roles resolve to the same
  shape and are defined independently (issue #299), so a change to one cannot
  move the other;
- render a display heading at a caller-supplied depth (issue #267) and, in
  tagged output, record the heading's plain text as its element's title;
- open the `Sect` division that a heading at that depth introduces (issue
  #268), so a record class's section encloses the content it names. This uses
  the kernel's own `sec/begin`/`sec/end` tagging sockets, and therefore the
  kernel's section stack, rather than a private structure-element pair — which
  is what makes a sibling heading close the previous division and an unclosed
  one close at the end of the document. It emits no typeset material;
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

- the public header-stack composition API every header is built from;
- identity block, including its token-sized text and baseline-derived spacing;
- shared page-style pair, single-page suppression, running header, and folio;
- the `medium=print|screen` decision of whether any furniture is emitted, and
  the same option's decision of whether a link carries a visible decoration;
- the link-decoration role `\CDossierLinkStyle`, the `\CDossierPlainLinks`
  suppression declaration, and the `\href` hook that reaches an author's own
  anchor text;
- the `muted=italic|gray|both|plain` de-emphasis role, `\CDossierMutedStyle`, and the
  decision of what it resolves to;
- the `entrymeta=column|inline` placement of an entry's dates and location, and
  the separator token `\CDossierEntryMetaSeparator` the inline form joins them
  with;
- shared CV/résumé section rule, including token-owned vertical spacing and
  tagged layout-artifact treatment;
- the shared record subsection renderer (#337) — the second heading level both
  record classes expose as `\CDossierSubsection`, including its depth-3 division
  and heading, its two tokens, its own needs-N-lines bound, and the test for
  whether a section has typeset anything yet. The classes hand-roll
  `\CDossierSection` twice already; one renderer here is what keeps the tokens
  and the tagged structure from drifting between the two spellings;
- contact line;
- optional-field separator handling;
- hyperlink wrappers, including `\CDossierLink`, the body-text link, and the
  scheme normalization it shares with the web-profile contact fields;
- common entry-heading primitives;
- date and location primitives;
- shared letterhead pieces that do not impose full page geometry;
- PDF document metadata derived from the profile;
- the no-op `\pdffakespace` fallback every class relies on when untagged.

The link decoration is where this package reaches furthest outside itself, so
its two hooks are worth stating plainly (issue #278).

`\href` is wrapped by a replacement that grabs **no** arguments: it records a
flag and hands the untouched token stream to the original. That is not a style
choice. hyperref re-catcodes a URL argument inside `\hyper@normalise` before
expanding it, so any wrapper that reads the argument first — an
`\RenewDocumentCommand\href{omm}`, for instance — fails inside the URL scanner.
The flag is read once, in hyperref's `\hyper@link@`, which is where the link
text is in hand and the catcode work is finished; that is also where the
decoration is applied. The flag is global because it must survive the
`\begingroup` `\href` opens between the two points, and it is cleared before
anything is typeset so `\hyperlink` and `\hyperref`, which share
`\hyper@link@`, never inherit it. Both patches are guarded on the existence of
what they replace, and `tests/regression/components-linkdecoration.lvt` asserts
they were installed — a hook that silently failed to apply is indistinguishable
on the page from `medium=print`.

The rule itself is drawn by `lua-ul`, which is this package's only third-party
dependency beyond the CareerDossierTeX packages it requires. `ulem` was the
obvious candidate and was rejected on measurement: `\uline` reboxes its
argument and rebuilds interword spaces as its own leaders, which passes every
extraction check — Poppler, MuPDF, and PDFKit all rebuild words from glyph
geometry and see the gap — while the structure tree loses the space, so a
consumer reading a Link element's logical text gets `publicwrite-up`. That is
the defect class of issues #302 and #315 arriving by a third route. `lua-ul`
attaches a node attribute and lets LuaTeX draw the rule at shipout: nothing is
reboxed, no glue is touched, no break point moves, and the `/Artifact` hazard of
issue #161 does not arise because there is no box to be artifacted. It is
LuaLaTeX-only, which costs nothing here, and LPPL 1.3c.

Scheme normalization has a catcode requirement of its own, and it belongs with
the hooks above because it is the same class of problem: a link that is wrong
only in the PDF. A colon written literally inside `\ExplSyntaxOn` is a letter,
catcode 11. `hyperref` finds an `\href` target's scheme by splitting the target
on a catcode-12 colon (`\@hyper@readexternallink`), so a scheme the package
supplies with `\tl_put_left:Nn` is invisible to that split: `hyperref` concludes
the target is a local file, appends `.pdf`, and emits a `GoToR` "open page 1 of
a remote PDF" action instead of a `URI` action. Nothing is logged, and the
rendered page, the extracted text, and the copy-paste invariant of `make links`
are all unaffected — the only wrong thing in the file is the annotation's action
type. Every scheme insertion therefore goes in through `\tl_put_left:Ne` with
`\tl_to_str:n`, which produces the catcode-12 form a document that wrote the
address out in full would have given (issue #328). The comment above
`\__cdossier_components_scheme:N` already warned about the catcode for
*detecting* an existing scheme; the insertion on the next line had the bug the
comment described, and the same insertion in
`careerdossier-cv.cls`'s publication list had it at three more sites.
`tests/annotations/` is what asserts the action type, since no text-layer suite
can see it.

The canonical-address expansion for `linkedin`, `github`, and `scholar` (issue
#330) sits on that same path and deliberately does not repeat the pattern. It
prepends its prefix to the *displayed* value, before the scheme insertion runs
at all, so the package contributes only `linkedin.com/in/`-shaped text with no
colon in it and the one colon in the final target still arrives through
`\__cdossier_components_scheme:N`. Two properties follow, and both are the
reason for the ordering rather than consequences of it: there is exactly one
scheme-insertion site to keep correct, and the visible address and the link
target cannot disagree, because the second is derived from the first instead of
being built by a parallel rule. `\CDossierLink` shares the scheme insertion but
not the expansion — body text names no service to expand a handle against. Which
values are expanded is a `\prop_const` keyed by field name, so `website`, which
has no canonical host, is absent from it and keeps its previous behaviour by
having no entry rather than by an exception in the code.

The `\pdffakespace` fallback below is a one-line declaration but it belongs here
rather than in a class. `\pdffakespace` is tagpdf's; it puts a real, zero-width U+0020 into the
content stream so a gap made of pure positioning glue still reads as a word
boundary to a consumer of the structure tree (issue #302). It exists only when
the document asked for tagging, and both call sites — this package's entry
heading and `careerdossier-letter.cls`'s recipient block — are on paths that
must also work untagged. Every class loads this package, so one fallback here
covers both. It is declared at `\begin{document}`, not at load time: tagpdf
declares the real command with `\NewDocumentCommand`, which errors on an
existing definition, so a `\providecommand` at load time would break the tagged
build rather than merely lose to it.

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
owns its typography and auxiliary-file page-count decision, while leaving the
document-specific running label to the document classes. The furniture's own
geometry is not a class concern either: `careerdossier-tokens.sty` derives
`\headheight`, `\headsep`, and `\footskip` inside
`\__cdossier_tokens_apply_geometry:n`.

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

Since #224 the stack is a **public interface owned by this module**:
`\CDossierHeaderBegin`, `\CDossierHeaderLine`, and `\CDossierHeaderEnd`, with
`\MakeCDossierHeader` and `\MakeCDossierStatementHeader` both implemented over
it. #204 shared the mechanism but left it private, so the statement class drove
another module's `\__cdossier_components_headerstack_*` primitives — a boundary
leak the naming convention forbids. Sharing it under a public name is the fix;
reusing `\MakeCDossierHeader` is not available, because the statement's title,
subtitle, and context lines interleave with the identity lines rather than
appending to them, so no hook on a fixed three-line block preserves the reading
order.

It is a command triple, not a `CDossierHeader` environment, even though the
project ships public environments elsewhere. An environment is the better
spelling only when its body is genuinely restricted to line calls; here both
wrappers interleave conditionals between lines, so the begin/end pair is no
harder to misuse and the triple translates the existing primitives verbatim.

How the triple meets the four public-API conditions above (#252): it is named
and documented in `docs/API.md`, covered by `components-headerstack.lvt`, and
introduced in the changelog. The "used by a supported example" condition is met
by the two wrappers, which exercise it on every build of every class, plus a
worked example in `docs/API.md` compiled as
`tests/smoke/components-header-stack-doc.tex`. Deliberately **no** new document
under `examples/`: that directory is user documentation for people writing
dossiers, and this is a composition interface for whoever writes the class. A
document author reaches for `\MakeCDossierHeader`. The smoke runner diffs the
fixture against the published block before compiling it, so the documented
example cannot drift from the one that is known to build.

The split of concerns across that boundary is fixed: the stack owns every gap
and holds no validation, while each wrapper owns its own line list and its own
preconditions — `\__cdossier_base_require_name:N` for `\MakeCDossierHeader`,
`\__cdossier_statement_validate:` for `\MakeCDossierStatementHeader`. Neither
precondition belongs to stacking lines.

#### Why the `medium` option resolves here

`medium=print|screen` is a public *class* option, but the thing it decides —
whether page furniture is emitted at all — is owned by this module. The four
classes therefore validate the value and forward it with
`\PassOptionsToPackage`; this module holds the resolved boolean and
`\__cdossier_components_apply_page_furniture:` acts on it. Putting the decision
in the classes would replicate one policy four times, and a direct user of
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

#### Why the de-emphasis role resolves here

`Muted` used to name two mechanisms in two modules — `\CDossierMutedColor` in
the theme and `\CDossierMutedStyle` in typography — and only the italic one
reached the page. Making it one rendered result forced the question of where it
can live, and there is exactly one answer.

`careerdossier-theme` owns colour and `careerdossier-typography` owns shape,
and the dependency direction forbids either from reaching into the other:
typography must contain no colour, which is precisely what `muted=gray` needs.
This module owns rendered parts and already loads both, so it is the only place
a role combining a shape and a colour token can be assembled. `muted` therefore
follows the same forwarding path as `medium` — each class validates the public
value, this module holds the decision — and `\CDossierMutedStyle` is published
from here.

The role is resolved once, at option time, into a single `\RenewDocumentCommand`
rather than branched at each use, so there is one definition to read and a
de-emphasised run costs no more than it did before the option existed.

#### Why PDF metadata lives here

`/Title`, `/Author`, and `/Lang` are derived from profile data this module
already owns, and both classes need them identically, so putting them in either
class would duplicate the logic and duplicate it again for every class added
later. The classes contribute only the one thing they own that components cannot
know: what kind of document they produce, declared through
`\__cdossier_components_doctype:n`, so a résumé and a letter built from one
profile do not receive identical titles.

Three constraints shape the implementation:

- **Timing.** The values cannot be applied when the class loads `hyperref`,
  because `\CDossierSetup` has not run yet and the profile is still empty. They
  are applied at `\begin{document}` instead.
- **Precedence.** Because they are applied late, a blind write would silently
  discard a user's own `\hypersetup` — including the one the ATS guide's own
  template places *before* `\CDossierSetup`. Each field is therefore written
  only when the document has not already set it. The language has two routes and
  both count: `\hypersetup{pdflang=...}` lands in `hyperref`'s `\@pdflang`, while
  `\DocumentMetadata{lang=...}` is recorded by the kernel and never reaches
  `hyperref` at all. Reading only the first mistakes the second kind of document
  for one that declared nothing, so `\GetDocumentProperties{document/lang}` is
  consulted as well. It is undefined exactly when `\DocumentMetadata` was never
  used — the path where the derived value is the one that should apply — and
  under `\DocumentMetadata` it always holds a language, defaulting to `en`, so
  the kernel owns `/Lang` outright there.
- **Ordering against `hyperref`.** The three fields are not written by the same
  mechanism at the same moment, and `/Lang` is the odd one out. `/Title` and
  `/Author` reach the Info dictionary from `\PDF@FinishDoc` at `\end{document}`,
  so nothing here can be too late for them. On the default path, where
  `\DocumentMetadata` is absent and the kernel's PDF management is inactive,
  `hyperref` writes the *catalog* itself from its own `begindocument` chunk —
  `/Lang(\@pdflang)` in `hluatex.def` — and a `pdflang` set after that chunk has
  run is simply not in the file, with nothing logged. This module's chunk must
  therefore precede `hyperref`'s. The four classes produce that order anyway,
  since each loads this package before it loads `hyperref`, but a document using
  the package directly need not, so a `\DeclareHookRule` states the requirement
  rather than inheriting it (#276). `tests/metadata/` holds the fixture that
  fails without the rule.

`/DisplayDocTitle` is the exception to both, and is applied separately from
`\__cdossier_components_pdfmeta:` for that reason. It is a boolean, not a
derived string: `hyperref` records no state that separates its `false` default
from a document's explicit `pdfdisplaydoctitle = false` — the legacy driver has
only `\ifHy@pdfdisplaydoctitle`, and under `\DocumentMetadata` the key writes
straight to the catalog, so a refused flag and an unset one are both an absent
entry. With nothing to detect, a write at `\begin{document}` could only
overwrite the document's choice. It also needs no profile data, so it does not
have to wait. It is therefore requested from the `package/hyperref/after` hook,
where it precedes every preamble line the document writes, and both drivers
honour the last write — which reverses the precedence mechanism, from detection
to ordering, while keeping the same outcome. The limits of that are recorded in
[`API.md`](API.md).

This module does not load `hyperref` (the classes own it), so the entry points
are guarded and the package still loads without it, matching how the link
wrappers already degrade.

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
- process `fontsize`, `margin`, `paper`, `bodyfont`, `medium`, `muted`, and
  `entrymeta` class options, forwarding `medium`, `muted`, and `entrymeta` to
  the components module that owns the furniture, de-emphasis, and
  entry-metadata decisions;
- register the `Résumé` running label and enable shared page furniture;
- render résumé sections, entries, and lists from the shared type, rhythm, rule,
  and list tokens, and expose the shared second heading level as
  `\CDossierSubsection` (#337) — two heading levels, matching the CV and the
  statement, so one profile's documents are written the same way;
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
- process `medium=print|screen` and `muted=italic|gray|both|plain`, forwarding both
  to the components module that owns the furniture and de-emphasis decisions;
- register the `Cover Letter` running label and enable shared page furniture;
- support one-page and multi-page letters without résumé-specific compression.

The letter class should not reuse résumé geometry merely because both documents
share a header, and the family choice should not introduce family-conditional
geometry or spacing.

The recipient block additionally scopes its own `\\`. For the length of that
block, and no longer, `\\` carries the structure-text separator described under
`careerdossier-components.sty` above. Attaching it to `\\` rather than to the
four field-joining call sites is the point: `recipient-address` is documented as
taking a multi-line value with the user's own `\\` inside it, and that break
never passes through `\__cdossier_letter_rcptline:N`. The redefinition is
undone when the block closes, because past that point `\\` is the document
author's ordinary line break again.

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
  and forward `medium=print|screen` and `muted=italic|gray|both|plain` to it;
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
- process the documented `fontsize`, `margin`, `paper`, `bodyfont`, `medium`,
  `muted`, and `entrymeta` options, forwarding `medium`, `muted`, and
  `entrymeta` to the components module that owns the furniture, de-emphasis,
  and entry-metadata decisions;
- render the first-page identity in the body;
- register the `Curriculum Vitae` running label and enable shared page
  furniture without making contact details running-only content;
- render the generic section, entry, and item-list interfaces from shared type,
  rhythm, rule, and list tokens, and expose the shared second heading level as
  `\CDossierSubsection` (#337), which is what lets `Publications` carry journal,
  conference, and preprint groups without promoting each to a ruled section;
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
  the profile never owns a competing spacing value;
- inherit the shared list label token, `\CDossierListLabelSep`, for the
  horizontal gap between an entry number and its entry, for the same reason and
  on the same terms, so the label geometry matches `CDossierPublications`
  rather than BibLaTeX's wider `2\labelsep` default;
- keep printed URLs extractable by removing the stretch BibLaTeX applies at each
  URL break point, and supply the additional break points that rigid glue then
  needs, so a URL can still reach the end of a line without overrunning it; and
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
\CDossierHeaderBegin … \CDossierHeaderLine … \CDossierHeaderEnd
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
intended.

`tests/tagging/run.sh` runs three tiers, and the difference between them matters
when reporting what is covered:

- **Five named profiles** — résumé, CV, letter, academic letter, and statement —
  take the full pass: structure, two-page continuation furniture, the page-two
  artifact stream, extraction, untagged equivalence, visual equivalence, and
  PDF/UA-2 validation. List checks apply to the résumé and CV.
- **`resume-contact-labels`** is a sixth blocking fixture, deliberately outside
  that loop because it is one page and must *not* have continuation furniture.
  It takes contact-label tagging, extraction, and PDF/UA-2 validation.
- **`biblatex`** is a seventh fixture and is **non-blocking by design**. Tagging
  support inside BibLaTeX and Biber is upstream work, so the runner records its
  build and validator result rather than asserting them; a failure fails the
  suite only if CareerDossierTeX's own code caused it, which is a maintainer
  judgement made from the retained report.

So six fixtures carry three-extractor baselines (Poppler, MuPDF, and Apple
PDFKit) and blocking validator results; the seventh carries a recorded one and
no extraction baseline. Of the screen-reader checks, the four `v0.4.0` profiles
have a macOS VoiceOver pass; the statement fixture and Windows/NVDA remain
unverified.

veraPDF is not installed in the per-PR `tagging` job — it runs weekly from
`.github/workflows/verapdf-scheduled.yml` — so a pull request is not
PDF/UA-validated on the strength of its own checks. See the guide's tagging
section before adding any tagging-related dependency.

## Repository layout

The tracked tree:

```text
CareerDossierTeX/
├── careerdossier-base.sty
├── careerdossier-tokens.sty
├── careerdossier-typography.sty
├── careerdossier-theme.sty
├── careerdossier-components.sty
├── careerdossier-resume.cls
├── careerdossier-letter.cls
├── careerdossier-cv.cls
├── careerdossier-statement.cls
├── careerdossier-biblatex.sty
├── examples/
│   ├── profiles/
│   │   ├── profile-english.tex
│   │   └── profile-academic.tex
│   ├── industry/
│   │   ├── resume-english.tex
│   │   └── letter-industry.tex
│   ├── academic/
│   │   ├── cv-academic.tex
│   │   ├── cv-bibliography.tex
│   │   ├── letter-academic.tex
│   │   └── publications.bib
│   └── statements/           (one example per statement type)
├── docs/
│   ├── API.md
│   ├── ARCHITECTURE.md
│   ├── ATS-EXTRACTION.md
│   ├── MIGRATION.md
│   ├── NAMING-CONVENTION.md
│   ├── ROADMAP.md
│   └── TESTING.md
├── tests/
│   ├── lint/
│   ├── regression/
│   ├── smoke/
│   ├── layout/
│   ├── extraction/
│   ├── bibliography/
│   └── tagging/
├── .agents/
│   └── skills/
│       ├── open-draft-pr/
│       │   ├── SKILL.md
│       │   └── reference.md
│       └── release-notes/
│           ├── SKILL.md
│           └── reference.md
├── .claude/
│   ├── settings.json
│   └── skills/               (symlinks into .agents/skills/)
├── .codex/
│   └── config.toml
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── config.yml
│   │   ├── bug_report.md
│   │   ├── feature_request.md
│   │   └── epic.md
│   ├── workflows/
│   │   ├── build.yml
│   │   └── verapdf-scheduled.yml
│   └── pull_request_template.md
├── build.lua
├── Makefile
├── manifest.txt
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── AGENTS.md
├── AI-POLICY.md
├── CLAUDE.md
├── LICENSE
└── .gitignore
```

`manifest.txt` is the authoritative list of the files constituting the Work;
update it in the same change whenever that set changes. Agent instruction
content has one home under `.agents/`, and the per-tool directories hold only
that tool's own settings.

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

`.github/workflows/build.yml` runs on pull requests to `main` and on pushes to
`main`, with `contents: read` and every action and container pinned to an
immutable reference. A `toolchain` job records the exact TeX Live, LuaLaTeX,
`fontspec`, `pdfmanagement-testphase`, `tagpdf`, `l3build`, BibLaTeX/Biber, and
default-font versions a run used, so a result can be read alongside the
toolchain that produced it. Twelve independent check jobs run in parallel, each
uploading its PDFs, logs, or reports as artifacts:

- `lint` runs `make lint`. It is the one job that needs no TeX, so it runs on the
  bare runner rather than the TeX Live container — which also means the option
  lint is exercised against a second `grep` and `awk` implementation.
- `regression` runs `l3build check`.
- `smoke`, `layout`, `extraction`, `tagging`, and `bibliography` run the matching
  fixture runner under `tests/`.
- `resume`, `letter`, `cv`, `academic-letter`, and `statement` build the
  supported examples for each document family.

A second workflow, `.github/workflows/verapdf-scheduled.yml`, reruns
`tests/tagging/run.sh` weekly with veraPDF built from a pinned commit. Building
that validator costs several minutes, which the project pays weekly rather than
on every pull request, so the per-PR `tagging` job skips the PDF/UA-2 gate and
runs the structural, extraction, and geometry checks only. A pull request is
therefore not PDF/UA-validated on the strength of its own checks.

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

- `tests/lint/` — source-level invariants no compiled fixture can assert, with
  their own fixture packages;
- `tests/regression/` — stable API behavior, options, diagnostics, load order,
  and fixed bugs;
- `tests/smoke/` — supported document builds and required failure paths;
- `tests/extraction/` — expected text, Unicode mapping, and reading order;
- `tests/layout/` — long fields, multi-page content, and page-break stress;
- `tests/bibliography/` — Biber-backed sorting and rendered identifier
  precedence;
- `tests/metadata/` — PDF metadata on the default (untagged) build path, where
  no `\DocumentMetadata` is in play;
- `tests/annotations/` — the action type of each emitted link annotation, the
  one link property no text-layer suite can see; and
- `tests/tagging/` — tagged structure, the untagged path, and the extractor
  matrix.

`tests/metadata/` and `tests/tagging/` divide by build path, not by subject.
Every tagging fixture opts into `\DocumentMetadata`, which supplies catalog
entries of its own — so it is exactly the wrong place to ask what this package
contributes without it. That masking is why the `/Lang` question in #276 had no
suite that could answer it.

User examples remain under `examples/`. CI should build them, but they are not a
substitute for focused tests. A milestone release reruns the accumulated suite;
it does not introduce tests that were already known to be required.

The test type follows the module's concern, but no module is exempt from a log
diff. Anything with observable logic — values, options, errors, or emitted
structure — takes an `l3build` regression test (`.lvt` source with a saved `.tlg`
baseline) in `tests/regression/`. Every shared package and every class already
has that coverage: 28 `.lvt`/`.tlg` pairs, spread across
`careerdossier-base.sty` (2), `careerdossier-tokens.sty` (8),
`careerdossier-components.sty` (6), `careerdossier-typography.sty` (3),
`careerdossier-theme.sty` (1), `careerdossier-biblatex.sty` (1), and the four
classes (7). Extend the existing file for a module rather than assuming the
module is exempt. Layout behavior additionally owns visual results that no log
diff fully captures, so the classes also carry smoke, layout, extraction,
tagging, and reviewed reference-PDF coverage, with final layout correctness
confirmed by human inspection. A saved baseline is the assertion: regenerate one
only for an intended, reviewed output change.

### Coverage matrix

Which document families, fields, errors, extraction, tagging, link, and
bibliography cases a change has to cover is stated once, in
[`TESTING.md`](TESTING.md) ("Coverage expectations"). It is not
summarized here: the copy that used to sit in this section had already drifted,
omitting the link copy-paste and link-annotation rows.

### Regression harness

`build.lua` configures `l3build` for the module regression suite. `testfiledir`
points at `tests/regression/`, so no top-level `testfiles/` directory is
introduced. There is no `.dtx`/`.ins` unpack step: the handwritten sources live
at the repository root, and `sourcefiles`/`installfiles` copy
`careerdossier-*.sty` and `careerdossier-*.cls` into the test sandbox so
`\usepackage` and `\documentclass` resolve them. Because the project is
LuaLaTeX-only, `checkengines` and `stdengine` are `luatex` and `checkformat` is
`latex`. These tests assert token lists and diagnostics rather than multi-pass
references, so `checkruns` is 1.

`l3build check` runs the whole suite, `l3build check <name>` one test, and
`l3build save <name>` regenerates a baseline. The shell-driven runners under
`tests/` are not invoked by `l3build`; `make check` runs both.

Because a `.lvt` test cannot run without the harness, the harness precedes the
tests that depend on it: a module that relies on `l3build` coverage does not land
ahead of the configuration that can execute it.

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
