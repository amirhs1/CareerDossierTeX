# CI, Branch Protection, and Releases

## 1. GitHub Actions purpose

Continuous integration should answer:

```text
Does each committed behavior still pass its focused test?
Can the supported examples compile from a clean GitHub runner?
```

For Phase 1, CI grows with the project: a test is added to CI as soon as the
corresponding behavior and test runner exist. Tests are not saved for a
milestone-end batch.

Official documentation:

- https://docs.github.com/actions
- https://docs.github.com/actions/concepts/workflows-and-actions/workflow-artifacts

## 2. First workflow responsibilities

Create:

```text
.github/workflows/build.yml
```

The workflow should:

- run on pull requests;
- run on pushes to `main`;
- check out the repository;
- install or invoke a XeLaTeX-capable TeX environment;
- run every applicable suite under `tests/`;
- compile the résumé example;
- compile the letter example;
- preserve PDFs and logs as artifacts;
- fail if compilation fails.

## 3. Example workflow structure

The exact TeX installation action must be selected and pinned when implemented. Do not copy an unmaintained third-party action without checking it.

Conceptual example:

```yaml
name: Build examples

on:
  pull_request:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Check out repository
        uses: actions/checkout@v4

      - name: Install TeX dependencies
        run: |
          # Install a tested XeLaTeX environment here.

      - name: Build résumé
        run: |
          latexmk -xelatex -interaction=nonstopmode -halt-on-error \
            examples/industry/resume-english.tex

      - name: Build cover letter
        run: |
          latexmk -xelatex -interaction=nonstopmode -halt-on-error \
            examples/industry/letter-industry.tex

      - name: Upload PDFs and logs
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: phase-1-build
          path: |
            examples/industry/*.pdf
            examples/industry/*.log
```

Use the current supported major version of `actions/upload-artifact`. Check official action documentation when implementing because action versions can change.

## 4. Artifact use

Workflow artifacts are useful for:

- downloading the compiled PDFs;
- inspecting logs after failure;
- comparing output from a pull request;
- proving that the project builds on a clean environment.

Artifacts are temporary build outputs. A GitHub Release is the correct place for long-lived release assets.

## 5. Add quality checks with the behavior they protect

As soon as basic compilation works, add:

```bash
grep -E "LaTeX Error|Undefined control sequence|Emergency stop" file.log
```

Add the relevant checks in the same PR as behavior that can trigger them:

- overfull boxes;
- undefined citations;
- unresolved references;
- missing glyphs;
- font substitution;
- page count;
- text extraction.

Do not make every warning fatal immediately. First understand which warnings are meaningful and stable enough to enforce.

## 6. Branch rules for `main`

Do not enable a required status check before that check has successfully run in the repository.

After the workflow works:

1. Open repository **Settings**.
2. Open **Rules** or **Branches**, depending on the current GitHub interface.
3. Create a branch ruleset or protection rule targeting `main`.
4. Require a pull request before merging.
5. Require the build status check.
6. Require conversation resolution.
7. Block force pushes.
8. Block deletion.
9. Optionally require linear history.

Official documentation:

- https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches
- https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets

## 7. Solo-developer branch-rule recommendation

Enable:

- pull request required;
- status checks required;
- conversation resolution;
- no force pushes;
- no deletion.

Avoid initially requiring:

- one external approval;
- code-owner approval;
- merge queue.

Those are useful for teams but can unnecessarily block a solo practice repository.

## 8. Release preparation

Before tagging:

```bash
git switch main
git pull --ff-only
```

Confirm:

```bash
git status
```

The working tree should be clean.

Run:

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/resume-english.tex

latexmk -xelatex -interaction=nonstopmode -halt-on-error \
  examples/industry/letter-industry.tex

make extract-test
```

Also run every other committed suite under `tests/`. Release preparation is a
full rerun of coverage accumulated during implementation, not the point where
feature tests are first created.

Update:

- version strings in `.cls` and `.sty` files;
- `CHANGELOG.md`;
- README status;
- API documentation.

Commit release preparation through a PR:

```text
release: prepare v0.1.0
```

## 9. Create the Git tag

After the release-preparation PR is merged:

```bash
git switch main
git pull --ff-only
git tag -a v0.1.0 -m "Release v0.1.0: English industry dossier"
git push origin v0.1.0
```

A tag identifies the exact source commit for the release.

## 10. Create the GitHub Release

1. Open the repository.
2. Open **Releases**.
3. Select **Draft a new release**.
4. Choose tag `v0.1.0`.
5. Set title:
   `CareerDossierTeX v0.1.0 — English Industry Dossier`
6. Write concise release notes.
7. Attach the résumé and cover-letter PDFs.
8. Publish the release.
9. Close the `v0.1.0` milestone.

Official documentation:

- https://docs.github.com/repositories/releasing-projects-on-github/about-releases

## 11. Suggested release notes

```markdown
## CareerDossierTeX v0.1.0

The first working release provides a shared XeLaTeX foundation for an
English industry résumé and matching cover letter.

### Included

- English résumé class
- English industry cover-letter class
- shared profile metadata
- monochrome Letter-paper layout
- reusable header and contact components
- XeLaTeX example builds
- GitHub Actions compilation

### Not yet included

- academic CV
- bibliography and Biber support
- Farsi or bilingual layouts
- statement classes
- A4 and color themes

See `CHANGELOG.md` and `docs/API.md` for details.
```

## 12. CI maturity path

### `v0.1.0`

- run Phase 1 regression, smoke, layout, and extraction suites as they land;
- compile two examples;
- upload artifacts.

### `v0.2.0`

- extend the existing regression harness for academic behavior;
- build Biber example;
- inspect logs;
- test long CV.

### `v0.3.0`

- build Farsi and bilingual examples;
- test mixed-direction fields;
- check fonts and extracted text.

### `v1.0.0`

- test all documented configurations;
- compile manual;
- create release package;
- validate Overleaf-compatible ZIP.
