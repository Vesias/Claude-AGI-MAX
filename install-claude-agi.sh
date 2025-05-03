#!/bin/bash

# CLAUDE-AGI: Sicherer Installer mit Memory-Bank-System
# Version 1.0 - 2025-05-02
# Dieses Skript installiert das CLAUDE-AGI Framework mit eingebauten Sicherheitsmaßnahmen.

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
echo "  ██████╗██╗      █████╗ ██╗   ██╗██████╗ ███████╗       █████╗  ██████╗ ██╗"
echo " ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗██╔════╝      ██╔══██╗██╔════╝ ██║"
echo " ██║     ██║     ███████║██║   ██║██║  ██║█████╗  █████╗███████║██║  ███╗██║"
echo " ██║     ██║     ██╔══██║██║   ██║██║  ██║██╔══╝  ╚════╝██╔══██║██║   ██║██║"
echo " ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝███████╗      ██║  ██║╚██████╔╝██║"
echo "  ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝      ╚═╝  ╚═╝ ╚═════╝ ╚═╝"
echo -e "${NC}"
echo -e "${BLUE}Memory-Bank-System mit MCP-Tools Integration${NC}"
echo -e "${BLUE}Version 1.0 • Claude Pro MAX Edition${NC}"
echo "========================================================"
echo ""

# Konfigurationsvariablen
INSTALL_DIR="${HOME}/.claude"
TEMPLATE_DIR="$INSTALL_DIR/templates"
STORAGE_DIR="$INSTALL_DIR/memory_storage"
BACKUP_DIR="$INSTALL_DIR/backups"
LOGS_DIR="$INSTALL_DIR/logs"
CONFIG_DIR="${HOME}/.config/claude-desktop"
DESKTOP_DIR="${HOME}/Schreibtisch"
CLAUDE_DIR="$DESKTOP_DIR/CLAUDE"
LOG_FILE="$LOGS_DIR/installation.log"

# Prüfsummenverifikation
INSTALLER_CHECKSUM="$(sha256sum "$0" | cut -d' ' -f1)"
EXPECTED_CHECKSUM="PLACEHOLDER_CHECKSUM" # Wird bei Release aktualisiert

# Optionale Konfiguration aus Umgebungsvariablen
MCP_KEY="${MCP_KEY:-}"
GH_TOKEN="${GH_TOKEN:-}"
CLAUDE_PRO_MAX="${CLAUDE_PRO_MAX:-false}"

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

