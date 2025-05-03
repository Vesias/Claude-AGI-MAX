# Standardisierungszusammenfassung: CLAUDE-AGI-System v1.2

Diese Dokumentation beschreibt die Standardisierung des CLAUDE-AGI-Systems in Version 1.2.

## 1. Projektstruktur

Das CLAUDE-AGI-System verwendet eine standardisierte Projektstruktur:

```
CLAUDE/
├── claude-terminal/          # Terminal-Anwendung
├── claude-agi-projects/      # Hauptprojektverzeichnis
│   ├── .project-config.json  # Projektkonfiguration
│   └── default-project/      # Standardprojekt
│       └── memory-bank/      # Projektspezifische Memory-Bank
├── memory-bank/              # Globale Memory-Bank-Templates
│   ├── templates/            # Standarddateien
│   └── README.md             # Memory-Bank-Dokumentation
├── .claude-agi/              # Service-Komponenten
│   └── services/
│       └── proxyclaude/      # Claude API Proxy Service
├── .config/                  # MCP-Konfiguration
│   └── claude_desktop_config.json
└── docs/                     # Dokumentation
    ├── proxyclaude-guide.md  # ProxyClaude-Dokumentation
    └── STANDARDIZATION_SUMMARY.md  # Diese Datei
```

## 2. Memory-Bank-System

Das Memory-Bank-System dient zur strukturierten Speicherung von Projektkontext:

- **Globale Templates**: Standardisierte Dateien im Verzeichnis `memory-bank/templates/`
- **Projektspezifisch**: Jedes Projekt hat eine eigene Memory-Bank in `claude-agi-projects/[projektname]/memory-bank/`
- **Standarddateien**:
  - `projectbrief.md`: Projektzusammenfassung und -ziele
  - `activeContext.md`: Aktueller Arbeitsfokus
  - `techContext.md`: Technischer Stack und Konfiguration
  - `systemPatterns.md`: Architektur und Design-Patterns
  - `progress.md`: Fortschritt und Aufgabenverwaltung

## 3. ProxyClaude Service

Der ProxyClaude Service dient als zentraler API-Proxy für Claude:

- **Standardisierte Konfiguration**: JWT-Authentifizierung, Nutzerbasierte Ratenbegrenzung
- **Umgebungsvariablen**: Alle sensiblen Daten in `.env`-Dateien (nicht im Git)
- **Verzeichnisstruktur**: Standardisierte Express.js-Struktur mit TypeScript
- **MCP-Integration**: Automatische Integration in MCP-Tools-Ökosystem

## 4. MCP-Tools

Die MCP-Tools-Konfiguration ist standardisiert:

- **Konfigurationsdatei**: `.config/claude_desktop_config.json`
- **Standard-Tools**:
  - memory-bank-mcp: Persistente Kontext-Verwaltung
  - filesystem: Dateisystemzugriff
  - proxyclaude: Claude API Proxy
  - browser-tools: Web-Recherche
  - desktop-commander: Dateisystem-/Shell-Operationen
  - code-mcp: Code-Generierung/-Analyse
  - sequentialthinking: Strukturierte Problemlösung
  - context7-mcp: Semantische Kontext-Verwaltung
  - brave-search: Web-Suche
  - marketing-tools: Marketing-Werkzeuge

## 5. Git-Sicherheitsstandards

Standardisierte Git-Sicherheitsmaßnahmen:

- **Opt-in .gitignore**: Standardmäßig alles ignorieren außer explizit erlaubten Dateien
- **Expliziter Ausschluss sensibler Projekte**: Automatische Blockierung von sensiblen Projekten
- **ENV-Dateien**: Standardmäßig ausgeschlossen
- **Pre-Commit-Hook**: Sicherheitsprüfung vor jedem Commit
- **Keine API-Schlüssel im Git**: Strikte Trennung von Code und Zugangsdaten

## 6. Terminal-Integration

Die Claude-Terminal-Integration wurde standardisiert:

- **Konfiguration**: Automatische Nutzung der standardisierten Projektstruktur
- **Node.js-Kompatibilität**: Unterstützung für moderne Node.js-Versionen (v18+)
- **Entwicklungswerkzeuge**: Standard-npm-Skripte für Entwicklung, Build und Start

## Installationsprozess

Der standardisierte Installationsprozess umfasst:

1. **Systemvoraussetzungsprüfung**: Node.js, npm, Git, Systemressourcen
2. **Sichere Datenmigration**: Automatische Sicherung sensibler Projekte
3. **Verzeichnisstruktur**: Erstellung der standardisierten Projektstruktur
4. **Memory-Bank-Setup**: Erstellung aller Template-Dateien
5. **MCP-Konfiguration**: Konfiguration aller MCP-Tools
6. **Terminal-Installation**: Kompatibilitäts-Patches für moderne Node.js-Versionen
7. **ProxyClaude-Setup**: Einrichtung des API-Proxy-Services
8. **Dokumentation**: Erstellung von README.md und CLAUDE.md

## Wartung und Updates

Die Standardisierung unterstützt einfache Updates:

- **Modulare Struktur**: Separate Komponenten können unabhängig aktualisiert werden
- **Konfigurationsdateien**: Zentrale Konfiguration für einfache Anpassungen
- **Dokumentation**: Umfassende Dokumentation aller Komponenten
- **Sicherheitshinweise**: Klare Richtlinien zur Wartung der Sicherheit