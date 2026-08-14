# Fenced code is not scanned

A link inside a fence is an example, not a pointer, and a heading inside one is
not a heading. Both must be ignored, or documentation that shows Markdown fails
the lint that checks Markdown.

```markdown
[an example of a broken link](anchorfixture-target.md#not-a-real-anchor)

## A heading that is only an example
```

- [and this real one resolves](anchorfixture-target.md#boundary-ownership)
