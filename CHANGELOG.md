# Changelog

All notable changes to CareerDossierTeX will be documented in this file.

The project follows [Semantic Versioning](https://semver.org/). The structure of this file is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Before `v1.0.0`, breaking changes may occur, but they must be documented here and in `docs/MIGRATION.md`.

## [Unreleased]

### Changed

- **BREAKING (design token):** `\CDossierListEdgeSkip` is now two tokens,
  `\CDossierListEdgeSkipBefore` for the space above a list and
  `\CDossierListEdgeSkipAfter` for the space below it, so the two ends of a
  bullet or publication list can be tuned independently. LaTeX has a single
  `topsep` and spends it at both ends, so one token could not express a
  different value above and below. ([#191])

  Both tokens keep the value the single token had, so no document reflows:
  every list in every class renders exactly as in `v0.6.0` at every `fontsize`.
  Retuning either ratio is deliberately left to a separate change. Only source
  that reads or sets the old token by name needs an edit — read
  `\CDossierListEdgeSkipBefore` wherever `\CDossierListEdgeSkip` appeared. No
  class, option, key, command, or environment changed. See
  [`docs/MIGRATION.md`](docs/MIGRATION.md).

  One path is unaffected by the new token: under
  `\DocumentMetadata{tagging=on}` the space below a list comes from LaTeX Lab's
  own list implementation rather than from `\CDossierListEdgeSkipAfter`. That
  is pre-existing behavior, not a change in this release.

- The smoke and layout-stress suites now run as their own CI jobs instead of
  running in sequence inside the `resume` job, so they start in parallel with
  the rest of the workflow. Coverage and the commands themselves are unchanged;
  their CI artifacts moved out of `resume-artifacts` into the new
  `smoke-artifacts` and `layout-artifacts`. ([#188])

### Fixed

- The running header and the `Page N of M` folio now sit in the vertical centre
  of the top and bottom margins at every `fontsize` and `margin` combination and
  on both paper sizes. They were positioned by `geometry`'s untouched defaults —
  a 12 pt head box 25 pt above the text and a 30 pt foot skip, identical at all
  six combinations — rather than by the selected preset. At `margin=narrow` that
  left the header effectively touching the top edge of the paper and the folio
  about 6 pt (0.09 in) from the bottom edge, inside the unprintable region of
  most printers. Their placement is now derived from the resolved margin and the
  furniture step of the type scale, like every other dimension in the design
  system.

  This moves only the furniture within the existing margins. `\textheight` and
  `\textwidth` are byte-identical to `v0.6.0` at every combination, so the body
  text does not move and pagination is unchanged; no class, option, key, or
  command changed. Documents that print the folio close to the trim edge will
  show it further inside the page. ([#183])

[#183]: https://github.com/amirhs1/CareerDossierTeX/issues/183
[#188]: https://github.com/amirhs1/CareerDossierTeX/issues/188
[#191]: https://github.com/amirhs1/CareerDossierTeX/issues/191

## [0.6.0] - 2026-07-30

### Added

- Added `careerdossier-tokens`, the shared source of truth for the 10 pt,
  11 pt, and 12 pt type scales, baseline-derived vertical rhythm, rule and
  flush-left list metrics, and `margin=normal|narrow` geometry presets. All
  four classes accept the same `fontsize` and `margin` values; advanced users
  may call `\geometry{...}` after the class for an untested custom layout
  without reloading the package. Optional fields and separator behavior are
  unchanged. ([#138])

- Added `\CDossierSection` and `\CDossierSubsection` to the statement class,
  giving a statement the same heading command name the résumé and CV already
  use, so documents built from one profile are written the same way. Each is a
  wrapper over the standard LaTeX unnumbered heading it replaces — `\section*`
  and `\subsection*` — which both remain supported and render identically.
  Existing statements need no source edit. ([#177])

### Changed

- The shared baseline-derived spacing tokens now use a compact
  one-sixteenth-line vocabulary. Résumé and CV entry/list grouping, statement
  and letter block spacing, identity headers, section rules, and signature
  space are retuned together; document commands, options, fields, and
  extraction order are unchanged. Existing documents may reflow and should
  have their pagination reviewed. ([#166])

- **BREAKING (layout defaults):** The résumé now defaults to
  `fontsize=11pt,margin=narrow`; the CV, letter, and statement classes default
  to `fontsize=12pt,margin=normal`. `normal` is one inch and `narrow` is half
  an inch. Existing documents may reflow and should have their pagination
  reviewed after upgrading. ([#138], [#141], [#142])

- The shared résumé, CV, and letter identity block now scales its name,
  headline, contact text, and vertical gaps from the calibrated `fontsize`
  tokens. Its outer spacing is project-owned rather than inherited from
  LaTeX's `center` environment, while field order, optional-field behavior,
  contact separators, and extracted reading order remain unchanged. ([#139])

- All four document classes now use one component-owned page-furniture design.
  One-page documents suppress the folio entirely; multi-page documents show a
  centered `Page N of M` throughout and a centered name/document label from
  page two. The résumé and industry letter now gain continuation furniture,
  while the CV, academic letter, and statement no longer print `Page 1 of 1`.
  Furniture uses the calibrated sans-serif size and remains a tagged layout
  artifact. ([#140])

- The résumé and CV classes now derive section, entry, rule, and bullet-list
  metrics from the calibrated type and rhythm tokens. The CV's dependency-free
  manual-publication list also uses the shared list spacing and label
  separation. Section headings contribute their intended section leading to
  the page. Existing profile fields, optional-field separators, extracted
  reading order, and the CV's optional BibLaTeX boundary are unchanged.
  ([#141], [#142])

- **BREAKING (letter layout):** The industry and academic letter families now
  share the same token-derived geometry and prose rhythm. Letterhead blocks,
  salutation spacing, paragraph gaps, and signature space scale with
  `fontsize`; `family=academic` is label- and metadata-only rather than a
  layout selector. Optional recipient and subject blocks still collapse
  without stray gaps, and both families use the shared multi-page furniture.
  Existing letters may reflow and should have their pagination reviewed.
  ([#143])

- **BREAKING (statement layout):** Statement headers and prose now use the
  calibrated type and rhythm tokens. The name, full title, subtitle,
  affiliation, application context, contacts, header gaps, and paragraph gaps
  scale with `fontsize`; in particular, the name is no longer fixed at LaTeX's
  24.88 pt `\Huge` size. The seven type contracts, short continuation titles,
  PDF metadata, required fields, contact sets, and optional-field separators
  are unchanged. Existing statements may reflow and should have their
  pagination reviewed. ([#144])

- The résumé and CV classes now apply a stated page-break policy instead of
  leaving every break to LaTeX's defaults. A section heading stays with the
  entry it introduces, an entry heading stays with its own second line and
  with the first line of its body, and a bullet list is never split so that a
  single item stands alone on either side of a break. The letter and statement
  classes are continuous prose and keep ordinary widow and orphan handling.

  The policy uses page-break penalties rather than boxing, so material that
  genuinely does not fit still breaks: an entry or a bullet list longer than a
  page paginates normally instead of overflowing. Because a list must know its
  own length before it is typeset, each list records that count in the
  auxiliary file, so résumé and CV documents need the second LaTeX pass they
  already require for the `Page N of M` folio. This changes pagination in
  documents that break across pages; no class, option, key, or command
  changed. ([#145])

### Fixed

- Statement section headings now belong to the calibrated design system. They
  were `article`'s: `\Large` — 17.28 pt at the class's 12 pt default, outside
  the documented type scale, where a section heading is 13 pt — set in whichever
  family `bodyfont` selected, so a serif statement had serif headings while
  every other class used the sans heading role, and spaced by `article`'s own
  display skips, which left 26.15 pt above a heading and 19.67 pt below it: near
  enough to equal that the heading read as floating between two paragraphs
  rather than labelling the one under it. Headings now use the shared sans
  heading role, the `\CDossierSizeSection` and `\CDossierSizeBody` steps, and
  four new prose heading tokens — `\CDossierProseSectionAboveSkip` (1.50 line),
  `\CDossierProseSectionBelowSkip` (0.75), and the subsection pair (1.00 and
  0.625) — giving 21.75 pt and 10.875 pt at the same body size. Each token is
  the complete gap, including the paragraph spacing either side of a heading
  contributes, which the ruled section tokens could not express in a class whose
  paragraphs are themselves separated. A statement heading carries no decorative
  rule: that rule is entry-structured section furniture. The heading is restyled
  through LaTeX's own sectioning machinery rather than replaced by a new one, so
  a tagged statement keeps the section division and heading title the kernel
  produces. Numbered sectioning and levels below `\subsection` are untouched and
  remain outside the calibrated design. No public command, class option, key, or
  field changes; existing statements may reflow and should have their pagination
  reviewed. ([#177])

- A résumé, CV, letter, or statement page break could split a hyphenated word
  across pages or strand a single line of a paragraph alone at the foot of one
  page or the head of the next, because `\brokenpenalty`, `\clubpenalty`, and
  `\widowpenalty` were left at LaTeX's defaults (`100`, `150`, and `150`) while
  the structural keep-together policy above ([#145]) covered only headings and
  lists. All four classes now call `\CDossierApplyPageBreakPenalties`, which
  sets these from the named tokens `\CDossierBrokenPenalty`,
  `\CDossierClubPenalty`, and `\CDossierWidowPenalty` (`careerdossier-tokens.sty`),
  each defaulting to `10000` — forbidding the break — because every class is
  `\raggedbottom`, so forbidding it only removes a paragraph's first and last
  line as break points and cannot overflow a page. No token value, public
  command, or option is added beyond the three penalty tokens; existing
  documents may reflow and should have their pagination reviewed. ([#171])

- A bullet whose text fills the line no longer inflates the spacing that follows
  it. The space produced by the newline before `\end{CDossierItemize}` was
  carried onto a line of its own when the final item's last line already filled
  the measure. Nothing was visible, but the empty line hid the preceding spacing
  from the gap that came next, so the following section heading was pushed down
  by a whole line — 27.84 pt instead of 14.28 pt in the shipped default résumé,
  where one bullet happens to land on the boundary. Only the last item of a list
  was affected; entry bodies, section prose, and the letter and statement classes
  were checked across 32 text lengths each and are not. No token value, public
  command, option, or default changes; existing documents may reflow. ([#170])

- The section rule in a résumé or CV now sits a fixed distance below its
  heading's baseline, so its height no longer follows the heading's glyphs. The
  offset was previously measured from the bottom of the heading's line box, which
  is as deep as its deepest glyph, so the rule dropped further under a heading
  containing a descender than under one without — 4.80 pt versus 2.28 pt at
  11 pt, a visible swing within a single document.
  `\CDossierSectionRuleSkip` now means baseline-to-rule and rises from `0.15` to
  `0.3125` line, the token's smallest value on the calibrated grid that keeps the
  rule clear of descender ink at every supported body size. Rule thickness and
  colour, public commands, page geometry, reading order, and tagged
  layout-artifact treatment are unchanged; existing documents may reflow and
  should have their pagination reviewed. ([#169])

- The rule-to-content gap in a résumé or CV section is now the value
  `\CDossierSectionBelowSkip` declares, whichever kind of content opens the
  section. The gap previously depended on what followed the rule: a section
  opening with an entry or a bullet list received that token *plus* the block's
  own leading space, so one document could show the same boundary at up to three
  different sizes and a section heading read as almost equidistant between the
  block above it and the block it labels. Spacing now collapses the way LaTeX
  composes vertical space, taking the larger of the two values rather than their
  sum. Token values, rule thickness and colour, public commands, page geometry,
  reading order, and tagged layout-artifact treatment are unchanged; existing
  documents may reflow and should have their pagination reviewed. ([#168])

- `\CDossierListEdgeSkip` now determines the complete gap between a bullet or
  publication list and the content above it, at every body size. LaTeX added
  3 pt of its own whenever such a list opened a new paragraph, so the real
  gap was the token plus a constant that no token owned and that did not rescale
  — proportionally wider at `10pt` than at `12pt`. The lists now suppress that
  constant and the token's ratio absorbs it, so the rendered edge is materially
  the one the calibrated rhythm already produced (3.75 pt, 4.25 pt, and 4.53 pt
  at the three body sizes, against 4.5 pt, 4.7 pt, and 4.81 pt before) and the
  whole of it now scales with `fontsize`. Public commands, options, fields,
  optional-field separators, and reading order are unchanged; documents with
  many lists may reflow slightly and should have their pagination reviewed.
  ([#176])

- The résumé and CV section-rule spacing tokens now determine the complete
  heading-to-rule and rule-to-content gaps. The decorative rule previously
  occupied its own paragraph line, which added hidden baseline spacing even
  when all three section skips were set to zero. The existing proportional
  values, rule thickness and colour, public commands, extraction order, and
  tagged layout-artifact treatment are unchanged. ([#164])

- Contact separators now disappear when the contact paragraph wraps between
  fields, so no visual line begins or ends with `|`. Every contact item remains
  intact on one visual line; if an item is wider than the available line, the
  package stops with a field-specific error rather than splitting it or
  producing knowingly overfull output. Fixed field and extraction order, link
  targets, tagged artifact treatment, and the rule that missing fields leave
  no stray separators are preserved. ([#151])

- In tagged output, contact labels and unlinked contact values (phone and
  location) were emitted as layout artifacts rather than content, hiding them
  from assistive technology even though they display normally and extract
  normally. Introduced by the separator-wrapping fix above ([#151]) and never
  reached a release; contact labels and unlinked values are content again.
  ([#161])

### Removed

- **BREAKING (résumé and CV options):** Removed
  `density=compact|standard` from `careerdossier-resume` and
  `careerdossier-cv`. Their rhythm now scales from `fontsize`; remove the old
  option and use `fontsize` plus `margin` to select the layout. ([#141],
  [#142])

[#138]: https://github.com/amirhs1/CareerDossierTeX/issues/138
[#139]: https://github.com/amirhs1/CareerDossierTeX/issues/139
[#140]: https://github.com/amirhs1/CareerDossierTeX/issues/140
[#141]: https://github.com/amirhs1/CareerDossierTeX/issues/141
[#142]: https://github.com/amirhs1/CareerDossierTeX/issues/142
[#143]: https://github.com/amirhs1/CareerDossierTeX/issues/143
[#144]: https://github.com/amirhs1/CareerDossierTeX/issues/144
[#145]: https://github.com/amirhs1/CareerDossierTeX/issues/145
[#151]: https://github.com/amirhs1/CareerDossierTeX/issues/151
[#161]: https://github.com/amirhs1/CareerDossierTeX/issues/161
[#164]: https://github.com/amirhs1/CareerDossierTeX/issues/164
[#166]: https://github.com/amirhs1/CareerDossierTeX/issues/166
[#168]: https://github.com/amirhs1/CareerDossierTeX/issues/168
[#169]: https://github.com/amirhs1/CareerDossierTeX/issues/169
[#170]: https://github.com/amirhs1/CareerDossierTeX/issues/170
[#171]: https://github.com/amirhs1/CareerDossierTeX/issues/171
[#176]: https://github.com/amirhs1/CareerDossierTeX/issues/176
[#177]: https://github.com/amirhs1/CareerDossierTeX/issues/177

## [0.5.0] - 2026-07-24

### Added

- Added an opt-in `contact-labels` key to `\CDossierSetup`. When enabled, the
  contact line prefixes `Email:`, `Phone:`, and `Website:` text labels to
  those fields in every document class, so each field's nature is stated in
  the visible text itself rather than left to inference from format and
  position — the gap that motivated the change: assistive technology announces
  the email and website as links, but a phone number is otherwise read as
  unidentified digits. Because the label is ordinary visible text, it is
  present in the default untagged output and verified to survive plain-text
  extraction. The remaining contacts stay unlabelled because their values
  identify themselves (service-domain URLs, the permanent `ORCID:` label,
  place-name locations). The default rendering is unchanged, labels are fixed
  English strings, and an absent field leaves no orphan label or stray
  separator. Regression and extraction fixtures pin both the labelled and
  unlabelled forms. ([#95])

- Added a consistent `bodyfont=serif|sans` class option to the résumé, CV,
  industry and academic letters, and statement documents. `serif` remains the
  default and preserves the existing TeX Gyre Termes body with TeX Gyre Heros
  headings; `sans` uses TeX Gyre Heros for both body and headings without
  changing sizes, spacing, geometry, semantic roles, or page furniture. Both
  families resolve through exact TeX Live files, provide explicit upright,
  bold, italic, and bold-italic faces, and were tested at version 2.004 under
  the GUST Font License. Focused regression, smoke, extraction, and tagged-build
  fixtures cover selection and invalid values. Existing optional-field and
  separator behavior is unchanged. ([#119])

- Added opt-in A4 paper to the résumé, industry and academic letters, academic
  CV, and the statement class through one consistent
  `paper=letter|a4` class option. US Letter remains the default, and both paper
  sizes keep each class's established physical margins, typography, spacing,
  and page-furniture design. A4 layout fixtures verify the media box, long-form
  wrapping, multi-page flow, folios, and continuation headers across every
  document family. Existing optional-field and separator behavior is
  unchanged. ([#105])

- Added `careerdossier-statement`, one LuaLaTeX class with a default
  interest type plus research, teaching, teaching-philosophy, diversity,
  artist, and statement-of-purpose documents. The optional `type` option
  selects the default full and running titles plus the relevant contact and
  validation contract; `\CDossierStatementSetup` adds
  optional subtitle, application-context, and application-ID metadata. The
  centered first-page identity block uses the academic-letter typography,
  margins, and prose rhythm, while continuation pages carry a short running
  title and every page carries `Page N of M`. Six two-page examples and focused
  smoke, layout, extraction, and tagged-PDF fixtures cover the new interface.

  The additive shared-profile `affiliation` key is required for research
  statements and optional elsewhere; artist statements require the existing
  `website` field. Optional metadata and contacts collapse without blank lines
  or stray separators. Existing résumé, CV, and letter interfaces and defaults
  are unchanged. ([#104])

### Changed

- PDF/UA-2 validation with veraPDF now runs in continuous integration on a
  weekly schedule, where it previously ran only locally. A new
  `verapdf-scheduled` workflow builds veraPDF from a pinned upstream commit and
  runs the tagged-PDF suite's UA-2 gate against the five named fixtures,
  retaining the reports as artifacts. The per-push `tagging` job still skips the
  veraPDF gate — building the validator from source is too costly to run on
  every pull request — and continues to name it in its `GATES NOT RUN` summary,
  so a routine CI pass is still not mistaken for a validated one. No package,
  class, option, key, command, or rendered output changed. ([#94])

### Fixed

- Statements now default to `type=interest` when `type` is omitted. The default
  title and continuation header read `Statement of Interest`, and this general
  contract requires only `name` and `email`. The distinct `purpose` type remains
  supported. The unreleased `general-interest` spelling was removed rather than
  retained as an alias, so no released document needs migration. Other explicit
  statement types and their validation remain unchanged. ([#117], [#128])

[#94]: https://github.com/amirhs1/CareerDossierTeX/issues/94
[#95]: https://github.com/amirhs1/CareerDossierTeX/issues/95
[#104]: https://github.com/amirhs1/CareerDossierTeX/issues/104
[#105]: https://github.com/amirhs1/CareerDossierTeX/issues/105
[#117]: https://github.com/amirhs1/CareerDossierTeX/issues/117
[#119]: https://github.com/amirhs1/CareerDossierTeX/issues/119
[#128]: https://github.com/amirhs1/CareerDossierTeX/issues/128

## [0.4.0] - 2026-07-20

**LuaLaTeX Transition and Tagged-PDF Preview.** A breaking toolchain change:
LuaLaTeX replaces XeLaTeX as the sole supported engine. The English public API
and visual design are preserved, apart from the academic CV and letter page
furniture noted below. Adds an opt-in tagged-PDF path validated for four named
fixtures. See [`docs/MIGRATION.md`](docs/MIGRATION.md) for the upgrade path.

### Changed

- **BREAKING (toolchain): LuaLaTeX replaces XeLaTeX as the sole supported
  engine.** Build commands change from `latexmk -xelatex` to
  `latexmk -lualatex`, and XeLaTeX or pdfLaTeX now stop with a fatal error from
  `careerdossier-typography` naming LuaLaTeX. There is no compatibility mode.

  No class, class option, profile key, public command, or environment changed.
  Paper size, monochrome theme, and page design are unchanged. A document
  without XeTeX-specific preamble code needs no edit beyond the build command.
  `docs/MIGRATION.md` gives the upgrade path, including editor and CI settings,
  `\XeTeXgenerateactualtext` removal, font-override checks, and pagination
  review. ([#75], [#76])

  LuaHBTeX writes real interword spaces into the text layer and supports the
  LaTeX kernel tagging pipeline; XeTeX supports neither. That limitation capped
  extraction reliability (see `0.2.1`) and blocked tagged output entirely.

- The academic CV folio now reads `Page N of M`, matching
  `careerdossier-letter`. It previously read `Page N`, which cannot tell a
  reader holding page two whether the document ended — the case that matters
  most for the printed and separated pages a multi-page CV produces. The total
  comes from the LaTeX kernel's last absolute page already recorded in the
  auxiliary file, so no total-page package is added and the value resolves on
  the second pass. Single-page CVs now read `Page 1 of 1`, as single-page
  academic letters already did.

  This changes rendered CV output. Documents are unaffected apart from the
  folio text; no class, option, key, or command changed. ([#91])

- The academic cover letter now shares `careerdossier-cv`'s page furniture, so
  the two multi-page academic documents read as one family. From page two it
  carries a centered running header — `<name> — Cover Letter`, matching the CV's
  `<name> — Curriculum Vitae` — and its folio is now a centered `Page N of M`
  that no longer repeats the name. Page one has no running header, as in the CV,
  because the letterhead already carries identity. ([#98])

  The name is not lost: it already appears in the letterhead and the signature
  block, so on a single-page letter the old footer was a third occurrence.

  The running header is a layout artifact — it does not enter the structure tree
  and screen readers do not announce it, verified by comparing the tagged
  structure tree before and after the change. `family=industry` is unaffected
  and keeps its `v0.1` empty page style.

  This changes rendered academic-letter output. No class, option, key, or
  command changed.

- Default fonts now resolve by file name through `luaotfload` (`texgyretermes`
  and `texgyreheros` with explicit faces) instead of by fontconfig family name.
  The build no longer depends on OS-installed fonts. Documents that override
  fonts with a system font name should recheck their logs for substitutions.

- The `Makefile`, `l3build` configuration, test runners, and CI workflow all
  build with LuaLaTeX. `make tagging` is a new suite and is included in
  `make check`. ([#76])

- CI gained a `tagging` job running the tagged-PDF suite on every push and pull
  request, installing `mupdf-tools` alongside `poppler-utils` so both
  command-line extractors run there. veraPDF is not installed in CI yet — that
  is a new third-party binary needing an approved immutable pin, so PDF/UA-2
  validation currently runs locally only and the job reports that gate as not
  run. ([#77])

### Added

- Opt-in tagged semantic structure under LuaLaTeX, enabled per document with
  `\DocumentMetadata{lang=en, tagging=on}` before `\documentclass`. Section
  headings, lists, paragraphs, and links are exposed as structure; decorative
  rules, contact separators, and running page furniture are marked as layout
  artifacts. ([#28])

  Tagging is **off by default** and introduces no class option or public
  command — the interface is the LaTeX kernel's. Documents that do not enable it
  produce byte-identical output to the untagged path.

  This is a tested preview for four fixture profiles (industry résumé, industry
  letter, academic CV, academic letter). Fixtures assert that a structure tree
  exists and check heading, list, link, and artifact classification, text
  extraction, and tagged-versus-untagged geometry. It is **not** a PDF/UA, WCAG,
  ATS, or general accessibility conformance claim, and it is not validated for
  arbitrary user documents. Independent validator and macOS screen-reader
  verification are recorded below; NVDA on Windows is tracked in [#96] and has
  not been performed.

- PDF/UA-2 validation and a three-extractor round-trip for the four tagged
  fixture profiles. Each profile gains a `-ua2.tex` variant that shares the
  tagged fixture's body and adds `pdfstandard=ua-2`; `make tagging` builds it,
  validates it with veraPDF, and compares Poppler, MuPDF, and Apple PDFKit
  extraction against committed per-extractor baselines. The run also writes a
  toolchain record, because a validation result is only meaningful alongside the
  versions that produced it. ([#77])

  All four profiles pass veraPDF `ua2`, and all three extractors agree with
  their baselines. Reports are retained as CI artifacts, never committed.
  Sections 7.1–7.3 of `docs/guides/ats-extraction.md` record the results, the
  exact toolchain, and what the result does and does not license.

  veraPDF, MuPDF, Biber, and PDFKit gates skip with a notice when the tool is
  unavailable, and the runner's closing summary names every gate that did not
  run, so a partial local environment cannot be mistaken for a full pass.

  **Screen-reader review: macOS done, Windows outstanding.** A VoiceOver pass on
  macOS 15.7.5 confirmed correct reading order across all four profiles, with
  every artifact-suppression check passing — the CV running header and folio and
  the academic letter's repeated footer are silent, and the contact line is
  announced as one coherent run. Results are recorded in section 7.2. NVDA on
  Windows has **not** been performed; it is a platform limitation tracked in
  [#96], and the release claims no Windows screen-reader result.

- A tagged-BibLaTeX feasibility fixture, recorded separately and deliberately
  non-blocking, since tagging support in BibLaTeX and Biber is upstream work.
  It currently builds and passes veraPDF `ua2` with genuine list structure per
  entry. Limitations — Biber and a multi-pass build, and the fact that a
  bibliography-only document renders zero pages and fails to build — are
  documented in section 7.3. Tagged BibLaTeX is **not** a supported `v0.4.0`
  feature. ([#77])

### Removed

- `\XeTeXgenerateactualtext` handling, along with the rest of the XeTeX-specific
  code path. The primitive does not exist under LuaTeX. ([#75])

[#28]: https://github.com/amirhs1/CareerDossierTeX/issues/28
[#75]: https://github.com/amirhs1/CareerDossierTeX/issues/75
[#76]: https://github.com/amirhs1/CareerDossierTeX/issues/76
[#77]: https://github.com/amirhs1/CareerDossierTeX/issues/77
[#82]: https://github.com/amirhs1/CareerDossierTeX/issues/82
[#98]: https://github.com/amirhs1/CareerDossierTeX/issues/98
[#91]: https://github.com/amirhs1/CareerDossierTeX/issues/91
[#96]: https://github.com/amirhs1/CareerDossierTeX/issues/96

## [0.2.1] - 2026-07-19

### Fixed

- Text extracted from CareerDossierTeX PDFs no longer merges adjacent words in
  PDFKit-based consumers — macOS Preview, Quick Look, Spotlight, Safari's PDF
  viewer, and ordinary copy/paste. `careerdossier-typography` had enabled
  `\XeTeXgenerateactualtext`, which wraps each word in its own `/ActualText`
  span with no space between spans; consumers that trust `/ActualText` over
  glyph geometry read `Research& Development` for `Research & Development`.
  The setting is now off. Rendered pages are unchanged, and Poppler
  (`pdftotext`) output is unchanged for the résumé, letter, and CV fixtures.
  This addresses the text layer only and is not a tagging, PDF/UA, WCAG, or
  ATS-conformance claim. ([#72])

  One extraction change is visible with the optional BibLaTeX integration.
  BibLaTeX sets its `doi` and `url` labels as lowercase text rendered in small
  capitals; `/ActualText` used to report the lowercase source, so extraction
  read `doi:` and `url:`. Without it, extraction reads the glyphs actually shown
  and reports `DOI:` and `URL:`. The visible page is identical, and the
  extracted form now matches both the printed capitalization and the
  conventional acronym, but Poppler-based tooling that matched the lowercase
  labels will need updating.

### Changed

- The extraction fixture suite now gates on three checks instead of one: the
  Poppler baseline, the absence of `/ActualText` spans in the PDF, and — on
  macOS — an Apple PDFKit baseline extracted through `PDFDocument.string`.
  Fixtures build uncompressed so the `/ActualText` check needs no tool beyond
  `grep`. The PDFKit check is skipped with a notice on other platforms.

[#72]: https://github.com/amirhs1/CareerDossierTeX/issues/72

## [0.2.0] - 2026-07-17

### Added

- `careerdossier-cv`: the English academic-CV class. It provides US
  Letter, monochrome, multi-page CV layout with `fontsize` (`10pt` or `11pt`;
  default `11pt`) and `density` (`compact` or `standard`; default `standard`).
  The first page uses the shared dossier header; subsequent pages carry a
  name-derived running header, and every page has a `Page n` folio. The class
  uses the existing section, entry, and list interface and does not load
  BibLaTeX or require Biber.
- Optional shared-profile `orcid` metadata. It renders as descriptive visible
  text and a link; bare identifiers resolve through `https://orcid.org/` while
  complete URLs retain their scheme. Academic profiles can therefore be shared
  with the existing résumé without leaving stray contact separators.
- A supported academic-CV example, shared academic profile, CV smoke and
  extraction fixtures, and long-field/two-page layout checks. CI and `make`
  now build the academic-CV example.
- `careerdossier-letter` now accepts `family=academic` for the
  academic cover-letter family. `industry` remains the default and existing
  letter metadata, optional recipient handling, and public commands are shared
  unchanged. Academic letters derive the PDF title `Academic Cover Letter –
  <name>` and carry a print-oriented footer with the name and `Page n of N`.
  A supported academic-letter example and its smoke, extraction, and layout
  coverage build through `make` and CI.
- Dependency-free manual publication lists through `CDossierPublications` and
  `\CDossierPublication`, with source-order numbering, clean optional-field
  punctuation, and DOI-over-URL link precedence.
- Optional `careerdossier-biblatex` integration with the fixed numeric,
  Biber-backed, year-descending academic profile; repeatable exact author-name
  highlighting; DOI → e-print → URL precedence; an actionable missing-package
  diagnostic; and a fictional Biber example built by `latexmk`, `make`, and CI.

### Changed

- The supported no-BibLaTeX academic-CV example now demonstrates manual
  publications. README, API, roadmap, contributor requirements, and build
  guidance now distinguish `v0.1.1` behavior from released `v0.2.0` support,
  map every academic interface to a complete example, document the Biber
  verification path, and state the release's explicit non-goals.

## [0.1.1] - 2026-07-17

### Added

- `AI-POLICY.md` and contribution guidance for disclosed, human-reviewed AI
  assistance; accurate non-duplicated commit attribution; prompt-injection
  handling; and licensing, provenance, privacy, and verification duties. Claude
  Code project settings now deny built-in read and edit access to declared
  private paths and enable sandbox enforcement for Bash when supported.
- PDF document metadata derived from the shared profile, applied automatically
  at `\begin{document}` by `careerdossier-components`. A résumé now carries
  `/Title` `Résumé – <name>`, a cover letter `Cover Letter – <name>`, both carry
  `/Author` `<name>`, and both declare `/Lang` `en`. Previously the classes set
  no PDF metadata at all, so viewers and file managers showed the filename
  instead of a title, and the document declared no language. The document type is
  part of the title so a résumé and a letter built from one profile stay
  distinguishable. Any field set with `\hypersetup` is left untouched, in either
  order relative to `\CDossierSetup`; fields left alone are still derived. When
  `name` is absent, `/Title` and `/Author` are omitted rather than raising a
  second error. See `docs/API.md`, "PDF document metadata".

### Changed

- The LPPL Work is now defined in one place by `manifest.txt`; each source
  file's licence notice refers to the manifest instead of naming itself as a
  separate Work. The licence (LPPL 1.3c), maintenance status, and maintainer are
  unchanged. `latexmkrc` was removed and its references dropped, since the
  supported build already passes `-xelatex` explicitly.
- `make` now builds both supported examples, and the test suites are exposed as
  Make targets (`make check`, `regression`, `smoke`, `layout`, `extract-test`,
  `clean`) that mirror the CI commands. The README build instruction is
  corrected accordingly.

### Fixed

- CI now pins the TeX Live container to an image digest and every GitHub Action
  to a commit SHA, and records the resolved toolchain versions as an artifact,
  so a run is reproducible and an upstream retag cannot change what executes.

## [0.1.0] - 2026-07-15

First tagged release: an English industry résumé and a matching industry cover
letter driven by shared profile metadata, built with XeLaTeX on US Letter paper
in a monochrome theme.

### Added

- `l3build` regression harness (`build.lua`) configured for XeTeX and
  `tests/regression/`, run with `l3build check`. Backfilled committed regression
  coverage for the Phase 1 packages: `careerdossier-base` field storage,
  trimming, presence, overwrite, and the unknown-key, unknown-field, and
  missing-name diagnostics; `careerdossier-components` link-target scheme
  normalization and contact-line separator placement; `careerdossier-theme`
  monochrome palette values and color tokens; and `careerdossier-typography`
  semantic role classes and the ATS actual-text setting.
- `careerdossier-letter.cls`: the English industry cover-letter class. US Letter
  geometry with one-inch margins; no user-facing class options (family, paper,
  language, and theme are fixed, and any option is rejected with an actionable
  message); page numbers disabled by default. `\CDossierLetterSetup` for letter
  metadata (`date`, `recipient-name`, `recipient-title`,
  `recipient-organization`, `recipient-address`, `subject`, `salutation`,
  `closing`) with English defaults for `date`, `salutation`, and `closing` and
  unknown keys rejected. `\MakeCDossierLetterhead` (centered sender identity,
  date, collapsing recipient block, optional subject, salutation) and
  `\MakeCDossierClosing` (closing, signature space, validated `name`). An absent
  recipient field, subject, or contact field leaves no stray line or separator.
- `examples/industry/letter-industry.tex`: the supported cover-letter example,
  sharing `examples/profiles/profile-english.tex` with the résumé example.
- Cover-letter tests: smoke fixtures for the supported builds and the required
  failure paths (missing `name`, unknown class option, unknown
  `\CDossierLetterSetup` key), layout-stress fixtures (`tests/layout/`) for long
  fields and a two-page letter, and a letter extraction fixture
  (`tests/extraction/`) pinning the recipient block, contact line, and reading
  order when optional fields are absent.
- `careerdossier-resume.cls`: the English industry résumé class. US Letter
  geometry; `fontsize` (`10pt`, `11pt`) and `density` (`compact`, `standard`)
  options with actionable rejection of unsupported keys and values; page numbers
  disabled by default; `\CDossierSection`, the `CDossierEntry` environment, and
  the `CDossierItemize` list.
- Shared entry-heading primitive in `careerdossier-components.sty` that renders a
  required title with optional organization, location, and dates and leaves no
  stray separators when fields are absent.
- `examples/industry/resume-english.tex` and `examples/profiles/profile-english.tex`:
  the supported résumé example and its shared profile data.
- Smoke tests (`tests/smoke/`) for the supported builds and the required failure
  paths, layout-stress fixtures (`tests/layout/`) for long fields and a two-page
  résumé, and a résumé extraction fixture (`tests/extraction/`) that pins the
  contact line and reading order.
- Initial project scope, phased roadmap, and Phase 1 implementation plan.
- Repository architecture and documentation plan.
- GitHub issue, branch, pull-request, CI, and release workflow documentation.
- Draft user documentation for the planned `v0.1.0` public interface.
- Contributor workflow and coding conventions.
- LaTeX Project Public License version 1.3c.
- `docs/API.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, and `docs/MIGRATION.md`, resolving links that `README.md` and `CONTRIBUTING.md` already pointed to.
- GitHub issue templates (`.github/ISSUE_TEMPLATE/bug_report.md`, `.github/ISSUE_TEMPLATE/feature_request.md`) and a pull-request template (`.github/pull_request_template.md`).
- `docs/guides/ats-and-extraction.md`: design and reference guide for ATS-safe, extractable XeLaTeX output (single-column layout, font/ligature policy, `/ActualText` limits, extraction testing, tagging status). Reference material only; scope-gated to distinguish Phase 1 from planned work.

### Changed

- Clarified that the résumé, cover-letter class, shared profile interface, and CI workflow remain pre-release targets until implemented and verified.
- Standardized licensing language around LPPL maintenance status and the current maintainer.

### Fixed

- `careerdossier-components.sty`: a `website`, `linkedin`, `github`, or `scholar`
  value that already carried a scheme (for example `https://example.com`) had a
  second `https://` prepended to its link target, producing a broken href such as
  `https://https://example.com`. The scheme is now detected by string comparison,
  which is insensitive to the colon's category code, so an existing scheme is
  preserved and `https://` is added only when none is present. The visible text
  was already correct, so extraction output is unaffected.
- Corrected relative links in `CONTRIBUTING.md` that assumed the file lived under `docs/` instead of the repository root.

[Unreleased]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.4.0...v0.5.0
[0.2.1]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/amirhs1/CareerDossierTeX/releases/tag/v0.1.0
