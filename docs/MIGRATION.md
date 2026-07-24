# Migration Notes

## Status

`v0.5.0` is the current published release. `v0.4.0` **changes the supported
engine from XeLaTeX to LuaLaTeX** — see
[Upgrading to `v0.4.0`](#upgrading-to-v040-xelatex--lualatex) below.

No released public command, key, class option, or default has been renamed or
removed in `v0.5.0`. Its statement class, A4 paper, sans body font, affiliation
key, and contact labels are additive and opt-in; existing documents need no
source edit. The `v0.4.0` break is in the toolchain, not the document API. Two
documents do render differently — the academic CV's folio and the academic
letter's page furniture — and neither requires a source edit; see step 5.

## Upgrading to `v0.4.0`: XeLaTeX → LuaLaTeX

`v0.4.0` makes LuaLaTeX the sole supported engine. XeLaTeX and pdfLaTeX now stop
with a fatal error from `careerdossier-typography`:

```text
CareerDossierTeX requires LuaLaTeX.
Compile with lualatex, not xelatex or pdflatex.
```

There is no compatibility mode and no option to bypass the guard. Stay on
`v0.2.1` if you cannot move to LuaLaTeX.

### What does not change

Classes, class options, profile keys, public commands, environments, paper size,
and theme are unchanged. An existing document that does not contain
XeTeX-specific preamble code needs no edit beyond the build command.

Two exceptions to "page design is unchanged": the academic CV's folio and the
academic letter's running header and footer both changed, so those two documents
render slightly differently. Neither needs a source edit. See step 5.

### 1. Change the build command

Before:

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex
```

After:

```bash
latexmk -lualatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex
```

Update editor and CI configuration too. In TeXShop, TeXworks, VS Code
(LaTeX Workshop), or Overleaf, select LuaLaTeX as the typesetting engine. A
stale `latexmkrc`, `.vscode/settings.json`, or CI workflow still passing
`-xelatex` is the most common cause of the engine error after upgrading.

Reason: LuaHBTeX writes real interword spaces into the PDF text layer and
supports the LaTeX kernel tagging pipeline. XeTeX supports neither, which capped
both extraction reliability (see `v0.2.1` and issue #72) and tagged output.

### 2. Remove XeTeX-only preamble code

`\XeTeXgenerateactualtext` and other `\XeTeX…` primitives do not exist under
LuaTeX and raise "undefined control sequence".

Before:

```latex
\XeTeXgenerateactualtext=1
```

After:

```latex
% Delete it. CareerDossierTeX never enabled this from v0.2.1 onward, and
% LuaHBTeX does not need it: interword spaces are real in the text layer.
```

Guards of the form `\ifXeTeX … \fi` should be deleted or inverted to
`\ifLuaTeX`. `iftex` still provides both.

Reason: the primitive is engine-specific. Under XeTeX it also wrapped every word
in its own `/ActualText` span, which made PDFKit-based readers merge adjacent
words — the bug fixed in `v0.2.1`.

### 3. Check fonts if you overrode them

CareerDossierTeX resolves TeX Gyre Termes and TeX Gyre Heros **by file name**
through `luaotfload`, so the default build does not depend on OS-installed
fonts. Documents that called `\setmainfont` with a system font *name* that
resolved through fontconfig under XeLaTeX may resolve differently under
`luaotfload`.

If you override fonts, recompile and check the log for font substitutions and
missing glyphs before trusting the output.

### 4. Re-check pagination

LuaHBTeX's line breaking is not byte-identical to XeTeX's. Page breaks can shift
by a line in long documents. Review multi-page CVs and two-page résumés after
upgrading rather than assuming identical pagination.

### 5. Review the academic CV and letter page furniture

`v0.4.0` changes the running headers and folios of two documents so that a CV
and an academic cover letter sent together look like one set. **No source edit
is required** — this is rendered output only, and no class, option, key, or
command changed.

Affects `careerdossier-cv` and `careerdossier-letter` with `family=academic`.
The industry letter and the résumé are **unaffected**: the industry letter keeps
its `v0.1` empty page style, and the résumé still prints no folio.

| | Before (`v0.2.x`) | After (`v0.4.0`) |
| --- | --- | --- |
| CV folio | `Page 2` | `Page 2 of 2` |
| CV running header (page 2+) | `Name — Curriculum Vitae` | unchanged |
| Academic letter running header | *none* | `Name — Cover Letter` from page 2 |
| Academic letter folio | `Name` at left, `Page 2 of 2` at right | centered `Page 2 of 2` |

Reasons, in short: a bare `Page 2` cannot tell a reader holding a loose sheet
whether the document ended, and the two classes previously disagreed on every
aspect of their page furniture. The letter adopted the CV's pattern rather than
the reverse, because a running header naming the person and document type on
continuation pages is the stronger convention for both academic CVs and formal
multi-page correspondence.

The academic letter's name has moved, not disappeared: it is in the running
header from page two, and the letterhead and signature block already carried it
on page one. On a single-page letter the old footer was a third occurrence.

**What to check after upgrading:**

- Multi-page academic CVs and letters, to confirm the new furniture looks right
  with your own name and content lengths. A long name in the running header is
  the case most worth a glance.
- Any tooling that parsed your PDFs' footer text.

  A **CV** footer extracted as `Page 1` and now extracts as `Page 1 of 2`.

  An **academic letter** footer used to contain the name as well as the folio,
  and now contains only `Page 1 of 2`. How that name appeared in extracted text
  varied with the extractor, the name's length, and the resulting gap: some
  fixtures extracted `Ada Lovelace Page 1 of 1` as a single line, others put the
  name on its own line above the folio. Either way the name is no longer in the
  footer, so a script keying on it will need updating.

  This is the same class of breakage as the `doi:` → `DOI:` extraction change in
  `v0.2.1`.

If you enable tagged structure (step 6), both the running header and the folio
are marked as layout artifacts, so screen readers skip them rather than reading
page furniture into the document's prose. Untagged output is unaffected, since
it carries no structure tree either way.

### 6. Optional: enable tagged structure

`v0.4.0` adds opt-in tagged semantic structure. It is off by default and
requires no migration. To try it, add `\DocumentMetadata` before
`\documentclass`:

```latex
\DocumentMetadata{lang=en, tagging=on}
\documentclass{careerdossier-resume}
```

Tagged output is a tested preview for the four fixture profiles only and carries
no PDF/UA, WCAG, or ATS conformance claim. See [`API.md`](API.md) for scope.

## Purpose

This file records migration paths for incompatible public changes once
implementation begins, per the stability policy in [`docs/API.md`](API.md).

Before `v1.0.0`, breaking changes are allowed but must be documented here and in
[`CHANGELOG.md`](../CHANGELOG.md) in the same pull request that introduces the
change.

## Entry format

When a public command, key, or option is renamed, changed, or removed, add an
entry using this shape:

```text
## [0.x.0] - YYYY-MM-DD

### `\OldCommand` renamed to `\NewCommand`

Before:

\OldCommand{...}

After:

\NewCommand{...}

Reason: <why the change was necessary>
```

No released public command, key, or option has been renamed or removed, so no
entry in this format exists yet. The `v0.4.0` engine change is a toolchain
break rather than an API rename and is documented in
[Upgrading to `v0.4.0`](#upgrading-to-v040-xelatex--lualatex) above.
