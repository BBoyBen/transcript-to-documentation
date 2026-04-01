# Transcript to Documentation System

Automated system for transforming transcripts into structured and queryable documentation.

## 📖 Introduction

This project provides a **complete suite of tools and agents** to transform raw transcripts (meeting recordings, knowledge transfer interviews, etc.) into **structured, navigable and queryable documentation**.

Generated documentation can be searched and queried via the **integrated search agent** (`search-doc`), allowing quick and precise access to documented information.

### Why It Matters

- 📝 **Knowledge Capture**: Transforms verbal transcripts into written documentation
- 🔍 **Accessibility**: Makes information easily accessible via intelligent search
- 📊 **Structuring**: Organizes information in a coherent and logical manner
- 🔄 **Reusability**: Generic documentation usable on any project
- 🤖 **Automation**: Uses GitHub Copilot to accelerate the process

---

## 🔧 Requirements

### Required Tools

- **GitHub Copilot Chat** - AI assistant for executing agents
- **Visual Studio Code** - Code editor with Copilot Chat support
- **Project Folder** - Structure prepared with necessary folders

### Recommended Versions

- VS Code: Recent version (2024+)
- GitHub Copilot: Access enabled

### Required Skills

- Understand Git/GitHub basics
- Familiarity with VS Code
- Ability to follow step-by-step instructions

---

## 📦 Installation

### Step 1: Clone/Create Repository

```bash
# Option 1: Clone existing repository
git clone <repository-url>
cd <repository-name>

# Option 2: Create structure from scratch
mkdir -p .github/{agents,prompts,instructions}
mkdir -p transcripts/{raw,clean}
mkdir -p docs
mkdir -p temp
```

### Step 2: Verify File Structure

Ensure following files exist in your project:

**Required Files**:

```
.github/
├── agents/
│   ├── clean-transcript.agent.md               ← Cleaning agent
│   ├── doc-planner.agent.md                    ← Planning agent
│   ├── doc-plan-executor.agent.md              ← Execution agent
│   └── search-doc.agent.md                     ← Search agent
├── prompts/
│   └── validate-transcripts.prompt.md          ← Transcript validation gate
├── instructions/
│   ├── agents.instructions.md                  ← Agent rules
│   ├── markdown.instructions.md                ← Markdown standards
│   ├── process.instructions.md                 ← Global process
│   └── prompt.instructions.md                  ← Prompt standards
├── skills/
│   ├── doc-config-reading/SKILL.md             ← Config keys, defaults, normalization
│   ├── doc-metadata-format/SKILL.md            ← Metadata schema and rendering rules
│   ├── doc-output-structure/SKILL.md           ← Folder naming, depth, overview rules
│   └── doc-entrypoint-template/SKILL.md        ← SUMMARY.md template and structure
└── prompts.config                              ← Central configuration

transcripts/
├── raw/                                         ← Raw transcripts
└── clean/                                       ← Cleaned transcripts

docs/                                            ← Generated documentation

temp/                                            ← Temporary files
```

### Step 3: Initial Configuration

Edit `.github/prompts.config` file with your project parameters:

```yaml
PROJECT_NAME: Your Project Name
AGENT_NAME: doc-plan-executor
SOURCE_PATHS:
  - /transcripts/clean/1_Domain_1
  - /transcripts/clean/2_Domain_2
OUTPUT_PATH: /docs
ENTRYPOINT: SUMMARY.md
CREATE_OVERVIEW_FILES: true
OVERVIEW_FILE_NAME: overview.md
LANGUAGE: English
DOMAINS:
  - name: Domain 1
    path: 1_Domain_1
    description: My domain 1
  - name: Domain 2
    path: 2_Domain_2
    description: My domain 2
BATCH_SIZE: 2-4
```

---

## 📁 File and Folder Description

### Agents (`.github/agents/`)

#### `clean-transcript.agent.md`
**Role**: Transcript cleaning and structuring agent
- Reads raw transcripts (`.transcript`)
- Corrects errors and omissions
- Structures content into markdown
- Applies formatting standards
- Output: Structured `.md` files in `/transcripts/clean`
- **Status**: Required agent (necessary at startup)

#### `doc-planner.agent.md`
**Role**: Documentation planning agent
- Reads `.github/prompts.config` and analyzes `/transcripts/clean/`
- Produces `temp/plan.json` and `temp/plan.md`
- Adapts the plan to business and technical context while keeping execution explicit
- **Status**: Primary planning agent

