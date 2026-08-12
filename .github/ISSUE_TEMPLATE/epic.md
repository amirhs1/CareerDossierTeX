---
name: Epic
about: Group work that genuinely decomposes into several issues
title: "[epic] Release vX.Y.Z release goal"
labels: ""
assignees: ""
---

<!--
Title form: `docs/NAMING-CONVENTION.md` section 2, "Epic issue titles".
Open an epic only for work that genuinely decomposes into several issues —
a release epic, or a cross-cutting effort spanning more than one class or
package. `CONTRIBUTING.md` "Work item structure" is canonical for when an epic
is warranted. Apply one `type:*` label and the relevant `area:*` labels from
`gh label list --limit 100`; there is no epic-specific label.
-->

## Goal

The one result this epic delivers, in a sentence.

## Scope

The sub-issue graph on this epic is canonical: add each issue as a sub-issue
rather than listing it here. Name the milestone every sub-issue carries, and
anything deliberately excluded.

## Definition of done

- every sub-issue closed;
- `make check` green at the closing commit;
- documentation and `CHANGELOG.md` updated as the work required.

## Release

- Milestone:
- Project phase:
