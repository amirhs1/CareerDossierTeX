# Project Scope and Phased Roadmap

## 1. Product vision

`CareerDossierTeX` is a reusable XeLaTeX toolkit for producing consistent career documents from shared profile data.

The long-term product includes:

- industry résumés;
- industry and academic cover letters;
- academic CVs;
- research, teaching, diversity, and artist statements;
- optional bibliography-driven academic sections;
- English, Farsi, bilingual, and later additional languages;
- local, GitHub Actions, and Overleaf builds.

The project should favor a small stable public interface over many partially implemented options.

## 2. Release strategy

Use semantic versions:

```text
0.1.0  English industry dossier
0.2.0  Academic dossier and bibliography
0.3.0  Farsi and bilingual support
0.4.0  Statements and broader customization
1.0.0  Stable documented public API
```

Before `1.0.0`, breaking changes are acceptable when documented in `CHANGELOG.md` and `docs/MIGRATION.md`.

## 3. Phase 0: inventory and baseline

### Goal

Understand the current classes before replacing them.

### Deliverables

- Select the best existing résumé design.
- Select the best existing cover-letter design.
- Compile and save reference PDFs.
- Save representative compilation logs.
- List public commands and environments.
- List package dependencies.
- Identify duplicated implementation.
- Record margins, fonts, colors, headers, and spacing.
- Begin `docs/MIGRATION.md`.
- Define the first public API in `docs/API.md`.

### Why this phase matters

Refactoring without a baseline makes it difficult to distinguish intentional improvement from accidental regression.

## 4. Phase 1: English industry dossier

### Release

```text
v0.1.0 — English Industry Dossier
```

### Supported scope

- XeLaTeX only.
- English only.
- Letter paper.
- Monochrome theme.
- One résumé layout.
- One industry cover-letter layout.
- Shared profile metadata.
- Basic metadata validation.
- Basic integration builds in GitHub Actions.

### Files

```text
careerdossier-base.sty
careerdossier-i18n.sty
careerdossier-typography.sty
careerdossier-theme.sty
careerdossier-components.sty
careerdossier-resume.cls
careerdossier-letter.cls
```

`careerdossier-i18n.sty` exists in Phase 1, but it contains only the English label and language abstraction needed to avoid hard-coding labels throughout the classes. It does not yet claim Farsi or RTL support.

### Public API

Initial commands:

```latex
\CDossierSetup
\CDossierLetterSetup
\MakeCDossierHeader
\MakeCDossierLetterhead
\CDossierSection
\begin{CDossierEntry}...\end{CDossierEntry}
\begin{CDossierItemize}...\end{CDossierItemize}
```

Initial profile keys:

```text
name
headline
email
phone
location
website
linkedin
github
```

Initial letter keys:

```text
date
recipient-name
recipient-title
recipient-organization
recipient-address
subject
salutation
closing
```

### Explicitly postponed

- academic CV;
- `biblatex`;
- Biber;
- Farsi;
- bilingual layouts;
- right-to-left layout;
- statements;
- A4 paper;
- color themes;
- icons;
- font presets;
- CTAN packaging;
- visual regression testing.

### Acceptance criteria

- Both classes stop with a clear message under pdfLaTeX.
- The résumé compiles under XeLaTeX.
- The cover letter compiles under XeLaTeX.
- Both use the same profile file.
- Missing required `name` produces a clear error.
- Missing optional fields leave no empty separators.
- The résumé text is selectable and extracts in logical order.
- GitHub Actions builds both examples.
- The README describes only capabilities that actually work.
- Tag and release `v0.1.0` exist.

## 5. Phase 2: academic dossier

### Release

```text
v0.2.0 — Academic Dossier
```

### Deliverables

- `careerdossier-cv.cls`;
- academic cover-letter family;
- `careerdossier-biblatex.sty`;
- optional Biber integration;
- manual publication entries;
- multi-page CV behavior;
- page numbers;
- running headers;
- Google Scholar, ORCID, LinkedIn, and website fields;
- long-entry and page-break tests;
- initial `l3build` regression suite.

### Acceptance criteria

- Long CVs page-break safely.
- Bibliography use is optional.
- A CV without `biblatex` still works.
- A Biber example builds with `latexmk -xelatex`.
- Academic and industry documents can reuse the same profile.
- CV-specific metadata and commands are documented.

### Bibliography recommendation

Adding bibliography support in Phase 2 is appropriate because it belongs to the academic CV feature set. It should not delay the industry release.

## 6. Phase 3: Farsi and bilingual support

### Release

```text
v0.3.0 — Farsi and Bilingual Support
```

### Deliverables

- `language=english|farsi|bilingual`;
- `main-language=english|farsi`;
- central translation tables;
- Farsi font configuration;
- RTL and mixed-direction helpers;
- mirrored dates, bullets, and layout components;
- LTR email, URL, ORCID, and Latin-number handling inside RTL documents;
- Farsi and bilingual examples;
- direction and glyph tests.

### Architectural rule

Farsi support should extend the existing language abstraction, not create separate duplicated Farsi classes.

Correct:

```text
careerdossier-cv.cls
  + language=farsi
```

Avoid:

```text
careerdossier-cv-farsi.cls
```

unless a truly different document model later requires it.

## 7. Phase 4: statements and customization

### Release

```text
v0.4.0 — Statements and Customization
```

### Deliverables

- `careerdossier-statement.cls`;
- research, teaching, diversity, artist, and general statements;
- A4 paper;
- color and print themes;
- Merriweather and Neuton presets;
- optional Font Awesome icons;
- numeral styles;
- more stress tests;
- improved documentation.

## 8. Version 1.0

### Release

```text
v1.0.0 — Stable Public API
```

### Definition

Version `1.0.0` means:

- public commands and keys are documented;
- supported engines and languages are tested;
- migration paths exist for renamed features;
- release ZIP works on Overleaf;
- manual and examples are complete;
- CI verifies all supported configurations;
- deprecation policy is documented.

## 9. Scope-control rule

A feature may enter a release only when:

1. its public behavior is defined;
2. a minimal example exists;
3. it is documented;
4. it has at least one automated or repeatable test;
5. its addition does not require falsely claiming unsupported configurations.

Use the backlog for attractive but nonessential ideas. Do not allow them to expand the current milestone.
