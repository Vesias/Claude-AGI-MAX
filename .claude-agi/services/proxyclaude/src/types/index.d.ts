import { Express } from 'express';

declare global {
  namespace Express {
    interface Request {
      user: {
        id: string;
        apiKey: string;
        [key: string]: any;
      };
    }
  }
}