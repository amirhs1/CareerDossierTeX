---
name: project-metadata
description: Set and verify the GitHub Project fields (Status, Phase, Priority, Size), labels, milestone, assignee, and epic parent of a CareerDossierTeX issue or pull request. Use whenever an issue is filed, a pull request opens, or an open pull request's diff changes, and before a release to audit a milestone.
---

# Populate and verify GitHub Project metadata

`open-issue` and `open-pull-request` call this skill for the fields; it opens
nothing itself. `reference.md`, alongside this file, holds the values and the
commands. Read the item's current metadata live before changing it.

## Procedure

1. Read every id and option string live with `reference.md`, "1. Discover every
   id in one query": the lookup is by name, and a copied string that has
   drifted resolves to no option.
2. Choose each value from `reference.md`, "Project field values", and its "Size
   guide", and the labels from "Label selection".
3. Write every field in one mutation, `reference.md`, "4. Write every field in
   one mutation". An issue joins the Project as a sub-issue of its release
   epic; a pull request that closes only the focused issue also writes that
   issue's `Size`.
4. Read every field back and **assert** it, `reference.md`, "Verification". A
   blank is unfinished work: fill it and read back again.

Each step is one batched call; `reference.md`, "The shape of the sequence",
says why.

## Boundaries

`AGENTS.md`, "Git", bounds this delegation; `reference.md`, "Routine
authorization", adds the cases met while setting fields. When Project access is
unavailable, set what is reachable and report exactly what could not be set.
