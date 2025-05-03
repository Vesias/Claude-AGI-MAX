/**
 * Knowledge Graph API for CLAUDE AGI Memory Bank
 * 
 * This API provides functions for creating, managing, and querying a knowledge graph
 * to store semantic relationships between concepts in the CLAUDE AGI ecosystem.
 * 
 * Version: 1.0.0
 */

const fs = require('fs');
const path = require('path');

class KnowledgeGraphAPI {
  constructor(projectPath) {
    this.projectPath = projectPath;
    this.graphPath = path.join(projectPath, 'memory-bank', 'knowledgeGraph.json');
    this.graph = this.loadGraph();
  }

  /**
   * Load the knowledge graph from disk
   */
  loadGraph() {
    try {
      if (fs.existsSync(this.graphPath)) {
        const data = fs.readFileSync(this.graphPath, 'utf8');
        return JSON.parse(data);
      }
      
      // Initialize empty graph if none exists
      return {
        nodes: [],
        edges: [],
        metadata: {
          version: '1.0.0',
          created: new Date().toISOString(),
          updated: new Date().toISOString()
        }
      };
    } catch (error) {
      console.error(`Error loading knowledge graph: ${error.message}`);
      return {
        nodes: [],
        edges: [],
        metadata: {
          version: '1.0.0',
          created: new Date().toISOString(),
          updated: new Date().toISOString()
        }
      };
    }
  }

