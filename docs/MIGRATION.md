# Migration Notes

## Status

`v0.2.0` is the current release. No released public command, key, class option,
or default has yet been renamed or removed.

The pre-release prototypes inventoried below are **not** a published API. They are
recorded here so that the released industry and `v0.2.0` academic implementations
can preserve the strongest existing design
while deliberately diverging where the supported scope (XeLaTeX, English, US
Letter, monochrome, extraction-conscious) requires.

## Purpose

This file records migration paths for incompatible public changes once
implementation begins, per the stability policy in [`docs/API.md`](API.md).

Before `v1.0.0`, breaking changes are allowed but must be documented here and in
[`CHANGELOG.md`](../CHANGELOG.md) in the same pull request that introduces the
change.

## Phase 0 baseline inventory

Baseline sources were supplied by the maintainer as standalone prototype classes
and test documents. They are design references and migration sources, not files
to port verbatim. This inventory satisfies the Phase 0 goal of understanding and
preserving the strongest existing implementations before refactoring.

### Selected baselines

| Document type | Baseline (primary) | Also considered | Phase |
|---|---|---|---|
| Résumé | `resume_modern.cls` | `resume_legacy.cls` | Phase 1 (`v0.1.0`) |
| Industry cover letter | `cover_letter_no_website_black_white-underlined_links.cls` | — | Phase 1 (`v0.1.0`) |
| Academic CV | `cv-v2-no_website-no_color.cls` (monochrome) | `cv-v1.cls` (colour) | Phase 2 (`v0.2.0`) |

Notes:

- `resume_modern.cls` is the strongest résumé starting point: it already has an
  `iftex` engine guard that errors under pdfLaTeX, key-value-free class options
  (`10pt`/`11pt`/`12pt`, `letterpaper`/`a4paper`, `compact`/`normal`), a
  `\IfFileExists` font-fallback chain, and the fullest item set.
- `resume_legacy.cls` is a simpler consolidation (from `resume_v1` and
  `resume_canada_government`) with a `phone` profile key and TeX Gyre / DejaVu
  fallbacks; it is retained as a secondary reference for the plainer layout.
- The academic CV prototypes carry publication, teaching, grant, and presentation
  machinery (`biblatex`, `etaremune`, `academicons`) that belongs to the academic
  milestone, not Phase 1.

### Reference PDFs

Reference PDFs were **not** reproducible in the current environment. Every
baseline loads fonts from a bundled `config/fonts/` tree (Merriweather, Barlow
Condensed, Liberation) that is not part of this repository, and the by-name
fallbacks (for example `DejaVu Serif`) do not resolve through `fontspec` on the
build host. The baselines' design characteristics are therefore captured from
source in this document. To regenerate visual references, compile the prototypes
on a host where the bundled or fallback fonts are installed.

### Dependency inventory

Union of packages required across the baseline classes, with the Phase 1
disposition:

| Package | Used by | Phase 1 disposition |
|---|---|---|
| `fontspec` | all | Keep — owned by `careerdossier-typography` |
| `iftex` | `resume_*` | Keep — engine guard in `careerdossier-typography` |
| `geometry` | all | Keep — margins owned by each class |
| `xcolor` | all | Keep — monochrome tokens in `careerdossier-theme` |
| `hyperref` | all | Keep — metadata and safe links |
| `enumitem` | all | Keep — `CDossierItemize` |
| `titlesec` | all | Keep (or kernel headings) — `\CDossierSection` |
| `etoolbox` | all | Keep internally; prefer `expl3` for new logic |
| `microtype` | all | Keep |
| `parskip` | all | Keep |
| `keycommand` | all | Replace with `\NewDocumentCommand` + l3keys |
| `xstring` | letter, `cv-v2` | Replace with `expl3` string tests |
| `fontawesome5` | all | Drop — icon-only contact labels are non-ATS |
| `academicons` | `resume_modern` | Drop — icon-only labels (Scholar) |
| `pifont` | most | Drop — decorative symbols |
| `multicol` | most | Drop — no multi-column body |
| `tabularx` | `resume_modern` | Drop — no table layout for fields |
| `fancyhdr`, `lastpage` | all | Do not revive for `v0.2.0`; CV uses a class-owned kernel page style and does not promise total-page counts |
| `etaremune` | all | Drop — academic entries and manual publications retain explicit source order |
| `biblatex` + `biber` | all | Keep only behind optional `careerdossier-biblatex`; never a CV-class dependency |
| `pgffor` | all | Drop — author matching belongs in the optional integration package without a general loop dependency |
| `polyglossia`, `datetime2` | letter | Drop — `v0.1.0` is English-only; the letter date is a plain `date` key |
| `graphicx` | `resume_modern` | Drop from default — no images |

