<!-- tokenfixture-testing-ok.md — the rendering table names exactly the tokens the source allocates. -->

### Spacing tokens: reporting a value is not rendering a gap

Each public spacing token must be rendered by at least one committed fixture,
and the table below records which.

| Token                       | Rendered by     | At the boundary |
| --------------------------- | --------------- | --------------- |
| `\CDossierFixtureAboveSkip` | `fixture-edges` | block → heading |
| `\CDossierFixtureBelowSkip` | `fixture-edges` | heading → block |

### After the table

Prose, so the parser has a heading to stop at.
