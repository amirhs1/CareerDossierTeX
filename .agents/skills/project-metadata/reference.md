# GitHub Project metadata

This is the canonical repository procedure for populating and verifying the
GitHub Project fields, labels, milestone, and assignee on an **issue or a pull
request**. It applies to every agent.

The fields, their option ids, and the read-back obligation do not depend on
which of the two objects carries them. Where a rule genuinely does depend on it,
this file says so at that point; `.agents/skills/open-draft-pr/reference.md`
holds what is PR-only — the close-out gate, the PR body, and the push.

## Project field values

For a **newly opened draft pull request**:

- **Status:** the in-progress option — `docs/NAMING-CONVENTION.md` "Project
  Status convention" for what it means, the appendix's discovery query for how
  it is spelled
- **Phase:** inherit from the focused issue
- **Priority:** inherit from the focused issue
- **Size:** score the actual completed diff against the "Size guide" below
- **Start date:** leave unset for routine items
- **Target date:** leave unset for routine items

For a **newly filed issue**, the same four fields are required and only their
sources differ:

- **Status:** `Ready` when the issue is defined enough to start, `Backlog` when
  it is accepted but not scheduled — `docs/NAMING-CONVENTION.md` "Project Status
  convention" for the vocabulary
- **Phase:** the phase paired with the issue's milestone
- **Priority:** judged from the work, since there is nothing to inherit from
- **Size:** estimated, not measured — see "Sizing an item that has no diff yet"
  below


### Size guide

`Size` is scored from a diff, so a pull request is the object it applies to
directly; "An issue takes the size of the PR that closed it" below is the bridge
to the other one, and "Sizing an item that has no diff yet" covers the case
where no diff exists.

Score the diff on both axes and take the **larger** of the two tiers:

| | XS | S | M | L |
|---|---|---|---|---|
| files changed | ≤4 | 5–14 | 15–40 | >40 |
| lines (additions+deletions) | <50 | <250 | <3,000 | ≥3,000 |

Neither axis alone is sufficient: a change spread across many files with small
per-file diffs and a change concentrated in few files with a large diff both
need to be caught, and only the larger of the two tiers catches both.

**Measured fit** (2026-09-02, n=261 merged PRs currently carrying a `Size` in
the `CareerDossierTeX Development` Project — recorded XS 45, S 95, M 108,
L 13): this table reproduces the recorded value for 204/261 (78.2%) — XS
38/45 (84%), S 65/95 (68%), M 97/108 (90%), **L 4/13 (31%)**. The previous
thresholds (files ≤2/3–8/9–20/>20, lines <50/<250/<700/≥700) reproduced only
167/261 (64.0%) against the same data, which is why this table replaces
rather than adjusts them — the v0.9.0 backfill moved the distribution enough
to invalidate the old fit. Re-run "Re-measuring the Size fit" in the appendix
before trusting either number for a release far from 2026-09-02.

**`L` is a judgement call, not primarily a diff-size threshold.** The 9
recorded-`L` PRs this table misses span 4–81 files and 511–5,978 lines —
ranges that overlap heavily with recorded `M` — and no retuning of these two
axes reproduces them without fitting a boundary to a single outlier PR.
Treat a broad or risky-feeling change as `L` even when the table says `M`;
the table is not a ceiling on `L`.

Three cases the table does not cover:

- **A PR closing more than one issue does not give each issue the PR's own
  size.** #456 (17 files, 582 lines, `M`) closed both #447 and #450, and
  each is individually `S`. Score the PR from its own diff; do not propagate
  that score to every issue it closes.
- **An issue closed `not_planned` has no diff to score.** Its `Size` is an
  estimate from the issue body, not a measurement — #395 (`M`) and #433
  (`XS`) are the current examples.
- **`[epic]` and `[release]` issues do not follow this rule.** Copy the
  previous release's pair instead.

**An issue takes the size of the PR that closed it**, except the three cases
above.

### Sizing an item that has no diff yet

An issue's `Size` must be set when it is filed, which is before any diff exists
and long before the closing PR does. Leaving it blank is not an option — a blank
is unfinished work, per "Verification" below.

Predict the diff instead of guessing the tier. The issue's `Likely files`
section is required to be the output of a **search command**, not of recall, so
the file count is already measured; score that count and a line estimate on the
same two axes and take the larger tier. Re-score from the real diff when the PR
opens rather than inheriting the filing-time number — the guide's rule is about
a diff, and the estimate is only standing in for one.

### Two rules that bound any value set here

If a pull request scores `L`, keep it draft and recommend splitting it unless
broad scope was already approved.

Do not infer a higher priority than the focused issue. Where a field is
inherited and its source has none, leave it unset and report it.


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

An issue or a pull request may carry several area labels but should normally
carry exactly one primary type label. An issue filed from `development.md`
pre-applies no `type:*` label at all — that form spans five of them — so
applying one is part of filing the issue, not an optional extra.

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

The following are pre-authorized on an issue or pull request whose underlying
work is itself authorized:

- assignment to `amirhs1`;
- existing labels;
- a milestone inherited from the focused issue, or matching the release the work
  lands in;
- addition to the `CareerDossierTeX Development` Project;
- Project values derived from the issue and the item's actual scope;
- moving the focused issue to the in-progress option.

Obtain explicit approval before:

- creating, renaming, deleting, or recoloring labels;
- creating, editing, closing, or deleting milestones;
- creating or changing Project fields, allowed values, workflows, or views;
- changing Phase or Priority contrary to the issue.

Everything `AGENTS.md` rule 11 (Maintainer authority) reserves is reserved here
too. Rule 11 states that action set; this list does not repeat it, and adds only
the GitHub-object cases an agent meets while populating metadata.


## Verification

