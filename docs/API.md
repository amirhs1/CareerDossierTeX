# CareerDossierTeX Public API

## Status

This document records two API layers:

```text
Released: v0.1.1 — English Industry Dossier plus maintenance corrections
Development: selected v0.2.0 Academic Dossier behavior (not yet released)
```

Sections that are not explicitly marked as planned describe released behavior.
The `v0.2.0` section distinguishes development behavior from the remaining
planned work; neither is shipped until the release is tagged. Before
`v1.0.0` the interface may still change between minor versions; such changes are
recorded in [`../CHANGELOG.md`](../CHANGELOG.md) and
[`MIGRATION.md`](MIGRATION.md).

The API is intentionally small. Internal helper commands are not public merely because they are technically accessible.

## Supported configuration

| Setting | Released support | `v0.2.0` development / planned addition |
|---|---|---|
| Engine | XeLaTeX only | Unchanged |
| Language | English | Unchanged |
| Paper | US Letter | Unchanged |
| Theme | Monochrome | Unchanged |
| Résumé class | `careerdossier-resume` | Unchanged |
| CV class | Not supported | `careerdossier-cv` implemented on the development branch |
| Letter class | `careerdossier-letter`, industry family | Academic family |
| Bibliography | Not supported | Optional `careerdossier-biblatex` implemented on the development branch |
| Manual publications | Not supported | Implemented in `careerdossier-cv` on the development branch |
| RTL or bilingual layout | Not supported | Unchanged |

## Loading the classes

Public class and package files live at the repository root.

Use:

```latex
\documentclass{careerdossier-resume}
```

or:

```latex
\documentclass{careerdossier-letter}
```

Do not depend on repository-specific paths such as:

```latex
\documentclass{classes/careerdossier-resume}
```

## Résumé class

### Class declaration

```latex
\documentclass[
  fontsize=10pt,
  density=compact
]{careerdossier-resume}
```

### Options

#### `fontsize`

Accepted values:

```text
10pt
11pt
```

Default:

```text
10pt
```

Any unsupported value should produce an actionable class error.

#### `density`

Accepted values:

```text
compact
standard
```

Default:

```text
compact
```

`compact` reduces vertical spacing for short industry résumés. `standard` provides more breathing room.

### Fixed settings

The following are fixed in `v0.1.0` and should not be accepted as user options:

```text
paper=letter
language=english
theme=monochrome
```

It is better to reject or omit an unsupported option than silently ignore it.

## Letter class

### Class declaration

```latex
\documentclass{careerdossier-letter}
```

The following settings are fixed in `v0.1.0`:

```text
family=industry
paper=letter
language=english
theme=monochrome
```

Academic letter layouts belong to `v0.2.0`.

## Shared profile metadata

### `\CDossierSetup`

```latex
\CDossierSetup{
  name     = {Amir Sadeghi},
  headline = {Data Scientist},
  email    = {name@example.com},
  phone    = {+1 555 555 5555},
  location = {Ontario, Canada},
  website  = {example.com},
  linkedin = {linkedin.com/in/example},
  github   = {github.com/example},
  scholar  = {scholar.google.com/citations?user=example}
}
```

This command stores profile metadata for reuse across the supported dossier
classes. The optional `orcid` key is development behavior for `v0.2.0`; the
other keys remain available to the released industry classes.

### Profile keys

| Key | Required | Availability | Purpose |
|---|---:|---|---|
| `name` | Yes | Released | Person's display name |
| `headline` | No | Released | Professional title or short descriptor |
| `email` | No | Released | Email address |
| `phone` | No | Released | Telephone number |
| `location` | No | Released | City, region, or country |
| `website` | No | Released | Personal or professional website |
| `linkedin` | No | Released | LinkedIn URL or profile path |
| `github` | No | Released | GitHub URL or profile path |
| `scholar` | No | Released | Google Scholar profile URL or identifier |
| `orcid` | No | `v0.2.0` development | ORCID identifier or profile URL |

Whitespace-only values should be treated as missing.

### Required-field validation

The `name` field is required before rendering a dossier header or letterhead.

A missing name should produce an error that:

- names the missing key;
- identifies the command that required it;
- shows a minimal correction example.

Optional fields must not produce empty separators or blank lines.

