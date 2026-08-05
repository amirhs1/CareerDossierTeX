# CareerDossierTeX Roadmap

Release scope, phase boundaries, and explicit non-goals — what each release is
for, and what it deliberately excludes. **Nothing here is a support statement.**
A feature described in a planned phase does not exist yet; `README.md` and
[`API.md`](API.md) describe what is actually released.

## Product direction

CareerDossierTeX is a reusable LuaLaTeX toolkit for creating consistent career documents from shared profile data.

The project follows incremental releases. Each implementation issue should
produce one complete, documented, and tested vertical slice. Tests are added
under `tests/` with the behavior they protect, not collected into a separate
test pass at the end of a milestone.

> **Current status:** `v0.7.0 — Page Furniture, Output Medium, and Spacing
> Ownership` is released. `v0.3.0` is dropped. The next planned release is
> `v0.8.0 — Semantic Structure and Tagged Output`, followed by `v0.9.0 —
> Documentation, Examples, and Release Readiness` and `v1.0.0 — Stable Public
> API`.
>
> **Renumbered on 2026-08-01.** `v0.7.0` was numbered `v0.6.1` until then. It
> adds new public API — the `medium` option and new spacing tokens — which is a
> minor release under Semantic Versioning, not a patch; it also renames public
> design tokens and retunes calibrated values, so documents reflow. The former
> `v0.7.0 — Examples and Templates Revision` moved to `v0.8.0`. See
> [issue #205](https://github.com/amirhs1/CareerDossierTeX/issues/205).
>
> **Reorganised on 2026-08-05.** By then `v0.8.0` held eleven structure and
> semantics issues against three examples issues, so its title no longer
> described its contents. It was retitled `v0.8.0 — Semantic Structure and
> Tagged Output`, and the examples and documentation work moved into `v0.9.0`,
> retitled from `Documentation, Packaging, and Release Readiness` to
> `Documentation, Examples, and Release Readiness`. `v1.0.0` moved from
> `Phase 8` to `Phase 9` to make room for the `v0.9.0` phase section, which this
> document previously did not have. `v1.1.0 — Themes and Font Families` was
> closed empty; its deferred work has no milestone. See
> [issue #279](https://github.com/amirhs1/CareerDossierTeX/issues/279).

## Release overview

| Version | Release goal | Status |
|---|---|---|
| `v0.1.0` | English industry résumé and cover letter | Released |
| `v0.1.1` | English industry dossier plus metadata and build corrections | Released |
| `v0.2.0` | Academic CV, academic letter, and bibliography support | Released |
| `v0.2.1` | PDFKit text-extraction correction | Released |
| `v0.4.0` | LuaLaTeX transition and opt-in tagged-PDF preview | Released |
| `v0.3.0` | Farsi, bilingual, and right-to-left support | **Dropped — 2026-07-16** |
| `v0.5.0` | Statement classes and broader customization | Released |
| `v0.6.0` | Calibrated type scale, vertical rhythm, and page geometry | Released |
| `v0.7.0` | Page furniture placement, the `medium` output-context option, and spacing ownership | Released |
| `v0.8.0` | Semantic structure, tagged-output metadata, and the public typography and colour roles | Planned |
| `v0.9.0` | Documentation set, revised examples, PDF manual, and CTAN archive | Planned |
| `v1.0.0` | Stable, documented public API | Planned |
| `v1.1.0` | Themes and font families | **Closed empty — 2026-08-05** |

Repository milestones are tracked on the GitHub milestones page:

```text
https://github.com/amirhs1/CareerDossierTeX/milestones
```

## Phase numbering

The Project's `Phase` field is the canonical numbering; the headings below
follow it. Every shipped major or minor release has a phase of its own. A patch
release does not — its issues carry the phase of the minor release they correct,
which is why `v0.1.1` and `v0.2.1` appear in the release overview above but have
no phase heading here.

A release that never ships has no phase number at all. `v0.3.0` **held**
`Phase 3` and gave it up when it was dropped, and the Project reused the slot for
`v0.4.0`; `v1.1.0` was closed empty before it had an option to give up. Both
therefore appear unnumbered. See `docs/NAMING-CONVENTION.md` §10.

The two forms differ deliberately — this document keys each phase to its
version, the Project uses a short label — so they cross-walk as follows:

| This document | Project `Phase` option |
|---|---|
| `Phase 0: inventory and baseline` | `Phase 0 — Inventory` |
| `Phase 1: v0.1.0` | `Phase 1 — Industry` |
| `Phase 2: v0.2.0` | `Phase 2 — Academic` |
| `v0.3.0` **(dropped, unnumbered)** | *(none — slot reused)* |
| `Phase 3: v0.4.0` | `Phase 3 — Engine and Accessibility` |
| `Phase 4: v0.5.0` | `Phase 4 — Expansion` |
| `Phase 5: v0.6.0` | `Phase 5 — Calibration` |
| `Phase 6: v0.7.0` | `Phase 6 — Spacing Ownership and Output Medium` |
| `Phase 7: v0.8.0` | `Phase 7 — Semantic Structure and Tagged Output` |
| `Phase 8: v0.9.0` | `Phase 8 — Documentation, Examples, and Release Readiness` |
| `Phase 9: v1.0.0` | `Phase 9 — Stable API` |
| `v1.1.0` **(closed empty, unnumbered)** | *(none — never had an option)* |

The two patch releases have no heading of their own: `v0.1.1` carries
`Phase 1 — Industry` and `v0.2.1` carries `Phase 2 — Academic`, alongside the
minor release each one corrects. `Phase 0 — Inventory` runs the other way — it is
the pre-release baseline and has no milestone.

## Phase 0: inventory and baseline

### Goal

Understand and preserve the strongest existing résumé and cover-letter implementations before refactoring.

### Deliverables

- select baseline résumé and letter designs;
- compile and save reference PDFs;
- record dependencies and public commands;
- identify duplicated code;
- begin `docs/MIGRATION.md`;
- define the initial public interface in `docs/API.md`.

### Completion condition

The project has a documented baseline against which later changes can be compared.

## Phase 1: `v0.1.0 — English Industry Dossier`

### Goal

Publish the smallest useful CareerDossierTeX release.

### Included

- XeLaTeX;
- English;
- US Letter paper;
- monochrome theme;
- one résumé layout;
- one industry cover-letter layout;
- shared profile metadata;
- required-field validation;
- optional-field separator handling;
- package/class regression coverage for implemented Phase 1 behavior;
- smoke, error-path, layout-stress, and extraction fixtures under `tests/`;
- example résumé and letter;
- local `latexmk` builds;
- GitHub Actions compilation;
- release documentation.

### Explicit non-goals

- academic CV;
- bibliography or Biber;
- Farsi or bilingual documents;
- RTL layout;
- statement classes;
- A4 paper;
- color themes;
- icons;
- CTAN packaging.

### Release criteria

- résumé and letter compile locally with XeLaTeX;
- both reuse the same profile file;
- missing required metadata produces a clear error;
- missing optional fields do not leave empty separators;
- extracted résumé text follows logical reading order;
- every implemented behavior has the relevant committed test under `tests/`;
- the accumulated regression, smoke, layout, and extraction suites pass;
- CI builds both examples;
- README and API documentation match actual behavior;
- tag and GitHub Release `v0.1.0` are published.

## Phase 2: `v0.2.0 — Academic Dossier`

### Goal

Extend the shared foundation to academic applications.

### Included

- `careerdossier-cv.cls`;
- academic cover-letter family;
- `careerdossier-biblatex.sty`;
- optional Biber integration;
- manual publication entries;
- multi-page CV support;
- running headers and page numbers;
- Scholar and ORCID fields;
- long-entry and page-break tests added with the academic features they cover;
- supported no-BibLaTeX CV, Biber-backed CV, and academic-letter examples; and
- user, contributor, API, architecture, migration, roadmap, and changelog
  documentation matched to implemented behavior.

These interfaces are released in `v0.2.0`.

### Release criteria

- long CVs page-break safely;
- bibliography support remains optional;
- a CV without `biblatex` still builds;
- a Biber example builds through `latexmk`;
- academic and industry documents reuse the same profile;
- every supported example builds locally and in CI;
- the accumulated regression, extraction, smoke, layout, and bibliography
  suites pass; and
- README and API documentation match the tagged behavior.

### Explicit non-goals

- pdfLaTeX or LuaLaTeX;
- Farsi, bilingual, or RTL documents;
- A4 paper;
- color themes, font presets, icons, or bundled fonts;
- statement classes;
- alternate bibliography or citation styles;
- automatic import from ORCID, Scholar, DOI services, or external APIs; and
- PDF/UA or broad ATS-conformance claims.

## `v0.3.0 — Farsi and Bilingual Support` **(dropped — 2026-07-16)**

> **Status:** dropped on 2026-07-16. The milestone is closed and the release is
> not planned. CareerDossierTeX is English-only, and no language-abstraction
> module exists (see `docs/ARCHITECTURE.md`). This section is retained as a
> design record, not as committed scope — nothing here may be implemented or
> documented as current.
>
> **No phase number:** this section is deliberately unnumbered. The Project's
> `Phase` field reused the `Phase 3` slot for the engine and accessibility work
> that shipped as `v0.4.0`, and a dropped release does not retain a phase
> number (see `docs/NAMING-CONVENTION.md` §10). Refer to this section by name,
> never by number.
>
> **Consequence:** mature RTL support via `bidi` was the main reason the
> project stayed XeLaTeX-only. With multilingual work dropped, that constraint
> no longer applies, which removes the structural argument against evaluating
> a LuaLaTeX migration.

### Goal

Add multilingual and mixed-direction documents without duplicating the class system.

### Deliverables if revived

- `language=english|farsi|bilingual`;
- `main-language=english|farsi`;
- translation tables;
- Farsi font configuration;
- RTL and mixed-direction helpers;
- mirrored dates, bullets, and layout components;
- LTR handling for email, URL, ORCID, and Latin numbers;
- Farsi and bilingual examples;
- direction and glyph tests.

### Architectural rule

Extend existing classes:

```latex
\documentclass[language=farsi]{careerdossier-cv}
```

Do not create separate language-specific classes unless a future document model is genuinely different.

## Phase 3: `v0.4.0 — LuaLaTeX Transition and Tagged-PDF Preview`

### Goal

Replace XeLaTeX with LuaLaTeX as the sole supported engine, preserving the
English public API and visual design, and add a validated opt-in tagged-PDF path
for the named fixture profiles.

This is a **breaking toolchain change**. Documents keep their classes, options,
keys, and commands; the build command changes from `latexmk -xelatex` to
`latexmk -lualatex`, and XeTeX-specific preamble code stops working.

### Included

- LuaLaTeX-only engine guard; XeLaTeX and pdfLaTeX fail early with an actionable
  diagnostic;
- removal of the XeTeX-only `\XeTeXgenerateactualtext` primitive;
- portable font resolution through `luaotfload` on macOS and pinned Linux CI;
- re-baselined visual layout and extraction against `v0.2.0`;
- `Makefile`, `l3build`, test runners, and CI migrated to LuaLaTeX;
- opt-in `\DocumentMetadata{tagging=on}` semantic structure covering headings,
  lists, links, and layout artifacts;
- validation of the four named fixtures with an independent validator and
  screen-reader reading-order checks;
- migration notes, canonical documentation, and release preparation.

### Explicit non-goals

- Farsi, bilingual, or RTL support (dropped);
- tagging enabled by default;
- any broad PDF/UA, WCAG, or ATS conformance claim for arbitrary user documents;
- public API, paper-size, or theme changes.

### Release criteria

- every supported example compiles locally and in CI under LuaLaTeX;
- XeLaTeX and pdfLaTeX produce a clear, tested engine error;
- layout and extraction are reviewed against `v0.2.0` rather than silently
  re-baselined;
- untagged output is unchanged when tagging is not enabled;
- tagged fixtures pass structure, extraction, and artifact checks, and the
  validator and screen-reader results are recorded with tool versions.
  **Status:** met for macOS. The four named profiles pass veraPDF `ua2` and a
  three-extractor round trip (section 7.1), and a maintainer VoiceOver pass on
  2026-07-20 confirmed correct reading order with all decorative and repeated
  page furniture silent (section 7.2). NVDA on Windows stays platform-deferred;
  the release documents that rather than claiming a Windows result;
- `docs/MIGRATION.md` gives XeTeX-preamble users an actionable upgrade path;
- documentation claims no more than the fixtures actually verify.

## Phase 4: `v0.5.0 — Statements and Customization`

### Goal

Support additional application documents and broader visual configuration.

### Planned deliverables

- `careerdossier-statement.cls`;
- one class with `research`, `teaching`, `teaching-philosophy`, `diversity`,
  `artist`, and `purpose` types;
- A4 paper;
- a cross-class `bodyfont=serif|sans` option with the current serif default;
- additional stress tests and documentation.

The maintainer deferred color themes, named or per-role font combinations,
optional icons, and the Windows/NVDA reading-order check on 2026-07-22. Their
future milestone remains undecided; they are not release blockers for
`v0.5.0`.

## Phase 5: `v0.6.0 — Calibrated Type Scale and Rhythm`

### Goal

Replace the mixture of per-class settings and inherited `article` defaults with
one shared, proportional design system, driven by two public inputs —
`fontsize` and `margin` — applied identically by every document class.

### Governing rules

1. Every type size is a ratio of the body size, snapped to whole points.
2. Every vertical gap is a ratio of the body baseline.
3. Therefore `10pt`, `11pt`, and `12pt` are one design at three scales, not
   three differently proportioned designs.

### Included

- `careerdossier-tokens.sty`: the single source of truth for the type scale,
  vertical rhythm, rule weight, list metrics, and page geometry;
- `fontsize` (`10pt`, `11pt`, `12pt`) and `margin` (`normal`, `narrow`) on all
  four classes; `fontsize` is new on the letter and statement classes, `12pt`
  is new everywhere;
- per-class defaults rather than one uniform default: the résumé stays compact
  (`11pt`, `narrow`), while the CV, letter, and statement default to `12pt` at
  the shared `normal` margin to
  keep prose line length within a readable range at a conventional margin;
- one shared page-furniture design (running header from page two, `Page N of
  M` folio) across all four classes, with the folio suppressed on single-page
  documents;
- a keep-together page-break policy for section headings, entry headings, and
  bullet groups;
- reference PDFs for every `fontsize` × `margin` combination, across all four
  document types.

### Agreed defaults and their measured cost

Defaults are per class, not uniform, because document conventions differ: the
résumé is `11pt` at `margin=narrow`, and the CV, letter, and statement classes
are `12pt` at `margin=normal`. The measured characters per line for each
combination live in [`ARCHITECTURE.md`](ARCHITECTURE.md#careerdossier-tokenssty),
which records the `\textwidth` values and the counting method alongside them.

The prose classes take `12pt` specifically to control measure: at `normal`,
`11pt` runs longer than the conventional 45–90 guidance while `12pt` lands just
inside it. Capping `\textwidth` from a
target measure was considered and rejected — reaching 80 characters at `11pt`
needs side margins near 1.68 in, which no career-services guidance endorses.

**Known accepted limitation:** the résumé default is the longest measure in the
project, accepted for one-page capacity rather than overlooked. It is stated
for authors in `docs/API.md`, with the rationale in `docs/ARCHITECTURE.md`.

### Explicit non-goals

- color themes, named or per-role font combinations, and icons — still
  deferred, undecided future milestone (see Phase 4);
- any change to public content commands, key names, contact rendering,
  colours, or fonts;
- a language- or direction-abstraction option (see the dropped
  `v0.3.0 — Farsi and Bilingual Support` section).

### Removed

- the `density` (`compact`/`standard`) class option, replaced by the
  calibrated, proportional rhythm derived from `fontsize`.

### Release criteria

- no `.sty` or `.cls` file mentions `density`, and no file under `examples/`
  passes it as an option — `grep -rnE 'density[[:space:]]*=' *.sty *.cls
  examples/` returns nothing. Match on `density=`, not the bare word:
  `examples/statements/artist-statement.tex` uses "density" as ordinary
  English prose;
- the résumé and CV classes reject `density=` with their actionable
  unknown-option message, pinned by `tests/smoke/resume-density-option.tex`
  and `tests/smoke/cv-density-option.tex` at the class layer and
  `tests/regression/tokens-errors.lvt` at the package layer. These fixtures
  are the enforcement of the removal and are expected to name the option;
  mentions in `CHANGELOG.md`, `docs/MIGRATION.md`, and `docs/API.md` are
  required by the breaking-change documentation rule. Neither is an exception
  to be eliminated;
- no literal type size or structural vertical space outside
  `careerdossier-tokens.sty`;
- no `\geometry` call outside the shared geometry primitive;
- all four classes accept `fontsize` and `margin` and reject unsupported
  values with an actionable message;
- every type size in the output is a whole number of points;
- bullets align with section headings, section rules, and entry titles;
- a one-page document carries no folio; a multi-page document carries a folio
  throughout and a running header from page two;
- tagged builds still mark furniture and the section rule as artifacts;
- CI builds every example at all three `fontsize` values.

Tracked under
[milestone `v0.6.0`](https://github.com/amirhs1/CareerDossierTeX/milestone/9)
and [epic #137](https://github.com/amirhs1/CareerDossierTeX/issues/137).

## Phase 6: `v0.7.0 — Page Furniture, Output Medium, and Spacing Ownership`

### Goal

Reclaim ownership of vertical placement and spacing for the calibrated design
system released in `v0.6.0`, make page furniture selectable by output context,
and retune the vertical-rhythm ratios once every gap is owned by a token.

The unifying concern is not page furniture as such. In several places a
vertical dimension is decided by a third-party default or a hard-coded constant
rather than by the design system that is supposed to own it: `geometry`'s
defaults place the running header and folio (#183); LaTeX's single `topsep`
cannot express a different space above and below a list (#191);
`careerdossier-biblatex` hard-codes the bibliography's inter-entry gap at `6pt`
(#196); LaTeX Lab's block default decides the space below a list on the tagged
path (#193); and the prose `\parskip` floors every header gap, leaving the
header tokens unable to express the spacing they name (#204). Each item hands
one such decision back to the token that should own it. #203 then makes the
token names consistent, and #206 sets the values.

Two items do not share that concern; both arrived from implementing #184 in
PR #210. #212 widens the named-values class error from `medium` to every
choice-valued option — the inconsistency that PR knowingly left behind as out of
scope. #211 investigates a Biber date-parsing failure that the same work
uncovered but did not cause.

**Scope expanded on 2026-08-03.** A trial retune under #206 established that
four of the values it had to set were pinned by defects rather than chosen by
design: the list-edge opening token by an extraction-order fault (#219), the
shared header gap by a cross-family coupling (#223), the prose paragraph gap by
one token serving both the letter and the statement (#222), and two header
tokens that could not affect output at any value (#220). Tuning against those
would have reflowed every document twice in consecutive releases, so #219–#225
were added ahead of #206. As shipped, all six are output-neutral or corrective —
the milestone description's "five of the six" predates #219 resolving as
documentation and tests only — and #206 remains the release's one deliberate
reflow. #220, #222, and #223 change the public token list and #224 adds three
public commands, so the breaking surface and `MIGRATION.md` grew accordingly.

A further group landed as the work proceeded: #218 (the CV's manual publication
list did not build under tagging), #232 and #233 and #236 (option-error
reporting and the lint that keeps it from regressing), #242 (three
public-prefixed internal primitives made private), and the documentation and
process issues #205, #208, #213, #239, #241, #246, #252, and the fixture audit
#255.

**No type-scale step or margin preset changes value.** The vertical-rhythm
ratios do, under #206 and against its stated design rules.

Rendered output therefore moves in two ways: it is *corrected* where a spacing
decision was never the design system's to begin with, and it *reflows by
design* where the ratios are retuned.

| Item | Rendered effect |
|---|---|
| #183 | furniture moves within the existing margins; `\textheight` and `\textwidth` are unchanged |
| #184 | defaults to `print`, reproducing current output exactly |
| #191 | none — both tokens keep the single token's value |
| #195 | none — generated review filenames only |
| #196 | bibliography entries move up as the hard-coded `6pt` gap closes |
| #193 | the tagged path's space below a list changes to match the untagged path |
| #211 | none — the reported failure did not reproduce; see below |
| #212 | none — error text only; no document that compiles today is affected |
| #204, #220, #222, #223, #224 | header and list boundaries move where a token could not previously express its gap; the token splits themselves are output-neutral |
| #206 | every document reflows by design; no combination changes page count |
| #218, #219, #232, #233, #236, #242 | none for a document that builds today; #218 makes a tagged CV build at all |

The new public surface is one additive class option whose default reproduces
current output exactly (#184), three additive header-composition commands
(#224), and a reworked vertical-spacing token vocabulary: renamed onto one
convention (#191, #203), split per family where one token served two (#222,
#223), extended where a boundary had no token (#204), and reduced where a token
could not reach the page (#204, #220). Every rename and retirement is
source-compatible for a document that does not read the token by name.

### Included

- furniture placement derived from the resolved margin rather than from
  `geometry` package defaults: `headheight`, `headsep`, and `footskip` are
  computed so that the running header is vertically centred in the top margin
  and the `Page N of M` folio is vertically centred in the bottom margin, at
  every `fontsize` × `margin` combination and on both `letter` and `a4`;
- a `headheight` large enough for the furniture step of the type scale at every
  `fontsize`, replacing the inherited fixed `12pt`;
- a public `medium` option (`screen`, `print`) on all four document classes,
  defaulting to `print`: `print` keeps today's behaviour (running header from
  page two, folio throughout, both suppressed on a single-page document) and
  `screen` emits no running header and no folio on any page. Both open
  questions on the proposal are settled: the option is named `medium`, and
  `screen` suppresses the running header as well as the folio;
- an actionable class error for an unsupported `medium` value, naming the
  accepted values instead of falling back to `l3keys`' generic choice error
  (#184). As shipped in PR #210 this left `medium` the only option that explains
  itself, which #212 below corrects;
- every other choice-valued public option naming its accepted values and its
  owning module when it rejects one (#212): `fontsize`, `margin`, `paper`, and
  `bodyfont` on all four classes, the letter's `family`, and the same options on
  `careerdossier-typography` and `careerdossier-tokens` for direct package users.
  No option name, accepted value, or default changes — only the text of an error
  that already stops the build — so `docs/MIGRATION.md` needs no entry. The
  smoke suite's `*-bad-<option>` expectations match on the generic wording and
  are updated with it;
- splitting the single list-edge token into `\CDossierRecordListEdgeAboveSkip`
  and `\CDossierRecordListEdgeBelowSkip`, so the space above a list and the
  space below it can be tuned independently (#191). Both keep the value the
  single token had, so no list moves;
- the bibliography's inter-entry gap reading `\CDossierRecordItemSepSkip`
  instead of a hard-coded `6pt`, so a `biblatex` publication list and a
  `CDossierPublications` list share one rhythm at every `fontsize` (#196);
- a diagnosis and named CI coverage for the Biber date-parsing failure reported
  in #211, which **did not reproduce**. It was reported as Biber 2.21 rejecting
  every `date` value while accepting the legacy `year` field — dropping every
  year from the rendered bibliography and misordering the entries — but
  `make bibliography-test` passes on a clean tree with the same binary, and CI
  had been running that suite since #69, buried inside the job named `cv`. The
  likely mechanism is an incomplete `PAR::Packer` cache under `TMPDIR`, which
  only the `date` path depends on; it is documented as plausible, not proven.
  The work therefore keeps the `date` field and the biber-warning gate exactly
  as they were — both proposed escapes remain explicit non-fixes — and instead
  splits the suite into a visible `bibliography` CI job and teaches
  `tests/bibliography/run.sh` to recognise the signature and name the remedy;
- the tagged path's closing list edge owned by
  `\CDossierRecordListEdgeBelowSkip` rather than LaTeX Lab's block default, so
  a tagged and an untagged build of one source stop paginating toward
  different outcomes (#193). The candidate fix depends on `latex-lab`
  testphase package internals rather than a stable interface, so it targets a
  guarded fix that degrades cleanly if that interface changes;
- regression, smoke, and layout coverage for the resolved furniture metrics,
  both `medium` values, the unknown-value error on every choice-valued option,
  and both list edges on both the untagged and tagged paths;
- this roadmap renumbering and the phase-numbering convention that prevents it
  from drifting again;
- one naming convention across the vertical-spacing tokens (#203), and header
  and letter-block tokens that own the gaps they name rather than inheriting
  the prose `\parskip` (#204). #204 retires the two tokens that never won an
  `\addvspace` maximum and adds three for boundaries no token described. Unlike
  #191 and #203 it is *not* output-neutral: letter and statement headers
  tighten by the prose paragraph gap at each header boundary, the gap above a
  bullet list inside an entry tightens by `\CDossierRecordEntryGapSkip`, and a
  document with no `headline` gains that same amount below the name;
- the four defects that pinned values #206 had to set: the entry-head date
  column extracting out of order below a list-edge floor of `0.25` (#219, with
  #221 covering it in the extraction suite), the two header tokens that could
  not affect output at any value (#220), and the two tokens that each served two
  families and so coupled their retunes (#222, #223). #224 makes the shared
  header stack a public composition triple so the statement class can interleave
  its own lines without reaching into another module's private commands, and
  #225 asserts the heading-pair and run-in floors before the retune moves them;
- a retune of the vertical-rhythm ratios (#206), once #203 and #204 leave every
  gap owned by a token that can express it. Documents reflow;
- option-error consistency and the gate that holds it: one report per rejected
  class option instead of two (#232), a TeX-free `make lint` that fails when a
  choice-valued option does not name its accepted values (#233), and the
  statement class's `type` declared as an ordinary choice list so the lint can
  see it (#236);
- the CV's `CDossierPublications` list building under
  `\DocumentMetadata{tagging=on}`, where it stopped with `Missing number,
  treated as zero` and produced no PDF at all (#218);
- three class-to-package primitives that carried a public prefix without being
  part of the author-facing interface made private, ahead of `v1.0.0` freezing
  whatever still carries that prefix (#242);
- a fixture audit establishing that a spacing token's value being *reported* by
  a regression fixture is not the same as its gap being *rendered* by one, and
  a committed fixture that renders every token (#255).

### Explicit non-goals

- any change to the *value* of a type-scale step or a margin preset. The
  vertical-rhythm ratios *are* retuned in this release, but only under #206 and
  only against its stated design rules; a ratio changed incidentally by any
  other issue here is out of scope. The list-edge split and the token renames
  are mechanism and naming changes that preserve every rendered gap;
- colour themes. `theme=monochrome` remains fixed, and `medium` is deliberately
  a separate axis from colour — the two must not be conflated;
- per-class furniture customization, user-supplied header or footer content,
  and page-numbering format options;
- widening `medium` beyond page furniture (hyperlink colour, PDF metadata, or
  viewer preferences) in this release;
- the extracted reading order of a bibliography's entry numbers (#199), a
  follow-up from #196. Once the entry gap closes, the default `pdftotext`
  heuristic groups the entry numbers ahead of the entry text. The PDF geometry
  is correct — each label shares a baseline with its entry, and
  `pdftotext -layout` reads in source order — and fixing it means changing
  `biblatex` label geometry, which #196 lists as a non-goal.

### Release criteria

- header and folio are vertically centred in their margins at all six
  `fontsize` × `margin` combinations, on Letter and A4;
- `\textheight` and `\textwidth` are unchanged from `v0.6.0` at every
  combination;
- `medium=screen` suppresses furniture and `medium=print` retains current
  behaviour, on all four document classes;
- an unsupported value for any choice-valued public option — `medium` (#184) and
  every other option (#212) — produces an actionable class error naming the
  accepted values and the owning module, with the smoke suite asserting the new
  text for every `*-bad-*` fixture and a regression pinning one message per
  module;
- `make review-matrix` output is reviewed for both media, with PDFs named
  `type-margin-fontsize` (#195);
- the extraction, tagging, layout, and regression suites pass;
- both list edges are owned by their tokens on the untagged path, with the
  rendered gap unchanged from `v0.6.0` by the split itself (#191) — the later
  retune (#206) moves it deliberately;
- the tagged path's closing list edge equals
  `\CDossierRecordListEdgeBelowSkip`, and `pdftotext -bbox` output agrees
  between tagged and untagged builds of every supported example, or every
  remaining difference is explained (#193);
- `cv-bibliography`'s inter-entry gap equals `\CDossierRecordItemSepSkip`
  (#196);
- `make bibliography-test` passes on a clean tree with the `date` field and the
  biber-warning gate both intact, the rendered bibliography shows every year in
  `ydnt` order, and that suite is visible as its own CI job rather than nested
  in another (#211);
- `docs/API.md`, `docs/ARCHITECTURE.md`, `docs/MIGRATION.md`, and
  `CHANGELOG.md` are updated;
- the vertical-spacing tokens follow one naming convention (#203), headers and
  letter blocks own their own gaps (#204), and the retuned ratios are reviewed
  against rendered output at both margins and all three body sizes (#206);
- every ordering relation in `tests/regression/tokens-invariants` holds at all
  three body sizes, and every spacing token is rendered — not merely reported —
  by a committed fixture (#225, #255);
- `make lint` passes, and every choice-valued option in the classes and shared
  packages names its accepted values and its owning module (#233, #236);
- tag and GitHub Release `v0.7.0` are published.

Tracked under
[milestone `v0.7.0`](https://github.com/amirhs1/CareerDossierTeX/milestone/10)
and [epic #182](https://github.com/amirhs1/CareerDossierTeX/issues/182).

## Phase 7: `v0.8.0 — Semantic Structure and Tagged Output`

### Goal

Complete the semantic structure and the tagged-output metadata, and settle the
public typography and colour roles, before the `v1.0.0` API freeze.

The unifying concern is that the released output carries less structure than it
appears to. At `v0.7.0` no document from any of the four classes contains an
`/H1`, and the résumé and CV contain no `Sect` division at all where the
statement nests two (#267, #268); the derived `/Title` never reaches a viewer's
window because `DisplayDocTitle` is unset (#277); and `/Lang` is absent from the
default build path (#276). Alongside that, three public roles are still
unsettled: `Title` names two different things in the type scale and the entry
primitives (#269), entry metadata has no decided de-emphasis role (#271), and
several semantic colour tokens are declared but never consumed (#270).

Two items change rendered output where the current behaviour is a defect rather
than a choice: links have no visible affordance under `medium=screen` (#278),
and `emergencystretch` is set in more than one place with no named token (#272).

### Included

- a top-level heading role for the document identity, so tagged output has an
  `/H1` (#267);
- `Sect` divisions around résumé and CV section headings, matching the statement
  class (#268);
- `/Lang` emitted on the default build path (#276);
- `DisplayDocTitle` set so the derived `/Title` reaches the viewer (#277);
- the `Title` collision between the type scale and the entry role resolved
  (#269);
- a decided rendered de-emphasis role for entry metadata (#271);
- the unused semantic colour tokens either consumed or retired (#270);
- a visible link affordance under `medium=screen`, keeping `medium=print`
  unchanged (#278);
- one `emergencystretch` policy behind one named token (#272);
- an inline entry-metadata option, which also frees the list-edge floor (#230);
- the extracted reading order of bibliography entry numbers corrected (#199), a
  follow-up from #196 that `v0.7.0` lists as a non-goal because fixing it means
  changing `biblatex` label geometry.

### Explicit non-goals

- PDF/UA-2 conformance claims. Tagged structure remains opt-in through
  `\DocumentMetadata{tagging=on}`, and veraPDF validation runs on the scheduled
  workflow, not on the per-PR tagging job.
- colour themes and named font families. Deferred on 2026-07-22 with no
  milestone; `v1.1.0 — Themes and Font Families` was closed empty on 2026-08-05
  ([issue #120](https://github.com/amirhs1/CareerDossierTeX/issues/120)).
- a `templates/` folder. Proposed in
  [issue #280](https://github.com/amirhs1/CareerDossierTeX/issues/280) and
  deliberately unmilestoned; the release that carries it is undecided.

Tracked under
[milestone `v0.8.0`](https://github.com/amirhs1/CareerDossierTeX/milestone/11)
and [epic #281](https://github.com/amirhs1/CareerDossierTeX/issues/281).

## Phase 8: `v0.9.0 — Documentation, Examples, and Release Readiness`

### Goal

Consolidate the documentation set, revise and extend the examples, build the PDF
manual, and configure the CTAN release archive.

### Scope

Documentation:

- split `docs/ATS-EXTRACTION.md` into its charter and the documents that own the
  rest of its material (#262);
- give each duplicated mechanism explanation one canonical home (#259);
- document how to install the classes (#261);
- correct two source comments that document rejected behaviour (#275);
- decide whether maintainer-tooling fixes belong in `CHANGELOG.md`, which #245
  currently has no entry for (#260).

Examples:

- review each example under `examples/` for currency against the calibrated
  token system, consistency with the others, and whether it still demonstrates
  its intended feature clearly;
- add a longer, multi-page `cv-bibliography` example where the current fixture is
  too thin to show real behavior (#197);
- demonstrate tagging and contact labels in a shipped example (#273).

Release readiness:

- build a PDF manual and ship it with its source (#263) — the one hard blocker
  on a CTAN submission;
- configure `l3build ctan` and inspect the resulting archive (#264);
- lint that every Work file declares the same version and date (#258);
- record a VoiceOver reading-order check for the statement fixture (#274).

Tracked under
[milestone `v0.9.0`](https://github.com/amirhs1/CareerDossierTeX/milestone/12)
and [epic #283](https://github.com/amirhs1/CareerDossierTeX/issues/283).

## Phase 9: `v1.0.0 — Stable Public API`

### Goal

Declare a stable and fully documented interface.

### Definition of `1.0.0`

- public commands, options, keys, and environments are documented;
- supported engines and languages are tested;
- migration paths exist for renamed features;
- deprecation policy is documented;
- release ZIP works on Overleaf;
- examples and manual are complete;
- CI verifies all supported configurations.

Tracked under
[milestone `v1.0.0`](https://github.com/amirhs1/CareerDossierTeX/milestone/5)
and [epic #285](https://github.com/amirhs1/CareerDossierTeX/issues/285).

## Continuous testing policy

Testing is part of each implementation issue and pull request:

1. define the observable behavior and its test before implementation;
2. place automated sources, fixtures, runners, and baselines under `tests/`;
3. write the test first when practical, or alongside the first usable
   implementation when a pre-implementation run is not possible;
4. run the focused test plus affected existing suites before merge;
5. rerun the accumulated suite at release time without deferring new feature
   coverage to release preparation.

Dedicated test issues are reserved for shared harness work, cross-cutting quality
improvements, or explicit legacy test debt. They are not a substitute for tests
required by a feature's acceptance criteria.

The repository uses an `l3build` regression harness (`build.lua`, run with
`l3build check`) whose sources and baselines live under `tests/regression/`, so
all test material remains under `tests/` with no top-level `testfiles/`
directory. Every shared package and every document class carries committed
regression coverage — no module is exempt — alongside the extraction, layout,
tagging, bibliography, and lint suites; extend the existing file for a module
with the behavior each future change adds. `docs/ARCHITECTURE.md` ("Testing
strategy") holds the current count and its per-module split.

## Engineering work (tracked as issues)

The live issue and Project metadata now follow the continuous-testing policy:

- CTAN packaging via `l3build ctan`, and the PDF manual a submission requires —
  `v0.9.0`, under #264 and #263. Whether the manual is handwritten or generated
  from a `.dtx` is decided there; `.dtx` is not a CTAN requirement.
- Tagged PDF is no longer gated on XeTeX gaining real interword spaces. The
  LuaLaTeX transition supersedes that precondition, and opt-in tagged structure
  is now in-scope for `v0.4.0` via
  [issue #28](https://github.com/amirhs1/CareerDossierTeX/issues/28), with
  validation in [issue #77](https://github.com/amirhs1/CareerDossierTeX/issues/77).
  No PDF/UA conformance is claimed.

## Scope-control rule

A feature may enter a release only when:

1. its public behavior is defined;
2. a minimal example exists;
3. it is documented;
4. its repeatable or automated test was added with the implementation under
   `tests/`;
5. it does not require claiming unsupported configurations.

Attractive but nonessential features belong in the backlog until the current milestone is complete.
