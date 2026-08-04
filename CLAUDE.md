# CLAUDE.md — CareerDossierTeX

@AGENTS.md

## Shared contract

`AGENTS.md` is the canonical operating contract for every agent. Do not restate
it here; add only Claude Code-specific behavior below.

## Local and scoped instructions

- Read `CLAUDE.local.md` when present; keep it gitignored and never commit it.
- Recurring multi-step procedures load on demand from `.claude/skills/`, whose
  entries are symlinks into `.agents/skills/`:

```text
.claude/skills/open-draft-pr  -> ../../.agents/skills/open-draft-pr
.claude/skills/release-notes  -> ../../.agents/skills/release-notes
```

Edit the file in `.agents/`, never the link, and never replace a link with a
copy — a second copy is what let the two skill sets drift apart before this
layout.

## Permissions and enforcement

Treat instruction files as behavioral guidance, not technical enforcement. Obey
Claude Code permissions, sandbox settings, hooks, and GitHub branch protection.
Never bypass a denied command or weaken a permission rule. The committed
`.claude/settings.json` denies built-in file access to private repository paths
and enables sandbox enforcement for Bash when the effective settings and local
installation support it; verify the effective state and do not claim OS-level
isolation when the sandbox is inactive or unavailable.

## Git attribution

Use Claude Code's current `attribution` configuration. Do not rely on the
deprecated `includeCoAuthoredBy` setting, replace configured attribution with a
hard-coded generic identity, or add a duplicate attribution trailer. Attribute
Claude only when it materially co-authored the commit, and preserve at most one
attribution block.

The trailer names the session's active model, so it is not a constant — this
repository already contains both `Claude Opus 5` and `Claude Sonnet 5
<noreply@anthropic.com>`. Copy the identity from the commit when writing the PR
disclosure; never retype it from memory.

The commit trailer does not satisfy the PR disclosure. `AGENTS.md` ("AI
attribution and disclosure") requires both, and the `AI assistance` section is
the last section of `.github/pull_request_template.md`.

## Draft pull requests

For an authorized draft PR, follow the `open-draft-pr` skill, which loads
`.agents/skills/open-draft-pr/reference.md`. Build the PR body from
`.github/pull_request_template.md` and fill every section, including the final
`AI assistance` one. If GitHub Projects access is unavailable, set all supported
ordinary PR metadata and report exactly which Project fields remain unset.

## Release notes

For a `CHANGELOG.md` entry or GitHub Release notes, follow the `release-notes`
skill, which loads `.agents/skills/release-notes/reference.md`. Never tag or publish
a release without the maintainer's explicit authorization for that exact
release.
