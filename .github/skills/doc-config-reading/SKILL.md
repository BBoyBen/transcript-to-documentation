# Skill: doc-config-reading

## Purpose

Canonical rules for reading, normalizing, and applying `.github/prompts.config` in any agent or prompt.
Load this skill at the start of any task that depends on repository configuration.

## How to Use This Skill

1. Read `.github/prompts.config` using the `read` tool.
2. Apply the key definitions, defaults, and normalization rules below.
3. Record all resolved values before proceeding with your task.

---

## Complete Key Reference

### Project Keys

| Key | Type | Required | Default | Description |
|-----|------|----------|---------|-------------|
| `PROJECT_NAME` | string | yes | `My Documentation` | Project name, used in titles and entrypoint |
| `PROJECT_DESCRIPTION` | string | no | — | Project description, used in entrypoint overview |
| `AGENT_NAME` | string | no | `doc-plan-executor` | Active agent name (informational) |
| `AGENT_DESCRIPTION` | string | no | — | Active agent description (informational) |

### Source Keys

| Key | Type | Required | Default | Description |
|-----|------|----------|---------|-------------|
| `SOURCE_PATHS` | string[] | **yes** | — | Directories containing cleaned transcript `.md` files |
| `SOURCE_FORMAT` | string | no | `markdown with metadata headers` | Source file format description |
| `SOURCE_DESCRIPTION` | string | no | — | Free-text description of source content |

### Output Keys

| Key | Type | Required | Default | Description |
|-----|------|----------|---------|-------------|
| `OUTPUT_PATH` | string | yes | `/docs` | Root output directory for generated documentation |
| `OUTPUT_FORMAT` | string | no | `markdown` | Output file format |
| `ENTRYPOINT` | string | no | `SUMMARY.md` | Single entrypoint file directly under `OUTPUT_PATH` |

### Documentation Convention Keys

| Key | Type | Required | Default | Description |
|-----|------|----------|---------|-------------|
| `METADATA_FORMAT` | enum | no | `both` | `yaml-frontmatter` \| `bold-lines` \| `both` |
| `CREATE_OVERVIEW_FILES` | boolean | no | `true` | Create `OVERVIEW_FILE_NAME` for each folder node |
| `OVERVIEW_FILE_NAME` | string | no | `overview.md` | Filename for folder-level overview documents |
| `PREFER_SHORT_DOCS` | boolean | no | `true` | Allow splitting long documents when plan specifies it |
| `SPLIT_THRESHOLD_LINES` | integer | no | `1000` | Line count above which a document may be split |
| `MODULE_README_NAME` | string | no | `README.md` | Name for module-level readme files (rarely used) |

### Domain Keys

| Key | Type | Required | Default | Description |
|-----|------|----------|---------|-------------|
| `DOMAINS` | object[] | no | — | List of domain definitions. Each object: `name` (string), `path` (string), `description` (string, optional) |

### Language & Style Keys

| Key | Type | Required | Default | Description |
|-----|------|----------|---------|-------------|
| `LANGUAGE` | string | no | `English` | Content language applied to all generated documentation |
| `TONE` | string | no | `Professional` | Writing tone for generated documentation |
| `AUDIENCE` | string | no | `Technical teams and AI agents` | Target audience, used to calibrate content depth |

### Processing Keys

| Key | Type | Required | Default | Description |
|-----|------|----------|---------|-------------|
| `BATCH_SIZE` | string or integer | no | `3` | Number of files per processing batch |
| `PROGRESS_FILE` | string | no | `/temp/doc-plan-executor-progress.md` | Path to the execution progress tracking file |
| `AUTO_BATCH` | boolean | no | `true` | Automatically group files into batches |

### Quality Keys

| Key | Type | Required | Default | Description |
|-----|------|----------|---------|-------------|
| `SPECIAL_REQUIREMENTS` | string[] | no | — | Hard constraints on every generated page (non-negotiable) |
| `ADDITIONAL_FEATURES` | string[] | no | — | Best-effort capabilities to activate during generation |

### Execution Keys

| Key | Type | Required | Default | Description |
|-----|------|----------|---------|-------------|
| `EXECUTION_MODE` | string | no | `sequential_batches` | Execution mode |
| `VALIDATION_ENABLED` | boolean | no | `true` | Run validation phase at the end |
| `AUTO_CROSS_REFERENCE` | boolean | no | `true` | Automatically resolve cross-references after batch processing |
| `GENERATE_SUMMARY` | boolean | no | `true` | Generate entrypoint and summary in final phase |
| `TOOLS` | string[] | no | `[read, edit, search]` | Tools available (informational) |
| `TARGET` | string | no | `vscode` | Target environment |

---

## Normalization Rules

### `BATCH_SIZE`

- Integer (e.g., `3`): use as-is.
- Range (e.g., `2-4`): resolve to `floor((lower + upper) / 2)` — e.g., `2-4` → `3`.
- Unparseable value: fall back to `3` and log the assumption.
- Record the resolved value as `config.effective_batch_size` in `temp/plan.json`.

### `METADATA_FORMAT`

- Accepted values: `yaml-frontmatter`, `bold-lines`, `both`.
- Default: `both`.
- Invalid value: log a warning and apply default `both`.

### `CREATE_OVERVIEW_FILES` / `VALIDATION_ENABLED` / `AUTO_BATCH` / `PREFER_SHORT_DOCS` / `AUTO_CROSS_REFERENCE` / `GENERATE_SUMMARY`

- Accepted truthy: `true`, `yes`, `1`.
- Accepted falsy: `false`, `no`, `0`.
- Default when absent: `true` (all of the above default to enabled).

### Missing Required Keys

| Key | Category | Behaviour when missing |
|-----|----------|----------------------|
| `SOURCE_PATHS` | **Blocking** | Stop immediately and ask the user to supply it |
| `OUTPUT_PATH` | Warning | Use default `/docs`; document the assumption |
| `PROJECT_NAME` | Warning | Use default `My Documentation`; document the assumption |
| `ENTRYPOINT` | Silent | Use default `SUMMARY.md` |

### `SPECIAL_REQUIREMENTS` vs `ADDITIONAL_FEATURES`

- `SPECIAL_REQUIREMENTS`: every item is a **non-negotiable hard constraint**. Every generated page must satisfy each item. Propagate into `config.constraints` in `temp/plan.json`.
- `ADDITIONAL_FEATURES`: every item is a **best-effort capability**. Activate at the relevant phase. If an item cannot be fully satisfied, document it in the execution report rather than failing.

---

## Source-of-Truth Priority

When both `temp/plan.json` (key `config`) and `.github/prompts.config` exist:

1. Actual repository state (files on disk, readable paths)
2. `.github/prompts.config`
3. `temp/plan.json` `config` block
4. `temp/plan.md` (narrative reference only)

Minor discrepancies → continue and record in execution report.
Structural discrepancies → stop and request user input.
