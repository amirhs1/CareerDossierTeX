# CareerDossierTeX

A reusable LuaLaTeX toolkit for producing consistent career documents from shared profile data.

For people using the toolkit: what it supports today, how to install and build,
and the options at a glance. [`docs/API.md`](docs/API.md) is the complete
interface reference; [`CONTRIBUTING.md`](CONTRIBUTING.md) is for people changing
the code.

> **Status:** `v0.7.0 — Page Furniture, Output Medium, and Spacing Ownership`
> is the current published release. Several vertical placement and spacing
> decisions were being made by a third-party default or a hard-coded constant
> rather than by the design system meant to own them; this release hands each
> one back to a calibrated token, gives the tokens one naming convention, and
> retunes the ratios now that every gap is expressible. It also adds
> `medium=print|screen`, which decides whether page furniture is emitted at all.
> **Breaking:** public design tokens are renamed, split, and retired, and the
> retune means **every document reflows** — though no supported combination
> changes its page count. See [`docs/MIGRATION.md`](docs/MIGRATION.md) for the
> upgrade path.
>
> Before `v1.0.0` the public interface may still change between minor versions;
> such changes are recorded in [`CHANGELOG.md`](CHANGELOG.md) and
> [`docs/MIGRATION.md`](docs/MIGRATION.md).

## What it provides

CareerDossierTeX separates personal information from document content and presentation. A shared profile file can be reused across a résumé and matching cover letter, helping keep names, contact details, links, and visual styling consistent.

### Support matrix

| Capability | Current support | Notes |
|---|---|---|
| Industry résumé | Supported | Multi-page output gains a continuation header and folios; one-page output stays clean |
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
| Entry-metadata de-emphasis | Italic, gray, or both | `muted=italic` remains the default; `muted=gray` and `muted=both` opt into the muted color token |
| Theme | Monochrome | Color themes, named font combinations, and icons are unsupported |
| Continuous integration | Supported | Accumulated suites plus every shipped example |

Color themes, named font combinations, icons, and alternate bibliography styles
remain later work. Farsi, bilingual, and right-to-left support is dropped;
CareerDossierTeX is English-only.

## Requirements

- LuaLaTeX (LuaHBTeX)
- `latexmk`
- A reasonably complete TeX Live or MiKTeX installation

Fonts are resolved by file name through `luaotfload`, so the build does not
depend on OS-installed fonts.

BibLaTeX and Biber are optional and are needed only by documents that load
`careerdossier-biblatex`. Manual publication lists and CVs without an external
bibliography do not require them.

CareerDossierTeX does not support XeLaTeX or pdfLaTeX. Compiling with either
stops with an actionable error naming LuaLaTeX. Users upgrading from `v0.2.x`
should read [`docs/MIGRATION.md`](docs/MIGRATION.md).

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

### 2. Create a résumé

```latex
\documentclass[
  fontsize=11pt,
  margin=narrow,
  paper=letter,
  bodyfont=serif,
  medium=print,
  muted=italic
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
`medium=print|screen`, and `muted=italic|gray|both`. US Letter remains the
default.
The résumé defaults to `11pt,narrow`; the CV, letter, and statement classes
default to `12pt,normal`. `normal` is one inch and `narrow` is half an inch.
One `fontsize` drives every type size and every structural gap, so the three
sizes are one design at three scales rather than three separate designs.

The prose classes default to `12pt` deliberately: at a one-inch margin that is
the only body size whose full-measure line lands near the conventional 45–90
character range. The résumé instead keeps `11pt,narrow` for one-page capacity,
which runs long in full-width prose — see [`docs/API.md`](docs/API.md) for the
measured figures and when to override it.

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

### 3. Create a cover letter

```latex
\documentclass{careerdossier-letter}

\input{examples/profiles/profile-english.tex}

\CDossierLetterSetup{
  date                   = {\today},
  recipient-name         = {Hiring Manager},
  recipient-organization = {Example Organization},
  recipient-address      = {Toronto, Ontario},
  subject                = {Application for the Data Scientist Position},
  salutation             = {Dear Hiring Manager,},
  closing                = {Sincerely,}
}

\begin{document}

\MakeCDossierLetterhead

I am writing to apply for the Data Scientist position.

% Continue the letter body here.

\MakeCDossierClosing

