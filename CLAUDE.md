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

### `gh` must lead the Bash invocation

The `gh` exclusion in `.claude/settings.json` is matched against the command
Claude runs, not against the calls nested inside it. `gh` must therefore be the
**leading** command; a trailing pipeline is fine, and everything that nests it
is not. Measured, not inferred:

| Form | Result |
|---|---|
| `gh api …` | works |
| `gh api … \| cat` | works — `gh` still leads |
| `for i in 1; do gh api …; done` | denied |
| `( gh api … )` | denied |
| `V="$(gh api …)"` | denied |
| `echo x \| xargs gh api …` | denied |
| `gh api graphql -f query='…multi-line…'` | works — `gh` still leads |

A denied call fails with:

```text
tls: failed to verify certificate: x509: OSStatus -26276
```

which is a sandbox denial wearing a TLS error's clothes. It reads as a network
or certificate problem and invites the wrong fix; there is no `gh` outage to
work around.

The last row was measured on 2026-08-12 against the discovery query in
`.agents/skills/open-draft-pr/reference.md`; the rest on 2026-08-11 against
`gh api rate_limit`.

Two consequences worth having in advance. Batching `gh` calls into a loop to
save round-trips costs a failed run plus a second permission gate — more than
the round-trips it saves. And capturing output with `V="$(gh …)"` is denied even
though the same call is fine bare, so read the value from the command's own
output, or run that one call with the sandbox disabled deliberately rather than
after a confusing failure.

That leaves exactly one way to batch here, and the table is why. A wrapper
script — `scripts/pr-metadata.sh` around a sequence of `gh` calls — is the shape
the loop row already rules out, and buying it back with a permission entry is
the weakening "Permissions and enforcement" above forbids. `gh api graphql` is
the form that survives: it leads the invocation, needs no permission change, and
batches inside one request rather than around several.
`.agents/skills/open-draft-pr/reference.md` (appendix) is where that is spent,
and is canonical for the procedure.

## Git attribution

Use Claude Code's current `attribution` configuration, and do not rely on the
deprecated `includeCoAuthoredBy` setting. That configuration is how this tool
satisfies `AI-POLICY.md` ("Attribution"), which is normative for the trailer
format, when a tool may be attributed at all, the separate PR-disclosure
obligation, and why the trailer identity is not a fixed string.
