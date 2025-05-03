#!/bin/bash

# CLAUDE-AGI-Terminal: Integrierter Installer für AGI + Terminal
# Version 1.2 - 2025-05-05
# Standardisierte Projektstruktur mit ProxyClaude und MCP-Tools

set -e

# Farbdefinitionen für bessere Lesbarkeit
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner anzeigen
echo -e "${CYAN}"
echo "  ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗      ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗     "
echo " ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝      ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║     "
echo " ██║     ██║     ███████║██║   ██║██║  ██║█████╗  █████╗   ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║     "
echo " ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝  ╚════╝   ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║     "
echo " ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗         ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗"
echo "  ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝         ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝"
echo -e "${NC}"
echo -e "${BLUE}AGI + Terminal + ProxyClaude mit standardisierter Projektstruktur${NC}"
echo -e "${BLUE}Version 1.2 • Claude Pro MAX Edition${NC}"
echo "========================================================"
echo ""

# Konfigurationsvariablen
DESKTOP_DIR="${HOME}/Schreibtisch"
CLAUDE_DIR="$DESKTOP_DIR/CLAUDE"
TERMINAL_DIR="$CLAUDE_DIR/claude-terminal"
AGI_PROJECTS_DIR="$CLAUDE_DIR/claude-agi-projects"
DEFAULT_PROJECT_DIR="$AGI_PROJECTS_DIR/default-project"
MEMORY_BANK_DIR="$CLAUDE_DIR/memory-bank"
CONFIG_DIR="${HOME}/.config/claude-desktop"
LOGS_DIR="$CLAUDE_DIR/logs"
LOG_FILE="$LOGS_DIR/terminal-installation.log"

# Hilfsfunktion: Loggen
log() {
  local level=$1
  local message=$2
  local color=$NC
  
  case $level in
    "INFO") color=$BLUE ;;
    "SUCCESS") color=$GREEN ;;
    "WARNING") color=$YELLOW ;;
    "ERROR") color=$RED ;;
  esac
  
  echo -e "${color}[$(date +"%Y-%m-%d %H:%M:%S")] [$level] $message${NC}"
  
  # Stelle sicher, dass das Logs-Verzeichnis existiert
  mkdir -p "$LOGS_DIR"
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$level] $message" >> "$LOG_FILE"
}

# Voraussetzungen prüfen
check_prerequisites() {
  log "INFO" "Prüfe Systemvoraussetzungen..."
  
  # Node.js-Version prüfen - mindestens v16, empfehle v18+
  if ! command -v node &> /dev/null; then
    log "ERROR" "Node.js ist nicht installiert. Bitte installiere Node.js v16 oder höher."
    exit 1
  fi
  
  NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
  if [ "$NODE_VERSION" -lt 16 ]; then
    log "ERROR" "Node.js v$NODE_VERSION ist zu alt. Mindestens Node.js v16 wird benötigt, v18+ empfohlen."
    exit 1
  elif [ "$NODE_VERSION" -lt 18 ]; then
    log "WARNING" "Node.js v$NODE_VERSION funktioniert, aber v18+ wird empfohlen für bessere Kompatibilität."
  else
    log "SUCCESS" "Node.js v$NODE_VERSION gefunden. ✓"
  fi
  
  # npm-Version prüfen
  if ! command -v npm &> /dev/null; then
    log "ERROR" "npm ist nicht installiert. Bitte installiere npm."
    exit 1
  fi
  
  log "SUCCESS" "npm $(npm -v) gefunden. ✓"
  
  # git prüfen
  if ! command -v git &> /dev/null; then
    log "WARNING" "git ist nicht installiert. Einige Funktionen könnten eingeschränkt sein."
  else
    log "SUCCESS" "git $(git --version | cut -d' ' -f3) gefunden. ✓"
  fi
  
  # Systemressourcen prüfen
  MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  MEM_GB=$(echo "scale=1; $MEM_TOTAL/1024/1024" | bc)
  
  if (( $(echo "$MEM_GB < 4" | bc -l) )); then
    log "WARNING" "Nur ${MEM_GB}GB RAM gefunden. Mindestens 4GB werden für optimale Leistung empfohlen."
  else
    log "SUCCESS" "${MEM_GB}GB RAM gefunden. ✓"
  fi
  
  log "SUCCESS" "Systemvoraussetzungen erfüllt."
}

