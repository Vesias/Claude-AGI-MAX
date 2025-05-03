# Claude Terminal: Technische Notizen

## Installationshinweise

### Node.js-Versionskompatibilität

Claude Terminal erfordert **Node.js 18.x** für eine erfolgreiche Installation und Kompilierung, insbesondere für die `node-pty`-Abhängigkeit.

Das Installationsskript wurde entsprechend aktualisiert, um:
1. Zu prüfen, ob NVM (Node Version Manager) installiert ist
2. Temporär zu Node.js 18.19.1 zu wechseln, falls eine andere Version aktiv ist
3. Nach der Installation zur ursprünglichen Node.js-Version zurückzukehren

### Bekannte Compilierungsprobleme

Bei Node.js 22.x tritt folgender Fehler auf:
```
error: no matching function for call to 'v8::ObjectTemplate::SetAccessor'
```

Dieser Fehler stammt aus der NaN-Bibliothek, die von `node-pty` verwendet wird und nicht mit neueren V8-Versionen kompatibel ist.

### Lösungsansatz

1. **NVM-basierte Lösung**:
   - `.nvmrc`-Datei mit "18.19.1" wurde dem Projekt hinzugefügt
   - `install.sh` wurde aktualisiert, um automatisch die richtige Node.js-Version zu verwenden
   - Neue npm-Scripts `setup` und `clean` wurden hinzugefügt

2. **Manuelle Installation**:
   ```bash
   # Node.js 18.x über NVM installieren (falls noch nicht vorhanden)
   nvm install 18.19.1
   
   # Projektverzeichnis wechseln
   cd /pfad/zu/claude-terminal
   
   # Zu Node.js 18.19.1 wechseln
   nvm use
   
   # Bereinigen und installieren
   npm run clean
   npm install
   
   # Bauen der Anwendung
   npm run build
   ```

## Abhängigkeiten

### Veraltete Pakete

Folgende Pakete wurden als veraltet markiert und sollten in zukünftigen Versionen aktualisiert werden:

- `xterm` → `@xterm/xterm`
- `xterm-addon-fit` → `@xterm/addon-fit`
- `boolean@3.2.0`
- `glob@7.2.3`
- `inflight@1.0.6`

### Native Abhängigkeiten

Die einzige native Abhängigkeit im Projekt ist `node-pty@1.0.0`, die für die Pseudoterminal-Funktionalität erforderlich ist.

Diese Komponente verursacht die meisten Kompatibilitätsprobleme und sollte in zukünftigen Versionen durch eine modernere Alternative ersetzt werden, die besser mit neueren Node.js-Versionen kompatibel ist.

## Systemanforderungen

Aufgrund der Abhängigkeit von der älteren `node-pty`-Version gelten folgende Systemanforderungen:

- **Node.js**: 18.x (vorzugsweise 18.19.1 LTS)
- **Electron**: 28.x
- **Betriebssysteme**: 
  - Windows 10/11 
  - macOS 10.15+
  - Linux mit glibc 2.28+

## AGI-Integration (2025-05-03)

Die Integration zwischen Claude Terminal und dem Claude-AGI-System wurde am 2025-05-03 implementiert. Die folgenden technischen Aspekte wurden berücksichtigt:

### Konfigurationsänderungen

1. Die Konfigurationsdatei `config.ts` wurde erweitert, um das AGI-System zu integrieren:
   - Pfad zur Memory-Bank: `/home/jan/Schreibtisch/CLAUDE/memory-bank`
   - Log-Verzeichnis: `/home/jan/Schreibtisch/CLAUDE/claude-agi-test/monitoring/data/logs`
   - AGI-Projekt-Pfad: `/home/jan/Schreibtisch/CLAUDE/claude-agi-project`
   - Monitoring-Pfad: `/home/jan/Schreibtisch/CLAUDE/claude-agi-test/monitoring`
   - VibeCodingTest-Pfad: `/home/jan/Schreibtisch/CLAUDE/VibeCodingTest`

