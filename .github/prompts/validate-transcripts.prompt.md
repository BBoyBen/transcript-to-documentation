---
description: 'Validates cleaned transcript files before documentation planning — checks structure, metadata, and content completeness'
agent: 'ask'
---

# Transcript Validation (Phase 3 Gate)

Validate all cleaned transcript files in `SOURCE_PATHS` before triggering the documentation pipeline. This is the automated gate between Phase 2 (Cleaning) and Phase 4 (Plan Generation).

## Mission

Scan every `.md` file in each `SOURCE_PATHS` directory and produce a **validation report** indicating which files are ready, which need revision, and what specific issues block them.

## Scope & Preconditions

- **Required Input**: Configuration in `.github/prompts.config` (keys: `SOURCE_PATHS`, `LANGUAGE`)
- **Expected Output**: Console report — no files are written unless explicitly confirmed
- **Halt condition**: Stop and report if `SOURCE_PATHS` is missing or no `.md` files are found

## Workflow

### Step 1 — Load Configuration

Read `.github/prompts.config` and extract:
- `SOURCE_PATHS` (required — list of directories to validate)
- `LANGUAGE` (optional — used to flag language mismatches)

### Step 2 — Discover Files

For each path in `SOURCE_PATHS`:
- List all `.md` files recursively
- Skip non-`.md` files silently
- Report if a `SOURCE_PATHS` directory does not exist

### Step 3 — Validate Each File

For each `.md` file, apply the following checks:

#### 3a. Frontmatter Checks
- [ ] YAML frontmatter block is present (`---` delimiters)
- [ ] `Topics` field is present and non-empty (array of strings)
- [ ] `Source` field is present and references an existing `.transcript` file in `/transcripts/raw/`
- [ ] No blog-platform fields present (`post_title`, `author1`, `microsoft_alias`, `featured_image`, `categories`)

#### 3b. Structure Checks
- [ ] At least one `##` heading exists (H2 minimum)
- [ ] No heading levels are skipped (e.g., H4 without H3)
- [ ] At least 100 words of body content (excluding frontmatter and headings)
- [ ] No raw transcript artifacts: speaker labels (`Speaker 1:`, `[inaudible]`, `00:00`), filler words in bulk, or uncorrected OCR patterns

#### 3c. Content Checks
- [ ] Content language matches `LANGUAGE` config value (surface obvious mismatches)
- [ ] No empty sections (heading immediately followed by another heading)
- [ ] No placeholder text (`TODO`, `FIXME`, `[...]`, `???`)

### Step 4 — Produce Report

Output a structured report grouped by status:

```
## Validation Report — /transcripts/clean/

### ✅ Ready (N files)
- domain/file.md — all checks passed

### ⚠️ Needs Revision (N files)
- domain/file.md
  - Missing `Topics` frontmatter field
  - Empty section: "## Context"

### ❌ Blocked (N files)
- domain/file.md
  - No frontmatter block
  - Contains raw transcript artifacts (speaker labels found)

---
Summary: N/N files ready. Run @doc-planner only when all files are ✅ or ⚠️ (minor issues).
```

**Severity rules**:
- `❌ Blocked` — missing frontmatter, transcript artifacts, or file is unreadable
- `⚠️ Needs Revision` — structural gaps, empty sections, placeholders
- `✅ Ready` — all checks pass or only cosmetic issues

### Step 5 — Recommend Next Action

After the report, state one of:
- **"All files ready — run `@doc-planner` to generate the execution plan."**
- **"N file(s) require revision before planning. Re-run `@clean-transcript` on the affected files or fix manually."**
- **"N file(s) are blocked and cannot be planned until resolved."**

## Quality Assurance

- Do not modify any files — this prompt is read-only
- Do not invoke `@doc-planner` automatically — this is a gate check only
- If `SOURCE_PATHS` contains nested subdirectories, validate all `.md` files recursively
- Surface structural issues clearly enough that the user can act without re-reading the file
