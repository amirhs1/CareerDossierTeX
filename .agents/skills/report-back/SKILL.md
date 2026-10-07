---
name: report-back
description: Report back in chat in the full or the short form, with progress lines while the maintainer is away. Use at the end of every task.
---

# Report back

`AGENTS.md` ("Report back") states the rules: which form, one verdict, and no
section dropped. This skill holds the forms.

1. Choose the form. Full: this session changed a file, opened or updated an
   issue or pull request, or needs a decision. Otherwise short. Posting a
   comment gets the short form.
2. Fill every section; a section that does not apply says `None`. Give the
   verdict once, at the top.
3. Report actual output, not expected output. Say what was not run, and why.
4. List each decision you made that was the maintainer's.

## Short form

```text
<Answer in one or two sentences.>
Based on: <files read or commands run; "memory only" if nothing was checked>
Open: <anything unverified, or None>
```

## Full form

The title line is the branch's own commit and pull request title, with a
`closes #<issue>` suffix:

```text
## <type>(<scope>): <summary> — closes #<issue>

**Verdict: COMPLETE — nothing further, safe to approve on green.**
(or) **Verdict: NOT COMPLETE — remaining: <what is outstanding>.**
```

Then the seven numbered sections, in this order:

| Section                            | Carries                                                                                                       |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| 1 Problem                          | the observable symptom first, then the mechanism behind it                                                    |
| 2 What changed                     | every file touched, as `path:line`, and the reasoning a reader cannot reconstruct from the diff               |
| 3 Visual impact                    | `None`, with the evidence establishing it — or what moves, and how that was confirmed                         |
| 4 Test criteria                    | the criteria this change had to meet, the exact commands run and their outcomes, and what was not run and why |
| 5 Decisions I made that were yours | each call made without asking, the alternative rejected, and what reversing it would cost                     |
| 6 What I need from you             | each item tagged `Action Needed:` or `Decision Needed:`, blocking items first; then what is worth knowing but is not blocking; then follow-up issues opened or proposed. `None` when nothing is needed |
| 7 Close-out actions                | approve on green or not; what to do with the branch; anything to preserve before the session ends             |

Each section is a few lines: the report is a summary, and reasoning a reviewer
needs in order to judge the change belongs in the pull request body. Four
sections answer a recurring failure: 3 because the first question after any
change is _does it look different_; 4 because a criterion with no command
against it is unmet, not implied; 5 because the expensive failure is a silent
judgement call, not a bug; and 7 because a close-out should be actionable
without reading the six above it.

A skill's read-back, such as `project-metadata` ("Verification") or
`release-notes` ("Verification"), is the payload of section 4. It is not a
second report and has no verdict of its own.

## Progress lines

When the maintainer is not at the keyboard, send one progress line at each
step of `AGENTS.md` ("How to work here"), not one per tool call:

```text
**[n/8] <step>** — <what just happened, one line>
Next: <one line>
Blocked: <only when true>
```

`n` is the step's number and the step's name follows it. Step 4 covers the
failing test and the implementation together and is reported once. Progress
lines do not replace the full report.
