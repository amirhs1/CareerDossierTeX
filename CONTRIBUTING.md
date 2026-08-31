# Contributing to CareerDossierTeX

Thank you for helping improve CareerDossierTeX.

For people changing the code: how to propose, build, test, and submit a change.
[`docs/NAMING-CONVENTION.md`](docs/NAMING-CONVENTION.md) owns the naming rules
this file refers to, and [`AGENTS.md`](AGENTS.md) is the equivalent contract for
AI coding agents.

This project uses focused issues, short-lived branches, pull requests, repeatable LuaLaTeX builds, and incremental releases. The goal is not process for its own sake; the goal is a repository whose behavior and history remain understandable.

## Before contributing

Read:

- [`README.md`](README.md) for current support;
- the PDF manual, [`doc/careerdossier.tex`](doc/careerdossier.tex), for the
  public interface — build it with `make manual`;
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for module boundaries;
- [`docs/ROADMAP.md`](docs/ROADMAP.md) for release scope;
- [`docs/MIGRATION.md`](docs/MIGRATION.md) before renaming public features;
- [`docs/TESTING.md`](docs/TESTING.md) before writing or running a test;
- [`LICENSE`](LICENSE) for the project license.

Do not implement a planned feature as though it is already part of the current release. Confirm that it belongs to the active milestone.

## AI-assisted contributions

AI coding assistants are welcome. The maintainer uses them, and the repository
publishes an [`AI-POLICY.md`](AI-POLICY.md) and agent contract (`AGENTS.md`) for
that reason. An AI-assisted contribution is held to the same standard as any
other contribution.

**Disclose material assistance.** If an agent or model wrote or substantially
shaped code, tests, documentation, or other submitted content, fill in the
`AI assistance` section of the pull-request template. `AI-POLICY.md`
("Attribution") is normative for what that section must contain and how it
relates to commit trailers; neither is repeated here. A short statement is
enough, and it must not include prompts, private reasoning, secrets, or personal
data.

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

The ordinary resume, letter, and no-BibLaTeX CV paths do not require BibLaTeX
or Biber. Install LuaLaTeX: `AGENTS.md` rule 1 states the engine scope and what
the unsupported engines do, and is not repeated here.

## Work item structure

Three rules govern how work is divided across issues, pull requests, and
branches. They exist so the history explains itself: every change should be
traceable to a release, to a written rationale, and to a reviewable diff.

These three rules are documentation, not enforcement. What actually gates a
merge to `main` is the `Protect Main` ruleset; see "What actually gates a merge"
under "CI expectations".

### 1. Every issue carries a milestone

The milestone answers *which release*, and almost every issue can answer it. An
issue without one is invisible to release planning and to the Project's `Phase`
field, which follows the milestone.

The exception is work whose release is **genuinely undecided** — deferred design
work with no scheduled release, or a proposal whose home has not been chosen.
Such an issue stays unmilestoned rather than take a milestone that would
misstate the plan, and it stays invisible to release planning on purpose until
that decision is made. Do not invent a placeholder milestone for it, and do not
park it in the furthest-out open milestone. `docs/NAMING-CONVENTION.md`
"Milestone naming convention" names the issues that currently qualify; anything
unmilestoned beyond those is an oversight.

An **epic parent** is for work that genuinely decomposes into several issues — a
release epic, or a cross-cutting effort spanning more than one class or package.
A bug found mid-milestone, a CI repair, or a documentation sync takes a
milestone and no parent. Do not create a placeholder epic so a lone issue has
somewhere to sit; that reproduces the milestone with extra steps.

Where an epic exists, its **sub-issue graph is canonical**. A checklist in the
epic body is a rendering of that graph, not a second register — if the two
disagree, the graph is right. Prefer GitHub's rendered sub-issue progress over a
list maintained by hand.

### 2. Every pull request links an issue, with three exceptions

Use `Closes #...` or `Fixes #...` in the pull request body. The exceptions are:

- a revert of a merged change;
- a release chore, such as a version bump or a changelog assembly pull request;
- a CI, tooling, or lint repair that restores an existing check.

When an exception applies, the pull request body carries what the issue would
have: the problem, the proposal, and the acceptance criteria. The obligation is
that the reasoning exists in a reviewable place before the change merges — the
issue is the usual vehicle for it, not the only one.

