import express from 'express';
import dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';
import { setupPaymentRoutes } from './routes/payment';
import { setupApiRoutes } from './routes/api';
import { setupAdminRoutes } from './routes/admin';
import { setupMonitoring } from './services/monitoring';
import { setupQueue } from './services/queue';
import logger from './services/logger';

// Load environment variables from .env.local
dotenv.config({ path: path.resolve(__dirname, '../.env.local') });

// Create Express app
const app = express();
const PORT = process.env.PORT || 4001;

// Middleware
app.use(express.json());
app.use(logger.requestLogger());

// Setup services
const queue = setupQueue();
const metrics = setupMonitoring('proxyclaude');

// Create necessary directories
const logsDir = path.join(__dirname, '../logs');
const invitesDir = path.join(__dirname, '../invites');
const dataDir = path.join(__dirname, '../data');

[logsDir, invitesDir, dataDir].forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
    console.log(`Created directory: ${dir}`);
  }
});

// Setup routes
app.use('/payment', setupPaymentRoutes());
app.use('/api', setupApiRoutes(queue));
app.use('/admin', setupAdminRoutes(metrics));

// Simple health check
app.get('/', (req, res) => {
  res.send(`
    <html>
      <head><title>ProxyClaude</title></head>
      <body>
        <h1>ProxyClaude API Service</h1>
        <p>Status: Active</p>
        <p>Part of CLAUDE-AGI ecosystem</p>
      </body>
    </html>
  `);
});

// Write PID file for easier management
const pidFile = path.join(__dirname, '../.pid');
fs.writeFileSync(pidFile, process.pid.toString());

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception: %s', error.stack || error.message);
  // In production, you might want to exit the process here or use a process manager like PM2
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Promise Rejection: %s', reason);
});

// Graceful shutdown
const gracefulShutdown = () => {
  logger.info('Received shutdown signal, closing server...');
  // Close server and release resources
  process.exit(0);
};

// Listen for termination signals
process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

// Start server
app.listen(PORT, () => {
  logger.success(`ProxyClaude service running on port ${PORT}`);
  logger.info(`API access through http://localhost:${PORT}/api`);
  logger.info(`Payment portal at http://localhost:${PORT}/payment/checkout`);
  logger.info(`Admin dashboard at http://localhost:${PORT}/admin`);
  logger.info(`PID ${process.pid} saved to ${pidFile}`);
});

// Export for tests
export default app;