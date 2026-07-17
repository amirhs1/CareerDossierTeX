---
name: open-draft-pr
description: Open or update a CareerDossierTeX draft pull request and populate its GitHub labels, milestone, assignee, and Project fields.
---

# Open or update a draft PR

Read and follow, in order:

1. `AGENTS.md`
2. `docs/agent-workflows/github-project.md`
3. `docs/naming_conventions.md`
4. `scripts/setup-labels.sh`
5. the focused GitHub issue and its current Project metadata

## Procedure

1. Confirm the current branch is focused and is not `main`.
2. Review `git status --short` and the complete branch-versus-base diff.
3. Run relevant tests and record exact outcomes.
4. Build the PR title and body from the canonical naming and workflow documents.
5. Confirm the PR disclosure repeats the identity and email from every AI
   co-author trailer in the branch commits.
6. If no focused issue exists, stop before pushing and obtain the maintainer's
   explicit decision about issue creation and release metadata.
7. Push only the focused feature branch.
8. Open or update the PR as a draft.
9. Assign `amirhs1`.
10. Add the PR to the `CareerDossierTeX Development` Project.
11. Apply one existing primary `type:*` label and all relevant `area:*` labels.
12. Inherit the focused issue's milestone, Phase, and Priority.
13. Set Status to `In progress`.
14. Estimate Size from the actual completed scope.
15. Verify every metadata field and report anything left unset.

## Boundaries

Do not mark the PR ready, merge, enable auto-merge, alter Project configuration,
or change release scope without explicit maintainer authorization.

If GitHub Projects access is unavailable (missing `project` token scope or
identifiers), still open the authorized draft PR, set all supported ordinary PR
metadata, and report exactly which Project fields could not be set.
