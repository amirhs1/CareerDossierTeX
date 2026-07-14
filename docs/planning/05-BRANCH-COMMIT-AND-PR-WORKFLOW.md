# Branch, Commit, and Pull-Request Workflow

## 1. Why use branches when working alone

Branches are not only for teams. They help you:

- isolate incomplete work;
- preserve a stable `main`;
- create a reviewable history;
- connect code changes to issues;
- practice the workflow used in software jobs;
- let CI verify changes before merge.

## 2. Branch naming

Use:

```text
type/short-description
```

Recommended types:

```text
feat/
fix/
docs/
test/
ci/
refactor/
release/
```

Phase 1 examples:

```text
docs/v0.1-api
refactor/current-class-inventory
feat/shared-foundation
feat/resume-class
feat/industry-letter
test/regression-harness
ci/xelatex-build
docs/v0.1-release
```

Do not include spaces. Keep names short but meaningful.

## 3. Standard branch workflow

### Update `main`

```bash
git switch main
git pull --ff-only
```

### Create a branch

```bash
git switch -c feat/resume-class
```

### Work in small steps

Inspect:

```bash
git status
git diff
```

Stage intentionally:

```bash
git add careerdossier-resume.cls
git add examples/industry/resume-english.tex
git add tests/regression/resume-options.lvt tests/regression/resume-options.tlg
```

Commit:

```bash
git commit -m "feat(resume): add initial English resume class"
```

Push:

```bash
git push -u origin feat/resume-class
```

Open a pull request on GitHub.

## 4. Commit-message convention

Use a lightweight Conventional Commits style:

```text
type(scope): imperative summary
```

Examples:

```text
docs(api): define v0.1 metadata keys
feat(core): add profile metadata storage
feat(resume): add dossier entry environment
feat(letter): add recipient address block
fix(components): omit separators for empty fields
test(resume): add long URL stress example
ci(build): compile industry examples with XeLaTeX
refactor(theme): centralize monochrome color tokens
```

Useful types:

```text
feat
fix
docs
test
ci
refactor
chore
release
```

A commit should represent one coherent change. Do not combine unrelated typography, API, CI, and documentation changes in one commit merely because they happened on the same day.

## 5. Connect commits and pull requests to issues

In the pull-request body, use:

```text
Closes #12
```

or:

```text
Fixes #12
```

When the PR merges into the default branch, GitHub closes the linked issue.

For a PR covering multiple tightly related issues:

```text
Closes #12
Closes #13
```

Avoid closing a large epic directly from an early implementation PR. Close its sub-issue instead.

## 6. Open draft pull requests early

A draft PR is useful when:

- the branch has been pushed;
- implementation is incomplete;
- you want CI to run;
- you want a visible place to record design decisions.

Suggested draft PR title:

```text
Draft: feat(resume): implement English resume class
```

When ready:

1. rebase or merge the latest `main` if needed;
2. confirm behavior changes include focused tests under `tests/`;
3. run local tests;
4. update documentation;
5. mark the PR ready for review;
6. move the Project item to `In review`.

## 7. Self-review checklist

Before merging your own PR:

- Read the full diff.
- Check for unrelated files.
- Check public command names.
- Check comments explain intent.
- Confirm no generated build files were accidentally committed.
- Confirm each behavior change has a focused committed test under `tests/`.
- Compile the affected examples.
- Check logs for overfull boxes and missing glyphs.
- Confirm documentation matches behavior.
- Confirm CI passes.
- Resolve all review comments and conversations.

A solo project still benefits from a deliberate review pause.

## 8. Merge strategy

Recommended:

```text
Squash and merge
```

Why:

- each PR becomes one understandable commit on `main`;
- temporary implementation commits remain available inside the PR;
- the main branch history stays readable.

Use the final squash title:

```text
feat(resume): add English industry resume class (#12)
```

After merge:

```bash
git switch main
git pull --ff-only
git branch -d feat/resume-class
```

Optionally delete the remote branch through the GitHub PR page.

## 9. When to use separate pull requests

Use separate PRs when changes have separate review questions.

Good split:

1. API documentation.
2. Shared foundation with its tests.
3. Résumé class with its tests.
4. Letter class with its tests.
5. CI.
6. Release documentation.

Do not create a milestone-end PR for tests already required by items 2--4. A
separate `test/` PR is appropriate only for shared test infrastructure,
cross-cutting coverage, or explicit legacy test debt.

Avoid an artificial PR for every one-line edit. The goal is a meaningful history, not maximum activity.

## 10. Handling changes discovered during implementation

When you discover unrelated work:

- create a new issue;
- label it;
- place it in the correct milestone or backlog;
- keep the current branch focused.

Only fix it immediately when it blocks the current issue.

This practice prevents scope creep and produces clearer pull requests.

## 11. Example end-to-end workflow

```bash
git switch main
git pull --ff-only
git switch -c feat/shared-foundation

# Add focused tests under tests/, then edit the implementation.

git status
git diff
git add careerdossier-base.sty careerdossier-i18n.sty tests/regression/
git commit -m "feat(core): add shared metadata foundation"
git push -u origin feat/shared-foundation
```

Then on GitHub:

1. Open a draft PR.
2. Add `Closes #<issue-number>`.
3. Add the PR to the Project.
4. Set Phase, Priority, and Status.
5. Let CI run.
6. Review the diff.
7. Mark ready.
8. Merge only when checks pass.
9. Confirm the linked issue closes.
