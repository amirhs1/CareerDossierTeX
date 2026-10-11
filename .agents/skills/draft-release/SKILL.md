---
name: draft-release
description: Draft a GitHub release and its CHANGELOG.md section; never publish it. Use only when the person running you asks for a release.
disable-model-invocation: true
---

# Draft a release

1. Check the branch, the working tree, and `HEAD`: on `main`, clean, and
   level with `origin/main`. Confirm the rest of CONTRIBUTING.md,
   "Release contributions", is done.
2. Tag and release title: both `v<MAJOR>.<MINOR>.<PATCH>`, as
   CONTRIBUTING.md, "Names", sets them. The person running you chooses the
   version.
3. List the changes since the last tag:
   `git log --no-merges --format='%h %s' <last tag>..HEAD`.
4. Write the changes in Common Changelog form: `### Changed`, `### Added`,
   `### Removed`, `### Fixed`, in that order, each only when it has a change;
   one imperative line per change, citing its commit, and its pull request
   when there is one; no Unreleased section.
   - Keep only what a user of the classes and packages would notice: rendered
     output, a public name, or documented behaviour. Agent instructions, CI,
     tests, and maintainer-only scripts get no line.
   - Open a breaking change with `**Breaking:**`. When `docs/MIGRATION.md`
     gains an entry, put the line
     `_If you are upgrading: please see [docs/MIGRATION.md](docs/MIGRATION.md)._`
     under the version heading.
5. `CHANGELOG.md`: add them at the top under a version heading whose version
   links to the release,
   `## [<MAJOR>.<MINOR>.<PATCH>](<release URL>) - <YYYY-MM-DD>`, with no
   trailer; its commit carries one. If the file still has a `## [Unreleased]`
   section, the new section replaces it, since the commits cover its entries,
   and the opening paragraph names Common Changelog instead of Keep a
   Changelog; earlier sections stay as written. Do this on a new branch
   (`create-branch`), and open a pull request.
6. Before that pull request, check what this package's users need stated:
   - every `\ProvidesExplPackage` and `\ProvidesExplClass` line carries the
     release date and version; `make lint` checks only that the ten agree with
     each other;
   - every added, renamed, or removed public command, environment, class
     option, or key has its line, and a rename has its `docs/MIGRATION.md`
     entry;
   - every output-affecting change (spacing, fonts, page layout, folio or
     running-header text, links, PDF metadata, or tagging defaults) has its
     line, even when compilation still succeeds;
   - a new minimum dependency version or newly required package is stated;
   - no line claims ATS, WCAG, or PDF/UA conformance or broad accessibility,
     and a preview feature does not read as a general capability
     (AGENTS.md, "Settled decisions").
7. Release notes: the same categories without the heading, then your trailer
   block (AGENTS.md, "Provenance"). Create the draft, and never publish it:
   `gh release create v<version> --draft --title v<version> --notes-file <file>`.
8. To revise the draft: `gh release edit v<version> --notes-file <file>`.
