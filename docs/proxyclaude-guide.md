# ProxyClaude Service Guide

ProxyClaude ist ein API-Proxy-Dienst für Claude, der speziell für das CLAUDE-AGI-Ökosystem entwickelt wurde. Es bietet eine zentrale Schnittstelle für alle Claude-AI-Interaktionen mit erweiterten Funktionen wie Nutzungsverfolgung, Ratenbegrenzung und Zahlungsabwicklung.

## Funktionen

- **API-Zugriffsverwaltung**: Nutzerverwaltung mit JWT-Authentifizierung
- **Nutzungskontingente**: Flexible Preisstufen mit unterschlichen API-Limits
- **Stripe-Integration**: Automatisierte Zahlungsabwicklung und Abonnementverwaltung
- **Memory-Bank-Integration**: Persistenter Kontext über Sitzungen hinweg
- **Monitoring-Dashboard**: Echtzeit-Überwachung der API-Nutzung und -Kosten
- **Warteschlangensystem**: Optimale Ressourcennutzung und Lastausgleich

## Einrichtung

### Voraussetzungen

- Node.js 18+ und npm
- Redis Server (für Warteschlangenverwaltung)
- Stripe-Konto (für Zahlungsabwicklung)
- Claude API-Zugang

### Installation

1. Der Dienst ist bereits im CLAUDE-AGI-Workspace installiert:

   ```bash
   cd .claude-agi/services/proxyclaude
   ```

2. Abhängigkeiten installieren:

   ```bash
   npm install
   ```

3. Umgebungsvariablen konfigurieren:

   ```bash
   cp .env.example .env.local
   # Bearbeite .env.local mit deinen API-Schlüsseln und Einstellungen
   ```

4. Service starten:

   ```bash
   npm run dev  # Entwicklungsmodus mit Hot-Reload
   # oder
   npm run build && npm start  # Produktionsmodus
   ```

Der Service wird standardmäßig auf http://localhost:4001 verfügbar sein.

## Verwendung

### Integration mit Claude Desktop

ProxyClaude kann nahtlos in die Claude Desktop App integriert werden:

```json
{
  "mcpServers": {
    "proxyclaude": {
      "command": "npx",
      "args": ["-y", "@claude-agi/proxyclaude-mcp-server"],
      "env": {
        "API_ENDPOINT": "http://localhost:4001",
        "MAX_RETRIES": "3"
      }
    }
  }
}
```

Diese Konfiguration ist bereits in der standardmäßigen `.config/claude_desktop_config.json` enthalten.

### Für Kunden

1. Besuche `/payment/checkout`, um API-Zugang zu erwerben
2. Nach der Zahlung erhältst du einen API-Schlüssel per E-Mail
3. Verwende den API-Schlüssel in deinen Anfragen:

```bash
curl -X POST http://localhost:4001/api/claude-agi/chat \
  -H "Authorization: Bearer DEIN_API_SCHLÜSSEL" \
  -H "Content-Type: application/json" \
  -d '{"content": "Dein Prompt hier"}'
```

### Für Administratoren

1. Zugriff auf das Admin-Dashboard:

   ```bash
   curl -X POST http://localhost:4001/auth/admin-login \
     -H "Content-Type: application/json" \
     -d '{"password": "ADMIN_SECRET_AUS_ENV"}'
   ```

2. Mit dem erhaltenen Token kannst du auf das Dashboard zugreifen:

   ```bash
   curl http://localhost:4001/admin/dashboard \
     -H "Authorization: Bearer ADMIN_TOKEN"
   ```

   Oder besuche `/admin` im Browser nach dem Einloggen.

## API-Referenz

### Authentication Endpoints

| Endpoint | Methode | Beschreibung |
|----------|---------|--------------|
| `/auth/register` | POST | Neuen Benutzer registrieren |
| `/auth/login` | POST | Benutzer einloggen und Token erhalten |
| `/auth/refresh` | POST | Access Token erneuern |
| `/auth/admin-login` | POST | Admin-Zugriff |

### API Endpoints

| Endpoint | Methode | Beschreibung |
|----------|---------|--------------|
| `/api/claude-agi/chat` | POST | Claude-Chat-Anfrage senden |
| `/api/claude-agi/completions` | POST | Textergänzungen generieren |
| `/api/usage` | GET | Nutzungsstatistiken abrufen |

