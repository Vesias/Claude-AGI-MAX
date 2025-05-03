# Memory Bank - Claude-AGI Persistence System

Die Memory Bank ist ein strukturiertes Dateisystem für die Speicherung von Projekt-Kontext und Wissen in Claude-AGI-Projekten. Sie ermöglicht die Kontinuität zwischen Sitzungen und dient als zentrale Wissensquelle für alle Claude-AGI-Anwendungen.

## Struktur

Jedes Projekt enthält einen `memory-bank`-Ordner mit den folgenden Kerndateien:

| Datei | Beschreibung |
|-------|-------------|
| `projectbrief.md` | Grundlegende Projektdefinition, Ziele und Umfang |
| `productContext.md` | Zweck und Problemlösung des Projekts |
| `activeContext.md` | Aktueller Arbeitsfokus und Prioritäten |
| `systemPatterns.md` | Systemarchitektur und Design-Patterns |
| `techContext.md` | Verwendete Technologien und technische Entscheidungen |
| `progress.md` | Aktueller Status und Fortschrittsprotokoll |
| `sequentialThinking.config` | Konfiguration für strukturiertes Reasoning |
| `knowledgeGraph.json` | (Optional) Semantisches Netzwerk von Projektkonzepten |

## Verwendung

### Neue Memory Bank erstellen

```bash
# Erstellt eine neue Memory Bank mit Standarddateien
mkdir -p project-name/memory-bank
cp -r /home/jan/Schreibtisch/CLAUDE/memory-bank/templates/* project-name/memory-bank/
```

### Memory Bank aktualisieren

```bash
# Kontext aktualisieren
claude-agi update-memory /pfad/zum/projekt
```

## Memory Bank im Claude-AGI-Ökosystem

Die Memory Bank ist eng mit allen Komponenten des Claude-AGI-Ökosystems integriert:

- **Claude Terminal**: Visualisierung und Bearbeitung der Memory Bank
- **Claude Desktop**: Direkter Zugriff über Memory Bank MCP-Tool
- **ProxyClaude**: Gemeinsamer Zugriff für Teams
- **Vibe-Coding-Projekte**: Automatische Integration in neue Projekte

## Erweiterte Funktionen

- **Sequential Thinking**: Strukturiertes Reasoning mit Gedächtnispersistenz
- **Knowledge Graph**: Semantisches Netzwerk von Projektkonzepten
- **Kontext-Synchronisierung**: Automatische Aktualisierung bei Git-Commits

## Best Practices

1. Halte `activeContext.md` aktuell, um den Fokus zu bewahren
2. Dokumentiere wichtige Entscheidungen in `systemPatterns.md`
3. Protokolliere Fortschritte regelmäßig in `progress.md`
4. Verwende Tags in Markdown-Dateien zur besseren Kategorisierung
5. Strukturiere Informationen klar und konsistent
6. Vermeide Duplikation von Informationen
7. Füge komplexe Visualisierungen als Mermaid-Diagramme hinzu

## Integration mit MCP-Tools

Die Memory Bank kann über das `memory-bank-mcp`-Tool direkt in Claude Desktop integriert werden:

```json
{
  "mcpServers": {
    "memory-bank": {
      "command": "npx",
      "args": ["-y", "@alioshr/memory-bank-mcp"],
      "env": {
        "MEMORY_BANK_ROOT": "/home/jan/.claude-agi/memory-bank"
      }
    }
  }
}
```

## Beispiele

Ein gut gepflegtes Memory Bank-System ermöglicht Claude, komplexe Projekte besser zu verstehen und zielgerichtete Unterstützung zu bieten. Siehe die vorhandenen Projekte für Beispiele:

- `/claude-terminal/memory-bank/` - Terminal-Anwendung
- `/claude-agi-project/memory-bank/` - Hauptprojekt
- `/VibeCodingTest/memory-bank/` - Beispiel für Vibe-Coding-Projekt