---
name: open-draft-pr
description: Open or update a CareerDossierTeX draft pull request and populate its GitHub labels, milestone, assignee, and Project fields.
---

# Open or update a draft PR

Read and follow, in order:

1. `AGENTS.md`
2. `reference.md`, alongside this file
3. `docs/NAMING-CONVENTION.md`
4. `scripts/setup-labels.sh`
5. the focused GitHub issue and its current Project metadata

## When this runs

This skill is entered at step 7 of `AGENTS.md` "Default work sequence" — after
the change has been implemented, verified, self-reviewed, and committed on a
focused branch. It opens a pull request; it does not implement anything.

So where a step below says *confirm*, the work itself belongs to the earlier
sequence and should already be done. A step that turns up undone work is a
finding: complete it on this branch before pushing, since the branch must be
close-out-complete at the first push. It is not a licence to start the work
here.

## Procedure

1. Confirm the current branch is focused and is not `main`.
2. Review `git status --short` and the complete branch-versus-base diff.
3. Confirm the relevant tests were run and record their exact outcomes for the
   PR body. Re-run anything whose recorded result is older than the last commit.
4. Confirm the documentation the change requires is updated, and `CHANGELOG.md`
   when the change is user-visible.
5. Build the PR title from `docs/NAMING-CONVENTION.md` and the PR body from the
   template below.
6. Complete the AI-assistance section from the branch's actual commit trailers.
7. If no focused issue exists, stop before pushing and obtain the maintainer's
   explicit decision about issue creation and release metadata.
8. Confirm the branch is close-out-complete against `reference.md` ("Before
   opening a draft PR"). Steps 2–6 are that gate; nothing on it may be deferred
   to a commit after the push, and green CI does not discharge any of it.
9. Push only the focused feature branch.
10. Open or update the PR as a draft.
11. Assign `amirhs1`.
12. Add the PR to the `CareerDossierTeX Development` Project.
13. Apply one existing primary `type:*` label and all relevant `area:*` labels.
14. Inherit the focused issue's milestone, Phase, and Priority.
15. Set Status to the Project's in-progress option.
16. Estimate Size from the actual completed scope.
17. Read every field back from GitHub, fill anything still blank, and read back
    again. A blank is unfinished work, not a reporting line. `reference.md`
    ("Verification") says which fields have no legitimate blank value and holds
    the queries.
18. Close the report with the single completion verdict `AGENTS.md`
    ("Completion report") requires, covering the branch as a whole.

`docs/NAMING-CONVENTION.md` section 9 defines which `Status` to use and section
10 the `Phase` numbering; `reference.md` ("Project field values") covers the
rest. Copy every literal option string from `gh project field-list`, never from
prose in this file or any other — the transcriptions drift, and a name that does
not match sets nothing without reporting an error.

## PR body template

`.github/pull_request_template.md` is the canonical section set. Use it verbatim
as the skeleton, keep its section order, and fill every section rather than
deleting the ones that seem empty. In order:

`Summary` → `Related issues` → `Changes` → `Public API impact` → `Testing` →
`Visual verification` → `Notes for review` → `AI assistance`

`reference.md` states what belongs in each section.
**`AI assistance` is always last.**

The `Testing` section carries no `GitHub Actions passes` checkbox. Do not add
one: the body is written before the first push, so no workflow has run when it
is composed, and the line could only be left unticked or ticked against
`AGENTS.md` rule 2. The real check-run status is already on the PR.

When writing the body to a file for `gh pr create --body-file`, start from a
copy of the committed template so a section is never silently dropped, and keep
that copy outside the repository so it is never staged.

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
