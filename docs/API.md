# CareerDossierTeX Public API

For people writing documents with the toolkit: every public class, option,
command, key, and design token, with its accepted values and default. It
describes the released interface, not the internals —
[`ARCHITECTURE.md`](ARCHITECTURE.md) covers which module owns what and why.

## Status

This document records the released public interface:

```text
Released: v0.8.0 — Semantic Structure and Tagged Output
```

Sections that are not explicitly marked as planned describe released behavior.
Before `v1.0.0` the interface may still change between minor versions; such
changes are recorded in [`../CHANGELOG.md`](../CHANGELOG.md) and
[`MIGRATION.md`](MIGRATION.md).

`v0.8.0` changed the interface in six ways:

- `\CDossierSubsection{<title>}` gives the résumé and the CV a second heading
  level, below the ruled section and above an entry. It carries no rule and no
  size of its own, and under `\DocumentMetadata{tagging=on}` it is a depth-3
  heading role-mapped to `/H3`.
- `\CDossierLink{<url>}` is the supported way to put a link in body text, and
  `\CDossierSubjectStyle` is a semantic role for a cover letter's subject line.
- All four document classes accept `muted=plain|italic|gray|both`, and the
  résumé and CV additionally accept `entrymeta=column|inline`. **`muted`
  defaults to `plain`**, so entry metadata is upright black body text rather
  than italic; `muted=italic` restores the previous appearance.
- The `linkedin`, `github`, and `scholar` profile keys accept a bare handle as
  well as a full URL, and a value that already carries a scheme is used as
  written. An `orcid` value that is not ORCID-shaped, and a build in which
  `hyperref` is absent so links degrade to plain text, each now warn once.
- **BREAKING (type-scale token):** `\CDossierSizeTitle` is renamed to
  `\CDossierSizeDocumentTitle`. **BREAKING (color token):**
  `\CDossierPrimaryColor` is removed; `\CDossierTextColor` is an identical
  drop-in.
- `CDossierEntry` reads its body as an argument, so catcode-sensitive content
  such as `\verb` must be defined outside the entry. No other source edit
  follows from it.