# Hilfsfunktion: Ja/Nein-Abfrage
prompt_yes_no() {
  local prompt=$1
  local default=${2:-n}
  
  if [ "$default" = "y" ]; then
    prompt="$prompt [Y/n]"
  else
    prompt="$prompt [y/N]"
  fi
  
  read -p "$(echo -e "${CYAN}$prompt${NC} ") " response
  response=${response:-$default}
  
  if [[ "$response" =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

# Hilfsfunktion: Sicherheitsüberprüfung
verify_security() {
  log "INFO" "Führe Sicherheitsüberprüfung durch..."
  
  # Überprüfe Skriptintegrität (nur wenn es sich nicht um Entwicklungsmodus handelt)
  if [[ "$EXPECTED_CHECKSUM" != "PLACEHOLDER_CHECKSUM" ]]; then
    if [[ "$INSTALLER_CHECKSUM" != "$EXPECTED_CHECKSUM" ]]; then
      log "ERROR" "Skriptintegrität konnte nicht verifiziert werden!"
      log "ERROR" "Erwartete Prüfsumme: $EXPECTED_CHECKSUM"
      log "ERROR" "Tatsächliche Prüfsumme: $INSTALLER_CHECKSUM"
      
      if prompt_yes_no "Möchten Sie trotzdem fortfahren? Dies wird NICHT empfohlen!" "n"; then
        log "WARNING" "Fortfahren trotz fehlgeschlagener Integritätsprüfung auf eigenes Risiko."
      else
        log "INFO" "Installation abgebrochen - Integritätsprüfung fehlgeschlagen."
        exit 1
      fi
    else
      log "SUCCESS" "Skriptintegrität verifiziert."
    fi
  fi
  
  # Überprüfe, ob wir Root-Rechte haben (sollten wir nicht haben)
  if [ "$EUID" -eq 0 ]; then
    log "ERROR" "Dieses Skript sollte NICHT als Root ausgeführt werden!"
    exit 1
  fi
  
  log "SUCCESS" "Sicherheitsüberprüfung abgeschlossen."
}

# Hilfsfunktion: Voraussetzungen prüfen
check_prerequisites() {
  log "INFO" "Prüfe Systemvoraussetzungen..."
  
  # Node.js
  if ! command -v node &> /dev/null; then
    log "ERROR" "Node.js ist nicht installiert! Bitte installieren Sie Node.js (v20+)."
    echo -e "${BLUE}Installationsanleitung:${NC} https://nodejs.org/de/download/"
    exit 1
  fi
  
  # Node.js-Version prüfen
  NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
  if [ "$NODE_VERSION" -lt 20 ]; then
    log "ERROR" "Node.js v$NODE_VERSION gefunden, aber mindestens Version 20 erforderlich!"
    echo -e "${BLUE}Aktuelle Version:${NC} $(node -v)"
    echo -e "${BLUE}Installationsanleitung:${NC} https://nodejs.org/de/download/"
    exit 1
  fi
  
  # NPM
  if ! command -v npm &> /dev/null; then
    log "ERROR" "npm ist nicht installiert!"
    exit 1
  fi
  
  # Git
  if ! command -v git &> /dev/null; then
    log "ERROR" "Git ist nicht installiert! Bitte installieren Sie Git."
    echo -e "${BLUE}Installationsanleitung:${NC} https://git-scm.com/downloads"
    exit 1
  fi
  
  # GitHub CLI
  if ! command -v gh &> /dev/null; then
    log "WARNING" "GitHub CLI (gh) nicht gefunden."
    
    if prompt_yes_no "Möchten Sie die GitHub CLI installieren?" "y"; then
      log "INFO" "Installiere GitHub CLI..."
      
      # Betriebssystem erkennen und entsprechend installieren
      if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command -v apt-get &> /dev/null; then
          # Debian/Ubuntu
          type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
          curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
          && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
          && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
          && sudo apt update \
          && sudo apt install gh -y
        elif command -v dnf &> /dev/null; then
          # Fedora/RHEL
          sudo dnf install 'dnf-command(config-manager)' -y
          sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
          sudo dnf install gh -y
        else
          log "ERROR" "Unterstütztes Paketmanagement nicht gefunden. Bitte installieren Sie GitHub CLI manuell."
          echo -e "${BLUE}Installationsanleitung:${NC} https://github.com/cli/cli#installation"
          exit 1
        fi
      elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
          brew install gh
        else
          log "ERROR" "Homebrew nicht gefunden. Bitte installieren Sie Homebrew oder GitHub CLI manuell."
          echo -e "${BLUE}Homebrew-Installation:${NC} https://brew.sh/"
          echo -e "${BLUE}GitHub CLI-Anleitung:${NC} https://github.com/cli/cli#installation"
          exit 1
        fi
      else
        log "ERROR" "Betriebssystem nicht erkannt. Bitte installieren Sie GitHub CLI manuell."
        echo -e "${BLUE}Installationsanleitung:${NC} https://github.com/cli/cli#installation"
        exit 1
      fi
    else
      log "WARNING" "GitHub CLI-Installation übersprungen. Einige Funktionen werden eingeschränkt sein."
    fi
  fi
  
  # TypeScript und ts-node
  if ! command -v ts-node &> /dev/null; then
    log "INFO" "Installiere ts-node und Abhängigkeiten..."
    npm install -g ts-node typescript @types/node inquirer @types/inquirer
  fi
  
  log "SUCCESS" "Alle Systemvoraussetzungen erfüllt."
}

# Hilfsfunktion: Claude Pro MAX überprüfen
verify_claude_pro_max() {
  log "INFO" "Überprüfe Claude Pro MAX Berechtigung..."
  
  if [ "$CLAUDE_PRO_MAX" != "true" ]; then
    log "WARNING" "Claude Pro MAX nicht bestätigt!"
    echo -e "${YELLOW}⚠️  WARNUNG: Dieses Framework erfordert ein aktives Claude Pro MAX Abonnement.${NC}"
    
    if prompt_yes_no "Haben Sie ein aktives Claude Pro MAX Abonnement?" "n"; then
      CLAUDE_PRO_MAX="true"
      log "SUCCESS" "Claude Pro MAX bestätigt."
    else
      log "ERROR" "Claude Pro MAX wird für die vollständige Funktionalität benötigt."
      
      if prompt_yes_no "Möchten Sie trotzdem mit eingeschränkter Funktionalität fortfahren?" "n"; then
        log "WARNING" "Fortfahren mit eingeschränkter Funktionalität."
      else
        log "INFO" "Installation abgebrochen."
        exit 1
      fi
    fi
  else
    log "SUCCESS" "Claude Pro MAX bestätigt."
  fi
}

# Verzeichnisstruktur erstellen
create_directory_structure() {
  log "INFO" "Erstelle Verzeichnisstruktur..."
  
  mkdir -p "$INSTALL_DIR"
  mkdir -p "$TEMPLATE_DIR"
  mkdir -p "$STORAGE_DIR"
  mkdir -p "$BACKUP_DIR"
  mkdir -p "$LOGS_DIR"
  mkdir -p "$CONFIG_DIR"
  mkdir -p "$CLAUDE_DIR"
  mkdir -p "$CLAUDE_DIR/.config"
  
  # Template-Unterverzeichnisse
  mkdir -p "$TEMPLATE_DIR/components"
  mkdir -p "$TEMPLATE_DIR/workflows"
  mkdir -p "$TEMPLATE_DIR/apis"
  mkdir -p "$TEMPLATE_DIR/database"
  mkdir -p "$TEMPLATE_DIR/project-types"
  mkdir -p "$TEMPLATE_DIR/tech-stacks"
  
  # Setze sichere Berechtigungen für sensible Verzeichnisse
  chmod 700 "$INSTALL_DIR"
  chmod 700 "$CONFIG_DIR"
  
  log "SUCCESS" "Verzeichnisstruktur erstellt."
}

# Konfiguriere MCP-Server
configure_mcp_servers() {
  log "INFO" "Konfiguriere MCP-Server..."
  
  # Fordere MCP-Key an, falls nicht gesetzt
  if [ -z "$MCP_KEY" ]; then
    read -sp "$(echo -e "${CYAN}Bitte geben Sie Ihren MCP Master Key ein (wird nicht angezeigt): ${NC}") " MCP_KEY
    echo ""
    
    if [ -z "$MCP_KEY" ]; then
      log "WARNING" "Kein MCP-Key angegeben. Einige Funktionen werden eingeschränkt sein."
    fi
  fi
  
  # Fordere GitHub-Token an, falls nicht gesetzt
  if [ -z "$GH_TOKEN" ]; then
    read -sp "$(echo -e "${CYAN}Bitte geben Sie Ihren GitHub Personal Access Token ein (wird nicht angezeigt): ${NC}") " GH_TOKEN
    echo ""
    
    if [ -z "$GH_TOKEN" ]; then
      log "WARNING" "Kein GitHub-Token angegeben. GitHub-Integration wird deaktiviert."
    fi
  fi
  
  # Weitere Einstellungen abfragen
  read -p "$(echo -e "${CYAN}Brave Search Profil (default): ${NC}") " BRAVE_PROFILE
  BRAVE_PROFILE=${BRAVE_PROFILE:-default}
  
  read -sp "$(echo -e "${CYAN}Twenty First API Key (optional): ${NC}") " TWENTY_FIRST_KEY
  echo ""
  
  # MCP-Server-Konfiguration erstellen
  cat > "$CONFIG_DIR/claude_desktop_config.json" << EOL
{
  "mcpServers": {
    "desktop-commander": {
      "command": "npx",
      "args": ["-y", "@wonderwhy-er/desktop-commander", "--key", "\${MCP_KEY}"]
    },
    "code-mcp": {
      "command": "npx",
      "args": ["-y", "@block/code-mcp", "--key", "\${MCP_KEY}"]
    },
    "sequentialthinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "memory-bank": {
      "command": "npx",
      "args": ["-y", "@alioshr/memory-bank-mcp", "--key", "\${MCP_KEY}"]
    },
    "context7-mcp": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp", "--key", "\${MCP_KEY}"]
    }
EOL

  # Bedingte MCP-Server hinzufügen
  if [ ! -z "$TWENTY_FIRST_KEY" ]; then
    cat >> "$CONFIG_DIR/claude_desktop_config.json" << EOL
,
    "magic-mcp": {
      "command": "npx",
      "args": ["-y", "@21st-dev/magic@latest"],
      "env": { "TWENTY_FIRST_API_KEY": "\${TWENTY_FIRST_API_KEY}" }
    }
EOL
  fi

  # Ersetze smithery-ai durch alternative Implementierung
  cat >> "$CONFIG_DIR/claude_desktop_config.json" << EOL
,
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@searchweb/brave-mcp", "--key", "\${MCP_KEY}", "--profile", "\${BRAVE_PROFILE}"]
    }
EOL

  # GitHub-Integration
  if [ ! -z "$GH_TOKEN" ]; then
    cat >> "$CONFIG_DIR/claude_desktop_config.json" << EOL
,
    "github": {
      "command": "npx",
      "args": ["-y", "github-mcp-server"],
      "env": { "GITHUB_TOKEN": "\${GH_TOKEN}" }
    },
    "git": {
      "command": "npx",
      "args": ["-y", "git-mcp-server"]
    }
EOL
  fi

  # Abschluss der JSON-Struktur
  cat >> "$CONFIG_DIR/claude_desktop_config.json" << EOL
  }
}
EOL

  # Kopiere Konfiguration nach CLAUDE/.config/
  cp "$CONFIG_DIR/claude_desktop_config.json" "$CLAUDE_DIR/.config/"
  
  # Erstelle .env-Datei für Umgebungsvariablen
  cat > "$INSTALL_DIR/.env" << EOL
# MCP API Keys
MCP_KEY="${MCP_KEY}"
BRAVE_PROFILE="${BRAVE_PROFILE}"
TWENTY_FIRST_API_KEY="${TWENTY_FIRST_KEY}"

# GitHub
GH_TOKEN="${GH_TOKEN}"

# Claude Pro MAX Verification
CLAUDE_PRO_MAX=${CLAUDE_PRO_MAX}
EOL

  # Setze strenge Berechtigungen für .env
  chmod 600 "$INSTALL_DIR/.env"
  
  log "SUCCESS" "MCP-Server erfolgreich konfiguriert."
}

