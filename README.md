# CareerDossierTeX

A reusable XeLaTeX toolkit for producing consistent career documents from shared profile data.

> **Status:** `v0.2.1 — Extraction Correction` is the current release.
> Before `v1.0.0` the public interface may still change between minor versions;
> such changes are recorded in [`CHANGELOG.md`](CHANGELOG.md) and
> [`docs/MIGRATION.md`](docs/MIGRATION.md).

## What it provides

CareerDossierTeX separates personal information from document content and presentation. A shared profile file can be reused across a résumé and matching cover letter, helping keep names, contact details, links, and visual styling consistent.

### Support matrix

| Capability | `v0.2.0` support | Notes |
|---|---|---|
| Industry résumé | Supported | Existing `v0.1.x` behavior remains compatible |
| Industry cover letter | Supported | `family=industry` remains the default |
| Academic CV | Supported | Multi-page layout with running headers and folios |
| Academic cover letter | Supported | Select with `family=academic` |
| Manual publication lists | Supported | No BibLaTeX or Biber required |
| External bibliography | Optional | Fixed BibLaTeX/Biber profile |
| Shared profile metadata | Supported | Includes optional Scholar and ORCID fields |
| Language | English | Farsi, bilingual, and RTL support is dropped |
| Engine | XeLaTeX | pdfLaTeX and LuaLaTeX are unsupported |
| Paper size | US Letter | A4 is unsupported |
| Theme | Monochrome | Color themes, font presets, and icons are unsupported |
| Continuous integration | Supported | Accumulated suites plus every shipped example |

Statement classes, A4 paper, color themes, font presets, icons, and alternate
bibliography styles belong to later milestone work. Farsi, bilingual, and
right-to-left support is dropped; CareerDossierTeX is English-only.

## Requirements

- XeLaTeX
- `latexmk`
- A reasonably complete TeX Live or MiKTeX installation

BibLaTeX and Biber are optional and are needed only by documents that load
`careerdossier-biblatex`. Manual publication lists and CVs without an external
bibliography do not require them.

CareerDossierTeX does not support pdfLaTeX or LuaLaTeX.

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
  fontsize=10pt,
  density=compact
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

### 4. Create an academic CV

The academic CV reuses the shared profile, section, entry, and list interfaces.
It also provides a dependency-free manual publication list:

```latex
\documentclass[fontsize=11pt, density=standard]{careerdossier-cv}

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

## Build

Compile the supported examples with XeLaTeX:

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex

latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/letter-industry.tex

latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/academic/cv-academic.tex

# Optional BibLaTeX/Biber example; latexmk runs Biber automatically.
latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/academic/cv-bibliography.tex

latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/academic/letter-academic.tex
```

All five examples may also be built with the repository `Makefile`:

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

Run everything CI runs — the regression, extraction, smoke, and layout suites
plus every supported example build — with:

```bash
make check
```

Individual suites are available as `make regression`, `make extract-test`,
`make smoke`, `make layout`, and `make bibliography-test`; `make clean` removes
the generated files afterwards. Each target runs the same command as the
matching CI job.

The full suite requires `l3build` and `pdftotext` (Poppler) in addition to
XeLaTeX and `latexmk`. Because `make check` exercises the optional bibliography
profile, it also requires BibLaTeX and Biber. Ordinary résumé, letter, and
no-BibLaTeX CV builds do not.

Release preparation reruns the accumulated suite. It is a final verification
gate, not the stage where feature tests are first created. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) for the full workflow.

## Documentation

- [`docs/API.md`](docs/API.md): public commands, keys, environments, defaults, and errors
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): module boundaries and internal design
- [`docs/ROADMAP.md`](docs/ROADMAP.md): release phases and planned features
- [`docs/guides/ats-extraction.md`](docs/guides/ats-extraction.md): design guidance for ATS-safe output and text extraction (reference material, not shipped-behavior docs)
- [`CONTRIBUTING.md`](CONTRIBUTING.md): issue, branch, commit, test, and pull-request workflow
- [`AI-POLICY.md`](AI-POLICY.md): AI-assisted contribution, attribution, security, and accountability policy
- [`docs/MIGRATION.md`](docs/MIGRATION.md): migration from earlier class files
- [`CHANGELOG.md`](CHANGELOG.md): release history and user-visible changes

Only behavior documented in `docs/API.md` and covered by the relevant tests and
supported examples should be treated as supported.

## Releases

The current release is:

```text
v0.2.1 — Extraction Correction
```

Source archives and selected example PDFs are available through GitHub Releases.

## Roadmap

| Version | Goal |
|---|---|
| `v0.1.0` | English industry résumé and cover letter |
| `v0.1.1` | Metadata and build corrections |
| `v0.2.0` | Academic CV, academic letter, and optional bibliography support |
| `v0.2.1` | Extraction correction |
| `v0.5.0` | Statement classes and broader customization |
| `v1.0.0` | Stable and documented public API |

Farsi, bilingual, and right-to-left support (`v0.3.0`) is dropped.
CareerDossierTeX is English-only.

See [`docs/ROADMAP.md`](docs/ROADMAP.md) for release boundaries and non-goals.

## Contributing

Focused bug reports, feature proposals, documentation improvements, and pull requests are welcome. Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before opening a pull request.

## License

CareerDossierTeX is distributed under the LaTeX Project Public License, version 1.3c or, at your option, any later version.

The project has LPPL maintenance status `maintained`. The current maintainer is Amir Sadeghi.

See [`LICENSE`](LICENSE) for the complete license text. Documents and PDFs produced with CareerDossierTeX are not required to use the LPPL merely because they were created with these classes.
