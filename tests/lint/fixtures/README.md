# Option-lint fixtures

These files pin the verdicts of `tests/lint/run.sh` (issue #233). One holds a
complete choice-valued option; the other four each omit or misdirect exactly one
half of the pairing the lint exists to enforce.

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

Each fixture keeps a second, complete option alongside the defective one, so the
lint has to single out the right key rather than condemn the whole file.

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

Check (4) — every public name the Work defines is documented — needs two inputs
rather than one, so its fixtures come in a set:

| Fixture | Role |
| --- | --- |
| `manual-defined-names.txt` | stands in for the Work's defined names, so a fixture manual need not document all 84 real ones |
| `backlog-ok.txt` | the undocumented name is declared, with a reason → `OK` |
| `backlog-empty.txt` | it is not declared at all → `UNDOCUMENTED NAME` |
| `backlog-noreason.txt` | declared with no reason → `NO REASON` |
| `backlog-stale.txt` | declares a name the fixture Work does not define → `STALE ENTRY` |

`manualfixture-documented.tex` deliberately does not name the undocumented
command even in a TeX comment: the lint's manual-side collector reads comments
too, so naming it there would make it look documented and the
`UNDOCUMENTED NAME` fixture would silently stop testing anything.

## Token-value fixtures

`tokenfixture-*` pin the verdicts of `tests/lint/run-token-values.sh` (issue
#487), which compares the calibrated numbers `docs/ARCHITECTURE.md` and the
manual state against the ones `careerdossier-tokens.sty` declares. Like the
files above they are lint input and are never compiled.

That lint's fixtures come in two halves, because it compares two files rather
than reading one. The source half is held fixed and the document half varies:

| Fixture | Role |
| --- | --- |
| `tokenfixture-source.sty` | the source side for every case below — one token of each declared shape |
| `tokenfixture-nosource.sty` | a source that declares nothing the lint parses → `NO SOURCE VALUES` |

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

`tokenfixture-source.sty` declares its two spacing ratios under names the real
`careerdossier-tokens.sty` does not use, so a check that had quietly fallen
back to reading the real source would report `UNKNOWN TOKEN` on the `OK`
fixture rather than pass it. The two
`-notable` fixtures carry near-miss headings rather than empty files, because
that is how the failure actually arrives — a heading renamed in a
documentation tidy-up, leaving a parser that finds nothing and a lint that
reports no mismatches.
