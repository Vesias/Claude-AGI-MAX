# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Command Reference
- Build: `cd claude-terminal && npm run build` or `cd .claude-agi/services/proxyclaude && npm run build`
- Dev: `cd claude-terminal && npm run dev` or `cd .claude-agi/services/proxyclaude && npm run dev`
- Start: `cd claude-terminal && npm start` or `cd .claude-agi/services/proxyclaude && PORT=4001 npm start`
- Monitoring: `cd claude-agi-project/monitoring && npm start`
- Test: `cd VibeCodingTest/APP && npm test` or `cd .claude-agi/services/proxyclaude && npm test`
- Lint: `cd claude-agi-project/APP && npm run lint`

## Code Style Guidelines
- TypeScript: Use strict typing where possible, ES2020 target
- Imports: Sort alphabetically, group by external/internal
- Formatting: Use consistent indentation (2 spaces)
- Naming: PascalCase for components/classes, camelCase for functions/variables, UPPER_CASE for constants
- Error Handling: Structured error handling with specific error types
- MCP Tools: Follow Model Context Protocol conventions for tool integration
- Documentation: Include JSDoc comments for functions and interfaces

## Project Architecture
- Claude Terminal: Electron-based app with TypeScript and xterm.js
- ProxyClaude: Express API service for shared Claude API access
- Memory Bank: Persistent context system for the CLAUDE-AGI ecosystem
- VibeCoding: Next.js 15 with Tailwind, tRPC, and React Three Fiber

## Key Components

### Claude Terminal
- Electron-based terminal emulator
- TypeScript implementation with node-pty for terminal emulation
- MCP tools monitoring dashboard
- Memory-bank integration for persistent context
- Unified interface for Claude AI interaction

### ProxyClaude Service
- Express.js API proxy service running on port 4001
- Bearer token authentication system
- Rate limiting based on user tiers (standard/premium/enterprise)
- Admin dashboard for monitoring and management
- Stripe integration for payment processing
- MCP server integration for Claude Desktop

### Memory Bank System
- Structured Markdown files for persistent context
- Standardized file structure (projectbrief.md, activeContext.md, etc.)
- Projectwide knowledge storage with specific file roles
- Integration with Claude Desktop and Claude Terminal
- Extensible to custom project requirements

### MCP Tools Integration
- Model Context Protocol servers for extended functionality
- Configuration in ~/.config/claude-desktop/claude_desktop_config.json
- Tools categorized by functionality (core, vector, web, etc.)
- Common interface for all MCP-compatible tools

## Directory Structure
- `/claude-terminal`: Electron terminal application
- `/.claude-agi`: Services including ProxyClaude
- `/memory-bank`: Global memory bank storage
- `/docs`: System documentation
- `/claude-agi-project`: Main AGI system components

## Documentation Resources
- Terminal Guide: `/docs/TERMINAL_GUIDE.md`
- Architecture Overview: `/docs/ARCHITECTURE.md`
- ProxyClaude Guide: `/docs/proxyclaude-guide.md`
- MCP Tools Reference: `/docs/mcp-tools-reference.md`
- Vibe Coding Stack: `/docs/vibe-coding-stack.md`

## File Management
- Always remove outdated/useless files immediately when restructuring, cleaning or analyzing code