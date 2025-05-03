# ProxyClaude - Systemarchitektur & Design Patterns

## 🏗️ Architektur-Übersicht

```
┌─────────────────┐      ┌────────────────┐      ┌────────────────┐
│  Claude Desktop │─────▶│  MCP Server    │─────▶│  ProxyClaude   │
│  (Client)       │◀─────│  (Middleware)  │◀─────│  (API Service) │
└─────────────────┘      └────────────────┘      └────────────────┘
                                                        │
                                                        ▼
                                               ┌────────────────┐
                                               │   Claude API   │
                                               │   (External)   │
                                               └────────────────┘
```

### Kernkomponenten

1. **ProxyClaude API Service**:
   - Express.js basierter REST-API Server
   - API-Key Authentifizierung
   - Rate Limiting und Queue Management
   - Admin Dashboard und Monitoring

2. **MCP Server**:
   - Middleware zwischen Claude Desktop und ProxyClaude
   - Request Transformation und Formatierung
   - Caching und Fehlerbehandlung
   - Retry-Logik für robuste Kommunikation

3. **Claude Desktop Integration**:
   - Nahtlose MCP-Tools Konfiguration
   - Browser-Tools für erweiterte Funktionalität
   - Memory-Bank für Persistenz
   - Desktop Commander für Systemautomation

## 🧩 Design Patterns

### 1. Proxy Pattern
Das zentrale Architekturmuster ist das Proxy Pattern, bei dem ProxyClaude als Vermittler zwischen Clients und der Claude API fungiert:
```javascript
// API Proxy Implementierung
router.post('/claude-agi/chat', async (req, res) => {
  // Authentifizierung und Rate Limiting
  // Weiterleitung der Anfrage an Claude API
  // Rückgabe der Antwort an Client
});
```

### 2. Middleware-Kette Pattern
Express.js Middleware-Ketten für modulare Funktionalität:
```javascript
// Middleware-Kette für API-Anfragen
router.use(apiKeyAuth);      // Authentifizierung
router.use(rateLimiter);     // Rate Limiting
router.use(metricsCollector); // Metriken sammeln
router.use(errorHandler);     // Fehlerbehandlung
```

### 3. Decorator Pattern
Das Logger-System nutzt das Decorator Pattern, um zusätzliche Funktionalität zu HTTP-Responses hinzuzufügen:
```javascript
// Dekorieren der Response mit Logging
const originalEnd = res.end;
res.end = function(chunk, encoding) {
  const duration = Date.now() - start;
  logRequest(req, res.statusCode, duration);
  return originalEnd.call(this, chunk, encoding);
};
```

### 4. Factory Pattern
Die Queue-Implementierung nutzt ein Factory Pattern, um standardisierte Job-Objekte zu erstellen:
```javascript
// Queue Factory für Job-Erstellung
function createJob(type, data, options) {
  return {
    id: `job-${Date.now()}`,
    type,
    data,
    options,
    createdAt: new Date(),
    status: 'pending'
  };
}
```

### 5. Observer Pattern
Das Monitoring-System implementiert das Observer Pattern für Event-Handling:
```javascript
// Event Emitter für Monitoring
const eventEmitter = new EventEmitter();
eventEmitter.on('request', incrementRequests);
eventEmitter.on('error', incrementErrors);
eventEmitter.on('completed', recordProcessingTime);
```

### 6. Strategy Pattern
Die Rate-Limiting-Implementierung verwendet das Strategy Pattern für unterschiedliche Tier-Levels:
```javascript
// Rate Limiting Strategien
const rateLimitStrategies = {
  standard: {
    requestsPerMinute: 40,
    queuePriority: 2
  },
  premium: {
    requestsPerMinute: 100,
    queuePriority: 1
  }
};

// Strategie basierend auf User-Tier auswählen
const strategy = rateLimitStrategies[userTier] || rateLimitStrategies.standard;
```

## 🔄 Datenfluss

### 1. API-Anfrage-Verarbeitung
```
Client Request → API-Key Auth → Rate Limiting → Queue → Claude API → Response Formatting → Client Response
```

### 2. Zahlungsverarbeitung
```
Client Checkout → Stripe Session → Payment Processing → API Key Generation → Email Notification → User Activation
```

### 3. Admin-Dashboard
```
Admin Request → Token Auth → Metrics Collection → Invite Management → System Monitoring → Admin Interface
```

## 📊 Skalierungsansatz

### Horizontale Skalierung
```
┌─────────────┐
│ Load        │
│ Balancer    │
└──────┬──────┘
       │
       ▼
┌──────┬──────┬──────┐
│ API  │ API  │ API  │
│ Node │ Node │ Node │
└──────┴──────┴──────┘
       │
       ▼
┌──────┴──────┐
│ Shared      │
│ Database    │
└─────────────┘
```

### Queue-basierte Architektur
```
┌──────────┐   ┌──────────┐   ┌──────────┐
│ Client   │──▶│ Request  │──▶│ Worker   │
│ Requests │   │ Queue    │   │ Processes│
└──────────┘   └──────────┘   └──────────┘
                    ▲               │
                    └───────────────┘
                      Results Queue
```

## 🔒 Sicherheitsarchitektur

### Authentifizierung & Autorisierung
```
┌──────────┐   ┌──────────┐   ┌──────────┐
│ API Key  │──▶│ API Key  │──▶│ Request  │
│ Validation│   │ Lookup   │   │Processing│
└──────────┘   └──────────┘   └──────────┘
```

### Rate Limiting
```
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│ Request     │──▶│ Rate Limit  │──▶│ Request     │
│ Count Update│   │ Check       │   │ Processing  │
└─────────────┘   └─────────────┘   └─────────────┘
                         │
                         ▼
                  ┌─────────────┐
                  │ 429 Too Many│
                  │ Requests    │
                  └─────────────┘
```

## 🧪 Testarchitektur

### Unit Testing
```
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│ Test        │──▶│ Function    │──▶│ Assertion   │
│ Case        │   │ Execution   │   │ Verification│
└─────────────┘   └─────────────┘   └─────────────┘
```

### Integration Testing
```
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│ API         │──▶│ Response    │──▶│ Expectation │
│ Request     │   │ Capture     │   │ Matching    │
└─────────────┘   └─────────────┘   └─────────────┘
```

## 🔧 MCP-Tools Integration

### MCP Server Kommunikation
```
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ Claude Desktop│──▶│ MCP Server    │──▶│ ProxyClaude   │
│ Request       │   │ Communication │   │ API Request   │
└───────────────┘   └───────────────┘   └───────────────┘
```

### Browser-Tools Integration
```
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ Screenshot    │──▶│ Image         │──▶│ Claude        │
│ Capture       │   │ Processing    │   │ Analysis      │
└───────────────┘   └───────────────┘   └───────────────┘
```

### Memory-Bank Integration
```
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ Context       │──▶│ Memory        │──▶│ Context       │
│ Capture       │   │ Storage       │   │ Retrieval     │
└───────────────┘   └───────────────┘   └───────────────┘
```

## 🚀 Deployment-Architektur

### Entwicklungsumgebung
```
┌────────────┐
│ Local      │
│ Development│
└────────────┘
      │
      ▼
┌────────────┐
│ Local      │
│ Testing    │
└────────────┘
```

### Produktionsumgebung
```
┌────────────┐   ┌────────────┐   ┌────────────┐
│ CI/CD      │──▶│ Staging    │──▶│ Production │
│ Pipeline   │   │ Environment│   │ Deployment │
└────────────┘   └────────────┘   └────────────┘
```