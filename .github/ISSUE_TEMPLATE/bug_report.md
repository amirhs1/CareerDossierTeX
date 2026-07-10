---
name: Bug report
about: Report a reproducible LaTeX, layout, or build problem
title: "[bug] "
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
latexmk -xelatex -interaction=nonstopmode -halt-on-error example.tex
```

## Relevant log excerpt

```text
Paste the smallest useful log excerpt.
```

## Environment

- Operating system:
- TeX distribution and year:
- XeLaTeX version:
- CareerDossierTeX version or commit:

## Regression information

- Did this work in an earlier release?
- First known failing version or commit:

## Acceptance criteria

- [ ] Minimal reproducer passes.
- [ ] Existing examples still compile.
- [ ] A regression test or stress example is added.
- [ ] Documentation is updated when behavior changes.
