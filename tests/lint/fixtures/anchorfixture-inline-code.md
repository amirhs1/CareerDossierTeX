# Inline code is not a link

Documenting the lint means writing its own syntax in prose. A span such as
`](anchorfixture-target.md#not-a-real-anchor)` is an example, and so is a bare
`](#not-a-real-anchor)`. Neither is a pointer, and neither may fail the lint.

Link text may itself contain a span, and that link must still be checked:

- [`anchorfixture-target.md`](anchorfixture-target.md#boundary-ownership)
