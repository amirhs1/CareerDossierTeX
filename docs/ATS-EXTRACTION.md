# Engineering ATS-friendly career documents with LuaLaTeX

This file is the engineering contract CareerDossierTeX is built toward for text
extraction, tagging, and fonts: what a generated PDF's text layer, reading
order, Unicode mapping, and semantic structure have to do, and what has been
measured about each. It is design and reference material, not documentation of
shipped behavior — the PDF manual and the compiled examples describe what is
currently supported. Where this guide and the rest of `docs/` disagree, the
repository documentation is authoritative and this file is the one to correct.

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
- all fonts used for meaningful text are embedded or otherwise reliably
  available to the PDF consumer;
- the document remains readable without colour and without hyperlink behaviour;
- the portal's parsed preview or autofill is correct when such a preview is
  available;
- the PDF remains easy for a human to skim; and
- the employer accepts a PDF at all — a sound PDF cannot satisfy a portal that
  requires DOCX, so follow the requested file type whatever this list says.

These properties improve the odds of successful parsing. They do not control an
employer's ranking rules, keyword logic, AI models, or internal workflow.

### Three related but distinct targets

| Target         | Main question                                                             | Useful evidence                                                 | What it does not prove           |
| -------------- | ------------------------------------------------------------------------- | --------------------------------------------------------------- | -------------------------------- |
| ATS extraction | Can a parser recover the words and associate them in a sensible order?    | `pdftotext`, copy/paste, portal autofill                        | Accessibility or correct tagging |
| Accessibility  | Can assistive technology understand the document's structure and meaning? | tagged-PDF inspection, PDF/UA validation, screen-reader testing | ATS field recognition            |
| Visual quality | Can a recruiter read and scan the document comfortably?                   | rendered-page inspection, print test, zoom test                 | text-layer correctness           |

A tagged PDF can still have a poor extraction order. An untagged PDF can
sometimes extract cleanly. A beautiful PDF can fail both. Test all three.

### Constructs that must not carry essential content

- `twocolumn`, `multicol`, `paracol`, sidebars, or parallel minipages;
- `tabular`, `tabularx`, `longtable`, `array`, or nested boxes used merely to
  align resume fields;
- TikZ nodes, `textpos`, `picture`, overlays, absolute positioning, or floating
  text boxes;
- text converted to paths or embedded in SVG/PDF artwork;
- contact details stored only in running headers or footers;
- icon-only labels for phone, email, location, website, LinkedIn, GitHub,
  ORCID, or Google Scholar;
- skill bars, stars, charts, ratings, timelines, maps, portraits, logos, QR
  codes, or infographic elements as substitutes for text;
- negative spacing or overlapping boxes that visually reorder content;
- manual letterspacing implemented by inserting spaces between characters; or
- hidden, white, zero-size, clipped, or transparent keyword text.

Some of these constructs can generate extractable PDFs in controlled cases.
They remain high-risk because different extractors make different ordering
decisions. The default output should avoid the entire class of failure. The
rule underneath all of them: the implementation may change font, spacing,
weight, or alignment, but it must never move a later semantic block to an
earlier visual position.

The same rule governs the interface. Do not define layout-only commands such as
`\LeftColumn`, `\RightColumn`, or `\SkillBar`; define semantic ones, so that a
document's structure survives being flattened into a single stream of text.

One case a class cannot enforce, because it is the author's: a scanned
signature may be decorative, but the typed name must remain present as text,
and the image must neither interrupt the reading order nor stand in for the
name.

### Safe visual hierarchy

Prefer hierarchy created with:

- conventional section headings;
- font weight and modest size changes;
- consistent vertical space;
- indentation of ordinary lists;
- short horizontal rules used only as decoration; and
- source-order-preserving inline alignment.

Bold, italics, and dark accent colours are generally safe because the words
remain words. Colour must not carry meaning by itself. Keep body text black or
very dark, maintain strong contrast, and test grayscale output.

### Dates and right alignment

An entry's dates and location can sit in a right-hand column, set against the
margin opposite the title, or inline on the entry's own line after it. The
column is the default: it is the conventional form for a career document and
the fastest for a human to scan.

