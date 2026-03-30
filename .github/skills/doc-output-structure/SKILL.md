# Skill: doc-output-structure

## Purpose

Canonical rules for naming, organizing, and structuring the documentation output tree under `OUTPUT_PATH`.
Load this skill during documentation planning (structure design) and execution (path creation and validation).

---

## Top-Level Layout

```
OUTPUT_PATH/
├── ENTRYPOINT                 ← single entrypoint (default: SUMMARY.md)
├── 01_DomainName/             ← one folder per DOMAIN (NN_ prefix, from DOMAINS[].path)
│   ├── overview.md            ← folder overview (when CREATE_OVERVIEW_FILES=true)
│   ├── 01_TopicName/          ← optional subtopic subfolder
│   │   ├── overview.md
│   │   └── 01_SubtopicDoc.md
│   └── 02_TopicDoc.md
└── 02_DomainName/
    ├── overview.md
    └── 01_TopicDoc.md
```

---

## Naming Convention: `NN_Name`

- `NN` = zero-padded 2-digit integer starting at `01` (e.g., `01`, `02`, `10`)
- Indexing restarts at each folder level
- `Name` = PascalCase or Title_Case label — no spaces, no special characters (hyphens, underscores allowed)
- Apply to both **folders** and **document files**

### Examples

| Source concept | Correct name |
|----------------|--------------|
| Domain "Domain 1" with `path: 1_Domain_1` | `1_Domain_1/` (follow `DOMAINS[].path` from config exactly) |
| Topic "Authentication" | `01_Authentication/` or `01_Authentication.md` |
| Topic "Token refresh flow" | `01_TokenRefreshFlow.md` or `01_Token_Refresh_Flow.md` |
| Folder overview file | `overview.md` (uses `OVERVIEW_FILE_NAME`) |
| Documentation entrypoint | `SUMMARY.md` (uses `ENTRYPOINT`) |

---

## Domain Mapping Rules

1. The first-level children of `OUTPUT_PATH` are **always** domain folders — one per configured domain.
2. Domain folder names come from `DOMAINS[].path` in `.github/prompts.config`. Do not invent or rename them.
3. If `DOMAINS` is absent: infer domain folder names from `SOURCE_PATHS` directory names.
4. Ordering of domains follows their sequence in `DOMAINS` or `SOURCE_PATHS`.

---

## Depth Rules

| Level | What it contains |
|-------|-----------------|
| 1 | Domain folders — one per domain |
| 2 | Topic folders or single-topic documents |
| 3 | Subtopic folders or subtopic documents |
| 4 (max) | Leaf documents only — no sub-folders at level 4 |

- **Never** create folders at level 5 or deeper.
- Prefer flat (level 2) over nested (level 3–4) unless content density clearly justifies depth.
- If a topic contains only **one** document, place the document at the parent level — do not create a single-child folder.

---

## Overview Files

When `CREATE_OVERVIEW_FILES=true` (default `true`):

- Every **domain folder** (level 1) must contain one `OVERVIEW_FILE_NAME` file.
- Every **topic folder** (level 2+) must contain one `OVERVIEW_FILE_NAME` file.
- Overview files must include:
  - A brief description of what the folder covers
  - Links to all direct children (sub-folders and documents)
  - Metadata: `doc_type: overview`, `topics`, `generated_at`
- Overview files must **not** duplicate child content — they link and contextualize, they do not summarize body text.

---

## File Naming Rules

| File type | Name |
|-----------|------|
| Domain overview | Value of `OVERVIEW_FILE_NAME` (default: `overview.md`) |
| Topic overview | Value of `OVERVIEW_FILE_NAME` (default: `overview.md`) |
| Document file | `NN_TopicName.md` |
| Documentation entrypoint | Value of `ENTRYPOINT` (default: `SUMMARY.md`), placed directly under `OUTPUT_PATH` |
| Execution progress | Value of `PROGRESS_FILE`, placed under `temp/` |

Do **not** create additional index or summary files outside these conventions.

---

## Source-to-Output Mapping

Unless the plan explicitly specifies splitting:

- One source transcript → **one** output document (default)
- One source transcript → **multiple** output documents only when:
  - `PREFER_SHORT_DOCS=true` **and**
  - Content exceeds `SPLIT_THRESHOLD_LINES` (default: 1000 lines)
- When splitting, each resulting document retains its own `sources` metadata pointing back to the original transcript.

---

## Path Validity Rules

- All **relative links** between documents must be computed from the current file's own directory.
- **Never** use absolute paths in `related` metadata or in-document links.
- All `sources` values in metadata must be relative to the **workspace root** (e.g., `transcripts/clean/domain/file.md`).
- Every link in the entrypoint must be a valid relative path from `OUTPUT_PATH/`.

---

## Validation Checklist

- [ ] First-level children of `OUTPUT_PATH` are exactly the configured domain folders (no extras, no missing)
- [ ] All folder and file names follow the `NN_Name` convention
- [ ] Depth never exceeds 4 levels
- [ ] No single-child folders (merge into parent level)
- [ ] Every folder at level 1–3 has an `OVERVIEW_FILE_NAME` file (when `CREATE_OVERVIEW_FILES=true`)
- [ ] `ENTRYPOINT` exists at `OUTPUT_PATH/ENTRYPOINT`
- [ ] No absolute paths in any generated file
