# TypeScript Security Checklist

Security considerations and common vulnerabilities to check during TypeScript code reviews.

## Input Validation & Sanitization

### ✅ Validate User Input
```typescript
// Bad - no validation
function createUser(data: any) {
  return database.insert('users', data);
}

// Good - validate input structure
interface CreateUserInput {
  name: string;
  email: string;
  age: number;
}

function isValidUserInput(data: unknown): data is CreateUserInput {
  return (
    typeof data === 'object' &&
    data !== null &&
    'name' in data &&
    typeof (data as CreateUserInput).name === 'string' &&
    (data as CreateUserInput).name.length > 0 &&
    'email' in data &&
    typeof (data as CreateUserInput).email === 'string' &&
    isValidEmail((data as CreateUserInput).email) &&
    'age' in data &&
    typeof (data as CreateUserInput).age === 'number' &&
    (data as CreateUserInput).age >= 0
  );
}

function createUser(data: unknown) {
  if (!isValidUserInput(data)) {
    throw new Error('Invalid user data');
  }
  return database.insert('users', data);
}
```

### ✅ Use Schema Validation Libraries
```typescript
// Good - use Zod, Yup, or io-ts for validation
import { z } from 'zod';

const UserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().min(0).max(150),
});

type User = z.infer<typeof UserSchema>;

function createUser(data: unknown): User {
  // Throws if invalid, type-safe if valid
  const validatedUser = UserSchema.parse(data);
  return database.insert('users', validatedUser);
}
```

**Security Risk**: Without validation, malicious input can cause SQL injection, NoSQL injection, or unexpected behavior.

---

## XSS (Cross-Site Scripting) Prevention

### ✅ Sanitize HTML Output
```typescript
// Bad - directly inserting user content
function displayComment(comment: string) {
  document.getElementById('comment')!.innerHTML = comment;
}

// Good - use textContent or sanitize
function displayComment(comment: string) {
  document.getElementById('comment')!.textContent = comment;
}

// Good - use a sanitization library for rich content
import DOMPurify from 'dompurify';

function displayComment(comment: string) {
  const sanitized = DOMPurify.sanitize(comment);
  document.getElementById('comment')!.innerHTML = sanitized;
}
```

**Security Risk**: Unsanitized user input in HTML can execute malicious scripts.

### ✅ Avoid `eval` and Similar Functions
```typescript
// Bad - eval executes arbitrary code
function calculate(expression: string): number {
  return eval(expression); // Never do this!
}

// Bad - Function constructor is also dangerous
const fn = new Function('return ' + userInput);

// Good - use a safe parser
import { evaluate } from 'mathjs';

function calculate(expression: string): number {
  try {
    return evaluate(expression);
  } catch {
    throw new Error('Invalid expression');
  }
}
```

**Security Risk**: `eval` and `Function` constructor can execute arbitrary code.

---

## SQL/NoSQL Injection Prevention

### ✅ Use Parameterized Queries
```typescript
// Bad - string concatenation (SQL injection risk)
function getUser(userId: string) {
  return db.query(`SELECT * FROM users WHERE id = '${userId}'`);
}

// Good - parameterized query
function getUser(userId: string) {
  return db.query('SELECT * FROM users WHERE id = $1', [userId]);
}

// Good - ORM with type safety
async function getUser(userId: string): Promise<User | null> {
  return prisma.user.findUnique({
    where: { id: userId },
  });
}
```

**Security Risk**: String concatenation in queries allows SQL injection attacks.

### ✅ Validate Database Query Parameters
```typescript
// Bad - no validation
function getUsersByRole(role: string) {
  return db.query('SELECT * FROM users WHERE role = $1', [role]);
}

// Good - validate against known values
type UserRole = 'admin' | 'user' | 'guest';

function isValidRole(role: string): role is UserRole {
  return ['admin', 'user', 'guest'].includes(role);
}

function getUsersByRole(role: string) {
  if (!isValidRole(role)) {
    throw new Error('Invalid role');
  }
  return db.query('SELECT * FROM users WHERE role = $1', [role]);
}
```

---

## Authentication & Authorization

### ✅ Never Store Passwords in Plain Text
```typescript
// Bad - storing plain text passwords
interface User {
  id: string;
  email: string;
  password: string; // Never store plain text!
}

// Good - hash passwords
import bcrypt from 'bcrypt';

async function createUser(email: string, password: string): Promise<User> {
  const hashedPassword = await bcrypt.hash(password, 10);
  return db.insert('users', {
    email,
    password: hashedPassword,
  });
}

async function verifyPassword(user: User, password: string): Promise<boolean> {
  return bcrypt.compare(password, user.password);
}
```

**Security Risk**: Plain text passwords expose all user accounts if the database is compromised.