#### `doc-plan-executor.agent.md`
**Role**: Documentation execution agent
- Reads `temp/plan.json` and produces final documentation directly in `OUTPUT_PATH/`
- Can challenge the plan when source evidence or execution constraints require a bounded correction
- Generates progress tracking, execution report, validation report, and navigation files
- **Status**: Primary execution agent

#### `search-doc.agent.md`
**Role**: Search and response agent
- Queries generated documentation
- Responds only based on documentation
- No hallucination or invention
- Provides sources and citations
- Restriction: No code execution
- **Status**: Generic agent (copy-paste ready)

### Prompts (`.github/prompts/`)

#### `validate-transcripts.prompt.md`
**Role**: Transcript validation gate (Phase 3)
- Scans all `.md` files in `SOURCE_PATHS` for structural and metadata completeness
- Read-only: produces a pass/fail report without writing files
- Blocks pipeline progress until all files are ✅ Ready or ⚠️ Needs Revision (minor issues)
- **Status**: Active — run before planning (`@validate-transcripts`)

### Instructions (`.github/instructions/`)

#### `process.instructions.md`
Global process and workflow:
- Complete end-to-end system description
- Pipeline phases and steps
- Data flow between components
- Dependencies and sequencing
- Completion checklists

#### `agents.instructions.md`
Creation rules for `.agent.md` files:
- YAML frontmatter structure
- Required sections
- Format and conventions
- Best practices

#### `markdown.instructions.md`
Documentation standards:
- Consistent markdown formatting
- Document structure
- Naming conventions
- Required metadata

#### `prompt.instructions.md`
Standards for `.prompt.md` files:
- Structure and format
- Instruction sections
- Best practices
- Validation

### Skills (`.github/skills/`)

On-demand knowledge packages loaded by agents when needed. Unlike instructions (always in context), skills are loaded explicitly at a specific step — reducing context size and keeping domain knowledge reusable across agents.

#### `doc-config-reading/SKILL.md`
Canonical reference for reading `.github/prompts.config`: complete key table with types, defaults, and required flags; normalization rules (`BATCH_SIZE` range resolution, boolean parsing, missing key handling); source-of-truth priority. Used by: `doc-planner`, `doc-plan-executor`.

#### `doc-metadata-format/SKILL.md`
Schema and rendering rules for metadata in all pipeline-generated files: required fields (`topics`, `sources`, `generated_at`, `doc_type`), the 6 valid `doc_type` values, rendering per `METADATA_FORMAT` mode, and a validation checklist. Used by: `doc-planner`, `doc-plan-executor`, `clean-transcript`.

#### `doc-output-structure/SKILL.md`
Naming convention (`NN_Name`), domain mapping rules, depth limits (4 levels max), overview file requirements, and source-to-output mapping rules. Used by: `doc-planner`, `doc-plan-executor`.

#### `doc-entrypoint-template/SKILL.md`
Canonical template for `OUTPUT_PATH/ENTRYPOINT` (`SUMMARY.md`): the 11 required sections in order, a full annotated template, a folder `overview.md` template, and a validation checklist. Also documents how `search-doc` uses the entrypoint for navigation. Used by: `doc-plan-executor`, `search-doc`.

### Configuration (`.github/prompts.config`)

Centralized YAML file containing:
- `PROJECT_NAME`: Project name
- `SOURCE_PATHS`: Transcript locations
- `OUTPUT_PATH`: Where to generate documentation
- `LANGUAGE`: Language (e.g., English)
- `DOMAINS`: Main domains/topics
- `BATCH_SIZE`: Files per batch (2-4)
- `TARGET`: Execution environment (e.g., `vscode`)
- `TOOLS`: Available tools (e.g., `read`, `edit`, `search`)

### Folders

#### `transcripts/raw/`
- **Contains**: Raw `.transcript` files
- **Source**: Original recordings/transcriptions
- **Format**: Plain text or formatted
- **Role**: Process starting point

#### `transcripts/clean/`
- **Contains**: Cleaned `.md` files
- **Source**: Transformed from raw files
- **Format**: Structured markdown
- **Role**: Source for documentation generation

