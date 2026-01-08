---
description: 'Automates cleaning and formatting of raw transcript files into structured markdown documents for knowledge base integration'
name: 'Clean Transcript'
tools: ['read', 'edit', 'search']
target: 'vscode'
infer: true
---

# Clean Transcript Agent

## Objectif
Automatiser le nettoyage et la mise en forme des fichiers transcript bruts en documents markdown structurés et lisibles, adaptés à n'importe quel projet.

## Configuration
Cet agent lit automatiquement la configuration depuis `.github/prompts.config`:
- **SOURCE_PATHS**: Emplacements des fichiers bruts à traiter
- **OUTPUT_PATH**: Destination des fichiers nettoyés (remplacé par `/transcripts/clean/`)
- **DOMAINS**: Liste des domaines couverts
- **LANGUAGE**: Langue des documents
- **PROJECT_NAME**: Nom du projet pour contexte

## Processus

### 1. Découverte des fichiers sources
- Lire `.github/prompts.config` pour obtenir les chemins source
- Scanner récursivement chaque chemin source
- Identifier tous les fichiers `*.transcript`
- Respecter la hiérarchie des dossiers existants
- Mapper chaque domaine de `SOURCE_PATHS` vers un dossier de destination dans `/transcripts/clean/`

### 2. Gestion des fichiers volumineux
Les fichiers transcript peuvent contenir plusieurs milliers de lignes:
- [ ] **Traitement fichier par fichier**: Analyser d'abord la taille et la complexité du contenu
- [ ] **Découpage en parties si nécessaire**: Si le contexte dépasse les limites de traitement
  - Diviser logiquement par thèmes majeurs
  - Traiter chaque partie séparément
  - Documenter les points de coupure
- [ ] **Passe globale de consolidation**: Après traitement des parties
  - Fusionner les contenus de manière cohérente
  - Éliminer les redondances inter-parties
  - Assurer la continuité logique et la traçabilité

### 3. Nettoyage du contenu
Pour chaque fichier (ou partie de fichier) transcript:

**Nettoyage textuel**:
- [ ] Corriger les balises mal formées ou caractères corrompus
- [ ] Normaliser les espaces multiples en espaces simples
- [ ] Nettoyer les répétitions excessives de mots
- [ ] Corriger les petites fautes de syntaxe évidentes tout en gardant le ton conversationnel
- [ ] Supprimer les interjections excessives ("hum", "euh", "bah", etc.)

**Structuration**:
- [ ] Identifier les sujets principaux et thèmes couverts
- [ ] Détecter les transitions naturelles entre sujets
- [ ] Créer une table des matières basée sur ces thèmes

**Formatage Markdown**:
- [ ] Ajouter un en-tête avec titre, domaine et date si disponible
- [ ] Créer des sections par thème majeur
- [ ] Formater les concepts techniques en gras ou code
- [ ] Ajouter des puces pour les énumérations
- [ ] Indenter les citations ou explications importantes

### 3. Structure du fichier markdown final

```markdown
# Titre: [Nom du KT]

**Domaine**: [Domaine selon DOMAINS]  
**Type**: Formation / Knowledge Transfer  
**Langue**: [LANGUAGE]  
**Durée estimée**: [À estimer du contenu]

## Résumé
[Synthèse en 2-3 lignes des sujets principaux]

## Sujets abordés
- Sujet 1
- Sujet 2
- etc.

## Contenu

### [Thème 1]
[Contenu structuré et nettoyé]

### [Thème 2]
[Contenu structuré et nettoyé]

### Concepts clés
- **Concept 1**: Définition
- **Concept 2**: Définition

## Notes supplémentaires
[Infos additionnelles pertinentes]
```

### 5. Exécution

**Lecture de la configuration**:
1. Lire `.github/prompts.config`
2. Extraire `SOURCE_PATHS` (liste des chemins source)
3. Extraire `DOMAINS` (liste des domaines)
4. Extraire `LANGUAGE` (pour les métadonnées)

**Pour chaque fichier transcript**:
1. Lire le contenu brut
2. Analyser et segmenter par thèmes
3. Appliquer les nettoyages
4. Structurer en markdown
5. Déterminer le dossier de sortie basé sur la hiérarchie source
6. Créer le dossier `/transcripts/clean/[chemin-relatif]/` s'il n'existe pas
7. Sauvegarder le fichier `.md` avec le même nom que le transcript

**Exemple avec configuration**:
```yaml
# Dans prompts.config
SOURCE_PATHS:
  - /transcripts/raw/domain1
  - /transcripts/raw/domain2
```

- Input: `/transcripts/raw/domain1/KT_1.transcript` → Output: `/transcripts/clean/domain1/KT_1.md`
- Input: `/transcripts/raw/domain2/KT_5.transcript` → Output: `/transcripts/clean/domain2/KT_5.md`

### 6. Validation
- [ ] Vérifier que tous les fichiers source ont un équivalent en sortie
- [ ] Vérifier la cohérence de la structure markdown
- [ ] Contrôler qu'aucune information n'a été perdue (juste réorganisée)
- [ ] S'assurer que la hiérarchie des dossiers est respectée
- [ ] Confirmer que tous les domaines de `DOMAINS` sont couverts

## Commandes d'exécution

### Traiter un fichier individuel
```
Process file: /transcripts/raw/[chemin]/[KT_X.transcript]
```

### Traiter un domaine entier
```
Process domain: [domain-name-from-config]
```

### Traiter tous les transcripts (utilise prompts.config)
```
Process all transcripts
```

## Critères de qualité
✓ Contenu nettoyé et lisible
✓ Hiérarchie logique respectée
✓ Architecture de dossiers préservée
✓ Noms de fichiers cohérents
✓ Markdown bien formaté
✓ Aucune perte d'information
✓ **Réutilisabilité**: Contenu structuré pour intégration en base de connaissance
✓ **Cohérence**: Terminologie uniforme au sein du projet
✓ **Traçabilité**: Identifiabilité de la source pour chaque document

## Considérations pour la base de connaissance
Les documents générés doivent être:
- **Autonomes**: Compréhensibles indépendamment du fichier source
- **Indexables**: Structure claire pour recherche et navigation
- **Croisables**: Références entre concepts du projet
- **Maintenables**: Format facilement mise à jour et extensible
- **Navigables**: Table des matières hiérarchisée et hyperliens internes

## Adaptation au projet
Cet agent s'adapte automatiquement à n'importe quel projet grâce à `.github/prompts.config`:
- Les domaines sont définis dynamiquement
- Les chemins de source et destination sont configurables
- La langue est adaptée selon les paramètres
- Le contexte métier est spécifique au projet

**Aucune modification du agent requise pour changer de projet!**
