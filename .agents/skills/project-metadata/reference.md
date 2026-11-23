# GitHub Project metadata

How to set and verify the Project fields, labels, milestone, assignee, and
parent of an issue or a pull request. The rules are the same for both objects;
where one differs, the section says so. `.agents/skills/open-pull-request/SKILL.md`
holds what is pull-request-only: the close-out gate, the body, and the push.

Contents: Project field values (Size guide; Sizing an item that has no diff
yet) · Label selection · Status transitions · Routine authorization ·
Verification · Appendix: steps 1 to 5; Filing an issue instead; Updating an open
pull request; Read option strings live; Auditing a milestone before a release.

## Project field values

| Field | Newly opened draft pull request | Newly filed issue |
| --- | --- | --- |
| Status | the in-progress option | `Ready` if defined enough to start, else `Backlog` |
| Phase | inherited from the focused issue | the phase paired with the milestone |
| Priority | inherited from the focused issue | judged from the work |
| Size | scored from the completed diff ("Size guide") | estimated ("Sizing an item that has no diff yet") |
| Start date, Target date | unset | unset |

`CONTRIBUTING.md`, "Project Status convention", defines what each `Status`
means, and "Phase numbering convention" pairs phases with milestones. Never set
a higher priority than the focused issue's. Where an inherited field's source
has none, leave it unset and report it.

A pull request that closes the focused issue and no other also writes that
issue's `Size`, as "Size guide" scores it.

