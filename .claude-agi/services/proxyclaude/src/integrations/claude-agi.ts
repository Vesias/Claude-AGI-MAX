/**
 * CLAUDE-AGI Integration Module
 * 
 * Verbindet ProxyClaude mit dem CLAUDE-AGI Ökosystem.
 * Diese Integration ist optional - ProxyClaude kann auch standalone laufen.
 */

import path from 'path';
import fs from 'fs';

// Pfad zur CLAUDE-AGI Memory Bank
const MEMORY_BANK_PATH = path.resolve(__dirname, '../../../../memory-bank');
const PROXY_METRICS_PATH = path.join(MEMORY_BANK_PATH, 'proxyclaude-metrics.json');

/**
 * Speichert ProxyClaude Metriken in der CLAUDE-AGI Memory Bank
 */
export async function trackMetricsInMemoryBank(metrics: any) {
  // Prüfen ob CLAUDE-AGI Memory Bank existiert
  if (!fs.existsSync(MEMORY_BANK_PATH)) {
    console.log('CLAUDE-AGI Memory Bank nicht gefunden, überspringe Integration');
    return false;
  }

  try {
    // Existierende Metriken laden oder neues Objekt anlegen
    let existingMetrics = {};
    if (fs.existsSync(PROXY_METRICS_PATH)) {
      const data = fs.readFileSync(PROXY_METRICS_PATH, 'utf8');
      existingMetrics = JSON.parse(data);
    }

    // Aktualisieren mit neuen Metriken
    const updatedMetrics = {
      ...existingMetrics,
      lastUpdated: new Date().toISOString(),
      metrics: {
        ...metrics,
        lastSnapshot: {
          timestamp: new Date().toISOString(),
          activeUsers: metrics.activeUsers,
          requests: metrics.requests,
          revenue: metrics.revenue
        }
      }
    };

    // In Memory Bank speichern
    fs.writeFileSync(PROXY_METRICS_PATH, JSON.stringify(updatedMetrics, null, 2));
    return true;
  } catch (error) {
    console.error('Fehler beim Speichern der Metriken in Memory Bank:', error);
    return false;
  }
}

/**
 * Registriert ProxyClaude als MCP-Tool bei CLAUDE-AGI
 */
export function registerAsMcpTool() {
  const MCP_CONFIG_PATH = path.resolve(__dirname, '../../../../.config/claude_desktop_config.json');
  
  // Prüfen ob MCP-Config existiert
  if (!fs.existsSync(MCP_CONFIG_PATH)) {
    console.log('CLAUDE-AGI MCP Config nicht gefunden, überspringe Integration');
    return false;
  }

  try {
    // MCP-Config laden
    const mcpConfig = JSON.parse(fs.readFileSync(MCP_CONFIG_PATH, 'utf8'));
    
    // Prüfen ob ProxyClaude bereits registriert ist
    const hasProxyClaude = mcpConfig.tools?.some(tool => tool.name === 'proxyclaude');
    
    if (!hasProxyClaude && mcpConfig.tools) {
      // ProxyClaude als Tool hinzufügen
      mcpConfig.tools.push({
        name: 'proxyclaude',
        description: 'ProxyClaude API access management',
        enabled: true,
        path: path.resolve(__dirname, '../..')
      });
      
      // Config zurückschreiben
      fs.writeFileSync(MCP_CONFIG_PATH, JSON.stringify(mcpConfig, null, 2));
      console.log('ProxyClaude erfolgreich als MCP-Tool registriert');
      return true;
    }
    
    return hasProxyClaude; // true wenn bereits registriert
  } catch (error) {
    console.error('Fehler beim Registrieren als MCP-Tool:', error);
    return false;
  }
}

/**
 * Initialisiert die CLAUDE-AGI Integration
 */
export function initClaudeAgiIntegration() {
  console.log('Initialisiere CLAUDE-AGI Integration...');
  
  // Memory Bank Integration
  const memoryBankConnected = trackMetricsInMemoryBank({
    activeUsers: 0,
    requests: 0,
    revenue: 0
  });
  
  // MCP-Tool Registration
  const mcpToolRegistered = registerAsMcpTool();
  
  return {
    memoryBankConnected,
    mcpToolRegistered,
    
    // Methoden für regelmäßige Updates
    updateMetrics: trackMetricsInMemoryBank
  };
}