### Admin Endpoints

| Endpoint | Methode | Beschreibung |
|----------|---------|--------------|
| `/admin/dashboard` | GET | Admin-Dashboard anzeigen |
| `/admin/users` | GET | Alle Benutzer anzeigen |
| `/admin/users/:id` | GET | Spezifischen Benutzer anzeigen |
| `/admin/invite` | POST | Einladungscode generieren |

### Payment Endpoints

| Endpoint | Methode | Beschreibung |
|----------|---------|--------------|
| `/payment/checkout` | GET | Checkout-Seite öffnen |
| `/payment/success` | GET | Erfolgreiche Zahlung |
| `/payment/webhook` | POST | Stripe-Webhook-Handler |

## Geschäftsmodell: ProxyClaude für Teams

### Preisstruktur
- **Standard Tier**: €20/Monat (Warteliste - Aktivierung nach 3 Teilnehmern)
- **Premium Tier**: €30/Monat (Sofortiger Zugang)
- **Team Plan**: 1 Claude Pro MAX Account (€90) für bis zu 6 Nutzer

### Kapazitätsmanagement
Jeder €90 Account generiert 6 Zugänge:
1. 3 Standard-Nutzer (€20 = €60)
2. 2-3 Premium-Nutzer (€60-105)
3. Gesamteinnahmen: €120-€165 pro Account

## Sicherheit

- API-Schlüssel werden sicher gehashed gespeichert
- Stripe verarbeitet alle Zahlungsinformationen
- Ratenbegrenzung verhindert Missbrauch
- Alle sensiblen Konfigurationen werden in `.env.local` gespeichert (nicht im Git)

## Wartung und Betrieb

### Logs

Die Logs werden im `/logs`-Verzeichnis gespeichert und können wie folgt eingesehen werden:

```bash
cat .claude-agi/services/proxyclaude/logs/proxyclaude.log
```

### Warteschlangen-Management

Redis Warteschlangenstatus ansehen:

```bash
npx bull-repl
```

### Prozessverwaltung

Der Service schreibt seine PID in eine `.pid`-Datei. Um den Prozess zu stoppen:

```bash
kill -SIGTERM $(cat .claude-agi/services/proxyclaude/.pid)
```

## Integration mit dem CLAUDE-AGI-Ökosystem

ProxyClaude nutzt mehrere CLAUDE-AGI-Komponenten:

- **Memory Bank**: für persistente Kontextverwaltung
- **Monitoring-System**: für Nutzungsverfolgung
- **MCP-Tools**: für erweiterte Funktionen

## Automatisierte Workflows

### 1. Benutzer-Onboarding Workflow

```bash
# Neuen Benutzer hinzufügen
curl -X POST http://localhost:4001/admin/users/create \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Neuer Nutzer",
    "email": "nutzer@example.com",
    "tier": "premium"
  }'
```

### 2. System-Monitoring Workflow

```bash
# ProxyClaude Status Check
curl http://localhost:4001/admin/system/status \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

## Fehlerbehebung

### Häufige Probleme

1. **Redis-Verbindungsfehler**:
   - Prüfe, ob Redis läuft: `redis-cli ping`
   - Überprüfe die Redis-URL in der `.env.local`

2. **API-Schlüssel funktioniert nicht**:
   - Prüfe die API-Kontingente mit `/api/usage`
   - Stelle sicher, dass der Schlüssel nicht abgelaufen ist

3. **Stripe-Webhooks funktionieren nicht**:
   - Teste Webhooks lokal mit `stripe listen`
   - Überprüfe STRIPE_WEBHOOK_SECRET in `.env.local`

## Best Practices

1. **Morgen-Routine**:
   - Status-Check aller Services
   - Review der Overnight-Logs
   - Kapazitätsplanung für den Tag

2. **User-Support**:
   - Automatisierte FAQ-Responses über das Admin-Dashboard
   - Ticketsystem-Integration für Support-Anfragen
   - Proaktive Monitoring-Alerts bei API-Problemen

3. **Business-Operations**:
   - Tägliche Revenue-Reports
   - Kapazitäts-Optimierung
   - Customer Success Tracking