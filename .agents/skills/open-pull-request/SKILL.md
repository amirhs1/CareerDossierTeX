---
name: open-pull-request
description: Open a draft GitHub pull request whose body is the full report, and set its fields. Use when a change is committed and ready for review, or to update an open pull request's body; not for reviewing someone else's pull request.
---

# Open a pull request

1. Check the branch, the working tree, and `HEAD`; the branch is not `main`.
   Run the full gate in AGENTS.md, "Commands": `make check`.
2. Before the push, review the diff: `git status --short`, then the whole
   branch diff, `git diff origin/main...HEAD`, for unrelated files, generated
   artifacts, secrets, private data, and accidental deletions. A change on the
   list in AGENTS.md, "Ask first", needs that approval before you push it.
3. Confirm the branch is close-out-complete, as AGENTS.md, "Vocabulary",
   defines it: its tests are committed under `tests/`, the documentation it
   needs is updated, and every commit ends with its trailer block. Without a
   focused issue, stop before the push and ask the maintainer, unless the work
   is a revert, a release chore, or a repair that restores an existing check;
   then the body states the problem, the proposal, and the acceptance criteria
   instead (CONTRIBUTING.md, "Work item structure").
4. Write the body from `.github/pull_request_template.md`: every section, in
   order; a section that does not apply says `None`.
   - Summary: the reason only as the maintainer supplied it.
   - Related issues: one `Closes #n` per issue the pull request completes;
     `Refs #n` for one it covers only in part. From an early pull request,
     close the focused sub-issue, never its epic.
   - Checks run: commands you ran in this session, with their actual output.
   - Notes for review: mark every wording or design you proposed.
   - Last, your own trailer block, as AGENTS.md, "Provenance", gives it. Do
     not list the commits' trailers. Keep each trailer line within 72
     characters, since GitHub wraps the body into the merge commit; give a
     long check result in "Checks run" and a short one in the trailer.

   Write it to a file outside the repository, by absolute path.
5. Title and labels: follow "Names" in CONTRIBUTING.md. The type comes from
   the branch name; the areas, from the parts the diff changes.
6. Push the branch, open a draft, then read it back with `gh pr view`:
   `gh pr create --draft --base main --title "<title>" --label <labels> --body-file <file>`.
   Never mark it ready or merge it.
7. Set its fields with `project-metadata`: the assignee, the Project, the
   focused issue's milestone, `Phase`, and `Priority`, the in-progress
   `Status`, and `Size` scored from the diff. Its read-back adds four items for
   a pull request: the URL and draft status; the base and head branches; the
   focused issue the body links; and, for a pull request scored `L`, its extra
   obligation: stay draft and recommend splitting, unless broad scope was
   already approved.
8. If the branch already has a pull request, first check
   `gh pr view <n> --json state`, and stop if it has merged. Otherwise push,
   then replace its body and read it back:
   `gh pr edit <n> --body-file <file>`.
