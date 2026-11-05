<!-- tokenfixture-testing-extra.md — a row names a token the source does not allocate, as a row left behind by a renamed or retired token would. -->

### Spacing tokens: reporting a value is not rendering a gap

A row for a token the source no longer has.

| Token                         | Rendered by     | At the boundary   |
| ----------------------------- | --------------- | ----------------- |
| `\CDossierFixtureAboveSkip`   | `fixture-edges` | block → heading   |
| `\CDossierFixtureBelowSkip`   | `fixture-edges` | heading → block   |
| `\CDossierFixtureRetiredSkip` | `fixture-edges` | retired → nowhere |

### After the table

Prose, so the parser has a heading to stop at.
