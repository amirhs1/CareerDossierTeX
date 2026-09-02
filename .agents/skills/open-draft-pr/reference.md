# GitHub Project and draft pull-request workflow

This is the canonical repository procedure for opening or updating a draft pull
request and populating its GitHub metadata. It applies to every agent.

## Authority boundary

A draft PR is a work-in-progress review container, not maintainer approval.

When implementation of a focused issue is authorized, the agent may create
feature-branch commits, push that non-`main` branch, open or update a draft PR,
and populate routine metadata.

`AGENTS.md` rule 11 (Maintainer authority) states the complete boundary on this
delegation; it is not restated here.

## Sources of truth

Before setting metadata, inspect:

1. the focused issue;
2. `docs/NAMING-CONVENTION.md`;
3. the issue's milestone;
4. the issue's current Project fields;
5. existing PR metadata when updating a PR.

Do not invent labels, milestones, field names, or single-select values. Preserve
existing remote metadata unless the current work clearly requires a change.

If directly authorized work has no focused issue, stop before the first push and
ask the maintainer whether to create or select one and which release metadata
applies. Do not invent a milestone, Phase, or Priority to fill the gap.

`CONTRIBUTING.md` "Work item structure" names the three kinds of work exempt
from needing a focused issue, and is not repeated here. For those, proceed
without stopping, but state the problem, the proposal, and the acceptance
criteria in the PR body — the exemption is from the issue object, not from the
reasoning. Set the milestone from the release the work lands in; leave
Phase and Priority to follow it as usual. Anything outside those three still
stops for the maintainer.

Once a focused issue exists, its own metadata governs: inherit what the issue
has, and where the issue itself has no Phase or Priority, leave that PR field
unset and name the missing issue field — see
`.agents/skills/project-metadata/reference.md` ("Project field values" and
"Verification"). The rule above is about opening a
PR with no focused issue at all, not about an issue whose fields are
incomplete.

If GitHub metadata conflicts with repository documentation, report the conflict
and preserve the existing remote value until the maintainer decides.

## Before opening a draft PR

### The first push is a commitment

The maintainer's merge trigger is green CI. A branch that arrives incomplete is
therefore either approved before its missing parts land, or loses them with the
deleted branch. Push only a **close-out-complete** branch — one that needs
nothing further before it could be approved. This section is the canonical
statement of that gate, and `AGENTS.md` "Git and draft PR policy" points here.

An agent that wants early signal runs `make check` locally. It does not push a
partial branch to borrow CI.

One narrow exception: a fact that can only be read from a CI artifact — the
TeX Live release behind a newly pinned digest, per `CONTRIBUTING.md` "Bumping
the pinned TeX Live image" — is recorded in the PR after the run. The branch
still arrives complete in every other respect; the exception is the one
recorded value, not the close-out.

**Green CI is not a completion signal.** The checks build and test LaTeX. No
check reads the PR body's `AI assistance` section, `CHANGELOG.md`, the
documentation rule 7 requires, or the Project fields — precisely the items most
likely to be missing. A green run therefore carries no information about them,
and it is not the author's attestation that they are done.

Anything genuinely discovered after a push — a CI-only failure, a real defect —
goes in the **first line of the next message**, not its last paragraph. A
discovery that falls outside the issue's scope becomes a follow-up issue rather
than extra commits that move the branch's endpoint.

### The gate applied to opening a PR

Confirm:

- the branch is not `main`;
- the focused issue is identified, or one of the three exemptions applies and
  the PR body carries the rationale in its place;
- the issue carries a milestone;
- the diff is limited to the issue;
- behavior changes include their focused committed tests under `tests/` rather
  than deferring them to a later milestone task;
- relevant tests and checks were run, and their exact outcomes recorded;
- the documentation those changes require is updated in the same change;
- `CHANGELOG.md` is updated when the change is user-visible;
- the PR body is written in full, including its `AI assistance` section built
  from the branch's real trailers;
- no generated artifacts, secrets, private data, or unrelated changes are included;
- API, docs, design, and accessibility impacts are documented;
- the PR title follows `docs/NAMING-CONVENTION.md`.

Nothing on this list may be deferred to a follow-up commit after the push, and
green CI discharges none of it.

## PR body

`.github/pull_request_template.md` is the canonical section set. Keep its
section order and fill every section. In order:

- **Summary** — concise statement of the change and its purpose;
- **Related issues** — `Closes #NN` for the focused issue when the PR should
  complete it;
- **Changes** — the change list;
- **Public API impact**;
- **Testing** — tests run and exact outcomes, and tests added or updated under
  `tests/`, including the expected pre-fix failure when it was demonstrated;
- **Visual verification** — visual and accessibility checks when relevant;
- **Notes for review** — design decisions, known limitations, follow-up work,
  and documentation/changelog impact;
- **AI assistance** — last, and never omitted or left as template text.
  `AI-POLICY.md` ("Attribution") is normative for the obligation and
  `SKILL.md` ("AI assistance") holds the procedure; neither is repeated here.

The `Testing` section carries no `GitHub Actions passes` checkbox, and one must
not be added by hand. The body is written before the first push, so no workflow
has run when it is composed — the box could only be left unticked or ticked
against `AGENTS.md` rule 2 (verification honesty). The live check-run status is
already on the PR, and green CI is not a completion signal, so it is not
something the author attests to.

Do not close the parent epic from a focused implementation PR.

## Routine metadata

After opening or updating the draft PR:

1. Assign the PR to `amirhs1`.
2. Add it to the `CareerDossierTeX Development` Project.
3. Link the focused issue in the PR body.
4. Inherit the focused issue's milestone.
5. Apply exactly one primary existing `type:*` label.
6. Apply every relevant existing `area:*` label.
7. Apply `blocked`, `technical-debt`, or `breaking-change` only when genuinely
   applicable and explained in the PR body.
8. Populate applicable Project fields.
9. Verify and report the final metadata.

Items 1, 2, and 4–9 are not PR-specific, and the `project-metadata` skill owns
them for issues and pull requests alike: which value each field takes, the
`Size` guide, label selection, `Status` transitions, what is pre-authorized, and
the read-back that closes them out. Follow
`.agents/skills/project-metadata/reference.md` rather than a second statement of
it here — a second copy is what let the two skill sets drift apart before this
layout.

Item 3 is the exception that stays here, because a PR body is the only place a
`Closes #...` link can live. "PR body" above states it.

## The four PR-only read-back items

`.agents/skills/project-metadata/reference.md` ("Verification") is canonical
for the read-back:
what must be asserted rather than eyeballed, that a blank field is unfinished
work rather than a reporting line, and which blanks are legitimate. It is not
repeated here.

Four items exist only on a pull request, and this skill adds them to that
read-back rather than running a second one:

- PR URL and draft status;
- base and head branches;
- the focused issue the body links;
- the `L`-scored PR's extra obligation — stay draft and recommend splitting,
  unless broad scope was already approved.

The appendix in `.agents/skills/project-metadata/reference.md` reads the
repository metadata
and both items' Project fields in **one** query, PR-only fields included, so
these four cost no call of their own.

The read-back is not a report of its own. `AGENTS.md` "Completion report"
defines the one report shape and states that this list is the metadata payload
of its `Test criteria` section. Close with that report — seven sections, one
verdict, covering the branch as a whole and not only its metadata.
