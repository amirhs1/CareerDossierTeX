# Phase 1 Implementation Plan

## Objective

Finish a working English résumé class and English industry cover-letter class using shared components.

Target release:

```text
v0.1.0 — English Industry Dossier
```

## 1. Technical dependency order

Implement in this order:

```text
API definition
  → engine and metadata base + focused tests
  → typography and theme + focused tests
  → shared components + focused tests
  → résumé class + example + focused tests
  → letter class + example + focused tests
  → GitHub Actions
  → documentation
  → release
```

Do not start with every planned class. Build one complete vertical slice.
Do not place tests at the end of this sequence. Each implementation step adds
the relevant fixture, runner, or baseline under `tests/` in the same branch.
Write the test first when practical and confirm it fails for the intended reason.

## 2. Step 1: define the public API

Create `docs/API.md` before implementation.

Document:

- supported engine;
- supported paper size;
- supported theme;
- profile keys;
- letter keys;
- commands;
- environments;
- defaults;
- required and optional fields;
- error behavior;
- experimental versus stable features.

For `v0.1.0`, keep the API deliberately small.

## 3. Step 2: implement `careerdossier-base.sty`

Responsibilities:

- define `\CDossierSetup`;
- store metadata;
- provide field access;
- test whether a field exists;
- validate required fields;
- report actionable warnings and errors;
- provide shared setup keys.

Suggested public accessors:

```latex
\CDossierPrintField{name}

\CDossierIfFieldTF{phone}
  {<present>}
  {<absent>}
```

Do not put margins or résumé-specific spacing here.

Add regression fixtures under `tests/regression/` for key parsing, blank-value
handling, overwrites, unknown keys and fields, and required-name validation as
part of this step.

## 4. Step 3: implement `careerdossier-i18n.sty`

Phase 1 responsibilities:

- centralize fixed English labels;
- expose a small translation lookup;
- provide neutral wrappers for text direction;
- leave extension points for Phase 3.

For example:

```latex
\CDossierLabel{experience}
\CDossierLabel{education}
```

Do not implement unused Farsi code tonight. Do not hard-code English labels directly in every class.

Add label lookup and unknown-label coverage under `tests/regression/` with this
module.

## 5. Step 4: implement `careerdossier-typography.sty`

Responsibilities:

- detect XeLaTeX;
- load `fontspec`;
- define default fonts available in TeX Live;
- define semantic roles.

Suggested roles:

```latex
\CDossierNameStyle
\CDossierHeadlineStyle
\CDossierSectionStyle
\CDossierEntryTitleStyle
\CDossierBodyStyle
\CDossierMutedStyle
```

Default fonts should be portable. Custom Merriweather or Neuton presets can be restored later after the public API is stable.

Add XeLaTeX success, unsupported-engine failure, font/glyph, and extraction
coverage under the appropriate `tests/regression/` and `tests/extraction/`
directories with this module.

## 6. Step 5: implement `careerdossier-theme.sty`

Phase 1 responsibilities:

- monochrome semantic colors;
- rule thicknesses;
- link appearance;
- print-safe visual hierarchy.

Use semantic tokens, even when all are black or gray:

```latex
\CDossierPrimaryColor
\CDossierTextColor
\CDossierMutedColor
\CDossierRuleColor
\CDossierLinkColor
```

This makes later color themes an extension rather than a rewrite.

Add focused token and link-configuration tests under `tests/regression/`; keep
rendered/grayscale inspection requirements with the layout fixtures that use the
theme.

## 7. Step 6: implement `careerdossier-components.sty`

Responsibilities:

- identity block;
- contact line;
- optional-field separators;
- hyperlink wrappers;
- common entry heading;
- reusable date and location primitives.

Critical behavior:

```text
email | phone | website
```

must become:

```text
email | website
```

when phone is missing, not:

```text
email | | website
```

The component layer must expose reusable pieces without forcing the résumé and letter into identical page geometry.

Add committed separator, link-target, missing-name, and long-contact fixtures
under `tests/regression/` and `tests/layout/` as part of the component change.

## 8. Step 7: implement `careerdossier-resume.cls`

Responsibilities:

- Letter paper geometry;
- compact section spacing;
- résumé-specific entry layout;
- controlled lists;
- page numbers disabled by default;
- logical source and extraction order.

Initial options:

```text
fontsize=10pt|11pt
density=compact|standard
```

Fixed in `v0.1.0`:

```text
paper=letter
theme=monochrome
language=english
```

It is better to omit unsupported options than accept them while ignoring them.

Add the valid build, option/error, missing-field, long-value, two-page, and
reading-order fixtures under `tests/smoke/`, `tests/regression/`,
`tests/layout/`, and `tests/extraction/` with the résumé implementation.

## 9. Step 8: implement `careerdossier-letter.cls`

Responsibilities:

- industry letter geometry;
- date and recipient block;
- optional subject;
- salutation and closing;
- shared letterhead;
- page-breaking appropriate for prose.

Fixed in `v0.1.0`:

```text
family=industry
paper=letter
theme=monochrome
language=english
```

The future `family=academic` option belongs to Phase 2.

Add the valid build, option/error, optional-subject, one-page, two-page, and
page-break fixtures under `tests/smoke/`, `tests/regression/`, and
`tests/layout/` with the letter implementation.

## 10. Step 9: create shared-profile examples

Create:

```text
examples/profiles/profile-english.tex
examples/industry/resume-english.tex
examples/industry/letter-industry.tex
```

The profile file contains personal metadata only.

The résumé and cover letter contain document-specific content only.

This demonstrates separation of data and presentation.

Examples are user-facing documentation. Tests may compile them, but focused test
fixtures remain under `tests/` and are introduced with the behavior they cover.

## 11. Continuous test matrix for Steps 2--9

This matrix applies throughout implementation; it is not a later project step.
Add each case when the behavior it covers is introduced, run the focused case
while developing, and expand the full-suite run as the repository grows.

Minimum test cases:

1. Valid résumé.
2. Valid cover letter.
3. Missing required name.
4. Missing optional phone.
5. Missing optional website.
6. Long LinkedIn URL.
7. Two-page résumé stress example.
8. Text extraction with `pdftotext`.

Suggested commands:

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex

latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/letter-industry.tex

pdftotext examples/industry/resume-english.pdf \
  build/resume-english.txt
```

Do not claim these tests pass until they have actually been run.

## 12. Step 10: add GitHub Actions

The first workflow should:

- run on pull requests and pushes to `main`;
- install a pinned or explicitly chosen TeX environment;
- run every applicable committed suite under `tests/`;
- compile the résumé;
- compile the letter;
- upload PDFs and logs as artifacts;
- fail when a test or compilation fails.

Do not introduce the release workflow before the build workflow is reliable.

## 13. Step 11: document and release

Update:

```text
README.md
CHANGELOG.md
docs/API.md
docs/ROADMAP.md
docs/MIGRATION.md
```

Then:

```bash
git tag -a v0.1.0 -m "Release v0.1.0: English industry dossier"
git push origin v0.1.0
```

Create a GitHub Release and attach:

- source ZIP;
- résumé example PDF;
- cover-letter example PDF;
- optional compiled documentation.

## 14. Phase 1 definition of done

Phase 1 is done when the release is usable by someone who did not write the classes.

That person should be able to:

1. clone or download the repository;
2. edit the profile file;
3. edit the résumé and letter content;
4. compile with XeLaTeX;
5. receive clear errors for invalid required metadata;
6. build the same examples in GitHub Actions;
7. run the committed tests that were added throughout implementation;
8. download a known release.
