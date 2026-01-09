---
description: 'Interactive prompt generator for batch-based documentation transformation execution'
usage: 'Pass project parameters directly in chat - no file editing needed. Agent auto-determines batch structure.'
---

# Batch Execution Prompt Generator (Interactive)

Generalized interactive template for generating sequential prompts to execute documentation transformation agents with auto-calculated batch processing.

## How to Use in Copilot Chat

**Configuration-Based Approach** - All parameters are read from `.github/prompts.config`.

### Simple Command

Just call the prompt - it reads everything from the config file:

```
@[AGENT_NAME] génère les prompts d'exécution
```

**Example**:
```
@create-docs génère les prompts d'exécution
```

### What Happens Automatically

The prompt will:
1. **Read `.github/prompts.config`** - Load all project configuration
2. **Scan source directories** - List all files from SOURCE_PATHS
3. **Analyze file sizes** - Determine optimal batch structure
4. **Group files intelligently** - 2-4 files per batch, by domain
5. **Calculate total batches** - Based on file count and BATCH_SIZE config
6. **Generate all prompts** - Init + batches + cross-refs + summary + validation
7. **Display execution plan** - Complete batch breakdown
8. **Provide ready-to-copy prompts** - In execution order

---

## Configuration-Based Workflow

When you call this prompt, it will:

### 1. Load Configuration from `.github/prompts.config`
- Read AGENT_NAME, PROJECT_NAME
- Load SOURCE_PATHS (can be multiple directories)
- Get OUTPUT_PATH and LANGUAGE settings
- Read PROGRESS_FILE location
- Apply BATCH_SIZE and DOMAINS configuration

### 2. Scan and Analyze Sources
- List all files in configured SOURCE_PATHS
- Calculate file sizes and estimate complexity
- Identify natural domain groupings (use DOMAINS config or auto-detect)
- Count total files to process

### 3. Auto-Create Batch Structure
- Group files by domain and size
- Create batches of configured BATCH_SIZE (default: 2-4 files)
- Generate intelligent batch names based on domain and content
- Calculate total number of batches needed
- Estimate execution time

### 4. Generate All Execution Prompts
- **Prompt 0**: Initialization (create progress file, setup structure)
- **Prompts 1-N**: One per batch with specific files
- **Prompt N+1**: Cross-reference resolution
- **Prompt N+2**: Summary generation
- **Prompt N+3**: Final validation

### 5. Display Complete Execution Plan
- Show batch breakdown with file assignments
- List all prompts in execution order
- Provide ready-to-copy prompt text
- Include estimated timing

---

## Configuration File Reference

All parameters come from `.github/prompts.config`:

### Used Configuration Sections

**Project & Agent**
- `PROJECT_NAME`: Project identifier
- `AGENT_NAME`: Agent to use for execution (@agent-name)
- `AGENT_DESCRIPTION`: Purpose description

**Source & Output**
- `SOURCE_PATHS`: List of source directories to scan
- `OUTPUT_PATH`: Destination for generated documentation
- `LANGUAGE`: Documentation language

**Processing**
- `PROGRESS_FILE`: Progress tracking file location
- `BATCH_SIZE`: Target files per batch (e.g., "2-4 files per batch")
- `AUTO_BATCH`: Enable/disable auto-batch detection

**Domains** (optional)
- `DOMAINS`: Pre-defined domain structure with names and paths
- If not provided, domains are auto-detected from folder structure

### Auto-Detected Information

The prompt automatically determines:
- **Total files**: Counts all files in SOURCE_PATHS
- **File sizes**: Analyzes to optimize batch sizes
- **Domain groupings**: Uses DOMAINS config or auto-detects from folders
- **Batch names**: Creates from domain names + content hints
- **Batch structure**: Groups files according to BATCH_SIZE config
- **Total batches**: Calculates based on files and optimal grouping

---

## How the Agent Processes Parameters

### Step 1: Scan and Analyze Sources
The agent receives source paths from chat and:
- Lists all files in specified directories (recursively)
- Checks file sizes and estimates processing complexity
- Groups files by directory structure (auto-detects domains)
- Identifies file naming patterns (e.g., KT_1, KT_2, etc.)

### Step 2: Auto-Create Batch Structure
- **Batch size calculation**: Aims for 2-4 files per batch
- **Domain-based grouping**: Keeps related files together
- **Intelligent naming**: Uses folder names + content hints (e.g., "OIA Fundamentals", "Agefiph Portals")
- **Sequential ordering**: Orders batches logically (fundamentals → advanced)
- **Total batch count**: `total_files / 3` (average) with adjustments

Example auto-batching:
```
Source: /transcripts/clean/1_OIA/ (5 files), /transcripts/clean/2_Agefiph/ (10 files)

Auto-detected batches:
1. OIA Basics (KT_1, KT_2)
2. OIA Advanced (KT_3, KT_4, KT_5)
3. Agefiph Foundation (KT_1, KT_2, KT_3)
4. Agefiph Features (KT_4, KT_5, KT_6)
5. Agefiph Workflows (KT_7, KT_8, KT_9, KT_10)

Total: 5 batches
```

### Step 3: Calculate Structure
- **Number of prompts** = [AUTO_BATCH_COUNT] + 3 (init + cross-refs + summary + validation)
- **Total batches** = Calculated from file analysis
- **Batch names** = Auto-generated from content/location
- **Progress file** = Default or custom path

### Step 4: Generate All Prompts
For each auto-created batch:
1. Batch-specific prompt with exact file paths
2. Domain-appropriate folder structure
3. Cross-batch reference placeholders
4. Estimated processing time per batch

