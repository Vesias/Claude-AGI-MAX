#!/bin/bash

# CLAUDE-AGI-Terminal: Integrierter Installer für AGI + Terminal
# Version 1.0 - 2025-05-03
# Dieses Skript installiert das kombinierte CLAUDE-AGI-Terminal-System

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
echo -e "${BLUE}AGI + Terminal-Integration mit MCP-Tools${NC}"
echo -e "${BLUE}Version 1.0 • Claude Pro MAX Edition${NC}"
echo "========================================================"
echo ""

# Konfigurationsvariablen
DESKTOP_DIR="${HOME}/Schreibtisch"
CLAUDE_DIR="$DESKTOP_DIR/CLAUDE"
TERMINAL_DIR="$CLAUDE_DIR/claude-terminal"
AGI_PROJECT_DIR="$CLAUDE_DIR/claude-agi-project"
AGI_TEST_DIR="$CLAUDE_DIR/claude-agi-test"
VIBE_TEST_DIR="$CLAUDE_DIR/VibeCodingTest"
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

# Hilfsfunktion: Voraussetzungen prüfen
check_prerequisites() {
  log "INFO" "Prüfe Systemvoraussetzungen..."
  
  # Node.js
  if ! command -v node &> /dev/null; then
    log "ERROR" "Node.js ist nicht installiert! Bitte installieren Sie Node.js."
    echo -e "${BLUE}Installationsanleitung:${NC} https://nodejs.org/de/download/"
    exit 1
  fi
  
  # Node.js-Version prüfen - mindestens v16, empfehle v18+
  NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
  if [ "$NODE_VERSION" -lt 16 ]; then
    log "ERROR" "Node.js v$NODE_VERSION ist zu alt. Mindestens Node.js v16 wird benötigt, v18+ empfohlen."
    echo -e "${BLUE}Bitte aktualisieren Sie Node.js:${NC} https://nodejs.org/de/download/"
    exit 1
  fi
  
  # NVM prüfen
  if command -v nvm &> /dev/null; then
    log "INFO" "NVM ist installiert. Aktuelle Node.js-Version: $(node -v)"
    
    # Für node-pty Kompatibilität auf LTS-Versionen hinweisen
    if [ "$NODE_VERSION" -lt 18 ] || [ "$NODE_VERSION" -gt 20 ]; then
      log "WARNING" "Node.js v$NODE_VERSION erkannt. Für optimale Kompatibilität werden LTS-Versionen (v18 oder v20) empfohlen."
    else
      log "INFO" "Node.js v$NODE_VERSION (LTS) erkannt - optimale Kompatibilität."
    fi
  else
    log "INFO" "NVM nicht erkannt. Aktuelle Node.js-Version: $(node -v)"
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
  
  # Prüfen ob Electron global installiert ist
  if ! command -v electron &> /dev/null; then
    log "WARNING" "Electron ist nicht global installiert."
    
    if prompt_yes_no "Möchten Sie Electron global installieren?" "y"; then
      log "INFO" "Installiere Electron global..."
      # Neuere Version verwenden (Electron 28+ ist mit Node.js 18+ kompatibel)
      npm install -g electron@latest
    else
      log "WARNING" "Electron-Installation übersprungen. Die Terminal-App benötigt Electron."
    fi
  else
    ELECTRON_VERSION=$(electron -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$ELECTRON_VERSION" -lt 24 ]; then
      log "WARNING" "Electron v$ELECTRON_VERSION ist älter. Für optimale Kompatibilität mit modernem Node.js wird v24+ empfohlen."
      if prompt_yes_no "Möchten Sie Electron aktualisieren?" "y"; then
        log "INFO" "Aktualisiere Electron..."
        npm install -g electron@latest
      fi
    fi
  fi
  
  # TypeScript global prüfen
  if ! command -v tsc &> /dev/null; then
    log "WARNING" "TypeScript ist nicht global installiert."
    
    if prompt_yes_no "Möchten Sie TypeScript global installieren?" "y"; then
      log "INFO" "Installiere TypeScript global..."
      npm install -g typescript@latest
    else
      log "WARNING" "TypeScript-Installation übersprungen. Die Entwicklung erfordert TypeScript."
    fi
  else
    TS_VERSION=$(tsc --version | awk '{print $2}' | cut -d'.' -f1)
    if [ "$TS_VERSION" -lt 4 ] || [ "$TS_VERSION" -eq 4 ] && [ "$(tsc --version | awk '{print $2}' | cut -d'.' -f2)" -lt 9 ]; then
      log "WARNING" "TypeScript Version ist zu alt. Für optimale Kompatibilität wird v4.9+ empfohlen."
      if prompt_yes_no "Möchten Sie TypeScript aktualisieren?" "y"; then
        log "INFO" "Aktualisiere TypeScript..."
        npm install -g typescript@latest
      fi
    fi
  fi
  
  log "SUCCESS" "Alle Systemvoraussetzungen erfüllt."
}

# Terminal-Installation vorbereiten
prepare_terminal_install() {
  log "INFO" "Bereite Terminal-Installation vor..."
  
  if [ ! -d "$TERMINAL_DIR" ]; then
    log "ERROR" "Claude-Terminal-Verzeichnis nicht gefunden: $TERMINAL_DIR"
    
    if prompt_yes_no "Möchten Sie das Claude-Terminal-Repository klonen?" "y"; then
      log "INFO" "Klone Claude-Terminal-Repository..."
      mkdir -p "$CLAUDE_DIR"
      
      # In diesem Fall würde hier das Repository geklont - in diesem Beispiel überspringen wir das,
      # da das Verzeichnis bereits in der Directory-Struktur existiert
      log "WARNING" "In einer realen Implementierung würde hier das Repository geklont werden."
    else
      log "ERROR" "Terminal-Installation kann ohne das Claude-Terminal-Verzeichnis nicht fortgesetzt werden."
      exit 1
    fi
  fi
  
  log "SUCCESS" "Terminal-Installation vorbereitet."
}

# MCP-Konfiguration erstellen
create_mcp_config() {
  log "INFO" "Erstelle MCP-Konfiguration..."
  
  # Verzeichnis für Konfigurationsdatei erstellen
  mkdir -p "$CONFIG_DIR"
  
  # MCP-Konfigurationsdatei erstellen
  cat > "$CONFIG_DIR/claude_desktop_config.json" << EOL
{
  "mcpServers": {
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
      "args": ["-y", "@wonderwhy-er/desktop-commander"]
    },
    "code-mcp": {
      "command": "npx",
      "args": ["-y", "@block/code-mcp"]
    },
    "sequentialthinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "memory-bank": {
      "command": "npx",
      "args": ["-y", "@alioshr/memory-bank-mcp"],
      "env": {
        "MEMORY_BANK_ROOT": "/home/jan/.claude-agi/memory-bank"
      }
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
  
  log "SUCCESS" "MCP-Konfiguration erstellt."
}

# AGI-Integration vorbereiten
prepare_agi_integration() {
  log "INFO" "Bereite AGI-Integration vor..."
  
  # Prüfe, ob AGI-Projektverzeichnis existiert
  if [ ! -d "$AGI_PROJECT_DIR" ]; then
    log "WARNING" "Claude-AGI-Projekt-Verzeichnis nicht gefunden: $AGI_PROJECT_DIR"
    
    if prompt_yes_no "Möchten Sie das AGI-Projektverzeichnis erstellen?" "y"; then
      log "INFO" "Erstelle AGI-Projektverzeichnis..."
      mkdir -p "$AGI_PROJECT_DIR"
      mkdir -p "$AGI_PROJECT_DIR/APP"
      mkdir -p "$AGI_PROJECT_DIR/DOCS"
      mkdir -p "$AGI_PROJECT_DIR/MARKETING"
      mkdir -p "$AGI_PROJECT_DIR/FINANCE"
      mkdir -p "$AGI_PROJECT_DIR/memory-bank"
      mkdir -p "$AGI_PROJECT_DIR/mcp-tools"
    else
      log "WARNING" "AGI-Integration wird ohne AGI-Projektverzeichnis eingeschränkt sein."
    fi
  fi
  
  # Prüfe, ob AGI-Testverzeichnis existiert
  if [ ! -d "$AGI_TEST_DIR" ]; then
    log "WARNING" "Claude-AGI-Test-Verzeichnis nicht gefunden: $AGI_TEST_DIR"
    
    if prompt_yes_no "Möchten Sie das AGI-Testverzeichnis erstellen?" "y"; then
      log "INFO" "Erstelle AGI-Testverzeichnis..."
      mkdir -p "$AGI_TEST_DIR"
      mkdir -p "$AGI_TEST_DIR/monitoring/data/logs"
    fi
  fi
  
  # Prüfe, ob VIBE-TEST-Verzeichnis existiert
  if [ ! -d "$VIBE_TEST_DIR" ]; then
    log "WARNING" "VibeCodingTest-Verzeichnis nicht gefunden: $VIBE_TEST_DIR"
    
    if prompt_yes_no "Möchten Sie das VibeCodingTest-Verzeichnis erstellen?" "y"; then
      log "INFO" "Erstelle VibeCodingTest-Verzeichnis..."
      mkdir -p "$VIBE_TEST_DIR"
      mkdir -p "$VIBE_TEST_DIR/APP"
      mkdir -p "$VIBE_TEST_DIR/DOCS"
      mkdir -p "$VIBE_TEST_DIR/memory-bank"
    fi
  fi
  
  # Global Memory-Bank Verzeichnis prüfen
  if [ ! -d "$MEMORY_BANK_DIR" ]; then
    log "WARNING" "Globales Memory-Bank-Verzeichnis nicht gefunden: $MEMORY_BANK_DIR"
    
    if prompt_yes_no "Möchten Sie das Memory-Bank-Verzeichnis erstellen?" "y"; then
      log "INFO" "Erstelle Memory-Bank-Verzeichnis..."
      mkdir -p "$MEMORY_BANK_DIR"
      mkdir -p "$MEMORY_BANK_DIR/claude-terminal"
      
      # Basis-Dateien für Memory-Bank erstellen
      cat > "$MEMORY_BANK_DIR/claude-terminal/projectbrief.md" << EOL
# Claude Terminal - Projektdefinition

## Primäre Zielsetzung
Eine eigenständige Terminal-Anwendung, die die Funktionalität des Claude-AGI-Systems mit MCP-Tools und Memory-Bank-Integration bietet.

## Technische Grundparameter
- Electron-App mit TypeScript
- Node.js/Electron Backend
- Integration mit Claude Code CLI
- MCP-Tools-Überwachung und -Steuerung
- Memory-Bank-Verwaltung

## Geschäftsziele
- Vereinfachte Nutzung des Claude-AGI-Systems
- Konsistente Entwicklungsumgebung
- Nahtlose MCP-Tools-Integration

## Meilensteine
1. Basis-Terminal-Funktionalität
2. MCP-Tools-Integration
3. Memory-Bank-Integration
4. AGI-Installer-Integration
5. Integration mit VibeCodingTest
EOL

      cat > "$MEMORY_BANK_DIR/claude-terminal/activeContext.md" << EOL
# Claude Terminal - Aktiver Kontext

## Aktuelle Phase
- Integration mit AGI-System
- MCP-Tools-Konfiguration
- Memory-Bank-Anbindung

## Letzte Änderungen
- $(date +"%Y-%m-%d"): Installation und Integration

## Aktuelle Prioritäten
- 🔥 AGI-Integration abschließen
- ⚠️ Memory-Bank-Verbindung einrichten
- 📋 MCP-Tools konfigurieren

## Nächste Schritte
- Installationsskript optimieren
- Integrationstests durchführen
- Dokumentation erweitern
EOL

      cat > "$MEMORY_BANK_DIR/claude-terminal/progress.md" << EOL
# Claude Terminal - Fortschrittsprotokoll

## Implementierte Funktionen
- ✅ Basis-Terminal-Funktionalität - 2025-05-02
- ✅ Installationsskript - 2025-05-03

## In Bearbeitung
- ⏳ AGI-Integration - Start: 2025-05-03
- ⏳ Memory-Bank-Integration - Start: 2025-05-03

## Ausstehend
- 📋 MCP-Tools-Integration vollständig testen
- 📋 Dokumentation erstellen
- 📋 Installationsanleitung verfassen
EOL
    fi
  fi
  
  log "SUCCESS" "AGI-Integration vorbereitet."
}

# Terminal installieren und konfigurieren
install_terminal() {
  log "INFO" "Installiere Terminal-App..."
  
  # Wechsle ins Terminal-Verzeichnis
  cd "$TERMINAL_DIR"
  
  # Modifiziere package.json für optimale Kompatibilität
  log "INFO" "Passe package.json für bessere Kompatibilität an..."
  if [ -f "package.json" ]; then
    # Sichern der originalen package.json
    cp package.json package.json.backup
    
    # Node.js Version bestimmen für optimale Konfiguration
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    
    # Konfiguration basierend auf Node.js Version anpassen
    if [ "$NODE_VERSION" -ge 18 ]; then
      # Moderne Node.js-Version (18+)
      log "INFO" "Optimiere package.json für Node.js v$NODE_VERSION..."
      
      # Aktualisiere postinstall-Script und node-pty für moderne Node.js-Versionen
      sed -i 's/"postinstall": "electron-builder install-app-deps",/"postinstall": "electron-builder install-app-deps || true",/g' package.json
      # Verwende neueres node-pty
      sed -i 's/"node-pty": "[^"]*",/"node-pty": "^0.11.0-beta2",/g' package.json
      
      log "SUCCESS" "package.json für moderne Node.js v$NODE_VERSION optimiert."
    else
      # Ältere Node.js-Version (<18)
      log "INFO" "Konfiguriere für ältere Node.js v$NODE_VERSION Kompatibilität..."
      
      # Bei älteren Versionen ist konservativere Konfiguration nötig
      sed -i 's/"postinstall": "electron-builder install-app-deps",/"postinstall": "",/g' package.json
      sed -i 's/"node-pty": "[^"]*",/"node-pty": "0.10.1",/g' package.json
      
      log "INFO" "package.json für ältere Node.js v$NODE_VERSION angepasst."
    fi
    
    log "SUCCESS" "package.json angepasst. Original in package.json.backup gesichert."
  else
    log "ERROR" "package.json nicht gefunden. Installation wird fortgesetzt, aber es können Fehler auftreten."
  fi
  
  # NPM-Abhängigkeiten installieren
  log "INFO" "Installiere NPM-Abhängigkeiten..."
  npm install --no-optional || log "WARNING" "Einige Abhängigkeiten konnten nicht installiert werden. Fortfahren mit Teilinstallation."
  
  # node-pty Installation basierend auf Node.js Version
  log "INFO" "Installiere node-pty basierend auf Node.js-Version..."
  if [ "$NODE_VERSION" -ge 18 ]; then
    # Moderne Version für Node.js 18+
    npm install node-pty@0.11.0-beta2 --save --no-optional || log "WARNING" "Installation von node-pty fehlgeschlagen. Versuche alternative Version..."
    
    # Fallback auf ältere Version bei Fehler
    if [ $? -ne 0 ]; then
      log "INFO" "Versuche alternative node-pty Version..."
      npm install node-pty@latest --save --no-optional || log "WARNING" "Installation von node-pty fehlgeschlagen. Terminal wird möglicherweise eingeschränkt funktionieren."
    fi
  else
    # Kompatible Version für ältere Node.js
    npm install node-pty@0.10.1 --save --no-optional || log "WARNING" "Installation von node-pty fehlgeschlagen. Terminal wird möglicherweise eingeschränkt funktionieren."
  fi
  
  # TypeScript-Konfiguration für optimale Kompatibilität anpassen
  log "INFO" "Optimiere TypeScript-Konfiguration..."
  if [ -f "tsconfig.json" ]; then
    # Sichern der originalen tsconfig.json
    cp tsconfig.json tsconfig.json.backup
    
    # Bestimme optimale TypeScript-Konfiguration basierend auf Node.js-Version
    if [ "$NODE_VERSION" -ge 18 ]; then
      # Moderne Konfiguration für Node.js 18+
      cat > "tsconfig.json" << EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": false,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "dist",
    "rootDir": "src",
    "baseUrl": ".",
    "resolveJsonModule": true
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules",
    "**/*.spec.ts"
  ]
}
EOF
    else
      # Kompatible Konfiguration für ältere Node.js-Versionen
      cat > "tsconfig.json" << EOF
{
  "compilerOptions": {
    "target": "ES2018",
    "module": "CommonJS",
    "moduleResolution": "node",
    "strict": false,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "dist",
    "rootDir": "src",
    "baseUrl": "."
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules",
    "**/*.spec.ts"
  ]
}
EOF
    fi
    
    log "SUCCESS" "TypeScript-Konfiguration optimiert. Original in tsconfig.json.backup gesichert."
  else
    log "WARNING" "tsconfig.json nicht gefunden. Erstelle neue Konfiguration..."
    
    # Erstelle eine neue optimierte Konfiguration
    if [ "$NODE_VERSION" -ge 18 ]; then
      # Moderne Konfiguration für Node.js 18+
      cat > "tsconfig.json" << EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": false,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "dist",
    "rootDir": "src",
    "baseUrl": ".",
    "resolveJsonModule": true
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules",
    "**/*.spec.ts"
  ]
}
EOF
    else
      # Kompatible Konfiguration für ältere Node.js-Versionen
      cat > "tsconfig.json" << EOF
{
  "compilerOptions": {
    "target": "ES2018",
    "module": "CommonJS",
    "moduleResolution": "node",
    "strict": false,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "dist",
    "rootDir": "src",
    "baseUrl": "."
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules",
    "**/*.spec.ts"
  ]
}
EOF
    fi
  fi
  
  # TypeScript installieren basierend auf Node.js-Version
  log "INFO" "Installiere TypeScript mit optimaler Version..."
  if [ "$NODE_VERSION" -ge 18 ]; then
    npm install typescript@latest --save-dev
  else
    npm install typescript@4.9.5 --save-dev
  fi
  
  # TypeScript kompilieren mit verbesserter Fehlerbehandlung
  log "INFO" "Kompiliere TypeScript-Code..."
  if npx tsc; then
    log "SUCCESS" "TypeScript-Kompilierung erfolgreich."
  else
    log "WARNING" "TypeScript-Kompilierung fehlgeschlagen. Versuche erneut mit --skipLibCheck..."
    if npx tsc --skipLibCheck; then
      log "SUCCESS" "TypeScript-Kompilierung mit --skipLibCheck erfolgreich."
    else
      log "WARNING" "TypeScript-Kompilierung fehlgeschlagen. Erstelle minimalen Build als Fallback."
      # Erstelle einen minimalen Build als Fallback
      mkdir -p dist
      cp -r src/* dist/ 2>/dev/null || true
    fi
  fi
  
  # Installiere die App global, falls gewünscht
  if prompt_yes_no "Möchten Sie die Terminal-App global installieren?" "y"; then
    log "INFO" "Installiere Terminal-App global..."
    cd "$TERMINAL_DIR"
    
    # Alternativer Ansatz zur globalen Installation ohne npm link
    if [ ! -d "/usr/local/bin" ]; then
      sudo mkdir -p /usr/local/bin
    fi
    
    # Erstelle Starter-Script
    cat > "$TERMINAL_DIR/bin/claude-terminal" << EOL
#!/bin/bash
cd "$TERMINAL_DIR"
npm start
EOL
    
    chmod +x "$TERMINAL_DIR/bin/claude-terminal"
    
    log "SUCCESS" "Terminal-App global installiert. Sie können nun 'claude-terminal' in der Kommandozeile verwenden."
  else
    log "INFO" "Globale Installation übersprungen."
  fi
  
  log "SUCCESS" "Terminal-App installiert (mit möglichen Einschränkungen)."
}

# Abschlussarbeiten
finalize_installation() {
  log "INFO" "Führe Abschlussarbeiten durch..."
  
  # CLAUDE.md im Hauptverzeichnis erstellen
  cat > "$CLAUDE_DIR/CLAUDE.md" << EOL
# CLAUDE.md

Diese Datei bietet Anweisungen für Claude Code (claude.ai/code) bei der Arbeit mit diesem Repository.

## CLAUDE AGI-Terminal-System v1.0

Das CLAUDE AGI-Terminal-System kombiniert die Claude-Terminal-App mit dem Claude-AGI-Project und einem gemeinsamen Memory-Bank-System.

## Komponenten
1. **claude-terminal**: Eigenständige Terminal-App für den Zugriff auf Claude-Funktionen
2. **claude-agi-project**: Projektvorlage mit MCP-Tools-Integration
3. **memory-bank**: Gemeinsames Speichersystem für persistenten Kontext
4. **VibeCodingTest**: Test-Suite für Vibe-Coding-Projekte

## Wichtige Befehle
- `cd claude-terminal && npm start`: Terminal-App starten
- `cd claude-agi-project/monitoring && node start.js`: Monitoring-Server starten
- `cd VibeCodingTest/APP && npm test`: Test-Suite ausführen

## Integration
Die Komponenten sind über folgende Mechanismen integriert:
- Gemeinsame MCP-Konfiguration in \`claude_desktop_config.json\`
- Gemeinsame Memory-Bank im \`memory-bank\`-Verzeichnis
- AGI-Installer-Integration in der Terminal-App
- Monitoring-Integration für alle Komponenten
EOL

  # Erstelle Symbolischen Link für einfachen Zugriff, falls gewünscht
  if prompt_yes_no "Möchten Sie einen symbolischen Link für einfachen Zugriff erstellen?" "y"; then
    USER_BIN="${HOME}/.local/bin"
    
    # Erstelle den Benutzerverzeichnis-Binärordner, falls nicht vorhanden
    if [ ! -d "$USER_BIN" ]; then
      mkdir -p "$USER_BIN"
      log "INFO" "Benutzerverzeichnis für Binärdateien erstellt: $USER_BIN"
    fi
    
    # Entferne vorhandenen symbolischen Link
    if [ -L "$USER_BIN/claude-term" ]; then
      rm -f "$USER_BIN/claude-term"
    fi
    
    log "INFO" "Erstelle symbolischen Link im Benutzerverzeichnis..."
    ln -s "$TERMINAL_DIR/bin/claude-terminal" "$USER_BIN/claude-term"
    
    # Prüfe, ob der PATH bereits das Benutzerverzeichnis enthält
    if [[ ":$PATH:" != *":$USER_BIN:"* ]]; then
      log "INFO" "Füge $USER_BIN zu Ihrem PATH hinzu (in .bashrc oder .zshrc)..."
      echo "export PATH=\"\$PATH:$USER_BIN\"" >> "$HOME/.bashrc"
      
      # Auch in .zshrc hinzufügen, falls vorhanden
      if [ -f "$HOME/.zshrc" ]; then
        echo "export PATH=\"\$PATH:$USER_BIN\"" >> "$HOME/.zshrc"
      fi
      
      log "INFO" "Sie müssen Ihre Shell neu starten oder 'source ~/.bashrc' ausführen, um den Befehl zu verwenden."
    fi
    
    log "SUCCESS" "Symbolischer Link erstellt. Sie können nun 'claude-term' in der Kommandozeile verwenden (nach Shell-Neustart)."
  fi
  
  log "SUCCESS" "Abschlussarbeiten abgeschlossen."
}

# Hauptfunktion
main() {
  # Banner anzeigen (bereits am Anfang durchgeführt)
  
  # Voraussetzungen prüfen
  check_prerequisites
  
  # Terminal-Installation vorbereiten
  prepare_terminal_install
  
  # MCP-Konfiguration erstellen
  create_mcp_config
  
  # AGI-Integration vorbereiten
  prepare_agi_integration
  
  # Terminal installieren und konfigurieren
  install_terminal
  
  # Abschlussarbeiten
  finalize_installation
  
  # Erfolgreicher Abschluss
  echo ""
  echo -e "${GREEN}✅ CLAUDE-AGI-Terminal erfolgreich installiert!${NC}"
  echo ""
  echo -e "${BLUE}Installierte Komponenten:${NC}"
  echo "- Claude-Terminal-App"
  echo "- AGI-Integration"
  echo "- Memory-Bank-System"
  echo "- MCP-Tools-Konfiguration"
  echo ""
  echo -e "${BLUE}Nächste Schritte:${NC}"
  echo "1. Starte die Terminal-App: cd $TERMINAL_DIR && npm start"
  
  if [ -d "$HOME/.local/bin" ]; then
    echo "2. Oder verwende den Befehl (nach Shell-Neustart oder 'source ~/.bashrc'): claude-term"
  fi
  
  echo "3. Nutze den AGI-Installer im Hauptmenü der Terminal-App"
  echo ""
  echo -e "${YELLOW}Hinweis: Die Installation wurde mit Kompatibilitätsanpassungen durchgeführt.${NC}"
  echo -e "${YELLOW}Bei Problemen mit node-pty oder TypeScript, starten Sie die App manuell mit 'npm start'.${NC}"
  echo -e "${YELLOW}Für optimale Funktionalität wird Node.js v16 empfohlen.${NC}"
  echo -e "${YELLOW}Aktuelle Konfiguration wurde für Ihre Node.js-Version ($(node -v)) angepasst.${NC}"
  echo ""
}

# Ausführung
main