That choice is not free, because a right-hand column is a second column, and an
extractor infers reading order from geometry rather than from the source. Once
the column's vertical band stops being distinct from the material below it, the
page can be read as two columns and the whole left one emitted first — so an
entry's dates arrive after its bullets, or after the page folio, instead of
with the entry they belong to. It is a property of the layout rather than of
the tagging, and consumers differ on whether they show it.

Two rules follow. A right-aligned column is only ever as safe as the vertical
space beneath the heading that carries it, so that space is a deliberate design
value and not whatever the vertical rhythm happens to leave. And the risk
belongs to the page rather than to the entry, so no refinement of the entry
itself removes it: the only way out is to have no column at all, which is what
the inline form is for.

### Page geometry and furniture

Margins are a small set of presets rather than a free dimension. The measure a
career document is set to is a design decision, and a continuum invites tuning
a page until the content fits instead of until it reads.

Page furniture answers one question: could this page become separated from its
fellows? On paper it can, so a repeated identity and a position marker let a
reader reassemble the document. On screen it cannot, so both are noise. A
single-sheet document needs neither under either condition.

Every spacing decision a document can reach is a named value rather than a
number written where it is used. A number can only be changed where it sits; a
named one can be related to its neighbours and held to a bound when something
outside the design turns out to depend on it.

## Typography and fonts

### Font choice is a build dependency

What a font displays and what it extracts to depend on far more than its name:
on the exact files behind each of the four faces, on which optional
substitutions are active, on the shaping the renderer applies, and on the
mapping the file carries from glyph back to character. Change any of them and
the text layer can change while the page does not.

So a font and the way it is used are one dependency, tested together. Do not
call a font ATS-safe on the strength of its family name, and do not let a
default resolve through whatever is installed: two people naming the same
family can hold different files.

### Package default versus user-selected fonts

A font earns its place in the default not by being safe — no font is — but by
being widely distributed with the toolchain and reproducibly testable. Those
two properties are what make a claim about extraction mean anything: everyone
who builds the document gets the same files, and the claim can be re-checked
against them.

That is also the boundary. Choosing among a small set of tested profiles is
part of the interface; reaching past it to arbitrary installed fonts, or
selecting a different face per role, is not. Those documents can be built, but
they leave the tested combination, and nothing measured about the default
carries over to them.

### Prefer literal Unicode source

Source is UTF-8 and characters are themselves. Nobody should have to spell
`Zoë`, `José`, `Łukasz`, or `İpek` with accent macros to accommodate an engine,
and a name is the most likely place a career document will carry a character
outside ASCII — so the round trip from source character to extracted character
is a property the design owes its users, not a nicety.

### Ligatures and alternate glyphs

The visible glyph and the extracted text are different layers. A ligature can
display as one glyph and must still extract as the characters it stands for. An
alternate punctuation glyph can look exactly right on the page and extract as a
private-use code point that means nothing to any reader but the font that
supplied it.

A font's own version can change that behaviour without anything in the document
changing, which has happened in the wild to a widely used family. So a font and
the feature set it is used with are a build dependency: the pair is tested, not
assumed, and a face that passes with one feature set has been tested with that
set alone.

The default is therefore conservative — optional ligature and alternate
substitutions are switched off, and figures are lining — with three
qualifications that keep the rule from overreaching.

Required shaping is not optional and is never disabled indiscriminately; other
scripts depend on it, and switching it off to make extraction tidier would
break the text it was protecting **(deferred — unscheduled)**. Disabling
substitutions changes metrics slightly, so kerning, line breaks, and page
breaks move with it — a typographic decision, not only an extraction one. And a
document that selects arbitrary font features has left the tested combination:
the extraction guarantee does not extend to it until that document's own output
is checked.

### What a file claims about its own text

A PDF can carry a machine-readable assertion of what its text _really_ says,
running alongside the glyphs that display it. The intent is redundancy: a
consumer that cannot read the glyphs correctly can read the assertion instead.
This package emits no such assertion at word level — specifically, no per-word
`/ActualText` span — and would not even if the engine offered to generate them.