\end{document}
```

See the complete example in:

```text
examples/industry/letter-industry.tex
```

`family=academic` changes the letter's document-type metadata, not its layout.
Both letter families use the same selected size, margin, prose rhythm, and
shared continuation furniture.

### 4. Create an academic CV

The academic CV reuses the shared profile, section, entry, and list interfaces.
It also provides a dependency-free manual publication list:

```latex
\documentclass[fontsize=12pt, margin=normal]{careerdossier-cv}

\CDossierSetup{
  name     = {Ada Lovelace},
  headline = {Researcher in Analytical Computing},
  scholar  = {scholar.google.com/citations?user=ada-example},
  orcid    = {0000-0002-1825-0097}
}

\begin{document}
\MakeCDossierHeader

\CDossierSection{Academic Appointments}
\begin{CDossierEntry}[
  title        = {Research Fellow},
  organization = {Example Institute},
  dates        = {2024--Present}
]
  Research and teaching summary.
\end{CDossierEntry}

\CDossierSection{Selected Publications}
\begin{CDossierPublications}
  \CDossierPublication{
    authors = {Ada Lovelace and Grace Hopper},
    title   = {Reliable Analytical Engines},
    venue   = {Journal of Example Computing},
    date    = {2026},
    doi     = {10.9999/example.2026.1}
  }
\end{CDossierPublications}
\end{document}
```

The complete no-BibLaTeX example is
[`examples/academic/cv-academic.tex`](examples/academic/cv-academic.tex).

### 5. Opt in to BibLaTeX and Biber

```latex
\documentclass{careerdossier-cv}
\usepackage{careerdossier-biblatex}

\input{examples/profiles/profile-academic.tex}
\addbibresource{publications.bib}
\CDossierHighlightAuthor{family={Lovelace}, given={Ada}}

\begin{document}
\MakeCDossierHeader
\nocite{*}
\printbibliography[title={Selected Publications}]
\end{document}
```

This optional package uses the fixed `backend=biber`, `style=numeric`, and
`sorting=ydnt` profile. See
[`examples/academic/cv-bibliography.tex`](examples/academic/cv-bibliography.tex)
and its fictional
[`publications.bib`](examples/academic/publications.bib).

### 6. Create an academic cover letter

```latex
\documentclass[family=academic]{careerdossier-letter}
\input{examples/profiles/profile-academic.tex}

\CDossierLetterSetup{
  recipient-name         = {Professor Grace Hopper},
  recipient-organization = {Example University},
  subject                = {Application for Assistant Professor},
  salutation             = {Dear Professor Hopper,}
}

\begin{document}
\MakeCDossierLetterhead
I am writing to apply for the Assistant Professor position.
\MakeCDossierClosing
\end{document}
```

See [`examples/academic/letter-academic.tex`](examples/academic/letter-academic.tex).

### 7. Create a statement

Use one class. Omit `type` for a statement of interest, or select an
explicit type when its title and validation contract fit the document:

```latex
\documentclass[
  type=research,
  fontsize=12pt,
  margin=normal
]{careerdossier-statement}
\input{examples/profiles/profile-academic.tex}

\CDossierStatementSetup{
  subtitle            = {Reliable scientific computing},
  application-context = {Application for Assistant Professor},
  application-id      = {APP-2026-0042}
}

