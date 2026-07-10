# Agent-instruction file set

This directory documents how coding agents (OpenAI Codex and Anthropic Claude
Code) are configured for `CareerDossierTeX`.

## Principle

Shared repository policy lives in neutral files. Tool-specific directories
contain only adapters, path-scoped rules, or task skills. Nothing is duplicated.

## Layout

```text
CareerDossierTeX/
├── AGENTS.md                                 # shared operating contract (both agents)
├── CLAUDE.md                                 # Claude Code adapter: @AGENTS.md + Claude-only notes
├── docs/agent-workflows/
│   ├── README.md                             # this map
│   └── github-project.md                     # draft-PR + Project metadata workflow (+ gh commands)
├── .agents/skills/open-draft-pr/SKILL.md     # Codex draft-PR skill
└── .claude/
    ├── rules/latex.md                        # Claude path-scoped LaTeX rules (*.tex/*.sty/*.cls)
    └── skills/open-draft-pr/SKILL.md         # Claude draft-PR skill
```

## Files

- **`AGENTS.md`** — the canonical contract: purpose, sources of truth, scope and
  verification rules, module ownership, API/LaTeX conventions, build/test
  expectations, design and accessibility baselines, the Git and draft-PR
  authority model, high-risk approval gates, CI/CD, licensing, and completion
  reporting. Codex reads it directly; Claude Code reads it through `CLAUDE.md`.
- **`CLAUDE.md`** — a small Claude adapter. It imports `AGENTS.md` with
  `@AGENTS.md` (Claude Code reads `CLAUDE.md`, not `AGENTS.md`) and adds only
  Claude-specific guidance for `CLAUDE.local.md`, `.claude/rules/`,
  `.claude/skills/`, permissions/enforcement, attribution, and the draft-PR skill.
- **`docs/agent-workflows/github-project.md`** — neutral, human-readable workflow
  shared by both agents: authority boundary, PR-body sections, labels, milestone,
  Project membership, Status/Phase/Priority/Size rules, status transitions,
  approval boundaries, verification, and a `gh` command appendix.
- **`.agents/skills/open-draft-pr/SKILL.md`** — Codex task adapter for opening or
  updating a draft PR. Codex scans `.agents/skills/` from the working directory
  up to the repository root.
- **`.claude/skills/open-draft-pr/SKILL.md`** — the Claude equivalent, kept nearly
  identical to the Codex skill.
- **`.claude/rules/latex.md`** — a Claude path-scoped rule. It loads only for
  LaTeX paths via `paths:` frontmatter and holds the detailed XeLaTeX, module
  ownership, optional-field, log-inspection, and accessibility-claim rules. Codex
  has no equivalent `paths`-glob rules directory, so the concise LaTeX invariants
  also live in `AGENTS.md`.

## Maintenance

- Shared policy belongs in `AGENTS.md`, `CONTRIBUTING.md`, or `docs/`.
- Codex-specific task loading belongs in `.agents/skills/`.
- Claude-specific task loading belongs in `.claude/skills/`; Claude path-scoped
  rules belong in `.claude/rules/`.
- Instruction files are behavioral guidance. Enforce hard limits with Claude Code
  permissions and hooks, GitHub branch protection, and repository rulesets.
