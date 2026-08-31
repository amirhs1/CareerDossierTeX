# Changelog

All notable changes to CareerDossierTeX will be documented in this file.

The project follows [Semantic Versioning](https://semver.org/). The structure of this file is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Before `v0.10.0`, breaking changes may occur, but they must be documented here and in `docs/MIGRATION.md`.

## [Unreleased]

### Changed

- Change the resume `/Title` and running page label to `Resume`, spelled in ASCII. ([#543])

[#543]: https://github.com/amirhs1/CareerDossierTeX/issues/543

## [0.9.0] - 2026-08-26

_If you are upgrading: please see [`docs/MIGRATION.md`](docs/MIGRATION.md)._

### Added

- Add `doc/careerdossier.tex`, the PDF interface manual, built by `make manual`. ([#263])
- Add `numbering=restart|continue` to `CDossierPublications`; `restart` is the default. ([#355])
- Document the three installation routes and the supported kernel floor in `README.md`. ([#261])

### Changed

- Reduce `docs/ATS-EXTRACTION.md` to design rules and rehome its evidence. ([#262], [#480], [#508])
- Change `docs/API.md` to a pointer at the manual plus the stability policy. ([#263])
- Shorten `README.md`'s quick start to the profile and resume, tabling the other five. ([#263])
- Replace `README.md`'s twelve-row roadmap table with a pointer to `docs/ROADMAP.md`. ([#449])
- Move contributor guidance out of the reader's path in `docs/MIGRATION.md`. ([#446], [#481])
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
[#262]: https://github.com/amirhs1/CareerDossierTeX/issues/262
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
[#480]: https://github.com/amirhs1/CareerDossierTeX/issues/480
[#481]: https://github.com/amirhs1/CareerDossierTeX/issues/481
[#508]: https://github.com/amirhs1/CareerDossierTeX/issues/508

## [0.8.0] - 2026-08-12

**Scope note, added after release.** `CHANGELOG.md` records user-visible
changes only; a change to contributor tooling is documented in
`CONTRIBUTING.md` instead. That boundary was settled after this release shipped
(#260) and is not applied backwards, so one entry below that it would not have
produced stays as written: `make review-pagefill` and its 90% page-fill floor
under `### Added

- Add `\CDossierSubsection{<title>}`, a second heading level for the resume and CV. ([#337])
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
- Fix a tagged resume or CV section heading opening no enclosing `Sect` division, leaving the tree flat. ([#268])
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
- **Breaking:** Change the resume's default to `fontsize=11pt,margin=narrow`, and the other three to `12pt,normal`. ([#138], [#141], [#142])
- Scale the shared identity block's name, headline, contact text, and vertical gaps from the calibrated `fontsize` tokens. ([#139])
- Change all four classes to one component-owned page furniture: no folio on a one-page document, `Page N of M` beyond it. ([#140])
- Derive the resume and CV section, entry, rule, and bullet-list metrics from the calibrated type and rhythm tokens. ([#141], [#142])
- **Breaking:** Change the industry and academic letters to share one token-derived geometry; `family=academic` becomes label-only. ([#143])
- **Breaking:** Scale statement headers and prose from the calibrated tokens; the name is no longer fixed at LaTeX's `\Huge`. ([#144])
- Change the resume and CV to apply a stated page-break policy, keeping each heading with what it introduces. ([#145])

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

- **Breaking:** Remove `density=compact|standard` from the resume and CV; use `fontsize` with `margin` instead. ([#141], [#142])

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

- Change default font resolution to `luaotfload` file names, so the build needs no OS-installed font. ([#75], [#76])

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

- Extend the extraction suite from one gate to three, adding an `/ActualText` check and a PDFKit baseline. ([#72])

[#72]: https://github.com/amirhs1/CareerDossierTeX/issues/72

## [0.2.0] - 2026-07-17

### Added

- Add `careerdossier-cv`, the English academic-CV class, with a running header, a `Page n` folio, and no BibLaTeX dependency. ([#44])
- Add optional `orcid` profile metadata, resolving a bare identifier through `https://orcid.org/`. ([#44])
- Add a supported academic-CV example and shared academic profile, with smoke, extraction, and two-page layout coverage. ([#44])
- Add `family=academic` to `careerdossier-letter`, with its own PDF title and print-oriented footer; `industry` stays the default. ([#45])
- Add dependency-free manual publication lists through `CDossierPublications` and `\CDossierPublication`. ([#46])
- Add optional `careerdossier-biblatex` integration: fixed numeric, Biber-backed, year-descending, with DOI over e-print over URL. ([#46])

### Changed

- Change the no-BibLaTeX academic-CV example to demonstrate manual publications. ([#47])

[#44]: https://github.com/amirhs1/CareerDossierTeX/issues/44
[#45]: https://github.com/amirhs1/CareerDossierTeX/issues/45
[#46]: https://github.com/amirhs1/CareerDossierTeX/issues/46
[#47]: https://github.com/amirhs1/CareerDossierTeX/issues/47

## [0.1.1] - 2026-07-17

### Added

- Add `AI-POLICY.md` and contribution guidance for disclosed, human-reviewed AI assistance. ([#62])
- Add `/Title`, `/Author`, and `/Lang` derived from the shared profile; a field set with `\hypersetup` is left alone. ([#50])

### Changed

- Change `manifest.txt` to define the LPPL Work in one place, and remove `latexmkrc`. ([#52])
- Change `make` to build both supported examples, and expose every test suite as a target mirroring its CI command. ([#53])

### Fixed

- Fix CI depending on mutable tags, by pinning the TeX Live image to a digest and every action to a commit SHA. ([#51])

[#50]: https://github.com/amirhs1/CareerDossierTeX/issues/50
[#51]: https://github.com/amirhs1/CareerDossierTeX/issues/51
[#52]: https://github.com/amirhs1/CareerDossierTeX/issues/52
[#53]: https://github.com/amirhs1/CareerDossierTeX/issues/53
[#62]: https://github.com/amirhs1/CareerDossierTeX/pull/62

## [0.1.0] - 2026-07-15

First tagged release: an English industry resume and a matching industry cover
letter driven by shared profile metadata, built with XeLaTeX on US Letter paper
in a monochrome theme.

Eight entries below carry no reference. They record the repository's initial
commit, which predates both the issue tracker and the pull-request workflow, so
there is nothing to cite; see `.agents/skills/release-notes/reference.md`.

### Added

- Add the `l3build` regression harness and backfill committed coverage for the four Phase 1 packages. ([#10], [#25])
- Add `careerdossier-resume.cls`, the English industry resume class, with `\CDossierSection`, `CDossierEntry`, and `CDossierItemize`. ([#8])
- Add `careerdossier-letter.cls`, the English industry cover-letter class, with `\CDossierLetterSetup` and its letterhead commands. ([#9])
- Add a shared entry-heading primitive in `careerdossier-components.sty`, leaving no stray separator when a field is absent. ([#8])
- Add the supported resume example and the shared profile it reads. ([#8])
- Add the supported cover-letter example, sharing the resume's profile. ([#9])
- Add resume smoke, layout-stress, and extraction fixtures covering the supported builds and the required failure paths. ([#8])
- Add cover-letter smoke, layout-stress, and extraction fixtures, pinning the recipient block and reading order. ([#9])
- Add `docs/API.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, and `docs/MIGRATION.md`. ([#4], [#20])
- Add GitHub issue templates and a pull-request template. ([#20])
- Add `docs/guides/ats-and-extraction.md`, the design and reference guide for ATS-safe extractable output. ([#22])
- Add the initial project scope, phased roadmap, and Phase 1 implementation plan.
- Add the repository architecture and documentation plan.
- Add GitHub issue, branch, pull-request, CI, and release workflow documentation.
- Add draft user documentation for the planned `v0.1.0` public interface.
- Add contributor workflow and coding conventions.
- Add the LaTeX Project Public License version 1.3c.

### Changed

- Clarify that the resume, cover-letter class, shared profile interface, and CI workflow remain pre-release targets until verified.
- Standardize the licensing language around LPPL maintenance status and the current maintainer.

### Fixed

- Fix a profile value that already carried a scheme having a second `https://` prepended to its link target. ([#38])
- Fix relative links in `CONTRIBUTING.md` that assumed the file lived under `docs/` rather than the repository root. ([#21])

[#4]: https://github.com/amirhs1/CareerDossierTeX/issues/4
[#8]: https://github.com/amirhs1/CareerDossierTeX/issues/8
[#9]: https://github.com/amirhs1/CareerDossierTeX/issues/9
[#10]: https://github.com/amirhs1/CareerDossierTeX/issues/10
[#20]: https://github.com/amirhs1/CareerDossierTeX/issues/20
[#21]: https://github.com/amirhs1/CareerDossierTeX/pull/21
[#22]: https://github.com/amirhs1/CareerDossierTeX/pull/22
[#25]: https://github.com/amirhs1/CareerDossierTeX/issues/25
[#38]: https://github.com/amirhs1/CareerDossierTeX/pull/38

[Unreleased]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.9.0...HEAD
[0.9.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.2.1...v0.4.0
[0.2.1]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/amirhs1/CareerDossierTeX/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/amirhs1/CareerDossierTeX/releases/tag/v0.1.0
