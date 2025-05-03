# CLAUDE AGI Terminal Guide

*Version 1.0 • May 2025*

## Overview

The CLAUDE AGI Terminal is an Electron-based application that provides a powerful interface to the Claude AI assistant with integrated MCP tools, Memory-Bank system, and ProxyClaude service.

## Installation

### Prerequisites

Before installing the CLAUDE AGI Terminal, ensure you have the following:

- **Node.js** (v16 recommended for optimal compatibility)
- **NPM** (included with Node.js)
- **Git** (for version control)
- **Claude Pro MAX** subscription

### Installation Options

#### Automated Installation

The easiest way to install is using the provided installation script:

```bash
# Navigate to the CLAUDE directory
cd ~/Schreibtisch/CLAUDE

# Run the installer
./install-claude-agi-terminal.sh
```

The installer will:
1. Check system prerequisites
2. Set up the terminal application
3. Configure MCP tools
4. Initialize the memory-bank system
5. Create necessary symbolic links

#### Manual Installation

For advanced users who prefer manual installation:

1. Clone or download the repository
2. Install dependencies:
   ```bash
   cd claude-terminal
   npm install
   ```
3. Build the TypeScript code:
   ```bash
   npm run build
   ```
4. Create required directories:
   ```bash
   mkdir -p ~/.config/claude-desktop
   mkdir -p ~/Schreibtisch/CLAUDE/memory-bank
   ```

## Using the Terminal

### Starting the Terminal

Start the terminal using one of these methods:

1. **From the command line**:
   ```bash
   cd ~/Schreibtisch/CLAUDE/claude-terminal
   npm start
   ```

2. **Using the symbolic link** (if created during installation):
   ```bash
   claude-term
   ```

### Main Terminal Features

The CLAUDE AGI Terminal includes:

1. **Command-line Interface**: Direct interaction with Claude AI
2. **MCP Tools Dashboard**: Monitor and manage Model Context Protocol tools
3. **Memory-Bank Panel**: Access persistent context across sessions
4. **AGI Installer**: Create new projects with the correct structure

### Keyboard Shortcuts

- `Ctrl+T`: Open new terminal tab
- `Ctrl+D`: Toggle dashboard view
- `Ctrl+M`: Open memory-bank panel
- `Ctrl+I`: Launch AGI Installer
- `Ctrl+Q`: Quit application

## MCP Tools Integration

The terminal integrates with these MCP tools by default:

| Tool | Purpose | Command |
|------|---------|---------|
| proxyclaude | API sharing | `/mcp proxyclaude` |
| browser-tools | Web browsing | `/mcp browser` |
| desktop-commander | File operations | `/mcp desktop` |
| code-mcp | Code generation | `/mcp code` |
| sequentialthinking | Complex reasoning | `/mcp think` |
| memory-bank | Context management | `/mcp memory` |
| context7-mcp | Semantic context | `/mcp context` |
| brave-search | Web search | `/mcp search` |

## Memory Bank System

The memory-bank system maintains persistent context between sessions:

### Standard Files

- `projectbrief.md`: Project definition and goals
- `activeContext.md`: Current focus and priorities
- `techContext.md`: Technical stack information
- `systemPatterns.md`: System architecture patterns
- `progress.md`: Progress tracking

### Memory Bank Commands

- `/memory list <project>`: List all memory files
- `/memory read <project> <file>`: Read a memory file
- `/memory update <project> <file>`: Update a memory file
- `/memory create <project> <file>`: Create a new memory file

## ProxyClaude Service

The ProxyClaude service allows sharing a Claude Pro MAX subscription between multiple users:

### Starting ProxyClaude

```bash
cd ~/Schreibtisch/CLAUDE/.claude-agi/services/proxyclaude
npm install (first time only)
npm run build
PORT=4001 npm start
```

### Using ProxyClaude

- API endpoint: `http://localhost:4001/api/claude`
- Admin dashboard: `http://localhost:4001/admin`
- Integration with CLAUDE AGI Terminal is automatic when both are running

## Troubleshooting

### Common Issues

1. **Terminal fails to start**:
   - Check Node.js version (v16 recommended)
   - Ensure all dependencies are installed

2. **MCP tools unavailable**:
   - Verify configuration in `~/.config/claude-desktop/claude_desktop_config.json`
   - Check logs in `~/Schreibtisch/CLAUDE/logs/`

3. **Memory-bank access errors**:
   - Ensure the directory structure exists
   - Check file permissions

### Logs Location

- Terminal logs: `~/Schreibtisch/CLAUDE/logs/terminal-installation.log`
- MCP server logs: `~/Schreibtisch/CLAUDE/logs/<server-name>.log`
- ProxyClaude logs: `~/Schreibtisch/CLAUDE/.claude-agi/services/proxyclaude/logs/`

## Additional Resources

- [MCP Tools Reference](./mcp-tools-reference.md)
- [Vibe-Coding Stack](./vibe-coding-stack.md)
- [ProxyClaude Guide](./proxyclaude-guide.md)