## Letter metadata

### `\CDossierLetterSetup`

```latex
\CDossierLetterSetup{
  date                   = {\today},
  recipient-name         = {Hiring Manager},
  recipient-title        = {Director of Analytics},
  recipient-organization = {Example Organization},
  recipient-address      = {123 Example Street\\Toronto, Ontario},
  subject                = {Application for the Data Scientist Position},
  salutation             = {Dear Hiring Manager,},
  closing                = {Sincerely,}
}
```

### Letter keys

| Key | Required | Default or behavior |
|---|---:|---|
| `date` | No | `\today` |
| `recipient-name` | No | Omitted when empty |
| `recipient-title` | No | Omitted when empty |
| `recipient-organization` | No | Omitted when empty |
| `recipient-address` | No | Omitted when empty; may contain `\\` |
| `subject` | No | Entire subject line omitted when empty |
| `salutation` | No | `Dear Hiring Manager,` |
| `closing` | No | `Sincerely,` |

The recipient block must collapse cleanly when one or more optional fields are absent.

## PDF document metadata

Both classes derive the PDF's document metadata from the shared profile. Nothing
needs to be called; the values are applied automatically at `\begin{document}`.

| PDF field | Derived from | Résumé value | Letter value |
|---|---|---|---|
| `/Title` | `name` | `Résumé – <name>` | `Cover Letter – <name>` |
| `/Author` | `name` | `<name>` | `<name>` |
| `/Lang` | fixed | `en` | `en` |

The document type is part of the title so that a résumé and a cover letter built
from one profile are distinguishable in a viewer's tab bar, in document
properties, and in a file manager.

When `name` is absent, `/Title` and `/Author` are left unset. `\MakeCDossierHeader`
and `\MakeCDossierLetterhead` already error on a missing `name`; metadata does not
add a second diagnostic.

`/Lang` is `en` because `v0.1.0` is English-only. There is no language key.

### Overriding the derived metadata

Set any field yourself with `\hypersetup` and it is used unchanged:

```latex
\documentclass{careerdossier-resume}

\hypersetup{
  pdftitle  = {Ada Lovelace — Data Scientist, Analytical Engine Division},
  pdfauthor = {A. Lovelace},
  pdflang   = {en-GB}
}

\CDossierSetup{ name = {Ada Lovelace} }
```

A field you set is never overwritten, and the order does not matter — the
`\hypersetup` may appear before or after `\CDossierSetup`. Fields you do not set
are still derived, so overriding `pdftitle` alone leaves `/Author` and `/Lang`
in place.

Other `hyperref` metadata (`pdfsubject`, `pdfkeywords`, …) is untouched; set it
with `\hypersetup` as usual.

## Public commands

### `\MakeCDossierHeader`

```latex
\MakeCDossierHeader
```

Renders the résumé identity block using shared profile metadata.

Expected behavior:

- validates `name`;
- renders `headline` only when present;
- renders available contact fields;
- inserts separators only between rendered fields;
- creates links for supported contact fields;
- does not add page numbers.

### `\MakeCDossierLetterhead`

```latex
\MakeCDossierLetterhead
```

Renders the cover-letter opening material:

1. shared sender identity;
2. date;
3. recipient block;
4. optional subject;
5. salutation.

The exact spacing belongs to the letter class, not to the shared metadata package.

### `\MakeCDossierClosing`

```latex
\MakeCDossierClosing
```

Renders:

1. the configured closing;
2. suitable signature space;
3. the profile `name`.

This command validates that `name` exists.

### `\CDossierSection`

```latex
\CDossierSection{Experience}
```

Creates a résumé section heading using the semantic section style and class-controlled spacing.

The argument is user-visible text. The command does not automatically translate arbitrary section titles.

### `CDossierEntry`

```latex
\begin{CDossierEntry}[
  title        = {Data Scientist},
  organization = {Example Organization},
  location     = {Toronto, Ontario},
  dates        = {2024--Present}
]
  Entry content.
\end{CDossierEntry}
```

Entry keys:

| Key | Required | Purpose |
|---|---:|---|
| `title` | Yes | Position, degree, award, or entry title |
| `organization` | No | Employer, institution, or organization |
| `location` | No | City, region, country, or remote status |
| `dates` | No | Date or date range |