# Memory-Bank-Struktur erstellen
create_memory_bank() {
  log "INFO" "Erstelle Memory-Bank-Struktur..."
  
  # Hauptverzeichnis
  mkdir -p "$MEMORY_BANK_DIR/templates"
  mkdir -p "$MEMORY_BANK_DIR/apis"
  
  # Standard-Template-Dateien erstellen
  cat > "$MEMORY_BANK_DIR/templates/projectbrief.md" << EOL
# [Projektname]

## Projektzusammenfassung
Kurze Zusammenfassung des Projekts, seiner Hauptziele und seines Werts.

## Schlüsselkomponenten
- Komponente 1: Kurzbeschreibung
- Komponente 2: Kurzbeschreibung
- Komponente 3: Kurzbeschreibung

## Zielplattformen
- Web/Desktop/Mobile/etc.

## Technologie-Stack
- Frontend: 
- Backend: 
- Datenbank: 
- Hosting: 

## Anforderungen und Abhängigkeiten
- Anforderung 1
- Anforderung 2
EOL

  cat > "$MEMORY_BANK_DIR/templates/activeContext.md" << EOL
# Aktiver Kontext

## Aktuelle Aufgabe
Beschreibung der aktuellen Aufgabe oder des aktuellen Features, an dem gearbeitet wird.

## Aktueller Fortschritt
- Meilenstein 1: Abgeschlossen
- Meilenstein 2: In Bearbeitung
- Meilenstein 3: Ausstehend

## Offene Fragen
- Frage 1
- Frage 2

## Nächste Schritte
1. Schritt 1
2. Schritt 2
3. Schritt 3

## Sequential Thinking Ergebnisse
Hier werden automatisch die Ergebnisse von Sequential Thinking Analysen hinzugefügt.
EOL

  cat > "$MEMORY_BANK_DIR/templates/techContext.md" << EOL
# Technischer Kontext

## Frontend
- Framework: 
- UI-Bibliothek: 
- State Management: 
- Routing: 

## Backend
- Framework: 
- API-Stil: 
- Authentifizierung: 
- Validierung: 

## Datenbank
- Typ: 
- Schema: 
- ORM/Query Builder: 
- Migrations-Strategie: 

## Infrastruktur
- Hosting: 
- CI/CD: 
- Monitoring: 
- Logging: 

## Entwicklungswerkzeuge
- Linter: 
- Formatter: 
- Testing: 
- Dokumentation: 
EOL

  cat > "$MEMORY_BANK_DIR/templates/systemPatterns.md" << EOL
# System-Architektur und Design-Patterns

## Architektur-Übersicht
Beschreibung der grundlegenden Architektur des Systems.

## Kern-Design-Patterns
- Pattern 1: Verwendungszweck und Implementierungsdetails
- Pattern 2: Verwendungszweck und Implementierungsdetails
- Pattern 3: Verwendungszweck und Implementierungsdetails

## Datenflussmuster
Beschreibung wie Daten durch das System fließen.

## Fehlerbehandlung
Strategie und Muster für die Fehlerbehandlung im System.

## Sicherheitsmuster
Beschreibung der Sicherheitsmuster und -praktiken im System.
EOL

  cat > "$MEMORY_BANK_DIR/templates/progress.md" << EOL
# Fortschritt

## Abgeschlossene Aufgaben
- [x] Aufgabe 1 (Datum)
- [x] Aufgabe 2 (Datum)

## Aktuelle Aufgaben
- [ ] Aufgabe 3 (Priorität: Hoch)
- [ ] Aufgabe 4 (Priorität: Mittel)

## Geplante Aufgaben
- [ ] Aufgabe 5
- [ ] Aufgabe 6

## Bekannte Probleme
- Problem 1: Status und Lösungsansätze
- Problem 2: Status und Lösungsansätze

## Erkenntnisse und Hinweise
- Erkenntnis 1
- Hinweis 1
EOL

  # Knowledge Graph JSON Template
  cat > "$MEMORY_BANK_DIR/templates/knowledgeGraph.json" << EOL
{
  "nodes": [],
  "edges": [],
  "metadata": {
    "version": "1.0.0",
    "created": "$(date -Iseconds)",
    "updated": "$(date -Iseconds)",
    "description": "Knowledge Graph für semantische Beziehungen zwischen Konzepten im Projekt"
  }
}
EOL

  # Sequential Thinking Config Template
  cat > "$MEMORY_BANK_DIR/templates/sequentialThinking.config" << EOL
{
  "mcpEndpoint": "http://localhost:3000/api/sequential-thinking",
  "maxSteps": 5,
  "storeHistory": true,
  "appendToActiveContext": true,
  "thinkingModels": {
    "problem-solving": {
      "steps": ["Problem verstehen", "Lösungsansätze entwickeln", "Optionen bewerten", "Lösungsplan erstellen", "Umsetzung planen"],
      "description": "Allgemeines Problemlösungsmodell für vielfältige Herausforderungen"
    },
    "code-design": {
      "steps": ["Anforderungen analysieren", "Schnittstellen definieren", "Komponenten entwerfen", "Datenstrukturen definieren", "Implementierungsplan erstellen"],
      "description": "Für Software-Design und Architekturentscheidungen"
    },
    "feature-planning": {
      "steps": ["Nutzerbedürfnisse verstehen", "Akzeptanzkriterien definieren", "Technische Machbarkeit prüfen", "Umsetzungsschritte planen", "Tests definieren"],
      "description": "Für die Planung neuer Features und Funktionen"
    }
  }
}
EOL

  # README für das Memory-Bank-System v2.0
  cat > "$MEMORY_BANK_DIR/README.md" << EOL
# Memory Bank System v2.0

Das Memory Bank System ist ein strukturierter Ansatz zur Speicherung und Verwaltung von Projektkontext für das CLAUDE-AGI-Ökosystem. Version 2.0 erweitert das System um Knowledge Graph APIs und Sequential Thinking für fortschrittliche Kontextverwaltung.

## Kern-Komponenten

### Strukturierte Markdown-Dokumente

Jedes Projekt verwendet die folgenden standardisierten Dateien:

- **projectbrief.md**: Grundlegende Projektdefinition und Ziele
- **activeContext.md**: Aktueller Arbeitsfokus und nächste Schritte
- **techContext.md**: Verwendete Technologien und ihre Konfiguration
- **systemPatterns.md**: Architektur und Design-Patterns
- **progress.md**: Fortschritt, abgeschlossene und geplante Aufgaben

### Knowledge Graph API

Die Knowledge Graph API ermöglicht es, semantische Beziehungen zwischen Konzepten im Projekt zu speichern und abzufragen:

- Konzepte und Beziehungen automatisch aus Projektdateien extrahieren
- Semantische Abfragen über verwandte Konzepte durchführen
- Visualisierungen des Projektwissens generieren

### Sequential Thinking API

Die Sequential Thinking API bietet strukturierte Denkprozesse mit MCP-Integration:

- Verschiedene Denkmodelle für unterschiedliche Problemtypen
- Integration mit dem Sequential Thinking MCP Tool
- Persistente Speicherung von Denkprozessen und Ergebnissen

## Verwendung

1. Kopiere die Templates in das memory-bank-Verzeichnis deines Projekts
2. Passe die Dateien an dein spezifisches Projekt an
3. Nutze die Memory-Bank APIs für fortgeschrittene Funktionen:
   - \`node apis/cli.js update /pfad/zum/projekt\`
   - \`node apis/cli.js extract-knowledge /pfad/zum/projekt\`
   - \`node apis/cli.js think "Wie löse ich Problem X?"\`
   - \`node apis/cli.js visualize-graph /pfad/zum/projekt\`

## Integration

Das Memory-Bank-System ist vollständig in das CLAUDE-AGI-Ökosystem integriert:

- Automatische Erkennung durch Claude Terminal
- MCP-Integration über memory-bank-mcp Tool
- Projekt-spezifische Memory-Banks in der standardisierten Struktur
- Fortschrittliche APIs für Knowledge Graph und Sequential Thinking
EOL

  # package.json für Memory Bank APIs erstellen
  cat > "$MEMORY_BANK_DIR/package.json" << EOL
{
  "name": "claude-agi-memory-bank",
  "version": "2.0.0",
  "description": "Memory Bank System mit Knowledge Graph und Sequential Thinking APIs für das CLAUDE-AGI-Ökosystem",
  "main": "apis/index.js",
  "scripts": {
    "update": "node apis/cli.js update",
    "extract-knowledge": "node apis/cli.js extract-knowledge",
    "think": "node apis/cli.js think",
    "visualize": "node apis/cli.js visualize-graph"
  },
  "dependencies": {
    "axios": "^1.6.2",
    "fs-extra": "^11.1.1"
  }
}
EOL

  # Installiere Abhängigkeiten, wenn möglich
  if command -v npm &> /dev/null; then
    log "INFO" "Installiere Memory Bank API Abhängigkeiten..."
    cd "$MEMORY_BANK_DIR" && npm install --no-fund --no-audit 2>/dev/null || {
      log "WARNING" "NPM-Installation fehlgeschlagen, versuche mit --legacy-peer-deps..."
      cd "$MEMORY_BANK_DIR" && npm install --legacy-peer-deps --no-fund --no-audit 2>/dev/null || {
        log "WARNING" "Memory Bank Abhängigkeiten konnten nicht installiert werden. Sie müssen später manuell installiert werden."
      }
    }
  else
    log "WARNING" "npm nicht gefunden. Memory Bank API Abhängigkeiten müssen manuell installiert werden."
  fi
  
  # Knowledge Graph API erstellen
  cat > "$MEMORY_BANK_DIR/apis/knowledgeGraphAPI.js" << 'EOL'
/**
 * Knowledge Graph API for CLAUDE AGI Memory Bank
 * 
 * This API provides functions for creating, managing, and querying a knowledge graph
 * to store semantic relationships between concepts in the CLAUDE AGI ecosystem.
 * 
 * Version: 1.0.0
 */

const fs = require('fs');
const path = require('path');

class KnowledgeGraphAPI {
  constructor(projectPath) {
    this.projectPath = projectPath;
    this.graphPath = path.join(projectPath, 'memory-bank', 'knowledgeGraph.json');
    this.graph = this.loadGraph();
  }

  /**
   * Load the knowledge graph from disk
   */
  loadGraph() {
    try {
      if (fs.existsSync(this.graphPath)) {
        const data = fs.readFileSync(this.graphPath, 'utf8');
        return JSON.parse(data);
      }
      
      // Initialize empty graph if none exists
      return {
        nodes: [],
        edges: [],
        metadata: {
          version: '1.0.0',
          created: new Date().toISOString(),
          updated: new Date().toISOString()
        }
      };
    } catch (error) {
      console.error(`Error loading knowledge graph: ${error.message}`);
      return {
        nodes: [],
        edges: [],
        metadata: {
          version: '1.0.0',
          created: new Date().toISOString(),
          updated: new Date().toISOString()
        }
      };
    }
  }

  /**
   * Save the current graph to disk
   */
  saveGraph() {
    try {
      // Update the 'updated' timestamp
      this.graph.metadata.updated = new Date().toISOString();
      
      // Ensure the directory exists
      const dir = path.dirname(this.graphPath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      
      fs.writeFileSync(this.graphPath, JSON.stringify(this.graph, null, 2), 'utf8');
      return true;
    } catch (error) {
      console.error(`Error saving knowledge graph: ${error.message}`);
      return false;
    }
  }

  /**
   * Add a new concept node to the graph
   * @param {string} concept - The concept name
   * @param {string} type - The type of the concept (e.g., 'component', 'technology', 'feature')
   * @param {Object} properties - Additional properties of the concept
   * @returns {string} The ID of the newly created node
   */
  addConcept(concept, type, properties = {}) {
    const id = `${type}_${concept.replace(/\s+/g, '_').toLowerCase()}`;
    
    // Check if the node already exists
    const existingNode = this.graph.nodes.find(node => node.id === id);
    if (existingNode) {
      // Update existing node
      existingNode.properties = { ...existingNode.properties, ...properties };
      existingNode.updated = new Date().toISOString();
      this.saveGraph();
      return id;
    }
    
    // Create new node
    const newNode = {
      id,
      concept,
      type,
      properties,
      created: new Date().toISOString(),
      updated: new Date().toISOString()
    };
    
    this.graph.nodes.push(newNode);
    this.saveGraph();
    return id;
  }

  /**
   * Add a relationship between two concepts
   * @param {string} sourceId - The ID of the source node
   * @param {string} targetId - The ID of the target node
   * @param {string} relationship - The type of relationship
   * @param {Object} properties - Additional properties of the relationship
   * @returns {boolean} Success of the operation
   */
  addRelationship(sourceId, targetId, relationship, properties = {}) {
    // Validate that both nodes exist
    const sourceExists = this.graph.nodes.some(node => node.id === sourceId);
    const targetExists = this.graph.nodes.some(node => node.id === targetId);
    
    if (!sourceExists || !targetExists) {
      console.error(`Cannot create relationship: one or both nodes don't exist`);
      return false;
    }
    
    const edgeId = `${sourceId}_${relationship}_${targetId}`;
    
    // Check if the edge already exists
    const existingEdge = this.graph.edges.find(edge => edge.id === edgeId);
    if (existingEdge) {
      // Update existing edge
      existingEdge.properties = { ...existingEdge.properties, ...properties };
      existingEdge.updated = new Date().toISOString();
      this.saveGraph();
      return true;
    }
    
    // Create new edge
    const newEdge = {
      id: edgeId,
      source: sourceId,
      target: targetId,
      relationship,
      properties,
      created: new Date().toISOString(),
      updated: new Date().toISOString()
    };
    
    this.graph.edges.push(newEdge);
    this.saveGraph();
    return true;
  }

  /**
   * Query the graph for nodes that match given criteria
   * @param {Object} criteria - Criteria to match against node properties
   * @returns {Array} Matching nodes
   */
  queryConcepts(criteria = {}) {
    return this.graph.nodes.filter(node => {
      for (const [key, value] of Object.entries(criteria)) {
        if (key === 'properties') {
          for (const [propKey, propValue] of Object.entries(value)) {
            if (!node.properties || node.properties[propKey] !== propValue) {
              return false;
            }
          }
        } else if (node[key] !== value) {
          return false;
        }
      }
      return true;
    });
  }

  /**
   * Find all relationships for a given concept
   * @param {string} conceptId - The ID of the concept
   * @returns {Object} Object containing incoming and outgoing relationships
   */
  getConceptRelationships(conceptId) {
    const outgoing = this.graph.edges.filter(edge => edge.source === conceptId);
    const incoming = this.graph.edges.filter(edge => edge.target === conceptId);
    
    return { outgoing, incoming };
  }

  /**
   * Find the shortest path between two concepts
   * @param {string} sourceId - Starting concept ID
   * @param {string} targetId - Target concept ID
   * @returns {Array|null} Array of nodes and edges in the path, or null if no path exists
   */
  findShortestPath(sourceId, targetId) {
    if (sourceId === targetId) {
      return [{ node: this.graph.nodes.find(node => node.id === sourceId) }];
    }
    
    // Breadth-first search
    const queue = [{ node: sourceId, path: [{ node: sourceId }] }];
    const visited = new Set([sourceId]);
    
    while (queue.length > 0) {
      const { node: currentId, path } = queue.shift();
      
      // Get all connected nodes (both outgoing and incoming)
      const outgoingEdges = this.graph.edges.filter(edge => edge.source === currentId);
      
      for (const edge of outgoingEdges) {
        if (edge.target === targetId) {
          // Found the target
          const finalNode = this.graph.nodes.find(node => node.id === targetId);
          return [
            ...path,
            { 
              edge,
              direction: 'outgoing'
            },
            { 
              node: finalNode
            }
          ];
        }
        
        if (!visited.has(edge.target)) {
          visited.add(edge.target);
          const nextNode = this.graph.nodes.find(node => node.id === edge.target);
          queue.push({
            node: edge.target,
            path: [
              ...path,
              { 
                edge,
                direction: 'outgoing'
              },
              { 
                node: nextNode
              }
            ]
          });
        }
      }
      
      // Also check incoming edges
      const incomingEdges = this.graph.edges.filter(edge => edge.target === currentId);
      
      for (const edge of incomingEdges) {
        if (edge.source === targetId) {
          // Found the target
          const finalNode = this.graph.nodes.find(node => node.id === targetId);
          return [
            ...path,
            { 
              edge,
              direction: 'incoming'
            },
            { 
              node: finalNode
            }
          ];
        }
        
        if (!visited.has(edge.source)) {
          visited.add(edge.source);
          const nextNode = this.graph.nodes.find(node => node.id === edge.source);
          queue.push({
            node: edge.source,
            path: [
              ...path,
              { 
                edge,
                direction: 'incoming'
              },
              { 
                node: nextNode
              }
            ]
          });
        }
      }
    }
    
    // No path found
    return null;
  }

  /**
   * Extract concepts from a markdown text and add them to the graph
   * @param {string} text - Markdown text to analyze
   * @param {string} type - Default type for extracted concepts
   * @param {Array} existingConcepts - List of existing concepts to match against
   * @returns {Array} Newly identified concepts
   */
  extractConceptsFromText(text, type = 'concept', existingConcepts = []) {
    // Get all existing concept names for matching
    const existingNames = existingConcepts.length > 0 
      ? existingConcepts 
      : this.graph.nodes.map(node => node.concept);
    
    // Simple extraction strategy - look for capitalized phrases and items in lists
    const capitalizedRegex = /\b[A-Z][a-zA-Z0-9]+([ -][A-Z][a-zA-Z0-9]+)*\b/g;
    const listItemRegex = /[*-]\s+([A-Z][a-zA-Z0-9]+([ -][a-zA-Z0-9]+)*)/g;
    
    const conceptMatches = [
      ...(text.match(capitalizedRegex) || []),
      ...((text.match(listItemRegex) || []).map(match => match.replace(/[*-]\s+/, '')))
    ];
    
    // Filter for unique concepts and remove any that already exist
    const uniqueConcepts = [...new Set(conceptMatches)]
      .filter(concept => !existingNames.includes(concept));
    
    // Add each new concept
    const addedConcepts = [];
    
    for (const concept of uniqueConcepts) {
      const id = this.addConcept(concept, type, {
        extractedFrom: 'text',
        confidence: 'low'
      });
      
      addedConcepts.push({
        id,
        concept
      });
    }
    
    return addedConcepts;
  }

  /**
   * Update the graph with concepts extracted from all memory bank text files
   * @returns {Object} Summary of updates made
   */
  updateFromMemoryBank() {
    const memoryBankPath = path.join(this.projectPath, 'memory-bank');
    const fileTypes = [
      'activeContext.md',
      'productContext.md',
      'projectbrief.md',
      'systemPatterns.md',
      'techContext.md',
      'progress.md'
    ];
    
    const summary = {
      filesProcessed: 0,
      conceptsAdded: 0,
      relationshipsAdded: 0
    };
    
    for (const fileType of fileTypes) {
      const filePath = path.join(memoryBankPath, fileType);
      
      if (fs.existsSync(filePath)) {
        try {
          const content = fs.readFileSync(filePath, 'utf8');
          
          // Determine concept type based on file
          let conceptType = 'concept';
          if (fileType === 'techContext.md') conceptType = 'technology';
          if (fileType === 'systemPatterns.md') conceptType = 'pattern';
          if (fileType === 'productContext.md') conceptType = 'feature';
          
          const addedConcepts = this.extractConceptsFromText(content, conceptType);
          summary.conceptsAdded += addedConcepts.length;
          
          // If this is a new file being processed, add a relationship from the file to the concepts
          const fileNodeId = `file_${fileType.replace('.md', '')}`;
          const fileExists = this.graph.nodes.some(node => node.id === fileNodeId);
          
          if (!fileExists) {
            this.addConcept(fileType.replace('.md', ''), 'file', {
              path: filePath,
              type: 'memory-bank-file'
            });
            
            // Add relationships from file to concepts
            for (const { id } of addedConcepts) {
              this.addRelationship(fileNodeId, id, 'contains');
              summary.relationshipsAdded++;
            }
          }
          
          summary.filesProcessed++;
        } catch (error) {
          console.error(`Error processing ${filePath}: ${error.message}`);
        }
      }
    }
    
    return summary;
  }

  /**
   * Generate a visual representation of the graph
   * @param {string} format - Output format ('json', 'graphviz', 'html')
   * @returns {string} Graph representation in the specified format
   */
  visualize(format = 'json') {
    if (format === 'json') {
      return JSON.stringify(this.graph, null, 2);
    }
    
    if (format === 'graphviz') {
      let dot = 'digraph G {\n';
      
      // Add nodes
      for (const node of this.graph.nodes) {
        const label = `${node.concept} (${node.type})`;
        dot += `  "${node.id}" [label="${label}"];\n`;
      }
      
      // Add edges
      for (const edge of this.graph.edges) {
        dot += `  "${edge.source}" -> "${edge.target}" [label="${edge.relationship}"];\n`;
      }
      
      dot += '}';
      return dot;
    }
    
    if (format === 'html') {
      return `
<!DOCTYPE html>
<html>
<head>
  <title>Knowledge Graph Visualization</title>
  <style>
    body { font-family: sans-serif; }
    #graph { width: 100%; height: 600px; border: 1px solid #ccc; }
    .info { padding: 10px; background: #f5f5f5; border-radius: 5px; }
  </style>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/vis-network/9.1.2/vis-network.min.js"></script>
</head>
<body>
  <h1>Knowledge Graph Visualization</h1>
  <div class="info">
    <p>Nodes: ${this.graph.nodes.length} | Edges: ${this.graph.edges.length}</p>
  </div>
  <div id="graph"></div>
  
  <script>
    const graph = ${JSON.stringify(this.graph)};
    
    // Prepare data for visualization
    const nodes = graph.nodes.map(node => ({
      id: node.id,
      label: node.concept,
      title: \`Type: \${node.type}<br>Properties: \${JSON.stringify(node.properties)}\`,
      group: node.type
    }));
    
    const edges = graph.edges.map(edge => ({
      from: edge.source,
      to: edge.target,
      label: edge.relationship,
      arrows: 'to'
    }));
    
    // Create network
    const container = document.getElementById('graph');
    const data = { nodes, edges };
    const options = {
      nodes: {
        shape: 'dot',
        size: 16
      },
      physics: {
        stabilization: false,
        barnesHut: {
          gravitationalConstant: -80,
          springConstant: 0.001,
          springLength: 200
        }
      }
    };
    
    new vis.Network(container, data, options);
  </script>
</body>
</html>
      `.trim();
    }
    
    return this.graph;
  }
}

