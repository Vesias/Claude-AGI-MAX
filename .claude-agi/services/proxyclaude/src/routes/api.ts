import { Router } from 'express';
import { Queue } from 'bull';

// Allow mock queue implementation
interface QueueLike {
  add: (name: string, data: any, options?: any) => Promise<any>;
}

export function setupApiRoutes(queue: Queue | QueueLike) {
  const router = Router();

  // Middleware to verify API key
  const apiKeyAuth = (req: any, res: any, next: any) => {
    const authHeader = req.headers.authorization;
    const apiKey = authHeader && authHeader.startsWith('Bearer ') 
      ? authHeader.substring(7) 
      : null;
      
    if (!apiKey) {
      return res.status(401).json({ error: 'API key required' });
    }
    
    // Check if the API key is in the valid list
    const validKeys = (process.env.VALID_API_KEYS || 'test-key').split(',');
    if (!validKeys.includes(apiKey)) {
      return res.status(403).json({ error: 'Invalid API key' });
    }
    
    // Set user on request object for later use
    req.user = { id: 'test-user', apiKey };
    next();
  };

  // All routes require API key
  router.use(apiKeyAuth);

  // Rate limiting middleware
  let requestCounts: Record<string, number[]> = {};
  const MAX_REQUESTS_PER_MINUTE = 60;
  
  const rateLimiter = (req: any, res: any, next: any) => {
    const userId = req.user?.id || 'anonymous';
    const now = Date.now();
    
    // Initialize or clean up old entries
    requestCounts[userId] = requestCounts[userId]?.filter(
      timestamp => now - timestamp < 60000
    ) || [];
    
    // Check if too many requests
    if (requestCounts[userId].length >= MAX_REQUESTS_PER_MINUTE) {
      return res.status(429).set({
        'Retry-After': '60', 
        'X-RateLimit-Limit': MAX_REQUESTS_PER_MINUTE,
        'X-RateLimit-Remaining': 0
      }).json({ 
        error: 'Too many requests',
        retryAfter: 60
      });
    }
    
    // Track this request
    requestCounts[userId].push(now);
    
    // Set headers
    res.set({
      'X-RateLimit-Limit': MAX_REQUESTS_PER_MINUTE,
      'X-RateLimit-Remaining': MAX_REQUESTS_PER_MINUTE - requestCounts[userId].length
    });
    
    next();
  };

  // Apply rate limiter
  router.use(rateLimiter);

  // Chat endpoint
  router.post('/claude-agi/chat', async (req, res) => {
    const { content } = req.body;
    
    if (!content) {
      return res.status(400).json({ error: 'Content is required' });
    }
    
    try {
      // Add job to queue
      const job = await queue.add('claude-request', {
        prompt: content,
        userId: req.user ? req.user.id : 'anonymous',
        timestamp: Date.now()
      }, {
        removeOnComplete: true,
        attempts: 3,
        backoff: {
          type: 'exponential',
          delay: 1000
        }
      });
      
      // Simple streaming simulation
      let responseChunks = [
        { content: 'I\'m processing your request...', done: false },
        { content: '\nAnalyzing input...', done: false },
        { content: '\nHere\'s my response to your query:', done: false }
      ];
      
      // Simulate waiting for job completion
      const result = await new Promise(resolve => {
        // This would normally wait for the job to complete
        // For now, just simulate a delayed response
        setTimeout(() => {
          resolve({
            content: `Thank you for your question about "${content}". Here is a detailed response from ProxyClaude...`,
            done: true
          });
        }, 2000);
      });
      
      // According to the documentation, format the response as:
      // {
      //   "result": {
      //     "content": "Response from Claude",
      //     "tokens": {
      //       "prompt": 5,
      //       "completion": 20
      //     }
      //   }
      // }
      
      // For streaming we might want to keep the chunks for client-side rendering
      // But final response needs to follow the documented format
      const combinedContent = responseChunks.map(chunk => chunk.content).join('') + 
                             (result as any).content;
      
      res.json({
        result: {
          content: combinedContent,
          tokens: {
            prompt: Math.ceil(content.length / 4), // Approximate token count
            completion: Math.ceil(combinedContent.length / 4) // Approximate token count
          }
        }
      });
    } catch (error) {
      console.error('API error:', error);
      res.status(500).json({ error: 'Failed to process request' });
    }
  });

  return router;
}