# CareerDossierTeX Public API

For people writing documents with the toolkit: every public class, option,
command, key, and design token, with its accepted values and default. It
describes the released interface, not the internals —
[`ARCHITECTURE.md`](ARCHITECTURE.md) covers which module owns what and why.

## Status

This document records the released public interface:

```text
Released: v0.7.0 — Page Furniture, Output Medium, and Spacing Ownership
```

Sections that are not explicitly marked as planned describe released behavior.
Before `v1.0.0` the interface may still change between minor versions; such
changes are recorded in [`../CHANGELOG.md`](../CHANGELOG.md) and
[`MIGRATION.md`](MIGRATION.md).

`v0.7.0` changed the interface in four ways:

- `medium=print|screen` is accepted by all four document classes. `print` is
  the default and reproduces the previous behaviour exactly; `screen` emits no
  running header and no folio on any page.
- `\CDossierHeaderBegin`, `\CDossierHeaderLine`, and `\CDossierHeaderEnd`
  compose a centered header stack line by line. `\MakeCDossierHeader` and
  `\MakeCDossierStatementHeader` remain what a document uses.
- **The vertical-spacing design tokens are reworked.** Every one is renamed onto
  `\CDossier<Family><Scope><Position>Skip`; three that could never render are
  retired; two are added for boundaries no token described; and three are split
  — the list edge into an above and a below token, and the header below-gap and
  the prose paragraph gap into one token per document family. The vocabulary
  goes from twenty-two tokens to twenty-five. A document needs a source edit
  only if it reads or sets one of these tokens by name.
- **Every choice-valued option now names its accepted values** when it rejects
  one. No option name, accepted value, or default changed — only the wording of
  an error that already stopped the build.

