# Process Instructions - Transcript to Documentation System

## 📋 Overview

Ce document décrit le processus global de transformation de **transcripts bruts** en **documentation structurée et interrogeable**. Il permet à tout agent impliqué dans le système de comprendre le contexte complet et sa place dans le flux de travail.

---

## 🔄 Flux de travail global

```
Transcripts Bruts → Transcripts Nettoyés → Documentation → Recherche/Interrogation
```

### Phases

| Phase | Entrée | Agent/Outil | Sortie | Description |
|-------|--------|-------------|--------|-------------|
| **1. Préparation** | Enregistrements bruts | Manuel | `/transcripts/raw/` | Placer les transcripts bruts |
| **2. Nettoyage** | `/transcripts/raw/` | `clean-transcript` | `/transcripts/clean/` | Transformer en markdown structuré |
| **3. Validation** | `/transcripts/clean/` | Manuel | ✓ Approuvé | Vérifier qualité et complétude |
| **4. Génération d'Agent** | `/transcripts/clean/` + config | `generic-doc-transformation-agent` | `create-docs.agent.md` | Créer agent personnalisé |
| **5. Génération de Prompts** | `/transcripts/clean/` + config | `create-prompt` | `*.prompt.md` numérotés | Créer prompts d'exécution |
| **6. Création de Docs** | `/transcripts/clean/` + prompts | `create-docs` | `/docs/` | Générer documentation finale |
| **7. Interrogation** | `/docs/` | `search-doc` | Réponses | Rechercher et répondre |

---

## 🎯 Détail des phases

### Phase 1: Préparation (Manual)

**Objectif**: Collecter les transcripts bruts

**Entrée**: Enregistrements, transcriptions (fichiers `.transcript`)

**Actions**:
- Placer les fichiers dans `/transcripts/raw/`
- Organiser par domaines si nécessaire
- Format: Texte brut ou légèrement formaté

**Sortie**: Fichiers `.transcript` dans `/transcripts/raw/`

**Exemple**:
```
transcripts/raw/
├── KT_1.transcript
├── KT_2.transcript
└── KT_3.transcript
```

---

### Phase 2: Nettoyage (`clean-transcript` agent)

**Objectif**: Transformer transcripts bruts en markdown structuré

**Agent**: `clean-transcript.agent.md`

**Entrée**: Fichiers `.transcript` bruts

**Actions du agent**:
1. Lire le fichier brut
2. Corriger les erreurs de transcription
3. Ajouter les omissions manquantes
4. Structurer en sections markdown
5. Appliquer les standards de formatage
6. Ajouter les métadonnées (Topics, Related, Source)

**Sortie**: Fichiers `.md` structurés

**Exemple de transformation**:
```
ENTRÉE (raw):
"le transfert de connaissance sur le sujet X et Y... 
 et aussi le process Z"

SORTIE (clean):
# Transfert de Connaissances

## Topics
- Sujet X
- Sujet Y
- Process Z

## Content
[Contenu structuré...]
```

**Résultat**: Fichiers `.md` organisés par domaines dans `/transcripts/clean/`

---

### Phase 3: Validation (Manual)

**Objectif**: S'assurer que les transcripts nettoyés sont corrects

**Actions**:
- Examiner les fichiers dans `/transcripts/clean/`
- Vérifier la complétude du contenu
- Vérifier la structure markdown
- Vérifier la présence des métadonnées
- Corriger si nécessaire (relancer clean-transcript si besoin)

**Critères d'acceptation**:
- ✅ Contenu correct et complet
- ✅ Structure logique et cohérente
- ✅ Métadonnées présentes
- ✅ Formatage markdown valide
- ✅ Pas de corruption de fichiers

---

### Phase 4: Génération d'Agent (`generic-doc-transformation-agent`)

**Objectif**: Créer un agent personnalisé pour la génération de documentation

**Prompt**: `generic-doc-transformation-agent.prompt.md`

**Entrée**: 
- Fichiers source dans `/transcripts/clean/`
- Configuration depuis `prompts.config`

**Actions du prompt**:
1. Lire la structure source
2. Analyser les domaines et sections
3. Lire `prompts.config` pour les paramètres
4. Générer un agent `create-docs` personnalisé
5. Adapter le agent à votre structure

**Sortie**: `.github/agents/create-docs.agent.md` (personnalisé)

**Résultat**: Agent généré et prêt pour exécution

---

### Phase 5: Génération de Prompts (`create-prompt`)

**Objectif**: Créer tous les prompts d'exécution nécessaires

**Prompt**: `create-prompt.prompt.md`

**Entrée**:
- Fichiers source dans `/transcripts/clean/`
- Configuration depuis `prompts.config`

**Actions du prompt**:
1. Compter les fichiers source
2. Calculer groupement optimal en lots (2-4 fichiers)
3. Générer prompt d'initialisation (`01-init-docs.prompt.md`)
4. Générer prompts de batches (`02-batch-01.prompt.md`, `03-batch-02.prompt.md`, etc.)
5. Générer prompt de références croisées (`N-cross-references.prompt.md`)
6. Générer prompt de synthèse (`N+1-summary.prompt.md`)

**Sortie**: Fichiers `.prompt.md` numérotés dans `.github/prompts/`

**Exemple pour 6 fichiers (2 par batch)**:
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

### Phase 6: Création de Documentation (`create-docs` agent)

**Objectif**: Transformer les transcripts nettoyés en documentation final

**Agent**: `create-docs.agent.md` (généré à phase 4)

**Entrée**: 
- Fichiers `.md` structurés dans `/transcripts/clean/`
- Prompts numérotés générés à phase 5

**Actions du agent** (exécution séquentielle):
1. **Initialisation** (`01-init-docs.prompt.md`):
   - Créer la structure de base
   - Initialiser les fichiers de destination

