#!/usr/bin/env bash
set -euo pipefail

MILESTONE="v0.1.0 — English Industry Dossier"
PARENT="#2"

create_issue() {
  local title="$1"
  local labels="$2"
  local body="$3"

  echo "Creating issue: $title"

  gh issue create \
    --title "$title" \
    --milestone "$MILESTONE" \
    $(printf '%s' "$labels" | awk -F',' '{for (i=1;i<=NF;i++) printf "--label \"%s\" ", $i}') \
    --body "$body"
}

create_issue \
"[docs] Inventory current résumé and cover-letter implementations" \
"type:docs,type:refactor,area:resume,area:letter" \
"## Goal

Create a baseline inventory of the current résumé and cover-letter implementations before refactoring.

## Included

- Identify the best current résumé baseline.
- Identify the best current cover-letter baseline.
- Compile and save reference PDFs locally or as artifacts.
- Record current public commands and environments.
- Record current package dependencies.
- Identify duplicated implementation.
- Start the migration table.

## Excluded

- Rewriting the classes.
- Changing the public API.
- Adding new layouts.

## Likely files

- Existing résumé class files
- Existing cover-letter class files
- docs/MIGRATION.md
- docs/API.md

## Acceptance criteria

- [ ] Best résumé baseline identified.
- [ ] Best letter baseline identified.
- [ ] Reference PDFs compiled and saved locally or as artifacts.
- [ ] Public commands inventoried.
- [ ] Dependencies inventoried.
- [ ] Duplicate code identified.
- [ ] Migration table started.

## Parent and release

- Parent issue: $PARENT
- Milestone: $MILESTONE
- Project phase: Phase 1 — Industry"

create_issue \
"[docs] Define the v0.1 public API" \
"type:docs,area:core,area:documentation" \
"## Goal

Define the first small public API for CareerDossierTeX v0.1.0 before implementation.

## Included

- Profile keys.
- Letter keys.
- Public commands.
- Public environments.
- Required fields.
- Defaults.
- Unsupported features.

## Excluded

- Academic CV API.
- Bibliography API.
- Farsi or bilingual options.
- Statement-class API.

## Likely files

- docs/API.md
- docs/ROADMAP.md

## Acceptance criteria

- [ ] Profile keys documented.
- [ ] Letter keys documented.
- [ ] Commands and environments documented.
- [ ] Required fields documented.
- [ ] Defaults documented.
- [ ] Unsupported features clearly excluded.

## Parent and release

- Parent issue: $PARENT
- Milestone: $MILESTONE
- Project phase: Phase 1 — Industry"

create_issue \
"[core] Implement metadata storage and validation" \
"type:feature,area:core" \
"## Goal

Implement the shared metadata foundation used by the résumé and cover-letter classes.

## Included

