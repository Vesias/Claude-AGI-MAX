# CLAUDE - Technologiekontext

## Stack-Konfiguration
- Frontend:
  - Framework: Next.js 15 mit App Router
  - UI: React 18+ mit TypeScript 5.0+
  - State-Management: Zustand für globalen State
  - Typ-System: TypeScript mit strikter Konfiguration und Zod für Runtime-Validierung

- Backend:
  - Infrastruktur: Supabase mit PostgreSQL
  - Datenbank: PostgreSQL 14+ mit JSONB, RLS und Volltext-Indizierung
  - Serverless: Edge Functions für globale Performance
  - API: REST und GraphQL über Supabase API

- DevOps:
  - CI/CD: GitHub Actions für automatisierte Tests und Deployment
  - Hosting: Vercel für Frontend, Supabase für Backend
  - Monitoring: Sentry für Fehler-Tracking, Vercel Analytics für Performance

- Terminal-App:
  - Framework: Electron 28+ mit TypeScript
  - Terminal-Emulation: xterm.js, node-pty
  - Benutzeroberfläche: blessed, blessed-contrib für TUI-Komponenten
  - Node.js: Version 16 für maximale Kompatibilität mit node-pty

## Entwicklungsumgebung
- VS Code Konfiguration:
  - Erweiterungen: ESLint, Prettier, Tailwind CSS IntelliSense, TypeScript
  - Settings: formatOnSave, defaultFormatter, codeActionsOnSave
  - Memory-Bank-Integration über claude-dev.memoryBankDir

- ESLint + Prettier Setup:
  - ESLint mit Airbnb-Konfiguration und TypeScript-Plugins
  - Prettier mit konsistentem Stil über alle Projekte
  - Husky für Pre-Commit-Hooks

- MCP Tool Integration:
  - Memory-Server für persistente Speicherung
  - Sequential-Thinking für strukturierte Problemlösung
  - Code-Context für Codeverstehen und -generierung
  - Desktop-Commander für Dateisystem-Operationen
  - Brave-Search für Websuche-Integration

## Drittanbieter-Integration
- MCP-Server API:
  - JSON-RPC 2.0 über HTTP/WebSockets
  - Standardisierte Schnittstellen für Werkzeugnutzung
  - Authentifizierte Verbindungen mit Umgebungsvariablen
  - Konfigurations-Management in claude_desktop_config.json

- Claude-API:
  - OpenAI-kompatible Schnittstelle für Textgenerierung
  - Streaming-Unterstützung für progressive Antworten
  - System-Prompt-Management für konsistentes Verhalten

- GitHub API:
  - Repository-Management
  - Workflow-Trigger
  - Pull-Request-Automatisierung

## Leistungsmetriken
- Frontend-Metrics:
  - Core Web Vitals: LCP < 2,5s, FID < 100ms, CLS < 0,1
  - Bundle-Größe: < 100KB gzipped initial load
  - Hydration-Zeit: < 1s auf mittleren Geräten

- Backend-Metrics:
  - API-Latenz: < 300ms für 95% der Anfragen
  - Datenbank-Performance: < 50ms für häufige Abfragen
  - Serverless-Kaltstarts: < 800ms

- Terminal-App-Metrics:
  - Startzeit: < 2s
  - Speicherverbrauch: < 350MB RAM
  - Terminalarkeit: < 50ms Eingabeverzögerung
  - Abhängigkeitsoptimierung: 249MB Einsparung nach Optimierung

- Monitoring-Strategie:
  - Privacy-First Monitoring-System mit Datenschutz als Priorität
  - Automatische Anonymisierung von sensiblen Daten und Projektinformationen
  - Real-User-Monitoring (RUM) für Client-Performance
  - APM für Backend-Überwachung
  - Logging mit strukturierten Logs und Indexierung
  - Zentrale Log-Aggregation in monitoring/data/logs
  - Web-Dashboard für Echtzeit-Monitoring mit Filterfunktionen
  - Verschlüsselung von kritischen Daten mit AES-256-CBC