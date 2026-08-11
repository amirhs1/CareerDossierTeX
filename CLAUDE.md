# CLAUDE.md — CareerDossierTeX

@AGENTS.md

## Shared contract

`AGENTS.md` is the canonical operating contract for every agent, and the import
above loads it. Do not restate it here; add only Claude Code-specific behavior
below. Anything that is also true for another agent belongs in `AGENTS.md` or in
the relevant `.agents/skills/` entry, not in this file.

## Local and scoped instructions

- Read `CLAUDE.local.md` when present; keep it gitignored and never commit it.
- Recurring multi-step procedures load on demand from `.claude/skills/`, whose
  entries are symlinks into `.agents/skills/`:

```text
.claude/skills/open-draft-pr  -> ../../.agents/skills/open-draft-pr
.claude/skills/release-notes  -> ../../.agents/skills/release-notes
```

Each skill states its own procedure, entry point, and boundaries; `AGENTS.md`
says when to load it. Edit the file in `.agents/`, never the link, and never
replace a link with a copy — a second copy is what let the two skill sets drift
apart before this layout.

## Permissions and enforcement

Treat instruction files as behavioral guidance, not technical enforcement. Obey
Claude Code permissions, sandbox settings, hooks, and GitHub branch protection.
Never bypass a denied command or weaken a permission rule. The committed
`.claude/settings.json` denies built-in file access to private repository paths
and enables sandbox enforcement for Bash — with `gh` excluded — when the
effective settings and local installation support it; verify the effective state
and do not claim OS-level isolation when the sandbox is inactive or unavailable.

## Git attribution

Use Claude Code's current `attribution` configuration. Do not rely on the
deprecated `includeCoAuthoredBy` setting, replace configured attribution with a
hard-coded generic identity, or add a duplicate attribution trailer. Attribute
Claude only when it materially co-authored the commit, and preserve at most one
attribution block.

`AGENTS.md` ("AI attribution and disclosure") holds the trailer format, the
separate PR-disclosure obligation, and why the trailer identity is not a fixed
string.
