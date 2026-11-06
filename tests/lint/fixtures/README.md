# Option-lint fixtures

These files pin the verdicts of `tests/lint/run.sh` (issue #233). One holds a
complete choice-valued option; four each omit or misdirect exactly one half of
the pairing the lint exists to enforce. The rest pin the checks issue #266 added
for the shared-option generators: a generator template, calls to it, and
owning packages to compare it with.

They are lint input, not LaTeX: they are never compiled, are not part of the
Work, and are named `lintfixture-*` rather than `careerdossier-*` so that
`build.lua`'s `careerdossier-*.sty` source glob cannot pick them up.

| Fixture | Expected verdict |
| --- | --- |
| `lintfixture-complete.sty` | `OK` |
| `lintfixture-no-handler.sty` | `MISSING HANDLER` |
| `lintfixture-no-message.sty` | `MISSING MESSAGE` |
| `lintfixture-wrong-module.sty` | `WRONG MODULE` |
| `lintfixture-wrong-target.sty` | `WRONG TARGET` |
| `lintfixture-generator.sty` | `OK`; the generator the fixtures below call and compare against |
| `lintfixture-template-wrong-module.sty` | `WRONG MODULE` |
| `lintfixture-call-ok.sty` | `OK` |
| `lintfixture-call-wrong-module.sty` | `WRONG MODULE` |
| `lintfixture-call-wrong-path.sty` | `WRONG PATH` |
| `lintfixture-call-unknown.sty` | `UNKNOWN GENERATOR` |
| `lintfixture-call-duplicate.sty` | `DUPLICATE` |
| `lintfixture-parity-ok.sty` | `PARITY OK` |
| `lintfixture-parity-drift.sty` | `VALUE LISTS DIFFER` |

Each of the four defective option fixtures keeps a second, complete option
alongside the defective one, so the lint has to single out the right key rather
than condemn the whole file.

The `version/` subdirectory holds a separate set, for
`tests/lint/run-version-declarations.sh` (issue #258); see its own `README.md`.
Those are whole trees rather than single files, because that lint's subject is a
manifest and the sources it lists taken together.

## Manual-name fixtures

`manualfixture-*.tex` pin the verdicts of
`tests/lint/run-manual-names.sh` (issues #263, #468). Like the files above they
are lint input and are never compiled.

| Fixture | Driven check | Expected verdict |
| --- | --- | --- |
| `manualfixture-ok.tex` | all | `OK` |
| `manualfixture-private.tex` | private names | `PRIVATE NAME` |
| `manualfixture-unknown.tex` | public names | `UNKNOWN NAME` |
| `manualfixture-nonames.tex` | public names | `NO NAMES FOUND` |
| `manualfixture-version.tex` | declared release | `VERSION MISMATCH` |
| `manualfixture-documented.tex` | documented names | varies with the backlog below |

`manualfixture-ok.tex` declares no release of its own. Its version and date are
the placeholders `@WORK-VERSION@` and `@WORK-DATE@`, which the self-check
replaces with the Work's declaration before the release check reads it (issue
#523), so a release bump needs no edit here. `manualfixture-version.tex` keeps
its fixed `0.7.0` on purpose: it must disagree with the Work.

Check (4) — every public name the Work defines is documented — needs two inputs
rather than one, so its fixtures come in a set:

| Fixture | Role |
| --- | --- |
| `manual-defined-names.txt` | stands in for the Work's defined names, so a fixture manual need not document all 84 real ones |
| `manualfixture-alldocumented.tex` | documents all three fixture names → `OK` |
| `manualfixture-documented.tex` | documents two of the three → `UNDOCUMENTED NAME` |

Until #243 the check also read a backlog of names accepted as undocumented, and
four `backlog-*.txt` fixtures drove its verdicts; the backlog emptied and both
went with it.

`manualfixture-documented.tex` deliberately does not name the undocumented
command even in a TeX comment: the lint's manual-side collector reads comments
too, so naming it there would make it look documented and the
`UNDOCUMENTED NAME` fixture would silently stop testing anything.

## Token-value fixtures

`tokenfixture-*` pin the verdicts of `tests/lint/run-token-values.sh` (issue
#487), which compares the calibrated numbers `docs/ARCHITECTURE.md` and the
manual state against the ones `careerdossier-tokens.sty` declares, and the
token table in `docs/TESTING.md` against the spacing tokens it allocates (issue
#590). Like the files above they are lint input and are never compiled.

That lint's fixtures come in two halves, because it compares two files rather
than reading one. The source half is held fixed and the document half varies:

| Fixture | Role |
| --- | --- |
| `tokenfixture-source.sty` | the source side for every case below — one token of each declared shape |
| `tokenfixture-nosource.sty` | a source that declares nothing the lint parses → `NO SOURCE VALUES` |
| `tokenfixture-noskip.sty` | a source that sets ratios but allocates no token with `\skip_new:N` → `NO SPACING TOKENS` |

| Fixture | Driven check | Expected verdict |
| --- | --- | --- |
| `tokenfixture-arch-ok.md` | all three tables | `OK` |
| `tokenfixture-arch-ratio.md` | vertical rhythm | `RATIO MISMATCH` |
| `tokenfixture-arch-value.md` | vertical rhythm | `VALUE MISMATCH` |
| `tokenfixture-arch-dropped.md` | vertical rhythm | `MISSING ROW` |
| `tokenfixture-arch-extra.md` | vertical rhythm | `UNKNOWN TOKEN` |
| `tokenfixture-arch-scale.md` | type scale | `SCALE MISMATCH` |
| `tokenfixture-arch-derived.md` | derived metrics | `FACTOR MISMATCH` |
| `tokenfixture-arch-notable.md` | all three tables | `NO TABLE FOUND` |
| `tokenfixture-manual-ok.tex` | the manual's `fontsize` table | `OK` |
| `tokenfixture-manual-value.tex` | the manual's `fontsize` table | `MANUAL VALUE MISMATCH` |
| `tokenfixture-manual-unknown.tex` | the manual's `fontsize` table | `UNKNOWN ROLE` |
| `tokenfixture-manual-notable.tex` | the manual's `fontsize` table | `NO TABLE FOUND` |
| `tokenfixture-testing-ok.md` | the `docs/TESTING.md` token table | `OK` |
| `tokenfixture-testing-dropped.md` | the `docs/TESTING.md` token table | `MISSING ROW` |
| `tokenfixture-testing-extra.md` | the `docs/TESTING.md` token table | `UNKNOWN TOKEN` |
| `tokenfixture-testing-notable.md` | the `docs/TESTING.md` token table | `NO TABLE FOUND` |

`tokenfixture-source.sty` declares its two spacing tokens under names the real
`careerdossier-tokens.sty` does not use, so a check that had quietly fallen
back to reading the real source would report `UNKNOWN TOKEN` on the `OK`
fixture rather than pass it. The three
`-notable` fixtures carry near-miss headings rather than empty files, because
that is how the failure actually arrives — a heading renamed in a
documentation tidy-up, leaving a parser that finds nothing and a lint that
reports no mismatches.

## Prose section pointer fixtures

`pointerfixture-*.md` pin the verdicts of
`tests/lint/run-prose-pointers.sh` (issue #559). They resolve against each
other, never against the real tree, and `pointerfixture-target.md` is the only
one any of them cites.

| Fixture | Expected verdict |
| --- | --- |
| `pointerfixture-resolvable.md` | `OK` |
| `pointerfixture-bad-file.md` | `no such file` |
| `pointerfixture-bad-heading.md` | `no heading of that name` |
| `pointerfixture-wrapped.md` | `OK` |
| `pointerfixture-sibling.md` | `OK` |
| `pointerfixture-fenced.md` | `OK` |
| `pointerfixture-second-name.md` | `no heading of that name` |
| `pointerfixture-in-form.md` | `OK` |
| `pointerfixture-in-bad-heading.md` | `no heading of that name` |
| `pointerfixture-old-parenthetical.md` | `write this parenthetical citation as` |
| `pointerfixture-old-section.md` | `write this section citation as` |
| `pointerfixture-old-bare-quoted.md` | `write this bare-quoted citation as` |

The first seven are written in the template form (#583). `-in-form` pins the
templates' other form, a name before `in` and a path, and a bare path without
backticks; `-in-bad-heading` pins a missing heading in that form. The three
`-old-` fixtures each resolve, and pin the rejection of a form the convention
retired.

Four of the first seven pin an `OK`, which is unusual for a fixture set here and
is the point: this lint's plausible failure is reporting a present pointer as
broken, not missing a broken one. `-wrapped` carries a pointer split across a
newline and a section name split across one, because at 80 columns that is how
most of them are written. `-sibling` cites a file that exists only beside it and
not at the repository root, so a lint that resolved only root-relative paths
would fail it. `-fenced` puts an unresolvable pointer inside a fence, where it
is illustration rather than a pointer.

`-second-name.md` is the one that pins a resolution rather than a pointer: its
single citation carries two names, the first valid and the second not. The
hand-written checker that motivated #559 read only the first name of each
citation and reported the tree clean, so this fixture fails any
reimplementation that regresses to counting pointers instead of resolutions.

## Layout fixtures

`layoutfixture-*.txt` pin the verdicts of `tests/lint/run-agents-layout.sh`
(issue #584). Each one is a "Layout" section compared against the same
`layoutfixture-manifest.txt`, whose second group opens with a prose paragraph
and whose "Not distributed" group holds a line shaped like an entry: neither
may be read as one. The files are `.txt`, not `.md`, so the Markdown lints do
not read them as documents.

| Fixture | Expected verdict |
| --- | --- |
| `layoutfixture-ok.txt` | `OK` |
| `layoutfixture-missing.txt` | `missing from "Layout": LICENSE` |
| `layoutfixture-extra.txt` | `not in manifest.txt: CLAUDE.md` |
| `layoutfixture-wrong-group.txt` | `missing from "Layout": README.md, under "Distributed with the Work"` |
| `layoutfixture-order.txt` | `same entries in another order` |
| `layoutfixture-empty.txt` | `no entries parsed` |

## Commit-message hook fixtures

`commitfixture-*.txt` pin the verdicts of `tests/lint/run-commit-msg-hook.sh`
(issue #573). Each is a whole commit message, given to `.githooks/commit-msg`
as git would give it.

| Fixture | Expected verdict |
| --- | --- |
| `commitfixture-accepted.txt` | accepted |
| `commitfixture-no-trailers.txt` | accepted |
| `commitfixture-free-role.txt` | rejected |
| `commitfixture-ai-coauthor.txt` | rejected |

`-free-role.txt` is the case that made the hook necessary: both AI-assisted
commits on `main` before #573 gave a sentence as the `Assisted-by:` role.

## Docs-only classifier fixtures

`docsonlyfixture-*.txt` pin the `--paths` verdicts of `tests/lib/docs-only.sh`,
driven by `tests/lint/run-docs-only.sh` (issue #603). Each is a path list, one
path per line, as `git diff --no-renames --name-only` prints it. The expected
verdicts follow the path list `CONTRIBUTING.md`, "CI expectations", documents.

| Fixture | Expected verdict |
| --- | --- |
| `docsonlyfixture-docs.txt` | docs-only: one path under each entry of the list |
| `docsonlyfixture-sty.txt` | full: a docs edit and a `.sty` |
| `docsonlyfixture-manual.txt` | full: `doc/careerdossier.tex`, which the `manual` job builds |
| `docsonlyfixture-makefile.txt` | full: `Makefile` |
| `docsonlyfixture-workflow.txt` | full: `.github/workflows/build.yml`, beside `.github/ISSUE_TEMPLATE/` |
| `docsonlyfixture-rename.txt` | full: a `.sty` renamed into `docs/`, listed as both sides |
| `docsonlyfixture-classifier.txt` | full: `tests/lib/docs-only.sh` itself |
| `docsonlyfixture-empty.txt` | full: an empty change |

Each "full" list but the last keeps a docs path beside the one that disqualifies
it, so the classifier has to single out that path rather than reject the list
whole. The working-tree cases build their repository at run time and have no
fixture file.

## Testphase-key fixtures

These pin the verdicts of `tests/lint/run-testphase-keys.sh` (issue #478), which
reports a LaTeX Lab testphase key named outside `careerdossier-components.sty`.
Like the files above they are lint input and are never compiled.

| Fixture | Verdict |
| --- | --- |
| `testphasefixture-code.cls` | a key set in code → reported |
| `testphasefixture-comment.cls` | a key named only in a comment → reported, because comments count |
| `testphasefixture-clean.cls` | only the stable tagpdf API → not reported |

## Fixture-header fixtures

These pin the verdicts of `tests/lint/run-fixture-headers.sh` (issue #534).
Like the files above they are lint input and are never compiled, and they sit
outside the lint's own scope.

| Fixture | Backlog | Verdict |
| --- | --- | --- |
| `headerfixture-named.tex` | `headerbacklog-empty.txt` | `OK` |
| `headerfixture-unnamed.tex` | `headerbacklog-empty.txt` | `UNNAMED FIXTURE` |
| `headerfixture-unnamed.tex` | `headerbacklog-ok.txt` | `OK`: declared, with a reason |
| `headerfixture-unnamed.tex` | `headerbacklog-noreason.txt` | `NO REASON` |
| `headerfixture-unnamed.tex` | `headerbacklog-stale.txt` | `STALE ENTRY`: it also lists a file that does not exist |
| `headerfixture-named.tex` | `headerbacklog-fixed.txt` | `FIXED, DROP THE ENTRY` |
| `headerfixture-unnamed.tex`, `headerfixture-unnamed-2.tex` | `headerbacklog-over.txt` | `OVER THE FROZEN SIZE`: two entries, frozen at one |