Named keys are preferred over positional arguments because they are self-documenting and can be extended without changing the meaning of existing arguments.

Missing optional keys must be omitted without leaving visible punctuation or spacing artifacts.

The environment controls the entry heading and local spacing but does not force bullet content.

### `CDossierItemize`

```latex
\begin{CDossierItemize}
  \item First accomplishment.
  \item Second accomplishment.
\end{CDossierItemize}
```

Provides a résumé-appropriate itemized list with controlled indentation and spacing.

Users should prefer this environment over globally redefining `itemize`.

## Public field accessors

These commands are intended mainly for advanced users and shared components.

### `\CDossierPrintField`

```latex
\CDossierPrintField{name}
```

Prints the stored value of a profile field.

For an absent optional field, it should print nothing.

For an unknown field name, it should produce an actionable error.

### `\CDossierIfFieldTF`

```latex
\CDossierIfFieldTF{phone}
  {Phone is present.}
  {Phone is absent.}
```

Executes the first branch when the profile field exists and is nonblank; otherwise it executes the second branch.

The two branches are long, so they may contain `\par` or full paragraphs.

### `\CDossierFieldValue`

```latex
\CDossierFieldValue{email}
```

Expands to the stored value of a profile field, or to nothing when the field is absent. It does not typeset and does not validate the field name.

This accessor is expandable and is intended mainly for shared components that need the raw value, for example to build a link target. Prefer `\CDossierPrintField` for ordinary typesetting.

## Hyperlink behavior

When present:

- `email` should use a `mailto:` link;
- `website`, `linkedin`, `github`, and `scholar` should use web links;
- printed text should remain readable in monochrome;
- URLs should be breakable rather than extending beyond the margin.

The class must not assume that a displayed URL includes a protocol. The implementation should normalize links or clearly document the required input format.

## Typography roles

The typography package may expose semantic style commands for internal and advanced use:

```latex
\CDossierNameStyle
\CDossierHeadlineStyle
\CDossierSectionStyle
\CDossierEntryTitleStyle
\CDossierBodyStyle
\CDossierMutedStyle
```

These commands describe meaning rather than a particular font family, weight, or size.

Their visual definitions may evolve before `v1.0.0`.

## `v0.2.0` academic API contract

This section does not describe released behavior. The academic CV, its ORCID
profile field, manual publications, optional BibLaTeX integration, and the
academic letter family are implemented on the development branch. The
implementation preserves the existing résumé and industry-letter interface
unless an incompatibility is separately approved and documented.

The supported development examples map directly to the academic interfaces:

| Interface | Complete example | Build command |
|---|---|---|
| Academic CV and dependency-free manual publications | `examples/academic/cv-academic.tex` | `make academic-cv` |
| Optional BibLaTeX/Biber profile | `examples/academic/cv-bibliography.tex` | `make academic-bibliography` |
| Academic cover-letter family | `examples/academic/letter-academic.tex` | `make academic-letter` |

`make bibliography-test` runs the focused Biber ordering, identifier-precedence,
and extracted-text baseline. `latexmk` invokes Biber automatically for the
external-bibliography example.

### Academic CV class

Load the academic CV with:

```latex
\documentclass[
  fontsize=11pt,
  density=standard
]{careerdossier-cv}
```

The class accepts the same value sets as the résumé class:

| Option | Accepted values | CV default |
|---|---|---|
| `fontsize` | `10pt`, `11pt` | `11pt` |
| `density` | `compact`, `standard` | `standard` |

US Letter paper, English, and the monochrome theme remain fixed. Unsupported
options or values must produce an actionable class error rather than being
ignored.

The first page renders the ordinary dossier header in the document body. Page
numbers appear on every page, and pages after the first receive a simple running
header derived from `name`; contact information must not exist only in running
material. The running header and page number are fixed CV behavior in `v0.2.0`,
not new user-configurable style options.

The CV reuses the existing public content interface:

```latex
\MakeCDossierHeader
\CDossierSection{Academic Appointments}

\begin{CDossierEntry}[
  title        = {Assistant Professor},
  organization = {Example University},
  location     = {Toronto, Ontario},
  dates        = {2024--Present}
]
  \begin{CDossierItemize}
    \item Research and teaching summary.
  \end{CDossierItemize}
\end{CDossierEntry}
```

