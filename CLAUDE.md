# CLAUDE.md — CareerDossierTeX

@AGENTS.md

## Shared contract

`AGENTS.md` is the canonical operating contract for every agent. Do not restate
it here; add only Claude Code-specific behavior below.

## Local and scoped instructions

- Read `CLAUDE.local.md` when present; keep it gitignored and never commit it.
- Path-scoped rules live in `.claude/rules/` and load only for matching files
  (for example, `.claude/rules/latex.md` for `*.tex`, `*.sty`, `*.cls`, `*.dtx`,
  and `*.ins`).
- Recurring multi-step procedures live in `.claude/skills/` and load on demand.

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

## Draft pull requests

For an authorized draft PR, follow `.claude/skills/open-draft-pr/SKILL.md`, which
loads `docs/agent-workflows/github-project.md`. If GitHub Projects access is
unavailable, set all supported ordinary PR metadata and report exactly which
Project fields remain unset.

## Release notes

For a `CHANGELOG.md` entry or GitHub Release notes, follow
`.claude/skills/release-notes/SKILL.md`, which loads
`docs/agent-workflows/release-notes.md`. Never tag or publish a release
without the maintainer's explicit authorization for that exact release.