After writing the fields, read the metadata back from GitHub — do not report
what you intended to set — and confirm each of:

- assignee;
- labels;
- milestone;
- Project membership;
- Status;
- Phase;
- Priority;
- Size;
- fields intentionally left unset and why.

A pull request additionally confirms its URL and draft status, its base and head
branches, and its focused issue; `.agents/skills/open-draft-pr/reference.md`
("The four PR-only read-back items") carries those four and nothing else.

A blank field in that read-back is unfinished work, not a reporting line. Fill
it and read back again. The appendix has the queries, and reads the list back in
one call — as an assertion that each value equals the intended one, not as a
list to eyeball, because a null field and a wrongly-set field read alike in
prose.

Which blanks are legitimate:

- **Status, Size, assignee, and labels** are determinable from the item itself,
  so none of them may be left unset. `Status` comes from
  `docs/NAMING-CONVENTION.md` "Project Status convention"; `Size` from "Size
  guide" above — judged on the completed diff for a pull request, and predicted
  per "Sizing an item that has no diff yet" for a freshly filed issue.
- **Milestone, Phase, and Priority** on a *pull request* are inherited and must
  not be invented. Each may stay blank, and only when the focused issue itself
  has none — in which case name the missing *issue* field, not the PR field.
  On an *issue* there is nothing to inherit from: the milestone is required by
  `CONTRIBUTING.md` "Every issue carries a milestone" (with the one exception
  that section names), and `Phase` follows the milestone.
  `docs/NAMING-CONVENTION.md` "Phase numbering convention" defines it.

A deliberately unmilestoned issue is the ordinary case for work the maintainer
has postponed, and a PR against one inherits no milestone. Do not read the rule
against blank fields as licence to pick a milestone the issue does not have —
that silently pulls postponed work into a release.

If Project API access is unavailable, still set every field that is reachable
without it. Report the exact fields that could not be updated rather than
claiming completion.

The read-back above is not a report of its own. `AGENTS.md` "Completion report"
defines the one report shape and states, under "How the report formats
compose", that this list is the metadata payload of its `Test criteria`
section. Close with that report — seven sections, one verdict, covering the
work as a whole and not only its metadata. Neither the shape nor the verdict
wording is repeated here.


## Appendix: gh command reference

These commands are how an agent (or the maintainer) actually reads and writes
the Project. Steps 1, 4, and 5 are object-neutral — an item id is an item id.
Step 2 is written for a pull request because that is the busier path; "Filing an
issue instead" after step 5 gives the two substitutions an issue needs.

Repository metadata (assignee, labels, milestone) needs only the `repo` token
scope; Project reads/writes additionally need `read:project` and `project`:

```bash
gh auth refresh -s read:project,project
```

### The shape of the sequence

The `gh project` sub-commands expose one identifier per invocation — project
number, then field ids, then item ids, then one write per field — so the
straightforward path costs sixteen round-trips for one ordinary item. None
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

### Filing an issue instead

Two substitutions turn the sequence above into the issue path; steps 1, 4, and 5
are unchanged.

**Step 2 becomes `gh issue create`.** It takes the same metadata flags, so the
issue is filed fully configured in one call:

```bash
gh issue create --title "[area] Verb object" --body-file <body.md> \
  --assignee amirhs1 --label type:docs --label area:agents \
  --milestone "<milestone string from step 1>"
```

`gh issue create` has **no `--project` flag**, which is the one asymmetry with
`gh pr create`. Add the issue to the Project with a mutation instead, reading
its node id in the same call — `gh` still leads, so the nested substitution is
sandbox-safe:

```bash
gh api graphql -f query='
mutation{ addProjectV2ItemById(input:{projectId:"<project-id from step 1>",
  contentId:"'"$(gh issue view <n> --json id --jq .id)"'"}){item{id}} }'
```

The returned `item.id` is what step 4 writes against, so **step 3 is not needed
on this path** — the mutation that adds the item already returns its id, while
a PR's item id has to be read back separately.

**Step 4 drops the `issueStatus` alias.** There is no second object to move, so
the mutation carries four aliases rather than five.

When several issues are filed together, add them one call at a time rather than
batching the `addProjectV2ItemById` aliases: the order of sequential calls is
the order they appear in the Project and in an epic's sub-issue graph, and that
order is maintainer-curated.

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

### Re-measuring the Size fit

The query behind "Size guide" above. It pages through every item in the
Project (`first:100`; repeat with `-f c=<endCursor>` from the previous
response's `pageInfo`, adding `$c:String!` and `after:$c` to the query, until
`hasNextPage` is `false` — six pages at 546 sized items, the count when this
was last run) and returns each item's recorded `Size` next to its own diff
stats in one pass, `PullRequest` and `Issue` content both, so no second query
is needed to cross-reference the two:

```bash
gh api graphql -f p=<project-id> -f query='
query($p:ID!){
  node(id:$p){
    ... on ProjectV2{
      items(first:100){
        pageInfo{hasNextPage endCursor}
        nodes{
          size:fieldValueByName(name:"Size"){... on ProjectV2ItemFieldSingleSelectValue{name}}
          content{
            __typename
            ... on Issue{number state stateReason}
            ... on PullRequest{number state changedFiles additions deletions
              closingIssuesReferences(first:10){nodes{number}}}
          }
        }
      }
    }
  }
}'
```

Score each `state:"MERGED"` `PullRequest` node against the table in "Size
guide" above (files-changed tier, lines-changed tier, take the larger) and
compare against its own `size.name` — that comparison is the measured-fit
number reported there. `stateReason` marks the `not_planned` carve-out on
`Issue` nodes, and `closingIssuesReferences` is how an issue's own
`size.name` is checked against the multi-issue-PR carve-out rather than
assumed to equal its closing PR's score.