### Step 5: Display Execution Plan
Shows complete plan including:
- Total files discovered
- Auto-created batch breakdown
- Batch sequence with file assignments
- Estimated total execution time
- File structure that will be created

---

## Prompt Output Structure

After calling this prompt, the agent returns:

### Part 1: Execution Plan Summary
```
PROJECT EXECUTION PLAN
======================
Project: [PROJECT_NAME]
Agent: @[AGENT_NAME]
Language: [LANGUAGE]

Total Batches: [N]
Total Prompts: [N+3]
Estimated Time: ~[TIME] hours

Batch Sequence:
1. [Batch Name] - [Files] → [Output folders]
2. [Batch Name] - [Files] → [Output folders]
...
```

### Part 2: Ready-to-Copy Prompts
Sequential prompts labeled:
- `00-initialize.prompt.md`
- `01-batch-1.prompt.md`
- `02-batch-2.prompt.md`
- ... etc
- `[N]-cross-references.prompt.md`
- `[N+1]-summary.prompt.md`
- `[N+2]-validation.prompt.md`

Each prompt is complete and ready to paste into chat.

### Part 3: Usage Instructions
```
## Execution Steps

1. Copy "00-initialize.prompt.md" content
2. Paste into chat with @[AGENT_NAME] at the start
3. Wait for completion
4. Copy "01-batch-1.prompt.md" content
5. Paste into chat
6. Wait for completion
... repeat until final validation
```

---

## Real-World Example in Chat

### Configuration File

The `.github/prompts.config` contains:
```yaml
PROJECT_NAME: Agefiph Documentation
AGENT_NAME: create-docs
SOURCE_PATHS:
  - /transcripts/clean/1_OIA
  - /transcripts/clean/2_Agefiph
OUTPUT_PATH: /docs
LANGUAGE: Français
BATCH_SIZE: 2-4 files per batch
PROGRESS_FILE: /temp/create-docs-progress.md
DOMAINS:
  - name: OIA
    path: 1_OIA
    file_count: 5
  - name: Agefiph
    path: 2_Agefiph
    file_count: 10
```

### User Command

Simply call:
```
@create-docs génère les prompts d'exécution
```

### Agent Output

**SCANNING SOURCE FILES...**
```
Scanning: /transcripts/clean/1_OIA/
Found: KT_1.md, KT_2.md, KT_3.md, KT_4.md, KT_5.md (5 files)

Scanning: /transcripts/clean/2_Agefiph/
Found: KT_1.md, KT_2.md, KT_3.md, KT_4.md, KT_5.md, KT_6.md, KT_7.md, KT_8.md, KT_9.md, KT_10.md (10 files)

Total files: 15
```

**AUTO-CREATING BATCH STRUCTURE...**
```
Analyzing content and grouping files...

Batch 1 - OIA Fundamentals: KT_1.md, KT_2.md from 1_OIA/
Batch 2 - OIA Connectors: KT_3.md, KT_4.md from 1_OIA/
Batch 3 - OIA Advanced: KT_5.md from 1_OIA/
Batch 4 - Agefiph Business Context: KT_1.md, KT_2.md, KT_3.md from 2_Agefiph/
Batch 5 - Agefiph Portals: KT_4.md, KT_5.md, KT_6.md from 2_Agefiph/
Batch 6 - Agefiph Workflows: KT_7.md, KT_8.md, KT_9.md, KT_10.md from 2_Agefiph/

Total batches: 6
```

**PROJECT EXECUTION PLAN**
```
Project: Agefiph Documentation
Agent: @create-docs
Language: Français
Source files: 15 (across 2 domains)

Total Batches: 6 (auto-generated)
Total Prompts: 9 (1 init + 6 batches + 1 cross-refs + 1 summary + 1 validation)
Estimated Time: ~1.5 hours

Batch Breakdown:
1. OIA Fundamentals - 2 files → /docs/1_OIA/fundamentals/
2. OIA Connectors - 2 files → /docs/1_OIA/connectors/
3. OIA Advanced - 1 file → /docs/1_OIA/advanced/
4. Agefiph Context - 3 files → /docs/2_Agefiph/business-context/
5. Agefiph Portals - 3 files → /docs/2_Agefiph/portals/
6. Agefiph Workflows - 4 files → /docs/2_Agefiph/workflows/
```

Then, ready-to-use prompts for each step...

---

## Benefits of Config-Based Auto-Batch Approach

✅ **No configuration in chat** - Everything from `prompts.config`
✅ **Zero manual planning** - No need to decide batch structure
✅ **Intelligent grouping** - Files grouped by domain and complexity
✅ **Optimal batch sizes** - Auto-calculated from BATCH_SIZE config
✅ **Smart naming** - Batch names reflect actual content
✅ **Flexible** - Works with any number of source files
✅ **Consistent** - Same logic applied across all projects
✅ **Version controlled** - Config file in Git with your project
✅ **Copy-paste ready** - Each prompt ready to use immediately
✅ **Transparent** - See complete execution plan before starting
✅ **Team-friendly** - Share same config across team members
✅ **Reusable** - Update config file to change behavior

---

## Tips for Best Results

### 1. Organize Batches Logically
Group related source files in each batch:
```
✓ Good:
- Batch 1: KT_1, KT_2 (related fundamentals)
- Batch 2: KT_3, KT_4 (related advanced)

✗ Avoid:
- Batch 1: KT_1, KT_3, KT_5 (random files)
```

### 2. Name Batches Clearly
Use descriptive names that reflect content:
```
✓ Good: "OIA Fundamentals", "Agefiph Portals"
✗ Avoid: "Batch 1", "Set A"
```

