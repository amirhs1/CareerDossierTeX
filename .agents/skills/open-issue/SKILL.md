---
name: open-issue
description: Open a CareerDossierTeX issue from its form, with its title, milestone, labels, and Project fields. Use to open an issue.
---

# Open an issue

The forms in `.github/ISSUE_TEMPLATE/` supply an issue's body; this skill is the
procedure around them, and `project-metadata` sets the fields.

1. Search for a duplicate first:
   `gh issue list --state all --search "<terms>"`.
2. Pick the form by what the issue delivers, never a blank body:

   | Form | For |
   | --- | --- |
   | `development.md` | documentation, tests, refactoring, CI, or agent tooling |
   | `feature_request.md` | a user-visible or maintainer-visible new capability |
   | `bug_report.md` | a reproducible LaTeX, layout, or build defect |
   | `epic.md` | work that genuinely decomposes into several issues |

3. Fill every section the form has. "Likely files" is the output of a search
   command, recorded beside it. Where the issue concerns a statement or value
   that could appear in more than one place, at least one acceptance criterion
   is a command over the repository, scoped by excluding directories, never by
   filtering in on extension.
4. The reason comes from the person who asked, or from the evidence; never
   invent it. Mark wording you drafted as a proposal, and include no secrets
   or personal data.
5. Title: `[area] Verb object`, in the imperative; an epic is
   `[epic] Release vX.Y.Z goal`.
6. Milestone: every issue carries one, unless its release is genuinely
   undecided (today only #120); never invent a placeholder milestone. Give an
   issue an epic parent only when the work genuinely decomposes into several
   issues.
7. Labels: one primary `type:*` label and every relevant `area:*` label, from
   `gh label list --limit 100`, which defines them. The development form
   applies no `type:*` label itself.
8. Unless the person running you asked you to create it directly, show them
   the title and body first.
9. Create it with the body in a file outside the repository:
   `gh issue create --title "<title>" --body-file <file> --assignee amirhs1 --label <type> --label <area> --milestone "<milestone>"`.
10. Set its Project fields with `project-metadata`, then report back as
    `AGENTS.md` ("Report back") says.
