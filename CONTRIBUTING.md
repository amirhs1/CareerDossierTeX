# Contributing to CareerDossierTeX

Thank you for helping improve CareerDossierTeX.

This project uses focused issues, short-lived branches, pull requests, repeatable XeLaTeX builds, and incremental releases. The goal is not process for its own sake; the goal is a repository whose behavior and history remain understandable.

## Before contributing

Read:

- [`README.md`](README.md) for current support;
- [`docs/API.md`](docs/API.md) for the public interface;
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for module boundaries;
- [`docs/ROADMAP.md`](docs/ROADMAP.md) for release scope;
- [`docs/MIGRATION.md`](docs/MIGRATION.md) before renaming public features;
- [`LICENSE`](LICENSE) for the project license.

Do not implement a planned feature as though it is already part of the current release. Confirm that it belongs to the active milestone.

## Development requirements

Phase 1 development requires:

- Git;
- XeLaTeX;
- `latexmk`;
- a sufficiently complete TeX Live or MiKTeX installation;
- optionally `pdftotext` for extraction checks.

CareerDossierTeX `v0.1.0` is XeLaTeX-only.

## Issue workflow

Open or select an issue before starting a meaningful change.

A good implementation issue explains:

1. the problem or deliverable;
2. what is included;
3. what is excluded;
4. likely affected files;
5. observable acceptance criteria;
6. the parent issue and release milestone.

Use focused issues that can be completed on one branch. Split work that becomes too broad.

### Bug reports

Include:

- what happened;
- what you expected;
- a minimal `.tex` reproducer;
- the exact compile command;
- the smallest useful log excerpt;
- operating system;
- TeX distribution and version;
- XeLaTeX version;
- CareerDossierTeX version or commit;
- whether the behavior worked in an earlier release.

### Feature proposals

Describe:

- the user-visible result;
- motivation;
- included and excluded scope;
- proposed public interface;
- likely files;
- acceptance criteria;
- testing approach;
- intended milestone.

Public API proposals should include example LaTeX syntax before implementation begins.

## Branch naming

Use:

```text
type/short-description
```

Recommended prefixes:

```text
feat/
fix/
docs/
test/
ci/
refactor/
release/
```

Examples:

```text
docs/v0.1-api
feat/shared-foundation
feat/resume-class
feat/industry-letter
fix/contact-separators
test/phase-1-examples
ci/xelatex-build
release/v0.1.0
```

Keep branch names short, lowercase, and free of spaces.

## Standard branch workflow

Update `main`:

```bash
git switch main
git pull --ff-only
```

Create a branch:

```bash
git switch -c feat/resume-class
```

Inspect changes regularly:

```bash
git status
git diff
```

Stage files intentionally:

```bash
git add careerdossier-resume.cls
git add examples/industry/resume-english.tex
```

Commit and push:

```bash
git commit -m "feat(resume): add initial English resume class"
git push -u origin feat/resume-class
```

Open a draft pull request early when the work is incomplete but ready for CI or design discussion.

## Commit messages

Use a lightweight Conventional Commits format:

```text
type(scope): imperative summary
```

Examples:

```text
docs(api): define v0.1 metadata keys
feat(core): add profile metadata storage
feat(resume): add dossier entry environment
feat(letter): add recipient address block
fix(components): omit separators for empty fields
test(resume): add long URL stress example
ci(build): compile industry examples with XeLaTeX
refactor(theme): centralize monochrome color tokens
```

Useful types:

```text
feat
fix
docs
test
ci
refactor
chore
release
```

Each commit should represent one coherent change. Avoid combining unrelated API, typography, CI, and documentation edits in one commit.

## Local builds

Build the résumé example:

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex
```

Build the cover-letter example:

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/letter-industry.tex
```

When available, build the supported examples through the repository `Makefile`:

```bash
make
```

Clean generated files:

```bash
latexmk -C examples/industry/resume-english.tex
latexmk -C examples/industry/letter-industry.tex
```

Do not state that a build passes unless you have run it or CI has run it successfully.

## Phase 1 testing expectations

Changes affecting shared packages should test both supported classes.

Minimum smoke tests include:

1. valid résumé;
2. valid cover letter;
3. missing required `name`;
4. missing optional `phone`;
5. missing optional `website`;
6. long LinkedIn or website field;
7. two-page résumé stress example;
8. text extraction.

Example extraction command:

```bash
mkdir -p build

pdftotext examples/industry/resume-english.pdf \
  build/resume-english.txt
```

Inspect the output for logical reading order.

### Extraction round-trip test

Beyond eyeballing reading order, run the automated extraction fixture, which
compiles a torture document and diffs its `pdftotext` output against a committed
baseline:

    tests/extraction/run.sh

It fails on any character, spacing, ordering, or Unicode-mapping change, and on
any non-allowlisted XeLaTeX warning. Regenerate the baseline **only** when a
change to output is intended and reviewed:

    tests/extraction/run.sh --update

Run it after any change to fonts, `fontspec` options, or the TeX distribution.
Rationale and the full method are in
[`docs/guides/ats-extraction.md`](docs/guides/ats-extraction.md).

### Log inspection

After compiling, inspect logs for:

- LaTeX errors;
- undefined control sequences;
- emergency stops;
- overfull boxes;
- missing glyphs;
- font substitutions;
- unresolved references.

Not every warning must become a failing CI check immediately. First determine whether it is meaningful and stable enough to enforce.

### Visual verification

When layout changes:

- inspect the affected PDFs;
- compare them with the current baseline;
- check page breaks;
- check long links and contact lines;
- attach or link a preview in the pull request.

## Coding conventions

### Public names

Use the `CDossier` prefix for public commands and environments:

```latex
\CDossierSetup
\CDossierSection
\begin{CDossierEntry}
```

Use explicit names that describe document behavior.

### Internal names

Prefer private `expl3` names:

```latex
\__cdossier_<module>_<action>:<signature>
```

Do not use private commands in examples or documentation.

### Package responsibility

Place code according to ownership:

- metadata and validation → `careerdossier-base.sty`;
- labels and language abstraction → `careerdossier-i18n.sty`;
- fonts and semantic text roles → `careerdossier-typography.sty`;
- colors and visual tokens → `careerdossier-theme.sty`;
- reusable rendered pieces → `careerdossier-components.sty`;
- résumé geometry and layout → `careerdossier-resume.cls`;
- letter geometry and prose behavior → `careerdossier-letter.cls`.

Do not place margins in the metadata package or duplicate contact-line logic inside both classes.

### Maintainable LaTeX

Prefer:

- LaTeX3 key-value interfaces for structured options;
- `xparse` or modern kernel command definitions;
- semantic commands;
- grouped local formatting;
- explicit errors and warnings;
- comments that explain design intent.

Avoid:

- unnecessary TeX primitives;
- undocumented global assignments;
- duplicated language-specific classes;
- silent acceptance of unsupported options;
- clever expansion tricks when a readable solution exists.

### Optional fields

Render optional fields structurally. Build a list of present fields and insert separators between them.

Do not generate every separator first and attempt to remove empty ones later.

### Engine support

Phase 1 is XeLaTeX-only. Unsupported engines should receive a clear package or class error.

Do not add partial pdfLaTeX or LuaLaTeX support without defining, documenting, and testing it.

## Documentation requirements

Update documentation in the same pull request as the related behavior.

### Update `API.md` when:

- a public command is added, changed, or removed;
- a class option or setup key changes;
- a default changes;
- validation behavior changes;
- a public warning or error changes meaningfully.

### Update `ARCHITECTURE.md` when:

- module responsibilities change;
- dependency direction changes;
- a new shared package is introduced;
- language, testing, or build strategy changes.

### Update `ROADMAP.md` when:

- release boundaries change;
- a feature moves between phases;
- a milestone is completed or postponed.

### Update `MIGRATION.md` when:

- a public command or key is renamed;
- behavior changes incompatibly;
- users need a replacement example.

### Update `CHANGELOG.md` when:

- a user-visible feature is added;
- behavior changes;
- a bug is fixed;
- a breaking change is introduced.

## Proposing public API changes

Before implementing a significant public API change:

1. open or update an issue;
2. describe the problem;
3. show proposed syntax;
4. provide at least one usage example;
5. identify compatibility consequences;
6. explain why a local fix is insufficient;
7. assign the correct milestone.

A public API change should answer:

- Is the name clear?
- Is the default predictable?
- Can unsupported values be rejected?
- Does it belong to the correct module?
- Can it be tested with a minimal example?
- Does it create unnecessary future compatibility obligations?

Before `v1.0.0`, breaking changes are allowed but must be documented in `CHANGELOG.md` and `MIGRATION.md`.

## Pull requests

A pull request should include:

- a concise summary;
- linked issues using `Closes #...` or `Fixes #...`;
- a focused change list;
- public API impact;
- testing performed;
- visual verification when layout changed;
- design decisions or follow-up work.

Use draft pull requests when implementation is incomplete.

### Self-review checklist

Before marking a pull request ready:

- read the full diff;
- remove unrelated files;
- verify public names;
- confirm comments explain intent;
- confirm generated build files are not committed accidentally;
- compile affected examples;
- inspect PDFs and logs;
- test missing optional fields;
- update documentation;
- update the changelog when appropriate;
- confirm CI passes;
- resolve review conversations.

## Merge strategy

Recommended:

```text
Squash and merge
```

Use a final squash title such as:

```text
feat(resume): add English industry resume class (#12)
```

After merging:

```bash
git switch main
git pull --ff-only
git branch -d feat/resume-class
```

Delete the remote branch when it is no longer needed.


## Licensing contributions

CareerDossierTeX is distributed under the LaTeX Project Public License, version 1.3c or, at your option, any later version.

By submitting a contribution, you agree that it may be distributed under the same license.

When adding or changing licensed source files:

- keep the official `LICENSE` text unchanged;
- add the project copyright, license, maintenance-status, and maintainer notice to new `.cls` and `.sty` files;
- update `manifest.txt` when the set of files constituting the LPPL Work changes;
- identify third-party code, fonts, images, or other assets and confirm that their licenses are compatible;
- do not copy code from another project without preserving its required notices.

The public class and package files should state that the Work has LPPL maintenance status `maintained` and that the current maintainer is Amir Sadeghi.

## Generated files

Do not commit routine build output:

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

Project policy:

- `.tex`, `.cls`, `.sty`, `.bib`, and documentation files are authoritative;
- CI PDFs and logs are artifacts;
- selected PDFs may be attached to releases;
- preview PNGs may be committed under `docs/assets/`.

## CI expectations

The Phase 1 workflow should:

- run on pull requests;
- run on pushes to `main`;
- compile both supported examples;
- fail when compilation fails;
- upload PDFs and logs as artifacts.

Do not require a status check in branch protection until that check has completed successfully at least once.

## Release contributions

Release preparation should verify:

- release-blocking issues are closed;
- supported examples compile locally;
- CI passes on `main`;
- version strings are updated;
- `README.md` reflects current support;
- `API.md` matches implementation;
- `CHANGELOG.md` is updated;
- `LICENSE` and `manifest.txt` remain accurate;
- the working tree is clean.

Tagging and publishing a release should occur only after the release-preparation pull request is merged.
