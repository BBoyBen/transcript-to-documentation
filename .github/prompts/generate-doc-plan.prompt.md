---
description: 'Generates a complete execution plan for documentation transformation'
tools: ['read', 'edit', 'search']
---

# Documentation Plan Generator (Deterministic)

This prompt analyzes source files and generates a **deterministic, machine-readable execution plan** for documentation transformation. The plan is structured in JSON format to ensure reproducibility and precise execution.

## Mission

Create `temp/plan.json` and `temp/plan.md` files containing:
- **plan.json**: Machine-readable structured plan for deterministic execution
- **plan.md**: Human-readable documentation of the plan for review and auditing

The plan includes all execution phases: initialization, batch processing, cross-references, summary generation, and validation.

## Scope & Preconditions

- **Required Inputs**: Configuration in `.github/prompts.config`
- **Necessary Context**: Source files in SOURCE_PATHS directories
- **Expected Outputs**: 
  - `temp/plan.json` (machine-readable, for execution)
  - `temp/plan.md` (human-readable, for review)
- **Constraints**: 
  - The plan must be deterministic (same inputs → same plan)
  - Must be executable sequentially by `execute-doc-plan.prompt.md`

## Documentation Conventions (from `.github/prompts.config`)

These conventions MUST be read from `.github/prompts.config` (same format as the rest of the configuration).

- `OUTPUT_PATH`: Documentation root folder.
- `ENTRYPOINT` (default: `SUMMARY.md`): Single documentation entrypoint created under `OUTPUT_PATH`. This file MUST contain everything a search agent needs (navigation + topic index + source mapping).
- `METADATA_FORMAT` (default: `both`): `yaml-frontmatter` | `bold-lines` | `both`.
- `CREATE_OVERVIEW_FILES` (default: `true`): `true` to create an `overview.md` per folder node in the docs hierarchy.
- `OVERVIEW_FILE_NAME` (default: `overview.md`): File name for folder-level overview documents.
- `PREFER_SHORT_DOCS` (default: `true`): `true` to allow splitting long docs into smaller, retrieval-friendly docs.
- `SPLIT_THRESHOLD_LINES` (default: `1000`): Line threshold for splitting (plan-time only).

## Workflow

### Step 1: Reading Configuration

1. Read the `.github/prompts.config` file
2. Extract all project parameters:
   - PROJECT_NAME, AGENT_NAME, AGENT_DESCRIPTION
   - SOURCE_PATHS (list of source directories)
   - OUTPUT_PATH
   - LANGUAGE, TONE, AUDIENCE
   - BATCH_SIZE, PROGRESS_FILE
   - DOMAINS (if defined, otherwise auto-detection)
   - SPECIAL_REQUIREMENTS, ADDITIONAL_FEATURES
3. Validate that all required parameters are present

4. Derive documentation conventions deterministically:
  - `output_path` MUST be `OUTPUT_PATH` from `.github/prompts.config`
  - `entrypoint`, `metadata_format`, `create_overview_files`, `overview_file_name`, `prefer_short_docs`, `split_threshold_lines` come from `.github/prompts.config` (use defaults if missing)

### Step 2: Analysis of Source Files

1. Scan all directories listed in SOURCE_PATHS
2. List all markdown files (.md) found
3. For each file:
   - Retrieve absolute path
   - Estimate size/complexity
   - Identify domain (based on path or DOMAINS config)
4. Count total number of files to process

### Step 3: Logical Course Organization (Structure Design)

**Objective**: Design a coherent, pedagogical course structure per domain.

**CRITICAL**:
- The FIRST folder level under `OUTPUT_PATH/` MUST be one folder per domain defined in `.github/prompts.config` → `DOMAINS`.
- Each output document MUST live under exactly one domain folder (no cross-domain reorganization).
- Within each domain folder, output structure should be organized as a progressive learning path (topics/subtopics), NOT as a mirror of source files.

**Algorithm Steps**:

1. **Analyze source content semantically**:
   - Read metadata and content from source files
   - Extract key concepts and learning outcomes
   - Identify prerequisite relationships
   - Map thematic areas across all files

