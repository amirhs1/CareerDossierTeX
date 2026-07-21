# Contributing to CareerDossierTeX

Thank you for helping improve CareerDossierTeX.

This project uses focused issues, short-lived branches, pull requests, repeatable LuaLaTeX builds, and incremental releases. The goal is not process for its own sake; the goal is a repository whose behavior and history remain understandable.

## Before contributing

Read:

- [`README.md`](README.md) for current support;
- [`docs/API.md`](docs/API.md) for the public interface;
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for module boundaries;
- [`docs/ROADMAP.md`](docs/ROADMAP.md) for release scope;
- [`docs/MIGRATION.md`](docs/MIGRATION.md) before renaming public features;
- [`LICENSE`](LICENSE) for the project license.

Do not implement a planned feature as though it is already part of the current release. Confirm that it belongs to the active milestone.

## AI-assisted contributions

AI coding assistants are welcome. The maintainer uses them, and the repository
publishes an [`AI-POLICY.md`](AI-POLICY.md) and agent contract (`AGENTS.md`) for
that reason. An AI-assisted contribution is held to the same standard as any
other contribution.

**Disclose material assistance.** If an agent or model wrote or substantially
shaped code, tests, documentation, or other submitted content, name the tool and
summarize its role in the pull-request description. A short statement is enough;
do not include prompts, private reasoning, secrets, or personal data. Commit
attribution does not replace the pull-request disclosure.

**Own what you submit.** Before opening the pull request:

- read and understand the change, and be prepared to explain it and respond to
  review feedback;
- meet the same `tests/` obligation as any behavior change and actually run
  every check you claim passed;
- verify citations, links, and factual claims against primary sources; and
- confirm that no code, prose, font, image, data, or other asset has uncertain
  provenance or a license incompatible with LPPL v1.3c or later (see
  "Licensing contributions").

Large, unrequested, or unreviewed generated changes may be closed without a
line-by-line review. Open or claim a focused issue first for substantial work.

## Development requirements

Development requires:

- Git;
- LuaLaTeX (LuaHBTeX);
- `latexmk`;
- a sufficiently complete TeX Live or MiKTeX installation;
- `pdftotext` from Poppler when running extraction, layout, or bibliography
  checks;
- macOS with `osascript` to run the extraction suite's Apple PDFKit check; it is
  skipped elsewhere, so run the suite on macOS at least once before release; and
- BibLaTeX and Biber when running the optional bibliography example or the full
  `make check` suite.

The ordinary résumé, letter, and no-BibLaTeX CV paths do not require BibLaTeX or
Biber. CareerDossierTeX is LuaLaTeX-only; XeLaTeX and pdfLaTeX fail with an
actionable engine error.

## Issue workflow

Open or select an issue before starting a meaningful change.

A good implementation issue explains:

1. the problem or deliverable;
2. what is included;
3. what is excluded;
4. likely affected files;
5. observable acceptance criteria;
6. the test files under `tests/` that will prove those criteria;
7. the parent issue and release milestone.

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
- LuaLaTeX (LuaHBTeX) version;
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
test/regression-harness
ci/lualatex-build
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
ci(build): compile industry examples with LuaLaTeX
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

Build every supported example:

```bash
make
```

Run every suite CI runs — regression, extraction, smoke, layout, the focused
BibLaTeX/Biber fixture, and the tagged-structure fixtures — plus all supported
example builds:

```bash
make check
```

Clean generated files afterwards:

```bash
make clean
```

Run `make help` for the full target list. Every target runs the same command as
the matching job in `.github/workflows/build.yml`, so a local check and a CI
check cannot silently diverge. If you change a command in one place, change it
in the other.

The underlying invocation, if you prefer to run it directly or need to build a
single document:

```bash
latexmk -lualatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex

latexmk -lualatex -interaction=nonstopmode -halt-on-error \
  examples/industry/letter-industry.tex
```

Do not state that a build passes unless you have run it or CI has run it successfully.

## Test-driven where practical; test-as-you-go always

Do not schedule known feature tests for the end of a milestone. A feature, fix,
or behavior-changing refactor is incomplete until the smallest relevant test is
committed with it. When practical:

1. add a test that demonstrates the missing or incorrect behavior;
2. run it and confirm it fails for the expected reason;
3. implement the behavior;
4. run the focused test and the affected broader suites;
5. commit the test and implementation in the same pull request.

If a pre-implementation failure cannot be demonstrated safely—for example, a
new class does not exist yet—add the fixture alongside the first implementation
commit and explain the limitation in the pull request.

All automated test sources, expected outputs, fixtures, and runners belong under:

```text
tests/
├── regression/   # package/class API, options, diagnostics, and fixed bugs
├── smoke/        # supported document builds and failure-path fixtures
├── extraction/   # text-layer and reading-order round trips
└── layout/       # long-value, multi-page, and page-break stress sources
```

Create subdirectories only when the first real test needs them. Keep user-facing
demonstrations under `examples/`; tests may compile those examples, but must not
hide focused fixtures among them.

