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
unset and name the missing issue field — see "Project field values" and
"Verification". The rule above is about opening a PR with no focused issue at
all, not about an issue whose fields are incomplete.

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

## Project field values

For a newly opened draft PR:

- **Status:** the in-progress option — `docs/NAMING-CONVENTION.md` "Project
  Status convention" for what it means, the appendix's discovery query for how
  it is spelled
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

`docs/NAMING-CONVENTION.md` "Project Status convention" is the canonical
statement of the `Status` vocabulary and of the issue and PR transitions through
it — including which value a newly opened draft PR takes and when it changes.
Read the value there; this skill does not restate it, and an answer derived from
anywhere else is wrong.

Two cases that section leaves to this skill, because they are procedure rather
than naming:

- PR closed without merge → restore or preserve the appropriate issue status;
- blocked work → add `blocked` and keep an appropriate non-`Done` status.

Prefer GitHub Project workflows for deterministic transitions such as merged PRs
and closed issues becoming `Done`. "Project Status convention" also carries the
warning about transcribing option strings exactly, which applies to every value
set here.

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
- creating or changing Project fields, allowed values, workflows, or views;
- changing Phase or Priority contrary to the issue.

Everything `AGENTS.md` rule 11 (Maintainer authority) reserves is reserved here
too. Rule 11 states that action set; this list does not repeat it, and adds only
the GitHub-object cases an agent meets while populating PR metadata.

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
it and read back again. The appendix has the queries, and reads the list back in
one call — as an assertion that each value equals the intended one, not as a
list to eyeball, because a null field and a wrongly-set field read alike in
prose.

Which blanks are legitimate:

- **Status, Size, assignee, and labels** are determinable from the PR itself, so
  none of them may be left unset. `Status` for a newly opened draft comes from
  `docs/NAMING-CONVENTION.md` "Project Status convention"; `Size` from "Size
  guide" above, judged on the completed scope.
- **Milestone, Phase, and Priority** are inherited and must not be invented. Each
  may stay blank, and only when the focused issue itself has none — in which case
  name the missing *issue* field, not the PR field.
  `docs/NAMING-CONVENTION.md` "Phase numbering convention" defines it.

A deliberately unmilestoned issue is the ordinary case for work the maintainer
has postponed, and a PR against one inherits no milestone. Do not read the rule
against blank fields as licence to pick a milestone the issue does not have —
that silently pulls postponed work into a release.

If Project API access is unavailable, still create the authorized draft PR and
set all supported ordinary PR metadata. Report the exact fields that could not
be updated rather than claiming completion.

The read-back above is not a report of its own. `AGENTS.md` "Completion report"
defines the one report shape and states, under "How the report formats
compose", that this list is the metadata payload of its `Test criteria`
section. Close with that report — seven sections, one verdict, covering the
branch as a whole and not only its metadata. Neither the shape nor the verdict
wording is repeated here.

## Appendix: gh command reference

These commands are how an agent (or the maintainer) actually reads and writes the
Project. Repository metadata (assignee, labels, milestone) needs only the `repo`
token scope; Project reads/writes additionally need `read:project` and `project`:

```bash
gh auth refresh -s read:project,project
```

### The shape of the sequence

The `gh project` sub-commands expose one identifier per invocation — project
number, then field ids, then item ids, then one write per field — so the
straightforward path costs sixteen round-trips for one ordinary draft PR. None
of that is a rule; it is the sub-command surface, and it is paid on every
branch.

`gh api graphql` removes the id-discovery and per-field calls without removing
anything the rules require: it batches inside one request, and it still reads
every id and option string live in the same run, so nothing is cached into the
tree. `CLAUDE.md` ("`gh` must lead the Bash invocation") is canonical for why
this is the only form that batches here and why a wrapper script is not; that
reasoning is not repeated.

The five steps below cost five calls, and with `gh label list` and `gh issue
view` the whole path from "branch ready" to "metadata verified" is **seven**.

What the collapse does not buy is a shorter verification. Batching four writes
into one document adds a way for one write to fail among four successes, so
step 5 is more load-bearing here, not less.

### 1. Discover every id in one query

Project id, every field id, every single-select option id, and the focused
issue's item id with its current Status, Phase, and Priority:

