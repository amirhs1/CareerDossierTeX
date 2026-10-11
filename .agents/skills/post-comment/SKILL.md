---
name: post-comment
description: Post a short comment on a GitHub issue or pull request. Use when asked to reply to, comment on, or revise your comment on an issue or pull request, not for comments in code.
---

# Post a comment

1. Comment only on the issue or pull request the person running you named.
2. Give the answer first, in the short form AGENTS.md, "Report back", gives:
   the answer in one or two sentences, then its `Based on:` and `Open:` lines.
   Cite evidence as `path:line` or `command → result`. Include no secrets or
   personal data. End with your trailer block, as AGENTS.md, "Provenance",
   gives it.
3. Write the body to a file outside the repository, by absolute path, and post
   it with `gh issue comment <n> --body-file <file>` or
   `gh pr comment <n> --body-file <file>`.
4. To revise your last comment there, run the same command with
   `--edit-last`.
