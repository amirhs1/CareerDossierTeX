# Migration Notes

## Status

No `CareerDossierTeX` release has been published yet, so no public command, key, class option, or default has been renamed or removed.

## Purpose

This file will record migration paths for incompatible public changes once implementation begins, per the stability policy in [`docs/API.md`](API.md).

Before `v1.0.0`, breaking changes are allowed but must be documented here and in [`CHANGELOG.md`](../CHANGELOG.md) in the same pull request that introduces the change.

## Entry format

When a public command, key, or option is renamed, changed, or removed, add an entry using this shape:

```text
## [0.x.0] - YYYY-MM-DD

### `\OldCommand` renamed to `\NewCommand`

Before:

\OldCommand{...}

After:

\NewCommand{...}

Reason: <why the change was necessary>
```

No entries exist yet.
