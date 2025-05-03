# CLAUDE AGI System Architecture

## Overview

The CLAUDE AGI system is a comprehensive framework for AI-assisted development, combining multiple components that work together to provide a seamless experience.

## Architecture Diagram

```
+----------------------------------------------+
|                                              |
|            CLAUDE AGI ECOSYSTEM              |
|                                              |
+----------------------------------------------+
                      |
          +-----------+-----------+
          |           |           |
+---------v---+ +-----v------+ +--v-----------+
|             | |            | |              |
| Claude      | | ProxyClaude| | Memory-Bank  |
| Terminal    | | Service    | | System       |
| (Electron)  | | (Express)  | | (Filesystem) |
|             | |            | |              |
+------+------+ +-----+------+ +------+-------+
       |              |               |
       |              |               |
+------v--------------v---------------v-------+
|                                             |
|              MCP Tools Layer                |
|                                             |
+---------------------------------------------+
       |              |               |
+------v------+ +-----v------+ +------v-------+
|             | |            | |              |
| Desktop     | | Browser    | | Sequential   |
| Commander   | | Tools      | | Thinking     |
|             | |            | |              |
+-------------+ +------------+ +--------------+
       |              |               |
+------v------+ +-----v------+ +------v-------+
|             | |            | |              |
| Code Tools  | | Web Search | | VectorDB     |
|             | |            | | Integration  |
|             | |            | |              |
+-------------+ +------------+ +--------------+
```

## Component Description

### Primary Components

1. **Claude Terminal**
   - Electron-based desktop application
   - Provides command-line interface to Claude
   - Integrates with MCP tools and Memory-Bank
   - Includes dashboard for monitoring services

2. **ProxyClaude Service**
   - Express.js API service
   - Acts as a proxy for Claude API
   - Provides authentication and rate limiting
   - Enables sharing Claude API access between multiple users
   - Features admin dashboard for monitoring

3. **Memory-Bank System**
   - Persistent storage for context between sessions
   - Standardized file structure for project knowledge
   - Enables continuity across multiple Claude sessions
   - Organizes projects into dedicated directories

### MCP Tools Layer

The Model Context Protocol (MCP) tools layer provides extended capabilities through specialized microservices:

1. **Core Tools**
   - desktop-commander: File and system operations
   - code-mcp: Code generation and modification
   - sequentialthinking: Complex problem solving

2. **Web & Search Tools**
   - browser-tools: Headless browser automation
   - brave-search: Web search integration
   - web-spider: Web scraping capabilities

3. **Specialized Tools**
   - memory-bank-mcp: Memory system integration
   - context7-mcp: Semantic context management
   - vector-database: Embedding storage and retrieval

## Data Flow

```
User Input → Claude Terminal → MCP Router → Appropriate MCP Tool
                   ↓
               Memory Bank ← Context Storage
                   ↓
           Claude API (direct or via ProxyClaude)
                   ↓
            Response Processing
                   ↓
            Output to User
```

## Integration Points

1. **Claude Terminal ↔ ProxyClaude**
   - Communication via HTTP API
   - Authentication with bearer tokens
   - Configuration in claude_desktop_config.json

2. **Claude Terminal ↔ Memory-Bank**
   - Direct filesystem access
   - Standardized file structure
   - Memory-Bank manager component

3. **ProxyClaude ↔ Claude API**
   - Secure API key management
   - Request forwarding and response handling
   - Rate limiting and usage tracking

4. **MCP Tools ↔ Claude Terminal**
   - Standard MCP protocol communication
   - Tools launched as child processes
   - Status monitoring via health checks

## Configuration Files

- `~/.config/claude-desktop/claude_desktop_config.json`: MCP tools configuration
- `~/Schreibtisch/CLAUDE/.claude-agi/services/proxyclaude/.env`: ProxyClaude environment variables
- `~/Schreibtisch/CLAUDE/CLAUDE.md`: Documentation for Claude Code

## Deployment Options

1. **Local Development**
   - All components run on the same machine
   - Suitable for individual developers

2. **Team Deployment**
   - ProxyClaude deployed on shared server
   - Terminal installed on each developer's machine
   - Shared Memory-Bank via Git repository

3. **Enterprise Setup**
   - ProxyClaude deployed with high availability
   - Centralized monitoring and billing
   - Team-based access control