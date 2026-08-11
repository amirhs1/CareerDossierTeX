# Engineering ATS-friendly career documents with LuaLaTeX

## A design and reference guide for CareerDossierTeX

**Status:** Design and reference material — describes the engineering contract the
package is built toward. It is **not** documentation of shipped behavior; only
`docs/API.md` and the compiled examples describe what is currently supported.
**Primary engine:** LuaLaTeX (LuaHBTeX). XeLaTeX was the engine through `v0.2.1`;
sections that discuss XeTeX behavior are retained as rationale and history, and
are marked as such.
**Current published scope (`v0.7.0`):** English industry résumé, industry and academic
cover-letter families, academic CV, statement documents, and optional publication
support; US Letter (default) and opt-in A4, monochrome, LuaLaTeX, and opt-in
tagged structure. The statement class supports a default statement of interest
plus six other statement types — see `docs/API.md` and `docs/ROADMAP.md`. Every
class accepts the calibrated `fontsize=10pt|11pt|12pt` and `margin=normal|narrow`
options plus `medium=print|screen`, which decides whether page furniture is
emitted at all, and `muted=italic|gray|both|plain`, which decides how an entry's
dates and location are de-emphasized; the résumé and CV no longer accept
`density`. Neither option changes the text layer or the reading order.
**Maintainer:** Amir Sadeghi
**Last reviewed:** 2026-08-03

> **Scope banner.** Material tagged **(Phase 1)** records the released `v0.1.x`
> foundation. Material tagged **(planned — vX.Y.Z)** describes future work
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

Use these rules as the default design contract. `v0.2.0` realizes the industry
and academic dossier subset; the rest guides later phases.

1. Make the default output single-column, linear, text-first, and restrained.
2. Put all essential information in the document body, not in headers, footers,
   pictures, icons, text boxes, overlays, or sidebars.
3. Use conventional section names and real text. Do not communicate meaning only
   through position, colour, or graphics.
4. Compile with LuaLaTeX, load fonts through `fontspec`, and treat every font file
   and OpenType feature combination as testable code.
5. Do **not** add per-word `/ActualText` spans. Consumers disagree on how to
   honour `/ActualText`; LuaHBTeX writes real interword spaces, so nothing of the
   kind is needed (section 4.5).
6. Keep source text in logical reading order. Visual placement must never require
   the parser to reconstruct the intended order.
7. Run automated round-trip extraction tests and manual copy-and-paste tests after
   changes to layout, fonts, symbols, dependencies, or the TeX distribution.
8. Keep ATS compatibility, PDF accessibility, and visual quality as separate
   release gates. They overlap, but passing one does not prove the others. In
   particular, tagged structure is opt-in and validated only for named fixtures
   (section 7).
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
  LuaLaTeX: <https://ctan.org/pkg/fontspec>.
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

The shipped entry heading takes the right-aligned form, and "it must be tested"
is not a formality: Poppler keeps the right-hand dates/location column with its
entry only while the entry's vertical band stays distinct from the block beneath
it. Close the following bullet list up against the heading and Poppler groups the
two bands, then sorts the column as trailing material — after the bullets, or,
on a page carrying furniture, after the `Page N of M` folio. The reordering is a
property of the component's geometry, not of tagging, and Apple PDFKit does not
show it. `tests/extraction/` pins the order for both classes; see section 11.6.

#### Why the component cannot fix this itself

Poppler groups lines into blocks by vertical proximity, then orders the blocks.
Its `-bbox-layout` tree shows the whole mechanism:

| list gap | blocks Poppler builds |
|---|---|
| wide (`0.3125`) | `[Senior Engineer / Example Labs]`, `[2024–Present / Toronto, ON]`, `[bullets]` — one flow, sorted top-to-bottom then left-to-right, so the column lands in place |
| tight (`0.125`) | `[Senior Engineer / Example Labs / bullets]`, then `[2024–Present / Toronto, ON]` — the heading and the list merge into one *tall* block |

`0.3125` is the value the token carried when #219 took this measurement, not
today's default; #206 later retuned it to `0.25`, which is where the floor
below now sits.

A tall left block that spans the entire vertical band of a short right-hand one
is Poppler's signature for a two-column page, so it emits the whole left column
before the right. The trigger is therefore page-level, not local to the heading:
with the tight gap unchanged, lengthening a bullet until it reaches the dates'
horizontal band restores the correct order on its own, because the left column
then overlaps the right and the two stop looking like separate columns.

That rules out repairing it inside `\__cdossier_components_entryhead:nnnn`.
Measured against the committed fixtures:

- The heading row is **already** one line box emitting title before dates in
  source order. Neither is what Poppler groups on.
- Changing the two heading lines' spacing, from −3 pt to +2 pt, never splits the
  merged block.
- Every invisible character that could bridge the gap fails. Poppler discards
  U+0020, U+00A0, and U+200B outright; U+2000, U+2002, U+2003, U+2007, U+2009,
  and U+205F are each absent from TeX Gyre Heros and raise hundreds of
  missing-character warnings.
- U+00AD *is* kept by Poppler and does bridge, but only as a dense run — one
  glyph every few points, roughly 130 per heading row. That draws a visible
  dashed rule across the heading and fills the text layer with soft hyphens,
  which breaks phrase search across the row. Ten evenly spaced glyphs do
  nothing.

So the constraint is carried by the vertical gap, and
`\CDossierRecordListEdgeAboveSkip` is the token that owns it.

Issue #302 does put a real U+0020 between the two cells, and that is not a
contradiction of the bullet above: it is emitted only on the tagged path, for a
consumer that reads the structure element's text, and Poppler discards it here
exactly as recorded — none of the extraction baselines moved. The two problems
are separate. This one is Poppler's *geometric* block grouping, which no
character fixes; #302's is the *logical* text of a structure element, which no
amount of geometry fixes. See 7.6.

#### The measured floor

`\CDossierRecordListEdgeAboveSkip` has an extraction floor of **0.25**. On the
`*-entry-dates-*` fixtures the column extracts with its entry at `0.25` and
reorders at `0.1875`, identically for the résumé and CV classes at 10 pt, 11 pt,
and 12 pt — so the floor is a property of the ratio, not of any body size. Since
#206 the committed default sits exactly *at* the floor rather than clear of it.

Any retune of this token must respect the floor. `tokens-invariants` states it
as a relation, and the three `*-entry-dates-*` fixtures fail if it is breached.
Note that it interacts with the design rule that a list sits nearer the entry
above it than the material below (`ListEdgeAbove < RecordEntryAboveSkip`):
holding both at once forces `RecordEntryAboveSkip` above `0.25` as well.

#### The escape: `entrymeta=inline`

Everything above says the floor cannot be removed *while the column exists*.
Issue #230 takes the remaining option and removes the column, behind a key:

```latex
\documentclass[entrymeta=inline]{careerdossier-resume}
```

Under `inline` the dates and location follow the title and organization on the
same line, joined by `\CDossierEntryMetaSeparator` (`~|~`). There is then no
horizontal gap on any heading row, so Poppler never splits the row, never builds
a short right-hand block, and never has two blocks to mistake for two columns.
The floor is not lifted under `inline` — it is inapplicable, because the fault
it stands in for cannot arise.

Measured on the committed `*-entry-inline-*` fixtures at `0.125`, half the
floor and the value at which the column form reorders:

| form | list edge | first entry's dates | last entry's dates |
|---|---|---|---|
| `column` | `0.25` | in place | after its bullets (a property of being the last block, at every value) |
| `column` | `0.125` | after its bullets | after its bullets |
| `inline` | `0.125` | in place | in place |

The last row is the result. `inline` at half the floor extracts *both* entries'
metadata in place, including the final one that no value of the list edge ever
fixed under `column`.

This does not change the calibration. `column` is the default, the committed
`0.25` is unchanged, and `tokens-invariants` still guards it; a document buys
the lower edge by selecting `inline` and setting the token itself, and gets no
warning if it sets the token without the option. See
[`API.md`](API.md) for the option and the separator token.

On the tagged path the two values are equivalent. The separator is emitted as a
layout artifact, as the contact line's `|` is, so the structure element text
reads `Engineer 2024–2026` under both — the same string, with the word boundary
coming from a real interword space under `inline` and from `\pdffakespace`
under `column` (see 7.6). `tests/tagging/resume-entrymeta-inline` pins that and
validates as PDF/UA-2.