The calibrated ratios behind those tokens were also retuned, so **every document
reflows**, though no supported combination changes its page count. See
[`MIGRATION.md`](MIGRATION.md#070---2026-08-04).

`v0.6.0` before it removed `density=compact|standard` from the résumé and CV
classes with no replacement, made `fontsize` and `margin` uniform across all
four classes with per-class defaults, and reduced `family=academic` to a
label- and metadata-only distinction. A document coming from `v0.5.x` or
earlier needs that migration too.

The API is intentionally small. Internal helper commands are not public merely because they are technically accessible.

## Supported configuration

| Setting | Support |
|---|---|
| Engine | LuaLaTeX only |
| Language | English |
| Paper | US Letter (default) and opt-in A4 |
| Body size | `fontsize=10pt\|11pt\|12pt`, per-class default |
| Margins | `margin=normal` (1 in) or `margin=narrow` (0.5 in), per-class default |
| Body font | Serif (default) and opt-in sans |
| Output medium | `medium=print` (default) or `medium=screen` |
| Entry-metadata de-emphasis | `muted=italic` (default), `muted=gray`, or `muted=both` |
| Theme | Monochrome |
| Tagged structure | Opt-in, off by default |
| Résumé class | `careerdossier-resume` |
| CV class | `careerdossier-cv` |
| Letter class | `careerdossier-letter`, industry and academic families |
| Statement class | Default interest type plus six other explicit types |
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

or:

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

Tagged output is a tested preview for the five fixture profiles (industry
résumé, industry letter, academic CV, academic letter, and statement). It is not
a PDF/UA, WCAG, ATS, or general accessibility conformance claim. The macOS
VoiceOver pass covers four of the five — the statement fixture and
Windows/NVDA remain screen-reader-unverified. See
[`../README.md`](../README.md) and
[`ATS-EXTRACTION.md`](ATS-EXTRACTION.md) for the scope of what has
actually been verified.

## Résumé class

### Class declaration

```latex
\documentclass[
  fontsize=11pt,
  margin=narrow,
  paper=letter,
  bodyfont=serif,
  medium=print,
  muted=italic
]{careerdossier-resume}
```

### Options

Every option below takes a fixed set of values. An unsupported value stops the
build with a class error that names the option, the value supplied, the owning
class, and the accepted values — so the accepted set never has to be looked up
here to act on the error.

Three packages also accept options when loaded directly with `\usepackage`, and
report an unsupported value the same way:

| Package | Options | Package default |
|---|---|---|
| `careerdossier-tokens` | `fontsize`, `margin` | `fontsize=12pt`, `margin=normal` |
| `careerdossier-typography` | `bodyfont` | `bodyfont=serif` |
| `careerdossier-components` | `medium`, `muted` | `medium=print`, `muted=italic` |

**A package default is not a class default.** Loading `careerdossier-tokens`
directly gives `12pt`/`normal`, while `\documentclass{careerdossier-resume}`
resolves to `11pt`/`narrow` — the class passes its own values down with
`\PassOptionsToPackage` before `\LoadClass`. Set the option explicitly when
loading a package directly; do not assume it inherits a class's choice.

#### `fontsize`

Accepted values:

```text
10pt
11pt
12pt
```

Default:

```text
11pt
```

Any unsupported value produces a class error naming the accepted values.

`fontsize` selects one whole-point type scale for the entire document. It is
the only input to type size; there is no per-element size option. The sizes it
resolves to, in points, are:

| Element | `10pt` | `11pt` | `12pt` |
|---|---:|---:|---:|
| Name | 19 | 21 | 23 |
| Statement title | 15 | 16 | 18 |
| Headline, subtitle | 12 | 13 | 14 |
| Section heading | 11 | 12 | 13 |
| Entry title, body text, bullets, dates | 10 | 11 | 12 |
| Contact line | 9 | 10 | 11 |
| Running header, folio | 8 | 9 | 10 |

Structural vertical spacing scales with the same option, as a fixed fraction of
the body baseline. The values use a one-sixteenth-line vocabulary, with zero
reserved for deliberately collapsed spacing. The ratios behind both tables, and
the reasoning behind the per-class defaults, are recorded in
[`ARCHITECTURE.md`](ARCHITECTURE.md#careerdossier-tokenssty).

`density=compact|standard` was removed in `v0.6.0` and has no replacement; see
[`MIGRATION.md`](MIGRATION.md).

#### `margin`

Every CareerDossierTeX document class accepts:

```text
normal
narrow
```

`normal` means one-inch margins and `narrow` means half-inch margins. The
résumé defaults to `narrow`; the CV, letter, and statement classes default to
`normal`. Unsupported values produce a class error naming the accepted values.

`margin` and `fontsize` together decide line length. Measured in TeX Gyre
Termes on US Letter, full lines of running prose hold roughly:

| `fontsize` | `margin` | Characters per line |
|---|---|---|
| `10pt` | `normal` | 110–120 |
| `10pt` | `narrow` | 130–140 |
| `11pt` | `normal` | 102–113 |
| `11pt` | `narrow` | 118–127 |
| `12pt` | `normal` | 93–101 |
| `12pt` | `narrow` | 108–117 |

The prose classes default to `12pt` at `margin=normal` because that is the only
combination whose measure lands near the conventional 45–90 character guidance
at a one-inch margin.

**Known limitation.** The résumé's default `11pt` with `margin=narrow`
produces the longest measure in the project — roughly 118–127 characters per
line. It is chosen for one-page capacity and is fine for entry lines and short
bullets, which are `\hfill`-split and never reach the full measure. It is
visibly long in a full-width Summary paragraph. If a résumé opens with a dense
prose summary, prefer `margin=normal`, `fontsize=12pt`, or a shorter summary.

This is the canonical statement of that limitation; the reasoning behind
accepting it is recorded in
[`ARCHITECTURE.md`](ARCHITECTURE.md#measure-and-why-the-prose-classes-default-to-12-pt).

The classes load `geometry` through `careerdossier-tokens`. An advanced user
may call `\geometry{...}` after `\documentclass` to replace the preset with
custom geometry. Do not load `geometry` again with package options: doing so
can produce an option clash. A raw `\geometry` override bypasses the two tested
CareerDossierTeX presets, so its pagination and visual result remain the
author's responsibility.

#### `paper`

Every CareerDossierTeX document class accepts:

```text
letter
a4
```

The default is `letter`. `a4` selects an ISO A4 media box while retaining the
selected `normal` or `narrow` margin preset, font size, spacing, and
page-furniture design. Because A4 is slightly narrower and taller than US
Letter, line and page breaks may change. Unsupported values produce a class
error naming the accepted values.

#### `bodyfont`

Every CareerDossierTeX document class accepts:

```text
serif
sans
```

The default is `serif`, preserving the existing TeX Gyre Termes body and TeX
Gyre Heros headings. `sans` selects TeX Gyre Heros for the ordinary document
body while headings remain TeX Gyre Heros. The option does not change font
size, semantic typography roles, spacing, geometry, or page furniture.
Unsupported values produce a class error naming the accepted values. Arbitrary
font names and per-role font selection are not supported.

#### `medium`

Every CareerDossierTeX document class accepts:

```text
print
screen
```

`medium` is new after `v0.6.0`.

The default is `print`, which is the page-furniture policy described below: a
running header from page two and a `Page N of M` folio throughout, both
suppressed on a one-page document. `screen` emits no running header and no
folio on any page.

The same dossier is read in two contexts with different needs. On screen the
PDF viewer already shows page position, so the folio is redundant chrome; on
paper a loose page has no such affordance, and the folio is what keeps a
multi-page dossier in order after it is put down.

The option changes only whether furniture is emitted. Page geometry is
unchanged, so the text block sits in exactly the same place under both values
and switching `medium` cannot reflow a document. Unsupported values produce a
class error naming the accepted values.

#### `muted`

Every CareerDossierTeX document class accepts:

```text
italic
gray
both
```

`muted` is new after `v0.7.0`. Note the spelling: `gray`, not `grey`.

`muted` decides how de-emphasised runs are rendered — an entry's dates and
location in the résumé and CV, and the statement's application-context line.
The default is `italic`, which reproduces the previous behaviour exactly:
italic in the body family, in the ordinary black text token. `gray` renders the
same runs upright in the muted token instead, and `both` applies the italic and
the muted token together.

The muted token is `gray 0.30`, which measures 8.52:1 against white under the
WCAG 2.1 relative-luminance formula — well above the 4.5:1 normal-text floor.

Which value to choose is a genuine trade-off, which is why it is an option:

- italic at small sizes is harder to read for low-vision and dyslexic readers
  than a high-contrast gray, and this metadata is scanned rather than read;
- shape, unlike a gray level, survives a fax, a photocopy, and a 1-bit print.

Under every value the de-emphasis is reinforced by position and content — the
dates sit in their own flush-right column and read as a date range — so colour
is never the only carrier of meaning. All three values are visual only: no
extractor sees a difference, and the reading order is identical under each.

Unsupported values produce a class error naming the accepted values.

### Fixed settings

The following remain fixed and are not accepted as user options:

```text
language=english
theme=monochrome
```

It is better to reject or omit an unsupported option than silently ignore it.

### Page furniture

All four document classes use the same page-furniture policy. Under the default
`medium=print`:

- a one-page document has no running header and no folio;
- page one of a multi-page document has only a centered `Page N of M` folio;
- pages two and later add a centered `<name> -- <document label>` running
  header above the body and retain the centered folio; and
- the résumé label is `Résumé`, the CV label is `Curriculum Vitae`, both
  letter families use `Cover Letter`, and a statement uses its independently
  configurable short running title.

Under `medium=screen` neither the running header nor the folio is emitted, on
any page and at any page count.

Furniture uses the sans-serif furniture step of the calibrated type scale and
the monochrome text token. It remains print-safe and is marked as a layout
artifact when tagged PDF is active. Which furniture is emitted is the only
user-configurable part of the policy; its typography, wording, and placement
are not.

The header and the folio sit in the vertical centre of the top and bottom
margins respectively, at every `fontsize` × `margin` combination and on both
paper sizes. Their distance from the paper edge therefore follows the selected
`margin` preset: about 30.6 pt at `margin=normal` and 12.6 pt at
`margin=narrow` at the default 11 pt. This affects only where the furniture
sits inside the margin; the text block is unchanged.

Single-page suppression and the `of M` total use the LaTeX kernel's last
absolute page recorded in the auxiliary file. A first build from a clean tree
therefore shows a provisional folio; the next run suppresses it when the
document has only one page. `latexmk` and the repository build commands perform
the required rerun.

## Letter class

### Class declaration

```latex
\documentclass[
  family=industry,
  fontsize=12pt,
  margin=normal,
  paper=letter,
  bodyfont=serif,
  medium=print,
  muted=italic
]{careerdossier-letter}
```

`family` accepts `industry` and `academic`; the default is `industry`. `paper`
uses the shared `letter|a4` contract above and defaults to `letter`. `bodyfont`
uses the shared `serif|sans` contract above and defaults to `serif`. `medium`
uses the shared `print|screen` contract above and defaults to `print`. `muted`
uses the shared `italic|gray|both` contract above and defaults to `italic`.
`fontsize` and `margin` use the shared contracts above and default to `12pt`
and `normal`.

`family` is label- and metadata-only: it selects the PDF document type while
both values use the same geometry, calibrated type scale, prose rhythm,
letterhead structure, and shared `Cover Letter` continuation label. Switching
between `industry` and `academic` therefore does not select a denser or roomier
layout.

The following settings remain fixed:

```text
language=english
theme=monochrome
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
| `affiliation` | Conditional | `v0.5.0` | Current institution, organization, studio, or independent-practice description |

Whitespace-only values should be treated as missing.

`name` is the only key every class requires. A class may require a further key
for a particular document, and three do — the statement class requires `email`
for every statement, `affiliation` for `type=research`, and `website` for
`type=artist`. "Conditional" in the table above means exactly that: the key is
optional to the profile and required by some documents that use it. See
"Required profile fields and displayed contacts" for the statement rules.

### Contact-field labels (`contact-labels`)

```latex
\CDossierSetup{ contact-labels = true }   % default: false
```

`contact-labels` is an option key, not a profile field: it holds no value to
print and cannot be read back with `\CDossierPrintField`. Introduced in
`v0.5.0`.

When enabled, the contact line prefixes a short identifying label to the
fields whose nature the value itself does not convey:

| Field | Rendered as |
|---|---|
| `email` | `Email: ada@example.com` |
| `phone` | `Phone: +1 555 0100` |
| `website` | `Website: example.test/resume` |

The remaining fields stay unlabelled by design: `linkedin`, `github`, and
`scholar` values begin with their service's domain, `orcid` always carries its
own `ORCID:` label, and a `location` value is a place name. Labels are fixed
English strings; the project is English-only.

**Accessibility rationale.** In the default rendering, a screen reader
announces the email and the website as links, so their nature is conveyed —
but the phone number is announced as bare digits with nothing indicating what
it is. Sighted readers infer all three from format and position; that
inference is exactly what a screen-reader user does not get. A visible text
label is the one mechanism that works in every consumer — screen readers,
plain `pdftotext` extraction, and ATS parsers — including the default untagged
output, which is why it is the primary fix rather than a tag-level attribute.

Behavioral guarantees:

- The default rendering is unchanged; the feature is strictly opt-in.
- The key applies to every class's contact line, including document-specific
  subsets such as the statement classes'.
- An absent field leaves no orphan label and no stray separator.
- Labels are content, not layout artifacts: they reach the structure tree and
  the extracted text. Separators remain artifacts.
- `contact-labels` alone means `true`; the value must be a boolean.

The labelled and unlabelled renderings each have a committed extraction
baseline (`tests/extraction/resume-contact-labels.tex` and
`tests/extraction/resume-contact-optional.tex`). The labels survive Poppler
and PDFKit plain-text extraction with clean separators.

### Contact-line wrapping

Contact fields form a centered block whose rows are packed greedily in the
fixed field order. Complete fields are the only permitted contact-line units:
email addresses, phone numbers, locations, websites, LinkedIn, GitHub, Scholar,
and ORCID items remain intact on one visual line. A ` | ` separator is inserted
only after two adjacent items are known to fit on the same row, so no visual
line begins or ends with one.

The component does not truncate values or reduce the selected font size. Before
packing, each complete item is measured against the available contact-line
width. An item that cannot fit on an otherwise empty line raises an error
naming the field; shorten its displayed value, select `margin=narrow`, or choose
a smaller supported `fontsize`. Field order, link targets, extraction order,
and missing-field handling are unchanged; separators remain layout artifacts
in tagged output.

**VoiceOver verification (2026-07-23).** The maintainer ran VoiceOver in
Preview (PDFKit) over all four tagged/untagged × labelled/unlabelled
combinations of a fixture matching this section's example. Both unlabelled
combinations reproduce the original gap exactly: the phone number is
announced as bare digits with nothing identifying it. Both labelled
combinations announce "Phone" immediately before the digits, and "Email" and
"Website" are likewise identified; confirmed independently in tagged and
untagged output. Separator behavior is unaffected: silent in tagged output
(artifact-marked), spoken as "vertical line" in untagged output. No broader
accessibility claim beyond this check is made.

**Decisions recorded from this review:**

- **`tel:` linking the phone number** (one of the mechanisms weighed in #95)
  remains intentionally unshipped. The visible label already conveys the
  field's nature in every consumer this project verifies against, so a
  `tel:` link would be redundant for that purpose, and its behavior under ATS
  parsers was never verified. Not planned unless a new use case reopens it.
- **Tagged output with labels enabled** was verified only ad hoc during
  review (VoiceOver above, plus a one-off `verapdf -f ua2` pass reporting
  `isCompliant="true"`) — it has no committed fixture with a saved baseline.
  Tracked as non-blocking test debt in #125.

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
needs to be called; the derived values are applied automatically at
`\begin{document}`.

| PDF field | Derived from | Résumé value | Letter value |
|---|---|---|---|
| `/Title` | `name` | `Résumé – <name>` | `Cover Letter – <name>` |
| `/Author` | `name` | `<name>` | `<name>` |
| `/Lang` | fixed | `en` | `en` |

The document type is part of the title so that a résumé and a cover letter built
from one profile are distinguishable in a viewer's tab bar, in document
properties, and in a file manager.

When `name` is absent, `/Title` and `/Author` are left unset.
`\MakeCDossierHeader` and `\MakeCDossierLetterhead` already error on a missing
`name`; metadata does not add a second diagnostic.

`/Lang` is `en` because `v0.1.0` is English-only. There is no language key.

### `/DisplayDocTitle`

A `/Title` in the file is not what a viewer puts in its window title, tab bar, or
recent-documents list. A viewer uses the filename unless the PDF's
`ViewerPreferences` ask otherwise, so the classes also request
`/DisplayDocTitle true`. Without it the derived title is present and unused —
the case PDF/UA-2 clause 8.11.2 and WCAG 2.1 AA 2.4.2 (Page Titled) are about.

It is requested on both the default and the tagged build path, and it changes
nothing about rendering, extracted text, or the structure tree. New in `v0.8.0`.

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

The language has a second route, and it wins too:

```latex
\DocumentMetadata{ lang = de, tagging = on }
\documentclass{careerdossier-resume}
```

`\DocumentMetadata` records the language for the LaTeX kernel, which writes
`/Lang` itself, and the derived `en` stands aside. `\DocumentMetadata` always
settles on a language — it defaults to `en` when you give no `lang` key — so on
that path the kernel owns `/Lang` outright.

Declaring a language does not make the document that language. CareerDossierTeX
is English-only (see [`ROADMAP.md`](ROADMAP.md)); `lang` sets the declaration a
screen reader reads, not hyphenation, fonts, or any fixed string.

`pdfdisplaydoctitle` is the one setting that works by ordering rather than by
detection, because `hyperref` gives a boolean no state that distinguishes "not
set" from "set to `false`". The classes request it while `hyperref` is still
loading, so any value in your preamble is later and wins:

```latex
\documentclass{careerdossier-resume}

\hypersetup{ pdfdisplaydoctitle = false }   % show the filename instead
```

The one place that does not reach is a value passed as a package option — with
`\PassOptionsToPackage{...}{hyperref}` before `\documentclass` — which
`hyperref` processes before the classes can be asked anything. Set it with
`\hypersetup` in the preamble instead.

Other `hyperref` metadata (`pdfsubject`, `pdfkeywords`, …) is untouched; set it
with `\hypersetup` as usual.

## Public commands

### `\CDossierHeaderBegin`, `\CDossierHeaderLine`, `\CDossierHeaderEnd`

```latex
\CDossierHeaderBegin
\CDossierHeaderLine{<content>}
\CDossierHeaderLine{<content>}
\CDossierHeaderEnd
```

Composes a centered header stack line by line. New in `v0.7.0`.

`\MakeCDossierHeader` and `\MakeCDossierStatementHeader` render fixed line
lists and are what a document normally uses. This triple is the interface
beneath them, for a header whose lines a class or a document has to choose
itself — the statement's title, subtitle, and context lines interleave with the
identity lines rather than following them, so no append-only hook over
`\MakeCDossierHeader` can express it.

A caller states only which lines are present, in reading order.
`careerdossier-components` owns every gap, and the triple adds no spacing
option:

- no gap above the first line;
- `\CDossierSharedHeaderNameGapSkip` below the first line;
- `\CDossierSharedHeaderMetaGapSkip` below every later line;
- the rendering class's own header-below token as the boundary under the stack
  (`\CDossierRecordHeaderBelowSkip`, `\CDossierLetterHeaderBelowSkip`, or
  `\CDossierProseHeaderBelowSkip`);
- `\parskip` zeroed for the header group, so each token names the rendered gap
  in every class.

Position decides which token guards a boundary, never presence, so an omitted
line leaves neither a blank line nor a gap behind. Emit a line conditionally by
calling `\CDossierHeaderLine` only when you have content for it.

Expected behavior:

- `\CDossierHeaderBegin` starts a stack and discards any lines left over from
  an abandoned one;
- `\CDossierHeaderLine` stores its argument unexpanded and does not typeset
  anything yet, so a line may carry structure — a heading, a link, a tagged
  element — and keeps it;
- `\CDossierHeaderEnd` renders the collected lines, each as its own centered
  paragraph, and emits the boundary below the stack;
- a stack with no lines renders nothing, including no boundary below it;
- no validation is performed. `\CDossierHeaderBegin` does not require `name`;
  the wrapper commands keep their own validation.

Worked example. `\MakeCDossierHeader` renders name, optional headline, and
contact line; this résumé wants `location` on a line of its own *between* the
headline and the contact line, which is a position no append-only hook can
reach:

```latex
\documentclass{careerdossier-resume}

\CDossierSetup{
  name     = {Ada Lovelace},
  headline = {Data Scientist},
  location = {London, UK},
  email    = {ada@example.com},
}

\begin{document}

\CDossierHeaderBegin
\CDossierHeaderLine{
  \CDossierNameStyle \CDossierSizeName
  \CDossierPrintField{name}
}
\CDossierHeaderLine{
  \CDossierHeadlineStyle \CDossierSizeHeadline
  \CDossierPrintField{headline}
}
\CDossierIfFieldTF{location}
  {
    \CDossierHeaderLine{
      \CDossierMutedStyle \CDossierSizeSmall
      \CDossierPrintField{location}
    }
  }
  { }
\CDossierHeaderLine{
  \CDossierBodyStyle \CDossierSizeSmall
  \CDossierPrintField{email}
}
\CDossierHeaderEnd

\CDossierSection{Experience}

\end{document}
```

The `location` line is emitted only when the field is set — that is the whole
of "conditional", and it is why the guard wraps the `\CDossierHeaderLine` call
rather than appearing inside it. Drop the `location` key from `\CDossierSetup`
and the header renders three lines with no gap left behind, because the tokens
follow position: the boundary below the name stays
`\CDossierSharedHeaderNameGapSkip` and each later boundary is
`\CDossierSharedHeaderMetaGapSkip`, whichever lines are present.

This composes a header; it does not replace `\MakeCDossierHeader`'s validation.
A document that needs `name` enforced should keep calling `\MakeCDossierHeader`,
or check the field itself.

### `\MakeCDossierHeader`

```latex
\MakeCDossierHeader
```

Renders the résumé identity block using shared profile metadata. Since `v0.7.0`
it is a wrapper over the public header stack above, which it drives with a
fixed three-line list.

Expected behavior:

- validates `name`;
- sets the name, optional headline, and contact line with the calibrated
  `fontsize` type scale;
- derives the gaps within and around the identity block from the shared
  baseline rhythm rather than the base class's `center` environment, and from
  its own zeroed `\parskip` rather than the class's document-wide one;
- renders `headline` only when present, and leaves no gap behind when it is
  absent;
- guards the boundary below the name with
  `\CDossierSharedHeaderNameGapSkip` whether or not `headline` is present
  (before `v0.7.0` an absent `headline` silently moved that boundary to
  `\CDossierSharedHeaderMetaGapSkip`);
- renders available contact fields;
- inserts separators only between rendered fields that remain on the same
  visual line;
- creates links for supported contact fields;
- prefixes `Email:`, `Phone:`, and `Website:` text labels when
  `contact-labels = true` (see “Contact-field labels”);
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

The letter class arranges these blocks using the shared
`careerdossier-tokens` prose and block-spacing values. An absent recipient
block or subject omits both the content and its following block skip.

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

Creates a résumé or CV section heading followed by a full-width decorative
rule. Class-controlled spacing places the rule closer to its heading than to
the content below; no additional paragraph line spacing is inserted around the
rule.

The rule sits `\CDossierRecordSectionRuleGapSkip` below the heading's
**baseline**, not below the bottom of its line box, so its height does not
change when the heading happens to contain a descender. The token consequently
has a lower bound: it must exceed the heading's depth, or the rule would cross
descender ink.

The gap between the rule and the section's first content is the larger of
`\CDossierRecordSectionBelowSkip` and whatever leading space the following
block contributes — never their sum. A section that opens with an entry, a
bullet list, or an ordinary paragraph therefore yields one predictable gap
rather than three different ones.

The argument is user-visible text. The command does not automatically translate arbitrary section titles.

The statement class defines `\CDossierSection` too, and it opens a section
there as well, but a statement is prose: the heading is set without a rule and
on the prose heading rhythm. See "Author content and headings" for that class's
two heading levels.

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

The space above the list is `\CDossierRecordListEdgeAboveSkip` and the space
below it is `\CDossierRecordListEdgeBelowSkip` (`careerdossier-tokens.sty`).
Each token is the complete gap at its end of the list, and both collapse with
the adjacent block's own spacing rather than adding to it. The two replace the
single `\CDossierListEdgeSkip` of `v0.6.0`, which LaTeX could only apply at
both ends at once; see [`MIGRATION.md`](MIGRATION.md). Both keep that token's
calibrated value, so a document's rendered list spacing is unchanged. The CV's
`CDossierPublications` list uses the same pair.

`\CDossierRecordListEdgeAboveSkip` additionally has a **lower bound of `0.25`**,
which is an extraction constraint rather than a design preference. The entry
heading sets its dates and location in a right-hand column, and Poppler keeps
that column with its entry only while the entry's vertical band stays distinct
from the list beneath it. Below `0.25` the two merge and the dates extract after
the bullets — on the résumé and the CV alike, at every supported body size, and
on tagged and untagged output equally. Overriding this token below `0.25`
therefore breaks reading order in `pdftotext`-class consumers; see
[`ATS-EXTRACTION.md`](ATS-EXTRACTION.md) section 3.4.

Both tokens apply under `\DocumentMetadata{tagging=on}` as well, so a tagged
build and an untagged build of the same source place their lists identically
([#193](https://github.com/amirhs1/CareerDossierTeX/issues/193)). Tagged output
remains an opt-in preview and carries no conformance claim; see
[Tagged structure (opt-in)](#tagged-structure-opt-in).

When the list crosses a page boundary it is never split so that a single item
stands alone on either side; a list longer than a page still breaks normally.
See "Page-break policy" below.

## Page-break policy

The résumé and CV classes state where a page may break rather than leaving
every break to LaTeX's defaults:

- a section heading stays with the entry it introduces;
- an entry heading stays with its own second line and with the first line of
  its body;
- a bullet list is never split leaving one item alone on either side.

The policy uses page-break penalties, not boxing, so material that genuinely
does not fit still breaks: an entry or bullet list longer than a page
paginates normally rather than overflowing. Because a list must know its own
length before it is typeset, each list records that count in the auxiliary
file — so a résumé or CV needs the same second LaTeX pass it already requires
for the `Page N of M` folio. On a first clean pass the breaks are provisional.

### Typographic page-break penalties

All four classes call `\CDossierApplyPageBreakPenalties` to set `\brokenpenalty`,
`\clubpenalty`, and `\widowpenalty` from the named tokens `\CDossierBrokenPenalty`,
`\CDossierClubPenalty`, and `\CDossierWidowPenalty` (`careerdossier-tokens.sty`),
so a hyphenated word is never split across a page break and no single line of a
paragraph is stranded alone at the foot of one page (a club line) or the head of
the next (a widow line).

All three tokens default to `10000` — forbidding the break — across every
family, not only the résumé and CV covered by the structural policy above.
Measurement against the committed letter fixtures during development showed a
discounted value (`4000`) for the continuous-prose classes still let a club
line through; `10000` removed it, with zero overfull `\vbox`es across every
two-page fixture. This is safe because all four classes are `\raggedbottom`:
forbidding a club or widow break only closes off the first and last line of a
paragraph as a break point, and every interior line break remains available,
so a page can still break inside an over-long paragraph rather than overflow.

The letter and statement classes otherwise remain continuous prose with no
further structural page-break policy.

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

The typography package may expose semantic style commands for internal and advanced use. Each names one place in a document, and the table says which:

| Role | Where it applies |
|---|---|
| `\CDossierNameStyle` | the profile name at the head of every document |
| `\CDossierHeadlineStyle` | the optional headline below the name |
| `\CDossierSectionStyle` | every section heading, in every class; also, composed with a smaller step of the size scale, the statement's subsection headings, and with a larger one its document title |
| `\CDossierEntryTitleStyle` | the heading of one job, degree, or project — the title line a `CDossierEntry` environment renders, in the résumé and the CV |
| `\CDossierSubjectStyle` | a cover letter's subject line, between the recipient block and the salutation |
| `\CDossierBodyStyle` | running prose, and every line set as prose: the contact line, an entry's organization, and the letter's date, recipient block, salutation, closing, and signature name |

These commands describe meaning rather than a particular font family, weight, or size.

`\CDossierEntryTitleStyle` and `\CDossierSubjectStyle` resolve to the same shape
today. That is two independent decisions agreeing, not one role with two names:
redefining either leaves the other alone, so restyling entry headings does not
restyle letter subject lines. Do not define one in terms of the other.

One further role, `\CDossierMutedStyle`, is published by
`careerdossier-components` rather than by the typography package, because
`muted=gray` and `muted=both` resolve it to a colour and the typography package
owns no colour. It behaves like the roles above and is available in every
document class; only a document loading `careerdossier-typography` on its own
does not get it. See [`muted`](#muted) and
[`MIGRATION.md`](MIGRATION.md#080---unreleased).

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
  fontsize=12pt,
  margin=normal,
  paper=letter,
  bodyfont=serif,
  medium=print,
  muted=italic
]{careerdossier-cv}
```

The class accepts the same value sets as the résumé class:

| Option | Accepted values | CV default |
|---|---|---|
| `fontsize` | `10pt`, `11pt`, `12pt` | `12pt` |
| `margin` | `normal`, `narrow` | `normal` |
| `paper` | `letter`, `a4` | `letter` |
| `bodyfont` | `serif`, `sans` | `serif` |
| `medium` | `print`, `screen` | `print` |
| `muted` | `italic`, `gray`, `both` | `italic` |

English and the monochrome theme remain fixed. Unsupported options or values
must produce a class error rather than being ignored, and the error for an
unsupported value must name the accepted set.

Section, entry, rule, bullet-list, and manual-publication-list metrics derive
from the shared calibrated tokens and scale with `fontsize`. The CV intentionally
shares the résumé rhythm; its roomier default presentation comes from its
larger default body size.

The first page renders the ordinary dossier header in the document body. A
multi-page CV follows the shared page-furniture policy above; a one-page CV
suppresses the former `Page 1 of 1` folio. Contact information must not exist
only in running material.

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

`CDossierPublications` creates a numbered list in source order, resets its
counter on entry, and uses the shared list spacing and label separation.
`\CDossierPublication` is valid only inside that environment.

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

The gap between bibliography entries follows the same calibrated list token as
every other list in the CV, `\CDossierRecordItemSepSkip`, so a `biblatex`
publication list and a `CDossierPublications` list share one rhythm at every
supported `fontsize`. When the package is loaded by a class that does not
provide the token, the gap falls back to a fixed `6pt`.

The horizontal gap between an entry number and its entry follows the shared
list label token, `\CDossierListLabelSep`, for the same reason: an entry number
sits as close to its entry as a `CDossierPublications` label does. BibLaTeX's
own default is `2\labelsep`, which places the gap at roughly one em — the width
at which `pdftotext`'s default (non-layout) mode stops treating the numbers as
labels and starts treating them as a separate left-hand column, emitting them
as a block ahead of the entry text. `\CDossierListLabelSep` is half the body
size, so the gap clears that threshold at every supported `fontsize`. When the
host class does not provide the token, BibLaTeX's own default is left in place.

URLs printed in a bibliography keep BibLaTeX's break points but use a reduced
stretch at each of them, so a justified line ending in a URL spreads its word
spaces rather than the URL itself. A stretched URL extracts as separate tokens
(`https : / / example . invalid /`) and is then neither searchable nor
copyable. This narrows the failure considerably but cannot rule it out: TeX
will exceed a stated stretch to set an otherwise underfull line.

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
`\CDossierLetterSetup`, `\MakeCDossierLetterhead`, and `\MakeCDossierClosing`,
including the current recipient, salutation, subject, closing, and
sender-metadata behavior. Optional recipient and academic profile fields
collapse independently.

The academic family derives `/Title` as
`Academic Cover Letter – <name>`, but it does not change geometry, type scale,
prose rhythm, or letterhead spacing. Both letter families follow the shared
page-furniture policy: one-page output is clean, while multi-page output uses
`Cover Letter` as its continuation label. The academic family does not
introduce new recipient keys or change the industry family's defaults. Unknown
family values must produce a class error naming the accepted values.

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

A4 paper and statement classes are supported as of `v0.5.0`; this historical
list describes the scope of `v0.2.0` only.

### Compatibility with `v0.1.x`

The `v0.2.0` additions are intentionally additive:

- `careerdossier-resume` keeps its options, defaults, and commands;
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

> **Status:** released in `v0.5.0`.

### Class and statement types

All statement documents use one class with an optional `type` option and the
shared `fontsize`, `margin`, `paper`, `bodyfont`, and `medium` settings:

```latex
\documentclass[
  type=research,
  fontsize=12pt,
  margin=normal,
  paper=letter,
  bodyfont=serif,
  medium=print,
  muted=italic
]{careerdossier-statement}
```

When `type` is omitted, the class selects `interest`; it requires no
profile fields beyond `name` and `email`. Supplying `type` without a value or
using an unsupported value produces an actionable class error. The accepted
values, page-one titles, and continuation-header titles are:

| `type` value | Default title | Default running title |
|---|---|---|
| `interest` (default) | `Statement of Interest` | `Statement of Interest` |
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

The `v0.6.0` layout uses the shared calibrated design system:

- LuaLaTeX, English, and monochrome output;
- `paper=letter|a4`, defaulting to US Letter and preserving the academic
  letter's physical margins on A4;
- `bodyfont=serif|sans`, defaulting to the current TeX Gyre Termes body and
  retaining TeX Gyre Heros headings in both modes;
- 12 pt body text by default, with `10pt` and `11pt` available;
- normal one-inch margins by default, with `margin=narrow` available;
- name, title, subtitle, affiliation, context, and contact sizes selected from
  the calibrated type scale;
- header gaps and prose paragraph rhythm derived from the selected body
  baseline;
- section and subsection headings on the same semantic heading role, type
  scale, and baseline-derived rhythm as every other class;
- a centered identity block in the body on page one;
- no running header on page one;
- a centered `<name> -- <running title>` header from page two; and
- the shared one-page suppression and multi-page continuation furniture under
  the default `medium=print`, and no furniture at all under `medium=screen`.

Page furniture is component-owned; `medium` is the only public control over
it, and it decides only whether furniture is emitted. The statement
class registers its short running title with the shared component and uses the
same type, rhythm, geometry, paper, and body-font system as the résumé, CV, and
letter classes. The seven statement types retain independent full display and
short running titles: the full title remains meaningful page-one content and
PDF metadata, while the short title is used only in continuation furniture.
Named or per-role font combinations remain future design work in issue #120.
Color themes and icons remain unsupported.

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
| `interest` (default) | None | `phone`, `website`, `affiliation` |
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
contact list. Since `v0.7.0` the header shares one emission site with
`\MakeCDossierHeader`, which places a gap *between* two present lines rather
than attaching one to each optional block, so an absent value leaves neither a
blank line nor a gap. The boundary below the name is
`\CDossierSharedHeaderNameGapSkip` and every later boundary is
`\CDossierSharedHeaderMetaGapSkip`, whatever the line beneath it turns out to
be. That emission site is the public `\CDossierHeaderBegin` /
`\CDossierHeaderLine` / `\CDossierHeaderEnd` triple, which
`\MakeCDossierStatementHeader` composes over; the interleaved order above is why
the statement cannot simply call `\MakeCDossierHeader`. Contact and context
separators are inserted only between present
items and are layout artifacts in tagged output. The selected page-one `title`
drives PDF document metadata; the shorter `running-title` exists only for page
furniture and does not replace the full title in meaningful content.

### Author content and headings

The class introduces no command for research aims, teaching themes, EDI
commitments, artistic methods, or statement-of-purpose paragraphs. Authors
write ordinary prose and may add headings when the application and content
benefit from them. The class does not force headings, a page count, or a
type-specific narrative schema.

Two unnumbered heading levels are available, and each has two spellings:

```latex
\CDossierSection{Research Vision and Significance}
\CDossierSubsection{A Narrower Theme}
```

`\CDossierSection` matches the name the résumé and CV use, so one profile's
documents are written the same way. It is a wrapper over standard LaTeX
`\section*`, and `\CDossierSubsection` over `\subsection*`; both spellings
remain supported and render identically, because there is one renderer.

Since `v0.6.0` the rendering is part of the calibrated design system rather
than `article`'s heading defaults:

| Property | Statement heading |
|---|---|
| Section size | `\CDossierSizeSection` — 11 / 12 / 13 pt |
| Subsection size | `\CDossierSizeBody` — 10 / 11 / 12 pt |
| Typeface | `\CDossierSectionStyle`, the sans heading role, in both `bodyfont` modes |
| Space above | `\CDossierProseSectionAboveSkip` / `\CDossierProseSubsectionAboveSkip` |
| Space below | `\CDossierProseSectionBelowSkip` / `\CDossierProseSubsectionBelowSkip` |
| Decorative rule | None |

Each spacing token is the complete gap, including the paragraph spacing either
side of the heading contributes. A statement heading carries no rule: the
full-width rule under `\CDossierSection` in the résumé and CV is
entry-structured section furniture, and a prose document reads better without
it.

Numbered sectioning and heading levels below `\subsection` are inherited from
`article` unchanged and are outside the calibrated design; a statement is not
expected to use them.

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

The first-page title, ordinary paragraphs, section headings, and links remain
meaningful structure in source order. Running headers, folios, and contact
separators are layout artifacts. Both heading spellings go through the kernel's
own sectioning machinery, so each opens a section division enclosing its
heading and the content that follows, and records the heading text as that
division's title. This design extends the academic
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

The committed smoke, layout, extraction, and tagging fixtures cover all seven
type values, required and invalid inputs, optional-field collapse, continuation
page furniture, PDF metadata, source-order extraction, and tagged/untagged
output. The six complete specialized-type two-page examples provide the visual
review surface.

## Vertical-spacing tokens

Every vertical boundary in the four classes is owned by exactly one token, and
each token is the complete gap a reader measures. The names follow
`\CDossier<Family><Scope><Position>Skip`; the calibrated ratios and their
resolved values at each `fontsize` are tabulated in
[`ARCHITECTURE.md`](ARCHITECTURE.md#vertical-rhythm).

| Family | Tokens |
|---|---|
| Shared (all four classes) | `\CDossierSharedHeaderNameGapSkip`, `\CDossierSharedHeaderMetaGapSkip` |
| Record (résumé, CV) | `\CDossierRecordHeaderBelowSkip`, `\CDossierRecordSectionAboveSkip`, `\CDossierRecordSectionRuleGapSkip`, `\CDossierRecordSectionBelowSkip`, `\CDossierRecordEntryAboveSkip`, `\CDossierRecordEntryGapSkip`, `\CDossierRecordListEdgeAboveSkip`, `\CDossierRecordListEdgeBelowSkip`, `\CDossierRecordItemSepSkip`, `\CDossierRecordParSkip` |
| Prose (statement) | `\CDossierProseHeaderBelowSkip`, `\CDossierProseSectionAboveSkip`, `\CDossierProseSectionBelowSkip`, `\CDossierProseSubsectionAboveSkip`, `\CDossierProseSubsectionBelowSkip`, `\CDossierProseParSkip` |
| Letter | `\CDossierLetterHeaderBelowSkip`, `\CDossierLetterParSkip`, `\CDossierLetterRecipientLineGapSkip`, `\CDossierLetterBlockSkip`, `\CDossierLetterBodyAboveSkip`, `\CDossierLetterBodyBelowSkip`, `\CDossierLetterSignatureGapSkip` |

Only the two gaps *inside* the header block are shared. The gap *below* it is a
boundary against whatever the class puts next — a ruled section in the record
classes, a prose section in the statement, the date line in the letter — so each
family owns that one, and all three ship at the same `0.9375` ratio.

Two rules govern how a token reaches the page, and overriding a token without
them in mind is the usual reason an override appears to do nothing:

- **Boundaries compose with `\addvspace`, which takes the maximum of the
  adjacent claims and never their sum.** Raising a token past its neighbour is
  what makes it visible; lowering it below its neighbour makes it inert.
  `\CDossierRecordEntryGapSkip` in particular is a *floor* for the entry
  heading → body boundary, which a bullet list overrides with
  `\CDossierRecordListEdgeAboveSkip`.
- **One token also carries a constraint from outside the type scale.**
  `\CDossierRecordListEdgeAboveSkip` may not go below `0.25` without breaking
  the extraction order of the entry heading's dates column, as described under
  [`CDossierItemize`](#cdossieritemize).
- **A paragraph boundary also contributes `\parskip`.** In the statement class
  that is `\CDossierProseParSkip`, and in the letter class it is
  `\CDossierLetterParSkip`; a token at such a boundary is emitted as
  `token − \parskip` so the token still names the rendered gap. The header block
  zeroes `\parskip` for its own scope, which is why the two shared header gap
  tokens behave identically in all four classes.

Since `v0.7.0`, `\CDossierRecordHeaderBelowSkip`,
`\CDossierProseHeaderBelowSkip`, `\CDossierLetterHeaderBelowSkip`,
`\CDossierLetterParSkip`, `\CDossierLetterRecipientLineGapSkip`, and
`\CDossierLetterBodyBelowSkip` are new, and `\CDossierRecordEntryBelowSkip`,
`\CDossierLetterheadBelowSkip`, `\CDossierSharedHeaderAboveSkip`, and
`\CDossierSharedHeaderBelowSkip` are removed; see
[`MIGRATION.md`](MIGRATION.md#070---2026-08-04).

The calibrated *values* are not stable API before `v1.0.0`; the token names and
the boundaries they own are.

## Colors and theme tokens

The monochrome theme may expose semantic tokens:

```latex
\CDossierTextColor
\CDossierMutedColor
\CDossierRuleColor
\CDossierLinkColor
```

`\CDossierMutedColor` is `gray 0.30`, measured at 8.52:1 against white under
the WCAG 2.1 relative-luminance formula. It is what `muted=gray` and
`muted=both` render de-emphasised runs in; under the default `muted=italic`
nothing uses it.

`\CDossierPrimaryColor` was removed: it reached no component, class, or
example, and its underlying color was `gray 0` — the same value as
`\CDossierTextColor` under a different name. See
[`docs/MIGRATION.md`](MIGRATION.md#080---unreleased).

Users should not rely on the underlying color names or values as stable API before `v1.0.0`.

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
