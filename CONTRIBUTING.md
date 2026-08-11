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
summarize its role in the `AI assistance` section of the pull-request template,
which is its last section. A short statement is enough; do not include prompts,
private reasoning, secrets, or personal data. Commit attribution does not
replace the pull-request disclosure — when a commit carries an AI
`Co-authored-by` trailer, repeat that trailer's exact identity and email in the
disclosure so the two records agree.

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
park it in the furthest-out open milestone. `docs/NAMING-CONVENTION.md` §7 names
the issues that currently qualify; anything unmilestoned beyond those is an
oversight.

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

Branch from an up-to-date `main`, one issue per branch where practical. Never
commit or push to `main` directly.

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
4. likely affected files;
5. observable acceptance criteria;
6. the test files under `tests/` that will prove those criteria;
7. the release milestone, which is required, and the parent epic when the issue
   is part of one.

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

Allowed prefixes:

```text
feat/
fix/
docs/
test/
ci/
refactor/
release/
chore/
```

`docs/NAMING-CONVENTION.md` section 3 is the canonical list.

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

Keep the branch short-lived. Merge or rebase onto `main` within three days; if
the work will not land in that window, split it rather than letting the branch
run. See "Every pull request comes from a focused branch, merged within three
days".

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

Run every suite CI runs — the option lint, the module regression suite,
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

`make help` is the authoritative target list, and the `check` prerequisites at
`Makefile:92` are the authoritative suite list. Prefer both to any prose
enumeration, here or elsewhere. A hand-maintained copy of either will drift, and
a drifted copy is how the `annotations` suite came to be omitted from a run that
was then reported clean.

A local check and the matching CI job are equivalent, but not textually
identical. Most jobs run the same `make` target you would; `extraction`,
`tagging`, `smoke`, and `layout` invoke `tests/<suite>/run.sh` directly and
`regression` runs a bare `l3build check` — in each case the same command the
target itself wraps, with the empty selector described below. If you change a
command in one place, change it in the other.

### Scoping a suite while you iterate

A suite that only runs whole is a suite you pay for whole. A failure in the
fiftieth of fifty-four layout fixtures used to cost the forty-nine compiles
ahead of it — the whole suite's wall time to learn one thing — and that cost is
what pushes a development loop towards guessing instead of checking.

Four targets take an optional selector:

```bash
make regression TEST=base-diagnostics
make smoke FIXTURE=bad-medium
make layout FIXTURE=resume-two-page
make extract-test FIXTURE=statement
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

`tests/lint/run-fixture-filter.sh` holds this contract to account and runs in
the `lint` slot; see "Option lint" below.

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
├── lint/         # source-level invariants no compiled fixture can assert
├── regression/   # package/class API, options, diagnostics, and fixed bugs
├── smoke/        # supported document builds and failure-path fixtures
├── extraction/   # text-layer and reading-order round trips
├── layout/       # long-value, multi-page, and page-break stress sources
├── links/        # copy-paste integrity of URLs and e-mail addresses
├── metadata/     # default-path PDF catalog metadata, /Lang included
├── annotations/  # link-annotation action types (/S/URI, never /S/GoToR)
├── bibliography/ # Biber-backed sorting and rendered identifier precedence
└── tagging/      # tagged structure, the untagged path, and the extractor matrix
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

- **Observable logic** — values, options, errors, or emitted structure — can be
  asserted directly by a log diff. Write a focused `l3build` regression test
  (`.lvt` source with a saved `.tlg` baseline) under `tests/regression/` as the
  behavior is added, in the same rhythm as writing a `test_*.py` beside each
  Python module. This is where a pre-implementation failing test is usually
  practical and most valuable. **No module is exempt.** Every shared package and
  every class already has such coverage — 46 `.lvt`/`.tlg` pairs when this line
  was last derived, and `ls tests/regression/*.lvt | wc -l` is the live count —
  so extend the existing file for that module rather than assuming a class does
  not need one.
- **Layout behavior** — the visual result the classes own — is what no log diff
  fully captures, and it takes coverage *in addition to* the regression test:
  smoke tests (compiles clean, expected diagnostics), extraction tests (text
  present and in logical order), tagging fixtures, and a small set of reviewed
  reference PDFs. Final layout correctness stays a human visual check. Do not
  force brittle per-line-break or per-metric assertions onto a class before its
  design has settled.

When a change spans both — a shared package edit that both classes render — add
or update the unit-level regression for the shared logic *and* re-run the smoke,
extraction, and layout coverage for both classes.

### Five-family page-two visual review

Build the repeatable page-two review set from the repository root:

```bash
make review-page-two
```

The command compiles the canonical two-page résumé, industry-letter, academic
CV, academic-letter, and research-statement fixtures. It renders page two for
all five short-name cases, then repeats the CV, academic letter, and statement
with a deliberately long name. It also renders page two of all six specialized
statement examples (research, teaching, teaching philosophy, diversity, artist,
and purpose) and the default-interest long-fields fixture. The research
statement remains the sole representative tagged statement profile; the
statement-title regression pins all seven display and running-title defaults
without duplicating tagged tests.

Review the PNGs under `build/page-two-review/` and record the result in the pull
request:

1. all five short-name running headers are centered, clear, and neither clipped
   nor crowded; the CV, academic-letter, and statement long-name renders meet
   the same requirement;
2. their `Page N of M` folios are centered, correctly numbered, and separated
   cleanly from the body;
3. the gap between running furniture and body text is consistent and no body
   content overlaps either header or folio;
4. the résumé and industry-letter page-two renders use the same running-header
   and `Page N of M` policy as the other document classes;
5. each specialized statement example uses the expected applicant name and
   type-specific running title on page two;
6. the default-interest long-name header shows `Statement of Interest` without
   clipping (the layout suite separately gates its page-one contact fields on
   overfull boxes); and
7. links, page breaks, and body content remain visible and unclipped.

The PDFs, page-two PNGs, logs, and review record are generated evidence under
the gitignored `build/` directory. They must not be committed.

### Size/margin reference matrix

Build the `{normal,narrow} x {10pt,11pt,12pt}` reference matrix across all four
document classes from the repository root:

```bash
make review-matrix
```

The command compiles the canonical two-page résumé, CV, industry-letter, and
research-statement fixtures — the same ones `review-page-two` uses — at every
size/margin combination, 24 PDFs in total. The statement class is represented
by a single type (research); per-type rendering differences are already
covered by the five-family page-two review and the statement-title
regression, so statement type does not multiply this matrix.

Each PDF is named `<type>-<margin>-<fontsize>.pdf` (for example
`resume-normal-11pt.pdf`), so a directory listing groups every size of one
margin preset together.

Review the PDFs under `build/size-margin-matrix/` and record the result in the
pull request:

1. every type size in the output is a whole number of points;
2. bullets align with section headings, section rules, and entry titles;
3. the heading-to-rule gap is visibly smaller than the rule-to-content gap at
   every size;
4. gaps scale with the body size — a 12pt document does not feel cramped and a
   10pt one does not feel loose;
5. no overfull boxes, missing glyphs, font substitutions, or unresolved
   references in any log — the runner flags any combination with such
   diagnostics in `review-record.txt` rather than hiding it, but still builds
   the remaining combinations so they can all be reviewed together; and
6. print and grayscale behaviour, and text extraction and logical reading
   order, are unchanged from the existing per-class coverage.

The PDFs, logs, and review record are generated evidence under the gitignored
`build/` directory. They must not be committed.

### Entry-metadata placement and de-emphasis matrix

Build the `{column,inline} x {italic,gray,both,plain}` matrix for the two record
classes from the repository root:

```bash
make review-entrymeta-muted
```

`entrymeta` and `muted` both land on the same piece of the page — the entry
heading's dates and location — so the pair has to be reviewed as a grid rather
than one option at a time. The command compiles the canonical two-page résumé
and CV fixtures at all sixteen combinations, leaving every other option at its
class default, so each visible difference is attributable to the two options in
the filename (`<type>-<entrymeta>-<muted>.pdf`). This is what separates it from
`review-matrix`, which sweeps size and margin with the semantic options fixed.

Review the PDFs under `build/entrymeta-muted-matrix/` and record the result in
the pull request. Two cells carry most of the weight: `*-column-plain`, because
`muted=plain` under `entrymeta=column` is what a document setting neither option
gets, and `inline` with an italic-bearing `muted`, because that is the only
place a de-emphasised run sits beside the — deliberately never italic — entry
metadata separator.

### Link decoration under `medium`

Build the print/screen link-decoration pair:

```bash
make review-link-decoration
```

`medium=screen` rules author-written `\href` anchor text and `medium=print`
does not. What that branch *does* is already pinned by the regression,
extraction, tagging, and links suites; what no suite can decide is whether the
rule is the right weight, sits at the right depth, and reads as a link rather
than as emphasis.

Review the pair under `build/link-decoration-review/` and record the result in
the pull request:

1. under `screen` the anchor text is unmistakably actionable; under `print` it
   is indistinguishable from body text;
2. the rule's weight against the section rule above it, its clearance under
   descenders, and its behaviour where an anchor wraps across a line break; and
3. the contact line, which #278 settled as **not** decorated under either
   medium, still reads as a set of links — that reading is what the decision
   rests on. The letter fixture is in the set because it carries the one case
   the résumé does not: an author's own `\href` whose anchor text is itself an
   address, which *is* decorated.

Neither target carries a baseline or belongs to `make check`; both produce
evidence for a human, under the gitignored `build/` directory, and must not be
committed.

### Line-breaking calibration sweep

When a change proposes a different value for a line-breaking parameter —
`\emergencystretch`, `\hyphenpenalty`, `\exhyphenpenalty` — measure it rather
than asserting it:

```bash
make review-linebreak SWEEP_ARGS="--param hyphenation --values '50 200 500'"
```

The command forces the parameter to each candidate, rebuilds both corpora, and
reports overfull boxes, hyphenated line ends, lines looser than badness 99, the
worst line badness, paragraphs that reached TeX's third line-breaking pass, and
page counts. `--corpus fixtures|examples` restricts the run, which is worth
doing because the full default sweep over the fixture corpus takes several
minutes.

A value is any TeX `<dimen>` or `<integer>` the parameter accepts — a plain
number for a penalty, or for `--param emergencystretch` a coefficient times a
length register, e.g. `--values '1.50\CDossierBodySize 0.040\textwidth'`. The
register form is what lets a derivation that varies per body size and margin be
swept at all: a fixed dimension cannot express it. Single-quote a value carrying
a backslash so the shell keeps it, and quote it again through `SWEEP_ARGS`.

Three rules for reading it, learned the hard way in #309 and #310:

1. **Never sum the two corpora, and decide policy on `examples`.** The stress
   fixtures exist to find what breaks, and their content is deliberately
   hostile. Measured over them the résumé family hyphenates more than any
   other, which is an artifact of the keep-together fixtures repeating filler
   bullets — and it argues the exact opposite of what the committed examples
   show.
2. **Read the cost columns, not only the benefit.** A hyphen count alone makes
   raising a penalty look free. `loose`, `worst`, and `pages` are the other side
   of the trade, and a value that removes hyphens while adding gappy lines or a
   page has not improved anything.
3. **`third` decides whether a paragraph enters the emergency pass, not whether
   it succeeds there.** #310 found this count identical across every candidate
   `\emergencystretch` derivation at a non-zero pool, which is why it cannot by
   itself discriminate between them — `overfull` still can.

The instrument carries no baseline and is not part of `make check`. It produces
evidence for a human; the decisions it informs are pinned by `.tlg` baselines
and layout fixtures. Its output under `build/linebreak-sweep/` is generated
evidence and must not be committed.

For a large sweep, `make review-linebreak-parallel` takes the same arguments and
runs one sweep per value concurrently, merging the results into the same place:

```bash
make review-linebreak-parallel SWEEP_ARGS="--jobs 4 --corpus fixtures \
  --param emergencystretch --values '1.50\CDossierBodySize 0.040\textwidth'"
```

It matters at scale rather than for a spot check. One value against the fixture
corpus is 36 discovered fixtures × 3 body sizes × 2 margins = 216 builds; the
nine-arm sweep behind the `\CDossierEmergencyStretch` table in
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) is 1,944, which is roughly 40
minutes serially and around 10 in parallel. Parallelism is across values, not
within one, so more workers than values buys nothing.

**Do not run either script under a restricted sandbox.** LuaLaTeX needs to write
luaotfload's font cache; where it cannot, fontspec falls back to `nullfont`,
every document typesets empty, and the sweep reports zero overfull boxes
everywhere — a failure indistinguishable from a clean result. If an arm comes
back implausibly clean, grep a `.log` in the scratch directory for
`not loadable: metric data not found` before believing it.

If a long run measures everything but fails while merging, do not repeat it:

```bash
make review-linebreak-parallel SWEEP_ARGS="--merge-only /path/from/the/failed/run"
```

The failed run prints that path as `Per-value console output kept at:`.

### Page fill

Measure how full each page is, and what forced each page break, across every
committed layout fixture that renders more than one page:

```bash
make review-pagefill
```

This is the other half of the page-break policy. `make layout` asserts that
material stays *together* — no list split leaving one item behind, no heading
separated from what it introduces, no page ending on a section heading — and
not one of those assertions can fail on a page that is half empty. In documents
whose entire constraint is a page limit, that is the more important half, and it
went unmeasured until this target existed.

The measurement is `\tracingpages` output parsed out of the log by
[`tests/layout/page-fill.awk`](tests/layout/page-fill.awk), not a reading of the
PDF, so it needs only LuaLaTeX and awk. That is deliberate: CI's texlive image
has no poppler.

Review the artifacts under `build/pagefill-review/`:

- `pagefill-report.txt` — per fixture and per page: `\pagegoal`, the height
  used, the fill percentage, the penalty at the break taken, and the size of the
  atom that forced it;
- `baseline.md` — the same figures as one table, regenerated on every run so the
  numbers are reproducible rather than transcribed;
- `pagefill.tsv` and each fixture's `.log` — the raw record and its source.

The column that decides how to read a row is `kind`:

| kind | what ended the page | fill means |
|---|---|---|
| `overflow` | the next atom did not fit | a policy question; `atom` says how large it was |
| `keep` | `\CDossierSectionNeedLines`, the bounded section keep (#333) | a policy question |
| `eject` | the fixture source: `\newpage`, `\vfill`, the `\end{document}` flush | nothing — the source decided it |

Both forced kinds print `p=-10000`; only the fil stretch on the taken candidate
tells them apart. Five committed fixtures eject, and their page-one fill runs
from 26% to 54% purely because their source says so — a threshold that counted
them would fail five fixtures for behaving exactly as written. A short *last*
page is normal for the same reason and is excluded too.

#### The floor `make layout` enforces

`make layout` carries the same measurement as an assertion, reported per fixture
as a `page fill:` line and enforced against a floor held in `run.sh`.

**The floor is a ratchet, not a fill policy.** *How full should a page be* is a
design question; it belongs to #333 and its successor #351, and neither has
answered it. The floor asks the narrower question the committed corpus already
answers: may a page get worse than anything the project has deliberately
accepted? One governed page sits at 86.9% and every other at 92.9% or above, so
the floor runs through the gap between the single accepted outlier and the rest.

It is a real guard rather than a formality. Measured at `8212a0f`, the commit
before #332, `resume-two-page` filled 80.6% of its goal and left a 140.04pt hole
— the defect that produced #332, #333, and this check — and the floor fails it.

A fixture whose accepted state sits below the floor declares its own:

```text
% PAGEFILLFLOOR: <pct>
```

`statement-two-page` is the only one that does. Its 86.9% is the prose-family
hole #342 swept over seven penalty values and closed with no change, and which
#351 now owns; the fixture carries the reasoning at the directive. Putting the
exemption in the fixture means whoever next changes that family's pagination
sees it, instead of it hiding inside a global number chosen low enough to
accommodate it.

**A declaration that is no longer needed fails the run.** When every governed
page of a declaring fixture clears the *global* floor, the runner reports
`EXPIRED PAGE-FILL FLOOR` and asks for the line's removal — so a stale exemption
cannot go on silently suppressing the floor for its fixture. Nothing has to
remember to delete it when #351 lands.

To explore a candidate value against the corpus, or to re-prove either failure
mode:

```bash
CDOSSIER_PAGE_FILL_MIN=94 make layout
```

At 94 four pages fail — `resume-a4-two-page` (93.0%), `resume-section-need`
(93.6%), `resume-a4-sans-body-two-page` (93.9%), `statement-a4-sans-body-two-page`
(92.9%) — while the declared exemption correctly holds `statement-two-page` at
its own 85. At 80 nothing fails the floor and the expiry check fires instead.
Setting the variable empty measures and reports without asserting.

#### Two more things the fixture list and the parser are held to

The fixture list is a glob, not a register, and it is wider than `*two-page*` on
purpose: `resume-section-need` renders two pages without saying so in its name,
so a list that trusted the name would have left a governed page out of the
baseline — and out of the count above.

The parser identifies a page by TeX's own shipout marker, and every run checks
the count it found against the log's `Output written on ... (N pages)`. To
re-prove that check, break the marker rule in `page-fill.awk` and run
`make layout`: it must report `PAGE-FILL PARSE MISMATCH` rather than passing.
A parser that finds no page reports no hole, which reads exactly like a corpus
that has none.

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

### Coverage expectations

Changes affecting a shared package should test every affected class. There are
four: résumé, cover letter (industry and academic families), academic CV, and
statement.

`AGENTS.md` ("Build and test") states the coverage matrix in full. In summary,
cover the relevant parts of:

1. each affected document family, and each affected statement `type`;
2. missing required `name`, per affected class;
3. missing optional `phone` and `website` without stray separators;
4. long URL or contact field, contact-line wrapping, and the copy-paste
   integrity of any link the change touches;
5. two-page output, page furniture, and single-page suppression;
6. text extraction and logical reading order;
7. the unsupported-engine error;
8. every option's accepted and rejected values, including the error naming the
   accepted values, and rejection reported exactly once;
9. tagged and untagged output, after tagging or shared-package changes;
10. bibliography sorting and field precedence, after Biber-facing changes.

Example extraction command:

```bash
make resume

pdftotext build/examples/resume-english.pdf \
  build/resume-english.txt
```

Inspect the output for logical reading order.

### Extraction round-trip test

Beyond eyeballing reading order, run the automated extraction fixture, which
compiles a torture document and checks its text layer three ways:

```bash
make extract-test          # or: tests/extraction/run.sh
```

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

`--update` composes with a fixture pattern, and narrowing it is the safer
default — it rewrites only the baselines the change was meant to move, so a
regeneration cannot quietly absorb a second, unrelated output change:

    tests/extraction/run.sh --update statement

Run it after any change to fonts, `fontspec` options, or the TeX distribution.
Rationale and the full method are in
[`docs/ATS-EXTRACTION.md`](docs/ATS-EXTRACTION.md).

### Link copy-paste integrity suite

A URL or an e-mail address must not pick up extraction whitespace within a
visual line, and one that legitimately wraps must reassemble exactly from its
ordered line fragments — the checkable form of "it survives copy-and-paste":

```bash
make links                 # or: tests/links/run.sh
```

Whether it does is a typesetting question, not a text one. Current Poppler
starts a new word when the spacing between two characters exceeds 0.1× the
font size, so a URL whose breakpoints were stretched to justify a line
extracts as `https : / / example . invalid /` while the rendered page looks
entirely normal. Ordinary extracted text cannot even diagnose it: a legitimate
line wrap and a split token both appear as whitespace. The suite therefore
reads `pdftotext -bbox` coordinates — pieces on *different* visual lines are a
wrap, pieces sharing *one* line are the defect. The threshold is an extractor
implementation detail, so the runner prints `pdftotext -v` at the start of
every run, and what the suite proves is scoped to that extractor's model.

Each fixture declares what must stay atomic in its own header, and the runner
extracts the directives:

    % LINKTOKEN: example.org/ada-lovelace/portfolio
    % LINKEXPECT: split          (optional; marks a negative control)

A declared token that is not in the PDF at all fails the run, so a fixture that
stops rendering its link cannot pass by silence.

One fixture covers each site that renders a link: the résumé contact line, the
CV contact line and its manual publication list, both letter families, and the
BibLaTeX bibliography. The bibliography is the only one of them that puts glue
at a URL's breakpoints — `\biburlsetup` sets `\Urlmuskip` from
`\biburlbigskip`, whose BibLaTeX default of `0mu plus 3mu` produced exactly this
defect in issue #199 — so `cv-bibliography-urlmuskip-raised.tex` widens that
glue deliberately and **must** be reported as split. If that negative control
ever stops firing, the check has gone blind; fix the check rather than the
expectation. Because it needs Biber, a run without Biber skips both bibliography
fixtures, says so in its summary, and exercises neither the glue site nor the
control.

Nothing in this suite is toolchain-dependent, and keeping it that way is the
point of how the control is built. It sets a rigid 4 mu at every breakpoint —
more than twice the 0.1 em threshold, decided by the fixture — rather than
raising the *stretch* and letting justification produce the gap. Issue #312 is
why. In the stretch form the realized gap landed within a point or two of the
threshold, so the same fixture from a clean tree split on CI
(`texlive/texlive`, Debian) and stayed intact locally (TeX Live 2026, macOS):
`make links` was red on a clean checkout of `main` while CI was green, and the
paragraph above told whoever hit it that the check was broken. Lengthening the
URL does not repair a stretch-based control — swept across all six
`fontsize` × `margin` combinations, the stretch form split at two of them. If
you ever find yourself tuning a fixture until a control fires, that is the
symptom: make the fixture decide the outcome instead.

Both bibliography fixtures build with `latexmk -g`. Without the `-g`, latexmk
treats an existing up-to-date PDF as done, so a run in a directory holding an
earlier build judges *that* PDF and the suite reports on the previous state of
the package rather than the current one.

### Default-path metadata suite

The PDF metadata a document gets when it does *not* opt into tagging has its own
small suite:

```bash
make metadata              # or: tests/metadata/run.sh
```

It builds each class on the default path and checks the catalog's `/Lang`, plus
a document that sets `pdflang` itself and one that loads
`careerdossier-components` after `hyperref`. It needs only LuaLaTeX.

Two things about it are deliberate and worth keeping. Its fixtures build
uncompressed, because on the default path the catalog otherwise sits inside a
compressed object stream, where a text search of the file finds nothing whether
or not the entry is there — a false negative indistinguishable from the bug, and
the reason #276 was reported against behaviour that was working. And every
assertion is paired with a positive control (`/Type /Catalog`, found by the same
method on the same file), so a build that produced nothing cannot pass by
silence.

It is separate from the tagged-PDF suite below by build path rather than by
subject: every tagging fixture passes `\DocumentMetadata`, which supplies
catalog entries itself and therefore cannot show what the package contributes on
its own.

### Link-annotation suite

Every other link-facing suite reads the *text* layer. `links` decides
copy-paste integrity from word bounding boxes; `extraction` and `tagging`
compare extracted strings. None of them can see what a link annotation actually
*does*, which is how issue #328 survived: every scheme-less profile link was
emitted as a `GoToR` remote-PDF action with `.pdf` appended, while the page, the
extracted text, and the copy-paste invariant were all correct. That is the gap
this suite closes:

```bash
make annotations           # or: tests/annotations/run.sh
```

Each fixture declares one `% URIEXPECT:` directive per link it renders, and the
runner requires the declared multiset and the emitted one to match exactly —
not "contains", since an extra annotation is as much a defect as a missing one.
It additionally fails any fixture whose PDF carries a `GoToR` action at all, so
a regression names the actual symptom rather than showing an opaque multiset
difference. It needs only LuaLaTeX.

Two things it borrows from the metadata suite are worth keeping. Its fixtures
build uncompressed, because link annotations otherwise sit inside a compressed
object stream where a text search of the file finds nothing whether or not the
annotation is there. And every assertion is paired with a positive control
(`/Subtype /Link`, found by the same method on the same file), so a fixture that
stopped emitting links cannot pass by silence.

When you add a fixture, keep its addresses short enough that no link wraps: a
wrapped link is emitted as two annotations sharing one action, which the
comparison would report as an unexplained duplicate.

### Tagged-PDF suite

Opt-in tagged output has its own suite covering five profiles — industry
résumé, industry letter, academic CV, academic letter, and research statement:

```bash
make tagging               # or: tests/tagging/run.sh
```

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

One check in the suite is deliberately *not* an extraction check.
`tests/tagging/structure-text.pl` decodes each marked-content run straight out
of the content stream — `BDC`/`EMC`, then the enclosed `Tj`/`TJ` glyph codes
through each font's `/ToUnicode` CMap — and consults no glyph coordinate at
all. What it prints is the logical text of a structure element, which is what a
consumer that walks the structure tree receives, not what an extractor
reconstructs from the page. Poppler, MuPDF, and PDFKit all rebuild words from
geometry, so all three were blind to two cells joined by nothing but
positioning glue; that is how issue #302 shipped. Each fixture has a committed
`<name>.structure.txt` baseline, and `run.sh` additionally asserts the
separator in each two-cell row by name, so the specific defect cannot be waved
through by regenerating a baseline. The script needs the fixtures'
`compresslevel=0`/`objcompresslevel=0`, and says so rather than silently
decoding nothing.

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
[`docs/ATS-EXTRACTION.md`](docs/ATS-EXTRACTION.md). Screen-reader
review is manual by nature and is not automated by this suite.

**veraPDF in CI.** The per-PR `tagging` job does not install veraPDF, so its
veraPDF gate is always skipped there — building it from source costs several
minutes that a per-push job should not pay. A separate weekly
`verapdf-scheduled` workflow builds veraPDF from a pinned commit and runs the
same gate; see "Pinned dependencies" below and
[`docs/ATS-EXTRACTION.md`](docs/ATS-EXTRACTION.md) section 7.1.

### Option lint

Every choice-valued public option must name its accepted values when it is given
one that is not accepted. That needs two hand-written pieces in the same file —
a `\msg_new:nnnn { <module> } { unknown-<key> }` and a `<key> / unknown .code:n`
sub-key routing l3keys' choice error to it — and LaTeX enforces neither. Omit
the sub-key and the option falls back to l3keys' stock "accepts only a fixed set
of choices" error, which never says what the set is, with no test failure: every
other test asserts a message that *is* defined, not the absence of one that is
not.

The lint derives the expected set from the source instead. For each
`<key> .choices:nn` in a root `.cls`/`.sty` it requires both halves, in the same
`\keys_define:nn` block and the same file, each naming the module the filename
implies:

```bash
make lint                  # or: tests/lint/run.sh
```

It compiles nothing, needs no TeX installation, and finishes in under a second,
so run it first. A failure names the module, the key, and which half is missing.
Adding a choice-valued option therefore means adding its message and its
`unknown` sub-key, not remembering to.

Every public choice-valued option is inside the lint. That is also why
`.choices:nn` is the only supported way to declare one: a choice list
hand-rolled from `\str_case:nnF` — as `careerdossier-statement`'s `type` was
until `v0.7.0` — is invisible to the lint, and dropping its `F` branch makes it
accept a bad value in silence, which is worse than the stock error the lint
exists to replace. Convert such an option rather than declaring a new one.

The fixtures under `tests/lint/fixtures/` are the lint's own tests — one
complete option and four each missing or misdirecting one half — and the runner
checks itself against them every run, so a lint that stopped detecting anything
fails rather than passing everything. They are lint input, never compiled, and
not part of the Work.

The `lint` target runs a second script in the same slot:

```bash
tests/lint/run-fixture-filter.sh
```

It holds the fixture-selection contract from "Scoping a suite while you iterate"
to account. Selection is the one part of a test runner whose own failure mode is
a *pass* — a suite that selects nothing asserts nothing and reports every
assertion clean — so it gets a check rather than a convention. For each scopable
runner it asserts that `--list` names exactly the `*.tex` files in that
directory, that a matching pattern selects a proper non-empty subset of them,
that a non-matching pattern exits nonzero, that the empty pattern (what `make`
passes when `FIXTURE` is unset) selects everything, and that an unrecognised
option is rejected instead of taken for a pattern. It also greps the `Makefile`
for the four pass-through recipes, because a recipe that dropped its variable
would leave every other check passing while the selector silently did nothing.

It belongs here, with the option lint, because it compiles nothing: every
invocation is in `--list` mode, so it needs no TeX and adds no measurable time
to the sub-second `lint` job. It checks the runner sources for a `--list` branch
*before* invoking them — without one, `--list` is read as a fixture pattern and
the checks would compile all three suites on a runner that may have no TeX at
all.

The universe check is not a formality for the smoke suite in particular, whose
fixture list is a hand-written `cases` array rather than a glob: a `cases` entry
with no fixture, or a fixture no entry names, is caught here rather than at the
next full run.

### Module regression suite (l3build)

The logic-bearing packages are covered by an `l3build` regression suite. Each
`.lvt` source under `tests/regression/` is compiled on LuaTeX and its filtered
log is diffed against a committed `.tlg` baseline. Run the whole suite from the
repository root:

```bash
make regression            # or: l3build check
```

Run a single test by name (without the `.lvt` extension):

```bash
make regression TEST=base-diagnostics    # or: l3build check base-diagnostics
```

A failing check writes the difference to `build/test/<name>.luatex.diff`; read it
to see the intended baseline versus the actual log. When an output change is
intended and understood, re-save the baseline, then review the diff before
committing it (see "Baselines are load-bearing" above):

```bash
l3build save base-diagnostics
```

The harness is configured in `build.lua` (`tests/regression/`, LuaTeX, LaTeX
format). Writing a test: `\input{regression-test}`, load the package under test,
and inside `\TEST{name}{...}` use `\TYPE{...}` to record the behavior in the log.
Catcodes cannot be switched inside an already-tokenized `\TEST` body, so any
expl3 or `@`-bearing name must be reached through a helper defined earlier under
`\ExplSyntaxOn`, or via `\use:c`.

### Spacing tokens: reporting a value is not rendering a gap

A spacing token reaches the page only where it wins a maximum. `\addvspace`
collapses two adjacent claims to the larger one, so a token that is smaller than
its neighbour everywhere a fixture happens to look contributes nothing there —
and a fixture that prints the token with `\TYPE` still records a difference when
the ratio changes. Its baseline moves, and the test looks like it is working.

That is not hypothetical. `resume-entry-edges` exists to assert entry and list
boundary composition and printed `\CDossierRecordEntryAboveSkip`, but every
entry in it had a body, and that token only wins a maximum between two *bodiless*
entries. When issue #206 moved the ratio, only the echoed number changed. The
unreachable-token condition issue #204 exists to prevent was reproduced inside
the test written to catch it.

So each public spacing token must be rendered by at least one committed fixture,
and the table below records which. Extend the fixture named there when you retune
a ratio, and add a row when you add a token.

| Token | Rendered by | At the boundary |
| --- | --- | --- |
| `\CDossierSharedHeaderNameGapSkip` | `components-headerstack` | header line 1 → line 2 |
| `\CDossierSharedHeaderMetaGapSkip` | `components-headerstack` | header line 2 → line 3 |
| `\CDossierRecordHeaderBelowSkip` | `resume-header-edges` | header stack → first ruled section |
| `\CDossierRecordSectionAboveSkip` | `resume-entry-edges` | entry → next section heading |
| `\CDossierRecordSectionRuleGapSkip` | `resume-entry-edges` | heading baseline → section rule |
| `\CDossierRecordSectionBelowSkip` | `resume-entry-edges` | section rule → first entry |
| `\CDossierRecordEntryAboveSkip` | `resume-entry-edges` | bodiless entry → bodiless entry |
| `\CDossierRecordEntryGapSkip` | `resume-entry-edges` | entry heading → prose body |
| `\CDossierRecordListEdgeAboveSkip` | `resume-entry-edges` | entry heading → bullet list |
| `\CDossierRecordListEdgeBelowSkip` | `resume-entry-edges` | bullet list → next block |
| `\CDossierRecordItemSepSkip` | `resume-entry-edges` | bullet → bullet |
| `\CDossierRecordParSkip` | `resume-entry-edges` | every paragraph boundary |
| `\CDossierProseHeaderBelowSkip` | `statement-prose-edges` | header stack → first section |
| `\CDossierProseSectionAboveSkip` | `statement-prose-edges` | paragraph → section heading |
| `\CDossierProseSectionBelowSkip` | `statement-prose-edges` | section heading → paragraph |
| `\CDossierProseSubsectionAboveSkip` | `statement-prose-edges` | paragraph → subsection heading |
| `\CDossierProseSubsectionBelowSkip` | `statement-prose-edges` | subsection heading → paragraph |
| `\CDossierProseParSkip` | `statement-prose-edges` | paragraph → paragraph |
| `\CDossierLetterHeaderBelowSkip` | `letter-block-edges`, `components-headerstack` | header stack → date line |
| `\CDossierLetterParSkip` | `letter-block-edges` | paragraph → paragraph |
| `\CDossierLetterRecipientLineGapSkip` | `letter-block-edges` | recipient line → recipient line |
| `\CDossierLetterBlockSkip` | `letter-block-edges` | letterhead block → letterhead block |
| `\CDossierLetterBodyAboveSkip` | `letter-block-edges` | salutation → body |
| `\CDossierLetterBodyBelowSkip` | `letter-block-edges` | body → closing |
| `\CDossierLetterSignatureGapSkip` | `letter-block-edges` | closing → signature name |

Two kinds of fixture are *not* in that column, and neither is a substitute.

`tokens-scale`, the four `tokens-*-defaults`, and `tokens-invariants` echo values
and compare them to one another. Pinning resolved values and their ordering is a
legitimate contract on its own — it is what catches a ratio changed by accident —
but it answers a different question, so a token covered only there is untested.
The same holds for a traced `\addvspace`: `components-headerstack` and
`statement-headerstack` intercept it to record *which* token the header stack
selected and how many times, which is a claim, not a rendered gap. Both fixtures
keep those traces; `components-headerstack` adds composed heights alongside them.

`tests/layout/` renders rather than reports, but it asserts page counts, overfull
boxes, furniture, media box, and widow/orphan behaviour — not gaps. A spacing
change of a grid step or two moves nothing it looks at. It is corroboration when
a retune flips a page count, not a per-token instrument.

Verify a new shape by perturbing the ratio and rebuilding — do not assume it from
the token's definition. Perturb *downward* where the token allows it: raising a
token that currently loses its maximum can make it win, which reports coverage
the committed values do not have. For a token whose default is `0.00` only the
upward direction exists, and the reading is then "any non-zero value renders",
not "this gap is on the page today".

### BibLaTeX/Biber fixture

The optional integration has a focused multi-pass fixture that runs Biber,
rejects Biber warnings/errors, and diffs extracted output to pin `ydnt` ordering
and DOI → e-print → URL precedence:

```bash
make bibliography-test     # or: tests/bibliography/run.sh
```

The ordinary academic CV smoke/example path remains separate and must continue
to compile without loading BibLaTeX or invoking Biber.

CI runs this fixture in its own `bibliography` job, on the pinned TeX Live
container, so a local failure can always be checked against a second toolchain.

#### The shipped example renders its entries

The same target additionally builds `examples/academic/cv-bibliography.tex` from
the repository root and asserts it rendered as many entries as
`examples/academic/publications.bib` declares. Building it any other way is the
point: the example writes root-relative include and bibliography paths, and from
another working directory Biber cannot resolve them — at which point `\nocite{*}`
against no database is not a LaTeX error, `latexmk -halt-on-error` exits `0`, and
a PDF ships with the entries silently absent. Measured with the database removed,
`make academic-bibliography` produces 12297 bytes where a complete build produces
24514, and reports nothing wrong.

That is not a hypothetical: it is how the figures recorded for #309 came to be
one hyphenated line end low in every arm, until #316's instrument disagreed with
them.

The check derives everything from the sources, so adding an entry to the database
never requires editing it. It asserts four things in order — Biber's log is free
of warnings and errors, the `.bbl` emits as many `\entry{` as the `.bib`
declares, the `.log` reports no undefined citation, and the rendered labels are
exactly `1 … N`. The first three prove Biber succeeded; only the fourth proves
LaTeX put the entries on the page.

It pins no content, deliberately. The extraction baseline above is measured
against a fixture this suite owns, precisely so that editing the example's prose,
profile, or database cannot turn the suite red; a count-equality assertion keeps
that property because it holds no string, order, field, key, or year.

`missing-bibresource.tex` is the committed negative control, and the guard is
only worth having because that control fires. It names a database that does not
exist, `latexmk` exits `0`, and the guard must reject it — if it ever passes,
the guard has stopped seeing the defect it exists for, and the failure it guards
is silent, so nothing else would reveal that. The control is handed the *real*
database rather than the missing one, so it decides on the build's evidence
instead of short-circuiting on the guard's own input check.

#### Known local failure: Biber rejects every `date` field

If the fixture fails with a Biber log full of

```text
WARN - article entry 'newest' (publications.bib): Invalid format '2026' of
date field 'date' - ignoring
```

then Biber dropped the dates, every year disappeared from the rendered
bibliography, and the `ydnt` sort order came out wrong (issue #211). The tell is
that *every* entry is rejected at every granularity — `2024`, `2024-01`, and
`2024-01-01` alike — while the legacy `year` field still works.

This is a fault in the local Biber install, not in the fixture data. Biber ships
as a PAR-packed binary that unpacks its Perl runtime into a per-user cache under
`TMPDIR`; on macOS that lives in `/var/folders/...`, which the system purges
periodically. Only the `date` path needs the bundled DateTime modules, so an
incomplete cache breaks `date` while leaving `year` intact. Clear the cache and
let Biber unpack itself again:

```bash
rm -rf "${TMPDIR:-/tmp}"/par-*
biber --version
```

Two fixes that look tempting are both wrong. Switching the fixture to `year=`
turns the suite green while hiding a genuinely wrong bibliography, and makes the
fixture test less than it does now — `date` is BibLaTeX's modern field.
Relaxing the Biber-warning gate in `tests/bibliography/run.sh` removes the only
thing that caught the corruption. The runner prints this diagnosis itself when
it sees the signature, and still fails.

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
- type scale, vertical rhythm, list metrics, and page geometry →
  `careerdossier-tokens.sty`;
- fonts and semantic text roles → `careerdossier-typography.sty`;
- colors and visual tokens → `careerdossier-theme.sty`;
- reusable rendered pieces, page furniture, and PDF metadata →
  `careerdossier-components.sty`;
- the BibLaTeX/Biber boundary → `careerdossier-biblatex.sty`;
- résumé structure and options → `careerdossier-resume.cls`;
- cover-letter structure and prose behavior → `careerdossier-letter.cls`;
- academic CV flow and the manual publication list → `careerdossier-cv.cls`;
- the statement model and its type-specific validation →
  `careerdossier-statement.cls`.

`AGENTS.md` ("Module ownership") carries the same map with the dependency
direction; `docs/ARCHITECTURE.md` has the per-file detail.

Page geometry belongs to `careerdossier-tokens.sty`, not to a class: a class
chooses paper and options and does not set margins itself. Do not duplicate
contact-line logic inside the classes, and do not load
`careerdossier-biblatex.sty` from `careerdossier-cv.cls` — the CV must build
without a bibliography toolchain.

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

### Update `ATS-EXTRACTION.md` when:

- extracted text content, order, or spacing changes;
- tagged-structure behavior or a validator result changes;
- a fixture, baseline, or extractor in the extraction or tagging suites changes;
- the reproducibility or screen-reader procedure changes.

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

Before `v1.0.0`, breaking changes are allowed but must be documented in `CHANGELOG.md` and `MIGRATION.md`.

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
- pin every container and third-party action to an immutable reference.

### What actually gates a merge

Branch protection on `main` is the `Protect Main` **ruleset**, not classic
branch protection, so read it with `gh api repos/<owner>/<repo>/rulesets` rather
than from the older branch-protection endpoint or from this paragraph. As last
derived, it requires a pull request, allows all three merge methods, requires
**zero** approving reviews, forbids deletion and non-fast-forward pushes, and
requires every one of the workflow's sixteen job contexts to pass against an
up-to-date branch. Green CI is therefore the merge gate; a branch that is not
close-out complete when it goes green is one that can be merged incomplete.

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

See `.agents/skills/release-notes/reference.md` for CHANGELOG and release-note
format, house style, and the LaTeX-package compatibility checklist.

Tagging and publishing a release should occur only after the release-preparation pull request is merged.
