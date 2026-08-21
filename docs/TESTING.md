# Testing CareerDossierTeX

Two things live here: the rules a change has to meet before its tests count as
done, and a map of the harness that runs them.

Neither the mechanism of a suite nor the invocation of a target is one of them.
`make help` lists every target with a one-line description. Each runner under
`tests/` opens with a header comment stating what it asserts and why, at the
code that does it. This file points at both rather than repeating either, so
that a suite and its description cannot drift apart.

[`../CONTRIBUTING.md`](../CONTRIBUTING.md) owns the surrounding workflow — how
to propose, build, commit, and submit a change — and its "Testing" section
states the one-sentence obligation this file details.

Read the section that covers the concern you are changing; there is no
expectation that anyone reads it end to end.

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

### What lives in `tests/`

All automated test sources, expected outputs, fixtures, and runners belong
under `tests/`:

| Path | Holds |
| --- | --- |
| `tests/lint/` | source-level invariants no compiled fixture can assert; eleven scripts and their self-test `fixtures/` |
| `tests/regression/` | `l3build` `.lvt` sources and `.tlg` baselines, one pair per module concern |
| `tests/smoke/` | supported builds (`*-valid`), required failures (`*-bad-*`, `*-missing-*`), and the manual's templates |
| `tests/extraction/` | text-layer round trips: fixtures plus `*.expected.txt` (Poppler) and `*.pdfkit.txt` (PDFKit) baselines |
| `tests/layout/` | multi-page and long-value stress sources, the two `.awk` log parsers, and every visual-review renderer |
| `tests/links/` | copy-paste integrity fixtures, `links.bib`, and `link-token-check.awk` |
| `tests/metadata/` | default- and tagged-path PDF catalog metadata fixtures |
| `tests/annotations/` | link-annotation action-type fixtures |
| `tests/bibliography/` | Biber sorting and identifier-precedence fixtures over `publications.bib` |
| `tests/tagging/` | tagged, untagged, and `-ua2` fixtures with `*.structure.txt` and `*.mupdf.txt` baselines; `reports/` is generated |
| `tests/spacing/` | the node-level spacing probe (`probe.lua`) and its report drivers |
| `tests/lib/` | shared helpers: `fanout.sh` (per-fixture concurrency), `text.sh` (three-state extracted-text guards) |
| `tests/check-parallel.sh` | the `make check` driver |

Fixture names are load-bearing: `*two-page*` selects the multi-page assertions,
`*-valid`/`*-bad-*` select the smoke verdict, and `-ua2` marks the UA-2 variant.
`.inc`/`.inc.tex` files are shared bodies included by several fixtures, so one
edit moves every fixture that includes it.

Create subdirectories only when the first real test needs them. Keep
user-facing demonstrations under `examples/`; tests may compile those examples,
but must not hide focused fixtures among them.

A separate test-only issue is appropriate for a reusable harness, a
cross-cutting quality improvement, or explicitly recorded legacy test debt. It
must not be used to postpone tests already known to be necessary for an
implementation issue.

### Match the test to the module

Test-as-you-go is not one uniform activity. What "the smallest relevant test"
means depends on what the module owns, so match the test type to the concern:

- **Observable logic** — values, options, errors, or emitted structure — can be
  asserted directly by a log diff. Write a focused `l3build` regression test
  (`.lvt` source with a saved `.tlg` baseline) under `tests/regression/` as the
  behavior is added, in the same rhythm as writing a `test_*.py` beside each
  Python module. This is where a pre-implementation failing test is usually
  practical and most valuable. **No module is exempt.** Every shared package
  and every class already has such coverage so extend the existing file for
  that module rather than assuming a class does not need one.
- **Layout behavior** — the visual result the classes own — is what no log diff
  fully captures, and it takes coverage _in addition to_ the regression test:
  smoke tests (compiles clean, expected diagnostics), extraction tests (text
  present and in logical order), tagging fixtures, and a small set of reviewed
  reference PDFs. Final layout correctness stays a human visual check. Do not
  force brittle per-line-break or per-metric assertions onto a class before its
  design has settled.

