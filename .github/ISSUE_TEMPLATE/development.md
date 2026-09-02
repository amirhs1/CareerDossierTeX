---
name: Development task
about: Documentation, tests, refactoring, CI, or agent-tooling work
title: "[area] "
labels: ""
assignees: ""
---

<!--
Apply one `type:*` label from `gh label list --limit 100` — `type:docs`,
`type:test`, `type:refactor`, `type:ci`, or `type:release` — and the relevant
`area:*` labels. This form pre-applies none, because the kind varies; the
bug and feature forms can pre-apply one because theirs does not.

For a user-visible feature use `feature_request.md`; for a reproducible defect
use `bug_report.md`; for work that genuinely decomposes into several issues use
`epic.md`.
-->

## Problem

What is wrong, missing, or duplicated today, and what observable state replaces
it. Lead with the symptom a reader can check, then the mechanism behind it.

## Included

-

## Excluded

-

## Likely files

Record the search that produced this list, not just the list. An issue scoped to
the first file someone noticed the statement in is fixed in that file alone,
which is how the same stale claim survives its own correction.

Scope the search by **excluding directories, never by filtering in on
extension** — `--include='*.md'` matches no file that has no extension, so it is
blind to `Makefile` and `LICENSE`. `git grep` needs neither flag: it searches
tracked files, so `build/` is excluded by construction.

```bash
# The command that produced the list below.
```

-

## Acceptance criteria

Where the issue concerns a statement or value that could appear in more than one
place, make at least one criterion a command over the repository rather than a
check of the files listed above. A criterion that reads only the named files
cannot fail on the copy nobody thought to look for. See `CONTRIBUTING.md`
section "Issue workflow" item 5.

```bash
# The command a reviewer runs to confirm no copy was missed.
```

- [ ]
- [ ]
- [ ]

## Testing

Name the fixture, runner, or lint under `tests/` that will prove the criteria
above, and the broader suites to rerun. When the deliverable is prose that no
suite reads, say so and name the mechanical check that does apply — `make lint`
resolves every `.md#anchor` in the tree and runs `shellcheck` over fenced shell.

## How this could be wrong

Only when something above prescribes a *mechanism* rather than an outcome —
"extract the shared half", "cache the result", "use a lock". Name the smallest
command that would show that mechanism does not work, and record what happened
when you ran it. `N/A` when the issue asks for an outcome and leaves the
mechanism to whoever implements it, which is the ordinary case.

The cost of skipping this is paid by the implementer, not the author: #392
prescribed warming biber's cache, and four concurrent `biber --version` calls
refuted it in five seconds — after the warm-up had been built, given its own
committed control, and documented in three files.

## Parent and release

- Parent issue:
- Milestone:
- Project phase:
