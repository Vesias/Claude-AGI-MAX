import fs from 'fs';
import path from 'path';
import { format } from 'util';

// Log levels 
enum LogLevel {
  ERROR = 0,
  WARN = 1,
  INFO = 2,
  DEBUG = 3,
}

// Log colors for console output
const LOG_COLORS = {
  ERROR: '\x1b[31m', // Red
  WARN: '\x1b[33m',  // Yellow
  INFO: '\x1b[36m',  // Cyan
  DEBUG: '\x1b[90m', // Gray
  RESET: '\x1b[0m',  // Reset color
};

// Current log level, can be changed at runtime
let currentLogLevel = process.env.NODE_ENV === 'production' ? LogLevel.INFO : LogLevel.DEBUG;

// Ensure log directory exists
const logDir = path.join(__dirname, '../../logs');
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

// Log file paths
const logFilePath = path.join(logDir, 'server.log');
const errorLogFilePath = path.join(logDir, 'error.log');

// Create log files if they don't exist
if (!fs.existsSync(logFilePath)) {
  fs.writeFileSync(logFilePath, '');
}
if (!fs.existsSync(errorLogFilePath)) {
  fs.writeFileSync(errorLogFilePath, '');
}

// Convert log level string to enum
function getLogLevelFromString(level: string): LogLevel {
  switch (level.toUpperCase()) {
    case 'ERROR': return LogLevel.ERROR;
    case 'WARN': return LogLevel.WARN;
    case 'INFO': return LogLevel.INFO;
    case 'DEBUG': return LogLevel.DEBUG;
    default: return LogLevel.INFO;
  }
}

// Set log level
export function setLogLevel(level: string | LogLevel): void {
  if (typeof level === 'string') {
    currentLogLevel = getLogLevelFromString(level);
  } else {
    currentLogLevel = level;
  }
}

// Format log message
function formatLogMessage(level: string, message: string): string {
  const timestamp = new Date().toISOString();
  return `[${timestamp}] [${level}] ${message}`;
}

// Write to log files
function writeToLogFile(message: string, isError: boolean = false): void {
  try {
    fs.appendFileSync(logFilePath, message + '\n');
    if (isError) {
      fs.appendFileSync(errorLogFilePath, message + '\n');
    }
  } catch (err) {
    console.error('Failed to write to log file:', err);
  }
}

// Main logger functions
export function error(message: string, ...args: any[]): void {
  if (currentLogLevel >= LogLevel.ERROR) {
    const formattedMessage = formatLogMessage('ERROR', format(message, ...args));
    console.error(`${LOG_COLORS.ERROR}${formattedMessage}${LOG_COLORS.RESET}`);
    writeToLogFile(formattedMessage, true);
  }
}

export function warn(message: string, ...args: any[]): void {
  if (currentLogLevel >= LogLevel.WARN) {
    const formattedMessage = formatLogMessage('WARN', format(message, ...args));
    console.warn(`${LOG_COLORS.WARN}${formattedMessage}${LOG_COLORS.RESET}`);
    writeToLogFile(formattedMessage);
  }
}

export function info(message: string, ...args: any[]): void {
  if (currentLogLevel >= LogLevel.INFO) {
    const formattedMessage = formatLogMessage('INFO', format(message, ...args));
    console.info(`${LOG_COLORS.INFO}${formattedMessage}${LOG_COLORS.RESET}`);
    writeToLogFile(formattedMessage);
  }
}

export function debug(message: string, ...args: any[]): void {
  if (currentLogLevel >= LogLevel.DEBUG) {
    const formattedMessage = formatLogMessage('DEBUG', format(message, ...args));
    console.debug(`${LOG_COLORS.DEBUG}${formattedMessage}${LOG_COLORS.RESET}`);
    writeToLogFile(formattedMessage);
  }
}

export function success(message: string, ...args: any[]): void {
  if (currentLogLevel >= LogLevel.INFO) {
    const formattedMessage = formatLogMessage('SUCCESS', format(message, ...args));
    console.log(`\x1b[32m${formattedMessage}${LOG_COLORS.RESET}`); // Green color
    writeToLogFile(formattedMessage);
  }
}

// Log request information
export function logRequest(req: any, status: number, duration: number): void {
  const userId = req.user?.id || 'anonymous';
  const method = req.method;
  const url = req.originalUrl || req.url;
  const level = status >= 400 ? (status >= 500 ? 'ERROR' : 'WARN') : 'INFO';
  
  const message = formatLogMessage(
    level, 
    `${method} ${url} ${status} - ${duration}ms - User: ${userId}`
  );
  
  console.log(message);
  writeToLogFile(message, status >= 500);
}

// Create request logger middleware
export function requestLogger() {
  return (req: any, res: any, next: any) => {
    const start = Date.now();
    
    // Capture the original end function
    const originalEnd = res.end;
    
    // Override end function to log when response is sent
    res.end = function(chunk: any, encoding: string) {
      const duration = Date.now() - start;
      logRequest(req, res.statusCode, duration);
      
      // Call the original end function
      return originalEnd.call(this, chunk, encoding);
    };
    
    next();
  };
}

// Export default logger object
export default {
  error,
  warn,
  info,
  debug,
  success,
  setLogLevel,
  requestLogger,
};