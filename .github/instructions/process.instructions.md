# Process Instructions - Transcript to Documentation System

## 📋 Overview

This document describes the overall process for transforming **raw transcripts** into **structured and queryable documentation**. It enables any agent involved in the system to understand the complete context and their role in the workflow.

---

## 🔄 Overall Workflow

```
Raw Transcripts → Cleaned Transcripts → Documentation → Search/Querying
```

### Phases

| Phase | Input | Agent/Tool | Output | Description |
|-------|--------|-------------|--------|-------------|
| **1. Preparation** | Raw recordings | Manual | `/transcripts/raw/` | Place raw transcripts |
| **2. Cleaning** | `/transcripts/raw/` | `clean-transcript` | `/transcripts/clean/` | Transform into structured markdown |
| **3. Validation** | `/transcripts/clean/` | Manual | ✓ Approved | Verify quality and completeness |
| **4. Plan Generation** | `/transcripts/clean/` + config | `doc-planner` | `temp/plan.json` + `temp/plan.md` | Generate the execution plan |
| **5. Docs Creation** | `temp/plan.json` + config | `doc-plan-executor` | `OUTPUT_PATH/` | Execute the plan and generate documentation |
| **6. Querying** | `OUTPUT_PATH/` | `search-doc` | Answers | Search and respond |

---

## 🎯 Phase Details

### Phase 1: Preparation (Manual)

**Objective**: Collect raw transcripts

**Input**: Recordings, transcriptions (`.transcript` files)

**Actions**:
- Place files in `/transcripts/raw/`
- Organize by domains if necessary
- Format: Plain text or slightly formatted

**Output**: `.transcript` files in `/transcripts/raw/`

**Example**:
```
transcripts/raw/
├── KT_1.transcript
├── KT_2.transcript
└── KT_3.transcript
```

---

### Phase 2: Cleaning (`clean-transcript` agent)

**Objective**: Transform raw transcripts into structured markdown

**Agent**: `clean-transcript.agent.md`

**Input**: Raw `.transcript` files

**Agent Actions**:
1. Read raw file
2. Correct transcription errors
3. Add missing information
4. Structure into markdown sections
5. Apply formatting standards
6. Add metadata (Topics, Related, Source)

**Output**: Structured `.md` files

**Example Transformation**:
```
INPUT (raw):
"knowledge transfer on subject X and Y... 
 and also process Z"

OUTPUT (clean):
# Knowledge Transfer

## Topics
- Subject X
- Subject Y
- Process Z

## Content
[Structured content...]
```

**Result**: `.md` files organized by domains in `/transcripts/clean/`

---

### Phase 3: Validation (Manual)

**Objective**: Ensure cleaned transcripts are correct

**Actions**:
- Examine files in `/transcripts/clean/`
- Verify content completeness
- Verify markdown structure
- Verify presence of metadata
- Correct if necessary (re-run clean-transcript if needed)

**Acceptance Criteria**:
- ✅ Correct and complete content
- ✅ Logical and coherent structure
- ✅ Metadata present
- ✅ Valid markdown formatting
- ✅ No file corruption

---

### Phase 4: Plan Generation (`doc-planner`)

**Objective**: Create a complete execution plan for documentation transformation

**Agent**: `doc-planner.agent.md`

**Input**: 
- Source files in `/transcripts/clean/`
- Configuration from `prompts.config`

**Prompt Actions**:
1. Read configuration from `.github/prompts.config`
2. Scan and analyze all source files
3. Create intelligent batch grouping (2-4 files per batch)
**Agent Actions**:
5. Generate deterministic execution order

3. Create the most relevant domain-first documentation structure for the current context
4. Create explicit batch grouping for execution
5. Record assumptions, risks, and rationale
6. Generate deterministic execution order

**Output**: Structured plan files:
- `temp/plan.json` (machine-readable, for execution)
- `temp/plan.md` (human-readable, for review)

**Result**: Plan ready for execution by `doc-plan-executor`

**Legacy compatibility**:
- The generated artifacts remain compatible with the existing `generate-doc-plan.prompt.md` / `execute-doc-plan.prompt.md` contract

**Example plan structure**:
```
temp/plan.json
├── metadata
├── config
├── batches
├── phases
└── execution_order

temp/plan.md
├── Overview
├── Batches (files per batch)
├── Phases (actions + success criteria)
└── Execution Order
```

