# Engineering ATS-friendly career documents with XeLaTeX

## A design and reference guide for CareerDossierTeX

**Status:** Design and reference material — describes the engineering contract the
package is built toward. It is **not** documentation of shipped behavior; only
`docs/API.md` and the compiled examples describe what is currently supported.
**Primary engine:** XeLaTeX
**Current scope (Phase 1, `v0.1.0`):** one English industry résumé and one industry
cover letter, US Letter, monochrome. Later phases extend the same principles to
academic CVs, reference lists, and statements — see `docs/ROADMAP.md`.
**Maintainer:** Amir Sadeghi
**Last reviewed:** 2026-07-13

> **Scope banner.** Throughout this guide, material tagged **(Phase 1)** is in
> scope for `v0.1.0`. Material tagged **(planned — vX.Y.Z)** describes future work
> and must not be implemented or documented as if it were current. When this guide
> and the repository's `docs/` disagree on names, module boundaries, or scope, the
> repository documentation is authoritative and this guide should be corrected to
> match it.

## Executive standard

An ATS does not read LaTeX source. It receives the generated PDF, extracts text,
guesses reading order, and attempts to classify the result into fields. Therefore
the package's real product is not merely a visually correct PDF. It is a PDF whose
visible page, text layer, reading order, Unicode mapping, and semantic structure
agree.

Use these rules as the default design contract. Phase 1 realizes the résumé and
cover-letter subset; the rest guides later phases.

1. Make the default output single-column, linear, text-first, and restrained.
2. Put all essential information in the document body, not in headers, footers,
   pictures, icons, text boxes, overlays, or sidebars.
3. Use conventional section names and real text. Do not communicate meaning only
   through position, colour, or graphics.
4. Compile with XeLaTeX, load fonts through `fontspec`, and treat every font file
   and OpenType feature combination as testable code.
5. Enable XeTeX's `/ActualText` generation, but do not regard it as a universal
   fix. Some PDF consumers ignore or mishandle `/ActualText`.
6. Keep source text in logical reading order. Visual placement must never require
   the parser to reconstruct the intended order.
7. Run automated round-trip extraction tests and manual copy-and-paste tests after
   changes to layout, fonts, symbols, dependencies, or the TeX distribution.
8. Keep ATS compatibility, PDF accessibility, and visual quality as separate
   release gates. They overlap, but passing one does not prove the others. In
   particular, current XeTeX tagging has an interword-space limitation.
9. Follow the employer's requested file type. A sound PDF cannot satisfy a portal
   that requires DOCX.
10. Never claim that a template is "ATS-proof" or "guaranteed." Say that it is
    designed and tested for robust text extraction, and publish the tested
    environments.

