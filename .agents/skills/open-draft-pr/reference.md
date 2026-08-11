# GitHub Project and draft pull-request workflow

This is the canonical repository procedure for opening or updating a draft pull
request and populating its GitHub metadata. It applies to every agent.

## Authority boundary

A draft PR is a work-in-progress review container, not maintainer approval.

When implementation of a focused issue is authorized, the agent may create
feature-branch commits, push that non-`main` branch, open or update a draft PR,
and populate routine metadata.

The maintainer alone may mark the PR ready, approve, merge, enable auto-merge,
change release scope, publish releases, or alter Project/repository configuration.

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

Three kinds of work are exempt from needing a focused issue, per
`CONTRIBUTING.md` "Work item structure": a revert of a merged change, a release
chore, and a CI/tooling repair that restores an existing check. For these,
proceed without stopping, but state the problem, the proposal, and the
acceptance criteria in the PR body — the exemption is from the issue object, not
from the reasoning. Set the milestone from the release the work lands in; leave
Phase and Priority to follow it as usual. Anything outside those three still
stops for the maintainer.

Once a focused issue exists, its own metadata governs: inherit what the issue
has, and where the issue itself has no Phase or Priority, leave that PR field
unset and name the missing issue field — see "Project field values" and
"Verification". The rule above is about opening a PR with no focused issue at
all, not about an issue whose fields are incomplete.

If GitHub metadata conflicts with repository documentation, report the conflict
and preserve the existing remote value until the maintainer decides.

## Before opening a draft PR

Confirm:

- the branch is not `main`;
- the focused issue is identified, or one of the three exemptions applies and
  the PR body carries the rationale in its place;
- the issue carries a milestone;
- the diff is limited to the issue;
- behavior changes include their focused committed tests under `tests/` rather
  than deferring them to a later milestone task;
- relevant tests and checks were run;
- no generated artifacts, secrets, private data, or unrelated changes are included;
- API, docs, design, and accessibility impacts are documented;
- the PR title follows `docs/NAMING-CONVENTION.md`.

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
- **AI assistance** — last, and never omitted or left as template text. Name
  each AI tool that materially shaped the contribution and its role, or state
  `None`. When a branch commit carries an AI `Co-authored-by` trailer, repeat
  that trailer's exact identity and email so the commit and PR records agree.
  Read the trailers rather than recalling them:

  ```bash
  git log --format='%(trailers:key=Co-authored-by)' main..HEAD | sort -u
  ```

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

## Project field values

For a newly opened draft PR:

- **Status:** the in-progress option — `docs/NAMING-CONVENTION.md` section 9 for
  what it means, `gh project field-list` for how it is spelled
- **Phase:** inherit from the focused issue
- **Priority:** inherit from the focused issue
- **Size:** estimate from the actual completed PR scope
- **Start date:** leave unset for routine PRs
- **Target date:** leave unset for routine PRs

### Size guide

- `XS` — one small localized edit
- `S` — one focused change with limited tests or documentation
- `M` — several related files or one meaningful feature
- `L` — broad work that should normally be split

If the PR is `L`, keep it draft and recommend splitting it unless broad scope was
already approved.

Do not infer a higher priority than the focused issue. If Phase or Priority is
missing, leave the corresponding PR field unset and report it.

## Label selection

Use only labels that already exist on the repository. Read them live rather than
from any list in the tree:

```bash
gh label list --limit 100
```

| Change | Labels |
| --- | --- |
| Public resume feature | `type:feature`, `area:resume` |
| Contact-line bug | `type:bug`, `area:components` |
| API documentation clarification | `type:docs`, `area:documentation` |
| Typography implementation | `type:feature`, `area:typography` |
| GitHub Actions change | `type:ci`, `area:build` |
| Theme restructuring without behavior change | `type:refactor`, `area:theme` |
| Agent instructions, skills, or workflow docs | `type:docs`, `area:agents` |
| Agent sandbox, permissions, or settings config | `type:ci`, `area:agents` |

A PR may have several area labels but should normally have exactly one primary
type label.

The two `area:agents` rows differ by what the change *is*, not what it touches.
Editing `AGENTS.md`, a `SKILL.md`, or a `reference.md` is documentation.
Changing `.claude/settings.json` or `.codex/config.toml` alters how a tool is
permitted to execute, which is closer to build and CI configuration.

## Status transitions

- focused issue selected and branch created → issue `In Progress`
- draft PR opened → PR `In Progress`
- maintainer marks PR ready → PR `In review`
- PR merged → PR and completed issue `Done`
- PR closed without merge → restore or preserve the appropriate issue status
- blocked work → add `blocked` and keep an appropriate non-`Done` status

Prefer GitHub Project workflows for deterministic transitions such as merged PRs
and closed issues becoming `Done`.

## Routine authorization

The following are pre-authorized for an authorized draft PR:

- assignment to `amirhs1`;
- existing labels;
- inheritance of the issue's existing milestone;
- addition to the `CareerDossierTeX Development` Project;
- Project values derived from the issue and actual PR scope;
- moving the focused issue to `In Progress`.

