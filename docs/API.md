# CareerDossierTeX Public API

## Status

This document records the released public interface:

```text
Released: v0.4.0 — LuaLaTeX Transition and Tagged-PDF Preview
```

Sections that are not explicitly marked as planned describe released behavior.
Before `v1.0.0` the interface may still change between minor versions; such
changes are recorded in [`../CHANGELOG.md`](../CHANGELOG.md) and
[`MIGRATION.md`](MIGRATION.md).

The API is intentionally small. Internal helper commands are not public merely because they are technically accessible.

## Supported configuration

| Setting | `v0.4.0` support |
|---|---|
| Engine | LuaLaTeX only |
| Language | English |
| Paper | US Letter; A4 implemented for upcoming `v0.5.0` |
| Body font | Serif; opt-in sans implemented for upcoming `v0.5.0` |
| Theme | Monochrome; opt-in accent and print themes implemented for upcoming `v0.5.0` |
| Tagged structure | Opt-in, off by default |
| Résumé class | `careerdossier-resume` |
| CV class | `careerdossier-cv` |
| Letter class | `careerdossier-letter`, industry and academic families |
| Statement class | Default general-interest type plus six explicit types implemented for upcoming `v0.5.0` |
| Bibliography | Optional `careerdossier-biblatex` |
| Manual publications | `CDossierPublications` in `careerdossier-cv` |
| RTL or bilingual layout | Not supported |

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

or:

```latex
\documentclass{careerdossier-cv}
```

or, from the upcoming `v0.5.0` source:

```latex
\documentclass[type=research]{careerdossier-statement}
```

Do not depend on repository-specific paths such as:

```latex
\documentclass{classes/careerdossier-resume}
```

## Engine

LuaLaTeX is the sole supported engine as of `v0.4.0`. `careerdossier-typography`
performs the check and raises a fatal error naming LuaLaTeX under any other
engine. XeLaTeX and pdfLaTeX are unsupported; there is no compatibility mode and
no option to bypass the guard.

## Tagged structure (opt-in)

Tagged output is opt-in and off by default. It is enabled with the LaTeX kernel's
`\DocumentMetadata`, which must appear **before** `\documentclass`:

```latex
\DocumentMetadata{lang=en, tagging=on}
\documentclass{careerdossier-resume}
```

This introduces no CareerDossierTeX class option and no public command. The
tagging interface is the kernel's, not this package's, and is not covered by the
stability policy below.

When tagging is active the classes expose section headings, lists, paragraphs,
and links as structure, and mark decorative rules, contact separators, and
running page furniture as layout artifacts. When it is not active, output is
unchanged from the untagged path.

Tagged output is a tested preview for the four fixture profiles (industry
résumé, industry letter, academic CV, academic letter). It is not a PDF/UA,
WCAG, ATS, or general accessibility conformance claim. See
[`../README.md`](../README.md) and
[`guides/ats-extraction.md`](guides/ats-extraction.md) for the scope of what has
actually been verified.

## Résumé class

### Class declaration

```latex
\documentclass[
  fontsize=10pt,
  density=compact,
  paper=letter,
  bodyfont=serif,
  theme=monochrome
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

#### `paper` (upcoming `v0.5.0`)

Every CareerDossierTeX document class accepts:

```text
letter
a4
```

The default is `letter`, preserving existing output. `a4` selects an ISO A4
media box while retaining the class's established physical margins, font size,
spacing, and page-furniture design. Because A4 is slightly narrower and taller
than US Letter, line and page breaks may change. Unsupported values produce an
actionable class error.

#### `bodyfont` (upcoming `v0.5.0`)

Every CareerDossierTeX document class accepts:

```text
serif
sans
```

The default is `serif`, preserving the existing TeX Gyre Termes body and TeX
Gyre Heros headings. `sans` selects TeX Gyre Heros for the ordinary document
body while headings remain TeX Gyre Heros. The option does not change font
size, semantic typography roles, spacing, geometry, or page furniture.
Unsupported values produce an actionable class error. Arbitrary font names and
per-role font selection are not supported.

#### `theme` and `accent` (upcoming `v0.5.0`)

Every CareerDossierTeX document class accepts:

```text
theme=monochrome
theme=accent
theme=print
```

`monochrome` is the default. It preserves black link text and adds a thin black
PDF-annotation underline so links remain identifiable without color.
`accent` changes link text only; body text, headings, rules, spacing, and page
geometry remain unchanged. `print` renders black links without color, border,
or underline.

The `accent` theme also accepts one fixed named link color:

```text
accent=navy
accent=teal
accent=magenta
```

`navy` is the default. The `accent` value is accepted with every theme so class
option order does not matter, but it affects output only when `theme=accent`.
Arbitrary colors and per-field or per-role color keys are not supported.

| Accent | Hex value | Contrast on white | Lowest simulated CVD contrast |
|---|---:|---:|---:|
| `navy` | `#1B365D` | 12.12:1 | 11.48:1 |
| `teal` | `#005A5A` | 8.05:1 | 7.47:1 |
| `magenta` | `#8A1C5A` | 8.77:1 | 7.84:1 |