### 3. Provide Exact Paths
Be precise with source file locations:
```
✓ Good: "KT_1, KT_2 from /transcripts/clean/1_OIA/"
✗ Avoid: "some files from transcripts"
```

### 4. Set Realistic Batch Sizes
2-4 files per batch for optimal context usage:
```
✓ Good: 2-4 source files
✗ Avoid: 10+ files per batch
```

### 5. Use Consistent Naming
Keep batch naming style consistent:
```
✓ Good: "Domain TopicGroup", "Feature Area"
✗ Avoid: "FirstBatch", "Stuff", "more things"
```

---

## Advanced Usage

### Multiple Projects

Simply call the prompt multiple times with different parameters:

```
First call: @create-docs with Agefiph batches
... get prompts and execute
... complete Project 1

Second call: @build-wiki with WikiProject batches
... get prompts and execute
... complete Project 2
```

### Batch Modification During Execution

If you need to add/remove batches:
1. Note where execution stopped
2. Call prompt again with modified batch list
3. Agent skips already-completed batches
4. Resumes from where you left off

### Custom Progress Tracking

Specify your own progress file path:
```
Fichier suivi: /custom/path/my-progress.md
```

Or use default:
```
Fichier suivi: (default: /temp/[AGENT_NAME]-progress.md)
```

---

## Troubleshooting

### Issue: "Too many batches"
**Solution**: The agent didn't count correctly
- Recount your batch list
- Ensure each batch is on a new line
- Try again with exact same format

### Issue: "Can't find source files"
**Solution**: Path mismatch
- Verify source paths in parameters
- Use absolute paths, not relative
- Check file names are exact

### Issue: "Output directory doesn't exist"
**Solution**: Agent didn't create it
- Manually create the directory first
- Or request agent creates it in Step 0

### Issue: "Prompts look incomplete"
**Solution**: Agent may have hit length limits
- Try with fewer batches (split into 2 projects)
- Request one batch at a time if needed

---

## File Organization After Execution

After all batches complete and validation finishes:

```
.github/prompts/
├── generic-doc-transformation-agent.prompt.md    # Template
├── create-doc-agent.prompt.md                     # Agent definition
├── create-prompt.prompt.md                        # This file
├── 00-initialize.prompt.md                        # From this run
├── 01-batch-1-fundamentals.prompt.md
├── 02-batch-2-connectors.prompt.md
├── 03-batch-3-advanced.prompt.md
├── 04-batch-4-context.prompt.md
├── 05-batch-5-portals.prompt.md
├── 06-batch-6-workflows.prompt.md
├── 07-cross-references.prompt.md
├── 08-summary.prompt.md
└── 09-validation.prompt.md

/temp/
└── create-docs-progress.md                        # Tracking file

/docs/
├── summary.md
├── 1_OIA/
│   ├── overview.md
│   ├── fundamentals/
│   ├── connectors/
│   ├── advanced/
│   └── reference/
└── 2_Agefiph/
    ├── overview.md
    ├── business-context/
    ├── portals/
    ├── workflows/
    └── reference/
```

---

## Quick Start

Copy this and paste into Copilot chat (replacing brackets):

```
@[AGENT_NAME]

**Génère les prompts d'exécution** selon cette configuration:

Agent: [AGENT_NAME]
Projet: [PROJECT_NAME]
Source: [SOURCE_PATHS]
Sortie: [OUTPUT_PATH]
Langue: [LANGUAGE]

Batches à traiter:
- Batch 1 - [NAME]: [FILES]
- Batch 2 - [NAME]: [FILES]
- Batch 3 - [NAME]: [FILES]
```

The agent will automatically generate all prompts needed and display the execution plan.

---

## No More Manual Steps Needed! 

✨ Just provide the batch definitions in the chat, and the agent handles everything:
- Counts batches automatically
- Generates all prompts
- Displays execution plan
- Provides ready-to-copy prompts

No file editing. No manual calculations. Pure convenience!

### Batch Information Template

For each batch, you'll need:
- `[BATCH_N_NUMBER]`: Batch number (1, 2, 3, etc.)
- `[BATCH_N_NAME]`: Batch topic name (e.g., "OIA Fundamentals")
- `[BATCH_N_TRANSCRIPTS]`: Source files in this batch (e.g., "KT_1, KT_2 from /transcripts/clean/1_OIA/")
- `[BATCH_N_TOPICS]`: Main topics covered
- `[BATCH_N_OUTPUT_FOLDERS]`: Folders this batch will create
- `[BATCH_N_FILES]`: Expected output files

## Master Execution Guide

### Overview

```
PROJECT: [PROJECT_NAME]
AGENT: @[AGENT_NAME]
TOTAL BATCHES: [TOTAL_BATCHES]
LANGUAGE: [LANGUAGE]
OUTPUT: [OUTPUT_DIRECTORY]
PROGRESS TRACKING: [PROGRESS_FILE]
```

### Execution Steps

**Step 0**: Initialization (run first)
- Creates progress tracking file
- Lists all batches and files to generate
- Sets up directory structure

**Steps 1-[TOTAL_BATCHES]**: Batch Processing (run sequentially)
- Each batch processes a subset of source files
- Generates documentation for that batch
- Updates progress file
- Uses TBD placeholders for cross-batch references

**Step [TOTAL_BATCHES+1]**: Cross-Reference Resolution
- After all batches complete
- Resolves all TBD placeholders
- Verifies all links work correctly

**Step [TOTAL_BATCHES+2]**: Summary Generation
- Creates master index/summary file
- Documents complete project
- Adds navigation and search capabilities