### ✅ Implement Proper Session Management
```typescript
// Bad - predictable session IDs
function createSession(userId: string): string {
  return `session_${userId}_${Date.now()}`;
}

// Good - cryptographically secure session IDs
import crypto from 'crypto';

function createSession(userId: string): string {
  return crypto.randomBytes(32).toString('hex');
}

// Better - use established session libraries
import session from 'express-session';

app.use(session({
  secret: process.env.SESSION_SECRET!,
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: true, // HTTPS only
    httpOnly: true, // Not accessible via JavaScript
    maxAge: 3600000, // 1 hour
    sameSite: 'strict', // CSRF protection
  },
}));
```

### ✅ Implement Rate Limiting
```typescript
// Good - rate limiting for authentication
import rateLimit from 'express-rate-limit';

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests per window
  message: 'Too many login attempts, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
});

app.post('/login', loginLimiter, async (req, res) => {
  // Login logic
});
```

**Security Risk**: Without rate limiting, attackers can perform brute-force attacks.

---

## Secrets Management

### ✅ Never Hardcode Secrets
```typescript
// Bad - hardcoded secrets
const API_KEY = 'sk_live_abc123xyz789';
const DATABASE_URL = 'postgresql://user:password@localhost:5432/db';

// Good - use environment variables
const API_KEY = process.env.API_KEY;
const DATABASE_URL = process.env.DATABASE_URL;

// Better - validate environment variables at startup
import { z } from 'zod';

const EnvSchema = z.object({
  API_KEY: z.string().min(1),
  DATABASE_URL: z.string().url(),
  NODE_ENV: z.enum(['development', 'production', 'test']),
});

const env = EnvSchema.parse(process.env);

// Now TypeScript knows these exist and are valid
export const config = {
  apiKey: env.API_KEY,
  databaseUrl: env.DATABASE_URL,
  nodeEnv: env.NODE_ENV,
};
```

### ✅ Don't Commit Secrets to Git
```typescript
// Add to .gitignore
/*
.env
.env.local
.env.*.local
config/secrets.json
*/

// Use .env.example for documentation
/*
# .env.example
API_KEY=your_api_key_here
DATABASE_URL=postgresql://user:password@localhost:5432/db
*/
```

**Security Risk**: Hardcoded secrets in code can be exposed in version control or logs.

---

## CSRF (Cross-Site Request Forgery) Protection

### ✅ Use CSRF Tokens
```typescript
// Good - CSRF protection middleware
import csrf from 'csurf';

const csrfProtection = csrf({ cookie: true });

app.get('/form', csrfProtection, (req, res) => {
  res.render('form', { csrfToken: req.csrfToken() });
});

app.post('/process', csrfProtection, (req, res) => {
  // Process form
});
```

### ✅ Set Proper CORS Headers
```typescript
// Bad - allowing all origins
app.use(cors({ origin: '*' }));

// Good - specific allowed origins
app.use(cors({
  origin: ['https://example.com', 'https://app.example.com'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Better - validate origin dynamically
app.use(cors({
  origin: (origin, callback) => {
    const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') ?? [];
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
}));
```

**Security Risk**: Open CORS policies allow malicious sites to make requests on behalf of users.

---

## Data Exposure Prevention

### ✅ Don't Return Sensitive Data
```typescript
// Bad - exposing password hash
interface User {
  id: string;
  email: string;
  password: string;
}

async function getUser(id: string): Promise<User> {
  return db.users.findById(id);
}

// Good - use separate types for public data
interface User {
  id: string;
  email: string;
  password: string;
  createdAt: Date;
}

type PublicUser = Omit<User, 'password'>;

async function getUser(id: string): Promise<PublicUser> {
  const user = await db.users.findById(id);
  const { password, ...publicUser } = user;
  return publicUser;
}

// Better - define public type separately
interface UserDTO {
  id: string;
  email: string;
  createdAt: Date;
}

function toUserDTO(user: User): UserDTO {
  return {
    id: user.id,
    email: user.email,
    createdAt: user.createdAt,
  };
}
```

### ✅ Validate Authorization
```typescript
// Bad - no authorization check
async function deleteUser(userId: string) {
  return db.users.delete(userId);
}

// Good - check permissions
async function deleteUser(currentUserId: string, targetUserId: string) {
  const currentUser = await db.users.findById(currentUserId);

  if (currentUser.role !== 'admin' && currentUserId !== targetUserId) {
    throw new Error('Unauthorized');
  }

  return db.users.delete(targetUserId);
}

// Better - use middleware/decorators
function requireAuth(role?: UserRole) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    if (role && req.user.role !== role) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    next();
  };
}

app.delete('/users/:id', requireAuth('admin'), async (req, res) => {
  await db.users.delete(req.params.id);
  res.json({ success: true });
});
```

**Security Risk**: Exposing sensitive data or allowing unauthorized actions can compromise user privacy and security.

---

## Dependency Security

### ✅ Regularly Audit Dependencies
```bash
# Check for vulnerabilities
npm audit

# Fix vulnerabilities
npm audit fix

# Check with yarn
yarn audit
```

### ✅ Use Exact Versions for Critical Dependencies
```json
// Bad - using ranges (can introduce vulnerabilities)
{
  "dependencies": {
    "express": "^4.18.0"
  }
}

// Good - exact versions for critical dependencies
{
  "dependencies": {
    "express": "4.18.2"
  }
}
```

