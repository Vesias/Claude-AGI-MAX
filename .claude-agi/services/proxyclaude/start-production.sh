#!/bin/bash
# ProxyClaude Production Starter
# Startet den ProxyClaude Service im Produktionsmodus mit PM2

# Ensure we're in the right directory
cd "$(dirname "$0")"

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
  echo "PM2 nicht gefunden. Installiere PM2..."
  npm install -g pm2
fi

# Ensure Redis is running
if ! pgrep redis-server > /dev/null; then
  echo "⚠️ Redis nicht erkannt. Starte Redis in Docker..."
  docker run --name proxyclaude-redis -p 6379:6379 -d redis
fi

# Create ecosystem.config.js for PM2
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'proxyclaude',
    script: 'dist/index.js',
    env: {
      NODE_ENV: 'production'
    },
    watch: false,
    max_memory_restart: '300M',
    log_date_format: 'YYYY-MM-DD HH:mm:ss',
    error_file: 'logs/error.log',
    out_file: 'logs/out.log',
    merge_logs: true,
    instances: 1,
    exec_mode: 'fork'
  }]
};
EOF

# Create logs directory
mkdir -p logs

# Build the project
echo "🛠️ Building ProxyClaude..."
npm run build

# Start with PM2
echo "🚀 Starting ProxyClaude in PRODUCTION mode with PM2..."
pm2 start ecosystem.config.js

# Display status
pm2 status

echo ""
echo "✅ ProxyClaude läuft jetzt im Produktionsmodus mit PM2"
echo "📊 Logs: pm2 logs proxyclaude"
echo "🛑 Stoppen: pm2 stop proxyclaude"
echo "🚀 API erreichbar unter: http://localhost:4000"
echo ""
echo "Generiere Einladungslinks mit: ./scripts/generate-invites.sh"