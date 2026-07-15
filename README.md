# CareerDossierTeX

A reusable XeLaTeX toolkit for producing consistent career documents from shared profile data.

> **Status:** Pre-release development toward `v0.1.0 — English Industry Dossier`.  
> The public interface may change before the first stable release.

## What it provides

CareerDossierTeX separates personal information from document content and presentation. A shared profile file can be reused across a résumé and matching cover letter, helping keep names, contact details, links, and visual styling consistent.

### Target `v0.1.0` scope

| Capability | Target |
|---|---|
| Industry résumé | Implemented; pre-release |
| Industry cover letter | Implemented; pre-release |
| Shared profile metadata and components | Implemented; pre-release |
| Language | English |
| Engine | XeLaTeX |
| Paper size | US Letter |
| Theme | Monochrome |
| Local build | `latexmk` |
| Continuous integration | Extraction, smoke, and layout tests plus example build active |

The academic CV, bibliography integration, Farsi, bilingual layouts, statement classes, A4 paper, and additional themes belong to later releases.

## Requirements

- XeLaTeX
- `latexmk`
- A reasonably complete TeX Live or MiKTeX installation

CareerDossierTeX is not intended to compile with pdfLaTeX in `v0.1.0`.

## Quick start

> The examples below describe the proposed `v0.1.0` public interface. Until the implementation and CI build are complete, treat this interface as provisional.

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

## Build

After the Phase 1 source and example files are implemented, compile them with XeLaTeX:

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex

latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/letter-industry.tex
```

When the repository `Makefile` is available, both examples may also be built with:

```bash
make
```

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

Run the currently available extraction suite with:

```bash
make extract-test
```

This suite requires `pdftotext` from Poppler in addition to XeLaTeX.

Release preparation reruns the accumulated suite. It is a final verification
gate, not the stage where feature tests are first created. See
[`CONTRIBUTING.md`](CONTRIBUTING.md) for the full workflow.

## Documentation

- [`docs/API.md`](docs/API.md): public commands, keys, environments, defaults, and errors
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): module boundaries and internal design
- [`docs/ROADMAP.md`](docs/ROADMAP.md): release phases and planned features
- [`docs/guides/ats-extraction.md`](docs/guides/ats-extraction.md): design guidance for ATS-safe output and text extraction (reference material, not shipped-behavior docs)
- [`CONTRIBUTING.md`](CONTRIBUTING.md): issue, branch, commit, test, and pull-request workflow
- [`docs/MIGRATION.md`](docs/MIGRATION.md): migration from earlier class files
- [`CHANGELOG.md`](CHANGELOG.md): release history and user-visible changes

Only behavior documented in `docs/API.md` and covered by the relevant tests and
supported examples should be treated as supported.

## Releases

No public release has been published yet.

The first planned release is:

```text
v0.1.0 — English Industry Dossier
```

After it is published, source archives and selected example PDFs will be available through GitHub Releases.

## Roadmap

| Version | Goal |
|---|---|
| `v0.1.0` | English industry résumé and cover letter |
| `v0.2.0` | Academic CV, academic letter, and optional bibliography support |
| `v0.3.0` | Farsi, bilingual, and right-to-left support |
| `v0.4.0` | Statement classes and broader customization |
| `v1.0.0` | Stable and documented public API |

See [`docs/ROADMAP.md`](docs/ROADMAP.md) for release boundaries and non-goals.

## Contributing

Focused bug reports, feature proposals, documentation improvements, and pull requests are welcome. Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before opening a pull request.

## License

CareerDossierTeX is distributed under the LaTeX Project Public License, version 1.3c or, at your option, any later version.

The project has LPPL maintenance status `maintained`. The current maintainer is Amir Sadeghi.

See [`LICENSE`](LICENSE) for the complete license text. Documents and PDFs produced with CareerDossierTeX are not required to use the LPPL merely because they were created with these classes.