### 3.5 Headers, footers, and page numbers

For a one- or two-page résumé, prefer no running header. For a long CV
**(supported in v0.2.0)**, a simple name-derived header and page number can help
humans, but they must not be
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
owns the concern — page geometry, margins, and the vertical rhythm belong in
`careerdossier-tokens.sty`, never in a class or in `careerdossier-base`. A class
chooses paper and options and passes them down. Do not scatter unexplained
numeric dimensions through the implementation. See `docs/ARCHITECTURE.md`
("File responsibilities") for the full ownership map.

## 4. Typography and font engineering under LuaLaTeX

Engine detection, `fontspec` loading, portable font selection, and semantic text
roles are owned by `careerdossier-typography.sty`. The examples below illustrate
the policy; in the implementation they live in that module.

### 4.1 Font choice is a build dependency

With LuaLaTeX, `fontspec` makes OpenType fonts easy to use through `luaotfload`,
but the output depends on:

- the exact font files and versions;
- the selected upright, bold, italic, and bold-italic faces;
- the renderer and script/language settings;
- enabled OpenType substitutions;
- LuaHBTeX and `luaotfload` versions; and
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

As of `v0.5.0`, every class exposes only
`bodyfont=serif|sans`. The default `serif` mode keeps TeX Gyre Termes for body
text and TeX Gyre Heros for headings; `sans` uses TeX Gyre Heros for both. Both
families are resolved by exact TeX Live file name with all four common faces
declared explicitly. Arbitrary installed fonts and per-role font selection are
not part of this interface.

### 4.3 Prefer literal Unicode source

Use UTF-8 source and actual Unicode characters for names and languages. Do not
require users to spell `Zoë`, `José`, `Łukasz`, or `İpek` with legacy accent
macros merely to accommodate an old engine. LuaLaTeX is the package baseline.

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
`\XeTeXgenerateactualtext=1` fixed Poppler extraction but not every PDF consumer,
and introduced a worse defect of its own — see section 4.5. The engine has since
changed, but the underlying lesson has not: a font version and feature
combination is a build dependency that must be tested, not assumed.

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
OpenType faces under LuaLaTeX, use the `...Off` form and verify against the
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

**Do not introduce per-word `/ActualText` spans.** Under LuaLaTeX the question is
moot — LuaHBTeX writes real interword spaces into the text layer, and the
XeTeX-only `\XeTeXgenerateactualtext` primitive does not exist. The extraction
runner still fails if `/ActualText` spans reappear by any route.

The rest of this section is the **history** that produced that rule. It is
retained because the reasoning still governs how extraction is tested, and
because it explains the `v0.2.1` release.

XeTeX's reference described the setting as adding `/ActualText` for better
copy/paste and search, and it was a real defence against shaped-glyph mapping
problems. But under XeTeX it wrapped **every word** in its own marked-content
sequence:

```
/Span << /ActualText (Research) >> BDC ... EMC
/Span << /ActualText (&) >> BDC ... EMC
```

with no space token between adjacent spans. The interword space existed only as
glyph geometry. A consumer therefore got a different answer depending on which
layer it trusted:

| Consumer | Strategy | Result |
|---|---|---|
| Poppler (`pdftotext`), MuPDF | Falls back to glyph positions | `Research & Development` |
| Apple PDFKit (`PDFDocument.string`) | Concatenates `/ActualText` | `Research& Development` |

PDFKit is not a niche consumer: it is the framework behind **Preview, Quick Look,
Spotlight indexing, Safari's built-in PDF viewer, and ordinary macOS
copy/paste**. A résumé that a recruiter pastes out of Preview loses a space at
most word boundaries — exactly the text an ATS then tokenizes.

