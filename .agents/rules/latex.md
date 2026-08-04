---
paths:
  - "**/*.tex"
  - "**/*.sty"
  - "**/*.cls"
  - "**/*.dtx"
  - "**/*.ins"
---

# CareerDossierTeX LaTeX rules

These rules complement `AGENTS.md` and load only for LaTeX source files.

- Use LuaLaTeX. It is the sole supported engine; XeLaTeX and pdfLaTeX must fail
  early with an actionable error.
- Confirm the change belongs to the owning module before editing.
- Keep metadata separate from layout and styling.
- Use the `CDossier` prefix for public commands and environments.
- Use private LaTeX3 names of the form
  `\__cdossier_<module>_<action>:<signature>`.
- Prefer `l3keys` and modern kernel or `xparse` interfaces.
- Reject unsupported options clearly.
- Render optional fields by joining present items with separators.
- Compile affected supported examples when execution is available.
- Inspect logs for errors, undefined controls, overfull boxes, missing glyphs,
  font substitutions, and unresolved references.
- For layout changes, inspect rendered pages, page breaks, clipping, links,
  contact lines, print/grayscale behavior, and text extraction order.
- Do not claim accessibility or PDF/UA conformance without suitable validation.
- Tagged structure is opt-in through `\DocumentMetadata{tagging=on}`. Keep the
  untagged path unchanged when editing tagging code.
