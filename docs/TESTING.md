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
- unsupported-engine error;
- every option's accepted and rejected values, including the error naming the
  accepted values, and rejection reported exactly once;
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
[`ATS-EXTRACTION.md`](ATS-EXTRACTION.md) section 7.1.

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

The `lint` target runs a third script in the same slot:

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

The `lint` target runs two more scripts in the same slot:

```bash
tests/lint/run-text-guards.sh
tests/check-parallel.sh --self-test
```

Both are committed negative controls, and both belong in this slot because they
compile nothing and need neither TeX nor biber. What the second asserts is in
"The parallel run" below; the first is the section immediately following.

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
extraction could not be performed. A caller must treat `2` as a failure of its
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

Its last control is a ratchet: no `... | grep -q` guard may reappear in a runner
or a shared library. It is scoped to the shape rather than to a list of known
sites, so a *new* runner with the old spelling is caught too. The one exemption
is the control script itself, which must hold the old spelling in order to
demonstrate that it fails.

### The parallel run

`make check` runs its eleven targets four at a time rather than one after
another, and `make check-serial` is the same eleven singly. `CONTRIBUTING.md`
"The gate, and the serial path" is canonical for how to invoke either; this
section is about what the thing actually does, what it costs, and what it is
worth.

The parallel path was opt-in when it arrived in #378 and became the gate in
#399. The argument for keeping the gate serial had been that `check` is the
CI-aligned entry point — but `.github/workflows/build.yml` runs sixteen jobs on
sixteen runners with no `needs:` anywhere, so CI's execution model is fully
concurrent and fully isolated, and local serial `check` was the one execution
model nothing else in the project used. What "CI-aligned" buys is the same
target set and the same commands, and both paths still dispatch
`$(CHECK_TARGETS)` through the same `make <target>` invocations. Neither
property depends on scheduling.

That is the argument for allowing it. What makes it *safe* are the properties
and proofs below, and they are the reason a scheduled run is permitted to be the
thing a push happens behind — a gate that reports green without having done the
work would be worse than a slow one.

#### How it works

The unit of parallelism is the **target**, not the fixture and not the compile.
`tests/check-parallel.sh` asks the `Makefile` which targets `check` runs, then
dispatches each as its own `make <target>`, four at a time by default:

```text
make check-targets  ->  lint regression extract-test smoke layout
                        bibliography-test links metadata annotations
                        tagging examples
```

Nothing about how a suite decides anything changes. Every verdict is still made
by the suite that made it serially; only how many of them are in flight at once
is different. Three properties make that safe to believe:

- **One target list.** Both paths expand the same `CHECK_TARGETS` variable, and
  `make lint` compares what each of them would dispatch. A hand-maintained
  second copy is how the `annotations` suite once dropped out of a run that was
  then reported clean.
- **Ordered replay.** Each worker's stdout and stderr is captured to
  `build/check-parallel/NN-<target>.log` and replayed in the `Makefile`'s order
  after the run, so "which suite failed" is answerable from the transcript. This
  is one of the two reasons it is not `make -j check`: macOS ships GNU make
  3.81, which has no `--output-sync`, so eleven suites would interleave line by
  line. The other is that `-j` would also fan out *inside* `examples`, whose six
  sub-targets share one `latexmk` output directory — a collision this driver
  does not have, because it dispatches `examples` whole.
- **Accounting.** Every dispatched target must leave a result file, and the run
  fails when the count of results is not the count dispatched, naming the ones
  that produced none. Concurrency adds a failure no suite can report on itself:
  a worker that dies before its suite ever ran leaves no failure behind, only an
  absence, and an absence reads exactly like a clean run unless something is
  counting.

Two tool caches then have to be prepared before anything fans out, because a
cache that several processes build at once is a cache built wrong — and the two
need opposite treatment:

- **luaotfload's font cache is warmed.** One small LuaLaTeX build before
  dispatch, required to prove it typeset real glyphs. Where the cache is
  unwritable, `fontspec` falls back to `nullfont`, every document typesets
  empty, and every suite passes having measured nothing.
- **biber's cache is isolated, because it cannot be warmed.** Issue #392
  measured why: biber re-unpacks its native binary into that cache on *every*
  invocation, not the first — the extracted file's inode changes on each run —
  so two invocations sharing one cache truncate each other's binary. Six
  concurrent invocations failed against a fully warm shared cache exactly as
  against a cold one; six with a private `PAR_TMPDIR` each failed zero times.
  Each worker therefore gets its own, and one probe extraction before dispatch
  proves biber can unpack here at all.

