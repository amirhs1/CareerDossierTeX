<!-- tokenfixture-testing-dropped.md — a token the source allocates has no row. This is the defect issue #590 found: two tokens added with no row, and nothing that noticed. -->

### Spacing tokens: reporting a value is not rendering a gap

A token added to the source without the row the rule asks for.

| Token                       | Rendered by     | At the boundary |
| --------------------------- | --------------- | --------------- |
| `\CDossierFixtureAboveSkip` | `fixture-edges` | block → heading |

### After the table

Prose, so the parser has a heading to stop at.
