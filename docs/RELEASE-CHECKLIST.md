# CareerDossierTeX release checklist

The per-release gate: what a release has to satisfy before it is tagged, and
what CTAN additionally requires of the uploaded archive at `v0.10.0`. It is the
one file that answers "is this releasable yet"; `docs/ROADMAP.md` owns which
release a change belongs to, and `.agents/skills/release-notes/reference.md`
owns how `CHANGELOG.md` and the GitHub Release notes are written.

The checks below reference [`ATS-EXTRACTION.md`](ATS-EXTRACTION.md) for the
font, extraction, and tagging policy each one asserts, and
[`TESTING.md`](TESTING.md) for the suites that run them.

## CTAN readiness **(planned — v0.10.0)**

CTAN's requirements govern the uploaded archive, not the development repository. As
of July 2026 the core expectations, verified against
[CTAN's upload guidance](https://ctan.org/help/upload-pkg?lang=en), include:

- one `.zip`, `.tar.gz`, or `.tgz` archive;
- a top-level directory named for the package;
- a top-level `README`/`README.txt`/`README.md`, ASCII or UTF-8 (no BOM), in
  English, containing a licence statement and a version identifier;
- PDF documentation together with its source;
- no files that can be generated from other files, except the PDF documentation
  and derived fonts.

The PDF documentation is `careerdossier.pdf`, built by `make manual` from the
committed `doc/careerdossier.tex` (#263). The source is tracked and the PDF is
not, so the archive is what carries both.

Handwritten `.sty`/`.cls` files are source and are included as-is; a `.dtx`/`.ins`
workflow is optional. CTAN in fact discourages *generated* `README` and `.ins`
files because they tend to go stale against their source. There is no need to
migrate to `.dtx`, and the archive is generated from the handwritten source as
it stands.

### Building the archive

```bash
make ctan
```

Configured in `build.lua` under "CTAN packaging" (#264); `make ctan` is the
entry point and `l3build ctan` is what it runs. That command runs the `l3build`
regression suite first and skips the zip stage when it fails, so an archive only
ever exists for a tree that passed — but it does **not** run the shell-driven
suites, so `make check` is still the gate before a release.

It produces `build/distrib/ctan/careerdossier/`, one top-level directory holding
the ten Work files, `README.md`, `LICENSE`, `CHANGELOG.md`, `manifest.txt`, and
`doc/` with the manual's source and the PDF typeset from it. Two artifacts land
outside `build/` because l3build puts them there — `careerdossier-ctan.zip` at
the repository root and `doc/careerdossier.pdf` beside its source. Both are
ignored by `.gitignore`, and `make clean` removes both.

`make ctan-lint` checks the configuration, and `make check` dispatches it on
every run ([`TESTING.md`](TESTING.md#ctan-packaging-lint), "CTAN packaging
lint"). It exists because `l3build ctan` cannot: its file lists are
globs, and a glob matching nothing builds an archive missing that file and exits
0. Extracting and reading the archive is still required before upload — the
lint asserts what was configured, not what was produced.

### TDS packaging

`packtdszip = false`, set explicitly rather than left to l3build's identical
default so that the decision has a value to point at. The package installs as
ten files into `tex/latex/careerdossier/` with no scripts, fonts, or generated
assets to place, so CTAN's installers derive that tree from the archive without
help. `.tds.zip` is optional and, for a package without an elaborate install,
generally unnecessary.

### Name and filename availability

CTAN requires both a free package *name* and filenames unique across TeX Live.
Both were checked; re-run them before upload, because either can be taken by a
package published in between.

| Check | Command or source | Result |
|---|---|---|
| Package name | `ctan.org/pkg/careerdossier` | 404 — free (2026-08-05, re-confirmed 2026-08-17) |
| Package name | `ctan.org/pkg/careerdossiertex` | 404 — free (2026-08-05, re-confirmed 2026-08-17) |
| Index scan | `ctan.org/json/2.0/packages`, 7037 packages, `career`/`dossier` in `key` or `name` | no matches (2026-08-17; 7027 packages, same result, 2026-08-05) |
| Filenames | `kpsewhich careerdossier-*.sty careerdossier-*.cls` from **outside** the repository, TeX Live 2026 | nothing found (2026-08-17) |
| Filenames | `find "$(kpsewhich -var-value TEXMFDIST)" -iname 'careerdossier*'`, and grep of `texlive.tlpdb` | no matches (2026-08-17) |

Nearest neighbours by subject are `curriculum-vitae`, `resumecls`,
`simple-resume-cv`, `moderncv`, `gradstudentresume`, `jsonresume`, and
`pats-resume`; none shares a filename.

Give each probe a control, and prefer a control that is *present*. A 404 and a
failed fetch read alike, and an empty grep is the same shape whether the index
was searched or never downloaded — so the name probe is run against
`ctan.org/pkg/moderncv` (200), the index scan against `moderncv`, `resumecls`,
and `lua-ul` (all found), and `kpsewhich` against `article.cls` and
`moderncv.cls` (both found). Without them "no matches" is not evidence.

Run the `kpsewhich` check from a directory outside this repository. Run inside
it, every name resolves to `./careerdossier-*.sty` — the repository's own copy —
and the check reports a collision that does not exist.

### The Overleaf route

Overleaf has no personal `texmf` tree, so it exercises `README.md`'s "Route 1"
mechanism: the class files sit in a flat directory beside the document, and
`latexmk -lualatex` drives the build. That mechanism was run against the
extracted archive on 2026-08-17 — the ten Work files from
`build/distrib/ctan/careerdossier/`, an example document and its profile beside
them, `TEXINPUTS` emptied and `TEXMFHOME` pointed at a nonexistent path — and
`latexmk -lualatex` produced the résumé, resolving every class and package from
that directory.

**That is the route's mechanism, not Overleaf.** Overleaf pins its own TeX Live
release and its own `latexmk`, and neither can be checked from here. The
checklist item below stays open until someone uploads the extracted archive into
an Overleaf project, sets the compiler to LuaLaTeX, and compiles.

### Upload metadata

`uploadconfig` in `build.lua` carries the CTAN upload form: package name,
version, author, licence `lppl1.3c`, summary and description, topics, repository,
bug tracker, and support channel. The version is **derived from the Work** rather
than restated, so it cannot disagree with the ten `\ProvidesExpl*` declarations
the version lint holds equal.

Two fields need a decision at upload time rather than in the file:

- **`email` is deliberately absent.** CTAN requires a reachable address for the
  uploader and this repository publishes only a GitHub noreply address, so an
  upload cannot complete from a checkout alone. Supply it on the command line —
  `l3build upload --email <address>` — without editing `build.lua`.
- **`update = false`** declares a new package. Flip it at the first revision.

`ctanPath` is `/macros/luatex/latex/careerdossier`: LuaLaTeX-only packages are
filed there rather than under `macros/latex/contrib` (confirmed against
`ctan.org/pkg/lua-ul`, filed there for the same reason). CTAN staff may reassign
it on upload.

Nothing here uploads, and nothing should. `AGENTS.md` rule 11 reserves release
publication to the maintainer, and a CTAN upload cannot be withdrawn the way a
GitHub release can. Verify the archive manually before upload.

### Licence and fonts

- LPPL 1.3c or later is conventional for LaTeX code; the project uses LPPL 1.3c,
  maintenance status `maintained`, maintainer Amir Sadeghi.
- Give documentation and examples explicit licence terms.
- Do not assume a font licence permits bundling merely because the font is free to
  use in documents. List every bundled asset and its licence, and keep third-party
  notices and source links.

### Versioning and maintenance

- Keep release date and version synchronized across source, documentation, README,
  and CTAN metadata.
- Maintain a changelog that calls out extraction or rendering changes.
- State the minimum LaTeX release and TeX Live versions.
- Provide a public bug tracker and repository.
- Document deprecations before removing public interfaces, and add a regression
  test for each fixed parsing bug.

## Release checklist

> This is the full CTAN-quality release checklist, targeted at `v0.10.0`. For Phase
> 1, the applicable subset is the **Document output** and **Extraction** groups
> plus basic build CI; the CTAN group is out of Phase 1 scope.

### Document output

- [ ] Single-column output is the default.
- [ ] Essential content appears in the document body.
- [ ] Headings are conventional and extract correctly.
- [ ] Dates remain associated with the correct entry.
- [ ] Links retain useful visible text.
- [ ] Bullets are standard list constructs.
- [ ] No icon, table, graphic, or colour carries unique meaning.
- [ ] No hidden or mismatched text exists.

### LuaLaTeX and fonts

- [ ] Wrong engines fail early with a useful message.
- [ ] Default fonts are reproducible and legally distributable.
- [ ] Upright, bold, italic, and bold italic are explicit.
- [ ] No per-word `/ActualText` spans are present
      ([`ATS-EXTRACTION.md`](ATS-EXTRACTION.md#actualtext-tounicode-and-their-limits),
      "`/ActualText`, `ToUnicode`, and their limits").
- [ ] Ligature and alternate-feature policy is documented.
- [ ] Font versions are recorded and all meaningful fonts are embedded.

### Extraction

- [ ] Ground-truth text round-trips through Poppler.
- [ ] Ground-truth text round-trips through a second, non-Poppler consumer
      (PDFKit on macOS), because Poppler recovers spacing that others do not.
- [ ] The output contains no `/ActualText` spans
      ([`ATS-EXTRACTION.md`](ATS-EXTRACTION.md#actualtext-tounicode-and-their-limits),
      "`/ActualText`, `ToUnicode`, and their limits").
- [ ] Default and `-layout` extraction have been inspected.
- [ ] Punctuation, accents, symbols, URLs, and ligature sequences pass.
- [ ] Ordered-block assertions pass.
- [ ] Copy/paste passes in at least two independent PDF engines.
- [ ] A real portal preview has been checked when feasible.

### Accessibility and rendering

- [ ] The default `hyperref` metadata route and the separate opt-in
      `\DocumentMetadata` tagging route are documented.
- [ ] Tagged fixtures pass structure, artifact, and extraction checks, and the
      untagged path is unchanged.
- [ ] The five UA-2 fixture variants pass veraPDF, and the reports and toolchain
      record from that run were reviewed
      ([`ATS-EXTRACTION.md`](ATS-EXTRACTION.md#recorded-validation-results-v040-plus-the-v050-statement-fixture),
      "Recorded validation results").
- [ ] At least one macOS and one Windows screen-reader reading-order check is
      recorded, or the release explicitly states which one is outstanding
      ([`ATS-EXTRACTION.md`](ATS-EXTRACTION.md#screen-reader-reading-order-checks),
      "Screen-reader reading-order checks").
- [ ] No PDF/UA or WCAG claim is made beyond what a validator run and manual
      inspection actually covered, and the fixtures that were validated are named.
- [ ] Rendered pages have no clipping, overlap, missing glyphs, or bad page breaks,
      and output is legible in grayscale and at high zoom.

### Package quality

- [ ] Public API is semantic and documented; internal names are namespaced.
- [ ] Current l3keys options and kernel hooks are used where appropriate.
- [ ] Errors and warnings are actionable.
- [ ] Every fixed bug has a regression test.
- [ ] User and programmer documentation build cleanly; changelog and version
      metadata agree. `make manual` builds the user manual, and `make lint`
      asserts that the release it declares matches the Work's.

### CTAN **(v0.10.0)**

- [ ] README, licence, PDF manual, and documentation source are present —
      `careerdossier.pdf` and `doc/careerdossier.tex`, the PDF built from that
      source rather than from anything else.
- [ ] Archive has one correctly named top-level directory.
- [ ] No temporary or prohibited generated files are included.
- [ ] Font and asset licences have been audited.
- [ ] The archive installs and compiles on Overleaf, which has no personal
      `texmf` tree — `README.md`'s "Route 3 — Overleaf" is the route it must
      satisfy.
- [ ] The package name and the `careerdossier-*` filenames are still free
      ("Name and filename availability" above); the `kpsewhich` check was run
      from outside this repository.
- [ ] `uploadconfig`'s two upload-time fields are settled: an `email` for the
      uploader, and `update` matching new-versus-revision.
- [ ] `make check`, documentation build, and `make ctan` pass, and the final
      archive has been extracted and inspected by hand — one top-level
      directory, README with licence and version, no prohibited generated
      files, and a document that builds from the extracted tree.

---

*Part of CareerDossierTeX. Licensed under LPPL 1.3c. Maintainer: Amir Sadeghi.*