# Template-Dateien erstellen
create_template_files() {
  log "INFO" "Erstelle Template-Dateien..."
  
  # Basisdateien für Memory-Bank
  cat > "$TEMPLATE_DIR/projectbrief.md" << 'EOL'
# $PROJECT - Projektdefinition

## Primäre Zielsetzung
[Definition des Kernproblems und der angestrebten Lösung]

## Technische Grundparameter
- Frontend: [Next.js 15, React, TypeScript, Tailwind]
- Backend: [Supabase, PostgreSQL, Serverless]
- Zusätzliche Module: [3D-Visualisierung/Blockchain/E-Commerce]

## Geschäftsziele
- [ROI-Metriken]
- [Skalierungsstrategie]

## Meilensteine
1. [Meilenstein 1 mit Zeitrahmen]
2. [Meilenstein 2 mit Zeitrahmen]
3. [Meilenstein 3 mit Zeitrahmen]

## Integration mit anderen Systemen
- [System 1]
- [System 2]
EOL

  cat > "$TEMPLATE_DIR/productContext.md" << 'EOL'
# $PROJECT - Produktkontext

## Marktpositionierung
- [Zielmarktdefinition]
- [Alleinstellungsmerkmale]
- [Wettbewerbsabgrenzung]

## Nutzerperspektive
- [Primäre Persona: Beschreibung]
- [Sekundäre Persona: Beschreibung]
- [Schlüssel-Nutzungsszenarien]

## Technische Differenzierung
- [Technologische Innovationsaspekte]
- [Implementierungsvorteile]
- [Skalierungsstrategie]

## Geschäftsrelevanz
- [Geschäftskritische Funktionen]
- [Monetarisierungsstrategie]
- [Erfolgsindikatoren]
EOL

  cat > "$TEMPLATE_DIR/systemPatterns.md" << 'EOL'
# $PROJECT - Systemmuster und Architektur

## Architekturansatz
- [Architekturdiagramm]
- [Komponentenkommunikation]
- [Datenflussmodell]

## Designprinzipien
- [Kernprinzip 1: Erklärung]
- [Kernprinzip 2: Erklärung]
- [Kernprinzip 3: Erklärung]

## Implementierungsmuster
- [Frontend-Muster]
  - [Komponentenhierarchie]
  - [State-Management-Strategie]
  - [Routing-Konzept]

- [Backend-Muster]
  - [API-Strukturen]
  - [Datenbankschema]
  - [Serverless-Funktionen]

- [Integrationsmuster]
  - [Authentication]
  - [Externe APIs]
  - [Websocket-Kommunikation]

## Leistungsoptimierung
- [Caching-Strategie]
- [Lazy-Loading-Konzept]
- [Serverless-Optimierung]

## Sicherheitskonzept
- [Authentication]
- [Authorization]
- [Datenvalidierung]
EOL

  cat > "$TEMPLATE_DIR/techContext.md" << 'EOL'
# $PROJECT - Technologiekontext

## Stack-Konfiguration
- Frontend:
  - Framework: [Next.js 15]
  - UI: [React mit Tailwind]
  - State-Management: [Zustand/Redux/Context]
  - Typ-System: [TypeScript Konfiguration]

- Backend:
  - Infrastruktur: [Supabase]
  - Datenbank: [PostgreSQL Schema]
  - Serverless: [Edge Functions]
  - API: [REST/GraphQL]

- DevOps:
  - CI/CD: [GitHub Actions]
  - Hosting: [Vercel/AWS]
  - Monitoring: [Sentry/LogRocket]

## Entwicklungsumgebung
- [VS Code Konfiguration]
- [ESLint + Prettier Setup]
- [Husky Git Hooks]
- [MCP Tool Integration]

## Drittanbieter-Integration
- [API 1: Dokumentation]
- [API 2: Dokumentation]
- [API 3: Dokumentation]

## Leistungsmetriken
- [Frontend Metrics]
- [Backend Metrics]
- [Monitoring-Strategie]
EOL

  cat > "$TEMPLATE_DIR/activeContext.md" << 'EOL'
# $PROJECT - Aktiver Kontext

## Aktuelle Phase
- [Phase-Name]
- [Fokus]
- [Kritische Pfade]

## Letzte Änderungen
- [Datum]: [Implementierte Funktion]
- [Datum]: [Architekturentscheidung]
- [Datum]: [Behobenes Problem]

## Aktuelle Prioritäten
- 🔥 [Höchste Priorität]
- ⚠️ [Hohe Priorität]
- 📋 [Normale Priorität]

## Blockierende Probleme
- 🛑 [Problem 1: Beschreibung, mögliche Lösungsansätze]
- 🛑 [Problem 2: Beschreibung, mögliche Lösungsansätze]

## Nächste Schritte
- [Unmittelbarer nächster Schritt]
- [Folgenden Schritte]
- [Mittelfristige Schritte]

## Offene Fragen
- [Frage 1]
- [Frage 2]
EOL

  cat > "$TEMPLATE_DIR/progress.md" << 'EOL'
# $PROJECT - Fortschrittsprotokoll

## Implementierte Funktionen
- ✅ [Funktion 1: Beschreibung - Datum]
- ✅ [Funktion 2: Beschreibung - Datum]
- ✅ [Funktion 3: Beschreibung - Datum]

## In Bearbeitung
- ⏳ [Funktion 4: Beschreibung - Start: Datum]
- ⏳ [Funktion 5: Beschreibung - Start: Datum]

## Ausstehend
- 📋 [Funktion 6: Beschreibung]
- 📋 [Funktion 7: Beschreibung]

## Bekannte Probleme
- 🐛 [Problem 1: Beschreibung - Status]
- 🐛 [Problem 2: Beschreibung - Status]

## Leistungskennzahlen
- [KPI 1: Aktueller Wert vs. Zielwert]
- [KPI 2: Aktueller Wert vs. Zielwert]
- [KPI 3: Aktueller Wert vs. Zielwert]

## Verbesserungspotential
- [Bereich 1: Spezifische Optimierungsvorschläge]
- [Bereich 2: Spezifische Optimierungsvorschläge]
EOL

  cat > "$TEMPLATE_DIR/CLAUDE.md" << 'EOL'
# CLAUDE.md

Diese Datei bietet Anweisungen für Claude Code (claude.ai/code) bei der Arbeit mit diesem Repository.

## Command Reference
- Build: `cd APP && npm run build`
- Dev: `cd APP && npm run dev`
- Lint: `cd APP && npm run lint`
- Test: `cd APP && npm test`
- Test Single: `cd APP && npx playwright test path/to/test.spec.ts`

## Code Style Guidelines
- TypeScript: Strict type checking, keine any-Typen
- Imports: Alphabetisch sortiert, gruppiert nach extern/intern, relative Pfade mit @/-Alias
- Components: Atomares Design (Atoms → Molecules → Organisms → Templates → Pages)
- Error Handling: Strukturierte Fehlertypen mit Zod für Validierung
- API: tRPC für End-to-End-Typsicherheit mit Zod-Schemas

## Projekt-Architektur
- Next.js 15 mit App Router
- Tailwind CSS mit shadcn/ui-Komponenten
- Supabase für Datenbank, Auth und Storage
- Memory-Bank-System für persistenten Kontext
- MCP-Tools-Integration für externe Funktionalitäten

## Dokumentationsstandards
- Komplexe Logik mit JSDoc-Format kommentieren
- Memory-Bank-Dateien aktualisiert halten (insbesondere activeContext.md, progress.md)
- CLAUDE.md mit neuen Konventionen aktualisieren
EOL

  # Konfigurationsdateien für MCP-Integration
  cat > "$TEMPLATE_DIR/knowledgeGraph.json" << 'EOL'
{
  "entities": [],
  "relationships": [],
  "metadata": {
    "version": "1.0",
    "lastUpdated": "",
    "description": "Wissensgraph für $PROJECT"
  },
  "settings": {
    "entityTypes": ["concept", "feature", "component", "task", "actor"],
    "relationshipTypes": ["depends_on", "part_of", "associated_with", "causes", "influences"]
  }
}
EOL

  cat > "$TEMPLATE_DIR/sequentialThinking.config" << 'EOL'
{
  "thinking_modes": {
    "default": {
      "max_thoughts": 5,
      "strategy": "linear",
      "thought_token_limit": 256
    },
    "complex_problem": {
      "max_thoughts": 10,
      "strategy": "tree",
      "thought_token_limit": 512
    },
    "creative": {
      "max_thoughts": 8,
      "strategy": "divergent",
      "thought_token_limit": 384
    }
  },
  "memory_settings": {
    "short_term": {
      "max_thoughts": 20,
      "ttl": "session"
    },
    "long_term": {
      "max_thoughts": 100,
      "ttl": "permanent",
      "storage": "knowledgeGraph"
    }
  },
  "integration": {
    "mcp_server": "sequentialthinking",
    "mcp_version": "1.0",
    "active": true
  }
}
EOL

  # Vibe-Coding-Stack Dokumentation
  cat > "$TEMPLATE_DIR/tech-stacks/vibe-coding-stack.md" << 'EOL'
# Vibe-Coding-Stack

Der Vibe-Coding-Stack ist eine moderne Full-Stack-Entwicklungsumgebung für Web- und Blockchain-Anwendungen.

## Core Stack (Must-Haves)

- UI/SSR: Next.js 15 (App Router, Turbopack)
- DB + Auth: Supabase (TypeScript Edge-Funktionen)
- Hosting: Vercel (Preview-Deployments, Edge Runtime)
- Component Kit: shadcn/ui + Tailwind (100% TypeScript)
- 3D/Visuals: Three.js + react-three-fiber (Deklaratives WebGL)

## Erweiterungen für Blockchain-Integration

### Ethereum & Layer-2
- wagmi + viem
- RainbowKit oder ConnectKit
- WalletConnect v2

### Solana
- Phantom Wallet
- Anchor Framework
- Metaplex für NFTs

## DX-, Safety- & Observability-Layer

- End-to-End-Types: tRPC
- Runtime-Validation: Zod
- Data-Sync: TanStack Query v5
- Testing: Playwright
- Error-Tracking: Sentry-Vercel
EOL

  # Projekt-Initialisierungsskript
  cat > "$TEMPLATE_DIR/project-types/vibe-coding-init.sh" << 'EOL'
#!/bin/bash

# Vibe-Coding-Projekt Initialisierung
# Erstellt ein neues Projekt mit Vibe-Coding-Stack

# Variablen
PROJECT_NAME=$1
BASE_DIR="${2:-$(pwd)}"
CLAUDE_DIR="$HOME/Schreibtisch/CLAUDE"
TEMPLATE_DIR="$HOME/.claude/templates"
PROJECT_DIR="$CLAUDE_DIR/$PROJECT_NAME"

# Hilfsfunktion: Loggen
log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1"
}

