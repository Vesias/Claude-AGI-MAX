#!/bin/bash
# ProxyClaude Launch Script

# Ensure we're in the right directory
cd "$(dirname "$0")"

# Check if Redis is running
if ! pgrep redis-server > /dev/null; then
  echo "⚠️ Redis not detected. Starting Redis in Docker..."
  docker run --name proxyclaude-redis -p 6379:6379 -d redis
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
fi

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
  echo "⚠️ .env.local not found. Creating from example..."
  cp .env.example .env.local
  echo "⚙️ Please edit .env.local with your real API keys before proceeding."
  exit 1
fi

# Build TypeScript
echo "🛠️ Building ProxyClaude..."
npm run build

# Start server in production mode
echo "🚀 Starting ProxyClaude in PRODUCTION mode..."
NODE_ENV=production npm start