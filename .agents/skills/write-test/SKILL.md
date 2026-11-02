---
name: write-test
description: Write or change a test under tests/: an l3build regression test, a smoke, layout, extraction, links, metadata, annotations, or tagging fixture, or a lint. Use when a change needs its test, or when adding or changing a baseline; not for probes that are never committed.
---

# Write a test

## Before you write

1. Pick the suite from what the module owns: `docs/TESTING.md`, "Match the
   test to the module". Observable logic takes an `l3build` regression test
   in `tests/regression/`; extend that module's existing `.lvt` before adding
   a new one. Layout behaviour takes smoke, layout, extraction, or tagging
   fixtures as well, never instead. `docs/TESTING.md`, "The suites", says
   what each suite asserts, and `docs/TESTING.md`, "Coverage expectations",
   which families and cases a change must cover.
2. Start from the test-case list in the approved acceptance criteria: for
   each case, the behaviour, the input or fixture, and the source of the
   expected value. With no list, propose one; you may propose criteria, not
   decide them (`AGENTS.md`, "How to work here"). Do not add cases the list
   lacks without saying so.
3. Produce the red run before the fix, as `docs/TESTING.md`, "Test-driven
   where practical; test-as-you-go always", sets out. A defect that does not
   crash is no exception: a value that differs is what a `.tlg` compares. Run
   the new test through its `Makefile` target, never a hand-written engine
   call, in one of two forms:
   - Before the fix is in the tree: `make regression TEST=<name>`, or
     `make smoke FIXTURE=<pattern>`, and the same `FIXTURE=` form for
     `layout`, `extract-test`, and `tagging`. `links`, `metadata`, and
     `annotations` take no selector; run the whole target.
   - Once the fix is in the tree: run the new test against `main` in a
     detached worktree in a scratch directory outside the repository, so
     nothing in yours is reverted. `git worktree` writes to `.git`, so run
     its two commands with the sandbox off.

     ```bash
     git worktree add --detach "$SCRATCH/prefix" main
     cp tests/regression/<name>.lvt tests/regression/<name>.tlg \
       "$SCRATCH/prefix/tests/regression/"
     make -C "$SCRATCH/prefix" regression TEST=<name>   # expect a non-zero exit
     git worktree remove --force "$SCRATCH/prefix"
     ```

     For another suite, copy the fixture and every baseline it has into the
     same path in the worktree, and run that suite's target there.

   In the pull request, give how many cases failed, their names, and one
   failing value pair, expected against got, quoted from the `.diff` or the
   runner's output. If the failure cannot be shown safely, for example
   because the class under test does not exist yet, say why instead: the
   second box of `.github/pull_request_template.md`, "Checks run", asks for
   one or the other.

## Each test

4. Open the file with a comment that names it, the issue, and the claim: the
   statement that is false if the test fails, as
   `tests/regression/resume-entry-edges.lvt` and
   `tests/smoke/cv-bad-medium.tex` do. A comment that only restates the code
   states no claim.
5. Give an `.lvt` the structure the `l3build` manual (CTAN,
   `macros/latex/contrib/l3build/l3build.pdf`) sets out in "2 Writing test
   files": `\input{regression-test}` first, `\START` where the comparison
   begins, and one `\TEST{<title>}{...}` per claim, so each claim has its own
   numbered block in the `.tlg` and fails on its own. Put `\OMIT`…`\TIMO`
   around log output that varies for reasons the test does not assert, such
   as register numbers from an allocation. Mittelbach, Robertson, and the
   LaTeX3 team, "l3build: A modern Lua test suite for TeX programming",
   TUGboat 35:3 (2014), explains why in "4.3 The structure of test files",
   and in "3.1 Modes of testing" when to write a value with `\TYPE` and when
   to show a box.
6. Do not hide by hand what `l3build` already removes. The manual's "1.12
   Output normalization" lists it: line numbers, file dates and versions, and
   register numbers in assignment lines, among others. `build.lua` sets
   `stdengine` to `luatex`, so the further cross-engine normalization that
   section describes does not apply, and a `.tlg` here records LuaTeX's log
   as it is.
