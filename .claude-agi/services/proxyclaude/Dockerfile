FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy app source
COPY dist/ ./dist/
COPY .env.example ./

# Create necessary directories
RUN mkdir -p logs data invites

# Set correct permissions
RUN chmod -R 750 logs data invites

# Expose port
EXPOSE 4000

# Start in production mode
CMD ["node", "dist/index.js"]