`--self-test` is the committed control for all of that, driven over synthetic
workers and synthetic logs so it needs no TeX and no biber: a clean batch must
pass and account for every member; a batch with one failing member must fail,
name it, and replay its output; a batch with one result file removed — the state
a killed worker leaves — must fail as an accounting failure rather than as two
passes and a shrug; three workers must report three *distinct* biber caches,
since an isolation that quietly stopped being applied would restore a failure
that reads as a flaky bibliography fixture; and the extraction verdict must
refuse a failure that still exited 0, because the status is not the proof, the
log is. It also asserts that every dispatched name is `.PHONY`, since a
dispatched name that is not `.PHONY` would make `make <target>` a no-op that
exits 0. The font-cache proof is the one part not exercised here — it needs TeX,
so every real run exercises it instead.

Three further controls guard the target list itself, and #399 is why there are
three rather than one. Until then a single grep asserted that `check`'s
prerequisite list was literally `$(CHECK_TARGETS)`. Making `check` a recipe left
that grep with nothing to say about the gate — it could only be pointed at
`check-serial` — so the obvious move, retargeting it, would have quietly stopped
covering the target that matters. Each control was therefore run against a
Makefile broken in the way it claims to catch:

| Divergence introduced | `check-serial` grep | gate grep | list comparison |
|---|---|---|---|
| `check-targets` prints a hand-written list, dropping `annotations` | ok | ok | **FAIL** |
| `check` stops dispatching through the driver | ok | **FAIL** | ok |
| `check-serial`'s prerequisites become a copy that still matches | **FAIL** | ok | ok |

The diagonal is the point: no control is redundant. The first row is the
historical failure this whole arrangement exists to prevent — a suite silently
absent from a run that is then reported clean — and only the list comparison
catches it, because it is the only one comparing *what each path would dispatch*
rather than how either is spelled. It reads the serial list out of `make -p`'s
expanded rule database and the parallel one from `make check-targets`, the exact
command the driver runs, so it fails for any way the two disagree rather than
for the spellings someone anticipated. The two greps each catch a row it cannot
see in turn, which is why the one #399 expected to become vestigial was kept.

#### What it is worth, and what it costs

The calibration sweep, measured on the maintainer's machine 2026-08-13 with
`make clean` before every run so none inherited an up-to-date `examples`:

| | Wall time | Result |
|---|---|---|
| `make check-serial` | 439 s | green |
| `make check JOBS=2` | 285 s | green |
| **`make check JOBS=4`** (the default) | **211 s** | **green** |
| `make check JOBS=8` | 168–201 s | **4 red in 8 runs** |

That sweep is what settled the default at 4. It was confirmed at the default
when #399 landed, by five consecutive clean-tree runs on the branch: **211, 225,
247, 248, and 249 s, all green**, against `make check-serial` at **431 s** in
the same session. So the speedup is **roughly 1.8×–2.0×**, saving about three
minutes — and note the spread, which is the honest reading: a single 211 s run
is the fast end of a range, not the figure to quote. Wall time here moves with
whatever else the machine is doing.

