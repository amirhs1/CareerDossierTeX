<!-- tokenfixture-arch-ratio.md — one ratio perturbed (0.75 -> 0.80). Acceptance criterion: perturbing a ratio fails the lint, by name. -->

One stated ratio no longer matches the declaration.

#### Type scale

| Role | Selector | Ratio | `10pt` | `11pt` | `12pt` |
|---|---|---:|---:|---:|---:|
| Name | `\CDossierSizeName` | 1.90 | 19 / 21 | 21 / 23 | 23 / 25 |
| Running header, folio | `\CDossierSizeFurniture` | 0.85 | 8 / 10 | 9 / 11 | 10 / 12 |

#### Vertical rhythm

| Token | Ratio | `10pt` | `11pt` | `12pt` |
|---|---:|---:|---:|---:|
| `\CDossierFixtureAboveSkip` | 0.80 | 9.0 pt | 10.2 pt | 10.875 pt |
| `\CDossierFixtureBelowSkip` | 0.375 | 4.5 pt | 5.1 pt | 5.4375 pt |

#### Dimensions outside the vertical rhythm

| Token | Derivation | `10pt` | `11pt` | `12pt` |
|---|---|---:|---:|---:|
| `\CDossierRuleThickness` | 0.04 × body size | 0.4 pt | 0.44 pt | 0.48 pt |
| `\CDossierFurnitureLeading` | leading of `\CDossierSizeFurniture` | 10 pt | 11 pt | 12 pt |

#### After the tables

Prose, so the parser has a heading to stop at.
