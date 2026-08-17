# CareerDossierTeX release checklist

The per-release gate: what a release has to satisfy before it is tagged, and
what CTAN additionally requires of the uploaded archive at `v1.0.0`. It is the
one file that answers "is this releasable yet"; `docs/ROADMAP.md` owns which
release a change belongs to, and `.agents/skills/release-notes/reference.md`
owns how `CHANGELOG.md` and the GitHub Release notes are written.

The checks below reference [`ATS-EXTRACTION.md`](ATS-EXTRACTION.md) for the
font, extraction, and tagging policy each one asserts, and
[`TESTING.md`](TESTING.md) for the suites that run them.

## CTAN readiness **(planned — v1.0.0)**

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
not, so the archive is what carries both; wiring that into `l3build ctan` is
#264.

Handwritten `.sty`/`.cls` files are source and are included as-is; a `.dtx`/`.ins`
workflow is optional. CTAN in fact discourages *generated* `README` and `.ins`
files because they tend to go stale against their source. TDS packaging
(`.tds.zip`) is optional and, for a package without an elaborate install, generally
unnecessary.

When the project reaches this milestone, `l3build ctan` can generate and inspect
the release archive from the handwritten source; there is no need to migrate to
`.dtx`. Verify the archive manually before upload.

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

> This is the full CTAN-quality release checklist, targeted at `v1.0.0`. For Phase
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
      ([`ATS-EXTRACTION.md`](ATS-EXTRACTION.md#45-actualtext-tounicode-and-their-limits) §4.5).
- [ ] Ligature and alternate-feature policy is documented.
- [ ] Font versions are recorded and all meaningful fonts are embedded.

### Extraction

- [ ] Ground-truth text round-trips through Poppler.
- [ ] Ground-truth text round-trips through a second, non-Poppler consumer
      (PDFKit on macOS), because Poppler recovers spacing that others do not.
- [ ] The output contains no `/ActualText` spans
      ([`ATS-EXTRACTION.md`](ATS-EXTRACTION.md#45-actualtext-tounicode-and-their-limits) §4.5).
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
      ([`ATS-EXTRACTION.md`](ATS-EXTRACTION.md#71-recorded-validation-results-v040-plus-the-v050-statement-fixture) §7.1).
- [ ] At least one macOS and one Windows screen-reader reading-order check is
      recorded, or the release explicitly states which one is outstanding
      ([`ATS-EXTRACTION.md`](ATS-EXTRACTION.md#72-screen-reader-reading-order-checks) §7.2).
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

### CTAN **(v1.0.0)**

- [ ] README, licence, PDF manual, and documentation source are present —
      `careerdossier.pdf` and `doc/careerdossier.tex`, the PDF built from that
      source rather than from anything else.
- [ ] Archive has one correctly named top-level directory.
- [ ] No temporary or prohibited generated files are included.
- [ ] Font and asset licences have been audited.
- [ ] The archive installs and compiles on Overleaf, which has no personal
      `texmf` tree — `README.md`'s "Route 3 — Overleaf" is the route it must
      satisfy.
- [ ] `l3build check`, extraction tests, documentation build, and `l3build ctan`
      pass, and the final archive has been opened and inspected manually.

---

*Part of CareerDossierTeX. Licensed under LPPL 1.3c. Maintainer: Amir Sadeghi.*
