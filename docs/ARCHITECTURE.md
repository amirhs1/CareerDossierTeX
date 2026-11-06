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
which class loaded it. `careerdossier-components.sty` loads two more, so a class
reaches them without naming them:

```text
careerdossier-{resume,letter,cv,statement}.cls
        │
        ├── careerdossier-tokens.sty       size and spacing
        ├── careerdossier-typography.sty   engine guard, fonts, text roles
        ├── careerdossier-theme.sty        colour
        ├── careerdossier-components.sty   rendered parts
        │       ├── careerdossier-links.sty      links and linked fields
        │       └── careerdossier-metadata.sty   derived PDF metadata
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
                                        renders identity, contact line, entry
                                        primitives, furniture, section rules,
                                        list breaks; links and PDF metadata
                                        through the two packages it loads
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

Nor does a class write out the options it shares with the others. Every class
takes `fontsize`, `margin`, `paper`, `bodyfont`, `medium`, and `muted`, and the
resume and CV also take `entrymeta`; `careerdossier-base.sty` declares them,
and each class calls its generators with its own module name and key path
(#266). See `careerdossier-base.sty` below.

The one option a class also accepts inside the document is `entrymeta`, as a
key in `\CDossierSection`'s optional argument on the resume and CV (#569). The
class owns the key and its `unknown-section-key` error, and hands the value to
`careerdossier-components.sty`, which validates it against the same
declaration its package option uses and restores the document's value at every
section, so a value never outlives the section that set it.

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
| `\CDossierRecordSectionBelowSkip` | 0.6875 | 8.25 pt | 9.35 pt | 9.96875 pt |
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

Two ordering relations bind a retune, and neither can be stated at a single
declaration because each relates one token to another:

- The heading-to-rule gap must stay unambiguously smaller than the
  rule-to-content gap — `\CDossierRecordSectionRuleGapSkip` against
  `\CDossierRecordSectionBelowSkip`, currently 1:2.2. At 1:2 the rule starts
  to read as a divider floating between two blocks rather than as part of the
  heading above it. A retune may move both numbers, but not their order.
- Both list-edge ratios stay below `\CDossierRecordSectionBelowSkip` (#191,
  #206), or entering a list would look like entering a section.

`tests/regression/tokens-invariants.lvt` asserts both relations at 10, 11, and
12 pt. From `v0.7.0` until #420, `\CDossierRecordListEdgeBelowSkip` (0.50)
exceeded `\CDossierRecordSectionBelowSkip` (0.4375), and nothing asserted the
second relation.

Every other constraint on these values is commented at the declaration it
governs in `careerdossier-tokens.sty`, which is also where the measurement
behind it lives: the rule gap's hard lower bound, the heading's own depth
(#169); why the four `Prose…` tokens own the complete gap including the
`\parskip` an adjacent paragraph contributes, and must stay above
`\CDossierProseParSkip` (#177); and the `0.25` floor on the list opening edge,
which Poppler's reading order imposes rather than this design (#219, #230).

The tagged path reaches the same closing edge by a different route (#193):
LaTeX Lab's block templates leave `\@topsepadd` at 0 pt, so
`careerdossier-components.sty` declares one `cdossier-closing-edge` key that
sets LaTeX Lab's own two closing keys instead. "Testphase interfaces stay
behind one wrapper", below, states the rule that keeps those keys there.

##### Record and prose section headings render alike

The rule under a record section heading is part of the heading (#420; the
maintainer decided on 2026-08-15 that the two kinds of section heading render
alike, and on 2026-11-06 which reading of "alike" applies). A record heading
therefore ends at its rule, and the gap compared with a prose section is the
white from the rule to the body against the white from a prose heading to the
text below it. The white above is the same for both, because both are
body-to-heading with the same token and heading size.

The two below-gaps are built differently, so they are compared as a band
rather than as two numbers. A rule takes no interline glue, so the record white
is `\CDossierRecordSectionBelowSkip` alone, whatever the heading's glyphs. The
prose white includes interline glue, `baselineskip - depth(heading) -
height(next)`, so a heading with descenders gets less of it. Measured with
`make review-spacing` on the same two heading texts in both fixtures, in
points, ink to ink:

| | 10 pt | 11 pt | 12 pt |
|---|---:|---:|---:|
| White above, both kinds | 13.12 | 14.56 | 15.39 |
| Prose below, heading with a descender (`Experience`) | 7.27 | 8.57 | 8.91 |
| Prose below, heading without (`Research Vision`) | 9.57 | 11.08 | 11.62 |
| Record rule to body | 8.25 | 9.35 | 9.97 |
| Record minus the band's midpoint | -0.17 | -0.47 | -0.30 |

The tolerance is that the record white lies inside the prose band and within
one grid step (1/16 of the body baseline: 0.75 / 0.85 / 0.91 pt) of its
midpoint, at every size. The report prints this comparison as
`build/spacing/section-alike.tsv`. Two grid values meet it: 0.6875 and 0.75.
0.6875 is closer at 10 and 12 pt, 0.75 at 11 pt (0.38 against 0.47 pt), and
0.6875 has the smaller total error and spends less space. 0.625 misses by more
than a step at 11 and 12 pt.

Two other readings were measured and set aside. Matching the heading-to-rule
clearance would need a rule gap of 0.8125, which puts the rule closer to the
body than to its heading and breaks the first relation above. Treating the rule
as an object inside the gap compares the span from heading to body across the
rule. That span was already within 0.27–0.55 pt of prose, but it reads as
alike only if the rule belongs to neither block, and the rule sits 1.4–4.4 pt
under its heading.

The record section pair is consequently not held to the `above >= 2 x below`
floor that the other heading pairs meet; `tokens-invariants.lvt` explains why.

#### Testphase interfaces stay behind one wrapper

An unstable LaTeX Lab *testphase* interface is reached only through a
CDossier-owned wrapper in `careerdossier-components.sty` (#478). The closing
edge above is the worked case. LaTeX Lab's block-template keys `end-vspace` and
`end-extra-vspace` appear there and nowhere else, behind the one
`cdossier-closing-edge` key the classes use. If a later LaTeX Lab renames or
withdraws them, that key becomes a no-op that still consumes its value: a tagged
build warns once and keeps LaTeX Lab's own closing spacing instead of stopping
at an unknown-key error. One file changes when the interface does, not every
class.

The rule names a tier, not every tagging call. The tagpdf expl3 API
(`\tag_if_active:TF`, `\tag_struct_begin:n`, `\tag_mc_begin:n`, and the rest of
`\tag_…`) is documented and stable, so it is called directly and not wrapped.
Today `careerdossier-typography.sty`, `careerdossier-cv.cls`, and
`careerdossier-resume.cls` call it. Putting an indirection in front of a stable
interface would cost a layer and buy nothing.

`tests/lint/run-testphase-keys.sh` enforces the first half: no Work file but
`careerdossier-components.sty` names a LaTeX Lab block-template vertical-space
key, in code or in a comment. `docs/TESTING.md`, "Testphase key lint", lists
the keys and the controls.

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

The resume is the deliberate exception — `11pt` at `margin=narrow`, the longest
measure in the project — because one-page capacity was judged worth more than
the measure. The trade is bounded, since `\hfill`-split entry lines and short
bullets never approach the full measure, but it is real in a full-width summary
paragraph. Do not narrow the resume's default without revisiting the capacity
argument: it is an accepted limitation, not an oversight.

#### Page-break penalties

`careerdossier-tokens.sty` owns the named typographic penalties (#171) and the
resume/CV-only structural keep-together penalties (#145), applied by
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
value — of the pair, and of each penalty alone (#542) — and the evidence that
forbidding hyphenation outright is decisively wrong are commented beside the
penalty declarations in `careerdossier-tokens.sty`, reproducible with
`make review-linebreak` (#316).

### `careerdossier-base.sty`

Shared profile state and validation: the project's data model, not its page. The
file's own header comment states the responsibilities and what it must not
define.

It is also where shared class options are declared (#266). One internal
generator, `\__cdossier_base_declare_shared_options:nn`, declares the six
options every class takes; a second, `\__cdossier_base_declare_record_options:nn`,
declares `entrymeta` for the two record classes only, on the same Record versus
Prose line as the `\CDossierRecord…Skip` and `\CDossierProse…Skip` token
families. Each class loads `careerdossier-base.sty` before it processes its
options and calls them with its own module name and key path, so the error text
still names the class. For each option a generator emits the class's storage
variable, its `unknown-<key>` message, and its key properties, and sets the
default wherever every class agrees on it. The class keeps everything that
differs: its `fontsize` and `margin` defaults, its own options (`family`,
`type`, `numbering`), its `unknown-option` message, and the forwarding.

The owning packages keep their own declarations, so each package still
validates what it receives and works without a class. A value list therefore
lives in two places, the generator and the owning package, and the option lint
compares them (`docs/TESTING.md`, "Option lint"). `paper` has no owning
package: the generator is its only declaration.

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

Declaring a language is not translating one, and the profile's `language` key
(#288) does only the first. It records which language the author's own text is
in, so that the PDF's `/Lang` is true and a screen reader picks the right
voice. It changes no emitted string, loads no `babel` or `polyglossia`, and
sets no hyphenation; a document in French still supplies its own salutation and
closing, as above. So the key does not contradict this section: the toolkit's
strings stay English, and only the declaration follows the document.

### `careerdossier-typography.sty`

The engine guard, font loading, and the six semantic text roles — meaning, never
an implementation. The file's own header comment states the responsibilities.
It owns no colour and no dimension.

### `careerdossier-theme.sty`

Semantic monochrome colour, rule, and link tokens, and no dimension of any kind.
The file's own header comment states the responsibilities.

### `careerdossier-components.sty`

The reusable rendered pieces every class arranges: identity, furniture, section
rule, contact line, and entry primitives. The file's own header comment states
the responsibilities in full. It owns neither links nor PDF document metadata:
it loads `careerdossier-links.sty` and `careerdossier-metadata.sty`, below, so
that every class reaches both through the `\RequirePackage` list it already
has.

Three boundary questions this package answers are recorded where they were
decided, not restated here. Each mechanism is commented at the code that
implements it in `careerdossier-components.sty`; each decision is in its issue.

| Question | The answer, in one line | Decided in |
|---|---|---|
| Why one stack serves both header shapes | The identity block and the statement header are the same sequence of optional lines, so *position* decides which gap token applies rather than presence — the defect that let an absent `headline` change the gap below the name. | #204, #224, #252 |
| Why `medium=print\|screen` resolves here | The classes validate the public value and forward it, but what it decides — whether page furniture is emitted at all — is owned here, so the policy exists once instead of once per class. Its link half is handed to `careerdossier-links.sty` through one setter. | #184, #465 |
| Why the de-emphasis role resolves here | `muted` combines a shape from typography with a colour from theme, and the dependency direction forbids either module from reaching into the other. This one loads both. | #271, #324 |

Optional fields follow the project-wide rule: collect the present fields, then
insert separators between them, so an absent `phone` leaves no separator behind.

### `careerdossier-links.sty`

Every link the toolkit emits and how a link looks: the decoration role
`\CDossierLinkStyle` and its `\CDossierPlainLinks` suppression, the `\href`
hook that reaches an author's own anchor text, the single link chokepoint with
its `#` rewrite, scheme normalisation, `\CDossierLink`, the one-time warning
when `hyperref` is absent, and the profile fields that become links. It lays out
nothing and does not load `hyperref`. The file's own header comment states the
responsibilities and its interfaces, and comments the two mechanisms that reach
outside it — the `\href` hook against hyperref's `\hyper@link@`, and why
`lua-ul` draws the link rule and `ulem` was rejected on measurement. Neither is
restated here.