`JOBS=8` is a further 20% and is not the default, because it fails about half
the time: every one of those failures is a text-extraction assertion against a
document that is provably correct — a guard that reports present text as missing
under load (#398) — so the ceiling is an open defect elsewhere rather than a
property of the machine. The default carries that bound, and the honest form of
the claim is not "a parallel gate is trustworthy" but **"a parallel gate is
trustworthy at 4 and is not at 8"**. If a `JOBS=4` run is ever red for the #398
reason, this arrangement should be reconsidered rather than retried.

Four honest bounds on the speedup itself:

1. **The ceiling is structural, not a matter of more workers.** Parallel wall
   time is the longest single target plus contention, not the sum divided by
   `JOBS`. `smoke` (124 s), `tagging` (116 s), and `layout` (114 s) dominate,
   while `lint` (2 s), `annotations` (5 s), and `metadata` (8 s) are finished
   before the long ones are a third done.

   How much more than four workers buys was measured on 2026-08-13, when #390
   needed to know whether cheaper scheduling would do its job for it: `JOBS=8`
   ran in **157 s** against `JOBS=4`'s 206 s, a further 24%, both from a clean
   tree so that neither run inherited an up-to-date `examples`. The reason is
   dispatch order, not core count — the eleven targets are dispatched in
   `Makefile` order and `tagging`, the third-longest, sits tenth, so at four
   slots it cannot start until t≈85 s and cannot finish before t≈204 s. That
   models the measured 206 s almost exactly. At eight slots every target starts
   at once and the makespan collapses to the longest one.

   So the target-level floor is the longest single target, and only fanning out
   *inside* it goes lower. That is what the next section does.
2. **It is the smallest of the four costs of a change.** Reading the canonical
   sources, following the procedure, and late rework each cost more than compute
   does; those are addressed by the reading map, the batched metadata path, and
   suite scoping respectively. This saves four minutes **once per branch**, not
   once per edit — the development loop should be using `FIXTURE=`/`TEST=`
   scoping, which takes the full layout suite from 95.1 s to 1.8 s.
3. **CI gains nothing from it.** `.github/workflows/build.yml` already runs one
   suite per job across roughly sixteen jobs. This is a local convenience only,
   and #399 changed no CI file.
4. **The saving only counts because it lands on the gate.** #378 and #390 were
   both justified by making a change cheaper to verify, and both left the gate
   serial — so the saving landed on a run made *in addition to* the one pushed
   behind, which is no saving for anyone who has to run the gate anyway. Moving
   it onto `check` is what collects the debt those two issues ran up, and is
   why the dispatch order below still matters.

Dispatch order was the other candidate for that 50 s and was rejected under
#399. Sorting longest-first models ~158 s at `JOBS=4`, but the replay follows
dispatch order, so sorting for speed also sorts the transcript — and "which
suite failed is answerable in `Makefile` order" is one of the two reasons this
is not `make -j`. It would also push `lint` from first to eleventh, and pair
`bibliography-test` with `examples`, two biber targets that never currently
overlap. The queue only exists because there are fewer slots than targets;
removing it means `JOBS≥11`, which #398 blocks.

Against that, the costs:

- **Disk.** Each biber-using worker's private cache is about 208 MB of unpacked
  Perl runtime, and three or four of them are made over a run. Each is freed as
  its worker finishes rather than at the end, so the peak follows how much
  actually overlaps rather than the whole run: sampled every five seconds at
  `JOBS=4`, it reached **416 MB** — two caches at once — against the ~830 MB the
  same run would hold if they lived to the end. The tree goes entirely when the
  run ends, and with `make clean`.

  That cost is the price of the only isolation biber allows, and the two cheaper
  alternatives were measured and rejected under #392: a shared cache made
  read-only after warming does not work, because biber cannot write it, falls
  back to the *default* shared cache, and races there; and giving each worker
  its own `PAR_TMPDIR` while sharing the modules through `PAR_GLOBAL_TMPDIR`
  does not work either, because the global setting overrides the per-process one
  and re-shares everything — the per-worker directories stayed empty at 0 B and
  all four invocations raced.

  Where that 208 MB goes, since the number is surprising: `inc/` (the bundled
  Perl module tree) is 124 MB, `thin/biber` (the arm64 slice `lipo` extracts
  from the 79 MB universal binary on every run) is 41 MB, and ICU's Unicode
  collation data is 31 MB. biber is a PAR-packed self-contained application
  rather than a script — Perl cannot `require` a module, and the loader cannot
  `dlopen` a library, from inside a packed archive — so unpacking to a real
  filesystem path is how it runs at all, not an optimisation.
- **Machinery.** Two cache workarounds, an accounting assertion, and eight
  committed controls exist so that a scheduled run cannot quietly report a clean
  one. That is the right ratio for this repository, whose characteristic failure
  is a check that passes without doing the work — and it is the whole of what
  earns this path the gate. `make check-serial` is the standing answer to a
  parallel result that looks wrong, since it removes scheduling as a variable
  without removing any assertion.

Parallelising *across targets* is ordinary build engineering rather than
anything LaTeX-specific, and it is worth knowing that the LaTeX toolchain makes
it harder than most: `l3build` has no parallel mode at all, and the two failures
above are both global-state hazards — a per-user font cache and a per-user
unpacking cache — of a kind a single-user, single-run toolchain accumulates
freely.

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

- inspect the affected PDFs, including rendered pages and any clipping;
- compare them with the current baseline;
- check page breaks;
- check long links and contact lines;
- check print and grayscale behavior;
- attach or link a preview in the pull request.