2. **Design logical course structure**:
   - Identify natural progression (foundational → advanced)
   - Group related concepts from different sources
  - Create logical topic/subtopic hierarchy within each domain
   - Define hierarchical organization (up to 4 nesting levels)

3. **Create semantic file naming**:
  - Domain folder name: MUST use the configured `DOMAINS[].path` (top-level under `OUTPUT_PATH/`)
  - Below the domain folder: generate descriptive topic/subtopic folder names
   - Create meaningful file names reflecting content (not "doc1", but "01_Concept_Title")
   - Use prefixes for ordering: "01_", "02_", etc.
   - Ensure names are consistent with pedagogical structure

4. **Example transformation**:
   ```
   SOURCE (by knowledge transfer):
   - transcripts/clean/networking/KT_1.md (mentions DNS basics)
   - transcripts/clean/security/KT_2.md (mentions DNS security)
   - transcripts/clean/networking/KT_3.md (mentions DNS advanced)
   
  ORGANIZED (domain as top-level + course logic inside domain):
  - OUTPUT_PATH/networking/overview.md
  - OUTPUT_PATH/networking/01_Fundamentals/overview.md
  - OUTPUT_PATH/networking/01_Fundamentals/01_DNS_Basics.md
  - OUTPUT_PATH/networking/02_Advanced_Topics/overview.md
  - OUTPUT_PATH/networking/02_Advanced_Topics/01_DNS_Security.md
  - OUTPUT_PATH/security/overview.md
  - OUTPUT_PATH/security/01_Fundamentals/overview.md
  - OUTPUT_PATH/security/01_Fundamentals/01_DNS_Security_Basics.md
   ```

**Output**: Logical organization mapping (source files → course structure)

---

### Step 3bis: Creation of Batch Structure (Deterministic Algorithm)

**CRITICAL**: This algorithm MUST produce identical batches given identical inputs.

**Algorithm Steps**:

1. **Sort files deterministically**:
   - Primary sort: By domain (alphabetically)
   - Secondary sort: By file path (alphabetically)
   - Result: Stable, reproducible file ordering

2. **Group files by domain**:
   - Each domain forms separate processing unit
   - Files within domain stay together
   - Domain order: alphabetical

3. **Create batches within each domain**:
   ```
   FOR each domain:
     files_in_domain = sorted files for this domain
     batch_size = BATCH_SIZE from config (default: 3)
     
     WHILE files_in_domain not empty:
       batch = take next batch_size files
       batch_id = generate_id(domain, batch_number)
       store_batch(batch_id, files)
   ```

4. **Generate deterministic batch IDs**:
   - Format: `{DOMAIN}_{BATCH_NUM:03d}`
   - Example: `DOMAIN1_001`, `DOMAIN1_002`, `DOMAIN2_001`

5. **Define strict execution order**:
   - Phase 0: Initialization (always first)
   - Phases 1-N: Batches in order of batch_id (alphabetical)
   - Phase N+1: Cross-references (after all batches)
   - Phase N+2: Summary (after cross-refs)
   - Phase N+3: Validation (always last)

**Output**: Deterministic batch structure

### Step 3ter: Retrieval-Friendly Splitting (Deterministic)

**Applies only if** `PREFER_SHORT_DOCS` is `true` in `.github/prompts.config`.

**Goal**: Allow the plan to create multiple smaller output docs when a planned document would be too large.

**Deterministic rule**:

1. For each planned output document listed in the plan under `logical_organization` → `domains[]` → `topics[]` (and optional nested subtopics) → `files[]`, compute `estimated_line_count` as the sum of line counts of its `source_files` (use exact source line counts).
2. If `estimated_line_count` > `split_threshold_lines` (default 1000): split into:
  - 1 overview file (keeps the original `output_file` name and ordering)
  - 2 to 6 sub-documents, created by grouping source content in a stable order