The recorded checks use the WCAG relative-luminance calculation against white
plus deterministic full-severity protanopia, deuteranopia, and tritanopia
simulation. Grayscale preserves the listed base contrast. This is a focused
palette review, not a WCAG, PDF/UA, or broad accessibility-conformance claim.
Visible URLs, identifiers, and descriptive labels remain present; authors of
custom `\href` links should likewise use link text that identifies its
destination rather than relying on color alone.

### Fixed settings

The following remains fixed and is not accepted as a user option:

```text
language=english
```

It is better to reject or omit an unsupported option than silently ignore it.

## Letter class

### Class declaration

```latex
\documentclass[family=industry, paper=letter, bodyfont=serif, theme=monochrome]{careerdossier-letter}
```

`family` accepts `industry` and `academic`; the default is `industry`. `paper`
uses the shared `letter|a4` contract above and defaults to `letter`. `bodyfont`
uses the shared `serif|sans` contract above and defaults to `serif`. `theme` and
`accent` use the shared contracts above. The following setting remains fixed:

```text
language=english
```

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
classes. The optional `orcid` key was introduced in `v0.2.0`; the other keys
remain compatible with the released industry classes.

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
| `orcid` | No | `v0.2.0` | ORCID identifier or profile URL |

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

This section describes the academic CV, its ORCID profile field, manual
publications, optional BibLaTeX integration, and the academic letter family
released in `v0.2.0`. These additions preserve the existing résumé and
industry-letter interface.