---

### Phase 5: Documentation Creation (`doc-plan-executor`)

**Objective**: Execute the complete plan to transform all transcripts into documentation

**Agent**: `doc-plan-executor.agent.md`

**Input**:
- Execution plan from `temp/plan.json` (generated in Phase 4)
- `temp/plan.md` (human-readable reference)
- Source files in `/transcripts/clean/`
- Configuration from `prompts.config`

**Agent Actions** (sequential execution of all phases):

1. **Validate the plan**:
   - Verify plan exists and is valid
   - Reconcile plan with actual repository state
   - Stop and request replanning if structural issues are found

2. **Phase 0: Initialization**:
   - Create output folder structure in `OUTPUT_PATH/`
   - Initialize progress tracking file
   - Validate all source files are accessible

3. **Phases 1-N: Batch Processing**:
   - Read source files for current batch
   - Extract key concepts and structure
   - Create documentation files with metadata (Topics, Related, Source)
   - Optimize for AI search
   - Add Mermaid diagrams when they clarify concepts, flows, or relationships
   - Mark cross-references with TBD placeholders when needed
   - Update progress file

4. **Phase N+1: Cross-Reference Resolution**:
   - Scan all generated files
   - Identify all TBD markers
   - Replace with actual relative links
   - Validate all links work correctly
   - Update progress file

5. **Phase N+2: Summary Generation**:
   - Scan all generated documentation
   - Create the single documentation entrypoint at `OUTPUT_PATH/ENTRYPOINT`
   - Ensure `ENTRYPOINT` contains navigation + topic index + page index + source mapping
   - If `CREATE_OVERVIEW_FILES` is enabled: ensure `OVERVIEW_FILE_NAME` exists for each folder node
   - Update progress file

6. **Phase N+3: Final Validation**:
   - Verify complete structure
   - Validate metadata completeness
   - Check all links are valid
   - Verify no TBD markers remain
   - Generate validation report
   - Mark project as COMPLETE

**Additional Outputs**:
- `temp/execution-report.md` - Detailed execution timeline
- `temp/validation-report.md` - Validation results
- Progress tracked in `temp/[progress-file]`

**Features**:
- ✅ Automatically executes all phases without pause
- ✅ Can challenge a weak plan when execution evidence requires it
- ✅ Continuous progress tracking
- ✅ Can resume after interruption
- ✅ Complete error handling
- ✅ No intermediate generated documentation agent required

---
# Example when OUTPUT_PATH=/docs and ENTRYPOINT=SUMMARY.md
docs/
├── SUMMARY.md
├── 1_Domain_1/
│   ├── overview.md
│   ├── 01_Topic_A/
│   │   ├── overview.md
│   │   └── 01_Topic_A.md
│   └── 02_Topic_B.md
└── 2_Domain_2/
   ├── overview.md
   └── 01_Topic_C.md
```

---

### Phase 7: Querying (`search-doc` agent)

**Objective**: Enable search and querying of documentation

**Agent**: `search-doc.agent.md` (generic)

**Input**: Documentation in `OUTPUT_PATH/`
 
This agent MUST start from the entrypoint defined by `.github/prompts.config`:
- Read `OUTPUT_PATH/ENTRYPOINT` (default: `OUTPUT_PATH/SUMMARY.md`)
- Use it to locate relevant pages deterministically

**Usage**:
```
@search-doc "What is [Concept] ?"
@search-doc "How to [Action] ?"
@search-doc "What is the difference between [A] and [B] ?"
```

**Agent Actions**:
1. Analyze the question
2. Read `OUTPUT_PATH/ENTRYPOINT` and use it as the search entrypoint
3. Search in `OUTPUT_PATH/` and follow the entrypoint navigation/indexes to locate relevant pages
4. Extract information with citations
5. If docs are insufficient: consult transcripts only as a last resort and only when the transcript sources are explicitly referenced by the docs (never scan all transcripts)
6. Generate structured response

**Responses**:
- ✅ Based ONLY on documentation
- ✅ With exact citations
- ✅ With references to sources
- ✅ Indicating limitations
- ✅ Suggestions for related documents

---

## 🔧 Central Configuration

### File: `.github/prompts.config`

This YAML file controls **the entire process**. Agents and prompts read it to adapt their behavior.

**Key Parameters**:

```yaml
PROJECT_NAME: My Project
SOURCE_PATHS:
   - /transcripts/clean/1_Domain_1
   - /transcripts/clean/2_Domain_2
