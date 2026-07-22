# CareerDossierTeX Architecture

## Purpose

CareerDossierTeX is a modular LuaLaTeX toolkit for producing related career documents from shared profile data.

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

careerdossier-letter.cls
        │
        ├── careerdossier-components.sty
        ├── careerdossier-typography.sty
        ├── careerdossier-theme.sty
        └── careerdossier-base.sty
```

The exact package-loading order may differ when implementation requires it, but dependency direction should remain one-way. Shared packages must not depend on the résumé or letter classes.

## Phase 2 module graph

The academic CV class, optional bibliography integration, and academic letter
family were released in `v0.2.0`. These additions do not
change the Phase 1 dependency direction:

```text
careerdossier-cv.cls
        │
        ├── careerdossier-components.sty
        ├── careerdossier-typography.sty
        ├── careerdossier-theme.sty
        └── careerdossier-base.sty

careerdossier-biblatex.sty  ──optional──▶  biblatex / Biber
        │
        └── semantic typography and theme roles

careerdossier-letter.cls
        └── family=industry|academic
```

`careerdossier-cv.cls` must not load `careerdossier-biblatex.sty` or `biblatex`.
That separation is the architectural enforcement for the supported no-BibLaTeX
CV path. The integration package may be loaded by a CV document, but neither it
nor the external bibliography toolchain becomes a dependency of the shared
profile or the other document classes.

## `v0.5.0` statement module graph

One statement class defaults to `general-interest` and implements the six
explicit type values approved in issue #103:

```text
careerdossier-statement.cls
        │
        ├── careerdossier-components.sty
        ├── careerdossier-typography.sty
        ├── careerdossier-theme.sty
        └── careerdossier-base.sty

careerdossier-statement.cls
        └── type=general-interest|research|teaching|teaching-philosophy|diversity|artist|purpose
