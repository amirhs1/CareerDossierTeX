---
name: open-draft-pr
description: Open or update a CareerDossierTeX draft pull request — the close-out gate, the PR body, AI disclosure, and the push. Calls project-metadata for the fields. Use to open or update a draft pull request.
---

# Open or update a draft PR

Read and follow, in order:

1. `AGENTS.md`
2. `reference.md`, alongside this file
3. `.agents/skills/project-metadata/`, which owns every field this skill sets
4. `docs/NAMING-CONVENTION.md`
5. the focused GitHub issue and its current Project metadata

## When this runs

This skill is entered at step 7 of `AGENTS.md` ("How to work here") — after
the change has been implemented, verified, self-reviewed, and committed on a
focused branch. It opens a pull request; it does not implement anything.

So where a step below says *confirm*, the work itself belongs to the earlier
sequence and should already be done. A step that turns up undone work is a
finding: complete it on this branch before pushing, since the branch must be
close-out-complete at the first push. It is not a licence to start the work
here.

## Procedure

1. Confirm the current branch is focused and is not `main`.
2. Confirm the close-out inspection `reference.md` ("The first push is a
   commitment") requires is done: `git status --short` read, and the complete
   branch-versus-base diff reviewed with no unrelated files, generated
   artifacts, secrets, private data, or accidental deletions. Re-read the diff
   only when commits have landed since — on a shared worktree another session
   can add one. This step cites that inspection rather than repeating it; step 8
   is where the whole gate is confirmed.
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
10. Open or update the PR as a draft, then confirm the items in `reference.md`
    ("The four PR-only read-back items"): URL, draft status, base and head
    branches, and the focused issue the body links. Read the body back
    (`gh pr view <n> --json body`) and check it is the one you wrote.
11. Set and verify every field through the `project-metadata` skill — assignee,
    Project membership, labels, milestone, `Status`, `Phase`, `Priority`, and
    `Size`, then the read-back that closes them out. That skill is canonical for
    all of it, including which `Status` a newly opened draft takes and how
    `Size` is scored from the completed diff.
12. Close with the full report `.agents/skills/report-back/SKILL.md` ("Full
    form") defines, covering the branch as a whole. The step-11 read-back is the
    metadata payload of that report's `Test criteria` section, not a separate
    report.

Step 11 is one skill call, not eight fields.
`.agents/skills/project-metadata/reference.md`'s appendix opens the PR fully configured and
sets the rest in three `gh` calls, then reads it all back in a fourth — follow
that appendix rather than issuing one call per field, and read every literal
option string and id live from its discovery query. Never take one from prose in
this file or any other: the transcriptions drift, and a name that does not match
resolves to no option id.

## PR body template

`.github/pull_request_template.md` is the canonical section set. Use it verbatim
as the skeleton, keep its section order, and fill every section rather than
deleting the ones that seem empty. In order:

`Summary` → `Related issues` → `Problem` → `What changed` → `Public API impact`
→ `Checks run` → `Visual verification` → `Decisions and risks` →
`Notes for review` → `AI assistance`

`reference.md` states what belongs in each section.
**`AI assistance` is always last.**

The `Checks run` section carries no `GitHub Actions passes` checkbox, and one
must not be added by hand. `reference.md` ("PR body") gives the reason; it is
not repeated here.

When writing the body to a file for `gh pr create --body-file`, start from a
copy of the committed template so a section is never silently dropped, and keep
that copy outside the repository so it is never staged.

### AI assistance

Never leave this section as unfilled template text, and never omit it.

1. Read the branch's real `Assisted-by:` lines before writing the section:

   ```bash
   git log --format='%(trailers:key=Assisted-by,unfold)' "$(git merge-base origin/main HEAD)"..HEAD | sed '/^$/d' | sort -u
   ```

   The merge base keeps a stale local `main` from widening the range, `unfold`
   joins a value wrapped onto a second line, and `sed` drops the blank line
   each commit without the trailer prints.
2. Name each AI tool that materially shaped the contribution, its model if
   known (`not recorded` otherwise; never a guess), its role, and what it did
   in one clause. Each `Assisted-by:` line carries one of the six roles
   `AGENTS.md` ("Commit format") defines. `AI-POLICY.md` ("Disclosure")
   governs what is disclosed; the template's `None` covers a contribution with
   no AI help.
3. Repeat every line step 1 printed in the section, so the commit record and
   the PR record agree — `.github/pull_request_template.md`'s `AI assistance`
   section has the worked example. Prose may name the tool loosely; each
   `Assisted-by:` line must match the commit byte for byte. Codex additionally
   adds `Generated with Codex.` to the PR body.
4. Copy the lines from the commits, not from an example in this file or in the
   template — the examples drift, the commits do not.
5. Do not include prompts, private reasoning, secrets, or personal data.

`AI-POLICY.md` ("Disclosure") is normative for what is disclosed and for who
stays responsible. These steps are the procedure for satisfying it, not a
second statement of it.

## Boundaries

`AGENTS.md` ("Git") states the complete boundary on this delegation; it is not
restated here.

When Project access is unavailable — a missing `project` token scope, or
missing identifiers — `.agents/skills/project-metadata/SKILL.md` ("Boundaries") states the
fallback; it is not restated here.
