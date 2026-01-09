---
description: 'Template for creating documentation transformation agents'
usage: 'Customize the variables and use this prompt to create agent files for different projects'
---

# Documentation Transformation Agent Generator

Generic prompt for creating agents that transform source content into structured, organized documentation.

## How to Use in Copilot Chat

**Configuration-Based Approach** - All parameters are read from `.github/prompts.config`.

### Step 1: Configure Your Project

Edit [.github/prompts.config](../.github/prompts.config) with your project parameters:

```yaml
PROJECT_NAME: Your Project Name
AGENT_NAME: your-agent-name
SOURCE_PATHS:
  - /path/to/source1
  - /path/to/source2
OUTPUT_PATH: /output/path
LANGUAGE: Français
... etc
```

### Step 2: Call the Prompt

Simply call the prompt without parameters - it reads the config file automatically:

```
@workspace /using #file:generic-doc-transformation-agent.prompt.md crée l'agent
```

The prompt will:
1. **Read `.github/prompts.config`** to get all parameters
2. **Validate configuration** - ensure all required fields are present
3. **Generate complete agent file** with all features configured
4. **Save to** `.github/agents/[AGENT_NAME].agent.md`

## Configuration-Based Workflow

When you call this prompt, it will:

1. **Read `.github/prompts.config`** - Load all project parameters from config file
2. **Validate configuration** - Check all required fields are present and valid
3. **Scan source files** - List and analyze files from configured SOURCE_PATHS
4. **Generate agent structure** - Create complete `.agent.md` file with YAML frontmatter
5. **Add batch processing** - Include automatic batch strategy based on file analysis
6. **Configure progress tracking** - Set up progress file from PROGRESS_FILE setting
7. **Apply best practices** - Include all configured SPECIAL_REQUIREMENTS and ADDITIONAL_FEATURES
8. **Create complete agent** - Ready-to-use agent file in `.github/agents/[AGENT_NAME].agent.md`

### Configuration File Structure

The `prompts.config` file must contain these sections:
- **Project Configuration**: PROJECT_NAME, AGENT_NAME, AGENT_DESCRIPTION
- **Source Configuration**: SOURCE_PATHS, SOURCE_FORMAT, SOURCE_DESCRIPTION
- **Output Configuration**: OUTPUT_PATH, OUTPUT_FORMAT
- **Domain Configuration**: DOMAINS (optional - can be auto-detected)
- **Language & Style**: LANGUAGE, TONE, AUDIENCE
- **Processing Configuration**: BATCH_SIZE, PROGRESS_FILE, AUTO_BATCH
- **Quality Requirements**: SPECIAL_REQUIREMENTS, ADDITIONAL_FEATURES

## Configuration Reference

All parameters are defined in `.github/prompts.config`:

### Required Configuration Sections

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

### Optional Configuration Sections

**Domain Configuration**
- `DOMAINS`: List of content domains with metadata (auto-detected if omitted)

**Processing Configuration**
- `BATCH_SIZE`: Files per batch (default: 2-4)
- `PROGRESS_FILE`: Progress tracking location
- `AUTO_BATCH`: Enable automatic batch detection

**Quality Requirements**
- `SPECIAL_REQUIREMENTS`: List of special constraints or requirements
- `ADDITIONAL_FEATURES`: Extra features to include

**Execution Configuration**
- `EXECUTION_MODE`: sequential_batches, parallel, etc.
- `VALIDATION_ENABLED`: true/false
- `AUTO_CROSS_REFERENCE`: true/false
- `GENERATE_SUMMARY`: true/false

## How the Prompt Processes Configuration

When you call this prompt, it executes these steps:

### 1. Load Configuration
- Read `.github/prompts.config` file
- Parse all configuration sections
- Validate required fields are present
- Apply defaults for optional fields
- Report any missing or invalid configuration

### 2. Analyze Source Files
- Scan all directories in `SOURCE_PATHS`
- List and count files
- Estimate file sizes and complexity
- Detect natural groupings from folder structure
- Use `DOMAINS` config if provided, otherwise auto-detect

### 3. Calculate Batch Strategy
- If `AUTO_BATCH: true`, calculate optimal batches
- Group files by domain and size
- Apply `BATCH_SIZE` setting (default 2-4 files)
- Generate intelligent batch names
- Estimate total execution time

