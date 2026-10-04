# AI Policy — CareerDossierTeX

Last reviewed: 2026-10-03

AI tools are welcome here. They don't change who is responsible: whoever
submits a change must understand it, have checked it, and be able to explain
it. This applies to maintainers too. How AI was used in this project, and how
each part was checked, is described in the README.

## Verification

- Expected results come from outside the AI's own output: documented
  behavior, a page a person has inspected, or an independent implementation.
  If none exists, test a property (the same input gives the same output,
  extracted text keeps its reading order, a missing field leaves no stray
  separator) and say so.
- Replace a stored reference value only after a person has inspected the new
  output, and say so in the pull request.
- Do not weaken or delete a test to make it pass.
- Reported measurements, such as spacing, page counts, or timings, trace back
  to the run that produced them.
- Check every citation against its source before using it; an AI-suggested
  reference is a lead, not evidence.
- Decisions about the public API, typography, and test baselines are made by a
  person, not an AI tool.

## Disclosure

- Say in the pull request which AI tools you used and for what. If you don't
  know which model was used, write `not recorded`; don't guess.
- Maintainers record substantial AI help in commits with an `Assisted-by:`
  trailer. Add `Checks-run:` only for a check actually run, with its observed
  result. Add `Ground-truth-source:` only when a commit adds or changes a
  reference value, naming its independent source. Outside contributors may use
  these trailers too, but their pull-request statement is enough.

  ```text
  Assisted-by: <tool>, <model identifier or not recorded> (<role or extent>)
  Checks-run: <check actually run> — <observed result>
  Ground-truth-source: <independent source of a reference value>
  ```

  Omit trailers that do not apply. A property test without a reference value
  does not need `Ground-truth-source:`.

## Communication

Write issues, pull request descriptions, and replies in your own words. AI may
fix grammar or translate. The reason a change exists — in a commit, pull
request, or changelog — comes from a person, not from the AI.

## Licensing and data

- You must have the right to submit what you submit. AI output that reproduces
  someone else's code is their code: attribute it under its license or replace
  it.
- Do not give AI tools credentials, private or restricted data, or material you
  are not allowed to share.

## Agents

AI agents act only on a maintainer's request; they may open draft pull
requests, and a person reviews and merges. Instructions for agents working in
this repository are in `AGENTS.md`.

## Enforcement

Maintainers may close a contribution that does not follow this policy without a
full review.
