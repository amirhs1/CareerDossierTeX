# CareerDossierTeX Architecture

## Purpose

CareerDossierTeX is a modular XeLaTeX toolkit for producing related career documents from shared profile data.

The architecture separates:

- user metadata;
- document content;
- reusable components;
- typography;
- visual theme;
- language labels;
- document-specific page layout;
- build and test automation.

This separation allows the résumé and cover letter to share identity and contact behavior without forcing them to share the same geometry or content model.

## Architectural goals

1. Keep the public API small and explicit.
2. Separate content from presentation.
3. Reuse profile metadata across document types.
4. Make optional fields safe and predictable.
5. Keep document classes focused on page-level behavior.
6. Use semantic typography and theme roles.
7. Leave extension points for academic and multilingual releases.
8. Reject unsupported configurations rather than silently ignoring them.
9. Keep source order logical for text selection and extraction.
10. Make supported examples reproducible locally and in CI.

## Phase 1 module graph

```text
careerdossier-resume.cls
        │
        ├── careerdossier-components.sty
        ├── careerdossier-typography.sty
        ├── careerdossier-theme.sty
        └── careerdossier-base.sty
                    │
                    └── careerdossier-i18n.sty

careerdossier-letter.cls
        │
        ├── careerdossier-components.sty
        ├── careerdossier-typography.sty
        ├── careerdossier-theme.sty
        └── careerdossier-base.sty
                    │
                    └── careerdossier-i18n.sty
```

The exact package-loading order may differ when implementation requires it, but dependency direction should remain one-way. Shared packages must not depend on the résumé or letter classes.

## Data flow

```text
profile file
    │
    ▼
\CDossierSetup
    │
    ▼
careerdossier-base.sty
    │
    ├── validation
    ├── field lookup
    └── presence tests
            │
            ▼
careerdossier-components.sty
    │
    ├── identity block
    ├── contact line
    ├── links
    └── entry primitives
            │
            ▼
document class
    │
    ├── résumé geometry and spacing
    └── letter geometry and prose flow
            │
            ▼
PDF output
```

Letter-specific metadata follows the same pattern:

```text
\CDossierLetterSetup
    │
    ▼
letter metadata storage
    │
    ▼
recipient block, subject, salutation, closing
    │
    ▼
careerdossier-letter.cls
```

## File responsibilities

### `careerdossier-base.sty`

Owns shared state and validation.

Responsibilities:

- define `\CDossierSetup`;
- store profile fields;
- expose supported field access;
- test whether fields are present;
- validate required fields;
- report actionable errors and warnings;
- provide shared key-value infrastructure.

It must not define:

- résumé margins;
- letter margins;
- résumé section spacing;
- document-specific page styles;
- final visual typography values.

This package is analogous to a small data model or configuration module. It stores values and enforces basic rules but does not decide how a document page looks.

### `careerdossier-i18n.sty`

Owns fixed interface labels and language abstraction.

Phase 1 responsibilities:

- provide English labels;
- expose `\CDossierLabel`;
- centralize label lookup;
- provide neutral wrappers that can later support direction changes.

Phase 1 does not implement:

- Farsi fonts;
- RTL page layout;
- bilingual documents;
- automatic translation of user content.

In Phase 3, the package should grow translation tables and direction helpers without requiring duplicated language-specific classes.

### `careerdossier-typography.sty`

Owns engine checks and semantic text roles.

Responsibilities:

- require XeLaTeX;
- load `fontspec`;
- select portable default fonts;
- define semantic styles such as name, headline, section, entry title, body, and muted text;
- provide extension points for future font presets.
- set `\XeTeXgenerateactualtext=1`;
- apply the Latin ligature-suppression and lining-numbers defaults;
- resolve the default font deliberately (fontconfig family name, or an explicit
  `Path=`), not by bare file name — bare-file-name loading of the tex-gyre OTFs
  is not resolved by fontspec on stock XeLaTeX;
- record the tested font version for reproducibility.

Typography commands should express meaning:

```latex
\CDossierSectionStyle
```

not a specific implementation:

```latex
\Large\bfseries
```

The semantic layer allows fonts and sizes to change without rewriting every component.

### `careerdossier-theme.sty`

Owns visual tokens that are not page geometry.

