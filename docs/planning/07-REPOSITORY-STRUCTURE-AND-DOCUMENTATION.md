# Repository Structure and Documentation

## 1. Phase 1 repository structure

At the end of `v0.1.0`, use:

```text
CareerDossierTeX/
├── careerdossier-base.sty
├── careerdossier-i18n.sty
├── careerdossier-typography.sty
├── careerdossier-theme.sty
├── careerdossier-components.sty
├── careerdossier-resume.cls
├── careerdossier-letter.cls
│
├── examples/
│   ├── profiles/
│   │   └── profile-english.tex
│   └── industry/
│       ├── resume-english.tex
│       └── letter-industry.tex
│
├── tests/
│   ├── regression/
│   ├── smoke/
│   ├── extraction/
│   └── layout/
│
├── docs/
│   ├── API.md
│   ├── ARCHITECTURE.md
│   ├── ROADMAP.md
│   ├── MIGRATION.md
│   └── planning/
│       └── ...
│
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug.md
│   │   └── feature.md
│   ├── workflows/
│   │   └── build.yml
│   └── pull_request_template.md
│
├── build.lua
├── latexmkrc
├── Makefile
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── .gitignore
```

Do not create empty placeholder files for every future class merely to make the repository look complete.
Create a test subdirectory only when its first real fixture lands. Automated test
sources, baselines, and runners belong under `tests/`; user examples stay under
`examples/`.

## 2. Phase 2 additions

Add:

```text
careerdossier-cv.cls
careerdossier-biblatex.sty

examples/
└── academic/
    ├── cv-english.tex
    ├── letter-academic.tex
    └── publications.bib
```

Extend the existing suites under `tests/` for academic behavior. Do not create a
top-level `testfiles/` directory; configure `l3build` to use
`tests/regression/`.

## 3. Phase 3 additions

Extend:

```text
careerdossier-i18n.sty
careerdossier-typography.sty
careerdossier-components.sty
careerdossier-resume.cls
careerdossier-cv.cls
careerdossier-letter.cls
```

Add:

```text
examples/profiles/profile-farsi.tex
examples/profiles/profile-bilingual.tex
examples/industry/resume-bilingual.tex
examples/academic/cv-farsi.tex
examples/academic/cv-bilingual.tex
```

Avoid separate duplicated language-specific classes.

## 4. Documentation responsibilities

### `README.md`

Audience:

```text
new user or recruiter viewing the repository
```

Include:

- one-sentence purpose;
- current release status;
- supported classes;
- XeLaTeX requirement;
- quick start;
- build command;
- preview image;
- release link;
- roadmap summary;
- licence.

Do not present planned features as currently supported.

### `docs/ARCHITECTURE.md`

Audience:

```text
maintainer or contributor
```

Include:

- module boundaries;
- data flow;
- class/package responsibilities;
- public versus internal APIs;
- language strategy;
- test strategy;
- build and release principles.

The revised architecture blueprint belongs here.

### `docs/ROADMAP.md`

Audience:

```text
users and contributors interested in future work
```

Include:

- phases;
- release goals;
- explicit non-goals;
- status of each phase;
- links to GitHub milestones.

Keep it shorter than the full architecture.

### `docs/API.md`

Audience:

```text
class and package users
```

Include only implemented behavior:

- class options;
- setup keys;
- commands;
- environments;
- defaults;
- required fields;
- examples;
- errors and warnings;
- stability status.

Update this in the same PR as public API changes.

### `docs/MIGRATION.md`

Audience:

```text
you and users of earlier class files
```

Include mappings such as:

```text
old command
  → new key or command
  → behavioral difference
  → replacement example
```

### `CONTRIBUTING.md`

Include:

- issue workflow;
- branch names;
- commit format;
- pull-request process;
- local build commands;
- testing expectations;
- coding conventions;
- how to propose API changes.

### `CHANGELOG.md`

Use a human-readable version structure:

```markdown
# Changelog

## [Unreleased]

### Added
### Changed
### Fixed

## [0.1.0] - 2026-07-08

### Added

- English résumé class.
- English industry cover-letter class.
```

## 5. Generated files policy

Usually ignore:

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

Decide deliberately whether example PDFs are committed.

Recommended:

- generated PDFs are CI artifacts;
- selected release PDFs are release assets;
- preview PNGs may be committed under `docs/assets/`;
- source files remain authoritative.

## 6. Public-file loading

Users should write:

```latex
\documentclass{careerdossier-resume}
```

not:

```latex
\documentclass{classes/careerdossier-resume}
```

For early releases, keep public `.cls` and `.sty` files together at the repository root. This simplifies local and Overleaf use.

## 7. Profile separation

Example:

```latex
% examples/profiles/profile-english.tex

\CDossierSetup{
  name     = {Amir Sadeghi},
  headline = {Data Scientist},
  email    = {name@example.com},
  location = {Ontario, Canada},
  linkedin = {linkedin.com/in/example},
  github   = {github.com/example}
}
```

Then both documents use:

```latex
\input{examples/profiles/profile-english.tex}
```

This separation demonstrates a reusable data layer rather than duplicated personal information.

## 8. Repository portfolio value

A strong job-facing repository should visibly demonstrate:

- understandable README;
- structured issues;
- milestone planning;
- focused branches;
- meaningful commits;
- reviewed pull requests;
- automated builds;
- releases;
- tagged versions;
- technical documentation;
- migration and changelog discipline.

The repository does not need every GitHub feature. It needs a coherent workflow that can be explained.
