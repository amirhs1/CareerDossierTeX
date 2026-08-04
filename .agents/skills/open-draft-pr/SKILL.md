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
4. Build the PR title from `docs/NAMING-CONVENTION.md` and the PR body from the
   template below.
5. Complete the AI-assistance section from the branch's actual commit trailers.
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

## PR body template

`.github/pull_request_template.md` is the canonical section set. Use it verbatim
as the skeleton, keep its section order, and fill every section rather than
deleting the ones that seem empty. In order:

`Summary` → `Related issues` → `Changes` → `Public API impact` → `Testing` →
`Visual verification` → `Notes for review` → `AI assistance`

`docs/agent-workflows/github-project.md` states what belongs in each section.
**`AI assistance` is always last.**

When writing the body to a file for `gh pr create --body-file`, start from the
committed template so a section is never silently dropped:

```bash
cp .github/pull_request_template.md /tmp/pr-body.md   # then fill each section
```

### AI assistance

Never leave this section as unfilled template text, and never omit it.

1. Read the branch's real trailers before writing the section:

   ```bash
   git log --format='%(trailers:key=Co-authored-by)' main..HEAD | sort -u
   ```

2. Name each AI tool that materially shaped the contribution and summarize what
   it did in one clause. State `None` when no AI tool materially participated.
3. For every AI `Co-authored-by` trailer the branch commits carry, repeat that
   trailer's exact identity and email in the section so the commit record and
   the PR record agree. Example shape:

   ```text
   Claude Code — drafted the token refactor and its regression test.
   Co-authored-by: Claude Opus 5 <noreply@anthropic.com>
   ```

   The trailer identity is whatever the agent emitted, and it is not one fixed
   string. Claude Code's trailer carries the session's model, so this repository
   already contains both `Claude Opus 5` and `Claude Sonnet 5
   <noreply@anthropic.com>`; Codex writes `Codex <noreply@openai.com>` and adds
   `Generated with Codex.` to the PR body. Prose may name the tool loosely; the
   trailer line must match the commit byte for byte.

4. Copy the identity from the commits, not from an example in this file or in
   `AGENTS.md`. Do not invent a trailer for a tool that did not participate, do
   not substitute a hard-coded vendor or model identity for the agent's actual
   configured attribution, and do not add a second equivalent trailer.
5. Do not include prompts, private reasoning, secrets, or personal data.

Disclosure does not transfer responsibility for the change. `AI-POLICY.md` holds
the policy; `AGENTS.md` holds the commit-trailer rules.

## Boundaries

Do not mark the PR ready, merge, enable auto-merge, alter Project configuration,
or change release scope without explicit maintainer authorization.

If GitHub Projects access is unavailable (missing `project` token scope or
identifiers), still open the authorized draft PR, set all supported ordinary PR
metadata, and report exactly which Project fields could not be set.
