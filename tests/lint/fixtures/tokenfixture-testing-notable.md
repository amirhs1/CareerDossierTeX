<!-- tokenfixture-testing-notable.md — the table the rendering check reads is absent.

Drives the third state (docs/TESTING.md, "A guard answers three states, not
two"). The heading is a near-miss of the real one, which is how this failure
actually arrives: a heading renamed in a documentation tidy-up. Reporting "no
mismatches" here would be the check quietly retiring itself. -->

### Spacing tokens: reporting a value

Renamed, so the parser cannot find it.

| Token                       | Rendered by     | At the boundary |
| --------------------------- | --------------- | --------------- |
| `\CDossierFixtureAboveSkip` | `fixture-edges` | block → heading |
| `\CDossierFixtureBelowSkip` | `fixture-edges` | heading → block |