module.exports = KnowledgeGraphAPI;
EOL

  log "INFO" "Knowledge Graph API erstellt."
  
  # Sequential Thinking API erstellen
  cat > "$MEMORY_BANK_DIR/apis/sequentialThinkingAPI.js" << 'EOL'
/**
 * Sequential Thinking API for CLAUDE AGI Memory Bank
 * 
 * This API provides an interface for structured problem-solving with sequential thinking.
 * It integrates with the Sequential Thinking MCP tool and persists reasoning steps in the memory bank.
 * 
 * Version: 1.0.0
 */

const fs = require('fs');
const path = require('path');
const axios = require('axios');

class SequentialThinkingAPI {
  constructor(projectPath, config = {}) {
    this.projectPath = projectPath;
    this.configPath = path.join(projectPath, 'memory-bank', 'sequentialThinking.config');
    this.historyPath = path.join(projectPath, 'memory-bank', 'sequentialThinking.history.json');
    
    // Default config
    this.config = {
      mcpEndpoint: 'http://localhost:3000/api/sequential-thinking',
      maxSteps: 5,
      storeHistory: true,
      appendToActiveContext: true,
      ...config
    };
    
    this.loadConfig();
    this.history = this.loadHistory();
  }

  /**
   * Load configuration from disk
   */
  loadConfig() {
    try {
      if (fs.existsSync(this.configPath)) {
        const data = fs.readFileSync(this.configPath, 'utf8');
        const loadedConfig = JSON.parse(data);
        this.config = { ...this.config, ...loadedConfig };
      } else {
        // Save default config
        this.saveConfig();
      }
    } catch (error) {
      console.error(`Error loading sequential thinking config: ${error.message}`);
    }
  }

