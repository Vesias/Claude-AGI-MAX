# CLAUDE-AGI: Standardisierte Entwicklungsumgebung für KI-Projekte

*Version 1.1 • 2025-05-03*

> **⚠️ WICHTIG: Benötigt Claude Pro MAX Abonnement**
> 
> Dieses Framework erfordert ein aktives Claude Pro MAX Abonnement für die volle Funktionalität.

## 🌟 Überblick

CLAUDE-AGI ist ein standardisiertes Framework für KI-gestützte Entwicklung mit einer sicheren, skalierbaren Projektstruktur:

- **Standardisierte Projektstruktur**: Automatische Arbeitsumgebung in `claude-agi-projects/`
- **Memory-Bank-System**: Projektbasierte Wissensverwaltung
- **MCP-Tools-Integration**: Erweiterte Funktionalität ohne Smithery
- **Datensicherheit**: Automatischer Ausschluss privater Projekte
- **Skalierbare Architektur**: Vorbereitet für Enterprise-Nutzung

## 📁 Standardisierte Projektstruktur

```
/CLAUDE/
├── claude-terminal/                # Terminal-Anwendung
├── claude-agi-projects/           # Standardisiertes Projekt-Workspace
│   ├── .project-config.json       # Globale Projektkonfiguration
│   ├── default-project/           # Standard-Arbeitsverzeichnis
│   │   └── memory-bank/           # Projekt-Memory-Bank
│   └── [weitere-projekte]/        # Projektbasierte Organisation
├── memory-bank/                   # Globale Templates
│   └── templates/                 # Standard-Memory-Bank-Strukturen
├── .claude-agi/                   # Service-Komponenten
│   └── services/                  # ProxyClaude und andere Services
├── .config/                       # MCP-Konfiguration
└── .gitignore                     # Sichere Git-Konfiguration
```

## 🚀 Schnellstart

### 1. Installation

```bash
# Terminal installieren und Standardstruktur einrichten
bash install-claude-agi-terminal.sh
```

### 2. Arbeiten mit der Standardstruktur

Die Terminal-Anwendung arbeitet automatisch in `claude-agi-projects/default-project/`:

```bash
# Terminal starten - arbeitet automatisch im Standard-Projekt
cd claude-terminal && npm start
```

### 3. Neue Projekte erstellen

```bash
# Neues AGI-Projekt erstellen
mkdir -p claude-agi-projects/mein-neues-projekt
cp -r memory-bank/templates/* claude-agi-projects/mein-neues-projekt/memory-bank/
```

## 🔐 Sicherheitsfunktionen

### Automatischer Ausschluss privater Projekte

CLAUDE-AGI schützt automatisch sensible Projektdaten:

```json
{
  "excludedPatterns": [
    "**/goldankauf/**",
    "**/aclearallb.gg/**", 
    "**/sj-bandolerosz/**",
    "**/deepsleeping/**",
    "**/node_modules/**",
    "**/.env*"
  ]
}
```

### Git-Sicherheit

Die `.gitignore` verwendet das "Opt-in" statt "Opt-out" Prinzip:
- Standardmäßig wird ALLES ignoriert
- Nur explizit erlaubte Strukturen werden eingecheckt
- Private Projekte werden niemals versehentlich committed

## 🛠️ MCP-Tools ohne Smithery

CLAUDE-AGI verwendet direkte NPM-Package-Referenzen statt Smithery:

```json
{
  "mcpServers": {
    "desktop-commander": {
      "command": "npx",
      "args": ["-y", "@wonderwhy-er/desktop-commander"],
      "env": {
        "WORKSPACE_PATH": "/path/to/claude-agi-projects"
      }
    }
  }
}
```

Verfügbare Tools:
- **Filesystem**: `@modelcontextprotocol/server-filesystem`
- **Code**: `@block/code-mcp`
- **Memory**: `@alioshr/memory-bank-mcp`
- **Browser**: `@agentdeskai/browser-tools-mcp`
- **Desktop**: `@wonderwhy-er/desktop-commander`

## 💫 Memory-Bank-System

Jedes Projekt enthält eine vollständige Memory-Bank:

| Datei | Zweck |
|-------|--------|
| `projectbrief.md` | Projektdefinition und Ziele |
| `activeContext.md` | Aktueller Arbeitsfokus |
| `systemPatterns.md` | Architektur und Design |
| `techContext.md` | Technologie-Stack |
| `progress.md` | Fortschrittsverfolgung |

### Memory-Bank aktualisieren

```bash
# Kontext für aktuelles Projekt aktualisieren
cd claude-agi-projects/default-project
claude.ai update-memory .
```

## 🎯 Workflow-Integration

### Terminal-Workflow

1. Terminal startet automatisch in `default-project/`
2. Memory-Bank wird automatisch geladen
3. MCP-Tools stehen sofort zur Verfügung
4. Sichere Speicherung aller Änderungen

### Git-Workflow

```bash
# Sichere Commits - nur erlaubte Strukturen
git add .
git commit -m "feat: Update standardized project structure"
git push
```

## 🔄 Skalierung und Enterprise-Nutzung

Die standardisierte Struktur ermöglicht:
- **Team-Kollaboration**: Konsistente Umgebung für alle
- **Projekt-Isolation**: Klare Trennung zwischen Projekten
- **Automatisierte Workflows**: CI/CD-Integration
- **Enterprise-Sicherheit**: Datenschutz und Compliance

## 📚 Dokumentation

- [Architektur-Übersicht](./docs/ARCHITECTURE.md)
- [Terminal-Guide](./docs/TERMINAL_GUIDE.md)
- [MCP-Tools-Referenz](./docs/mcp-tools-reference.md)
- [ProxyClaude-Service](./docs/proxyclaude-guide.md)

## 📝 Lizenz

MIT License - siehe [LICENSE](LICENSE) für Details.

## 🚦 Status

- ✅ Standardisierte Projektstruktur
- ✅ Sichere Git-Integration
- ✅ MCP-Tools ohne Smithery
- ✅ Memory-Bank-System
- 🚧 Enterprise-Features in Entwicklung