When a change spans both — a shared package edit that both classes render — add
or update the unit-level regression for the shared logic _and_ re-run the
smoke, extraction, and layout coverage for both classes.

### Reproduce a mechanism below the level of a suite

The tests above are what a change must _ship_. They are usually the wrong
instrument for finding out how something behaves in the first place, and
reaching for a suite to answer that question is the most expensive habit
available here.

Reproduce a mechanism at the smallest scale that exhibits it, and use a suite
only to confirm. Three practical consequences:

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

## Baselines and layers

### Baselines are load-bearing

A saved baseline (an `l3build` `.tlg`, or the committed extraction reference)
is the assertion. Capturing it is not a formality: an incorrect baseline
silently records a bug as the expected result. Whenever you save or regenerate
a baseline:

1. do it only for an output change that is intended and understood;
2. read the new baseline, or its diff against the previous one, and confirm
   every change is one you meant to make;
3. commit the baseline in the same change as the behavior it describes.

Never regenerate a baseline merely to make a red suite green. A `.tlg` may echo
the same value several times; regenerate every affected line, not the first
one.

### The harness precedes the tests that need it

`l3build` regression tests cannot run until the harness exists. The harness
(`build.lua` configured for `tests/regression/`) is therefore a prerequisite
for the per-module `.lvt` workflow above, not a parallel nicety: stand it up
before — or in the same change as — the first module whose coverage depends on
it, rather than accumulating `.lvt` sources that no runner can execute. Until
the harness lands, record the specific regression tests owed as explicit,
tracked debt.

### The five test layers

Every automated check here belongs to one of five layers, and the layer decides
what a failure means:

1. **Class/package regression tests** — API behaviour, options, errors,
   grouping, and load order **(l3build; Phase 1 onward)**.
2. **PDF extraction tests** — characters, spaces, reading order, and semantic
   adjacency **(Phase 1)**.
3. **PDF structural tests** — syntax, embedded fonts, metadata, tags, and
   accessibility claims.
4. **Rendered-page tests** — overlap, clipping, density, page breaks, contrast.
5. **Real-portal tests** — parsed preview or autofill where possible.

Add each layer's focused fixture with the implementation it validates. When
practical, run the new fixture before implementation and confirm that it fails
for the intended reason. All automated sources, expected outputs, runners, and
baselines belong under `tests/`; milestone release work reruns them but does
not defer their creation.

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
- link-annotation action types after any change that emits a link
  (`make annotations`) — no other suite can see this one;
- derived PDF document metadata after any change to it, on **both** build paths
  (`make metadata`), covering the precedence rule on each path as well as the
  derived value;
- unsupported-engine error;
- every option's accepted and rejected values, including the error naming the
  accepted values, and rejection reported exactly once;
- any user-facing template a change publishes or edits: one added to the
  manual's "Complete examples" chapter needs a `manual-example-*.tex` fixture in
  the same change, or `make smoke` fails — see "Documented templates are
  compiled" below;
- the release archive after any change to the Work's file set or to
  `build.lua`'s packaging configuration (`make ctan-lint`) — see "CTAN packaging
  lint" below;
- the documented calibrated values after any retune of a spacing token, the type
  scale, or a derived metric (`make lint`) — see "Token-value lint" below;
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

## Spacing tokens

### Spacing tokens: reporting a value is not rendering a gap

A spacing token reaches the page only where it wins a maximum. `\addvspace`
collapses two adjacent claims to the larger one, so a token that is smaller
than its neighbour everywhere a fixture happens to look contributes nothing
there — and a fixture that prints the token with `\TYPE` still records a
difference when the ratio changes. Its baseline moves, and the test looks like
it is working.

That is not hypothetical. `resume-entry-edges` exists to assert entry and list
boundary composition and printed `\CDossierRecordEntryAboveSkip`, but every
entry in it had a body, and that token only wins a maximum between two
_bodiless_ entries. When issue #206 moved the ratio, only the echoed number
changed. The unreachable-token condition issue #204 exists to prevent was
reproduced inside the test written to catch it.

So each public spacing token must be rendered by at least one committed
fixture, and the table below records which. Extend the fixture named there when
you retune a ratio, and add a row when you add a token.

