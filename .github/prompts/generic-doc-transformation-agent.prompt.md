---
description: 'Template for creating documentation transformation agents'
usage: 'Customize the variables and use this prompt to create agent files for different projects'
---

# Documentation Transformation Agent Generator

Generate custom agents that transform source content into structured, organized documentation.

## Configuration Parameters

Read from `.github/prompts.config`:

### Required Parameters

**Project Configuration**
- `PROJECT_NAME`: Project identifier and title
- `AGENT_NAME`: Agent file name (lowercase-with-hyphens)
- `AGENT_DESCRIPTION`: Purpose and goals of the agent

**Source Configuration**
- `SOURCE_PATHS`: List of source directories (can be multiple)
- `SOURCE_FORMAT`: File format (markdown, JSON, plain text, etc.)
- `SOURCE_DESCRIPTION`: What source files contain

**Output Configuration**
- `OUTPUT_PATH`: Destination directory for generated docs
- `OUTPUT_FORMAT`: Output file format

**Language & Style**
- `LANGUAGE`: Documentation language (Français, English, etc.)
- `TONE`: Writing style (Professional, casual, technical, etc.)
- `AUDIENCE`: Target readers (Technical teams, general public, etc.)

### Optional Parameters

- `DOMAINS`: List of content domains with metadata (auto-detected if omitted)
- `BATCH_SIZE`: Files per batch (default: 2-4)
- `PROGRESS_FILE`: Progress tracking location
- `AUTO_BATCH`: Enable automatic batch detection
- `SPECIAL_REQUIREMENTS`: List of special constraints or requirements
- `ADDITIONAL_FEATURES`: Extra features to include
- `EXECUTION_MODE`: sequential_batches, parallel, etc.
- `VALIDATION_ENABLED`: true/false
- `AUTO_CROSS_REFERENCE`: true/false
- `GENERATE_SUMMARY`: true/false

## Agent Generation Process

1. Load `.github/prompts.config` and validate all required fields
2. Scan source directories from `SOURCE_PATHS` to analyze files
3. Calculate optimal batch strategy based on `BATCH_SIZE` and file analysis
4. Generate YAML frontmatter from config parameters
5. Build agent instructions using `LANGUAGE`, `TONE`, and `AUDIENCE` settings
6. Create complete `.agent.md` file at `.github/agents/[AGENT_NAME].agent.md`

## Generated Agent Template

```yaml
---
description: '[Agent Description from parameters]'
name: '[Agent Name from parameters]'
tools: ['read', 'edit', 'search']
target: vscode
infer: false
---

# [Agent Name] Agent

## Purpose

Transform source files from [Source Path] into structured [Output Format] documentation in [Output Path].

## Language Requirements

All generated documentation MUST be in [Language from LANGUAGE parameter]. This includes:
- Document titles and headings
- Body text and descriptions  
- Metadata and annotations
- File names and directory names
- Summary and index content

## Source Material

- **Location**: [Source Path from parameters]
- **Format**: [Source Format from parameters]
- **Content**: [Source Description from parameters]
- **Volume**: [Auto-detected file count and total size]

## Output Structure

- **Destination**: [Output Path from parameters]
- **Format**: [Output Format from parameters]
- **Organization**: Hierarchical with 2-4 nesting levels maximum
- **Folder Structure**: Create sub-folders as needed for optimal documentation hierarchy
- **Index**: `summary.md` at root

## Domain Organization

[If DOMAINS provided in config, list them. Otherwise: "Auto-detect domains from source files"]

## Batch Processing Strategy

Source files may be long. Process in batches to avoid context window overflow.

### Batch Configuration

- **Batch Size**: 2-4 files per batch (from BATCH_SIZE parameter)
- **Total Batches**: [Auto-calculated based on file count]
- **Progress Tracking**: [From PROGRESS_FILE parameter]

### Batch Processing Workflow

**Step 0: Initialize**
1. Scan [Source Path] and list all source files
2. Analyze file sizes and natural groupings
3. Create batch plan based on BATCH_SIZE
4. Create progress tracking file
5. Create base [Output Path] directory structure

**Step 1-N: Process Each Batch**
For each batch:
1. Read batch source files
2. Analyze and structure content
3. Create organized documentation files
4. Use TBD placeholders for cross-batch references
5. Update progress tracking

**Step N+1: Cross-Reference Resolution**
1. Review all generated documentation
2. Replace all `[TBD: ...]` placeholders with actual cross-references
3. Ensure all internal links are valid

**Step N+2: Generate Summary**
1. Create `summary.md` at [Output Path] root
2. Include hierarchical index of all documentation
3. Add navigation aids

**Step N+3: Validation**
1. Verify all source files processed
2. Check all cross-references resolved
3. Validate documentation structure
4. Confirm language consistency

## Document Structure Template

```markdown
# [Document Title]

## Metadata
- **Source**: [Original source file]
- **Domain**: [Domain/Category]
- **Last Updated**: [Date]
- **Topics**: [Key topics covered]
- **Related**: [Links to related docs]

## [Section 1 Title]

[Content...]

## [Section 2 Title]

[Content...]

## See Also

- [Related Doc 1](path/to/doc1.md)
- [Related Doc 2](path/to/doc2.md)
```

## Quality Standards

- **Human-Readable**: Clear headings, natural language flow, appropriate detail level
- **AI-Optimized**: Rich metadata, consistent terminology, clear semantic structure
- **Well-Organized**: Logical hierarchy (2-4 levels), coherent grouping, intuitive navigation
- **Complete**: All source files processed, all cross-references resolved
- **Validated**: Structure verified, language consistency confirmed
```
