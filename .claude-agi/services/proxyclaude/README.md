# ProxyClaude

ProxyClaude is an API proxy service for Claude AI integrated with the CLAUDE-AGI ecosystem. It provides managed access to Claude capabilities with usage tracking, rate limiting, and payment processing.

## Features

- 🔑 API key management with Stripe payments
- ⚡ Queue-based request handling for optimal resource usage
- 📊 Usage tracking and monitoring
- 🛡️ Rate limiting and access controls
- 🔄 Load balancing across multiple Claude API keys

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- Redis server (for queue management)
- Stripe account (for payment processing)
- Claude API access

### Installation

1. Clone into the CLAUDE-AGI workspace:
   ```bash
   # The service is already installed in the .claude-agi workspace
   cd .claude-agi/services/proxyclaude
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure environment:
   ```bash
   cp .env.example .env.local
   # Edit .env.local with your API keys and settings
   ```

4. Start the service:
   ```bash
   npm run dev
   ```

The service will be available at http://localhost:4000

## Usage

### For customers

1. Visit `/payment/checkout` to purchase API access
2. After payment, receive an API key via email
3. Use the API key in requests:

```bash
curl -X POST http://localhost:4000/api/claude-agi/chat \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"content": "Your prompt here"}'
```

### For administrators

Monitor usage and manage keys through the integrated dashboard at `/admin` (requires admin authentication).

## Integration with CLAUDE-AGI

ProxyClaude leverages several CLAUDE-AGI components:

- Memory Bank for persistent context management
- Monitoring system for usage tracking
- MCP tools for advanced capabilities

## Security

- API keys are securely stored and hashed
- Stripe handles all payment information
- Rate limiting prevents abuse
- All sensitive configuration is stored in .env.local (not committed to Git)

## License

Private - Part of the CLAUDE-AGI ecosystem