| Token                                 | Rendered by                                    | At the boundary                     |
| ------------------------------------- | ---------------------------------------------- | ----------------------------------- |
| `\CDossierSharedHeaderNameGapSkip`    | `components-headerstack`                       | header line 1 → line 2              |
| `\CDossierSharedHeaderMetaGapSkip`    | `components-headerstack`                       | header line 2 → line 3              |
| `\CDossierRecordHeaderBelowSkip`      | `resume-header-edges`                          | header stack → first ruled section  |
| `\CDossierRecordSectionAboveSkip`     | `resume-entry-edges`                           | entry → next section heading        |
| `\CDossierRecordSectionRuleGapSkip`   | `resume-entry-edges`                           | heading baseline → section rule     |
| `\CDossierRecordSectionBelowSkip`     | `resume-entry-edges`                           | section rule → first entry          |
| `\CDossierRecordEntryAboveSkip`       | `resume-entry-edges`                           | bodiless entry → bodiless entry     |
| `\CDossierRecordEntryGapSkip`         | `resume-entry-edges`                           | entry heading → prose body          |
| `\CDossierRecordListEdgeAboveSkip`    | `resume-entry-edges`                           | entry heading → bullet list         |
| `\CDossierRecordListEdgeBelowSkip`    | `resume-entry-edges`                           | bullet list → next block            |
| `\CDossierRecordItemSepSkip`          | `resume-entry-edges`                           | bullet → bullet                     |
| `\CDossierRecordParSkip`              | `resume-entry-edges`                           | every paragraph boundary            |
| `\CDossierProseHeaderBelowSkip`       | `statement-prose-edges`                        | header stack → first section        |
| `\CDossierProseSectionAboveSkip`      | `statement-prose-edges`                        | paragraph → section heading         |
| `\CDossierProseSectionBelowSkip`      | `statement-prose-edges`                        | section heading → paragraph         |
| `\CDossierProseSubsectionAboveSkip`   | `statement-prose-edges`                        | paragraph → subsection heading      |
| `\CDossierProseSubsectionBelowSkip`   | `statement-prose-edges`                        | subsection heading → paragraph      |
| `\CDossierProseParSkip`               | `statement-prose-edges`                        | paragraph → paragraph               |
| `\CDossierLetterHeaderBelowSkip`      | `letter-block-edges`, `components-headerstack` | header stack → date line            |
| `\CDossierLetterParSkip`              | `letter-block-edges`                           | paragraph → paragraph               |
| `\CDossierLetterRecipientLineGapSkip` | `letter-block-edges`                           | recipient line → recipient line     |
| `\CDossierLetterBlockSkip`            | `letter-block-edges`                           | letterhead block → letterhead block |
| `\CDossierLetterBodyAboveSkip`        | `letter-block-edges`                           | salutation → body                   |
| `\CDossierLetterBodyBelowSkip`        | `letter-block-edges`                           | body → closing                      |
| `\CDossierLetterSignatureGapSkip`     | `letter-block-edges`                           | closing → signature name            |

Two kinds of fixture are _not_ in that column, and neither is a substitute.

`tokens-scale`, the four `tokens-*-defaults`, and `tokens-invariants` echo
values and compare them to one another. Pinning resolved values and their
ordering is a legitimate contract on its own — it is what catches a ratio
changed by accident — but it answers a different question, so a token covered
only there is untested. The same holds for a traced `\addvspace`:
`components-headerstack` and `statement-headerstack` intercept it to record
_which_ token the header stack selected and how many times, which is a claim,
not a rendered gap. Both fixtures keep those traces; `components-headerstack`
adds composed heights alongside them.

`tests/layout/` renders rather than reports, but it asserts page counts,
overfull boxes, furniture, media box, and widow/orphan behaviour — not gaps. A
spacing change of a grid step or two moves nothing it looks at. It is
corroboration when a retune flips a page count, not a per-token instrument.

Verify a new shape by perturbing the ratio and rebuilding — do not assume it
from the token's definition. Perturb _downward_ where the token allows it:
raising a token that currently loses its maximum can make it win, which reports
coverage the committed values do not have. For a token whose default is `0.00`
only the upward direction exists, and the reading is then "any non-zero value
renders", not "this gap is on the page today".

