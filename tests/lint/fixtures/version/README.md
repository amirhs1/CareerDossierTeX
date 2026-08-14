# Version-declaration fixtures

Each subdirectory here is a complete miniature Work — a `manifest.txt` with a
"The Work" section and the sources it lists — and pins one verdict of
`tests/lint/run-version-declarations.sh` (issue #258).

They are lint input, not LaTeX: they are never compiled, are not part of the
Work, and their sources are named `lintfixture-*` rather than `careerdossier-*`
so that `build.lua`'s `careerdossier-*.sty` source glob cannot pick them up.
Their manifests define only themselves; the repository's own `manifest.txt`
remains the one that defines the Work.

| Tree | Expected verdict |
| --- | --- |
| `consistent/` | `OK` |
| `version-mismatch/` | `VERSION MISMATCH` |
| `date-mismatch/` | `DATE MISMATCH` |
| `no-declaration/` | `NO DECLARATION` |
| `unparseable/` | `UNPARSEABLE DECLARATION` |
| `missing-file/` | `MISSING FILE` |
| `not-in-manifest/` | `NOT IN MANIFEST` |

Every tree carries three sources rather than two, and the defective one is
always the third. Two agreeing files and one outlier is what makes the lint
choose a reference pair by frequency rather than by position: with two files a
mismatch is a tie, and either could be reported as the wrong one. Ten files
disagreeing one-to-nine is the shape a missed release bump actually takes, and
the outlier is the file that has to be named.