The shipped examples map directly to the academic interfaces:

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
  density=standard,
  paper=letter,
  bodyfont=serif,
  theme=monochrome
]{careerdossier-cv}
```

The class accepts the same value sets as the résumé class:

| Option | Accepted values | CV default |
|---|---|---|
| `fontsize` | `10pt`, `11pt` | `11pt` |
| `density` | `compact`, `standard` | `standard` |
| `paper` | `letter`, `a4` | `letter` |
| `bodyfont` | `serif`, `sans` | `serif` |
| `theme` | `monochrome`, `accent`, `print` | `monochrome` |
| `accent` | `navy`, `teal`, `magenta` | `navy` |

English remains fixed. Unsupported options or values must produce an actionable
class error rather than being ignored.

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

### Historical exclusions in `v0.2.0`

The `v0.2.0` academic release did not support:

- XeLaTeX or pdfLaTeX (as of `v0.4.0`; `v0.2.x` was XeLaTeX-only);
- Farsi, bilingual, or RTL documents;
- A4 paper;
- color themes, font presets, icons, or bundled fonts;
- statement classes;
- alternate bibliography or citation styles;
- automatic import from ORCID, Scholar, DOI services, or external APIs; or
- a PDF/UA or broad ATS-compatibility claim.

A4 paper and statement classes are implemented in repository source for the
upcoming `v0.5.0`; this historical list describes the scope of `v0.2.0` only.

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

## `v0.5.0` statement API

> **Status:** implemented for the upcoming `v0.5.0` release. The current
> published release remains `v0.4.0`; these interfaces are available from the
> repository source and become released behavior with `v0.5.0`.

### Class and statement types

All statement documents use one class with an optional `type` option and the
shared optional `paper`, `bodyfont`, `theme`, and `accent` settings:

```latex
\documentclass[type=research, paper=letter, bodyfont=serif, theme=monochrome]{careerdossier-statement}
```

When `type` is omitted, the class selects `general-interest`; it requires no
profile fields beyond `name` and `email`. Supplying `type` without a value or
using an unsupported value produces an actionable class error. The accepted
values, page-one titles, and continuation-header titles are:

| `type` value | Default title | Default running title |
|---|---|---|
| `general-interest` (default) | `General Interest Statement` | `General Interest Statement` |
| `research` | `Research Statement` | `Research Statement` |
| `teaching` | `Teaching Statement` | `Teaching Statement` |
| `teaching-philosophy` | `Statement of Teaching Philosophy` | `Teaching Philosophy` |
| `diversity` | `Statement of Contributions to Equity, Diversity, Inclusion, and Accessibility` | `EDIA Statement` |
| `artist` | `Artist Statement` | `Artist Statement` |
| `purpose` | `Statement of Purpose` | `Statement of Purpose` |

The type selects a title, continuation-page identification, and required-field
contract. It does not generate or enforce content sections. One class avoids
duplicating geometry and page behavior across statement document models.

### Statement layout

The initial statement release starts from the academic cover-letter design:

- LuaLaTeX and English output;
- `paper=letter|a4`, defaulting to US Letter and preserving the academic
  letter's physical margins on A4;
- `bodyfont=serif|sans`, defaulting to the current TeX Gyre Termes body and
  retaining TeX Gyre Heros headings in both modes;
- the shared `theme=monochrome|accent|print` and
  `accent=navy|teal|magenta` link-only appearance contract;
- 11 pt body text;
- academic-letter margins and prose paragraph rhythm;
- a centered identity block in the body on page one;
- no running header on page one;
- a centered `<name> -- <running title>` header from page two; and
- a centered `Page N of M` folio on every page.

Page furniture is class-owned and not user-configurable. The statement class
uses the same paper and body-font options and defaults as the résumé, CV, and
letter classes. Named or per-role font combinations remain future design work
in issue #120. Icons remain deferred.

### Statement metadata

Document-specific values use a separate setup command:

```latex
\CDossierStatementSetup{
  title               = {Research Statement},
  running-title       = {Research Statement},
  subtitle            = {Reliable scientific computing},
  application-context = {Application for Assistant Professor of Computational Science},
  application-id      = {APP-2026-0042}
}
```

| Key | Required | Default or behavior |
|---|---:|---|
| `title` | No | Default selected by the explicit or default `type`; a nonblank value overrides it |
| `running-title` | No | Short default selected by the explicit or default `type`; a nonblank value overrides it independently of `title` |
| `subtitle` | No | One short line beneath the title; omitted when blank |
| `application-context` | No | Separate contextual line; omitted when blank |
| `application-id` | No | Rendered as labelled text with application context; omitted when blank |

These values describe one statement, so they do not become shared
`\CDossierSetup` profile keys. Whitespace-only values count as absent. Repeated
setup calls follow the existing metadata convention: later values overwrite
earlier values and may warn consistently with the other setup commands.

Current affiliation is reusable identity data, not application-specific state,
so `v0.5.0` adds one shared-profile key:

| Profile key | Required | Purpose |
|---|---:|---|
| `affiliation` | For `research` statements only | Current institution, organization, studio, or independent-practice description |

Other statement types may display `affiliation` when present. Existing profiles
remain valid because no released class requires or displays this new field.

### Required profile fields and displayed contacts

Every statement requires the shared `name` and `email` profile fields. The
header validates the following additional type-specific requirements and
renders only the listed optional contacts:

| Type | Additional required field | Optional displayed fields |
|---|---|---|
| `general-interest` (default) | None | `phone`, `website`, `affiliation` |
| `research` | profile `affiliation` | `phone`, `website`, `scholar`, `orcid` |
| `teaching` | None | `phone`, `website`, `affiliation` |
| `teaching-philosophy` | None | `phone`, `website`, `affiliation` |
| `diversity` | None | `phone`, `website`, `affiliation` |
| `artist` | profile `website` | `phone`, `affiliation` |
| `purpose` | None | `phone`, `website`, `affiliation` |

For `artist`, `website` may identify a personal site, portfolio, Instagram
profile, or comparable public presence; it remains the existing web-link field
rather than a new platform-specific key. Shared `headline`, `location`,
`linkedin`, and `github` values remain available to other dossier documents but
are not displayed by the statement header. Their presence must not trigger a
warning because a shared profile is expected to contain fields for multiple
document types.

### First-page identity order

`\MakeCDossierStatementHeader` validates the active type and emits present
items in this fixed logical order:

1. profile `name`;
2. selected statement title;
3. optional one-line `subtitle`;
4. optional or required profile `affiliation`;
5. optional `application-context`, followed by labelled `application-id` when
   both are present;
6. required `email`, followed by the active type's present optional contacts.

Application context is not a second subtitle, and it is not mixed into the
contact list. Each optional line owns its spacing, so an absent value leaves no
blank line. Contact and context separators are inserted only between present
items and are layout artifacts in tagged output. The selected page-one `title`
drives PDF document metadata; the shorter `running-title` exists only for page
furniture and does not replace the full title in meaningful content.

### Author content and headings

The class introduces no command for research aims, teaching themes, EDI
commitments, artistic methods, or statement-of-purpose paragraphs. Authors
write ordinary prose and may choose standard LaTeX `\section*` and
`\subsection*` headings when the application and content benefit from them.
The class does not force headings, a page count, or a type-specific narrative
schema.

The six canonical typed examples use the maintainer-supplied research reports to
demonstrate recognizable structures. Each example naturally spans two pages
under the default design so continuation furniture is visible.

The example sources are:

| Type | Source path |
|---|---|
| `research` | `examples/statements/research-statement.tex` |
| `teaching` | `examples/statements/teaching-statement.tex` |
| `teaching-philosophy` | `examples/statements/teaching-philosophy-statement.tex` |
| `diversity` | `examples/statements/diversity-statement.tex` |
| `artist` | `examples/statements/artist-statement.tex` |
| `purpose` | `examples/statements/statement-of-purpose.tex` |

### Tagged structure

Tagged statements use the existing opt-in kernel interface:

```latex
\DocumentMetadata{lang=en, tagging=on}
\documentclass[type=research]{careerdossier-statement}
```

The first-page title, ordinary paragraphs, standard section headings, and links
remain meaningful structure in source order. Running headers, folios, and
contact separators are layout artifacts. This design extends the academic
letter's approach; it does not establish PDF/UA, WCAG, or general ATS
conformance for arbitrary statements.

### Minimal examples by type

General-interest is the default and needs only the shared `name` and `email`
fields:

```latex
\documentclass{careerdossier-statement}
\CDossierSetup{name={Ada Lovelace}, email={ada@example.com}}
\begin{document}
\MakeCDossierStatementHeader
This statement introduces work and interests without a type-specific contract.
\end{document}
```

Research requires affiliation:

```latex
\documentclass[type=research]{careerdossier-statement}
\CDossierSetup{
  name={Ada Lovelace}, email={ada@example.com},
  affiliation={Example University}, orcid={0000-0002-1825-0097}
}
\begin{document}
\MakeCDossierStatementHeader
My research develops reliable methods for computational inquiry.
\end{document}
```

Teaching may add an optional affiliation:

```latex
\documentclass[type=teaching]{careerdossier-statement}
\CDossierSetup{
  name={Ada Lovelace}, email={ada@example.com},
  affiliation={Example University}
}
\begin{document}
\MakeCDossierStatementHeader
My teaching connects transparent reasoning with purposeful practice.
\end{document}
```

Teaching philosophy has a distinct title and type but the same metadata
contract as teaching:

```latex
\documentclass[type=teaching-philosophy]{careerdossier-statement}
\CDossierSetup{name={Ada Lovelace}, email={ada@example.com}}
\begin{document}
\MakeCDossierStatementHeader
I understand learning as an active and reflective process.
\end{document}
```

Diversity may identify the application separately from the subtitle:

```latex
\documentclass[type=diversity]{careerdossier-statement}
\CDossierSetup{name={Ada Lovelace}, email={ada@example.com}}
\CDossierStatementSetup{application-context={Application to Example University}}
\begin{document}
\MakeCDossierStatementHeader
Inclusive academic practice requires transparent expectations and feedback.
\end{document}
```

Artist requires a web presence:

```latex
\documentclass[type=artist]{careerdossier-statement}
\CDossierSetup{name={Ada Lovelace}, email={ada@example.com}, website={portfolio.example.com}}
\begin{document}
\MakeCDossierStatementHeader
My practice examines the relationship between material and computation.
\end{document}
```

Purpose may carry both application context and an ID:

```latex
\documentclass[type=purpose]{careerdossier-statement}
\CDossierSetup{name={Ada Lovelace}, email={ada@example.com}}
\CDossierStatementSetup{
  application-context = {Application to the MSc in Computational Science},
  application-id      = {12345678}
}
\begin{document}
\MakeCDossierStatementHeader
I seek advanced study in reliable scientific computing.
\end{document}
```

### Compatibility analysis

The implementation is additive. It introduces a new class, one optional shared
`affiliation` profile key, one new class-scoped setup command, and one new
rendering command. It does not change the options, output, or defaults of the
résumé, CV, or letter classes. Existing shared profiles remain valid without
editing; statement-specific required fields are checked only when
`\MakeCDossierStatementHeader` is used.

Because no earlier statement API was released, the statement type names and setup
keys need no migration or deprecation path.

### Verification coverage

The committed smoke, layout, extraction, and tagging fixtures cover all six
types, required and invalid inputs, optional-field collapse, continuation page
furniture, PDF metadata, source-order extraction, and tagged/untagged output.
The six complete two-page examples provide the visual review surface.

## Colors and theme tokens

All themes expose the same semantic tokens:

```latex
\CDossierPrimaryColor
\CDossierTextColor
\CDossierMutedColor
\CDossierRuleColor
\CDossierLinkColor
```

Only `\CDossierLinkColor` varies under the `accent` theme. The other tokens
retain the established monochrome palette. Users should not rely on the
underlying internal color names as stable API before `v1.0.0`.

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
