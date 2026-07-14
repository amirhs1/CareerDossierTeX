# GitHub Project and draft pull-request workflow

This is the canonical repository procedure for opening or updating a draft pull
request and populating its GitHub metadata. It applies to Codex and Claude Code.

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
2. `docs/naming_conventions.md`;
3. `scripts/setup-labels.sh`;
4. the issue's milestone;
5. the issue's current Project fields;
6. existing PR metadata when updating a PR.

Do not invent labels, milestones, field names, or single-select values. Preserve
existing remote metadata unless the current work clearly requires a change.

If GitHub metadata conflicts with repository documentation, report the conflict
and preserve the existing remote value until the maintainer decides.

## Before opening a draft PR

Confirm:

- the branch is not `main`;
- the focused issue is identified;
- the diff is limited to the issue;
- behavior changes include their focused committed tests under `tests/` rather
  than deferring them to a later milestone task;
- relevant tests and checks were run;
- no generated artifacts, secrets, private data, or unrelated changes are included;
- API, docs, design, and accessibility impacts are documented;
- the PR title follows `docs/naming_conventions.md`.

## PR body

Include:

- concise summary;
- `Closes #NN` for the focused issue when the PR should complete it;
- change list;
- public-API impact;
- tests run and exact outcomes;
- tests added or updated under `tests/`, including the expected pre-fix failure
  when it was demonstrated;
- visual and accessibility checks when relevant;
- documentation and changelog impact;
- known limitations and follow-up work.

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

- **Status:** `In progress`
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

Use only labels already defined by `scripts/setup-labels.sh`.

| Change | Labels |
| --- | --- |
| Public resume feature | `type:feature`, `area:resume` |
| Contact-line bug | `type:bug`, `area:components` |
| API documentation clarification | `type:docs`, `area:documentation` |
| Typography implementation | `type:feature`, `area:typography` |
| GitHub Actions change | `type:ci`, `area:build` |
| Theme restructuring without behavior change | `type:refactor`, `area:theme` |

A PR may have several area labels but should normally have exactly one primary
type label.

## Status transitions

- focused issue selected and branch created → issue `In progress`
- draft PR opened → PR `In progress`
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
- moving the focused issue to `In progress`.

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

After opening or updating the PR, verify and report:

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
# Open a draft PR whose title follows docs/naming_conventions.md
gh pr create --draft --base main --head <branch> \
  --title "type(scope): imperative summary" --body-file <body.md>

# Assignee, labels, milestone (labels must already exist in setup-labels.sh)
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
```

Field values must match the Project's configured options exactly (for example
Status `In progress`; Phase `Phase 1 — Industry`; Priority `P2 — Normal`;
Size `S`). Do not invent option names.
