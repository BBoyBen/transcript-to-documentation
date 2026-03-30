# Skill: doc-metadata-format

## Purpose

Canonical schema and rendering rules for metadata in all `.md` files produced by the documentation pipeline.
Load this skill when generating, validating, or reading metadata from cleaned transcripts or generated documentation.

---

## Metadata Fields

### Required Fields (every generated page and every cleaned transcript)

| Field | YAML key | Bold-line key | Type | Notes |
|-------|----------|---------------|------|-------|
| Topics | `topics` | `**Topics**` | string[] | 3–7 items, alphabetical order |
| Source | `sources` | `**Source**` | string[] | Relative path(s) to original `.transcript` file(s), from workspace root |
| Generated at | `generated_at` | `**Generated at**` | ISO 8601 string | Creation or last-update timestamp |
| Doc type | `doc_type` | `**Doc type**` | enum | See valid values below |

### Optional Fields

| Field | YAML key | Bold-line key | Type | Notes |
|-------|----------|---------------|------|-------|
| Related | `related` | `**Related**` | string[] | Relative paths to related documents within `OUTPUT_PATH` |
| Title | `title` | — | string | Overrides the H1 heading when present |

### `doc_type` Valid Values

| Value | When to use |
|-------|-------------|
| `concept` | Explains what something is (architecture, data model, principle) |
| `guide` | Step-by-step instructions or how-to |
| `process` | Describes a workflow, process, or procedure |
| `reference` | Reference tables, key lists, parameter docs |
| `overview` | Folder-level overview; summarizes and links to sub-documents |
| `transcript` | Direct output from `clean-transcript` (cleaned but not restructured) |

---

## Rendering Rules by `METADATA_FORMAT`

Read `METADATA_FORMAT` from `.github/prompts.config` (default: `both`).

### `yaml-frontmatter`

Place a YAML block at the very top of the file, before any heading:

```yaml
---
title: "Document Title"
topics:
  - Topic A
  - Topic B
related:
  - ../path/to/related-doc.md
sources:
  - transcripts/clean/domain/source.md
generated_at: "2026-03-30T10:00:00Z"
doc_type: concept
---
```

### `bold-lines`

Place bold metadata lines immediately after the H1 heading:

```markdown
# Document Title

**Topics**: Topic A, Topic B
**Related**: ../path/to/related-doc.md
**Source**: transcripts/clean/domain/source.md
**Generated at**: 2026-03-30T10:00:00Z
**Doc type**: concept
```

### `both` (default)

Include **both** YAML frontmatter and bold lines. This is the standard mode for this repository — it ensures compatibility with both AI metadata parsing and human readability.

The YAML block comes first, then the H1 heading, then the bold lines:

```yaml
---
title: "Document Title"
topics:
  - Topic A
  - Topic B
related:
  - ../path/to/related-doc.md
sources:
  - transcripts/clean/domain/source.md
generated_at: "2026-03-30T10:00:00Z"
doc_type: concept
---
```

```markdown
# Document Title

**Topics**: Topic A, Topic B
**Related**: ../path/to/related-doc.md
**Source**: transcripts/clean/domain/source.md
**Generated at**: 2026-03-30T10:00:00Z
**Doc type**: concept
```

> When using `both`, YAML frontmatter and bold lines must always be consistent — they represent the same data in two formats.

---

## Validation Checklist

For each generated or cleaned file:

- [ ] `topics` / `**Topics**` — present, non-empty, 3–7 items, alphabetical order
- [ ] `sources` / `**Source**` — present; paths point to existing files in `SOURCE_PATHS` or `transcripts/`
- [ ] `generated_at` — present, valid ISO 8601 format
- [ ] `doc_type` — present, value is one of the six allowed types listed above
- [ ] `related` / `**Related**` — if present, all paths are valid relative links within `OUTPUT_PATH`
- [ ] When `METADATA_FORMAT: both` — YAML and bold lines are consistent with each other
- [ ] **No blog-platform fields**: `post_title`, `author1`, `microsoft_alias`, `featured_image`, `categories`, `tags`, `ai_note`, `post_slug` must never appear in pipeline-generated files

---

## Common Mistakes

| Mistake | Correct form |
|---------|-------------|
| `topics: "Topic A, Topic B"` (string in YAML) | `topics:` as an array with `- Topic A` / `- Topic B` |
| Absolute path in `related` or `sources` | Relative path from the current file's directory or workspace root |
| `doc_type: documentation` | Must be one of the six valid values (`concept`, `guide`, etc.) |
| Missing `generated_at` | Always required; use ISO 8601 (e.g., `2026-03-30T10:00:00Z`) |
| YAML and bold lines showing different topics | Keep them identical — same items, same order |
| `related` pointing to a file outside `OUTPUT_PATH` | Only link within the documentation output tree |
