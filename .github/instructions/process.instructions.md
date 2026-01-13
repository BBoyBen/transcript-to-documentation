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
| **4. Plan Generation** | `/transcripts/clean/` + config | `generate-doc-plan` | `temp/plan.md` | Generate complete execution plan |
| **5. Agent Generation** | `/transcripts/clean/` + config | `generic-doc-transformation-agent` | `create-docs.agent.md` | Create custom agent |
| **6. Docs Creation** | `temp/plan.md` | `execute-doc-plan` | `/docs/` | Execute all phases sequentially |
| **7. Querying** | `/docs/` | `search-doc` | Answers | Search and respond |

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

### Phase 4: Plan Generation (`generate-doc-plan`)

**Objective**: Create a complete execution plan for documentation transformation

**Prompt**: `generate-doc-plan.prompt.md`

**Input**: 
- Source files in `/transcripts/clean/`
- Configuration from `prompts.config`

**Prompt Actions**:
1. Read configuration from `.github/prompts.config`
2. Scan and analyze all source files
3. Create intelligent batch grouping (2-4 files per batch)
4. Generate complete execution plan with all phases
5. Calculate optimal execution order and timing

**Output**: Structured plan file `temp/plan.md`

**Result**: Plan ready for execution by `execute-doc-plan` prompt

**Example plan structure**:
```
temp/plan.md
├── Project Summary (statistics, domains, batches)
├── Configuration (all parameters)
├── Batch Structure (list of all batches with files)
├── Execution Phases (detailed steps for each phase)
│   ├── Phase 0: Initialization
│   ├── Phase 1-N: Batch processing
│   ├── Phase N+1: Cross-reference resolution
│   ├── Phase N+2: Summary generation
│   └── Phase N+3: Final validation
├── Execution Order (strict sequential order)
└── Progress Tracking (format and update strategy)
```

---

### Phase 5: Agent Generation (`generic-doc-transformation-agent`)

**Objective**: Create a custom agent for documentation generation

**Prompt**: `generic-doc-transformation-agent.prompt.md`

**Input**: 
- Source files in `/transcripts/clean/`
- Configuration from `prompts.config`
- Execution plan from `temp/plan.md` (generated in Phase 4)

**Prompt Actions**:
1. Read source structure
2. Analyze domains and sections from plan
3. Read `prompts.config` for parameters
4. Generate custom `create-docs` agent adapted to plan structure
5. Optimize agent based on batch grouping and execution plan

**Output**: `.github/agents/create-docs.agent.md` (custom)

**Result**: Agent generated and ready for execution with plan

---

### Phase 6: Documentation Creation (`execute-doc-plan`)

**Objective**: Execute the complete plan to transform all transcripts into documentation

**Prompt**: `execute-doc-plan.prompt.md`

**Input**: 
- Execution plan from `temp/plan.md` (generated in Phase 4)
- Source files in `/transcripts/clean/`
- Custom agent from `create-docs.agent.md` (generated in Phase 5)

**Prompt Actions** (sequential execution of all phases):

1. **Phase 0: Initialization**:
   - Verify plan exists and is valid
   - Create output folder structure in `/docs/`
   - Initialize progress tracking file
   - Validate all source files are accessible

2. **Phases 1-N: Batch Processing** (executes each batch):
   - Read source files for current batch
   - Extract key concepts and structure
   - Create documentation files with metadata (Topics, Related, Source)
   - Optimize for AI search
   - Mark cross-references with TBD placeholders
   - Update progress file

3. **Phase N+1: Cross-Reference Resolution**:
   - Scan all generated files
   - Identify all TBD markers
   - Replace with actual relative links
   - Validate all links work correctly
   - Update progress file

4. **Phase N+2: Summary Generation**:
   - Scan all generated documentation
   - Create README.md with complete index and navigation
   - Create SUMMARY.md with statistics
   - Organize by domain and topic
   - Update progress file

5. **Phase N+3: Final Validation**:
   - Verify complete structure
   - Validate metadata completeness
   - Check all links are valid
   - Verify no TBD markers remain
   - Generate validation report
   - Mark project as COMPLETE

**Output**: Complete documentation in `/docs/`

**Additional Outputs**:
- `temp/execution-report.md` - Detailed execution timeline
- `temp/validation-report.md` - Validation results
- Progress tracked in `temp/[progress-file]`

**Features**:
- ✅ Automatically executes all phases without pause
- ✅ Continuous progress tracking
- ✅ Can resume after interruption
- ✅ Complete error handling

