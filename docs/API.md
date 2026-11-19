# CareerDossierTeX Public API

The public interface — every class, option, key, command, environment, and
design token, with its accepted values and default — is documented in the PDF
manual, [`doc/careerdossier.tex`](../doc/careerdossier.tex).

## Where the manual is

CTAN requires PDF documentation together with its source, so the manual is the
authored reference and this file is a pointer to it. Build it from a checkout:

```bash
make manual        # -> build/manual/careerdossier.pdf
```

The built PDF is a build artifact and is not tracked (rule 8, "Source-only
Git"); a release ships it in the CTAN archive, and the GitHub Release attaches
it. `doc/careerdossier.tex` is the source, and it is committed.

## Why one document rather than two

This file held a second, Markdown description of the same interface until
`v0.9.0`. Two documents describing one interface is the duplication
[#259](https://github.com/amirhs1/CareerDossierTeX/issues/259) exists to stop,
and it had already cost this project once:
[#185](https://github.com/amirhs1/CareerDossierTeX/issues/185) found ten
sentences left stale across three documents after the `v0.7.0` retune, one of
which documented a recipe that restored half the spacing it claimed to remove.
A PDF manual as the reference is also the ordinary shape for a LaTeX package.

What that costs a reader of this repository on the web: there is no inline,
browsable interface reference here any more. `README.md` links the released PDF,
and the command above builds it.

Two assertions keep the manual honest, and neither is a claim in prose.
`tests/lint/run-manual-names.sh`, which `make lint` runs, fails the build if the
manual documents a private LaTeX3 name, if it documents a public name that
appears in no file of the Work, or if the release it declares disagrees with the
one the Work declares. `docs/TESTING.md`, "Manual-name lint", states what
it does and does not check.

## What is still here

The stability policy below, because it is repository governance rather than
interface reference: it binds a contributor changing the interface, not an
author using it. Everything else moved into the manual.

## Stability policy

What a released public name commits the project to, and which release may
carry which change. The rules govern the interface `v1.0.0` freezes
([`ROADMAP.md`](ROADMAP.md#definition-of-100)). Only the deprecation cycle
waits for the freeze: `v1.0.0` may still rename, split, retire, or make private
a public name at once, which
[#710](https://github.com/amirhs1/CareerDossierTeX/issues/710) audits for, and
every release after it needs the cycle. The rules describe four earlier
changes, listed under [Where the rules come from](#where-the-rules-come-from),
and say where they depart from them.

### What is public

Every name that begins with `CDossier` or `MakeCDossier` is public, whether or
not the manual documents it, an example uses it, or a test covers it. That is
the rule [#242](https://github.com/amirhs1/CareerDossierTeX/issues/242)
settled: three public-prefixed names that nobody had meant to publish were
public all the same, so making them private took a `docs/MIGRATION.md` entry,
like any other removal.

A name spelled `\__cdossier_<module>_…` is private and carries no promise: any
release may rename or remove it, with no deprecation cycle and no
`docs/MIGRATION.md` entry. That holds although the Work's own files call one
another's private names; the coupling is internal to the Work, not an
interface. A private rename owes users nothing, but it is not free of risk.
Outside `\ExplSyntaxOn` a private name splits into `\_` and ordinary text and
never runs, with no error
([PR #250](https://github.com/amirhs1/CareerDossierTeX/pull/250)), so a call
site the rename missed fails silently. Regression coverage, not a deprecation
cycle, is what protects those call sites.

### Which release may carry which change

A version number has the major, minor, and patch parts of
[Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html), and the table
says what each may carry here. Each row names the lowest release that may carry
a change; a higher one may carry it too.

| Change | Lowest release | In `docs/MIGRATION.md` |
| --- | --- | --- |
| Remove or rename a public name | major, after the [deprecation cycle](#the-deprecation-cycle) | an entry |
| Deprecate a public name | minor | an entry |
| Add a public name | minor | nothing |
| Change a default on purpose, such as a token value or a layout | minor | a line under "Status" |
| Stop with an error on input that was accepted and ignored | minor | an entry |
| Bring output back to the documented behaviour | patch | a line under "Status" |
| Rename or remove a private name | patch | nothing |

A change to output with no name changing is not a deprecation: nothing warns,
and nothing is removed. Its notice is the release's line under
[`MIGRATION.md`, "Status"](MIGRATION.md#status), which says whether a document
needs a source edit and whether it reflows. `v0.6.0` and `v0.7.0` each reflowed
every document and said so there.

Input that was accepted and ignored and now stops with an error counts as a
fix, not a removal, so it needs no deprecation cycle; it still ships in a minor
release, never a patch.
[#690](https://github.com/amirhs1/CareerDossierTeX/issues/690) is the first
case.

### The deprecation cycle

A public name is removed or renamed only in a major release. Before that, the
old name keeps working for at least one minor release, and emits a LaTeX
warning that names its replacement. A name deprecated in `v1.4.0` therefore
works, and warns, in every `v1.x` release from then on, and `v2.0.0` is the
earliest release that may remove it. Splitting, retiring, or making private a
public name removes the old name, so it takes the same cycle.

### What a `docs/MIGRATION.md` entry adds

[`CONTRIBUTING.md`, "Update `MIGRATION.md` when:"](../CONTRIBUTING.md#update-migrationmd-when)
gives the shape of an entry. The policy adds two requirements:

- A deprecation entry names the old name, the new name, the release that
  deprecated it, the release that removes it, and the edit a document needs.
- A recipe that restores earlier output quotes a literal value, never a token
  the same release moves. `v0.7.0`'s recipe for keeping the earlier header
  spacing first read `\CDossierProseParSkip`, which the same release halved, so
  it restored half the spacing it claimed to
  ([#185](https://github.com/amirhs1/CareerDossierTeX/issues/185), recorded in
  [#259](https://github.com/amirhs1/CareerDossierTeX/issues/259)); the
  recipe now writes the value out, `7.25pt` at `fontsize=12pt`.

### Where a change is recorded

- `docs/MIGRATION.md`, in the pull request that makes the change, as the table
  above requires.
- `doc/careerdossier.tex`, in the same pull request, for any change to the
  public interface.
- `CHANGELOG.md` records every user-visible change, but no pull request writes
  it: the `draft-release` skill writes each release's section when the release
  is drafted
  ([`CONTRIBUTING.md`, "Update `CHANGELOG.md` when:"](../CONTRIBUTING.md#update-changelogmd-when)).

### Where the rules come from

Four changes before `v1.0.0` set the practice these rules describe. Each was
recorded in `docs/MIGRATION.md`, and none had a policy to follow.

- `v0.6.0` removed `density=compact|standard` from the resume and the CV, so
  passing it stops with an unknown-option error
  ([#141](https://github.com/amirhs1/CareerDossierTeX/issues/141),
  [#142](https://github.com/amirhs1/CareerDossierTeX/issues/142)), and changed
  every class's type sizes, spacing, and default size or margin, so every
  document reflowed. Its migration notes kept the two apart: a source edit only
  where a document passes `density`, a reflow in every document.
- `v0.7.0` renamed seventeen of the twenty-two vertical-spacing tokens onto one
  grammar, `\CDossier<Family><Scope><Position>Skip`
  ([#203](https://github.com/amirhs1/CareerDossierTeX/issues/203)), with a
  table from each old name to its new one and no value changed. The same
  release retuned seventeen ratios, recorded in an entry of its own with a
  table of old and new values.
- [PR #237](https://github.com/amirhs1/CareerDossierTeX/pull/237), in
  `v0.7.0`, retired `\CDossierSharedHeaderAboveSkip`, a token that could not
  change output at any value. Setting it became an undefined-control-sequence
  error, and its entry says to delete the setting.
- [#242](https://github.com/amirhs1/CareerDossierTeX/issues/242), in
  [PR #250](https://github.com/amirhs1/CareerDossierTeX/pull/250), made three
  public-prefixed names private, each with a migration entry. It is where the
  rule under [What is public](#what-is-public) comes from, and PR #250 found
  the `\ExplSyntaxOn` trap described there.

What the rules keep from them: a migration entry for every change to a public
name, the edit shown before and after, and a notice of reflow kept apart from
the notice of a source edit. Where the rules depart: each of the four removed
the old name or option in the release that changed it, with no warning, which
this section allowed before `v1.0.0`. After `v1.0.0` the same change keeps the
old name working, with a warning, for at least one minor release, and removes
it only in a major release, because from then on public commands, keys,
options, and documented behaviour are to be treated as stable
([`ROADMAP.md`](ROADMAP.md#definition-of-100)).