2. Der AGI-Installer wurde aktualisiert, um:
   - Memory-Bank-Dateien aus dem globalen Template zu kopieren
   - MCP-Tools aus dem AGI-Projekt-Template zu kopieren
   - Fehlende Dateien automatisch zu erstellen

### Installation

Ein kombiniertes Installationsskript `install-claude-agi-terminal.sh` wurde erstellt, das:
1. Die Systemvoraussetzungen prüft (Node.js, npm, Git, Electron, TypeScript)
2. Die Terminal-App installiert und konfiguriert
3. Die MCP-Konfiguration erstellt
4. Die AGI-Integration vorbereitet
5. Die Memory-Bank initialisiert

### Test-Integration

Der VibeCodingTest wird als Test-Suite integriert durch:
1. Einen neuen Test-Runner in `test/vibe-test-runner.js`
2. Automatische Initialisierung des Test-Verzeichnisses
3. Parsing und Persistenz der Test-Ergebnisse
4. Integration mit dem Claude-Terminal-Dashboard

### Bekannte AGI-Integrationsprobleme

- Die Integration erfordert, dass alle Verzeichnisse an den erwarteten Pfaden existieren
- Bei fehlenden Verzeichnissen müssen diese manuell erstellt werden
- Das Test-Framework muss an die spezifische Ausgabe angepasst werden

### Nächste Schritte für AGI-Integration

- Installationsskript testen und optimieren
- Dokumentation für Endbenutzer erstellen
- Veraltete Dateien und Beispielcode bereinigen
- Integration von GitHub-Aktionen für automatisierte Tests

### Update 2025-05-03

Die folgenden Teile der Integration wurden erfolgreich implementiert:
- [x] Konfigurationsänderungen in `config.ts`
- [x] AGI-Installer-Updates
- [x] Kombiniertes Installationsskript
- [x] Test-Runner-Integration
- [ ] Dokumentation für Endbenutzer
- [ ] Bereinigung veralteter Dateien
- [ ] Abschließende Integrationstests

## Zukünftige technische Verbesserungen

1. **Ersatz für `node-pty`**:
   - Alternative Bibliotheken wie `node-pty-prebuilt-multiarch` evaluieren
   - Eigene, schlankere PTY-Integration entwickeln, die besser mit modernen Node.js-Versionen kompatibel ist

2. **Modernisierung der XTerm-Abhängigkeiten**:
   - Migration zu `@xterm/xterm` und `@xterm/addon-fit`
   - Verbesserte Terminal-Emulation mit WebGL-Rendering

3. **Verbesserte Build-Pipeline**:
   - Docker-basierter Build-Prozess für konsistente Umgebungen
   - CI/CD-Pipeline für automatische Tests und Builds

4. **AGI-Integration verbessern**:
   - Robustere Path-Handling-Mechanismen
   - Konfigurierbare Pfade über UI-Einstellungen
   - Automatische Erkennung und Installation fehlender Komponenten

## Debugging-Tipps

Bei Installationsproblemen:

1. **Node.js-Version prüfen**:
   ```bash
   node -v
   # Sollte v18.x ausgeben
   ```

2. **Native Module neu kompilieren**:
   ```bash
   # In einigen Fällen kann es helfen, die nativen Module explizit neu zu kompilieren
   cd /pfad/zu/claude-terminal
   npm rebuild
   ```

3. **Electron-spezifische Builds**:
   ```bash
   # Manchmal ist es nötig, node-pty explizit für Electron zu kompilieren
   npm rebuild node-pty --runtime=electron --target=28.3.3 --disturl=https://electronjs.org/headers
   ```

4. **AGI-Integration testen**:
   ```bash
   # Prüfen, ob die Verzeichnisse existieren
   ls /home/jan/Schreibtisch/CLAUDE/claude-agi-project
   ls /home/jan/Schreibtisch/CLAUDE/memory-bank
   
   # Installationsskript ausführen
   bash /home/jan/Schreibtisch/CLAUDE/install-claude-agi-terminal.sh
   ```

## Tags: installation, node-version, kompilierungsprobleme, abhängigkeiten, debugging, agi-integration, memory-bank, test-integration