3. Stable grouping order:
  - Sort `source_files` alphabetically
  - Within each source file, split by H2 headings (`## `) boundaries
  - Group consecutive H2 sections until the next group would exceed `ceil(estimated_line_count / target_parts)`
  - `target_parts` is deterministically chosen as `min(6, max(2, ceil(estimated_line_count / split_threshold_lines)))`
4. For each sub-document:
  - Add it as an additional entry in the same section `files[]` list with the next ordering number
  - Use the same folder_path as the overview doc
  - Add `related` links between overview ↔ subdocs (relative paths)
5. The executor MUST create exactly the files listed in the plan (no additional splitting during execution).

### Step 4: Generation of Complete Plan (JSON + Markdown)

#### Step 4A: Generate `temp/plan.json` (Machine-Readable)

Create a structured JSON file with the following schema:

```json
{
  "metadata": {
    "plan_version": "2.0",
    "generated_at": "ISO8601 timestamp",
    "generated_by": "generate-doc-plan.prompt.md",
    "project_name": "from config",
    "agent_name": "from config"
  },
  
  "config": {
    "project_name": "PROJECT_NAME from config",
    "agent_name": "AGENT_NAME from config",
    "agent_description": "AGENT_DESCRIPTION from config",
    "source_paths": ["array from SOURCE_PATHS"],
    "output_path": "OUTPUT_PATH from config",
    "language": "LANGUAGE from config",
    "tone": "TONE from config",
    "audience": "AUDIENCE from config",
    "batch_size": "BATCH_SIZE from config or 3",
    "progress_file": "PROGRESS_FILE from config",
    "domains": ["array from DOMAINS or auto-detected"],
    "special_requirements": ["from config if present"],
    "additional_features": ["from config if present"],
    "documentation_conventions": {
      "entrypoint": "ENTRYPOINT from .github/prompts.config (default: SUMMARY.md)",
      "metadata_format": "METADATA_FORMAT from .github/prompts.config (default: both)",
      "create_overview_files": "CREATE_OVERVIEW_FILES from .github/prompts.config (default: true)",
      "overview_file_name": "OVERVIEW_FILE_NAME from .github/prompts.config (default: overview.md)",
      "prefer_short_docs": "PREFER_SHORT_DOCS from .github/prompts.config (default: true)",
      "split_threshold_lines": "SPLIT_THRESHOLD_LINES from .github/prompts.config (default: 1000)",
      "use_mermaid_diagrams": "true — always add Mermaid diagrams (flowchart, sequenceDiagram, classDiagram, erDiagram, stateDiagram-v2…) wherever they clarify structure, flow, or relationships; never omit them to keep docs short"
    }
  },
  
  "source_analysis": {
    "total_files": 0,
    "total_size_bytes": 0,
    "domains_detected": [],
    "files": [
      {
        "path": "relative/path/to/file.md",
        "domain": "detected or from config",
        "size_bytes": 0,
        "batch_id": "assigned batch"
      }
    ]
  },
  
  "logical_organization": {
    "description": "Domain-first structure (top-level domains from config), with pedagogical organization inside each domain",
    "domains": [
      {
        "domain_name": "Domain 1",
        "domain_path": "OUTPUT_PATH/<domain.path>",
        "overview_path": "OUTPUT_PATH/<domain.path>/overview.md",
        "description": "Domain purpose and scope",
        "topics": [
          {
            "topic_name": "Topic Name",
            "folder_path": "OUTPUT_PATH/<domain.path>/01_Topic_Name",
            "overview_path": "OUTPUT_PATH/<domain.path>/01_Topic_Name/overview.md",
            "level": 2,
            "files": [
              {
                "output_file": "01_Concept_Title.md",
                "full_path": "OUTPUT_PATH/<domain.path>/01_Topic_Name/01_Concept_Title.md",
                "learning_objective": "What students should learn",
                "source_files": ["transcripts/clean/.../file1.md", "transcripts/clean/.../file2.md"],
                "ordering": 1
              }
            ]
          }
        ]
      }
    ],
    "folder_metadata_files": {
      "overview_file_name": "overview.md",
      "rule": "Create an overview.md for each folder that groups multiple documents and/or subfolders; overview.md contains folder-level metadata and links"
    },
    "naming_rules": {
      "use_prefixes": "01_, 02_, 03_ for ordering",
      "use_descriptive_names": "Based on content, not source",
      "folder_names": "CapitalizedWords with underscores",
      "file_names": "01_Descriptive_Title.md",
      "max_nesting_levels": 4
    }
  },
  
  "batches": [
    {
      "batch_id": "DOMAIN1_001",
      "batch_number": 1,
      "domain": "Domain 1",
      "files": [
        {
          "source_path": "transcripts/clean/domain1/file1.md",
          "expected_output_path": "OUTPUT_PATH/<domain.path>/01_Topic_Name/01_Concept_Title.md"
        }
      ],
      "transformation_rules": {
        "extract_topics": true,
        "min_topics": 3,
        "max_topics": 7,
        "heading_levels": {"min": 2, "max": 4},
        "metadata_format": "METADATA_FORMAT from .github/prompts.config (default: both)",
        "require_metadata": ["Topics", "Related", "Source"],
        "yaml_frontmatter_fields": ["title", "topics", "related", "sources", "generated_at", "doc_type"],
        "bold_line_fields": ["Topics", "Related", "Source"],
        "cross_ref_marker": "TBD",
        "use_mermaid_diagrams": true,
        "mermaid_diagram_types": ["flowchart", "sequenceDiagram", "classDiagram", "erDiagram", "stateDiagram-v2"],
        "language": "from config",
        "tone": "from config",
        "output_path_strategy": "PEDAGOGICAL_ORGANIZATION",
        "naming_convention": "Descriptive content-based names with numeric prefixes",
        "folder_structure": "Domain-first (top-level domain folder), then organized by topic/subtopic learning progression (not a mirror of source file paths)",
        "file_naming_examples": "01_Concept_Title.md, 02_Advanced_Topic.md"
      },
      "validation_criteria": [
        "All source files read completely",
        "All output files created",
        "Output paths follow pedagogical structure",
        "File names are descriptive and ordered",
        "Metadata present and complete",
        "Heading structure 2-4 levels",
        "Cross-batch references marked TBD",
        "Language matches config"
      ]
    }
  ],
  
  "phases": [
    {
      "phase_id": "PHASE_000",
      "phase_number": 0,
      "phase_name": "Initialization",
      "phase_type": "init",
      "depends_on": [],
      "actions": [
        {
          "action_id": "INIT_001",
          "description": "Create progress file",
          "target": "temp/progress.json",
          "validation": "File exists and is valid JSON"
        },
        {
          "action_id": "INIT_002",
          "description": "Create output directory structure",
          "target": "docs/",
          "subdirectories": ["list of domains"],
          "validation": "All directories exist and are writable"
        },
        {
          "action_id": "INIT_003",
          "description": "Validate source files",
          "validation": "All source files accessible and readable"
        }
      ],
      "success_criteria": [
        "Progress file created",
        "Directory structure created",
        "Source files validated"
      ]
    },
    {
      "phase_id": "PHASE_001",
      "phase_number": 1,
      "phase_name": "Batch DOMAIN1_001",
      "phase_type": "batch",
      "batch_id": "DOMAIN1_001",
      "depends_on": ["PHASE_000"],
      "actions": [
        {
          "action_id": "BATCH_001_READ",
          "description": "Read source files",
          "files": ["list from batch"],
          "validation": "Files read completely"
        },
        {
          "action_id": "BATCH_001_TRANSFORM",
          "description": "Transform to documentation",
          "transformation_rules": "from batch.transformation_rules",
          "validation": "Output files created with correct structure"
        },
        {
          "action_id": "BATCH_001_VALIDATE",
          "description": "Validate batch output",
          "validation": "All criteria from batch.validation_criteria met"
        }
      ],
      "success_criteria": ["from batch.validation_criteria"]
    }
  ],
  
  "execution_order": [
    "PHASE_000",
    "PHASE_001",
    "PHASE_002",
    "...",
    "PHASE_CROSSREF",
    "PHASE_SUMMARY",
    "PHASE_VALIDATION"
  ],
  
  "estimated_time": {
    "initialization_minutes": 5,
    "per_batch_minutes": 15,
    "crossref_minutes": 10,
    "summary_minutes": 5,
    "validation_minutes": 5,
    "total_minutes": 0
  }
}
```

