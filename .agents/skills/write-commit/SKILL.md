---
name: write-commit
description: Write and make a commit in this project's format, ending with one trailer block. Use for every commit.
---

# Write a commit

Every AI-assisted commit follows this format and ends with `Assisted-by:`.

```text
<type>(<scope>): <imperative summary>

<what changed>

Why: <reason supplied by the maintainer; omit for a trivial change>

Assisted-by: <tool>, <model identifier or not recorded> (<role>)
Checks-run: <check actually run> — <observed result>
Ground-truth-source: <independent source of a reference value>
```

## Rules

- `type` is `feat`, `fix`, `docs`, `test`, `ci`, `refactor`, `chore`, or
  `release`. `scope` names the part of the repository affected, such as
  `core`, `tokens`, `components`, `resume`, `test`, `build`, or `agents`;
  prefer a scope already in `git log --format='%s' main`. Keep the subject
  short and imperative, with no agent or tool prefix, and one coherent change
  in each commit.
- Write the subject and what changed. Add the reason only if the maintainer
  gave you one, in the issue, the pull request, or this session, or if an
  outside report the change answers supplies it; otherwise leave it out or
  ask. Never write a placeholder.
- All trailers sit in one final paragraph, one per line, with no blank line
  between them and nothing after them. `Why:` stays in the body above it.
- `Assisted-by:` names your actual model and one role, with no free detail; the
  body carries the detail. If you don't know the model, write `not recorded`;
  never guess or fill it in later from memory. Pick the first role that fits:
  - `full implementation`: you wrote essentially all of the committed content.
  - `partial implementation`: you wrote part of it; a person wrote the rest.
  - `refactor`: you chose how to restructure existing content without changing
    what it does or says.
  - `plan`: you proposed the approach or steps; a person wrote the content.
  - `review`: you reviewed or tested a person's work and wrote none of it.
  - `transcription`: a person wrote or fully specified the change; you
    entered, moved, formatted, or committed it without adding content.
- Add `Checks-run:` only for a check actually run, with its observed result.
- Add `Ground-truth-source:` only when the commit adds or changes a reference
  value, such as a baseline, naming its independent source. A property test
  without a reference value does not need it.
- Do not add a `Co-authored-by:` line for an AI tool; write `Assisted-by:`
  instead.
- If the `commit-msg` hook rejects a commit, fix the message. Never use
  `--no-verify`.

## Procedure

1. Stage the files by name and read the staged diff (`git diff --cached`).
2. Write the message to a file outside the repository, in the format above.
   The body's bullets say which wording or code you were given and which you
   wrote; that is where the detail of your role goes.
3. Commit from the file: `git commit -F <message file>`.
4. Check that git reads every trailer: `git log -1 --format='%(trailers)'`.
