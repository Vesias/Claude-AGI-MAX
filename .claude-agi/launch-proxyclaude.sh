#!/bin/bash
# Claude-Terminal Integration für ProxyClaude
# Startet ProxyClaude direkt aus dem CLAUDE-Verzeichnis

# Farben für Terminal-Output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 ProxyClaude Terminal Launcher${NC}"
echo -e "${BLUE}==============================${NC}"

# Prüfen, ob ProxyClaude existiert
if [ ! -d ".claude-agi/services/proxyclaude" ]; then
  echo -e "${YELLOW}ProxyClaude noch nicht installiert. Starte Setup...${NC}"
  mkdir -p .claude-agi/services/proxyclaude
  
  # Hier könnte man einen auto-setup Schritt durchführen
  echo -e "${YELLOW}Bitte installiere ProxyClaude erst vollständig.${NC}"
  echo -e "${YELLOW}Führe aus: cd .claude-agi/services/proxyclaude && ./setup-quick-service.sh${NC}"
  exit 1
fi

# Ins ProxyClaude-Verzeichnis wechseln
cd .claude-agi/services/proxyclaude

# Prüfen, ob Setup bereits ausgeführt wurde
if [ ! -f "package.json" ]; then
  echo -e "${YELLOW}ProxyClaude scheint nicht korrekt installiert zu sein.${NC}"
  echo -e "${YELLOW}Führe aus: ./setup-quick-service.sh${NC}"
  exit 1
fi

# Prüfen, ob build existiert
if [ ! -d "dist" ]; then
  echo -e "${YELLOW}ProxyClaude ist noch nicht gebaut. Baue jetzt...${NC}"
  npm run build
fi

# Menü anzeigen
echo -e "\n${BLUE}Wähle eine Option:${NC}"
echo -e "1) ProxyClaude im Entwicklungsmodus starten"
echo -e "2) ProxyClaude im Produktionsmodus starten"
echo -e "3) ProxyClaude mit PM2 starten/stoppen"
echo -e "4) Einladungslinks generieren"
echo -e "5) Admin-Übersicht anzeigen"
echo -e "6) ProxyClaude status anzeigen"
echo -e "q) Beenden"

read -p "Wähle (1-6, q): " option

case $option in
  1)
    echo -e "${GREEN}Starte ProxyClaude im Entwicklungsmodus...${NC}"
    npm run dev
    ;;
  2)
    echo -e "${GREEN}Starte ProxyClaude im Produktionsmodus...${NC}"
    NODE_ENV=production node dist/index.js
    ;;
  3)
    # PM2 Submenu
    echo -e "\n${BLUE}PM2 Optionen:${NC}"
    echo -e "a) ProxyClaude mit PM2 starten"
    echo -e "b) ProxyClaude mit PM2 stoppen"
    echo -e "c) ProxyClaude PM2 logs anzeigen"
    read -p "Wähle (a-c): " pm2_option
    
    case $pm2_option in
      a)
        echo -e "${GREEN}Starte ProxyClaude mit PM2...${NC}"
        ./start-production.sh
        ;;
      b)
        echo -e "${YELLOW}Stoppe ProxyClaude...${NC}"
        pm2 stop proxyclaude
        ;;
      c)
        echo -e "${BLUE}Zeige Logs (Ctrl+C zum Beenden)...${NC}"
        pm2 logs proxyclaude
        ;;
      *)
        echo -e "${YELLOW}Ungültige Option!${NC}"
        ;;
    esac
    ;;
  4)
    echo -e "${GREEN}Generiere Einladungslinks...${NC}"
    ./scripts/generate-invites.sh
    ;;
  5)
    # Admin Übersicht - In richtigem System würde man hier ein echtes Admin-Panel zeigen
    echo -e "${GREEN}Öffne Admin-Übersicht im Browser...${NC}"
    
    # Admin-Token aus .env.local extrahieren
    if [ -f ".env.local" ]; then
      ADMIN_TOKEN=$(grep ADMIN_TOKEN .env.local | cut -d '=' -f2)
      echo -e "${YELLOW}Admin Token: ${ADMIN_TOKEN}${NC}"
      echo -e "${YELLOW}Admin URL: http://localhost:4000/admin${NC}"
    else
      echo -e "${YELLOW}Keine .env.local gefunden. Bitte Setup ausführen.${NC}"
    fi
    ;;
  6)
    echo -e "${GREEN}ProxyClaude status:${NC}"
    if pm2 list | grep -q "proxyclaude"; then
      pm2 info proxyclaude
    else
      echo -e "${YELLOW}ProxyClaude läuft nicht mit PM2.${NC}"
      if pgrep -f "node.*proxyclaude" > /dev/null; then
        echo -e "${GREEN}ProxyClaude läuft als Node-Prozess.${NC}"
        ps aux | grep "node.*proxyclaude" | grep -v grep
      else
        echo -e "${YELLOW}ProxyClaude ist nicht aktiv.${NC}"
      fi
    fi
    ;;
  q)
    echo -e "${BLUE}Beende...${NC}"
    exit 0
    ;;
  *)
    echo -e "${YELLOW}Ungültige Option!${NC}"
    ;;
esac