### Structural gap and visible gap are different numbers

The matrix above proves each token _renders_. It does not say how much white a
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

**Two measures of "white" exist, and they disagree on ratios.**
`pdftotext -bbox` reports each word as the font's full **em-box**, not glyph
ink — at 12 pt body that box is 15.97 pt tall against 14.5 pt of leading, so
consecutive lines in one paragraph overlap and the tool reports **−1.53 pt**. A
negative gap is the tell that a figure came from it. The node-level measure
this harness uses takes TeX's line boxes, which bound the glyphs actually
present. Both are legitimate — use `pdftotext -bbox` for extraction and
reading-order work, because it is the extractor's own view, and the node
measure for typographic judgements. **Whichever you use, record which one
produced the number.** #206's figures were labelled "ink to ink" and were not,
and the mislabelling survived two releases because no measurement script was
committed to check them against.

## Running the harness

`make check` is the gate and runs every suite below. `CONTRIBUTING.md` "Local
builds" and "The gate, and the serial path" own the invocation, scoping, and
what each target's CI job is called.

The entries below say only what a suite covers and where its output lands, so
that you can find the right runner to read.

### Running under a restricted sandbox

`tests/extraction/run.sh`, `tests/bibliography/run.sh`, and `tests/tagging/run.sh`
need a writable per-user temp directory, and `tests/tagging/run.sh` additionally
needs one veraPDF's JVM can reach. Denied, they fail in this file's
characteristic way — a verdict about work that never happened. Each source
carries the full diagnosis in comments at the repair site.

The same failure mode governs LuaLaTeX itself: where luaotfload cannot write its
font cache, fontspec falls back to `nullfont` and every document typesets empty,
so a sweep or suite reports a clean result it never measured. Suspicious speed
or an implausibly clean arm is the tell; grep a `.log` for
`not loadable: metric data not found` before believing it, and never regenerate
a baseline from such a run.

### The parallel run

`tests/check-parallel.sh` dispatches `CHECK_TARGETS` across workers, captures
each to `build/check-parallel/NN-<target>.log`, and replays them in `Makefile`
order. It accounts for every dispatched target, warms the font cache, and gives
each worker its own biber cache. `--self-test` drives its five committed
controls. The `Makefile` header owns why `JOBS` defaults to 4.

### Fanning out inside a suite

`tests/lib/fanout.sh` is the shared fan-out `smoke`, `layout`, and `tagging` use
for `JOBS=N` over their own fixtures, with the same per-fixture accounting. The
two layers multiply, so the driver passes every target an explicit `JOBS` and
only `INNER_JOBS=N` raises the product.

### Log inspection

After compiling, inspect logs for:

- LaTeX errors;
- undefined control sequences;
- emergency stops;
- overfull boxes;
- missing glyphs;
- font substitutions;
- unresolved references.

Not every warning must become a failing CI check immediately. First determine
whether it is meaningful and stable enough to enforce.

### Visual verification

When layout changes:

- inspect the affected PDFs, including rendered pages and any clipping;
- compare them with the current baseline;
- check page breaks;
- check long links and contact lines;
- check print and grayscale behavior;
- attach or link a preview in the pull request.

Render each example to PNG and inspect it after meaningful changes. Include
narrow and long values, multiple pages, long organization names, long URLs, and
accents. Check clipping and overlap; broken bold/italic; orphan headings;
awkward page splits; rules extending into text; contrast; and 200–400% zoom.
Full automated visual regression is a later-phase goal.

## The suites

One entry per `CHECK_TARGETS` member. Read the named runner for what it asserts.

### Module regression suite (l3build)

`make regression` — `l3build check` over `tests/regression/`, one `.lvt` source
and committed `.tlg` baseline per module. API behaviour, option values,
diagnostics, grouping, and load order. `TEST=<name>` runs one.

### Smoke suite

`make smoke` — `tests/smoke/run.sh` compiles every supported document and
asserts every required failure path. `*-valid.tex` must compile, `*-bad-*.tex`
and `*-missing-*.tex` must fail with the expected diagnostic, and
`manual-example-*.tex` compiles the manual's published templates verbatim.

