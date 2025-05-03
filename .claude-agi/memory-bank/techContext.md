# ProxyClaude - Technologie-Kontext

## 🛠️ Technologie-Stack

### Backend-Framework
- **Node.js** (v18+): JavaScript-Laufzeitumgebung
- **Express.js**: Web-Framework für API-Endpunkte
- **TypeScript**: Stark typisierte Erweiterung für JavaScript

### Datenverarbeitung
- **Mock Queue**: In-Memory-Implementation (anstelle von Redis)
- **Bull**: Queue-Bibliothek (falls Redis verfügbar)
- **File System**: Für Logs und einfache Datenpersistenz

### Frontend / Admin
- **HTML/CSS/JavaScript**: Einfaches Admin-Dashboard
- **Bootstrap-ähnliches Styling**: Für UI-Komponenten

### Zahlungsabwicklung
- **Stripe API** (2023-08-16): Für Zahlungsabwicklung und Abonnements
- **Webhook-Integration**: Für Zahlungsbenachrichtigungen

### Authentifizierung
- **API Key Auth**: Bearer-Token im Authorization-Header
- **Admin Token**: Query-Parameter für Admin-Dashboard-Zugriff

### Logging und Monitoring
- **Custom Logger**: Datei- und Console-basiertes Logging
- **In-Memory Metrics**: Für Echtzeit-Monitoring im Admin-Panel

### Deployment
- **PID-Datei**: Für Service-Management
- **Environment Variables**: Für Konfiguration (.env.local)

## 🧩 Externe Abhängigkeiten

### Produktionsabhängigkeiten
```json
{
  "dependencies": {
    "dotenv": "^16.3.1",
    "express": "^4.18.2",
    "stripe": "^13.4.0"
  }
}
```

### Entwicklungsabhängigkeiten
```json
{
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/node": "^20.5.7",
    "typescript": "^5.2.2"
  }
}
```

## 🧪 Testumgebung

### Test-Credentials
- **Stripe Test Keys**: Für Zahlungstests ohne echte Transaktionen
- **Claude API Test Keys**: Für API-Anfragen ohne echte Tokens zu verbrauchen

### API-Testbeispiele
```bash
# API-Test mit CURL
curl -X POST http://localhost:4001/api/claude-agi/chat \
  -H "Authorization: Bearer test-key" \
  -H "Content-Type: application/json" \
  -d '{"content":"Hello, how are you today?"}'

# Erwartete Antwort
{
  "result": {
    "content": "Simulierte Antwort von Claude...",
    "tokens": {
      "prompt": 7,
      "completion": 49
    }
  }
}
```

## 🏛️ Architektur

### Hauptkomponenten
1. **API Router**: Verarbeitet Claude-API-Anfragen
2. **Payment Router**: Handhabt Stripe-Integration
3. **Admin Router**: Bietet Dashboard und Monitoring
4. **Queue Service**: Verarbeitet Anfragen asynchron
5. **Monitoring Service**: Sammelt Metriken
6. **Logger Service**: Verwaltet Logging

### Datenfluss
1. Client sendet API-Anfrage mit Authorization-Header
2. Middleware prüft API-Key und Rate Limits
3. Anfrage wird in Queue eingereiht
4. Queue-Processor verarbeitet Anfrage (simuliert Claude-API)
5. Antwort wird an Client zurückgesendet
6. Metriken werden aktualisiert

### Verzeichnisstruktur
```
proxyclaude/
├── .env.local              # Umgebungsvariablen
├── .pid                    # Service PID
├── tsconfig.json           # TypeScript-Konfiguration
├── package.json            # Abhängigkeiten
├── src/
│   ├── index.ts            # Haupteinstiegspunkt
│   ├── routes/
│   │   ├── api.ts          # API-Endpunkte
│   │   ├── payment.ts      # Zahlungsendpunkte
│   │   └── admin.ts        # Admin-Dashboard
│   ├── services/
│   │   ├── queue.ts        # Queue-Implementierung
│   │   ├── monitoring.ts   # Metriken-Sammlung
│   │   └── logger.ts       # Logging-System
│   └── types/
│       └── index.d.ts      # TypeScript-Deklarationen
├── dist/                   # Kompilierte JavaScript-Dateien
├── logs/                   # Log-Dateien
├── invites/                # Einladungen für Beta-Tester
└── scripts/
    └── invite-generator.js # Skript für Einladungsgenerierung
```

## 🚀 MCP-Integration

### MCP-Server-Konfiguration
```json
{
  "command": "npx",
  "args": ["-y", "@proxyclaude/mcp-server@latest"],
  "env": {
    "API_ENDPOINT": "http://localhost:4001",
    "MAX_RETRIES": "3"
  }
}
```

### MCP-Server-Funktionalität
- **API-Proxy**: Leitet Anfragen an ProxyClaude-Service weiter
- **Fehlerbehandlung**: Automatische Wiederholungen bei Fehlern
- **Zwischenspeicherung**: Optional Caching für wiederholte Anfragen
- **Formatkonvertierung**: Von/zu Claude Desktop Format

## 🌐 API-Spezifikation

### Endpunkte
- **POST /api/claude-agi/chat**: Claude-Chat-Anfrage
- **GET /payment/checkout**: Zahlungsseite
- **POST /payment/create-checkout-session**: Erstellt Stripe-Session
- **GET /admin**: Admin-Dashboard
- **GET /**: Health-Check

### API-Anfrage-Format
```json
{
  "content": "Benutzeranfrage an Claude"
}
```

### API-Antwort-Format
```json
{
  "result": {
    "content": "Antwort von Claude",
    "tokens": {
      "prompt": 10,
      "completion": 50
    }
  }
}
```

## 🔐 Sicherheitsaspekte

### API-Schlüsselverwaltung
- **Speicherung**: In .env.local (nicht versioniert)
- **Validierung**: Gegen Liste gültiger Schlüssel
- **Format**: Bearer-Token im Authorization-Header

### Rate Limiting
- **Zeitbasiert**: 60 Anfragen pro Minute pro Benutzer
- **Headers**: X-RateLimit-* für Client-Feedback
- **Speicherung**: In-Memory (könnte Redis verwenden)

### Datenschutz
- **Logs**: Keine vollständigen Anfragetexte in Logs
- **Stripe**: Nur E-Mail für Identifikation
- **API-Anfragen**: Keine persistente Speicherung von Inhalten