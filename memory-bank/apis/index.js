/**
 * Memory Bank API Index
 * 
 * This file exports all Memory Bank APIs for easy consumption by other projects.
 * 
 * Version: 2.0.0
 */

const KnowledgeGraphAPI = require('./knowledgeGraphAPI');
const SequentialThinkingAPI = require('./sequentialThinkingAPI');
const path = require('path');
const fs = require('fs');

/**
 * Get the memory bank path for a given project
 * @param {string} projectPath - Path to the project
 * @returns {string} Path to the memory bank
 */
function getMemoryBankPath(projectPath) {
  return path.join(projectPath, 'memory-bank');
}

/**
 * Initialize all memory bank APIs for a project
 * @param {string} projectPath - Path to the project
 * @returns {Object} Object containing initialized APIs
 */
function initMemoryBank(projectPath) {
  // Ensure memory bank exists
  const memoryBankPath = getMemoryBankPath(projectPath);
  if (!fs.existsSync(memoryBankPath)) {
    fs.mkdirSync(memoryBankPath, { recursive: true });
  }
  
  // Initialize APIs
  const knowledgeGraph = new KnowledgeGraphAPI(projectPath);
  const sequentialThinking = new SequentialThinkingAPI(projectPath);
  
  return {
    knowledgeGraph,
    sequentialThinking,
    memoryBankPath
  };
}

/**
 * Create a new memory bank project
 * @param {string} projectPath - Path to the project
 * @param {Object} options - Options for the new project
 * @returns {boolean} Success of the operation
 */
function createMemoryBank(projectPath, options = {}) {
  try {
    // Get template path
    const templatePath = path.join(__dirname, '..', 'templates');
    
    // Create memory bank directory
    const memoryBankPath = getMemoryBankPath(projectPath);
    if (!fs.existsSync(memoryBankPath)) {
      fs.mkdirSync(memoryBankPath, { recursive: true });
    }
    
    // Copy template files
    const templateFiles = fs.readdirSync(templatePath);
    
    for (const file of templateFiles) {
      const sourcePath = path.join(templatePath, file);
      const destPath = path.join(memoryBankPath, file);
      
      if (!fs.existsSync(destPath)) {
        fs.copyFileSync(sourcePath, destPath);
      }
    }
    
    // Customize templates if needed
    if (options.projectName) {
      // Update project brief
      const briefPath = path.join(memoryBankPath, 'projectbrief.md');
      if (fs.existsSync(briefPath)) {
        let content = fs.readFileSync(briefPath, 'utf8');
        content = content.replace(/\[Projektname\]/g, options.projectName);
        fs.writeFileSync(briefPath, content);
      }
      
      // Update knowledge graph
      const graphPath = path.join(memoryBankPath, 'knowledgeGraph.json');
      if (fs.existsSync(graphPath)) {
        const graph = JSON.parse(fs.readFileSync(graphPath, 'utf8'));
        
        if (graph.metadata) {
          graph.metadata.description = `Knowledge Graph für ${options.projectName}`;
          graph.metadata.created = new Date().toISOString();
          graph.metadata.updated = new Date().toISOString();
        }
        
        fs.writeFileSync(graphPath, JSON.stringify(graph, null, 2));
      }
    }
    
    // Initialize APIs
    const apis = initMemoryBank(projectPath);
    
    return true;
  } catch (error) {
    console.error(`Error creating memory bank: ${error.message}`);
    return false;
  }
}

/**
 * Update a memory bank file
 * @param {string} projectPath - Path to the project
 * @param {string} fileName - Name of the file to update
 * @param {string} content - New content for the file
 * @returns {boolean} Success of the operation
 */
function updateMemoryBankFile(projectPath, fileName, content) {
  try {
    const memoryBankPath = getMemoryBankPath(projectPath);
    const filePath = path.join(memoryBankPath, fileName);
    
    fs.writeFileSync(filePath, content);
    
    return true;
  } catch (error) {
    console.error(`Error updating memory bank file: ${error.message}`);
    return false;
  }
}

/**
 * Read a memory bank file
 * @param {string} projectPath - Path to the project
 * @param {string} fileName - Name of the file to read
 * @returns {string|null} File content or null if error
 */
function readMemoryBankFile(projectPath, fileName) {
  try {
    const memoryBankPath = getMemoryBankPath(projectPath);
    const filePath = path.join(memoryBankPath, fileName);
    
    if (fs.existsSync(filePath)) {
      return fs.readFileSync(filePath, 'utf8');
    }
    
    return null;
  } catch (error) {
    console.error(`Error reading memory bank file: ${error.message}`);
    return null;
  }
}

/**
 * Update active context with a timestamp
 * @param {string} projectPath - Path to the project
 * @returns {boolean} Success of the operation
 */
function updateActiveContextTimestamp(projectPath) {
  try {
    const memoryBankPath = getMemoryBankPath(projectPath);
    const filePath = path.join(memoryBankPath, 'activeContext.md');
    
    if (fs.existsSync(filePath)) {
      let content = fs.readFileSync(filePath, 'utf8');
      const timestamp = new Date().toISOString().replace('T', ' ').replace(/\.\d+Z$/, '');
      const lastUpdatedSection = `\n\n## Last Updated\n\n${timestamp}\n`;
      
      // Check if Last Updated section exists
      if (content.includes('## Last Updated')) {
        // Replace existing section
        content = content.replace(/## Last Updated[\s\S]*?(?=\n## |$)/, lastUpdatedSection);
      } else {
        // Add new section
        content += lastUpdatedSection;
      }
      
      fs.writeFileSync(filePath, content);
      return true;
    }
    
    return false;
  } catch (error) {
    console.error(`Error updating active context timestamp: ${error.message}`);
    return false;
  }
}

// Export APIs and utility functions
module.exports = {
  KnowledgeGraphAPI,
  SequentialThinkingAPI,
  initMemoryBank,
  createMemoryBank,
  updateMemoryBankFile,
  readMemoryBankFile,
  updateActiveContextTimestamp,
  getMemoryBankPath
};