### Layout stress suite

`make layout` — `tests/layout/run.sh` compiles the stress fixtures and asserts
page-level properties: no overfull boxes, correct furniture and folios,
`*two-page*` fixtures actually spanning two pages, no split hyphenated word
across a break, and the page-fill floor. `tests/layout/page-break-check.awk` and
`page-fill.awk` do the log parsing.

### Extraction round-trip test

`make extract-test` — `tests/extraction/run.sh` compiles each fixture and
compares Poppler output against its `*.expected.txt` baseline, asserts no
`/ActualText`, and on macOS compares Apple PDFKit output against `*.pdfkit.txt`
via `pdfkit-extract.js`. The two extractors keep separate baselines because they
impose different line structure. `./run.sh --update` regenerates, deliberately.

### Reading-order assertions

Part of the extraction suite: the committed `*.expected.txt` baselines fix the
order in which text extracts, so a reflow that changes reading order fails even
when every character is still present. `docs/ATS-EXTRACTION.md` is canonical for
what that order must be.

### Real portal acceptance

Manual, unautomated: paste an example PDF into a real applicant-tracking portal
and record the parsed result in the pull request. No runner covers it;
`docs/ATS-EXTRACTION.md` holds the recorded results and the size limit.

### Link copy-paste integrity suite

`make links` — `tests/links/run.sh` asserts a URL or e-mail address never picks
up extraction whitespace inside a visual line and reassembles exactly when it
wraps, reading `pdftotext -bbox` coordinates via `link-token-check.awk`.
Fixtures declare `% LINKTOKEN:` and optionally `% LINKEXPECT: split` for a
negative control. `docs/ATS-EXTRACTION.md` "Copy-paste integrity" is canonical
for the extractor behaviour behind it.

### Default-path metadata suite

`make metadata` — `tests/metadata/run.sh` checks derived PDF catalog metadata on
the default (untagged) path and, for `/Title` and `/Author`, on both paths. The
two paths hand the string to different writers, so a value correct on one can be
wrong on the other with nothing logged.

### Link-annotation suite

`make annotations` — `tests/annotations/run.sh` asserts every link annotation
carries a `/S/URI` action and never a `/S/GoToR` remote-PDF one. The page, the
extracted text, and the `links` invariant all stay correct when this is wrong,
so no other suite covers it.

### Tagged-PDF suite

`make tagging` — `tests/tagging/run.sh` builds each fixture tagged, untagged,
and as a `-ua2` variant, compares structure against `*.structure.txt` and
extracted text against `*.mupdf.txt`, runs a three-extractor matrix, and
validates UA-2 with veraPDF. `structure-text.pl` does the structure dump.
Reports land in `tests/tagging/reports/`, never committed. The per-PR CI job
skips the veraPDF gate; a weekly `verapdf-scheduled` workflow runs it.

### BibLaTeX/Biber fixture

`make bibliography-test` — `tests/bibliography/run.sh` checks Biber sorting and
rendered identifier precedence over `publications.bib`, plus the
missing-`\addbibresource` diagnostic. Needs Biber; a run without it skips and
says so.

### Documented templates are compiled

A documented template is a promise that the code in it runs. Every complete
document in the manual's "Complete examples" chapter needs a matching
`tests/smoke/manual-example-*.tex`, and `tests/lint/run-manual-examples.sh`
fails when one is missing, orphaned, or has drifted from the published text.

## The lints

`make lint` — `tests/lint/run.sh` plus ten sibling scripts, all in one
sub-second slot. Every one reads text and needs no TeX, which is why CI runs
them on a bare runner. `tests/lint/fixtures/` holds each lint's own self-test
fixtures and is canonical for that set; they are lint input, never compiled, and
not part of the Work.

### Option lint

`tests/lint/run.sh` — every choice-valued public option must pair a
`\msg_new:nnnn { <module> } { unknown-<key> }` with a `<key> / unknown .code:n`
sub-key in the same `\keys_define:nn` block and file. LaTeX enforces neither, so
omitting the sub-key degrades the error silently. `.choices:nn` is the only
supported way to declare such an option, because a hand-rolled `\str_case:nnF`
list is invisible to this lint.

