# CareerDossierTeX Public API

## Status

This document defines the proposed public interface for:

```text
v0.1.0 — English Industry Dossier
```

Until the implementation, examples, and CI builds are complete, treat this API as provisional. Before release, remove any command or option that is not implemented and tested.

The API is intentionally small. Internal helper commands are not public merely because they are technically accessible.

## Supported configuration

| Setting | `v0.1.0` support |
|---|---|
| Engine | XeLaTeX only |
| Language | English |
| Paper | US Letter |
| Theme | Monochrome |
| Résumé class | `careerdossier-resume` |
| Letter class | `careerdossier-letter` |
| Bibliography | Not supported |
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

This command stores profile metadata for use by both document classes.

### Profile keys

| Key | Required | Purpose |
|---|---:|---|
| `name` | Yes | Person's display name |
| `headline` | No | Professional title or short descriptor |
| `email` | No | Email address |
| `phone` | No | Telephone number |
| `location` | No | City, region, or country |
| `website` | No | Personal or professional website |
| `linkedin` | No | LinkedIn URL or profile path |
| `github` | No | GitHub URL or profile path |
| `scholar` | No | Google Scholar profile URL or identifier |

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

### `\CDossierLabel`

```latex
\CDossierLabel{experience}
```

Returns a fixed interface label from the active language table.

In `v0.1.0`, only English labels are available. This command exists to prevent English text from being duplicated across classes and components.

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
- malformed key-value input that cannot be interpreted safely.

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