#### `docs/`
- **Contains**: Final generated documentation
- **Structure**: Organized by domains and hierarchical sub-folders
- **Format**: Markdown with metadata
- **Role**: Documentation destination (defaults to `/docs/` when `OUTPUT_PATH: /docs`)
- **Flexibility**: First folder level under `OUTPUT_PATH/` is always one folder per configured domain (`DOMAINS[].path`). Inside each domain, the agent can create topic/subtopic sub-folders (up to ~4 nesting levels total).

#### `temp/`
- **Contains**: Progress temporary files
- **Usage**: Batch tracking during processing
- **Format**: Progress files (`agent-progress.md`)
- **Role**: Long operation management

---

## 🚀 Usage

### Complete Workflow

```mermaid
graph LR
    A["Raw Transcripts<br/>/transcripts/raw"] -->|"@clean-transcript"| B["Cleaned Transcripts<br/>/transcripts/clean"]
    B -->|"@doc-planner"| D["Plan Generated<br/>temp/plan.json + temp/plan.md"]
    D -->|"handoff"| E["@doc-plan-executor"]
  E -->|"produces"| F["Documentation<br/>OUTPUT_PATH"]
    F -->|"@search-doc"| G["Answers"]
```

### Step 1: Prepare Raw Transcripts

**Action**: Add transcripts to `/transcripts/raw/`

```
transcripts/raw/
├── KT_1.transcript
├── KT_2.transcript
└── KT_3.transcript
```

**Accepted Format**:
- `.transcript` files (plain text)
- Content: Text transcriptions of meetings/interviews

### Step 2: Clean Transcripts

**Tool**: Cleaning agent `clean-transcript.agent.md`

**VS Code Command**:
```
@clean-transcript
Process the transcript "/transcripts/raw/KT_1.transcript"
```

**Note**: Select **@clean-transcript** agent in Copilot Chat interface

**Output**: Cleaned `.md` files in `/transcripts/clean/`

**Note**: Multiple iterations may be necessary
- Check quality
- Correct omissions
- Refine structure

### Step 3: Verify Cleaned Transcripts

**Action**: Run the validation prompt, then examine files in `/transcripts/clean/`

**Automated gate** — run `@validate-transcripts` to check all files in `SOURCE_PATHS` for metadata completeness, structure, and transcript artifacts before proceeding:
```
@validate-transcripts
```
This prompt is read-only and produces a pass/fail report. Proceed to Step 4 only when all files are ✅ Ready or ⚠️ Needs Revision (minor issues).

```
transcripts/clean/
├── domain1/
│   ├── KT_1.md
│   └── KT_2.md
└── domain2/
    ├── KT_1.md
    └── KT_2.md
```

**Checks**:
- ✅ Correct and complete content
- ✅ Logical structure
- ✅ Metadata present
- ✅ No file corruption

### Step 4: Generate Execution Plan

**Tool**: `doc-planner.agent.md`

**Steps**:
1. Use the planning agent in chat:
  ```
  @doc-planner
  Build the documentation plan from the cleaned transcripts and current configuration.
  ```
2. The agent analyzes source files and creates the complete plan.

**Output**: Complete execution plan in `temp/plan.json` + `temp/plan.md`
- Deterministic batch structure with file groupings
- All execution phases (init + batches + cross-refs + summary + validation)
- Strict execution order
- Progress tracking format

### Step 5: Execute Documentation Plan

**Tool**: `doc-plan-executor.agent.md`

**Steps**:
1. Use the execution agent to execute the plan:
  ```
  @doc-plan-executor
  Execute the documentation plan in temp/plan.json.
  ```

2. The plan executes automatically through all phases:
   - **Phase 0**: Initialization (creates folder structure)
   - **Phases 1-N**: Batch Processing (transforms transcripts by batch)
   - **Phase N+1**: Cross-Reference Resolution (links documents)
   - **Phase N+2**: Summary Generation (creates index and overview)
   - **Phase N+3**: Final Validation (verifies completeness)

3. Progress is tracked continuously with updates

**Output**: Complete documentation in `OUTPUT_PATH/`
- Structured markdown files with metadata
- `OUTPUT_PATH/ENTRYPOINT` (default: `OUTPUT_PATH/SUMMARY.md`) as the single documentation entrypoint
- Entry point includes pages (course order) with topics + description, plus A–Z indexes (pages + topics) and source mapping
- Folder-level `overview.md` files (one per domain/topic/subtopic) when enabled by `CREATE_OVERVIEW_FILES`
- All cross-references resolved
- Validation report confirming completion
- **Hierarchical structure**: Within each domain folder, the agent creates topic/subtopic sub-folders as needed (up to ~4 nesting levels total)

