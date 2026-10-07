---
name: write-commit
description: Write and make a commit in this project's format, ending with one trailer block. Use for every commit.
---

# Write a commit

`AGENTS.md` ("Commit format") holds the rules; this skill is the procedure.

1. Stage the files by name and read the staged diff (`git diff --cached`). One
   commit holds one coherent change.
2. Subject: `type(scope): imperative summary`, with the types and scopes
   `AGENTS.md` ("Commit format") lists, and no agent or tool prefix.
3. Body: bullets of what changed, including which wording or code you were
   given and which you wrote. This is where the detail of your role goes.
4. `Why:` only for a reason the maintainer supplied, in the issue, the pull
   request, or this session, or for an outside report the change answers.
   Otherwise leave it out.
5. End with one trailer block, after a blank line, with no blank line in it and
   nothing after it: `Assisted-by: <tool>, <model id or not recorded> (<role>)`,
   then `Checks-run:` for each check you ran on this commit's tree, then
   `Ground-truth-source:` if a reference value changed. Pick the role as
   `AGENTS.md` ("Commit format") defines it.
6. Commit from a file: `git commit -F <message file>`. Never add an AI
   `Co-authored-by:` line, and never use `--no-verify`. If the `commit-msg`
   hook rejects the message, fix the message.
7. Check that git reads every trailer: `git log -1 --format='%(trailers)'`.
