# CLAUDE-AGI: Komplettes Framework für KI-gestützte Entwicklung

*Version 1.0 • 2025-05-03*

> **⚠️ WICHTIG: Benötigt Claude Pro MAX Abonnement**
> 
> Dieses Framework erfordert ein aktives Claude Pro MAX Abonnement für die Nutzung aller Funktionen.

## 🌟 Überblick

CLAUDE-AGI ist ein umfassendes Framework zur Projektverwaltung und -entwicklung mit Claude als KI-Assistenten. Es kombiniert:

- **Memory-Bank-System**: Kontinuität zwischen Sitzungen
- **MCP-Tools**: Erweiterte Funktionalität durch externe Tools
- **Vibe-Coding-Stack**: Modern Web/Blockchain Development
- **GitHub-Integration**: Private Repositories und Workflow-Automation
- **ProxyClaude-Service**: Teilen von Claude-API-Zugängen im Team

## 📋 Inhaltsverzeichnis

1. [Voraussetzungen](#voraussetzungen)
2. [Installation](#installation)
3. [Verfügbare MCP-Tools](#verfügbare-mcp-tools)
4. [Vibe-Coding-Stack](#vibe-coding-stack)
5. [Projektverwaltung](#projektverwaltung)
6. [ProxyClaude-Service](#proxyclaude-service)
7. [Dokumentation](#dokumentation)

## 🔧 Voraussetzungen

- **Node.js** (v20+)
- **Git** (v2.40+)
- **GitHub CLI** (v2.50+)
- **Claude Desktop** (≥ v0.19)
- **Claude Code** (≥ v0.12)
- **Claude Pro MAX** Abonnement

## 🚀 Installation

### Sichere Installation (empfohlen)

```bash
# Lade das Installationsskript herunter
curl -sSL https://github.com/claude-agi/cli/releases/download/v1.0/install-claude-agi.sh -O

# Überprüfe Prüfsumme
echo "abcdef1234567890abcdef1234567890 install-claude-agi.sh" | sha256sum -c

# Führe Installer aus
bash install-claude-agi.sh
```

Der Installer führt dich durch den gesamten Prozess:
- Überprüft Systemvoraussetzungen
- Konfiguriert MCP-Tools ohne Smithery
- Richtet das Vibe-Coding-Stack ein
- Speichert API-Keys sicher in .env (nicht committet)

### Manuelle Einrichtung

Alternativ kannst du das System auch manuell einrichten:

1. Repository klonen: `git clone https://github.com/YourUsername/claude-agi.git ~/.claude`
2. Abhängigkeiten installieren: `cd ~/.claude && npm install`
3. MCP-Tools konfigurieren: Bearbeite `.config/claude_desktop_config.json`
4. API-Keys einrichten: Erstelle `.env` nach dem Vorbild von `.env.example`

## 🛠️ Verfügbare MCP-Tools

CLAUDE-AGI integriert zahlreiche MCP-Tools, organisiert nach Kategorien:

| Kategorie | Beispiel-Tools | Anwendungsfälle |
|-----------|----------------|-----------------|
| **Core** | desktop-commander, code-mcp, sequentialthinking | Dateisystem, Code-Generierung, Problemanalyse |
| **Web Automation** | browserbase, spider | Headless Browser, Web-Scraping |
| **Vector & Memory** | qdrant, milvus, memory-bank | Embeddings, Vektordatenbanken, Kontext-Speicherung |
| **Datenbanken** | db-mcp-server | PostgreSQL, MySQL, MongoDB Integration |
| **Git & CI/CD** | github, git-mcp-server | PRs, Issues, Code-Reviews |
| **PDF & Dokumente** | mcp-pdf-tools, pandoc | PDF-Bearbeitung, Format-Konvertierung |
| **Übersetzung** | lara-translate, deepl | Multi-Sprach-Support |
| **Messaging** | twilio, slack-mcp | SMS, WhatsApp, Slack-Integration |

Vollständige Dokumentation: [MCP-Tools Referenz](./docs/mcp-tools-reference.md)

## 💎 Vibe-Coding-Stack

Der integrierte Vibe-Coding-Stack ist eine moderne Full-Stack-Entwicklungsumgebung:

- **Next.js 15** (React 19)
- **Supabase** (DB, Auth, Storage)
- **Vercel** (Hosting, Edge Functions)
- **shadcn/ui + Tailwind CSS** (UI-Komponenten)
- **tRPC + Zod** (Typsichere API)
- **Three.js + react-three-fiber** (3D-Visualisierungen)

Mit Erweiterungen für Blockchain:
- **Phantom Wallet** (Solana, ETH, BTC)
- **wagmi + RainbowKit** (Ethereum)
- **BTCPay Server** / **Stripe Crypto** (Payments)

Details: [Vibe-Coding-Stack Dokumentation](./docs/vibe-coding-stack.md)

## 📁 Projektverwaltung

### Neues Projekt erstellen

```bash
# Standard-Projekt
memory-bank init ProjektName

# Vibe-Coding-Projekt
memory-bank vibe ProjektName
```

### Mit Memory-Bank arbeiten

Jedes Projekt enthält eine Memory-Bank für Kontinuität zwischen Sitzungen:

1. `projectbrief.md`: Grundlegende Projektdefinition
2. `productContext.md`: Zweck und Problemlösung
3. `activeContext.md`: Aktueller Fokus und nächste Schritte
4. `systemPatterns.md`: Systemarchitektur und Design-Patterns
5. `techContext.md`: Verwendete Technologien
6. `progress.md`: Aktueller Status und Fortschritt

Um die Memory-Bank zu aktualisieren:
```bash
memory-bank update ~/Schreibtisch/CLAUDE/ProjektName
```

## 🚀 ProxyClaude-Service

ProxyClaude ermöglicht das Teilen eines Claude Pro MAX Accounts zwischen mehreren Teammitgliedern zum Festpreis:

- Bis zu 6 Entwickler teilen sich einen Account
- API-basierter Zugriff mit Authentifizierung
- Stripe-Integration zur Zahlungsabwicklung (30€/Monat)
- Rate Limiting und Monitoring

### Einrichtung

```bash
cd .claude-agi/services/proxyclaude
npm install
npm run build
PORT=4001 npm start
```

### Integration in Claude Desktop

ProxyClaude bindet sich nahtlos in die Claude Desktop App ein:

```json
{
  "mcpServers": {
    "proxyclaude": {
      "command": "npx",
      "args": ["-y", "@proxyclaude/mcp-server@latest"],
      "env": {
        "API_ENDPOINT": "http://localhost:4001",
        "MAX_RETRIES": "3"
      }
    }
  }
}
```

Weitere Informationen: [ProxyClaude Komplettleitfaden](./.claude-agi/services/proxyclaude/README.md)

## 📚 Dokumentation

- [CLAUDE AGI Terminal Guide](./docs/TERMINAL_GUIDE.md): Installation und Verwendung des CLAUDE AGI Terminals
- [Systemarchitektur](./docs/ARCHITECTURE.md): Detaillierte Architekturübersicht des Gesamtsystems
- [ProxyClaude Guide](./docs/proxyclaude-guide.md): Integration und Nutzung von ProxyClaude
- [Claude Code Leitfaden](./docs/claude-code-guide.md): Tutorials, Troubleshooting, CLI-Referenz
- [MCP-Tools Referenz](./docs/mcp-tools-reference.md): Umfassende Tool-Liste mit Anleitungen
- [Vibe-Coding-Stack](./docs/vibe-coding-stack.md): Kompletter Leitfaden für den Stack

## 🔐 Sicherheitshinweise

- **Private Repositories**: Alle Projekt-Repos werden als privat konfiguriert
- **Secrets-Schutz**: API-Keys werden in .env gespeichert und nicht committet
- **Verified Tools**: Nutze bevorzugt offizielle oder verifizierte MCP-Server

## 🤝 Mitwirkung & Support

- Probleme melden: [GitHub Issues](https://github.com/YourUsername/claude-agi/issues)
- Dokumentation verbessern: PRs willkommen
- Unterstützung: Discord-Server oder E-Mail an support@example.com