# CareerDossierTeX GitHub Implementation Plan

## Purpose

This documentation set turns the long-term `CareerDossierTeX` architecture into a practical implementation and GitHub-learning plan.

The project remains a reusable XeLaTeX toolkit, but the release order is changed to match the immediate priority:

1. English industry résumé and cover-letter classes.
2. Academic CV and bibliography support.
3. Farsi, bilingual, and right-to-left support.
4. Statement classes, more themes, more languages, and packaging.
5. A stable `1.0.0` public API.

The architecture remains modular. The roadmap changes so that the smallest useful product can be finished first.

## Files in this documentation set

| File | Purpose |
|---|---|
| `01-PROJECT-SCOPE-AND-PHASES.md` | Revised phases, release boundaries, and acceptance criteria |
| `02-PHASE-1-IMPLEMENTATION-PLAN.md` | Technical implementation order for the English résumé and cover letter |
| `03-GITHUB-PROJECT-SETUP.md` | Step-by-step GitHub Project configuration |
| `04-MILESTONES-LABELS-AND-ISSUES.md` | Milestones, labels, parent issues, sub-issues, and issue backlog |
| `05-BRANCH-COMMIT-AND-PR-WORKFLOW.md` | Practical Git, branch, commit, and pull-request workflow |
| `06-CI-BRANCH-PROTECTION-AND-RELEASES.md` | GitHub Actions, status checks, branch rules, tags, and releases |
| `07-REPOSITORY-STRUCTURE-AND-DOCUMENTATION.md` | Phase-based repository layout and documentation responsibilities |
| `08-TONIGHT-EXECUTION-CHECKLIST.md` | Ordered checklist for the July 8, 2026 Phase 1 deadline |
| `templates/FEATURE-ISSUE.md` | Copyable feature issue template |
| `templates/BUG-ISSUE.md` | Copyable bug report template |
| `templates/PULL-REQUEST-TEMPLATE.md` | Copyable pull-request template |

## Recommended location in the repository

Commit these files under:

```text
docs/planning/
```

For example:

```text
CareerDossierTeX/
└── docs/
    └── planning/
        ├── 00-START-HERE.md
        ├── 01-PROJECT-SCOPE-AND-PHASES.md
        └── ...
```

The long-term architecture blueprint should become:

```text
docs/ARCHITECTURE.md
```

The live user-facing API should become:

```text
docs/API.md
```

## How the planning levels fit together

Use the following hierarchy:

```text
Architecture
  └── Roadmap phase
       └── Version milestone
            └── Parent issue or epic
                 └── Sub-issue
                      └── Feature branch
                           └── Pull request
                                └── Merge
                                     └── Tagged release
```

Each level has a distinct purpose:

- **Architecture** describes the intended system.
- **Roadmap** determines implementation order.
- **Milestone** represents a release.
- **Issue** defines a deliverable.
- **Branch** isolates work.
- **Pull request** records review and verification.
- **GitHub Actions** verifies the work automatically.
- **Release** publishes a known working version.

## Immediate goal

The first public release is:

```text
v0.1.0 — English Industry Dossier
```

It contains:

- `careerdossier-resume.cls`;
- `careerdossier-letter.cls`;
- shared English profile metadata;
- shared typography, theme, and header components;
- XeLaTeX support;
- Letter paper;
- monochrome output;
- one résumé example;
- one industry cover-letter example;
- a simple automated build;
- a tagged GitHub release.

The academic CV, bibliography support, Farsi, bilingual documents, and statement classes are explicitly outside the `v0.1.0` scope.