### 4. Generate Agent Structure
- Create YAML frontmatter from config (name, description, tools, model)
- Build instructions using `LANGUAGE`, `TONE`, and `AUDIENCE` settings
- Add all `SPECIAL_REQUIREMENTS`
- Include all `ADDITIONAL_FEATURES`
- Set up batch processing workflow
- Configure progress tracking to `PROGRESS_FILE`

### 5. Add Documentation Templates
- Define output document structure
- Include metadata templates
- Set up cross-reference patterns based on `AUTO_CROSS_REFERENCE`
- Add validation criteria based on `VALIDATION_ENABLED`

### 6. Create Agent File
- Write complete `.agent.md` to `.github/agents/[AGENT_NAME].agent.md`
- Include all configured sections and workflows
- Ready for immediate use with `@[AGENT_NAME]`

## Generated Agent Template

Based on the parameters provided by the user, generate an agent file with this structure:

```yaml
---
description: '[Agent Description from parameters]'
name: '[Agent Name from parameters]'
tools:
  - read
  - edit
  - search
model: claude-sonnet-4.5
target: vscode
infer: false
---

# [Agent Name] Agent

## Purpose

Transform source files from [Source Path] into structured [Output Format] documentation in [Output Path].

## Language Requirements

🇫🇷 **[Language from Special Requirements, default: French]**

All generated documentation MUST be in [Language]. This includes:
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
- **Index**: `summary.md` (or equivalent) at root

## Domain Organization

[If Domain Groups provided, list them. Otherwise state: "Auto-detect domains from source files"]

## Batch Processing Strategy

⚠️ **Critical**: Source files may be long. Process in batches to avoid context window overflow.

### Batch Configuration

- **Batch Size**: 2-4 files per batch (adjust based on file sizes)
- **Total Batches**: [Auto-calculated based on file count]
- **Progress Tracking**: `/temp/[agent-name]-progress.md`

### Batch Processing Workflow

**Step 0: Initialize**
1. Scan [Source Path] and list all source files
2. Analyze file sizes and natural groupings
3. Create batch plan (2-4 files per batch)
4. Create `/temp/[agent-name]-progress.md` with batch list
5. Create base [Output Path] directory structure

**Step 1-N: Process Each Batch**
For each batch:
1. Read batch source files
2. Analyze and structure content
3. Create organized documentation files in [Output Path]
4. Use TBD placeholders for cross-batch references: `[TBD: reference to Batch X]`
5. Update progress file with completion status

**Step N+1: Cross-Reference Resolution**
1. Review all generated documentation
2. Replace all `[TBD: ...]` placeholders with actual cross-references
3. Ensure all internal links are valid

**Step N+2: Generate Summary**
1. Create `summary.md` at [Output Path] root
2. Include hierarchical index of all documentation
3. Add navigation and discovery aids

**Step N+3: Validation**
1. Verify all source files processed
2. Check all cross-references resolved
3. Validate documentation structure
4. Confirm [Language] consistency

## Document Structure Template

Each generated document should follow:

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

✅ **Human-Readable**
- Clear headings and structure
- Natural language flow
- Appropriate detail level

✅ **AI-Optimized**
- Rich metadata for discovery
- Consistent terminology
- Clear semantic structure
- Cross-references and relationships

✅ **Well-Organized**
- Logical hierarchy (2-4 levels)
- Coherent grouping by topic/domain
- Intuitive navigation
- Comprehensive index

## Additional Features

[Include Additional Features from parameters, or standard features like:]
- Cross-document references
- Search optimization keywords
- Version/update tracking
- Source traceability

## Special Requirements

[Include Special Requirements from parameters]

## Execution Instructions

To use this agent:

1. Ensure source files exist at [Source Path]
2. Call this agent to initialize and create batch plan
3. Process each batch sequentially
4. Resolve cross-references after all batches complete
5. Generate summary index
6. Validate final documentation

Progress tracking in `/temp/[agent-name]-progress.md` allows resuming if interrupted.
```

## Benefits of Configuration-Based Approach

