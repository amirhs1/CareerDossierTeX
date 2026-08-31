# CareerDossierTeX

A reusable LuaLaTeX toolkit for producing consistent career documents from shared profile data.

For people using the toolkit: what it supports today, how to install and build,
and the options at a glance. The PDF manual — `make manual`, or the
`careerdossier.pdf` attached to a release — is the complete interface
reference; [`CONTRIBUTING.md`](CONTRIBUTING.md) is for people changing the
code.

> **Status:** `v0.9.0 — Documentation, Examples, and Release Readiness` is the
> current published release. The toolkit worked, but it was hard to learn: no
> reference described its public interface, nothing said how to install it, and
> the documentation set had grown to restate itself. This release adds
> [`doc/careerdossier.tex`](doc/careerdossier.tex), a PDF manual documenting
> every public class, option, key, command, environment, and design token with
> its accepted values and default; an `## Installation` section covering the
> three routes onto a path where the classes resolve; and a configured CTAN
> release archive. The documentation set is reduced to one home per rule, and
> the examples are revised — a two-page bibliography CV, and tagging and contact
> labels demonstrated in shipped documents.
>
> It also settles the last public-interface work before the `v0.10.0` freeze:
> `CDossierPublications` gains `numbering=restart|continue`, a raw `#` in a
> profile value no longer truncates the link it appears in, and a document's PDF
> metadata is now identical on the tagged and untagged build paths.
>
> **No public command, environment, class option, or key is added, renamed, or
> removed.** One change moves the page: the gap below the header stack in a
> cover letter or statement no longer adds `\parskip` on top of the token that
> names it, tightening the header-to-body gap by one `\parskip` once per
> document. Resume and CV are unaffected. See
> [`docs/MIGRATION.md`](docs/MIGRATION.md) for the upgrade path.
>
> Before `v0.10.0` the public interface may still change between minor versions;
> such changes are recorded in [`CHANGELOG.md`](CHANGELOG.md) and
> [`docs/MIGRATION.md`](docs/MIGRATION.md).

## What it provides

CareerDossierTeX separates personal information from document content and presentation. A shared profile file can be reused across a resume and matching cover letter, helping keep names, contact details, links, and visual styling consistent.

### Support matrix