```

All statement types share geometry and a prose document model. The default
general-interest type has no extra required-field contract; an explicit type
changes the default title, continuation-page identification, displayed contact
set, and, where applicable, required fields. This does not justify duplicate
classes or hard-coded narrative schemas. Shared packages remain independent of
the new class.

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

### English strings and the absence of a language module

CareerDossierTeX is English-only and has no language-abstraction module and no
`\CDossierLabel` command. This is a settled design decision, not a gap: Farsi,
bilingual, and RTL support is dropped (see `docs/ROADMAP.md`), and a label
indirection layer earns its keep only once a second language exists.

The letter's English defaults (`Dear Hiring Manager,` and `Sincerely,`) are
therefore defined inline in `careerdossier-letter.cls`, which owns letter prose
structure. They are defaults, not fixed strings — `\CDossierLetterSetup` exposes
`salutation` and `closing` keys, so a user overrides them per document without
any language machinery:

```latex
\CDossierLetterSetup{
  salutation = {Dear Dr. Chen,},
  closing    = {Best regards,}
}
```

If multilingual support is ever revived, the label table belongs in a new shared
module rather than in either class, so the classes are not duplicated per
language.

### `careerdossier-typography.sty`

Owns engine checks and semantic text roles.

Responsibilities:

- require LuaLaTeX and fail fatally under any other engine;
- load `fontspec`;
- select portable default fonts;
- define semantic styles such as name, headline, section, entry title, body, and muted text;
- provide extension points for future font presets.
- apply the Latin ligature-suppression and lining-numbers defaults;
- resolve the default fonts by file name through `luaotfload` (for example
  `texgyretermes` with `Extension = .otf` and explicit face suffixes), so the
  build depends on the TeX Live font tree rather than on OS-installed fonts;
- record the tested font version for reproducibility.

The XeTeX-only `\XeTeXgenerateactualtext` primitive is gone with the engine.
LuaHBTeX emits real interword spaces in the text layer, so no per-word
`/ActualText` workaround is needed or available; see the ATS guide, section 4.5,
for the history.

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
- shared letterhead pieces that do not impose full page geometry;
- PDF document metadata derived from the profile.

#### Why PDF metadata lives here

`/Title`, `/Author`, and `/Lang` are derived from profile data this module
already owns, and both classes need them identically, so putting them in either
class would duplicate the logic and duplicate it again for every class added
later. The classes contribute only the one thing they own that components cannot
know: what kind of document they produce, declared through
`\__cdossier_components_doctype:n`, so a résumé and a letter built from one
profile do not receive identical titles.

Two constraints shape the implementation:

- **Timing.** The values cannot be applied when the class loads `hyperref`,
  because `\CDossierSetup` has not run yet and the profile is still empty. They
  are applied at `\begin{document}` instead.
- **Precedence.** Because they are applied late, a blind write would silently
  discard a user's own `\hypersetup` — including the one the ATS guide's own
  template places *before* `\CDossierSetup`. Each field is therefore written
  only when the document has not already set it.

This module does not load `hyperref` (the classes own it), so the entry point is
guarded and the package still loads without it, matching how the link wrappers
already degrade.

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
- set Letter or A4 geometry while preserving the established physical margins;
- process `fontsize`, `density`, and `paper` class options;
- control compact or standard density;
- disable page numbers by default;
- define résumé section spacing;
- define entry layout;
- define résumé list behavior;
- preserve logical source and extraction order.

The résumé class may call shared components, but reusable contact or identity logic should not be implemented directly inside the class.

### `careerdossier-letter.cls`

Owns industry and academic cover-letter behavior.

Responsibilities:

- set Letter or A4 geometry for both letter families;
- define prose-friendly paragraph and page-breaking behavior;
- render date and recipient blocks;
- render an optional subject;
- render salutation and closing;
- reuse the shared sender identity;
- process `family=industry|academic` while preserving `industry` as the default;
- process `paper=letter|a4` while preserving Letter as the default;
- support one-page and multi-page letters without résumé-specific compression.

The letter class should not reuse résumé geometry merely because both documents share a header.

### `careerdossier-statement.cls` (`v0.5.0`)

Owns the shared statement document model approved in issue #103.

Responsibilities:

- require one of the six documented `type` values and select its default title;
- store statement-scoped title, running-title, subtitle, application-context,
  and application-ID metadata;
- validate `name` and `email` for every type, research affiliation, and artist
  website at the point the statement header renders;
- arrange the centered first-page identity block in logical source order;
- keep the full meaningful title in the page-one body and PDF metadata while a
  separately bounded running title identifies continuation pages;
- reuse component-owned link normalization and separator-safe contact output;
- start from the academic letter's geometry, typography, prose
  rhythm, continuation header, and `Page N of M` folio;
- keep running page furniture out of tagged structure; and
- allow ordinary prose and standard LaTeX sectioning without imposing a
  type-specific narrative schema.

The class owns the choice of which shared profile fields are relevant to each
statement type. Its filtered contact line delegates privately to
`careerdossier-components.sty`, where shared link normalization and
separator insertion remain owned.

Current `affiliation` is reusable identity data and therefore extends the
shared profile in `careerdossier-base.sty`; the statement class decides when it
is required or displayed. In contrast, `application-context` and
`application-id` describe one application document and remain class-scoped.
The shared profile is intentionally allowed to contain fields such as
`linkedin`, `github`, or `location` that a statement does not render; this is
normal cross-document reuse and must not generate warnings.

Paper size and font presets are cross-class concerns: every class implements the
same `paper=letter|a4` contract from issue #105, and Letter remains the default.
The statement class must not introduce statement-only option names or fallback
behavior. Font presets remain owned by issue #107.

### `careerdossier-cv.cls` (Phase 2, released in `v0.2.0`)

Owns academic-CV document behavior.

Responsibilities:

- set Letter or A4 CV geometry while preserving the established physical margins;
- process the documented `fontsize`, `density`, and `paper` options;
- render the first-page identity in the body;
- provide a simple running header after the first page and page numbers on all
  pages without making contact details running-only content;
- reuse the generic section, entry, and item-list interfaces;
- own the manual-publication list and its source-order numbering;
- keep entries together across page breaks where practical without boxing an
  entire long entry; and
- preserve logical source and extraction order.

The CV class must not own shared metadata, contact-link normalization,
bibliography formatting, or font selection. A kernel page style is preferred to
reviving the prototypes' `fancyhdr`/`lastpage` dependency solely for
`Page n of m`; `v0.2.0` requires a page number, not a total-page count.

### `careerdossier-biblatex.sty` (Phase 2, optional)

Owns the supported BibLaTeX interoperability profile.

Responsibilities:

- load `biblatex` only when the user opts into this package;
- configure the fixed numeric, Biber-backed, year-descending profile documented
  in `docs/API.md`;
- expose repeatable author-highlighting declarations;
- implement DOI, then e-print, then URL display precedence;
- reuse semantic monochrome typography and link tokens; and
- report an actionable optional-dependency error when BibLaTeX is unavailable.

It must not:

- be loaded by `careerdossier-cv.cls`;
- change the generic entry, list, section, or page-layout APIs;
- make Biber necessary for manual publications or a CV without publications;
- offer undocumented citation-style pass-through options; or
- infer an author's bibliographic identity from the display-oriented `name`
  profile field.

Standard BibLaTeX commands continue to own resource selection, `\nocite`, and
bibliography printing. CareerDossierTeX owns only the dossier-specific profile
and author-emphasis extension.

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
cdossier/cv
cdossier/entry
cdossier/publication
cdossier/biblatex
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

### Dropped design sketch: Farsi and bilingual support

> **Status:** dropped 2026-07-16, not scheduled (see `docs/ROADMAP.md`). Kept
> as a design record only — none of this is implemented or committed scope.

If Farsi/bilingual support is ever revived:

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

- compile with LuaLaTeX: LuaHBTeX writes real interword spaces, so extraction
  does not depend on per-word `/ActualText` spans (the XeTeX workaround that
  made PDFKit-class consumers merge adjacent words);
- disable common/contextual/discretionary/historic ligatures in the Latin
  default so `ffi`/`ffl` sequences extract as separate letters;
- treat each font file, version, and OpenType-feature combination as testable
  code; record the tested font version;
- keep meaningful content in source (reading) order; never rely on visual
  repositioning that a parser must undo.

### Tagged PDF (status)

The XeTeX interword-space limitation that previously blocked tagging no longer
applies: LuaLaTeX supports the kernel tagging pipeline. As of `v0.4.0` the
classes emit tagged semantic structure when a document opts in with
`\DocumentMetadata{tagging=on}`.

Ownership: `careerdossier-typography` owns the engine check and the tagging
helpers; the classes own reading order and decide which page furniture is a
layout artifact. Tagging is off by default, and the untagged path must stay
byte-identical when tagging code changes — the fixtures under `tests/tagging/`
assert this.

No PDF/UA or WCAG conformance is asserted. Fixture coverage checks that a
structure tree exists and that headings, links, and artifacts are classified as
intended for five named profiles, with list checks on the résumé and CV. All
five automated fixtures have independent validator and three-extractor results;
the four `v0.4.0` profiles also have a macOS VoiceOver pass, while the statement
fixture and Windows/NVDA remain screen-reader-unverified. See the guide's
tagging section before adding any tagging-related dependency.

## Repository layout

At the end of `v0.1.0`:

```text
CareerDossierTeX/
├── careerdossier-base.sty
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
├── build.lua
├── Makefile
├── manifest.txt
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
latexmk -lualatex / l3build / suite runner
    │
    ▼
