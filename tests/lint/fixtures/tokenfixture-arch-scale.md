<!-- tokenfixture-arch-scale.md — one type-scale pair perturbed (19 / 21 -> 19 / 22). The leading half of a pair is the half a reader is least likely to check. -->

One size/leading pair disagrees with the source.

#### Type scale

| Role | Selector | Ratio | `10pt` | `11pt` | `12pt` |
|---|---|---:|---:|---:|---:|
| Name | `\CDossierSizeName` | 1.90 | 19 / 22 | 21 / 23 | 23 / 25 |
| Running header, folio | `\CDossierSizeFurniture` | 0.85 | 8 / 10 | 9 / 11 | 10 / 12 |

#### Vertical rhythm

| Token | Ratio | `10pt` | `11pt` | `12pt` |
|---|---:|---:|---:|---:|
| `\CDossierFixtureAboveSkip` | 0.75 | 9.0 pt | 10.2 pt | 10.875 pt |
| `\CDossierFixtureBelowSkip` | 0.375 | 4.5 pt | 5.1 pt | 5.4375 pt |

#### Derived metrics

| Token | Derivation | `10pt` | `11pt` | `12pt` |
|---|---|---:|---:|---:|
| `\CDossierRuleThickness` | 0.04 × body size | 0.4 pt | 0.44 pt | 0.48 pt |
| `\CDossierFurnitureLeading` | leading of `\CDossierSizeFurniture` | 10 pt | 11 pt | 12 pt |

#### After the tables

Prose, so the parser has a heading to stop at.
