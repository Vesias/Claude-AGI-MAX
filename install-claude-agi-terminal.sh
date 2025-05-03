#!/bin/bash

# CLAUDE-AGI-Terminal: Integrierter Installer für AGI + Terminal
# Version 1.1 - 2025-05-03
# Standardisierte Projektstruktur mit claude-agi-projects

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
echo -e "${BLUE}AGI + Terminal-Integration mit standardisierter Projektstruktur${NC}"
echo -e "${BLUE}Version 1.1 • Claude Pro MAX Edition${NC}"
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

# Standardisierte Projektstruktur erstellen
create_standardized_structure() {
  log "INFO" "Erstelle standardisierte Projektstruktur..."
  
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

# Haupt-Installation
main() {
  # Sichere Datenmigration zuerst
  secure_data_migration
  
  # Basis-Voraussetzungen prüfen
  check_prerequisites 2>/dev/null || true
  
  # Standardisierte Projektstruktur erstellen
  create_standardized_structure
  
  # MCP-Konfiguration aktualisieren
  update_mcp_config
  
  # Terminal-Anpassungen
  adapt_terminal_for_structure
  
  # .gitignore aktualisieren
  update_gitignore
  
  # CLAUDE.md aktualisieren
  cat > "$CLAUDE_DIR/CLAUDE.md" << EOL
# CLAUDE.md

Diese Datei bietet Anweisungen für Claude Code (claude.ai/code) bei der Arbeit mit diesem Repository.

## CLAUDE AGI-Terminal-System v1.1

Das CLAUDE AGI-Terminal-System nutzt eine standardisierte Projektstruktur mit claude-agi-projects.

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
└── .config/                  # MCP-Konfiguration
\`\`\`

## Wichtige Regeln
1. Alle AGI-Projekte werden in claude-agi-projects/ verwaltet
2. Terminal arbeitet automatisch in default-project/
3. Private Projekte (goldankauf, aclearallb.gg, etc.) werden NICHT im Git eingecheckt
4. Memory-Bank wird pro Projekt strukturiert

## Befehle
- \`cd claude-terminal && npm start\`: Terminal in Standard-Projektstruktur starten
- \`cd claude-agi-projects/default-project\`: Zum Hauptarbeitsverzeichnis wechseln
EOL

  # Erfolgreicher Abschluss
  echo ""
  echo -e "${GREEN}✅ Claude-AGI mit standardisierter Projektstruktur installiert!${NC}"
  echo ""
  echo -e "${BLUE}Standardisierte Struktur:${NC}"
  echo "- Projektverzeichnis: $AGI_PROJECTS_DIR"
  echo "- Standard-Arbeitsverzeichnis: $DEFAULT_PROJECT_DIR"
  echo "- Memory-Bank-System: Strukturiert nach Projekten"
  echo ""
  echo -e "${YELLOW}Hinweise:${NC}"
  echo "- Sensible Projekte werden automatisch ausgeschlossen"
  echo "- Terminal arbeitet automatisch im Standardprojekt"
  echo "- Alle Projektdaten sind durch .gitignore geschützt"
  echo ""
}

# Ausführung
main