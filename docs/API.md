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
one the Work declares. `docs/TESTING.md` section "Manual-name lint" states what
it does and does not check.

## What is still here

The stability policy below, because it is repository governance rather than
interface reference: it binds a contributor changing the interface, not an
author using it. Everything else moved into the manual.

## Stability policy

Before `v0.10.0`:

- breaking changes are allowed;
- public changes must be documented in [`../CHANGELOG.md`](../CHANGELOG.md);
- renamed commands or keys should be recorded in [`MIGRATION.md`](MIGRATION.md);
- public API changes must update `doc/careerdossier.tex` in the same pull
  request.

After `v0.10.0`, incompatible changes should require a major-version release or a
documented deprecation path.

Calibrated token *values* are not stable API before `v0.10.0`; the token names
and the boundaries they own are.

A command or environment becomes public only when it is intentionally named and
documented in the manual, used by a supported example, covered by a repeatable
test, and recorded in [`../CHANGELOG.md`](../CHANGELOG.md) when it is
introduced. Anything else is internal, and may change without a migration note.