**Step [TOTAL_BATCHES+3]**: Final Validation
- Verifies all formatting and structure
- Checks completeness
- Provides final report

---

## Template: Step 0 - Initialization

```
@[AGENT_NAME]

**Étape 0: Initialisation du projet de documentation**

**Objectif**: Préparer le projet et mettre en place le suivi d'avancement

**Actions**:
1. Crée le fichier de suivi: `[PROGRESS_FILE]`
   - Statut global du projet
   - Liste de tous les [TOTAL_BATCHES] batches
   - Checklist des fichiers à générer
   - État de chaque batch (Pending)

2. Vérifie la structure source
   - Confirme que tous les fichiers source existent
   - Compte les fichiers par batch

3. Planifie la sortie
   - Crée la structure de dossiers prévue dans `[OUTPUT_DIRECTORY]`
   - Documente l'hiérarchie attendue

**Rapport final**:
- Confirmation que tout est prêt
- Résumé du nombre de fichiers à traiter
- Statut "Ready for Batch 1"

Démarre maintenant!
```

---

## Template: Batch Execution Prompts

Use this template for each batch (N = 1 to [TOTAL_BATCHES]):

```
@[AGENT_NAME]

**Étape [BATCH_N_NUMBER]: Batch [BATCH_N_NUMBER] - [BATCH_N_NAME]**

**Source**:
- Fichiers: [BATCH_N_TRANSCRIPTS]
- Topics: [BATCH_N_TOPICS]

**Étapes**:

#### 2.[BATCH_N_NUMBER]A: Lecture et Analyse
- Lis les fichiers source assignés à ce batch uniquement
- Identifie les thèmes et contenus
- Note les connexions internes et cross-batch
- Mets à jour: "Analyzed" dans la progress file

#### 2.[BATCH_N_NUMBER]B: Planification de la Structure
- Planifie les dossiers et fichiers pour ce batch
- Crée la hiérarchie: [BATCH_N_OUTPUT_FOLDERS]
- Identifie les dépendances internes
- Mets à jour: structure plan dans progress file

#### 2.[BATCH_N_NUMBER]C: Création de la Documentation
- Crée les dossiers: [BATCH_N_OUTPUT_FOLDERS]
- Génère les fichiers: [BATCH_N_FILES]
- Utilise `[TBD: reference to Batch N doc]` pour références croisées
- Assure le formatage markdown complet
- Ajoute métadonnées (Topics, Related, Source)
- Mets à jour: fichiers complétés dans progress file [x]

#### 2.[BATCH_N_NUMBER]D: Finalisation du Batch
- Vérifie les références internes du batch
- Met à jour statut: "Completed"
- Documente les références croisées découvertes
- Ajoute timestamp
- Met à jour le pourcentage global de progression

**Contraintes**:
- Traite UNIQUEMENT ce batch
- Ignorre les autres batches
- Tout en [LANGUAGE]
- Respecte guidelines markdown

**Rapport final**:
- Nombre de fichiers créés
- Références croisées découvertes
- Statut "Batch [BATCH_N_NUMBER] Complete - Ready for Batch [BATCH_N_NUMBER+1]"
```

---

## Template: Step [TOTAL_BATCHES+1] - Cross-Reference Resolution

```
@[AGENT_NAME]

**Étape [TOTAL_BATCHES+1]: Résolution des Références Croisées**

**Objectif**: Remplacer tous les placeholders TBD par des liens réels

**Actions**:

1. **Recherche des placeholders**
   - Cherche tous les `[TBD: ...]` dans `[OUTPUT_DIRECTORY]`
   - Compile une liste complète

2. **Résolution des liens**
   - Pour chaque `[TBD: ...]`:
     - Identifie le document référencé
     - Localise le chemin exact
     - Remplace par lien markdown valide: `[texte](chemin/vers/fichier.md)`

3. **Vérification**
   - Teste que tous les liens pointent vers des fichiers existants
   - Corrige les chemins relatifs si nécessaire
   - Valide la syntaxe markdown

4. **Mise à jour de la progress file**
   - Marque: "Cross-references resolved"
   - Liste les références croisées résolues

**Rapport final**:
- Nombre de références croisées trouvées
- Nombre de références croisées résolues
- Statut "All cross-references resolved - Ready for Summary Generation"
```

---

## Template: Step [TOTAL_BATCHES+2] - Summary Generation

```
@[AGENT_NAME]

**Étape [TOTAL_BATCHES+2]: Génération du Summary**

**Objectif**: Créer le fichier index/résumé principal

**Actions**:

1. **Crée `[OUTPUT_DIRECTORY]/summary.md`** avec:

   #### Section 1: Aperçu
   - Description du projet
   - Domaines couverts
   - Nombre total de documents

   #### Section 2: Navigation par Domaine
   - Listes des documents par domaine
   - Brèves descriptions

   #### Section 3: Navigation par Sujet (A-Z)
   - Index alphabétique des sujets majeurs
   - Liens vers documentation pertinente

   #### Section 4: Cas d'Usage
   - Scénarios courants
   - Où trouver l'information

   #### Section 5: Carte Documentaire
   - Hiérarchie visuelle
   - Structure complète

   #### Section 6: Conseils de Recherche pour Agents IA
   - Comment utiliser les métadonnées Topics
   - Comment suivre les liens Related
   - Comment utiliser Source pour traçabilité

2. **Métadonnées du summary**:
   - Topics: keywords principaux
   - Date de génération
   - Total de documents indexés
   - Domaines couverts

3. **Liens vers tous les documents**
   - Assure que tous les fichiers créés sont référencés
   - Valide tous les chemins

**Rapport final**:
- Fichier summary.md créé
- Nombre de documents indexés
- Statut "Summary generated - Ready for Final Validation"
```

