#!/bin/bash
# ProxyClaude Schnell-Setup
# Erzeugt die gesamte Infrastruktur in wenigen Minuten

set -e  # Sofort abbrechen bei Fehlern

# Farben für Terminal-Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 ProxyClaude Schnell-Setup${NC}"
echo -e "${BLUE}==============================${NC}"

# Ensure we're in the right directory
cd "$(dirname "$0")"

# 1. Abhängigkeiten installieren
echo -e "\n${YELLOW}1. Abhängigkeiten installieren${NC}"
npm install

# 2. TypeScript kompilieren
echo -e "\n${YELLOW}2. TypeScript kompilieren${NC}"
npm run build

# 3. Redis starten (wenn nötig)
echo -e "\n${YELLOW}3. Redis für Queue-System prüfen${NC}"
if ! pgrep redis-server > /dev/null; then
  echo -e "${YELLOW}   Redis nicht gefunden, starte über Docker...${NC}"
  docker run --name proxyclaude-redis -p 6379:6379 -d redis || {
    echo -e "${RED}   ❌ Docker-Start fehlgeschlagen. Installiere Redis manuell oder starte Docker.${NC}"
    exit 1
  }
fi

# 4. Umgebungsvariablen einrichten
echo -e "\n${YELLOW}4. Umgebungsvariablen einrichten${NC}"
if [ ! -f ".env.local" ]; then
  echo -e "${YELLOW}   .env.local nicht gefunden, erstelle aus Vorlage...${NC}"
  cp .env.example .env.local
  
  # Generiere admin token
  ADMIN_TOKEN=$(openssl rand -hex 12)
  sed -i "s/ADMIN_TOKEN=.*/ADMIN_TOKEN=${ADMIN_TOKEN}/" .env.local
  echo -e "${GREEN}   ✅ Admin-Token generiert: ${ADMIN_TOKEN}${NC}"
fi

# 5. Einladungen generieren
echo -e "\n${YELLOW}5. Einladungen für die ersten 6 Nutzer generieren${NC}"
mkdir -p invites
chmod 700 invites
node scripts/invite-generator.js

# 6. Verzeichnisse für Daten anlegen
echo -e "\n${YELLOW}6. Daten-Verzeichnisse vorbereiten${NC}"
mkdir -p logs data
chmod 750 logs data

# 7. Service starten
echo -e "\n${YELLOW}7. ProxyClaude starten${NC}"
echo -e "${BLUE}   Wähle Startmodus:${NC}"
echo -e "   1) Entwicklungsmodus (ts-node-dev)"
echo -e "   2) Produktionsmodus (Node.js)"
echo -e "   3) Produktionsmodus mit PM2"

read -p "   Wähle (1-3): " start_mode

case $start_mode in
  1)
    echo -e "${GREEN}   ✅ Starte im Entwicklungsmodus...${NC}"
    npm run dev
    ;;
  2)
    echo -e "${GREEN}   ✅ Starte im Produktionsmodus...${NC}"
    NODE_ENV=production node dist/index.js
    ;;
  3)
    echo -e "${GREEN}   ✅ Starte im Produktionsmodus mit PM2...${NC}"
    ./start-production.sh
    ;;
  *)
    echo -e "${RED}   ❌ Ungültige Auswahl!${NC}"
    exit 1
    ;;
esac

echo -e "\n${GREEN}✅ ProxyClaude Setup abgeschlossen!${NC}"
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}📌 API URL: http://localhost:4000${NC}"
echo -e "${GREEN}📌 Admin-URL: http://localhost:4000/admin${NC}"
echo -e "${GREEN}📌 Admin-Token: ${ADMIN_TOKEN}${NC}"
echo -e "${GREEN}📌 Payment-URL: http://localhost:4000/payment/checkout${NC}"
echo -e "${GREEN}=================================================${NC}"
echo -e "${YELLOW}⚠️ WICHTIG: Trage deine STRIPE- und CLAUDE-API-Keys in .env.local ein,${NC}"
echo -e "${YELLOW}   bevor du den Service produktiv nutzt!${NC}"