#### Step 4B: Generate `temp/plan.md` (Human-Readable)

Create a markdown file for human review with the following structure:

```markdown
# Execution Plan - [PROJECT_NAME]

**Generated on**: [DATE]
**Agent**: @[AGENT_NAME]
**Language**: [LANGUAGE]

## Project Summary

- **Project**: [PROJECT_NAME]
- **Description**: [AGENT_DESCRIPTION]
- **Source files**: [NUMBER] files
- **Domains**: [LIST OF DOMAINS]
- **Batches**: [NUMBER] batches
- **Total phases**: [NUMBER] (1 init + [N] batches + 3 finalization)
- **Estimated time**: ~[TIME] hours

## Configuration

[Copy of key parameters from .github/prompts.config]

## Pedagogical Course Structure

**Important**: Output organization follows a logical learning progression, not the source file organization.

### Course Organization

The documentation will be organized as:

docs/
├── 01_Foundational_Concepts/
│   ├── 01_Core_Topic.md
│   ├── 02_Supporting_Concept.md
│   └── ...
├── 02_Intermediate_Topics/
│   ├── 01_Building_Blocks.md
│   └── ...
└── 03_Advanced_Topics/
    ├── 01_Expert_Concepts.md
    └── ...

### Naming Convention

- **Folders**: Descriptive names reflecting learning modules (e.g., "Foundational_Concepts", "Advanced_Topics")
- **Files**: Ordered with prefixes (01_, 02_, etc.) and descriptive names (e.g., "01_Core_Principles.md")
- **Logic**: Based on content and learning progression, not source file names or domains

## Batch Structure

### Batch 1: [DESCRIPTIVE_NAME]
- **Files**: [LIST OF SOURCE FILES]
- **Source Domain**: [ORIGINAL_DOMAIN]
- **Target Structure**: Organized into pedagogical modules
- **Output Examples**:
  - Source: `transcripts/clean/domain1/file1.md` → Output: `docs/01_Foundational_Concepts/01_Core_Topic.md`
  - Source: `transcripts/clean/domain2/file2.md` → Output: `docs/01_Foundational_Concepts/02_Supporting_Concept.md`
- **Estimated duration**: ~[MINUTES] minutes

[... Repeat for each batch ...]

## Execution Phases

### Phase 0: Initialization

**Objective**: Prepare the environment and create base structures

**Actions**:
1. Create progress tracking file: [PROGRESS_FILE]
2. Create output folder structure: [OUTPUT_PATH]
3. Initialize project metadata
4. Validate that all source files are accessible

**Success Criteria**:
- Progress file created with "INITIALIZED" status
- Folder structure created
- All source files validated

**Detailed Instructions**:
[Complete initialization instructions]

---

### Phase 1: Batch 1 - [BATCH_NAME]

**Objective**: Transform Batch 1 files into structured documentation

**Source Files**:
- [FILE_PATH_1]
- [FILE_PATH_2]
- ...

**Expected Output**:
- [OUTPUT_PATH_1]
- [OUTPUT_PATH_2]
- ...

**Actions**:
1. Read each source file
2. Extract key concepts and structure
3. Create documentation files with:
   - Metadata (Topics, Related, Source)
   - Hierarchical structure (2-4 levels max)
   - Optimization for AI search
   - Cross-references with TBD markers
4. Update progress file

**Special Requirements**:
[SPECIAL_REQUIREMENTS from config]

**Success Criteria**:
- All output files created
- Structure conforms to standards
- Cross-references marked with TBD
- Progress updated with "BATCH_1_COMPLETE" status

**Detailed Instructions**:
[Complete batch instructions with structure examples]

---

[... Repeat Phase N for each batch ...]

---

### Phase [N+1]: Cross-Reference Resolution

**Objective**: Replace all TBD markers with actual links between documents

**Actions**:
1. Scan all generated files in [OUTPUT_PATH]
2. Identify all TBD markers
3. For each marker:
   - Locate target document
   - Create correct relative link
   - Replace TBD marker
4. Validate that all links work
5. Update progress file

**Success Criteria**:
- No TBD markers remaining
- All links valid and relative
- Progress updated with "CROSS_REFS_COMPLETE" status

**Detailed Instructions**:
[Complete reference resolution instructions]

---

### Phase [N+2]: Summary Generation

**Objective**: Create a synthesis document and global index

**Actions**:
1. Scan all generated documents
2. Extract metadata (format depends on `METADATA_FORMAT` from `.github/prompts.config`)
3. Create main entrypoint file `ENTRYPOINT` under `OUTPUT_PATH` with:
  - Project overview
  - Documentation structure
  - Pages list (course order): every document link + title + topics + one-line description
  - Index by domain
  - Index by topic (A–Z): topic → list of documents
  - Index by page title (A–Z): page → link + topics
  - Source mapping: each output document → its sources
  - A short "How to search" section for agents
  - Navigation guide
4. If `CREATE_OVERVIEW_FILES` is `true`: ensure `OVERVIEW_FILE_NAME` exists for each folder node described in the plan under `logical_organization` (domain/topic/subtopic folders). These overview files contain folder-level metadata and links.
5. Update progress file

**Success Criteria**:
- Entrypoint created with complete index
- Folder overview.md files created when enabled
- All documents listed and categorized
- Progress updated with "SUMMARY_COMPLETE" status

**Detailed Instructions**:
[Complete summary generation instructions]

---

### Phase [N+3]: Final Validation

**Objective**: Verify quality and completeness of generated documentation

**Actions**:
1. Verify complete structure:
   - All expected files are created
   - Correct folder hierarchy
   - Compliant file names
2. Validate content:
   - Metadata present and complete
   - No TBD markers remaining
   - All links work
   - Hierarchical structure correct (2-4 levels)
3. Verify special requirements:
   - Language: [LANGUAGE]
   - Tone: [TONE]
   - AI optimization: ✓
   - [Other SPECIAL_REQUIREMENTS]
4. Generate validation report
5. Update progress file with "PROJECT_COMPLETE" status

**Success Criteria**:
- All checks pass
- Positive validation report
- Progress file marks "PROJECT_COMPLETE"
- Documentation ready for search and publication

**Detailed Instructions**:
[Complete validation instructions]

---

## Execution Order

**IMPORTANT**: Phases must be executed in this strict order:

1. ✅ Phase 0: Initialization
2. ✅ Phase 1: Batch 1 - [NAME]
3. ✅ Phase 2: Batch 2 - [NAME]
[... List of all phases ...]
N. ✅ Phase N: Batch N - [NAME]
N+1. ✅ Phase N+1: Cross-References
N+2. ✅ Phase N+2: Summary Generation
N+3. ✅ Phase N+3: Final Validation

**Never**:
- Skip a phase
- Execute phases in parallel
- Continue if a phase fails

## Progress Tracking

The file `[PROGRESS_FILE]` will be updated after each phase with:
- Phase status (NOT_STARTED, IN_PROGRESS, COMPLETE, FAILED)
- Timestamp
- Files created
- Errors or warnings
- Next recommended action

## Estimated Execution Time

- **Initialization**: ~5 minutes
- **Per batch**: ~[BATCH_TIME] minutes (depending on size)
- **Cross-references**: ~5-10 minutes
- **Summary generation**: ~5 minutes
- **Final validation**: ~5 minutes
- **TOTAL**: ~[TOTAL_TIME] hours

## Important Notes

- This plan is generated automatically based on source file analysis
- The detailed instructions for each phase are complete and ready for execution
- The plan must be executed sequentially by `execute-doc-plan.prompt.md`
- In case of phase error, fix and relaunch that phase before continuing
- The progress file allows resumption in case of interruption

---

**Plan generated by**: generate-doc-plan.prompt.md
**Ready for execution with**: execute-doc-plan.prompt.md via @[AGENT_NAME]
```

