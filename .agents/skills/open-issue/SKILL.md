---
name: open-issue
description: Open a GitHub issue from this repository's issue forms, with its title, labels, milestone, and Project fields. Use when asked to file or revise an issue; not for a suspected vulnerability or a reply on an existing issue.
---

# Open an issue

1. A suspected vulnerability never goes into a public issue: stop and tell the
   person running you.
2. Search for a duplicate first:
   `gh issue list --state all --search "<terms>"`.
3. Title: follow "Names" in CONTRIBUTING.md.
4. Body: the form in `.github/ISSUE_TEMPLATE/` that fits what the issue
   delivers, never a blank body:

   | Form                 | For                                                     |
   | -------------------- | ------------------------------------------------------- |
   | `development.md`     | documentation, tests, refactoring, CI, or agent tooling |
   | `feature_request.md` | a user-visible or maintainer-visible new capability     |
   | `bug_report.md`      | a reproducible LaTeX, layout, or build defect           |
   | `epic.md`            | work that genuinely decomposes into several issues      |

   - Fill every section the form has. "Likely files" is the output of a search
     command, recorded beside it.
   - Where the issue concerns a statement or value that could appear in more
     than one place, at least one acceptance criterion is a command over the
     repository, scoped by excluding directories, never by filtering in on
     extension.
   - Mark wording you drafted as a proposal.
   - Last, your trailer block, as AGENTS.md, "Provenance", gives it.
5. The reason comes only from a person or from the source of the evidence;
   never invent it. Include no secrets or personal data.
6. Labels, from "Names": the type that fits the work, with the form's type as
   the default, and the area of each part it changes.
7. Milestone: every issue carries one, unless its release is genuinely
   undecided; never invent a placeholder. Give an issue an epic parent only
   when the work genuinely decomposes into several issues.
8. Unless the person running you asked you to create it directly, show them
   the title and body first.
9. Write the body to a file outside the repository, by absolute path, and open
   the issue with
   `gh issue create --title "<title>" --label <labels> --milestone <milestone> --assignee amirhs1 --body-file <file>`.
10. Set its Project fields with `project-metadata`.
11. To revise an issue you opened, rewrite its body file and run
    `gh issue edit <n> --body-file <file>`.