---

## Template: Step [TOTAL_BATCHES+3] - Final Validation

```
@[AGENT_NAME]

**Étape [TOTAL_BATCHES+3]: Validation Finale**

**Objectif**: Valider l'intégrité et la complétude du projet

**Vérifications**:

1. **Structure**
   - Tous les dossiers attendus existent
   - Tous les fichiers attendus existent
   - Hiérarchie correcte (max 3-4 niveaux)

2. **Références**
   - Aucun `[TBD: ...]` placeholder restant
   - Tous les liens markdown sont valides
   - Les chemins relatifs sont corrects

3. **Formatage**
   - Pas de H1 (réservé au titre)
   - Utilise H2 et H3 uniquement
   - Code blocks avec langage spécifié
   - Listes correctement indentées
   - Longueur ligne < 400 caractères

4. **Langue**
   - Tout en [LANGUAGE]
   - Terminologie cohérente
   - Pas de mélange de langues (sauf code)

5. **Métadonnées**
   - Tous les docs ont Topics, Related, Source
   - Cohérence des tags
   - Keywords appropriés

6. **Complétude**
   - Tous les fichiers source sont couverts
   - Aucun sujet majeur oublié
   - Summary référence tous les documents

**Actions correctives**:
Si des problèmes trouvés:
- Corrige les problèmes
- Revalide après chaque correction
- Documente ce qui a été corrigé

**Rapport Final Complet**:

```
=== RAPPORT FINAL - [PROJECT_NAME] ===

**Statut Global**: ✓ COMPLÉTÉ

**Résumé du Projet**
- Batches traités: [TOTAL_BATCHES]/[TOTAL_BATCHES]
- Fichiers générés: [COUNT]
- Dossiers créés: [COUNT]
- Domaines couverts: [LIST]

**Validations**
- ✓ Structure vérifiée
- ✓ Références validées
- ✓ Formatage conforme
- ✓ Langue cohérente
- ✓ Métadonnées complètes

**Statistiques**
- Documents générés: [N]
- Sections principales: [N]
- Références croisées: [N]
- Ligne total (caractères): [N]

**Navigation**
- Index principal: [OUTPUT_DIRECTORY]/summary.md
- Domaines: [LIST WITH COUNTS]
- Profondeur max hiérarchie: [N] niveaux

**Prêt pour**:
- Lecture humaine: ✓ OUI
- Recherche par IA: ✓ OUI
- Publication: ✓ OUI
```

Statut "PROJECT COMPLETE"
```

---

## Real-World Example: create-docs Project

### Project Configuration

```
AGENT_NAME: create-docs
PROJECT_NAME: Agefiph Documentation
TOTAL_BATCHES: 7
OUTPUT_DIRECTORY: /docs
PROGRESS_FILE: /temp/create-docs-progress.md
LANGUAGE: French

BATCHES:
- Batch 1: OIA Fundamentals (KT_1, KT_2 from 1_OIA)
- Batch 2: OIA Connectors (KT_3, KT_4 from 1_OIA)
- Batch 3: OIA Advanced (KT_5 from 1_OIA)
- Batch 4: Agefiph Context (KT_1-3 from 2_Agefiph)
- Batch 5: Agefiph Portals (KT_4-6 from 2_Agefiph)
- Batch 6: Agefiph Workflows (KT_7-10 from 2_Agefiph)
- Batch 7: Cross-domain (remaining topics)
```

### Execution Order

1. Run: **Step 0 Initialization Prompt**
2. Run: **Batch 1 Prompt** → Wait for completion
3. Run: **Batch 2 Prompt** → Wait for completion
4. Run: **Batch 3 Prompt** → Wait for completion
5. Run: **Batch 4 Prompt** → Wait for completion
6. Run: **Batch 5 Prompt** → Wait for completion
7. Run: **Batch 6 Prompt** → Wait for completion
8. Run: **Batch 7 Prompt** → Wait for completion
9. Run: **Step 8 Cross-Reference Resolution Prompt**
10. Run: **Step 9 Summary Generation Prompt**
11. Run: **Step 10 Final Validation Prompt**

---

## How to Use This Template

### 1. Define Project Variables

Create a configuration file with:
```
AGENT_NAME: [your-agent]
PROJECT_NAME: [Your Project Title]
TOTAL_BATCHES: [N]
BATCHES:
  - Batch 1: [description and source files]
  - Batch 2: [description and source files]
  ... etc
LANGUAGE: [French/English/other]
```

### 2. Generate All Prompts

For each step and batch, customize the templates:
- Replace all `[VARIABLES]` with your specific values
- Ensure batch-specific details are accurate
- Review for clarity

### 3. Execute Sequentially

Run prompts in order:
- Wait for each to complete before next
- Save outputs
- Update progress file between steps
- Never skip steps

### 4. Save Prompts in Project

Store completed prompts as:
```
.github/prompts/
├── 00-initialization.prompt.md
├── 01-batch-1.prompt.md
├── 02-batch-2.prompt.md
├── ...
├── 08-cross-references.prompt.md
├── 09-summary-generation.prompt.md
└── 10-final-validation.prompt.md
```

### 5. Reuse in Future Projects

For similar projects:
1. Copy this template file
2. Update the project variables
3. Generate new prompts
4. Execute in sequence

---

## Best Practices

### Timing
- Run one batch at a time
- Wait for full completion before next batch
- Allow 5-10 minutes between batches (real-world timing)
- Document timestamps

### Monitoring
- Check progress file after each batch
- Review generated files
- Verify cross-batch references are marked TBD
- Keep track of any issues