Education, appointments, research, teaching, grants, awards, presentations, and
service use `CDossierEntry`; `v0.2.0` does not add one command per section type.
This keeps content semantic without reviving the prototype-only
`\EducationItem`, `\GrantItem`, or `\PresentationItem` interfaces.

### Academic profile metadata

The shared profile gains one key:

| Key | Required | Purpose |
|---|---:|---|
| `orcid` | No | ORCID identifier or profile URL |

`scholar` remains the existing optional Google Scholar key. A CV may use both:

```latex
\CDossierSetup{
  name    = {Amir Sadeghi},
  scholar = {https://scholar.google.com/citations?user=example},
  orcid   = {0000-0002-1825-0097}
}
```

ORCID must be displayed as ordinary text with a descriptive `ORCID:` label and
a web link. A bare identifier is normalized to an `https://orcid.org/` target;
a complete URL is used as supplied. Scholar and ORCID are omitted independently
when blank and must not leave separators, blank lines, or icon-only content.

The CV derives `/Title` as `Curriculum Vitae – <name>`, `/Author` from `name`,
and `/Lang` as `en`, subject to the existing `\hypersetup` precedence rule.

### Manual publication entries

Manual publications require no bibliography package or Biber run:

```latex
\CDossierSection{Publications}

\begin{CDossierPublications}
  \CDossierPublication{
    authors = {Amir Sadeghi and Jane Example},
    title   = {A Demonstration Article},
    venue   = {Journal of Examples},
    date    = {2026},
    doi     = {10.9999/example.2026.1}
  }
\end{CDossierPublications}
```

`CDossierPublications` creates a numbered list in source order and resets its
counter on entry. `\CDossierPublication` is valid only inside that environment.

| Key | Required | Purpose |
|---|---:|---|
| `authors` | Yes | Display-order author list |
| `title` | Yes | Publication title |
| `venue` | No | Journal, book, conference, or publisher |
| `date` | No | Year or display date |
| `doi` | No | DOI value or complete DOI URL |
| `url` | No | Fallback public URL |
| `note` | No | Short status or contribution note |

Missing optional values must collapse cleanly. When both `doi` and `url` are
present, DOI is the displayed link and URL is the fallback; `v0.2.0` does not
offer a style option for changing that precedence. Each entry renders in this
order: authors, italic title, the comma-joined present `venue`/`date` values,
`note`, and the preferred visible identifier. Sentence punctuation is emitted
only around present groups, so absent optional fields leave no stray separators.

### Optional BibLaTeX and Biber integration

The CV class does not load `biblatex`. Opt in explicitly:

```latex
\documentclass{careerdossier-cv}
\usepackage{careerdossier-biblatex}

\addbibresource{publications.bib}
\CDossierHighlightAuthor{
  family = {Sadeghi},
  given  = {Amir}
}

\begin{document}
\nocite{*}
\printbibliography[title={Publications}]
\end{document}
```

The integration package loads and configures `biblatex`; standard BibLaTeX
commands remain the public resource-selection and printing interface. Its one
supported `v0.2.0` profile is fixed:

```text
backend=biber
style=numeric
sorting=ydnt
```

Entries are numbered, sorted year-descending/name/title, and show at most one
preferred public identifier in this order: DOI, e-print, URL. The package uses
monochrome link styling and must not redefine unrelated document lists or
headings globally.

`\CDossierHighlightAuthor` may be repeated for spelling or initial variants.
It bolds an exact BibLaTeX-parsed family/given-name pair in the bibliography and
does not alter citations. Both keys are required; an incomplete declaration
must produce an actionable package error.

Loading `careerdossier-biblatex` when `biblatex` is unavailable must report the
missing optional dependency and explain that the user may either install
BibLaTeX/Biber or use `CDossierPublications`. A CV that does not load the
integration package must build without `biblatex` or Biber.

### Academic cover-letter family

The academic family extends the existing class:

```latex
\documentclass[family=academic]{careerdossier-letter}
```

