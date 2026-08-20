# Testing CareerDossierTeX

For people writing or running the tests: the suites, the review targets, the
fixtures they select, and the rules that govern them.
[`../CONTRIBUTING.md`](../CONTRIBUTING.md) owns the surrounding workflow — how
to propose, build, commit, and submit a change — and its "Testing" section
states the one-sentence obligation that this file details. It is not restated
here.

This file is reference material for someone already writing a test. Read the
section that covers the concern you are changing; there is no expectation that
anyone reads it end to end.

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

### Reproduce a mechanism below the level of a suite

The tests above are what a change must *ship*. They are usually the wrong
instrument for finding out how something behaves in the first place, and
reaching for a suite to answer that question is the most expensive habit
available here.

Reproduce a mechanism at the smallest scale that exhibits it, and use a suite
only to confirm. Issue #392 is the worked example in both directions. The
question was whether concurrent `biber` invocations corrupt each other's
unpacked binary; the answer took four `biber --version` calls and five seconds,
and it refuted the fix the issue prescribed. The same session also spent eight
200-second full-suite runs, of which two carried information the probe had not
already given.

Three practical consequences:

- **A probe is not a test and is not committed.** It answers a question, gets
  quoted in the issue or PR where the number matters, and is thrown away. What
  ships is the committed test that would fail without the change.
- **Sequence the expensive runs last.** Finish the design, then run the full
  campaign. Re-running a suite because the script changed underneath it is the
  common way a day disappears.
- **Prefer the scoping the runners already give you** — `FIXTURE=` and `TEST=`,
  see `CONTRIBUTING.md` "Scoping a suite while you iterate" — over a full run,
  right up until the run that has to be full.

`CONTRIBUTING.md` "Issue workflow" carries the matching obligation on the other
side: an issue that prescribes a mechanism records what would refute it.

Every review target below writes its PDFs, PNGs, logs, and review record under
the gitignored `build/` directory. That output is generated evidence for a human
reader: record the result in the pull request, and never commit the artifacts
themselves. The individual targets do not repeat this.

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

A class default is not always what the source fixture declares: the CV fixture
names `fontsize=11pt` while its class defaults to `12pt`, so the eight `cv-*.pdf`
are one type size larger than the fixture they are built from and the eight
`resume-*.pdf` are not. `review-record.txt` therefore names the resolved
`fontsize`, `margin`, `paper`, and `bodyfont` for each record class — read back
from the build rather than transcribed — and says explicitly where one differs
from what the fixture declares. Check that block before comparing a matrix PDF
against a fixture or a `review-matrix` render.

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
and layout fixtures. Its output lands under `build/linebreak-sweep/`.

For a large sweep, `make review-linebreak-parallel` takes the same arguments and
runs one sweep per value concurrently, merging the results into the same place:

```bash
make review-linebreak-parallel SWEEP_ARGS="--jobs 4 --corpus fixtures \
  --param emergencystretch --values '1.50\CDossierBodySize 0.040\textwidth'"
```

It matters at scale rather than for a spot check. One value against the fixture
corpus is 36 discovered fixtures × 3 body sizes × 2 margins = 216 builds; the
nine-arm sweep behind the `\CDossierEmergencyStretch` table in
[`ARCHITECTURE.md`](ARCHITECTURE.md) is 1,944, which is roughly 40
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
[`tests/layout/page-fill.awk`](../tests/layout/page-fill.awk), not a reading of the
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
design question; #333 closed without setting a value, and #351 — which owned the
one route that would have lifted the outlier — built it, measured it, and
declined it. The floor asks the narrower question the committed corpus already
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
#351 then declined to close by other means; the fixture carries the reasoning at
the directive, and the figure is accepted rather than pending. Putting the
exemption in the fixture means whoever next changes that family's pagination
sees it, instead of it hiding inside a global number chosen low enough to
accommodate it.

**A declaration that is no longer needed fails the run.** When every governed
page of a declaring fixture clears the *global* floor, the runner reports
`EXPIRED PAGE-FILL FLOOR` and asks for the line's removal — so a stale exemption
cannot go on silently suppressing the floor for its fixture. #351 has since
landed and declined the change, so the one declaration stands; the check remains
for whatever later change does close that hole.

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

Never regenerate a baseline merely to make a red suite green. A `.tlg` may echo
the same value several times; regenerate every affected line, not the first one.

### The harness precedes the tests that need it

`l3build` regression tests cannot run until the harness exists. The harness
(`build.lua` configured for `tests/regression/`) is therefore a prerequisite for
the per-module `.lvt` workflow above, not a parallel nicety: stand it up before —
or in the same change as — the first module whose coverage depends on it, rather
than accumulating `.lvt` sources that no runner can execute. Until the harness
lands, record the specific regression tests owed as explicit, tracked debt.

### The five test layers

Every automated check here belongs to one of five layers, and the layer decides
what a failure means:

1. **Class/package regression tests** — API behaviour, options, errors, grouping,
   and load order **(l3build; Phase 1 onward)**.
2. **PDF extraction tests** — characters, spaces, reading order, and semantic
   adjacency **(Phase 1)**.
3. **PDF structural tests** — syntax, embedded fonts, metadata, tags, and
   accessibility claims.
4. **Rendered-page tests** — overlap, clipping, density, page breaks, contrast.
5. **Real-portal tests** — parsed preview or autofill where possible.

Add each layer's focused fixture with the implementation it validates. When
practical, run the new fixture before implementation and confirm that it fails
for the intended reason. All automated sources, expected outputs, runners, and
baselines belong under `tests/`; milestone release work reruns them but does not
defer their creation.

### Coverage expectations

Changes affecting a shared package should test every affected class. There are
four: résumé, cover letter (industry and academic families), academic CV, and
statement.

This is the one statement of the coverage matrix — which document families,
required and optional fields, engine and option errors, extraction, tagging,
links, and bibliography cases a change has to cover. Nothing summarizes it
elsewhere, because a summary is what drifts. Cover the relevant parts:

- each affected document family: résumé, industry letter, academic letter,
  academic CV, and each affected statement `type`;
- missing required `name` with a clear error, per affected class;
- missing optional `phone` and `website` without stray separators;
- long URL or contact field, and contact-line wrapping;
- two-page output, page furniture, and single-page suppression;
- text extraction and logical reading order, across the supported extractors;
- copy-paste integrity of any URL or e-mail address a change touches: no pieces
  sharing one visual line, and a wrapped address reassembles exactly
  (`make links`);
- link-annotation action types after any change that emits a link: every
  annotation carries a `/S/URI` action and never a `/S/GoToR` remote-PDF one
  (`make annotations`). The page, the extracted text, and the `links` invariant
  all stay correct when this one is wrong, so no other suite covers it;
- derived PDF document metadata after any change to it, on **both** build paths
  (`make metadata`): the two paths hand the string to different writers, so a
  value that is right on the default path can be wrong under
  `\DocumentMetadata` while nothing is logged and every other suite passes.
  This covers the precedence rule as well as the derived value — a document's
  own `\hypersetup` reaches the two paths by different routes, so "the user's
  field is never overwritten" is a claim that has to be made on each of them;
- unsupported-engine error;
- every option's accepted and rejected values, including the error naming the
  accepted values, and rejection reported exactly once;
