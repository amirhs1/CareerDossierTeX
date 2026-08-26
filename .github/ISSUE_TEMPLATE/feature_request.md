---
name: Feature
about: Propose or implement a scoped feature
title: "[area] "
labels: "type:feature"
assignees: ""
---

## Goal

Describe the user-visible or maintainer-visible result.

## Motivation

Why is this feature needed?

## Included

-

## Excluded

-

## Proposed public interface

```latex
% Add commands, options, keys, or environments when relevant.
```

## Likely files

Record the search that produced this list, not just the list. An issue scoped to
the first file someone noticed the statement in is fixed in that file alone,
which is how the same stale claim survives its own correction.

```bash
# The command that produced the list below.
```

-

## Acceptance criteria

Where the issue concerns a statement or value that could appear in more than one
place, make at least one criterion a command over the repository rather than a
check of the files listed above. Scope it by excluding directories, never by
filtering in on extension — `--include='*.md'` is blind to `Makefile` and
`LICENSE`. See `CONTRIBUTING.md` section "Issue workflow" item 5.

```bash
# The command a reviewer runs to confirm no copy was missed.
```

- [ ]
- [ ]
- [ ]

## Testing

List the focused fixture, expected output, or runner that will be added under
`tests/` with this feature. State how the test will demonstrate the behavior
before implementation when practical, and list the broader suites to rerun.

## How this could be wrong

Only when something above prescribes a *mechanism* rather than an outcome —
"warm the cache", "cache the result", "use a lock". Name the smallest command
that would show that mechanism does not work, and record what happened when you
ran it. `N/A` when the issue asks for an outcome and leaves the mechanism to
whoever implements it, which is the ordinary case.

The cost of skipping this is paid by the implementer, not the author: #392
prescribed warming biber's cache, and four concurrent `biber --version` calls
refuted it in five seconds — after the warm-up had been built, given its own
committed control, and documented in three files.

## Parent and release

- Parent issue:
- Milestone:
- Project phase:
