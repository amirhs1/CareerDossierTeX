# Changelog

All notable changes to CareerDossierTeX will be documented in this file.

The project follows [Semantic Versioning](https://semver.org/). The structure of this file is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Before `v1.0.0`, breaking changes may occur, but they must be documented here and in `docs/MIGRATION.md`.

## [Unreleased]

### Added

- `careerdossier-cv`: the unreleased English academic-CV class. It provides US
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
- `careerdossier-letter` now accepts `family=academic` for the unreleased
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
  guidance now distinguish released `v0.1.1` behavior from implemented but
  unreleased `v0.2.0` support, map every academic interface to a complete
  example, document the Biber verification path, and state the release's
  explicit non-goals.

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

[Unreleased]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/amirhs1/CareerDossierTeX/releases/tag/v0.1.0
