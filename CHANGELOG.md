# Changelog

All notable changes to CareerDossierTeX will be documented in this file.

The project follows [Semantic Versioning](https://semver.org/). The structure of this file is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Before `v1.0.0`, breaking changes may occur, but they must be documented here and in `docs/MIGRATION.md`.

## [Unreleased]

### Added

- Added an opt-in `contact-labels` key to `\CDossierSetup`. When enabled, the
  contact line prefixes `Email:`, `Phone:`, and `Website:` text labels to
  those fields in every document class, so each field's nature is stated in
  the visible text itself rather than left to inference from format and
  position — the gap that motivated the change: assistive technology announces
  the email and website as links, but a phone number is otherwise read as
  unidentified digits. Because the label is ordinary visible text, it is
  present in the default untagged output and verified to survive plain-text
  extraction. The remaining contacts stay unlabelled because their values
  identify themselves (service-domain URLs, the permanent `ORCID:` label,
  place-name locations). The default rendering is unchanged, labels are fixed
  English strings, and an absent field leaves no orphan label or stray
  separator. Regression and extraction fixtures pin both the labelled and
  unlabelled forms. ([#95])

- Added a consistent `bodyfont=serif|sans` class option to the résumé, CV,
  industry and academic letters, and statement documents. `serif` remains the
  default and preserves the existing TeX Gyre Termes body with TeX Gyre Heros
  headings; `sans` uses TeX Gyre Heros for both body and headings without
  changing sizes, spacing, geometry, semantic roles, or page furniture. Both
  families resolve through exact TeX Live files, provide explicit upright,
  bold, italic, and bold-italic faces, and were tested at version 2.004 under
  the GUST Font License. Focused regression, smoke, extraction, and tagged-build
  fixtures cover selection and invalid values. Existing optional-field and
  separator behavior is unchanged. ([#119])

- Added opt-in A4 paper to the résumé, industry and academic letters, academic
  CV, and the statement class through one consistent
  `paper=letter|a4` class option. US Letter remains the default, and both paper
  sizes keep each class's established physical margins, typography, spacing,
  and page-furniture design. A4 layout fixtures verify the media box, long-form
  wrapping, multi-page flow, folios, and continuation headers across every
  document family. Existing optional-field and separator behavior is
  unchanged. ([#105])

- Added `careerdossier-statement`, one LuaLaTeX class with a default
  general-interest type plus research, teaching, teaching-philosophy, diversity,
  artist, and statement-of-purpose documents. The optional `type` option
  selects the default full and running titles plus the relevant contact and
  validation contract; `\CDossierStatementSetup` adds
  optional subtitle, application-context, and application-ID metadata. The
  centered first-page identity block uses the academic-letter typography,
  margins, and prose rhythm, while continuation pages carry a short running
  title and every page carries `Page N of M`. Six two-page examples and focused
  smoke, layout, extraction, and tagged-PDF fixtures cover the new interface.

  The additive shared-profile `affiliation` key is required for research
  statements and optional elsewhere; artist statements require the existing
  `website` field. Optional metadata and contacts collapse without blank lines
  or stray separators. Existing résumé, CV, and letter interfaces and defaults
  are unchanged. ([#104])

### Fixed

- Statements now default to `type=general-interest` when `type` is omitted.
  The default title and continuation header read `General Interest Statement`,
  and this general contract requires only `name` and `email`. Explicit statement
  types and their existing validation remain unchanged. ([#117])

[#95]: https://github.com/amirhs1/CareerDossierTeX/issues/95
[#104]: https://github.com/amirhs1/CareerDossierTeX/issues/104
[#105]: https://github.com/amirhs1/CareerDossierTeX/issues/105
[#117]: https://github.com/amirhs1/CareerDossierTeX/issues/117
[#119]: https://github.com/amirhs1/CareerDossierTeX/issues/119

## [0.4.0] - 2026-07-20

**LuaLaTeX Transition and Tagged-PDF Preview.** A breaking toolchain change:
LuaLaTeX replaces XeLaTeX as the sole supported engine. The English public API
and visual design are preserved, apart from the academic CV and letter page
furniture noted below. Adds an opt-in tagged-PDF path validated for four named
fixtures. See [`docs/MIGRATION.md`](docs/MIGRATION.md) for the upgrade path.

### Changed

- **BREAKING (toolchain): LuaLaTeX replaces XeLaTeX as the sole supported
  engine.** Build commands change from `latexmk -xelatex` to
  `latexmk -lualatex`, and XeLaTeX or pdfLaTeX now stop with a fatal error from
  `careerdossier-typography` naming LuaLaTeX. There is no compatibility mode.

  No class, class option, profile key, public command, or environment changed.
  Paper size, monochrome theme, and page design are unchanged. A document
  without XeTeX-specific preamble code needs no edit beyond the build command.
  `docs/MIGRATION.md` gives the upgrade path, including editor and CI settings,
  `\XeTeXgenerateactualtext` removal, font-override checks, and pagination
  review. ([#75], [#76])

  LuaHBTeX writes real interword spaces into the text layer and supports the
  LaTeX kernel tagging pipeline; XeTeX supports neither. That limitation capped
  extraction reliability (see `0.2.1`) and blocked tagged output entirely.

- The academic CV folio now reads `Page N of M`, matching
  `careerdossier-letter`. It previously read `Page N`, which cannot tell a
  reader holding page two whether the document ended — the case that matters
  most for the printed and separated pages a multi-page CV produces. The total
  comes from the LaTeX kernel's last absolute page already recorded in the
  auxiliary file, so no total-page package is added and the value resolves on
  the second pass. Single-page CVs now read `Page 1 of 1`, as single-page
  academic letters already did.

  This changes rendered CV output. Documents are unaffected apart from the
  folio text; no class, option, key, or command changed. ([#91])

- The academic cover letter now shares `careerdossier-cv`'s page furniture, so
  the two multi-page academic documents read as one family. From page two it
  carries a centered running header — `<name> — Cover Letter`, matching the CV's
  `<name> — Curriculum Vitae` — and its folio is now a centered `Page N of M`
  that no longer repeats the name. Page one has no running header, as in the CV,
  because the letterhead already carries identity. ([#98])

  The name is not lost: it already appears in the letterhead and the signature
  block, so on a single-page letter the old footer was a third occurrence.

  The running header is a layout artifact — it does not enter the structure tree
  and screen readers do not announce it, verified by comparing the tagged
  structure tree before and after the change. `family=industry` is unaffected
  and keeps its `v0.1` empty page style.

  This changes rendered academic-letter output. No class, option, key, or
  command changed.

- Default fonts now resolve by file name through `luaotfload` (`texgyretermes`
  and `texgyreheros` with explicit faces) instead of by fontconfig family name.
  The build no longer depends on OS-installed fonts. Documents that override
  fonts with a system font name should recheck their logs for substitutions.

- The `Makefile`, `l3build` configuration, test runners, and CI workflow all
  build with LuaLaTeX. `make tagging` is a new suite and is included in
  `make check`. ([#76])

- CI gained a `tagging` job running the tagged-PDF suite on every push and pull
  request, installing `mupdf-tools` alongside `poppler-utils` so both
  command-line extractors run there. veraPDF is not installed in CI yet — that
  is a new third-party binary needing an approved immutable pin, so PDF/UA-2
  validation currently runs locally only and the job reports that gate as not
  run. ([#77])

### Added

- Opt-in tagged semantic structure under LuaLaTeX, enabled per document with
  `\DocumentMetadata{lang=en, tagging=on}` before `\documentclass`. Section
  headings, lists, paragraphs, and links are exposed as structure; decorative
  rules, contact separators, and running page furniture are marked as layout
  artifacts. ([#28])

  Tagging is **off by default** and introduces no class option or public
  command — the interface is the LaTeX kernel's. Documents that do not enable it
  produce byte-identical output to the untagged path.

  This is a tested preview for four fixture profiles (industry résumé, industry
  letter, academic CV, academic letter). Fixtures assert that a structure tree
  exists and check heading, list, link, and artifact classification, text
  extraction, and tagged-versus-untagged geometry. It is **not** a PDF/UA, WCAG,
  ATS, or general accessibility conformance claim, and it is not validated for
  arbitrary user documents. Independent validator and macOS screen-reader
  verification are recorded below; NVDA on Windows is tracked in [#96] and has
  not been performed.

- PDF/UA-2 validation and a three-extractor round-trip for the four tagged
  fixture profiles. Each profile gains a `-ua2.tex` variant that shares the
  tagged fixture's body and adds `pdfstandard=ua-2`; `make tagging` builds it,
  validates it with veraPDF, and compares Poppler, MuPDF, and Apple PDFKit
  extraction against committed per-extractor baselines. The run also writes a
  toolchain record, because a validation result is only meaningful alongside the
  versions that produced it. ([#77])

  All four profiles pass veraPDF `ua2`, and all three extractors agree with
  their baselines. Reports are retained as CI artifacts, never committed.
  Sections 7.1–7.3 of `docs/guides/ats-extraction.md` record the results, the
  exact toolchain, and what the result does and does not license.

  veraPDF, MuPDF, Biber, and PDFKit gates skip with a notice when the tool is
  unavailable, and the runner's closing summary names every gate that did not
  run, so a partial local environment cannot be mistaken for a full pass.

  **Screen-reader review: macOS done, Windows outstanding.** A VoiceOver pass on
  macOS 15.7.5 confirmed correct reading order across all four profiles, with
  every artifact-suppression check passing — the CV running header and folio and
  the academic letter's repeated footer are silent, and the contact line is
  announced as one coherent run. Results are recorded in section 7.2. NVDA on
  Windows has **not** been performed; it is a platform limitation tracked in
  [#96], and the release claims no Windows screen-reader result.

- A tagged-BibLaTeX feasibility fixture, recorded separately and deliberately
  non-blocking, since tagging support in BibLaTeX and Biber is upstream work.
  It currently builds and passes veraPDF `ua2` with genuine list structure per
  entry. Limitations — Biber and a multi-pass build, and the fact that a
  bibliography-only document renders zero pages and fails to build — are
  documented in section 7.3. Tagged BibLaTeX is **not** a supported `v0.4.0`
  feature. ([#77])

### Removed

- `\XeTeXgenerateactualtext` handling, along with the rest of the XeTeX-specific
  code path. The primitive does not exist under LuaTeX. ([#75])

[#28]: https://github.com/amirhs1/CareerDossierTeX/issues/28
[#75]: https://github.com/amirhs1/CareerDossierTeX/issues/75
[#76]: https://github.com/amirhs1/CareerDossierTeX/issues/76
[#77]: https://github.com/amirhs1/CareerDossierTeX/issues/77
[#82]: https://github.com/amirhs1/CareerDossierTeX/issues/82
[#98]: https://github.com/amirhs1/CareerDossierTeX/issues/98
[#91]: https://github.com/amirhs1/CareerDossierTeX/issues/91
[#96]: https://github.com/amirhs1/CareerDossierTeX/issues/96

## [0.2.1] - 2026-07-19

### Fixed

- Text extracted from CareerDossierTeX PDFs no longer merges adjacent words in
  PDFKit-based consumers — macOS Preview, Quick Look, Spotlight, Safari's PDF
  viewer, and ordinary copy/paste. `careerdossier-typography` had enabled
  `\XeTeXgenerateactualtext`, which wraps each word in its own `/ActualText`
  span with no space between spans; consumers that trust `/ActualText` over
  glyph geometry read `Research& Development` for `Research & Development`.
  The setting is now off. Rendered pages are unchanged, and Poppler
  (`pdftotext`) output is unchanged for the résumé, letter, and CV fixtures.
  This addresses the text layer only and is not a tagging, PDF/UA, WCAG, or
  ATS-conformance claim. ([#72])

  One extraction change is visible with the optional BibLaTeX integration.
  BibLaTeX sets its `doi` and `url` labels as lowercase text rendered in small
  capitals; `/ActualText` used to report the lowercase source, so extraction
  read `doi:` and `url:`. Without it, extraction reads the glyphs actually shown
  and reports `DOI:` and `URL:`. The visible page is identical, and the
  extracted form now matches both the printed capitalization and the
  conventional acronym, but Poppler-based tooling that matched the lowercase
  labels will need updating.

### Changed

- The extraction fixture suite now gates on three checks instead of one: the
  Poppler baseline, the absence of `/ActualText` spans in the PDF, and — on
  macOS — an Apple PDFKit baseline extracted through `PDFDocument.string`.
  Fixtures build uncompressed so the `/ActualText` check needs no tool beyond
  `grep`. The PDFKit check is skipped with a notice on other platforms.

[#72]: https://github.com/amirhs1/CareerDossierTeX/issues/72

## [0.2.0] - 2026-07-17

### Added

- `careerdossier-cv`: the English academic-CV class. It provides US
  Letter, monochrome, multi-page CV layout with `fontsize` (`10pt` or `11pt`;
  default `11pt`) and `density` (`compact` or `standard`; default `standard`).
  The first page uses the shared dossier header; subsequent pages carry a
  name-derived running header, and every page has a `Page n` folio. The class
  uses the existing section, entry, and list interface and does not load
  BibLaTeX or require Biber.
- Optional shared-profile `orcid` metadata. It renders as descriptive visible
  text and a link; bare identifiers resolve through `https://orcid.org/` while
  complete URLs retain their scheme. Academic profiles can therefore be shared
  with the existing résumé without leaving stray contact separators.
- A supported academic-CV example, shared academic profile, CV smoke and
  extraction fixtures, and long-field/two-page layout checks. CI and `make`
  now build the academic-CV example.
- `careerdossier-letter` now accepts `family=academic` for the
  academic cover-letter family. `industry` remains the default and existing
  letter metadata, optional recipient handling, and public commands are shared
  unchanged. Academic letters derive the PDF title `Academic Cover Letter –
  <name>` and carry a print-oriented footer with the name and `Page n of N`.
  A supported academic-letter example and its smoke, extraction, and layout
  coverage build through `make` and CI.
- Dependency-free manual publication lists through `CDossierPublications` and
  `\CDossierPublication`, with source-order numbering, clean optional-field
  punctuation, and DOI-over-URL link precedence.
- Optional `careerdossier-biblatex` integration with the fixed numeric,
  Biber-backed, year-descending academic profile; repeatable exact author-name
  highlighting; DOI → e-print → URL precedence; an actionable missing-package
  diagnostic; and a fictional Biber example built by `latexmk`, `make`, and CI.

### Changed

- The supported no-BibLaTeX academic-CV example now demonstrates manual
  publications. README, API, roadmap, contributor requirements, and build
  guidance now distinguish `v0.1.1` behavior from released `v0.2.0` support,
  map every academic interface to a complete example, document the Biber
  verification path, and state the release's explicit non-goals.

## [0.1.1] - 2026-07-17

### Added

- `AI-POLICY.md` and contribution guidance for disclosed, human-reviewed AI
  assistance; accurate non-duplicated commit attribution; prompt-injection
  handling; and licensing, provenance, privacy, and verification duties. Claude
  Code project settings now deny built-in read and edit access to declared
  private paths and enable sandbox enforcement for Bash when supported.
- PDF document metadata derived from the shared profile, applied automatically
  at `\begin{document}` by `careerdossier-components`. A résumé now carries
  `/Title` `Résumé – <name>`, a cover letter `Cover Letter – <name>`, both carry
  `/Author` `<name>`, and both declare `/Lang` `en`. Previously the classes set
  no PDF metadata at all, so viewers and file managers showed the filename
  instead of a title, and the document declared no language. The document type is
  part of the title so a résumé and a letter built from one profile stay
  distinguishable. Any field set with `\hypersetup` is left untouched, in either
  order relative to `\CDossierSetup`; fields left alone are still derived. When
  `name` is absent, `/Title` and `/Author` are omitted rather than raising a
  second error. See `docs/API.md`, "PDF document metadata".

### Changed

- The LPPL Work is now defined in one place by `manifest.txt`; each source
  file's licence notice refers to the manifest instead of naming itself as a
  separate Work. The licence (LPPL 1.3c), maintenance status, and maintainer are
  unchanged. `latexmkrc` was removed and its references dropped, since the
  supported build already passes `-xelatex` explicitly.
- `make` now builds both supported examples, and the test suites are exposed as
  Make targets (`make check`, `regression`, `smoke`, `layout`, `extract-test`,
  `clean`) that mirror the CI commands. The README build instruction is
  corrected accordingly.

### Fixed

- CI now pins the TeX Live container to an image digest and every GitHub Action
  to a commit SHA, and records the resolved toolchain versions as an artifact,
  so a run is reproducible and an upstream retag cannot change what executes.

## [0.1.0] - 2026-07-15

First tagged release: an English industry résumé and a matching industry cover
letter driven by shared profile metadata, built with XeLaTeX on US Letter paper
in a monochrome theme.

### Added

- `l3build` regression harness (`build.lua`) configured for XeTeX and
  `tests/regression/`, run with `l3build check`. Backfilled committed regression
  coverage for the Phase 1 packages: `careerdossier-base` field storage,
  trimming, presence, overwrite, and the unknown-key, unknown-field, and
  missing-name diagnostics; `careerdossier-components` link-target scheme
  normalization and contact-line separator placement; `careerdossier-theme`
  monochrome palette values and color tokens; and `careerdossier-typography`
  semantic role classes and the ATS actual-text setting.
- `careerdossier-letter.cls`: the English industry cover-letter class. US Letter
  geometry with one-inch margins; no user-facing class options (family, paper,
  language, and theme are fixed, and any option is rejected with an actionable
  message); page numbers disabled by default. `\CDossierLetterSetup` for letter
  metadata (`date`, `recipient-name`, `recipient-title`,
  `recipient-organization`, `recipient-address`, `subject`, `salutation`,
  `closing`) with English defaults for `date`, `salutation`, and `closing` and
  unknown keys rejected. `\MakeCDossierLetterhead` (centered sender identity,
  date, collapsing recipient block, optional subject, salutation) and
  `\MakeCDossierClosing` (closing, signature space, validated `name`). An absent
  recipient field, subject, or contact field leaves no stray line or separator.
- `examples/industry/letter-industry.tex`: the supported cover-letter example,
  sharing `examples/profiles/profile-english.tex` with the résumé example.
- Cover-letter tests: smoke fixtures for the supported builds and the required
  failure paths (missing `name`, unknown class option, unknown
  `\CDossierLetterSetup` key), layout-stress fixtures (`tests/layout/`) for long
  fields and a two-page letter, and a letter extraction fixture
  (`tests/extraction/`) pinning the recipient block, contact line, and reading
  order when optional fields are absent.
- `careerdossier-resume.cls`: the English industry résumé class. US Letter
  geometry; `fontsize` (`10pt`, `11pt`) and `density` (`compact`, `standard`)
  options with actionable rejection of unsupported keys and values; page numbers
  disabled by default; `\CDossierSection`, the `CDossierEntry` environment, and
  the `CDossierItemize` list.
- Shared entry-heading primitive in `careerdossier-components.sty` that renders a
  required title with optional organization, location, and dates and leaves no
  stray separators when fields are absent.
- `examples/industry/resume-english.tex` and `examples/profiles/profile-english.tex`:
  the supported résumé example and its shared profile data.
- Smoke tests (`tests/smoke/`) for the supported builds and the required failure
  paths, layout-stress fixtures (`tests/layout/`) for long fields and a two-page
  résumé, and a résumé extraction fixture (`tests/extraction/`) that pins the
  contact line and reading order.
- Initial project scope, phased roadmap, and Phase 1 implementation plan.
- Repository architecture and documentation plan.
- GitHub issue, branch, pull-request, CI, and release workflow documentation.
- Draft user documentation for the planned `v0.1.0` public interface.
- Contributor workflow and coding conventions.
- LaTeX Project Public License version 1.3c.
- `docs/API.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, and `docs/MIGRATION.md`, resolving links that `README.md` and `CONTRIBUTING.md` already pointed to.
- GitHub issue templates (`.github/ISSUE_TEMPLATE/bug_report.md`, `.github/ISSUE_TEMPLATE/feature_request.md`) and a pull-request template (`.github/pull_request_template.md`).
- `docs/guides/ats-and-extraction.md`: design and reference guide for ATS-safe, extractable XeLaTeX output (single-column layout, font/ligature policy, `/ActualText` limits, extraction testing, tagging status). Reference material only; scope-gated to distinguish Phase 1 from planned work.

### Changed

- Clarified that the résumé, cover-letter class, shared profile interface, and CI workflow remain pre-release targets until implemented and verified.
- Standardized licensing language around LPPL maintenance status and the current maintainer.

### Fixed

- `careerdossier-components.sty`: a `website`, `linkedin`, `github`, or `scholar`
  value that already carried a scheme (for example `https://example.com`) had a
  second `https://` prepended to its link target, producing a broken href such as
  `https://https://example.com`. The scheme is now detected by string comparison,
  which is insensitive to the colon's category code, so an existing scheme is
  preserved and `https://` is added only when none is present. The visible text
  was already correct, so extraction output is unaffected.
- Corrected relative links in `CONTRIBUTING.md` that assumed the file lived under `docs/` instead of the repository root.

[Unreleased]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/amirhs1/CareerDossierTeX/releases/tag/v0.1.0