The reason is that redundancy here is not free. Two layers can disagree, and
consumers do not agree on which to trust: one that reads the assertions
concatenates them and loses the boundary between adjacent words, while one that
falls back to glyph positions keeps it. The same file then yields different
text to different readers, and the divergent reader is not an exotic one — it
is the framework behind a major platform's built-in viewer, its search
indexing, and its ordinary copy and paste. A document pasted out of a preview
window is exactly the text an applicant-tracking system goes on to tokenize.

The general form of the problem is that no self-description a file carries is
sufficient evidence about its own text:

- consumers vary in whether and how they honour such an assertion, and
  honouring it can be worse than ignoring it;
- a document may carry several fonts with different character mappings;
- a mapping table can be present and still be incomplete or wrong;
- correct character mapping establishes nothing about reading order; and
- an assertion can simply disagree with what is on the page.

So the presence of the metadata proves nothing. What settles the question is
comparing extracted output against text already known to be correct — and
because the disagreement lives in the consumer rather than in the file, more
than one consumer has to be asked. A defect that none of the readers you
happened to try can see is still a defect.

This concerns the text layer alone, and is not a tagging or conformance claim
of any kind.

## Copy-paste integrity

An address a reader copies out of the document must paste back exactly, into a
browser or into a mail client. Stated so it can be checked, that is two
conditions: the address must not break into several words inside one visual
line, and where it legitimately wraps, its fragments must rejoin into exactly
the address that was written.

Nothing about the characters causes this to fail — the typesetting does. An
extractor rebuilds words from the spacing between glyphs, so an address that a
justified line has stretched apart arrives as separated pieces: a defect in the
text layer, invisible on the printed page. Any decision that puts elasticity
inside an address is therefore an extraction decision, even when it changes no
text.

Addresses appear in three settings and each takes its own answer. One set as a
measured item of its own is safe by construction, because nothing justifies it.
One set inside justified prose, as a bibliography entry is, is not: elasticity
there is removed outright rather than limited, because a limit only bounds the
ordinary case and typesetting will exceed it to avoid a worse-looking line. An
address written into body text fails the opposite way — left to ordinary
paragraph breaking it is hyphenated, and the pasted result carries a hyphen
that was never in it, which no word-boundary check can notice because a hyphen
is a legitimate character in a legitimate word. Body text therefore uses a link
form whose break points add no hyphen, so a wrapped address still rejoins
exactly.

The same constraint governs decoration. An underline must be drawn over an
address rather than around it: anything that re-boxes text in order to decorate
it rebuilds the spaces inside it, and the text layer changes while the page
looks identical.

One consequence decides how any of this can be checked. In extracted text a
legitimate wrap and a split address look alike — both are whitespace. Telling
them apart needs the geometry: fragments on different visual lines are a wrap,
fragments sharing a line are the defect. And the spacing at which an extractor
decides to start a new word is that extractor's own business, so the guarantee
is only ever as broad as the extraction models actually checked.

## Tagged PDF and accessibility

Tagged structure gives a document a semantic tree a consumer can read instead
of inferring one from geometry. It is worth supporting, and it guarantees
nothing about extraction: a tagged file can still extract in the wrong order,
and an untagged one can extract cleanly. The two are separate targets and are
tested separately.

Tagging is opt-in, and it is the document's decision rather than the class's.
The declaration that enables it has to precede the class, so a class cannot
turn it on for a document that did not ask; that follows from where the
declaration must sit, and no internal late call is equivalent to it. The
documentation says so rather than implying otherwise.

Because it is opt-in, the untagged path is the one every document gets by
default, and it must be provably unchanged whenever tagging code moves. Paired
output — the same document built both ways — is the only evidence that settles
it. Neither path asks the author to declare metadata: the classes derive the
document's title, ask the viewer to display it, and record the language, on
both.

Kernel support for tagging is still changing, so treat every dependency's
tagging status as something to check rather than assume, and re-check it each
release. Two limits follow from that. Claim no conformance — accessibility
standard or otherwise — without a validator run and a manual inspection of the
exact output being released; a validator alone establishes only the half it
covers. And where strict conformance is an application requirement, say plainly
that the current scope may not meet it rather than leaving it to be inferred.

