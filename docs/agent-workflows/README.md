# Agent-instruction file set

This directory documents how coding agents (OpenAI Codex and Anthropic Claude
Code) are configured for `CareerDossierTeX`.

## Principle

Shared repository policy lives in neutral files. Instruction content has exactly
one copy, in the vendor-neutral `.agents/` directory. A tool-specific directory
holds only that tool's own settings, plus symlinks pointing at the neutral copy.
Nothing is duplicated.

This is not a style preference. `.claude/skills/open-draft-pr/SKILL.md` and
`.agents/skills/open-draft-pr/SKILL.md` were maintained as two "nearly
identical" copies, and they silently diverged: the Claude copy lost the
AI-disclosure step the Codex copy had. Two copies of a rule means one of them is
wrong and nobody finds out.

## Layout

```text
CareerDossierTeX/
├── AGENTS.md                                 # shared operating contract (canonical)
├── AI-POLICY.md                              # public AI-use and contribution policy
├── CLAUDE.md                                 # Claude Code adapter: @AGENTS.md + Claude-only notes
├── .github/pull_request_template.md          # canonical PR section set; AI assistance last
├── docs/agent-workflows/
│   ├── README.md                             # this map
│   ├── github-project.md                     # draft-PR + Project metadata workflow (+ gh commands)
│   └── release-notes.md                      # CHANGELOG + GitHub Release workflow (+ gh commands)
├── .agents/                                  # vendor-neutral, canonical
│   ├── rules/latex.md                        # path-scoped LaTeX rules (*.tex/*.sty/*.cls/*.dtx/*.ins)
│   └── skills/
│       ├── open-draft-pr/SKILL.md            # draft-PR skill
│       └── release-notes/SKILL.md            # CHANGELOG/release-notes skill
├── .claude/                                  # Claude Code only
│   ├── settings.json                         # permissions and sandbox settings
│   ├── rules/latex.md          -> ../../.agents/rules/latex.md
│   └── skills/
│       ├── open-draft-pr       -> ../../.agents/skills/open-draft-pr
│       └── release-notes       -> ../../.agents/skills/release-notes
└── .codex/config.toml                        # Codex only: sandbox mode
```

Edit the file in `.agents/`. Never edit through a link, and never replace a link
with a copy.

## Why this split

`.agents/skills/` is the cross-tool convention: Codex scans `.agents/skills/`
directly, and the Agent Skills specification recommends it precisely so skills
installed by one client are visible to another. Claude Code scans
`.claude/skills/` instead, and documents that a skill entry may be a symlink to
a directory elsewhere, which it follows to read `SKILL.md`. The symlinks are the
supported bridge between the two.

Rules are the asymmetric case, and `.agents/rules/` is **a local convention, not
a standard**. No vendor documents it and no tool discovers it. Claude Code's
`.claude/rules/` with `paths:` frontmatter is the only path-scoped rules feature
that exists; Codex's "rules" are sandbox command permissions, an unrelated
feature that shares the name.

So the rules file is reached exactly one way: Claude Code reads
`.claude/rules/latex.md`, which is a symlink. `.agents/rules/` holds the file so
that every piece of agent instruction content has one home and one copy, and so
a second tool that gains the feature has an obvious place to point at. It earns
nothing from any tool today. If that indirection ever costs more than it is
worth, the correct simplification is to move the file back to
`.claude/rules/latex.md` and drop the link — not to add a second copy.

Because Codex cannot read that file at all, the concise LaTeX invariants are
*also* stated in `AGENTS.md`. That single overlap is deliberate and is the one
place the no-duplication rule is relaxed.

A caveat worth knowing: a Git checkout on a filesystem or platform without
symlink support materializes these links as plain text files containing their
target path. If a tool reports an unreadable skill or rule, check that first.

## Files

- **`AGENTS.md`** — the canonical contract: purpose, sources of truth, scope and
  verification rules, module ownership, API/LaTeX conventions, build/test
  expectations, design and accessibility baselines, the Git and draft-PR
  authority model, high-risk approval gates, CI/CD, licensing, and completion
  reporting. Codex reads it directly; Claude Code reads it through `CLAUDE.md`.
- **`AI-POLICY.md`** — the public policy for AI-assisted work: human
  accountability, disclosure, attribution, verification, security, privacy,
  and licensing.
- **`CLAUDE.md`** — a small Claude adapter. It imports `AGENTS.md` with
  `@AGENTS.md` (Claude Code reads `CLAUDE.md`, not `AGENTS.md`) and adds only
  Claude-specific guidance for `CLAUDE.local.md`, the symlinked rules and skills,
  permissions/enforcement, attribution, and the draft-PR and release-notes
  skills.
- **`docs/agent-workflows/github-project.md`** — neutral, human-readable workflow
  shared by both agents: authority boundary, PR-body sections, labels, milestone,
  Project membership, Status/Phase/Priority/Size rules, status transitions,
  approval boundaries, verification, and a `gh` command appendix.
- **`docs/agent-workflows/release-notes.md`** — neutral, human-readable workflow
  shared by both agents for `CHANGELOG.md` entries and GitHub Release notes:
  the CHANGELOG-vs-Release authority boundary, house style, the LaTeX-package
  compatibility checklist, verification, and a `gh` command appendix.
- **`.github/pull_request_template.md`** — the canonical PR section set for both
  humans and agents. `AI assistance` is deliberately its last section, and it is
  never left as unfilled template text.
- **`.agents/skills/open-draft-pr/SKILL.md`** — the single draft-PR skill, used
  by every agent. It holds the PR-body procedure, including how to fill the
  `AI assistance` section from the branch's real commit trailers.
- **`.agents/skills/release-notes/SKILL.md`** — the single skill for CHANGELOG
  entries and release-note drafts.
- **`.agents/rules/latex.md`** — the detailed LuaLaTeX, module-ownership,
  optional-field, log-inspection, and accessibility-claim rules. Its `paths:`
  frontmatter scopes it to LaTeX sources so it loads only when relevant.
- **`.claude/settings.json`** and **`.codex/config.toml`** — the only genuinely
  tool-specific files. `settings.json` denies Claude's built-in read and edit
  tools access to repository paths declared private and extends those
  restrictions to sandboxed Bash when supported; `config.toml` sets Codex's
  sandbox mode. Neither holds anything another tool would need.

## Maintenance

- Shared AI posture belongs in `AI-POLICY.md`; enforceable contributor and agent
  rules belong in `CONTRIBUTING.md` and `AGENTS.md`.
- Skills and path-scoped rules belong in `.agents/`, once. A tool directory gets
  a symlink, not a copy.
- A tool directory holds only that tool's settings: `.claude/settings.json` for
  Claude Code permissions and sandbox defaults, `.codex/config.toml` for Codex.
- Adding a third agent means adding its settings file and its own symlinks. It
  must not mean a third copy of a skill.
- Instruction files are behavioral guidance. Enforce hard limits with Claude Code
  permissions and hooks, GitHub branch protection, and repository rulesets.