Obtain explicit approval before:

- creating, renaming, deleting, or recoloring labels;
- creating, editing, closing, or deleting milestones;
- creating or changing Project fields or allowed values;
- changing Project workflows or views;
- changing Phase or Priority contrary to the issue;
- moving work to another release;
- marking the PR ready;
- enabling auto-merge or merging;
- changing repository settings, branch protections, or rulesets.

## Verification

After opening or updating the PR, read the metadata back from GitHub — do not
report what you intended to set — and confirm each of:

- PR URL and draft status;
- base and head branches;
- focused issue;
- assignee;
- labels;
- milestone;
- Project membership;
- Status;
- Phase;
- Priority;
- Size;
- fields intentionally left unset and why.

A blank field in that read-back is unfinished work, not a reporting line. Fill
it and read back again. The appendix has the queries.

Which blanks are legitimate:

- **Status, Size, assignee, and labels** are determinable from the PR itself, so
  none of them may be left unset. `Status` for a newly opened draft comes from
  `docs/NAMING-CONVENTION.md` section 9; `Size` from "Size guide" above, judged
  on the completed scope.
- **Milestone, Phase, and Priority** are inherited and must not be invented. Each
  may stay blank, and only when the focused issue itself has none — in which case
  name the missing *issue* field, not the PR field.
  `docs/NAMING-CONVENTION.md` section 10 defines the Phase numbering.

A deliberately unmilestoned issue is the ordinary case for work the maintainer
has postponed, and a PR against one inherits no milestone. Do not read the rule
against blank fields as licence to pick a milestone the issue does not have —
that silently pulls postponed work into a release.

If Project API access is unavailable, still create the authorized draft PR and
set all supported ordinary PR metadata. Report the exact fields that could not
be updated rather than claiming completion.

## Appendix: gh command reference

These commands are how an agent (or the maintainer) actually reads and writes the
Project. Repository metadata (assignee, labels, milestone) needs only the `repo`
token scope; Project reads/writes additionally need `read:project` and `project`:

```bash
gh auth refresh -s read:project,project
```

### Repository metadata (repo scope)

```bash
# Open a draft PR whose title follows docs/NAMING-CONVENTION.md
gh pr create --draft --base main --head <branch> \
  --title "type(scope): imperative summary" --body-file <body.md>

# Assignee, labels, milestone (labels must already exist — see `gh label list`)
gh pr edit <pr-number> --add-assignee amirhs1 \
  --add-label type:docs --add-label area:documentation \
  --milestone "v0.1.0 — English Industry Dossier"
```

### Project fields (project scope)

Project v2 fields are edited by ID, so first discover the IDs, then set values:

```bash
# 1. Find the Project number and node id
gh project list --owner amirhs1

# 2. List fields to get each field id and single-select option id
gh project field-list <project-number> --owner amirhs1

# 3. Add the issue or PR to the Project (returns/stores an item id)
gh project item-add <project-number> --owner amirhs1 \
  --url https://github.com/amirhs1/CareerDossierTeX/pull/<pr-number>

# 4. List items to find the item id for this PR
gh project item-list <project-number> --owner amirhs1

# 5. Set a single-select field (Status / Phase / Priority / Size)
gh project item-edit --project-id <PVT_...> --id <item-id> \
  --field-id <field-id> --single-select-option-id <option-id>

# Text, date, and number fields use --text, --date, or --number instead.

# 6. Read the values back. Step 3 populates no field, and step 5 addresses an
#    item by id, so a wrong id succeeds silently against the wrong row. This
#    query is the only evidence the values landed.
#
#    The field keys are lower-case: status, phase, priority, size. jq's {Status}
#    shorthand means {Status: .Status} and yields null for every field, which
#    reads exactly like unset metadata. Spell each mapping out.
gh project item-list <project-number> --owner amirhs1 --limit 400 --format json \
  --jq '.items[] | select(.content.number==<pr-number>
        and .content.type=="PullRequest")
        | {Status:.status, Phase:.phase, Priority:.priority, Size:.size}'

# Repository metadata reads back separately
gh pr view <pr-number> --json isDraft,assignees,labels,milestone
```

**Discover option strings from step 2, never from prose.** The live Project is
authoritative for the exact text of an option; this document and
`docs/NAMING-CONVENTION.md` are authoritative for *which* option to choose and
what it means. Those are different questions, and a transcription of the first
into prose drifts silently.

The casing is the part that bites, because lookup is by name. A `--jq
'select(.name=="In progress")'` against an option actually called `In Progress`
yields an empty option id, and the resulting `item-edit` sets nothing while
reporting no error — a failure with no failing exit status. This exact mismatch
existed between the Project and `docs/NAMING-CONVENTION.md` section 9 until
2026-08-04, when the documentation was corrected to match the Project. Assume it
can recur; read `gh project field-list` output and copy the string it returns.

So: take `Status` semantics from `docs/NAMING-CONVENTION.md` section 9 and
`Phase` from section 10, take `Priority` and `Size` from "Project field values"
above, and take every literal option string from `field-list`.