An issue whose body would only restate its pull request's title is a sign that
an exception applies, not a form to fill in.

### 3. Every pull request comes from a focused branch, merged within three days

Branch from an up-to-date `main`, one issue per branch where practical. Direct
commits and pushes to `main` are reserved to the maintainer; `AGENTS.md` rule
11 (Maintainer authority) states that reservation and the rest of the
maintainer-only action set, which this guide does not repeat.

Three days is the assessable part of "short-lived". A branch that outlives it is
rebased onto `main`, split into smaller pieces, or closed — not silently
carried. A long-running branch accumulates conflicts against calibrated token
values and saved `.tlg` baselines faster than it accumulates review.

## Issue workflow

Open or select an issue before starting a meaningful change, subject to the
exceptions in "Every pull request links an issue" above.

A good implementation issue explains:

1. the problem or deliverable;
2. what is included;
3. what is excluded;
4. likely affected files, as the output of a search rather than of recall, with
   the command that produced the list recorded beside it. An issue scoped to the
   first file someone noticed the statement in is fixed in that file alone;
5. observable acceptance criteria; where the issue concerns a statement or value
   that could appear in more than one place, at least one of them is a command
   over the repository rather than a check of the files named in item 4. A
   criterion that reads only the named files cannot fail on the copy nobody
   thought to look for — #275 wrote its criterion as a command instead, and the
   command found four hits where the issue had named two.

   Scope that command by **excluding directories, never by filtering in on
   extension**. `--include='*.md'` matches no file that has no extension, so it
   is blind to `Makefile` and `LICENSE` — and to whatever extensionless file is
   added next — and it filters build artifacts in rather than out. `git grep`
   needs neither flag: it searches tracked files, so `build/` is excluded by
   construction. #491's criterion was a command over the repository and still
   certified an incomplete fix — it named two copies of a stale value, and the
   third was in `Makefile`:

   ```bash
   # On ce42158^, the tree #491 was filed against:
   git grep -n -e '[0-9]\+-page' ce42158^                    # finds all 3
   git grep -n -e '[0-9]\+-page' ce42158^ -- '*.md' '*.lua'  # finds 2 of 3
   ```

   A criterion narrower than the defect is worse than none: it certifies the
   fix that left a copy behind, at review time, when the diff shown is correct;
6. the test files under `tests/` that will prove those criteria;
7. where the issue prescribes a *mechanism* rather than an outcome, the smallest
   command that would show that mechanism does not work, and the result of
   running it — see "How this could be wrong" in the templates;
8. the release milestone, which is required, and the parent epic when the issue
   is part of one.

Use focused issues that can be completed on one branch. Split work that becomes too broad.

The templates in `.github/ISSUE_TEMPLATE/` encode that structure —
`bug_report.md`, `feature_request.md`, and `epic.md`. File from one of them
rather than a blank body; blank issues are disabled. From the command line:
`gh issue create --template feature_request.md`.

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

`docs/NAMING-CONVENTION.md` "Branch naming convention" is the canonical list
of allowed prefixes
and worked examples; it is not reproduced here.

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

Keep the branch short-lived, on the terms "Every pull request comes from a
focused branch, merged within three days" sets out above.

## Commit messages

Use a lightweight Conventional Commits format:

```text
type(scope): imperative summary
```

`docs/NAMING-CONVENTION.md` "Commit message convention" is the canonical list
of types and
worked examples; it is not reproduced here.

Each commit should represent one coherent change. Avoid combining unrelated API, typography, CI, and documentation edits in one commit.

## Local builds

Build every supported example:

```bash
make
```

Run every suite CI runs — the static lint, the module regression suite,
extraction, smoke, layout, the focused BibLaTeX/Biber fixture, the link
copy-paste, default-path metadata, and link-annotation suites, and the
tagged-structure fixtures — plus all supported example builds:

```bash
make check
```

Clean generated files afterwards:

```bash
make clean
```

`make help` is the authoritative target list, and the `Makefile`'s
`CHECK_TARGETS` variable — which both `check` and `check-serial` dispatch — is
the authoritative suite list. Prefer both to any prose enumeration, here or
elsewhere. A hand-maintained copy of either will drift, and a drifted copy is
how the `annotations` suite came to be omitted from a run that was then reported
clean.