An issue also takes a **parent**: its milestone's release epic, the issue in
that milestone whose title begins `[epic]` (`CONTRIBUTING.md`, "1. Every issue
carries a milestone"). A patch release has no epic, and an epic is not its own
sub-issue, so neither takes a parent.

### Size guide

Score a diff on both axes and take the **larger** tier, so that neither a change
spread thinly over many files nor a large change to a few escapes:

| | XS | S | M | L |
|---|---|---|---|---|
| files changed | ≤2 | 3–9 | 10–40 | >40 |
| lines (additions+deletions) | <30 | <100 | <1,000 | ≥1,000 |

A deleted file may count as one line; say so in the pull request when that
changes the tier.

**`L` means "split it".** A pull request expected to score `L` needs a stated
reason it cannot be split, and approval before its branch starts (`AGENTS.md`,
"Git"); one that scores `L` stays draft with a recommendation to split it,
unless broad scope was approved. Treat a broad or risky change as `L` even when
the table says `M`.

**An issue takes the size of its pull requests together.** An issue that holds
several findings ships as several pull requests, each saying `Refs #n` and the
last saying `Closes #n` (`AGENTS.md`, "Git"), so the last one alone understates
it. Its pull requests are those that close it and those whose body says
`Refs #n`, merged or open, each naming no other issue with `Closes` or `Refs`.
Score them as one diff: the **distinct files** across them and the **sum** of
their lines. A file several of them edit counts once, so an issue scores the
same however it was split; with one pull request, the score is that one's own.

The pull request that closes the issue and no other writes this value (step 3a
scores it, step 4 writes it), when it opens and on each update that changes the
diff. A pull request that only says `Refs #n` writes nothing: the issue keeps
its estimate until the closing pull request opens.

Three cases take no size from a pull request:

- **A pull request that closes more than one issue.** Score it from its own
  diff; each issue keeps its own `Size`.
- **An issue closed `not_planned`.** Its `Size` is an estimate from its body.
- **An epic or a release-preparation issue.** Copy the previous release's pair.

Recorded values keep the table they were scored with; never re-score a past
item to fit a later table.

### Sizing an item that has no diff yet

An issue's `Size` is set when it is filed, before any diff exists, and a blank
is unfinished work. Predict the diff: the issue's `Likely files` is the output
of a search command, so score its file count and a line estimate on the same two
axes, and take the larger tier. For an issue planned as several pull requests,
predict them together. The closing pull request re-scores it from the real
diffs.

## Label selection

Use only the labels `CONTRIBUTING.md`, "Names", lists:

```bash
gh label list --limit 100
```

| Change | Labels |
| --- | --- |
| Public resume feature | `type:feat`, `area:resume` |
| Contact-line bug | `type:fix`, `area:components` |
| API documentation clarification | `type:docs`, `area:documentation` |
| Typography implementation | `type:feat`, `area:typography` |
| GitHub Actions change | `type:ci`, `area:build` |
| Theme restructuring without behavior change | `type:refactor`, `area:theme` |
| Agent instructions, skills, or workflow docs | `type:docs`, `area:agents` |
| Agent sandbox, permissions, or settings config | `type:ci`, `area:agents` |

Apply one primary `type:*` label and every relevant `area:*` label. The
`development.md` issue form pre-applies no `type:*` label, so filing from it
includes choosing one. The two `area:agents` rows differ by what the change is:
editing `AGENTS.md`, a `SKILL.md`, or a `reference.md` is documentation;
changing `.claude/settings.json` or `.codex/config.toml` changes how a tool may
run, which is closer to CI.

## Status transitions

`CONTRIBUTING.md`, "Project Status convention", states the `Status` vocabulary
and every issue and pull request transition; take the value from there. Two
cases it leaves here:

- a pull request closed without merge: restore or keep the issue's status;
- blocked work: keep a non-`Done` status and say in the issue what blocks it;
  there is no `blocked` label.

Leave deterministic transitions, such as a merged pull request becoming `Done`,
to the Project's workflows.

## Routine authorization

Pre-authorized on an issue or pull request whose work is itself authorized:

- assignment to `amirhs1`;
- existing labels;
- a milestone inherited from the focused issue, or matching the release the work
  lands in;
- addition to the `CareerDossierTeX Development` Project;
- Project values derived from the issue and the item's actual scope;
- moving the focused issue to the in-progress option.

Ask first before:

- creating, renaming, deleting, or recoloring labels;
- creating, editing, closing, or deleting milestones;
- creating or changing Project fields, allowed values, workflows, or views;
- changing Phase or Priority contrary to the issue.

Everything `AGENTS.md`, "Git", reserves to the maintainer stays reserved.

## Verification

Read every value back from GitHub and assert it equals what you set: a null
field and a wrong one read alike in prose, but not in a comparison. Step 5 does
this in one call. Check:

- assignee, labels, milestone, and Project membership;
- Status, Phase, Priority, and Size;
- on an issue, its parent;
- on a pull request, also its URL and draft status, its base and head branches,
  the issue its body closes, and that issue's Status, Size, and parent.

A blank is unfinished work: fill it and read back again. The only legitimate
blanks:

- **Milestone, Phase, and Priority on a pull request**, when the focused issue
  has none; report the missing issue field. Never pick a milestone the issue
  lacks: an unmilestoned issue is usually postponed work.
- **The parent**, on an epic, an issue in a patch release, or an issue with no
  milestone. Anywhere else, attach it with the mutation in "Filing an issue
  instead".

Status, Size, assignee, and labels are never blank. If Project access is
unavailable (a missing `project` scope or identifier), set every reachable
field and report exactly which could not be set. The read-back goes in the
report's "2 Checks run" (`AGENTS.md`, "Report back").

## Appendix: gh command reference

Repository metadata needs the `repo` token scope; the Project needs
`read:project` and `project` too:

```bash
gh auth refresh -s read:project,project
```

### The shape of the sequence

Each step is one `gh api graphql` call, which batches what `gh project` does
one id or one field per call, and still reads every id live; `CLAUDE.md`,
"Sandbox and permissions", says why `gh` runs alone. A pull request takes seven
calls with `gh label list` and `gh issue view`, eight with step 3a. Batched
writes can fail one alias among many, so step 5 matters more, not less. Steps 1
to 5 are for a pull request; "Filing an issue instead" gives an issue's own.

### 1. Discover every id in one query

The project, its field and option ids, and the focused issue's item, parent,
milestone, and current values:

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
      id title
      parent{number}
      milestone{title
        issues(first:100,orderBy:{field:CREATED_AT,direction:ASC}){nodes{number title}}}
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
four field ids, and the option id of each value to set. From the issue take its
item id, the milestone, Phase, and Priority to inherit, and its release epic:
the first issue in its milestone whose title begins `[epic]`. Its own title says
whether it is an epic or a release issue (`[epic]`, `[release]`), which step 4
writes no `Size` to.

### 2. Open the PR fully configured (repo scope)

Use the milestone and project title exactly as step 1 returned them:

```bash
gh pr create --draft --base main --head <branch> \
  --title "type(scope): imperative summary" --body-file <body.md> \
  --assignee amirhs1 --label type:docs --label area:agents \
  --milestone "<milestone string from step 1>" \
  --project "<project title from step 1>"
```

To update an open pull request, `gh pr edit` takes `--add-assignee`,
`--add-label`, `--milestone`, and `--add-project`.

### 3. Read the new PR's item id

```bash
gh api graphql -f owner=amirhs1 -f repo=CareerDossierTeX -F pr=<pr-number> -f query='
query($owner:String!,$repo:String!,$pr:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$pr){id projectItems(first:10){nodes{id project{id title}}}}
  }
}'
```

An empty `projectItems` means `--project` matched nothing: add the pull request
to the Project before writing fields. If `gh pr create` exits 1 with `Content
already exists in this project`, the pull request was opened and the Project's
auto-add got there first; do not run it again, take the URL from the output, and
run this step.

### 3a. Score the focused issue's pull requests together

Run this when the pull request closes the focused issue and no other, and the
issue may have other pull requests: an earlier `Refs #n` one, or a second
closing one. Otherwise give step 4's `issueSize` the pull request's own option.

```bash
gh api graphql -f owner=amirhs1 -f repo=CareerDossierTeX -F issue=<issue-number> -f query='
query($owner:String!,$repo:String!,$issue:Int!){
  repository(owner:$owner,name:$repo){
    issue(number:$issue){
      closedByPullRequestsReferences(first:10){pageInfo{hasNextPage} nodes{...pr}}
      timelineItems(first:100,itemTypes:[CROSS_REFERENCED_EVENT]){pageInfo{hasNextPage} nodes{
        ... on CrossReferencedEvent{source{...pr}}}}
    }
  }
}
fragment pr on PullRequest{
  number state body additions deletions
  files(first:100){nodes{path}}
  closingIssuesReferences(first:5){totalCount}
}' --jq '
    def tier($f; $l): ["XS","S","M","L"][
        ([ (if $f <= 2 then 0 elif $f <= 9 then 1 elif $f <= 40 then 2 else 3 end),
           (if $l < 30 then 0 elif $l < 100 then 1 elif $l < 1000 then 2 else 3 end) ] | max) ];
    <issue-number> as $n
    | .data.repository.issue as $x
    | if $x.closedByPullRequestsReferences.pageInfo.hasNextPage or $x.timelineItems.pageInfo.hasNextPage
      then "more pull requests than the query reads: score it by hand" | halt_error(1) else . end
    | [$x.closedByPullRequestsReferences.nodes[] | select(.state == "MERGED" or .state == "OPEN")] as $closing
    | [ $x.timelineItems.nodes[].source
        | select(.number != null and (.state == "MERGED" or .state == "OPEN"))
        | select(.body // "" | test("(?i)\\brefs #\($n)\\b"))
        | select([.body | scan("(?i)(?:closes|refs) #([0-9]+)") | .[0]] | unique | length == 1)
        | select(. as $p | ([$closing[].number] | index($p.number)) == null) ] as $refs
    | ($closing + $refs) as $prs
    | ([$prs[].files.nodes[].path] | unique | length) as $f
    | ([$prs[] | .additions + .deletions] | add) as $l
    | {size:tier($f; $l), files:$f, lines:$l, prs:[$prs[].number],
       closesOthers:([$closing[] | select(.closingIssuesReferences.totalCount != 1) | .number])}'
```

Take `size`'s option id from step 1. A non-empty `closesOthers` means write
nothing ("Size guide", first case). A `Refs` pull request that names another
issue is left out of `prs`; say so in the pull request. The query stops when a
list is longer than it reads.

### 4. Write every field in one mutation

The pull request's Status, Phase, Priority, and Size, and the focused issue's
Status and Size; each alias reads back what it wrote:

```bash
gh api graphql \
  -f p=<project-id> -f pi=<pr-item-id> -f ii=<issue-item-id> \
  -f fSt=<status-field-id> -f fPh=<phase-field-id> \
  -f fPr=<priority-field-id> -f fSz=<size-field-id> \
  -f oSt=<pr-status-option-id> -f oPh=<phase-option-id> \
  -f oPr=<priority-option-id> -f oSz=<size-option-id> \
  -f oIs=<issue-status-option-id> -f oIz=<issue-size-option-id> -f query='
mutation($p:ID!,$pi:ID!,$ii:ID!,$fSt:ID!,$fPh:ID!,$fPr:ID!,$fSz:ID!,
         $oSt:String!,$oPh:String!,$oPr:String!,$oSz:String!,$oIs:String!,
         $oIz:String!){
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
  issueSize: updateProjectV2ItemFieldValue(input:{projectId:$p,itemId:$ii,
    fieldId:$fSz,value:{singleSelectOptionId:$oIz}}){projectV2Item{
      fieldValueByName(name:"Size"){... on ProjectV2ItemFieldSingleSelectValue{name}}}}
}'
```

`$oIz` is step 3a's option, or `$oSz` when the issue has no other pull request.
Drop the `issueSize` alias when "Size guide" gives the issue no size from this
pull request: it closes more than one issue or none, or the issue is an epic or
a release issue. Text, date, and number fields take `text:`, `date:`, or
`number:` instead of `singleSelectOptionId:`.

A batched write fails per alias: a rejected alias is `null`, `errors[].path`
names it, and `gh` exits non-zero while the others have applied. Read every
returned name.

### 5. Read the verification list back in one query

Fill `$want` from what you set, then run it; it prints the table and exits 1 on
any mismatch:

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
      closingIssuesReferences(first:10){nodes{number}}
      projectItems(first:10){nodes{project{title}
        status:fieldValueByName(name:"Status"){... on ProjectV2ItemFieldSingleSelectValue{name}}
        phase:fieldValueByName(name:"Phase"){... on ProjectV2ItemFieldSingleSelectValue{name}}
        priority:fieldValueByName(name:"Priority"){... on ProjectV2ItemFieldSingleSelectValue{name}}
        size:fieldValueByName(name:"Size"){... on ProjectV2ItemFieldSingleSelectValue{name}}
      }}
    }
    issue(number:$issue){
      parent{number}
      projectItems(first:10){nodes{project{title}
        status:fieldValueByName(name:"Status"){... on ProjectV2ItemFieldSingleSelectValue{name}}
        size:fieldValueByName(name:"Size"){... on ProjectV2ItemFieldSingleSelectValue{name}}
      }}
    }
  }
}' --jq '
    {"url":"<pr-url>","isDraft":true,"base":"main","head":"<branch>",
     "assignees":["amirhs1"],"labels":["<label>","<label>"],
     "milestone":"<milestone>","closes":[<issue-number>],
     "project":"CareerDossierTeX Development",
     "status":"<intended>","phase":"<intended>",
     "priority":"<intended>","size":"<intended>",
     "issueStatus":"<intended>","issueSize":"<intended>",
     "issueParent":<epic-number>} as $want
    | .data.repository as $r
    | ( $r.pullRequest.projectItems.nodes
        | map(select(.project.title | test("CareerDossierTeX")))[0] // {} ) as $i
    | ( $r.issue.projectItems.nodes
        | map(select(.project.title | test("CareerDossierTeX")))[0] // {} ) as $j
    | ( ( $r.pullRequest
          | {url, isDraft, base:.baseRefName, head:.headRefName,
             assignees:([.assignees.nodes[].login] | sort),
             labels:([.labels.nodes[].name] | sort),
             milestone:.milestone.title,
             closes:[.closingIssuesReferences.nodes[].number]} )
        + {project:$i.project.title, status:$i.status.name,
           phase:$i.phase.name, priority:$i.priority.name,
           size:$i.size.name, issueStatus:$j.status.name,
           issueSize:$j.size.name, issueParent:$r.issue.parent.number} ) as $got
    | [ $want | to_entries[] | {field:.key, want:.value, got:$got[.key]} ]
    | map(. + {ok:(.want == .got)})
    | if all(.[]; .ok) then . else halt_error(1) end'
```

In `$want`, sort `assignees` and `labels`; give `closes` as each `Closes #n`, or
`[]`; `null` for an inherited field the issue lacks; `issueSize` as step 4 wrote
it, or step 1's value where step 4 dropped it; `issueParent` as step 1's epic,
or `null` where "Verification" allows none. A wrong parent is a missing
sub-issue link: attach it as "Filing an issue instead" does. Never pipe `gh` to
`jq`: piped, `gh` runs in the sandbox and is denied, and `jq` exits 0 on empty
input.

### Filing an issue instead

Step 1 reads no issue, step 2 files it, step 3 is not needed, step 4 drops the
`issueStatus` and `issueSize` aliases, and step 5 reads the issue alone.

**Step 1** reads the Project and the open milestones; its pull request form
fails without an issue number:

```bash
gh api graphql -f owner=amirhs1 -f repo=CareerDossierTeX -f query='
query($owner:String!,$repo:String!){
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
    milestones(states:OPEN,first:20){nodes{title}}
  }
}'
```

`CONTRIBUTING.md`, "1. Every issue carries a milestone", decides the milestone,
and this list gives its exact string.

**Step 2** files the issue fully configured:

```bash
gh issue create --title "[area] Verb object" --body-file <body.md> \
  --assignee amirhs1 --label type:docs --label area:agents \
  --milestone "<milestone string from step 1>"
```

`gh issue create` has no `--project` flag, so a mutation adds the issue to the
Project and makes it a sub-issue of its epic. Read both node ids first, then
write them, each `gh` call alone:

```bash
gh api graphql -f owner=amirhs1 -f repo=CareerDossierTeX -F issue=<n> -f query='
query($owner:String!,$repo:String!,$issue:Int!){
  repository(owner:$owner,name:$repo){
    issue(number:$issue){
      id number
      milestone{title
        issues(first:100,orderBy:{field:CREATED_AT,direction:ASC}){nodes{id number title}}}
    }
  }
}' --jq '.data.repository.issue
    | {id, milestone:.milestone.title,
       epic:([.milestone.issues.nodes[]? | select(.title | startswith("[epic]"))][0] // null)}'
```

```bash
gh api graphql -f p=<project-id from step 1> -f c=<issue id from the call above> \
  -f e=<epic id from the call above> -f query='
mutation($p:ID!,$c:ID!,$e:ID!){
  add: addProjectV2ItemById(input:{projectId:$p,contentId:$c}){item{id}}
  sub: addSubIssue(input:{issueId:$e,subIssueId:$c}){subIssue{number parent{number}}}
}'
```

Drop `sub` and `$e` when `epic` is `null` or names the issue itself. `add`
returns the existing item if auto-add got there first; `sub` on an issue that
already has a parent is `null` with a `VALIDATION` error, and `gh` exits 1
though `add` applied. Step 4 writes to `add`'s item id.

**Step 5** asserts the issue's nine values the same way:

```bash
gh api graphql -f owner=amirhs1 -f repo=CareerDossierTeX -F issue=<issue-number> -f query='
query($owner:String!,$repo:String!,$issue:Int!){
  repository(owner:$owner,name:$repo){
    issue(number:$issue){
      assignees(first:5){nodes{login}}
      labels(first:20){nodes{name}}
      milestone{title}
      parent{number}
      projectItems(first:10){nodes{project{title}
        status:fieldValueByName(name:"Status"){... on ProjectV2ItemFieldSingleSelectValue{name}}
        phase:fieldValueByName(name:"Phase"){... on ProjectV2ItemFieldSingleSelectValue{name}}
        priority:fieldValueByName(name:"Priority"){... on ProjectV2ItemFieldSingleSelectValue{name}}
        size:fieldValueByName(name:"Size"){... on ProjectV2ItemFieldSingleSelectValue{name}}
      }}
    }
  }
}' --jq '
    {"assignees":["amirhs1"],"labels":["<label>","<label>"],
     "milestone":"<milestone>","parent":<epic-number>,
     "project":"CareerDossierTeX Development",
     "status":"<intended>","phase":"<intended>",
     "priority":"<intended>","size":"<intended>"} as $want
    | .data.repository.issue as $x
    | ( $x.projectItems.nodes
        | map(select(.project.title | test("CareerDossierTeX")))[0] // {} ) as $i
    | {assignees:([$x.assignees.nodes[].login] | sort),
       labels:([$x.labels.nodes[].name] | sort),
       milestone:$x.milestone.title, parent:$x.parent.number,
       project:$i.project.title, status:$i.status.name,
       phase:$i.phase.name, priority:$i.priority.name,
       size:$i.size.name} as $got
    | [ $want | to_entries[] | {field:.key, want:.value, got:$got[.key]} ]
    | map(. + {ok:(.want == .got)})
    | if all(.[]; .ok) then . else halt_error(1) end'
```

File several issues one call at a time: the order of the calls is their order in
the Project and under the epic, which the maintainer curates.

### Updating an open pull request

When an update to an open pull request pushes commits, re-score the whole
branch diff, not the new commits, from its own counts:

```bash
gh pr view <pr-number> --json changedFiles,additions,deletions
```

Then run steps 1, 3, 3a when the issue has other pull requests, 4, and 5. Step
4 carries only the `size` and `issueSize` aliases and declares only the
variables they use (`$p`, `$pi`, `$ii`, `$fSz`, `$oSz`, `$oIz`): GraphQL rejects
a declared variable that nothing uses. Step 5 runs in full. An update to the
body alone changes no field.

### Read option strings live, never from prose

Take each option's exact name and id from step 1, never from this file or
`CONTRIBUTING.md`, which say only which option to choose. The lookup is by
name, and a drifted transcription, such as `In progress` for `In Progress`,
resolves to no id: step 4 then fails with `The single select option Id does not
belong to the field`. Step 5 still has to catch a valid id written to the wrong
row.

### Auditing a milestone before a release

One read-only query checks a milestone for the two values written outside a
field mutation: each issue's parent, and the `Size` it takes from its pull
requests. Run it before a release and after any hand correction. It prints one
line per finding and exits 1, or prints nothing and exits 0. Put the exact
milestone title in `-f m=` and in `$m`: `query:` matches partially, so the
`--jq` keeps only the exact title, and stops when it is not among the first
three matches.

```bash
gh api graphql -f owner=amirhs1 -f repo=CareerDossierTeX -f m=<milestone> -f query='
query($owner:String!,$repo:String!,$m:String!){
  repository(owner:$owner,name:$repo){
    milestones(query:$m,first:3,states:[OPEN,CLOSED]){nodes{title
      issues(first:100){pageInfo{hasNextPage} nodes{
        number title stateReason parent{number}
        projectItems(first:5){nodes{project{title}
          size:fieldValueByName(name:"Size"){... on ProjectV2ItemFieldSingleSelectValue{name}}}}
        closedByPullRequestsReferences(first:3){pageInfo{hasNextPage} nodes{...pr}}
        timelineItems(first:25,itemTypes:[CROSS_REFERENCED_EVENT]){pageInfo{hasNextPage} nodes{
          ... on CrossReferencedEvent{source{...pr}}}}
      }}
    }}
  }
}
fragment pr on PullRequest{
  number state body additions deletions
  files(first:41){nodes{path}}
  closingIssuesReferences(first:5){totalCount}
  projectItems(first:3){nodes{project{title}
    size:fieldValueByName(name:"Size"){... on ProjectV2ItemFieldSingleSelectValue{name}}}}
}' --jq '
    def size: [.projectItems.nodes[] | select(.project.title | test("CareerDossierTeX")) | .size.name][0];
    def tier($f; $l): ["XS","S","M","L"][
        ([ (if $f <= 2 then 0 elif $f <= 9 then 1 elif $f <= 40 then 2 else 3 end),
           (if $l < 30 then 0 elif $l < 100 then 1 elif $l < 1000 then 2 else 3 end) ] | max) ];
    def names: map("#\(.number)") | join(", ");
    "<milestone>" as $m
    | [ .data.repository.milestones.nodes[] | select(.title == $m) ] as $ms
    | if ($ms | length) != 1 then "milestone \($m) not found" | halt_error(1) else $ms[0] end
    | if .issues.pageInfo.hasNextPage then "more than 100 issues: page" | halt_error(1) else . end
    | .issues.nodes as $is
    | ([$is[] | select(.title | startswith("[epic]")) | .number][0]) as $e
    | [ ( $is[] | select(.number != $e and .parent.number != $e)
          | "#\(.number) parent \(.parent.number // "none"), want \($e // "none")" ),
        ( $is[]
          | select((.title | test("^\\[(epic|release)\\]")) | not)
          | select(.stateReason != "NOT_PLANNED")
          | . as $x
          | [.closedByPullRequestsReferences.nodes[] | select(.state == "MERGED")] as $closing
          | select($closing | length > 0)
          | [ .timelineItems.nodes[].source
              | select(.number != null and .state == "MERGED")
              | select(.body // "" | test("(?i)\\brefs #\($x.number)\\b"))
              | select([.body | scan("(?i)(?:closes|refs) #([0-9]+)") | .[0]] | unique | length == 1)
              | select(. as $p | ([$closing[].number] | index($p.number)) == null) ] as $refs
          | ($closing + $refs) as $prs
          | if $x.closedByPullRequestsReferences.pageInfo.hasNextPage or $x.timelineItems.pageInfo.hasNextPage
            then "#\($x.number) cites more pull requests than the query reads: score it by hand"
            elif ($refs | length) == 0 and ($closing | length) == 1
            then $closing[0] | select(.closingIssuesReferences.totalCount == 1)
                 | select(size != ($x | size))
                 | "#\($x.number) Size \($x | size // "none"), closing PR #\(.number) \(size // "none")"
            elif ($closing | map(.closingIssuesReferences.totalCount) | all(. == 1))
            then ([$prs[].files.nodes[].path] | unique | length) as $f
                 | ([$prs[] | .additions + .deletions] | add) as $l
                 | tier($f; $l) as $t
                 | select($t != ($x | size))
                 | "#\($x.number) Size \($x | size // "none"), PRs \($prs | names) score \($t) (\($f) files, \($l) lines)"
            else empty end ) ]
    | if length == 0 then empty else join("\n") + "\n" | halt_error(1) end'
```

**Parent:** every issue but the epic has the milestone's first `[epic]` issue
as its direct parent; in a patch milestone, any parent is a finding.

**`Size`:** skipping the cases "Size guide" exempts and issues with no merged
closing pull request, it reads each issue's closing pull requests and the merged
ones that say `Refs #n` and name no other issue, found by cross-reference
whatever their milestone. With one closing pull request and no `Refs` one, the
issue's `Size` equals that pull request's recorded one; with any other count, it
equals the tier of their union. More than 3 closing pull requests or 25
cross-references is a finding to score by hand, never a pass; paths stop at 41,
already `L`. Raising any page size can exceed GitHub's limit of 500,000 nodes.