### Quality Control
- Read summaries carefully
- Spot-check generated files
- Verify folder structure matches plan
- Test links before final validation

### Issue Management
- If a batch fails, review the error message
- Re-run the batch with clarifications if needed
- Never proceed to next batch if current one failed
- Update progress file with issues and resolutions

### Documentation
- Keep all generated prompts
- Archive completed batch reports
- Document any special cases or modifications
- Maintain this template for future projects

---

## Common Issues and Solutions

### Issue: Batch takes too long or hits context limits
**Solution**: Reduce batch size, split into smaller batches

### Issue: Cross-batch references confusing
**Solution**: Use very clear TBD syntax like `[TBD: Batch 3 - entities.md]`

### Issue: Progress file gets cluttered
**Solution**: Use clear sections with timestamps, archive old entries

### Issue: Summary doesn't include all documents
**Solution**: After summary generation, search for any orphaned docs

### Issue: Links break during cross-reference resolution
**Solution**: Always use relative paths, test each link

---

## File Naming Convention

For a project called "create-docs":

```
.github/prompts/
├── create-docs.prompt.md          # Original agent definition
├── create-prompt.prompt.md        # This file (meta-prompt)
├── 00-initialize.prompt.md        # Step 0
├── 01-batch-1-fundamentals.prompt.md
├── 02-batch-2-connectors.prompt.md
├── 03-batch-3-advanced.prompt.md
├── 04-batch-4-context.prompt.md
├── 05-batch-5-portals.prompt.md
├── 06-batch-6-workflows.prompt.md
├── 07-batch-7-finalization.prompt.md
├── 08-cross-references.prompt.md
├── 09-summary.prompt.md
└── 10-validation.prompt.md
```

---

## Template Checklist

Before executing prompts, verify:

- [ ] All `[VARIABLES]` are replaced with real values
- [ ] Batch definitions are accurate and complete
- [ ] Source file paths are correct
- [ ] Output directory path is correct
- [ ] Language is specified
- [ ] Progress file location is correct
- [ ] All prompts follow the same format and tone
- [ ] Batch dependencies are correctly sequenced
- [ ] Final validation prompt is included
- [ ] Prompts saved in proper location with naming convention

---

## Quick Reference

**For [TOTAL_BATCHES] batches, you need [TOTAL_BATCHES+3] prompts:**
- 1 Initialization prompt
- [TOTAL_BATCHES] Batch prompts (one per batch)
- 1 Cross-Reference Resolution prompt
- 1 Summary Generation prompt
- 1 Final Validation prompt

**Total execution time estimate:**
- Initialization: ~5 minutes
- Per batch: ~5-15 minutes (depending on batch size)
- Cross-reference resolution: ~5 minutes
- Summary generation: ~5 minutes
- Final validation: ~5 minutes
- **Total: ~1-2 hours for 7 batches**

```
@[AGENT_NAME]

**Étape 0: Initialisation du projet de documentation**

**Objectif**: Préparer le projet et mettre en place le suivi d'avancement

**Actions**:
1. Crée le fichier de suivi: `[PROGRESS_FILE]`
   - Statut global du projet
   - Liste de tous les [TOTAL_BATCHES] batches
   - Checklist des fichiers à générer
   - État de chaque batch (Pending)

2. Vérifie la structure source
   - Confirme que tous les fichiers source existent
   - Compte les fichiers par batch

3. Planifie la sortie
   - Crée la structure de dossiers prévue dans `[OUTPUT_DIRECTORY]`
   - Documente l'hiérarchie attendue

**Rapport final**:
- Confirmation que tout est prêt
- Résumé du nombre de fichiers à traiter
- Statut "Ready for Batch 1"

Démarre maintenant!
```

---

## Template: Batch Execution Prompts

Use this template for each batch (N = 1 to [TOTAL_BATCHES]):

```
@[AGENT_NAME]

**Étape [BATCH_N_NUMBER]: Batch [BATCH_N_NUMBER] - [BATCH_N_NAME]**

**Source**:
- Fichiers: [BATCH_N_TRANSCRIPTS]
- Topics: [BATCH_N_TOPICS]

**Étapes**:

#### 2.[BATCH_N_NUMBER]A: Lecture et Analyse
- Lis les fichiers source assignés à ce batch uniquement
- Identifie les thèmes et contenus
- Note les connexions internes et cross-batch
- Mets à jour: "Analyzed" dans la progress file

#### 2.[BATCH_N_NUMBER]B: Planification de la Structure
- Planifie les dossiers et fichiers pour ce batch
- Crée la hiérarchie: [BATCH_N_OUTPUT_FOLDERS]
- Identifie les dépendances internes
- Mets à jour: structure plan dans progress file

#### 2.[BATCH_N_NUMBER]C: Création de la Documentation
- Crée les dossiers: [BATCH_N_OUTPUT_FOLDERS]
- Génère les fichiers: [BATCH_N_FILES]
- Utilise `[TBD: reference to Batch N doc]` pour références croisées
- Assure le formatage markdown complet
- Ajoute métadonnées (Topics, Related, Source)
- Mets à jour: fichiers complétés dans progress file [x]

#### 2.[BATCH_N_NUMBER]D: Finalisation du Batch
- Vérifie les références internes du batch
- Met à jour statut: "Completed"
- Documente les références croisées découvertes
- Ajoute timestamp
- Met à jour le pourcentage global de progression

**Contraintes**:
- Traite UNIQUEMENT ce batch
- Ignorre les autres batches
- Tout en [LANGUAGE]
- Respecte guidelines markdown

**Rapport final**:
- Nombre de fichiers créés
- Références croisées découvertes
- Statut "Batch [BATCH_N_NUMBER] Complete - Ready for Batch [BATCH_N_NUMBER+1]"
```