### Step 7: Query Documentation

**Tool**: Search agent `search-doc.agent.md`

**Usage**:
```
@search-doc
"What is [Concept]?"

@search-doc
"How to [Action]?"

@search-doc
"What is the difference between [A] and [B]?"
```

**Responses**:
- ✅ Based ONLY on documentation
- ✅ With citations and sources
- ✅ Indicating limitations
- ✅ Suggestions for related documents

---

## ⚙️ Configuration Details

### File: `.github/prompts.config`

Centralized YAML file containing all project parameters.

### Main Parameters

```yaml
# ========================================
# PROJECT INFORMATION
# ========================================
PROJECT_NAME: My Documentation
AGENT_NAME: doc-plan-executor
AGENT_DESCRIPTION: Agent for transforming transcripts to documentation

# ========================================
# PATHS AND SOURCES
# ========================================
SOURCE_PATHS:
  - /transcripts/clean/1_Domain_1
  - /transcripts/clean/2_Domain_2
OUTPUT_PATH: /docs

# ========================================
# STRUCTURE AND DOMAINS
# ========================================
DOMAINS:
  - name: Domain 1
    path: 1_Domain_1
    description: My awesome domain 1
  - name: Domain 2
    path: 2_Domain_2
    description: My awesome domain 2

LANGUAGE: English
TONE: Professional
AUDIENCE: Technical teams and documentation users

# ========================================
# BATCH PROCESSING
# ========================================
BATCH_SIZE: 2-4  # Files per batch
PROGRESS_FILE: /temp/[agent-name]-progress.md

# ========================================
# AGENT AND TOOLS
# ========================================
TOOLS: [read, edit, search]
TARGET: vscode
```

### How to Modify Configuration

**To change output path**:
```yaml
OUTPUT_PATH: /documentation  # Instead of /docs
```

**To add new domains**:
```yaml
DOMAINS:
  - name: Domain 1
    path: 1_Domain_1
  - name: Domain 2
    path: 2_Domain_2
  - name: New Domain
    path: 3_NewDomain
```

**To change language**:
```yaml
LANGUAGE: English  # Instead of French
```

**To modify batch size**:
```yaml
BATCH_SIZE: 3-5  # Process 3-5 files per batch
```

### Effect of Modifications

Agents and prompts reading from `prompts.config` automatically adapt:
- ✅ `doc-planner.agent.md` analyzes files and creates a plan based on the new structure
- ✅ `doc-plan-executor.agent.md` executes the plan with the new settings
- ✅ `search-doc.agent.md` queries new `OUTPUT_PATH`

**No code modification required!**

---

## 📋 Workflow Summary

| Step | Tool | Action | Output |
|------|------|--------|--------|
| 1 | Manual | Add transcripts | `/transcripts/raw/` |
| 2 | @clean-transcript | Clean transcripts | `/transcripts/clean/` |
| 3 | Manual | Verify quality | ✓ Validation |
| 4 | @doc-planner | Generate plan | `temp/plan.json` + `temp/plan.md` |
| 5 | @doc-plan-executor | Execute plan | `OUTPUT_PATH/` |
| 6 | @search-doc | Query docs | Answers |

---

## 🆘 Help and Support

### Common Issues

**Q: My agent doesn't generate documentation**
A: Verify that `/transcripts/clean/` contains files and that `OUTPUT_PATH` exists in `prompts.config`

**Q: Search returns no results**
A: Ensure documentation was generated in `OUTPUT_PATH/` and that the entrypoint exists at `OUTPUT_PATH/ENTRYPOINT` (default: `OUTPUT_PATH/SUMMARY.md`)

**Q: How do I add new domains?**
A: Edit `DOMAINS` in `.github/prompts.config` and re-run agents

**Q: Can I use the system for another project?**
A: Yes! Configure paths in `prompts.config` and execute agents

---

## 📄 Licenses and Authors

- **Project**: Transcript to Documentation System
- **Generic Agent**: Designed for reusability
- **Based on**: GitHub Copilot Chat

---

**Version**: 1.0 (Generic Release)  
**Date**: 2026  
**Status**: 🚀 Ready
