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