✅ **No repetition** - Configure once, reuse many times
✅ **Version controlled** - Config file tracked in Git with your code
✅ **Team collaboration** - Share same configuration across team
✅ **No typos** - Edit file carefully once, no chat input errors
✅ **Instant agent creation** - Just call the prompt, no parameters needed
✅ **Easy updates** - Change config file to update agent behavior
✅ **Complete** - All features auto-configured from one source
✅ **Documented** - Config file serves as project documentation
✅ **Consistent** - Same config used by all related prompts

## Quick Start Examples

### Example 1: Knowledge Base

**Edit `.github/prompts.config`:**
```yaml
PROJECT_NAME: Internal Knowledge Base
AGENT_NAME: build-kb
AGENT_DESCRIPTION: Transform raw knowledge articles into organized knowledge base
SOURCE_PATHS:
  - /raw-knowledge
SOURCE_FORMAT: markdown
SOURCE_DESCRIPTION: Unstructured articles and internal docs
OUTPUT_PATH: /knowledge-base
OUTPUT_FORMAT: markdown
DOMAINS:
  - name: Product Docs
  - name: API Guides
  - name: Best Practices
  - name: Troubleshooting
ADDITIONAL_FEATURES:
  - Search keywords
  - Cross-domain linking
  - Version tracking
```

**Call the prompt:**
```
@workspace /using #file:generic-doc-transformation-agent.prompt.md crée l'agent
```

### Example 2: Technical Documentation

**Edit `.github/prompts.config`:**
```yaml
PROJECT_NAME: Technical Documentation
AGENT_NAME: generate-tech-docs
AGENT_DESCRIPTION: Convert code docs into structured technical documentation
SOURCE_PATHS:
  - /source-code-docs
SOURCE_FORMAT: markdown with code snippets
SOURCE_DESCRIPTION: Technical specifications and API documentation
OUTPUT_PATH: /technical-docs
OUTPUT_FORMAT: markdown
SPECIAL_REQUIREMENTS:
  - Code examples with syntax highlighting
ADDITIONAL_FEATURES:
  - Dependency diagrams
  - API endpoint tables
```

**Call the prompt:**
```
@workspace /using #file:generic-doc-transformation-agent.prompt.md crée l'agent
```

### Example 3: Meeting Notes Wiki

**Edit `.github/prompts.config`:**
```yaml
PROJECT_NAME: Meeting Notes Wiki
AGENT_NAME: transform-meetings
AGENT_DESCRIPTION: Organize meeting notes into searchable wiki
SOURCE_PATHS:
  - /meetings/raw
SOURCE_FORMAT: unstructured text
SOURCE_DESCRIPTION: Meeting notes with decisions and action items
OUTPUT_PATH: /wiki
OUTPUT_FORMAT: markdown
SPECIAL_REQUIREMENTS:
  - Highlight decisions and action items
ADDITIONAL_FEATURES:
  - Timestamp tracking
  - Attendee lists
  - Decision log
```

**Call the prompt:**
```
@workspace /using #file:generic-doc-transformation-agent.prompt.md crée l'agent
```

## Implementation Guide

### Step 1: Define Your Project

Before calling the prompt, identify:

1. **Agent Identity**
   - What is the primary purpose?
   - How should it be named?
   - Who will use it?

2. **Source Material**
   - File location and path pattern
   - File format and structure
   - Content type and volume
   - Number of files

3. **Output Structure**
   - Destination directory
   - Output format(s)
   - Domain/category structure
   - Desired hierarchy depth

4. **Special Considerations**
   - Language requirements
   - Tone/style preferences
   - Metadata needs
   - Cross-reference patterns

### Step 2: Call the Prompt

Simply call the prompt - it reads configuration automatically:

```
@workspace /using #file:generic-doc-transformation-agent.prompt.md crée l'agent
```

The prompt will:
- Read all parameters from `.github/prompts.config`
- Validate configuration completeness
- Scan source files
- Generate complete agent file

### Step 3: Review Generated Agent

The prompt creates `.github/agents/[AGENT_NAME].agent.md` with:
- Complete YAML frontmatter from config
- Comprehensive instructions
- Batch processing strategy
- Progress tracking system (from PROGRESS_FILE config)
- Quality standards (from SPECIAL_REQUIREMENTS)
- Execution workflow

### Step 4: Use with create-prompt