A separate test-only issue is appropriate for a reusable harness, a cross-cutting
quality improvement, or explicitly recorded legacy test debt. It must not be used
to postpone tests already known to be necessary for an implementation issue.

### Match the test to the module

Test-as-you-go is not one uniform activity. What "the smallest relevant test"
means depends on what the module owns, so match the test type to the concern:

- **Logic-bearing modules** — `careerdossier-base.sty` (metadata, field
  presence, separator logic) and the non-visual parts of
  `careerdossier-typography.sty` (engine checks,
  role dispatch) and `careerdossier-biblatex.sty` (author matching and fixed
  profile behavior) — carry behavior that can be asserted directly. Write a
  focused `l3build` regression test (`.lvt` source with a saved `.tlg` baseline) per
  module as the behavior is added, in the same rhythm as writing a `test_*.py`
  beside each Python module. This is where a pre-implementation failing test is
  usually practical and most valuable.
- **Layout classes** — `careerdossier-resume.cls`,
  `careerdossier-letter.cls`, and `careerdossier-cv.cls` — own page geometry and
  visual result, which no log diff fully captures. Cover them with smoke tests (compiles clean, expected
  diagnostics), extraction tests (text present and in logical order), and a small
  set of reviewed reference PDFs. Final layout correctness stays a human visual
  check. Do not force brittle per-line-break or per-metric assertions onto a
  class before its design has settled.

When a change spans both — a shared package edit that both classes render — add
or update the unit-level regression for the shared logic *and* re-run the smoke,
extraction, and layout coverage for both classes.

### Baselines are load-bearing

A saved baseline (an `l3build` `.tlg`, or the committed extraction reference) is
the assertion. Capturing it is not a formality: an incorrect baseline silently
records a bug as the expected result. Whenever you save or regenerate a baseline:

1. do it only for an output change that is intended and understood;
2. read the new baseline, or its diff against the previous one, and confirm every
   change is one you meant to make;
3. commit the baseline in the same change as the behavior it describes.

Never regenerate a baseline merely to make a red suite green.

### The harness precedes the tests that need it

`l3build` regression tests cannot run until the harness exists. The harness
(`build.lua` configured for `tests/regression/`) is therefore a prerequisite for
the per-module `.lvt` workflow above, not a parallel nicety: stand it up before —
or in the same change as — the first module whose coverage depends on it, rather
than accumulating `.lvt` sources that no runner can execute. Until the harness
lands, record the specific regression tests owed as explicit, tracked debt.

### Phase 1 coverage expectations

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
compiles a torture document and checks its text layer three ways:

    make extract-test          # or: tests/extraction/run.sh

1. **Poppler** — diffs `pdftotext` output against the committed
   `*.expected.txt` baseline.
2. **`/ActualText`** — fails if the PDF contains any `/ActualText` span. Poppler
   recovers interword spacing from glyph geometry and so cannot see the issue
   #72 defect; this check runs everywhere, including Linux CI.
3. **Apple PDFKit** — on macOS, diffs `PDFDocument.string` output against the
   committed `*.pdfkit.txt` baseline. This is the consumer path behind Preview,
   Quick Look, Spotlight, Safari, and copy/paste. It is skipped with a notice on
   other platforms, so **run the suite on macOS before release**.

PDFKit and Poppler impose different line structure on multi-column layout, so
each keeps its own baseline; do not expect the two to match.

It fails on any character, spacing, ordering, or Unicode-mapping change, and on
any non-allowlisted LuaLaTeX warning. Regenerate baselines **only** when a change
to output is intended and reviewed:

    tests/extraction/run.sh --update

On Linux this refreshes only the Poppler baselines. Regenerate the PDFKit
baselines on macOS, and review both diffs before committing.

Run it after any change to fonts, `fontspec` options, or the TeX distribution.
Rationale and the full method are in
[`docs/guides/ats-extraction.md`](docs/guides/ats-extraction.md).

### Tagged-PDF suite

Opt-in tagged output has its own suite covering four profiles — industry
résumé, industry letter, academic CV, academic letter:

    make tagging               # or: tests/tagging/run.sh

Each profile has three fixtures sharing one body include: `<name>.tex`
(`tagging=on`), `<name>-untagged.tex`, and `<name>-ua2.tex` (adds
`pdfstandard=ua-2`). The runner checks structure-tree classification, marks on
decorative and repeated content, tagged-versus-untagged word geometry, a
three-extractor round trip (Poppler, MuPDF, PDFKit), and PDF/UA-2 validation
with veraPDF. It also writes a toolchain record, since a validation result
means little without the versions that produced it.

**Optional gates skip rather than fail.** veraPDF, MuPDF, Biber, and PDFKit are
each probed once; when a tool is missing that gate is skipped and named in the
closing `GATES NOT RUN` summary. A green run on a partial environment is
therefore *not* evidence that everything passed — read the summary. Only
LuaLaTeX and Poppler are hard requirements.

The MuPDF baselines are compared with blank lines removed. `mutool`'s blank-line
placement inside a two-column entry header differs between its macOS and Debian
builds, so pinning it would assert a property of the extractor rather than of
the PDF. Line content and line order are still fully asserted, and the Poppler
baseline continues to pin exact spacing.