---

## Template: Step [TOTAL_BATCHES+1] - Cross-Reference Resolution

```
@[AGENT_NAME]

**Étape [TOTAL_BATCHES+1]: Résolution des Références Croisées**

**Objectif**: Remplacer tous les placeholders TBD par des liens réels

**Actions**:

1. **Recherche des placeholders**
   - Cherche tous les `[TBD: ...]` dans `[OUTPUT_DIRECTORY]`
   - Compile une liste complète

2. **Résolution des liens**
   - Pour chaque `[TBD: ...]`:
     - Identifie le document référencé
     - Localise le chemin exact
     - Remplace par lien markdown valide: `[texte](chemin/vers/fichier.md)`

3. **Vérification**
   - Teste que tous les liens pointent vers des fichiers existants
   - Corrige les chemins relatifs si nécessaire
   - Valide la syntaxe markdown

4. **Mise à jour de la progress file**
   - Marque: "Cross-references resolved"
   - Liste les références croisées résolues

**Rapport final**:
- Nombre de références croisées trouvées
- Nombre de références croisées résolues
- Statut "All cross-references resolved - Ready for Summary Generation"
```

---

## Template: Step [TOTAL_BATCHES+2] - Summary Generation

```
@[AGENT_NAME]

**Étape [TOTAL_BATCHES+2]: Génération du Summary**

**Objectif**: Créer le fichier index/résumé principal

**Actions**:

1. **Crée `[OUTPUT_DIRECTORY]/summary.md`** avec:

   #### Section 1: Aperçu
   - Description du projet
   - Domaines couverts
   - Nombre total de documents

   #### Section 2: Navigation par Domaine
   - Listes des documents par domaine
   - Brèves descriptions

   #### Section 3: Navigation par Sujet (A-Z)
   - Index alphabétique des sujets majeurs
   - Liens vers documentation pertinente

   #### Section 4: Cas d'Usage
   - Scénarios courants
   - Où trouver l'information

   #### Section 5: Carte Documentaire
   - Hiérarchie visuelle
   - Structure complète

   #### Section 6: Conseils de Recherche pour Agents IA
   - Comment utiliser les métadonnées Topics
   - Comment suivre les liens Related
   - Comment utiliser Source pour traçabilité

2. **Métadonnées du summary**:
   - Topics: keywords principaux
   - Date de génération
   - Total de documents indexés
   - Domaines couverts

3. **Liens vers tous les documents**
   - Assure que tous les fichiers créés sont référencés
   - Valide tous les chemins

**Rapport final**:
- Fichier summary.md créé
- Nombre de documents indexés
- Statut "Summary generated - Ready for Final Validation"
```

---

## Template: Step [TOTAL_BATCHES+3] - Final Validation

```
@[AGENT_NAME]

**Étape [TOTAL_BATCHES+3]: Validation Finale**

**Objectif**: Valider l'intégrité et la complétude du projet

**Vérifications**:

1. **Structure**
   - Tous les dossiers attendus existent
   - Tous les fichiers attendus existent
   - Hiérarchie correcte (max 3-4 niveaux)

2. **Références**
   - Aucun `[TBD: ...]` placeholder restant
   - Tous les liens markdown sont valides
   - Les chemins relatifs sont corrects

3. **Formatage**
   - Pas de H1 (réservé au titre)
   - Utilise H2 et H3 uniquement
   - Code blocks avec langage spécifié
   - Listes correctement indentées
   - Longueur ligne < 400 caractères

4. **Langue**
   - Tout en [LANGUAGE]
   - Terminologie cohérente
   - Pas de mélange de langues (sauf code)

5. **Métadonnées**
   - Tous les docs ont Topics, Related, Source
   - Cohérence des tags
   - Keywords appropriés

6. **Complétude**
   - Tous les fichiers source sont couverts
   - Aucun sujet majeur oublié
   - Summary référence tous les documents

**Actions correctives**:
Si des problèmes trouvés:
- Corrige les problèmes
- Revalide après chaque correction
- Documente ce qui a été corrigé

**Rapport Final Complet**:

```
=== RAPPORT FINAL - [PROJECT_NAME] ===

**Statut Global**: ✓ COMPLÉTÉ

**Résumé du Projet**
- Batches traités: [TOTAL_BATCHES]/[TOTAL_BATCHES]
- Fichiers générés: [COUNT]
- Dossiers créés: [COUNT]
- Domaines couverts: [LIST]

**Validations**
- ✓ Structure vérifiée
- ✓ Références validées
- ✓ Formatage conforme
- ✓ Langue cohérente
- ✓ Métadonnées complètes

**Statistiques**
- Documents générés: [N]
- Sections principales: [N]
- Références croisées: [N]
- Ligne total (caractères): [N]

**Navigation**
- Index principal: [OUTPUT_DIRECTORY]/summary.md
- Domaines: [LIST WITH COUNTS]
- Profondeur max hiérarchie: [N] niveaux

**Prêt pour**:
- Lecture humaine: ✓ OUI
- Recherche par IA: ✓ OUI
- Publication: ✓ OUI
```

Statut "PROJECT COMPLETE"
```

---

## Real-World Example: create-docs Project

### Project Configuration

```
AGENT_NAME: create-docs
PROJECT_NAME: Agefiph Documentation
TOTAL_BATCHES: 7
OUTPUT_DIRECTORY: /docs
PROGRESS_FILE: /temp/create-docs-progress.md
LANGUAGE: French

BATCHES:
- Batch 1: OIA Fundamentals (KT_1, KT_2 from 1_OIA)
- Batch 2: OIA Connectors (KT_3, KT_4 from 1_OIA)
- Batch 3: OIA Advanced (KT_5 from 1_OIA)
- Batch 4: Agefiph Context (KT_1-3 from 2_Agefiph)
- Batch 5: Agefiph Portals (KT_4-6 from 2_Agefiph)
- Batch 6: Agefiph Workflows (KT_7-10 from 2_Agefiph)
- Batch 7: Cross-domain (remaining topics)
```

### Execution Order

1. Run: **Step 0 Initialization Prompt**
2. Run: **Batch 1 Prompt** → Wait for completion
3. Run: **Batch 2 Prompt** → Wait for completion
4. Run: **Batch 3 Prompt** → Wait for completion
5. Run: **Batch 4 Prompt** → Wait for completion
6. Run: **Batch 5 Prompt** → Wait for completion
7. Run: **Batch 6 Prompt** → Wait for completion
8. Run: **Batch 7 Prompt** → Wait for completion
9. Run: **Step 8 Cross-Reference Resolution Prompt**
10. Run: **Step 9 Summary Generation Prompt**
11. Run: **Step 10 Final Validation Prompt**

---

## How to Use This Template

### 1. Define Project Variables

Create a configuration file with:
```
AGENT_NAME: [your-agent]
PROJECT_NAME: [Your Project Title]
TOTAL_BATCHES: [N]
BATCHES:
  - Batch 1: [description and source files]
  - Batch 2: [description and source files]
  ... etc
LANGUAGE: [French/English/other]
```

### 2. Generate All Prompts

For each step and batch, customize the templates:
- Replace all `[VARIABLES]` with your specific values
- Ensure batch-specific details are accurate
- Review for clarity

### 3. Execute Sequentially

Run prompts in order:
- Wait for each to complete before next
- Save outputs
- Update progress file between steps
- Never skip steps

### 4. Save Prompts in Project

Store completed prompts as:
```
.github/prompts/
├── 00-initialization.prompt.md
├── 01-batch-1.prompt.md
├── 02-batch-2.prompt.md
├── ...
├── 08-cross-references.prompt.md
├── 09-summary-generation.prompt.md
└── 10-final-validation.prompt.md
```

### 5. Reuse in Future Projects

For similar projects:
1. Copy this template file
2. Update the project variables
3. Generate new prompts
4. Execute in sequence

---

## Best Practices

### Timing
- Run one batch at a time
- Wait for full completion before next batch
- Allow 5-10 minutes between batches (real-world timing)
- Document timestamps

### Monitoring
- Check progress file after each batch
- Review generated files
- Verify cross-batch references are marked TBD
- Keep track of any issues

### Quality Control
- Read summaries carefully
- Spot-check generated files
- Verify folder structure matches plan
- Test links before final validation

### Issue Management
- If a batch fails, review the error message
- Re-run the batch with clarifications if needed
- Never proceed to next batch if current one failed
- Update progress file with issues and resolutions

### Documentation
- Keep all generated prompts
- Archive completed batch reports
- Document any special cases or modifications
- Maintain this template for future projects

---

## Common Issues and Solutions

### Issue: Batch takes too long or hits context limits
**Solution**: Reduce batch size, split into smaller batches

### Issue: Cross-batch references confusing
**Solution**: Use very clear TBD syntax like `[TBD: Batch 3 - entities.md]`

### Issue: Progress file gets cluttered
**Solution**: Use clear sections with timestamps, archive old entries

### Issue: Summary doesn't include all documents
**Solution**: After summary generation, search for any orphaned docs

### Issue: Links break during cross-reference resolution
**Solution**: Always use relative paths, test each link

---

## File Naming Convention

For a project called "create-docs":

```
.github/prompts/
├── create-docs.prompt.md          # Original agent definition
├── create-prompt.prompt.md        # This file (meta-prompt)
├── 00-initialize.prompt.md        # Step 0
├── 01-batch-1-fundamentals.prompt.md
├── 02-batch-2-connectors.prompt.md
├── 03-batch-3-advanced.prompt.md
├── 04-batch-4-context.prompt.md
├── 05-batch-5-portals.prompt.md
├── 06-batch-6-workflows.prompt.md
├── 07-batch-7-finalization.prompt.md
├── 08-cross-references.prompt.md
├── 09-summary.prompt.md
└── 10-validation.prompt.md
```

---

## Template Checklist

Before executing prompts, verify:

- [ ] All `[VARIABLES]` are replaced with real values
- [ ] Batch definitions are accurate and complete
- [ ] Source file paths are correct
- [ ] Output directory path is correct
- [ ] Language is specified
- [ ] Progress file location is correct
- [ ] All prompts follow the same format and tone
- [ ] Batch dependencies are correctly sequenced
- [ ] Final validation prompt is included
- [ ] Prompts saved in proper location with naming convention

---

## Quick Reference

**For [TOTAL_BATCHES] batches, you need [TOTAL_BATCHES+3] prompts:**
- 1 Initialization prompt
- [TOTAL_BATCHES] Batch prompts (one per batch)
- 1 Cross-Reference Resolution prompt
- 1 Summary Generation prompt
- 1 Final Validation prompt

**Total execution time estimate:**
- Initialization: ~5 minutes
- Per batch: ~5-15 minutes (depending on batch size)
- Cross-reference resolution: ~5 minutes
- Summary generation: ~5 minutes
- Final validation: ~5 minutes
- **Total: ~1-2 hours for 7 batches**

