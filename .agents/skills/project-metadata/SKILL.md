---
name: project-metadata
description: Populate and verify the GitHub Project fields, labels, milestone, and assignee on a CareerDossierTeX issue or pull request. Use to set the fields of an issue or pull request.
---

# Populate and verify GitHub Project metadata

Read `reference.md`, alongside this file, and the item's own current
metadata, read live.

## What this skill owns

The metadata half of every tracked object: `Status`, `Phase`, `Priority`,
`Size`, the milestone, labels, the assignee, and Project membership. It applies
to an **issue** and to a **pull request** alike — the fields are the same, the
option ids are the same, and the read-back obligation is the same.

It does not open anything. `open-pull-request` owns the close-out gate, the
pull request body, and the push, and adds four items to this skill's read-back;
`open-issue` owns an issue's form and the procedure around it. Each calls this
skill for the fields.

## Procedure

1. Read every id and option string live, from `reference.md` ("1. Discover every
   id in one query"). Never from prose in this file, that one, or any other:
   option lookup is by name and a transcription that has drifted resolves to no
   option id.
2. Determine each value from `reference.md` ("Project field values"): `Status`
   from `CONTRIBUTING.md` ("Project Status convention"), `Phase` and
   `Priority` inherited, `Size` from the "Size guide".
3. Apply the labels `reference.md` ("Label selection") calls for — one primary
   `type:*`, every relevant `area:*` — from `CONTRIBUTING.md` ("Names").
4. Write every field in one mutation, per `reference.md` ("4. Write every field
   in one mutation"). A batched write fails per alias, not per call.
5. Read every field back and **assert** it, per `reference.md`
   ("Verification"). A blank is unfinished work, not a reporting line: fill it
   and read back again.

Steps 1–5 batch their reads and writes rather than making one call per field.
`reference.md` ("The shape of the sequence") counts the calls, and its appendix
is canonical for the shape and for why a wrapper script is not an option here.

## Boundaries

`AGENTS.md` ("Git") states the complete boundary on this delegation; it is not
restated here. `reference.md` ("Routine authorization")
adds only the GitHub-object cases an agent meets while setting fields.

When Project access is unavailable — a missing `project` token scope, or missing
identifiers — set every field that is reachable, then report the exact fields
that could not be set rather than claiming completion.