2. **Traitement par batches** (`02-batch-XX.prompt.md`):
   - Transformer chaque batch de 2-4 fichiers
   - Générer sections structurées
   - Ajouter métadonnées (Topics, Related, Source)
   - Créer fichiers dans `/docs/`

3. **Références croisées** (`N-cross-references.prompt.md`):
   - Analyser les connections entre documents
   - Ajouter les liens "Related"
   - Mettre à jour les références

4. **Synthèse** (`N+1-summary.prompt.md`):
   - Créer index complet
   - Générer vue d'ensemble
   - Créer fichier `summary.md`

**Sortie**: Documentation structurée dans `/docs/`

**Structure résultante**:
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

### Phase 7: Interrogation (`search-doc` agent)

**Objectif**: Permettre la recherche et l'interrogation de la documentation

**Agent**: `search-doc.agent.md` (générique)

**Entrée**: Documentation dans `/docs/`

**Utilisation**:
```
@search-doc "Qu'est-ce que [Concept] ?"
@search-doc "Comment faire [Action] ?"
@search-doc "Quelle est la différence entre [A] et [B] ?"
```

**Actions du agent**:
1. Analyser la question
2. Rechercher dans `/docs/`
3. Trouver documents pertinents
4. Extraire informations
5. Générer réponse structurée
6. Fournir citations et sources

**Réponses**:
- ✅ Basées UNIQUEMENT sur la documentation
- ✅ Avec citations exactes
- ✅ Avec références aux sources
- ✅ Indiquant les limitations
- ✅ Suggestions de documents connexes

---

## 🔧 Configuration centrale

### Fichier: `.github/prompts.config`

Ce fichier YAML contrôle **tout le processus**. Les agents et prompts le lisent pour adapter leur comportement.

**Paramètres clés**:

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
LANGUAGE: Français
```

**Impact**:
- Phase 4: `generic-doc-transformation-agent` l'utilise pour générer l'agent
- Phase 5: `create-prompt` l'utilise pour calculer les lots
- Phase 6: `create-docs` l'utilise pour structurer la documentation
- Phase 7: `search-doc` l'utilise pour chercher dans `OUTPUT_PATH`

---

## 📊 Dépendances et flux de données

```
prompts.config (source de vérité)
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

## ✅ Checklist de complétion

Pour confirmer que chaque phase est terminée:

- [ ] **Phase 1**: Fichiers `.transcript` dans `/transcripts/raw/`
- [ ] **Phase 2**: Fichiers `.md` générés dans `/transcripts/clean/`
- [ ] **Phase 3**: Validation manuelle complétée, qualité ✓
- [ ] **Phase 4**: Fichier `create-docs.agent.md` généré
- [ ] **Phase 5**: Fichiers `.prompt.md` numérotés dans `.github/prompts/`
- [ ] **Phase 6**: Documentation générée dans `/docs/`
- [ ] **Phase 7**: Interrogation fonctionnelle via `@search-doc`

---

## 🔄 Itération et amélioration

### Si la documentation n'est pas satisfaisante

**Option 1**: Améliorer les transcripts nettoyés
1. Modifier les fichiers dans `/transcripts/clean/`
2. Relancer Phase 5 (regenerate prompts)
3. Relancer Phase 6 (regenerate docs)

**Option 2**: Modifier la configuration
1. Éditer `.github/prompts.config`
2. Relancer Phase 4 (regenerate agent)
3. Relancer Phase 5 (regenerate prompts)
4. Relancer Phase 6 (regenerate docs)

**Option 3**: Corriger directement
1. Éditer les fichiers dans `/docs/`
2. Relancer Phase 7 (search-doc lira les fichiers modifiés)

---

## 🎓 Résumé pour les agents

### Pour `clean-transcript`:
- **Rôle**: Transformer brut → structuré
- **Entrée**: `/transcripts/raw/`
- **Sortie**: `/transcripts/clean/`
- **Phase**: 2

### Pour `generic-doc-transformation-agent`:
- **Rôle**: Générer agent personnalisé
- **Entrée**: `/transcripts/clean/` + `prompts.config`
- **Sortie**: `create-docs.agent.md`
- **Phase**: 4

### Pour `create-prompt`:
- **Rôle**: Générer prompts d'exécution
- **Entrée**: `/transcripts/clean/` + `prompts.config`
- **Sortie**: `*.prompt.md` numérotés
- **Phase**: 5

### Pour `create-docs`:
- **Rôle**: Générer documentation
- **Entrée**: `/transcripts/clean/` + prompts
- **Sortie**: `/docs/`
- **Phase**: 6

### Pour `search-doc`:
- **Rôle**: Interroger documentation
- **Entrée**: `/docs/`
- **Sortie**: Réponses structurées
- **Phase**: 7

---

## 📝 Conventions

- **Fichiers bruts**: `.transcript` (texte brut)
- **Fichiers nettoyés**: `.md` (markdown structuré)
- **Prompts d'exécution**: `NN-name.prompt.md` (numérotés, format .prompt.md)
- **Documentation finale**: `.md` (markdown avec métadonnées)
- **Configuration**: `prompts.config` (YAML)

---

## 🚀 Flux d'utilisation typique

```
1. Préparer transcripts → /transcripts/raw/
2. Exécuter @clean-transcript
3. Vérifier qualité
4. Exécuter @generic-doc-transformation-agent
5. Exécuter @create-prompt
6. Exécuter @create-docs (avec tous les prompts)
7. Utiliser @search-doc pour interroger
```

---

**Version**: 1.0  
**Langue**: Français  
**Audience**: Agents et développeurs  
**Statut**: Generic & Reusable