Responsibilities:

- monochrome colors;
- rule colors and thicknesses;
- link appearance;
- print-safe contrast;
- future theme extension points.

The theme package should use semantic tokens such as:

```latex
\CDossierTextColor
\CDossierMutedColor
\CDossierRuleColor
\CDossierLinkColor
```

It must not determine résumé margins or letter paragraph spacing.

### `careerdossier-components.sty`

Owns reusable rendered pieces.

Responsibilities:

- identity block;
- contact line;
- optional-field separator handling;
- hyperlink wrappers;
- common entry-heading primitives;
- date and location primitives;
- shared letterhead pieces that do not impose full page geometry.

A critical invariant is:

```text
email | phone | website
```

becoming:

```text
email | website
```

when `phone` is absent.

The component layer should collect present fields first and insert separators only between rendered items. It should not print a separator after every potential field and then try to remove extras.

### `careerdossier-resume.cls`

Owns résumé-specific document behavior.

Responsibilities:

- load an appropriate base class;
- set US Letter geometry;
- process supported class options;
- control compact or standard density;
- disable page numbers by default;
- define résumé section spacing;
- define entry layout;
- define résumé list behavior;
- preserve logical source and extraction order.

The résumé class may call shared components, but reusable contact or identity logic should not be implemented directly inside the class.

### `careerdossier-letter.cls`

Owns industry cover-letter behavior.

Responsibilities:

- set letter geometry;
- define prose-friendly paragraph and page-breaking behavior;
- render date and recipient blocks;
- render an optional subject;
- render salutation and closing;
- reuse the shared sender identity;
- support one-page and multi-page letters without résumé-specific compression.

The letter class should not reuse résumé geometry merely because both documents share a header.

## Public versus internal API

### Public API

Public commands, options, keys, and environments are documented in `docs/API.md`.

Examples include:

```latex
\CDossierSetup
\CDossierLetterSetup
\MakeCDossierHeader
\MakeCDossierLetterhead
\MakeCDossierClosing
\CDossierSection
\begin{CDossierEntry}
\begin{CDossierItemize}
```

A command becomes public only when it is:

1. intentionally named and documented;
2. used by a supported example;
3. covered by a repeatable test;
4. included in release notes when introduced.

### Internal API

Internal implementation commands should use a clearly private naming convention.

Recommended `expl3` pattern:

```latex
\__cdossier_<module>_<action>:<signature>
```

Examples:

```latex
\__cdossier_base_validate_name:
\__cdossier_components_print_contact_line:
```

Internal commands:

- may change without migration notes;
- should not appear in examples;
- should not be described as supported;
- should remain scoped to the package that owns them when practical.

## Key-value design

Prefer `expl3` and `l3keys2e` or an equivalent modern LaTeX3 key-value interface for:

- class options;
- profile metadata;
- letter metadata;
- validation;
- controlled defaults.

Key families should be separated by responsibility, for example:

```text
cdossier/profile
cdossier/letter
cdossier/resume
cdossier/entry
```

Avoid one global key family that mixes profile fields, typography, page geometry, and future language settings.

## State and grouping

Metadata is persistent document state. Local visual changes should remain grouped.

General rule:

- profile and letter setup values are global for the document;
- temporary formatting changes are local to their component or environment;
- entry and list environments must not leak spacing or font changes into following content.

This is one place where LaTeX differs from ordinary object-oriented code: grouping controls scope, expansion timing matters, and assignments may be local or global depending on how they are made.

## Language strategy

### Phase 1

- English labels only;
- no RTL claims;
- no separate English-specific classes;
- user-provided content remains the user's responsibility.

### Phase 3

Add:

```text
language=english|farsi|bilingual
main-language=english|farsi
```

The same classes should support different languages through shared abstractions.

Preferred:

```latex
\documentclass[language=farsi]{careerdossier-cv}
```

Avoid:

```latex
\documentclass{careerdossier-cv-farsi}
```

unless a future document model is genuinely different rather than merely translated or mirrored.

Mixed-direction fields such as email addresses, URLs, ORCID identifiers, and Latin numbers must remain LTR inside RTL documents.

## Typography strategy

The project should ship with fonts available in a normal TeX Live installation.