Baselines regenerate the same way as the extraction suite, and with the same
discipline — only for an intended, reviewed output change:

    tests/tagging/run.sh --update

veraPDF reports and the toolchain record land in `tests/tagging/reports/`, which
is gitignored: they are evidence retained per run and uploaded as CI artifacts,
never committed.

Recorded validation results, the outstanding VoiceOver and NVDA reading-order
checklists, and the tagged-BibLaTeX limitations are in sections 7.1–7.3 of
[`docs/guides/ats-extraction.md`](docs/guides/ats-extraction.md). Screen-reader
review is manual by nature and is not automated by this suite.

### Module regression suite (l3build)

The logic-bearing packages are covered by an `l3build` regression suite. Each
`.lvt` source under `tests/regression/` is compiled on LuaTeX and its filtered
log is diffed against a committed `.tlg` baseline. Run the whole suite from the
repository root:

    make regression            # or: l3build check

Run a single test by name (without the `.lvt` extension):

    l3build check base-diagnostics

A failing check writes the difference to `build/test/<name>.luatex.diff`; read it
to see the intended baseline versus the actual log. When an output change is
intended and understood, re-save the baseline, then review the diff before
committing it (see "Baselines are load-bearing" above):

    l3build save base-diagnostics

The harness is configured in `build.lua` (`tests/regression/`, LuaTeX, LaTeX
format). Writing a test: `\input{regression-test}`, load the package under test,
and inside `\TEST{name}{...}` use `\TYPE{...}` to record the behavior in the log.
Catcodes cannot be switched inside an already-tokenized `\TEST` body, so any
expl3 or `@`-bearing name must be reached through a helper defined earlier under
`\ExplSyntaxOn`, or via `\use:c`.

### BibLaTeX/Biber fixture

The optional integration has a focused multi-pass fixture that runs Biber,
rejects Biber warnings/errors, and diffs extracted output to pin `ydnt` ordering
and DOI → e-print → URL precedence:

    make bibliography-test     # or: tests/bibliography/run.sh

The ordinary academic CV smoke/example path remains separate and must continue
to compile without loading BibLaTeX or invoking Biber.

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

CareerDossierTeX is LuaLaTeX-only as of `v0.4.0`. Unsupported engines receive a
clear package or class error; `careerdossier-typography` owns the guard.

Do not add partial XeLaTeX or pdfLaTeX support without defining, documenting, and testing it.

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

For entry format, house style, and how `CHANGELOG.md` relates to GitHub
Release notes, see `docs/agent-workflows/release-notes.md`.

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
- tests added or updated under `tests/`;
- testing performed, including the expected pre-fix failure when demonstrated;
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
- confirm new behavior has a focused committed test under `tests/`;
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

The build workflow should:

- run on pull requests;
- run on pushes to `main`;
- run every committed automated suite under `tests/` that applies to the active
  milestone;
- compile every supported example;
- fail when compilation fails;
- upload PDFs and logs as artifacts;
- pin every container and third-party action to an immutable reference.

Do not require a status check in branch protection until that check has completed successfully at least once.

### Pinned dependencies

Every third-party action is pinned to a full commit SHA and the TeX Live
container to an image digest, each with a comment naming the release it came
from. A mutable tag such as `:latest` or `@v4` lets an upstream retag silently
change what runs, which would surface as an unexplained failure or an output
shift that looks like our bug.

The `toolchain` job records the TeX Live release, LuaHBTeX and the `lualatex`
format, `fontspec`, `pdfmanagement-testphase`, `tagpdf`, `l3build`,
BibLaTeX/Biber, and default-font paths that a run actually used, and uploads them
as the `toolchain-record` artifact. Read that artifact to learn
which release a digest resolves to.

### Bumping the pinned TeX Live image

1. Resolve the new digest:

   ```bash
   docker buildx imagetools inspect texlive/texlive:latest --format '{{.Manifest.Digest}}'
   ```

2. Replace the digest in every `container:` line in
   `.github/workflows/build.yml` and update the date comment at the top.
3. Push the branch and read the `toolchain-record` artifact to confirm the
   TeX Live release the digest resolved to; record it in the PR.
4. Inspect the full suite. A bump is expected to be behavior-neutral. If a
   `.tlg` baseline or an extraction reference changes, that is a finding to
   investigate and report — never regenerate a baseline merely to turn the
   suite green (see "Baselines are load-bearing").

## Release contributions

Release preparation should verify:

- release-blocking issues are closed;
- supported examples compile locally;
- the accumulated test suite passes without adding milestone-end coverage;
- CI passes on `main`;
- version strings are updated;
- `README.md` reflects current support;
- `API.md` matches implementation;
- `CHANGELOG.md` is updated;
- GitHub Release notes are drafted;
- `LICENSE` and `manifest.txt` remain accurate;
- the working tree is clean.

See `docs/agent-workflows/release-notes.md` for CHANGELOG and release-note
format, house style, and the LaTeX-package compatibility checklist.

Tagging and publishing a release should occur only after the release-preparation pull request is merged.