# Projektstruktur erstellen
create_project_structure() {
  log "Erstelle Projektstruktur für $PROJECT_NAME"
  
  mkdir -p "$PROJECT_DIR"
  mkdir -p "$PROJECT_DIR/APP"
  mkdir -p "$PROJECT_DIR/DOCS"
  mkdir -p "$PROJECT_DIR/MARKETING"
  mkdir -p "$PROJECT_DIR/FINANCE"
  mkdir -p "$PROJECT_DIR/memory-bank"
  
  log "Projektstruktur erfolgreich erstellt"
}

# Memory-Bank initialisieren
initialize_memory_bank() {
  log "Initialisiere Memory-Bank"
  
  # Kopiere Basisdateien
  cp "$TEMPLATE_DIR/projectbrief.md" "$PROJECT_DIR/memory-bank/"
  cp "$TEMPLATE_DIR/productContext.md" "$PROJECT_DIR/memory-bank/"
  cp "$TEMPLATE_DIR/systemPatterns.md" "$PROJECT_DIR/memory-bank/"
  cp "$TEMPLATE_DIR/techContext.md" "$PROJECT_DIR/memory-bank/"
  cp "$TEMPLATE_DIR/activeContext.md" "$PROJECT_DIR/memory-bank/"
  cp "$TEMPLATE_DIR/progress.md" "$PROJECT_DIR/memory-bank/"
  cp "$TEMPLATE_DIR/CLAUDE.md" "$PROJECT_DIR/"
  
  # Ersetze Platzhalter
  find "$PROJECT_DIR/memory-bank" -type f -name "*.md" -exec sed -i "s/\$PROJECT/$PROJECT_NAME/g" {} \;
  
  # Datum in activeContext.md aktualisieren
  today=$(date +"%Y-%m-%d")
  sed -i "s/\[Datum\]/$today/g" "$PROJECT_DIR/memory-bank/activeContext.md"
  
  log "Memory-Bank erfolgreich initialisiert"
}