`family` accepts `industry` and `academic`; its default remains `industry`, so
existing documents are unchanged. The academic family reuses
`\CDossierLetterSetup`, `\MakeCDossierLetterhead`, and
`\MakeCDossierClosing`, including the current recipient, salutation, subject,
closing, and sender-metadata behavior. Optional recipient and academic profile
fields collapse independently.

The family may change letter-owned spacing and derives `/Title` as
`Academic Cover Letter – <name>`. Each academic-letter page has a print-oriented
footer: `name` at left and `Page n of N` at right. It does not introduce new
recipient keys or change the industry family's defaults. Unknown family values
must produce an actionable class error.

### Explicitly unsupported in `v0.2.0`

The academic release does not support:

- pdfLaTeX or LuaLaTeX;
- Farsi, bilingual, or RTL documents;
- A4 paper;
- color themes, font presets, icons, or bundled fonts;
- statement classes;
- alternate bibliography or citation styles;
- automatic import from ORCID, Scholar, DOI services, or external APIs; or
- a PDF/UA or broad ATS-compatibility claim.

### Compatibility with `v0.1.x`

The `v0.2.0` additions are intentionally additive:

- `careerdossier-resume` keeps its options, defaults, commands, and no-folio
  behavior;
- `careerdossier-letter` defaults to `family=industry` and retains its existing
  setup keys and English defaults;
- `orcid` is an optional shared-profile key, and existing profiles need no edit;
- the CV reuses the existing generic section, entry, and list interfaces; and
- bibliography behavior is activated only by loading
  `careerdossier-biblatex`.

Any implementation that requires a different public command, default, or
compatibility outcome must update this contract and `MIGRATION.md` with the
design decision before the behavior is merged.

## Colors and theme tokens

The monochrome theme may expose semantic tokens:

```latex
\CDossierPrimaryColor
\CDossierTextColor
\CDossierMutedColor
\CDossierRuleColor
\CDossierLinkColor
```

Users should not rely on the underlying color names or values as stable API before `v1.0.0`.

## Errors and warnings

### Errors

The implementation should stop compilation for:

- use under an unsupported engine;
- an unsupported class-option value;
- a missing required `name` when rendering identity content;
- an unknown public field or label name;
- a manual publication used outside `CDossierPublications`;
- a manual publication missing `authors` or `title`;
- an unknown manual-publication or preferred-author key;
- a preferred-author declaration missing `family` or `given`;
- loading `careerdossier-biblatex` when the optional BibLaTeX dependency is
  unavailable; and
- malformed key-value input that cannot be interpreted safely.

A missing BibLaTeX diagnostic must name BibLaTeX and Biber, recommend building
with `latexmk` after installation, and point to `CDossierPublications` as the
dependency-free alternative. A missing Biber executable is reported by the
standard BibLaTeX/`latexmk` toolchain rather than a separate TeX preflight.

### Warnings

The implementation may warn for:

- unusually long contact fields;
- a URL that cannot be normalized;
- metadata overwritten by a later setup call;
- fields accepted but not displayed by the active class.

Warnings should explain the likely effect and corrective action.

## Minimal résumé example

```latex
\documentclass{careerdossier-resume}

\CDossierSetup{
  name     = {Amir Sadeghi},
  headline = {Data Scientist},
  email    = {name@example.com},
  location = {Ontario, Canada}
}

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
    \item Developed a reproducible analytical workflow.
  \end{CDossierItemize}
\end{CDossierEntry}

\end{document}
```

## Minimal letter example

```latex
\documentclass{careerdossier-letter}

\CDossierSetup{
  name     = {Amir Sadeghi},
  headline = {Data Scientist},
  email    = {name@example.com},
  location = {Ontario, Canada}
}

\CDossierLetterSetup{
  recipient-name         = {Hiring Manager},
  recipient-organization = {Example Organization},
  subject                = {Application for the Data Scientist Position}
}

\begin{document}

\MakeCDossierLetterhead

I am writing to apply for the Data Scientist position.

\MakeCDossierClosing

\end{document}
```

## Stability policy

Before `v1.0.0`:

- breaking changes are allowed;
- public changes must be documented in `CHANGELOG.md`;
- renamed commands or keys should be recorded in `docs/MIGRATION.md`;
- public API changes must update this file in the same pull request.

After `v1.0.0`, incompatible changes should require a major-version release or a documented deprecation path.
