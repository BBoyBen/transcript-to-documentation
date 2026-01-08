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
| **4. Agent Generation** | `/transcripts/clean/` + config | `generic-doc-transformation-agent` | `create-docs.agent.md` | Create custom agent |
| **5. Prompt Generation** | `/transcripts/clean/` + config | `create-prompt` | `*.prompt.md` numbered | Create execution prompts |
| **6. Docs Creation** | `/transcripts/clean/` + prompts | `create-docs` | `/docs/` | Generate final documentation |
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

### Phase 4: Agent Generation (`generic-doc-transformation-agent`)

**Objective**: Create a custom agent for documentation generation

**Prompt**: `generic-doc-transformation-agent.prompt.md`

**Input**: 
- Source files in `/transcripts/clean/`
- Configuration from `prompts.config`

**Prompt Actions**:
1. Read source structure
2. Analyze domains and sections
3. Read `prompts.config` for parameters
4. Generate custom `create-docs` agent
5. Adapt agent to your structure

**Output**: `.github/agents/create-docs.agent.md` (custom)

**Result**: Agent generated and ready for execution

---

### Phase 5: Prompt Generation (`create-prompt`)

**Objective**: Create all necessary execution prompts

**Prompt**: `create-prompt.prompt.md`

**Input**:
- Source files in `/transcripts/clean/`
- Configuration from `prompts.config`

**Prompt Actions**:
1. Count source files
2. Calculate optimal batch grouping (2-4 files)
3. Generate initialization prompt (`01-init-docs.prompt.md`)
4. Generate batch prompts (`02-batch-01.prompt.md`, `03-batch-02.prompt.md`, etc.)
5. Generate cross-references prompt (`N-cross-references.prompt.md`)
6. Generate summary prompt (`N+1-summary.prompt.md`)

**Output**: Numbered `.prompt.md` files in `.github/prompts/`

**Example for 6 files (2 per batch)**:
```
.github/prompts/
├── 01-init-docs.prompt.md
├── 02-batch-01.prompt.md (KT_1, KT_2)
├── 03-batch-02.prompt.md (KT_3, KT_4)
├── 04-batch-03.prompt.md (KT_5, KT_6)
├── 05-cross-references.prompt.md
└── 06-summary.prompt.md
```

---

### Phase 6: Documentation Creation (`create-docs` agent)

**Objective**: Transform cleaned transcripts into final documentation

**Agent**: `create-docs.agent.md` (generated in phase 4)

**Input**: 
- Structured `.md` files in `/transcripts/clean/`
- Numbered prompts generated in phase 5

**Agent Actions** (sequential execution):
1. **Initialization** (`01-init-docs.prompt.md`):
   - Create base structure
   - Initialize destination files

2. **Batch Processing** (`02-batch-XX.prompt.md`):
   - Transform each batch of 2-4 files
   - Generate structured sections
   - Add metadata (Topics, Related, Source)
   - Create files in `/docs/`

3. **Cross-references** (`N-cross-references.prompt.md`):
   - Analyze connections between documents
   - Add "Related" links
   - Update references

4. **Summary** (`N+1-summary.prompt.md`):
   - Create complete index
   - Generate overview
   - Create `summary.md` file

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
- Phase 4: `generic-doc-transformation-agent` uses it to generate the agent
- Phase 5: `create-prompt` uses it to calculate batches
- Phase 6: `create-docs` uses it to structure documentation
- Phase 7: `search-doc` uses it to search in `OUTPUT_PATH`

---

## 📊 Dependencies and Data Flow

```
prompts.config (source of truth)
    ↓
    ├→ Phase 4: generate create-docs agent
    ├→ Phase 5: generate numbered prompts
    │   ↓
    │   └→ Phase 6: execute with these prompts
    │       ↓
    │       └→ /docs/ (final output)
    │           ↓
    │           └→ Phase 7: search-doc queries this
    ├→ Phase 2: clean-transcript transforms raw
    └→ Phase 3: validate output
```

---

## ✅ Completion Checklist

To confirm that each phase is completed:

- [ ] **Phase 1**: `.transcript` files in `/transcripts/raw/`
- [ ] **Phase 2**: `.md` files generated in `/transcripts/clean/`
- [ ] **Phase 3**: Manual validation completed, quality ✓
- [ ] **Phase 4**: `create-docs.agent.md` file generated
- [ ] **Phase 5**: Numbered `.prompt.md` files in `.github/prompts/`
- [ ] **Phase 6**: Documentation generated in `/docs/`
- [ ] **Phase 7**: Functional querying via `@search-doc`

---

## 🔄 Iteration and Improvement

### If documentation is not satisfactory

**Option 1**: Improve cleaned transcripts
1. Modify files in `/transcripts/clean/`
2. Re-run Phase 5 (regenerate prompts)
3. Re-run Phase 6 (regenerate docs)

**Option 2**: Modify configuration
1. Edit `.github/prompts.config`
2. Re-run Phase 4 (regenerate agent)
3. Re-run Phase 5 (regenerate prompts)
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

### For `generic-doc-transformation-agent`:
- **Role**: Generate custom agent
- **Input**: `/transcripts/clean/` + `prompts.config`
- **Output**: `create-docs.agent.md`
- **Phase**: 4

### For `create-prompt`:
- **Role**: Generate execution prompts
- **Input**: `/transcripts/clean/` + `prompts.config`
- **Output**: `*.prompt.md` numbered
- **Phase**: 5

### For `create-docs`:
- **Role**: Generate documentation
- **Input**: `/transcripts/clean/` + prompts
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
4. Execute @generic-doc-transformation-agent
5. Execute @create-prompt
6. Execute @create-docs (with all prompts)
7. Use @search-doc to query
```

---

**Version**: 1.0  
**Language**: English  
**Audience**: Agents and developers  
**Status**: Generic & Reusable