### Version-declaration lint

`tests/lint/run-version-declarations.sh` — every file of the Work declares
itself once, and no baseline records a version, so a bump missing one file
passes every suite. Five checks over `manifest.txt` and the root sources:
existence, parseable triples, identical `{date} {version}` pairs, declared name
equal to basename, and the same file set on both sides.

### Fixture-selection lint

`tests/lint/run-fixture-filter.sh` — asserts each runner's `--list-units` covers
its `--list` exactly and that the `Makefile` can reach the `--jobs` path. A
runner whose fan-out dispatched a subset would report a clean run of something
other than the suite.

### AGENTS.md reference lint

`tests/lint/run-agents-references.sh` — every section name `AGENTS.md` quotes in
"Build and test" resolves to a real heading here or in `CONTRIBUTING.md`, and
every `###` of `CONTRIBUTING.md` "Local builds" is named there. Treats every
quoted string in that section as a section name.

### Markdown anchor lint

`tests/lint/run-markdown-anchors.sh` — every `file.md#anchor` link in the tree
resolves to a real heading.

### Manual-name lint

`tests/lint/run-manual-names.sh` — every public name the Work declares is
documented in the manual, and every name the manual documents exists. Private
`\__cdossier_` names must not appear. `tests/lint/manual-undocumented.txt` is
the declared-exception list and its ratchet.

### Token-value lint

`tests/lint/run-token-values.sh` — the calibrated values documented in
`docs/ARCHITECTURE.md` and the manual's `fontsize` table match what the source
declares. A stale number typesets and reads as authoritative.

### CTAN packaging lint

`make ctan-lint` — `tests/lint/run-ctan-config.sh` loads `build.lua` under
`texlua` and checks its packaging configuration against `tests/lint/ctan-config.lua`.
A Work file no `sourcefiles` glob matches, or a list naming something gone,
costs the archive a file and costs `l3build ctan` no error. It is its own
`CHECK_TARGETS` member rather than a `lint` script because it needs `texlua`.

### Text-guard lint

`tests/lint/run-text-guards.sh` — the extracted-text guards in `tests/lib/text.sh`
answer three states, not two, so an unperformable check reports as unperformable
rather than as absent text.

### Shell-harness lint

`tests/lint/run-shellcheck.sh` — shellcheck at `-S warning` over every runner
and helper in `tests/`.

## Visual review targets

Evidence for a human, not gates. Every target writes under the gitignored
`build/`; record the result in the pull request and never commit the artifacts.
None carries a baseline or belongs to `make check`.

| Target | Renders | Output |
| --- | --- | --- |
| `make review-page-two` | page two of five families, long-name variants, and every statement type | `build/page-two-review/` |
| `make review-matrix` | `{normal,narrow}` × `{10,11,12pt}` across four classes, 24 PDFs | `build/size-margin-matrix/` |
| `make review-entrymeta-muted` | `{column,inline}` × `{italic,gray,both,plain}`, 16 PDFs | `build/entrymeta-muted-matrix/` |
| `make review-link-decoration` | the print/screen link-decoration pair | `build/link-decoration-review/` |
| `make review-linebreak` | a line-breaking parameter swept over both corpora | `build/linebreak-sweep/` |
| `make review-pagefill` | page fill and the atom forcing each break | `build/pagefill-review/` |
| `make review-spacing` | structural and visible gap at every boundary | `build/spacing-review/` |

Each renderer under `tests/layout/` — `render-page-two.sh`,
`render-size-margin-matrix.sh`, `render-entrymeta-muted-matrix.sh`,
`render-link-decoration.sh`, `report-pagefill.sh`, `sweep-linebreak.sh`, and
`sweep-linebreak-parallel.sh` — carries its own header comment describing what
to look at and how to read its output. `tests/spacing/` holds the spacing
report's probe and drivers.

The page-fill floor is the one part of this that *is* asserted: `make layout`
enforces it, a fixture below it declares `% PAGEFILLFLOOR: <pct>` at the fixture,
and a declaration that is no longer needed fails the run. It is a ratchet
against the accepted corpus, not a fill policy.
