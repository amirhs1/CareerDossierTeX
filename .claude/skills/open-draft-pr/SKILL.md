---
name: open-draft-pr
description: Open or update a CareerDossierTeX draft pull request and populate its GitHub labels, milestone, assignee, and Project fields.
---

# Open or update a draft PR

Read and follow, in order:

1. `AGENTS.md`
2. `docs/agent-workflows/github-project.md`
3. `docs/NAMING-CONVENTION.md`
4. `scripts/setup-labels.sh`
5. the focused GitHub issue and its current Project metadata

## Procedure

1. Confirm the current branch is focused and is not `main`.
2. Review `git status --short` and the complete branch-versus-base diff.
3. Run relevant tests and record exact outcomes.
4. Build the PR title and body from the canonical naming and workflow documents.
5. Push only the focused feature branch.
6. Open or update the PR as a draft.
7. Assign `amirhs1`.
8. Add the PR to the `CareerDossierTeX Development` Project.
9. Apply one existing primary `type:*` label and all relevant `area:*` labels.
10. Inherit the focused issue's milestone, Phase, and Priority.
11. Set Status to `In progress`.
12. Estimate Size from the actual completed scope.
13. Verify every metadata field and report anything left unset.

## Boundaries

Do not mark the PR ready, merge, enable auto-merge, alter Project configuration,
or change release scope without explicit maintainer authorization.

If GitHub Projects access is unavailable (missing `project` token scope or
identifiers), still open the authorized draft PR, set all supported ordinary PR
metadata, and report exactly which Project fields could not be set.