LuaLaTeX passes
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
2. provide a tested LuaLaTeX environment;
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
- `tests/layout/` — long fields, multi-page content, and page-break stress; and
- `tests/bibliography/` — Biber-backed sorting and rendered identifier
  precedence.

User examples remain under `examples/`. CI should build them, but they are not a
substitute for focused tests. A milestone release reruns the accumulated suite;
it does not introduce tests that were already known to be required.

The test type follows the module's concern. Logic-bearing modules — metadata and
separator logic in `careerdossier-base.sty`, and the engine-check and
role-dispatch logic in `careerdossier-typography.sty` — expose behavior that a
log diff can assert, so they take `l3build` regression tests (`.lvt` sources
with saved `.tlg` baselines) in `tests/regression/`. Layout classes —
`careerdossier-resume.cls` and `careerdossier-letter.cls` — own visual results
that no log diff fully captures, so they rely on smoke, extraction, and reviewed
reference PDFs, with final layout correctness confirmed by human inspection. A
saved baseline is the assertion: regenerate one only for an intended, reviewed
output change.

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

Because a `.lvt` test cannot run without the harness, the harness precedes the
tests that depend on it: land `build.lua` before — or in the same change as — the
first module that relies on `l3build` coverage, rather than accumulating `.lvt`
sources no runner can execute. Regressions owed before the harness lands are
tracked as explicit test debt.

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

The CV class reuses profile, typography, theme, and components while owning
multi-page academic layout and the no-BibLaTeX manual-publication path. The
letter class gains its academic family without a duplicate class. Bibliography
support remains an explicit optional package so a CV without BibLaTeX still
builds.

### `v0.3.0` — dropped, 2026-07-16

Farsi, bilingual, and RTL support is dropped, not scheduled (see
`docs/ROADMAP.md`). If it is ever revived, extend the existing typography,
component, résumé, CV, and letter modules and add a shared label module. Do
not duplicate the class hierarchy by language.

### `v0.5.0`

Add one statement class with a general-interest default and six explicit types,
A4 paper, and font presets through documented
extension points. Color themes and optional icons were deferred by the
maintainer on 2026-07-22.

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