**Output**: Structured documentation in `/docs/`

**Resulting structure**:
```
docs/
├── summary.md
├── domain1/
│   ├── doc-KT_1.md
│   └── doc-KT_2.md
└── domain2/
    ├── doc-KT_3.md
    └── doc-KT_4.md
```

---

### Phase 7: Querying (`search-doc` agent)

**Objective**: Enable search and querying of documentation

**Agent**: `search-doc.agent.md` (generic)

**Input**: Documentation in `/docs/`

**Usage**:
```
@search-doc "What is [Concept] ?"
@search-doc "How to [Action] ?"
@search-doc "What is the difference between [A] and [B] ?"
```

**Agent Actions**:
1. Analyze the question
2. Search in `/docs/`
3. Find relevant documents
4. Extract information
5. Generate structured response
6. Provide citations and sources

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
  - /transcripts/clean/domain1
  - /transcripts/clean/domain2
OUTPUT_PATH: /docs
DOMAINS:
  - Domain1
  - Domain2
BATCH_SIZE: 2-4
LANGUAGE: English
```

**Impact**:
- Phase 4: `generate-doc-plan` uses it to analyze files and create plan
- Phase 5: `generic-doc-transformation-agent` uses it to generate the agent
- Phase 6: `create-docs` uses it to structure documentation
- Phase 7: `search-doc` uses it to search in `OUTPUT_PATH`

---

## 📊 Dependencies and Data Flow

```
prompts.config (source of truth)
    ↓
    ├→ Phase 2: clean-transcript transforms raw
    ├→ Phase 3: validate output
    ├→ Phase 4: generate execution plan
    │   ↓
    │   └→ Phase 5: generate create-docs agent (adapted to plan)
    │       ↓
    │       └→ Phase 6: execute plan with agent
    │           ↓
    │           └→ /docs/ (final output)
    │               ↓
    │               └→ Phase 7: search-doc queries this
```

---

## ✅ Completion Checklist

To confirm that each phase is completed:

- [ ] **Phase 1**: `.transcript` files in `/transcripts/raw/`
- [ ] **Phase 2**: `.md` files generated in `/transcripts/clean/`
- [ ] **Phase 3**: Manual validation completed, quality ✓
- [ ] **Phase 4**: Execution plan generated in `temp/plan.md`
- [ ] **Phase 5**: `create-docs.agent.md` file generated
- [ ] **Phase 6**: Documentation generated in `/docs/`
- [ ] **Phase 7**: Functional querying via `@search-doc`

---

## 🔄 Iteration and Improvement

### If documentation is not satisfactory

**Option 1**: Improve cleaned transcripts
1. Modify files in `/transcripts/clean/`
2. Re-run Phase 4 (regenerate plan)
3. Re-run Phase 5 (regenerate agent)
4. Re-run Phase 6 (regenerate docs)

**Option 2**: Modify configuration
1. Edit `.github/prompts.config`
2. Re-run Phase 4 (regenerate plan)
3. Re-run Phase 5 (regenerate agent)
4. Re-run Phase 6 (regenerate docs)

**Option 3**: Fix directly
1. Edit files in `/docs/`
2. Re-run Phase 7 (search-doc will read the modified files)

---

## 🎓 Summary for Agents

### For `clean-transcript`:
- **Role**: Transform raw → structured
- **Input**: `/transcripts/raw/`
- **Output**: `/transcripts/clean/`
- **Phase**: 2

### For `generate-doc-plan`:
- **Role**: Generate execution plan
- **Input**: `/transcripts/clean/` + `prompts.config`
- **Output**: `temp/plan.md`
- **Phase**: 4

### For `generic-doc-transformation-agent`:
- **Role**: Generate custom agent
- **Input**: `/transcripts/clean/` + `prompts.config` + `temp/plan.md`
- **Output**: `create-docs.agent.md`
- **Phase**: 5

### For `create-docs`:
- **Role**: Generate documentation
- **Input**: `temp/plan.md` + `/transcripts/clean/`
- **Output**: `/docs/`
- **Phase**: 6

### For `search-doc`:
- **Role**: Query documentation
- **Input**: `/docs/`
- **Output**: Structured responses
- **Phase**: 7

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
4. Execute /generate-doc-plan
5. Execute @generic-doc-transformation-agent
6. Execute @create-docs /execute-doc-plan
7. Use @search-doc to query
```

---

**Version**: 1.0  
**Language**: English  
**Audience**: Agents and developers  
**Status**: Generic & Reusable
