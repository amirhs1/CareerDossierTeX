---
name: write-test
description: Write or change a test under tests/: an l3build regression test, a smoke, layout, extraction, links, metadata, annotations, or tagging fixture, or a lint. Use when a change needs its test, or when adding or changing a baseline; not for probes that are never committed.
---

# Write a test

## Before you write

1. Pick the suite from what the module owns: `docs/TESTING.md`, "Match the
   test to the module". Extend the module's existing `.lvt` before adding
   one, and cover what `docs/TESTING.md`, "Coverage expectations", asks of
   the change.
2. Start from the test-case list in the approved acceptance criteria: for
   each case, the behaviour, the input, and the source of the expected value.
   Do not add cases the list lacks without saying so.
3. Show the red run before the fix, even for a defect that does not crash:
   `docs/TESTING.md`, "Test-driven where practical; test-as-you-go always".
   Run the `Makefile` target: `make regression TEST=<name>`, or
   `make smoke FIXTURE=<pattern>` and the same for `layout`, `extract-test`,
   and `tagging`. Once the fix is in your tree, run the new test against
   `main` in a detached worktree instead, with the sandbox off for the two
   `git worktree` commands:

   ```bash
   git worktree add --detach "$SCRATCH/prefix" main
   cp tests/regression/<name>.lvt tests/regression/<name>.tlg \
     "$SCRATCH/prefix/tests/regression/"
   make -C "$SCRATCH/prefix" regression TEST=<name>   # expect a non-zero exit
   git worktree remove --force "$SCRATCH/prefix"
   ```

   For another suite, copy the fixture and its baselines. In the pull
   request, give how many cases failed, their names, and one failing value
   pair, expected against got, or why the failure could not be shown
   (`.github/pull_request_template.md`, "Checks run").

## Each test

4. Open the file with a comment naming the issue and the claim that is false
   if the test fails, as `tests/regression/resume-entry-edges.lvt` does.
5. In an `.lvt`: `\input{regression-test}`, `\START`, one `\TEST` per claim,
   and `\OMIT`…`\TIMO` around log output the test does not assert, such as
   allocation numbers. Sources: the `l3build` manual (CTAN,
   `macros/latex/contrib/l3build/l3build.pdf`), "2 Writing test files" and
   "1.12 Output normalization"; Mittelbach, Robertson, and the LaTeX3 team,
   "l3build: A modern Lua test suite for TeX programming", TUGboat 35:3
   (2014), "3.1 Modes of testing" and "4.3 The structure of test files"; and
   `latex3/latex2e` `base/testfiles/` as a worked corpus.
6. `\TYPE` the measured value, not the token's definition: `docs/TESTING.md`,
   "Spacing tokens: reporting a value is not rendering a gap".
7. Name a fixture for the assertions it should get: `*two-page*`, `*-valid`,
   `*-bad-*`, and `-ua2` select them (`docs/TESTING.md`, "The suites"). A
   misnamed fixture asserts less than it appears to.
8. Take each expected value from documented behaviour, a page a person
   inspected, an independent implementation, or a reproducible computation,
   and name it in the commit's `Ground-truth-source:` trailer (`AGENTS.md`,
   "Provenance"). Output that `l3build save` wrote is not a source. With none
   of the four, test a property, such as the same input giving the same
   output or a missing field leaving no stray separator; say so in the header
   comment, and omit the trailer.
9. A new lint carries a fixture with a planted violation it must reject:
   `docs/TESTING.md`, "Section-sign lint".

## After you write

10. Read the whole new baseline or its diff before committing it, and
    regenerate every line that echoes a changed value: `docs/TESTING.md`,
    "Baselines are load-bearing". Never regenerate a baseline or weaken a
    test to turn a suite green (`AGENTS.md`, "Do not").
11. Regenerate extraction and tagging baselines only with the runner's
    `--update`; each extractor keeps its own, and PDFKit's regenerate only on
    macOS. Report every gate the runner's summary says it skipped, such as
    veraPDF for `-ua2`: `docs/TESTING.md`, "Tagged-PDF suite".
12. Run the focused target, then the affected suites, then `make check` in
    the background with the sandbox off, and report what each printed under
    `.github/pull_request_template.md`, "Checks run".

## Example

```tex
% contact-separators.lvt — issue #<n>: a missing phone or website leaves
% no stray separator in the contact line. Property test: no reference
% rendering exists.
```

Not: `% Test the contact line.` (it states no claim).