- any user-facing template a change publishes or edits: a documented template is
  a promise that the code in it runs, and the only thing that keeps the promise
  is a fixture compiling that exact text. A template added to the manual's
  "Complete examples" chapter needs a `manual-example-*.tex` fixture in the same
  change, or `make smoke` fails (see "Documented templates are compiled" below);
- the release archive after any change to the Work's file set or to `build.lua`'s
  packaging configuration (`make ctan-lint`). A file
  added to the Work that no `sourcefiles` glob matches, or a file list naming
  something that no longer exists, costs the archive a file and costs
  `l3build ctan` no error — see "CTAN packaging lint" below;
- all affected classes after changes to a shared package;
- tagged and untagged output after changes to tagging or shared packages; and
- bibliography sorting and field precedence after `careerdossier-biblatex.sty`
  or Biber-facing changes.

Example extraction command:

```bash
make resume

pdftotext build/examples/resume-english.pdf \
  build/resume-english.txt
```

Inspect the output for logical reading order.

### Documented templates are compiled

**Every complete document this repository publishes for a reader to copy is
compiled by a smoke fixture holding that text verbatim.** There are nine, in
three groups:

| Published in | Fixture | Drift check |
|---|---|---|
| `doc/careerdossier.tex`, "The header stack" | `tests/smoke/components-header-stack-doc.tex` | smoke unit `components-header-stack-doc-drift` (#252) |
| `docs/ATS-EXTRACTION.md`, "User template" | `tests/smoke/ats-user-template-doc.tex` | smoke unit `ats-user-template-doc-drift` (#450) |
| `doc/careerdossier.tex`, "Complete examples" — all seven | `tests/smoke/manual-example-*.tex` | `make lint`, `tests/lint/run-manual-examples.sh` (#458) |

Compiling the fixture is only half of it. A fixture that keeps building while
its published twin is edited proves nothing about the twin, so each drift unit
extracts the published block and diffs it against the fixture **before** either
is compiled, and reports `DRIFTED` with the diff when they disagree. Each block
is located by its content — the one that declares a document and opens a header
stack, the one that declares a document and calls `\MakeCDossierHeader` — so the
prose around an example may be reworded freely; failing to find exactly one such
block is a failure and not a skip, because a document this cannot find an
example in is indistinguishable from one that no longer publishes an example.

Each unit is gated on its own fixture being selected (#359), so `FIXTURE=`
scoping cannot leave a claim being made about something the run did not compile.

The failure this guards is #185's: an uncompiled template in a document nobody
re-reads goes stale silently, and a reader cannot tell which of several
published templates is current. No template was broken when its guard was added;
what a guard buys here is the next rename.

**The third row is a set assertion, not a seventh selector, and it lives in
`lint` rather than in the smoke runner. Both differences are the point.**

The first two units each name their example by content, which is right when a
document publishes one. Seven hand-kept selectors would not have caught what
#450 found: the chapter was uncovered precisely *because* the #252 control names
one example, so the other six were matched by nothing and nothing said so — an
example no selector names reads exactly like an example that does not exist.
`tests/lint/run-manual-examples.sh` therefore asserts that the chapter's
complete documents and the `manual-example-*.tex` fixtures are in **bijection**:
every published example has a fixture, every fixture has a published example,
and matching is by exact text, so renaming a fixture or reordering the chapter
breaks nothing. Adding an eighth example without a fixture fails with
`SET MISMATCH`.

It is a lint rather than a smoke unit for two reasons. It is a claim about text
and needs no TeX, so it belongs in the sub-second `lint` slot and on the
TeX-free CI lint runner, where it reports drift before any compile is paid for.
And it is owned by no single fixture, which `tests/lint/run-fixture-filter.sh`
correctly refuses to let a dispatched smoke unit be: an extra unit must be named
for a listed fixture, and this one would have to be named for seven. The seven
per-fixture compiles stay in `make smoke`, where a compile belongs. Five
committed self-test fixtures pin the lint's own verdicts, so a lint that had
stopped detecting anything fails there rather than passing everything.

A block counts as a complete document when it declares a class *and* opens a
document environment. Fragments illustrating one command are neither, cannot be
compiled as they stand, and are out of scope; `examples/` carries the long-form
equivalents, which `make examples` builds.

Three failure modes, each demonstrated against the real manual when the check was
added (#458): editing one published example reports `DRIFTED` naming the
fixtures that no longer match; injecting an eighth example reports
`SET MISMATCH` with both counts; and renaming the chapter heading reports
`NO COMPLETE DOCUMENT FOUND` rather than passing over an empty set, which is the
#398 shape the sibling units also refuse.

Four of the seven manual examples are statements whose classes and types already
have `statement-*-valid` fixtures, so their *compiles* are close to redundant.
Their value is the drift half: no other fixture asserts that the exact text the
manual publishes is the text that builds. The cost is seven compiles, measured
at roughly 8 s of `make smoke`'s wall clock at `JOBS=4`.

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
[`ATS-EXTRACTION.md`](ATS-EXTRACTION.md).

### Ground-truth extraction fixture **(Phase 1)**

Include a document containing text like:

```text
Zoë Dvořák Łukasz İpek José
office efficient affine waffle difficult
(C++) (c++) C# F# R&D 100% AT&T
email@example.org +1 416 555 0199
https://example.org/a_b?q=one&lang=en
Senior Research & Development Engineer
January 2023 - Present
```

Add representative bullets, headings, links, page breaks, bold, and italic. The
expected file should contain the intended plain text in the intended order.

### Command-line extraction

```sh
pdftotext -enc UTF-8 document.pdf document.txt
pdftotext -layout -enc UTF-8 document.pdf document-layout.txt
pdffonts document.pdf
qpdf --check document.pdf
```

Interpretation: default `pdftotext` is the more important reading-order signal;
`-layout` is a useful second view, not the canonical expected output; `pdffonts`
can reveal missing embedding but cannot prove correct mapping; `qpdf --check` tests
PDF syntax, not ATS semantics. Normalize line endings and Unicode deliberately
before diffing, but be cautious about normalizing all whitespace — removing too
much can hide missing word separators.

### Multiple-consumer test

Copy and paste the same high-risk text in at least: Poppler (`pdftotext`); a
PDFium-based viewer such as Chrome; PDF.js in Firefox; and one additional common
target such as Adobe Acrobat Reader or macOS Preview. The Inter example shows why
one extractor is not enough. If consumers disagree, record the discrepancy and
choose the more conservative font or feature setup.

### Reading-order assertions

Assert order and adjacency, not just a bag of words: applicant name precedes
contact information; the `Experience` heading precedes the first job; each title
remains near its organization and date; bullets remain under their entry;
`Education` does not interleave with `Skills`; and page furniture does not
interrupt sentences.

**Entry-head column order is covered** (issue #221). Three fixtures in
`tests/extraction/` assert that an entry heading's right-hand dates/location
column extracts between its heading and its bullets, on the untagged path this
suite builds:

| Fixture | Class | Pages | What it adds |
|---|---|---|---|
| `resume-entry-dates-order` | résumé | 1 | the cheapest form of the assertion |
| `cv-entry-dates-order` | CV | 1 | the same component under CV geometry |
| `resume-entry-dates-page-furniture` | résumé | 2 | running header and folio present |

Two findings from building them are worth keeping, because they decide what a
fixture of this kind has to look like:

- **Two entries, not one.** The last entry sorted on a page always trails its
  own column, at every list-edge value. A one-entry fixture therefore cannot see
  the fault appear or disappear — which is why the three pre-existing fixtures
  with dates (`resume-contact-optional`, `resume-contact-wrap`,
  `cv-contact-optional`) stayed green throughout the #219 regression. The
  assertion lives on an entry that is followed by more material.
- **Page furniture is sufficient, not necessary.** A single page with two
  entries reproduces the reordering exactly as the two-page form does; the folio
  only makes it more conspicuous by putting the dates below the page furniture.

Poppler is the discriminating consumer here. The committed `*.pdfkit.txt`
baselines keep each heading row on one line at every value tested, so they
record the layout but do not detect the fault.

Copy-paste integrity of a link is the same kind of assertion made on
coordinates rather than text; "Link copy-paste integrity suite" below is the
statement of it, and issue #294 the coverage.

### Real portal acceptance

When a portal previews parsed fields, inspect and correct name, email, phone, job
titles, employers, date ranges, education, current location, and links. Follow the
portal's requested format. Greenhouse documentation has stated a parser input size
limit in one recruiting workflow, so keep PDFs compact and image-light; do not
treat that vendor-specific limit as universal, and re-check the current figure.

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

It also holds the one assertion in the tree that spans both build paths: that
the derived `/Title` is the same string whether or not the document opts into
tagging. That comparison is here because `/Title` is Info-dictionary metadata,
which is this suite's subject, and because it cannot be made from one path
alone — issue #428, where the tagged path shipped `Cover Letter -- <name>`
against the default path's `Cover Letter – <name>` from identical source, for
as long as both paths had existed. The two writers serialise the same string
differently, hyperref's `\pdfstringdef` as an escaped literal and the kernel's
PDF management as hex, so the runner normalises both to UTF-16BE code units
before comparing; comparing the bytes would report every such pair as different.
The expected value is constructed in the runner rather than copied out of a
build, so a fixture cannot pass by agreeing with whatever the package currently
emits.

The pair beside it asks the prior question: whether a document's *own*
`pdftitle` and `pdfauthor` reach the PDF at all. They did not, under
`\DocumentMetadata` — issue #440, where `hyperref`'s driver records the value in
the kernel's PDF management and leaves the `\@pdftitle` the package reads
defined and empty, so a user's title looked like an absent one and the derived
value overwrote it. Both halves of that pair are load-bearing: the tagged one is
the defect, and the default one is the evidence that fixing it did not trade one
path for the other. Their strings are plain ASCII on purpose, so that the
separate question of how a `--` is spelled on each path (issue #439) cannot
change what they measure.

A third pair asks that separate question: whether a `--` the *user* typed, in a
value the package composes into the derived string, is spelled the same on both
paths (issue #439). It is not a variant of the #428 pair. That one uses a plain
name, so it is silent about anything a user typed, and its fix — naming the
separator by code point instead of writing `--` — does nothing for a `--`
arriving from the profile. Keep this pair's name double-barrelled, or it
collapses into a second copy of #428's and stops covering anything. It checks
`/Title` and `/Author` separately, because they are different routes out of
`name` and only one of them goes through the title builder.

The four-sequence conversion table behind it (`--`, `---`, `` !` ``, `` ?` ``,
and the ` `` `/`''` that are deliberately *not* on it) is pinned in
`tests/regression/components-pdfmeta.lvt` rather than here: a case costs a line
there and a built PDF pair here, and the property this suite exists to assert is
that the two paths agree, not what the table contains.

A fourth pair is the exception to every sentence above: it requires the two
paths to *disagree*. A `--` in a value the document sets itself is not the
package's to spell, and since #440 it is passed through untouched, so it
reaches an en dash on the default path and two hyphens under
`\DocumentMetadata`. Issue #442 weighed accepting that, reporting it upstream,
and working around it here, and settled on accepting it; this pair is what
stops "accepted" from decaying into "unnoticed".

It checks three fields, one of each kind that exists. `pdftitle` and
`pdfauthor` are the two the package would have to rewrite for a workaround to
reach them. `pdfsubject` is the third and the load-bearing one: nothing in
`careerdossier-components` reads or writes it, yet it diverges identically, so
it is the measurement behind the manual's claim that the cause is upstream
rather than anything the classes do. (`pdfkeywords` behaves as `pdfsubject`
does and is left out — a fourth field would cost the same build and prove the
same point.)

It is written to retire itself. If `hyperref` or the kernel ever converges the
two paths, this pair fails, and that failure is a notification rather than a
regression: the manual would then be documenting behaviour that no longer
happens. The repair at that point is to delete the pair and correct the
document — never to make the package converge the values itself, which is the
option #442 declined.

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
its own. The `/Title` pair above is the deliberate exception and stays one — a
fixture belongs here because the default path is the only place its subject is
visible, and `letter-title-tagged.tex` earns its `\DocumentMetadata` only by
being the other half of a comparison.

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

It borrows two things from the metadata suite above — build uncompressed for
the same reason, and pair every assertion with a positive control, here
`/Subtype /Link` found by the same method on the same file, so a fixture that
stopped emitting links cannot pass by silence. See "Default-path metadata
suite" for why both matter; they are not re-explained here.

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
[`ATS-EXTRACTION.md`](ATS-EXTRACTION.md). Screen-reader
review is manual by nature and is not automated by this suite.

**veraPDF in CI.** The per-PR `tagging` job does not install veraPDF, so its
veraPDF gate is always skipped there — building it from source costs several
minutes that a per-push job should not pay. A separate weekly
`verapdf-scheduled` workflow builds veraPDF from a pinned commit and runs the
same gate. Do not describe a pull request as PDF/UA-validated on the strength of
the PR checks alone; see `CONTRIBUTING.md` "Pinned dependencies" and
[`ATS-EXTRACTION.md`](ATS-EXTRACTION.md#recorded-validation-results-v040-plus-the-v050-statement-fixture),
"Recorded validation results".

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
tests/lint/run-version-declarations.sh
```

It asserts that the Work speaks with one voice about its own version. Every
file of the Work identifies itself once —

```latex
\ProvidesExplPackage {careerdossier-base} {2026-08-12} {0.8.0}
```

— ten times, bumped by hand, and until this script nothing compared the ten.
That is not an oversight of the baselines: no committed `.tlg` records a version
or a date, deliberately, because a baseline that pinned one would churn on every
release. The consequence is that a bump missing one file passes every suite and
ships. LaTeX writes both values into the `.log` without complaint, so a
distribution whose `careerdossier-resume.cls` says `0.8.0` while its
`careerdossier-theme.sty` says `0.7.0` contains nothing wrong enough to fail.

Five checks, over `manifest.txt` and the root sources together: every `.sty`
and `.cls` the manifest lists under "The Work" exists and declares itself; every
declaration parses into a `{name} {date} {version}` triple; all the
`{date} {version}` pairs are identical; every declared name equals its own
file's basename; and the declaring files and the manifest's list are the same
set. The name check is the same hand-typed-argument drift one field to the
left — a `careerdossier-them` inside `careerdossier-theme.sty` is silent in
exactly the way a stale version is, since LaTeX repeats the declared string into
the `.log` without comparing it to the filename and `l3build` uses it for
messages only. The last is here because it is the same class of drift and costs
nothing once both lists are open — and `manifest.txt` is what defines the Work
for the LPPL, so a source missing from it is a licensing defect before it is a
packaging one.

The reference pair is the commonest one, not the first: a bump that missed one
file should name that file, not the nine that are right. A failure prints the
offending file and both pairs.

Three things it deliberately does not check: the version against the latest git
tag, and the declarations against `CHANGELOG.md` and against `docs/MIGRATION.md`.
Each legitimately disagrees on `main` between releases, since the declarations
lead or trail the tag and the headings move at a different moment in the release
sequence. Consistency among the ten is the property that holds at every commit,
so it is the only one asserted.

The fixtures under `tests/lint/fixtures/version/` are this lint's own tests —
eight miniature Works, one consistent and one per way of being inconsistent —
and the runner checks itself against them every run. Each carries three sources
with the defect in the third, which is what exercises the frequency rule: with
two files a mismatch is a tie and either could be reported as the wrong one.

The `lint` target runs a third script in the same slot:

```bash
tests/lint/run-fixture-filter.sh
```

It holds the fixture-selection contract from `CONTRIBUTING.md` "Scoping a suite
while you iterate" to account. Selection is the one part of a test runner whose own failure mode is
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

The `lint` target runs a fourth script in the same slot:

```bash
tests/lint/run-agents-references.sh
```

`AGENTS.md` "Build and test" reproduces none of this file. It points here
instead, naming sections of `CONTRIBUTING.md` and `docs/TESTING.md` in
quotation marks — the right shape, and a hand-maintained index of another
file's headings. This script is what keeps the two in step, asserting in both
directions: every section name `AGENTS.md` quotes exists as a heading in one of
those two files, and every `###` section of `CONTRIBUTING.md`'s "Local builds"
chapter is named in `AGENTS.md`. The first catches a rename on the far side;
the second catches an addition, which is the one that has actually happened.

It was written because that index drifted twice in two days and neither review
caught it (#400). `check-parallel` arrived in PR #389 and per-suite `JOBS=` in
PR #397, each adding a section to the running chapter; `AGENTS.md` went on
naming two of what were by then four, so the always-loaded core pointed away
from the entry points that week of work had just built. Writing the lint found
a third defect nobody had reported: `AGENTS.md` cited "Test-driven where
practical", a truncated form of this file's actual heading, which resolves for
a human reader and not for anything mechanical.

The reverse direction is deliberately **not** asserted for `docs/TESTING.md`.
`AGENTS.md` names six of its sections and ignores the rest on purpose, because
the reading map exists to make reading selective; requiring every heading here
to be named would force that index to grow into the copy the lint exists to
prevent. One constraint it does impose, on one short section: every quoted
string in "Build and test" is treated as a section name, so a phrase quoted
there that is not a heading fails the lint by name and should be rephrased.

A fifth script in the same slot checks the other kind of cross-reference — the
Markdown link rather than the quoted section name:

```bash
tests/lint/run-markdown-anchors.sh
```

Every `](TARGET.md#anchor)` and every same-file `](#anchor)` in a tracked
Markdown file, outside fenced code, must resolve to a heading in the target.
This exists because #259 made those links load-bearing: `docs/API.md` and
`docs/MIGRATION.md` now point at `docs/ARCHITECTURE.md` for mechanisms they used
to restate, and a pointer that resolves to nothing is worse than the duplication
it replaced. The failure was already in the tree — `CHANGELOG.md` linked three
times to `docs/MIGRATION.md#080---unreleased` after the release renamed that
heading to `## [0.8.0] - 2026-08-12` (#407).

The lint derives GitHub's anchor from the heading text, and that derivation is
the part that can be wrong: get it wrong and it reports a working link as broken,
which is #398's failure mode. Two consequences worth knowing before editing it.
It strips punctuation by **blacklist**, naming the ASCII marks plus the em dash
and rightwards arrow that headings here actually contain, because a whitelist of
`[a-z0-9 _-]` turns `## Résumé class` into `#rsum-class`. And it emits one hyphen
per **space**, not per run of spaces: removing a `—` or `→` leaves the space that
flanked it on each side, so `## Upgrading to v0.4.0: XeLaTeX → LuaLaTeX` is
`#upgrading-to-v040-xelatex--lualatex` with two hyphens. Collapsing runs reported
two working `docs/MIGRATION.md` links as broken, and the tree caught it before
the lint was trusted. It is not a general GitHub-compatible implementation and
should not claim to be; when a heading uses punctuation it does not know, teach
the derivation rather than delete the check.

### Manual-name lint

The PDF manual became the authored interface reference in `v0.9.0` (#263), and
two of that issue's acceptance criteria are assertions rather than prose: every
public name it documents exists in the source, and no private name appears.
Neither is checkable by compiling it. A manual documenting
`\CDossierSubsectoin`, or still documenting a command deleted two releases ago,
typesets perfectly and reads as authoritative — LaTeX never sees those names as
names, only as words in a document.

```bash
tests/lint/run-manual-names.sh
```

It reads `doc/careerdossier.tex` as text and asserts four things: that no
`\__cdossier_` name appears; that every `\CDossier…`, `\MakeCDossier…`, and
`CDossier…` environment it mentions occurs in a file `manifest.txt` lists
under "The Work"; that every public name the Work *defines* is mentioned in the
manual; and that the release the manual declares, and the one `README.md`'s
"current release" block declares, both match the Work's `\ProvidesExpl*`
declarations.

The name check is deliberately weak: it asks whether a name occurs in the Work
at all, not whether it occurs in a *definition*. A stricter form would have to
know every way expl3, xparse, and the kernel can bind a name and would fail on
the ones it did not know — reporting its own gaps as the manual's, which is
#398's failure mode. The weak form still catches both failures that happen: a
name misspelled in the manual, and a name removed from the source while the
manual keeps it.

#### The documented-name direction, and its ratchet

The third assertion is check (2)'s mirror, added by #468. Check (2) stops the
manual naming something that does not exist; check (4) stops the Work exposing
something the manual never mentions. Without it a new public command shipped
undocumented and every suite passed.

Two things about it are worth knowing before changing it.

**It strips TeX comments from the Work, and check (2) does not.** A name
mentioned in a comment is still a claim check (2) should validate, so its
collector keeps them. Here the same inclusion would demand documentation for
names that are deliberately private: three names in this tree appear *only* in
comments recording that #242 privatised them, and three more —
`\CDossierRecordEntryBelowSkip`, `\CDossierSharedHeaderAboveSkip`,
`\CDossierSharedHeaderBelowSkip` — only in comments recording that #204 retired
them. The two collectors are therefore separate on purpose.

**It ships as a ratchet.** Nine public names were undocumented when the check
was added, and a lint that fails on all of them at once is a lint that gets
commented out. They are declared in `tests/lint/manual-undocumented.txt`, which
may only shrink; #243 is what shrinks it, and the lint prints the remaining
count on every run. What the check catches from day one is the tenth.

The backlog is held honest by two further failures, both of which are about the
*list* rather than the manual: an entry with no reason fails, following control
8 of `run-text-guards.sh` — an exemption must cost an argument rather than a
keyword — and an entry naming something the Work no longer defines fails, so
the list cannot rot behind the source. That second one earned itself
immediately: the first draft of the backlog listed the three #204-retired
tokens above, and the lint rejected it.

**What it does not check** is that a mention is a *definition* of the name for a
reader. A name appearing anywhere in the manual counts, including inside a TeX
comment. That is the same deliberate weakness as check (2) and for the same
reason; today no name in the manual is comment-only, so the looser rule and the
stricter one give identical answers, and the divergence is not worth a second
collector until it does.

The release check is the second half of a separate finding.
`run-version-declarations.sh` checks the `.sty`/`.cls` declarations against
`manifest.txt`, and nothing checked
the documentation, which named the release in two further places; the manual
would have made a third. Only declarations are checked, and deliberately:
`docs/MIGRATION.md` mentions many versions in prose, so a grep there would match
history and fail on nothing useful.

Five fixtures, `tests/lint/fixtures/manualfixture-*.tex`, hold one manual per
verdict — correct, private name, unknown name, wrong version, and a file the
extraction finds nothing in — so a lint that had stopped detecting anything
fails there rather than passing everything.

`tests/lint/run-manual-examples.sh` is its sibling and asks the other question
about the same file: not whether the names it documents exist, but whether the
complete documents it publishes compile. "Documented templates are compiled"
above is the one statement of that check and is not repeated here.

### CTAN packaging lint

```bash
make ctan-lint                         # tests/lint/run-ctan-config.sh, the driver
                                       # tests/lint/ctan-config.lua, the assertions
```

It is a `CHECK_TARGETS` member of its own rather than a script in the `lint`
slot, and the reason is the interpreter. Every other lint here reads text and
needs no TeX, which is why the CI `lint` job runs on a bare runner instead of
pulling the TeX Live container; this one loads `build.lua` under `texlua`. Its
CI cover is therefore a step of the `regression` job, which already loads that
same file.

`build.lua` gained a packaging configuration in `v0.9.0` (#264), and
`l3build ctan` cannot check it. Its file lists are globs, and **a glob that
matches nothing is not an error** — it contributes no files and the run exits 0.
Drop `README.md` from `textfiles`, or misspell `careerdossier.tex` in
`typesetfiles`, and l3build builds an archive with no README or no manual and
reports success. Those are the two CTAN requirements a submission is rejected
for: a top-level README carrying a licence and a version, and PDF documentation
together with its source.

Building the archive would not catch it either. What `l3build ctan` produces is
an archive; nothing compares that archive against what it was supposed to
contain. This lint does, from the two files that already know — `manifest.txt`,
which defines the Work, and a Work file's own `\ProvidesExpl*` declaration. Six
checks: the package name, the published version, that every literal filename in
a file list exists, that the README, licence, manifest, and manual source are
each carried by some list, that `packtdszip` was decided rather than defaulted,
and that every Work file is matched by a `sourcefiles` glob.

It is the one lint here that **loads** its subject instead of reading it, and
the reason is the version. `build.lua` derives that from
`careerdossier-base.sty` rather than restating it, so that no eleventh copy
exists to go stale beside the ten the version lint above already holds equal —
`manifest.txt` defines the Work and `build.lua` is not part of it, so a literal
there would sit outside the set that lint reads. A grep can see the derivation
but not its result; loading is what makes the value `l3build` would publish
available to compare, against a *different* Work file than the one it was
derived from. Two consequences. The l3build variable defaults are deliberately
not loaded first, which is what lets `packtdszip` distinguish "set to false"
from "never set" — unset is `nil`, and `nil` is the failure. And the driver
fails rather than skips when `texlua` is absent, per "A guard answers three
states, not two" below.

Its negative controls are not fixture directories but mutations: the audit takes
the configuration as an argument, so the self-check re-runs it over a broken
copy, one per check, each expecting its own failure back. A checker that stopped
detecting a stale version, a missing file, a defaulted `packtdszip`, a renamed
package, or a Work file left out of the archive fails there rather than
reporting a clean tree.

The `lint` target runs three more scripts in the same slot:

```bash
tests/lint/run-text-guards.sh
tests/lint/run-shellcheck.sh
tests/check-parallel.sh --self-test
```

All three belong in this slot because they compile nothing and need neither TeX
nor biber. Two are committed negative controls: what `check-parallel.sh
--self-test` asserts is in "The parallel run" below, and `run-text-guards.sh` is
the section immediately following. `run-shellcheck.sh` is static analysis rather
than a control, and is "Shell-harness lint" below.

### A guard answers three states, not two

Every assertion about a PDF's extracted text — a running header, a folio, a
contact item, a tagged label — asks two things in sequence: capture the text,
then ask whether a string is in it. Both can fail, and the failure that matters
is the one where the *question could not be asked at all*.

The old spelling had no room for it:

```sh
elif ! printf '%s\n' "$page_text" | grep -Fq "$furniture_label"; then
  echo "  MISSING RUNNING HEADER on page $n: $furniture_label"
```

Under `make check JOBS=8` this reported a label MISSING that sat on line 1 of a
page `pdftotext` had extracted correctly and exited 0 on, and that the runner's
own re-extraction found (issue #398). A pipeline that returns non-zero for any
reason other than "no match" is indistinguishable from absent text.

**The half that matters is the inverted one.** Each `medium=screen` branch asks
the same question the other way round — the header must *not* be there — and
whatever makes the pipeline spuriously non-zero makes that branch spuriously
false. The violation is not reported and the fixture passes. A hollow failure is
loud and wastes an afternoon; a hollow pass is this repository's characteristic
defect, and a two-state guard is one more way to manufacture one.

So the contract, in `tests/lib/text.sh`, is three-valued:

| Status | Meaning |
|---|---|
| `0` | present — the needle occurs in the text |
| `1` | absent — it does not |
| `2` | **unknown** — the question could not be answered |

`text_contains`, `text_contains_line`, and `text_matches` answer it; `text_page`
and `text_extract` capture text, or yield `CDTEXT_UNAVAILABLE` when the
extraction could not be performed.

**A count owes the same three states, and needs them more.** `text_count_lines`
and `text_count_matches` print a count and return `0`, or print nothing and
return `2`. The reason is arithmetic rather than logic: `grep -Fc … || true`
over text that was never extracted answers `0`, and `0` is the *passing* value
for every count guard here — the page-one label count tests `-ne 0`, the
orphaned-bullet check tests `-eq 1`. So the unperformable answer was
numerically identical to a clean page, and `|| true` is what made it silent, by
turning any pipeline failure into an empty string that `[ "" -ne 0 ]` reports as
false. Two guards shipped that way.

The counterexample is `tests/layout/run.sh`'s page-fill parse, which is safe
without any of this: it compares its record count against the page count derived
independently from the log, so "found nothing" cannot read as "nothing to find".
Where an independent expected value exists, comparing against it is the stronger
construction. A caller must treat `2` as a failure of its
own, naming that the check could not run — never as either verdict. Each runner
spells that in its own idiom, because what it does with a failure differs
(`tests/tagging/run.sh` has `require_text`/`forbid_text` around
`record_failure`; `tests/layout/run.sh` branches inline), and only the predicate
is shared.

Two design points are worth keeping, because both were load-bearing:

- **The fixed-string match runs in the shell.** `case` with a quoted expansion
  matches literally — the same semantics as `grep -F` — and forks nothing, opens
  no pipe, and runs no external program, so there is no channel by which a match
  can be reported as a miss whatever the load. `text_matches` still needs `grep`
  for the two genuine regular expressions, and uses a here-string rather than a
  pipe, reading grep's status three ways: `0` found, `1` absent, `2` or more
  could not be checked.
- **The mechanism was never diagnosed, and the fix does not depend on one.**
  #398 tested a `grep -q` SIGPIPE race under `pipefail`, `pdftotext` failing
  under concurrency, and the pipeline failing under fork pressure — 2000, 640,
  and 7200 trials — and *none* reproduced. The fix removes the class rather than
  repairing a cause, which is what makes it verifiable against what was actually
  established.

`tests/lint/run-text-guards.sh` is the committed control. Its first assertion is
the one to preserve: it runs both spellings over the same present text with
`PATH` emptied, which puts a guard into the unperformable state deterministically
and with no load at all. The old form reports the text MISSING; `text_contains`
does not. The rest cover the three states across all three predicates, both
polarities failing on an unperformable check *and saying so*, literal matching of
needles containing glob metacharacters, an empty needle refusing to pass, and a
failed extraction marking itself unavailable rather than reading as an empty
page.

Its last two controls are a ratchet: no `... | grep -q` **or** `... | grep -c`
guard may reappear in a runner or a shared library. It is scoped to the shape
rather than to a list of known sites, so a *new* runner with the old spelling is
caught too. The one blanket exemption is the control script itself, which must
hold the old spelling in order to demonstrate that it fails.

A count that is genuinely safe — one that is only printed, or one compared
against an independently derived expected value — is exempted at the site:

```sh
# guard-ok: compared against $pages, derived independently from the log, so a
# parse that finds nothing reports 0 against a non-zero page count and fails.
fill_pages="$(printf '%s\n' "$fill_records" | grep -c '.' || true)"
```

The marker lives next to the code rather than in a list, which would rot apart
from what it describes, and two properties make it worth trusting: it must carry
a reason, so an exemption costs an argument rather than a keyword; and it shields
only the contiguous run of code lines beneath it, ending at the first blank line,
so it cannot spread down a file. The last control asserts both by re-running the
scanner over a synthetic file containing a bare marker, a reasoned one, and an
offence past a blank line.

### Shell-harness lint

`tests/` is around 10,900 lines of shell, and every verification claim this
project makes is a claim about what those scripts did. `tests/lint/run-shellcheck.sh`
is the only thing that reads them:

```bash
tests/lint/run-shellcheck.sh        # or: make lint
```

Three things about it are decisions rather than defaults.

**The threshold is `-S warning`, not `-S error`.** The first defect it found —
a `local` whose later assignments dereference the variable being declared,
`tests/tagging/run.sh` — is reported as SC2318, which is *warning*-severity.
`-S error` would have run clean over it and reported a healthy harness with a
passing check's authority behind it.

**Sourced libraries are resolved, not suppressed.** `-x` alone buys nothing
here: the harness sources through variables (`. "$root/tests/lib/text.sh"`), and
shellcheck cannot resolve a path it would have to run the script to know. Each
such line carries a `# shellcheck source=` directive naming the file literally,
which removed five findings from `tests/check-parallel.sh` by telling shellcheck
where the definitions are — leaving SC2034 and SC2154 fully *active* in that
file rather than silenced.

**Suppressions are per-site and carry a reason.** A file-level
`disable=SC2034` would switch that check off for a whole file permanently,
including code not yet written, and SC2034 is exactly what catches a typo'd
accounting counter — `fanout_faild=0` for `fanout_failed=0`, a variable set and
never read, which would leave the counter untouched and the run reporting a
clean suite. That is the hollow pass `tests/lib/fanout.sh` exists to remove. Two
sites are suppressed: the positional placeholders in `tests/layout/run.sh`'s
page-fill `read`, and the four `eval`-written, `eval`-read variables in
`tests/metadata/run.sh`.

A missing `shellcheck` fails the lint rather than skipping it, as
`tests/lint/run-ctan-config.sh` does for a missing `texlua`: a check that could
not be performed is not a check that passed.

One version caveat. CI's `lint` job runs on the bare `ubuntu-latest` runner,
whose image ships shellcheck 0.9.0; a contributor's own may be newer and
therefore stricter, since shellcheck adds checks between releases. SC2318 exists
in 0.9.0, so the gate is real on both. The `lint` job records the version it
ran, for the same reason it records bash, grep, and awk.

### Running under a restricted sandbox

Two runners used to fail under a Bash sandbox that denies re-opening a pipe file
descriptor or reaching the per-user temp directory, and both failed in this
file's characteristic way — a verdict about work that never happened (#392).

`tests/extraction/run.sh` and `tests/bibliography/run.sh` compared their
extracted text against a process substitution. The denial lands on `diff`'s own
*input*, so `diff` exited non-zero having compared nothing and the runner
reported an extraction mismatch above an empty diff. Each now writes what it
extracted to a scratch `*.got` file and diffs two ordinary paths; the scratch
file is load-bearing rather than tidy, and `tests/check-parallel.sh` avoids
process substitution for the same reason.

`tests/tagging/run.sh` invokes veraPDF, whose JVM does not read `TMPDIR` but
asks Darwin for the per-user temp directory directly. Where that directory is
denied, veraPDF dies in its own static initialiser and every fixture was
reported as failing PDF/UA-2 validation — eleven verdicts from a validator that
never started, the hollow *failure* to the hollow pass above. The runner points
the JVM at the temp directory the rest of the suite already uses, appending to
`_JAVA_OPTIONS` so a caller's own value survives, and declines to set it when
the path contains whitespace rather than passing an unparsable option.

The third half of #392 — biber's cache, which cannot be shared between
concurrent invocations — is under "The parallel run" below, since it is a
concurrency defect rather than a sandbox one. Both source files carry the full
diagnosis in comments at the repair site.

### The parallel run

`make check` runs its twelve targets four at a time rather than one after
another, and `make check-serial` is the same twelve singly. `CONTRIBUTING.md`
"The gate, and the serial path" is canonical for how to invoke either; this
section is what the thing does, what it costs, and what it is worth. The argument
for allowing it at all — that CI's execution model is already fully concurrent,
so nothing "CI-aligned" depends on scheduling — is in #399.

What makes it *safe* are the properties and proofs below, and they are why a
scheduled run may be the thing a push happens behind: a gate that reports green
without having done the work would be worse than a slow one.

#### How it works

The unit of parallelism is the **target**, not the fixture and not the compile.
`tests/check-parallel.sh` asks the `Makefile` which targets `check` runs, then
dispatches each as its own `make <target>`, four at a time by default:

```text
make check-targets  ->  lint ctan-lint regression extract-test smoke layout
                        bibliography-test links metadata annotations
                        tagging examples
```

Nothing about how a suite decides anything changes: every verdict is still made
by the suite that made it serially, and only how many are in flight at once is
different. Three properties make that safe to believe:

- **One target list.** Both paths expand the same `CHECK_TARGETS` variable, and
  `make lint` compares what each would dispatch. A hand-maintained second copy is
  how the `annotations` suite once dropped out of a run reported clean.
- **Ordered replay.** Each worker's stdout and stderr is captured to
  `build/check-parallel/NN-<target>.log` and replayed in the `Makefile`'s order
  after the run, so "which suite failed" is answerable from the transcript. This
  is one of the two reasons it is not `make -j check`: macOS ships GNU make 3.81,
  which has no `--output-sync`, so twelve suites would interleave line by line.
  The other is that `-j` would also fan out *inside* `examples`, whose six
  sub-targets share one `latexmk` output directory — a collision this driver
  avoids by dispatching `examples` whole.
- **Accounting.** Every dispatched target must leave a result file, and the run
  fails when the count of results is not the count dispatched, naming the ones
  that produced none. Concurrency adds a failure no suite can report on itself:
  a worker that dies before its suite ever ran leaves only an absence, and an
  absence reads exactly like a clean run unless something is counting.

Two tool caches then have to be prepared before anything fans out, because a
cache several processes build at once is a cache built wrong — and the two need
opposite treatment:

- **luaotfload's font cache is warmed.** One small LuaLaTeX build before
  dispatch, required to prove it typeset real glyphs. Where the cache is
  unwritable, `fontspec` falls back to `nullfont`, every document typesets empty,
  and every suite passes having measured nothing.
- **biber's cache is isolated, because it cannot be warmed.** Issue #392
  measured why: biber re-unpacks its native binary into that cache on *every*
  invocation, not the first, so two invocations sharing one cache truncate each
  other's binary — a warm shared cache fails exactly as a cold one does. Each
  worker therefore gets its own `PAR_TMPDIR`, and one probe extraction before
  dispatch proves biber can unpack here at all.

`--self-test` is the committed control for all of that, driven over synthetic
workers and logs so it needs no TeX and no biber: a clean batch must pass and
account for every member; a batch with one failing member must fail, name it,
and replay its output; a batch with one result file removed — the state a killed
worker leaves — must fail as an accounting failure rather than as two passes and
a shrug; three workers must report three *distinct* biber caches, since an
isolation that quietly stopped being applied would restore a failure that reads
as a flaky bibliography fixture; the extraction verdict must refuse a failure
that still exited 0, because the status is not the proof, the log is; and every
dispatched name must be `.PHONY`, since one that is not would make
`make <target>` a no-op exiting 0. The font-cache proof needs TeX, so every real
run exercises it instead.

Three further controls guard the target list itself, each run against a
`Makefile` broken in the way it claims to catch. #399 records why there are
three rather than one:

| Divergence introduced | `check-serial` grep | gate grep | list comparison |
|---|---|---|---|
| `check-targets` prints a hand-written list, dropping `annotations` | ok | ok | **FAIL** |
| `check` stops dispatching through the driver | ok | **FAIL** | ok |
| `check-serial`'s prerequisites become a copy that still matches | **FAIL** | ok | ok |

The diagonal is the point: no control is redundant. The first row is the
historical failure this whole arrangement exists to prevent — a suite silently
absent from a run that is then reported clean — and only the list comparison
catches it, because it alone compares *what each path would dispatch* rather
than how either is spelled, reading the serial list out of `make -p`'s expanded
rule database and the parallel one from `make check-targets`.

#### What it is worth, and what it costs

The calibration sweep, measured on the maintainer's machine 2026-08-13, with
`make clean` before every run so none inherited an up-to-date `examples`:

| | Wall time | Result |
|---|---|---|
| `make check-serial` | 439 s | green |
| `make check JOBS=2` | 285 s | green |
| **`make check JOBS=4`** (the default) | **211 s** | **green** |
| `make check JOBS=8` | 168–201 s | **4 red in 8 runs** |

That sweep settled the default at 4, and five consecutive clean-tree runs when
#399 landed confirmed it — **211, 225, 247, 248, and 249 s, all green**, against
`make check-serial` at **431 s**. So the speedup is **roughly 1.8×–2.0×**: note
the spread, since a single 211 s run is the fast end of a range rather than the
figure to quote.

`JOBS=8` is a further 20% and is not the default, because it fails about half the
time: every one of those failures is a text-extraction assertion against a
document that is provably correct — a guard that reports present text as missing
under load (#398) — so the ceiling is an open defect elsewhere, not a property of
the machine. The honest form of the claim is **"a parallel gate is trustworthy at
4 and is not at 8"**, and a `JOBS=4` run ever red for the #398 reason is a reason
to reconsider this arrangement rather than to retry it.

**The ceiling is structural, not a matter of more workers.** Parallel wall time
is the longest single target plus contention, not the sum divided by `JOBS`:
`smoke` (124 s), `tagging` (116 s), and `layout` (114 s) dominate, while `lint`
(2 s), `annotations` (5 s), and `metadata` (8 s) finish before the long ones are
a third done. So the floor here is the longest single target, and only fanning
out *inside* it goes lower — the next section. What more workers would buy, and
why it is dispatch order rather than core count, was measured under #390.

Sorting the dispatch longest-first is the one remaining candidate for the rest,
and was rejected under #399, which also holds three further bounds on what the
speedup is worth: the replay follows dispatch order, so sorting for speed also
sorts the transcript, and "which suite failed is answerable in `Makefile` order"
is one of the two reasons this is not `make -j`.

Against that, the costs:

- **Disk.** Each biber-using worker's private cache is about 208 MB of unpacked
  Perl runtime, and three or four are made over a run, each freed as its worker
  finishes rather than at the end. Sampled every five seconds at `JOBS=4` the
  peak reached **416 MB** — two caches at once — against the ~830 MB the same
  run would hold if they lived to the end, and the tree goes entirely when the
  run ends or with `make clean`. That is the price of the only isolation biber
  allows: the two cheaper alternatives, a shared cache made read-only after
  warming and per-worker `PAR_TMPDIR` sharing modules through
  `PAR_GLOBAL_TMPDIR`, were both built under #392 and both still race.
- **Machinery.** Two cache workarounds, an accounting assertion, and eight
  committed controls exist so that a scheduled run cannot quietly report a clean
  one — the right ratio for a repository whose characteristic failure is a check
  that passes without doing the work, and the whole of what earns this path the
  gate. `make check-serial` is the standing answer to a parallel result that
  looks wrong: it removes scheduling without removing an assertion.

### Fanning out inside a suite

`make smoke JOBS=N`, `make layout JOBS=N`, and `make tagging JOBS=N` run that
many of the suite's own fixtures at once (issue #390). `CONTRIBUTING.md`
"Running one suite's fixtures concurrently" is canonical for how to invoke it;
this section is what it does and why it is safe to believe.

#### What is different from the target level

The section above parallelised *processes that already reported their own
verdicts*: a dispatched `make layout` either exits 0 or does not, and the driver
only had to count. Inside a runner there is no such boundary. Every assertion
wrote into shell state the loop accumulated — `fail=1`, counters, `failed`
arrays — and **shell state does not survive a subshell.** Getting that wrong
does not produce a crash. It produces a suite that compiles 54 fixtures, loses
53 verdicts, and reports a clean run: this repository's characteristic failure,
one layer further in.

So the unit is a *function* that prints what the serial runner printed and
reports through its **return status alone**. The serial driver calls those
functions in order; the parallel driver dispatches them and replays their
captured output in the same order. Identical output between the two paths is
therefore structural rather than something a test has to keep re-checking — and
it is checked anyway, by diffing a full run against the previous commit.

Two things made this a smaller change than it looks:

- **`local fail` shadows the global.** `layout` has eighteen `fail=1` sites and
  `tagging` has forty, reached through sixteen `check_*` helpers. Bash scopes
  dynamically, so a helper's `fail=1` lands on the nearest `fail` up the call
  stack — the unit's local. Measured on bash 5.3 and on the macOS `/bin/bash`
  3.2 these suites must run under. Not one of those sites changed, so not one of
  them could be missed, and a missed site reports a clean fixture.
- **An `EXIT` trap does not fire in a background subshell.** `layout`'s
  `control_dir` and `tagging`'s `work` are removed by traps, and a trap firing
  per worker would delete them mid-run. Measured on both bash versions: it fires
  once, in the parent, after `wait`.

#### What it asserts beyond the fixtures

- **Accounting.** Every dispatched fixture must leave a result file, and the run
  fails when the count of results is not the count dispatched, naming the ones
  that produced none. A fixture whose worker died leaves no failure behind, only
  an absence, and an absence reads exactly like a clean run unless something is
  counting.
- **One fixture universe.** `tests/lint/run-fixture-filter.sh` asserts that each
  runner's `--list-units` — the units its parallel driver would dispatch —
  covers its `--list` exactly, and that the `Makefile` can actually reach the
  `--jobs` path. A runner whose fan-out silently dispatched a subset would pass
  every other check and then report a clean run of something other than the
  suite. This compiles nothing and runs in the `lint` slot.
- **The font cache is warmed** before any fixture is dispatched, and the warm-up
  build must prove it typeset real glyphs. This bites hardest in `tagging`: a
  `nullfont` run still produces a structure tree, still extracts, and still
  validates — it would pass every gate having typeset nothing.

The dispatcher, the throttle, the ordered replay, and the accounting assertion
are one implementation, `tests/lib/fanout.sh`, shared with
`tests/check-parallel.sh` rather than copied into each runner — a second copy of
a check against a silent failure is how one of them stops being made. Its
committed negative controls are the driver's existing five, which now drive the
shared code: a clean batch accounts for every member; one failing member fails
by name with its output replayed; and **a removed result file is an accounting
failure rather than a pass.**

#### What it is worth, and what it costs

Measured on the maintainer's machine, 2026-08-13, each suite against the same
commit and its immediate parent:

| Suite | serial | `JOBS=4` | `JOBS=8` |
|---|---|---|---|
| `smoke` | 108 s | 40 s (2.7×) | 31 s (3.4×) |
| `layout` | 95 s | 35 s (2.7×) | 26 s (3.6×) |
| `tagging` | 100 s | 36 s (2.8×) | 31 s (3.2×) |

Each was also run against the immediately preceding commit and its serial output
diffed: identical in all three, apart from the `time` line, and — for `tagging` —
the timestamp and repository path its own toolchain record carries.

`tagging` scales despite being the suite with the most non-LaTeX work, and its
serial baseline already ran at 118% CPU because veraPDF's JVM is itself
threaded. It needed no biber-cache isolation: only one of its twelve groups
invokes biber, so no two of its own workers can race there.

Three bounds, in the spirit of the ones above:

1. **It still does not make the gate faster.** The gate fans out across
   *targets*, and pins the fixture fan-out inside each one to 1. So this saving
   lands on a scoped development loop and on running a long suite by itself —
   not on `make check`, which #399 sped up the other way.
2. **The two layers multiply.** `make check JOBS=4` with each target fanning out
   4 is sixteen LuaLaTeX processes. Left alone that would happen silently: a
   command-line `JOBS` lands in `MAKEFLAGS` and every dispatched sub-make would
   inherit it. So the driver passes every target an explicit `JOBS`, defaulting
   to 1, and the product is raised only by `INNER_JOBS=N`, which prints the
   budget it is about to use. That pinning is also why making the gate parallel
   did not multiply the process budget as a side effect.
3. **Contention is real above four.** The `JOBS=8` columns cost roughly a third
   more CPU-seconds than the `JOBS=4` ones for their extra wall-clock saving,
   because the fixtures start competing for the same cores.

### Module regression suite (l3build)

The logic-bearing packages are covered by an `l3build` regression suite. Each
`.lvt` source under `tests/regression/` is compiled on LuaTeX and its filtered
log is diffed against a committed `.tlg` baseline. Run the whole suite from the
repository root:

```bash
make regression            # or: l3build check
```

Two disciplines are load-bearing for a text-layer-sensitive package: add a
regression test for every fixed bug, and inspect every newly saved `.tlg` —
`l3build` detects change but cannot decide whether the new output is correct.
Maintain negative tests proving unsupported engines fail with the intended
message.

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

### Structural gap and visible gap are different numbers

The matrix above proves each token *renders*. It does not say how much white a
reader sees, and those are different quantities:

```text
visible white = structural gap + interline glue
interline glue = baselineskip - depth(previous box) - height(next box)
```

The tokens own the structural gap exactly — that is what
`statement-section-gap` asserts. **No token can reach the interline term**, and
it is not symmetric around a heading: a heading box is tall and shallow, so it
starves the gap above itself and hands it back below. Measured on the statement
class at 12 pt, the section pair is 2.33:1 in tokens and 1.32:1 in visible
white. A conclusion about hierarchy drawn from the token ratio alone will be
wrong by roughly that much.

```bash
make review-spacing        # or: tests/spacing/report.sh; tests/spacing/report-pages.sh
```

Both gaps, every boundary, four classes, 10/11/12 pt. It is a report, not a
gate: no assertion, no baseline, and it is not part of `make check`.

**Two measures of "white" exist, and they disagree on ratios.** `pdftotext
-bbox` reports each word as the font's full **em-box**, not glyph ink — at 12 pt
body that box is 15.97 pt tall against 14.5 pt of leading, so consecutive lines
in one paragraph overlap and the tool reports **−1.53 pt**. A negative gap is
the tell that a figure came from it. The node-level measure this harness uses
takes TeX's line boxes, which bound the glyphs actually present. Both are
legitimate — use `pdftotext -bbox` for extraction and reading-order work,
because it is the extractor's own view, and the node measure for typographic
judgements. **Whichever you use, record which one produced the number.** #206's
figures were labelled "ink to ink" and were not, and the mislabelling survived
two releases because no measurement script was committed to check them against.

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

- inspect the affected PDFs, including rendered pages and any clipping;
- compare them with the current baseline;
- check page breaks;
- check long links and contact lines;
- check print and grayscale behavior;
- attach or link a preview in the pull request.

Render each example to PNG and inspect it after meaningful changes. Include narrow
and long values, multiple pages, long organization names, long URLs, and accents.
Check clipping and overlap; broken bold/italic; orphan headings; awkward page
splits; rules extending into text; contrast; and 200–400% zoom. Full automated
visual regression is a later-phase goal.