```bash
gh api graphql -f owner=amirhs1 -f repo=CareerDossierTeX -F issue=<issue-number> -f query='
query($owner:String!,$repo:String!,$issue:Int!){
  user(login:$owner){
    projectsV2(first:20){nodes{
      id number title
      fields(first:50){nodes{
        ... on ProjectV2FieldCommon{id name}
        ... on ProjectV2SingleSelectField{id name options{id name}}
      }}
    }}
  }
  repository(owner:$owner,name:$repo){
    issue(number:$issue){
      id
      milestone{title}
      projectItems(first:10){nodes{
        id
        project{id title}
        fieldValues(first:30){nodes{
          ... on ProjectV2ItemFieldSingleSelectValue{
            name field{... on ProjectV2FieldCommon{name}}
          }
        }}
      }}
    }
  }
}'
```

From the `CareerDossierTeX Development` node take the project id and title, the
`Status`, `Phase`, `Priority`, and `Size` field ids, and the option id of each
value you intend to set. From the issue's own item take the milestone, Phase,
and Priority to inherit.

### 2. Open the PR fully configured (repo scope)

Assignee, labels, milestone, and Project membership are all `gh pr create`
flags, so they cost no call of their own. Use the project title exactly as
step 1 returned it:

```bash
gh pr create --draft --base main --head <branch> \
  --title "type(scope): imperative summary" --body-file <body.md> \
  --assignee amirhs1 --label type:docs --label area:agents \
  --milestone "<milestone string from step 1>" \
  --project "<project title from step 1>"
```

When updating an existing PR rather than opening one, the same flags are
`--add-assignee`, `--add-label`, `--milestone`, and `--add-project` on
`gh pr edit`.

### 3. Read the new PR's item id

The PR did not exist when step 1 ran, and a field write addresses an item by id,
so this read is the one that cannot be folded away:

```bash
gh api graphql -f owner=amirhs1 -f repo=CareerDossierTeX -F pr=<pr-number> -f query='
query($owner:String!,$repo:String!,$pr:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$pr){id projectItems(first:10){nodes{id project{id title}}}}
  }
}'
```

An empty `projectItems` means step 2's `--project` matched nothing. Add the PR
to the Project before writing fields, rather than writing them against a row
that does not exist.

### 4. Write every field in one mutation

One aliased `updateProjectV2ItemFieldValue` per value: the PR's Status, Phase,
Priority, and Size, and the focused issue's move to the in-progress option. Each
alias selects back the value it just wrote, so the response is evidence rather
than an exit status:

```bash
gh api graphql \
  -f p=<project-id> -f pi=<pr-item-id> -f ii=<issue-item-id> \
  -f fSt=<status-field-id> -f fPh=<phase-field-id> \
  -f fPr=<priority-field-id> -f fSz=<size-field-id> \
  -f oSt=<pr-status-option-id> -f oPh=<phase-option-id> \
  -f oPr=<priority-option-id> -f oSz=<size-option-id> \
  -f oIs=<issue-status-option-id> -f query='
mutation($p:ID!,$pi:ID!,$ii:ID!,$fSt:ID!,$fPh:ID!,$fPr:ID!,$fSz:ID!,
         $oSt:String!,$oPh:String!,$oPr:String!,$oSz:String!,$oIs:String!){
  status: updateProjectV2ItemFieldValue(input:{projectId:$p,itemId:$pi,
    fieldId:$fSt,value:{singleSelectOptionId:$oSt}}){projectV2Item{
      fieldValueByName(name:"Status"){... on ProjectV2ItemFieldSingleSelectValue{name}}}}
  phase: updateProjectV2ItemFieldValue(input:{projectId:$p,itemId:$pi,
    fieldId:$fPh,value:{singleSelectOptionId:$oPh}}){projectV2Item{
      fieldValueByName(name:"Phase"){... on ProjectV2ItemFieldSingleSelectValue{name}}}}
  priority: updateProjectV2ItemFieldValue(input:{projectId:$p,itemId:$pi,
    fieldId:$fPr,value:{singleSelectOptionId:$oPr}}){projectV2Item{
      fieldValueByName(name:"Priority"){... on ProjectV2ItemFieldSingleSelectValue{name}}}}
  size: updateProjectV2ItemFieldValue(input:{projectId:$p,itemId:$pi,
    fieldId:$fSz,value:{singleSelectOptionId:$oSz}}){projectV2Item{
      fieldValueByName(name:"Size"){... on ProjectV2ItemFieldSingleSelectValue{name}}}}
  issueStatus: updateProjectV2ItemFieldValue(input:{projectId:$p,itemId:$ii,
    fieldId:$fSt,value:{singleSelectOptionId:$oIs}}){projectV2Item{
      fieldValueByName(name:"Status"){... on ProjectV2ItemFieldSingleSelectValue{name}}}}
}'
```

