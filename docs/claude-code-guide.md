# Claude Code und Claude Desktop AGI - Anleitung

*Version 1.0 • 2025-05-02*

Dieses Dokument bietet einen umfassenden Leitfaden zur Nutzung von Claude Code (CLI) und Claude Desktop (GUI) mit dem AGI-Framework.

## Inhaltsverzeichnis

1. [Überblick](#überblick)
2. [Erste Schritte](#erste-schritte)
3. [Claude Code](#claude-code)
4. [Claude Desktop](#claude-desktop)
5. [MCP-Integration](#mcp-integration)
6. [Memory-Bank](#memory-bank)
7. [Troubleshooting](#troubleshooting)

## Überblick

Claude Code ist ein CLI-basiertes Entwickler-Tool, das direkten Zugriff auf die Claude-API ermöglicht. Claude Desktop bietet eine grafische Benutzeroberfläche für die Interaktion mit Claude und unterstützt zusätzlich die Integration externer Tools über das Model Context Protocol (MCP).

Beide Anwendungen sind zentrale Komponenten des CLAUDE-AGI-Frameworks und arbeiten nahtlos mit dem Memory-Bank-System zusammen, um Kontinuität zwischen Sitzungen zu gewährleisten.

## Erste Schritte

### Voraussetzungen

- **Claude Pro MAX** Abonnement
- Node.js v20 oder höher
- Git
- GitHub CLI (optional, für GitHub-Integration)

### Installation

1. **Claude Code**: 
   ```bash
   npm install -g @anthropic/claude-code
   ```

2. **Claude Desktop**:
   - Lade die neueste Version von [claude.ai/desktop](https://claude.ai/desktop) herunter
   - Installiere die Anwendung
   - Importiere die MCP-Konfiguration aus `~/.config/claude-desktop/claude_desktop_config.json`

## Claude Code

Claude Code ist ein leistungsstarkes CLI-Tool für Entwickler:

### Hauptfunktionen

- **Code-Navigation**: Durchsuche und verstehe große Codebasen
- **Pair-Programming**: Löse Probleme, schreibe Tests, behebe Bugs
- **Refactoring**: Verbessere Codequalität und -struktur
- **Tool-Integration**: Nutze Tools wie `ls`, `grep`, `glob` direkt in der Konversation

### Häufig verwendete Kommandos

```bash
# Starten mit einem neuen Projekt
claude-code /pfad/zum/projekt

# Befehle in der Sitzung
/help           # Zeigt verfügbare Befehle an
/tools          # Listet verfügbare Tools auf
/clear          # Löscht die aktuelle Konversation
/save filename  # Speichert die Konversation
/load filename  # Lädt eine gespeicherte Konversation
```

### Best Practices

- Stelle präzise Fragen zum Code
- Gib klaren Kontext, wenn du nach Hilfe fragst
- Nutze `/thinking` für komplexe Probleme
- Verwende regelmäßig `/update_memory` zur Aktualisierung des Memory-Bank-Systems

## Claude Desktop

Claude Desktop bietet eine benutzerfreundliche grafische Oberfläche:

### Hauptfunktionen

- **Chat-Interface**: Natürliche Konversation mit Claude
- **MCP-Integration**: Verbindung zu externen Tools und Datenquellen
- **Kontextuelles Gedächtnis**: Beibehaltung des Kontexts über Sitzungen hinweg
- **System-Prompts**: Definiere spezifische Rollen und Anweisungen für Claude

### Konfiguration

1. **MCP-Server einrichten**:
   - Gehe zu Einstellungen → MCP
   - Importiere Konfiguration aus `claude_desktop_config.json`
   - Aktiviere oder deaktiviere gewünschte MCP-Server

2. **System-Prompt anpassen**:
   - Gehe zu Einstellungen → System-Prompt
   - Verwende unsere Vorlage oder erstelle einen eigenen System-Prompt
   - Empfohlener Basis-Prompt:
     ```
     Du bist Claude-AGI, ein KI-Assistent mit Fokus auf Softwareentwicklung und
     Projektmanagement. Du unterstützt beim Vibe-Coding-Stack und nutzt MCP-Tools.
     Du liest zu Beginn jeder Sitzung die Memory-Bank, um Kontinuität zu gewährleisten.
     ```

## MCP-Integration

MCP (Model Context Protocol) ermöglicht Claude den Zugriff auf externe Tools:

### Verfügbare MCP-Server

| Kategorie | Tools | Beschreibung |
|-----------|-------|--------------|
| Dateisystem | desktop-commander | Shell-Befehle, Datei-Operationen |
| Code | code-mcp | Code-Generierung, Refactoring |
| Denken | sequentialthinking | Strukturierte Problemlösung |
| Web | brave-search | Websuche und -analyse |
| Memory | memory-bank, context7-mcp | Persistentes Gedächtnis |
| UI | magic-mcp | UI-Generierung und -Design |

### Nutzung in Claude Desktop

1. Aktiviere die gewünschten MCP-Server in den Einstellungen
2. Erteile notwendige Berechtigungen, wenn angefordert
3. Verwende natürliche Sprache, um Claude zur Nutzung der Tools anzuweisen
4. Prüfe die Ausgabe der Tools in der Konversation

## Memory-Bank

Das Memory-Bank-System ermöglicht Kontinuität zwischen Sitzungen:

### Hauptkomponenten

- **projectbrief.md**: Grundlegende Projektdefinition
- **productContext.md**: Zweck und Problemlösung
- **activeContext.md**: Aktueller Fokus und nächste Schritte
- **systemPatterns.md**: Systemarchitektur und Design-Patterns
- **techContext.md**: Verwendete Technologien
- **progress.md**: Aktueller Status und Fortschritt

### Memory-Bank-Verwaltung

```bash
# Neues Projekt erstellen
memory-bank init ProjektName

# Memory-Bank aktualisieren
memory-bank update ~/Schreibtisch/CLAUDE/ProjektName

# Backup erstellen
memory-bank backup ~/Schreibtisch/CLAUDE/ProjektName
```

## Troubleshooting

### Häufige Probleme

1. **MCP-Server startet nicht**
   - Prüfe, ob der MCP-Key korrekt ist
   - Stelle sicher, dass Node.js v20+ installiert ist
   - Überprüfe die Serverprotokolle in `~/.claude/logs/`

2. **Memory-Bank wird nicht erkannt**
   - Prüfe den Pfad zur Memory-Bank
   - Stelle sicher, dass die Verzeichnisstruktur korrekt ist
   - Führe `memory-bank update` aus, um die Memory-Bank zu aktualisieren

3. **Claude versteht Kontext nicht**
   - Verwende `/update_memory` in Claude Code
   - Aktualisiere den System-Prompt in Claude Desktop
   - Stelle sicher, dass die Memory-Bank-Dateien aktuell sind

### Support

Bei weiteren Problemen:
- Besuche unser [GitHub Repository](https://github.com/YourUsername/claude-agi)
- Tritt unserem Discord-Server bei
- Kontaktiere uns unter support@example.com