| Question | The answer, in one line | Decided in |
|---|---|---|
| Why links are not part of `careerdossier-components` | Nothing else in that package called into the link layer; its one real dependency, the link half of `medium`, now arrives through a setter, so the dependency runs one way. The analysis is on the issue. | #465 |
| Why its warnings still say `careerdossier-components` | That is what the log has always said and what the regression baselines pin, so the move changed no output. | #465 |

### `careerdossier-metadata.sty`

The document's derived PDF metadata: `/Title` and `/Author` from the profile's
`name` and the document type a class declares, `/Lang` from the profile's
`language` or `en`, and the `/DisplayDocTitle` viewer preference. It renders nothing, carries no dimension,
and does not load `hyperref`. Its one inbound interface is the private
`doctype` declaration each class makes once. The file's own header comment
states the responsibilities; timing, precedence on both build paths, and the
ordering against `hyperref` are commented at the implementation.

| Question | The answer, in one line | Decided in |
|---|---|---|
| Why PDF document metadata is derived in a shared package | `/Title`, `/Author`, and `/Lang` derive from profile data, so one implementation serves every class; the class contributes only the document type. | #276 |
| Why it is not part of `careerdossier-components` | It shares no code with the rendered parts, and has its own suite, `make metadata`; `careerdossier-components` loads it, so no class loads it by name. | #464 |
| Why the language is a profile key, not a class option | Language is profile data, not a layout decision, so `careerdossier-base.sty` owns and checks it beside the other profile keys and this package only reads it; a class option would repeat one declaration in four classes. | #288 |

### `careerdossier-resume.cls`

Resume-specific page behaviour for the English industry dossier. The file's own
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
and section machinery. `article` is a suitable base for the resume; the letter
class may build on `article` or `letter` if its output order is tested. Override
only what the document type requires.

### File identification and engine requirement

Every file should identify itself and its minimum kernel date:

```tex
\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesClass{careerdossier-resume}
  [2026-07-30 v0.6.0 ATS-conscious resume class]
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

`CONTRIBUTING.md`, "Coding conventions", owns the naming and interface rules;
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
