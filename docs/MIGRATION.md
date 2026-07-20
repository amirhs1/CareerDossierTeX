# Migration Notes

## Status

`v0.2.1` is the current published release. `v0.4.0` is in preparation on `main`
and **changes the supported engine from XeLaTeX to LuaLaTeX** — see
[Upgrading to `v0.4.0`](#upgrading-to-v040-xelatex--lualatex) below.

No released public command, key, class option, or default has been renamed or
removed. The `v0.4.0` break is in the toolchain, not the document API.

The pre-release prototypes inventoried below are **not** a published API. They are
recorded here so that the released industry and `v0.2.0` academic implementations
can preserve the strongest existing design
while deliberately diverging where the supported scope (LuaLaTeX, English, US
Letter, monochrome, extraction-conscious) requires.

## Upgrading to `v0.4.0`: XeLaTeX → LuaLaTeX

`v0.4.0` makes LuaLaTeX the sole supported engine. XeLaTeX and pdfLaTeX now stop
with a fatal error from `careerdossier-typography`:

```text
CareerDossierTeX requires LuaLaTeX.
Compile with lualatex, not xelatex or pdflatex.
```

There is no compatibility mode and no option to bypass the guard. Stay on
`v0.2.1` if you cannot move to LuaLaTeX.

### What does not change

Classes, class options, profile keys, public commands, environments, paper size,
and theme are unchanged. An existing document that does not contain
XeTeX-specific preamble code needs no edit beyond the build command.

Two exceptions to "page design is unchanged": the academic CV's folio and the
academic letter's running header and footer both changed, so those two documents
render slightly differently. Neither needs a source edit. See step 5.

### 1. Change the build command

Before:

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex
```

After:

```bash
latexmk -lualatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex
```

Update editor and CI configuration too. In TeXShop, TeXworks, VS Code
(LaTeX Workshop), or Overleaf, select LuaLaTeX as the typesetting engine. A
stale `latexmkrc`, `.vscode/settings.json`, or CI workflow still passing
`-xelatex` is the most common cause of the engine error after upgrading.

Reason: LuaHBTeX writes real interword spaces into the PDF text layer and
supports the LaTeX kernel tagging pipeline. XeTeX supports neither, which capped
both extraction reliability (see `v0.2.1` and issue #72) and tagged output.

### 2. Remove XeTeX-only preamble code

`\XeTeXgenerateactualtext` and other `\XeTeX…` primitives do not exist under
LuaTeX and raise "undefined control sequence".

Before:

```latex
\XeTeXgenerateactualtext=1
```

After:

```latex
% Delete it. CareerDossierTeX never enabled this from v0.2.1 onward, and
% LuaHBTeX does not need it: interword spaces are real in the text layer.
```

Guards of the form `\ifXeTeX … \fi` should be deleted or inverted to
`\ifLuaTeX`. `iftex` still provides both.

Reason: the primitive is engine-specific. Under XeTeX it also wrapped every word
in its own `/ActualText` span, which made PDFKit-based readers merge adjacent
words — the bug fixed in `v0.2.1`.

### 3. Check fonts if you overrode them

CareerDossierTeX resolves TeX Gyre Termes and TeX Gyre Heros **by file name**
through `luaotfload`, so the default build does not depend on OS-installed
fonts. Documents that called `\setmainfont` with a system font *name* that
resolved through fontconfig under XeLaTeX may resolve differently under
`luaotfload`.

If you override fonts, recompile and check the log for font substitutions and
missing glyphs before trusting the output.

### 4. Re-check pagination

LuaHBTeX's line breaking is not byte-identical to XeTeX's. Page breaks can shift
by a line in long documents. Review multi-page CVs and two-page résumés after
upgrading rather than assuming identical pagination.

### 5. Review the academic CV and letter page furniture

`v0.4.0` changes the running headers and folios of two documents so that a CV
and an academic cover letter sent together look like one set. **No source edit
is required** — this is rendered output only, and no class, option, key, or
command changed.

Affects `careerdossier-cv` and `careerdossier-letter` with `family=academic`.
The industry letter and the résumé are **unaffected**: the industry letter keeps
its `v0.1` empty page style, and the résumé still prints no folio.

| | Before (`v0.2.x`) | After (`v0.4.0`) |
| --- | --- | --- |
| CV folio | `Page 2` | `Page 2 of 2` |
| CV running header (page 2+) | `Name — Curriculum Vitae` | unchanged |
| Academic letter running header | *none* | `Name — Cover Letter` from page 2 |
| Academic letter folio | `Name` at left, `Page 2 of 2` at right | centered `Page 2 of 2` |

Reasons, in short: a bare `Page 2` cannot tell a reader holding a loose sheet
whether the document ended, and the two classes previously disagreed on every
aspect of their page furniture. The letter adopted the CV's pattern rather than
the reverse, because a running header naming the person and document type on
continuation pages is the stronger convention for both academic CVs and formal
multi-page correspondence.

The academic letter's name has moved, not disappeared: it is in the running
header from page two, and the letterhead and signature block already carried it
on page one. On a single-page letter the old footer was a third occurrence.

**What to check after upgrading:**

- Multi-page academic CVs and letters, to confirm the new furniture looks right
  with your own name and content lengths. A long name in the running header is
  the case most worth a glance.
- Any tooling that parsed your PDFs' footer text.

  A **CV** footer extracted as `Page 1` and now extracts as `Page 1 of 2`.

  An **academic letter** footer used to contain the name as well as the folio,
  and now contains only `Page 1 of 2`. How that name appeared in extracted text
  varied with the extractor, the name's length, and the resulting gap: some
  fixtures extracted `Ada Lovelace Page 1 of 1` as a single line, others put the
  name on its own line above the folio. Either way the name is no longer in the
  footer, so a script keying on it will need updating.

  This is the same class of breakage as the `doi:` → `DOI:` extraction change in
  `v0.2.1`.

If you enable tagged structure (step 6), both the running header and the folio
are marked as layout artifacts, so screen readers skip them rather than reading
page furniture into the document's prose. Untagged output is unaffected, since
it carries no structure tree either way.

### 6. Optional: enable tagged structure

`v0.4.0` adds opt-in tagged semantic structure. It is off by default and
requires no migration. To try it, add `\DocumentMetadata` before
`\documentclass`:

```latex
\DocumentMetadata{lang=en, tagging=on}
\documentclass{careerdossier-resume}
```

Tagged output is a tested preview for the four fixture profiles only and carries
no PDF/UA, WCAG, or ATS conformance claim. See [`API.md`](API.md) for scope.

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

No released public command, key, or option has been renamed or removed, so no
entry in this format exists yet. The `v0.4.0` engine change is a toolchain
break rather than an API rename and is documented in
[Upgrading to `v0.4.0`](#upgrading-to-v040-xelatex--lualatex) above.
