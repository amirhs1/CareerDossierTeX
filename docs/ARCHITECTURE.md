# CareerDossierTeX Architecture

For people changing the code: which module owns which concern, why the
boundaries fall where they do, and how the pieces load. It is the reference for
deciding *where* a change belongs. What each public name does belongs in
the PDF manual, [`../doc/careerdossier.tex`](../doc/careerdossier.tex); which
release a change belongs to, in [`ROADMAP.md`](ROADMAP.md); and what a release
has to satisfy before it ships, in
[`CONTRIBUTING.md`](../CONTRIBUTING.md#release-contributions) and
[`RELEASE-CHECKLIST.md`](RELEASE-CHECKLIST.md#release-checklist). This file
restates none of them.

## What this file enforces

The separation of concerns itself — profile data, rendered components,
calibrated tokens, typography, theme, page layout — is the module graph below,
and `README.md` states what the toolkit is for. Four rules are this document's
own, and each one decides where a change belongs:

1. A class owns page-level behaviour and nothing else. Geometry, type, colour,
   and rendered parts belong to the package that owns them.
2. An option is validated once, by the package that owns the behaviour, not by
   each class that accepts it.
3. Missing optional fields must be safe: collect the present fields, then insert
   separators, so an absent value leaves nothing behind.
4. Do not create empty placeholder classes or modules for a future release;
   `manifest.txt` is the complete list of what exists.

## Module graph and data flow

All four classes load the same five shared packages, and none of the five knows
which class loaded it:

```text
careerdossier-{resume,letter,cv,statement}.cls
        │
        ├── careerdossier-tokens.sty       size and spacing
        ├── careerdossier-typography.sty   engine guard, fonts, text roles
        ├── careerdossier-theme.sty        colour
        ├── careerdossier-components.sty   rendered parts
        └── careerdossier-base.sty         profile state and validation

careerdossier-biblatex.sty  ──optional──▶  biblatex / Biber
```

Loading order may differ where an implementation requires it; the direction may
not. No shared package depends on a class. `careerdossier-biblatex.sty` is the
one optional edge, and `careerdossier-cv.cls` must not load it or `biblatex` —
that separation is what makes the no-BibLaTeX CV path supportable. A CV document
may load the integration package itself, but neither it nor the external
toolchain becomes a dependency of the shared profile or of any other class.

Values flow the other way. A profile enters once and every option is validated
by the package that owns the behaviour, not by the class that accepted it:

```text
profile file ──▶ \CDossierSetup ──▶ careerdossier-base.sty
                                        ├── validation
                                        ├── field lookup
                                        └── presence tests
                                                │
                                                ▼
                                    careerdossier-components.sty
                                        renders identity, contact line, links,
                                        entry primitives, furniture, section
                                        rules, list breaks, derived PDF metadata
                                                │
                                                ▼
document class ── chooses paper, owns structure and the running label
    │
    ├── fontsize, margin        ─────▶ tokens       type scale, rhythm, geometry
    ├── bodyfont                ─────▶ typography   engine guard, fonts, roles
    ├── medium, muted, entrymeta ────▶ components   furniture, de-emphasis,
    │                                               entry-metadata placement
    └── colour and rule tokens  ─────▶ theme
            │
            ▼
        PDF output
```

The class is not where geometry lives. It hands each option to its owner with
`\PassOptionsToPackage` before `\LoadClass`, so a value is validated once
rather than separately in four classes.

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

Four constraints bind a retune. The derivations are in the issues named; the
mechanisms are commented at the code that implements them.

- **The rule gap is not a visible gap.**
  `\CDossierRecordSectionRuleGapSkip` is measured from the section heading's
  baseline since #169, so it spends the heading's own depth — about 0.20 line —
  before the rule is reached. Its 0.3125 renders as roughly 0.11 line, and is
  the smallest sixteenth that clears the descender. It must stay unambiguously
  smaller than the rule-to-content gap (0.4375), about 1:4; at 1:2 the rule
  starts to read as a divider between two blocks rather than as part of the
  heading above it. A retune may move both numbers but not their order, and may
  not take the rule skip below the heading's depth.
- **A token that claims a boundary owns all of it.** The two list-edge tokens
  own the complete distance between a list and its surroundings, which costs
  every shared list a `partopsep = 0pt` beside its `topsep` (#176); the four
  `Prose…` tokens own the complete heading gap, which costs the statement class
  a `\parskip` subtraction on both skips it passes to `\@startsection`. That
  subtraction has a floor — `\@xsect` reads a non-positive after-skip as a
  run-in heading request — and `careerdossier-statement.cls` comments it at the
  code.
- **Two ordering relations are load-bearing.** Both list-edge ratios stay below
  `\CDossierRecordSectionBelowSkip` (#191, #206), or entering a list would look
  like entering a section; and both prose below-tokens stay strictly above
  `\CDossierProseParSkip`, or every statement heading turns run-in. The prose
  pair is stated against the paragraph gap rather than against the ruled
  section, because one pair is calibrated against a zero paragraph gap and the
  other against a non-zero one, so neither can serve both classes (#177).
- **`\CDossierRecordListEdgeAboveSkip` carries a floor of 0.25** that does not
  come from the type scale: below it the entry heading's right-hand dates column
  stops extracting with its entry (#219). The token ships *at* the floor since
  #206, so tightening it further is not available without first solving the
  extraction fault. `entrymeta=inline` (#230) removes the two-column region the
  floor protects, which is why the inline fixtures may set 0.125 — it does not
  move the default. `tokens-invariants` guards both.

The tagged path reaches the same closing edge by a different route (#193):
LaTeX Lab's block templates leave `\@topsepadd` at 0 pt, so
`careerdossier-components.sty` declares one `cdossier-closing-edge` key that
sets LaTeX Lab's own two closing keys instead.

#### Boundary ownership

The table above gives each token a value; this section decides which token a
reader actually *sees*. That is a consequence of how a gap is contributed, not
of any token's value, and it is why every boundary has exactly one owning token.

1. **Blocks compose with `\addvspace`, which takes the maximum and never the
   sum** (#168). Where two tokens meet at one boundary only the larger renders;
   the smaller is unreachable, and changing it produces neither a movement nor a
   diagnostic. #204 therefore gave every boundary one owning token and retired
   the two that could never win a maximum. A gap that must *not* participate in
   a maximum has to be a `\vspace`, and one that must has to be an
   `\addvspace` — `\CDossierRecordEntryGapSkip` was moved between the two for
   exactly that reason.
2. **A paragraph boundary also contributes `\parskip`, and `\addvspace` cannot
   absorb it.** `\parskip` is inserted at the *next* paragraph's start, after
   `\addvspace` has read `\lastskip`, so the two always add. A token at such a
   boundary is emitted as `\addvspace{token − \parskip}`, which is what makes
   the table's numbers the gaps a reader measures. The statement class does this
   for its headings; the shared header stack does it for every header line and,
   since #419, for the boundary below the stack.

Two consequences are worth stating because they look like omissions. A token
that cannot move the page is not a token — `\CDossierSharedHeaderParSkip` and
`\CDossierSharedHeaderAboveSkip` were both retired in #220 for that reason, one
because it cancelled itself and one because TeX discards glue at the top of a
page. And a token is not always read at the boundary it names: the three
`…ParSkip` tokens are copied into `\parskip` when the class loads, so they
govern every paragraph in the document rather than one gap.

Why a shared token was split rather than kept — `\CDossierProseParSkip` from
`\CDossierLetterParSkip` (#222), and the three header below-skips from one
shared token (#223) — is commented at each declaration in
`careerdossier-tokens.sty`, together with the retune that followed. The rule
behind all of them is the same: a token shared by two families makes retuning
either one a side effect on the other.

#### Dimensions outside the vertical rhythm

| Token | Derivation | `10pt` | `11pt` | `12pt` |
|---|---|---:|---:|---:|
| `\CDossierRuleThickness` | 0.04 × body size | 0.4 pt | 0.44 pt | 0.48 pt |
| `\CDossierListLabelSep` | 0.50 × body size | 5.0 pt | 5.5 pt | 6.0 pt |
| `\CDossierEmergencyStretch` | 2.00 × body size | 20 pt | 22 pt | 24 pt |
| `\CDossierFurnitureLeading` | leading of `\CDossierSizeFurniture` | 10 pt | 11 pt | 12 pt |

`\CDossierPageMargin` is 72.27 pt (1 in) for `margin=normal` and 36.135 pt
(0.5 in) for `margin=narrow`, independent of `fontsize`.

`\CDossierEmergencyStretch` is the project's single `\emergencystretch` policy,
applied unconditionally by all four classes (#272). It derives from the body
size, not the leading, because emergency stretch is spent on a line's interword
glue: a horizontal quantity takes the horizontal unit of the type scale. A
measure-derived alternative was measured and rejected (#310, which holds the
sweep) — the two are indistinguishable at matched magnitudes, so neither wins on
rescue efficacy, and a measure-derived token would be the only entry above not
on the type scale. Raising the ratio is not free: paragraphs that already set in
the third pass get re-broken, so a rescue bought for a stress fixture is paid
for by reflowing documents that were fine.

#### Page-furniture placement

The running header and folio are the only components placed by page geometry
rather than by the vertical rhythm, so `careerdossier-tokens` derives
`headheight`, `headsep`, and `footskip` from the resolved margin and the
furniture line height. The derivation, and why both keys resolve to a baseline
rather than a box edge, is commented at
`\__cdossier_tokens_apply_geometry:n` (#183).

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

The ranges come from two prose samples typeset at each combination and counted
from extracted text, so they are a measured band rather than a constant.

The letter, statement, and CV therefore default to `12pt` at `margin=normal`,
and **must not be quietly moved back to `11pt`**: 12 pt is the only body size
whose full-measure paragraph at a one-inch margin lands near the 45–90
characters Butterick gives, and within sight of Bringhurst's 45–75. At 11 pt the
same margin yields about 106. Capping `\textwidth` from a target measure
instead was rejected for this release: reaching roughly 80 characters at 11 pt
needs side margins near 1.68 in, which no career-services guidance endorses.

The résumé is the deliberate exception — `11pt` at `margin=narrow`, the longest
measure in the project — because one-page capacity was judged worth more than
the measure. The trade is bounded, since `\hfill`-split entry lines and short
bullets never approach the full measure, but it is real in a full-width summary
paragraph. Do not narrow the résumé's default without revisiting the capacity
argument: it is an accepted limitation, not an oversight.

#### Page-break penalties

`careerdossier-tokens.sty` owns the named typographic penalties (#171) and the
résumé/CV-only structural keep-together penalties (#145), applied by
`\CDossierApplyPageBreakPenalties`. All default to `10000`, which `\raggedbottom`
is what makes safe — and that `\raggedbottom` is inherited from `article.cls`
rather than set here, which is why the `tokens-*-defaults` baselines assert each
class's bottom-fill state (#335). The two routes away from that default were
measured and declined (#342, #351); both arguments, and the `\topskip` mechanism
behind the second, are commented beside the declarations.

One structural keep lives outside this module, in `careerdossier-letter.cls`:
the `\nobreak` between closing text and signature name (#421), which the club
and widow parameters cannot reach because it is two one-line paragraphs rather
than one paragraph's edges.

#### Hyphenation

`\hyphenpenalty` and `\exhyphenpenalty` are deliberately left at TeX's default
of `50` with no token (#309), and the `tokens-*-defaults` baselines record both
so a later change argues with a diff. The measurements that refused a higher
value — and the evidence that forbidding hyphenation outright is decisively
wrong — are commented beside the penalty declarations in
`careerdossier-tokens.sty`, reproducible with `make review-linebreak` (#316).

### `careerdossier-base.sty`

Shared profile state and validation: the project's data model, not its page. The
file's own header comment states the responsibilities and what it must not
define.

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

The engine guard, font loading, and the six semantic text roles — meaning, never
an implementation. The file's own header comment states the responsibilities.
It owns no colour and no dimension.

### `careerdossier-theme.sty`

Semantic monochrome colour, rule, and link tokens, and no dimension of any kind.
The file's own header comment states the responsibilities.

### `careerdossier-components.sty`

The reusable rendered pieces every class arranges: identity, furniture, section
rule, contact line, entry primitives, the link layer, and the derived PDF
metadata. The file's own header comment states the responsibilities in full, and
comments the two mechanisms that reach outside this package — the `\href` hook
against hyperref's `\hyper@link@`, and why `lua-ul` draws the link rule and
`ulem` was rejected on measurement. Neither is restated here.

Four boundary questions this package answers are architectural rather than
internal, and stay below.

Four boundary questions this package answers are recorded where they were
decided, not restated here. Each mechanism is commented at the code that
implements it in `careerdossier-components.sty`; each decision is in its issue.

| Question | The answer, in one line | Decided in |
|---|---|---|
| Why one stack serves both header shapes | The identity block and the statement header are the same sequence of optional lines, so *position* decides which gap token applies rather than presence — the defect that let an absent `headline` change the gap below the name. | #204, #224, #252 |
| Why `medium=print\|screen` resolves here | The classes validate the public value and forward it, but what it decides — whether page furniture is emitted at all — is owned here, so the policy exists once instead of once per class. | #184 |
| Why the de-emphasis role resolves here | `muted` combines a shape from typography with a colour from theme, and the dependency direction forbids either module from reaching into the other. This one loads both. | #271, #324 |
| Why PDF document metadata lives here | `/Title`, `/Author`, and `/Lang` derive from profile data this module already owns; the class contributes only the document type. Timing, precedence, and ordering against `hyperref` are commented at the implementation. | #276 |

Optional fields follow the project-wide rule: collect the present fields, then
insert separators between them, so an absent `phone` leaves no separator behind.

### `careerdossier-resume.cls`

Résumé-specific page behaviour for the English industry dossier. The file's own
header comment states the responsibilities. Reusable contact or identity logic
belongs in `careerdossier-components.sty`, not in the class.

### `careerdossier-letter.cls`

Industry and academic cover-letter behaviour, the two families separated by a
label- and metadata-only `family` option rather than by a second class. The
file's own header comment states the responsibilities.

### `careerdossier-statement.cls`

Released in `v0.5.0`, calibrated in `v0.6.0`. The shared statement document
model approved in issue #103: one class, seven documented `type` values, no
type-specific schema. The file's own header comment states the
responsibilities, why its headings are restyled rather than replaced (#177),
and which fields are profile-scoped rather than document-scoped.

Paper and body font are cross-class contracts rather than statement decisions:
every class implements `paper=letter|a4` (#105) and `bodyfont=serif|sans`
(#119), Letter and serif remaining the defaults, and no class introduces an
option name of its own for either. Broader named or per-role font combinations
remain design work in issue #120.

### `careerdossier-cv.cls`

Phase 2; released in `v0.2.0`. Academic-CV behaviour, including the
dependency-free manual-publication list. The file's own header comment states
the responsibilities and the must-nots. It does not load
`careerdossier-biblatex.sty` — see "Dependency direction" above for why that
separation is architectural.

### `careerdossier-biblatex.sty` (Phase 2, optional)

The opt-in boundary around BibLaTeX and Biber: the fixed academic profile and
author emphasis, and nothing else. The file's own header comment states the
responsibilities and the must-nots; the one that is an architectural constraint
rather than a scope decision — that `careerdossier-cv.cls` must not load it — is
under "Dependency direction" above.

## Class and package construction

### Build on a stable base class

Use `\LoadClass` rather than reimplementing LaTeX's entire page, list, footnote,
and section machinery. `article` is a suitable base for the résumé; the letter
class may build on `article` or `letter` if its output order is tested. Override
only what the document type requires.

### File identification and engine requirement

Every file should identify itself and its minimum kernel date:

```tex
\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesClass{careerdossier-resume}
  [2026-07-30 v0.6.0 ATS-conscious résumé class]
```

Choose the actual date based on the newest kernel interface used. The current LaTeX
class/package author guide notes that kernel key-value options
(`\DeclareKeys`/`\ProcessKeyOptions`) require at least the 2022-06-01 release.

Fail early and clearly under the wrong engine (the canonical check lives in
`careerdossier-typography.sty`). Do not allow pdfLaTeX or XeLaTeX to proceed until
a late, confusing font error appears. LuaLaTeX is the supported engine.

### Dependencies

- Load packages with `\RequirePackage`, not primitive `\input`.
- Specify a minimum version date when relying on a recent feature.
- Keep the dependency set small.
- Consult current package manuals and the tagging-status table before adding a
  dependency.
- Prefer kernel hooks through `\AddToHook` over legacy `every...` packages or
  direct patching.
- Avoid redefining unsupported LaTeX internals. Commands containing `@` are
  generally internal and may change.
- Use LaTeX box commands rather than TeX primitives where practical.

## Public and internal surfaces

`CONTRIBUTING.md` ("Coding conventions") owns the naming and interface rules;
[`API.md`](API.md#stability-policy) owns what publishing a name commits the
project to. Neither is restated here. What belongs to this document is which
surface owns what:

- The manual, `doc/careerdossier.tex`, describes every public name. A name
  absent from it is internal and may change without a migration note.
- Key families are split by responsibility rather than pooled into one global
  family:

  ```text
  cdossier/profile       cdossier/letter        cdossier/resume
  cdossier/cv            cdossier/entry         cdossier/publication
  cdossier/publications  cdossier/biblatex
  ```

- Profile and letter setup values are document-global; formatting stays local to
  the component or environment that sets it, so an entry or list must not leak
  spacing or fonts into what follows. Grouping is the scoping mechanism, which
  makes local-versus-global a design decision here, not an implementation
  detail.
- `careerdossier-base.sty` emits stored keys in one canonical order whatever the
  input order, and omits an absent optional key without leaving a separator.
  The extraction suites depend on both.

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

Use `\ClassError`, `\ClassWarning`, `\ClassInfo`, or their package equivalents.
Every error should state (1) what failed, (2) why it matters, (3) what the user
should change, and (4) where the relevant documentation is.

Conditions worth diagnosing include: compilation under the wrong engine; an
unavailable selected font; an unsupported option value; a missing applicant name;
and duplicate critical metadata. Do not silently fall back from an unavailable
requested font to an arbitrary system font.