Custom presets such as Merriweather or Neuton belong to a later release after:

- the public API is stable enough;
- fallbacks are documented;
- examples are tested on a clean environment.

Typography should be controlled through semantic roles rather than repeated font commands in classes and components.

## Theme strategy

Phase 1 includes one monochrome theme.

Future themes should replace semantic tokens rather than rewrite components. Components ask for a meaning such as "muted text" or "rule color"; the active theme provides the value.

Page geometry is not a theme responsibility.

## Optional-field rendering

Optional metadata must be handled structurally.

Recommended approach:

1. inspect fields in desired display order;
2. append each present field to a sequence;
3. render the sequence with a separator;
4. omit the entire line when the sequence is empty.

This avoids output such as:

```text
email | | website
```

The same principle applies to recipient blocks, subject lines, dates, and entry metadata.

## Error and warning strategy

Errors should be:

- early when possible;
- specific;
- actionable;
- tied to a public command or key.

Example structure:

```text
CareerDossierTeX error:
Required profile field 'name' is missing.

Add:
\CDossierSetup{name={Your Name}}
before \MakeCDossierHeader.
```

Warnings should identify:

- what was unusual;
- what output may be affected;
- what the user can change.

Do not expose raw low-level TeX errors when the package can detect the problem first.

## Text extraction and accessibility

The source order should follow reading order.

Avoid layout techniques that visually position content in an order different from the underlying PDF text when a simpler structure is available.

Phase 1 acceptance checks should include:

```bash
pdftotext examples/industry/resume-english.pdf \
  build/resume-english.txt
```

The extracted text should remain understandable and follow the visible document order.

### Font and text-layer policy

The generated PDF's text layer is a first-class deliverable, owned jointly by
`careerdossier-typography.sty` (how glyphs map back to characters) and the
classes (reading order). The policy, with rationale and tests, lives in
[`docs/guides/ats-extraction.md`](guides/ats-extraction.md). In summary:

- compile with XeLaTeX and set `\XeTeXgenerateactualtext=1` in the typography
  module, early;
- disable common/contextual/discretionary/historic ligatures in the Latin
  default so `ffi`/`ffl` sequences extract as separate letters;
- treat each font file, version, and OpenType-feature combination as testable
  code; record the tested font version;
- keep meaningful content in source (reading) order; never rely on visual
  repositioning that a parser must undo.

### Tagged PDF (status)

Tagged PDF is not claimed for the XeLaTeX build in Phase 1. Current XeTeX does not
support real interword spaces in the tagging pipeline, so no PDF/UA conformance is
asserted. The classes stay tagging-compatible; the limitation is documented rather
than silently ignored. See the guide's tagging section before adding any
tagging-related dependency.

## Repository layout

At the end of `v0.1.0`:

```text
CareerDossierTeX/
├── careerdossier-base.sty
├── careerdossier-i18n.sty
├── careerdossier-typography.sty
├── careerdossier-theme.sty
├── careerdossier-components.sty
├── careerdossier-resume.cls
├── careerdossier-letter.cls
├── examples/
│   ├── profiles/
│   │   └── profile-english.tex
│   └── industry/
│       ├── resume-english.tex
│       └── letter-industry.tex
├── docs/
│   ├── API.md
│   ├── ARCHITECTURE.md
│   ├── ROADMAP.md
│   ├── MIGRATION.md
│   └── guides/
│       └── ats-extraction.md
├── tests/
│   ├── regression/
│   ├── smoke/
│   ├── layout/
│   └── extraction/
│       ├── extraction-torture.tex
│       ├── extraction-torture.expected.txt
│       └── run.sh
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── workflows/
│   │   └── build.yml
│   └── pull_request_template.md
├── latexmkrc
├── Makefile
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── .gitignore
```

Do not create empty placeholder classes for future releases.

## Example and profile separation

Profile files contain personal metadata only:

```latex
\CDossierSetup{
  name     = {Amir Sadeghi},
  headline = {Data Scientist},
  email    = {name@example.com}
}
```

Document files contain document-specific content:

```latex
\input{examples/profiles/profile-english.tex}
```

This gives the repository a reusable data layer and prevents the same contact information from being copied across every example.

## Build pipeline

The local build pipeline is:

