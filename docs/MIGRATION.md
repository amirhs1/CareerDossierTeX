# Migration Notes

## Status

No `CareerDossierTeX` release has been published yet, so no public command, key,
class option, or default has been renamed or removed.

The pre-release prototypes inventoried below are **not** a published API. They are
recorded here so that the `v0.1.0` implementation can preserve the strongest
existing design while deliberately diverging from it where the Phase 1 scope
(XeLaTeX, English, US Letter, monochrome, ATS-conscious) requires.

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
| Academic CV | `cv-v2-no_website-no_color.cls` (monochrome) | `cv-v1.cls` (colour) | Deferred to `v0.2.0` |

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
| `fancyhdr`, `lastpage` | all | Drop for résumé default — no running header/footer |
| `etaremune` | all | Defer — reverse-numbered lists are academic |
| `biblatex` + `biber` | all | Defer to `v0.2.0` — bibliography |
| `pgffor` | all | Defer — supports the biblatex name-bolding macro |
| `polyglossia`, `datetime2` | letter | Defer — language/date via `careerdossier-i18n` |
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
  aware prototypes. → deferred `careerdossier-biblatex` (`v0.2.0`).
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
