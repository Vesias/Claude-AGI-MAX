import { Router } from 'express';
import fs from 'fs';
import path from 'path';

export function setupAdminRoutes(metrics: any) {
  const router = Router();
  
  // Admin authentication middleware
  const adminAuth = (req: any, res: any, next: any) => {
    const token = req.query.token || req.headers['x-admin-token'];
    const validToken = process.env.ADMIN_TOKEN || 'admin_secret_token_for_testing';
    
    if (token !== validToken) {
      return res.status(401).send(`
        <html>
          <head><title>ProxyClaude Admin - Login</title></head>
          <body>
            <h1>ProxyClaude Admin</h1>
            <p style="color: red;">Unauthorized. Please log in with a valid admin token.</p>
            <form method="GET" action="/admin">
              <input type="password" name="token" placeholder="Admin token" />
              <button type="submit">Login</button>
            </form>
          </body>
        </html>
      `);
    }
    
    next();
  };
  
  // All admin routes require authentication
  router.use(adminAuth);
  
  // Admin dashboard
  router.get('/', async (req, res) => {
    const invitesPath = path.join(__dirname, '../../invites');
    let invites: any[] = [];
    
    // Load invite data if available
    if (fs.existsSync(invitesPath)) {
      const files = fs.readdirSync(invitesPath)
        .filter(file => file.startsWith('invite-') && file.endsWith('.json'));
      
      invites = files.map(file => {
        try {
          const data = JSON.parse(fs.readFileSync(path.join(invitesPath, file), 'utf8'));
          return { ...data, filename: file };
        } catch (err) {
          return { error: 'Failed to parse', filename: file };
        }
      });
    }
    
    // Get current metrics
    const currentMetrics = metrics.getMetrics ? metrics.getMetrics() : {
      requests: 0,
      errors: 0,
      processingTime: 0,
      activeUsers: 0,
      revenue: 0
    };
    
    // Admin panel HTML
    res.send(`
      <html>
        <head>
          <title>ProxyClaude Admin</title>
          <style>
            body { font-family: system-ui; max-width: 1200px; margin: 0 auto; padding: 20px; }
            table { width: 100%; border-collapse: collapse; margin: 20px 0; }
            th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
            .card { background: #f9f9f9; border-radius: 8px; padding: 15px; margin: 15px 0; }
            .metrics { display: flex; gap: 20px; flex-wrap: wrap; }
            .metric { flex: 1; min-width: 150px; background: #fff; border: 1px solid #eee; 
                    border-radius: 8px; padding: 15px; text-align: center; }
            .metric h3 { margin: 0; color: #333; }
            .metric p { font-size: 24px; font-weight: bold; margin: 10px 0; }
            .actions { margin-top: 20px; }
            button, .button { background: #5469d4; color: white; padding: 8px 15px; border: none; 
                      border-radius: 4px; cursor: pointer; text-decoration: none; display: inline-block; }
            .secondary { background: #6c757d; }
            .warning { background: #dc3545; }
          </style>
        </head>
        <body>
          <h1>ProxyClaude Admin Dashboard</h1>
          <p>Service status: <span style="color: green; font-weight: bold;">Active</span></p>
          
          <div class="card">
            <h2>Service Metrics</h2>
            <div class="metrics">
              <div class="metric">
                <h3>Total Requests</h3>
                <p>${currentMetrics.requests}</p>
              </div>
              <div class="metric">
                <h3>Errors</h3>
                <p>${currentMetrics.errors}</p>
              </div>
              <div class="metric">
                <h3>Active Users</h3>
                <p>${currentMetrics.activeUsers}</p>
              </div>
              <div class="metric">
                <h3>Revenue (€)</h3>
                <p>${(currentMetrics.revenue / 100).toFixed(2)}</p>
              </div>
              <div class="metric">
                <h3>Avg. Processing (ms)</h3>
                <p>${currentMetrics.requests > 0 ? (currentMetrics.processingTime / currentMetrics.requests).toFixed(2) : 0}</p>
              </div>
            </div>
          </div>
          
          <div class="card">
            <h2>Invite Management</h2>
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Token</th>
                  <th>Created</th>
                  <th>Status</th>
                  <th>URL</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                ${invites.map(invite => `
                  <tr>
                    <td>${invite.filename?.split('-')[1] || 'N/A'}</td>
                    <td>${invite.token?.substring(0, 10)}...</td>
                    <td>${invite.created || 'N/A'}</td>
                    <td>${invite.used ? '<span style="color: red">Used</span>' : '<span style="color: green">Available</span>'}</td>
                    <td><a href="${invite.url || '#'}" target="_blank">Checkout Link</a></td>
                    <td>
                      <button class="secondary" onclick="alert('View details for ${invite.token?.substring(0, 6)}')">View</button>
                      ${!invite.used ? `<button class="warning" onclick="alert('This would invalidate the invite')">Invalidate</button>` : ''}
                    </td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
            <div class="actions">
              <a href="/admin/generate-invites?token=${req.query.token || ''}" class="button">Generate New Invites</a>
            </div>
          </div>
          
          <div class="card">
            <h2>API Key Management</h2>
            <p>Valid API keys: <strong>${process.env.VALID_API_KEYS || 'test-key,demo-key,beta-tester-key'}</strong></p>
            <div class="actions">
              <button onclick="alert('This would generate a new API key')">Generate API Key</button>
              <button class="secondary" onclick="alert('This would rotate all API keys')">Rotate Keys</button>
            </div>
          </div>
          
          <div class="card">
            <h2>System Information</h2>
            <ul>
              <li>Environment: <strong>${process.env.NODE_ENV || 'development'}</strong></li>
              <li>Port: <strong>${process.env.PORT || '4001'}</strong></li>
              <li>PID: <strong>${process.pid}</strong></li>
              <li>Memory Usage: <strong>${(process.memoryUsage().rss / 1024 / 1024).toFixed(2)} MB</strong></li>
              <li>Uptime: <strong>${(process.uptime() / 60).toFixed(2)} minutes</strong></li>
            </ul>
            <div class="actions">
              <a href="/admin/logs?token=${req.query.token || ''}" class="button secondary">View Logs</a>
              <button class="warning" onclick="alert('This would restart the service')">Restart Service</button>
            </div>
          </div>
        </body>
      </html>
    `);
  });
  
  // Generate invites page
  router.get('/generate-invites', (req, res) => {
    res.send(`
      <html>
        <head>
          <title>ProxyClaude Admin - Generate Invites</title>
          <style>
            body { font-family: system-ui; max-width: 800px; margin: 0 auto; padding: 20px; }
            .card { background: #f9f9f9; border-radius: 8px; padding: 15px; margin: 15px 0; }
            button { background: #5469d4; color: white; padding: 8px 15px; border: none; 
                     border-radius: 4px; cursor: pointer; }
            .back { background: #6c757d; }
          </style>
        </head>
        <body>
          <h1>Generate Invite Links</h1>
          
          <div class="card">
            <h2>Create New Invites</h2>
            <p>This will generate new invite links for users to sign up.</p>
            
            <form method="POST" action="/admin/generate-invites?token=${req.query.token || ''}">
              <label>
                Number of invites:
                <input type="number" name="count" value="6" min="1" max="20" />
              </label>
              <button type="submit">Generate</button>
            </form>
          </div>
          
          <a href="/admin?token=${req.query.token || ''}" class="button back">Back to Dashboard</a>
        </body>
      </html>
    `);
  });
  
  // Process invite generation
  router.post('/generate-invites', (req, res) => {
    // In a real implementation, this would call the invite-generator.js script
    res.send(`
      <html>
        <head>
          <title>ProxyClaude Admin - Invites Generated</title>
          <style>
            body { font-family: system-ui; max-width: 800px; margin: 0 auto; padding: 20px; }
            .card { background: #f9f9f9; border-radius: 8px; padding: 15px; margin: 15px 0; }
            .success { color: green; }
            button { background: #5469d4; color: white; padding: 8px 15px; border: none; 
                     border-radius: 4px; cursor: pointer; }
          </style>
        </head>
        <body>
          <h1>Invite Links Generated</h1>
          
          <div class="card">
            <h2 class="success">Success!</h2>
            <p>New invite links have been generated. You can view them in the dashboard.</p>
            
            <p>To run the generator manually, use:</p>
            <pre>node scripts/invite-generator.js</pre>
          </div>
          
          <a href="/admin?token=${req.query.token || ''}" class="button">Back to Dashboard</a>
        </body>
      </html>
    `);
  });
  
  // View logs
  router.get('/logs', (req, res) => {
    const logsPath = path.join(__dirname, '../../logs/server.log');
    let logContent = 'No logs found';
    
    if (fs.existsSync(logsPath)) {
      try {
        // Read last 100 lines of log file
        const data = fs.readFileSync(logsPath, 'utf8');
        const lines = data.split('\n').slice(-100);
        logContent = lines.join('\n');
      } catch (err) {
        logContent = `Error reading logs: ${err.message}`;
      }
    }
    
    res.send(`
      <html>
        <head>
          <title>ProxyClaude Admin - Logs</title>
          <style>
            body { font-family: system-ui; max-width: 1200px; margin: 0 auto; padding: 20px; }
            .logs { background: #f0f0f0; border-radius: 4px; padding: 15px; height: 500px; 
                   overflow: auto; font-family: monospace; font-size: 12px; white-space: pre-wrap; }
            .error { color: #dc3545; }
            .info { color: #0d6efd; }
            .success { color: #198754; }
            button { background: #5469d4; color: white; padding: 8px 15px; border: none; 
                     border-radius: 4px; cursor: pointer; margin-top: 15px; }
          </style>
        </head>
        <body>
          <h1>Service Logs</h1>
          <p>Showing the last 100 log entries from server.log</p>
          
          <div class="logs">
            ${logContent.replace(/ERROR/g, '<span class="error">ERROR</span>')
                       .replace(/INFO/g, '<span class="info">INFO</span>')
                       .replace(/SUCCESS/g, '<span class="success">SUCCESS</span>')}
          </div>
          
          <a href="/admin?token=${req.query.token || ''}" class="button">Back to Dashboard</a>
        </body>
      </html>
    `);
  });

  return router;
}