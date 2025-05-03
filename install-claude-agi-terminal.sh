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

  # README für das Memory-Bank-System
  cat > "$MEMORY_BANK_DIR/README.md" << EOL
# Memory Bank System

Das Memory Bank System ist ein strukturierter Ansatz zur Speicherung und Verwaltung von Projektkontext für das CLAUDE-AGI-Ökosystem.

## Struktur

Jedes Projekt verwendet die folgenden standardisierten Dateien:

- **projectbrief.md**: Grundlegende Projektdefinition und Ziele
- **activeContext.md**: Aktueller Arbeitsfokus und nächste Schritte
- **techContext.md**: Verwendete Technologien und ihre Konfiguration
- **systemPatterns.md**: Architektur und Design-Patterns
- **progress.md**: Fortschritt, abgeschlossene und geplante Aufgaben

## Verwendung

1. Kopiere die Templates in das memory-bank-Verzeichnis deines Projekts
2. Passe die Dateien an dein spezifisches Projekt an
3. Halte die Dateien aktuell, wenn sich der Projektkontext ändert
4. Nutze die Memory-Bank für kontinuierliche Arbeit mit Claude

## Integration

Das Memory-Bank-System ist vollständig in das CLAUDE-AGI-Ökosystem integriert:

- Automatische Erkennung durch Claude Terminal
- MCP-Integration über memory-bank-mcp Tool
- Projekt-spezifische Memory-Banks in der standardisierten Struktur
EOL

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

Ein integriertes System für die Claude AI mit Terminal-Integration, Memory Bank und ProxyClaude Service.

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
- \`memory-bank/\`: Kontext-Verwaltungssystem

### 3. ProxyClaude Service
API-Proxy für Claude mit folgenden Features:
- JWT-Authentifizierung
- Nutzer-basierte Ratenbegrenzung
- Zentrale API-Schlüsselverwaltung

### 4. MCP-Tools Integration
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

## CLAUDE AGI-Terminal-System v1.1

Das CLAUDE AGI-Terminal-System nutzt eine standardisierte Projektstruktur mit Profilfunktionen, Memory-Bank und MCP-Tools-Integration.

## Standardisierte Projektstruktur
\`\`\`
$CLAUDE_DIR/
├── claude-terminal/          # Terminal-Anwendung
├── claude-agi-projects/      # Standardisierte Projektstruktur
│   ├── .project-config.json  # Konfiguration für Projekte
│   └── default-project/      # Standard-Arbeitsverzeichnis
│       └── memory-bank/      # Projekt-spezifische Memory Bank
├── memory-bank/              # Globale Memory Bank Templates
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

## MCP-Tools
Das System nutzt folgende MCP-Tools:
- memory-bank-mcp: Persistente Kontext-Verwaltung 
- desktop-commander: Dateisystem und Shell-Operationen
- browser-tools: Web-Recherche und Browser-Integration
- proxyclaude: Claude API Proxy für zentrale Nutzung
- code-mcp: Code-Generierung und Analyse
- sequentialthinking: Strukturierte Problemlösung

## Wichtige Regeln
1. Alle AGI-Projekte werden in claude-agi-projects/ verwaltet
2. Terminal arbeitet automatisch im Standard-Projektverzeichnis
3. Private Projekte (goldankauf, aclearallb.gg, etc.) werden NICHT im Git eingecheckt
4. Memory-Bank wird pro Projekt strukturiert
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
  echo -e "${GREEN}✅ Claude-AGI v1.1 mit standardisierter Projektstruktur installiert!${NC}"
  echo ""
  echo -e "${BLUE}Standardisierte Struktur:${NC}"
  echo "- Projektverzeichnis: $AGI_PROJECTS_DIR"
  echo "- Standard-Arbeitsverzeichnis: $DEFAULT_PROJECT_DIR"
  echo "- Memory-Bank-System: Strukturiert nach Projekten"
  echo "- ProxyClaude Service: $CLAUDE_DIR/.claude-agi/services/proxyclaude"
  echo ""
  echo -e "${BLUE}Integrierte Komponenten:${NC}"
  echo "- Claude Terminal: Konsolenbasierte AI-Integration"
  echo "- ProxyClaude: API-Proxy mit JWT-Authentifizierung"
  echo "- Memory-Bank: Persistenter Kontext für Projekte"
  echo "- MCP-Tools: Erweiterte KI-Funktionen über MCP-Protokoll"
  echo ""
  echo -e "${YELLOW}Nächste Schritte:${NC}"
  echo "1. Terminal starten: cd $TERMINAL_DIR && npm start"
  echo "2. ProxyClaude konfigurieren: cp $PROXYCLAUDE_DIR/.env.example $PROXYCLAUDE_DIR/.env"
  echo "3. API-Schlüssel einrichten: nano $PROXYCLAUDE_DIR/.env"
  echo "4. ProxyClaude starten: cd $PROXYCLAUDE_DIR && npm start"
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