```text
source files
    │
    ▼
focused tests under tests/
    │
    ▼
latexmk -xelatex / l3build / suite runner
    │
    ▼
XeLaTeX passes
    │
    ▼
PDF and log
    │
    ├── visual inspection
    ├── log inspection
    └── text extraction
```

The Phase 1 CI pipeline should:

1. check out the repository;
2. provide a tested XeLaTeX environment;
3. run the committed regression, smoke, layout, and extraction tests that exist;
4. build the résumé example;
5. build the letter example;
6. fail on test or compilation errors;
7. upload PDFs and logs as artifacts.

CI answers two main questions:

```text
Does the committed behavior still satisfy its focused tests?
Can the supported examples compile from a clean runner?
```

## Testing strategy

### Continuous test development

Tests are designed and committed with the behavior they protect. When practical,
write a focused failing test before implementation, then make it pass. If the
target file or public interface does not exist yet, add the fixture alongside the
first usable implementation and record why a pre-implementation failure was not
run.

All automated test material belongs under `tests/`:

- `tests/regression/` — stable API behavior, options, diagnostics, load order,
  and fixed bugs;
- `tests/smoke/` — supported document builds and required failure paths;
- `tests/extraction/` — expected text, Unicode mapping, and reading order;
- `tests/layout/` — long fields, multi-page content, and page-break stress.

User examples remain under `examples/`. CI should build them, but they are not a
substitute for focused tests. A milestone release reruns the accumulated suite;
it does not introduce tests that were already known to be required.

### Phase 1 coverage

- valid résumé;
- valid cover letter;
- missing required name;
- missing optional phone;
- missing optional website;
- long LinkedIn or website field;
- two-page résumé stress example;
- text extraction.

Already-merged Phase 1 modules have test debt because their local verification
fixtures were not committed. Backfill that coverage before or alongside the next
production feature.

### Regression harness

Adopt `l3build` during active Phase 1 work and point its test directory at
`tests/regression/`. Add each regression when its behavior is introduced or a
bug is fixed; do not wait for academic CV and bibliography work to start the
suite. Verify the exact configuration variables against the current `l3build`
manual when the harness is implemented.

Tests should focus on stable behavior, not every line break or font metric before the design settles.

### Visual verification

When layout changes:

- compile the affected examples;
- inspect PDFs;
- inspect logs for overfull boxes and missing glyphs;
- attach or link a preview in the pull request.

## Generated files policy

Normally ignore:

```text
*.aux
*.bbl
*.bcf
*.blg
*.fdb_latexmk
*.fls
*.log
*.out
*.run.xml
*.synctex.gz
*.toc
```

Recommended policy:

- source files are authoritative;
- CI PDFs and logs are temporary artifacts;
- selected example PDFs are release assets;
- small preview PNGs may be committed under `docs/assets/`.

## Release principles

A feature enters a release only when:

1. its public behavior is defined;
2. a minimal example exists;
3. documentation is updated;
4. a repeatable test was committed with the behavior under `tests/`;
5. the repository does not claim unsupported configurations.

Before tagging a release:

- affected examples compile locally;
- CI passes on `main`;
- `docs/API.md` matches implementation;
- `CHANGELOG.md` is updated;
- version strings are correct;
- the working tree is clean.

## Extension path

### `v0.2.0`

Add:

```text
careerdossier-cv.cls
careerdossier-biblatex.sty
```

The CV class may reuse profile, typography, theme, and components while owning multi-page academic layout.

Bibliography support must remain optional.

### `v0.3.0`

Extend the existing i18n, typography, component, résumé, CV, and letter modules. Do not duplicate the class hierarchy by language.

### `v0.4.0`

Add statement documents, A4 paper, additional themes, and font presets through documented extension points.

### `v1.0.0`

Stabilize the public API, document deprecation policy, validate an Overleaf-ready package, and test every supported configuration.

## Explicit Phase 1 non-goals

Phase 1 does not include:

- academic CVs;
- bibliography or Biber;
- Farsi;
- bilingual layout;
- RTL support;
- statement classes;
- A4 paper;
- color themes;
- icon sets;
- CTAN packaging;
- full visual regression testing.

These exclusions protect the first release from architecture and documentation claims that cannot yet be verified.