  /**
   * Save configuration to disk
   */
  saveConfig() {
    try {
      const dir = path.dirname(this.configPath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      
      fs.writeFileSync(this.configPath, JSON.stringify(this.config, null, 2), 'utf8');
      return true;
    } catch (error) {
      console.error(`Error saving sequential thinking config: ${error.message}`);
      return false;
    }
  }

  /**
   * Load thinking history from disk
   */
  loadHistory() {
    try {
      if (fs.existsSync(this.historyPath)) {
        const data = fs.readFileSync(this.historyPath, 'utf8');
        return JSON.parse(data);
      }
      
      return [];
    } catch (error) {
      console.error(`Error loading sequential thinking history: ${error.message}`);
      return [];
    }
  }

  /**
   * Save thinking history to disk
   */
  saveHistory() {
    if (!this.config.storeHistory) return false;
    
    try {
      const dir = path.dirname(this.historyPath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      
      fs.writeFileSync(this.historyPath, JSON.stringify(this.history, null, 2), 'utf8');
      return true;
    } catch (error) {
      console.error(`Error saving sequential thinking history: ${error.message}`);
      return false;
    }
  }

  /**
   * Add a thinking session to history
   * @param {Object} session - The thinking session to add
   */
  addToHistory(session) {
    if (!this.config.storeHistory) return;
    
    this.history.push(session);
    while (this.history.length > 50) { // Keep only the last 50 sessions
      this.history.shift();
    }
    
    this.saveHistory();
  }

  /**
   * Execute a sequential thinking process
   * @param {string} problem - The problem to solve
   * @param {Object} options - Additional options
   * @returns {Object} The thinking session result
   */
  async think(problem, options = {}) {
    const sessionOptions = {
      steps: this.config.maxSteps,
      appendToActiveContext: this.config.appendToActiveContext,
      ...options
    };
    
    // Initialize session
    const session = {
      id: `thinking_${Date.now()}`,
      problem,
      options: sessionOptions,
      steps: [],
      conclusion: null,
      created: new Date().toISOString()
    };
    
    try {
      // Use MCP Sequential Thinking if available
      if (this.config.mcpEndpoint) {
        const response = await this.callMcpService(problem, sessionOptions);
        
        if (response && response.data) {
          const { steps, conclusion } = response.data;
          session.steps = steps;
          session.conclusion = conclusion;
        }
      } else {
        // Fallback to structured format without MCP
        session.steps = [
          {
            id: 1,
            title: 'Problem Analysis',
            content: `Analyzing the problem: ${problem}`
          },
          {
            id: 2,
            title: 'Potential Approaches',
            content: 'Listing potential approaches to solving this problem.'
          }
        ];
        session.conclusion = 'No MCP service available for sequential thinking. This is a placeholder conclusion.';
      }
      
      // Update session
      session.completed = new Date().toISOString();
      
      // Store in history
      this.addToHistory(session);
      
      // Append to active context if configured
      if (sessionOptions.appendToActiveContext) {
        this.appendToActiveContext(session);
      }
      
      return session;
    } catch (error) {
      console.error(`Error in sequential thinking: ${error.message}`);
      
      // Create error session
      session.error = error.message;
      session.completed = new Date().toISOString();
      this.addToHistory(session);
      
      throw error;
    }
  }

  /**
   * Call the MCP Sequential Thinking service
   * @param {string} problem - The problem to solve
   * @param {Object} options - Additional options
   * @returns {Object} The service response
   */
  async callMcpService(problem, options) {
    try {
      const response = await axios.post(this.config.mcpEndpoint, {
        problem,
        options
      });
      
      return response;
    } catch (error) {
      console.error(`Error calling Sequential Thinking MCP: ${error.message}`);
      throw error;
    }
  }

  /**
   * Append thinking result to active context
   * @param {Object} session - The thinking session
   */
  appendToActiveContext(session) {
    const activeContextPath = path.join(this.projectPath, 'memory-bank', 'activeContext.md');
    
    try {
      let content = '';
      if (fs.existsSync(activeContextPath)) {
        content = fs.readFileSync(activeContextPath, 'utf8');
      }
      
      // Create markdown for the thinking session
      let thinkingMd = `\n\n## Sequential Thinking: ${session.problem}\n`;
      thinkingMd += `*Generated at: ${new Date(session.created).toLocaleString()}*\n\n`;
      
      // Add steps
      session.steps.forEach(step => {
        thinkingMd += `### Step ${step.id}: ${step.title}\n`;
        thinkingMd += `${step.content}\n\n`;
      });
      
      // Add conclusion
      thinkingMd += `### Conclusion\n`;
      thinkingMd += `${session.conclusion}\n`;
      
      // Write back to file
      fs.writeFileSync(activeContextPath, content + thinkingMd, 'utf8');
      
      return true;
    } catch (error) {
      console.error(`Error appending to active context: ${error.message}`);
      return false;
    }
  }

  /**
   * Get thinking history for a specific problem or all history
   * @param {string} problemSearch - Optional problem text to search for
   * @returns {Array} Matching thinking sessions
   */
  getHistory(problemSearch) {
    if (!problemSearch) {
      return this.history;
    }
    
    return this.history.filter(session => 
      session.problem.toLowerCase().includes(problemSearch.toLowerCase())
    );
  }

  /**
   * Create a new sequential thinking configuration
   * @param {Object} config - Configuration options
   * @returns {boolean} Success of the operation
   */
  updateConfig(config) {
    this.config = {
      ...this.config,
      ...config
    };
    
    return this.saveConfig();
  }
}

module.exports = SequentialThinkingAPI;
EOL

  log "INFO" "Sequential Thinking API erstellt."
  
  # CLI Tool für Memory Bank APIs erstellen
  cat > "$MEMORY_BANK_DIR/apis/cli.js" << 'EOL'
#!/usr/bin/env node

/**
 * Memory Bank CLI
 * 
 * A command-line tool for managing and interacting with the CLAUDE AGI Memory Bank.
 * 
 * Usage:
 *   node cli.js <command> [options]
 * 
 * Commands:
 *   update              Update memory bank files and knowledge graph
 *   extract-knowledge   Extract knowledge from memory bank into knowledge graph
 *   think               Apply sequential thinking to a problem
 *   visualize-graph     Generate visualization of the knowledge graph
 */

const fs = require('fs');
const path = require('path');
const KnowledgeGraphAPI = require('./knowledgeGraphAPI');
const SequentialThinkingAPI = require('./sequentialThinkingAPI');

// Parse command line arguments
const args = process.argv.slice(2);
const command = args[0];
const options = args.slice(1);

// Get current date/time formatted
function getFormattedDateTime() {
  const now = new Date();
  return now.toISOString().replace(/T/, ' ').replace(/\..+/, '');
}

// Handle update command
async function handleUpdate(projectPath) {
  try {
    console.log(`Updating memory bank for: ${projectPath}`);
    console.log(`[${getFormattedDateTime()}] Starting update...`);
    
    // Check if project path exists
    if (!fs.existsSync(projectPath)) {
      console.error(`Error: Project path ${projectPath} does not exist.`);
      process.exit(1);
    }
    
    // Memory bank path
    const memoryBankPath = path.join(projectPath, 'memory-bank');
    if (!fs.existsSync(memoryBankPath)) {
      console.error(`Error: Memory bank not found at ${memoryBankPath}`);
      process.exit(1);
    }
    
    // Update active context timestamp
    const activeContextPath = path.join(memoryBankPath, 'activeContext.md');
    if (fs.existsSync(activeContextPath)) {
      let content = fs.readFileSync(activeContextPath, 'utf8');
      const lastUpdatedSection = `\n\n## Last Updated\n\n${getFormattedDateTime()}\n`;
      
      // Check if Last Updated section exists
      if (content.includes('## Last Updated')) {
        // Replace existing section
        content = content.replace(/## Last Updated[\s\S]*?(?=\n## |$)/, lastUpdatedSection);
      } else {
        // Add new section
        content += lastUpdatedSection;
      }
      
      fs.writeFileSync(activeContextPath, content);
      console.log(`Updated activeContext.md with timestamp`);
    }
    
    // Update knowledge graph
    const knowledgeGraph = new KnowledgeGraphAPI(projectPath);
    const updateSummary = knowledgeGraph.updateFromMemoryBank();
    
    console.log(`Knowledge graph update complete:`);
    console.log(`- Files processed: ${updateSummary.filesProcessed}`);
    console.log(`- Concepts added: ${updateSummary.conceptsAdded}`);
    console.log(`- Relationships added: ${updateSummary.relationshipsAdded}`);
    
    console.log(`[${getFormattedDateTime()}] Memory bank update completed.`);
    return true;
  } catch (error) {
    console.error(`Error updating memory bank: ${error.message}`);
    return false;
  }
}

// Handle extract-knowledge command
async function handleExtractKnowledge(projectPath) {
  try {
    console.log(`Extracting knowledge from: ${projectPath}`);
    console.log(`[${getFormattedDateTime()}] Starting knowledge extraction...`);
    
    // Check if project path exists
    if (!fs.existsSync(projectPath)) {
      console.error(`Error: Project path ${projectPath} does not exist.`);
      process.exit(1);
    }
    
    // Initialize knowledge graph
    const knowledgeGraph = new KnowledgeGraphAPI(projectPath);
    
    // Process all markdown files in project
    const processDirectory = (dirPath, depth = 0) => {
      if (depth > 3) return; // Limit recursion depth
      
      const files = fs.readdirSync(dirPath);
      let totalConcepts = 0;
      
      for (const file of files) {
        const filePath = path.join(dirPath, file);
        const stat = fs.statSync(filePath);
        
        if (stat.isDirectory() && !file.startsWith('.') && file !== 'node_modules') {
          processDirectory(filePath, depth + 1);
        } else if (file.endsWith('.md')) {
          try {
            const content = fs.readFileSync(filePath, 'utf8');
            const fileType = path.basename(file, '.md');
            const conceptType = fileType.includes('tech') ? 'technology' : 
                              fileType.includes('system') ? 'pattern' :
                              fileType.includes('product') ? 'feature' : 'concept';
            
            const extractedConcepts = knowledgeGraph.extractConceptsFromText(content, conceptType);
            totalConcepts += extractedConcepts.length;
            
            console.log(`Processed ${file}: found ${extractedConcepts.length} concepts`);
          } catch (err) {
            console.error(`Error processing ${filePath}: ${err.message}`);
          }
        }
      }
      
      return totalConcepts;
    };
    
    const totalExtracted = processDirectory(projectPath);
    console.log(`Total concepts extracted: ${totalExtracted}`);
    
    console.log(`[${getFormattedDateTime()}] Knowledge extraction completed.`);
    return true;
  } catch (error) {
    console.error(`Error extracting knowledge: ${error.message}`);
    return false;
  }
}

// Handle think command
async function handleThink(problem, modelType = 'problem-solving') {
  try {
    console.log(`Applying sequential thinking to problem: "${problem}"`);
    console.log(`Using thinking model: ${modelType}`);
    console.log(`[${getFormattedDateTime()}] Starting thinking process...`);
    
    // Get current directory as default project path
    const projectPath = process.cwd();
    
    // Initialize sequential thinking
    const thinking = new SequentialThinkingAPI(projectPath);
    
    // Apply thinking
    const session = await thinking.think(problem, { 
      model: modelType,
      appendToActiveContext: true
    });
    
    console.log('\n=== Thinking Process ===\n');
    
    // Print steps
    for (const step of session.steps) {
      console.log(`\n### Step ${step.id}: ${step.title}`);
      console.log(step.content);
    }
    
    // Print conclusion
    console.log('\n### Conclusion');
    console.log(session.conclusion);
    
    console.log(`\n[${getFormattedDateTime()}] Thinking process completed.`);
    return true;
  } catch (error) {
    console.error(`Error in sequential thinking: ${error.message}`);
    return false;
  }
}

// Handle visualize-graph command
async function handleVisualizeGraph(projectPath, format = 'html', output = 'knowledge-graph') {
  try {
    console.log(`Visualizing knowledge graph for: ${projectPath}`);
    console.log(`Format: ${format}, Output: ${output}`);
    console.log(`[${getFormattedDateTime()}] Starting visualization...`);
    
    // Check if project path exists
    if (!fs.existsSync(projectPath)) {
      console.error(`Error: Project path ${projectPath} does not exist.`);
      process.exit(1);
    }
    
    // Initialize knowledge graph
    const knowledgeGraph = new KnowledgeGraphAPI(projectPath);
    
    // Generate visualization
    const visualization = knowledgeGraph.visualize(format);
    
    // Add file extension based on format
    let fileName = output;
    if (format === 'html' && !fileName.endsWith('.html')) {
      fileName += '.html';
    } else if (format === 'json' && !fileName.endsWith('.json')) {
      fileName += '.json';
    } else if (format === 'graphviz' && !fileName.endsWith('.dot')) {
      fileName += '.dot';
    }
    
    // Write to file
    fs.writeFileSync(fileName, visualization);
    
    console.log(`Visualization saved to: ${fileName}`);
    console.log(`[${getFormattedDateTime()}] Visualization completed.`);
    return true;
  } catch (error) {
    console.error(`Error visualizing knowledge graph: ${error.message}`);
    return false;
  }
}

// Main function
async function main() {
  try {
    switch (command) {
      case 'update':
        if (options.length === 0) {
          console.error('Error: Project path is required for update command.');
          process.exit(1);
        }
        await handleUpdate(options[0]);
        break;
      
      case 'extract-knowledge':
        if (options.length === 0) {
          console.error('Error: Project path is required for extract-knowledge command.');
          process.exit(1);
        }
        await handleExtractKnowledge(options[0]);
        break;
      
      case 'think':
        if (options.length === 0) {
          console.error('Error: Problem statement is required for think command.');
          process.exit(1);
        }
        const problem = options[0];
        const model = options[1] || 'problem-solving';
        await handleThink(problem, model);
        break;
      
      case 'visualize-graph':
        if (options.length === 0) {
          console.error('Error: Project path is required for visualize-graph command.');
          process.exit(1);
        }
        const projectPath = options[0];
        
        // Parse format option (--format=html)
        let format = 'html';
        const formatOption = options.find(opt => opt.startsWith('--format='));
        if (formatOption) {
          format = formatOption.split('=')[1];
        }
        
        // Parse output option (--output=filename)
        let output = 'knowledge-graph';
        const outputOption = options.find(opt => opt.startsWith('--output='));
        if (outputOption) {
          output = outputOption.split('=')[1];
        }
        
        await handleVisualizeGraph(projectPath, format, output);
        break;
      
      case '--help':
      case '-h':
      case 'help':
        showHelp();
        break;
      
      default:
        console.error(`Unknown command: ${command}`);
        showHelp();
        process.exit(1);
    }
  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

// Show help message
function showHelp() {
  console.log(`
Memory Bank CLI - v2.0.0

Usage:
  node cli.js <command> [options]

Commands:
  update <project-path>              Update memory bank files and knowledge graph
  extract-knowledge <project-path>   Extract knowledge from memory bank into knowledge graph
  think <problem> [model-type]       Apply sequential thinking to a problem
  visualize-graph <project-path>     Generate visualization of the knowledge graph
                   [--format=html|json|graphviz] 
                   [--output=filename]
  help                               Show this help message

Examples:
  node cli.js update /path/to/project
  node cli.js extract-knowledge /path/to/project
  node cli.js think "How to improve app performance?" code-design
  node cli.js visualize-graph /path/to/project --format=html --output=graph.html
  `);
}

// Execute main function
main();
EOL

  # Mache CLI-Skript ausführbar
  chmod +x "$MEMORY_BANK_DIR/apis/cli.js"
  
  # Erstelle index.js zum Exportieren aller APIs
  cat > "$MEMORY_BANK_DIR/apis/index.js" << 'EOL'
/**
 * Memory Bank API
 * 
 * Unified interface for the CLAUDE AGI Memory Bank System.
 * 
 * Version: 2.0.0
 */

const fs = require('fs');
const path = require('path');
const KnowledgeGraphAPI = require('./knowledgeGraphAPI');
const SequentialThinkingAPI = require('./sequentialThinkingAPI');

/**
 * Initialize a memory bank for a project
 * @param {string} projectPath - Path to the project
 * @param {boolean} useTemplates - Whether to copy templates if not exists
 */
function initMemoryBank(projectPath, useTemplates = true) {
  // Check if project exists
  if (!fs.existsSync(projectPath)) {
    throw new Error(`Project path does not exist: ${projectPath}`);
  }
  
  // Create memory-bank directory if it doesn't exist
  const memoryBankPath = path.join(projectPath, 'memory-bank');
  if (!fs.existsSync(memoryBankPath)) {
    fs.mkdirSync(memoryBankPath, { recursive: true });
    console.log(`Created memory-bank directory at ${memoryBankPath}`);
  }
  
  // Use templates if requested
  if (useTemplates) {
    const templateBaseDir = path.resolve(__dirname, '..', 'templates');
    if (fs.existsSync(templateBaseDir)) {
      const files = fs.readdirSync(templateBaseDir);
      
      for (const file of files) {
        const sourcePath = path.join(templateBaseDir, file);
        const targetPath = path.join(memoryBankPath, file);
        
        // Skip if file already exists
        if (fs.existsSync(targetPath)) {
          continue;
        }
        
        // Copy template file
        fs.copyFileSync(sourcePath, targetPath);
        console.log(`Copied template: ${file}`);
      }
    } else {
      console.warn(`Templates directory not found: ${templateBaseDir}`);
    }
  }
  
  // Initialize Knowledge Graph API
  const knowledgeGraph = new KnowledgeGraphAPI(projectPath);
  const sequentialThinking = new SequentialThinkingAPI(projectPath);
  
  return {
    knowledgeGraph,
    sequentialThinking,
    projectPath,
    memoryBankPath
  };
}

/**
 * Create a new memory bank from scratch
 * @param {string} projectPath - Path to the project
 * @param {string} projectName - Name of the project
 */
function createMemoryBank(projectPath, projectName) {
  // Ensure project directory exists
  if (!fs.existsSync(projectPath)) {
    fs.mkdirSync(projectPath, { recursive: true });
  }
  
  // Initialize memory bank
  const memoryBank = initMemoryBank(projectPath);
  
  // Update projectbrief.md with project name
  const projectBriefPath = path.join(memoryBank.memoryBankPath, 'projectbrief.md');
  if (fs.existsSync(projectBriefPath)) {
    let content = fs.readFileSync(projectBriefPath, 'utf8');
    content = content.replace(/# \[Projektname\]/, `# ${projectName}`);
    fs.writeFileSync(projectBriefPath, content);
  }
  
  return memoryBank;
}

// Export module
module.exports = {
  KnowledgeGraphAPI,
  SequentialThinkingAPI,
  initMemoryBank,
  createMemoryBank
};
EOL

  log "INFO" "Memory Bank CLI und Index erstellt."

  log "SUCCESS" "Memory-Bank-Struktur erstellt."
}

# Standardisierte Projektstruktur erstellen
create_standardized_structure() {
  log "INFO" "Erstelle standardisierte Projektstruktur..."
  
  # Memory-Bank erstellen
  create_memory_bank
  
  # Hauptprojekte-Verzeichnis
  mkdir -p "$AGI_PROJECTS_DIR"
  
  # Standardprojekt
  mkdir -p "$DEFAULT_PROJECT_DIR/memory-bank"
  
  # Kopiere Memory-Bank-Templates
  if [ -d "$MEMORY_BANK_DIR/templates" ]; then
    cp -r "$MEMORY_BANK_DIR/templates"/* "$DEFAULT_PROJECT_DIR/memory-bank/" 2>/dev/null || true
  fi
  
  # Projektkonfiguration erstellen
  cat > "$AGI_PROJECTS_DIR/.project-config.json" << EOL
{
  "version": "1.0.0",
  "defaultProjectPath": "$DEFAULT_PROJECT_DIR",
  "autoSwitchToProject": true,
  "allowedDirectories": [
    "$AGI_PROJECTS_DIR"
  ],
  "excludedPatterns": [
    "**/node_modules/**",
    "**/.git/**",
    "**/.env*",
    "**/goldankauf/**",
    "**/aclearallb.gg/**",
    "**/sj-bandolerosz/**",
    "**/deepsleeping/**"
  ],
  "memoryBankConfig": {
    "root": "$MEMORY_BANK_DIR",
    "projectMemoryPath": "claude-agi-projects/{projectName}/memory-bank"
  }
}
EOL
  
  log "SUCCESS" "Standardisierte Projektstruktur erstellt."
}

# MCP-Konfiguration aktualisieren
update_mcp_config() {
  log "INFO" "Aktualisiere MCP-Konfiguration für neue Struktur..."
  
  # Verzeichnis für Konfigurationsdatei erstellen
  mkdir -p "$CONFIG_DIR"
  
  # MCP-Konfigurationsdatei erstellen
  cat > "$CONFIG_DIR/claude_desktop_config.json" << EOL
{
  "mcpServers": {
    "memory-bank": {
      "command": "npx",
      "args": ["-y", "@alioshr/memory-bank-mcp"],
      "env": {
        "MEMORY_BANK_ROOT": "$MEMORY_BANK_DIR"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem"],
      "env": {
        "ALLOWED_DIRECTORIES": "$AGI_PROJECTS_DIR"
      }
    },
    "proxyclaude": {
      "command": "npx",
      "args": ["-y", "@proxyclaude/mcp-server@latest"],
      "env": {
        "API_ENDPOINT": "http://localhost:4001",
        "MAX_RETRIES": "3"
      }
    },
    "browser-tools": {
      "command": "npx",
      "args": ["-y", "@agentdeskai/browser-tools-mcp@latest"]
    },
    "desktop-commander": {
      "command": "npx",
      "args": ["-y", "@wonderwhy-er/desktop-commander"],
      "env": {
        "WORKSPACE_PATH": "$AGI_PROJECTS_DIR"
      }
    },
    "code-mcp": {
      "command": "npx",
      "args": ["-y", "@block/code-mcp"]
    },
    "sequentialthinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "context7-mcp": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@searchweb/brave-mcp", "--profile", "default"]
    },
    "marketing-tools": {
      "command": "uvx",
      "args": [
        "--from",
        "git+https://github.com/open-strategy-partners/osp_marketing_tools@main",
        "osp_marketing_tools"
      ]
    }
  }
}
EOL

  # Kopiere Konfiguration nach CLAUDE/.config/
  mkdir -p "$CLAUDE_DIR/.config"
  cp "$CONFIG_DIR/claude_desktop_config.json" "$CLAUDE_DIR/.config/"
  
  log "SUCCESS" "MCP-Konfiguration aktualisiert."
}

# Terminal-Anpassungen für neue Struktur
adapt_terminal_for_structure() {
  log "INFO" "Passe Terminal für neue Projektstruktur an..."
  
  # Aktualisiere Terminal-Einstellungen
  if [ -f "$TERMINAL_DIR/src/config/settings.json" ]; then
    cat > "$TERMINAL_DIR/src/config/settings.json" << EOL
{
  "defaultWorkspacePath": "$AGI_PROJECTS_DIR",
  "autoLoadDefaultProject": true,
  "memoryBankPath": "$MEMORY_BANK_DIR",
  "projectConfigFile": "$AGI_PROJECTS_DIR/.project-config.json",
  "excludedPatterns": [
    "**/goldankauf/**",
    "**/aclearallb.gg/**",
    "**/sj-bandolerosz/**",
    "**/deepsleeping/**"
  ]
}
EOL
  fi
  
  log "SUCCESS" "Terminal für neue Struktur angepasst."
}

# Sichere Datenmigration
secure_data_migration() {
  log "INFO" "Prüfe sensible Daten für Migration..."
  
  # Prüfe auf sensible Projektdaten
  if [ -d "$CLAUDE_DIR/goldankauf" ] || \
     [ -d "$CLAUDE_DIR/aclearallb.gg" ] || \
     [ -d "$CLAUDE_DIR/deepsleeping" ] || \
     [ -d "$CLAUDE_DIR/sj-bandolerosz" ]; then
    
    log "WARNING" "Sensible Projektdaten gefunden. Sichere vor Migration..."
    
    # Erstelle Backup-Verzeichnis außerhalb von CLAUDE
    SECURE_BACKUP_DIR="${HOME}/CLAUDE-private-backups"
    mkdir -p "$SECURE_BACKUP_DIR"
    
    # Sichere private Projekte
    [ -d "$CLAUDE_DIR/goldankauf" ] && cp -r "$CLAUDE_DIR/goldankauf" "$SECURE_BACKUP_DIR/" 2>/dev/null || true
    [ -d "$CLAUDE_DIR/aclearallb.gg" ] && cp -r "$CLAUDE_DIR/aclearallb.gg" "$SECURE_BACKUP_DIR/" 2>/dev/null || true
    [ -d "$CLAUDE_DIR/deepsleeping" ] && cp -r "$CLAUDE_DIR/deepsleeping" "$SECURE_BACKUP_DIR/" 2>/dev/null || true
    [ -d "$CLAUDE_DIR/sj-bandolerosz" ] && cp -r "$CLAUDE_DIR/sj-bandolerosz" "$SECURE_BACKUP_DIR/" 2>/dev/null || true
    
    log "SUCCESS" "Private Projekte wurden nach $SECURE_BACKUP_DIR gesichert."
  else
    log "INFO" "Keine sensiblen Projektdaten zum Migrieren gefunden."
  fi
}

# Aktualisierte .gitignore für die Struktur
update_gitignore() {
  log "INFO" "Aktualisiere .gitignore..."
  
  cat > "$CLAUDE_DIR/.gitignore" << EOL
# KRITISCH: Befolge das "Opt-in" statt "Opt-out" Prinzip für Git
# Ignoriere standardmäßig ALLES außer explizit erlaubten Strukturen

# Erste Regel in .gitignore: Alles ignorieren
*
**/
!.gitignore

# Erlaubte Basis-Komponenten der Claude-AGI-Infrastruktur
!claude-terminal/**
!claude-agi-projects/
!claude-agi-projects/.project-config.json
!claude-agi-projects/default-project/
!claude-agi-projects/default-project/**
!memory-bank/
!memory-bank/**
!memory-bank/templates/
!memory-bank/templates/**
!.claude-agi/
!.claude-agi/**
!.config/
!.config/**
!docs/
!docs/**
!install-claude-agi-terminal.sh
!install-claude-agi.sh
!CLAUDE.md
!README.md

# Explizite Ausschlüsse sensibler Projekte
goldankauf/
goldankauf/**
aclearallb.gg/
aclearallb.gg/**
sj-bandolerosz/
sj-bandolerosz/**
deepsleeping/
deepsleeping/**
EOL

  log "SUCCESS" ".gitignore aktualisiert."
}

# Claude Terminal installieren/aktualisieren
install_claude_terminal() {
  log "INFO" "Installiere/Aktualisiere Claude Terminal..."
  
  # Prüfe ob Terminal-Verzeichnis existiert
  if [ ! -d "$TERMINAL_DIR" ]; then
    log "INFO" "Claude Terminal-Verzeichnis nicht gefunden, klone Repository..."
    mkdir -p "$TERMINAL_DIR"
    git clone https://github.com/anthropics/claude-terminal.git "$TERMINAL_DIR" 2>/dev/null || {
      log "WARNING" "Git-Clone fehlgeschlagen, versuche direkten Download..."
      rm -rf "$TERMINAL_DIR"
      mkdir -p "$TERMINAL_DIR"
      
      # Fallback: Leeres Verzeichnis mit package.json erstellen
      cat > "$TERMINAL_DIR/package.json" << EOL
{
  "name": "claude-terminal",
  "version": "1.0.0",
  "description": "Terminal-basierte Benutzeroberfläche für Claude AI",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "nodemon --exec 'npm run build && npm start'"
  },
  "dependencies": {
    "node-pty": "^1.0.0",
    "xterm": "^5.0.0",
    "xterm-addon-fit": "^0.7.0",
    "express": "^4.18.0",
    "dotenv": "^16.0.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "nodemon": "^3.0.0",
    "@types/node": "^20.0.0"
  }
}
EOL
      
      mkdir -p "$TERMINAL_DIR/src/config"
      log "SUCCESS" "Leeres Terminal-Projekt erstellt."
    }
  else
    log "INFO" "Claude Terminal-Verzeichnis gefunden, aktualisiere..."
    
    # Aktualisiere das Repository wenn möglich
    if [ -d "$TERMINAL_DIR/.git" ]; then
      cd "$TERMINAL_DIR" && git pull 2>/dev/null || log "WARNING" "Git-Pull fehlgeschlagen, überspringe..."
    fi
  fi
  
  # Installiere Abhängigkeiten und baue das Projekt
  if [ -f "$TERMINAL_DIR/package.json" ]; then
    log "INFO" "Installiere Abhängigkeiten..."
    
    # node-pty Kompatibilitäts-Patch für neuere Node.js-Versionen
    if [ "$NODE_VERSION" -ge 18 ]; then
      log "INFO" "Node.js v$NODE_VERSION erkannt, wende node-pty Kompatibilitäts-Patch an..."
      
      # Überprüfe, ob ein package-lock.json existiert
      if [ -f "$TERMINAL_DIR/package-lock.json" ]; then
        # Temporäre Kopie erstellen
        cp "$TERMINAL_DIR/package-lock.json" "$TERMINAL_DIR/package-lock.json.bak"
      fi
      
      # Aktualisiere Node-Pty-Version in package.json
      if grep -q "\"node-pty\":" "$TERMINAL_DIR/package.json"; then
        sed -i 's/"node-pty": "[^"]*"/"node-pty": "^0.11.0-dev.1"/' "$TERMINAL_DIR/package.json"
      fi
    fi
    
    cd "$TERMINAL_DIR" && npm install --no-fund --no-audit 2>/dev/null || {
      log "WARNING" "NPM-Installation fehlgeschlagen, versuche mit --legacy-peer-deps..."
      cd "$TERMINAL_DIR" && npm install --legacy-peer-deps --no-fund --no-audit 2>/dev/null || {
        log "ERROR" "NPM-Installation fehlgeschlagen. Versuche es später erneut."
      }
    }
    
    log "INFO" "Baue Claude Terminal..."
    cd "$TERMINAL_DIR" && npm run build 2>/dev/null || {
      log "WARNING" "Build fehlgeschlagen, überprüfe Fehler..."
      
      # TypeScript-Einstellungen für Kompatibilität anpassen
      if [ -f "$TERMINAL_DIR/tsconfig.json" ]; then
        log "INFO" "Passe TypeScript-Konfiguration an..."
        sed -i 's/"target": "ES[^"]*"/"target": "ES2020"/' "$TERMINAL_DIR/tsconfig.json"
        sed -i 's/"module": "commonjs"/"module": "CommonJS"/' "$TERMINAL_DIR/tsconfig.json"
        
        # Erneut bauen
        cd "$TERMINAL_DIR" && npm run build 2>/dev/null || {
          log "ERROR" "Build weiterhin fehlgeschlagen. Manuelle Überprüfung erforderlich."
        }
      fi
    }
    
    log "SUCCESS" "Claude Terminal installiert/aktualisiert."
  else
    log "ERROR" "package.json nicht gefunden. Terminal-Installation fehlgeschlagen."
  fi
}

# ProxyClaude Service einrichten
setup_proxyclaude() {
  log "INFO" "Richte ProxyClaude Service ein..."
  
  # Verzeichnis für ProxyClaude erstellen
  PROXYCLAUDE_DIR="$CLAUDE_DIR/.claude-agi/services/proxyclaude"
  mkdir -p "$PROXYCLAUDE_DIR"
  
  # package.json erstellen
  cat > "$PROXYCLAUDE_DIR/package.json" << EOL
{
  "name": "@claude-agi/proxyclaude",
  "version": "1.0.0",
  "description": "API proxy service für Claude AI integrated mit dem CLAUDE-AGI Ökosystem",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "nodemon --exec 'npm run build && npm start'",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.2",
    "dotenv": "^16.3.1",
    "jsonwebtoken": "^9.0.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "axios": "^1.6.2",
    "winston": "^3.11.0",
    "joi": "^17.11.0"
  },
  "devDependencies": {
    "typescript": "^5.3.2",
    "nodemon": "^3.0.1",
    "@types/express": "^4.17.21",
    "@types/jsonwebtoken": "^9.0.5",
    "@types/node": "^20.9.4",
    "@types/cors": "^2.8.17",
    "jest": "^29.7.0",
    "ts-jest": "^29.1.1",
    "@types/jest": "^29.5.10"
  }
}
EOL
  
  # tsconfig.json erstellen
  cat > "$PROXYCLAUDE_DIR/tsconfig.json" << EOL
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts"]
}
EOL
  
  # Beispiel .env Datei erstellen
  cat > "$PROXYCLAUDE_DIR/.env.example" << EOL
# ProxyClaude Service Konfiguration
PORT=4001
NODE_ENV=development

# Claude API
CLAUDE_API_KEY=your_anthropic_api_key_here
CLAUDE_API_URL=https://api.anthropic.com/v1/messages

# JWT Authentifizierung
JWT_SECRET=change_this_to_a_secure_random_string
TOKEN_EXPIRY=7d

# Nutzerlimits (Anfragen pro Tag)
RATE_LIMIT_STANDARD=100
RATE_LIMIT_PREMIUM=500
RATE_LIMIT_ENTERPRISE=2000

# Logging
LOG_LEVEL=info
EOL
  
  # Basis-Struktur erstellen
  mkdir -p "$PROXYCLAUDE_DIR/src/controllers"
  mkdir -p "$PROXYCLAUDE_DIR/src/middleware"
  mkdir -p "$PROXYCLAUDE_DIR/src/routes"
  mkdir -p "$PROXYCLAUDE_DIR/src/services"
  mkdir -p "$PROXYCLAUDE_DIR/src/utils"
  mkdir -p "$PROXYCLAUDE_DIR/src/config"
  
  # Basis-Index-Datei erstellen
  cat > "$PROXYCLAUDE_DIR/src/index.ts" << EOL
import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import helmet from 'helmet';
import { logger } from './utils/logger';

// Lade Umgebungsvariablen
dotenv.config();

const app = express();
const port = process.env.PORT || 4001;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Einfacher Status-Endpunkt
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', service: 'proxyclaude', version: '1.0.0' });
});

// Starte Server
app.listen(port, () => {
  logger.info(\`ProxyClaude Service läuft auf Port \${port}\`);
});
EOL
  
  # Logger-Utility erstellen
  cat > "$PROXYCLAUDE_DIR/src/utils/logger.ts" << EOL
import winston from 'winston';

// Konfiguration für Winston Logger
export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    }),
    new winston.transports.File({ 
      filename: 'proxyclaude-error.log', 
      level: 'error' 
    }),
    new winston.transports.File({ 
      filename: 'proxyclaude.log' 
    })
  ]
});
EOL
  
  # Dokumentation erstellen
  mkdir -p "$CLAUDE_DIR/docs"
  cat > "$CLAUDE_DIR/docs/proxyclaude-guide.md" << EOL
# ProxyClaude Service Guide

ProxyClaude ist ein API-Proxy-Dienst für Claude, der speziell für das CLAUDE-AGI-Ökosystem entwickelt wurde. Er bietet zentralisierten API-Zugriff mit Authentifizierung, Ratenbegrenzung und Nutzerverwaltung.

## Installation

\`\`\`bash
# Wechsle zum ProxyClaude-Verzeichnis
cd $CLAUDE_DIR/.claude-agi/services/proxyclaude

# Erstelle eine .env-Datei basierend auf dem Beispiel
cp .env.example .env

# Bearbeite die .env-Datei mit deinem API-Schlüssel
nano .env

# Installiere Abhängigkeiten
npm install

# Baue das Projekt
npm run build

# Starte den Service
npm start
\`\`\`

## Verwendung mit Claude Terminal

ProxyClaude läuft standardmäßig auf Port 4001 und wird automatisch mit dem Claude Terminal integriert, wenn es konfiguriert ist.

## API-Endpunkte

- \`GET /health\`: Status des Services prüfen
- \`POST /api/claude\`: Claude API-Anfrage senden
- \`POST /api/auth/login\`: Authentifizieren und JWT-Token erhalten
- \`GET /api/user/status\`: Nutzerstatus und verbleibende Anfragen prüfen

## MCP-Integration

ProxyClaude wird automatisch als MCP-Tool konfiguriert, sodass es vom Claude Desktop genutzt werden kann.

## Sicherheitshinweise

- Ändere das JWT_SECRET in der .env-Datei
- Speichere niemals API-Schlüssel im Git-Repository
- Verwende HTTPS für Produktionsumgebungen
EOL
  
  log "SUCCESS" "ProxyClaude Service eingerichtet."
}

# README.md erstellen
create_readme() {
  log "INFO" "Erstelle README.md..."
  
  cat > "$CLAUDE_DIR/README.md" << EOL
# CLAUDE-AGI Terminal System

Ein integriertes System für die Claude AI mit Terminal-Integration, Memory Bank v2.0 und ProxyClaude Service.

![CLAUDE-AGI Terminal](https://raw.githubusercontent.com/anthropics/claude-terminal/main/docs/terminal-preview.png)

## Über das Projekt

Das CLAUDE-AGI Terminal System ist eine umfassende Lösung für die Interaktion mit Claude AI durch eine Terminal-basierte Benutzeroberfläche. Das System integriert verschiedene Komponenten für eine optimale Nutzererfahrung, persistenten Kontext und erweiterte Funktionalität.

## Hauptkomponenten

### 1. Claude Terminal
Eine Terminal-basierte Benutzeroberfläche für die Interaktion mit Claude AI.

### 2. Standardisierte Projektstruktur
Projektorganisation mit folgender Struktur:
- \`claude-agi-projects/\`: Hauptverzeichnis für alle Projekte
- \`default-project/\`: Standard-Arbeitsumgebung
- \`memory-bank/\`: Kontext-Verwaltungssystem mit Knowledge Graph und Sequential Thinking

### 3. Memory Bank v2.0
Fortschrittliches Kontext-Management-System mit neuen APIs:
- **Knowledge Graph API**: Semantische Beziehungen zwischen Konzepten im Projekt
- **Sequential Thinking API**: Strukturierte Problemlösung mit MCP-Integration
- **Memory Bank CLI**: Kommandozeilen-Tool für Verwaltung und Visualisierung

### 4. ProxyClaude Service
API-Proxy für Claude mit folgenden Features:
- JWT-Authentifizierung
- Nutzer-basierte Ratenbegrenzung
- Zentrale API-Schlüsselverwaltung

### 5. MCP-Tools Integration
Model Context Protocol Tools für erweiterte Funktionalität:
- Memory Bank MCP
- Desktop Commander
- Browser Tools
- Sequential Thinking
- Code MCP

## Installation

\`\`\`bash
# Installation starten
bash install-claude-agi-terminal.sh
\`\`\`

## Verwendung

### Claude Terminal starten

\`\`\`bash
cd claude-terminal && npm start
\`\`\`

### ProxyClaude konfigurieren

\`\`\`bash
cd .claude-agi/services/proxyclaude
cp .env.example .env
nano .env  # API-Schlüssel eintragen
npm start
\`\`\`

### Neues Projekt erstellen

\`\`\`bash
mkdir -p claude-agi-projects/mein-projekt/memory-bank
cp -r memory-bank/templates/* claude-agi-projects/mein-projekt/memory-bank/
\`\`\`

### Memory Bank v2.0 APIs nutzen

\`\`\`bash
# Memory Bank aktualisieren und Knowledge Graph erzeugen
cd memory-bank
node apis/cli.js update /pfad/zum/projekt

# Sequential Thinking für ein Problem anwenden
node apis/cli.js think "Wie kann ich die App-Performance verbessern?" code-design

# Knowledge Graph visualisieren
node apis/cli.js visualize-graph /pfad/zum/projekt --format=html
\`\`\`

## Mitwirkung

Mitwirkungen an diesem Projekt sind willkommen. Bitte stellen Sie sicher, dass Sie die folgenden Richtlinien beachten:

1. Verwenden Sie die standardisierte Projektstruktur
2. Befolgen Sie die Git-Sicherheitsrichtlinien (keine sensiblen Daten)
3. Aktualisieren Sie die Dokumentation bei Änderungen

## Sicherheitshinweise

- API-Schlüssel nur in .env-Dateien speichern (NIEMALS im Git)
- Persönliche Projekte außerhalb des Git-Repositories halten
- Die Opt-in-Git-Strategie in .gitignore beibehalten
EOL
  
  log "SUCCESS" "README.md erstellt."
}

# Haupt-Installation
main() {
  # Sichere Datenmigration zuerst
  secure_data_migration
  
  # Basis-Voraussetzungen prüfen
  check_prerequisites
  
  # Standardisierte Projektstruktur erstellen
  create_standardized_structure
  
  # MCP-Konfiguration aktualisieren
  update_mcp_config
  
  # Claude Terminal installieren/aktualisieren
  install_claude_terminal
  
  # ProxyClaude Service einrichten
  setup_proxyclaude
  
  # Terminal-Anpassungen
  adapt_terminal_for_structure
  
  # .gitignore aktualisieren
  update_gitignore
  
  # README.md erstellen
  create_readme
  
  # CLAUDE.md aktualisieren
  cat > "$CLAUDE_DIR/CLAUDE.md" << EOL
# CLAUDE.md

Diese Datei bietet Anweisungen für Claude Code (claude.ai/code) bei der Arbeit mit diesem Repository.

## CLAUDE AGI-Terminal-System v1.2

Das CLAUDE AGI-Terminal-System nutzt eine standardisierte Projektstruktur mit Profilfunktionen, Memory-Bank v2.0 und MCP-Tools-Integration.

## Standardisierte Projektstruktur
\`\`\`
$CLAUDE_DIR/
├── claude-terminal/          # Terminal-Anwendung
├── claude-agi-projects/      # Standardisierte Projektstruktur
│   ├── .project-config.json  # Konfiguration für Projekte
│   └── default-project/      # Standard-Arbeitsverzeichnis
│       └── memory-bank/      # Projekt-spezifische Memory Bank
├── memory-bank/              # Memory Bank v2.0 System
│   ├── templates/            # Vorlagen für neue Projekte
│   └── apis/                 # Knowledge Graph und Sequential Thinking APIs
├── .claude-agi/              # Service-Komponenten
│   └── services/
│       └── proxyclaude/      # Claude API Proxy Service
├── .config/                  # MCP-Konfiguration
└── docs/                     # Dokumentation
    └── proxyclaude-guide.md  # ProxyClaude Service Anleitung
\`\`\`

## Befehlsreferenz
- Terminal: \`cd claude-terminal && npm start\` 
- Claude API Proxy: \`cd .claude-agi/services/proxyclaude && PORT=4001 npm start\`
- Entwicklung: \`cd claude-terminal && npm run dev\` oder \`cd .claude-agi/services/proxyclaude && npm run dev\`
- Build: \`cd claude-terminal && npm run build\` oder \`cd .claude-agi/services/proxyclaude && npm run build\`
- Tests: \`cd .claude-agi/services/proxyclaude && npm test\`
- Memory Bank CLI: \`cd memory-bank && node apis/cli.js <command> [options]\`

## Memory Bank v2.0 APIs

### Knowledge Graph API
Die Knowledge Graph API ermöglicht das Verwalten und Abfragen semantischer Beziehungen im Projekt:

\`\`\`javascript
const KnowledgeGraphAPI = require('./memory-bank/apis/knowledgeGraphAPI');
const kg = new KnowledgeGraphAPI('/path/to/project');

// Konzepte hinzufügen und verbinden
const nodeId = kg.addConcept('Authentication', 'feature');
const relId = kg.addRelationship(sourceId, targetId, 'depends_on');

// Graph abfragen
const concepts = kg.queryConcepts({ type: 'technology' });
const path = kg.findShortestPath(conceptA, conceptB);

// Automatische Extraktion
const summary = kg.updateFromMemoryBank();

// Visualisierung
const html = kg.visualize('html');
\`\`\`

### Sequential Thinking API
Die Sequential Thinking API bietet strukturierte Problemlösungsmodelle mit MCP-Integration:

\`\`\`javascript
const SequentialThinkingAPI = require('./memory-bank/apis/sequentialThinkingAPI');
const st = new SequentialThinkingAPI('/path/to/project');

// Problem lösen
const session = await st.think('Wie optimiere ich die Performance?', {
  model: 'code-design',
  appendToActiveContext: true
});

// Ergebnisse betrachten
console.log(session.steps);
console.log(session.conclusion);

// Historie abfragen
const previousSessions = st.getHistory('performance');
\`\`\`

### CLI-Tool
Das Memory Bank CLI-Tool ermöglicht die Verwaltung und Visualisierung über die Kommandozeile:

\`\`\`bash
# Knowledge Graph aktualisieren
node apis/cli.js update /path/to/project

# Konzepte aus Projektdateien extrahieren
node apis/cli.js extract-knowledge /path/to/project

# Strukturiertes Problemlösen
node apis/cli.js think "Wie kann ich die API-Performance verbessern?" code-design

# Knowledge Graph visualisieren
node apis/cli.js visualize-graph /path/to/project --format=html --output=graph.html
\`\`\`

## MCP-Tools
Das System nutzt folgende MCP-Tools:
- memory-bank-mcp: Persistente Kontext-Verwaltung mit Knowledge Graph Integration
- desktop-commander: Dateisystem und Shell-Operationen
- browser-tools: Web-Recherche und Browser-Integration
- proxyclaude: Claude API Proxy für zentrale Nutzung
- code-mcp: Code-Generierung und Analyse
- sequentialthinking: Strukturierte Problemlösung und Integration mit Memory Bank

## Wichtige Regeln
1. Alle AGI-Projekte werden in claude-agi-projects/ verwaltet
2. Terminal arbeitet automatisch im Standard-Projektverzeichnis
3. Private Projekte (goldankauf, aclearallb.gg, etc.) werden NICHT im Git eingecheckt
4. Memory-Bank v2.0 bietet erweiterte APIs für Knowledge Graph und Sequential Thinking
5. ProxyClaude nutzt JWT für die Authentifizierung
6. API-Schlüssel werden IMMER in .env-Dateien gespeichert (nicht ins Git)

## Sicherheitshinweise
- Alle sensiblen Projekte sind automatisch durch .gitignore geschützt
- API-Schlüssel und Secrets werden durch .env-Dateien verwaltet
- Opt-in Git-Strategie: Standardmäßig wird alles ignoriert
- Private Projekte werden automatisch gesichert bei Migration
EOL

  # Erfolgreicher Abschluss
  echo ""
  echo -e "${GREEN}✅ Claude-AGI v1.2 mit Memory Bank v2.0 und standardisierter Projektstruktur installiert!${NC}"
  echo ""
  echo -e "${BLUE}Standardisierte Struktur:${NC}"
  echo "- Projektverzeichnis: $AGI_PROJECTS_DIR"
  echo "- Standard-Arbeitsverzeichnis: $DEFAULT_PROJECT_DIR"
  echo "- Memory-Bank-System v2.0: Strukturiert nach Projekten mit erweiterten APIs"
  echo "- ProxyClaude Service: $CLAUDE_DIR/.claude-agi/services/proxyclaude"
  echo ""
  echo -e "${BLUE}Integrierte Komponenten:${NC}"
  echo "- Claude Terminal: Konsolenbasierte AI-Integration"
  echo "- ProxyClaude: API-Proxy mit JWT-Authentifizierung"
  echo "- Memory-Bank v2.0: Persistenter Kontext mit Knowledge Graph und Sequential Thinking APIs"
  echo "- Memory-Bank CLI: Kommandozeilen-Tool für Verwaltung und Visualisierung"
  echo "- MCP-Tools: Erweiterte KI-Funktionen über MCP-Protokoll"
  echo ""
  echo -e "${YELLOW}Nächste Schritte:${NC}"
  echo "1. Terminal starten: cd $TERMINAL_DIR && npm start"
  echo "2. ProxyClaude konfigurieren: cp $PROXYCLAUDE_DIR/.env.example $PROXYCLAUDE_DIR/.env"
  echo "3. API-Schlüssel einrichten: nano $PROXYCLAUDE_DIR/.env"
  echo "4. ProxyClaude starten: cd $PROXYCLAUDE_DIR && npm start"
  echo "5. Memory Bank CLI testen: cd $MEMORY_BANK_DIR && node apis/cli.js think \"Wie kann ich ein neues Feature planen?\""
  echo ""
  echo -e "${YELLOW}Memory Bank v2.0 APIs nutzen:${NC}"
  echo "- Knowledge Graph aktualisieren: cd $MEMORY_BANK_DIR && node apis/cli.js update $DEFAULT_PROJECT_DIR"
  echo "- Konzepte extrahieren: node apis/cli.js extract-knowledge $DEFAULT_PROJECT_DIR"
  echo "- Knowledge Graph visualisieren: node apis/cli.js visualize-graph $DEFAULT_PROJECT_DIR --format=html"
  echo ""
  echo -e "${YELLOW}Sicherheitshinweise:${NC}"
  echo "- Sensible Projekte werden automatisch ausgeschlossen"
  echo "- Terminal arbeitet automatisch im Standardprojekt"
  echo "- Alle Projektdaten sind durch .gitignore geschützt"
  echo "- API-Schlüssel nur in .env-Dateien speichern (NIEMALS im Git)"
  echo "- Backup in $HOME/CLAUDE-private-backups für sensible Projekte"
  echo ""
}

# Ausführung
main