  /**
   * Save the current graph to disk
   */
  saveGraph() {
    try {
      // Update the 'updated' timestamp
      this.graph.metadata.updated = new Date().toISOString();
      
      // Ensure the directory exists
      const dir = path.dirname(this.graphPath);
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }
      
      fs.writeFileSync(this.graphPath, JSON.stringify(this.graph, null, 2), 'utf8');
      return true;
    } catch (error) {
      console.error(`Error saving knowledge graph: ${error.message}`);
      return false;
    }
  }

  /**
   * Add a new concept node to the graph
   * @param {string} concept - The concept name
   * @param {string} type - The type of the concept (e.g., 'component', 'technology', 'feature')
   * @param {Object} properties - Additional properties of the concept
   * @returns {string} The ID of the newly created node
   */
  addConcept(concept, type, properties = {}) {
    const id = `${type}_${concept.replace(/\s+/g, '_').toLowerCase()}`;
    
    // Check if the node already exists
    const existingNode = this.graph.nodes.find(node => node.id === id);
    if (existingNode) {
      // Update existing node
      existingNode.properties = { ...existingNode.properties, ...properties };
      existingNode.updated = new Date().toISOString();
      this.saveGraph();
      return id;
    }
    
    // Create new node
    const newNode = {
      id,
      concept,
      type,
      properties,
      created: new Date().toISOString(),
      updated: new Date().toISOString()
    };
    
    this.graph.nodes.push(newNode);
    this.saveGraph();
    return id;
  }

  /**
   * Add a relationship between two concepts
   * @param {string} sourceId - The ID of the source node
   * @param {string} targetId - The ID of the target node
   * @param {string} relationship - The type of relationship
   * @param {Object} properties - Additional properties of the relationship
   * @returns {boolean} Success of the operation
   */
  addRelationship(sourceId, targetId, relationship, properties = {}) {
    // Validate that both nodes exist
    const sourceExists = this.graph.nodes.some(node => node.id === sourceId);
    const targetExists = this.graph.nodes.some(node => node.id === targetId);
    
    if (!sourceExists || !targetExists) {
      console.error(`Cannot create relationship: one or both nodes don't exist`);
      return false;
    }
    
    const edgeId = `${sourceId}_${relationship}_${targetId}`;
    
    // Check if the edge already exists
    const existingEdge = this.graph.edges.find(edge => edge.id === edgeId);
    if (existingEdge) {
      // Update existing edge
      existingEdge.properties = { ...existingEdge.properties, ...properties };
      existingEdge.updated = new Date().toISOString();
      this.saveGraph();
      return true;
    }
    
    // Create new edge
    const newEdge = {
      id: edgeId,
      source: sourceId,
      target: targetId,
      relationship,
      properties,
      created: new Date().toISOString(),
      updated: new Date().toISOString()
    };
    
    this.graph.edges.push(newEdge);
    this.saveGraph();
    return true;
  }

  /**
   * Query the graph for nodes that match given criteria
   * @param {Object} criteria - Criteria to match against node properties
   * @returns {Array} Matching nodes
   */
  queryConcepts(criteria = {}) {
    return this.graph.nodes.filter(node => {
      for (const [key, value] of Object.entries(criteria)) {
        if (key === 'properties') {
          for (const [propKey, propValue] of Object.entries(value)) {
            if (!node.properties || node.properties[propKey] !== propValue) {
              return false;
            }
          }
        } else if (node[key] !== value) {
          return false;
        }
      }
      return true;
    });
  }

  /**
   * Find all relationships for a given concept
   * @param {string} conceptId - The ID of the concept
   * @returns {Object} Object containing incoming and outgoing relationships
   */
  getConceptRelationships(conceptId) {
    const outgoing = this.graph.edges.filter(edge => edge.source === conceptId);
    const incoming = this.graph.edges.filter(edge => edge.target === conceptId);
    
    return { outgoing, incoming };
  }

  /**
   * Find the shortest path between two concepts
   * @param {string} sourceId - Starting concept ID
   * @param {string} targetId - Target concept ID
   * @returns {Array|null} Array of nodes and edges in the path, or null if no path exists
   */
  findShortestPath(sourceId, targetId) {
    if (sourceId === targetId) {
      return [{ node: this.graph.nodes.find(node => node.id === sourceId) }];
    }
    
    // Breadth-first search
    const queue = [{ node: sourceId, path: [{ node: sourceId }] }];
    const visited = new Set([sourceId]);
    
    while (queue.length > 0) {
      const { node: currentId, path } = queue.shift();
      
      // Get all connected nodes (both outgoing and incoming)
      const outgoingEdges = this.graph.edges.filter(edge => edge.source === currentId);
      
      for (const edge of outgoingEdges) {
        if (edge.target === targetId) {
          // Found the target
          const finalNode = this.graph.nodes.find(node => node.id === targetId);
          return [
            ...path,
            { 
              edge,
              direction: 'outgoing'
            },
            { 
              node: finalNode
            }
          ];
        }
        
        if (!visited.has(edge.target)) {
          visited.add(edge.target);
          const nextNode = this.graph.nodes.find(node => node.id === edge.target);
          queue.push({
            node: edge.target,
            path: [
              ...path,
              { 
                edge,
                direction: 'outgoing'
              },
              { 
                node: nextNode
              }
            ]
          });
        }
      }
      
      // Also check incoming edges
      const incomingEdges = this.graph.edges.filter(edge => edge.target === currentId);
      
      for (const edge of incomingEdges) {
        if (edge.source === targetId) {
          // Found the target
          const finalNode = this.graph.nodes.find(node => node.id === targetId);
          return [
            ...path,
            { 
              edge,
              direction: 'incoming'
            },
            { 
              node: finalNode
            }
          ];
        }
        
        if (!visited.has(edge.source)) {
          visited.add(edge.source);
          const nextNode = this.graph.nodes.find(node => node.id === edge.source);
          queue.push({
            node: edge.source,
            path: [
              ...path,
              { 
                edge,
                direction: 'incoming'
              },
              { 
                node: nextNode
              }
            ]
          });
        }
      }
    }
    
    // No path found
    return null;
  }

  /**
   * Extract concepts from a markdown text and add them to the graph
   * @param {string} text - Markdown text to analyze
   * @param {string} type - Default type for extracted concepts
   * @param {Array} existingConcepts - List of existing concepts to match against
   * @returns {Array} Newly identified concepts
   */
  extractConceptsFromText(text, type = 'concept', existingConcepts = []) {
    // Get all existing concept names for matching
    const existingNames = existingConcepts.length > 0 
      ? existingConcepts 
      : this.graph.nodes.map(node => node.concept);
    
    // Simple extraction strategy - look for capitalized phrases and items in lists
    const capitalizedRegex = /\b[A-Z][a-zA-Z0-9]+([ -][A-Z][a-zA-Z0-9]+)*\b/g;
    const listItemRegex = /[*-]\s+([A-Z][a-zA-Z0-9]+([ -][a-zA-Z0-9]+)*)/g;
    
    const conceptMatches = [
      ...(text.match(capitalizedRegex) || []),
      ...((text.match(listItemRegex) || []).map(match => match.replace(/[*-]\s+/, '')))
    ];
    
    // Filter for unique concepts and remove any that already exist
    const uniqueConcepts = [...new Set(conceptMatches)]
      .filter(concept => !existingNames.includes(concept));
    
    // Add each new concept
    const addedConcepts = [];
    
    for (const concept of uniqueConcepts) {
      const id = this.addConcept(concept, type, {
        extractedFrom: 'text',
        confidence: 'low'
      });
      
      addedConcepts.push({
        id,
        concept
      });
    }
    
    return addedConcepts;
  }

  /**
   * Update the graph with concepts extracted from all memory bank text files
   * @returns {Object} Summary of updates made
   */
  updateFromMemoryBank() {
    const memoryBankPath = path.join(this.projectPath, 'memory-bank');
    const fileTypes = [
      'activeContext.md',
      'productContext.md',
      'projectbrief.md',
      'systemPatterns.md',
      'techContext.md',
      'progress.md'
    ];
    
    const summary = {
      filesProcessed: 0,
      conceptsAdded: 0,
      relationshipsAdded: 0
    };
    
    for (const fileType of fileTypes) {
      const filePath = path.join(memoryBankPath, fileType);
      
      if (fs.existsSync(filePath)) {
        try {
          const content = fs.readFileSync(filePath, 'utf8');
          
          // Determine concept type based on file
          let conceptType = 'concept';
          if (fileType === 'techContext.md') conceptType = 'technology';
          if (fileType === 'systemPatterns.md') conceptType = 'pattern';
          if (fileType === 'productContext.md') conceptType = 'feature';
          
          const addedConcepts = this.extractConceptsFromText(content, conceptType);
          summary.conceptsAdded += addedConcepts.length;
          
          // If this is a new file being processed, add a relationship from the file to the concepts
          const fileNodeId = `file_${fileType.replace('.md', '')}`;
          const fileExists = this.graph.nodes.some(node => node.id === fileNodeId);
          
          if (!fileExists) {
            this.addConcept(fileType.replace('.md', ''), 'file', {
              path: filePath,
              type: 'memory-bank-file'
            });
            
            // Add relationships from file to concepts
            for (const { id } of addedConcepts) {
              this.addRelationship(fileNodeId, id, 'contains');
              summary.relationshipsAdded++;
            }
          }
          
          summary.filesProcessed++;
        } catch (error) {
          console.error(`Error processing ${filePath}: ${error.message}`);
        }
      }
    }
    
    return summary;
  }

  /**
   * Generate a visual representation of the graph
   * @param {string} format - Output format ('json', 'graphviz', 'html')
   * @returns {string} Graph representation in the specified format
   */
  visualize(format = 'json') {
    if (format === 'json') {
      return JSON.stringify(this.graph, null, 2);
    }
    
    if (format === 'graphviz') {
      let dot = 'digraph G {\n';
      
      // Add nodes
      for (const node of this.graph.nodes) {
        const label = `${node.concept} (${node.type})`;
        dot += `  "${node.id}" [label="${label}"];\n`;
      }
      
      // Add edges
      for (const edge of this.graph.edges) {
        dot += `  "${edge.source}" -> "${edge.target}" [label="${edge.relationship}"];\n`;
      }
      
      dot += '}';
      return dot;
    }
    
    if (format === 'html') {
      return `
<!DOCTYPE html>
<html>
<head>
  <title>Knowledge Graph Visualization</title>
  <style>
    body { font-family: sans-serif; }
    #graph { width: 100%; height: 600px; border: 1px solid #ccc; }
    .info { padding: 10px; background: #f5f5f5; border-radius: 5px; }
  </style>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/vis-network/9.1.2/vis-network.min.js"></script>
</head>
<body>
  <h1>Knowledge Graph Visualization</h1>
  <div class="info">
    <p>Nodes: ${this.graph.nodes.length} | Edges: ${this.graph.edges.length}</p>
  </div>
  <div id="graph"></div>
  
  <script>
    const graph = ${JSON.stringify(this.graph)};
    
    // Prepare data for visualization
    const nodes = graph.nodes.map(node => ({
      id: node.id,
      label: node.concept,
      title: \`Type: \${node.type}<br>Properties: \${JSON.stringify(node.properties)}\`,
      group: node.type
    }));
    
    const edges = graph.edges.map(edge => ({
      from: edge.source,
      to: edge.target,
      label: edge.relationship,
      arrows: 'to'
    }));
    
    // Create network
    const container = document.getElementById('graph');
    const data = { nodes, edges };
    const options = {
      nodes: {
        shape: 'dot',
        size: 16
      },
      physics: {
        stabilization: false,
        barnesHut: {
          gravitationalConstant: -80,
          springConstant: 0.001,
          springLength: 200
        }
      }
    };
    
    new vis.Network(container, data, options);
  </script>
</body>
</html>
      `.trim();
    }
    
    return this.graph;
  }
}

module.exports = KnowledgeGraphAPI;