| Capability | Current support | Notes |
|---|---|---|
| Industry resume | Supported | Multi-page output gains a continuation header and folios; one-page output stays clean |
| Industry cover letter | Supported | `family=industry` remains the default; shared multi-page furniture applies |
| Academic CV | Supported | Multi-page layout with running headers and folios; one-page folios are suppressed |
| Academic cover letter | Supported | Select with `family=academic`; shares the cross-class page furniture |
| Statement documents | Supported | Default interest type plus six specialized types; calibrated header/prose rhythm and shared multi-page furniture apply |
| Manual publication lists | Supported | No BibLaTeX or Biber required |
| External bibliography | Optional | Fixed BibLaTeX/Biber profile |
| Shared profile metadata | Supported | Includes optional Scholar, ORCID, and affiliation fields |
| Language | English | Farsi, bilingual, and RTL support is dropped |
| Engine | LuaLaTeX | XeLaTeX and pdfLaTeX are unsupported and error early |
| Tagged PDF | Opt-in preview | Off by default; see [Tagged PDF](#tagged-pdf-opt-in-preview) |
| Paper size | US Letter and A4 | `paper=letter` remains the default; `paper=a4` is opt-in |
| Body font | Serif and sans | `bodyfont=serif` remains the default; `bodyfont=sans` is opt-in |
| Output medium | Print and screen | `medium=print` remains the default; `medium=screen` drops the running header and folio |
| Entry-metadata de-emphasis | None, italic, gray, or both | `muted=plain` is the default and applies no de-emphasis; `muted=italic`, `muted=gray`, and `muted=both` opt into the styling |
| Theme | Monochrome | Color themes, named font combinations, and icons are unsupported |
| Continuous integration | Supported | Accumulated suites plus every shipped example |

Color themes, named font combinations, icons, and alternate bibliography styles
remain later work. Farsi, bilingual, and right-to-left support is dropped;
CareerDossierTeX is English-only.

## Requirements

- LuaLaTeX (LuaHBTeX)
- `latexmk`
- A TeX Live or MiKTeX installation carrying `fontspec`, `geometry`,
  `hyperref`, `enumitem`, `xcolor`, `l3keys2e`, `lua-ul`, and the TeX Gyre
  fonts — all present in a full install of either distribution

Fonts are resolved by file name through `luaotfload`, so the build does not
depend on OS-installed fonts.

BibLaTeX and Biber are optional and are needed only by documents that load
`careerdossier-biblatex`. Manual publication lists and CVs without an external
bibliography do not require them.

CareerDossierTeX does not support XeLaTeX or pdfLaTeX. Compiling with either
stops with an actionable error naming LuaLaTeX. Users upgrading from `v0.2.x`
should read [`docs/MIGRATION.md`](docs/MIGRATION.md).

### Supported releases

| Component | Minimum | Verified against |
|---|---|---|
| LaTeX kernel | `2022-06-01` | `2026-06-01` |
| TeX Live | 2022 — the release carrying that kernel | 2026 |
| Engine | LuaHBTeX (any release providing the above) | LuaHBTeX 1.24.0 |
| `pdfmanagement-testphase` (tagged preview only) | — | 0.97c (2026-05-26) |
| `tagpdf` (tagged preview only) | — | 1.0c (2026-05-17) |

The two columns answer different questions, and the difference is deliberate.

**Minimum** is what the code declares. Every file of the Work carries
`\NeedsTeXFormat{LaTeX2e}[2022-06-01]`, so an older kernel names itself in a
LaTeX warning at the top of the log — the kernel treats this as a warning, not
an error, so the build continues and may then fail obscurely; the warning is
the thing to read first. MiKTeX is supported on the same terms — any release
shipping that kernel or newer.

**Verified against** is what this release was actually built and tested on:
locally under TeX Live 2026 on macOS, and in GitHub Actions against a pinned
`texlive/texlive` image digest. Releases between the declared minimum and the
verified toolchain are expected to work and are **not** tested; a report from
one is welcome. The last two rows apply only to the opt-in tagged-PDF preview.

## Installation

CareerDossierTeX is not on CTAN yet, so there is no `tlmgr install` route.
Installing means putting the class and package files somewhere LaTeX searches,
after which `\documentclass{careerdossier-resume}` resolves.

**What to install** is the set of files listed under "The Work" in
[`manifest.txt`](manifest.txt): six `careerdossier-*.sty` packages and four
`careerdossier-*.cls` classes, all at the top level of the repository.
`manifest.txt` is the single definition of that set — copy what it lists rather
than any list repeated elsewhere, so that adding or removing a module cannot
leave these instructions stale. Nothing else in the repository is needed to
compile your own document; `docs/`, `examples/`, `tests/`, and the `Makefile`
are for reading the reference material and for developing the toolkit.

The three routes below install the same files and differ only in where they put
them. All of them still require LuaLaTeX — see "Requirements" above.

### Route 1 — beside the document

The simplest route, and the one that needs no configuration on any installation.
Copy the files into the same directory as your `.tex` file:

```bash
cp /path/to/CareerDossierTeX/careerdossier-*.sty \
   /path/to/CareerDossierTeX/careerdossier-*.cls .
```

LaTeX searches the document's own directory first, so the classes resolve with
no further step. This is per-document: each new document needs its own copy, and
updating means recopying into each.

### Route 2 — a local `texmf` tree

Install once for every document on the machine. Ask your installation where its
personal tree lives rather than guessing — the path differs by platform
(`~/Library/texmf` on macOS, `~/texmf` on Linux):

```bash
kpsewhich -var-value=TEXMFHOME
```

Then copy the files into `tex/latex/careerdossier/` beneath it:

```bash
mkdir -p "$(kpsewhich -var-value=TEXMFHOME)/tex/latex/careerdossier"
cp /path/to/CareerDossierTeX/careerdossier-*.sty \
   /path/to/CareerDossierTeX/careerdossier-*.cls \
   "$(kpsewhich -var-value=TEXMFHOME)/tex/latex/careerdossier/"
```

On TeX Live that is the whole step. `TEXMFHOME` is searched by directory scan
rather than through an `ls-R` index, so no `mktexlsr` or `texhash` run is
needed; running one is harmless but changes nothing. On MiKTeX, register the
directory as a user root and refresh the file name database through MiKTeX
Console — MiKTeX's own documentation is authoritative for that step, which was
not exercised here.

Update by replacing the files; uninstall by deleting the `careerdossier`
directory.

### Route 3 — Overleaf

Overleaf projects have no personal `texmf` tree, so route 1 is the one that
applies:

1. Upload the files into the project alongside your `.tex` file. Overleaf's
   *Upload* accepts a multiple selection, so they all go in one action.
2. Set the compiler to **LuaLaTeX** under *Menu → Compiler*. This is required
   rather than a preference: under pdfLaTeX or XeLaTeX the classes stop with an
   error naming LuaLaTeX.

Overleaf compiles through `latexmk`, which already reruns as often as the
auxiliary files require, so the two-pass note under "Quick start" is handled for
you there.

## Quick start

### 1. Create a shared profile

Save personal metadata in `examples/profiles/profile-english.tex`:

```latex
\CDossierSetup{
  name     = {Amir Sadeghi},
  headline = {Data Scientist},
  email    = {name@example.com},
  phone    = {+1 555 555 5555},
  location = {Ontario, Canada},
  website  = {example.com},
  linkedin = {linkedin.com/in/example},
  github   = {github.com/example}
}
```

Optional fields may be omitted. Contact separators should adjust automatically when a field is missing.

`linkedin`, `github`, and `scholar` also accept a bare handle — `linkedin = {example}` displays and links `linkedin.com/in/example`. See the manual for the accepted forms per key.

### 2. Create a resume

```latex
\documentclass[
  fontsize=11pt,
  margin=narrow,
  paper=letter,
  bodyfont=serif,
  medium=print,
  muted=plain
]{careerdossier-resume}

\input{examples/profiles/profile-english.tex}

\begin{document}

\MakeCDossierHeader

\CDossierSection{Experience}

\begin{CDossierEntry}[
  title        = {Data Scientist},
  organization = {Example Organization},
  location     = {Toronto, Ontario},
  dates        = {2024--Present}
]
  \begin{CDossierItemize}
    \item Built and evaluated production machine-learning workflows.
    \item Communicated findings to technical and nontechnical partners.
  \end{CDossierItemize}
\end{CDossierEntry}

\end{document}
```

Every document class accepts `fontsize=10pt|11pt|12pt`,
`margin=normal|narrow`, `paper=letter|a4`, `bodyfont=serif|sans`,
`medium=print|screen`, and `muted=plain|italic|gray|both`. US Letter remains the
default.
The resume defaults to `11pt,narrow`; the CV, letter, and statement classes
default to `12pt,normal`. `normal` is one inch and `narrow` is half an inch.
One `fontsize` drives every type size and every structural gap, so the three
sizes are one design at three scales rather than three separate designs.

The prose classes default to `12pt` deliberately: at a one-inch margin that is
the only body size whose full-measure line lands near the conventional 45–90
character range. The resume instead keeps `11pt,narrow` for one-page capacity,
which runs long in full-width prose — see the manual for the measured figures
and when to override it.

`medium` names the output context and decides whether page furniture is
emitted. `print` is the default and keeps the running header and `Page N of M`
folio; `screen` drops both, because a PDF viewer already shows page position.
It changes nothing else — the text block does not move, so switching `medium`
cannot reflow a document.

`muted` decides how de-emphasized runs are rendered: an entry's dates and
location, and the statement's application-context line. `italic` is the default
and keeps them italic and black; `gray` renders them upright in the muted color
token (`gray 0.30`, measured at 8.52:1 against white); `both` applies the
italic and the color together. Italic is harder to read at small sizes than a
high-contrast gray, but shape survives a photocopy that a gray level does not —
which is why this is a choice rather than a fixed decision. Under every value
the dates are also identified by their position and content, so color is never
the only carrier of meaning, and no extractor sees any difference.

Advanced users can call `\geometry{...}` after `\documentclass` for a custom
layout, but should not load the already-loaded `geometry` package again.

Build every document **twice**. Single-page folio suppression and the
`Page N of M` total both read the previous run's auxiliary file, so a first
build from a clean tree still shows a folio on a one-page document. `latexmk`
and the `make` targets below already rerun; a bare `lualatex` call does not.

See the complete example in:

```text
examples/industry/resume-english.tex
```

### 3. The other document types

The remaining classes follow the same shape — load a class, set the profile,
render the header, write content. The manual walks each one through in full
under "Complete examples"; the shipped examples are complete working documents:

| Document | Class | Complete example |
|---|---|---|
| Cover letter | `careerdossier-letter` | [`examples/industry/letter-industry.tex`](examples/industry/letter-industry.tex) |
| Academic cover letter | `careerdossier-letter`, `family=academic` | [`examples/academic/letter-academic.tex`](examples/academic/letter-academic.tex) |
| Academic CV | `careerdossier-cv` | [`examples/academic/cv-academic.tex`](examples/academic/cv-academic.tex) |
| Academic CV with BibLaTeX | `careerdossier-cv` plus `careerdossier-biblatex` | [`examples/academic/cv-bibliography.tex`](examples/academic/cv-bibliography.tex) |
| Statements, seven types | `careerdossier-statement` | [`examples/statements/`](examples/statements/) |

Three things worth knowing before you open one:

- `family=academic` changes a letter's document-type metadata, not its layout.
  Both letter families use the same size, margin, prose rhythm, and continuation
  furniture.
- The CV adds a dependency-free publication list, `CDossierPublications`, and an
  optional BibLaTeX and Biber profile in `careerdossier-biblatex`. A CV that does
  not load that package builds without either tool.
- A statement selects one of seven types with `type=`. Omit it for a statement of
  interest, which requires only `name` and `email`; `type=research` also requires
  profile `affiliation`, and `type=artist` profile `website`.

`\CDossierSubsection` is available in the resume and the CV as the level between
a section and an entry — `Publications` split into journal, conference, and
preprint, or `Experience` into industry and academic — so a group need not be
promoted to a ruled section of its own.

## Tagged PDF (opt-in preview)

CareerDossierTeX can emit tagged semantic structure under LuaLaTeX. It is **off
by default**. Opt in with `\DocumentMetadata` before `\documentclass`:

```latex
\DocumentMetadata{lang=en, tagging=on}
\documentclass[fontsize=11pt, margin=narrow]{careerdossier-resume}
```

One shipped example is built this way so the opt-in is visible where users
start:
[`examples/industry/letter-industry.tex`](examples/industry/letter-industry.tex)
carries the `\DocumentMetadata` line above, and its source comment explains what
tagging does and what is not being claimed. The other ten examples stay on the
default untagged path.

When tagging is on, section headings, lists, paragraphs, and links are exposed
as structure, while decorative rules, contact separators, and running page
furniture are marked as layout artifacts. No public command or class option
changes, and since `v0.7.0` a tagged build puts every word of all eleven
supported examples at the same vertical position as the untagged build of the
same source — turning tagging on does not repaginate a document.

**What is and is not claimed.** This is a tested preview for five profiles
covered by fixtures — industry resume, industry letter, academic CV, academic
letter, and statement. Those fixtures assert that a structure tree exists and
check heading, link, and artifact structure plus text extraction and
tagged-versus-untagged geometry; list checks apply to the resume and CV.

Those five profiles were independently verified: each passes the **veraPDF**
PDF/UA-2 validator, their text extraction agrees across **Poppler, MuPDF, and
Apple PDFKit**. A **macOS VoiceOver** reading-order pass covered the four
`v0.4.0` profiles and confirmed that headings, lists, and links are announced
correctly while decorative rules and repeated page furniture stay silent; the
statement fixture has not received a screen-reader pass. The screen-reader procedure and its
recorded result are in
[`docs/TESTING.md`](docs/TESTING.md#screen-reader-reading-order-checks); the
toolchain each run was measured on is written to `tests/tagging/reports/`.

That automated verification covers **those five fixtures only**. It is **not** a PDF/UA,
WCAG, ATS, or general accessibility conformance claim, it does not extend to
arbitrary user documents, and it is not a reason to enable tagging by default. A
document with different content, packages, or graphics is unverified until it is
itself verified. No Windows screen-reader check has been performed — NVDA
coverage is tracked in
[issue #96](https://github.com/amirhs1/CareerDossierTeX/issues/96).

## Build

Compile the supported examples with LuaLaTeX:

```bash
latexmk -lualatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex

latexmk -lualatex -interaction=nonstopmode -halt-on-error \
  examples/industry/letter-industry.tex

latexmk -lualatex -interaction=nonstopmode -halt-on-error \
  examples/academic/cv-academic.tex

# Optional BibLaTeX/Biber example; latexmk runs Biber automatically.
latexmk -lualatex -interaction=nonstopmode -halt-on-error \
  examples/academic/cv-bibliography.tex

latexmk -lualatex -interaction=nonstopmode -halt-on-error \
  examples/academic/letter-academic.tex

# Build all six specialized statement examples through the repository target.
make statements
```

All eleven examples may also be built with the repository `Makefile`:

```bash
make
```

The manual is built the same way, and lands in `build/manual/`:

```bash
make manual
```

Run `make help` for the full target list.

A configuration is supported only after its examples compile locally and in GitHub Actions.

## Development and testing policy

CareerDossierTeX is test-driven where practical and test-as-you-go always. Every
behavior change adds or updates the relevant automated test in the same pull
request; known tests are not deferred to a testing pass at the end of a
milestone. When practical, write the test first and confirm that it detects the
missing or incorrect behavior before implementing the change.

All committed test fixtures, baselines, and runners live under `tests/`, grouped
by purpose. Files under `examples/` teach users and may also be compiled by CI,
but examples do not replace focused regression, smoke, error-path, extraction,
or layout-stress tests.

Run everything CI runs — the option lint, regression, extraction, smoke,
layout, bibliography, link-integrity, metadata, link-annotation, and tagging
suites plus every supported example build — with:

```bash
make check
```

`make check` runs those targets four at a time and is the pre-push gate;
`make check-serial` runs the same ones singly when a deterministic pass is worth
more than the wall clock, and [`CONTRIBUTING.md`](CONTRIBUTING.md) "The gate, and
the serial path" says when each is worth reaching for.

`make help` lists every individual target, `make clean` removes the generated
files afterwards, and the `Makefile`'s `CHECK_TARGETS` variable is the
authoritative suite list. A local suite and its CI job are equivalent, though a
few jobs invoke the suite runner under `tests/` directly rather than through the
target that wraps it.

The full suite requires `l3build` and `pdftotext` (Poppler) in addition to
LuaLaTeX and `latexmk`. Because `make check` exercises the optional bibliography
profile, it also requires BibLaTeX and Biber. Ordinary resume, letter, and
no-BibLaTeX CV builds do not.

Release preparation reruns the accumulated suite. It is a final verification
gate, not the stage where feature tests are first created. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) for the full workflow.

## Documentation

- [`doc/careerdossier.tex`](doc/careerdossier.tex): the PDF manual — public classes, options, keys, commands, environments, tokens, and errors. Build it with `make manual`, or take `careerdossier.pdf` from a release
- [`docs/API.md`](docs/API.md): where that manual is, and the interface stability policy
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): module boundaries and internal design
- [`docs/ROADMAP.md`](docs/ROADMAP.md): release phases and planned features
- [`docs/ATS-EXTRACTION.md`](docs/ATS-EXTRACTION.md): design guidance for ATS-safe output and text extraction (reference material, not shipped-behavior docs)
- [`CONTRIBUTING.md`](CONTRIBUTING.md): issue, branch, commit, and pull-request workflow
- [`docs/TESTING.md`](docs/TESTING.md): the test suites, review targets, and coverage expectations
- [`docs/NAMING-CONVENTION.md`](docs/NAMING-CONVENTION.md): naming for issues, branches, commits, labels, milestones, and releases
- [`AI-POLICY.md`](AI-POLICY.md): AI-assisted contribution, attribution, security, and accountability policy
- [`AGENTS.md`](AGENTS.md): the operating contract for coding agents
- [`docs/MIGRATION.md`](docs/MIGRATION.md): migration from earlier class files
- [`docs/RELEASE-CHECKLIST.md`](docs/RELEASE-CHECKLIST.md): the per-release gate and the CTAN packaging requirements
- [`CHANGELOG.md`](CHANGELOG.md): release history and user-visible changes

Only behavior documented in the manual and covered by the relevant tests and
supported examples should be treated as supported.

## Releases

The current release is:

```text
v0.9.0 — Documentation, Examples, and Release Readiness
```

Source archives and selected example PDFs are available through GitHub Releases.

## Roadmap

Everything in the support matrix above is in the current release, named under
[Releases](#releases). Two releases remain planned: `v0.9.0` consolidates the
documentation set, revises the examples, and prepares the CTAN archive, and
`v0.10.0` declares the public interface stable and fully documented. Nothing is
scheduled after that.

[`docs/ROADMAP.md`](docs/ROADMAP.md#release-overview) owns the release table —
every version, its goal, and its status, including the two milestones closed
without shipping — together with the boundary between releases and each one's
non-goals.

## Contributing

Focused bug reports, feature proposals, documentation improvements, and pull requests are welcome. Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before opening a pull request.

Three rules shape how work is divided here:

- every issue carries a release milestone, and an epic parent only when the work
  spans several issues;
- every pull request links an issue, except a revert, a release chore, or a
  CI/tooling repair, which state their rationale in the pull request body;
- every pull request comes from a focused branch, merged or rebased onto `main`
  within three days.

See [Work item structure](CONTRIBUTING.md#work-item-structure) for the full
statement and the reasoning behind each.

## License

CareerDossierTeX is distributed under the LaTeX Project Public License, version 1.3c or, at your option, any later version.

The project has LPPL maintenance status `maintained`. The current maintainer is Amir Sadeghi.

See [`LICENSE`](LICENSE) for the complete license text. Documents and PDFs produced with CareerDossierTeX are not required to use the LPPL merely because they were created with these classes.