A local check and the matching CI job are equivalent, but not textually
identical. Most jobs run the same `make` target you would; `extraction`,
`tagging`, `smoke`, and `layout` invoke `tests/<suite>/run.sh` directly and
`regression` runs a bare `l3build check` — in each case the same command the
target itself wraps, with the empty selector described below. If you change a
command in one place, change it in the other.

Target and job names overlap but are not in bijection, so do not derive one from
the other. The extraction and bibliography *targets* are `extract-test` and
`bibliography-test`, while the matching *jobs* are `extraction` and
`bibliography`; job `cv` runs `make academic-cv academic-bibliography` and job
`statement` runs `make statements`; and `examples`, `check`, `check-serial`,
`check-parallel`, `test`, `clean`, `ctan`, and every `review-*` target have no
job at all. Two of those need a word. `ctan-lint` is dispatched by `make check`
like any other suite, but its CI cover is a *step* of the `regression` job
rather than a job of its own: it loads `build.lua` under `texlua`, so it cannot
run in the TeX-free `lint` job, and the `regression` job already loads that file.
And `ctan` builds the release archive — a release-time action rather than a
per-pull-request one, which is why `ctan-lint` checks the configuration on every
run while the target itself is called for by
[`docs/RELEASE-CHECKLIST.md`](docs/RELEASE-CHECKLIST.md#building-the-archive).

### The gate, and the serial path

`make check` runs its twelve targets four at a time — about four minutes on the
maintainer's machine where `check-serial` takes seven, as orientation rather
than a figure to plan around. It is the pre-push gate. Set the worker count with
`JOBS`, or take the deterministic path instead:

```bash
make check                     # the gate: twelve targets, four at a time
make check JOBS=2              # fewer workers
make check-serial              # one target after another
```

`check-serial` dispatches exactly the same targets in the same order and is
worth reaching for when a parallel run reports something surprising: it removes
scheduling as a variable in one command. `check-parallel` survives as an alias
of `check`.

Four is the default because it is the fastest value measured green. The
`Makefile` header, where `JOBS` is defined and defaulted, owns that answer and
the standing of `JOBS=8` — which is **unmeasured rather than barred**, so
`make check JOBS=8` is a supported thing to run on hardware with the cores for
it. Neither question is answered here.

The driver is `tests/check-parallel.sh`. `docs/TESTING.md` "The parallel run" is
canonical for how it works, what it asserts beyond running the same targets, the
two tool caches it has to prepare first, its measured speedup, its ordered
replay of per-target output under `build/check-parallel/`, its disk cost, and
what a scheduled run had to prove before it could be the gate; none of that is
repeated here beyond the orientation figure above.

### Scoping a suite while you iterate

A suite that only runs whole is a suite you pay for whole. A failure in the
fiftieth of fifty-four layout fixtures used to cost the forty-nine compiles
ahead of it — the whole suite's wall time to learn one thing — and that cost is
what pushes a development loop towards guessing instead of checking.

Five targets take an optional selector:

```bash
make regression TEST=base-diagnostics
make smoke FIXTURE=bad-medium
make layout FIXTURE=resume-two-page
make extract-test FIXTURE=statement
make tagging FIXTURE=cv-subsection
```

`TEST` is passed through to `l3build check <name>` and is an exact test name.
`FIXTURE` is a shell glob matched anywhere in a fixture's basename, so a plain
word behaves as a substring search (`bad-medium` selects four smoke fixtures)
and a wildcard anchors it (`FIXTURE='resume-*'`). List the names without
compiling anything:

```bash
tests/layout/run.sh --list
tests/layout/run.sh --list two-page
```

Three properties make this safe to trust:

- **With no selector, nothing changed.** `make check` and every CI job invoke
  the suites unscoped and run exactly what they ran before.
- **A selector that matches nothing fails the run.** Every assertion these
  suites make is made per fixture, so a run that selected no fixture passes all
  of them — "0 fixtures, all passed" and "the suite is clean" print the same
  thing otherwise.
- **A scoped run says so.** Its closing line carries the filter, the count, and
  `NOT a full run`, so a filtered transcript cannot be pasted into a PR as
  evidence of a full one.

Scoping is a development-loop convenience and nothing more. `make check` before
you push is still the gate, and a scoped run is not a test result for the PR
body.

`make tagging` is the one whose selectable unit is not the `.tex` file but the
fixture **group**: `resume`, `cv-subsection`, `biblatex-ua2`. A group is a base
fixture plus the companions that assert nothing on their own — `-untagged`,
which exists to be compared against the tagged build, and `-ua2`, which shares
the group's `-body.inc` so a veraPDF verdict describes the output the structural
checks assert on. Selecting those separately would let a run assert less than it
appears to, so the twelve groups are backed by 37 `.tex` files.

That suite also has gates that can be unavailable (veraPDF, MuPDF, Biber,
PDFKit). A scoped run that selects a group whose only path is behind a missing
gate reports it under `SELECTED BUT NOT RUN` rather than letting "not selected"
and "selected, checked nothing" print as the same blank space.

`tests/lint/run-fixture-filter.sh` holds this contract to account and runs in
the `lint` slot; see `docs/TESTING.md` "Option lint".

### Running one suite's fixtures concurrently

Scoping helps when you know which fixture you care about. When you need the
whole of a long suite — before a push, or when the failure could be anywhere —
`smoke`, `layout`, and `tagging` take `JOBS=N` and run that many of their own
fixtures at once:

```bash
make smoke JOBS=4
make layout JOBS=8 FIXTURE='resume-*'
```

**With no `JOBS` nothing changes.** Each runs exactly the fixtures it ran
before, in the same order, with byte-identical output — which is what CI invokes
and why it is unaffected.

`JOBS` composes with `FIXTURE`, and it composes with the gate — but the two
layers multiply, so `check` pins the inner one to 1 and you raise it
deliberately:

```bash
make check JOBS=4 INNER_JOBS=2
```

That pinning is why making the gate parallel did not quietly quadruple the
process budget along with it.

`docs/TESTING.md` "Fanning out inside a suite" is canonical for the measured
speedups, the shared dispatcher, the accounting assertion that makes a
concurrent run safe to believe, and the process budget; none of it is repeated
here.

The underlying invocation, if you prefer to run it directly or need to build a
single document:

```bash
latexmk -lualatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex

latexmk -lualatex -interaction=nonstopmode -halt-on-error \
  examples/industry/letter-industry.tex
```

Do not state that a build passes unless you have run it or CI has run it successfully.

## Testing

The obligation is one sentence: a behavior change is incomplete until the
smallest test that fails without it is committed alongside it. Everything else —
where test material lives, which kind of test a given concern takes, the
coverage a change has to satisfy, each suite and review target in turn, how a
baseline is regenerated, and what to read in the logs and the rendered pages
afterwards — is stated in [`docs/TESTING.md`](docs/TESTING.md), which is
canonical for all of it and is not summarized here. Read the section that covers
what you are changing; it is reference material, not a document to read through.

"Local builds" above is the other half: how to invoke a suite, how to scope one
while you iterate, and how a target relates to its CI job. `make check` before
you push is the gate.

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

Place code according to ownership. `docs/ARCHITECTURE.md` ("File
responsibilities") carries the concern-to-module map and the per-file detail,
and `AGENTS.md` ("Module ownership") the dependency direction and the two
standing rules about page geometry and the CV's independence from BibLaTeX.
Neither is reproduced here.

One rule this guide adds: do not duplicate contact-line logic inside the
classes.

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

`AGENTS.md` rule 5 states how optional fields are rendered and is not repeated
here. The implementation consequence: do not generate every separator first and
attempt to remove the empty ones later.

### Engine support

`AGENTS.md` rule 1 states the engine scope and is not repeated here. Two things
specific to writing the code: `careerdossier-typography` owns the guard, and
partial XeLaTeX or pdfLaTeX support is not to be added without defining,
documenting, and testing it.

## Documentation requirements

Update documentation in the same pull request as the related behavior.

A reference document under `docs/` states the rule, the constraint that makes it
non-obvious, and the issue that decided it; the alternatives considered and the
measurements that discriminated between them belong in that issue. The test is
which sentences a person about to re-propose the change would need to read in
order to stop — those stay, and the rest is evidence for them. Check with
`gh issue view <n> --comments` and write the derivation into the issue before
cutting it from the document, because several issues do not carry their own
(#479).

### Update the manual (`doc/careerdossier.tex`) when:

- a public command is added, changed, or removed;
- a class option or setup key changes;
- a default changes;
- validation behavior changes;
- a public warning or error changes meaningfully.

The manual is the interface reference; `docs/API.md` is a pointer to it plus the
stability policy (#263). Build it with `make manual`, and read the built PDF
rather than the source before deciding the wording reads correctly.
`make lint` fails if the manual documents a private LaTeX3 name, documents a
public name that appears in no file of the Work, or declares a release the Work
does not.

### Update `ARCHITECTURE.md` when:

- module responsibilities change;
- dependency direction changes;
- a new shared package is introduced;
- language, testing, or build strategy changes.

### Update `ATS-EXTRACTION.md` when:

It holds the design rules for extraction, tagging, and fonts — what the output
has to do and why — and no fixture, baseline, procedure, or recorded result.
Update it when:

- the reading order a document must extract in changes;
- a rule about the text layer, its Unicode mapping, or copy-paste integrity
  changes;
- what tagged structure is required to say, or what a validator result is taken
  to license, changes;
- a font or ligature policy that extraction depends on changes.

### Update `TESTING.md` when:

- a suite, review target, fixture group, or runner selector changes;
- a threshold, floor, or accepted exception changes;
- the coverage a kind of change owes changes;
- a baseline regeneration procedure changes;
- a fixture, baseline, or extractor in the extraction or tagging suites
  changes; or
- a manual procedure, such as the screen-reader or portal pass, changes.

### Update `RELEASE-CHECKLIST.md` when:

- a per-release gate is added, removed, or reworded;
- the CTAN packaging or licence-audit requirements change;
- a check's supporting evidence moves to a different suite or document.

### Update `ROADMAP.md` when:

- release boundaries change;
- a feature moves between phases;
- a milestone is completed or postponed.

### Update `MIGRATION.md` when:

- a public command or key is renamed;
- behavior changes incompatibly;
- users need a replacement example.

An entry takes this shape, and belongs in the same pull request as the change it
describes:

```text
## [0.x.0] - YYYY-MM-DD

### `\OldCommand` renamed to `\NewCommand`

Before:

\OldCommand{...}

After:

\NewCommand{...}

Reason: <why the change was necessary>
```

A toolchain break is not an API rename and does not take that shape: the
`v0.4.0` XeLaTeX-to-LuaLaTeX change is written as an upgrade guide in
[`docs/MIGRATION.md`](docs/MIGRATION.md#upgrading-to-v040-xelatex--lualatex)
instead. The stability policy both serve is in
[`docs/API.md`](docs/API.md#stability-policy).

### Update `CHANGELOG.md` when:

- a feature is added;
- behavior changes;
- a bug is fixed;
- a breaking change is introduced.

Each of those four is qualified by *user-visible*: `manifest.txt` calls
`CHANGELOG.md` "user-visible changes per release", and that is the whole test —
what changed, not who ran it. A change that alters rendered output, a public
name, or a documented behavior earns an entry however internal its cause looks.
Maintainer tooling and agent instructions do not: `.agents/`, `.claude/`, a CI
workflow, a maintainer-only script. Neither does a `Makefile` target a
contributor is told to run, which is documented here instead. The boundary is
not applied backwards — entries already shipped stay as written, including five
in `[0.7.0]` (#188, #195, #211, #233, #236) and one in `[0.8.0]` (#334) that it
would not have produced (#260). `CHANGELOG.md` carries a note under each
release's own heading saying so, listing the same entries, so a reader who
opens the register first is not left reading them as precedent (#410, #413).

`[Unreleased]` is the one section this is *not* true of. It sits inside the
boundary's own era and is still editable, so an entry there that the boundary
would not have produced is removed at release preparation rather than annotated
— a note saying it predates the rule would be false. `v0.9.0` was the first
release to sweep it, and eleven entries came out (#414); the sweep is a standing
step in `.agents/skills/release-notes/reference.md`, "The tooling sweep".

For entry format, house style, and how `CHANGELOG.md` relates to GitHub
Release notes, see `.agents/skills/release-notes/reference.md`.

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

Before `v0.10.0`, breaking changes are allowed but must be documented in `CHANGELOG.md` and `MIGRATION.md`.

## Pull requests

A pull request should include:

- a concise summary;
- linked issues using `Closes #...` or `Fixes #...`, or, under one of the three
  exceptions in "Work item structure", the problem, proposal, and acceptance
  criteria stated in the body instead;
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
- record the tested toolchain beside the output it produced — TeX Live and
  LuaHBTeX versions, the LaTeX format date, and the `fontspec`, `luaotfload`,
  `tagpdf`, and `pdfmanagement-testphase` versions — so a result can be
  attributed to the build that produced it;
- keep its commands locally reproducible where practical;
- pin every container and third-party action to an immutable reference.

Broader gates are later-phase targets: a CI matrix (current TeX Live, optionally
the oldest supported release, a scheduled pre-release job); mandatory failure on
new unexpected warnings, missing/substituted font faces, semantic extraction
differences, ordered-block failures, unembedded meaningful fonts, `qpdf --check`
errors, or visual clipping.

Run the full suite, not only unit tests, after changes to: fonts or font versions;
`fontspec` options; section or entry formatting; box, list, header, footer, or
page-break code; hyperlink or icon packages; tagged-PDF settings; bibliography
styles **(planned)**; minimum LaTeX version; the TeX Live image; or any dependency
that affects output.

### What actually gates a merge

Branch protection on `main` is the `Protect Main` **ruleset**, not classic
branch protection, so read it with `gh api repos/<owner>/<repo>/rulesets` rather
than from the older branch-protection endpoint or from this paragraph. As last
derived, it requires a pull request, allows all three merge methods, requires
**zero** approving reviews, forbids deletion and non-fast-forward pushes, and
requires a named list of job contexts to pass against an up-to-date branch.
Green CI is therefore the merge gate; a branch that is not close-out complete
when it goes green is one that can be merged incomplete.

**How many contexts, and which, is a question for the ruleset and not for this
paragraph.** The list is not the workflow's job count — a job may exist without
being required, which is the state every new check passes through under the rule
below. Read it:

```bash
gh api repos/amirhs1/CareerDossierTeX/rulesets \
  --jq '.[] | select(.name=="Protect Main") | .id'
gh api repos/amirhs1/CareerDossierTeX/rulesets/<id> \
  --jq '[.rules[] | select(.type=="required_status_checks")
         | .parameters.required_status_checks[].context]'
```

A number written here instead would be wrong on the day someone adds a check.
That is not hypothetical: this paragraph said sixteen, named `manual` as the job
that was deliberately not yet required, and was falsified within the hour when
the maintainer required it (#451).

Do not require a status check in the ruleset until that check has completed
successfully at least once. Once it has, delete the "this is a new check"
comment that guarded it in `.github/workflows/build.yml` — a comment that
outlives its condition reads as current policy.

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

`verapdf-scheduled.yml` additionally pins veraPDF itself to a commit SHA
rather than a container digest or action tag, because `veraPDF/veraPDF-apps`
publishes tags but no release binaries — there is no prebuilt artifact to pin
by digest. The commit SHA is immutable by construction; the workflow verifies
the checked-out commit matches the pin before building, and fails rather than
silently building an unpinned `HEAD` if a fetch ever resolved differently.

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
   suite green (see `docs/TESTING.md` "Baselines are load-bearing").

## Release contributions

Release preparation should verify:

- release-blocking issues are closed;
- supported examples compile locally;
- the accumulated test suite passes without adding milestone-end coverage;
- CI passes on `main`;
- version strings are updated — `make lint` asserts that the ten Work files
  declare the same version and date as each other, so a bump that missed one is
  caught, but nothing checks the pair against the tag you are about to cut;
- `README.md` reflects current support;
- the manual matches implementation;
- `CHANGELOG.md` is updated;
- GitHub Release notes are drafted;
- `LICENSE` and `manifest.txt` remain accurate;
- the working tree is clean.

See `.agents/skills/release-notes/reference.md` for CHANGELOG and release-note
format, house style, and the LaTeX-package compatibility checklist.

Tagging and publishing a release should occur only after the release-preparation pull request is merged.