### Step 5: Plan Finalization and Validation

1. **Validate plan determinism**:
   - Verify all batch_ids follow naming convention: `{DOMAIN}_{NUM:03d}`
   - Verify execution_order is strict and sequential
   - Verify no ambiguous instructions (no "intelligent", "logical", etc.)
   - Verify all phases have measurable success criteria

2. **Write final files**:
   - Write `temp/plan.json` with complete structure
   - Write `temp/plan.md` for human review
   - Ensure both files are synchronized

3. **Verify outputs**:
   - Verify that both `temp/plan.json` and `temp/plan.md` are created
   - Validate JSON schema compliance
   - Verify that file paths are correct and relative to workspace
   - Ensure that instructions are detailed, actionable, and deterministic
   - Confirm that the plan is ready for execution

## Output Expectations

### Files Created

#### 1. `temp/plan.json` (Primary - Machine Readable)

**Purpose**: Deterministic execution plan for `execute-doc-plan.prompt.md`

**Content**:
- Complete metadata
- Full project configuration
- Source file analysis (paths, sizes, domains)
- Detailed batch structure with validation rules
- Numbered execution phases with actions
- Strict execution order
- Estimated times

**Format**:
- Valid JSON conforming to schema
- All paths relative to workspace
- ISO8601 timestamps
- Deterministic ordering (alphabetical where applicable)