# Next.js mit Vibe-Coding-Stack initialisieren
initialize_nextjs() {
  log "Initialisiere Next.js mit Vibe-Coding-Stack"
  
  cd "$PROJECT_DIR/APP"
  
  # Next.js-Projekt erstellen
  npx create-next-app@latest . --app --ts --tailwind --eslint
  
  # shadcn/ui hinzufügen
  npx shadcn-ui@latest init
  
  # Basiskomponenten installieren
  npx shadcn-ui@latest add button card dialog dropdown-menu input toast
  
  # tRPC installieren
  npm install @trpc/server @trpc/client @trpc/next @trpc/react-query zod superjson
  
  # 3D-Komponenten installieren
  npm install three @react-three/fiber @react-three/drei
  npm install --save-dev @types/three
  
  log "Next.js-Projekt mit Vibe-Coding-Stack erfolgreich initialisiert"
}

# README erstellen
create_readme() {
  log "Erstelle README.md"
  
  cat > "$PROJECT_DIR/README.md" << EOF
# $PROJECT_NAME

## Über dieses Projekt
Dieses Projekt wurde mit dem CLAUDE Vibe-Coding-Setup initialisiert.

## Tech-Stack
- Next.js 15
- Supabase
- Tailwind CSS + shadcn/ui
- tRPC für typsichere API
- Weitere Details: siehe \`DOCS/vibe-coding-stack.md\`

## Ordnerstruktur
- APP: Anwendungscode
- MARKETING: Marketing-Materialien
- FINANCE: Finanzinformationen
- DOCS: Dokumentation
- memory-bank: Claude-Memory-Bank für Projektkontinuität

## Getting Started
1. Installiere Abhängigkeiten:
   \`\`\`
   cd APP
   npm install
   \`\`\`

2. Konfiguriere .env-Datei

3. Starte den Entwicklungsserver:
   \`\`\`
   npm run dev
   \`\`\`

4. Öffne [http://localhost:3000](http://localhost:3000) im Browser

Weitere Details findest du in der memory-bank/techContext.md
EOF
  
  # Vibe-Coding-Stack Dokumentation kopieren
  mkdir -p "$PROJECT_DIR/DOCS"
  cp "$TEMPLATE_DIR/tech-stacks/vibe-coding-stack.md" "$PROJECT_DIR/DOCS/"
  
  log "README.md erfolgreich erstellt"
}

# Git-Repository initialisieren
initialize_git() {
  log "Initialisiere Git-Repository"
  
  cd "$PROJECT_DIR"
  
  # .gitignore erstellen
  cat > "$PROJECT_DIR/.gitignore" << EOF
# Sensible Dateien
.env
.env.*
.about
.DS_Store

# Node.js
node_modules/
.npm
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Next.js
.next/
out/

# Vercel
.vercel

# VS Code
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

# Supabase
.supabase/
EOF
  
  # Git initialisieren und ersten Commit erstellen
  git init
  git add .
  git commit -m "Initial commit: Vibe-Coding-Projekt"
  
  log "Git-Repository erfolgreich initialisiert"
}

# Hauptfunktion
main() {
  if [ -z "$PROJECT_NAME" ]; then
    echo "Fehler: Bitte Projektnamen angeben"
    echo "Verwendung: $0 <projektname> [projektverzeichnis]"
    exit 1
  fi
  
  log "Starte Initialisierung für Vibe-Coding-Projekt: $PROJECT_NAME"
  
  create_project_structure
  initialize_memory_bank
  initialize_nextjs
  create_readme
  initialize_git
  
  log "Vibe-Coding-Projekt '$PROJECT_NAME' erfolgreich initialisiert"
  echo ""
  echo "Projekt-Verzeichnis: $PROJECT_DIR"
  echo "Führe folgende Befehle aus, um zu starten:"
  echo "  cd $PROJECT_DIR/APP"
  echo "  npm run dev"
}

main
EOL

  # Skript ausführbar machen
  chmod +x "$TEMPLATE_DIR/project-types/vibe-coding-init.sh"

  log "SUCCESS" "Template-Dateien erstellt."
}

# Globale Utility-Skripte erstellen
create_utility_scripts() {
  log "INFO" "Erstelle globale Utility-Skripte..."
  
  # Projekt-Initialisierungsskript
  cat > "$INSTALL_DIR/init-project.sh" << 'EOL'
#!/bin/bash

# Standard-Projekt-Initialisierung
# Erstellt ein neues Projekt mit Memory-Bank-System

# Variablen
PROJECT_NAME=$1
CLAUDE_DIR="$HOME/Schreibtisch/CLAUDE"
TEMPLATE_DIR="$HOME/.claude/templates"
PROJECT_DIR="$CLAUDE_DIR/$PROJECT_NAME"

# Hilfsfunktion: Loggen
log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1"
}

# Projektstruktur erstellen
create_project_structure() {
  log "Erstelle Projektstruktur für $PROJECT_NAME"
  
  mkdir -p "$PROJECT_DIR"
  mkdir -p "$PROJECT_DIR/APP"
  mkdir -p "$PROJECT_DIR/DOCS"
  mkdir -p "$PROJECT_DIR/MARKETING"
  mkdir -p "$PROJECT_DIR/FINANCE"
  mkdir -p "$PROJECT_DIR/memory-bank"
  
  log "Projektstruktur erfolgreich erstellt"
}

# Memory-Bank initialisieren
initialize_memory_bank() {
  log "Initialisiere Memory-Bank"
  
  # Kopiere Basisdateien
  cp "$TEMPLATE_DIR/projectbrief.md" "$PROJECT_DIR/memory-bank/"
  cp "$TEMPLATE_DIR/productContext.md" "$PROJECT_DIR/memory-bank/"
  cp "$TEMPLATE_DIR/systemPatterns.md" "$PROJECT_DIR/memory-bank/"
  cp "$TEMPLATE_DIR/techContext.md" "$PROJECT_DIR/memory-bank/"
  cp "$TEMPLATE_DIR/activeContext.md" "$PROJECT_DIR/memory-bank/"
  cp "$TEMPLATE_DIR/progress.md" "$PROJECT_DIR/memory-bank/"
  cp "$TEMPLATE_DIR/CLAUDE.md" "$PROJECT_DIR/"
  
  # Ersetze Platzhalter
  find "$PROJECT_DIR/memory-bank" -type f -name "*.md" -exec sed -i "s/\$PROJECT/$PROJECT_NAME/g" {} \;
  
  # Datum in activeContext.md aktualisieren
  today=$(date +"%Y-%m-%d")
  sed -i "s/\[Datum\]/$today/g" "$PROJECT_DIR/memory-bank/activeContext.md"
  
  log "Memory-Bank erfolgreich initialisiert"
}

# README erstellen
create_readme() {
  log "Erstelle README.md"
  
  cat > "$PROJECT_DIR/README.md" << EOF
# $PROJECT_NAME

Ein Projekt mit CLAUDE Memory-Bank für strukturierte Entwicklung.

## Ordnerstruktur
- APP: Anwendungscode
- DOCS: Dokumentation
- MARKETING: Marketing-Materialien
- FINANCE: Finanzinformationen
- memory-bank: Claude-Memory-Bank für Projektkontinuität

## Memory-Bank-System
Die Memory-Bank dieses Projekts enthält:
- projectbrief.md: Grundlegende Projektdefinition
- productContext.md: Zweck und Problemlösung
- systemPatterns.md: Systemarchitektur und Design-Patterns
- techContext.md: Verwendete Technologien
- activeContext.md: Aktueller Arbeitsfokus
- progress.md: Aktueller Status und nächste Schritte

## Getting Started
Siehe memory-bank/projectbrief.md für weitere Details zu diesem Projekt.
EOF
  
  log "README.md erfolgreich erstellt"
}

# Git-Repository initialisieren
initialize_git() {
  log "Initialisiere Git-Repository"
  
  cd "$PROJECT_DIR"
  
  # .gitignore erstellen
  cat > "$PROJECT_DIR/.gitignore" << EOF
# Sensible Dateien
.env
.env.*
.about
.DS_Store

# Node.js
node_modules/
.npm
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# VS Code
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
EOF
  
  # Git initialisieren und ersten Commit erstellen
  git init
  git add .
  git commit -m "Initial commit: Projektstruktur mit Memory-Bank"
  
  log "Git-Repository erfolgreich initialisiert"
}

# Hauptfunktion
main() {
  if [ -z "$PROJECT_NAME" ]; then
    echo "Fehler: Bitte Projektnamen angeben"
    echo "Verwendung: $0 <projektname>"
    exit 1
  fi
  
  log "Starte Initialisierung für Projekt: $PROJECT_NAME"
  
  create_project_structure
  initialize_memory_bank
  create_readme
  initialize_git
  
  log "Projekt '$PROJECT_NAME' erfolgreich initialisiert"
  echo ""
  echo "Projekt-Verzeichnis: $PROJECT_DIR"
  echo "Nutze Claude mit Memory-Bank-Integration, um das Projekt zu bearbeiten."
}

main
EOL

  # Memory-Bank-Update-Skript
  cat > "$INSTALL_DIR/update-memory.sh" << 'EOL'
#!/bin/bash

# Memory-Bank-Update-Skript
# Aktualisiert die Memory-Bank eines Projekts

# Variablen
PROJECT_PATH=$1
MEMORY_BANK_DIR="$PROJECT_PATH/memory-bank"

# Hilfsfunktion: Loggen
log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1"
}

# Aktiver Kontext aktualisieren
update_active_context() {
  local today=$(date +"%Y-%m-%d")
  local file="$MEMORY_BANK_DIR/activeContext.md"
  
  if [ -f "$file" ]; then
    # Letzte Änderungen aktualisieren
    sed -i "0,/## Letzte Änderungen/,/##/{s/## Letzte Änderungen\n/## Letzte Änderungen\n- $today: Memory-Bank-Update\n/}" "$file"
    
    # Aktualisiere "Aktualisiert am"
    sed -i "s/## Aktualisiert am\n.*$/## Aktualisiert am\n$today/" "$file"
    
    log "Aktiver Kontext aktualisiert."
  else
    log "WARNUNG: activeContext.md nicht gefunden."
  fi
}

# Knowledge Graph aktualisieren
update_knowledge_graph() {
  local file="$MEMORY_BANK_DIR/knowledgeGraph.json"
  
  if [ -f "$file" ]; then
    # Update lastUpdated in metadata
    local temp_file=$(mktemp)
    jq ".metadata.lastUpdated = \"$(date -Iseconds)\"" "$file" > "$temp_file"
    mv "$temp_file" "$file"
    
    log "Knowledge Graph aktualisiert."
  else
    log "WARNUNG: knowledgeGraph.json nicht gefunden."
  fi
}

# Backup erstellen
create_backup() {
  local timestamp=$(date +"%Y%m%d_%H%M%S")
  local backup_dir="$PROJECT_PATH/backups/$timestamp"
  
  mkdir -p "$backup_dir"
  
  # Kopiere Memory-Bank-Dateien
  cp -r "$MEMORY_BANK_DIR"/* "$backup_dir/"
  
  log "Backup erstellt: $backup_dir"
}

# Hauptfunktion
main() {
  if [ -z "$PROJECT_PATH" ]; then
    echo "Fehler: Projektpfad erforderlich."
    echo "Verwendung: $0 /pfad/zum/projekt"
    exit 1
  fi
  
  if [ ! -d "$MEMORY_BANK_DIR" ]; then
    echo "Fehler: Memory-Bank-Verzeichnis nicht gefunden in $MEMORY_BANK_DIR"
    exit 1
  fi
  
  log "Aktualisiere Memory-Bank in $PROJECT_PATH"
  
  update_active_context
  update_knowledge_graph
  create_backup
  
  log "Memory-Bank erfolgreich aktualisiert."
}

main
EOL

  # Memory-Bank CLI-Tool
  cat > "$INSTALL_DIR/memory-bank-cli.js" << 'EOL'
#!/usr/bin/env node

// Memory-Bank CLI-Tool
// Verwaltet Memory-Bank-Projekte

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Konfiguration
const CONFIG = {
  installDir: process.env.HOME + '/.claude',
  claudeDir: process.env.HOME + '/Schreibtisch/CLAUDE'
};

// Befehlsdefinitionen
const COMMANDS = {
  init: {
    description: 'Initialisiere ein neues Projekt mit Memory-Bank',
    usage: 'memory-bank init <projektname>'
  },
  vibe: {
    description: 'Initialisiere ein neues Vibe-Coding-Projekt',
    usage: 'memory-bank vibe <projektname>'
  },
  update: {
    description: 'Aktualisiere die Memory-Bank eines Projekts',
    usage: 'memory-bank update <projektpfad>'
  },
  backup: {
    description: 'Erstelle ein Backup der Memory-Bank',
    usage: 'memory-bank backup <projektpfad>'
  },
  help: {
    description: 'Zeige Hilfe an',
    usage: 'memory-bank help [befehl]'
  }
};

// Hilfsfunktionen
function showHelp(command) {
  if (command && COMMANDS[command]) {
    console.log(`\n${COMMANDS[command].description}`);
    console.log(`Verwendung: ${COMMANDS[command].usage}\n`);
  } else {
    console.log('\nMemory-Bank CLI - Verwaltungstool für Claude Memory-Bank\n');
    console.log('Verfügbare Befehle:');
    
    Object.keys(COMMANDS).forEach(cmd => {
      console.log(`  ${cmd.padEnd(10)} ${COMMANDS[cmd].description}`);
    });
    
    console.log('\nFür Hilfe zu einem bestimmten Befehl: memory-bank help <befehl>\n');
  }
}

function executeCommand(command) {
  try {
    return execSync(command, { stdio: 'inherit' });
  } catch (error) {
    console.error(`Fehler beim Ausführen von: ${command}`);
    console.error(error.message);
    process.exit(1);
  }
}

// Befehlsimplementierungen
function initProject(args) {
  const projectName = args[0];
  
  if (!projectName) {
    console.error('Fehler: Projektname erforderlich');
    console.log(`Verwendung: ${COMMANDS.init.usage}`);
    process.exit(1);
  }
  
  executeCommand(`${CONFIG.installDir}/init-project.sh "${projectName}"`);
}

function initVibeProject(args) {
  const projectName = args[0];
  
  if (!projectName) {
    console.error('Fehler: Projektname erforderlich');
    console.log(`Verwendung: ${COMMANDS.vibe.usage}`);
    process.exit(1);
  }
  
  executeCommand(`${CONFIG.installDir}/templates/project-types/vibe-coding-init.sh "${projectName}"`);
}

function updateMemoryBank(args) {
  const projectPath = args[0];
  
  if (!projectPath) {
    console.error('Fehler: Projektpfad erforderlich');
    console.log(`Verwendung: ${COMMANDS.update.usage}`);
    process.exit(1);
  }
  
  executeCommand(`${CONFIG.installDir}/update-memory.sh "${projectPath}"`);
}

function backupMemoryBank(args) {
  const projectPath = args[0];
  
  if (!projectPath) {
    console.error('Fehler: Projektpfad erforderlich');
    console.log(`Verwendung: ${COMMANDS.backup.usage}`);
    process.exit(1);
  }
  
  const memoryBankPath = path.join(projectPath, 'memory-bank');
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const backupDir = path.join(projectPath, 'backups', timestamp);
  
  if (!fs.existsSync(memoryBankPath)) {
    console.error(`Fehler: Memory-Bank nicht gefunden in ${memoryBankPath}`);
    process.exit(1);
  }
  
  try {
    fs.mkdirSync(backupDir, { recursive: true });
    
    const files = fs.readdirSync(memoryBankPath);
    for (const file of files) {
      if (file === 'backups') continue;
      
      const sourcePath = path.join(memoryBankPath, file);
      const destPath = path.join(backupDir, file);
      
      if (fs.statSync(sourcePath).isDirectory()) {
        executeCommand(`cp -r "${sourcePath}" "${destPath}"`);
      } else {
        fs.copyFileSync(sourcePath, destPath);
      }
    }
    
    console.log(`Backup erstellt: ${backupDir}`);
  } catch (error) {
    console.error('Fehler bei der Backup-Erstellung:', error.message);
    process.exit(1);
  }
}

// Hauptfunktion
function main() {
  const args = process.argv.slice(2);
  const command = args.shift();
  
  switch (command) {
    case 'init':
      initProject(args);
      break;
    case 'vibe':
      initVibeProject(args);
      break;
    case 'update':
      updateMemoryBank(args);
      break;
    case 'backup':
      backupMemoryBank(args);
      break;
    case 'help':
      showHelp(args[0]);
      break;
    default:
      console.log(`Unbekannter Befehl: ${command || 'keiner'}`);
      showHelp();
      process.exit(1);
  }
}

// Start
main();
EOL

  # Skripte ausführbar machen
  chmod +x "$INSTALL_DIR/init-project.sh"
  chmod +x "$INSTALL_DIR/update-memory.sh"
  chmod +x "$INSTALL_DIR/memory-bank-cli.js"
  
  # Symbolischer Link für CLI-Tool
  if [ ! -d "/usr/local/bin" ]; then
    sudo mkdir -p /usr/local/bin
  fi
  
  if [ -L "/usr/local/bin/memory-bank" ]; then
    sudo rm /usr/local/bin/memory-bank
  fi
  
  sudo ln -s "$INSTALL_DIR/memory-bank-cli.js" "/usr/local/bin/memory-bank"
  
  log "SUCCESS" "Utility-Skripte erstellt und installiert."
}

# Globale CLAUDE.md erstellen
create_global_claude_md() {
  log "INFO" "Erstelle globale CLAUDE.md..."
  
  cat > "$CLAUDE_DIR/CLAUDE.md" << 'EOL'
# CLAUDE.md

Diese Datei bietet Anweisungen für Claude Code (claude.ai/code) bei der Arbeit mit diesem Repository.

## CLAUDE AGI-System v1.0

Das CLAUDE AGI-System dient zur strukturierten Organisation und Verwaltung aller Claude-basierten Projekte mit einem Memory-Bank-System für die Kontinuität zwischen Sitzungen und MCP-Tools für erweiterte Funktionalität.

## Hauptprinzipien
1. **Persistente Dokumentation**: Jedes Projekt erhält einen eigenen memory-bank Ordner
2. **Standardisierte Struktur**: APP/MARKETING/FINANCE Unterordner für klare Organisation
3. **MCP-Integration**: Nahtlose Nutzung von Desktop Commander und weiteren MCP-Tools
4. **Vibe Coding**: Einsatz moderner Full-Stack-Technologien für effiziente Entwicklung

## Memory-Bank-System
Bei jedem Projekt solltest du die memory-bank Dateien berücksichtigen:
- projectbrief.md: Grundlegende Projektdefinition
- productContext.md: Zweck und Problemlösung des Projekts
- activeContext.md: Aktueller Arbeitsfokus
- systemPatterns.md: Systemarchitektur und Design-Patterns
- techContext.md: Verwendete Technologien
- progress.md: Aktueller Status und nächste Schritte

## Vibe Coding Framework
Das bevorzugte Technologie-Stack besteht aus:
- Next.js 15 mit App Router
- Supabase für Datenbank, Auth, Edge Functions
- Tailwind + shadcn/ui für UI-Komponenten
- tRPC + Zod für typsichere API
- Three.js + react-three-fiber für 3D-Visualisierungen

## Wichtige Befehle
- `memory-bank init <projektname>` - Neues Projekt initialisieren
- `memory-bank vibe <projektname>` - Vibe-Coding-Projekt initialisieren
- `memory-bank update <projektpfad>` - Memory-Bank aktualisieren
EOL

  log "SUCCESS" "Globale CLAUDE.md erstellt."
}

# Hauptfunktion
main() {
  # Banner anzeigen (bereits am Anfang durchgeführt)
  
  # Sicherheitsüberprüfung
  verify_security
  
  # Voraussetzungen prüfen
  check_prerequisites
  
  # Claude Pro MAX überprüfen
  verify_claude_pro_max
  
  # Verzeichnisstruktur erstellen
  create_directory_structure
  
  # MCP-Server konfigurieren
  configure_mcp_servers
  
  # Template-Dateien erstellen
  create_template_files
  
  # Utility-Skripte erstellen
  create_utility_scripts
  
  # Globale CLAUDE.md erstellen
  create_global_claude_md
  
  # Erfolgreicher Abschluss
  echo ""
  echo -e "${GREEN}✅ CLAUDE-AGI Framework erfolgreich installiert!${NC}"
  echo ""
  echo -e "${BLUE}Installierte Komponenten:${NC}"
  echo "- Memory-Bank-System mit Templates"
  echo "- MCP-Server-Konfiguration (smithery-frei)"
  echo "- Utility-Skripte für Projektverwaltung"
  echo "- Vibe-Coding-Stack-Initialisierung"
  echo ""
  echo -e "${BLUE}Verfügbare Befehle:${NC}"
  echo "- memory-bank init <projektname> - Neues Projekt initialisieren"
  echo "- memory-bank vibe <projektname> - Vibe-Coding-Projekt initialisieren"
  echo "- memory-bank update <projektpfad> - Memory-Bank aktualisieren"
  echo "- memory-bank backup <projektpfad> - Memory-Bank-Backup erstellen"
  echo "- memory-bank help - Hilfe anzeigen"
  echo ""
  echo -e "${BLUE}Nächste Schritte:${NC}"
  echo "1. Öffne Claude Desktop"
  echo "2. Gehe zu Settings → Import Config"
  echo "3. Wähle $CONFIG_DIR/claude_desktop_config.json"
  echo ""
  echo -e "${YELLOW}Hinweis: Für vollständige Funktionalität wird Claude Pro MAX empfohlen.${NC}"
  echo ""
}

# Ausführung
main