7. Record what reached the page, not the definition that should put it there:
   `\TYPE` the measured value, such as a `\pagetotal` difference across a
   boundary, rather than a token's value. `docs/TESTING.md`, "Spacing tokens:
   reporting a value is not rendering a gap", gives the case where a printed
   token passed while its gap never rendered, and a new public spacing token
   takes a row in that section's table.
8. Name a fixture for the assertions you mean it to receive; the runners
   select them by name. `*two-page*` takes the layout suite's multi-page
   checks, `*-valid` must compile, `*-bad-*` and `*-missing-*` must fail with
   their diagnostic, and `-ua2` marks the tagging group's PDF/UA-2 member,
   which shares `<group>-body.inc.tex` with `<group>.tex` and
   `<group>-untagged.tex`. A misnamed fixture compiles and asserts less than
   it appears to. An `.inc` or `.inc.tex` body moves every fixture that
   includes it.
9. Take every expected value from one of four sources: documented behaviour,
   a page a person has inspected, an independent implementation, or a
   reproducible computation, such as a documented ratio worked by hand. Name
   it in the commit's `Ground-truth-source:` trailer (`AGENTS.md`,
   "Provenance"). A `.tlg` that `l3build save <name>` wrote is observed
   output; it becomes a baseline only once each value in it is checked
   against one of those sources. When none exists, test a property instead,
   and say so in the header comment: the same input gives the same output,
   extracted text keeps its reading order, a missing field leaves no stray
   separator, tagged and untagged builds break at the same place. A property
   test takes no `Ground-truth-source:` trailer.
10. A new lint under `tests/lint/` carries its own fixtures in
    `tests/lint/fixtures/`, among them a planted violation it must reject, so
    a clean run is told apart from a check that stopped looking.
    `docs/TESTING.md`, "Section-sign lint" and "Commit-message hook lint",
    are two such controls.

## After you write

11. Read the whole new `.tlg` or baseline, or its diff against the previous
    one, before committing it, and confirm every changed line is one you
    meant: `docs/TESTING.md`, "Baselines are load-bearing". Where a `.tlg`
    echoes a value several times, regenerate every line that echoes it. A
    changed baseline needs a person to have inspected the new output, and the
    pull request says so.
12. Never regenerate a baseline to turn a red suite green, and never weaken
    or delete a test to make a suite pass; report the failure instead
    (`AGENTS.md`, "Do not"). The manual's "2.7 Instructions for rebuilding
    test output" warns that `l3build check --show-saves` can bury a real
    failure among spurious ones; do not use it to save more than one test
    you have read.
13. Regenerate extraction and tagging baselines only through the runner's
    `--update`, scoped to the fixture. Each extractor keeps its own baseline,
    because each imposes its own line structure: Poppler `*.expected.txt`,
    Apple PDFKit `*.pdfkit.txt`, and, in the tagging suite, MuPDF
    `*.mupdf.txt`. Never copy one over another. PDFKit baselines regenerate
    only on macOS. The per-PR CI job skips the veraPDF gate a `-ua2` member
    feeds (`docs/TESTING.md`, "Tagged-PDF suite"), and each runner's closing
    summary lists the gates it skipped: report those as not run.
14. Run the focused target first, then the affected suites, every class for
    a shared package, then the gate, `make check`, in the background and
    with the sandbox off. Report each result as it printed, in the boxes of
    `.github/pull_request_template.md`, "Checks run", and as `Checks-run:`
    trailers.

## Example

```tex
% contact-separators.lvt — issue #<n>: a missing phone or website leaves
% no stray separator in the contact line.
%
% Property test: no reference rendering exists, so the claim is that the
% fields present are joined by exactly one separator each, whatever is absent.
\input{regression-test}
\documentclass{careerdossier-resume}
\begin{document}
\START
\TEST{no~phone}{...}
\TEST{no~website}{...}
\TEST{neither}{...}
\end{document}
```

Not: `% Test the contact line.` (it states no claim, so a failure says
nothing about what broke).

A red-run line in the pull request:

```text
make regression TEST=contact-separators at main -> 2 of 3 cases failed
(TEST 1, TEST 3); TEST 1 expected "<name> | <email>",
got "<name> |  | <email>".
```

For a large corpus of worked `.lvt` files, read the LaTeX2e kernel's
`base/testfiles/` in `latex3/latex2e`, where a test named for the issue it
answers, `github-0041.lvt` for example, opens with `\input{test2e}` and
`\START`.
