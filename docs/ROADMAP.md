# CareerDossierTeX Roadmap

This document acts as the strategic compass and sets the expectations in the
project. It is not a support statement.

## Renumbering and retitling history

These entries keep the numbers they were written with.

> **Renumbered on 2026-08-01.** `v0.7.0` was numbered `v0.6.1` until then. It
> adds new public API — the `medium` option and new spacing tokens — which is a
> minor release under Semantic Versioning, not a patch; it also renames public
> design tokens and retunes calibrated values, so documents reflow. The former
> `v0.7.0 — Examples and Templates Revision` moved to `v0.8.0`. See
> [issue #205](https://github.com/amirhs1/CareerDossierTeX/issues/205).
>
> **Reorganised on 2026-08-05.** By then `v0.8.0` held eleven structure and
> semantics issues against three examples issues, so its title no longer
> described its contents. It was retitled
> `v0.8.0 — Semantic Structure and Tagged Output`, and the examples and
> documentation work moved into `v0.9.0`, retitled from
> `Documentation, Packaging, and Release Readiness` to
> `Documentation, Examples, and Release Readiness`. `v1.0.0` moved from
> `Phase 8` to `Phase 9` to make room for the `v0.9.0` phase section, which
> this document previously did not have. `v1.1.0 — Themes and Font Families`
> was closed empty; its deferred work has no milestone. See
> [issue #279](https://github.com/amirhs1/CareerDossierTeX/issues/279).
>
> **Renumbered on 2026-08-19.** The stable-API release was numbered `v1.0.0`
> until then and became `v0.10.0 — Stable Public API`. The freeze itself did
> not move; only the number it carried. Released `CHANGELOG.md` and
> `MIGRATION.md` sections keep the number they published, because those record
> what the project said at the time rather than what it promises now. See
> [issue #473](https://github.com/amirhs1/CareerDossierTeX/issues/473).
>
> **Split on 2026-08-30.** `v0.10.0` was retitled
> `v0.10.0 — Consolidation and Correctness` and a new
> `v1.0.0 — Stable Public API` was created to carry the freeze, with eight
> interface issues moved to it (#96, #243, #265, #274, #280, #288, #327, #420)
> under new epic #539 and release #540. The freeze point still did not move —
> it is still the release after which public commands, keys, options, and
> documented behaviour are stable — but the release carrying it is now
> `v1.0.0`, restoring the number it held before 2026-08-19. `v0.10.0` adds no
> public interface: it removes duplication and fixes defects so that the freeze
> applies to a deduplicated surface. The Project gained `Phase 10 — Stable API`
> and `Phase 9` was retitled `Phase 9 — Consolidation and Correctness`.

## Releases and phases

One row per release, in phase order. `docs/NAMING-CONVENTION.md` "Phase
numbering convention" is canonical for how phases are numbered; this table is
the cross-walk, and the two label forms differ deliberately — only the numbers
must agree.

| Version | Release goal | Status | Phase | Project `Phase` option |
| --- | --- | --- | --- | --- |
| — | Pre-release inventory and baseline | Complete | 0 | `Phase 0 — Inventory` |
| `v0.1.0` | English industry resume and cover letter | Released | 1 | `Phase 1 — Industry` |
| `v0.1.1` | English industry dossier plus metadata and build corrections | Released | 1 | `Phase 1 — Industry` |
| `v0.2.0` | Academic CV, academic letter, and bibliography support | Released | 2 | `Phase 2 — Academic` |
| `v0.2.1` | PDFKit text-extraction correction | Released | 2 | `Phase 2 — Academic` |
| `v0.3.0` | Farsi, bilingual, and right-to-left support | **Dropped — 2026-07-16** | — | _(none — slot reused)_ |
| `v0.4.0` | LuaLaTeX transition and opt-in tagged-PDF preview | Released | 3 | `Phase 3 — Engine and Accessibility` |
| `v0.5.0` | Statement classes and broader customization | Released | 4 | `Phase 4 — Expansion` |
| `v0.6.0` | Calibrated type scale, vertical rhythm, and page geometry | Released | 5 | `Phase 5 — Calibration` |
| `v0.7.0` | Page furniture placement, the `medium` output-context option, and spacing ownership | Released | 6 | `Phase 6 — Spacing Ownership and Output Medium` |
| `v0.8.0` | Semantic structure, tagged-output metadata, and the public typography and colour roles | Released | 7 | `Phase 7 — Semantic Structure and Tagged Output` |
| `v0.9.0` | Documentation set, revised examples, PDF manual, and CTAN archive | Released | 8 | `Phase 8 — Documentation, Examples, and Release Readiness` |
| `v0.10.0` | Duplication removed, defects fixed, and each rule given one home | Planned | 9 | `Phase 9 — Consolidation and Correctness` |
| `v1.0.0` | Stable, documented public API — the freeze | Planned | 10 | `Phase 10 — Stable API` |
| `v1.1.0` | Themes and font families | **Closed empty — 2026-08-05** | — | _(none — never had an option)_ |

A patch release shares the phase of the minor release it corrects, a release
that never shipped has no phase number, and `Phase 0` has no milestone.

Repository milestones are tracked on the GitHub milestones page:

```text
https://github.com/amirhs1/CareerDossierTeX/milestones
```

## Standing non-goals

These hold for the project, not for one release, and a phase below repeats one
only where it has release-specific detail to add.

- **Farsi, bilingual, and right-to-left documents.** Dropped 2026-07-16; see the
  `v0.3.0 — Farsi and Bilingual Support` section for the design record and the
  architectural rule that would govern a revival.
- **Colour themes, named or per-role font combinations, and icons.** Deferred by
  the maintainer on 2026-07-22 with the milestone left undecided.
  `theme=monochrome` is fixed. `v1.1.0 — Themes and Font Families` was closed
  empty on 2026-08-05, and
  [issue #120](https://github.com/amirhs1/CareerDossierTeX/issues/120) carries
  no milestone deliberately.
- **Engines other than LuaLaTeX.** XeLaTeX and pdfLaTeX fail early with an
  actionable diagnostic.
- **Tagging enabled by default.** Tagged structure stays opt-in through
  `\DocumentMetadata{tagging=on}`, and the untagged path is unchanged by it.
- **PDF/UA, WCAG, or broad ATS conformance claims** for arbitrary user
  documents. What the fixtures verify is recorded in `docs/ATS-EXTRACTION.md`
  and claimed no more widely.
- **Alternate bibliography or citation styles**, and **automatic import from
  ORCID, Scholar, DOI services, or external APIs.**
- **Uploading to CTAN.** `make ctan` builds and inspects the archive;
  submission is a separate, maintainer-only act.

## Phase 0: inventory and baseline

### Goal

Understand and preserve the strongest existing resume and cover-letter
implementations before refactoring: baseline designs selected, reference PDFs
compiled, dependencies and public commands recorded, and duplication
identified.

It completed when the project had a documented baseline against which later
changes could be compared.

## Phase 1: `v0.1.0 — English Industry Dossier`

### Goal

Publish the smallest useful CareerDossierTeX release: one resume layout, one
industry cover-letter layout, shared profile metadata, and required-field
validation, under XeLaTeX on US Letter paper in a monochrome theme.

### Delivered

[`v0.1.0` milestone](https://github.com/amirhs1/CareerDossierTeX/milestone/1)
and its [`CHANGELOG.md` entry](../CHANGELOG.md#010---2026-07-15). `v0.1.1`
corrects metadata and the build and is recorded at
[milestone 6](https://github.com/amirhs1/CareerDossierTeX/milestone/6) and
[its entry](../CHANGELOG.md#011---2026-07-17).

## Phase 2: `v0.2.0 — Academic Dossier`

### Goal

Extend the shared foundation to academic applications: `careerdossier-cv.cls`,
the academic cover-letter family, optional `careerdossier-biblatex.sty` and
Biber integration, multi-page CV support, and running headers.

### Delivered

[`v0.2.0` milestone](https://github.com/amirhs1/CareerDossierTeX/milestone/2)
and its [`CHANGELOG.md` entry](../CHANGELOG.md#020---2026-07-17). `v0.2.1`
corrects PDFKit text extraction and is recorded at
[milestone 7](https://github.com/amirhs1/CareerDossierTeX/milestone/7) and
[its entry](../CHANGELOG.md#021---2026-07-19).

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
> number (see `docs/NAMING-CONVENTION.md` "Phase numbering convention"). Refer
> to this section by name, never by number.
>
> **Consequence:** mature RTL support via `bidi` was the main reason the
> project stayed XeLaTeX-only. With multilingual work dropped, that constraint
> no longer applies, which removes the structural argument against evaluating a
> LuaLaTeX migration.

### Goal

Add multilingual and mixed-direction documents without duplicating the class
system.

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

Do not create separate language-specific classes unless a future document model
is genuinely different.

## Phase 3: `v0.4.0 — LuaLaTeX Transition and Tagged-PDF Preview`

### Goal

Replace XeLaTeX with LuaLaTeX as the sole supported engine, preserving the
English public API and visual design, and add a validated opt-in tagged-PDF
path for the named fixture profiles.

This is a **breaking toolchain change**. Documents keep their classes, options,
keys, and commands; the build command changes from `latexmk -xelatex` to
`latexmk -lualatex`, and XeTeX-specific preamble code stops working.

### Delivered

[`v0.4.0` milestone](https://github.com/amirhs1/CareerDossierTeX/milestone/8)
and its [`CHANGELOG.md` entry](../CHANGELOG.md#040---2026-07-20).

**One release criterion is only partly discharged and stays live.** Tagged
fixtures pass structure, extraction, and artifact checks on macOS: the four
named profiles pass veraPDF `ua2` and a three-extractor round trip
(`docs/ATS-EXTRACTION.md`, "Recorded validation results"), and a maintainer
VoiceOver pass on 2026-07-20 confirmed correct reading order with all
decorative and repeated page furniture silent ("Screen-reader reading-order
checks"). NVDA on Windows stays platform-deferred under
[issue #96](https://github.com/amirhs1/CareerDossierTeX/issues/96), now in
`v1.0.0`; the release documents that rather than claiming a Windows result.

### Explicit non-goals

- public API, paper-size, or theme changes. This release moves the engine and
  nothing else.

## Phase 4: `v0.5.0 — Statements and Customization`

### Goal

Support additional application documents and broader visual configuration:
`careerdossier-statement.cls` with its `research`, `teaching`,
`teaching-philosophy`, `diversity`, `artist`, and `purpose` types, A4 paper,
and a cross-class `bodyfont=serif|sans` option.

### Delivered

[`v0.5.0` milestone](https://github.com/amirhs1/CareerDossierTeX/milestone/4)
and its [`CHANGELOG.md` entry](../CHANGELOG.md#050---2026-07-24).

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

### Delivered

[`v0.6.0` milestone](https://github.com/amirhs1/CareerDossierTeX/milestone/9),
[epic #137](https://github.com/amirhs1/CareerDossierTeX/issues/137), and its
[`CHANGELOG.md` entry](../CHANGELOG.md#060---2026-07-30).

### Agreed defaults

Defaults are per class, not uniform: the resume is `11pt` at `margin=narrow`,
the CV, letter, and statement classes `12pt` at `margin=normal`.
[`ARCHITECTURE.md`](ARCHITECTURE.md#careerdossier-tokenssty) is canonical for
the measured characters per line, why `12pt` is required for the prose classes,
and why the resume's longer measure is an accepted limitation rather than an
oversight.

### Explicit non-goals

- any change to public content commands, key names, contact rendering, colours,
  or fonts. This release changes proportions, not the interface.

### Removed

- the `density` (`compact`/`standard`) class option, replaced by the
  calibrated, proportional rhythm derived from `fontsize`.

## Phase 6: `v0.7.0 — Page Furniture, Output Medium, and Spacing Ownership`

### Goal

Reclaim ownership of vertical placement and spacing for the calibrated design
system released in `v0.6.0`, make page furniture selectable by output context,
and retune the vertical-rhythm ratios once every gap is owned by a token.
Several vertical dimensions had been decided by a third-party default or a
hard-coded constant rather than by the design system meant to own them —
`geometry`'s header and folio placement, LaTeX's single `topsep`, a hard-coded
bibliography inter-entry gap, LaTeX Lab's tagged-path list default, and headers
unable to escape the prose `\parskip` among them — and each is handed back to
its owning token. Rendered output therefore moves in two ways: it is
_corrected_ where a spacing decision was never the design system's to begin
with, and it _reflows by design_ where the ratios are retuned; no type-scale
step or margin preset changes value.

### Delivered

[`v0.7.0` milestone](https://github.com/amirhs1/CareerDossierTeX/milestone/10),
[epic #182](https://github.com/amirhs1/CareerDossierTeX/issues/182), and its
[`CHANGELOG.md` entry](../CHANGELOG.md#070---2026-08-04).

### Explicit non-goals

- any change to the _value_ of a type-scale step or a margin preset. The
  vertical-rhythm ratios _are_ retuned in this release, but only under #206 and
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

## Phase 7: `v0.8.0 — Semantic Structure and Tagged Output`

### Goal

Complete the semantic structure and the tagged-output metadata, and settle the
public typography and colour roles, before the API freeze. The released output
had carried less structure than it appeared to — no document from any of the
four classes contained an `/H1`, `/Lang` was absent from the default build
path, and the derived `/Title` never reached a viewer's window — and three
public roles were still unsettled: the `Title` collision between the type scale
and the entry primitives, entry metadata's de-emphasis role, and several
semantic colour tokens declared but never consumed.

### Delivered

[`v0.8.0` milestone](https://github.com/amirhs1/CareerDossierTeX/milestone/11),
[epic #281](https://github.com/amirhs1/CareerDossierTeX/issues/281), and its
[`CHANGELOG.md` entry](../CHANGELOG.md#080---2026-08-12).

### Explicit non-goals

- veraPDF validation on the per-PR tagging job. It runs on the scheduled
  workflow instead.
- a `templates/` folder. Proposed in
  [issue #280](https://github.com/amirhs1/CareerDossierTeX/issues/280), which
  now carries `v1.0.0`; a non-goal of this release, not of the project.

## Phase 8: `v0.9.0 — Documentation, Examples, and Release Readiness`

### Goal

Consolidate the documentation set, revise and extend the examples, build the
PDF manual, and configure the CTAN release archive.

Three strands joined the release after that charter was set: the behaviour and
public-interface corrections that had to land before the freeze, the agent
instruction set, and the build and test harness. Each is there because
deferring it cost more than carrying it — a public-interface fix pushed past
the freeze costs a major version instead of a minor one, and the harness and
instruction-set work paid for itself across the rest of the milestone.

### Delivered

[`v0.9.0` milestone](https://github.com/amirhs1/CareerDossierTeX/milestone/12),
[epic #283](https://github.com/amirhs1/CareerDossierTeX/issues/283), and its
[`CHANGELOG.md` entry](../CHANGELOG.md#090---2026-08-26).

Two outcomes are cited elsewhere and are recorded here because a later release
depends on them: the PDF manual (#263) made `doc/careerdossier.tex` the
interface reference and reduced `docs/API.md` to a pointer; and `make ctan`
(#264) builds the archive, but **nothing has been uploaded**, which stays a
maintainer decision.

## Phase 9: `v0.10.0 — Consolidation and Correctness`

### Goal

Remove duplication, fix defects, and give each rule one home, so that the
`v1.0.0` freeze applies to a deduplicated surface.

### Definition of `0.10.0`

- every rule stated in one place, with the other mentions reduced to pointers;
- fixture bodies shared rather than repeated, and a lint that every fixture
  declares what it asserts;
- shared class options declared once rather than once per class;
- module boundaries corrected before they are frozen;
- measured correctness and optimization work on the ten Work files.

**This release adds no public interface.** Public commands, keys, and options
may still change here; work that defines, documents, or freezes them belongs to
`v1.0.0`.

Tracked under
[milestone `v0.10.0`](https://github.com/amirhs1/CareerDossierTeX/milestone/5)
and [epic #285](https://github.com/amirhs1/CareerDossierTeX/issues/285).

## Phase 10: `v1.0.0 — Stable Public API`

### Goal

Declare a stable and fully documented interface.

### Definition of `1.0.0`

- public commands, options, keys, and environments are documented;
- supported engines and languages are tested;
- migration paths exist for renamed features;
- deprecation policy is documented;
- examples are complete;
- CI verifies all supported configurations;
- manual screen-reader passes are recorded for VoiceOver on the statement
  fixture (#274) and NVDA on Windows (#96), so both sit together as one release
  criterion;
- the uploaded archive satisfies the CTAN packaging requirements, which
  [`RELEASE-CHECKLIST.md`](RELEASE-CHECKLIST.md#ctan-readiness-planned--v100)
  states in full and this file does not restate (#448).

After this release, public commands, keys, options, and documented behaviour
should be treated as stable. This is the freeze.

Tracked under
[milestone `v1.0.0`](https://github.com/amirhs1/CareerDossierTeX/milestone/14)
and [epic #539](https://github.com/amirhs1/CareerDossierTeX/issues/539).