#### 2. `temp/plan.md` (Secondary - Human Readable)

**Purpose**: Human-friendly documentation for review and auditing

**Content**:
- Header with project summary
- Complete project configuration
- Detailed batch structure
- Numbered execution phases with complete instructions
- Strict execution order
- Progress tracking information
- Estimated times

**Format**:
- Well-structured markdown with hierarchical headings
- Clear sections with `---` separators
- Lists for actions and criteria
- Code blocks for examples
- Checkboxes for execution tracking

### Quality Requirements

The plan must be:
- ✅ **Deterministic**: Same inputs always produce identical plan
- ✅ **Complete**: All information necessary for execution
- ✅ **Detailed**: Step-by-step instructions for each phase
- ✅ **Actionable**: Ready to execute without ambiguity
- ✅ **Structured**: Logical organization and easy to follow
- ✅ **Traceable**: Clear success criteria and progress tracking
- ✅ **Reproducible**: Can be executed multiple times with same results

## Quality Assurance

### Validation Checklist

Before considering the plan complete, verify:

**Configuration & Analysis**:
- [ ] Configuration read from `.github/prompts.config`
- [ ] All required parameters validated
- [ ] All source files listed and analyzed
- [ ] Domains identified deterministically

**Batch Structure (Deterministic)**:
- [ ] Batches created with deterministic algorithm
- [ ] Files sorted alphabetically within domains
- [ ] Batch size consistent (from BATCH_SIZE config)
- [ ] Batch IDs follow convention: `{DOMAIN}_{NUM:03d}`
- [ ] Each batch has 2-4 files (or as configured)