- \`\\CDossierSetup\`.
- Metadata storage.
- Required-field validation.
- Optional-field checks.
- Safe field rendering.
- Clear errors and warnings.

## Excluded

- Résumé-specific layout.
- Letter-specific layout.
- Typography and theme styling.

## Likely files

- careerdossier-base.sty
- docs/API.md

## Acceptance criteria

- [ ] \`\\CDossierSetup\` exists.
- [ ] Required \`name\` is validated.
- [ ] Optional fields can be tested.
- [ ] Fields can be rendered safely.
- [ ] Errors are actionable.

## Parent and release

- Parent issue: $PARENT
- Milestone: $MILESTONE
- Project phase: Phase 1 — Industry"

create_issue \
"[theme] Implement XeLaTeX typography and monochrome tokens" \
"type:feature,area:typography,area:theme" \
"## Goal

Create the portable XeLaTeX typography and monochrome visual foundation for v0.1.0.

## Included

- XeLaTeX engine check.
- Clear pdfLaTeX error.
- Portable font setup.
- Semantic typography roles.
- Semantic monochrome color tokens.
- Print-safe link appearance.

## Excluded

- Farsi fonts.
- Font presets.
- Color themes.
- Icon support.

## Likely files

- careerdossier-typography.sty
- careerdossier-theme.sty

## Acceptance criteria

- [ ] pdfLaTeX receives a clear error.
- [ ] XeLaTeX loads portable fonts.
- [ ] Semantic typography roles exist.
- [ ] Semantic monochrome colors exist.
- [ ] Links remain readable in print.

## Parent and release

- Parent issue: $PARENT
- Milestone: $MILESTONE
- Project phase: Phase 1 — Industry"

create_issue \
"[components] Implement shared header and contact line" \
"type:feature,area:components" \
"## Goal

Implement reusable document components shared by the résumé and cover-letter classes.

## Included

- Identity block.
- Contact line.
- Optional-field separator handling.
- Link wrappers.
- Shared header or letterhead primitives.

## Excluded

- Résumé-only entry layout.
- Letter-only recipient block.
- Page geometry.

## Likely files

- careerdossier-components.sty
- careerdossier-base.sty
- careerdossier-theme.sty

## Acceptance criteria

- [ ] Name and headline render.
- [ ] Contact fields render as links where appropriate.
- [ ] Missing optional fields leave no duplicate separators.
- [ ] Components are reusable by résumé and letter.

## Parent and release

- Parent issue: $PARENT
- Milestone: $MILESTONE
- Project phase: Phase 1 — Industry"

create_issue \
"[resume] Implement the English résumé class" \
"type:feature,area:resume" \
"## Goal

Implement the first working English industry résumé class.

## Included

- Letter paper geometry.
- Résumé section command.
- Entry environment.
- Compact itemize environment.
- Page numbers disabled by default.
- Logical text extraction order.

## Excluded

- Academic CV behavior.
- Bibliography.
- Farsi or bilingual support.
- A4 paper.
- Color themes.

## Likely files

- careerdossier-resume.cls
- careerdossier-components.sty
- examples/industry/resume-english.tex

## Acceptance criteria

- [ ] Letter paper geometry implemented.
- [ ] \`\\CDossierSection\` implemented.
- [ ] \`CDossierEntry\` implemented.
- [ ] \`CDossierItemize\` implemented.
- [ ] Compact layout is readable.
- [ ] Page numbers are disabled by default.
- [ ] Text extraction order is logical.

## Parent and release

- Parent issue: $PARENT
- Milestone: $MILESTONE
- Project phase: Phase 1 — Industry"

create_issue \
"[letter] Implement the English industry cover-letter class" \
"type:feature,area:letter" \
"## Goal

Implement the first working English industry cover-letter class.

## Included

- Recipient block.
- Date.
- Optional subject.
- Salutation.
- Closing.
- Shared profile and letterhead.
- Acceptable one-page and two-page prose behavior.

## Excluded

- Academic letter family.
- Statement class.
- Farsi or bilingual support.
- A4 paper.

## Likely files

- careerdossier-letter.cls
- careerdossier-components.sty
- examples/industry/letter-industry.tex

## Acceptance criteria

- [ ] Recipient block implemented.
- [ ] Date, subject, salutation, and closing implemented.
- [ ] Shared profile and letterhead work.
- [ ] One-page and two-page prose page-breaking are acceptable.

## Parent and release

- Parent issue: $PARENT
- Milestone: $MILESTONE
- Project phase: Phase 1 — Industry"

create_issue \
"[test] Add Phase 1 examples and smoke tests" \
"type:test,area:resume,area:letter,area:build" \
"## Goal

Add repeatable examples and smoke tests for the Phase 1 résumé and cover letter.

## Included

- Shared profile example.
- Résumé example.
- Cover-letter example.
- Missing-name test.
- Missing optional-field tests.
- Long-link test.
- Text extraction command.

## Excluded

- Full l3build regression suite.
- Visual regression testing.
- Biber examples.

## Likely files

- examples/profiles/profile-english.tex
- examples/industry/resume-english.tex
- examples/industry/letter-industry.tex
- docs/API.md
- docs/CONTRIBUTING.md

## Acceptance criteria

- [ ] Shared profile example added.
- [ ] Résumé example added.
- [ ] Cover-letter example added.
- [ ] Missing-name test added.
- [ ] Missing-optional-field test added.
- [ ] Long-link test added.
- [ ] Text extraction command documented.

## Parent and release

- Parent issue: $PARENT
- Milestone: $MILESTONE
- Project phase: Phase 1 — Industry"

create_issue \
"[ci] Build Phase 1 examples in GitHub Actions" \
"type:ci,area:build" \
"## Goal

Add the first GitHub Actions workflow that verifies the supported examples compile.

## Included

- Workflow on pull requests.
- Workflow on pushes to main.
- XeLaTeX-capable build environment.
- Résumé build.
- Cover-letter build.
- PDF and log artifacts.
- Failed compilation fails the check.

## Excluded

- Release automation.
- Full matrix testing.
- l3build.
- Biber builds.

## Likely files

- .github/workflows/build.yml

## Acceptance criteria

- [ ] Workflow runs on pull requests.
- [ ] Workflow runs on pushes to \`main\`.
- [ ] Résumé compiles.
- [ ] Letter compiles.
- [ ] PDFs and logs upload as artifacts.
- [ ] Failed compilation fails the check.

## Parent and release

- Parent issue: $PARENT
- Milestone: $MILESTONE
- Project phase: Phase 1 — Industry"

create_issue \
"[docs] Prepare README, changelog, and release documentation" \
"type:docs,area:documentation" \
"## Goal

Prepare the user-facing and maintainer-facing documentation needed for v0.1.0.

## Included

- README quick start.
- Current support status.
- XeLaTeX requirement.
- Build commands.
- Changelog entry.
- Licence mention.
- Future scope clearly marked.

## Excluded

- Full manual.
- CTAN packaging documentation.
- Complete Phase 2 API docs.

## Likely files

- README.md
- CHANGELOG.md
- docs/API.md
- docs/ROADMAP.md
- docs/MIGRATION.md
- docs/CONTRIBUTING.md

## Acceptance criteria

- [ ] Quick start added.
- [ ] XeLaTeX requirement documented.
- [ ] Current scope documented.
- [ ] Future scope distinguished from current support.
- [ ] \`CHANGELOG.md\` contains \`0.1.0\`.
- [ ] Licence documented.

## Parent and release

- Parent issue: $PARENT
- Milestone: $MILESTONE
- Project phase: Phase 1 — Industry"

create_issue \
"[release] Publish v0.1.0" \
"type:release,area:build,area:documentation" \
"## Goal

Publish the first tagged GitHub Release for CareerDossierTeX.

## Included

- Close release-blocking issues.
- Confirm CI passes on main.
- Update version strings.
- Push tag.
- Create GitHub Release.
- Attach example PDFs.
- Close milestone.

## Excluded

- Automated release workflow.
- CTAN release.
- v0.2.0 features.

## Likely files

- CHANGELOG.md
- README.md
- docs/API.md
- .cls and .sty version strings

## Acceptance criteria

- [ ] All release-blocking issues closed.
- [ ] CI passes on \`main\`.
- [ ] Version strings updated.
- [ ] Tag \`v0.1.0\` pushed.
- [ ] GitHub Release created.
- [ ] Example PDFs attached.
- [ ] Milestone closed.

## Parent and release

- Parent issue: $PARENT
- Milestone: $MILESTONE
- Project phase: Phase 1 — Industry"

echo "Done creating Phase 1 issues."