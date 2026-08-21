# Engineering ATS-friendly career documents with LuaLaTeX

This file is the engineering contract CareerDossierTeX is built toward for text
extraction, tagging, and fonts: what a generated PDF's text layer, reading
order, Unicode mapping, and semantic structure have to do, and what has been
measured about each. It is design and reference material, not documentation of
shipped behavior — the PDF manual and the compiled examples describe what is
currently supported. Material tagged **(planned — vX.Y.Z)** is future work and
must not be implemented or documented as if it were current. Where this guide
and the rest of `docs/` disagree, the repository documentation is authoritative
and this file is the one to correct.

## What "ATS-friendly" means, and the layout rules that follow

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
  available;
- the PDF remains easy for a human to skim; and
- the employer accepts a PDF at all — a sound PDF cannot satisfy a portal that
  requires DOCX, so follow the requested file type whatever this list says.

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

### Default to one semantic stream

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

### Do not use these for essential content

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

### Safe visual hierarchy

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

### Dates and right alignment

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
show it. `tests/extraction/` pins the order for both classes; see
[`TESTING.md`](TESTING.md#reading-order-assertions) "Reading-order assertions".

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
amount of geometry fixes. See ["Structure tree by profile"](#structure-tree-by-profile).

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
the manual for the option and the separator token.

On the tagged path the two values are equivalent. The separator is emitted as a
layout artifact, as the contact line's `|` is, so the structure element text
reads `Engineer 2024–2026` under both — the same string, with the word boundary
coming from a real interword space under `inline` and from `\pdffakespace`
under `column` (see ["Structure tree by profile"](#structure-tree-by-profile)).
`tests/tagging/resume-entrymeta-inline` pins that and
validates as PDF/UA-2.

### Headers, footers, and page numbers

**The rule applied:** page furniture answers whether a page could be separated
from its fellows, so `medium=print` emits a name-derived running header from
page two and a `Page N of M` folio, `medium=screen` emits neither because an
electronic PDF cannot lose a page, and a one-page document gets none under
either.

For a one- or two-page résumé, prefer no running header. For a long CV
**(supported in v0.2.0)**, a simple name-derived header and page number can help
humans, but they must not be
the only appearance of the name or other essential data. Use standard page-style
mechanisms so tagging code can treat running material as artifacts, and inspect
the resulting structure.

Greenhouse explicitly identifies complex headers and footers, and contact data
placed within them, as parsing risks. Keep the canonical name and contact block in
the first page's body.

### Page geometry and density

**The rule applied:** margins are two presets rather than a free dimension —
`margin=normal` is one inch and `margin=narrow` is half an inch, with nothing
between them — and the résumé defaults to `narrow` at 11 pt while the CV,
letter, and statement default to `normal` at 12 pt.

Good defaults for most career documents are:

- 0.5-1 inch margins, with approximately 0.65-0.8 inch as a useful default;
- 10-12 pt body text, adjusted for the selected font's real x-height;
- moderate line length and visible separation between entries;
- no forced one-page compression at the cost of legibility; and
- no negative `\vspace` as a routine layout tool.

Use named lengths for every public spacing control rather than scattered
numeric dimensions, and see
[`ARCHITECTURE.md`](ARCHITECTURE.md#file-responsibilities) for which module owns
which of them.

## Typography and font engineering under LuaLaTeX

Engine detection, `fontspec` loading, portable font selection, and semantic text
roles are owned by `careerdossier-typography.sty`. The examples below illustrate
the policy; in the implementation they live in that module.

### Font choice is a build dependency

With LuaLaTeX, `fontspec` makes OpenType fonts easy to use through `luaotfload`,
but the output depends on:

- the exact font files and versions;
- the selected upright, bold, italic, and bold-italic faces;
- the renderer and script/language settings;
- enabled OpenType substitutions;
- LuaHBTeX and `luaotfload` versions; and
- how a PDF consumer interprets `ToUnicode` and `/ActualText`.

Do not describe a font as ATS-safe based on its family name alone.

### Package default versus user-selected fonts

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

### Prefer literal Unicode source

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

### Ligatures and alternate glyphs

The visible glyph and the extracted text are different layers. A ligature can
display as one glyph but should extract as its original character sequence. An
alternate punctuation glyph can look correct yet extract to a Private Use Area
code point.

The Inter 4.1 regression demonstrates the failure clearly: under XeLaTeX,
contextual (`calt`) and tabular-figure (`tnum`) alternates for `(`, `)`, and `+`
could extract as PUA characters, while Inter 3.19 extracted correctly. Enabling
`\XeTeXgenerateactualtext=1` fixed Poppler extraction but not every PDF consumer,
and introduced a worse defect of its own — see "`/ActualText`, `ToUnicode`, and
their limits". The engine has since changed, but the underlying lesson has not:
a font version and feature
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

### `/ActualText`, `ToUnicode`, and their limits

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

For this package the loss is small in any case: the ligature policy in
"Ligatures and alternate glyphs" already disables every optional ligature and
alternate, which is the main scenario
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
the text layer only; see "Tagged PDF and accessibility under current LaTeX".

Never search a decompressed PDF for the word `ToUnicode` and call the document
validated. Use `pdffonts` for a quick inventory, inspect suspicious mappings when
needed, and compare extracted output with known ground truth.

### A conservative font setup

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
% spaces. See "`/ActualText`, `ToUnicode`, and their limits".
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

### Font acceptance criteria

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

## Semantic structure for each career-document type

Why each document type is shaped the way it is, in extraction terms. What a
class actually emits, and in what order, is documented in the manual — this
section is the reasoning the manual's behavior was derived from, and where the
two appear to disagree the manual is authoritative, per the scope banner above.

### Shared rules

An extractor receives a single stream of text with no layout, so every property
below is one a document loses if it is expressed in geometry instead of in
structure. All document types should therefore provide:

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

### Résumé **(Phase 1)**

The résumé is the strictest profile, because it is the document most likely to
be parsed by machine before a person sees it. Each constraint below buys one
extraction property, and each is a choice the author makes in content rather
than something a class can enforce:

- one column;
- one or two pages when appropriate, without forced compression;
- conventional headings such as `Summary`, `Experience`, `Education`, `Skills`,
  `Projects`, and `Certifications`;
- reverse-chronological entries where dates are used;
- complete job titles rather than unexplained abbreviations;
- skills as comma-separated or ordinary grouped text, not a grid; and
- achievements in real `CDossierItemize` lists with a simple text bullet.

### Industry CV **(planned — later phase)**

Use the same extraction constraints as the résumé, with more sections and pages.
Long lists of presentations, publications, projects, or certifications should
remain ordinary vertical lists. A compact table may look attractive, but a
sequential list is safer and usually easier to maintain.

### Academic CV **(supported in v0.2.0)**

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

### Cover letter **(Phase 1)**

The applicant's address, recipient, date, and subject must reach the text layer
in the body, not only in a decorative letterhead or page header: furniture is
where an extractor is least likely to look, and page headers in particular are
often dropped or hoisted out of order. The reading order that follows from this
is a contract of `\MakeCDossierLetterhead` and `\MakeCDossierClosing`, and the
manual states what those two emit and in what order — this guide does not
restate it.

Two consequences the classes cannot enforce, because they are the author's:
a scanned signature may be decorative, but the typed name must remain present
as text; and a signature image must not interrupt reading order or replace the
name.

### Statements — default interest plus six other types **(v0.5.0)**

One class defaults to a statement of interest and also covers research,
teaching, teaching-philosophy, diversity, artist, and statement-of-purpose
documents. These are closer to short articles:

- use ordinary paragraphs and semantic headings;
- avoid magazine-style columns;
- keep citations and footnotes sparse and extractable;
- use figures only when essential, with text alternatives when tagging is enabled;
  and
- test page transitions and paragraph spacing in extracted text.

Keeping the title, applicant name, and required identity fields in the page-one
body rather than only in running furniture is the same argument as the cover
letter's above, and is likewise a contract of the class:
`\MakeCDossierStatementHeader` emits the present identity items in a fixed
logical order, which the manual states.

### Reference list **(planned — later phase)**

Emit each reference as a sequential block: name, title, organization, relationship
if appropriate, email, phone, and address. Do not place references in two or three
columns. Labels such as `Email:` and `Phone:` improve plain-text clarity.

## Hyperlinks, icons, symbols, bullets, and punctuation

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
`careerdossier-biblatex.sty` sets it rigid for that reason ("Academic CV" — it
capped it at `0mu plus 1mu` until issue #312 found a real URL long enough to
defeat the cap). Everywhere else `\Urlmuskip` is url.sty's `0mu`, and the contact line is
additionally immune because each item is measured in its own `\hbox` rather
than justified.

A link in body text is the third case, and it fails the other way round. It sits
in a justified paragraph with nothing measuring it, so a long address written as
plain text is *hyphenated*: the pasted URL then carries an inserted hyphen that
was never part of it, and no word-boundary check sees anything wrong, because
the hyphen is a legitimate character in a legitimate word.
`\CDossierLink` (see the manual) is the supported form (issue #308). It
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
either medium. That is a legibility decision (see the manual), and under a
reboxing underline it would also have been a correctness one.

Second, plain extracted text cannot check this: a legitimate line wrap and a
split token both read as whitespace. The decision needs word bounding boxes —
pieces on different visual lines are a wrap, pieces sharing one line are the
defect. `make links` is the assertion
([`TESTING.md`](TESTING.md#link-copy-paste-integrity-suite)), and it carries a
negative control
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

## Tagged PDF and accessibility under current LaTeX

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
well as the tagged one. See the manual for the derived fields and how to
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
  five named fixtures and recorded in "Recorded validation results", the manual
  screen-reader half is tracked in "Screen-reader reading-order checks" and
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

### Recorded validation results **(v0.4.0 plus the `v0.5.0` statement fixture)**

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

### Screen-reader reading-order checks

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

### Tagged BibLaTeX: feasibility and limitations

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
`/H2` alongside every other résumé/CV section heading — see ["Heading hierarchy"](#heading-hierarchy-issue-267)).
The
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

### Heading hierarchy (issue #267)

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
the same order — that is what the extraction and word-geometry gates in
["Recorded validation results"](#recorded-validation-results-v040-plus-the-v050-statement-fixture) already cover, and why this change touches none of them. The heading-jump
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
in ["Section divisions"](#section-divisions-issue-268) below.

### Section divisions (issue #268)

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

### Structure tree by profile

The table and diagram above show the heading skeleton only. The **complete**
tagged structure of every named fixture — every heading, link, list item, and
paragraph, in document order, with its extracted text — is committed as
`tests/tagging/*.structure.txt`, one per fixture, re-decoded and diffed on every
`make tagging` run by `tests/tagging/structure-text.pl`. Those ten files are the
record; this section reproduces one and states what they established.

Each line is one marked-content run — `<page>`, `<MCID>`, `<structure tag>`,
`<decoded text>` — decoded byte-for-byte from that fixture's `/StructTreeRoot`
and content streams (`/K` → `/MCR` → `/MCID` → the run's own `Tj`/`TJ` glyph
codes, resolved through each font's embedded `/ToUnicode` CMap), never inferred
from the source `.tex` and never from a glyph coordinate. The text column is
therefore exactly what a consumer reading structure rather than glyph geometry
receives. Three things are absent, each deliberately: a link annotation's
`/OBJR`, so a `/Link` line is the link's *text*, not an annotation announced on
its own; running headers, folios, rules, and separator characters, which are
`/Artifact`s, so their absence is 7's "mark decorative content as artifact"
rule working rather than an omission; and structure-only nodes carrying no
marked content (`/Document`, `/text-unit`, `/Sect`, `/itemize`, `/item`,
`/itembody`), whose nesting ["Heading hierarchy"](#heading-hierarchy-issue-267) and ["Section divisions"](#section-divisions-issue-268)
above describe.

`tests/tagging/resume.structure.txt`, as committed, is the résumé in full:

```text
1	0	section	Tagged Industry Resume
1	1	text	Accessibility Engineer
1	2	Link	resume@example.test
1	3	text	+1 555 0100
1	4	Link	example.test/resume
1	5	subsection	Experience
1	6	text	
1	7	text	
1	8	text	Engineer 2024–2026
1	9	text	Example Labs Toronto
1	10	itemlabel	•
1	11	text	First resume achievement in source order.
1	12	itemlabel	•
1	13	text	Second resume achievement with a meaningful 
1	14	Link	work link
1	15	text	.
2	0	subsection	Additional Experience
2	1	text	
2	2	text	
2	3	text	Senior Engineer 2022–2024
2	4	text	Example Services Ottawa
2	5	itemlabel	•
2	6	text	Second-page resume content after the shared page furniture.
```

The other nine pin the rest of the matrix: the academic CV, the résumé's shape
from the same `\MakeCDossierHeader` and `\CDossierSection`, with a blank
`location` that `\tl_if_blank:nF` omits rather than leaving a stray separator
(rule 5); the two letters, flat prose carrying no section-heading component and
so no heading role below the identity; the statement, the profile with the most
heading roles; and five option and defect fixtures.

**Two things are worth reading closely, not just skimming past.**

First, a handful of lines have an **empty text column** — MCIDs 6 and 7 on
page 1 above, and 1 and 2 on page 2. These are real, structurally-present
elements carrying zero glyphs: they sit where the shared header stack's closing
`\addvspace` (and, in the résumé and CV, the section rule's own paragraph) ends
one automatically-tagged paragraph and starts the next. A screen reader passes
over an empty element silently, so they are inert — but they are why a tree has
more `/text` elements than a count of visible lines predicts, and what issue
#267's own motivating résumé example undercounted.

Second, and more substantively: **a `/text` leaf that contains more than one
run used to concatenate those runs with no separating character at all.** This
is different from an ordinary sentence that happens to contain a link — MCIDs
13 to 15 on page 1 above, where the halves are already separate runs and the
embedded `/Link` element supplies the reading-order gap. That case is fine. The
genuine case was a two-column or two-line layout built with `\hfill` or `\\`
alone: the entry heading's title/dates row, its organization/location row, and
the letter's stacked recipient lines all land in **one** marked-content run,
and nothing — neither a space character nor a second structure element —
separated the two halves in the content stream. A structure-aware consumer
received the literal `Engineer2024–2026`, and, for a full recipient address,
`Casey ReaderHead of EngineeringExample Company123 Discovery AvenueVancouver,
BC V6T 1Z4`. Same root cause as the retired `/ActualText` history in
["`/ActualText`, `ToUnicode`, and their limits"](#actualtext-tounicode-and-their-limits) —
positioning glyphs by absolute coordinates rather than by a real interword
space — in a location that history did not cover.

Issue #302 fixed this, and the committed baselines are the fixed output. The
remedy is tagpdf's own `\pdffakespace`, which emits a real U+0020 into the
content stream at zero rendered width — the right instrument rather than a
workaround, because ordinary prose's interword spaces already arrive by exactly
this route. tagpdf inserts a real space glyph for any glue of positive natural
width next to a glyph, and `\hfill`'s **zero** natural width, not anything
about two-column layout, is the whole reason these joins were skipped. Zero
rendered width also means the fill still absorbs the line, so no glyph moves:
the untagged example PDFs are byte-identical across the fix apart from their
timestamps and `/ID`, and no Poppler, MuPDF, or PDFKit baseline in
["Recorded validation results"](#recorded-validation-results-v040-plus-the-v050-statement-fixture) changed.

Two details are worth keeping. In the letter the separator hangs off `\\` itself
for the length of the recipient block, not off the four field call sites: a
recipient address carries the user's own `\\` **inside a single field value**, so
a call-site fix would have left that break glued. And `\pdffakespace` expands to
a zero-width *skip*, discardable on either side of a forced line break — placed
bare around the `\\` it is dropped again and nothing is emitted. It must be boxed.

One case looks the same and is not: the statement's context line
(`statement.structure.txt`, page 1, MCIDs 4 and 5) is two adjacent leaves,
because the `|` between them is its own `/Artifact` and interrupts the run
where the cases above never opened a second one. #302 leaves it untouched, and
whether an element boundary reads better than a glued run is the question in
["Screen-reader reading-order checks"](#screen-reader-reading-order-checks).

**Still not verified against a live screen reader.** Everything above is
established at the byte level. Whether the glued form actually misread in
VoiceOver or NVDA — and so whether this was a real defect for a user rather
than only a structurally wrong one — was never confirmed, and the fix does not
confirm it retrospectively. The manual pass in ["Screen-reader reading-order checks"](#screen-reader-reading-order-checks)
is what would.

**Why nothing caught it.** Every extractor in the matrix rebuilds words from
glyph geometry, so none could see a missing character; `docs/TESTING.md`
§ "Tagged-PDF suite" states that, and what `make tagging` does instead.

## Compilation policy

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

## Documentation requirements

Keep documentation in sync with behaviour, in the same change; `CONTRIBUTING.md`
("Documentation requirements") maps each kind of change to the doc it belongs
in. This guide owns one of those docs: the font, extraction, and tagging policy
that `docs/ARCHITECTURE.md` summarizes from here.

Keep examples fictional and realistic. Obvious placeholders such as `First Last` or
`Company 1` can themselves be skipped by parsers, as Greenhouse's documentation
notes. Use clearly fictional but plausible names and organizations.

## What to do and what not to do while writing the package

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
- do not introduce per-word `/ActualText` spans ("`/ActualText`,
  `ToUnicode`, and their limits");
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

## Minimal reference template **(Phase 1)**

This template is compiled. `tests/smoke/ats-user-template-doc.tex` is the text
below verbatim, and `make smoke` diffs the two before compiling either, so the
template cannot go stale against the classes without failing a suite (#450).
The manual's "Complete examples" chapter and `examples/` carry the same shape at
greater length; this one exists here because the surrounding sections argue from
it.

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
- [The Not So Short Introduction to LaTeX2e (`lshort`)](https://ctan.org/pkg/lshort-english)
- *The LaTeX Companion*, 3rd ed. (Mittelbach & Fischer, Addison-Wesley, 2023),
  chapter 17, for documented sources, `docstrip`, `l3build`, regression testing,
  and CTAN release work. Book; no free URL.
- Peter Flynn, *Rolling your own Document Class* (2007) and Jim Hefferon,
  *Minutes in Less Than Hours*, for concepts only — their implementation
  techniques are dated, so check current kernel guidance before copying any
  internals.

Give the most weight to current, primary documentation from the LaTeX Project
and package maintainers; treat forum posts and commercial articles as
supporting evidence, weighted toward recency. Where a local note and current
documentation differ, follow the current primary source and re-test.

> **Verify at release.** Vendor guidance and limits change. Re-check the
> Greenhouse, Lever, and MIT pages above, and any figure attributed to a vendor
> (for example the Greenhouse parser size limit in
> [`TESTING.md`](TESTING.md#real-portal-acceptance) "Real portal acceptance"),
> each release cycle.

> **Maintainer note.** Some entries above point at canonical index or package
> pages rather than deep links, to avoid dead links as documents are revised.
> Confirm and, where useful, pin exact URLs when you next revise this file.

---

*Part of CareerDossierTeX. Licensed under LPPL 1.3c. Maintainer: Amir Sadeghi.
This document is design and reference material; the PDF manual and the compiled
examples remain the authority on shipped behavior.*
