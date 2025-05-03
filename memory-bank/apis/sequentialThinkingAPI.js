/**
 * Sequential Thinking API for CLAUDE AGI Memory Bank
 * 
 * This API provides an interface for structured problem-solving with sequential thinking.
 * It integrates with the Sequential Thinking MCP tool and persists reasoning steps in the memory bank.
 * 
 * Version: 1.0.0
 */

const fs = require('fs');
const path = require('path');
const axios = require('axios');

class SequentialThinkingAPI {
  constructor(projectPath, config = {}) {
    this.projectPath = projectPath;
    this.configPath = path.join(projectPath, 'memory-bank', 'sequentialThinking.config');
    this.historyPath = path.join(projectPath, 'memory-bank', 'sequentialThinking.history.json');
    
    // Default config
    this.config = {
      mcpEndpoint: 'http://localhost:3000/api/sequential-thinking',
      maxSteps: 5,
      storeHistory: true,
      appendToActiveContext: true,
      ...config
    };
    
    this.loadConfig();
    this.history = this.loadHistory();
  }

  /**
   * Load configuration from disk
   */
  loadConfig() {
    try {
      if (fs.existsSync(this.configPath)) {
        const data = fs.readFileSync(this.configPath, 'utf8');
        const loadedConfig = JSON.parse(data);
        this.config = { ...this.config, ...loadedConfig };
      } else {
        // Save default config
        this.saveConfig();
      }
    } catch (error) {
      console.error(`Error loading sequential thinking config: ${error.message}`);
    }
  }

  /**
   * Save configuration to disk
   */
  saveConfig() {
    try {
      const dir = path.dirname(this.configPath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      
      fs.writeFileSync(this.configPath, JSON.stringify(this.config, null, 2), 'utf8');
      return true;
    } catch (error) {
      console.error(`Error saving sequential thinking config: ${error.message}`);
      return false;
    }
  }

  /**
   * Load thinking history from disk
   */
  loadHistory() {
    try {
      if (fs.existsSync(this.historyPath)) {
        const data = fs.readFileSync(this.historyPath, 'utf8');
        return JSON.parse(data);
      }
      
      return [];
    } catch (error) {
      console.error(`Error loading sequential thinking history: ${error.message}`);
      return [];
    }
  }

  /**
   * Save thinking history to disk
   */
  saveHistory() {
    if (!this.config.storeHistory) return false;
    
    try {
      const dir = path.dirname(this.historyPath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      
      fs.writeFileSync(this.historyPath, JSON.stringify(this.history, null, 2), 'utf8');
      return true;
    } catch (error) {
      console.error(`Error saving sequential thinking history: ${error.message}`);
      return false;
    }
  }

  /**
   * Add a thinking session to history
   * @param {Object} session - The thinking session to add
   */
  addToHistory(session) {
    if (!this.config.storeHistory) return;
    
    this.history.push(session);
    while (this.history.length > 50) { // Keep only the last 50 sessions
      this.history.shift();
    }
    
    this.saveHistory();
  }

  /**
   * Execute a sequential thinking process
   * @param {string} problem - The problem to solve
   * @param {Object} options - Additional options
   * @returns {Object} The thinking session result
   */
  async think(problem, options = {}) {
    const sessionOptions = {
      steps: this.config.maxSteps,
      appendToActiveContext: this.config.appendToActiveContext,
      ...options
    };
    
    // Initialize session
    const session = {
      id: `thinking_${Date.now()}`,
      problem,
      options: sessionOptions,
      steps: [],
      conclusion: null,
      created: new Date().toISOString()
    };
    
    try {
      // Use MCP Sequential Thinking if available
      if (this.config.mcpEndpoint) {
        const response = await this.callMcpService(problem, sessionOptions);
        
        if (response && response.data) {
          const { steps, conclusion } = response.data;
          session.steps = steps;
          session.conclusion = conclusion;
        }
      } else {
        // Fallback to structured format without MCP
        session.steps = [
          {
            id: 1,
            title: 'Problem Analysis',
            content: `Analyzing the problem: ${problem}`
          },
          {
            id: 2,
            title: 'Potential Approaches',
            content: 'Listing potential approaches to solving this problem.'
          }
        ];
        session.conclusion = 'No MCP service available for sequential thinking. This is a placeholder conclusion.';
      }
      
      // Update session
      session.completed = new Date().toISOString();
      
      // Store in history
      this.addToHistory(session);
      
      // Append to active context if configured
      if (sessionOptions.appendToActiveContext) {
        this.appendToActiveContext(session);
      }
      
      return session;
    } catch (error) {
      console.error(`Error in sequential thinking: ${error.message}`);
      
      // Create error session
      session.error = error.message;
      session.completed = new Date().toISOString();
      this.addToHistory(session);
      
      throw error;
    }
  }

  /**
   * Call the MCP Sequential Thinking service
   * @param {string} problem - The problem to solve
   * @param {Object} options - Additional options
   * @returns {Object} The service response
   */
  async callMcpService(problem, options) {
    try {
      const response = await axios.post(this.config.mcpEndpoint, {
        problem,
        options
      });
      
      return response;
    } catch (error) {
      console.error(`Error calling Sequential Thinking MCP: ${error.message}`);
      throw error;
    }
  }

  /**
   * Append thinking result to active context
   * @param {Object} session - The thinking session
   */
  appendToActiveContext(session) {
    const activeContextPath = path.join(this.projectPath, 'memory-bank', 'activeContext.md');
    
    try {
      let content = '';
      if (fs.existsSync(activeContextPath)) {
        content = fs.readFileSync(activeContextPath, 'utf8');
      }
      
      // Create markdown for the thinking session
      let thinkingMd = `\n\n## Sequential Thinking: ${session.problem}\n`;
      thinkingMd += `*Generated at: ${new Date(session.created).toLocaleString()}*\n\n`;
      
      // Add steps
      session.steps.forEach(step => {
        thinkingMd += `### Step ${step.id}: ${step.title}\n`;
        thinkingMd += `${step.content}\n\n`;
      });
      
      // Add conclusion
      thinkingMd += `### Conclusion\n`;
      thinkingMd += `${session.conclusion}\n`;
      
      // Write back to file
      fs.writeFileSync(activeContextPath, content + thinkingMd, 'utf8');
      
      return true;
    } catch (error) {
      console.error(`Error appending to active context: ${error.message}`);
      return false;
    }
  }

  /**
   * Get thinking history for a specific problem or all history
   * @param {string} problemSearch - Optional problem text to search for
   * @returns {Array} Matching thinking sessions
   */
  getHistory(problemSearch) {
    if (!problemSearch) {
      return this.history;
    }
    
    return this.history.filter(session => 
      session.problem.toLowerCase().includes(problemSearch.toLowerCase())
    );
  }

  /**
   * Create a new sequential thinking configuration
   * @param {Object} config - Configuration options
   * @returns {boolean} Success of the operation
   */
  updateConfig(config) {
    this.config = {
      ...this.config,
      ...config
    };
    
    return this.saveConfig();
  }
}

module.exports = SequentialThinkingAPI;