@AGENTS.md

## Sandbox and permissions

`.claude/settings.json` denies reading and editing private paths, asks before
the commands only the maintainer may run, and runs Bash in a sandbox with `gh`
excluded. These settings bind Claude Code only.

- `gh` must be the whole command. Inside a loop, a subshell, `$(…)`, `xargs`,
  a pipe, or a redirect it runs sandboxed and fails with
  `tls: failed to verify certificate: x509: OSStatus -26276` — the sandbox, not
  the network (measured 2026-10-07). Assert with `gh`'s own `--jq`; batch with
  one `gh api graphql` document.
- Run these with the sandbox off: `make check`, writes to `.git/config`
  (`git config`, `git push -u`), and writes under `.claude/`.
- `allowWrite` covers `~/Library/texlive`, LuaLaTeX's font cache. Without it
  TeX typesets empty `nullfont` documents that pass every build and fail every
  baseline; never regenerate a baseline from such a run (#386, #392).
- Never `git stash` while `.claude/settings.json` is modified: the sandbox
  stops git rewriting it, and the working tree is left half reset.

## Git attribution

Claude Code's own commit and pull-request attribution is turned off in
`.claude/settings.json`. Do not rely on the deprecated `includeCoAuthoredBy`
setting.
