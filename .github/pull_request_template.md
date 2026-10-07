## Summary

What changed and why. The reason comes from a person or an outside report, not
from an AI tool; an agent gives it only as supplied.

## Related issues

Closes #

## Problem

What was wrong or missing, with evidence.

## What changed

Files as `path:line`, plus reasoning the diff does not show.

-
-

## Public API impact

- [ ] No public API change
- [ ] Public commands or keys added
- [ ] Public commands or keys changed
- [ ] Breaking change documented

## Checks run

Each check actually run, as `command → result`, and any human review or
independent reference used to judge correctness. Then a `Not verified:` line
for anything not checked, and why.

- [ ] Focused tests were added or updated under `tests/` with behavior changes
- [ ] Expected pre-fix failure was confirmed, or the reason it could not be was documented
- [ ] Compiled affected examples with `latexmk -lualatex`
- [ ] Relevant logs inspected
- [ ] No unexpected overfull boxes
- [ ] Missing optional fields render correctly
- [ ] Documentation updated
- [ ] Changelog updated when appropriate

## Visual verification

Attach or link the relevant PDF or preview when layout changed.

## Decisions and risks

Choices made, the alternatives rejected, and what could break.

## Notes for review

What needs line-by-line review, which wording is a proposal, and any
uncertainty, limitation, or follow-up issue.

## AI assistance

Keep this section last, and always fill it in.

Write `None`, or name each AI tool used, its model if known, its role, and what
it did. If the model was not recorded, write `not recorded`; do not guess. For
example:

```text
Claude Code (claude-opus-5-5): drafted the token refactor and its regression
test; I revised the error handling and reviewed the result.
Assisted-by: Claude Code, claude-opus-5-5 (partial implementation)
```

Then repeat each distinct `Assisted-by:` line on the branch exactly, so the
commit and pull request records agree. Copy them from the actual commits, not
from this example:
`git log --no-merges --format=%B main..HEAD | grep '^Assisted-by:' | sort -u`.
Do not include prompts, secrets, or personal data. This disclosure does not
transfer responsibility for the change; see `AI-POLICY.md`.