### Duplicated implementation

The prototypes repeat the same concerns across files, which is the motivation for
the shared-package architecture in [`docs/ARCHITECTURE.md`](ARCHITECTURE.md):

- **Font and icon block** — the `\setmainfont`/`\setsansfont`/`\setmonofont` +
  `\newfontfamily\barlowfont`/`\liberationsans` + `\barlowbold` block is copied
  across `cv-v1`, `cv-v2`, the cover letter, and (wrapped in fallbacks)
  `resume_legacy` and `resume_modern`. → `careerdossier-typography`.
- **Colour palette** — the Paul Tol `\definecolor` list is duplicated across
  `cv-v1`, the cover letter, `resume_legacy`, and `resume_modern`. →
  `careerdossier-theme` (monochrome tokens only in Phase 1).
- **Bibliography macros** — the `\mkbibnamefamily`/`\mkbibnamegiven` name-bolding
  toggle and the `doi+eprint+url` macro are duplicated across all bibliography-
  aware prototypes. → optional `careerdossier-biblatex` (`v0.2.0`).
- **Optional-field separators** — the "print a separator only between present
  fields" concern is implemented three different ways: nested `\ifstrequal`
  chains (`cv-v1`, commented cover-letter block), `\PrintField`/`\ifcv@printed`
  (`cv-v2`), and `\resume@profileitem`/`\ifresume@profilefirst` (`resume_*`). →
  a single implementation in `careerdossier-base`/`careerdossier-components`
  (AGENTS.md rule 5).
- **Section heading style** — the `\titleformat{\section}{... \scshape ...}`
  definition is repeated in every prototype. → `\CDossierSection`.
- **Entry item commands** — `\EducationItem`, `\ExperienceItem`,
  `\CertificateItem`, `\TeachingExperienceItem`, `\SkillItem`, `\ProjectItem`,
  `\GrantItem`, and `\PresentationItem` are redefined with per-file variations
  across four classes. → the single `CDossierEntry` environment plus, later,
  semantic academic entry kinds.

## Prototype → `v0.1.0` public API mapping

This table starts the migration record from the pre-release prototype surface to
the [`docs/API.md`](API.md) `v0.1.0` interface. It is a design map, not a
released-API rename log; released renames use the entry format below.

| Prototype interface | `v0.1.0` interface | Notes |
|---|---|---|
| `\Profile[fullname=…]` | `\CDossierSetup{ name=… }` + `\MakeCDossierHeader` | `fullname`→`name`; `address`→`location`; `update` dropped; contact icons removed |
| `\LetterProfile[fullname=…]` | `\CDossierSetup{…}` + `\CDossierLetterSetup{…}` + `\MakeCDossierLetterhead` | Sender identity shared with résumé; recipient/date/subject/salutation in the body |
| `\section{…}` (article) | `\CDossierSection{…}` | Semantic heading; class-controlled spacing |
| `\EducationItem[program,university,location,duration]` | `CDossierEntry[title,organization,location,dates]` | `program`→`title`, `university`→`organization`, `duration`→`dates` |
| `\ExperienceItem[position,company,location,duration]` | `CDossierEntry[title,organization,location,dates]` | `position`→`title`, `company`→`organization`, `duration`→`dates` |
| `\CertificateItem`, `\TeachingExperienceItem`, `\ProjectItem` | `CDossierEntry[…]` (+ `CDossierItemize`) | Collapse into the one semantic entry environment |
| `\GrantItem`, `\PresentationItem` | Deferred to `v0.2.0` | Return as semantic academic entry kinds |
| `\SkillItem[category,skills]` | `\CDossierSection{Skills}` + comma-separated text | Skills as plain text, not a grid (API/ATS guidance) |
| `itemize` (redefined) | `CDossierItemize` | Résumé-appropriate list; no global `itemize` redefinition |
| `\mynames`, `\printbibliography`, `biblatex` | Deferred to `v0.2.0` | Bibliography is out of Phase 1 scope |
| `[11pt,letterpaper,compact]` | `[fontsize=11pt, density=compact]` | `paper`/`language`/`theme` fixed in `v0.1.0` |
| Merriweather / Barlow Condensed / Liberation Mono | TeX Gyre Termes (body) / TeX Gyre Heros (headings) | Redistributable TeX Live fonts; mono reserved |
| Paul Tol colours, coloured links | Monochrome theme tokens, black links | Colour carries no meaning in Phase 1 |