**Phases & Execution**:
- [ ] Phase 0 (Initialization) with complete instructions
- [ ] One phase per batch with detailed, deterministic instructions
- [ ] Phase N+1 (Cross-references) included
- [ ] Phase N+2 (Summary) included
- [ ] Phase N+3 (Validation) included
- [ ] Execution order strictly sequential and defined
- [ ] Phase dependencies mapped (depends_on)

**Validation & Quality**:
- [ ] Success criteria for each phase clearly defined
- [ ] Transformation rules specified for each batch
- [ ] Validation criteria measurable and objective
- [ ] Progress file path configured
- [ ] Estimated times calculated deterministically
- [ ] File paths correct (relative to workspace)

**File Outputs**:
- [ ] `temp/plan.json` created with valid JSON
- [ ] `temp/plan.md` created with valid markdown
- [ ] Both files synchronized
- [ ] Plan ready for `execute-doc-plan.prompt.md`

**Determinism Check**:
- [ ] All sorting is alphabetical or rule-based
- [ ] No subjective terms ("intelligent", "logical", etc.)
- [ ] All actions have measurable validation criteria

### Quality Tests

1. **Completeness**: Does the plan contain all necessary information?
2. **Clarity**: Are instructions clear and unambiguous?
3. **Executability**: Can the plan be executed without additional information?
4. **Coherence**: Do phases flow logically?
5. **Traceability**: Do success criteria allow validating each phase?

