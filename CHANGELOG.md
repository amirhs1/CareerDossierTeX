# Changelog

All notable changes to CareerDossierTeX will be documented in this file.

The project follows [Semantic Versioning](https://semver.org/). The structure of this file is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Before `v0.10.0`, breaking changes may occur, but they must be documented here and in `docs/MIGRATION.md`.

## [Unreleased]

### Added

- A PDF manual, `doc/careerdossier.tex`, is the toolkit's interface reference,
  and `make manual` builds it into `build/manual/`. It documents every public
  class, option, key, command, environment, and design token, with its accepted
  values and default, in one document. CTAN requires PDF documentation together
  with its source, and this is the last of its requirements this project did not
  meet. ([#263])

  The PDF is a build artifact and is not tracked, like every other one here; the
  release archive ships it beside its source, and `manifest.txt` lists that
  source under "Distributed with the Work". A CI job builds the manual on every
  pull request, so one that stops compiling fails a check rather than a release.

  **Documentation only** — no class, option, key, command, token, or rendered
  output changed.

- `README.md` gains an `## Installation` section covering the three routes onto
  a path where `\documentclass{careerdossier-resume}` resolves: beside the
  document, a local `texmf` tree, and Overleaf. Nothing in the repository had
  said how, so a user who was not cloning it to develop the toolkit was blocked
  before the first build. ([#261])

  `## Requirements` now states a supported floor rather than "a reasonably
  complete TeX Live or MiKTeX installation": LaTeX kernel `2022-06-01`, the
  version every file of the Work already declares through `\NeedsTeXFormat`,
  and TeX Live 2022 as the release carrying it — held apart from the toolchain
  the release was verified against, which is TeX Live 2026 and LuaHBTeX 1.24.0.
  The required packages are named too.

  The file list points at `manifest.txt` instead of restating the ten
  filenames, so adding or removing a module cannot leave the instructions
  stale. **Documentation only** — no class, option, key, command, token, or
  rendered output changed.

- `CDossierPublications` takes a `numbering` key. `restart` is the default and
  is what the class has always done — each list numbers from `1)`. `numbering =
  continue` carries on from the previous list instead, so a document whose
  publication numbers are cited from a cover letter or a grant form can have one
  sequence across every group. ([#355])

  `\CDossierSubsection` ([#337]) is what made the question visible: before it, a
  second publication list meant a second ruled section, and restarting read as
  correct. With grouping, the natural markup is one `Selected Publications`
  section carrying `Journal Articles` and `Conference Papers`, and both groups
  opened at `1)` with no way to say which publication `1` meant. Restarting
  stays the default because a group is a self-contained list and "journal
  article 1" is unambiguous given the group; continuing is the document's
  choice, made per list.

  `continue` resumes from the final number of the preceding list wherever it
  was — a subsection heading and a section rule are equally invisible to it —
  and behaves identically on the tagged and untagged paths.

  **No existing output moves.** A document that does not set the key renders as
  before, including every shipped example; the key is additive and its default
  is the shipped behaviour.

### Changed

- **`docs/API.md` is now a pointer rather than the interface reference.** The
  manual above supersedes it: what is left is where to find the manual, how to
  build it, and the interface stability policy, which binds a contributor
  changing the interface rather than an author using it. Every other section
  moved into the manual. ([#263])

  Two documents describing one interface is the duplication [#259] exists to
  stop, and it had already cost this project once — [#185] found ten sentences
  left stale across three documents after the `v0.7.0` retune, one of them
  documenting a recipe that restored half the spacing it claimed to remove. A
  PDF manual as the reference is also the ordinary shape for a LaTeX package.
  What it costs a reader of this repository on the web is the inline, browsable
  reference; `README.md` links the built PDF and `docs/API.md` says how to get
  one.

  Fifty-three references across nine files were retargeted. `CHANGELOG.md`'s own
  references are historical and stay as they are, except that two of them
  carried a section anchor into a file that no longer has that section — those
  two now link to the file without the anchor, so `make lint` still resolves
  every Markdown anchor in the tree.

- `README.md`'s quick start covers the shared profile and the résumé, then
  names the other five document types with their shipped examples in a table.
  It used to walk through all seven, which the manual now does in full.
  ([#263])

- `examples/academic/publications.bib` now declares twenty fictional entries
  across four types (`article`, `inproceedings`, `unpublished` preprints, and
  `book`) instead of three, so `examples/academic/cv-bibliography.tex` renders
  two pages under its default `fontsize=12pt` rather than one. ([#197])

  The previous three-entry database was too thin to show the multi-page
  pagination, varied entry lengths, and list-edge behavior across a page break
  that [#196]'s calibrated item spacing actually has to handle. The expanded
  database still builds cleanly — Biber reports no warnings, LuaLaTeX reports
  no overfull boxes or undefined references — and `tests/bibliography/run.sh`,
  which derives its shipped-example assertion from the database's own entry
  count rather than pinning content, passes unchanged.

  **Example content only.** No class, option, key, command, or token changed.

- Two shipped examples now demonstrate the package's two accessibility opt-ins,
  which no example used before. `examples/industry/resume-english.tex` sets
  `contact-labels = true`, so its contact line reads `Email: …`, `Phone: …`,
  `Website: …`; `examples/industry/letter-industry.tex` carries
  `\DocumentMetadata{lang=en, tagging=on}` and ships tagged. Each explains in
  its own source comment what the feature does and why a reader might want it.
  ([#273])

  Both features were implemented, documented, and fixture-covered, but invisible
  where users actually start. `contact-labels` is the one that matters most: it
  is the only mechanism that identifies a phone number as a phone number in
  *untagged* output — the default path, and the one plain extraction and ATS
  parsers see. It is demonstrated on the résumé, which stays untagged for that
  reason, while the letter demonstrates the tagged path.

  The tagged letter's source comment repeats the same scope caveat `README.md`
  uses: the tagged path is a tested preview covering five fixture profiles, and
  neither that example nor a document derived from it carries a PDF/UA, WCAG,
  ATS, or general accessibility conformance claim.

  **Example content only.** No class, option, key, command, token, or default
  changed; both features remain opt-in and off by default, and the other nine
  examples are untouched. Neither example repaginates: every word of both keeps
  the vertical position it had, the résumé's labels change only how its contact
  line packs into its two existing rows, and both still build to one page.

- Headings in `docs/` carry no section number, and a cross-reference names the
  heading instead of numbering it. `docs/ATS-EXTRACTION.md` and
  `docs/NAMING-CONVENTION.md` were the two files of eight still numbered; the
  rule is now written down in `docs/NAMING-CONVENTION.md`, "Documentation
  heading convention". ([#447])

  A name survives an edit that renumbers everything below it, which is the
  argument the anchor lint added in [#407] already rests on: a numbered heading
  carries its number inside its own anchor, so inserting one subsection breaks
  every link below the insertion point. Roughly thirty cross-references now cite
  a heading by name, and the release stamps that sat inside two
  `docs/ARCHITECTURE.md` headings moved into the body under them.

  Eight anchors into the renumbered files were repointed, four of them in this
  file. Those are links, not text: shipped entries stay as written, including
  the seven that cite a section number in prose, per [#259] and the precedent
  [#263] set. Anchors elsewhere in the tree are unaffected, and `make lint`
  resolves every Markdown anchor in it.

  **Documentation only** — no class, option, key, command, token, or rendered
  output changed; the one source file touched is a comment in
  `careerdossier-typography.sty` citing a section by number.

- `docs/MIGRATION.md` is a reader's document from top to bottom. Its `Purpose`
  and `Entry format` sections sat a third of the way in, between the two upgrade
  guides and the versioned entries, so a reader upgrading met contributor
  procedure mid-file and a contributor adding an entry had to scroll past both
  upgrade guides to find the shape to follow. ([#446])

  The entry shape now lives in `CONTRIBUTING.md`, under "Update `MIGRATION.md`
  when:", which already stated *when* an entry is required — the same split
  `CHANGELOG.md`'s own bullet there already uses, pointing at
  `.agents/skills/release-notes/reference.md` for format. `docs/MIGRATION.md`
  says in its opening paragraph where that procedure is, and its restatement of
  the stability policy is now a pointer to `docs/API.md`, which owns it.

  **Documentation only** — no class, option, key, command, token, or rendered
  output changed, and no versioned entry was touched.

- `README.md`'s "Roadmap" is two paragraphs instead of a twelve-row table of
  every release and its goal. `docs/ROADMAP.md` "Release overview" carries the
  same information with a `Status` column the README's copy did not have, and
  owns it; nothing kept the two in step, and the list changes at every release
  boundary. What a reader landing on the README wants is what release this is
  and where the project is going, which is what is left, with the table one
  link away. ([#449])

  The dropped and deferred milestones are not lost with the table: the support
  matrix above already states that the toolkit is English-only, that Farsi,
  bilingual, and right-to-left support is dropped, and that themes, named font
  families, and icons remain later work.

  **Documentation only** — no class, option, key, command, token, or rendered
  output changed, and the "current release" block `make lint` reads is
  untouched.

### Fixed

- A `--` you type yourself now reaches the PDF `/Title` and `/Author` spelled the
  same way on both build paths. A `name` of `Ada Lovelace--Byron` shipped
  `Ada Lovelace–Byron` without `\DocumentMetadata` and `Ada Lovelace--Byron`
  with it, so turning tagging on changed the name a viewer displays and a screen
  reader announces. The en dash — what the default path has always produced — is
  now what both produce. ([#439])

  This is the half [#428] left out of scope. That entry removed the package's own
  `--` from the derived string by naming the separator as the character it is;
  that cannot reach a `--` arriving from your profile, because the package does
  not choose how you spell your own name. Every class is affected, and a
  statement's `title` is covered too, since it becomes the document type in front
  of the name.

  Four TeX input ligatures are converted, and `docs/API.md` now lists them:
  `--`, `---`, `` !` ``, and `` ?` ``. ` `` ` and `''` are **not** among them —
  measured, not assumed — and reach the PDF as the ASCII characters you typed on
  both paths, as they always did.

  Values you set yourself are unchanged and still follow `hyperref`'s own
  behaviour, which does differ between the paths; `docs/API.md` records that
  under "Overriding the derived metadata". Rewriting them would mean overriding
  the pass-through [#440] just established, so the package leaves them alone.
  [#442] settled that as a decision rather than an open residue, and `make
  metadata` now pins it with the one check in the tree that requires two build
  paths to *disagree*: the day upstream converges them is the day the suite
  says `docs/API.md` needs correcting. `pdfsubject`, which this package never
  reads or writes, diverges the same way, and so does a plain `article` with
  `hyperref` and none of these classes loaded; that is what places it upstream.

  `make metadata` gains a fixture pair carrying a double-barrelled name and
  requiring the two paths to agree on `/Title` *and* `/Author`, which are
  different routes out of `name`. The conversion table itself, including the two
  sequences that must stay unconverted, is pinned in
  `tests/regression/components-pdfmeta.lvt`.

  **Metadata only.** No class, option, key, command, token, or default changed,
  and nothing rendered on the page moves.

- A document's own `\hypersetup{pdftitle=…, pdfauthor=…}` now survives on the
  tagged build path. Under `\DocumentMetadata` both fields were discarded and
  replaced by the values derived from the profile, so a document asking for
  `Draft – Title` by `Someone Else` shipped `Cover Letter – Ada Lovelace` by
  `Ada Lovelace` instead — silently, with nothing in the log and a clean
  compile. `docs/API.md`'s "a field you set is never overwritten" is now true on
  both paths, as it always claimed to be. ([#440])

  Only the tagged path was affected, and it was so from the start rather than by
  regression. `hyperref`'s `\DocumentMetadata` driver writes the value straight
  into the LaTeX kernel's PDF management and leaves the `\@pdftitle` and
  `\@pdfauthor` macros the package reads defined and empty — which is exactly
  what an unset field looks like, so the package concluded the document had
  supplied nothing. The fix asks the kernel as well, through
  `\pdfmanagement_get:nnN`, and treats a field as the document's own when either
  route carries it. This is the same trap `/Lang` hit in [#276] and the same
  shape of fix; `/Title` and `/Author` had never been given the equivalent.

  `make metadata` gains a fixture pair that sets both fields and requires both
  to reach the PDF, tagged and untagged. The default half is not redundant: it
  is what would catch a repair that traded one path for the other.

  A separate difference — how a `--` you type yourself is spelled on each path —
  was tracked in [#439] and is fixed in this same release; see its entry above.
  That is about how your text is spelled, not about whether it arrives, and the
  fixtures here keep to plain ASCII so the two questions stay apart.

  **Metadata only.** No class, option, key, command, token, or default changed,
  and nothing rendered on the page moves.

- A document built with `\DocumentMetadata{tagging=on}` now carries the same PDF
  `/Title` as the same document built without it. Tagged output showed
  `Cover Letter -- Ada Lovelace` where the default path showed
  `Cover Letter – Ada Lovelace`, so turning tagging on changed the title a
  viewer puts in its window and a screen reader announces. The en dash — the
  form `docs/API.md` has always documented and the default path has always
  shipped — is now what both paths produce. ([#428])

  Every class is affected, since all four derive their title through one
  builder; the cover letter is simply where it was noticed. It is not a
  regression: the builder joined the document type to the name with a literal
  `--` from the start, and only the default path converted it, because hyperref's
  `\pdfstringdef` applies the usual ligature substitution on the way to the PDF
  string. Under `\DocumentMetadata` the kernel's PDF management writes the Info
  dictionary itself and no such conversion happens.

  `make metadata` now asserts the two paths agree, which is the half of this
  that closes the gap rather than the instance: nothing logged the difference,
  and no suite read the title, so both paths passed everything while disagreeing.

  **Metadata only.** No class, option, key, command, token, or default changed,
  and nothing rendered on the page moves.

- A raw `#` in a profile value or a `\CDossierLink` argument now builds, and the
  address reaches the link target intact. It used to stop the build with
  `! Illegal parameter number in definition of \Hy@tempa.` — hyperref's own
  diagnostic, naming neither the field, nor the value, nor the fix. `\#` keeps
  working and produces the same annotation, so no existing document changes, and
  `docs/API.md` no longer asks for the escape. ([#353])

  Every link the toolkit emits is covered: the contact line's `website` and web
  profiles, `\CDossierLink` in body text, the ORCID resolver, and the academic
  CV's manual publication list. Both arguments of a link needed the repair, not
  just the target — `\nolinkurl` is built on the same hyperref internal as
  `\href`, so the displayed address failed for the same reason.

  The tempting repair is worse than the bug and is worth naming so it is not
  attempted again: handing hyperref a catcode-12 string compiles with zero
  errors and silently drops everything from the `#` onwards, because an
  unescaped `#` is hyperref's fragment delimiter. `example.com/a#b` emitted
  `/URI(https://example.com/a)` — a loud build failure traded for a link that
  looks right on the page and points somewhere else, the same class of defect as
  [#328]. No text-layer suite can see it, so two `tests/annotations/` fixtures
  pin the emitted action for both spellings side by side.

  `%` is unchanged and still must be written `\%`. TeX's lexer discards it while
  `\CDossierSetup` is still reading its argument, so no package code can recover
  it; `docs/API.md` continues to say so.

- A cover letter no longer breaks a page between the closing and the signature
  name. `\MakeCDossierClosing` keeps the two on the same page, whichever page
  that turns out to be: when they do not both fit under the body, the break now
  falls above the closing and the whole block opens the next page. ([#421])

  The two are separate one-line paragraphs, so `\clubpenalty` and
  `\widowpenalty` — which govern the first and last line of *one* paragraph —
  never saw the boundary, and the signature gap between them was an ordinary
  legal breakpoint. The gap was latent in every release since the command was
  introduced; [#419]'s tightened header boundary is what first moved a committed
  fixture across the edge that exposes it.

  No public command, class option, key, or token value changes, and no gap
  moves. Only a letter whose closing did not fit repaginates, and it gains a
  page rather than losing one.

- The gap below the header stack in a statement or letter now equals the token
  that names it, at every body size. `\CDossierProseHeaderBelowSkip` and
  `\CDossierLetterHeaderBelowSkip` measured the boundary between the header
  stack and the paragraph after it, and a paragraph boundary contributes
  `\parskip` on top of whatever token guards it — 3.00 pt to 3.625 pt across
  the three body sizes — so the rendered gap was one `\parskip` wider than
  either token claimed, under-stating it by up to 27% at 12 pt. The header
  stack already zeroed and subtracted `\parskip` for the gaps between its own
  lines; the boundary below the stack now routes through the same emission
  contract, the way the section rule and the prose headings already do
  ([#168], [#177]). The résumé and CV's `\CDossierRecordHeaderBelowSkip` was
  already correct, because those classes' `\parskip` is `0`. No public
  command, class option, key, or token value changes; the tightened gap moves
  every statement and letter document and their pagination should be
  reviewed. ([#419])

[#197]: https://github.com/amirhs1/CareerDossierTeX/issues/197
[#259]: https://github.com/amirhs1/CareerDossierTeX/issues/259
[#261]: https://github.com/amirhs1/CareerDossierTeX/issues/261
[#273]: https://github.com/amirhs1/CareerDossierTeX/issues/273
[#353]: https://github.com/amirhs1/CareerDossierTeX/issues/353
[#355]: https://github.com/amirhs1/CareerDossierTeX/issues/355
[#185]: https://github.com/amirhs1/CareerDossierTeX/issues/185
[#259]: https://github.com/amirhs1/CareerDossierTeX/issues/259
[#263]: https://github.com/amirhs1/CareerDossierTeX/issues/263
[#407]: https://github.com/amirhs1/CareerDossierTeX/issues/407
[#419]: https://github.com/amirhs1/CareerDossierTeX/issues/419
[#421]: https://github.com/amirhs1/CareerDossierTeX/issues/421
[#428]: https://github.com/amirhs1/CareerDossierTeX/issues/428
[#439]: https://github.com/amirhs1/CareerDossierTeX/issues/439
[#440]: https://github.com/amirhs1/CareerDossierTeX/issues/440
[#442]: https://github.com/amirhs1/CareerDossierTeX/issues/442
[#446]: https://github.com/amirhs1/CareerDossierTeX/issues/446
[#447]: https://github.com/amirhs1/CareerDossierTeX/issues/447
[#449]: https://github.com/amirhs1/CareerDossierTeX/issues/449

## [0.8.0] - 2026-08-12

**Scope note, added after release.** `CHANGELOG.md` records user-visible
changes only; a change to contributor tooling is documented in
`CONTRIBUTING.md` instead. That boundary was settled after this release shipped
(#260) and is not applied backwards, so one entry below that it would not have
produced stays as written: `make review-pagefill` and its 90% page-fill floor
under `### Added` (#334). `CONTRIBUTING.md` lists the same entry. It was
accurate when written and is unchanged here, and is not precedent for adding a
similar entry today. See
[`CONTRIBUTING.md`](CONTRIBUTING.md#update-changelogmd-when).

### Added

- `\CDossierSubsection{<title>}` gives the résumé and the CV a second heading
  level, for a section with natural groupings that are not themselves sections —
  `Experience` split into industry and academic, `Publications` split into
  journal, conference, and preprint. ([#337])

  Until now the record classes offered one heading level and nothing between it
  and an entry title, so such a group had to be promoted to a full ruled
  section — flattening exactly the hierarchy the grouping was meant to show. The
  statement class has had two levels since it shipped, and its own source
  described the parity as already true; only the section half of that was.

  The heading carries no rule and no size of its own. The full-width rule is the
  section's mark, and repeating it one level down flattens the same hierarchy
  again; the level is carried by weight, face, and spacing instead, which is what
  the statement class already does at this level. Under
  `\DocumentMetadata{tagging=on}` it is a depth-3 heading role-mapped to `/H3`,
  opening a division that nests inside its section's. Untagged output is
  unchanged.

  Two new tokens, `\CDossierRecordSubsectionAboveSkip` (0.75) and
  `\CDossierRecordSubsectionBelowSkip` (0.375), and one new bound,
  `\CDossierSubsectionNeedLines` (3). The below-token is pinned from both sides:
  boundaries compose with `\addvspace`, which takes the maximum, so it has to
  exceed both claims a subsection can meet beneath it — an entry run's 0.3125 and
  the CV publication list's 0.25 — or it would never reach the page at any value,
  and it has to stay under the section's own 0.4375 to read as tighter than its
  parent. On the sixteenth grid that leaves exactly 0.375, which is also why one
  pair of tokens serves both groupings: in neither case does the neighbour own
  the boundary.

  A section that opens *directly* with a subsection leaves the same gap as one
  opening with an entry. The record classes render their headings without
  `\@startsection`, so they get no `\if@nobreak` guard for free; the equivalent
  is derived from `\prevdepth`, which the section rule leaves at its sentinel
  until something is typeset. The needs-N-lines bound is suppressed there for the
  same reason — the section's own bound already placed that material, and testing
  it twice could only break the page between a section heading and the subsection
  under it.

  **Additive.** No existing document renders differently: nothing calls the new
  command, and no existing token or default changed.

- `make review-pagefill` reports how full every page of the layout corpus is,
  and what forced each page break: the page goal, the height used, the fill
  percentage, the penalty at the break taken, and the size of the atom that
  would not fit. `make layout` now *asserts* on the same measurement — no page a
  policy governs may fall below 90% of its goal. ([#334])

  The page-break policy had two halves and only one of them was measured. The
  layout suite asserts that material stays *together* — no list split leaving
  one item behind, no heading separated from what it introduces, no page ending
  on a section heading — and not one of those assertions can fail on a page that
  is half empty. In documents whose entire constraint is a page limit that is
  the more important half, and nothing anywhere measured it. Every other spacing
  decision in this project was settled by measurement; page fill could not be.

  The figures come from `\tracingpages` output parsed out of the log, so the
  target needs only LuaLaTeX and awk — no poppler, which CI's texlive image does
  not have. What it reports per page is `kind`: `overflow` when the next atom
  did not fit, `keep` when `\CDossierSectionNeedLines` ended the page early, and
  `eject` when the fixture source ended it with `\newpage`. Both forced kinds
  print the same penalty and mean opposite things; only the fil stretch on the
  taken candidate tells them apart, and getting that wrong would have flagged
  five fixtures for behaving exactly as their source says.

  The 90% floor is a ratchet rather than a fill policy. *How full should a page
  be* is unanswered: #333 closed without setting a value, and #351 declined the
  one route that would have lifted the outlier. The floor asks only whether a
  page may get worse than anything the project has deliberately accepted. One
  governed page sits at 86.9% and every other at 92.9% or above, so it runs
  through the gap. Measured at `8212a0f`, the commit before #332,
  `resume-two-page` filled 80.6% of its goal and left a 140.04pt hole — the
  defect that produced this check — and the floor fails it.

  A fixture whose accepted state sits lower declares `% PAGEFILLFLOOR: <pct>` in
  its own source, as `statement-two-page` does at 85% for the prose-family hole
  #342 closed as a decision record. When such a declaration is no longer needed
  the run fails asking for its removal, so a stale exemption cannot go on
  suppressing the floor silently.

  **Test and build tooling only.** No class, option, key, command, environment,
  or calibrated value changed, and no document renders differently.

- `\CDossierLink{<url>}` is the supported way to put a link in body text — a
  bullet, an entry, a letter or statement paragraph. It prints the address as
  written, links it, and supplies the break points a long address needs; a value
  with no `://` scheme gains `https://`, exactly as the contact fields do.
  ([#308])

  Neither existing form works there. Plain text has no URL break points, so TeX
  either runs the address into the margin or hyphenates it — and that inserted
  hyphen travels into the pasted URL, where nothing marks it as an artifact.
  `\url` breaks after punctuation only, so a report or commit identifier
  carrying none stays a single unbreakable token: 178.34 pt over the measure in
  a résumé bullet at `fontsize=10pt, margin=narrow`. `\CDossierEmergencyStretch`
  reaches neither, because it redistributes a line's interword glue and a line
  holding one over-wide token has none to redistribute.

  `\CDossierLink` extends url.sty's `\UrlBreaks` with the letters and digits for
  the duration of one link, so the address may break after any character. Those
  break points carry a penalty and no discretionary hyphen, so a wrapped address
  still copies and pastes back character for character — the `make links`
  invariant from #294, which now covers body text as well as the contact line.
  The extension is local to one link, so the contact line and the bibliography
  keep the punctuation-only breaks they were calibrated with.

- The résumé and CV classes accept `entrymeta=column|inline`, choosing where an
  entry's dates and location sit. `column` is the default and renders exactly as
  before — title and organization left, dates and location flush right. `inline`
  sets them on the heading lines instead, joined by `\CDossierEntryMetaSeparator`
  (`~|~`): `Senior Engineer | 2024–Present`. ([#230])

  The option exists to buy back one number. `\CDossierRecordListEdgeAboveSkip`
  carries a lower bound of `0.25` that is not a rhythm decision at all — it is
  the vertical separation Poppler needs before it stops reading an entry's
  bullets ahead of its dates (#219). The flush-right column is what creates that
  hazard: Poppler splits a heading row at the large horizontal gap first, groups
  the fragments into blocks second, and a tall left block spanning a short right
  one is its signature for a two-column page. `inline` leaves no gap to split
  on, so the bound has nothing to protect and does not apply to a document that
  selects it. On the committed fixtures `inline` extracts both entries' metadata
  in place at `0.125` — half the floor, and the value at which `column` reorders
  — including the last entry on the page, which no value of the list edge ever
  fixed under `column`.

  Nothing is retuned. `column` stays the default, the token's calibrated `0.25`
  is unchanged, and the invariant that guards it is unchanged; a document that
  wants the tighter edge selects `inline` and sets the token itself. `inline` is
  not the default because it discards the column the résumé's layout is built
  around, and would reflow every existing document.

  Missing fields behave as they do everywhere else: an entry with no
  `organization`, `location`, or `dates` leaves no stray separator under
  `inline`, just as it leaves no empty column under `column`. On the opt-in
  tagged path the two values are indistinguishable — the separator is emitted as
  a layout artifact, as the contact line's `|` is, so the structure element text
  reads `Engineer 2024–2026` under both and assistive technology is not made to
  announce a vertical bar. Both validate as PDF/UA-2 in the repository's tagging
  fixtures. See [`docs/API.md`](docs/API.md) for the option and the separator
  token, and
  [`docs/ATS-EXTRACTION.md`](docs/ATS-EXTRACTION.md#dates-and-right-alignment)
  §3.4 for the measurements.

- All four document classes accept `muted=plain|italic|gray|both`, controlling
  how de-emphasized runs are rendered — an entry's dates and location in the
  résumé and CV, and the statement's application-context line. `plain` is the
  default and applies no de-emphasis: upright, in the ordinary black text token.
  `italic` slants the same runs, `gray` sets them upright in the muted color
  token instead, and `both` applies the italic and the color together.
  ([#271], [#324])

  **BREAKING (rendered output): entry metadata is no longer italic by default.**
  Every existing document renders differently — the dates and location of every
  résumé and CV entry, and the statement's application-context line, are now
  upright black body text. Nothing is renamed and no source edit is required;
  a document that wants the previous appearance adds `muted=italic` to its
  `\documentclass` options. See
  [`docs/MIGRATION.md`](docs/MIGRATION.md#080---2026-08-12).

  Which styling to want is a real trade-off, which is why it is a choice. Italic
  at small sizes is harder to read for low-vision and dyslexic readers than a
  high-contrast gray, and this metadata is scanned rather than read; but shape,
  unlike a gray level, survives a fax, a photocopy, and a 1-bit print. The muted
  token measures 8.52:1 against white under the WCAG 2.1 relative-luminance
  formula — the source previously estimated "about 8.5:1" and nothing rendered
  it.

  `plain` is the default because both halves of that trade-off are real, and a
  reader affected by both would otherwise have had nothing to select. Being body
  text in the ordinary text token, it is also the one value that cannot fail a
  contrast floor. What it gives up is a redundant signal rather than the only
  one: under every value the dates are identified by their position and their
  content as well — and under `entrymeta=inline` by the separator — so the
  styling was never the only carrier of meaning.

  All four values are visual only: no extractor sees a difference and the
  reading order is identical under each, so no extraction, link, metadata, or
  tagging baseline moves.

  **Breaking for direct package users:** `\CDossierMutedStyle` is now published
  by `careerdossier-components` rather than `careerdossier-typography`, because
  two of the four values resolve it to a color and the typography package owns
  no color. Every document class loads components, so no document built on a
  CareerDossierTeX class needs an edit; a document that loads
  `careerdossier-typography` on its own should load `careerdossier-components`
  instead. See [`docs/MIGRATION.md`](docs/MIGRATION.md#080---2026-08-12).

- A new `make links` suite asserts that no URL or e-mail address a document
  renders picks up extraction whitespace within a visual line — and that one
  which legitimately wraps reassembles exactly from its line fragments — across
  the résumé and CV contact lines, the CV's manual publication list, both
  letter families, and the BibLaTeX bibliography. That pair is the checkable
  form of "the address survives copy-and-paste". ([#294])

  The property already held; nothing recorded why, and it is easy to break from
  several directions at once. Whether a URL copies cleanly is decided by
  typesetting rather than by text: current Poppler starts a new word when the
  spacing between two characters exceeds 0.1× the font size, so a URL whose
  breakpoints were stretched to justify a line copies as
  `https : / / example . invalid /` while the printed page looks untouched.
  The suite reads word bounding boxes rather than extracted text, because a
  legitimate line wrap and a split token are indistinguishable in text — the
  pieces of a wrap sit on different visual lines, the pieces of a split share
  one. The threshold is an extractor implementation detail, so each run records
  its `pdftotext` version. The suite carries a negative control that restores
  BibLaTeX's `0mu plus 3mu` URL stretch, the setting that caused this in #199,
  so the check is re-proved against the real failure on every run.

  **Test coverage only.** No class, option, key, command, environment, or
  calibrated value changed, and no document renders differently.

- A new semantic role, `\CDossierSubjectStyle`, dresses a cover letter's
  subject line in both letter families. **No document renders differently** and
  nothing needs a source edit: the role is new, and the subject line has the
  same bold serif shape it always had. ([#299])

  The subject line previously borrowed `\CDossierEntryTitleStyle`, the
  published role for the heading of one job, degree, or project. Both resolve
  to the same shape, so nothing on the page distinguished them — but one
  published name then described only one of the two places it applied, and a
  future change to entry headings would have silently restyled every letter's
  subject line. The two roles are now defined independently and may diverge.

  `\CDossierEntryTitleStyle` keeps its name, its definition, and its use in
  entry headings. The published role list in
  [`docs/API.md`](docs/API.md) now says where each role
  applies.

- Under `medium=screen`, a link an author writes with their own anchor text is
  now underlined. Under `medium=print` — the default — nothing changes: links
  stay black, unruled, and unbordered, exactly as before. The new declaration
  `\CDossierPlainLinks` turns the decoration off for a group. ([#278])

  The gap was body copy. In `documented in a \href{...}{public write-up}`,
  nothing told a sighted reader that `public write-up` was actionable — not
  colour, not weight, not a rule. That is worse than the colour-only case WCAG
  2.1 AA 1.4.1 describes: there was no cue at all. Where a link's visible text
  *is* the address — the contact line, `\CDossierLink`, an ORCID iD, a
  bibliography DOI — it announced itself already, and those stay undecorated
  under both media. A rule under a contact line's e-mail and website but not
  under its phone or location reads as emphasis, not as linking.

  Nothing about the text layer changes. The extraction fixtures for the two
  media share one body so their committed baselines can be compared directly,
  and they are identical on every supported extractor; the link annotation is
  emitted under both media, with no border under either, so a `medium=print`
  file opened on screen still has live links. Nothing reflows, either: the rule
  is drawn from a node attribute at shipout, so it adds no box and moves no line
  break.

  That last property is why `lua-ul` is now a dependency of
  `careerdossier-components` rather than the more familiar `ulem`. `\uline`
  reboxes what it underlines and rebuilds interword spaces as its own leaders.
  Every extractor still reads `public write-up` correctly, because all of them
  rebuild words from glyph geometry, and PDF/UA-2 validation still passes — but
  the tagged structure tree loses the space, so a screen reader announces
  `publicwrite-up`. `lua-ul` is LuaLaTeX-only, which costs nothing here, and
  LPPL 1.3c. See [`docs/API.md`](docs/API.md) for the option and
  [`docs/ATS-EXTRACTION.md`](docs/ATS-EXTRACTION.md) for the measurements.

- The `linkedin`, `github`, and `scholar` profile keys accept a bare handle or
  identifier. `linkedin = {ada-lovelace}` now displays and links
  `linkedin.com/in/ada-lovelace`, `github = {ada-lovelace}` gives
  `github.com/ada-lovelace`, and `scholar = {kukA0LcAAAAJ}` gives
  `scholar.google.com/citations?user=kukA0LcAAAAJ`. ([#330])

  This is the form authors actually hold. Writing the natural value used to
  produce a link to `https://ada-lovelace` — broken, unwarned, and on a page
  that looked entirely correct, since the only place the expected
  `linkedin.com/in/…` form was recorded was a source comment.

  Nothing that works today changes. A value containing a `/` or a `.` is used
  exactly as written, scheme supplied only when absent, so a `www.` host, a
  trailing slash, and query parameters all survive; every shipped example and
  fixture uses such a value and renders byte-for-byte as before. The synthesized
  address is the displayed text as well as the link target, so the two agree and
  the address still reassembles by copy-paste under `make links`. `website` has
  no canonical host and is untouched, and `orcid` keeps its own `ORCID:` label
  and bare-iD display. See [`docs/API.md`](docs/API.md) for the accepted forms
  per key, the forms that build but produce a broken link, and the two
  characters — `#` and `%` — that must be escaped in any profile value.

- Four test targets take an optional selector, so a single fixture can be re-run
  without the ones ahead of it: `make regression TEST=<name>`, and
  `FIXTURE=<pattern>` on `make smoke`, `make layout`, and `make extract-test`.
  ([#359])

  Until now no target accepted one. A failure in the fiftieth of fifty-four
  layout fixtures cost the forty-nine compiles ahead of it — the whole suite's
  wall time to learn one thing — which is the kind of price that pushes a
  development loop towards guessing instead of checking. Measured on one
  machine: `make layout` 95.1 s, `make layout FIXTURE=resume-two-page` 1.8 s.

  `TEST` is passed to `l3build check <name>` and takes an exact test name.
  `FIXTURE` is a shell glob matched anywhere in a fixture's basename, so a plain
  word behaves as a substring search and a wildcard anchors it.
  `tests/<suite>/run.sh --list` prints the available names and compiles nothing.

  **No change without a selector.** `make check` and every CI job invoke the
  suites exactly as before, and `.github/workflows/build.yml` is untouched. Two
  properties keep a scoped run from being mistaken for a full one: a selector
  matching nothing fails the run rather than reporting a clean one — every
  assertion these suites make is per fixture, so a run that selected none passes
  all of them — and a scoped run's closing line carries the filter, the count,
  and `NOT a full run`. A new `tests/lint/run-fixture-filter.sh`, in the
  sub-second `lint` slot, holds all of that to account.

- The tagging suite becomes the fifth: `make tagging FIXTURE=<pattern>` runs
  only the matching fixture groups. ([#367])

  It was left out of [#359] deliberately, and it is the one most worth having.
  The suite is the second-slowest of the five and the one this repository
  iterates on most — [#28], [#77], [#161], [#268], [#302], and [#305] all landed
  against it, each paying the full run per attempt. Measured on one machine:
  `make tagging` 172 s, `make tagging FIXTURE=cv-subsection` 15.4 s.

  Its selectable unit is the fixture **group**, not the `.tex` file. A group is
  a base fixture plus the companions that assert nothing on their own — its
  `-untagged` build, which exists to be compared against the tagged one, and its
  `-ua2` build, which shares the group's `-body.inc` so a veraPDF verdict
  describes the output the structural checks assert on. Selecting those apart
  from each other would let a run assert less than it appears to, so twelve
  groups are backed by 37 `.tex` files. `tests/tagging/run.sh --list` prints the
  group names and compiles nothing.

  Because of that shape, the universe check the other four suites get — the
  selectable names are exactly the `.tex` files in the directory — would assert
  something false here. `tests/lint/run-fixture-filter.sh` instead requires every
  group to own a `<group>.tex` and every `.tex` to resolve to exactly one group,
  which fails on a group added without files, a file added without a group, and
  a name that resolves two ways.

  A scoped run also distinguishes a gate that is unavailable from a fixture that
  was never selected: a selected group whose only path is behind a missing tool
  is reported under `SELECTED BUT NOT RUN`, rather than counting as a pass.

  **No change without a selector.** `make check` and the `tagging` CI job invoke
  the suite exactly as before, and `.github/workflows/build.yml` is untouched.

- An epic issue template, `.github/ISSUE_TEMPLATE/epic.md`, and an
  `.github/ISSUE_TEMPLATE/config.yml` that disables blank issues and links the
  contribution guide and the naming convention from the issue chooser. ([#360])

  Epics were prescribed by `docs/NAMING-CONVENTION.md` and `CONTRIBUTING.md` but
  had no form to file from, and the two existing templates were optional because
  a blank issue was always offered alongside them.

- A warning when `hyperref` is absent and the toolkit's links are therefore
  typeset as plain text: `Links are typeset as plain text because hyperref is
  not loaded.` ([#329])

  Every link this toolkit emits — the contact fields, `\CDossierLink`, the ORCID
  iD, and the CV's manual publication identifiers — is guarded on `\href` and
  degrades to its visible address without it. That degradation is the right
  behavior, and it was completely silent: no warning, no log line, and a page
  that looks finished. An author found out by clicking a dead address in the
  finished PDF.

  It fires once per document, at the first link that degrades, rather than once
  per field: a contact line with five linked fields and a publication list with
  twenty identifiers have a single cause between them. All four classes load
  `hyperref`, so no supported document sees it; it is reachable by loading
  `careerdossier-components` into another class, which is the configuration the
  guard already anticipated.

  **No rendered change.** Neither branch typesets anything different from
  before, and no class, option, key, or command changed.

- A warning when an `orcid` value does not have the shape of an ORCID iD:
  `The 'orcid' value '...' does not look like an ORCID iD.` The warning names
  the value and the expected form. ([#331])

  An ORCID iD is sixteen digits in four hyphen-separated groups with a final
  digit or `X`. Nothing checked that: a value with no scheme was assumed to be a
  bare iD and prefixed with `https://orcid.org/`, so a truncated iD, or a
  Scholar profile pasted into the wrong key, became a confident link that
  rendered like any other. The failure was invisible until a reader clicked it.

  The check runs where the value is recorded, not where it is printed, so it is
  answered once per document and does not depend on which class prints it. A
  bare iD, an `orcid.org/` value with or without a scheme, an optional `www.`, a
  lowercase `x` checksum character, and one trailing slash all pass in silence —
  warning about a value that does resolve would only teach authors to ignore the
  warning that matters. `docs/API.md` records the accepted forms.

  It warns and never errors: an author may hold an identifier the check does not
  anticipate, and refusing to typeset a document over one would be
  disproportionate. It is a shape check only — it verifies no checksum, and
  LaTeX cannot ask whether an iD is registered.

  **No rendered change.** The stored value, the link target, and the `ORCID:`
  label are what they were for every value, valid or not, and no class, option,
  key, or command changed.

### Changed

- **BREAKING (type-scale token):** `\CDossierSizeTitle` is renamed to
  `\CDossierSizeDocumentTitle`. A source edit is required only in a document
  that reads or sets the token by name; **no document renders differently.**
  ([#269])

  `Title` named two unrelated things in the vocabulary a user is expected to
  learn. This token is a step of the type scale, and its one call site in the
  whole toolkit sizes a statement's document title — the literal
  "Statement of Interest" or "Statement of Teaching Philosophy" at the top of
  the page. `\CDossierEntryTitleStyle`, unchanged here, is a semantic role for
  the heading of a single job, degree, or project inside a résumé or CV. The
  two sit at different levels, are never composed, and now share no word.

  The rename moves no value: the token keeps its 1.50 ratio and its 15 / 17,
  16 / 18, and 18 / 20 pt sizes. Renaming it to `\CDossierSizeSection` was
  considered and rejected — that name is already taken by a distinct 1.12 step,
  and merging them would shrink a statement's title, which is a retune rather
  than a rename. `Document` rather than `Statement` keeps the size scale free
  of class names, matching the way the spacing tokens use the shape words
  `Record` and `Prose` in place of the classes that consume them.

  The rule governing which `Style` pairs with which `Size` — the two namespaces
  are orthogonal, and `\CDossierSectionStyle` composes with three different
  sizes — is not settled here; it belongs to the public-name classification in
  #243.

  A document that calls `\CDossierSizeTitle` now gets an
  undefined-control-sequence error. See
  [`docs/MIGRATION.md`](docs/MIGRATION.md#080---2026-08-12).

- `\CDossierEmergencyStretch` keeps its `2.00 ×` body-size derivation, now
  chosen by measurement rather than inherited for continuity. **No document
  renders differently.** ([#310])

  #272 picked `2.00` because it reproduced the `2em` the classes already set.
  The open question was whether the measure was the better quantity to scale
  with, since a pool is spent on a line and a line has a length. Measurement
  refuted the question rather than answering it: what a paragraph needs tracks
  neither quantity. Varying only the measure from 400 pt to 560 pt, the smallest
  pool that clears every overfull box is a sawtooth with no trend, correlating
  `+0.417` with the measure on the résumé Summary prose and `−0.568` on the
  bullet path — opposite signs. What the pool must cover is set by where one
  paragraph's break points happen to fall.

  Only the magnitude can be chosen, then, and the two forms are
  indistinguishable wherever their magnitudes match: `1.50 ×` body size and
  `0.040 ×` measure leave the same five overfull boxes in the same five cells,
  and `2.50 ×` and `0.050 ×` the same two. So the derivation stays on the type
  scale beside `\CDossierRuleThickness` and `\CDossierListLabelSep`, and the
  ratio stays where it was. Raising it would not be free either: 39 paragraphs
  in that sweep already reach TeX's third pass and set within it, and a larger
  pool re-breaks them.

  The two fixtures from #272 now prove their own premise on every run. A layout
  fixture carrying `% STRETCHCONTROL:` is rebuilt with `\emergencystretch` at
  `0pt` and must go overfull, so a fixture whose text drifted into setting clean
  either way fails instead of passing while asserting nothing.

- `\emergencystretch` is one policy behind one named token,
  `\CDossierEmergencyStretch`, and all four classes now apply it. **No
  committed example renders differently**, and nothing needs a source edit.
  ([#272])

  Four classes previously held three policies: the letter and the statement
  each wrote a bare `2em`, the CV wrote it only at `a4paper`, and the résumé
  wrote nothing at all. None of them said why it differed from the others, and
  the omission was the substantive half — the résumé is fully justified and its
  bullet text carries the toolkit's longest unbreakable strings.

  The token is `2.00 ×` the body size — 20, 22, and 24 pt at `fontsize=10pt`,
  `11pt`, and `12pt`. It derives from the body size rather than the body
  leading because emergency stretch is distributed among a line's interword
  glue, so the quantity is horizontal. The ratio reproduces the previous
  rendered value exactly: `\fontdimen6` equals the design size for both
  supported body fonts, so `2em` measured those same three values, and the
  change is mechanism-only wherever the setting already applied.

  Extending it to the résumé and to the letter-paper CV cannot loosen a
  paragraph that already sets. TeX consults `\emergencystretch` only in a third
  line-breaking pass, reached only when the second finds no feasible set of
  breakpoints within `\tolerance`; it buys back the paragraphs that would
  otherwise be set overfull, and nothing else. Every committed example was
  rebuilt and compared byte-for-byte against its previous PDF: all eleven are
  identical apart from `/CreationDate` and `/ID`, so no line broke differently
  anywhere in the toolkit.

  The layout fixtures still report zero overfull boxes at 10/11/12 pt across
  both margin presets, and `tests/regression/tokens-scale.lvt` pins the token's
  resolved value at each body size while the four `tokens-*-defaults` fixtures
  pin each class's setting against the token — catching both a class writing a
  literal again and a class silently setting nothing. Two new layout fixtures
  make the résumé's setting a *rendered* assertion rather than a reported one,
  one per path the class actually has: `resume-emergency-stretch` sets 8.47 pt
  over the measure with the token zeroed, and `resume-summary-prose` — the
  justified prose paragraph the shipped example opens with — sets 5.62 pt over.
  The suite's overfull check passes on both only because the token reaches the
  page.

- Hyphenation stays at TeX's defaults — `\hyphenpenalty` and `\exhyphenpenalty`
  are `50` in all four families — and that is now a recorded decision rather
  than an unexamined inheritance. **No document renders differently.** ([#309])

  The case for discouraging hyphenation more strongly was that a résumé bullet
  is scanned rather than read, so a hyphen at the end of a short line costs more
  there than in a page of prose. Measurement located the hyphenation somewhere
  else: 48 of the 56 hyphenated line ends in the committed examples are in the
  statements, which are continuous prose. The whole shipped résumé has one, the
  CV one, and raising the penalty removes neither.

  What raising it does do is trade one flaw for another at about one for one.
  `\hyphenpenalty=500` removes 18 hyphens across the examples and creates 10
  lines looser than badness 99 — the worst badness does not move, so the new
  loose lines are in the same quality band, but they are a real cost paid to fix
  a problem the record classes do not have. `500` and `1000` are identical, so
  there is nothing to tune inside the safe band. Forbidding hyphenation outright
  (`10000`) is decisively wrong: 68 overfull boxes across the stress sweep, one
  even in the examples, and a worst-case line badness of 2452.

  No committed example changes page count at any value tested, `10000` included.

  Nothing sets these parameters, so there is no new token to learn; the four
  `tokens-*-defaults` regression baselines record both values instead, which is
  what makes the decision reviewable — including against a future change that
  sets them indirectly by loading a language package.

- The section heading's page-break keep is now a bound rather than a
  prohibition. A section heading is placed only when at least
  `\CDossierSectionNeedLines` (default `4`) lines remain on the page; otherwise
  the page breaks before it and the heading opens the next one. The penalty that
  previously sat after the section rule is gone. ([#333], [#340])

  Read literally, that penalty did not say "keep the heading with its first few
  lines" — it said "keep the heading with everything up to the next legal
  breakpoint", which is unbounded, and it made the heading hostage to whatever
  the section happened to contain. Because every vertical token is rigid and all
  four classes are `\raggedbottom`, page badness is constant, so the page builder
  could never weigh that keep against the hole it opened; the penalty only ever
  deleted candidates.

  It also leaked. With no content to bind to, the penalty was left immediately
  before the gap glue under the rule, and a break at glue is legal only when a
  non-discardable item precedes it — so a section with no content made its own
  closing boundary impossible to break at, cumulatively across a run. Three
  consecutive empty sections left no legal breakpoint at all.

  **Pagination may change**, which is the point: the boundaries inside a section
  are legal breaks again, so a page fills to the last entry that fits instead of
  carrying the whole section to the next one. Measured blank space at the foot of
  page one, on the committed two-page fixtures: résumé 19.39 pt → 16.14 pt
  (2.7% → 2.2%), CV 15.73 pt → 8.80 pt (2.4% → 1.4%). The letter and statement
  families are unchanged — they have no section rule and their remaining slack
  comes from the club/widow policy, which this does not touch.

### Removed

- **BREAKING (color token):** `\CDossierPrimaryColor` is removed. No
  component, class, or example ever called it, and its underlying color,
  `cdossier-primary`, was `gray 0` — the same value as `cdossier-text` under a
  different name, so **no document that never called it renders
  differently.** ([#270])

  `theme-tokens.lvt` previously only asserted that the theme's five public
  color tokens existed, the same shape #255 found in the spacing fixtures,
  where 17 of 25 tokens were reported rather than rendered. The remaining four
  tokens now each have a use assertion at their consumer — `\CDossierTextColor`
  at the running head and folio, `\CDossierRuleColor` at the section rule,
  `\CDossierMutedColor` at the entry-metadata de-emphasis role ([#271]), and
  `\CDossierLinkColor` at the `hyperref` color-links hook, which is checked by
  confirming hyperref's own `\@linkcolor` resolves to the theme's color name —
  the same class of hook-ordering bug #276 and #277 found nearby.

  A document that calls `\CDossierPrimaryColor` now gets an
  undefined-control-sequence error; use `\CDossierTextColor` instead. See
  [`docs/MIGRATION.md`](docs/MIGRATION.md).

### Fixed

- A run of entries with no body no longer strands the rest of a page. An
  `Education` or `Certificates` section is normally written as entries whose
  heading carries everything — degree, institution, dates — and whose body is
  empty. Each of those emitted the penalty that binds an entry heading to the
  first line of its body, with no body to bind to, and a penalty sitting
  immediately before the gap glue makes that boundary illegal to break at. The
  next entry opens with `\addvspace`, which collapses into the glue already
  present rather than putting a box between them, so nothing restored the
  breakpoint and the effect accumulated across the run. In
  `tests/layout/resume-two-page.tex` the result was a 213.09 pt stretch with no
  legal breakpoint anywhere in it, and 140.05 pt — 1.94 in, or 19.4% of the text
  block — left blank at the foot of page one. ([#332])

  The penalty is now emitted only when the entry has a body. An entry with a
  body is bound to it exactly as before, including a prose body and not only a
  bullet list; an entry without one contributes no penalty, so every inter-entry
  boundary in the run stays a legal breakpoint. Both record classes changed
  together, since each declares its own `CDossierEntry`.

  This is a page-break fix, not a spacing change: no vertical token moved, and
  the `\pagetotal` measurements in `tests/regression/resume-entry-edges.tlg` are
  unchanged. Restoring the breakpoints does not by itself decide where the break
  should fall; that is #333, for which this is the prerequisite.

  One consequence is visible to documents: an entry body is now read as an
  argument, so catcode-sensitive content — `\verb`, `listings` — cannot appear
  directly inside `CDossierEntry` and must be wrapped in a macro defined outside
  it. This is what makes the emptiness test possible at all.

- A web-profile link written without a scheme now opens in a browser. `website`,
  `linkedin`, `github`, `scholar`, `orcid`, and the CV's manual publication DOIs
  and URLs are all documented as accepting the short form — `github.com/ada`
  rather than `https://github.com/ada` — and every one of them was emitted as a
  *remote-PDF* link instead of a web link, with `.pdf` appended to an address
  that has none. A reader following one got an error rather than the page. The
  shipped `profile-english.tex` was affected on three fields, and so was
  `\CDossierLink` in body text. ([#328])

  Nothing about the document gave this away. The page, the extracted text, the
  tagged structure, and the copy-paste integrity of the address were all
  correct; only the annotation's action type in the PDF was wrong, and no
  warning was issued. A value the document wrote out in full was never affected,
  which is why the defect survived the examples. `mailto:` links took the same
  wrong path and produced the right result by accident; they no longer depend on
  that.

  A new `make annotations` suite asserts the action type of every link the
  toolkit emits, in both spellings. No existing suite could see it: `make links`,
  `make extract-test`, and `make tagging` all read the text layer, and the text
  layer was never wrong.

- A long URL in a bibliography entry now copies and pastes back exactly. A
  262-character query-string address — a Wikipedia advanced-search result, not a
  contrived one — extracted as `silencing + diasporic + futurism` at the CV's
  own `fontsize=12pt, margin=normal`, so pasting it yielded a URL with spaces
  sprinkled through it. The rendered page looked entirely normal, which is why
  it went unnoticed. ([#312])

  BibLaTeX puts stretchable glue at every break point inside a URL, and a
  justified line spends that stretch on the URL rather than on the word spaces.
  #199 capped the stretch; a cap is not a guarantee, because TeX exceeds a
  stated stretch to set an otherwise underfull line, and this address was long
  enough to make it do so. The optional `careerdossier-biblatex` integration now
  removes the stretch instead of bounding it, which TeX cannot overrule, and
  enables BibLaTeX's URL break penalties so a URL still has somewhere to break
  without them.

  Two visible changes, both confined to bibliographies and intended: a URL now
  breaks where the line ends rather than at the nearest earlier punctuation, so
  an address can wrap mid-run; and a line holding nothing but URL is set
  ragged-right and reported underfull, because it has no glue left to justify
  with. Documents without the optional bibliography integration are unaffected —
  contact-line and `\CDossierLink` addresses were never exposed to this.

- `make links` no longer passes or fails depending on the toolchain. Its
  negative control — the fixture that must be reported as split, and which is
  what keeps the rest of the suite from passing vacuously — reproduced the
  defect by raising the URL stretch, which put the realized gap within a point
  or two of the extractor's threshold: it fired on CI and not on a clean local
  build of the same commit, so `make links` was red locally while CI was green.
  The control now sets that gap directly, so the fixture decides the outcome
  rather than the toolchain. ([#312])

  Every `latexmk` build in `make links` and `make bibliography-test` now forces
  a rebuild. `latexmk` treats an up-to-date PDF as done, so a run in a directory
  holding an earlier build was judging that PDF — reporting on the previous
  state of the package rather than the current one.

- `/Lang` no longer depends on package load order. A document that loads
  `careerdossier-components` directly, after `hyperref`, produced a PDF with no
  language declaration at all — silently, with nothing in the log. The four
  document classes were never affected: each loads the package before
  `hyperref`, which is the order the language declaration needs, so their output
  is unchanged. ([#276])

  On the default build path `hyperref` writes the PDF catalog itself, early at
  `\begin{document}`, and a language set after that point never reaches the
  file. The package now states that ordering requirement rather than inheriting
  it from how the classes happen to load. `/Title` and `/Author` were never
  exposed to this; they are written at `\end{document}`.

  A new `make metadata` suite covers PDF metadata on the default build path,
  which no existing suite could see — every tagged fixture passes
  `\DocumentMetadata`, and that supplies catalog entries of its own.

- A language declared with `\DocumentMetadata{lang=...}` is no longer replaced
  by the derived `en`. A document that asked for `de` got a PDF that said `en`,
  silently, because the two ways of declaring a language write the same catalog
  key by different routes and only one of them was being checked. Both are now
  honoured, alongside `\hypersetup{pdflang=...}`, which was already. ([#276])

  No English document changes: `\DocumentMetadata` settles on `en` when given no
  `lang` key, which is what the classes already produced.

- The PDF title derived from your profile now actually appears in the viewer.
  Every document requests `ViewerPreferences /DisplayDocTitle`, so a viewer
  shows `Résumé – <name>` in its window title, tab bar, and recent-documents
  list instead of the filename. ([#277])

  The title itself was already being written; nothing was telling viewers to
  use it, so the computed value sat in the file unused. That gap is what
  WCAG 2.1 AA 2.4.2 (Page Titled) is about, and it was the one substantive
  item between the documented tagged path — `\DocumentMetadata{tagging=on}` —
  and a clean veraPDF PDF/UA-2 result. That path now passes clause 8.11.2; it
  still declines to declare a PDF/UA identifier, which is a deliberate choice,
  not a defect.

  The request is made on the default path as well as the tagged one, and it
  changes nothing about rendering, extracted text, or the structure tree: no
  class, option, key, or command changed, and every example renders as before.
  A document that prefers the filename sets
  `\hypersetup{ pdfdisplaydoctitle = false }` in its preamble, which overrides
  the request — see `docs/API.md`.

- A `careerdossier-biblatex` bibliography's entry numbers now extract on the
  same line as their entry under a plain `pdftotext` run, instead of appearing
  as `1)`, `2)`, `3)` in a block ahead of all the entry text. ([#199])

  The PDF was never wrong: each label shared a baseline with its entry, and
  `pdftotext -layout` reported source order throughout. `pdftotext`'s default
  mode groups a narrow left column of short tokens once the gap beside them
  reaches about one em, and BibLaTeX's `2\labelsep` default sat on that
  threshold — measured on the project's own fixture, the numbers split at a
  11.955 pt gap and paired at 11.905 pt. The label separation now follows the
  shared `\CDossierListLabelSep`, half the body size, which clears the
  threshold at every supported `fontsize` and matches the geometry a manual
  `CDossierPublications` list already used. The calibrated *vertical* gap
  between entries is untouched: it stays `\CDossierRecordItemSepSkip`, as
  [#196] set it.

  Bibliography entries are indented slightly less as a result, so a document
  with a bibliography can reflow. All eleven supported examples still build,
  and `examples/academic/cv-bibliography.tex` remains one page.

- URLs printed in a bibliography no longer extract as separated tokens
  (`https : / / example . invalid /`) when they end a justified line. ([#199])

  BibLaTeX stretches a URL at its break points to help justify the line, and
  Poppler splits a word wherever the gap exceeds a tenth of an em, so a
  sufficiently stretched URL came out neither searchable nor copyable. The
  stretch is now capped; the break points are unchanged, so URLs still break in
  the same places. This narrows the failure rather than removing it — TeX will
  exceed a stated stretch to set an otherwise underfull line.

- Tagged output now gives the document identity (the name) its own top-level
  `/H1` heading, so a screen reader navigating by heading level reaches it
  before any section. ([#267])

  The name was rendered as an ordinary paragraph with no heading role at all,
  while every résumé/CV section heading and the statement's own title heading
  resolved to `/H1` in the kernel's default namespace — the document's only
  heading level in use, sitting one level above the identity it should have
  followed rather than led. veraPDF UA-2 passed regardless, the same
  validator-invisible, screen-reader-visible shape as [#161]'s boxed-text
  defect.

  The name is now depth 1 of the shared tagged-heading primitive, which the
  kernel's default namespace maps to `/H1`, and it always renders first. Every
  résumé/CV section heading, the statement's title, and the statement's own
  `\section`/`\subsection` moved one level down, so the hierarchy underneath
  the name is unskipped (`/H2`, then `/H3` where a statement uses
  `\CDossierSubsection`). See
  [`docs/ATS-EXTRACTION.md`](docs/ATS-EXTRACTION.md#heading-hierarchy-issue-267)
  §7.4 for the per-profile hierarchy.

  This is a structure-tree change under the opt-in `tagging=on` path only:
  rendered layout, extracted text, and the untagged path are all unaffected,
  and all five named tagged fixtures still pass veraPDF UA-2.

- In tagged output, each résumé and CV section heading now opens a `Sect`
  division enclosing the heading and the content it introduces, and records its
  own text as that heading element's title. ([#268])

  A heading element says that some words are a heading; it says nothing about
  where the section it names ends. Without the enclosing division, every
  heading and every paragraph in the tree was a flat sibling of every other,
  and assistive technology had no way to tell which entries belonged to
  "Experience" and which to "Education". The statement already had the
  divisions, for a purely mechanical reason: it kept the kernel's
  `\@startsection`, which opens them for it, while the résumé and CV render
  their headings through the shared display primitive, which opened a bare
  heading element and nothing else. Both families now produce the same shape.

  The CV's manual publication list needs no division of its own — it sits under
  an ordinary `\CDossierSection`, so that section's division encloses it — and
  the section rule remains an artifact, contributing nothing to the tree. See
  [`docs/ATS-EXTRACTION.md`](docs/ATS-EXTRACTION.md#section-divisions-issue-268)
  §7.5.

  This is a structure-tree change under the opt-in `tagging=on` path only: no
  class, option, key, or command changed, the tagged résumé and CV place every
  word exactly where they did before, and all five named tagged fixtures still
  pass veraPDF UA-2 — which passed before the change too, since a flat tree is
  structurally legal. The per-profile division count in `make tagging` is what
  sees it.

- In tagged output, the document identity (the name) and the statement's title
  line now record their own text as their heading element's title, as section
  headings already did. ([#305])

  The previous entry gave résumé and CV section headings a `/T` and left every
  other heading without one, so a section was titled while the name — the
  document's `/H1`, and the heading that outranks it — was not. All four
  families now title their identity heading, and the statement titles its title
  line as well.

  The `Sect` divisions still carry no title, deliberately: no division in any
  family has one, including the statement's, which the LaTeX kernel generates,
  and the kernel records a heading's title on the heading element. Titling the
  record classes' divisions alone would re-open the divergence [#268] closed.

  This is a structure-tree change under the opt-in `tagging=on` path only: no
  class, option, key, or command changed, every word in all five tagged
  fixtures sits where it did before, and all of them still pass veraPDF UA-2.

- In tagged output, an entry heading's title and dates, its organization and
  location, and a cover letter's recipient block are now separated by a real
  space character. They previously reached a consumer that reads the structure
  tree as one run-on string — `Engineer2024–2026`, `Example LabsToronto`, and,
  for a letter with a full address, `Casey ReaderHead of EngineeringExample
  Company123 Discovery AvenueVancouver, BC V6T 1Z4`. ([#302])

  Those layouts push their second piece into place with `\hfill` or `\\`, which
  move the pen by a coordinate jump and emit no character at all. Ordinary prose
  was never affected: tagged output already carries real space glyphs between
  words, and the gap was that the mechanism only marks glue of positive natural
  width, which `\hfill` has none of. The separator is emitted at zero rendered
  width, so nothing on the page moves — the untagged example PDFs are
  byte-identical across the change, and no extraction baseline moved.

  Whether the run-on form actually misread in VoiceOver or NVDA was never
  confirmed, and this fix does not confirm it retrospectively; it corrects text
  that was wrong at the byte level. See
  [`docs/ATS-EXTRACTION.md`](docs/ATS-EXTRACTION.md#structure-tree-by-profile)
  §7.6 for the decoded before-and-after.

  This is a structure-tree change under the opt-in `tagging=on` path only: no
  class, option, key, or command changed, and all five named tagged fixtures
  still pass veraPDF UA-2. `make tagging` now decodes each fixture's
  marked-content text directly and diffs it against a committed baseline, which
  is the check the whole extraction matrix was structurally unable to perform.

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

- All four document classes accept `medium=print|screen`, controlling whether
  page furniture is emitted. `print` is the default and keeps today's policy —
  a running header from page two, a `Page N of M` folio throughout, and neither
  on a one-page document. `screen` emits no running header and no folio on any
  page. ([#184])

  The same dossier is read in two contexts with different needs: a PDF viewer
  already shows page position, so the folio is redundant on screen, while a
  loose printed page has no such affordance and the folio is what keeps a
  multi-page dossier in order.

  This is additive and changes nothing for an existing document. Under the
  default `medium=print`, all eleven supported examples render byte-identically
  to the pre-change tree apart from the PDF timestamp. (The comparison baseline
  is this release's own furniture placement, which #183 already moved within
  the margins — not `v0.6.0`.) `medium` decides only whether
  furniture is emitted: page geometry is untouched, so the text block sits in
  the same place under both values and switching the option cannot reflow a
  document. An unsupported value produces a class error naming the accepted
  values. `medium` is a separate axis from `theme`, which remains fixed at
  `monochrome`; it does not affect colour, hyperlinks, or PDF metadata.

- Two vertical boundaries that no token described now have one:
  `\CDossierLetterRecipientLineGapSkip` (between two lines of the letter's
  recipient block) and `\CDossierLetterBodyBelowSkip` (letter body → closing).
  ([#204])

  Both are additive: `\CDossierLetterRecipientLineGapSkip` defaults to
  `0.00`, reproducing the plain `\baselineskip` the bare line break gave, and
  `\CDossierLetterBodyBelowSkip` defaults to the value that boundary already
  borrowed from `\CDossierLetterBlockSkip` — a token that names the boundaries
  *between letterhead blocks*, not the body's closing edge. A document that set
  `\CDossierLetterBlockSkip` to change the space above its closing must now set
  `\CDossierLetterBodyBelowSkip`.

- `\CDossierLetterParSkip` sets the letter's paragraph gap, split off from
  `\CDossierProseParSkip`, which now sets only the statement's. ([#222])

  Both classes set `\parindent = 0pt`, so this token was the only thing
  separating one paragraph from the next in either class, but the two pull it
  in opposite directions: the statement's heading below-tokens must stay
  strictly greater than it, while the letter has no heading scale to bound it
  and would prefer a more generous gap. A single shared token meant retuning
  either class's paragraph gap was decided for the other as a side effect.
  `\CDossierLetterParSkip` was introduced at the same `0.50` ratio
  `\CDossierProseParSkip` then carried, so the split itself reflowed nothing;
  [#206] later retuned both to `0.25`. See
  [`docs/MIGRATION.md`](docs/MIGRATION.md).

- `\CDossierHeaderBegin`, `\CDossierHeaderLine`, and `\CDossierHeaderEnd`
  compose a centered header stack line by line. ([#224])

  `\MakeCDossierHeader` and `\MakeCDossierStatementHeader` remain what a
  document uses; both are now implemented over this triple, which is the
  interface for a header whose lines a class has to choose itself. The
  statement's title, subtitle, and context lines interleave with the identity
  lines rather than following them, so no hook on the fixed three-line identity
  block can express its reading order — until now it reached into another
  module's private commands instead.

  `careerdossier-components` keeps owning every gap and the triple adds no
  spacing option: a caller states only which lines are present, in reading
  order, and position decides which token guards each boundary. This is
  additive and renders nothing differently.

### Changed

- **BREAKING (calibrated values):** the vertical-rhythm ratios are retuned.
  **Every document reflows.** No public name changes and no token is added or
  removed; only the values move. ([#206])

  The retune does three things. Prose documents tighten: the statement's
  paragraph gap halves and its section gaps come down with it, so a statement
  fits more argument on a page. Every heading pair is now asymmetric by at
  least 2:1, above to below, so a heading binds to the text it introduces
  instead of floating between two blocks. And two relations that the tokens
  named but the page never showed now hold in rendered white — a bullet list
  sits closer to the entry that owns it than to the next one, and the letter's
  body is framed by a gap visibly wider than an ordinary paragraph break.

  Measured on the built documents with `pdftotext -bbox`: the statement's
  section pair renders 9.65 pt above against 3.27 pt below at 12 pt, and its
  subsections 6.67 / 2.68. The
  résumé's bullet lists sit 2.30 pt below their entry heading and 4.99 pt above
  the next entry, reversing an inversion in which a list sat *further* from the
  entry that owned it. **No supported combination changes its page count** —
  all four classes at both margins and all three body sizes.

  A document that overrode any of these tokens keeps its own value and is
  unaffected. To restore the previous spacing exactly, set the tokens to the
  ratios recorded in the `v0.6.0` vertical-rhythm table.

- **BREAKING (design token):** the header block now zeroes its own paragraph
  gap instead of inheriting the prose classes' document-wide `\parskip`, so the
  header gap tokens name the gap a reader measures in all four classes.
  **Letters and statements reflow:** every header boundary tightens by
  `\CDossierProseParSkip`, 7.25 pt at `fontsize=12pt`. ([#204], [#220])

  Every header line is its own paragraph, so `\parskip` landed in every header
  boundary on top of the header token, and `\addvspace` could not absorb it —
  `\parskip` is inserted at the *next* paragraph's start, after `\addvspace`
  has already read `\lastskip`, so the two always add. The header tokens
  therefore could not express any gap below that floor: at 12 pt they
  contributed about a fifth of each gap they named.

  Measured on the shipped examples at 12 pt, page one reclaims 21.7 pt in
  `letter-industry` and `letter-academic`, 36.1 pt in `artist-statement`, and
  43.3 pt in `research-statement`. No example changes its page count, but a
  statement fits more body text on page one than before. Résumé and CV are
  unaffected, because `\CDossierRecordParSkip` is already `0.00`. To keep the
  previous spacing, add `\CDossierProseParSkip` to the two header gap tokens;
  see [`docs/MIGRATION.md`](docs/MIGRATION.md).

- **BREAKING (design token):** `\CDossierRecordEntryGapSkip` is now the *floor*
  for the entry heading → body boundary rather than space added on top of it.
  **Résumés and CVs reflow slightly:** the gap above a bullet list inside an
  entry tightens by that token — 0.85 pt at `fontsize=11pt`. An entry whose
  body is ordinary prose is unchanged. ([#204])

  The gap was contributed with `\vspace`, which appends a zero glue after its
  own skip, so the following block's `\addvspace` saw `\lastskip = 0` and the
  two added instead of collapsing. A bullet list therefore opened at
  `\CDossierRecordEntryGapSkip` **plus** `\CDossierRecordListEdgeAboveSkip`,
  which put it 5.10 pt from the entry that owns it and 4.25 pt from the next
  one — inverting the design intent that a list belongs to the entry above it.
  Both ends of a list are now maxima, so that relation follows from the ratios
  alone. `resume-english` reclaims 4.2 pt over its five lists and `cv-academic`
  0.9 pt; neither changes page count.

- The résumé, CV, and letter identity block and the statement header now emit
  their lines and the gaps between them from one shared helper instead of five
  separate sites, each of which attached a gap to the optional block below it.
  A gap is now placed *between* two present lines, so an absent optional field
  leaves neither a blank line nor a gap. ([#204])

  This corrects a defect the duplication hid: which token guarded the boundary
  below the name depended on whether an optional field two lines further down
  was present. **A résumé, CV, or letter with no `headline` reflows** — that
  boundary fell through to `\CDossierSharedHeaderMetaGapSkip` and is now
  `\CDossierSharedHeaderNameGapSkip`, gaining 0.85 pt at `fontsize=11pt`. A
  document that sets `headline` is unaffected, and no class, option, key,
  command, or environment changed.

- **BREAKING (design token):** `\CDossierListEdgeSkip` is now two tokens,
  `\CDossierRecordListEdgeAboveSkip` for the space above a list and
  `\CDossierRecordListEdgeBelowSkip` for the space below it, so the two ends of
  a bullet or publication list can be tuned independently. LaTeX has a single
  `topsep` and spends it at both ends, so one token could not express a
  different value above and below. ([#191])

  Both tokens keep the value the single token had, so no document reflows:
  every list in every class renders exactly as in `v0.6.0` at every `fontsize`.
  Retuning either ratio is deliberately left to a separate change. Only source
  that reads or sets the old token by name needs an edit — read
  `\CDossierRecordListEdgeAboveSkip` wherever `\CDossierListEdgeSkip` appeared.
  No class, option, key, command, or environment changed. See
  [`docs/MIGRATION.md`](docs/MIGRATION.md).

  Both tokens apply under `\DocumentMetadata{tagging=on}` as well. Reaching the
  closing edge on that path took a separate mechanism, recorded under ([#193])
  below.

- **BREAKING (design token):** every public vertical-spacing token now follows
  one naming convention, `\CDossier<Family><Scope><Position>Skip`. The family
  says which documents the token affects — `Shared` (all four classes),
  `Record` (résumé and CV), `Prose` (letter and statement), or `Letter` — and
  the position says where the space sits: `Above` or `Below` a block, or `Gap`
  between two parts of one block. Seventeen of the twenty-two tokens released
  in `v0.6.0` are renamed; the four `Prose…` heading tokens and
  `\CDossierProseParSkip` keep their names. ([#203])

  The vocabulary had drifted into three spellings of one idea:
  `Above`/`Below` before `Skip` on ten tokens, `Before`/`After` after `Skip` on
  the list-edge pair, and `After` alone on two more, with five tokens carrying
  no positional word at all. An unprefixed name meant either "shared by every
  class" or "résumé and CV only", with nothing in the name to tell the two
  apart, so a token's name did not predict what it affected.

  Two renames also correct what the token is named *for*.
  `\CDossierAfterSalutationSkip` becomes `\CDossierLetterBodyAboveSkip`, named
  for the boundary it opens rather than the block before it.
  `\CDossierSignatureSkip` becomes `\CDossierLetterSignatureGapSkip` rather
  than `…AboveSkip`, because it is the space reserved *for* a handwritten
  signature between the closing and the typed name — a `Gap` inside the closing
  block, not the space above one.

  **Renames only — no calibrated value changes.** Every renamed token keeps its
  ratio. All eleven supported examples, covering all four document families,
  render with identical word coordinates before and after the change, and
  `tests/regression/tokens-scale.tlg` differs only in the token names it
  records. No class, option, key, command, or environment changed. Only source
  that reads or sets a token by name needs an edit; the full old-to-new table
  is in [`docs/MIGRATION.md`](docs/MIGRATION.md).

- **BREAKING (design token):** the gap below the header block is one token per
  document family — `\CDossierRecordHeaderBelowSkip` (résumé, CV),
  `\CDossierProseHeaderBelowSkip` (statement), and
  `\CDossierLetterHeaderBelowSkip` (letter) — replacing the single
  `\CDossierHeaderBelowSkip` released in `v0.6.0`. ([#223])

  The two gaps *inside* the header block are genuinely shared: every class
  stacks the same lines in the same order. The gap *below* it is not. It is a
  boundary against whatever the class puts next, and that neighbour differs per
  family — a ruled section in the résumé and the CV, a prose section heading in
  the statement, the date line in the letter. One token had to clear whichever
  of those was largest in *any* class, so raising the statement's section gap
  spent vertical space in the résumé and the CV, and the letter carried a floor
  set by a section boundary it does not have.

  **Mechanism only — no calibrated value changes.** All three ship at the
  `0.8125` ratio the single token carried. All eleven supported examples,
  covering all four document families, render with identical word coordinates
  before and after the change, and every committed baseline except the token
  dump is unchanged. Only source that reads or sets the gap below a header by
  name needs an edit; see [`docs/MIGRATION.md`](docs/MIGRATION.md).

- The smoke and layout-stress suites now run as their own CI jobs instead of
  running in sequence inside the `resume` job, so they start in parallel with
  the rest of the workflow. Coverage and the commands themselves are unchanged;
  their CI artifacts moved out of `resume-artifacts` into the new
  `smoke-artifacts` and `layout-artifacts`. ([#188])

- `make review-matrix` now names each rendered PDF `<type>-<margin>-<fontsize>`
  rather than `<type>-<fontsize>-<margin>`, and builds margin as the outer loop
  so the build order matches the sorted order. A directory listing previously
  interleaved the two margin presets — `resume-10pt-narrow` sorted between
  `resume-10pt-normal` and `resume-11pt-narrow` — so a reviewer comparing the
  three sizes of one preset had to skip every second file. ([#195])

  **Naming only.** The same 24 combinations are built from the same fixtures
  with the same class options, and the diagnostic collection, the 24-PDF count
  check, and the exit codes are untouched.

- `\CDossierRecordListEdgeAboveSkip` now has a documented lower bound of `0.25`.
  Below it, the entry heading's right-hand dates and location stop extracting
  with their entry and sort after the entry's bullets — or after the `Page N of
  M` folio on a page carrying furniture. Overriding the token below `0.25`
  therefore breaks reading order for `pdftotext`-class consumers. The default
  was `0.3125` when the bound was measured; [#206] below then retuned the token
  to `0.25`, so it now ships exactly *at* the floor. ([#219])

  The bound is an extraction constraint, not a design preference, and it is not
  something the entry heading can be repaired to avoid. Poppler builds reading
  order from glyph positions alone, so once a bullet list closes up against the
  heading it groups the heading and the list into one tall block and reads the
  entry as the left column of a two-column page. The trigger is a property of
  the whole page rather than of the component, which is why the gap below the
  heading is the only lever. The floor measured identically — `0.25` holds,
  `0.1875` reorders — for the résumé and the CV at 10 pt, 11 pt, and 12 pt, and
  on tagged and untagged output alike; the tag tree is correct in every case
  and veraPDF UA-2 still passes. `tests/regression/tokens-invariants` states the
  bound and the three `*-entry-dates-*` extraction fixtures enforce it.
  [`docs/ATS-EXTRACTION.md`](docs/ATS-EXTRACTION.md) section 3.4 records the
  measurements and the alternatives ruled out.

  **Documentation and tests only.** No class, option, key, command, environment,
  or calibrated value changed, and no document renders differently.

- Every option that takes a fixed set of values now rejects an unsupported one
  with an error naming the accepted values and the owning class or package,
  instead of LaTeX's stock "accepts only a fixed set of choices" — which told
  the reader their value was wrong without saying what was right. This covers
  `fontsize`, `margin`, `paper`, and `bodyfont` on all four document classes,
  `family` on the letter class, and the same options on
  `careerdossier-typography` and `careerdossier-tokens` when either is loaded
  directly as a package. ([#212])

  `medium` reported this way from the start, and the statement class's `type`
  has since `v0.5.0`; the rest sent the reader to
  [`docs/API.md`](docs/API.md) to find an answer the class already had.

  **No accepted value, default, or option name changed**, and no document that
  compiles today is affected: only the wording of an error that already stopped
  the build. A build script matching the old message text needs its pattern
  updated.

- **BREAKING (internal name):** three class-to-package primitives that carried
  a public prefix without being part of the author-facing interface are now
  private: `\CDossierApplyBodySize` → `\__cdossier_tokens_apply_body_size:`,
  `\CDossierApplyGeometry:n` → `\__cdossier_tokens_apply_geometry:n`, and
  `\MakeCDossierPageFurniture` → `\__cdossier_components_apply_page_furniture:`.
  **No document reflows and no supported document needs an edit.** ([#242])

  Each is called once, by a document class, in its own preamble, to apply
  something a shared package had already computed — none was ever documented in
  [`docs/API.md`](docs/API.md), and no example or fixture calls one.
  `\CDossierApplyGeometry:n` was in addition the only name in the codebase that
  mixed the public prefix with an expl3 argument signature, a form reserved for
  private names. `\MakeCDossierPageFurniture` shared the `Make…` prefix with
  `\MakeCDossierHeader` and its siblings without sharing what makes them a
  family: each of those emits document material where the author calls it,
  while this one emits nothing at all.

  `v1.0.0` freezes the public interface, so a name still carrying a public
  prefix then is supported whether or not it is documented. The other fifteen
  public-prefixed names reviewed for the same reason — the type-scale size
  commands, the resolved dimension tokens, and the two keep-together penalties
  — were confirmed public and keep their names. Source that called one of the
  three old names gets an undefined-control-sequence error; see
  [`docs/MIGRATION.md`](docs/MIGRATION.md), which also covers the `\ExplSyntaxOn`
  requirement the new spellings carry.

### Removed

- **BREAKING (design token):** `\CDossierRecordEntryBelowSkip` and
  `\CDossierLetterheadBelowSkip` are removed. Neither rendered anything at the
  released defaults, so **no document changes** — a maintainer who lowered
  either one saw no movement and no diagnostic. ([#204])

  Block boundaries compose with `\addvspace`, which takes the maximum of the
  adjacent claims and never their sum, so where two tokens met at one boundary
  the smaller was unreachable. `\CDossierRecordEntryBelowSkip` (0.125) lost to
  `\CDossierRecordEntryAboveSkip` (0.25) between two entries and to
  `\CDossierRecordSectionAboveSkip` (0.6875) at the end of a section — every
  boundary it appeared at. `\CDossierLetterheadBelowSkip` (0.75) claimed the
  header → date boundary immediately after `\MakeCDossierHeader` had already
  claimed it with the header block's own below-token (0.8125), today
  `\CDossierLetterHeaderBelowSkip`.

  `\CDossierRecordEntryAboveSkip` is now the sole inter-entry token and
  `\CDossierLetterHeaderBelowSkip` the sole owner of the letter's header → date
  boundary. A document that sets either removed name now gets an
  undefined-control-sequence error; see
  [`docs/MIGRATION.md`](docs/MIGRATION.md).

- **BREAKING (design token):** `\CDossierSharedHeaderAboveSkip` — released in
  `v0.6.0` as `\CDossierHeaderAboveSkip` — is removed. It named the space above
  the first header line, and every class renders its header as the first
  material in the document, where TeX discards glue at the top of the page. It
  therefore rendered nothing at `0.00` or at any other value, so **no document
  changes.** ([#220])

  A document that sets either name now gets an undefined-control-sequence
  error; delete the setting. The space *around* the identity block is owned by
  the header block's own below-token below it and by the page geometry above
  it.
  See [`docs/MIGRATION.md`](docs/MIGRATION.md).

  This closes an acceptance criterion the pending ratio retune could not
  otherwise satisfy: a zero-and-rebuild sweep must show no token with zero
  effect in the class that uses it, and this one failed that check by
  construction.

### Fixed

- Under `\DocumentMetadata{tagging=on}`, the space below a bullet or
  publication list now comes from `\CDossierRecordListEdgeBelowSkip`, like the
  space above it and like both edges on the untagged path. It came from LaTeX
  Lab's own block default before — 12 pt against the token's 4.25 pt at the
  résumé default. **Tagged builds reflow; untagged builds are unaffected.**
  ([#193])

  A tagging switch is not supposed to change where text sits on the page, and
  it did: the tagged build of `resume-english` placed 99 of its 206 words lower
  than the untagged build of the same source, drifting from 7.72 pt after the
  first list to 13.0 pt by the last line — about a full line of body text, and
  enough to push a résumé onto a second page that the untagged build fits on
  one. After this change, `pdftotext -bbox` reports every word of all eleven
  supported examples at the identical vertical position in both builds.

  The mechanism the untagged path uses cannot reach a tagged list: LaTeX Lab
  replaces LaTeX's list internals, and the register that carries the closing
  edge measures 0 pt there. The closing token is now applied through LaTeX Lab's
  own block-template keys instead. Those are testphase interfaces, so their
  withdrawal is handled rather than assumed: a build whose LaTeX Lab no longer
  offers them warns once and keeps LaTeX Lab's spacing, instead of stopping at
  an error. Tagged output remains an opt-in preview and carries no PDF/UA,
  WCAG, or ATS conformance claim.

- The CV's `CDossierPublications` list now builds with tagging on. It passed
  enumitem's `leftmargin=*` calculation to LaTeX Lab's emulation, which parses
  that key as a dimension, so a tagged build of any CV with a manual
  publication list stopped with `Missing number, treated as zero` and produced
  no PDF — including `examples/academic/cv-academic.tex`. The list now takes
  the same explicitly measured label box on the tagged path that
  `CDossierItemize` already took, reproducing the untagged `leftmargin` and
  `labelwidth` exactly. Untagged output is unchanged. ([#218])

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

- The optional BibLaTeX integration now separates bibliography entries by the
  CV's calibrated list-item token, `\CDossierRecordItemSepSkip`, instead of a
  fixed `6pt`. A publication list rendered by `careerdossier-biblatex`
  therefore has the same inter-item gap as every other list in
  `careerdossier-cv` — including
  the dependency-free `CDossierPublications` — at every supported `fontsize`,
  rather than a wider gap that did not rescale with the type scale. ([#196])

  This changes rendered output for documents that load
  `careerdossier-biblatex`: bibliography entries move up as the gap closes, so
  a bibliography near a page boundary may repaginate. No class, option, key,
  command, or entry format changed, and `\CDossierRecordItemSepSkip` keeps its
  calibrated value. Loading the package with a class that does not provide the
  token — any non-CareerDossierTeX class — still gets the previous `6pt`.

  One extraction note: with the gap closed, `pdftotext`'s default (non-layout)
  mode groups the entry numbers into a block ahead of the entry text in the
  example. The rendered page and the PDF geometry are unaffected — each label
  shares its baseline with its entry, and `pdftotext -layout` reports the
  entries in source order.

- A rejected `fontsize` or `margin` class option is now reported once, by the
  class that owns it. It was reported twice — once by the class, and again by
  `careerdossier-tokens`, an internal package that appears in no `\usepackage`
  line a class user writes, so the second report named a module the reader had
  never heard of and could not act on. ([#232])

  `careerdossier-tokens` read the global `\documentclass` option list in
  addition to its own, so it re-validated the raw class option independently of
  the class that owns that public surface. It now reads local package options
  only, like `careerdossier-typography` and `careerdossier-components`. Every
  class already forwards the *resolved* value explicitly, so no valid document
  is affected and no option, value, or default changed; the only difference is
  that one diagnostic disappears from a build that already stopped.

  `\usepackage[fontsize=…]{careerdossier-tokens}` is still validated and still
  names the accepted values. A document that loaded `careerdossier-tokens`
  under a non-CareerDossierTeX class and relied on it picking `fontsize=` or
  `margin=` out of that class's option list must now pass the option to
  `\usepackage` (or `\PassOptionsToPackage`) instead.

- A new `make lint` gate keeps the named-values errors added under ([#212])
  from regressing as options are added. It reads the classes and packages and
  fails when a choice-valued option is missing either half of that error — the
  message, or the `unknown` sub-key that reaches it — naming the module and the
  key. It runs first in `make check` and in its own CI job, compiles nothing,
  and needs no TeX installation. ([#233])

  Coverage that enumerates the messages that exist cannot catch one that was
  never written, so this derives the expected set from the source instead:
  twenty-six choice-valued options today, each verified to define its message
  and route l3keys' choice error to it, both naming the module the filename
  implies. **Contributor tooling only.** No class, option, key, command,
  environment, or calibrated value changed, and no document renders
  differently.

- The BibLaTeX/Biber fixture now runs as its own `bibliography` CI job, and
  `tests/bibliography/run.sh` recognises a Biber installation that rejects every
  `date` field and names the cause and the remedy instead of only reporting the
  warnings. ([#211])

  The reported failure — Biber 2.21 dropping every year from the rendered
  bibliography and misordering the entries, while accepting the legacy `year`
  field — **did not reproduce**: `make bibliography-test` passes on a clean tree
  with the same binary, unchanged on disk. Two premises of the report were also
  wrong. CI had exercised this path since `v0.2.0`, inside the job named `cv`,
  so the coverage was real but invisible from the checks list; and the fixture
  needed no change, because its extraction reference already pinned all three
  years and the `ydnt` order independently of the Biber-warning gate.

  The likely mechanism is recorded as plausible rather than proven: `biber` is a
  `PAR::Packer` binary that unpacks its Perl runtime into a per-user cache under
  `TMPDIR`, only the `date` path needs the `DateTime` modules from that cache,
  and macOS purges `/var/folders` periodically — which would break `date` while
  leaving `year` intact. It could not be forced to recur, because `biber`
  re-extracts missing cache files on demand.

  **Diagnosis and CI visibility only.** The fixture keeps `date=`, the
  biber-warning gate is not relaxed, and no class, option, key, command,
  environment, or calibrated value changed.

- The statement class's `type` option is declared as an ordinary l3keys choice
  list, so it is covered by that lint like every other choice-valued option.
  ([#236])

  It was the one exception: hand-rolled from `\str_case:nnF`, which the lint
  keys off `.choices:nn` and could not see. The exclusion cost nothing today —
  the fallback branch was there and named all seven types — but it left a
  second way to declare a choice option, one where dropping the fallback makes
  the option accept a bad value in silence, which is worse than the stock error
  the lint exists to replace. **Contributor tooling only.** The seven accepted
  values, the default, and the wording of both the unknown-value and
  missing-value errors are unchanged, and no document renders differently.

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