## Academic prototype → `v0.2.0` public API mapping

This table is the compatibility analysis for the accepted academic API contract
in [`docs/API.md`](API.md). The left-hand interfaces were private prototypes and
do not receive deprecation aliases.

| Prototype interface | `v0.2.0` interface | Notes |
|---|---|---|
| `\documentclass{cv-v1}` / `cv-v2-no_website-no_color` | `\documentclass{careerdossier-cv}` | One supported, monochrome academic class; `fontsize` and `density` use the established option syntax |
| `\Profile[fullname=…, scholar=…, address=…]` | `\CDossierSetup{name=…, scholar=…, orcid=…, location=…}` + `\MakeCDossierHeader` | Shared with industry documents; icons and `update` are not restored |
| `\EducationItem`, `\ExperienceItem`, `\CertificateItem`, `\TeachingExperienceItem`, `\ProjectItem`, `\GrantItem`, `\PresentationItem` | `CDossierEntry[…]` (+ `CDossierItemize`) | One extensible semantic entry replaces per-section commands; grant amounts and presentation modes may be content or entry-body text |
| Manually maintained publication prose | `CDossierPublications` + `\CDossierPublication{…}` | Numbered source-order list; no BibLaTeX/Biber dependency |
| Class-level unconditional `\RequirePackage{biblatex}` | Explicit `\usepackage{careerdossier-biblatex}` | Opt-in boundary guarantees that an ordinary CV builds without BibLaTeX |
| `\mynames{family/given,…}` | Repeatable `\CDossierHighlightAuthor{family={…}, given={…}}` | Named keys replace slash parsing and reversed duplicate spellings |
| Prototype `\addbibresource`, `\nocite`, `\printbibliography` | Same standard BibLaTeX commands | CareerDossierTeX configures one supported profile instead of wrapping resource selection |
| `style=numeric, backend=biber, sorting=ydnt` | Fixed optional integration profile | Preserved from the maintainer's academic reference |
| Global `doi+eprint+url` override | Integration-local DOI → e-print → URL precedence | Must not affect documents that do not load the integration package |
| `Page n of m` via `fancyhdr`/`lastpage` | Running name header after page one plus `Page n` | Meets the milestone requirement without a total-page dependency or extra reference pass |
| `family=industry` fixed in the letter prototype | `family=industry|academic`, default `industry` | Additive; existing industry letters remain unchanged |
| Bundled Merriweather / Barlow Condensed / Liberation fonts | Existing TeX Gyre semantic typography roles | No new font assets or font presets in `v0.2.0` |
| Font Awesome icons and coloured links | Visible text labels and monochrome links | Scholar, ORCID, DOI, and contact meaning remains present without icons or colour |

## Entry format

When a public command, key, or option is renamed, changed, or removed, add an
entry using this shape:

```text
## [0.x.0] - YYYY-MM-DD

### `\OldCommand` renamed to `\NewCommand`

Before:

\OldCommand{...}

After:

\NewCommand{...}

Reason: <why the change was necessary>
```

No released-API entries exist yet.