The failure was invisible to a Poppler-only regression, which is why it shipped
in `v0.2.0` (issue #72). Measured against `tests/extraction/extraction-torture.tex`,
removing the setting changed Poppler output by **zero bytes** while fixing every
PDFKit merge, so nothing was traded away. The `v0.4.0` move to LuaLaTeX removed
the primitive along with the rest of the XeTeX code path; this class of defect
is now structurally impossible rather than merely disabled.

For this package the loss is small in any case: section 4.4's policy already
disables every optional ligature and alternate, which is the main scenario
`/ActualText` protects against.

More generally, `/ActualText` and `ToUnicode` are not sufficient evidence by
themselves because:

- PDF consumers vary in whether and how they honour `/ActualText` — and, as
  above, honouring it can be *worse* than ignoring it;
- a PDF may contain multiple fonts with different mappings;
- a `ToUnicode` CMap can exist but be incomplete or wrong;
- correct character mapping does not establish reading order; and
- an `/ActualText` string can itself be wrong.

The lesson generalizes past this one setting: **extraction correctness is
consumer-specific, so test more than one consumer.** The fixture runner gates on
Poppler, on the absence of `/ActualText`, and — on macOS — on PDFKit itself.

None of this is a tagging, PDF/UA, WCAG, or ATS-conformance claim. It concerns
the text layer only; see sections 7 and 8.

Never search a decompressed PDF for the word `ToUnicode` and call the document
validated. Use `pdffonts` for a quick inventory, inspect suspicious mappings when
needed, and compare extracted output with known ground truth.

### 4.6 A conservative font setup

This is a starting point, not a substitute for tests. In the implementation it
belongs in `careerdossier-typography.sty`, which owns the engine check and font
loading:

```tex
% expl3 form; the shipped guard uses \sys_if_engine_luatex:F with \msg_fatal:nn.
\sys_if_engine_luatex:F
  { \msg_fatal:nn { careerdossier-typography } { engine } }
% Message text: "CareerDossierTeX requires LuaLaTeX.
%                Compile with lualatex, not xelatex or pdflatex."

% No /ActualText workaround is needed: LuaHBTeX writes real interword
% spaces. See section 4.5.
\RequirePackage{fontspec}

\defaultfontfeatures+{
  Ligatures={CommonOff,ContextualOff,DiscretionaryOff,HistoricOff},
  Numbers=Lining
}

% Resolved by file name through luaotfload, so the build does not depend on
% OS-installed fonts.
\setmainfont{texgyreheros}[
  Extension      = .otf,
  UprightFont    = *-regular,
  BoldFont       = *-bold,
  ItalicFont     = *-italic,
  BoldItalicFont = *-bolditalic
]
```

The shipped default is the opposite of this illustration: `bodyfont=serif`
(TeX Gyre Termes body, TeX Gyre Heros headings) since `v0.5.0`, with
`bodyfont=sans` selecting Heros for both. The example above shows the mechanism,
not the default. Run the full extraction suite for both profiles when either
changes.

### 4.7 Font acceptance criteria

A font profile is releasable only if:

- all declared faces exist and are genuinely used;
- no silent synthetic bold or italic is required;
- all used fonts are embedded and subset as expected;
- punctuation, digits, symbols, accents, ligature sequences, URLs, and email
  addresses round-trip correctly;
- the profile passes with the current supported LuaHBTeX toolchain on each CI
  platform;
- text copies correctly in at least two independent PDF engines; and
- changes in font version trigger a fresh baseline review.

## 5. Semantic structure for each career-document type

### 5.1 Shared rules

All document types should provide:

- a real document title in PDF metadata, and the `ViewerPreferences` flag that
  makes a viewer use it instead of the filename;
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
`\CDossierSection` for headings. The `v0.2.0` academic CV adds a semantic manual
publication list on the same shared foundation; future document types may add
other entry kinds, such as references, without duplicating components per class.

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

### 5.4 Academic CV **(supported in v0.2.0)**

Academic readers often value structured publication and research sections, but the
PDF may still pass through a central HR platform. Keep:

- `Education`, `Academic Appointments`, `Publications`, `Research`, `Teaching`,
  `Grants`, `Awards`, and `Service` as recognizable headings;
- bibliographic entries in a predictable text order;
- DOI, ORCID, and profile identifiers as visible text when important;
- author emphasis as font weight, not a custom glyph or colour alone; and
- page breaks between entries rather than inside an entry where practical.

When using the optional `careerdossier-biblatex` integration, test the fixed
bibliography profile and every field type used. A bibliography package update
can change punctuation and extraction.

Two properties of that profile exist specifically to survive the default
extractor, and both are horizontal rather than vertical:

- **Entry numbers.** `pdftotext`'s default (non-layout) mode groups a narrow
  left column of short tokens once the gap to the text beside them reaches
  roughly one em, and then emits the whole column ahead of the text. BibLaTeX's
  default label separation sits on that threshold, so entry numbers extracted
  as `1)`, `2)`, `3)` in a block before any entry. The profile therefore uses
  the shared `\CDossierListLabelSep`, which is half the body size. Note what
  this is not: the PDF was correct throughout — every label shared a baseline
  with its entry, and `pdftotext -layout` reported source order — so the
  symptom is a heuristic in one extractor, and the fix belongs in the label
  geometry, never in the calibrated vertical gap between entries.
- **URLs.** Poppler splits a word wherever an intra-word gap exceeds 0.1 em.
  BibLaTeX stretches URLs at their break points to justify a line, which can
  push a URL past that and extract it as `https : / / example . invalid /`.
  The profile removes that stretch entirely rather than capping it. Capping was
  the original fix and it was only a mitigation, for a reason that turned out
  to be reachable with an ordinary address: TeX exceeds a stated stretch to set
  an otherwise underfull line. A 262-character query-string URL — a Wikipedia
  advanced-search result, not a contrived one — split at the CV's own
  `fontsize=12pt, margin=normal` with the cap in place (issue #312). Rigid glue
  is a guarantee where a cap was not, because TeX cannot stretch what has no
  stretch component, at any measure or URL length.

  Rigid glue has to be paid for in break points, exactly as body-text links are
  (below). With nothing to absorb the remainder of a line, TeX set the same URL
  5.09 pt into the margin instead; the profile therefore enables BibLaTeX's
  three `biburl*penalty` counters, which are 0 by default, so a URL may break
  inside a run of letters or digits when punctuation offers nowhere. Two
  visible consequences, both intended: URLs now break where the line ends
  rather than at the nearest earlier punctuation, so an address can wrap
  mid-run; and a line holding nothing but URL has no glue to justify with, so
  it is reported underfull and set ragged-right. Neither costs anything a
  reader pastes, and the tidier break they replace was bought by stretching the
  URL — which is the defect.

`tests/bibliography/run.sh` checks both the extracted text and, separately, the
label/entry baseline pairing read from `pdftotext -bbox`. The second check is
the one that stays meaningful if Poppler's grouping heuristic changes: it reads
the geometry out of the PDF instead of trusting the extractor's line grouping,
so an extractor change and a real regression stay distinguishable.

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

### 5.6 Statements — default interest plus six other types **(v0.5.0)**

One class defaults to a statement of interest and also covers research,
teaching, teaching-philosophy, diversity, artist, and statement-of-purpose
documents. These are closer to short articles:

- use ordinary paragraphs and semantic headings;
- avoid magazine-style columns;
- keep citations and footnotes sparse and extractable;
- use figures only when essential, with text alternatives when tagging is enabled;
- keep the title, applicant name, and required identity fields in the page-one
  body rather than only in running furniture; and
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

#### Copy-paste integrity

A reader who copies a URL or an e-mail address out of the PDF must get
something that pastes into a browser or a mail client. Stated checkably, that
is two requirements: the address must not be divided into several words within
one visual line, and when it legitimately wraps, its ordered line fragments
must concatenate back to the exact address. The character sequence is never
the problem; the *typesetting* is. In current Poppler versions the extractor
starts a new word when the spacing between two characters exceeds 0.1× the
font size, so a URL whose breakpoints were stretched to justify a line
extracts as `https : / / example . invalid /` — a text defect produced by a
line-breaking decision, and invisible in the rendered page.

Two things follow. First, a change that adds stretch at a URL's breakpoints is
an extraction change even though it touches no text: BibLaTeX's
`\biburlbigskip` default of `0mu plus 3mu` did exactly this in issue #199, and
`careerdossier-biblatex.sty` sets it rigid for that reason (§5.4 — it capped it
at `0mu plus 1mu` until issue #312 found a real URL long enough to defeat the
cap). Everywhere else `\Urlmuskip` is url.sty's `0mu`, and the contact line is
additionally immune because each item is measured in its own `\hbox` rather
than justified.

A link in body text is the third case, and it fails the other way round. It sits
in a justified paragraph with nothing measuring it, so a long address written as
plain text is *hyphenated*: the pasted URL then carries an inserted hyphen that
was never part of it, and no word-boundary check sees anything wrong, because
the hyphen is a legitimate character in a legitimate word.
[`\CDossierLink`](API.md#cdossierlink) is the supported form (issue #308). It
extends url.sty's `\UrlBreaks` with the letters and digits for one link, and
url.sty's break points carry a penalty and no discretionary hyphen, so a wrapped
address concatenates back exactly. `tests/links/resume-body-link.tex` pins that
for a bullet and for a prose paragraph.

`medium=screen` underlines author-written `\href` anchor text (issue #278), and
that decoration was chosen against exactly the constraints in this document. It
is drawn by `lua-ul` as a node attribute resolved at shipout, so it adds no box,
touches no glue, and moves no break point; `tests/links/resume-screen-links.tex`
pins the copy-paste invariant under `screen` as the fixtures above pin it under
`print`, and `tests/extraction/resume-link-decoration-{print,screen}.tex` share
one body so their committed baselines can be diffed against each other — the
text layer must be identical under both media, on every supported extractor.

`ulem` was tried first and is worth recording as a negative result, because it
passes everything except the check this project added in issue #302. `\uline`
reboxes its argument and rebuilds interword spaces as its own leaders. Poppler,
MuPDF, and PDFKit all read `public write-up` back correctly, because they
rebuild words from glyph geometry and the visual gap is still there; veraPDF
validates; no `/Artifact` appears. The structure tree is where it fails — the
Link element's logical text becomes `publicwrite-up`, so a screen reader
announces one word. Only `structure-text.pl` can see this, which is precisely
why it exists.

The address-as-text links this toolkit renders — the contact line,
`\CDossierLink`, an ORCID iD, a bibliography DOI — are never decorated, under
either medium. That is a legibility decision (see `docs/API.md`), and under a
reboxing underline it would also have been a correctness one.

Second, plain extracted text cannot check this: a legitimate line wrap and a
split token both read as whitespace. The decision needs word bounding boxes —
pieces on different visual lines are a wrap, pieces sharing one line are the
defect. `make links` (§11) is the assertion, and it carries a negative control
— a fixture that widens the bibliography's URL glue past the threshold on
purpose and must be reported as split — so the checker is re-proved against a
genuinely broken PDF on every run. The control sets that gap directly rather
than provoking justification into producing one: a stretch reaches the
threshold only when the line it lands on happens to need enough of it, which
put the same fixture on opposite sides of the threshold on the two supported
toolchains (issue #312). Because the word-break threshold is an extractor
implementation detail, each run records its `pdftotext` version, and the
guarantee is scoped to that extraction model — the PDFKit baselines in
`tests/extraction/` remain the second consumer the project checks.

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

For the default (untagged) output, set ordinary PDF metadata through `hyperref`
and do not invoke the tagging path:

```tex
\documentclass{careerdossier-resume}
\hypersetup{
  unicode = true,
  pdflang = en
}
```

`pdflang` records the PDF's natural language; it does not configure hyphenation or
script support. CareerDossierTeX is English-only and multilingual support is
dropped (see `docs/ROADMAP.md`), so hard-coding `pdflang = en` here is correct
and does not need a language-abstraction layer.

The title itself needs nothing set here: the classes derive `/Title` from the
profile and ask the viewer to display it (`/DisplayDocTitle`), on this path as
well as the tagged one. See [`API.md`](API.md) for the derived fields and how to
override them.

Opt in to tagged structure with `\DocumentMetadata` before `\documentclass`:

```tex
\DocumentMetadata{
  lang    = en,
  tagging = on
}
\documentclass{careerdossier-resume}
```

This placement has an architectural consequence: a class cannot retroactively
place `\DocumentMetadata` before its own loading. Tagging is therefore a document
decision, not a class option, and the documentation must say so rather than
pretending an internal late call is equivalent. `tests/tagging/` keeps paired
tagged and untagged fixtures for all five profiles so that the untagged path is
proven unchanged whenever tagging code moves.

As of the June 2026 LaTeX release, tagged-PDF work remains active and kernel
behaviour continues to change when `\DocumentMetadata` is used. The LaTeX Project
maintains a live
[package/class tagging status table](https://latex3.github.io/tagging-project/tagging-status/)
and reports ongoing changes in
[LaTeX News](https://www.latex-project.org/news/latex2e-news/ltnews.pdf). Check
both before adding or updating dependencies. **(Verify at release: confirm the
current LaTeX News issue number and its tagging notes.)**

The engine limitation that previously blocked this work is gone. `tagpdf` states
that only pdfLaTeX and LuaLaTeX have real interword-space support; XeTeX emitted
`engine/output mode xetex doesn't support the interword spaces`, and a TeX Live
2026 fixture compiled for this guide reproduced it (MuPDF recovered the visible
spaces while a PDFPlumber-based extraction merged some adjacent words — evidence
that geometry-based consumers compensate differently, not evidence of a sound
tagged text stream). Moving to LuaLaTeX in `v0.4.0` removed that constraint. See
the current
[`tagpdf` implementation documentation](https://mirrors.ctan.org/macros/latex/contrib/tagpdf/tagpdf-code.pdf).

Therefore:

- keep `tagging=on` **opt-in**, not the default, until validated output is broader
  than the named fixtures;
- keep paired tagged/untagged fixtures so an opt-out document's output is provably
  unaffected;
- run the supported extractor matrix against tagged output, not only untagged;
- claim no PDF/UA or WCAG conformance without a validator run and manual
  inspection of the exact release output — the validator half is now done for
  five named fixtures and recorded in section 7.1, the manual screen-reader half
  is tracked in section 7.2 and
  [issue #77](https://github.com/amirhs1/CareerDossierTeX/issues/77); and
- if strict PDF/UA conformance is an application requirement, state plainly that
  the current preview scope may be unsuitable.

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

### 7.1 Recorded validation results **(v0.4.0 plus the `v0.5.0` statement fixture)**

`tests/tagging/run.sh` builds each profile twice — once as `<name>.tex`
(`tagging=on`) and once as `<name>-ua2.tex`, which adds `pdfstandard=ua-2` over
the same body include — then validates the UA-2 variant with veraPDF and runs a
three-extractor matrix over the tagged variant. Reports land in
`tests/tagging/reports/` and are retained as CI artifacts, never committed.

**CI coverage.** The always-on `tagging` job in `.github/workflows/build.yml`
runs on every push and pull request but does not install veraPDF, so its
veraPDF gate is skipped there (named in the runner's `GATES NOT RUN`
summary). A separate `verapdf-scheduled` workflow
(`.github/workflows/verapdf-scheduled.yml`) runs weekly — and on demand via
`workflow_dispatch` — builds veraPDF from a pinned commit
(`veraPDF-apps@7d9b5c3f709846ab83f86ca1a538b24eac2d3f72`, tag `v1.30.2`; see
issue #94 for how the pin was chosen), and runs this same gate against the
five named fixtures. It is intentionally not a per-PR check: building veraPDF
from source costs several minutes, and tagging is an opt-in preview feature,
so the maintainer agreed on 2026-07-20 that a weekly schedule is enough to
catch upstream regressions without taxing routine work. Its reports upload as
the `verapdf-scheduled-reports` artifact.

Results recorded 2026-07-22 on macOS 15.7.5 (local run; see above for the
separate scheduled CI run):

| Fixture | Profile | veraPDF `ua2` | Poppler | MuPDF | PDFKit |
| --- | --- | --- | --- | --- | --- |
| `resume` | industry résumé | PASS | match | match | match |
| `cv` | academic CV, two pages | PASS | match | match | match |
| `letter` | industry letter | PASS | match | match | match |
| `academic-letter` | academic letter, two pages | PASS | match | match | match |
| `statement` | research statement, two pages | PASS | match | match | match |

Toolchain that produced this result, as recorded by
`tests/tagging/reports/toolchain.txt`:

| Component | Version |
| --- | --- |
| OS | macOS 15.7.5 (Darwin 24.6.0) |
| Engine | LuaHBTeX 1.24.0 (TeX Live 2026) |
| `pdfmanagement-testphase` | 0.97c (2026-05-26) |
| `tagpdf` | 1.0c (2026-05-17) |
| veraPDF | 1.30.0 (Homebrew formula 1.30.2) |
| Poppler `pdftotext` | 26.07.0 |
| MuPDF `mutool` | 1.28.0 |
| Biber | 2.21 |

Three extractors are used rather than one because Poppler, MuPDF, and PDFKit
each linearize the two-column entry header differently. Each therefore keeps its
own committed baseline (`*.expected.txt`, `*.mupdf.txt`, `*.pdfkit.txt`); a
shared baseline would only record whichever library ran last. The MuPDF baseline
is compared with blank lines removed, because `mutool`'s vertical whitespace
inside that header differs between its macOS and Debian builds — a property of
the extractor, not of the PDF. Line content and order remain fully asserted. Agreement across
three independent implementations is what supports the claim that reading order
is a property of the PDF rather than of one library's heuristics.

**What this does and does not license.** These five named artifacts passed a
PDF/UA-2 validator. That is not a PDF/UA, WCAG, accessibility, or ATS
conformance claim for arbitrary user documents, and it does not make `tagging=on`
safe to enable by default. A user document with different content, packages, or
graphics is unvalidated until it is itself validated.

### 7.2 Screen-reader reading-order checks

Automated validation cannot confirm that a document *reads* correctly. veraPDF
checks that structure exists and is well-formed; only a screen reader shows
whether decorative rules stay silent and whether headings, entries, and contact
lines arrive in a sensible order.

> **Status: macOS done, Windows outstanding.** A VoiceOver pass was performed by
> the maintainer on 2026-07-20; results below. The NVDA pass has not been run.

**macOS / VoiceOver (⌘F5), macOS 15.7.5 — performed 2026-07-20, Preview.**
Read top to bottom with `VO`+`→` over all four tagged fixtures.

- [x] headings announced as headings, in source order;
- [x] list items announced as list items;
- [x] the contact line announced as one coherent run — no merged words, no
      character-by-character spelling (the issue #72 regression stays fixed);
- [x] links announced as links;
- [x] horizontal rules and separators **not** announced;
- [x] the `cv` running header (`<name> -- Curriculum Vitae`) and its folio
      **not** announced on page two; and
- [x] the `academic-letter` repeated footer and `Page N of M` folio **not**
      announced on either page.

**Every artifact-suppression check passed.** Decorative and repeated page
furniture is silent to VoiceOver on all four profiles, which is the property
tagging was added to provide.

One behavior was observed and judged acceptable rather than defective. A
sentence ending in a link is announced in three parts — the leading prose, then
the link, then the final period as "period". For example, *"This page also
contains a meaningful academic-letter link."* reads as
`This page also contains a meaningful` / `academic-letter link` / `period`.

That split is the structure working correctly, not failing: the `/S /Link`
element genuinely is a separate node, and VoiceOver announces the trailing
period as its own run because it is a short isolated text run following that
node. HTML behaves the same way for `<a>…</a>.` — the split marks where the
link stops, which is information a listener needs. Merging the period into the
link would misreport the link's extent. No change is warranted.

> **Note:** the VoiceOver pass above covered the CV folio in its previous
> `Page N` wording. The folio now reads `Page N of M`; its artifact marking was
> re-verified programmatically and is unchanged, but a quick re-listen to
> `cv.pdf` page two would fully close this out.

**Windows / NVDA — deferred.** This project has no Windows machine and CI has no
Windows runner, so the NVDA pass is platform-deferred rather than complete. The
checklist is identical to the VoiceOver one, read with NVDA in Adobe Acrobat
Reader (browse mode, `↓` through the document). Anyone on Windows can run it and
record the result here; until then the release must not claim a Windows
screen-reader result. Tracked in
[issue #96](https://github.com/amirhs1/CareerDossierTeX/issues/96).

VoiceOver and NVDA differ in how they consume the structure tree, so the macOS
result above is evidence rather than proof. One screen reader passing does not
establish that both will.

### 7.3 Tagged BibLaTeX: feasibility and limitations

`tests/tagging/biblatex-ua2.tex` records how tagged BibLaTeX output currently
behaves. It is deliberately **non-blocking**: tagging support inside BibLaTeX
and Biber is upstream work, so a failure there does not gate the five named
profiles unless the cause is CareerDossierTeX's own code.

Recorded 2026-07-20 and reconfirmed 2026-08-06 against the heading-hierarchy
change in issue #267, the fixture builds and **passes** veraPDF `ua2`, and the
bibliography carries real structure rather than flat paragraphs — `/S /list`
with `/item`, `/itemlabel`, and `/itembody` per entry, `/S /Link` with `/URI`
for identifiers, and `/S /subsection` for the list heading (`\defbibheading`
renders it through the CV's own `\CDossierSection`, so it moved from `/H1` to
`/H2` alongside every other résumé/CV section heading — see 7.4). The
document identity (`\MakeCDossierHeader`) supplies the fixture's one `/S
/section`. The runner writes the observed role counts to
`tests/tagging/reports/biblatex-ua2-structure.txt` so this claim stays tied to
output rather than assumption.

Known limitations, all observed rather than assumed:

- **Biber is required, and the build is multi-pass.** The runner drives this
  fixture with `latexmk` instead of the two-pass LuaLaTeX loop the other
  fixtures use.
- **A bibliography-only document fails to build.** On the first pass the
  bibliography is still empty; a document whose only content is
  `\printbibliography` renders zero pages, and the PDF-management backend
  treats that as a fatal `no pages of output` error before Biber ever runs. Any
  tagged BibLaTeX document needs page-one content — a header is sufficient.
- **`tagpdf` emits a `unicode-math` advisory** under this configuration. It is
  benign and allowlisted in both the tagging and extraction runners.

This result is recorded, not advertised. Tagged BibLaTeX is not a supported
feature of `v0.4.0`; it is a feasibility measurement for a later phase.

### 7.4 Heading hierarchy (issue #267)

Before `v0.8.0`, the document identity (the name) carried no heading role at
all, while every résumé/CV section heading and the statement's own title
resolved to `/H1` in the kernel's default namespace — the document's only
heading level in use, and the level the identity should have occupied instead.
A screen reader navigating by heading level reached "Experience" or a
statement's title first, with nothing above it, and never reached the name
that way at all.

The identity is now the document's one and only depth-1 heading (`/S
/section`, which the kernel's default namespace maps to `/H1`), and it
precedes every other heading in source order because it is always the first
line the shared header stack renders. Everything that used to sit at depth 1
moved one level down, so the hierarchy is unskipped beneath it:

| Profile | `/H1` | `/H2` | `/H3` |
| --- | --- | --- | --- |
| Résumé | the name | each `\CDossierSection` heading | each `\CDossierSubsection` heading |
| Academic CV | the name | each `\CDossierSection` heading (including a `careerdossier-biblatex` bibliography heading, which renders through the same command) | each `\CDossierSubsection` heading |
| Industry and academic letter | the name | — | — |
| Statement | the name | the statement's title, and each `\CDossierSection`/`\section*` heading | each `\CDossierSubsection`/`\subsection*` heading |

The letter has no `/H2`: it carries no section-heading component, so its
identity `/H1` is the only heading in the document, which is a valid (if
trivial) hierarchy rather than a skip.

The record classes' `/H3` row is new in #337 and is the reason the level exists
at all: a group inside a section — journal against conference publications,
industry against academic experience — was previously expressible only by
promoting it to a `/H2` of its own, which told a screen reader the group was a
peer of the section containing it. A `\CDossierSubsection` heading also opens a
depth-3 `Sect` division nested inside its section's, so the entries beneath it
belong to the group and not merely to the section. `tests/tagging/cv-subsection`
asserts the counts and the role mapping, and passes veraPDF UA-2 — a skipped
heading level is a UA-2 failure, so the validator sees this too.

**How this reaches a screen-reader user.** A tagged PDF's structure tree
supports two different ways of consuming it: "Say All" walks every leaf in
document order at any heading level, while jumping by heading (VoiceOver's
rotor set to "Headings", or the `H` key in NVDA/JAWS) visits only
`/H1`–`/H6` elements, in order, skipping everything between them. This
change affects only the second mode — for the résumé fixture:

```text
"Say All" -- reads every leaf, in document order, at any heading level.
This is unaffected by #267; the résumé fixture reads the same either way:

  1.  Ada Lovelace                        <- /H1  (the identity)
  2.  Analytical Engine Programmer
  3.  ada@example.test . +1 555 0100
  4.  Experience                          <- /H2
  5.  Senior Engineer -- Example Labs
        - shipped the thing
        - fixed the other thing
  6.  Education                           <- /H2
  7.  PhD, Somewhere University

Heading navigation -- visits only /H1-/H6 elements, in that order,
skipping everything between them (VoiceOver rotor set to "Headings";
the H key in NVDA/JAWS). This is what #267 changes:

  Before #267                    After #267
  ---------------------------    ---------------------------
  H2  Experience                 H1  Ada Lovelace
  H2  Education                  H2  Experience
                                  H2  Education
  (the identity is never
   reached this way)
```

Every line on the "Say All" side reaches a screen-reader user either way, in
the same order — that is what the extraction and word-geometry gates in 7.1
already cover, and why this change touches none of them. The heading-jump
list is the part that was silently broken: before #267 it read `H2
Experience`, `H2 Education` and stopped there, because the identity carried
no heading role to be listed at all. A screen-reader user who orients by
heading level, rather than reading straight through, had no way to land on
whose résumé this was without first "Say All"-ing past it or arrowing past
the sections one line at a time. `/H1` is what makes the identity a stop on
that jump list, and the first one.

Mechanically, the shared heading primitive
(`\__cdossier_typography_heading:nnn` in `careerdossier-typography.sty`) takes
the heading depth as an explicit argument rather than assuming depth 1, and
the statement's native `\section`/`\subsection` (kept for their `Sect`-opening
tagging behavior; see `careerdossier-statement.cls`) moved from levels 1/2 to
2/3. `tests/tagging/run.sh`
gates this: every one of the five named profiles must carry exactly one `/S
/section` element, and an `/S /subsubsection` element may appear only where an
`/S /subsection` element also does.

This is a structure-tree change only. It does not alter rendered layout, and
the untagged path is unaffected because the heading primitive's untagged
branch does not depend on the depth argument. `Sect` divisions around
résumé/CV section headings were out of scope for this change and are covered
in 7.5 below.

### 7.5 Section divisions (issue #268)

A heading element records that some words are a heading. On its own it records
nothing about *extent* — where the section it names begins and ends. That is
the enclosing `Sect` division, and without one every heading and every
paragraph in the tree is a flat sibling of every other, with nothing tying a
section's content to the heading that introduces it.

Before `v0.8.0`, the résumé and the academic CV emitted **zero** `Sect`
divisions around two headings each, while the statement emitted one per
section. The difference was purely mechanical: `careerdossier-statement.cls`
kept the kernel's `\@startsection`, whose tagging support opens the division
for it, and the record classes render their headings through the shared
display primitive, which opens a bare heading element and nothing else. The
statement's own source comment had described that primitive as deficient for
exactly this reason since issue #177; the record classes had simply never been
brought over.

`\CDossierSection` in `careerdossier-resume.cls` and `careerdossier-cv.cls` now
opens the division itself, through
`\__cdossier_typography_division_begin:n` in `careerdossier-typography.sty`.
That primitive uses the kernel's own `sec/begin` and `sec/end` tagging
sockets rather than a private `\tag_struct_begin:n`/`\tag_struct_end:` pair, so
it shares the kernel's section stack: a sibling heading closes the previous
division before opening its own, and any division still open at the end of the
document is closed by the kernel's existing `tagpdf/finish/before` hook. This
is the same mechanism `\@startsection` gives the statement, so both families
now produce the same shape. Each heading additionally records its own plain
text as the element's `/T`, which is what the kernel already did for the
statement.

A CV's manual publication list needs no division of its own: it is a list
placed under an ordinary `\CDossierSection`, so the section's division already
encloses it. The section rule stays an `/Artifact` and contributes nothing to
the tree.

This too is a structure-tree change only. The division primitive emits no
typeset material in either branch, and callers open the division *after* their
`\addvspace` so that no structure node can land between the skip and the
vertical list it inspects. Two measurements back that: `make tagging`'s
tagged-versus-untagged word geometry gate, and a direct `pdftotext -bbox`
comparison of the tagged résumé and CV fixtures against their pre-change
builds, in which every word box is identical. `tests/tagging/run.sh` gates the
result: a per-profile `/S /Sect` count, and the heading title, which a PDF
stores as UTF-16BE hex rather than as readable characters.

Like #267, veraPDF UA-2 passed on both fixtures before and after — a flat tree
is structurally legal — so the count in the runner is the only thing that sees
this.

**Heading titles (issue #305).** #268 gave section headings a `/T` and left
every other heading without one, so a résumé section was titled while the
applicant's name — the document's `/H1`, and the heading that outranks it — was
not. Every heading now records its own text: the identity in all four families,
and the statement's title line as well. Two notes on the shape this took:

- **The `Sect` divisions still carry no `/T`, deliberately.** #268's acceptance
  criterion read "recorded as the division's title, as it is in the statement",
  and those halves contradict each other — no `Sect` in any family has a `/T`,
  including the statement's, which the kernel generates. The kernel puts
  `title-o` on the `sec/<n>/title` element, so that is where all four families
  put it. Titling the record classes' divisions would re-open exactly the
  résumé/CV-versus-statement divergence #268 closed.
- **A protected command in the title argument records the wrong title, not no
  title.** The title is purified before it is written, and purification expands
  what it can and discards what it cannot. `\CDossierPrintField` is protected,
  so it was stripped and its *argument* text survived: the first attempt
  recorded the literal string `name` for every profile. Nothing on the rendered
  page shows this, and veraPDF is indifferent to the value of a `/T`. The
  identity call sites use the expandable `\CDossierFieldValue` instead, and the
  tagging fixture asserts the decoded value per profile rather than merely
  asserting that some title exists.

### 7.6 Structure tree by profile

The table and diagram above show the heading skeleton only. This section shows
the **complete** tagged structure of each named fixture — every heading, link,
list, and paragraph, in document order, with its actual extracted text — so
the reading and heading-navigation experience is visible for every component,
not only headings.

Recorded 2026-08-06, refreshed 2026-08-07 for issue #302's separator fix,
decoded byte-for-byte from the committed fixtures' `/StructTreeRoot` and
content streams (`/K` → `/MCR` → `/MCID` → the marked-content run's own
`Tj`/`TJ` glyph codes, resolved through each font's embedded `/ToUnicode`
CMap) — not inferred from the source `.tex`. That decoding is no longer a
one-off: `tests/tagging/structure-text.pl` performs it, and the trees below are
the committed `tests/tagging/*.structure.txt` baselines it now asserts against.
`=>` shows the exact text a consumer that reads structure (rather than glyph
geometry) would receive for that element; an `[annotation: ...]` line is an
`/OBJR` pointing at a link annotation, not text a screen reader announces on
its own. Running headers, folios, decorative rules, and separator characters
are `/Artifact`s and are correctly **absent** below — that is the intended
result of 7's "mark decorative content as artifact" rule, not an omission.

**Two things are worth reading closely, not just skimming past.**

First, a handful of `/text` leaves below are marked `(no visible text)`. These
are real, structurally-present elements that carry zero glyphs — they sit at
the boundary where the shared header stack's closing `\addvspace` (and, in the
résumé and CV, the section rule's own paragraph) ends one automatically-tagged
paragraph and starts the next. A screen reader passes over an empty element
silently, so these are inert, but they are why the tree below has more
`/text-unit` nodes than a count of visible lines would predict — issue #267's
own motivating résumé example undercounted them for the same reason.

Second, and more substantively: **a `/text` leaf that contains more than one
run used to concatenate those runs with no separating character at all.** This
is different from an ordinary sentence that happens to contain a link (marked
`‖` below; that case is fine — the embedded `/Link` element supplies the
reading-order gap). The genuine case was a two-column or two-line layout built
with `\hfill` or `\\` alone: the entry heading's title/dates row, its
organization/location row, and the letter's stacked recipient lines all land in
**one** marked-content run, and nothing — neither a space character nor a
second structure element — separated the two halves in the content stream. The
decoded content a structure-aware consumer received was the literal string
`Engineer2024–2026`, and, for a letter with a full recipient address,
`Casey ReaderHead of EngineeringExample Company123 Discovery AvenueVancouver,
BC V6T 1Z4`. Same root cause as 4.5's retired `/ActualText` history —
positioning glyphs by absolute coordinates rather than by a real interword
space — in a location that history did not cover.

Issue #302 fixed this, and the trees below show the fixed output. The remedy is
tagpdf's own `\pdffakespace`, which emits a real U+0020 into the content stream
at zero rendered width. Two things make that the right instrument rather than a
workaround:

- The interword spaces inside ordinary prose already arrive by exactly this
  route. Tagged output carries real space glyphs where untagged output has only
  `TJ` kerns; tagpdf inserts them for any glue of positive natural width that
  sits next to a glyph. `\hfill` has **zero** natural width, and that — not
  anything about two-column layout — is the whole reason these joins were
  skipped.
- Zero rendered width means the fill still absorbs the entire line, so no glyph
  moves. The untagged example PDFs are byte-identical across the fix apart from
  their timestamps and `/ID`, and not one of the Poppler, MuPDF, or PDFKit
  baselines in 7.1 changed.

Two details are worth keeping. In the letter the separator hangs off `\\`
itself for the length of the recipient block, not off the four field call
sites: a recipient address carries the user's own `\\` **inside a single field
value**, so a call-site fix would have left that break glued. And
`\pdffakespace` expands to a zero-width *skip*, which is discardable on either
side of a forced line break — placed bare before or after the `\\` it is
dropped again and no character is emitted at all. It has to be boxed.

**Still not verified against a live screen reader.** Everything above is
established at the byte level. Whether the glued form actually misread in
VoiceOver or NVDA — and so whether this was a real defect for a user rather
than only a structurally wrong one — was never confirmed, and the fix does not
confirm it retrospectively. 7.2's manual pass is what would.

**Why nothing caught it.** Poppler's default extraction already separates these
onto different lines (see 7.1's baselines), because it splits on the horizontal
gap; MuPDF and PDFKit likewise rebuild words from glyph geometry. Every
extractor in the matrix was therefore structurally incapable of seeing a
missing character. `make tagging` now decodes the content stream itself
(`tests/tagging/structure-text.pl`), diffs the result against a committed
`*.structure.txt` baseline per fixture, and additionally asserts each two-cell
row's separator by name so the defect cannot be waved through by regenerating a
baseline. `tests/tagging/letter-recipient-address.tex` exists because no
previous fixture set `recipient-address` at all.

#### Résumé

```text
/Document
  /section                              => 'Tagged Industry Resume'            [/H1]  (also its /T)
  /text-unit
    /text                                => 'Accessibility Engineer'
  /Link                                  => 'resume@example.test'   (mailto: link)
  /text                                  => '+1 555 0100'           (not a link)
  /Link                                  => 'example.test/resume'   (https: link)
  /text-unit
    /text                                (no visible text)
  /Sect
    /subsection                          => 'Experience'                       [/H2]  (also its /T)
    /text-unit
      /text                              (no visible text)
    /text-unit
      /text                              => 'Engineer 2024–2026'
    /text-unit
      /text                              => 'Example Labs Toronto'
    /text-unit
      /itemize
        /item
          /itemlabel                     => '•'
          /itembody
            /text-unit
              /text                      => 'First resume achievement in source order.'
        /item
          /itemlabel                     => '•'
          /itembody
            /text-unit
              /text                      => 'Second resume achievement with a meaningful ' ‖ '.'
                /Link                    => 'work link'
  /Sect
    /subsection                          => 'Additional Experience'            [/H2]  (also its /T)
    /text-unit
      /text                              (no visible text)
    /text-unit
      /text                              => 'Senior Engineer 2022–2024'
    /text-unit
      /text                              => 'Example Services Ottawa'
    /text-unit
      /itemize
        /item
          /itemlabel                     => '•'
          /itembody
            /text-unit
              /text                      => 'Second-page resume content after the shared page furniture.'
```

The two `/Sect` divisions are issue #268's (7.5). Everything a section
introduces is now inside the division its heading opens, and the heading's own
text is repeated as the division-opening element's `/T` — the same shape the
statement below has had since #177.

#### Academic CV

Identical shape to the résumé — the same `\MakeCDossierHeader` and
`\CDossierSection` produce it — with its own field values and, on the second
page, one entry whose `location` is blank (`\tl_if_blank:nF` correctly omits
the row rather than leaving a stray separator, per rule 5):

```text
/Document
  /section                              => 'Tagged Academic CV'               [/H1]
  /text-unit
    /text                                => 'Research Engineer'
  /Link                                  => 'cv@example.test'
  /text                                  => '+1 555 0101'
  /Link                                  => 'example.test/cv'
  /text-unit
    /text                                (no visible text)
  /subsection                            => 'Research Experience'             [/H2]
  /text-unit
    /text                                (no visible text)
  /text-unit
    /text                                => 'Researcher 2023–2026'
  /text-unit
    /text                                => 'Example University Toronto'
  /text-unit
    /itemize
      /item /itemlabel => '•' /itembody /text-unit
        /text                            => 'First CV achievement in source order.'
      /item /itemlabel => '•' /itembody /text-unit
        /text                            => 'Second CV achievement with a meaningful ' ‖ '.'
          /Link                          => 'research link'
  /subsection                            => 'Teaching Experience'             [/H2]
  /text-unit
    /text                                (no visible text)
  /text-unit
    /text                                => 'Instructor 2025'
  /text-unit
    /text                                => 'Example University'              (location blank, rule 5: no stray separator)
  /text-unit
    /itemize
      /item /itemlabel => '•' /itembody /text-unit
        /text                            => 'Second-page CV content after the running header.'
```

#### Industry letter

No section-heading component at all, so nothing below the identity carries a
heading role — flat prose, in reading order:

```text
/Document
  /section                              => 'Tagged Industry Letter'            [/H1]
  /Link                                  => 'letter@example.test'
  /text                                  => '+1 555 0102'
  /text-unit
    /text                                (no visible text)
  /text-unit
    /text                                => 'July 20, 2026'
  /text-unit
    /text                                => 'Casey Reader Example Company'
  /text-unit
    /text                                => 'Application for Engineering Role'
  /text-unit
    /text                                => 'Dear Casey Reader,'
  /text-unit
    /text                                => 'The first industry-letter paragraph precedes the second in source order.'
  /text-unit
    /text                                => 'The second industry-letter paragraph contains a meaningful ' ‖ '.'
      /Link                              => 'letter link'
  /text-unit
    /text                                => 'The third industry-letter paragraph appears on page two after the shared running header and above the folio.'
  /text-unit
    /text                                => 'Sincerely,'
  /text-unit
    /text                                => 'Tagged Industry Letter'
```

#### Academic letter

Same shape as the industry letter (`family=academic` changes running-head
wording and closing conventions, not structure):

```text
/Document
  /section                              => 'Tagged Academic Letter'            [/H1]
  /Link                                  => 'academic-letter@example.test'
  /text                                  => '+1 555 0103'
  /text-unit
    /text                                (no visible text)
  /text-unit
    /text                                => 'July 20, 2026'
  /text-unit
    /text                                => 'Jordan Reader Example University'
  /text-unit
    /text                                => 'Application for Faculty Role'
  /text-unit
    /text                                => 'Dear Jordan Reader,'
  /text-unit
    /text                                => 'The first academic-letter paragraph appears on page one before the page break.'
  /text-unit
    /text                                => 'This page also contains a meaningful ' ‖ '.'
      /Link                              => 'academic-letter link'
  /text-unit
    /text                                => 'The second academic-letter paragraph appears on page two after the repeated footer from page one and before the closing.'
  /text-unit
    /text                                => 'Sincerely,'
  /text-unit
    /text                                => 'Tagged Academic Letter'
```

#### Statement

The profile with the most heading roles in one document: an `/H1` name, an
`/H2` for both the title line and each section, and a `/Sect` division per
section. The divisions come from the kernel's native
`\section*`/`\CDossierSection` — see `careerdossier-statement.cls` and issue
#177 — where the résumé and CV above open theirs explicitly (7.5); the
resulting shape is the same. This fixture does not exercise
`\CDossierSubsection`, so no `/H3` appears here; see 7.4's table for where one
would:

```text
/Document
  /section                              => 'Tagged Research Statement'         [/H1]  (also its /T)
  /subsection                           => 'Research Statement'                [/H2]  (the title line; also its /T)
  /text-unit
    /text                                => 'Reliable computational inquiry'   (subtitle)
  /text-unit
    /text                                => 'Example University'              (affiliation)
  /text-unit
    /text                                => 'Application for Faculty Role' ‖ 'Application ID: APP-104'
  /Link                                  => 'statement@example.test'
  /text                                  => '+1 555 0104'
  /Link                                  => 'example.test/statement'
  /Link                                  => 'ORCID: 0000-0002-1825-0097'
  /text-unit
    /text                                (no visible text)
  /Sect
    /subsection                         => 'Research Vision'                   [/H2]
    /text-unit
      /text                              => 'The first statement paragraph contains a meaningful ' ‖ '.'
        /Link                            => 'statement link'
  /Sect
    /subsection                         => 'Future Programme'                  [/H2]
    /text-unit
      /text                              => 'The second statement paragraph appears on page two.'
```

The context line (`'Application for Faculty Role' ‖ 'Application ID:
APP-104'`) is structurally two adjacent leaves, not one glued run, because the
`|` between them is its own `/Artifact` and interrupts the marked-content run
— unlike the entry-heading and recipient-block cases above, which never opened
a second run at all. It is therefore untouched by #302's fix and still carries
no character between its halves: what separates them is an element boundary,
not a space. Whether two separate accessible elements, read back to back with
their artifact-only separator invisible to the consumer, are any more legible
than one glued run is exactly the kind of question 7.2's manual screen-reader
pass, not a structural count, can actually answer.

## 8. Class and package architecture

### 8.1 Module layout (matches the repository)

CareerDossierTeX is modular: keep classes thin and put reusable behaviour in the
shared packages. `docs/ARCHITECTURE.md` is the authoritative module map and
dependency direction; the ATS-relevant rules are that margins never live in
`careerdossier-base` and contact-line logic is never duplicated across classes.

Multilingual and RTL support is **dropped** (see `docs/ROADMAP.md`); should it
ever return, it would extend the existing typography and component modules —
and introduce a label abstraction — rather than add language-specific classes.

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
  [2026-07-30 v0.6.0 ATS-conscious résumé class]
```

Choose the actual date based on the newest kernel interface used. The current LaTeX
class/package author guide notes that kernel key-value options
(`\DeclareKeys`/`\ProcessKeyOptions`) require at least the 2022-06-01 release.

Fail early and clearly under the wrong engine (the canonical check lives in
`careerdossier-typography.sty`). Do not allow pdfLaTeX or XeLaTeX to proceed until
a late, confusing font error appears. LuaLaTeX is the supported engine.

### 8.4 Public API: semantic, small, and stable

Public commands and environments use the `CDossier` prefix; `docs/API.md` is the
authoritative list with signatures, keys, and defaults. Two properties matter
for extraction: the implementation emits stored keys in one documented canonical
order regardless of input order, and it omits absent optional keys without
leaving separators or spacing artifacts.

Use `\NewDocumentCommand` and `\NewDocumentEnvironment` for public document
interfaces. Use `expl3` for internal data structures and logic. Internal names use
the private form `\__cdossier_<module>_<action>:<signature>`; never borrow another
package's internals and never expose private commands in examples or docs.

### 8.5 Options

Use the kernel's current key-value option system (l3keys-based) for new code;
`docs/API.md` lists each class's accepted option values and defaults. The design
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
workflow is an optional future consideration, not a requirement (see §14). See
`docs/ARCHITECTURE.md` for the current repository layout and module set, and
`build.lua` for the `l3build` regression configuration under `tests/regression/`.

Separate: public commands from internal implementation; content semantics from
visual details; user documentation from programmer documentation as the package
grows; examples from regression fixtures; and generated artifacts from tracked
source.

## 10. Compilation policy

### Supported command

```sh
lualatex -file-line-error -halt-on-error -interaction=nonstopmode document.tex
```

Use `latexmk -lualatex` for examples that need multiple runs. Do not hide required
shell escape, external converters, or non-TeX tools; the core should not need shell
escape.

### Reproducibility

Record in CI artifacts: LuaHBTeX version; LaTeX format date; `fontspec` version;
`luaotfload` version; `tagpdf` and `pdfmanagement-testphase` versions; font file
names and hashes or package versions; operating system; and extraction-tool
versions. Avoid system-font-only defaults, because two
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

The regression harness is configured in `build.lua` (`tests/regression/`,
LuaTeX, LaTeX format); `CONTRIBUTING.md` documents how to run and save its
checks. Two disciplines are load-bearing for a text-layer-sensitive package:
add a regression test for every fixed bug, and inspect every newly saved
`.tlg` — `l3build` detects change but cannot decide whether the new output is
correct. Maintain negative tests proving unsupported engines fail with the
intended message.

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

**Entry-head column order is covered** (issue #221). Three fixtures in
`tests/extraction/` assert that an entry heading's right-hand dates/location
column extracts between its heading and its bullets, on the untagged path this
suite builds:

| Fixture | Class | Pages | What it adds |
|---|---|---|---|
| `resume-entry-dates-order` | résumé | 1 | the cheapest form of the assertion |
| `cv-entry-dates-order` | CV | 1 | the same component under CV geometry |
| `resume-entry-dates-page-furniture` | résumé | 2 | running header and folio present |

Two findings from building them are worth keeping, because they decide what a
fixture of this kind has to look like:

- **Two entries, not one.** The last entry sorted on a page always trails its
  own column, at every list-edge value. A one-entry fixture therefore cannot see
  the fault appear or disappear — which is why the three pre-existing fixtures
  with dates (`resume-contact-optional`, `resume-contact-wrap`,
  `cv-contact-optional`) stayed green throughout the #219 regression. The
  assertion lives on an entry that is followed by more material.
- **Page furniture is sufficient, not necessary.** A single page with two
  entries reproduces the reordering exactly as the two-page form does; the folio
  only makes it more conspicuous by putting the dates below the page furniture.

Poppler is the discriminating consumer here. The committed `*.pdfkit.txt`
baselines keep each heading row on one line at every value tested, so they
record the layout but do not detect the fault.

**Link copy-paste integrity is covered** (issue #294). `tests/links/`
(`make links`) asserts that no URL or e-mail address is emitted as two or more
words sharing a visual line, and that a wrapped one reassembles exactly — see
§6, "Copy-paste integrity", for the mechanism. One fixture per link site: the
résumé contact line, the CV contact line and its manual publication list, both
letter families, and the BibLaTeX bibliography.

Three properties of the suite are the point of it:

- **It reads coordinates, not text.** `pdftotext -bbox` is what distinguishes a
  wrap from a split; the plain text of the two is identical. Line identity is
  inferred from `yMin` — the top of the word box, a line-position proxy rather
  than the typographic baseline, hence a small tolerance.
- **It declares its expectations in the fixture.** A `% LINKTOKEN:` line names
  each token that must stay atomic, and a token that is absent from the PDF
  fails the run — a fixture that stops rendering its link cannot pass quietly.
- **It carries a negative control.** `cv-bibliography-urlmuskip-raised.tex`
  restores BibLaTeX's `0mu plus 3mu` and must be reported as split. It shares
  its `.bib` with the passing bibliography fixture, so the muskip is the only
  difference between an intact URL and a spread one.

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

`tests/tagging/run.sh` (`make tagging`) automates every part of that except the
screen-reader pass, which stays manual by nature. Recorded results and the
outstanding VoiceOver/NVDA checklists are in sections 7.1 and 7.2.

One check there is not an extraction check and should not be read as one.
`tests/tagging/structure-text.pl` decodes each marked-content run from the
content stream and consults no glyph coordinate at all, so what it prints is
the *logical* text of a structure element rather than an extractor's
reconstruction of the page. That distinction is the whole reason it exists:
Poppler, MuPDF, and PDFKit all rebuild words from geometry, so all three were
blind to two cells joined by nothing but positioning glue (7.6). A defect of
that shape is invisible to every other check in this document. Its per-fixture
`*.structure.txt` baselines are assertions, not records — regenerate one only
for an intended change to the tagged text, and read the diff.

### 11.9 Real portal acceptance

When a portal previews parsed fields, inspect and correct name, email, phone, job
titles, employers, date ranges, education, current location, and links. Follow the
portal's requested format. Greenhouse documentation has stated a parser input size
limit in one recruiting workflow, so keep PDFs compact and image-light; do not
treat that vendor-specific limit as universal, and re-check the current figure.

## 12. CI and release gates

Phase 1 CI runs every applicable committed suite under `tests/`, compiles both
supported examples on pushes and pull requests, installs a LuaLaTeX-capable TeX
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

Keep documentation in sync with behaviour, in the same change; `CONTRIBUTING.md`
("Update … when") and `AGENTS.md` map each kind of change to the doc it belongs
in. This guide owns one of those docs: the font, extraction, and tagging policy
that `docs/ARCHITECTURE.md` summarizes from here.

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
- do not introduce per-word `/ActualText` spans (section 4.5);
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
- present future features (named font combinations, CTAN packaging, or a
  consolidated profile interface) as if they were current.

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
  [2026-07-30 v0.6.0 ATS-conscious résumé class]

% Declare and process class keys (fontsize, margin) here via l3keys,
% before \LoadClass. Pass documented base-class options deliberately.

\LoadClass[11pt]{article}

% Shared foundation. Load order may be adjusted as implementation requires,
% but dependency direction stays one-way (shared packages never depend on classes).
\RequirePackage{careerdossier-base}        % metadata, keys, validation
\RequirePackage{careerdossier-typography}  % LuaLaTeX check, fontspec,
                                           % semantic roles
\RequirePackage{careerdossier-theme}       % monochrome tokens
\RequirePackage{careerdossier-components}  % identity block, contact line, entry primitives

\RequirePackage{hyperref}
\hypersetup{ unicode = true, pdflang = en }
% English-only; multilingual support is dropped (docs/ROADMAP.md), so pdflang
% is hard-coded rather than routed through a language-abstraction layer.

% Page geometry, margins, and the vertical rhythm belong to
% careerdossier-tokens, NOT here and not in careerdossier-base: this class
% chooses paper and options and passes them down. Build entries from the shared
% semantic primitives — not from tables, columns, or positioned boxes.
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

### LuaLaTeX and fonts

- [ ] Wrong engines fail early with a useful message.
- [ ] Default fonts are reproducible and legally distributable.
- [ ] Upright, bold, italic, and bold italic are explicit.
- [ ] No per-word `/ActualText` spans are present (section 4.5).
- [ ] Ligature and alternate-feature policy is documented.
- [ ] Font versions are recorded and all meaningful fonts are embedded.

### Extraction

- [ ] Ground-truth text round-trips through Poppler.
- [ ] Ground-truth text round-trips through a second, non-Poppler consumer
      (PDFKit on macOS), because Poppler recovers spacing that others do not.
- [ ] The output contains no `/ActualText` spans (section 4.5).
- [ ] Default and `-layout` extraction have been inspected.
- [ ] Punctuation, accents, symbols, URLs, and ligature sequences pass.
- [ ] Ordered-block assertions pass.
- [ ] Copy/paste passes in at least two independent PDF engines.
- [ ] A real portal preview has been checked when feasible.

### Accessibility and rendering

- [ ] The default `hyperref` metadata route and the separate opt-in
      `\DocumentMetadata` tagging route are documented.
- [ ] Tagged fixtures pass structure, artifact, and extraction checks, and the
      untagged path is unchanged.
- [ ] The five UA-2 fixture variants pass veraPDF, and the reports and toolchain
      record from that run were reviewed (section 7.1).
- [ ] At least one macOS and one Windows screen-reader reading-order check is
      recorded, or the release explicitly states which one is outstanding
      (section 7.2).
- [ ] No PDF/UA or WCAG claim is made beyond what a validator run and manual
      inspection actually covered, and the fixtures that were validated are named.
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

ATS parsing, PDF consumers, LaTeX's tagged-PDF implementation, `fontspec`,
LuaHBTeX, fonts, and CTAN rules all change. Treat this guide as a maintained compatibility
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