Text, date, and number fields take `text:`, `date:`, or `number:` in `value:`
instead of `singleSelectOptionId:`.

**A batched write fails per alias, not per call.** When one alias is rejected,
its entry in `data` is `null`, `errors[].path` names it, and `gh` exits
non-zero — while the other four have already applied. So a zero exit is not
five successes, and neither is a response that merely contains data. Read the
five returned names.

### 5. Read the verification list back in one query

One query covers repository metadata and both items' Project fields:

```bash
gh api graphql -f owner=amirhs1 -f repo=CareerDossierTeX \
  -F pr=<pr-number> -F issue=<issue-number> -f query='
query($owner:String!,$repo:String!,$pr:Int!,$issue:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$pr){
      url isDraft baseRefName headRefName
      assignees(first:5){nodes{login}}
      labels(first:20){nodes{name}}
      milestone{title}
      projectItems(first:10){nodes{project{title}
        status:fieldValueByName(name:"Status"){... on ProjectV2ItemFieldSingleSelectValue{name}}
        phase:fieldValueByName(name:"Phase"){... on ProjectV2ItemFieldSingleSelectValue{name}}
        priority:fieldValueByName(name:"Priority"){... on ProjectV2ItemFieldSingleSelectValue{name}}
        size:fieldValueByName(name:"Size"){... on ProjectV2ItemFieldSingleSelectValue{name}}
      }}
    }
    issue(number:$issue){
      projectItems(first:10){nodes{project{title}
        status:fieldValueByName(name:"Status"){... on ProjectV2ItemFieldSingleSelectValue{name}}
      }}
    }
  }
}'
```

Reading that output is not the check. **Assert the values**, because a null
field and a wrongly-set field read alike in prose but not in a comparison. Pipe
the same call — `gh` still leads a pipeline — through a jq that compares each
field against what you meant to set and exits non-zero on any mismatch:

```bash
gh api graphql … -f query='…' \
| jq --argjson want '{"status":"<intended>","phase":"<intended>",
                      "priority":"<intended>","size":"<intended>"}' '
    ( .data.repository.pullRequest.projectItems.nodes
      | map(select(.project.title | test("CareerDossierTeX")))[0]
      // halt_error(1) ) as $i
    | [ $want | to_entries[]
        | {field:.key, want:.value, got:($i[.key].name // null)} ]
    | map(. + {ok:(.want == .got)})
    | if all(.[]; .ok) then . else halt_error(1) end'
```

Select the item by project rather than taking `nodes[0]`: a PR that ends up in
two projects would otherwise be checked against whichever row came back first,
which is the same class of mistake as writing a field to the wrong item.

`halt_error(1)` prints the offending table to stderr and exits 1, so a mismatch
cannot be read as a pass. Report the printed table; it is the metadata payload
of the completion report's `Test criteria` section. The issue's own Status comes
back in the same response and is confirmed the same way.

### Read option strings live, never from prose

The live Project is authoritative for the exact text and id of an option; this
document and `docs/NAMING-CONVENTION.md` are authoritative for *which* option to
choose and what it means. Those are different questions, and a transcription of
the first into prose drifts silently — which is why step 1 exists and why no id
or option string appears anywhere in this tree.

The casing is the part that bites, because the lookup is by name. A
`select(.name=="In progress")` against an option actually called `In Progress`
yields an empty option id. This exact mismatch existed between the Project and
`docs/NAMING-CONVENTION.md` "Project Status convention" until 2026-08-04, when
the documentation was corrected to match the Project; assume it can recur.

Under `gh project item-edit` that empty id set nothing and reported no error.
Under step 4 it is a `VALIDATION` error — `The single select option Id does not
belong to the field` — with the alias `null` and a non-zero exit. That is the
one behavioral difference between the old sequence and this one, and it is in
the safe direction: the silent failure became a loud one. It is still not a
substitute for step 5, which is what catches a *valid* id written to the wrong
row.

So: take `Status` semantics from `docs/NAMING-CONVENTION.md` "Project Status
convention" and `Phase` from "Phase numbering convention", take `Priority` and
`Size` from "Project field values" above, and take every literal option string
and id from step 1.