To generate execution prompts, just call create-prompt - it also reads the config:

```
@workspace /using #file:create-prompt.prompt.md génère les prompts
```

No parameters needed - everything comes from `prompts.config`.

## Complete Workflow Example

### Step A: Create Custom Agent

```
@workspace /using #file:generic-doc-transformation-agent.prompt.md crée un agent avec :
- Agent Name: create-docs
- Agent Description: Transform KT transcripts into structured documentation
- Source Path: /transcripts/clean
- Source Format: markdown with metadata
- Source Description: Knowledge transfer transcripts (15 files)
- Output Path: /docs
- Output Format: markdown
- Domain Groups: OIA (5 files), Agefiph (10 files)
- Special Requirements: French language, AI-optimized
- Additional Features: Cross-references, summary index
```

**Result**: `.github/agents/create-docs.agent.md` created

### Step B: Generate Execution Prompts

```
@workspace /using #file:create-prompt.prompt.md génère les prompts pour :
- Agent Name: create-docs
- Source Path: /transcripts/clean
- Output Path: /docs
```

**Result**: 9 ready-to-execute prompts (Initialize + 6 Batches + Cross-refs + Summary + Validation)

### Step C: Execute Generated Prompts

Copy and execute each prompt sequentially in Copilot Chat with the new `@create-docs` agent.

## Workflow Diagram

```
┌────────────────────────────────────┐
│ Step 1: Define Project Parameters      │
└──────────────────┬─────────────────┘
                   │
                   ↓
┌──────────────────┴─────────────────┐
│ Call generic-doc-transformation-agent  │
│ with parameters in chat                │
└──────────────────┬─────────────────┘
                   │
                   ↓
┌──────────────────┴─────────────────┐
│ Agent file created automatically       │
│ (.github/agents/[name].agent.md)       │
└──────────────────┬─────────────────┘
                   │
                   ↓
┌──────────────────┴─────────────────┐
│ Call create-prompt with same params    │
│ to generate execution prompts          │
└──────────────────┬─────────────────┘
                   │
                   ↓
┌──────────────────┴─────────────────┐
│ Execute prompts one by one with        │
│ your custom @agent                     │
└──────────────────┬─────────────────┘
                   │
                   ↓
┌──────────────────┴─────────────────┐
│ Complete documentation generated!      │
└────────────────────────────────────┘
```

---

## Real-World Example: create-docs Agent

### Interactive Call Used

```
@workspace /using #file:generic-doc-transformation-agent.prompt.md crée un agent avec :
- Agent Name: create-docs
- Agent Description: Transform KT transcripts into structured documentation
- Source Path: /transcripts/clean
- Source Format: markdown with metadata
- Source Description: Knowledge transfer transcripts (15 files across 2 domains)
- Output Path: /docs
- Output Format: markdown
- Domain Groups: OIA (5 files), Agefiph (10 files)
- Special Requirements: French language, AI-optimized structure
- Additional Features: Summary.md index, cross-references, batch processing
```

### Generated Agent Features

The prompt automatically created an agent with:
- ✅ Complete batch processing strategy (7 batches)
- ✅ Progress tracking in `/temp/create-docs-progress.md`
- ✅ French language enforcement throughout
- ✅ Human and AI-optimized structure
- ✅ Cross-reference management with TBD placeholders
- ✅ 5-step execution workflow
- ✅ Quality validation criteria
- ✅ Document structure templates

### Follow-up with create-prompt

After agent creation, execution prompts were generated:

```
@workspace /using #file:create-prompt.prompt.md génère les prompts pour :
- Agent Name: create-docs
- Source Path: /transcripts/clean
- Output Path: /docs
```

**Result**: 9 ready-to-execute prompts automatically generated

---

## More Ready-to-Use Examples

### Template 1: Knowledge Base Builder

```
@workspace /using #file:generic-doc-transformation-agent.prompt.md crée un agent avec :
- Agent Name: build-knowledge-base
- Agent Description: Transform raw articles into organized knowledge base
- Source Path: /raw-knowledge
- Source Format: markdown articles
- Source Description: Unstructured knowledge articles and internal documentation
- Output Path: /knowledge-base
- Output Format: markdown
- Domain Groups: Product Docs, API Guides, Best Practices, Troubleshooting
- Additional Features: Search keywords, cross-domain linking, version tracking
```

