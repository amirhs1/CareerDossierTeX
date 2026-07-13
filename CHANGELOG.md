# Changelog

All notable changes to CareerDossierTeX will be documented in this file.

The project follows [Semantic Versioning](https://semver.org/). The structure of this file is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Before `v1.0.0`, breaking changes may occur, but they must be documented here and in `docs/MIGRATION.md`.

## [Unreleased]

### Added

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

- Corrected relative links in `CONTRIBUTING.md` that assumed the file lived under `docs/` instead of the repository root.

### Release preparation

When `v0.1.0` is ready:

1. move completed entries from `[Unreleased]` into a new section;
2. use the heading `## [0.1.0] - YYYY-MM-DD`;
3. verify that the README and API documentation describe only tested behavior;
4. confirm that both supported examples compile locally and in CI;
5. create a new empty `[Unreleased]` section above the release.
