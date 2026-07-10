# CLAUDE.md — CareerDossierTeX

@AGENTS.md

## Claude Code-specific instructions

- Treat `AGENTS.md` as the shared repository operating contract. Do not duplicate
  its contents here.
- Read `CLAUDE.local.md` when present for private project-specific preferences.
  It must remain gitignored and must never be committed.
- Put durable path-specific rules in `.claude/rules/` and recurring multi-step
  procedures in Claude Code skills rather than expanding this file.
- Treat CLAUDE.md guidance as context, not technical enforcement. Obey configured
  permissions, sandbox settings, hooks, and GitHub protections.
- Use Claude Code's current `attribution` settings for commit and PR attribution.
  Do not rely on the deprecated `includeCoAuthoredBy` setting, hard-code a model
  name, or add duplicate attribution.
- At the commit and PR approval checkpoints required by `AGENTS.md`, show the
  complete proposed message/body, including any attribution Claude Code will add.