### Template 2: Technical Documentation

```
@workspace /using #file:generic-doc-transformation-agent.prompt.md crée un agent avec :
- Agent Name: generate-tech-docs
- Agent Description: Convert code docs into structured technical documentation
- Source Path: /source-code-docs
- Source Format: markdown with inline code comments
- Source Description: Code documentation and technical specifications
- Output Path: /technical-docs
- Output Format: markdown
- Domain Groups: Architecture, Core Concepts, API Reference, Examples, Best Practices
- Special Requirements: Code examples with syntax highlighting
- Additional Features: Dependency diagrams, API endpoint tables
```

### Template 3: Meeting Notes to Wiki

```
@workspace /using #file:generic-doc-transformation-agent.prompt.md crée un agent avec :
- Agent Name: transform-meeting-notes
- Agent Description: Organize meeting notes into searchable wiki
- Source Path: /meetings/raw
- Source Format: unstructured meeting notes
- Source Description: Meeting notes with decisions and action items
- Output Path: /wiki
- Output Format: markdown
- Domain Groups: By Team, By Project, By Topic, Decision Log
- Special Requirements: Highlight decisions and action items
- Additional Features: Timestamp preservation, attendee lists, decision tracking
```

### Template 4: FAQ Generator

```
@workspace /using #file:generic-doc-transformation-agent.prompt.md crée un agent avec :
- Agent Name: generate-faq
- Agent Description: Convert support tickets into FAQ documentation
- Source Path: /support-tickets
- Source Format: support ticket summaries
- Source Description: Common support questions and solutions
- Output Path: /faq
- Output Format: markdown
- Domain Groups: By Product, By Category, Troubleshooting, Getting Started
- Special Requirements: Clear Q&A format, numbered solution steps
- Additional Features: Search-optimized tags, related FAQ links, update frequency
```

---

## Best Practices

### 1. Before Creating Agent
- 📁 Examine 2-3 source files to understand structure
- 📊 Identify natural groupings and themes
- 📏 Note recurring patterns in content
- 📝 Sketch desired documentation hierarchy

### 2. When Providing Parameters
- ✅ Use absolute paths for Source Path and Output Path
- ✅ Be specific about source content description
- ✅ List Domain Groups if you know them (or let auto-detect)
- ✅ Specify language in Special Requirements if not French
- ✅ Mention any unique formatting needs

### 3. Agent Design Principles
- 🎯 **Focused hierarchy**: 2-4 nesting levels maximum
- 🔗 **Clear relationships**: Cross-references between related docs
- 🔍 **Search-optimized**: Rich metadata and consistent terminology
- 📚 **Human-friendly**: Natural language flow with clear structure
- 🤖 **AI-ready**: Semantic structure for agent discovery

### 4. Batch Processing
- For 10+ source files, batch processing is auto-included
- Optimal batch size: 2-4 files (auto-calculated)
- Progress tracking always included in `/temp/`
- TBD placeholders for cross-batch references

### 5. Quality Validation
- Review generated agent file before using
- Test with one batch first, validate output
- Adjust batch size if context issues occur
- Verify language consistency in output

## Simplified Workflow

### Single-Command Agent Creation

1. **Call prompt with parameters** → Agent file created
2. **Call create-prompt** → Execution prompts generated  
3. **Execute prompts** → Documentation generated

That's it! No manual editing, no configuration files, no complex setup.

### When to Refine

After initial use, refine the agent if:
- Batch sizes need adjustment (too many/few files per batch)
- Output structure doesn't match expectations
- Additional features are needed
- Language or formatting issues arise

Simply describe what to change, and the agent can be updated.
```

---

## File Naming Conventions

- Agent files: `agent-name.agent.md` (lowercase with hyphens)
- Prompt files: `agent-name.prompt.md`
- Progress files: `/temp/agent-name-progress.md`
- Generated docs: Lowercase with hyphens in `/docs/` directory

## Additional Resources

- [GitHub Copilot Agent Guidelines](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents)
- Markdown formatting standards (see `.github/instructions/markdown.instructions.md`)
- Agent creation guidelines (see `.github/instructions/agents.instructions.md`)
