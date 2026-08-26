# Changelog

All notable changes to CareerDossierTeX will be documented in this file.

The project follows [Semantic Versioning](https://semver.org/). The structure of this file is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Before `v0.10.0`, breaking changes may occur, but they must be documented here and in `docs/MIGRATION.md`.

## [Unreleased]

### Added

- Add `doc/careerdossier.tex`, the PDF interface manual, built by `make manual`. ([#263])
- Add `numbering=restart|continue` to `CDossierPublications`; `restart` is the default. ([#355])
- Document the three installation routes and the supported kernel floor in `README.md`. ([#261])

### Changed

- Reduce `docs/ATS-EXTRACTION.md` to design rules and rehome its evidence. ([#508])
- Change `docs/API.md` to a pointer at the manual plus the stability policy. ([#263])
- Shorten `README.md`'s quick start to the profile and résumé, tabling the other five. ([#263])
- Replace `README.md`'s twelve-row roadmap table with a pointer to `docs/ROADMAP.md`. ([#449])
- Move contributor guidance out of the reader's path in `docs/MIGRATION.md`. ([#446])
- Drop section numbers from `docs/` headings and name targets in cross-references. ([#447])
- Extend `examples/academic/publications.bib` to twenty entries, so the CV runs two pages. ([#197])
- Demonstrate tagging and contact labels in two shipped examples. ([#273])

### Fixed

- Fix `--` and `---` in PDF metadata being written literally on the tagged path. ([#439])
- Fix a document's own `\hypersetup{pdftitle=…}` being overwritten on the tagged path. ([#440])
- Fix tagged and untagged builds carrying different PDF metadata. ([#428])
- Fix a raw `#` in a profile value or `\CDossierLink` argument truncating the link. ([#353])
- Fix the header-to-body gap adding `\parskip` on top of its token in letters and statements. ([#419])
- Fix a cover letter breaking the page between the closing and the signature. ([#421])

[#197]: https://github.com/amirhs1/CareerDossierTeX/issues/197
[#261]: https://github.com/amirhs1/CareerDossierTeX/issues/261
[#263]: https://github.com/amirhs1/CareerDossierTeX/issues/263
[#273]: https://github.com/amirhs1/CareerDossierTeX/issues/273
[#353]: https://github.com/amirhs1/CareerDossierTeX/issues/353
[#355]: https://github.com/amirhs1/CareerDossierTeX/issues/355
[#419]: https://github.com/amirhs1/CareerDossierTeX/issues/419
[#421]: https://github.com/amirhs1/CareerDossierTeX/issues/421
[#428]: https://github.com/amirhs1/CareerDossierTeX/issues/428
[#439]: https://github.com/amirhs1/CareerDossierTeX/issues/439
[#440]: https://github.com/amirhs1/CareerDossierTeX/issues/440
[#446]: https://github.com/amirhs1/CareerDossierTeX/issues/446
[#447]: https://github.com/amirhs1/CareerDossierTeX/issues/447
[#449]: https://github.com/amirhs1/CareerDossierTeX/issues/449
[#508]: https://github.com/amirhs1/CareerDossierTeX/issues/508

## [0.8.0] - 2026-08-12

**Scope note, added after release.** `CHANGELOG.md` records user-visible
changes only; a change to contributor tooling is documented in
`CONTRIBUTING.md` instead. That boundary was settled after this release shipped
(#260) and is not applied backwards, so one entry below that it would not have
produced stays as written: `make review-pagefill` and its 90% page-fill floor
under `### Added

- Add `\CDossierSubsection{<title>}`, a second heading level for the résumé and CV. ([#337])
- Add `make review-pagefill`; `make layout` now asserts a 90% page-fill floor on every page a policy governs. ([#334])
- Add `\CDossierLink{<url>}`, the supported way to put a breakable, linked address in body text. ([#308])
- Add `entrymeta=column|inline`, choosing whether an entry's dates and location sit in a flush-right column or inline. ([#230])
- **Breaking:** Add `muted=plain|italic|gray|both`; the new `plain` default renders entry metadata upright, not italic. ([#271], [#324])
- Add a `make links` suite asserting that no rendered address picks up extraction whitespace within a visual line. ([#294])
- Add `\CDossierSubjectStyle`, a semantic role for a cover letter's subject line. ([#299])
- Add underlining for author-written link text under `medium=screen`; `\CDossierPlainLinks` turns it off. ([#278])
- Support a bare handle in the `linkedin`, `github`, and `scholar` profile keys, expanded to the canonical address. ([#330])
- Add a fixture selector to `make regression`, `smoke`, `layout`, and `extract-test`, so one fixture can be re-run alone. ([#359])
- Add `FIXTURE=<pattern>` to `make tagging`, the fifth and most-iterated suite. ([#367])
- Add an epic issue template and an issue-chooser config that disables blank issues. ([#360])
- Warn once per document when `hyperref` is absent and the toolkit's links are therefore typeset as plain text. ([#329])
- Warn when an `orcid` value does not have the shape of an ORCID iD, naming the value and the expected form. ([#331])

### Changed

- **Breaking:** Rename `\CDossierSizeTitle` to `\CDossierSizeDocumentTitle`; its value is unchanged. ([#269])
- Document `\CDossierEmergencyStretch`'s `2.00 ×` body-size derivation as measured rather than inherited for continuity. ([#310])
- Change all four classes to apply `\emergencystretch` through one named token; no committed example renders differently. ([#272])
- Document leaving `\hyphenpenalty` and `\exhyphenpenalty` at TeX's `50` in all four families, measured against the alternatives. ([#309])
- Change the section-heading keep from an unbounded penalty to a `\CDossierSectionNeedLines` bound; pagination may change. ([#333], [#340])

### Removed

- **Breaking:** Remove `\CDossierPrimaryColor`; use the identical `\CDossierTextColor`. ([#270])

### Fixed

- Fix a run of entries with no body stranding the rest of a page by leaving no legal breakpoint between them. ([#332])
- Fix a web-profile link written without a scheme being emitted as a remote-PDF link rather than a web link. ([#328])
- Fix a long bibliography URL extracting with spaces through it, by removing BibLaTeX's URL stretch rather than capping it. ([#312])
- Fix `make links` passing or failing by toolchain, by having its negative control set the extractor gap directly. ([#312])
- Fix `/Lang` depending on package load order when `careerdossier-components` is loaded directly after `hyperref`. ([#276])
- Fix a language declared with `\DocumentMetadata{lang=…}` being replaced by the derived `en`. ([#276])
- Fix the derived PDF title never reaching the viewer's window title, by requesting `ViewerPreferences /DisplayDocTitle`. ([#277])
- Fix a bibliography's entry numbers extracting as a block ahead of the entry text under a plain `pdftotext` run. ([#199])
- Fix a bibliography URL ending a justified line extracting as separated tokens. ([#199])
- Fix tagged output giving the document identity no heading role, so it now opens its own top-level `/H1`. ([#267])
- Fix a tagged résumé or CV section heading opening no enclosing `Sect` division, leaving the tree flat. ([#268])
- Fix the identity heading and the statement's title line recording no title on their heading element. ([#305])
- Fix an entry heading's parts and a letter's recipient block reaching the structure tree as one run-on string. ([#302])

[#230]: https://github.com/amirhs1/CareerDossierTeX/issues/230
[#267]: https://github.com/amirhs1/CareerDossierTeX/issues/267
[#268]: https://github.com/amirhs1/CareerDossierTeX/issues/268
[#269]: https://github.com/amirhs1/CareerDossierTeX/issues/269
[#270]: https://github.com/amirhs1/CareerDossierTeX/issues/270
[#271]: https://github.com/amirhs1/CareerDossierTeX/issues/271
[#272]: https://github.com/amirhs1/CareerDossierTeX/issues/272
[#276]: https://github.com/amirhs1/CareerDossierTeX/issues/276
[#277]: https://github.com/amirhs1/CareerDossierTeX/issues/277
[#278]: https://github.com/amirhs1/CareerDossierTeX/issues/278
[#294]: https://github.com/amirhs1/CareerDossierTeX/issues/294
[#299]: https://github.com/amirhs1/CareerDossierTeX/issues/299
[#302]: https://github.com/amirhs1/CareerDossierTeX/issues/302
[#305]: https://github.com/amirhs1/CareerDossierTeX/issues/305
[#308]: https://github.com/amirhs1/CareerDossierTeX/issues/308
[#309]: https://github.com/amirhs1/CareerDossierTeX/issues/309
[#310]: https://github.com/amirhs1/CareerDossierTeX/issues/310
[#312]: https://github.com/amirhs1/CareerDossierTeX/issues/312
[#324]: https://github.com/amirhs1/CareerDossierTeX/issues/324
[#328]: https://github.com/amirhs1/CareerDossierTeX/issues/328
[#329]: https://github.com/amirhs1/CareerDossierTeX/issues/329
[#330]: https://github.com/amirhs1/CareerDossierTeX/issues/330
[#331]: https://github.com/amirhs1/CareerDossierTeX/issues/331
[#332]: https://github.com/amirhs1/CareerDossierTeX/issues/332
[#333]: https://github.com/amirhs1/CareerDossierTeX/issues/333
[#334]: https://github.com/amirhs1/CareerDossierTeX/issues/334
[#337]: https://github.com/amirhs1/CareerDossierTeX/issues/337
[#340]: https://github.com/amirhs1/CareerDossierTeX/issues/340
[#359]: https://github.com/amirhs1/CareerDossierTeX/issues/359
[#360]: https://github.com/amirhs1/CareerDossierTeX/issues/360
[#367]: https://github.com/amirhs1/CareerDossierTeX/issues/367

## [0.7.0] - 2026-08-04

**Scope note, added after release.** `CHANGELOG.md` records user-visible
changes only; a change to contributor tooling is documented in
`CONTRIBUTING.md` instead. That boundary was settled after this release shipped
(#260) and is not applied backwards, so five entries below that it would not
have produced stay as written: #188 and #195 under `### Changed`, then the
three under `### Fixed` — #211, #233, and #236. `CONTRIBUTING.md` lists the
same five. Each was accurate when written and is unchanged here, and none is
precedent for adding a similar entry today. See
[`CONTRIBUTING.md`](CONTRIBUTING.md#update-changelogmd-when).

### Added

- Add `medium=print|screen` to all four classes, controlling whether page furniture is emitted; `print` is the default. ([#184])
- Add `\CDossierLetterRecipientLineGapSkip` and `\CDossierLetterBodyBelowSkip`, two previously unnamed boundaries. ([#204])
- Add `\CDossierLetterParSkip`, splitting the letter's paragraph gap off from `\CDossierProseParSkip`. ([#222])
- Add `\CDossierHeaderBegin`, `\CDossierHeaderLine`, and `\CDossierHeaderEnd`, composing a header stack line by line. ([#224])

### Changed

- **Breaking:** Retune the calibrated vertical-rhythm ratios; every document reflows, but none changes page count. ([#206])
- **Breaking:** Change the header block to zero its own paragraph gap; letters and statements reflow. ([#204], [#220])
- **Breaking:** Change `\CDossierRecordEntryGapSkip` to a floor rather than added space; a list inside an entry tightens. ([#204])
- Change the identity block and statement header to one shared helper; a document with no `headline` reflows. ([#204])
- **Breaking:** Split `\CDossierListEdgeSkip` into an `Above` and a `Below` token; both keep the old value, so nothing reflows. ([#191])
- **Breaking:** Rename seventeen spacing tokens onto one `\CDossier<Family><Scope><Position>Skip` convention; values are unchanged. ([#203])
- **Breaking:** Split `\CDossierHeaderBelowSkip` into one token per document family; all three ship at the old ratio. ([#223])
- Move the smoke and layout-stress suites into their own CI jobs, so they start in parallel with the rest of the workflow. ([#188])
- Rename each `make review-matrix` PDF to `<type>-<margin>-<fontsize>`, so a listing groups one preset together. ([#195])
- Document a lower bound of `0.25` on `\CDossierRecordListEdgeAboveSkip`, below which entry dates misextract. ([#219])
- Change every choice-valued option to reject a bad value with an error naming the accepted values. ([#212])
- **Breaking:** Rename three class-to-package primitives to private names; no supported document needs an edit. ([#242])

### Removed

- **Breaking:** Remove `\CDossierRecordEntryBelowSkip` and `\CDossierLetterheadBelowSkip`; neither ever rendered anything. ([#204])
- **Breaking:** Remove `\CDossierSharedHeaderAboveSkip`, which named glue TeX discards at the top of a page and so rendered nothing. ([#220])

### Fixed

- Fix a tagged build taking LaTeX Lab's spacing below a list instead of the token; tagged builds reflow. ([#193])
- Fix a tagged build of any CV with a `CDossierPublications` list producing no PDF. ([#218])
- Fix the running header and folio sitting at `geometry`'s defaults rather than the vertical centre of the selected margins. ([#183])
- Fix `careerdossier-biblatex` separating bibliography entries by a fixed `6pt` instead of the CV's calibrated item token. ([#196])
- Fix a rejected `fontsize` or `margin` being reported twice, once by a package the reader cannot act on. ([#232])
- Add a `make lint` gate deriving the expected named-values errors from the source. ([#233])
- Fix `tests/bibliography/run.sh` reporting Biber warnings without naming the cause or the remedy. ([#211])
- Change the statement class's `type` to an ordinary l3keys choice list, so that lint covers it. ([#236])

[#183]: https://github.com/amirhs1/CareerDossierTeX/issues/183
[#184]: https://github.com/amirhs1/CareerDossierTeX/issues/184
[#188]: https://github.com/amirhs1/CareerDossierTeX/issues/188
[#191]: https://github.com/amirhs1/CareerDossierTeX/issues/191
[#193]: https://github.com/amirhs1/CareerDossierTeX/issues/193
[#195]: https://github.com/amirhs1/CareerDossierTeX/issues/195
[#196]: https://github.com/amirhs1/CareerDossierTeX/issues/196
[#199]: https://github.com/amirhs1/CareerDossierTeX/issues/199
[#203]: https://github.com/amirhs1/CareerDossierTeX/issues/203
[#204]: https://github.com/amirhs1/CareerDossierTeX/issues/204
[#206]: https://github.com/amirhs1/CareerDossierTeX/issues/206
[#211]: https://github.com/amirhs1/CareerDossierTeX/issues/211
[#212]: https://github.com/amirhs1/CareerDossierTeX/issues/212
[#218]: https://github.com/amirhs1/CareerDossierTeX/issues/218
[#219]: https://github.com/amirhs1/CareerDossierTeX/issues/219
[#220]: https://github.com/amirhs1/CareerDossierTeX/issues/220
[#222]: https://github.com/amirhs1/CareerDossierTeX/issues/222
[#223]: https://github.com/amirhs1/CareerDossierTeX/issues/223
[#224]: https://github.com/amirhs1/CareerDossierTeX/issues/224
[#232]: https://github.com/amirhs1/CareerDossierTeX/issues/232
[#233]: https://github.com/amirhs1/CareerDossierTeX/issues/233
[#236]: https://github.com/amirhs1/CareerDossierTeX/issues/236
[#242]: https://github.com/amirhs1/CareerDossierTeX/issues/242

## [0.6.0] - 2026-07-30

### Added

- Add `careerdossier-tokens`, the shared source for the type scales, vertical rhythm, and geometry presets. ([#138])
- Add `\CDossierSection` and `\CDossierSubsection` to the statement class, wrapping the unnumbered LaTeX headings they replace. ([#177])

### Changed

- Retune the shared baseline-derived spacing tokens onto a compact one-sixteenth-line vocabulary; every document may reflow. ([#166])
- **Breaking:** Change the résumé's default to `fontsize=11pt,margin=narrow`, and the other three to `12pt,normal`. ([#138], [#141], [#142])
- Scale the shared identity block's name, headline, contact text, and vertical gaps from the calibrated `fontsize` tokens. ([#139])
- Change all four classes to one component-owned page furniture: no folio on a one-page document, `Page N of M` beyond it. ([#140])
- Derive the résumé and CV section, entry, rule, and bullet-list metrics from the calibrated type and rhythm tokens. ([#141], [#142])
- **Breaking:** Change the industry and academic letters to share one token-derived geometry; `family=academic` becomes label-only. ([#143])
- **Breaking:** Scale statement headers and prose from the calibrated tokens; the name is no longer fixed at LaTeX's `\Huge`. ([#144])
- Change the résumé and CV to apply a stated page-break policy, keeping each heading with what it introduces. ([#145])

### Fixed

- Fix statement section headings taking `article`'s size, family, and skips rather than the design system. ([#177])
- Fix a page break splitting a hyphenated word or stranding a single line of a paragraph at the foot or head of a page. ([#171])
- Fix a bullet whose text fills the line inflating the spacing that follows its list. ([#170])
- Fix the section rule's depth following its heading's descenders instead of sitting a fixed distance below the baseline. ([#169])
- Fix the rule-to-content gap depending on whether an entry, a bullet list, or prose opened the section. ([#168])
- Fix `\CDossierListEdgeSkip` under-stating the list edge by a constant 3 pt that did not rescale. ([#176])
- Fix the section-rule spacing tokens under-stating their gaps, because the rule occupied a paragraph line of its own. ([#164])
- Fix a contact separator beginning or ending a visual line when the contact paragraph wraps between fields. ([#151])
- Fix contact labels and unlinked contact values being emitted as layout artifacts rather than content in tagged output. ([#161])

### Removed

- **Breaking:** Remove `density=compact|standard` from the résumé and CV; use `fontsize` with `margin` instead. ([#141], [#142])

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

- Add an opt-in `contact-labels` key to `\CDossierSetup`, prefixing `Email:`, `Phone:`, and `Website:` in the contact line. ([#95])
- Add a `bodyfont=serif|sans` class option to all five document classes; `serif` stays the default. ([#119])
- Add opt-in A4 paper to all five document classes through `paper=letter|a4`; US Letter stays the default. ([#105])
- Add `careerdossier-statement`, one class covering seven statement types selected by `type`. ([#104])

### Changed

- Move PDF/UA-2 validation into CI on a weekly schedule; the per-push `tagging` job still names the veraPDF gate as not run. ([#94])

### Fixed

- Fix a statement with no `type` failing instead of defaulting to `type=interest`. ([#117], [#128])

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

- **Breaking:** Replace XeLaTeX with LuaLaTeX as the sole supported engine; there is no compatibility mode. ([#75], [#76])
- Change the academic CV folio to `Page N of M`, so a reader holding page two can tell whether the document ended. ([#91])
- Change the academic cover letter to share the CV's running header and `Page N of M` folio. ([#98])

- Default fonts now resolve by file name through `luaotfload` (`texgyretermes`
  and `texgyreheros` with explicit faces) instead of by fontconfig family name.
  The build no longer depends on OS-installed fonts. Documents that override
  fonts with a system font name should recheck their logs for substitutions.

- Move the `Makefile`, `l3build` config, test runners, and CI workflow to LuaLaTeX. ([#76])
- Extend CI with a `tagging` job carrying both command-line extractors; veraPDF needs an approved pin and stays local-only. ([#77])

### Added

- Add opt-in tagged semantic structure, enabled per document with `\DocumentMetadata{tagging=on}` and off by default. ([#28])
- Add PDF/UA-2 validation and a three-extractor round-trip over the four tagged fixture profiles, with a toolchain record. ([#77])
- Add a tagged-BibLaTeX feasibility fixture, deliberately non-blocking and not a supported feature. ([#77])

### Removed

- Remove `\XeTeXgenerateactualtext` handling with the rest of the XeTeX-specific code path. ([#75])

[#28]: https://github.com/amirhs1/CareerDossierTeX/issues/28
[#75]: https://github.com/amirhs1/CareerDossierTeX/issues/75
[#76]: https://github.com/amirhs1/CareerDossierTeX/issues/76
[#77]: https://github.com/amirhs1/CareerDossierTeX/issues/77
[#98]: https://github.com/amirhs1/CareerDossierTeX/issues/98
[#91]: https://github.com/amirhs1/CareerDossierTeX/issues/91

## [0.2.1] - 2026-07-19

### Fixed

- Fix adjacent words merging when text is extracted in macOS Preview, Quick Look, Safari, or Spotlight. ([#72])

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

[Unreleased]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.8.0...HEAD
[0.8.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.2.1...v0.4.0
[0.2.1]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/amirhs1/CareerDossierTeX/releases/tag/v0.1.0