\begin{document}
\MakeCDossierStatementHeader
\CDossierSection{Research Vision}
My research develops reliable methods for computational inquiry.
\end{document}
```

Statements of interest require only `name` and `email`. Research statements
also require profile `affiliation`; artist statements also require profile
`website`. Complete two-page examples for all six specialized types live in
[`examples/statements/`](examples/statements/).

## Tagged PDF (opt-in preview)

CareerDossierTeX can emit tagged semantic structure under LuaLaTeX. It is **off
by default**. Opt in with `\DocumentMetadata` before `\documentclass`:

```latex
\DocumentMetadata{lang=en, tagging=on}
\documentclass[fontsize=11pt, margin=narrow]{careerdossier-resume}
```

When tagging is on, section headings, lists, paragraphs, and links are exposed
as structure, while decorative rules, contact separators, and running page
furniture are marked as layout artifacts. No public command or class option
changes, and since `v0.7.0` a tagged build puts every word of all eleven
supported examples at the same vertical position as the untagged build of the
same source — turning tagging on does not repaginate a document.

**What is and is not claimed.** This is a tested preview for five profiles
covered by fixtures — industry résumé, industry letter, academic CV, academic
letter, and statement. Those fixtures assert that a structure tree exists and
check heading, link, and artifact structure plus text extraction and
tagged-versus-untagged geometry; list checks apply to the résumé and CV.

Those five profiles were independently verified: each passes the **veraPDF**
PDF/UA-2 validator, their text extraction agrees across **Poppler, MuPDF, and
Apple PDFKit**. A **macOS VoiceOver** reading-order pass covered the four
`v0.4.0` profiles and confirmed that headings, lists, and links are announced
correctly while decorative rules and repeated page furniture stay silent; the
statement fixture has not received a screen-reader pass. Recorded results and
the exact toolchain are in
[`docs/ATS-EXTRACTION.md`](docs/ATS-EXTRACTION.md) §7.1–7.2.

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
layout, bibliography, link-integrity, metadata, and tagging suites plus every
supported example build — with:

```bash
make check
```

Individual suites are available as `make lint`, `make regression`,
`make extract-test`, `make smoke`, `make layout`, `make bibliography-test`,
`make links`, `make metadata`, and `make tagging`;
`make clean` removes the generated files afterwards. Each target runs the same
command as the matching CI job.

The full suite requires `l3build` and `pdftotext` (Poppler) in addition to
LuaLaTeX and `latexmk`. Because `make check` exercises the optional bibliography
profile, it also requires BibLaTeX and Biber. Ordinary résumé, letter, and
no-BibLaTeX CV builds do not.

Release preparation reruns the accumulated suite. It is a final verification
gate, not the stage where feature tests are first created. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) for the full workflow.

## Documentation

- [`docs/API.md`](docs/API.md): public commands, keys, environments, defaults, and errors
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): module boundaries and internal design
- [`docs/ROADMAP.md`](docs/ROADMAP.md): release phases and planned features
- [`docs/ATS-EXTRACTION.md`](docs/ATS-EXTRACTION.md): design guidance for ATS-safe output and text extraction (reference material, not shipped-behavior docs)
- [`CONTRIBUTING.md`](CONTRIBUTING.md): issue, branch, commit, test, and pull-request workflow
- [`docs/NAMING-CONVENTION.md`](docs/NAMING-CONVENTION.md): naming for issues, branches, commits, labels, milestones, and releases
- [`AI-POLICY.md`](AI-POLICY.md): AI-assisted contribution, attribution, security, and accountability policy
- [`AGENTS.md`](AGENTS.md): the operating contract for coding agents
- [`docs/MIGRATION.md`](docs/MIGRATION.md): migration from earlier class files
- [`CHANGELOG.md`](CHANGELOG.md): release history and user-visible changes

Only behavior documented in `docs/API.md` and covered by the relevant tests and
supported examples should be treated as supported.

## Releases

The current release is:

```text
v0.7.0 — Page Furniture, Output Medium, and Spacing Ownership
```

Source archives and selected example PDFs are available through GitHub Releases.

## Roadmap

| Version | Goal |
|---|---|
| `v0.1.0` | English industry résumé and cover letter |
| `v0.1.1` | Metadata and build corrections |
| `v0.2.0` | Academic CV, academic letter, and optional bibliography support |
| `v0.2.1` | Extraction correction |
| `v0.4.0` | LuaLaTeX transition and tagged-PDF preview |
| `v0.5.0` | Statement classes and broader customization |
| `v0.6.0` | Calibrated type scale and vertical rhythm |
| `v0.7.0` | Page furniture placement, the `medium` option, and spacing ownership |
| `v0.8.0` | Semantic structure, tagged-output metadata, and public typography and colour roles |
| `v0.9.0` | Documentation set, revised examples, PDF manual, and CTAN archive |
| `v1.0.0` | Stable and documented public API |

Farsi, bilingual, and right-to-left support (`v0.3.0`) is dropped.
CareerDossierTeX is English-only. Colour themes and named font families
(`v1.1.0`) are deferred with no scheduled release; that milestone was closed
empty on 2026-08-05.

See [`docs/ROADMAP.md`](docs/ROADMAP.md) for release boundaries and non-goals.

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