OUTPUT_PATH: /docs
ENTRYPOINT: SUMMARY.md
CREATE_OVERVIEW_FILES: true
OVERVIEW_FILE_NAME: overview.md
DOMAINS:
   - name: Domain 1
      path: 1_Domain_1
      description: My domain 1
   - name: Domain 2
      path: 2_Domain_2
      description: My domain 2
BATCH_SIZE: 2-4
LANGUAGE: English
```

**Impact**:
- Phase 4: `doc-planner` uses it to analyze files and create the plan
- Phase 5: `doc-plan-executor` uses it to execute the plan and generate documentation
- Phase 6: `search-doc` uses it to search in `OUTPUT_PATH`

---

## 📊 Dependencies and Data Flow

```
prompts.config (source of truth)
    ↓
    ├→ Phase 2: clean-transcript transforms raw
    ├→ Phase 3: validate output
    ├→ Phase 4: generate execution plan
    │   ↓
   │   └→ Phase 5: execute plan with documentation executor
   │       ↓
   │       └→ OUTPUT_PATH/ (final output)
   │           ↓
   │           └→ Phase 6: search-doc queries this
```

---

## ✅ Completion Checklist

To confirm that each phase is completed:

- [ ] **Phase 1**: `.transcript` files in `/transcripts/raw/`
- [ ] **Phase 2**: `.md` files generated in `/transcripts/clean/`
- [ ] **Phase 3**: Manual validation completed, quality ✓
- [ ] **Phase 4**: Execution plan generated in `temp/plan.json` + `temp/plan.md`
- [ ] **Phase 5**: Documentation generated in `OUTPUT_PATH/`
- [ ] **Phase 6**: Functional querying via `@search-doc`

---

## 🔄 Iteration and Improvement

### If documentation is not satisfactory

**Option 1**: Improve cleaned transcripts
1. Modify files in `/transcripts/clean/`
2. Re-run Phase 4 (regenerate plan)
3. Re-run Phase 5 (regenerate docs)

**Option 2**: Modify configuration
1. Edit `.github/prompts.config`
2. Re-run Phase 4 (regenerate plan)
3. Re-run Phase 5 (regenerate docs)

**Option 3**: Fix directly
1. Edit files in `OUTPUT_PATH/`
2. Re-run Phase 6 (search-doc will read the modified files)

---

## 🎓 Summary for Agents

### For `clean-transcript`:
- **Role**: Transform raw → structured
- **Input**: `/transcripts/raw/`
- **Output**: `/transcripts/clean/`
- **Phase**: 2

### For `doc-planner`:
- **Role**: Generate execution plan
- **Input**: `/transcripts/clean/` + `prompts.config`
- **Output**: `temp/plan.json` + `temp/plan.md`
- **Phase**: 4

### For `doc-plan-executor`:
- **Role**: Generate documentation
- **Input**: `temp/plan.json` + `/transcripts/clean/`
- **Output**: `OUTPUT_PATH/`
- **Phase**: 5

### For `search-doc`:
- **Role**: Query documentation
- **Input**: `OUTPUT_PATH/` and `OUTPUT_PATH/ENTRYPOINT`
- **Output**: Structured responses
- **Phase**: 6

---

## 📝 Conventions

- **Raw files**: `.transcript` (plain text)
- **Cleaned files**: `.md` (structured markdown)
- **Execution prompts**: `NN-name.prompt.md` (numbered, .prompt.md format)
- **Final documentation**: `.md` (markdown with metadata)
- **Configuration**: `prompts.config` (YAML)

---

## 🚀 Typical Usage Flow

```
1. Prepare transcripts → /transcripts/raw/
2. Execute @clean-transcript
3. Verify quality
4. Execute @doc-planner
5. Execute @doc-plan-executor
6. Use @search-doc to query
```

---

**Version**: 1.0  
**Language**: English  
**Audience**: Agents and developers  
**Status**: Generic & Reusable
