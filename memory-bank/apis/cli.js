#!/usr/bin/env node

/**
 * Memory Bank CLI
 * 
 * A command-line tool for managing and interacting with the CLAUDE AGI Memory Bank.
 * 
 * Usage:
 *   node cli.js <command> [options]
 * 
 * Commands:
 *   update              Update memory bank files and knowledge graph
 *   extract-knowledge   Extract knowledge from memory bank into knowledge graph
 *   think               Apply sequential thinking to a problem
 *   visualize-graph     Generate visualization of the knowledge graph
 */

const fs = require('fs');
const path = require('path');
const KnowledgeGraphAPI = require('./knowledgeGraphAPI');
const SequentialThinkingAPI = require('./sequentialThinkingAPI');

// Parse command line arguments
const args = process.argv.slice(2);
const command = args[0];
const options = args.slice(1);

// Get current date/time formatted
function getFormattedDateTime() {
  const now = new Date();
  return now.toISOString().replace(/T/, ' ').replace(/\..+/, '');
}

// Handle update command
async function handleUpdate(projectPath) {
  try {
    console.log(`Updating memory bank for: ${projectPath}`);
    console.log(`[${getFormattedDateTime()}] Starting update...`);
    
    // Check if project path exists
    if (!fs.existsSync(projectPath)) {
      console.error(`Error: Project path ${projectPath} does not exist.`);
      process.exit(1);
    }
    
    // Memory bank path
    const memoryBankPath = path.join(projectPath, 'memory-bank');
    if (!fs.existsSync(memoryBankPath)) {
      console.error(`Error: Memory bank not found at ${memoryBankPath}`);
      process.exit(1);
    }
    
    // Update active context timestamp
    const activeContextPath = path.join(memoryBankPath, 'activeContext.md');
    if (fs.existsSync(activeContextPath)) {
      let content = fs.readFileSync(activeContextPath, 'utf8');
      const lastUpdatedSection = `\n\n## Last Updated\n\n${getFormattedDateTime()}\n`;
      
      // Check if Last Updated section exists
      if (content.includes('## Last Updated')) {
        // Replace existing section
        content = content.replace(/## Last Updated[\s\S]*?(?=\n## |$)/, lastUpdatedSection);
      } else {
        // Add new section
        content += lastUpdatedSection;
      }
      
      fs.writeFileSync(activeContextPath, content);
      console.log(`Updated activeContext.md with timestamp`);
    }
    
    // Update knowledge graph
    const knowledgeGraph = new KnowledgeGraphAPI(projectPath);
    const updateSummary = knowledgeGraph.updateFromMemoryBank();
    
    console.log(`Knowledge graph update complete:`);
    console.log(`- Files processed: ${updateSummary.filesProcessed}`);
    console.log(`- Concepts added: ${updateSummary.conceptsAdded}`);
    console.log(`- Relationships added: ${updateSummary.relationshipsAdded}`);
    
    console.log(`[${getFormattedDateTime()}] Memory bank update completed.`);
    return true;
  } catch (error) {
    console.error(`Error updating memory bank: ${error.message}`);
    return false;
  }
}

// Handle extract-knowledge command
async function handleExtractKnowledge(projectPath) {
  try {
    console.log(`Extracting knowledge from: ${projectPath}`);
    console.log(`[${getFormattedDateTime()}] Starting knowledge extraction...`);
    
    // Check if project path exists
    if (!fs.existsSync(projectPath)) {
      console.error(`Error: Project path ${projectPath} does not exist.`);
      process.exit(1);
    }
    
    // Initialize knowledge graph
    const knowledgeGraph = new KnowledgeGraphAPI(projectPath);
    
    // Process all markdown files in project
    const processDirectory = (dirPath, depth = 0) => {
      if (depth > 3) return; // Limit recursion depth
      
      const files = fs.readdirSync(dirPath);
      let totalConcepts = 0;
      
      for (const file of files) {
        const filePath = path.join(dirPath, file);
        const stat = fs.statSync(filePath);
        
        if (stat.isDirectory() && !file.startsWith('.') && file !== 'node_modules') {
          processDirectory(filePath, depth + 1);
        } else if (file.endsWith('.md')) {
          try {
            const content = fs.readFileSync(filePath, 'utf8');
            const fileType = path.basename(file, '.md');
            const conceptType = fileType.includes('tech') ? 'technology' : 
                              fileType.includes('system') ? 'pattern' :
                              fileType.includes('product') ? 'feature' : 'concept';
            
            const extractedConcepts = knowledgeGraph.extractConceptsFromText(content, conceptType);
            totalConcepts += extractedConcepts.length;
            
            console.log(`Processed ${file}: found ${extractedConcepts.length} concepts`);
          } catch (err) {
            console.error(`Error processing ${filePath}: ${err.message}`);
          }
        }
      }
      
      return totalConcepts;
    };
    
    const totalExtracted = processDirectory(projectPath);
    console.log(`Total concepts extracted: ${totalExtracted}`);
    
    console.log(`[${getFormattedDateTime()}] Knowledge extraction completed.`);
    return true;
  } catch (error) {
    console.error(`Error extracting knowledge: ${error.message}`);
    return false;
  }
}

// Handle think command
async function handleThink(problem, modelType = 'problem-solving') {
  try {
    console.log(`Applying sequential thinking to problem: "${problem}"`);
    console.log(`Using thinking model: ${modelType}`);
    console.log(`[${getFormattedDateTime()}] Starting thinking process...`);
    
    // Get current directory as default project path
    const projectPath = process.cwd();
    
    // Initialize sequential thinking
    const thinking = new SequentialThinkingAPI(projectPath);
    
    // Apply thinking
    const session = await thinking.think(problem, { 
      model: modelType,
      appendToActiveContext: true
    });
    
    console.log('\n=== Thinking Process ===\n');
    
    // Print steps
    for (const step of session.steps) {
      console.log(`\n### Step ${step.id}: ${step.title}`);
      console.log(step.content);
    }
    
    // Print conclusion
    console.log('\n### Conclusion');
    console.log(session.conclusion);
    
    console.log(`\n[${getFormattedDateTime()}] Thinking process completed.`);
    return true;
  } catch (error) {
    console.error(`Error in sequential thinking: ${error.message}`);
    return false;
  }
}

// Handle visualize-graph command
async function handleVisualizeGraph(projectPath, format = 'html', output = 'knowledge-graph') {
  try {
    console.log(`Visualizing knowledge graph for: ${projectPath}`);
    console.log(`Format: ${format}, Output: ${output}`);
    console.log(`[${getFormattedDateTime()}] Starting visualization...`);
    
    // Check if project path exists
    if (!fs.existsSync(projectPath)) {
      console.error(`Error: Project path ${projectPath} does not exist.`);
      process.exit(1);
    }
    
    // Initialize knowledge graph
    const knowledgeGraph = new KnowledgeGraphAPI(projectPath);
    
    // Generate visualization
    const visualization = knowledgeGraph.visualize(format);
    
    // Add file extension based on format
    let fileName = output;
    if (format === 'html' && !fileName.endsWith('.html')) {
      fileName += '.html';
    } else if (format === 'json' && !fileName.endsWith('.json')) {
      fileName += '.json';
    } else if (format === 'graphviz' && !fileName.endsWith('.dot')) {
      fileName += '.dot';
    }
    
    // Write to file
    fs.writeFileSync(fileName, visualization);
    
    console.log(`Visualization saved to: ${fileName}`);
    console.log(`[${getFormattedDateTime()}] Visualization completed.`);
    return true;
  } catch (error) {
    console.error(`Error visualizing knowledge graph: ${error.message}`);
    return false;
  }
}

// Main function
async function main() {
  try {
    switch (command) {
      case 'update':
        if (options.length === 0) {
          console.error('Error: Project path is required for update command.');
          process.exit(1);
        }
        await handleUpdate(options[0]);
        break;
      
      case 'extract-knowledge':
        if (options.length === 0) {
          console.error('Error: Project path is required for extract-knowledge command.');
          process.exit(1);
        }
        await handleExtractKnowledge(options[0]);
        break;
      
      case 'think':
        if (options.length === 0) {
          console.error('Error: Problem statement is required for think command.');
          process.exit(1);
        }
        const problem = options[0];
        const model = options[1] || 'problem-solving';
        await handleThink(problem, model);
        break;
      
      case 'visualize-graph':
        if (options.length === 0) {
          console.error('Error: Project path is required for visualize-graph command.');
          process.exit(1);
        }
        const projectPath = options[0];
        
        // Parse format option (--format=html)
        let format = 'html';
        const formatOption = options.find(opt => opt.startsWith('--format='));
        if (formatOption) {
          format = formatOption.split('=')[1];
        }
        
        // Parse output option (--output=filename)
        let output = 'knowledge-graph';
        const outputOption = options.find(opt => opt.startsWith('--output='));
        if (outputOption) {
          output = outputOption.split('=')[1];
        }
        
        await handleVisualizeGraph(projectPath, format, output);
        break;
      
      case '--help':
      case '-h':
      case 'help':
        showHelp();
        break;
      
      default:
        console.error(`Unknown command: ${command}`);
        showHelp();
        process.exit(1);
    }
  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

// Show help message
function showHelp() {
  console.log(`
Memory Bank CLI - v2.0.0

Usage:
  node cli.js <command> [options]

Commands:
  update <project-path>              Update memory bank files and knowledge graph
  extract-knowledge <project-path>   Extract knowledge from memory bank into knowledge graph
  think <problem> [model-type]       Apply sequential thinking to a problem
  visualize-graph <project-path>     Generate visualization of the knowledge graph
                   [--format=html|json|graphviz] 
                   [--output=filename]
  help                               Show this help message

Examples:
  node cli.js update /path/to/project
  node cli.js extract-knowledge /path/to/project
  node cli.js think "How to improve app performance?" code-design
  node cli.js visualize-graph /path/to/project --format=html --output=graph.html
  `);
}

// Execute main function
main();