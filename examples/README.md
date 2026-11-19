# Examples

Eleven complete documents, one per supported configuration, and the two
profiles they share. Every example uses only the public interface the manual
documents, and the personal data in them is fictional.

| Directory     | Holds                                                              |
| ------------- | ------------------------------------------------------------------ |
| `profiles/`   | the shared profiles: `profile-english.tex`, `profile-academic.tex` |
| `industry/`   | a resume and a cover letter, both on `profile-english.tex`         |
| `academic/`   | a CV, a CV with a BibLaTeX bibliography, and a letter              |
| `statements/` | one statement of each of six types                                 |

A profile is not a document: an example reads it with `\input`, and several
examples read the same one. That is the pattern to copy for your own
application.

## Building in the repository

From the repository root, `make` builds every example into `build/examples/`,
and `make help` lists the target for each one. A single example also builds
directly, from the repository root:

```bash
latexmk -lualatex examples/industry/resume-english.tex
```

## Building a copy outside the repository

Each example names its profile by a path from the repository root, such as
`examples/profiles/profile-english.tex`, so a copy placed in another directory
does not find it there. Two ways around that:

- **Keep the checkout and point TeX at it.** Set `TEXINPUTS` to the repository
  root, with a trailing colon so that TeX still searches its own tree. TeX then
  finds the classes, the packages, and the profile under that root:

  ```bash
  TEXINPUTS=/path/to/CareerDossierTeX: latexmk -lualatex resume-english.tex
  ```

  `academic/cv-bibliography.tex` also reads `publications.bib` by a path from
  the repository root, and Biber searches `BIBINPUTS`, not `TEXINPUTS`. Set
  both to the same value for that example. Without `BIBINPUTS` the build still
  ends without an error, and the bibliography is empty.

- **Take the files with you.** Install the classes and packages by one of the
  routes in [`README.md`](../README.md#installation), "Installation", copy the
  example and its profile into one directory, and change the `\input` line to
  the profile's new place, for example `\input{profile-english.tex}`.

If a build fails, or a PDF comes out empty, see "Troubleshooting" in the
manual, [`doc/careerdossier.tex`](../doc/careerdossier.tex).