The section-heading keep became a bound (`\CDossierSectionNeedLines`, default
`4`) rather than an unbounded prohibition, so **pagination may change** in a
document whose sections previously moved whole to the next page. See
[`MIGRATION.md`](MIGRATION.md#080---2026-08-12).

`v0.7.0` before it changed the interface in four ways:

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

`v0.6.0` earlier removed `density=compact|standard` from the résumé and CV
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
| Entry-metadata de-emphasis | `muted=plain` (default), `muted=italic`, `muted=gray`, or `muted=both` |
| Entry-metadata placement | `entrymeta=column` (default) or `entrymeta=inline`, résumé and CV |
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
  muted=plain,
  entrymeta=column
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
| `careerdossier-components` | `medium`, `muted`, `entrymeta` | `medium=print`, `muted=plain`, `entrymeta=column` |

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

`medium` also decides whether a link carries a visible decoration:

| Value | Author-written `\href` anchor text |
|---|---|
| `print` | undecorated — reads as ordinary body text |
| `screen` | underlined |

Links are drawn in body black with no border under both values, which is the
print-safe treatment this toolkit has always had. Where a link's visible text is
the address — the contact line, [`\CDossierLink`](#cdossierlink), an ORCID iD, a
bibliography DOI — that costs a reader nothing, because the text announces
itself. Where an author supplies their own anchor text there is otherwise no cue
of any kind:

```latex
Shipped the analytical engine, documented in a
\href{https://example.org/work}{public write-up}.
```

Under `medium=screen` `public write-up` is underlined; under `medium=print` it
is not. The decoration is applied to anchor text an author writes, and
deliberately not to the address-as-text links this toolkit renders itself — a
rule under a contact line's e-mail and website but not under its phone or
location reads as emphasis rather than as linking. `\CDossierPlainLinks`
suppresses the decoration for a region; see
[`\CDossierPlainLinks`](#cdossierplainlinks).

The link *annotation* is emitted under both media. It is invisible on paper and
costs nothing there, and stripping it would hand dead links to anyone who opens
a `medium=print` file on screen.

The option changes only whether furniture and link decoration are emitted. Page
geometry is unchanged, so the text block sits in exactly the same place under
both values and switching `medium` cannot reflow a document — the underline is
drawn from a node attribute at shipout, so it adds no box and moves no break
point. Extracted text is identical under both values, on every supported
extractor. Unsupported values produce a class error naming the accepted values.

#### `muted`

Every CareerDossierTeX document class accepts:

```text
plain
italic
gray
both
```

`muted` is new in `v0.8.0`, as are `plain` and `plain` as the default. Note the
spelling: `gray`, not `grey`.

`muted` decides how de-emphasised runs are rendered — an entry's dates and
location in the résumé and CV, and the statement's application-context line.
The default is `plain`, which applies no de-emphasis: upright, in the body
family, in the ordinary black text token. `italic` slants the same runs,
`gray` sets them upright in the muted token instead, and `both` applies the
italic and the muted token together.

| value | shape | colour |
|---|---|---|
| `plain` (default) | upright | text token (black) |
| `italic` | italic | text token (black) |
| `gray` | upright | muted token (gray 0.30) |
| `both` | italic | muted token (gray 0.30) |

The muted token is `gray 0.30`, which measures 8.52:1 against white under the
WCAG 2.1 relative-luminance formula — well above the 4.5:1 normal-text floor.

Which styling to want is a genuine trade-off, which is why it is an option:

- italic at small sizes is harder to read for low-vision and dyslexic readers
  than a high-contrast gray, and this metadata is scanned rather than read;
- shape, unlike a gray level, survives a fax, a photocopy, and a 1-bit print.

`plain` is the default because both halves of that trade-off are real, and a
reader affected by both would otherwise have nothing to select. Being body text
in the ordinary text token, it is also the one value that cannot fail the
contrast floor `gray` has to be measured against. What it gives up is a
redundant signal rather than the only one: under `plain` the dates and location
are distinguished by their position and their content alone — which is the
design's standing claim under every value rather than a new one, and under
`entrymeta=inline` the separator identifies them as well. A document that wants
the styling asks for it by name.

Under every value the de-emphasis is reinforced by position and content — the
dates sit in their own flush-right column and read as a date range — so colour
is never the only carrier of meaning. All four values are visual only: no
extractor sees a difference, and the reading order is identical under each.

Unsupported values produce a class error naming the accepted values.

#### `entrymeta`

The résumé and CV classes accept:

```text
column
inline
```

`entrymeta` is new in `v0.8.0`. The letter and statement classes do not
accept it: neither has entry headings.

`entrymeta` decides where an entry's dates and location sit. Under the default
`column` they are set flush right, opposite the title and organization:

```text
Senior Engineer                                          2024–Present
Example Labs                                              Toronto, ON
  • First achievement in source order.
```

Under `inline` they follow the title and organization on the same line, joined
by `\CDossierEntryMetaSeparator`:

```text
Senior Engineer | 2024–Present
Example Labs | Toronto, ON
  • First achievement in source order.
```

`column` reproduces the previous behaviour exactly. Nothing else changes under
either value: the cells keep their order, their semantic roles, and the
page-break penalty that holds the two heading lines together, and a missing
`organization`, `location`, or `dates` leaves no stray separator under `inline`
just as it leaves no empty column under `column`.

**What the option is for.** `\CDossierRecordListEdgeAboveSkip` carries a lower
bound of `0.25` that is an extraction constraint rather than a design
preference — see [`CDossierItemize`](#cdossieritemize) and
[`ATS-EXTRACTION.md`](ATS-EXTRACTION.md#34-dates-and-right-alignment) section
3.4. The bound exists because
the flush-right column makes each heading row a two-column region for a
geometric extractor, and only enough vertical separation below the heading keeps
the dates from being read after the bullets. `inline` has no column, so no such
region arises and the bound does not apply to a document that selects it. This
is the only supported way to set a list edge below `0.25` without breaking
reading order.

The bound is not lifted, and the token's calibrated default does not move. A
document that wants the tighter edge selects `inline` **and** sets the token
itself:

```latex
\documentclass[entrymeta=inline]{careerdossier-resume}
\ExplSyntaxOn
\skip_set:Nn \CDossierRecordListEdgeAboveSkip
  { \fp_to_dim:n { 0.125 * \dim_to_fp:n { \CDossierBodyLeading } } }
\ExplSyntaxOff
```

Under `column` that override still breaks reading order, and nothing detects it
for you.

`inline` is not the default because it is a visible design change — it discards
the column the résumé's layout is built around — and because making it the
default would reflow every existing document to buy a constraint only some
documents care about. Design, a clean text layer, and a sub-`0.25` list edge are
mutually exclusive; any two are available.

Both values are equivalent on the tagged path. The separator is emitted as a
layout artifact, exactly as the contact line's `|` is, so a consumer reading the
structure tree receives the same logical text under either value and assistive
technology is not made to announce a vertical bar. Both validate as PDF/UA-2 in
the repository's tagging fixtures.

Unsupported values produce a class error naming the accepted values.

#### `\CDossierEntryMetaSeparator`

The mark `entrymeta=inline` places between two cells, with its surrounding
space. The default is `~|~` — the same mark the contact line uses, so a document
has one field separator rather than two.

It is emitted only between two cells that are both present, so redefining it
cannot introduce a stray separator. Two properties of the default are worth
preserving in a replacement:

- The mark is wrapped as a **layout artifact**, which is what keeps it out of
  the structure tree on the tagged path. A replacement that sets the mark as
  ordinary text will render identically and will also be announced by a screen
  reader and appear in the structure element's text.
- The **leading** space is ordinary content glue and the **trailing** one sits
  inside the artifact. That asymmetry is deliberate: an artifact interrupts the
  enclosing run, so only the leading space survives as the word boundary between
  the two cells, and a second content space would show up as a doubled gap in
  the extracted logical text.

Keep the mark out of the muted role as well. The cell that follows it on the
second heading line is set in `\CDossierMutedStyle`, which is italic under
`muted=italic` and `muted=both`, and an italic separator reads as a glyph
belonging to the metadata rather than as the boundary between two fields. The
default wraps the mark in `\CDossierBodyStyle` for this reason, which resets
shape as well as family.

Under `entrymeta=column` the token is not used at all.

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
  muted=plain
]{careerdossier-letter}
```

`family` accepts `industry` and `academic`; the default is `industry`. `paper`
uses the shared `letter|a4` contract above and defaults to `letter`. `bodyfont`
uses the shared `serif|sans` contract above and defaults to `serif`. `medium`
uses the shared `print|screen` contract above and defaults to `print`. `muted`
uses the shared `italic|gray|both|plain` contract above and defaults to
`plain`.
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
| `linkedin` | No | Released | LinkedIn handle, profile path, or URL |
| `github` | No | Released | GitHub handle, profile path, or URL |
| `scholar` | No | Released | Google Scholar identifier, profile path, or URL |
| `orcid` | No | `v0.2.0` | ORCID identifier or profile URL |
| `affiliation` | Conditional | `v0.5.0` | Current institution, organization, studio, or independent-practice description |

Whitespace-only values should be treated as missing.

`name` is the only key every class requires. A class may require a further key
for a particular document, and three do — the statement class requires `email`
for every statement, `affiliation` for `type=research`, and `website` for
`type=artist`. "Conditional" in the table above means exactly that: the key is
optional to the profile and required by some documents that use it. See
"Required profile fields and displayed contacts" for the statement rules.

### Accepted forms for the web-profile keys

`linkedin`, `github`, and `scholar` name a service with a documented canonical
address, so each accepts a bare identifier as well as an address. A bare
identifier is expanded to the canonical address — for the displayed text and for
the link target alike, so the address on the page is the address the link goes
to:

| Key | Written | Displayed | Link target |
|---|---|---|---|
| `linkedin` | `ada-lovelace` | `linkedin.com/in/ada-lovelace` | `https://linkedin.com/in/ada-lovelace` |
| `github` | `ada-lovelace` | `github.com/ada-lovelace` | `https://github.com/ada-lovelace` |
| `scholar` | `kukA0LcAAAAJ` | `scholar.google.com/citations?user=kukA0LcAAAAJ` | `https://scholar.google.com/citations?user=kukA0LcAAAAJ` |

A value is read as a bare identifier when it contains neither `/` nor `.`.
Those two characters are what every address form carries — with a scheme,
without one, or with a `www.` host — and what none of these three services
permits in an identifier.

Any other value is used exactly as written, with only the `https://` scheme
supplied when it carries none. A `www.` host, a trailing slash, and query
parameters are all preserved:

| Written | Displayed | Link target |
|---|---|---|
| `linkedin.com/in/ada-lovelace` | as written | `https://linkedin.com/in/ada-lovelace` |
| `https://www.linkedin.com/in/ada-lovelace/` | as written | as written |

`website` has no canonical host by definition and is never expanded; a value
with no `/` or `.` is displayed and linked exactly as written. `orcid` keeps its
own normalization and its `ORCID:` label, described under
[Academic profile metadata](#academic-profile-metadata).

#### Forms that work

Every row below produces a working link. Give either the identifier alone or a
complete address; the forms in between are what go wrong.

| Key | Write | Displayed and linked as |
|---|---|---|
| `linkedin` | `ada-lovelace` | `linkedin.com/in/ada-lovelace` |
| `linkedin` | `linkedin.com/in/ada-lovelace` | unchanged |
| `linkedin` | `www.linkedin.com/in/ada-lovelace` | unchanged, `www.` kept |
| `linkedin` | `https://www.linkedin.com/in/ada-lovelace/` | unchanged, scheme and trailing slash kept |
| `github` | `ada-lovelace` | `github.com/ada-lovelace` |
| `github` | `github.com/ada-lovelace` | unchanged |
| `github` | `https://github.com/ada-lovelace` | unchanged |
| `scholar` | `kukA0LcAAAAJ` | `scholar.google.com/citations?user=kukA0LcAAAAJ` |
| `scholar` | `scholar.google.com/citations?user=kukA0LcAAAAJ` | unchanged |
| `scholar` | `https://scholar.google.com/citations?user=kukA0LcAAAAJ` | unchanged |

A Google Scholar identifier containing `_` needs no escape.

#### Forms to avoid

These build successfully and produce a broken link, which is the case worth
knowing about: the page looks correct, and nothing in the log says otherwise.
Bare identifiers are not validated, because nothing in LaTeX can dereference an
address.

| Written | You get | Why |
|---|---|---|
| `linkedin = {in/ada-lovelace}` | `https://in/ada-lovelace` | half a path: the `/` makes it read as an address, so it is left alone |
| `linkedin = {ada.lovelace}` | `https://ada.lovelace` | the `.` makes it read as a host — and no LinkedIn slug contains one |
| `linkedin = {Ada Lovelace}` | `linkedin.com/in/Ada Lovelace` | a display name, not a handle; note the space inside the address |
| `github = {@ada-lovelace}` | `github.com/@ada-lovelace` | `@` is a social-media convention, not part of a GitHub address |
| `github = {ada-lovelace/some-repo}` | `https://ada-lovelace/some-repo` | a repository, not a profile — put repository links in body text with [`\CDossierLink`](#cdossierlink) |
| `scholar = {citations?user=kukA0LcAAAAJ}` | `scholar.google.com/citations?user=citations?user=kukA0LcAAAAJ` | the query rather than the identifier, so the prefix is added on top of it |
| `scholar = {user=kukA0LcAAAAJ}` | `scholar.google.com/citations?user=user=kukA0LcAAAAJ` | the same, doubling `user=` |

#### Characters that stop the build

A field value is read as ordinary text, not as `\url`'s verbatim argument, so
one character is consumed by TeX before the link machinery ever sees it and must
be escaped. This applies to every profile field, not only these three.

| Written | Result | Write instead |
|---|---|---|
| `example.com/a%b` | build fails | `example.com/a\%b` |
| `example.com/a%25b` | build fails | `example.com/a\%25b` — percent-encoding does not help, the `%` is still a comment character |

`%` cannot be fixed at the package level, and the reason is worth stating once:
TeX's lexer discards it and the rest of the line while `\CDossierSetup` is still
reading its argument, so the tokens never reach any code this package could
write. `\%` is the only possible answer.

Nothing else needs escaping. `#`, `&`, `_`, `~`, `$`, and `^` all build and
render correctly, so a pasted Google Scholar address carrying `&hl=en` is fine
in every class, and so is a documentation link carrying `#installation`.

**Escaping them anyway is harmless**, which makes the rule safe to apply
defensively: `example.com/a&b` and `example.com/a\&b` produce a byte-identical
`/URI(https://example.com/a&b)` action in the PDF, and likewise for the others.
So the whole rule an author needs is *escape `%`; escaping anything else changes
nothing.* Over-escaping cannot silently break a link.

In practice this affects `website` and [`\CDossierLink`](#cdossierlink) far more
than the three keys above: a LinkedIn or GitHub handle and a Google Scholar
identifier are restricted to letters, digits, hyphens, and underscores, so `%`
does not occur in one.

`#` used to belong in the table above, failing with a hyperref-internal error
that named neither the field nor the fix. Since `v0.9.0` a raw `#` is accepted
and reaches the link target intact, and `\#` keeps working unchanged — the two
spellings produce the same annotation, so no existing document needs editing.

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
`scholar` values display beginning with their service's domain — including when
the author supplied a bare identifier, since that is expanded to the canonical
address — `orcid` always carries its own `ORCID:` label, and a `location` value
is a place name. Labels are fixed English strings; the project is English-only.

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

One shipped example turns the key on:
[`examples/industry/resume-english.tex`](../examples/industry/resume-english.tex)
sets it after loading the shared profile — the key is an option, not profile
data, so it belongs in the document rather than in
`examples/profiles/profile-english.tex`. That example stays on the default
untagged path deliberately, since untagged output is what the label exists to
fix. The remaining ten examples leave the key at its `false` default.

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
- `\parskip` zeroed for the header group and subtracted from the boundary below
  the stack (since #419), so each token names the rendered gap in every class.

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

The three are a single unit for pagination: the closing text and the signature
name always land on the same page, whichever page that turns out to be. When
they do not both fit under the body, the page breaks *above* the closing and
the whole block opens the next page. This is a contract of the command, not a
token: the boundary between the two is forbidden outright, because under
`\raggedbottom` a page-break penalty here is a boolean rather than a dial (see
"Typographic page-break penalties" below), and a keep-together that is not
infinite is not a keep.

It is a separate guarantee from `\clubpenalty` and `\widowpenalty`, which
cannot express it. Those govern the first and last line *of one paragraph*, and
the closing and the name are two separate one-line paragraphs — so before
`v0.9.0` a sufficiently-tuned letter could strand "Sincerely," at the foot of
one page and the signature name alone at the head of the next
([#421](https://github.com/amirhs1/CareerDossierTeX/issues/421)). Nothing else
about the block changed; a letter whose closing already fit paginates exactly as
before.

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
rather than three different ones. This is the general boundary rule applied to
one token; see
[“Boundary ownership” in `ARCHITECTURE.md`](ARCHITECTURE.md#boundary-ownership).

The argument is user-visible text. The command does not automatically translate arbitrary section titles.

The statement class defines `\CDossierSection` too, and it opens a section
there as well, but a statement is prose: the heading is set without a rule and
on the prose heading rhythm. See "Author content and headings" for that class's
two heading levels.

### `\CDossierSubsection`

```latex
\CDossierSection{Experience}
\CDossierSubsection{Industry}
```

Creates a second-level heading inside a résumé or CV section, for a section with
natural groupings that are not themselves sections — `Experience` split into
industry and academic, `Publications` split into journal, conference, and
preprint. Without it such a group has to be promoted to a full ruled section,
which flattens the hierarchy it was meant to show.

The heading carries no rule and no size of its own: it is
`\CDossierSectionStyle` at `\CDossierSizeBody`, so the level is marked by weight,
face, and spacing rather than by a second rule. The rule belongs to the section.

The gap **below** the heading is `\CDossierRecordSubsectionBelowSkip`, and it is
the same gap whether the next block is a run of `CDossierEntry` or a
`CDossierPublications` list: the token is calibrated to exceed both of their
opening claims, so one pair of tokens serves both groupings.

The gap **above** the heading is `\CDossierRecordSubsectionAboveSkip`, with one
deliberate exception. A section that opens *directly* with a subsection does not
take that gap; the boundary is `\CDossierRecordSectionBelowSkip` alone, which is
the same gap the section would leave before an entry. This matches the statement
class, where `\@startsection`'s own `\if@nobreak` guard produces the same result.
Anything typeset in between — an entry, a bullet list, a paragraph — ends the
exception.

A subsection heading is placed only when at least
`\CDossierSubsectionNeedLines` lines of body leading remain on the page;
otherwise the page ends and the heading opens the next one, so it is never left
alone at the foot of a page introducing nothing. The bound is smaller than
`\CDossierSectionNeedLines` because a subsection commits less: its own heading
line and the first entry heading, with no rule between them. The exception above
applies here too — a subsection opening its section is placed by the section's
own bound and does not test a second one.

Under `\DocumentMetadata{tagging=on}` the heading is a depth-3 heading element,
role-mapped to `/H3`, and it opens a depth-3 `Sect` division that nests inside
its section's. Untagged output is unaffected.

The argument is user-visible text. The command does not automatically translate
arbitrary subsection titles.

The statement class defines `\CDossierSubsection` too, on its own prose heading
rhythm; see "Author content and headings".

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

An entry body may be empty. A body-less entry — the normal shape for an `Education` or `Certificates` section, where the heading carries the degree, institution, and dates and there is nothing to add — renders its heading and contributes nothing further, and the boundary after it stays a legal page break. (Before `v0.8.0` it did not: the penalty that binds a heading to its body was emitted even with no body to bind to, and a run of body-less entries became unbreakable. See #332.)

The body is read as an argument, so catcode-sensitive content cannot appear directly inside an entry. `\verb`, `listings` environments, and anything else that depends on rescanning characters must be wrapped in a macro defined outside the entry, or placed outside it.

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

### `\CDossierLink`

```latex
\CDossierLink{example.org/ada/portfolio}
\CDossierLink{https://example.org/programs/2024/final-report/notes.html}
```

The supported way to put a link in body text — a bullet, an entry, a letter
paragraph, a statement paragraph. The argument is both the text that appears on
the page and, once normalized, the link target: a value carrying no `://` scheme
gains `https://`, exactly as the `website` profile field does, and a value that
has one keeps it. The displayed text is the argument as written, never the
normalized target.

`\CDossierLink` takes no bare identifier. Body text has no service to expand one
against; the canonical-address expansion belongs to the `linkedin`, `github`,
and `scholar` profile keys, which name one. See
[Accepted forms for the web-profile keys](#accepted-forms-for-the-web-profile-keys).

Use it for every address in running text. Typing the URL as plain text does not
work, and neither does `\url`:

| Form | What a long address does |
|---|---|
| plain text | no URL break points, so TeX either overruns the margin or hyphenates the address — and the inserted hyphen travels into the pasted URL |
| `\url` | breaks after punctuation only, so a long segment carrying none stays one unbreakable token: 178.34 pt over the measure in a résumé bullet at `fontsize=10pt, margin=narrow` |
| `\CDossierLink` | may break after any character, with no inserted hyphen |

`\CDossierEmergencyStretch` cannot rescue either of the first two. It
redistributes a line's interword glue, and a line holding one over-wide token
has none to redistribute; see [Line-breaking tokens](#line-breaking-tokens).

`\CDossierLink` extends url.sty's `\UrlBreaks` with the ASCII letters and digits
for the duration of one link, so the address may break anywhere rather than only
after punctuation. url.sty inserts a penalty and no discretionary hyphen at a
break point, so a wrapped address still copies and pastes back character for
character. The extension is local: the contact line and the bibliography keep
the punctuation-only breaks they were calibrated with.

The argument is read as ordinary text, exactly as a profile field value is — it
is not `\url`'s verbatim argument. A target containing a TeX special character
needs it escaped as it would be anywhere else. A query string is the common
case: write `\%` for `%` and `\&` for `&`.

```latex
\CDossierLink{https://example.org/search?q=sound+studies\&profile=advanced\&title=Special\%3ASearch}
```

Both render as themselves on the page and reach the link target unescaped, so
the address still pastes and resolves. An unescaped `%` comments out the rest of
the line and the run stops with an error rather than producing a wrong link.

Keep the address on one source line. A URL cannot contain a literal space, so a
space in the argument — in practice always a line break inside it — is removed
from the link target, with a warning naming the repaired target. Without that
repair the two halves would disagree: url.sty drops the space from the displayed
address, so the page looks correct, while the target keeps it and the link goes
somewhere else. Write `%20` if the space is genuinely part of the address.

Without hyperref the command still prints the address as plain visible text, so
the identifier is never lost; all four classes load hyperref, so the link is
present in ordinary use. See
[Without `hyperref`](#without-hyperref) for the warning that reports it.

A `\CDossierLink` is never underlined, under either `medium`: its visible text
is the address, so it already announces itself. See
[`medium`](#medium) and [`\CDossierPlainLinks`](#cdossierplainlinks).

Introduced in `v0.8.0`
([#308](https://github.com/amirhs1/CareerDossierTeX/issues/308)).

### `\CDossierPlainLinks`

```latex
{\CDossierPlainLinks
 Read the \href{https://example.org/report}{annual report}.}
```

A declaration that turns off link decoration for the rest of the enclosing
group. Under `medium=print` it changes nothing, because nothing is decorated
there; under `medium=screen` an `\href` inside its scope is set without the
underline while still emitting its link annotation.

Use it where a link's visible text is already the address, or where a passage
carries so many links that ruling each one would be noise. The toolkit applies
it to its own address-as-text links — the contact line, `\CDossierLink`, the
ORCID iD, the CV's manual publication identifiers, and the whole bibliography —
so those need nothing from a document.

There is no matching command to turn decoration back on. Scope it with a group,
as above, or with the environment it belongs to.

Introduced in `v0.8.0`
([#278](https://github.com/amirhs1/CareerDossierTeX/issues/278)).

## Page-break policy

The résumé and CV classes state where a page may break rather than leaving
every break to LaTeX's defaults:

- a section heading is placed only when it has room to introduce something;
- an entry heading stays with its own second line and with the first line of
  its body;
- a bullet list is never split leaving one item alone on either side.

The policy uses page-break penalties, not boxing, so material that genuinely
does not fit still breaks: an entry or bullet list longer than a page
paginates normally rather than overflowing.

#### `\CDossierSectionNeedLines`

The section heading's keep, expressed as a bound. A section heading is placed
only when at least this many lines of body leading remain on the page; otherwise
the page breaks before the heading and the heading opens the next one. Defaults
to `4`, which is what the heading needs to introduce anything: the heading and
its rule, the two lines of the first entry heading, and that entry's first line
of body.

It is a count of lines rather than a dimension, because it is a statement about
content — the same four lines at every `fontsize` — and `\CDossierBodyLeading`
supplies the measure at the point of use.

```latex
\int_set:Nn \CDossierSectionNeedLines { 6 }
```

Before `v0.8.0` this was a `\penalty \CDossierHeadingKeepPenalty` emitted *after*
the section rule. Read literally that did not say "keep the heading with its
first few lines" but "keep the heading with everything up to the next legal
breakpoint", which is unbounded: the heading became hostage to whatever the
section happened to contain, and because every vertical token is rigid and all
four classes are `\raggedbottom`, page badness is constant, so the page builder
could not weigh that keep against the hole it opened. It also leaked — with no
content after it the penalty made an empty section's own closing boundary
illegal to break at. Stating the keep as a requirement before the heading bounds
it and leaves every boundary inside the section a legal break, so a page fills to
the last entry that fits instead of dumping the whole section
([#333](https://github.com/amirhs1/CareerDossierTeX/issues/333),
[#340](https://github.com/amirhs1/CareerDossierTeX/issues/340)). Because a list must know its own
length before it is typeset, each list records that count in the auxiliary
file — so a résumé or CV needs the same second LaTeX pass it already requires
for the `Page N of M` folio. On a first clean pass the breaks are provisional.

#### `\CDossierSubsectionNeedLines`

The same bound for `\CDossierSubsection`, defaulting to `3`. It is smaller than
`\CDossierSectionNeedLines` because a subsection commits less to the page: its
own heading line and the two lines of the first entry heading, with no rule
between them. It does not additionally require that entry's first line of body,
because the entry heading already carries its own keep down to it.

```latex
\int_set:Nn \CDossierSubsectionNeedLines { 4 }
```

A subsection that opens its section directly is exempt from this bound. The
section's own four-line requirement already placed that material, and testing it
a second time could only break the page between a section heading and the
subsection immediately under it — the stranded heading the bound exists to
prevent ([#337](https://github.com/amirhs1/CareerDossierTeX/issues/337)).

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

That `\raggedbottom` is inherited rather than set here (#335). It comes from
`article.cls`, which issues it only for a one-side, one-column document and
selects `\flushbottom` otherwise, so the four classes hold it only because each
loads `article` that way. Under `\flushbottom` the short pages these penalties
produce would be stretched to the full text height, or reported as
`Underfull \vbox`, instead of ending in white space. The four
`tokens-*-defaults` regression baselines therefore record the effective
bottom-fill state of each class, so a class that later took `twoside` or
`twocolumn` fails a baseline rather than changing the page silently.

These two tokens are **booleans, not dials** (#342). Under `\raggedbottom` a page
being built carries no stretch, so every break candidate short of the goal scores
badness `10000` — `inf_bad` — and cost `deplorable`. All candidates tie, the page
builder keeps the last one that fits, and the penalty's magnitude never enters
the comparison. Only `p >= 10000` changes anything, by removing the breakpoint
from consideration altogether. Measured across every letter and statement fixture
at `10000, 4000, 1000, 300, 150, 50, 0`, the results form a step function with a
single step: `9999` paginates identically to `0`. Setting either token to a
"discounted" value does not soften the rule, it switches it off — which is why
`4000` behaved exactly like `0` and let a club line through.

The cost of that rule was measured rather than assumed, and accepted. Forbidding
these breaks leaves 13.1% of page one blank on `statement-two-page`, against 2.4%
and 3.1% on the two letter fixtures that move at all; permitting them closes
those holes to 1.4%, 0.1% and 0.5%. But the correspondence is one-to-one — each
of the three fixtures that gains fill gains a club or widow line, and no fixture
gains fill without one. There is no value, and no per-family split, that buys the
space without the defect, so the toolkit keeps the space.

The mechanism that would make the rule conditional — fill the page unless doing
so strands a line — was then built and measured, and declined (#351). It needs
no new token: giving `\topskip` a `plus` component, as plain TeX's own
`\raggedbottom` does, makes page badness finite and these two values a real dial,
with no visible change to the page. It is declined because the dial prices the
guarantee rather than keeping it — the recovered fill is still bought one-for-one
with a stranded line — and because the same tolerance makes LaTeX's `-300`
`\@secpenalty` live, which moves breaks earlier and costs two shipped examples
11.8 points of page-one fill. On the eleven shipped examples this rule costs
nothing measurable at all: permitting the break everywhere leaves each of them
byte-identical. `docs/ARCHITECTURE.md` holds the measurements; the
`tokens-*-defaults` baselines now record `\topskip` and `\@secpenalty` so the
state the decision rests on cannot change unnoticed.

The letter and statement classes otherwise remain continuous prose with no
further structural page-break policy.

### Hyphenation

`\hyphenpenalty` and `\exhyphenpenalty` keep TeX's defaults of `50` in all four
families. No token sets them, and that is a decision rather than an omission
(#309) — the four `tokens-*-defaults` regression baselines record both values,
so a change to either is visible in review.

Raising the penalty was measured and rejected. Almost all of the hyphenation in
the committed examples is in the statements, which are continuous prose and the
setting TeX's default was calibrated for; the whole committed résumé has one
hyphenated line end, and raising the penalty does not remove it. Across the
examples, `\hyphenpenalty=500` removes 18 hyphens and creates 10 lines looser
than badness 99 — roughly a one-for-one trade, paid to fix a problem the record
classes do not have. Forbidding hyphenation entirely (`10000`) produces overfull
boxes and a worst-case line badness of 2452.
[`ARCHITECTURE.md`](ARCHITECTURE.md) records the full measurement.

A document that wants different behavior can set either parameter in its
preamble; both are ordinary TeX parameters and nothing in the toolkit overrides
them.

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

Expandability is what makes it the correct choice anywhere the value is written into the PDF rather than onto the page — a heading's recorded title, or any other PDF string. Such values are purified first, and purification expands what it can and discards what it cannot: `\CDossierPrintField` is protected, so it does not survive as a value but its argument text does, which records a plausible wrong string rather than failing. Nothing on the rendered page reveals that.

## Hyperlink behavior

When present:

- `email` should use a `mailto:` link;
- `website`, `linkedin`, `github`, and `scholar` should use web links;
- printed text should remain readable in monochrome;
- URLs should be breakable rather than extending beyond the margin.

The class must not assume that a displayed URL includes a protocol. The implementation should normalize links or clearly document the required input format.

Those fields cover the contact line. A link written into body text is
[`\CDossierLink`](#cdossierlink); plain text and `\url` both fail on a long
address, in different ways.

### Without `hyperref`

Every link the toolkit emits — the contact fields above, `\CDossierLink`, the
ORCID iD, and the CV's manual publication identifiers — is emitted only when
`hyperref` has supplied `\href`. Without it each one degrades to its visible
address as plain text, so the identifier stays readable, selectable, and
extractable; nothing in the PDF is clickable.

All four classes load `hyperref`, so a document built on one of them is never in
this state. It is reachable by loading `careerdossier-components` into another
class, and there the degradation is otherwise invisible: the page looks
finished. The package therefore warns once per document, at the first link that
degrades, naming the cause and the effect:

```text
Package careerdossier-components Warning: Links are typeset as plain text
because hyperref is not loaded.
```

Once, not once per field — a contact line with five linked fields, or a
publication list with twenty identifiers, has a single cause. Load `hyperref`,
or use one of the supplied classes, to silence it. Nothing about what is
typeset changes either way.

Introduced in `v0.8.0`
([#329](https://github.com/amirhs1/CareerDossierTeX/issues/329)).

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
[`MIGRATION.md`](MIGRATION.md#080---2026-08-12).

A second such role, `\CDossierLinkStyle{<text>}`, is published by
`careerdossier-components` for the same reason: it resolves to a rule, and the
decision to draw it belongs to `medium`, which that package owns. It is what
decorates author-written `\href` anchor text under `medium=screen`, and it is
the identity under `medium=print` and inside `\CDossierPlainLinks`. A document
that wants a different affordance — a different weight, a different rule
position — redefines this one command. See [`medium`](#medium).

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
  muted=plain
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
| `muted` | `italic`, `gray`, `both`, `plain` | `plain` |

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
a complete URL is used as supplied. Since `v0.8.0` the value is checked against
the shape of an ORCID iD when it is recorded, and warns when it does not match;
see [Accepted `orcid` values](#accepted-orcid-values). ORCID is the one
web-profile key whose displayed text stays the bare identifier: its label
supplies the meaning that the other three take from the domain, so it does not
adopt the canonical-address display described under
[Accepted forms for the web-profile keys](#accepted-forms-for-the-web-profile-keys).
Scholar and ORCID are omitted independently when blank and must not leave
separators, blank lines, or icon-only content.

#### Accepted `orcid` values

An ORCID iD is sixteen digits in four hyphen-separated groups whose final
character is a digit or `X`. Since `v0.8.0` the value is checked against that
shape when `\CDossierSetup` records it, and a value matching neither the shape
nor an ORCID address raises the `orcid-shape` warning naming the value and the
expected form:

| Written | Result |
|---|---|
| `0000-0002-1825-0097` | accepted |
| `0000-0002-1825-009X` | accepted — `X` is the documented checksum character |
| `orcid.org/0000-0002-1825-0097` | accepted |
| `https://orcid.org/0000-0002-1825-0097` | accepted |
| `0000-0002-1825-009` | warns — too short |
| `0000-0002-1825-009X7` | warns — too long |
| `https://example.org/ada-lovelace` | warns — not an ORCID address |
| `scholar.google.com/citations?user=example` | warns — a value in the wrong key |

An optional `www.`, a lowercase `x` checksum character, and one trailing slash
are accepted without a warning; they resolve, and warning about a working value
would only teach authors to ignore the warning that matters.

The check never stops the build, and nothing about the stored value, the link
target, or the `ORCID:` label depends on its outcome — an author holding an
identifier this check does not anticipate still gets exactly the document they
wrote. The warning is a shape check only: it does not verify the ISO 7064
checksum, and it cannot tell whether an iD is registered, since LaTeX has no
network access.

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

`\CDossierPublication` takes these keys:

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

#### Numbering across grouped lists

The environment itself takes one optional key:

| Key | Values | Default | Purpose |
|---|---|---|---|
| `numbering` | `restart`, `continue` | `restart` | Whether this list numbers from 1 or carries on from the previous list |

Each list is self-contained by default, so a section that carries several groups
numbers each group from `1)`:

```latex
\CDossierSection{Selected Publications}
\CDossierSubsection{Journal Articles}
\begin{CDossierPublications} ... \end{CDossierPublications}   % 1) 2) 3)
\CDossierSubsection{Conference Papers}
\begin{CDossierPublications} ... \end{CDossierPublications}   % 1) 2)
```

That reads correctly when a number is cited together with its group — "journal
article 1". A document whose numbers are cited on their own, from a cover letter
or a grant form, wants one sequence across the whole document instead, and asks
for it per list:

```latex
\CDossierSubsection{Conference Papers}
\begin{CDossierPublications}[numbering = continue] ... \end{CDossierPublications}   % 4) 5)
```

`continue` resumes from the final number of the **preceding** list, wherever
that list was: a subsection heading and a section rule are equally invisible to
it, since the sequence belongs to the document rather than to the heading above
it. A `restart` list in between therefore resets what a later `continue` picks
up. Setting `numbering` on the first list of a document has no effect under
either value, and a document with a single publication list renders identically
whether it sets the key or not.

Both values behave the same under `\DocumentMetadata{tagging=on}`: the number a
consumer reads from the structure tree is the number on the page.

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

URLs printed in a bibliography carry no stretch at their break points, so a
justified line ending in a URL spreads its word spaces rather than the URL
itself. A stretched URL extracts as separate tokens
(`https : / / example . invalid /`) and is then neither searchable nor
copyable. A reduced stretch was used until v0.8.0 and only narrowed the
failure — TeX exceeds a stated stretch to set an otherwise underfull line, and
a 262-character query-string URL was long enough to make it do so. Rigid glue
rules it out instead, at any measure or URL length.

Rigid glue leaves a line no way to absorb a shortfall, so the profile also
enables BibLaTeX's three URL break penalties, which are disabled by default:
without them a long URL overruns the margin rather than spreading. Two visible
results follow, both intended. A URL breaks where the line ends rather than at
the nearest earlier punctuation, so an address may wrap in the middle of a run
of letters or digits; and a line holding nothing but URL is set ragged-right
and reported underfull, since it has no glue to justify with. A wrapped address
still concatenates back exactly — these break points insert a penalty and no
discretionary hyphen, as `\CDossierLink`'s do.

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
  muted=plain
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

Both names match the résumé and the CV, so one profile's documents are written
the same way. (`\CDossierSubsection` was the statement's alone until `v0.8.0`;
the record classes gained it in
[#337](https://github.com/amirhs1/CareerDossierTeX/issues/337).) Here they are
wrappers over standard LaTeX `\section*` and `\subsection*`; both spellings
remain supported and render identically, because there is one renderer.

The rhythm is this class's own. A statement separates its paragraphs by a
visible `\CDossierProseParSkip`, so its heading gaps are calibrated against that
and use the `\CDossierProse…` tokens rather than the record classes'
`\CDossierRecord…` ones. The two families are not interchangeable.

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
| Record (résumé, CV) | `\CDossierRecordHeaderBelowSkip`, `\CDossierRecordSectionAboveSkip`, `\CDossierRecordSectionRuleGapSkip`, `\CDossierRecordSectionBelowSkip`, `\CDossierRecordSubsectionAboveSkip`, `\CDossierRecordSubsectionBelowSkip`, `\CDossierRecordEntryAboveSkip`, `\CDossierRecordEntryGapSkip`, `\CDossierRecordListEdgeAboveSkip`, `\CDossierRecordListEdgeBelowSkip`, `\CDossierRecordItemSepSkip`, `\CDossierRecordParSkip` |
| Prose (statement) | `\CDossierProseHeaderBelowSkip`, `\CDossierProseSectionAboveSkip`, `\CDossierProseSectionBelowSkip`, `\CDossierProseSubsectionAboveSkip`, `\CDossierProseSubsectionBelowSkip`, `\CDossierProseParSkip` |
| Letter | `\CDossierLetterHeaderBelowSkip`, `\CDossierLetterParSkip`, `\CDossierLetterRecipientLineGapSkip`, `\CDossierLetterBlockSkip`, `\CDossierLetterBodyAboveSkip`, `\CDossierLetterBodyBelowSkip`, `\CDossierLetterSignatureGapSkip` |

Only the two gaps *inside* the header block are shared; the gap *below* it is
owned by one token per family. All three ship at the same ratio, so setting all
three reproduces the single shared token the families were split out of, and
setting one moves only that family.

Two rules govern how a token reaches the page, and overriding a token without
them in mind is the usual reason an override appears to do nothing. Both are
derived, together with the per-family split above, under
[“Boundary ownership” in `ARCHITECTURE.md`](ARCHITECTURE.md#boundary-ownership);
what an author needs from them is:

- **Boundaries compose with `\addvspace`, which takes the maximum of the
  adjacent claims and never their sum.** Raising a token past its neighbour is
  what makes it visible; lowering it below its neighbour makes it inert, and
  neither the output nor the log will say so. `\CDossierRecordEntryGapSkip` in
  particular is a *floor* for the entry heading → body boundary, which a bullet
  list overrides with `\CDossierRecordListEdgeAboveSkip`.
- **One token also carries a constraint from outside the type scale.**
  `\CDossierRecordListEdgeAboveSkip` may not go below `0.25` without breaking
  the extraction order of the entry heading's dates column, as described under
  [`CDossierItemize`](#cdossieritemize).
- **A paragraph boundary also contributes `\parskip`, and the class has already
  accounted for it.** Where a token sits at such a boundary the class emits it
  as `token − \parskip`, so the value you set is still the gap a reader
  measures — do not subtract the paragraph gap yourself. The header block
  zeroes `\parskip` for its own scope, which is why the two shared header gap
  tokens behave identically in all four classes. The boundary below the header
  block is outside that scope and reads the class's real `\parskip` instead
  (non-zero in the two prose classes), so it is subtracted explicitly there
  (#419) rather than by the zeroing.

Since `v0.7.0`, `\CDossierRecordHeaderBelowSkip`,
`\CDossierProseHeaderBelowSkip`, `\CDossierLetterHeaderBelowSkip`,
`\CDossierLetterParSkip`, `\CDossierLetterRecipientLineGapSkip`, and
`\CDossierLetterBodyBelowSkip` are new, and `\CDossierRecordEntryBelowSkip`,
`\CDossierLetterheadBelowSkip`, `\CDossierSharedHeaderAboveSkip`, and
`\CDossierSharedHeaderBelowSkip` are removed; see
[`MIGRATION.md`](MIGRATION.md#070---2026-08-04).

The calibrated *values* are not stable API before `v1.0.0`; the token names and
the boundaries they own are.

## Line-breaking tokens

```latex
\CDossierEmergencyStretch
```

`\CDossierEmergencyStretch` is the extra flexibility TeX may distribute among a
paragraph's interword glue when it can find no set of breakpoints within
`\tolerance`. It is `2.00 ×` the body size — 20 pt, 22 pt, and 24 pt at
`fontsize=10pt`, `11pt`, and `12pt` — and it derives from the body size rather
than the body leading because the quantity is horizontal.

It does not scale with the measure, and deliberately so. Deriving it from
`\linewidth` instead was measured and rejected: the pool a paragraph needs turns
out to track neither quantity, because it is decided by where that paragraph's
break points happen to fall, and the two forms then produce identical
overfull-box counts wherever their magnitudes match. Keeping the token on the
type scale, alongside `\CDossierRuleThickness` and `\CDossierListLabelSep`, is
what settles it. [`ARCHITECTURE.md`](ARCHITECTURE.md) records the measurement.

All four classes set `\emergencystretch` from it, unconditionally and
identically: one policy, stated once. Raising it lets a paragraph with few break
points set looser instead of overfull; lowering it to `0pt` restores TeX's
default behavior, which is to allow the overfull box. Neither direction affects
a paragraph that already sets within `\tolerance`, because `\emergencystretch`
is consulted only in a third line-breaking pass that such a paragraph never
reaches.

Before `v0.8.0` the letter and the statement each set `2em` directly, the CV set
it only at `a4paper`, and the résumé set nothing; see
[`CHANGELOG.md`](../CHANGELOG.md).

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
`muted=both` render de-emphasised runs in; under `muted=plain` (the default) or
`muted=italic` nothing uses it.

`\CDossierPrimaryColor` was removed: it reached no component, class, or
example, and its underlying color was `gray 0` — the same value as
`\CDossierTextColor` under a different name. See
[`docs/MIGRATION.md`](MIGRATION.md#080---2026-08-12).

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
- an unknown manual-publication, publication-list, or preferred-author key;
- an unsupported `numbering` value on `CDossierPublications`;
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
- an `orcid` value that does not have the shape of an ORCID iD, see
  [Accepted `orcid` values](#accepted-orcid-values);
- metadata overwritten by a later setup call;
- fields accepted but not displayed by the active class; and
- links degraded to plain text because `hyperref` is absent — once per
  document, see [Without `hyperref`](#without-hyperref).

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