### ✅ Minimize Dependencies
```typescript
// Bad - importing entire library
import _ from 'lodash';

// Good - import only what you need (tree-shaking)
import debounce from 'lodash/debounce';

// Better - consider if you need the dependency at all
function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout;
  return (...args: Parameters<T>) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => func(...args), wait);
  };
}
```

**Security Risk**: Each dependency is a potential attack vector; minimize and audit regularly.

---

## Path Traversal Prevention

### ✅ Validate File Paths
```typescript
// Bad - path traversal vulnerability
import path from 'path';
import fs from 'fs';

function readFile(filename: string): string {
  return fs.readFileSync(filename, 'utf-8');
}

// User could pass: '../../etc/passwd'

// Good - validate and normalize paths
function readFile(filename: string): string {
  const safeDir = '/app/uploads';
  const safePath = path.normalize(path.join(safeDir, filename));

  if (!safePath.startsWith(safeDir)) {
    throw new Error('Invalid file path');
  }

  return fs.readFileSync(safePath, 'utf-8');
}
```

**Security Risk**: Unvalidated file paths can allow access to sensitive system files.

---

## Type Safety as Security

### ✅ Use Type Guards for Runtime Safety
```typescript
// Bad - assuming structure
function processWebhook(data: any) {
  // No validation - could crash or be exploited
  return db.insert('events', data.payload);
}

// Good - validate structure
interface WebhookPayload {
  type: 'user.created' | 'user.updated';
  userId: string;
  timestamp: number;
}

function isWebhookPayload(data: unknown): data is WebhookPayload {
  return (
    typeof data === 'object' &&
    data !== null &&
    'type' in data &&
    (['user.created', 'user.updated'] as string[]).includes((data as any).type) &&
    'userId' in data &&
    typeof (data as any).userId === 'string' &&
    'timestamp' in data &&
    typeof (data as any).timestamp === 'number'
  );
}

function processWebhook(data: unknown) {
  if (!isWebhookPayload(data)) {
    throw new Error('Invalid webhook payload');
  }

  return db.insert('events', data);
}
```

### ✅ Use Tagged Template Literals for SQL
```typescript
// Good - template literals with proper escaping
import { sql } from 'your-db-library';

function getUserByEmail(email: string) {
  // The library ensures email is properly escaped
  return db.query(sql`SELECT * FROM users WHERE email = ${email}`);
}
```

---

## Logging & Monitoring Security

### ✅ Don't Log Sensitive Data
```typescript
// Bad - logging sensitive data
function login(email: string, password: string) {
  console.log(`Login attempt: ${email}:${password}`);
  // ...
}

// Good - log only non-sensitive data
function login(email: string, password: string) {
  console.log(`Login attempt for user: ${email}`);
  // ...
}

// Better - structured logging with redaction
import { logger } from './logger';

function login(email: string, password: string) {
  logger.info('Login attempt', {
    email,
    // Password is never logged
    timestamp: new Date().toISOString(),
  });
  // ...
}
```

### ✅ Implement Security Monitoring
```typescript
// Good - log security events
function logSecurityEvent(event: {
  type: 'login_failed' | 'unauthorized_access' | 'rate_limit_exceeded';
  userId?: string;
  ip: string;
  details?: Record<string, unknown>;
}) {
  logger.warn('Security event', {
    ...event,
    timestamp: new Date().toISOString(),
  });

  // Send to security monitoring service
  if (event.type === 'unauthorized_access') {
    securityMonitor.alert(event);
  }
}
```

---

## Security Headers

### ✅ Set Proper Security Headers
```typescript
// Good - using helmet middleware
import helmet from 'helmet';

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", 'data:', 'https:'],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true,
  },
}));

// Set additional headers
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  next();
});
```

---

## Security Review Checklist

- [ ] All user input is validated and sanitized
- [ ] No hardcoded secrets or credentials
- [ ] Environment variables are validated at startup
- [ ] SQL/NoSQL queries use parameterization
- [ ] Passwords are hashed (never stored in plain text)
- [ ] Authentication has rate limiting
- [ ] Session tokens are cryptographically secure
- [ ] CORS is properly configured (not allowing all origins)
- [ ] CSRF protection is implemented
- [ ] Sensitive data is not exposed in API responses
- [ ] Authorization checks are performed for all protected operations
- [ ] Dependencies are regularly audited for vulnerabilities
- [ ] File paths are validated (no path traversal)
- [ ] `eval()` and similar dangerous functions are not used
- [ ] HTML output is sanitized (XSS prevention)
- [ ] Security headers are set (CSP, HSTS, etc.)
- [ ] Sensitive data is not logged
- [ ] Error messages don't expose system details
- [ ] Type guards validate runtime data structure
- [ ] HTTPS is enforced in production

---

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)
- [TypeScript Security Guide](https://cheatsheetseries.owasp.org/cheatsheets/TypeScript_Cheat_Sheet.html)
- [npm Security Best Practices](https://docs.npmjs.com/security-best-practices)