Three rules bind package code on this path: use current kernel hooks instead of
patching the output routine; do not use fake math merely for vertical
alignment; and mark decorative content as an artifact through the supported
tagging interfaces, so that a consumer reading the tree is never handed
furniture as content.

### What validation establishes, and what it does not

A validator result describes the artifact validated and nothing beyond it.
Named fixtures passing is not a conformance claim for a document with different
content, different packages, or graphics; such a document is unvalidated until
it is itself validated, and no default may be flipped on the strength of the
fixtures alone.

Validation is also only half the evidence. A validator establishes that
structure exists and is well formed; only a person listening establishes that
the document _reads_ — that decorative rules and repeated page furniture stay
silent, and that headings, entries, and contact lines arrive in a sensible
order. One screen reader passing is evidence rather than proof, because
implementations differ in how they consume the tree, so a result on one
platform says nothing about another.

### Tagged bibliography output

Bibliography tagging depends on work upstream of this package, so its output is
measured and not claimed. A fixture that records how it currently behaves is
deliberately non-blocking: a failure there does not gate the supported profiles
unless the cause is this package's own code. The result is recorded, not
advertised — the difference between knowing how something behaves and offering
it as a feature.

### Heading levels

A tagged document is consumed two ways, and they are not equivalent. Reading
straight through visits every leaf in document order; jumping by heading visits
only the heading elements, in order, and skips everything between them. A
document that is correct under the first can be unusable under the second.

Two rules follow. The document's identity — the person's name — is its one
top-level heading, and it precedes every other heading in source order, because
a name that carries no heading role is simply unreachable by heading
navigation, and a section heading left at the top level announces itself as a
peer of the document rather than a part of it. And beneath it the levels are
unskipped: each level down is a real containment step, so a group inside a
section takes the next level rather than being promoted to a peer of the
section that holds it.

A skipped level is also a validation failure, so this is not only a matter of
taste.

### Section divisions

A heading names a region; it does not create one. The division that carries the
region has to enclose the content it introduces, or a consumer is told where a
section starts and never where it ends, and everything after the first heading
collapses into one flat run.

Two things follow from that. A heading and the material beneath it belong to
one division, so a document's regions nest the way its headings do. And
decoration that accompanies a heading — a rule beneath it, for instance — is
furniture rather than content, so it stays outside the structure and
contributes nothing to the tree.

### What the tree must say

A structure element's own text is not what an extractor reconstructs from glyph
positions; it is what a consumer reading the tree is handed directly. Two
pieces of content separated by nothing but positioning carry no boundary in
that text even though the page shows a gap, so a word boundary that exists only
as geometry has to be made real. Every extraction check in the project is blind
to this by construction, because all of them rebuild words from geometry —
which is why the tree is checked on its own terms rather than through them.

The committed `tests/tagging/*.structure.txt` baselines are the trees these
rules produce, and are what a change to any of them has to be diffed against.

## Current external references

- [LaTeX package/class tagging status](https://latex3.github.io/tagging-project/tagging-status/)
  — last checked 2026-08-26
- [`fontspec` documentation and package record](https://ctan.org/pkg/fontspec)
  — last checked 2026-08-26
- [Inter issue 774: XeLaTeX text-extraction regression](https://github.com/rsms/inter/issues/774)
  — last checked 2026-08-26
- [Checking PDF encoding and ToUnicode](https://stackoverflow.com/questions/53890212/how-to-check-if-encoding-and-tounicode-are-properly-done-for-a-pdf)
  — last checked 2026-08-26
- [Greenhouse: unsuccessful resume parse](https://support.greenhouse.io/hc/en-us/articles/200989175-Unsuccessful-resume-parse)
  — last checked 2026-08-26
- [Lever: understanding resume parsing](https://help.lever.co/hc/en-us/articles/20087345054749-Understanding-resume-parsing)
  — last checked 2026-08-26
- [MIT: make your resume ATS-friendly](https://capd.mit.edu/resources/make-your-resume-ats-friendly/)
  — last checked 2026-08-26
