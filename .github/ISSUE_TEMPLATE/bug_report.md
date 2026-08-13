---
name: Bug report
about: Report a reproducible LaTeX, layout, or build problem
title: "[area] "
labels: "type:bug"
assignees: ""
---

## Problem

Describe what happened.

## Expected behavior

Describe what should happen.

## Minimal example

```latex
\documentclass{careerdossier-resume}

\begin{document}
% Minimal reproducer
\end{document}
```

## Compile command

```bash
latexmk -lualatex -interaction=nonstopmode -halt-on-error example.tex
```

## Relevant log excerpt

```text
Paste the smallest useful log excerpt.
```

## Environment

- Operating system:
- TeX distribution and year:
- LuaLaTeX version:
- CareerDossierTeX version or commit:

## Regression information

- Did this work in an earlier release?
- First known failing version or commit:

## How this could be wrong

Only when this report names a *cause* or proposes a fix rather than reporting a
symptom. Name the smallest command that would show the diagnosis is wrong, and
record what happened when you ran it. `N/A` when the report stops at what was
observed, which is the ordinary case and is not a lesser report.

A symptom is evidence; a diagnosis is a claim. `AGENTS.md` rule 2 already
requires that a claim about a result be backed by a run, and a claim about a
cause is inherited unexamined by whoever implements the fix.

## Acceptance criteria

- [ ] Minimal reproducer passes.
- [ ] Existing examples still compile.
- [ ] A focused regression or stress test is added under `tests/` with the fix.
- [ ] Documentation is updated when behavior changes.
