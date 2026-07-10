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
Never bypass a denied command or weaken a permission rule.

## Git attribution

Use Claude Code's current `attribution` configuration. Do not rely on the
deprecated `includeCoAuthoredBy` setting, hard-code a model name, or add a
duplicate attribution trailer. Preserve at most one attribution block.

## Draft pull requests

For an authorized draft PR, follow `.claude/skills/open-draft-pr/SKILL.md`, which
loads `docs/agent-workflows/github-project.md`. If GitHub Projects access is
unavailable, set all supported ordinary PR metadata and report exactly which
Project fields remain unset.
