# MCP-Tools Referenz

*Version 1.0 • 2025-05-02*

Diese Referenz dokumentiert alle verfügbaren MCP-Tools (Model Context Protocol) für die Integration mit Claude.

## Inhaltsverzeichnis

1. [Überblick](#überblick)
2. [Core-Tools](#core-tools)
3. [Web-Tools](#web-tools)
4. [Entwicklungs-Tools](#entwicklungs-tools)
5. [Speicher & Vektordatenbanken](#speicher--vektordatenbanken)
6. [Kommunikation & Messaging](#kommunikation--messaging)
7. [Multimedia & Dokumente](#multimedia--dokumente)
8. [Agent-to-Agent (A2A) Protokoll](#agent-to-agent-a2a-protokoll)
9. [Eigene MCP-Server entwickeln](#eigene-mcp-server-entwickeln)

## Überblick

MCP (Model Context Protocol) ist ein offener Standard, der es Claude ermöglicht, mit externen Tools und Datenquellen zu interagieren. Die Tools werden als separate Server bereitgestellt, die über eine standardisierte Schnittstelle mit Claude kommunizieren.

### MCP vs. Smithery

CLAUDE-AGI verwendet native MCP-Server anstelle des Smithery-Frameworks aus folgenden Gründen:
- Direkte Integration ohne Vermittlungsschicht
- Geringere Latenz und Overhead
- Bessere Sicherheit durch geringere Angriffsfläche
- Vollständige Kontrolle über den Tool-Lebenszyklus

## Core-Tools

### Desktop Commander

```json
{
  "command": "npx",
  "args": ["-y", "@wonderwhy-er/desktop-commander", "--key", "${MCP_KEY}"]
}
```

Desktop Commander ermöglicht Claude den Zugriff auf das Dateisystem und die Ausführung von Shell-Befehlen:

- **Funktionen**: Dateien lesen/schreiben, Verzeichnisse durchsuchen, Befehle ausführen
- **Sicherheit**: Sandboxed, begrenzte Berechtigungen, nur im aktuellen Arbeitsverzeichnis
- **Anwendungsfälle**: Dateiverwaltung, Build-Prozesse, Git-Operationen

### Sequential Thinking

```json
{
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
}
```

Sequential Thinking verbessert die Problemlösungsfähigkeiten von Claude durch strukturiertes Denken:

- **Funktionen**: Step-by-Step-Reasoning, Multi-Strategie-Denken, Gedankenverfolgung
- **Konfiguration**: Verschiedene Denkmodi (linear, tree, divergent)
- **Anwendungsfälle**: Komplexe Probleme, Kreatives Denken, Debugging

### Code-MCP

```json
{
  "command": "npx",
  "args": ["-y", "@block/code-mcp", "--key", "${MCP_KEY}"]
}
```

Code-MCP unterstützt Claude bei Code-bezogenen Aufgaben:

- **Funktionen**: Code-Verstehen, -Generierung, -Refactoring
- **Unterstützte Sprachen**: JavaScript/TypeScript, Python, Rust, Go, Java, C++
- **Anwendungsfälle**: Code-Reviews, Bugfixing, Komponentenerstellung

## Web-Tools

### Brave Search

```json
{
  "command": "npx",
  "args": ["-y", "@searchweb/brave-mcp", "--key", "${MCP_KEY}", "--profile", "${BRAVE_PROFILE}"]
}
```

Brave Search ermöglicht Claude den Zugriff auf aktuelle Informationen aus dem Web:

- **Funktionen**: Web-Suche, Informationsbeschaffung, Quellenangaben
- **Konfiguration**: Profil, Region, Suchmodus
- **Anwendungsfälle**: Recherche, Fragen zu aktuellen Ereignissen, Faktenüberprüfung

### Browserbase

```json
{
  "command": "npx",
  "args": ["-y", "browserbase/mcp-server-browserbase"],
  "env": { "BROWSERBASE_API_KEY": "${BROWSERBASE_API_KEY}" }
}
```

Browserbase bietet fortschrittliche Web-Automatisierung und -Interaktion:

- **Funktionen**: Headless-Browser, Web-Scraping, Form-Interaktion
- **Konfiguration**: Cookie-Management, Proxy-Unterstützung
- **Anwendungsfälle**: Datenerfassung, Tests, UI-Automation

## Entwicklungs-Tools

### GitHub

```json
{
  "command": "npx",
  "args": ["-y", "github-mcp-server"],
  "env": { "GITHUB_TOKEN": "${GH_TOKEN}" }
}
```

GitHub ermöglicht Claude die Interaktion mit GitHub-Repositories:

- **Funktionen**: Issues, PRs, Releases, Code-Navigation
- **Sicherheit**: Token-basierte Authentifizierung, begrenzte Scope-Berechtigungen
- **Anwendungsfälle**: Code-Reviews, Issue-Management, Release-Planung

### Git

```json
{
  "command": "npx",
  "args": ["-y", "git-mcp-server"]
}
```

Git ermöglicht Claude die Arbeit mit lokalen Git-Repositories:

- **Funktionen**: Commits, Branches, Merge, Status
- **Sicherheit**: Nur lokale Operationen, kein automatisches Pushing
- **Anwendungsfälle**: Versionskontrolle, Feature-Branches, History-Analyse

## Speicher & Vektordatenbanken

### Memory Bank

```json
{
  "command": "npx",
  "args": ["-y", "@alioshr/memory-bank-mcp", "--key", "${MCP_KEY}"]
}
```

Memory Bank ermöglicht persistentes Gedächtnis über Sitzungen hinweg:

- **Funktionen**: Lesen/Schreiben von Gedächtnis, Strukturierte Speicherung
- **Dateiformat**: Markdown, JSON
- **Anwendungsfälle**: Projektkontinuität, Wissensmanagement, Langzeitkontext

### Context7

```json
{
  "command": "npx",
  "args": ["-y", "@upstash/context7-mcp", "--key", "${MCP_KEY}"]
}
```

Context7 ist eine hochperformante Vektordatenbank für semantische Suche:

- **Funktionen**: Embedding-Speicherung, Semantische Suche, Chunk-Management
- **Performance**: Niedrige Latenz, hoher Durchsatz
- **Anwendungsfälle**: Dokumentensuche, Ähnlichkeitsanalyse, Wissensextraktion

### Qdrant

```json
{
  "command": "npx",
  "args": ["-y", "qdrant/mcp-server-qdrant"],
  "env": { "QDRANT_URL": "${QDRANT_URL}", "QDRANT_API_KEY": "${QDRANT_API_KEY}" }
}
```

Qdrant ist eine leistungsstarke Vektordatenbank:

- **Funktionen**: Vektorsuche, Filtern, Clustering
- **Skalierung**: Cluster-Unterstützung, Sharding
- **Anwendungsfälle**: Semantische Suche, Empfehlungen, Bild/Text-Retrieval

## Kommunikation & Messaging

### Twilio

```json
{
  "command": "npx",
  "args": ["-y", "twilio-alpha-mcp"],
  "env": {
    "TWILIO_ACCOUNT_SID": "${TWILIO_SID}",
    "TWILIO_AUTH_TOKEN": "${TWILIO_TOKEN}"
  }
}
```

Twilio ermöglicht Claude das Senden und Empfangen von Nachrichten:

- **Funktionen**: SMS, WhatsApp, Sprachanrufe
- **Konfiguration**: Token-basierte Authentifizierung
- **Anwendungsfälle**: Benachrichtigungen, Kundenkommunikation, Zwei-Faktor-Authentifizierung

## Multimedia & Dokumente

### Imagen Generate

```json
{
  "command": "npx",
  "args": ["-y", "@falahgs/imagen-3-0-generate-google-mcp-server", "--key", "${MCP_KEY}"]
}
```

Imagen Generate ermöglicht Claude die Generierung von Bildern:

- **Funktionen**: Text-zu-Bild, Bildbearbeitung, Stilübertragung
- **Modelle**: Imagen 3.0
- **Anwendungsfälle**: Visuelle Designs, Mockups, Konzeptvisualisierungen

### Magic MCP

```json
{
  "command": "npx",
  "args": ["-y", "@21st-dev/magic@latest"],
  "env": { "TWENTY_FIRST_API_KEY": "${TWENTY_FIRST_API_KEY}" }
}
```

Magic MCP ist ein kreatives Tool für die Erstellung von Designs und UI:

- **Funktionen**: UI-Generierung, Mockup-Erstellung, Bildbearbeitung
- **Output-Formate**: SVG, HTML/CSS, PNG
- **Anwendungsfälle**: UI-Design, Logo-Erstellung, Konzepterstellung

## Agent-to-Agent (A2A) Protokoll

Das A2A-Protokoll ermöglicht die Kommunikation zwischen verschiedenen KI-Agenten:

### Überblick

A2A (Agent-to-Agent) ist ein komplementäres Protokoll zu MCP, das die Kommunikation zwischen verschiedenen KI-Agenten ermöglicht. Es bietet:

- **Agent Cards**: Standardisiertes JSON-Format für Agentenbeschreibungen
- **Cross-Ecosystem-Kommunikation**: Funktioniert mit verschiedenen Frameworks (LangChain, CrewAI, etc.)
- **Mehrstufige Konversationen**: Gedächtnis und Kontexterhaltung zwischen Agenten

### Integration mit CLAUDE-AGI

```json
{
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-a2a"],
  "env": { "A2A_AGENTS_CONFIG": "${A2A_CONFIG_PATH}" }
}
```

### Anwendungsfälle

- **Multi-Agent-Systeme**: Verschiedene spezialisierte Agenten arbeiten zusammen
- **Rollenbasierte Agenten**: Agenten übernehmen spezifische Rollen (PM, Entwickler, Designer)
- **Virtuelle Teams**: Simulierte Team-Interaktionen

## Eigene MCP-Server entwickeln

### Grundlagen

Ein MCP-Server ist ein einfacher HTTP-Server, der die MCP-Spezifikation implementiert:

```javascript
// Beispiel für einen minimalen MCP-Server
const express = require('express');
const app = express();
app.use(express.json());

app.post('/mcp/v1/invoke', (req, res) => {
  const { method, params } = req.body;
  
  // Verarbeite Methode und Parameter
  // ...
  
  res.json({
    result: {
      // Ergebnis der Methode
    }
  });
});

app.listen(3000, () => {
  console.log('MCP-Server läuft auf Port 3000');
});
```

### Best Practices

- **REST-API**: Verwende bewährte REST-Prinzipien
- **Fehlerbehandlung**: Standardisierte Fehlercodes und -meldungen
- **Dokumentation**: OpenAPI/Swagger für API-Dokumentation
- **Sicherheit**: Token-basierte Authentifizierung, Input-Validierung

### Tools für die Entwicklung

- **MCP-Server-Template**: [GitHub Repository](https://github.com/modelcontextprotocol/server-template)
- **MCP-CLI**: Kommandozeilentool für das Testen von MCP-Servern
- **MCP-TypeScript-SDK**: Typen und Hilfsfunktionen für die Entwicklung