The strongest current ATS evidence is consistent on the main failure modes.
Greenhouse lists columns, tables, headers, footers, text boxes, graphics, and
images among causes of unsuccessful parsing. Lever accepts text-based PDFs but
notes that a quick indicator is whether text can be highlighted. MIT recommends
common fonts, at least 10 pt type, avoiding tables and text boxes, and converting
to plain text to inspect loss or reordering. See
[Greenhouse's parsing guidance](https://support.greenhouse.io/hc/en-us/articles/200989175-Unsuccessful-resume-parse),
[Lever's parser documentation](https://help.lever.co/hc/en-us/articles/20087345054749-Understanding-resume-parsing),
and [MIT's ATS guide](https://capd.mit.edu/resources/make-your-resume-ats-friendly/).

> **Verify at release.** Vendor guidance and limits change. Re-check these three
> pages, and any figure attributed to a vendor (for example the Greenhouse parser
> size limit in §11.9), each release cycle.

## 1. What "ATS-friendly" should mean in this package

Treat ATS-friendly as a testable set of properties, not a marketing label.

A generated document is ATS-friendly enough to release only when:

- every meaningful character is selectable and extractable;
- extracted text uses the intended Unicode characters, not missing glyphs,
  Private Use Area code points, presentation-form ligatures, or replacement
  characters;
- extraction follows the intended top-to-bottom reading order;
- headings, names, organizations, job titles, dates, contact details, and URLs
  remain recognizable;
- visible words remain whole, with sensible spaces between them;
- the PDF contains no scanned or outlined substitute for meaningful text;
- all fonts used for meaningful text are embedded or otherwise reliably available
  to the PDF consumer;
- the document remains readable without colour and without hyperlink behaviour;
- the portal's parsed preview or autofill is correct when such a preview is
  available; and
- the PDF remains easy for a human to skim.

These properties improve the odds of successful parsing. They do not control an
employer's ranking rules, keyword logic, AI models, or internal workflow.

In Phase 1 there is a single output, and it is ATS-oriented by default: single
column, monochrome, body-first, no icons carrying meaning. Where this guide refers
to "the ATS profile" it means that default output. A switchable decorative or
"display" profile is a backlog idea (see `docs/ROADMAP.md`), not a current option;
do not write documentation or examples that assume a `profile` key exists.

### Three related but distinct targets

| Target | Main question | Useful evidence | What it does not prove |
|---|---|---|---|
| ATS extraction | Can a parser recover the words and associate them in a sensible order? | `pdftotext`, copy/paste, portal autofill | Accessibility or correct tagging |
| Accessibility | Can assistive technology understand the document's structure and meaning? | tagged-PDF inspection, PDF/UA validation, screen-reader testing | ATS field recognition |
| Visual quality | Can a recruiter read and scan the document comfortably? | rendered-page inspection, print test, zoom test | text-layer correctness |

A tagged PDF can still have a poor extraction order. An untagged PDF can sometimes
extract cleanly. A beautiful PDF can fail both. Test all three.

## 2. Sources and how to use this guide

This guide draws on the LaTeX community's authoritative documentation and on a set
of practitioner reports about ATS behaviour. Give the most weight to current,
primary documentation from the LaTeX Project and package maintainers; treat forum
posts and commercial articles as supporting evidence, weighted toward recency.

Primary authorities for class/package structure, keys, hooks, robustness, and
release work:

- **LaTeX for class and package authors** (`clsguide`), the LaTeX Project's own
  guide to modern class/package construction, key-value options, hooks, and the
  evolving output routine. Canonical documentation index:
  <https://www.latex-project.org/help/documentation/>.
- **The LaTeX Companion**, 3rd ed. (Mittelbach & Fischer, Addison-Wesley, 2023),
  chapter 17, for documented source files, `docstrip`, `l3build`, regression
  testing, documentation, and CTAN release work. (Book; no free URL.)
- **The Not So Short Introduction to LaTeX2e** (`lshort`), chapter 6, for logical
  formatting, font sizing, spacing, page layout, lengths, boxes, and rules:
  <https://ctan.org/pkg/lshort-english>.
- **`fontspec`** manual (2.9g, 2025-09-29) for OpenType feature selection under
  XeLaTeX: <https://ctan.org/pkg/fontspec>.
- Historical tutorials on class inheritance and semantic commands (Peter Flynn,
  *Rolling your own Document Class*, 2007; Jim Hefferon, *Minutes in Less Than
  Hours*) remain useful for concepts, but their implementation techniques are
  dated. Do not copy old internals without checking current kernel guidance.

Supporting practitioner evidence, weighted by recency and reproducibility:

- The Inter 4.1 XeLaTeX text-extraction regression is a reproducible warning about
  font-version and OpenType-feature interactions:
  <https://github.com/rsms/inter/issues/774>.
- The distinction between a `ToUnicode` map's *presence*, *completeness*, and
  *correctness* is well explained here:
  <https://stackoverflow.com/questions/53890212/how-to-check-if-encoding-and-tounicode-are-properly-done-for-a-pdf>.
- Recent practitioner overviews of ATS parsing and LaTeX résumés reinforce the
  single-column and copy/paste-test advice. Cite the original web sources when you
  add them; a commercial article or forum post is background, not authority.

Where a local note and current documentation differ, follow the current primary
source and re-test. For example, older `l3build` documentation used a different
documentation-engine setting; the current `l3build` manual uses
`typesetexe = "xelatex"`. That is exactly why every release is checked against
current manuals.

> **Maintainer note.** A few source URLs above point to canonical index or package
> pages rather than deep links, to avoid dead links as documents are revised.
> Confirm and, where useful, pin exact URLs when you next revise this file.

## 3. Layout rules: safe defaults and risky patterns

### 3.1 Default to one semantic stream

The input order should already be the order in which a plain-text reader should
encounter the content:

```text
Name
Contact details
Summary
Experience
  Job title
  Organization
  Location
  Date range
  Achievement bullets
Education
Skills
```

The implementation may change font, spacing, weight, or alignment, but it should
not move a later semantic block to an earlier visual position.

### 3.2 Do not use these for essential content

- `twocolumn`, `multicol`, `paracol`, sidebars, or parallel minipages;
- `tabular`, `tabularx`, `longtable`, `array`, or nested boxes used merely to
  align résumé fields;
- TikZ nodes, `textpos`, `picture`, overlays, absolute positioning, or floating
  text boxes;
- text converted to paths or embedded in SVG/PDF artwork;
- contact details stored only in running headers or footers;
- icon-only labels for phone, email, location, website, LinkedIn, GitHub, ORCID,
  or Google Scholar;
- skill bars, stars, charts, ratings, timelines, maps, portraits, logos, QR codes,
  or infographic elements as substitutes for text;
- negative spacing or overlapping boxes that visually reorder content;
- manual letterspacing implemented by inserting spaces between characters; or
- hidden, white, zero-size, clipped, or transparent keyword text.

Some of these constructs can generate extractable PDFs in controlled cases. They
remain high-risk because different extractors make different ordering decisions.
The default output should avoid the entire class of failure.

### 3.3 Safe visual hierarchy

Prefer hierarchy created with:

- conventional section headings;
- font weight and modest size changes;
- consistent vertical space;
- indentation of ordinary lists;
- short horizontal rules used only as decoration; and
- source-order-preserving inline alignment.

Bold, italics, and dark accent colours are generally safe because the words remain
words. Colour must not carry meaning by itself. Keep body text black or very dark,
maintain strong contrast, and test grayscale output.

### 3.4 Dates and right alignment

Putting a date at the far right with `\hfill` can preserve source order if the
title precedes the date in the source, but it must be tested. A safer default is a
short sequential block:

```text
Senior Data Analyst
Example Corporation, Toronto, Ontario
January 2023 - Present
```

If a compact same-line presentation is offered, implement it as an option and
require extraction fixtures proving that the title and date remain associated. Do
not use a two-cell table merely to push the date right.

### 3.5 Headers, footers, and page numbers

For a one- or two-page résumé, prefer no running header. For a long CV **(planned
— v0.2.0)**, a simple surname and page number can help humans, but it must not be
the only appearance of the name or other essential data. Use standard page-style
mechanisms so tagging code can treat running material as artifacts, and inspect
the resulting structure.

Greenhouse explicitly identifies complex headers and footers, and contact data
placed within them, as parsing risks. Keep the canonical name and contact block in
the first page's body.

### 3.6 Page geometry and density

Good defaults for most career documents are:

- 0.5-1 inch margins, with approximately 0.65-0.8 inch as a useful default;
- 10-12 pt body text, adjusted for the selected font's real x-height;
- moderate line length and visible separation between entries;
- no forced one-page compression at the cost of legibility; and
- no negative `\vspace` as a routine layout tool.

Use named lengths for every public spacing control, defined in the module that
owns the concern — margins and section spacing belong in the class, not in
`careerdossier-base`. Do not scatter unexplained numeric dimensions through the
implementation.

## 4. Typography and font engineering under XeLaTeX

Engine detection, `fontspec` loading, portable font selection, and semantic text
roles are owned by `careerdossier-typography.sty`. The examples below illustrate
the policy; in the implementation they live in that module.

### 4.1 Font choice is a build dependency

With XeLaTeX, `fontspec` makes system and OpenType fonts easy to use, but the
output depends on:

- the exact font files and versions;
- the selected upright, bold, italic, and bold-italic faces;
- the renderer and script/language settings;
- enabled OpenType substitutions;
- XeTeX and `xdvipdfmx` versions; and
- how a PDF consumer interprets `ToUnicode` and `/ActualText`.

Do not describe a font as ATS-safe based on its family name alone.

### 4.2 Package default versus user-selected fonts

For a portable, reproducible default:

- choose a freely redistributable OpenType family available in standard TeX
  distributions;
- load it by a known file name where practical, not by an OS-dependent display
  name;
- declare all four common faces explicitly;
- use a font licence compatible with redistribution;
- do not bundle Arial, Calibri, Cambria, Georgia, Helvetica, Times New Roman, or
  other proprietary system fonts;
- allow users to select an installed font, but warn that doing so changes the
  tested output; and
- record the exact tested font version in the release notes or test manifest.

TeX Gyre Heros and TeX Gyre Termes are reasonable portable starting points for
sans and serif profiles. They are not magically ATS-safe; they are useful because
they are widely distributed in TeX systems and can be tested reproducibly.

### 4.3 Prefer literal Unicode source

Use UTF-8 source and actual Unicode characters for names and languages. Do not
require users to spell `Zoë`, `José`, `Łukasz`, or `İpek` with legacy accent
macros merely to accommodate an old engine. XeLaTeX is the package baseline.

Include multilingual fixtures with:

- precomposed and decomposed accents;
- Latin Extended letters;
- right-to-left and non-Latin scripts that the package claims to support
  **(deferred — unscheduled; the package claims none today)**;
- apostrophes, quotation marks, percent signs, plus signs, ampersands, slashes,
  and parentheses;
- phone numbers and international prefixes;
- URLs and email addresses; and
- words containing `ff`, `fi`, `fl`, `ffi`, and `ffl` sequences.

Normalize expected extraction to Unicode NFC for comparison, while also retaining a
raw-output artifact for diagnosis.

### 4.4 Ligatures and alternate glyphs

The visible glyph and the extracted text are different layers. A ligature can
display as one glyph but should extract as its original character sequence. An
alternate punctuation glyph can look correct yet extract to a Private Use Area
code point.

The Inter 4.1 regression demonstrates the failure clearly: under XeLaTeX,
contextual (`calt`) and tabular-figure (`tnum`) alternates for `(`, `)`, and `+`
could extract as PUA characters, while Inter 3.19 extracted correctly. Enabling
`\XeTeXgenerateactualtext=1` fixed Poppler extraction but not every PDF consumer
(macOS Preview did not reliably honour it).

For a Latin-script default, begin conservatively:

```tex
\defaultfontfeatures+{
  Ligatures={
    CommonOff,
    ContextualOff,
    DiscretionaryOff,
    HistoricOff
  },
  Numbers=Lining
}
```

The `fontspec` 2.9g manual (Table 11, "Ligatures") documents the option names
`Common`, `Contextual`, `Rare`/`Discretionary`, `Historic`, and `TeX`, and states
that these OpenType selectors are disabled with the `...Off` variants — so
`CommonOff`, `ContextualOff`, `DiscretionaryOff`, and `HistoricOff` are correct for
OpenType fonts. Note that `NoCommon`, `NoContextual`, etc. are the **AAT (legacy
macOS)** convention, not merely an older spelling; because this package uses
OpenType faces under XeLaTeX, use the `...Off` form and verify against the
installed `fontspec` version.

Important qualifications:

- Do not disable required shaping indiscriminately. Required ligatures and shaping
  can be essential for Arabic and other scripts **(deferred — unscheduled)**.
- Disabling substitutions can slightly change metrics, kerning, line breaks, and
  page breaks.
- A font that passes with one feature set has not been tested with another.
- `Ligatures=TeX` (OpenType tag `tlig`) controls TeX-style input mappings for
  quotes and punctuation and is equivalent to `Mapping=tex-text`; it is not the
  same as ordinary OpenType `fi` ligatures.
- If the package accepts arbitrary font features, its documentation must say that
  extraction guarantees no longer apply until the resulting PDF is retested.

### 4.5 `/ActualText`, `ToUnicode`, and their limits

Set this early for XeLaTeX output (in `careerdossier-typography.sty`):

```tex
\XeTeXgenerateactualtext=1
```

XeTeX's reference describes this as adding `/ActualText` for better copy/paste and
search. It is a valuable defence against shaped-glyph mapping problems. It is not
sufficient evidence by itself because:

- PDF consumers vary in whether and how they honour `/ActualText`;
- a PDF may contain multiple fonts with different mappings;
- a `ToUnicode` CMap can exist but be incomplete or wrong;
- correct character mapping does not establish reading order; and
- an `/ActualText` string can itself be wrong.

Never search a decompressed PDF for the word `ToUnicode` and call the document
validated. Use `pdffonts` for a quick inventory, inspect suspicious mappings when
needed, and compare extracted output with known ground truth.

### 4.6 A conservative font setup

This is a starting point, not a substitute for tests. In the implementation it
belongs in `careerdossier-typography.sty`, which owns the engine check and font
loading:

```tex
\RequirePackage{iftex}
\ifXeTeX\else
  \PackageError{careerdossier-typography}
    {This package requires XeLaTeX}
    {Compile with xelatex, not pdflatex or lualatex.}
\fi

\XeTeXgenerateactualtext=1
\RequirePackage{fontspec}

\defaultfontfeatures+{
  Ligatures={CommonOff,ContextualOff,DiscretionaryOff,HistoricOff},
  Numbers=Lining
}

\setmainfont{texgyreheros-regular.otf}[
  UprightFont    = texgyreheros-regular.otf,
  BoldFont       = texgyreheros-bold.otf,
  ItalicFont     = texgyreheros-italic.otf,
  BoldItalicFont = texgyreheros-bolditalic.otf
]
```

If the package supports a serif profile **(planned)**, declare it separately and
run the full extraction suite for both profiles.

### 4.7 Font acceptance criteria

A font profile is releasable only if:

- all declared faces exist and are genuinely used;
- no silent synthetic bold or italic is required;
- all used fonts are embedded and subset as expected;
- punctuation, digits, symbols, accents, ligature sequences, URLs, and email
  addresses round-trip correctly;
- the profile passes with the current supported XeTeX toolchain on each CI
  platform;
- text copies correctly in at least two independent PDF engines; and
- changes in font version trigger a fresh baseline review.

## 5. Semantic structure for each career-document type

### 5.1 Shared rules

All document types should provide:

- a real document title in PDF metadata;
- a language declaration;
- a visible applicant name;
- a body-level contact block when contact information is relevant;
- standard headings;
- real lists for lists;
- descriptive link text or visible URLs; and
- source content in the same order a plain-text reader should receive it.

Do not define layout-only interfaces such as `\LeftColumn`, `\RightColumn`, or
`\SkillBar`. Define semantic interfaces. In Phase 1 the semantic primitive is the
`CDossierEntry` environment (with `CDossierItemize` for bullets) and
`\CDossierSection` for headings. Future document types may add semantic entry
kinds — for example a publication or reference entry **(planned — v0.2.0+)** —
built on the same shared components, not duplicated per class.

### 5.2 Résumé **(Phase 1)**

The résumé is the strictest profile:

- one column;
- one or two pages when appropriate, without forced compression;
- conventional headings such as `Summary`, `Experience`, `Education`, `Skills`,
  `Projects`, and `Certifications`;
- reverse-chronological entries where dates are used;
- complete job titles rather than unexplained abbreviations;
- skills as comma-separated or ordinary grouped text, not a grid; and
- achievements in real `CDossierItemize` lists with a simple text bullet.

### 5.3 Industry CV **(planned — later phase)**

Use the same extraction constraints as the résumé, with more sections and pages.
Long lists of presentations, publications, projects, or certifications should
remain ordinary vertical lists. A compact table may look attractive, but a
sequential list is safer and usually easier to maintain.

### 5.4 Academic CV **(planned — v0.2.0)**

Academic readers often value structured publication and research sections, but the
PDF may still pass through a central HR platform. Keep:

- `Education`, `Academic Appointments`, `Publications`, `Research`, `Teaching`,
  `Grants`, `Awards`, and `Service` as recognizable headings;
- bibliographic entries in a predictable text order;
- DOI, ORCID, and profile identifiers as visible text when important;
- author emphasis as font weight, not a custom glyph or colour alone; and
- page breaks between entries rather than inside an entry where practical.

If `biblatex` is supported **(planned — v0.2.0)**, test the exact bibliography
style and every field type used. A bibliography package update can change
punctuation and extraction.

### 5.5 Cover letter **(Phase 1)**

Do not place the applicant's address, recipient, date, or subject only in a
decorative letterhead or page header. Emit them in the document body in logical
order:

```text
Applicant name and contact
Date
Recipient name and organization
Subject or position
Salutation
Letter body
Closing and typed name
```

A scanned signature may be decorative, but the typed name must remain present as
text. If a signature image is included, it must not interrupt reading order or
replace the name.

### 5.6 Statements — research, teaching, diversity **(planned — v0.4.0)**

These are closer to short articles:

- use ordinary paragraphs and semantic headings;
- avoid magazine-style columns;
- keep citations and footnotes sparse and extractable;
- use figures only when essential, with text alternatives when tagging is enabled;
- avoid putting the title or applicant name only in a header; and
- test page transitions and paragraph spacing in extracted text.

### 5.7 Reference list **(planned — later phase)**

Emit each reference as a sequential block: name, title, organization, relationship
if appropriate, email, phone, and address. Do not place references in two or three
columns. Labels such as `Email:` and `Phone:` improve plain-text clarity.

## 6. Hyperlinks, icons, symbols, bullets, and punctuation

### Hyperlinks

- The visible text must remain useful if the link annotation disappears.
- Prefer `github.com/name` over an icon with an invisible destination.
- Prefer a descriptive label plus a visible identifier for ORCID, DOI, or
  LinkedIn.
- Do not use URL shorteners in package examples.
- Test URLs containing `_`, `-`, `~`, `?`, `&`, `%`, and non-ASCII characters.

### Icons

The default output should use no icons for essential information. If an optional
display profile **(planned)** includes icons, follow each icon with ordinary text
and test that the icon does not become a stray PUA character in extraction. Font
Awesome and similar icon fonts are a common source of meaningless extracted code
points.

### Bullets

Use the `CDossierItemize` environment and a simple bullet or hyphen. Do not
simulate bullets with icons, drawings, or dingbat fonts. Check whether the
extractor inserts a sensible space or line break after each label.

### Punctuation

Prefer plain, conventional punctuation. Curly quotes and en/em dashes are valid
Unicode, but they must be included in the extraction fixture. Use an ordinary
hyphen or a word such as `to` in date ranges if a target portal mishandles
typographic dashes.

### Hyphenation and line wrapping

Do not insert discretionary hyphens into keywords, organization names,
technologies, email addresses, or URLs. Consider a ragged-right setting if it
improves word integrity, but do not globally disable all language-aware shaping
without testing. Compare extraction both with and without `pdftotext -layout`;
different consumers infer line structure differently.

## 7. Tagged PDF and accessibility under current LaTeX

Tagged PDF is worth supporting because it provides a structure tree and can
improve reuse and accessibility. It is not an ATS guarantee.

For the default output, set ordinary PDF metadata through `hyperref` and do not
invoke the experimental tagging path:

```tex
\documentclass{careerdossier-resume}
\hypersetup{
  unicode = true,
  pdflang = en
}
```

`pdflang` records the PDF's natural language; it does not configure hyphenation or
script support. Language and `pdflang` should be routed through the i18n layer or
a class `language` option rather than hard-coded, so multilingual phases can extend
them. A TeX Live 2026 test for this guide found that even a language-only
`\DocumentMetadata{language=en}` call activated tagging infrastructure and produced
XeTeX's interword-space warning, which makes it inappropriate for the quiet default
until the implementation changes. **(Verify at release: this test result was
observed on TeX Live 2026 and has not been independently reproduced in this
document; re-run it against your CI image.)**

Maintain a separate experimental tagging fixture:

```tex
\DocumentMetadata{
  language = en,
  tagging  = on
}
\documentclass{careerdossier-resume}
```

The experimental fixture's placement has an architectural consequence: a class
cannot retroactively place `\DocumentMetadata` before its own loading. The
distributed tagging example must demonstrate it, and the documentation must explain
it. The class should remain as compatible with tagging as XeLaTeX permits and
should test whether its dependencies are compatible, but it should not pretend that
an internal late call is equivalent.

As of the June 2026 LaTeX release, tagged-PDF work remains active and kernel
behaviour continues to change when `\DocumentMetadata` is used. The LaTeX Project
maintains a live
[package/class tagging status table](https://latex3.github.io/tagging-project/tagging-status/)
and reports ongoing changes in
[LaTeX News](https://www.latex-project.org/news/latex2e-news/ltnews.pdf). Check
both before adding or updating dependencies. **(Verify at release: confirm the
current LaTeX News issue number and its tagging notes.)**

There is a material XeLaTeX limitation. The current `tagpdf` code states that only
pdfLaTeX and LuaLaTeX have some support for real interword spaces; XeTeX emits the
warning `engine/output mode xetex doesn't support the interword spaces`. A TeX Live
2026 fixture compiled for this guide reproduced that warning; MuPDF recovered the
visible spaces, while a PDFPlumber-based extraction merged some adjacent words.
That is evidence that geometry-based consumers compensate differently, not evidence
of a universally sound tagged text stream. See the current
[`tagpdf` implementation documentation](https://mirrors.ctan.org/macros/latex/contrib/tagpdf/tagpdf-code.pdf).

Therefore:

- do not enable `tagging=on` by default until the XeTeX limitation is resolved and
  the result passes the supported extractor matrix;
- keep the class tagging-compatible and keep a tagging test profile so improvements
  can be adopted promptly;
- document the known warning rather than silently allowlisting it;
- do not claim PDF/UA conformance from the XeLaTeX build while real interword
  spaces are unsupported; and
- if strict PDF/UA conformance is an application requirement, state that the
  current XeLaTeX-only scope may be unsuitable.

Package-author rules:

- use semantic LaTeX constructs rather than low-level boxes where possible;
- use current kernel hooks instead of patching the output routine;
- confirm that every dependency is compatible or partially compatible with the
  intended restrictions;
- do not use fake math merely for vertical alignment;
- mark decorative content as artifact through supported tagging interfaces;
- provide real alternative text for meaningful graphics, or omit them from the
  default output;
- set the document language and keep `babel` or `polyglossia` configuration
  consistent with it **(planned — later phase)**; and
- validate the final PDF rather than assuming that `tagging=on` proves conformance.

Do not advertise PDF/UA conformance until a validator and manual inspection pass
for the exact release output.

## 8. Class and package architecture

### 8.1 Module layout (matches the repository)

CareerDossierTeX is modular. Keep classes thin and put reusable behaviour in the
shared packages. The Phase 1 modules are:

```text
careerdossier-base.sty        metadata, shared keys, required-field validation; no layout
careerdossier-typography.sty  XeLaTeX check, fontspec, portable fonts, semantic text roles
careerdossier-theme.sty       monochrome semantic colour/rule/link tokens
careerdossier-components.sty  identity block, contact line, link wrappers, entry primitives
careerdossier-resume.cls      Letter geometry, sections, entries, compact lists
careerdossier-letter.cls      industry-letter geometry, recipient block, salutation/closing
```

Do not place margins in `careerdossier-base`, and do not duplicate contact-line
logic inside both classes.

Later phases extend this set without duplicating the class hierarchy:
`careerdossier-cv.cls` and `careerdossier-biblatex.sty` **(planned — v0.2.0)**;
`careerdossier-statement.cls` **(planned — v0.4.0)**. Multilingual and RTL
support is **deferred and unscheduled** (see `docs/ROADMAP.md`); should it ever
return, it would extend the existing typography and component modules — and
introduce a label abstraction — rather than add language-specific classes.

### 8.2 Build on a stable base class

Use `\LoadClass` rather than reimplementing LaTeX's entire page, list, footnote,
and section machinery. `article` is a suitable base for the résumé; the letter
class may build on `article` or `letter` if its output order is tested. Override
only what the document type requires.

### 8.3 File identification and engine requirement

Every file should identify itself and its minimum kernel date:

```tex
\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesClass{careerdossier-resume}
  [2026-07-13 v0.1.0 ATS-conscious résumé class]
```

Choose the actual date based on the newest kernel interface used. The current LaTeX
class/package author guide notes that kernel key-value options
(`\DeclareKeys`/`\ProcessKeyOptions`) require at least the 2022-06-01 release.

Fail early and clearly under the wrong engine (the canonical check lives in
`careerdossier-typography.sty`). Do not allow pdfLaTeX or LuaLaTeX to proceed until
a late, confusing font error appears.

### 8.4 Public API: semantic, small, and stable

Public commands and environments use the `CDossier` prefix. The Phase 1 interface
(see `docs/API.md` for the authoritative list) includes:

```tex
\CDossierSetup{
  name     = {Ada Lovelace},
  headline = {Data Scientist},
  email    = {ada@example.org},
  location = {Toronto, Ontario}
}

\CDossierSection{Experience}

\begin{CDossierEntry}[
  title        = {Senior Analyst},
  organization = {Example Corporation},
  location     = {Toronto, Ontario},
  dates        = {January 2023 -- Present}
]
  \begin{CDossierItemize}
    \item Reduced processing time by 35 percent.
  \end{CDossierItemize}
\end{CDossierEntry}
```

Entry metadata is passed as an optional key-value argument in `[...]`, and values
containing commas are wrapped in braces (`location = {Toronto, Ontario}`). The
implementation stores keys and emits them in one documented canonical order,
regardless of the order in which users write them, and omits absent optional keys
without leaving separators or spacing artifacts.

Use `\NewDocumentCommand` and `\NewDocumentEnvironment` for public document
interfaces. Use `expl3` for internal data structures and logic. Internal names use
the private form `\__cdossier_<module>_<action>:<signature>`; never borrow another
package's internals and never expose private commands in examples or docs.

### 8.5 Options

Use the kernel's current key-value option system (l3keys-based) for new code. The
Phase 1 résumé keys are `fontsize` (`10pt`/`11pt`) and `density`
(`compact`/`standard`); `paper=letter`, `theme=monochrome`, and `language=english`
are fixed in `v0.1.0`. There is no `profile` key in Phase 1. Illustratively:

```tex
\DeclareKeys[careerdossier-resume]
  {
    density  .choice:,
    density / compact  .code:n = { \__cdossier_resume_density_compact: },
    density / standard .code:n = { \__cdossier_resume_density_standard: },
    density  .initial:n = standard,

    fontsize .store  = \l__cdossier_resume_fontsize_tl,
    fontsize .initial:n = 11pt,
  }
\ProcessKeyOptions[careerdossier-resume]
```

Exact property names follow the installed kernel/l3keys documentation. The design
rules matter more than the syntax:

- documented defaults are predictable;
- unknown options produce an actionable error or are deliberately passed to the
  base class;
- options do not silently change the text layer;
- every option combination shown in documentation has a regression test; and
- it is better to omit an unsupported option than to accept and ignore it.

### 8.6 Dependencies

- Load packages with `\RequirePackage`, not primitive `\input`.
- Specify a minimum version date when relying on a recent feature.
- Keep the dependency set small.
- Consult current package manuals and the tagging-status table before adding a
  dependency.
- Prefer kernel hooks through `\AddToHook` over legacy `every...` packages or
  direct patching.
- Avoid redefining unsupported LaTeX internals. Commands containing `@` are
  generally internal and may change.
- Use LaTeX box commands rather than TeX primitives where practical.

### 8.7 Diagnostics

Use `\ClassError`, `\ClassWarning`, `\ClassInfo`, or their package equivalents.
Every error should state (1) what failed, (2) why it matters, (3) what the user
should change, and (4) where the relevant documentation is.

Conditions worth diagnosing include: compilation under the wrong engine; an
unavailable selected font; an unsupported option value; a missing applicant name;
and duplicate critical metadata. Do not silently fall back from an unavailable
requested font to an arbitrary system font.

## 9. Repository and source organization

The repository uses a flat, handwritten `.sty`/`.cls` layout — which is fully
acceptable for CTAN — with source at the top level and examples, docs, and CI in
their own directories. This is the project's chosen path; a `.dtx`/`docstrip`
workflow is an optional future consideration, not a requirement (see §14).

Phase 1 layout (as in `docs/ARCHITECTURE.md`):

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
├── tests/
│   ├── regression/
│   ├── smoke/
│   ├── layout/
│   └── extraction/
│       ├── extraction-torture.tex
│       └── extraction-torture.expected.txt
├── docs/
│   ├── API.md
│   ├── ARCHITECTURE.md
│   ├── ROADMAP.md
│   ├── MIGRATION.md
│   └── guides/
│       └── ats-extraction.md
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
└── LICENSE
```

Later phases add `careerdossier-cv.cls` and `careerdossier-biblatex.sty`.
Regression infrastructure is not deferred to those phases: introduce an
`l3build` `build.lua` during Phase 1 and keep its suite under
`tests/regression/`.

Separate: public commands from internal implementation; content semantics from
visual details; user documentation from programmer documentation as the package
grows; examples from regression fixtures; and generated artifacts from tracked
source.

## 10. Compilation policy

### Supported command

```sh
xelatex -file-line-error -halt-on-error -interaction=nonstopmode document.tex
```

Use `latexmk -xelatex` for examples that need multiple runs. Do not hide required
shell escape, external converters, or non-TeX tools; the core should not need shell
escape.

### Reproducibility

Record in CI artifacts: XeTeX version; LaTeX format date; `fontspec` version;
`xdvipdfmx` version; font file names and hashes or package versions; operating
system; and extraction-tool versions. Avoid system-font-only defaults, because two
users with the same family name can have different font files.

### Warnings as engineering signals

Review the log for: missing font shapes; font substitutions; overfull boxes that
clip or overlap text; duplicate destinations; unsupported tagging constructs;
missing characters; option clashes; and deprecated interfaces. Do not make every
harmless TeX warning fatal, but maintain an explicit allowlist; a new warning
should fail CI until reviewed.

## 11. Testing strategy

### 11.1 Test layers

1. **Class/package regression tests** — API behaviour, options, errors, grouping,
   and load order **(l3build; Phase 1 onward)**.
2. **PDF extraction tests** — characters, spaces, reading order, and semantic
   adjacency **(Phase 1)**.
3. **PDF structural tests** — syntax, embedded fonts, metadata, tags, and
   accessibility claims.
4. **Rendered-page tests** — overlap, clipping, density, page breaks, contrast.
5. **Real-portal tests** — parsed preview or autofill where possible.

Add each layer's focused fixture with the implementation it validates. When
practical, run the new fixture before implementation and confirm that it fails
for the intended reason. All automated sources, expected outputs, runners, and
baselines belong under `tests/`; milestone release work reruns them but does not
defer their creation.

### 11.2 `l3build` for package tests **(Phase 1 onward)**

When `l3build` is adopted, configure it to use `tests/regression/` rather than a
top-level `testfiles/` directory. Verify the exact variable names against the
current manual; current manuals use engine names such as `xetex` for checks and
an executable name for documentation typesetting:

```lua
module = "careerdossier"
testfiledir = "tests/regression"

checkengines = {"xetex"}
stdengine    = "xetex"
checkformat  = "latex"
typesetexe   = "xelatex"

checkruns   = 2
typesetruns = 3
```

Add a regression test for every fixed bug. Inspect every newly saved `.tlg`;
`l3build` can detect change, but it cannot decide whether the new output is
correct. Also maintain negative tests proving that unsupported engines fail with
the intended message.

### 11.3 Ground-truth extraction fixture **(Phase 1)**

Include a document containing text like:

```text
Zoë Dvořák Łukasz İpek José
office efficient affine waffle difficult
(C++) (c++) C# F# R&D 100% AT&T
email@example.org +1 416 555 0199
https://example.org/a_b?q=one&lang=en
Senior Research & Development Engineer
January 2023 - Present
```

Add representative bullets, headings, links, page breaks, bold, and italic. The
expected file should contain the intended plain text in the intended order.

### 11.4 Command-line extraction

```sh
pdftotext -enc UTF-8 document.pdf document.txt
pdftotext -layout -enc UTF-8 document.pdf document-layout.txt
pdffonts document.pdf
qpdf --check document.pdf
```

Interpretation: default `pdftotext` is the more important reading-order signal;
`-layout` is a useful second view, not the canonical expected output; `pdffonts`
can reveal missing embedding but cannot prove correct mapping; `qpdf --check` tests
PDF syntax, not ATS semantics. Normalize line endings and Unicode deliberately
before diffing, but be cautious about normalizing all whitespace — removing too
much can hide missing word separators.

### 11.5 Multiple-consumer test

Copy and paste the same high-risk text in at least: Poppler (`pdftotext`); a
PDFium-based viewer such as Chrome; PDF.js in Firefox; and one additional common
target such as Adobe Acrobat Reader or macOS Preview. The Inter example shows why
one extractor is not enough. If consumers disagree, record the discrepancy and
choose the more conservative font or feature setup.

### 11.6 Reading-order assertions

Assert order and adjacency, not just a bag of words: applicant name precedes
contact information; the `Experience` heading precedes the first job; each title
remains near its organization and date; bullets remain under their entry;
`Education` does not interleave with `Skills`; and page furniture does not
interrupt sentences.

### 11.7 Visual regression

Render each example to PNG and inspect it after meaningful changes. Include narrow
and long values, multiple pages, long organization names, long URLs, and accents.
Check clipping and overlap; broken bold/italic; orphan headings; awkward page
splits; rules extending into text; contrast; and 200-400% zoom. Full automated
visual regression is a later-phase goal.

### 11.8 Tagged-PDF checks

When tagging is enabled, inspect the structure tree; check language metadata;
verify headings and lists; confirm decorative rules and page furniture are
artifacts; run the appropriate veraPDF profile if claiming a standard; and perform
at least one screen-reader reading-order check. Do not let accessibility tests
replace text-extraction tests.

### 11.9 Real portal acceptance

When a portal previews parsed fields, inspect and correct name, email, phone, job
titles, employers, date ranges, education, current location, and links. Follow the
portal's requested format. Greenhouse documentation has stated a parser input size
limit in one recruiting workflow, so keep PDFs compact and image-light; do not
treat that vendor-specific limit as universal, and re-check the current figure.

## 12. CI and release gates

Phase 1 CI runs every applicable committed suite under `tests/`, compiles both
supported examples on pushes and pull requests, installs a XeLaTeX-capable TeX
environment, uploads PDFs and logs as artifacts, and fails when tests or
compilation fail. Do not require a new status check in branch protection until
it has passed at least once.

Broader gates are later-phase targets: a CI matrix (current TeX Live, optionally
the oldest supported release, a scheduled pre-release job); mandatory failure on
new unexpected warnings, missing/substituted font faces, semantic extraction
differences, ordered-block failures, unembedded meaningful fonts, `qpdf --check`
errors, or visual clipping.

Run the full suite, not only unit tests, after changes to: fonts or font versions;
`fontspec` options; section or entry formatting; box, list, header, footer, or
page-break code; hyperlink or icon packages; tagged-PDF settings; bibliography
styles **(planned)**; minimum LaTeX version; the TeX Live image; or any dependency
that affects output.

## 13. Documentation requirements

Keep documentation in sync with behaviour, in the same change. Map to the
repository's existing files:

- `docs/API.md` — every public command, environment, key, default, required field,
  error, and warning; implemented behavior only.
- `docs/ARCHITECTURE.md` — module boundaries and namespaces, canonical text
  emission order, hooks, option-processing sequence, tagging assumptions, and the
  font/extraction policy summarized from this guide.
- `docs/ROADMAP.md` — phases, non-goals, and backlog items (including CTAN
  packaging and the tagging revisit).
- `docs/guides/ats-extraction.md` — this design and reference guide.
- `README.md` — only behavior that actually works; never present planned features
  as supported.

Keep examples fictional and realistic. Obvious placeholders such as `First Last` or
`Company 1` can themselves be skipped by parsers, as Greenhouse's documentation
notes. Use clearly fictional but plausible names and organizations.

## 14. CTAN readiness **(planned — v1.0.0)**

CTAN's requirements govern the uploaded archive, not the development repository. As
of July 2026 the core expectations, verified against
[CTAN's upload guidance](https://ctan.org/help/upload-pkg?lang=en), include:

- one `.zip`, `.tar.gz`, or `.tgz` archive;
- a top-level directory named for the package;
- a top-level `README`/`README.txt`/`README.md`, ASCII or UTF-8 (no BOM), in
  English, containing a licence statement and a version identifier;
- PDF documentation together with its source;
- no files that can be generated from other files, except the PDF documentation
  and derived fonts.

Handwritten `.sty`/`.cls` files are source and are included as-is; a `.dtx`/`.ins`
workflow is optional. CTAN in fact discourages *generated* `README` and `.ins`
files because they tend to go stale against their source. TDS packaging
(`.tds.zip`) is optional and, for a package without an elaborate install, generally
unnecessary.

When the project reaches this milestone, `l3build ctan` can generate and inspect
the release archive from the handwritten source; there is no need to migrate to
`.dtx`. Verify the archive manually before upload.

### Licence and fonts

- LPPL 1.3c or later is conventional for LaTeX code; the project uses LPPL 1.3c,
  maintenance status `maintained`, maintainer Amir Sadeghi.
- Give documentation and examples explicit licence terms.
- Do not assume a font licence permits bundling merely because the font is free to
  use in documents. List every bundled asset and its licence, and keep third-party
  notices and source links.

### Versioning and maintenance

- Keep release date and version synchronized across source, documentation, README,
  and CTAN metadata.
- Maintain a changelog that calls out extraction or rendering changes.
- State the minimum LaTeX release and TeX Live versions.
- Provide a public bug tracker and repository.
- Document deprecations before removing public interfaces, and add a regression
  test for each fixed parsing bug.

## 15. What to do and what not to do while writing the package

### Do

- design semantic commands before visual styling;
- keep the ATS-oriented output the default and simplest path;
- build on `article` or another stable base class;
- use `\RequirePackage`, `\NewDocumentCommand`, `\NewDocumentEnvironment`, current
  l3keys options, and kernel hooks;
- keep meaningful content in source order;
- use real headings, lists, text, and URLs;
- use reproducible TeX-distributed OpenType defaults and declare font faces
  explicitly;
- enable `\XeTeXgenerateactualtext=1`;
- disable risky optional substitutions in the Latin default;
- test every font/feature combination and compare extraction with known source
  text;
- inspect rendered pages and test tagging separately;
- fail clearly on the wrong engine.

### Do not

- promise universal ATS compatibility;
- use two columns or sidebars, or tables as a general layout engine;
- place contact details only in page furniture;
- use icon fonts for information without visible text;
- assume Unicode input guarantees Unicode extraction, that embedded fonts guarantee
  correct extraction, that `/ToUnicode` presence proves correctness, or that
  `/ActualText` is honoured by every viewer;
- globally disable required shaping for all languages;
- bundle proprietary fonts or depend on an OS font for the default build;
- copy code from a 2005 or 2007 class without checking modern interfaces;
- patch the output routine when supported hooks exist;
- hide keywords or make `/ActualText` disagree with visible content;
- treat an online ATS score as proof;
- present planned features (CV, statements, `biblatex`, CTAN packaging, a `profile`
  key) as if they were current.

## 16. Minimal reference template and class skeleton

### User template **(Phase 1)**

```tex
\documentclass[fontsize=11pt]{careerdossier-resume}

% Optional. pdftitle, pdfauthor, and pdflang are derived from the profile
% automatically; set them only to override the derived values. A \hypersetup
% anywhere in the preamble wins, before or after \CDossierSetup.
\hypersetup{
  pdftitle  = {Résumé — Zoë Dvořák},
  pdfauthor = {Zoë Dvořák}
}

\CDossierSetup{
  name     = {Zoë Dvořák},
  headline = {Data Scientist},
  email    = {zoe@example.org},
  phone    = {+1 416 555 0199},
  location = {Toronto, Ontario},
  website  = {example.org/zoe}
}

\begin{document}
\MakeCDossierHeader

\CDossierSection{Experience}
\begin{CDossierEntry}[
  title        = {Senior Research and Development Engineer},
  organization = {Northstar Analytics Inc.},
  location     = {Toronto, Ontario},
  dates        = {January 2023 -- Present}
]
  \begin{CDossierItemize}
    \item Improved C++ data-processing throughput by 35 percent.
    \item Led an R\&D team of five engineers.
  \end{CDossierItemize}
\end{CDossierEntry}

\CDossierSection{Skills}
C++, Python, SQL, data modelling, technical writing
\end{document}
```

### Class outline (illustrative)

```tex
\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesClass{careerdossier-resume}
  [2026-07-13 v0.1.0 ATS-conscious résumé class]

% Declare and process class keys (fontsize, density) here via l3keys,
% before \LoadClass. Pass documented base-class options deliberately.

\LoadClass[11pt]{article}

% Shared foundation. Load order may be adjusted as implementation requires,
% but dependency direction stays one-way (shared packages never depend on classes).
\RequirePackage{careerdossier-base}        % metadata, keys, validation (loads i18n)
\RequirePackage{careerdossier-typography}  % XeLaTeX check, fontspec,
                                           % \XeTeXgenerateactualtext=1, semantic roles
\RequirePackage{careerdossier-theme}       % monochrome tokens
\RequirePackage{careerdossier-components}  % identity block, contact line, entry primitives

\RequirePackage{hyperref}
\hypersetup{ unicode = true }
% pdflang / document language are routed through the i18n layer or a class
% `language` option, not hard-coded, so later multilingual phases can extend them.

% Résumé geometry, section spacing, and margins belong HERE (module ownership),
% not in careerdossier-base. Build entries from the shared semantic primitives —
% not from tables, columns, or positioned boxes.
```

The exact load order for `fontspec`, `hyperref`, language support, and any
tagging-related packages must be verified against current manuals and the test
suite. Do not freeze this illustrative order as policy without integration tests.

## 17. Release checklist

> This is the full CTAN-quality release checklist, targeted at `v1.0.0`. For Phase
> 1, the applicable subset is the **Document output** and **Extraction** groups
> plus basic build CI; the CTAN group is out of Phase 1 scope.

### Document output

- [ ] Single-column output is the default.
- [ ] Essential content appears in the document body.
- [ ] Headings are conventional and extract correctly.
- [ ] Dates remain associated with the correct entry.
- [ ] Links retain useful visible text.
- [ ] Bullets are standard list constructs.
- [ ] No icon, table, graphic, or colour carries unique meaning.
- [ ] No hidden or mismatched text exists.

### XeLaTeX and fonts

- [ ] Wrong engines fail early with a useful message.
- [ ] Default fonts are reproducible and legally distributable.
- [ ] Upright, bold, italic, and bold italic are explicit.
- [ ] `\XeTeXgenerateactualtext=1` is enabled.
- [ ] Ligature and alternate-feature policy is documented.
- [ ] Font versions are recorded and all meaningful fonts are embedded.

### Extraction

- [ ] Ground-truth text round-trips through Poppler.
- [ ] Default and `-layout` extraction have been inspected.
- [ ] Punctuation, accents, symbols, URLs, and ligature sequences pass.
- [ ] Ordered-block assertions pass.
- [ ] Copy/paste passes in at least two independent PDF engines.
- [ ] A real portal preview has been checked when feasible.

### Accessibility and rendering

- [ ] The default `hyperref` metadata route and the separate experimental
      `\DocumentMetadata` tagging route are documented.
- [ ] The current XeTeX interword-space limitation and warning are documented.
- [ ] No PDF/UA claim is made for XeLaTeX while the interword-space limitation
      remains.
- [ ] Rendered pages have no clipping, overlap, missing glyphs, or bad page breaks,
      and output is legible in grayscale and at high zoom.

### Package quality

- [ ] Public API is semantic and documented; internal names are namespaced.
- [ ] Current l3keys options and kernel hooks are used where appropriate.
- [ ] Errors and warnings are actionable.
- [ ] Every fixed bug has a regression test.
- [ ] User and programmer documentation build cleanly; changelog and version
      metadata agree.

### CTAN **(v1.0.0)**

- [ ] README, licence, PDF manual, and documentation source are present.
- [ ] Archive has one correctly named top-level directory.
- [ ] No temporary or prohibited generated files are included.
- [ ] Font and asset licences have been audited.
- [ ] `l3build check`, extraction tests, documentation build, and `l3build ctan`
      pass, and the final archive has been opened and inspected manually.

## 18. Ongoing maintenance rule

ATS parsing, PDF consumers, LaTeX's tagged-PDF implementation, `fontspec`, XeTeX,
fonts, and CTAN rules all change. Treat this guide as a maintained compatibility
document. At least once per release cycle:

1. read the latest LaTeX News;
2. check the current class/package author guide;
3. review current `fontspec` and `l3build` manuals;
4. review the tagging-status table for every dependency;
5. rerun the extraction matrix on current TeX Live;
6. test any changed font files;
7. inspect current CTAN upload guidance; and
8. update the compatibility statement with tested versions and known failures.

Optimize for evidence, not folklore: simple structure, explicit semantics,
reproducible fonts, defensive PDF text generation, and repeatable tests.

## Current external references

- [LaTeX News](https://www.latex-project.org/news/latex2e-news/ltnews.pdf)
- [LaTeX Project documentation index (class/package author guide)](https://www.latex-project.org/help/documentation/)
- [LaTeX package/class tagging status](https://latex3.github.io/tagging-project/tagging-status/)
- [`fontspec` documentation and package record](https://ctan.org/pkg/fontspec)
- [`l3build` manual](https://mirrors.ctan.org/macros/latex/contrib/l3build/l3build.pdf)
- [CTAN package upload guidance](https://ctan.org/help/upload-pkg?lang=en)
- [Inter issue 774: XeLaTeX text-extraction regression](https://github.com/rsms/inter/issues/774)
- [Checking PDF encoding and ToUnicode](https://stackoverflow.com/questions/53890212/how-to-check-if-encoding-and-tounicode-are-properly-done-for-a-pdf)
- [Greenhouse: unsuccessful resume parse](https://support.greenhouse.io/hc/en-us/articles/200989175-Unsuccessful-resume-parse)
- [Lever: understanding resume parsing](https://help.lever.co/hc/en-us/articles/20087345054749-Understanding-resume-parsing)
- [MIT: make your resume ATS-friendly](https://capd.mit.edu/resources/make-your-resume-ats-friendly/)

---

*Part of CareerDossierTeX. Licensed under LPPL 1.3c. Maintainer: Amir Sadeghi.
This document is design and reference material; `docs/API.md` and the compiled
examples remain the authority on shipped behavior.*
