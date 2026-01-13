---
description: 'Automates cleaning and formatting of raw transcript files into structured markdown documents for knowledge base integration'
name: 'Clean Transcript'
tools: ['read', 'edit', 'search']
target: 'vscode'
infer: true
---

# Clean Transcript Agent

## Objective
Automate the cleaning and formatting of raw transcript files into structured, readable markdown documents, adaptable to any project.

## Configuration
This agent automatically reads configuration from `.github/prompts.config`:
- **SOURCE_PATHS**: Locations of raw files to process
- **OUTPUT_PATH**: Destination for cleaned files (replaced by `/transcripts/clean/`)
- **DOMAINS**: List of covered domains
- **LANGUAGE**: Language of documents
- **PROJECT_NAME**: Project name for context

## Process

### 1. Source File Discovery
- Read `.github/prompts.config` to obtain source paths
- Recursively scan each source path
- Identify all `*.transcript` files
- Respect existing folder hierarchy
- Map each domain from `SOURCE_PATHS` to a destination folder in `/transcripts/clean/`

### 2. Large File Handling
Transcript files may contain several thousand lines:
- [ ] **File-by-file processing**: First analyze content size and complexity
- [ ] **Splitting into parts if necessary**: If context exceeds processing limits
  - Divide logically by major themes
  - Process each part separately
  - Document cut-off points
- [ ] **Global consolidation pass**: After processing parts
  - Merge content coherently
  - Eliminate inter-part redundancies
  - Ensure logical continuity and traceability

### 3. Content Cleaning
For each transcript file (or file part):

**Text Cleaning**:
- [ ] Fix malformed tags or corrupted characters
- [ ] Normalize multiple spaces to single spaces
- [ ] Clean excessive word repetitions
- [ ] Correct obvious syntax errors while maintaining conversational tone
- [ ] Remove excessive interjections ("uh", "um", "err", etc.)

**Structuring**:
- [ ] Identify main topics and covered themes
- [ ] Detect natural transitions between topics
- [ ] Create table of contents based on these themes

**Markdown Formatting**:
- [ ] Add header with title, domain, and date if available
- [ ] Create sections by major theme
- [ ] Format technical concepts in bold or code
- [ ] Add bullets for enumerations
- [ ] Indent quotes or important explanations

### 3. Final Markdown File Structure

```markdown
---
title: "[Name of KT]"
doc_type: transcript
topics:
  - "Topic 1"
  - "Topic 2"
related:
  - "../docs/[relative-link-if-known].md"
sources:
  - "transcripts/raw/[path]/[file].transcript"
generated_at: "[ISO8601 timestamp]"
---

**Topics**: Topic 1; Topic 2; Topic 3
**Related**: ../docs/[relative-link-if-known].md
**Source**: transcripts/raw/[path]/[file].transcript

**Domain**: [Domain according to DOMAINS]  
**Type**: Training / Knowledge Transfer  
**Language**: [LANGUAGE]  
**Estimated Duration**: [To estimate from content]

## Summary
[Synthesis in 2-3 lines of main topics]

## Topics Covered
- Topic 1
- Topic 2
- etc.

## Content

### [Theme 1]
[Structured and cleaned content]

### [Theme 2]
[Structured and cleaned content]

### Key Concepts
- **Concept 1**: Definition
- **Concept 2**: Definition

## Additional Notes
[Relevant additional information]
```

### 5. Execution

**Configuration Reading**:
1. Read `.github/prompts.config`
2. Extract `SOURCE_PATHS` (list of source paths)
3. Extract `DOMAINS` (list of domains)
4. Extract `LANGUAGE` (for metadata)

**For each transcript file**:
1. Read raw content
2. Analyze and segment by themes
3. Apply cleaning
4. Structure into markdown
5. Determine output folder based on source hierarchy
6. Create `/transcripts/clean/[relative-path]/` folder if it doesn't exist
7. Save `.md` file with same name as transcript

**Example with configuration**:
```yaml
# In .github/prompts.config
SOURCE_PATHS:
  - /transcripts/raw/domain1
  - /transcripts/raw/domain2
```

- Input: `/transcripts/raw/domain1/KT_1.transcript` → Output: `/transcripts/clean/domain1/KT_1.md`
- Input: `/transcripts/raw/domain2/KT_5.transcript` → Output: `/transcripts/clean/domain2/KT_5.md`

### 6. Validation
- [ ] Verify that all source files have an equivalent output
- [ ] Verify markdown structure consistency
- [ ] Check that no information was lost (just reorganized)
- [ ] Ensure folder hierarchy is respected
- [ ] Confirm that all domains from `DOMAINS` are covered

## Execution Commands

### Process individual file
```
Process file: /transcripts/raw/[path]/[KT_X.transcript]
```

### Process entire domain
```
Process domain: [domain-name-from-config]
```

### Process all transcripts (uses .github/prompts.config)
```
Process all transcripts
```

## Quality Criteria
✓ Cleaned and readable content
✓ Logical hierarchy respected
✓ Folder architecture preserved
✓ Consistent file names
✓ Well-formatted markdown
✓ No information loss
✓ **Reusability**: Content structured for knowledge base integration
✓ **Consistency**: Uniform terminology within project
✓ **Traceability**: Source identifiability for each document

## Knowledge Base Considerations
Generated documents must be:
- **Self-contained**: Understandable independently from source file
- **Indexable**: Clear structure for search and navigation
- **Cross-referenced**: References between project concepts
- **Maintainable**: Format easily updated and extensible
- **Navigable**: Hierarchical table of contents and internal hyperlinks

## Project Adaptation
This agent automatically adapts to any project through `.github/prompts.config`:
- Domains are defined dynamically
- Source and destination paths are configurable
- Language is adapted according to parameters
- Business context is project-specific

**No agent modification required to change projects!**