## Example Usage

In Copilot Chat, with the appropriate agent:

```
@create-docs
/generate-doc-plan
```

The prompt will:
1. Read `.github/prompts.config`
2. Scan `/transcripts/clean/1_Domain_1/` and `/transcripts/clean/2_Domain_2/`
3. Analyze 15 source files
4. Create 6 intelligent batches
5. Generate `temp/plan.md` with 10 phases (1 init + 6 batches + 3 finalization)
6. Display a summary of the created plan

Then execute the plan with:

```
@create-docs
/execute-doc-plan
```

## Output Messages

### Success Message

```
✅ Deterministic documentation plan generated successfully!

📄 Files created:
- temp/plan.json (machine-readable)
- temp/plan.md (human-readable documentation)

📊 Plan Summary:
- Project: [PROJECT_NAME]
- Source files: [N] files
- Domains: [N] domains
- Batches: [N] batches (deterministic)
- Total phases: [N] phases
- Estimated time: ~[TIME] hours

🎯 Next steps:
1. Review plan: temp/plan.md (execution uses temp/plan.json)
2. Generate agent: @[AGENT_NAME] /generate-agent-from-plan
3. Execute plan: @[AGENT_NAME] /execute-doc-plan
```

### Error Message

If configuration is missing or invalid:

```
❌ Unable to generate plan

Problem: [ERROR DESCRIPTION]

Required actions:
1. Verify that .github/prompts.config exists
2. Ensure all required parameters are defined
3. Validate SOURCE_PATHS paths

Missing/invalid parameters:
- [LIST OF PARAMETERS]
```

## Technical Notes

### Deterministic Batching Algorithm

**Key Principle**: Same input files + same config = identical batches every time.

**Algorithm**:
```
1. List all files in SOURCE_PATHS
2. Sort files by:
   - Primary: Domain (alphabetical)
   - Secondary: File path (alphabetical)
3. Group files by domain (keep together)
4. Within each domain:
   - Take files in sorted order
   - Create batches of BATCH_SIZE
   - Generate ID: {DOMAIN}_{BATCH_NUM:03d}
```

**Why Deterministic**:
- No "intelligent" grouping (subjective)
- No "size balancing" (heuristic)
- No "logical order" (interpretative)
- Pure algorithmic: alphabetical + fixed batch size

### Cross-Reference Management

References between batches are managed via:
- **TBD markers**: `[TBD: Batch N - file.md]` during processing
- **Dedicated phase**: Phase N+1 replaces all TBD with real links
- **Validation**: Phase N+3 verifies no TBD remains

### Resumption After Interruption

The progress file allows:
- Identifying which phase was in progress
- Resuming from last completed phase
- Avoiding rework already done

## Maintenance

This prompt must be updated if:
- The format of `.github/prompts.config` changes
- New phases are added to workflow
- Quality requirements evolve
- Output format changes

---

## Determinism Guarantees

This prompt guarantees deterministic plan generation:

1. **Identical Inputs → Identical Plan**:
   - Same source files + same config = same plan.json
   - Batch structure will be identical

2. **Reproducibility**:
   - Plan can be regenerated any time
   - Results are predictable and verifiable
   - No randomness or heuristics

3. **Auditability**:
   - Complete trace of decisions
   - All rules explicit and measurable
   - Human-readable documentation (plan.md)

---

**Version**: 2.0 (Deterministic)
**Last updated**: 2026-01-12
**Complementary files**: 
- `execute-doc-plan.prompt.md` (executes the plan)
- `generate-agent-from-plan.prompt.md` (generates agent from plan)
