# Sample Code Review Output

This is an example of what a TypeScript code review output should look like when using this skill.

---

## Summary

The codebase shows a functional implementation but has several critical type safety issues and security vulnerabilities that need to be addressed. The code lacks proper input validation, uses unsafe type assertions, and has potential XSS and SQL injection vulnerabilities. Additionally, there are performance concerns with nested loops and memory leaks from uncleaned event listeners.

**Overall Assessment**: Requires significant improvements before production deployment.

---

## Critical Issues 🔴

### 1. SQL Injection Vulnerability
**File**: `src/database/users.ts:45`

**Issue**: Using string concatenation for SQL queries allows SQL injection attacks.

**Current code**:
```typescript
export function getUserByEmail(email: string) {
  return db.query(`SELECT * FROM users WHERE email = '${email}'`);
}
```

**Recommended**:
```typescript
export function getUserByEmail(email: string): Promise<User | null> {
  // Use parameterized query
  return db.query('SELECT * FROM users WHERE email = $1', [email]);
}
```

**Reasoning**: String interpolation in SQL queries allows attackers to inject malicious SQL code. Parameterized queries ensure email is treated as data, not code.

---

### 2. XSS Vulnerability
**File**: `src/components/Comment.ts:12`

**Issue**: Directly inserting user content into innerHTML without sanitization.

**Current code**:
```typescript
export function displayComment(comment: string) {
  document.getElementById('comment')!.innerHTML = comment;
}
```

**Recommended**:
```typescript
export function displayComment(comment: string): void {
  const element = document.getElementById('comment');
  if (!element) {
    throw new Error('Comment element not found');
  }

  // For plain text, use textContent
  element.textContent = comment;

  // Or if HTML is needed, sanitize it
  // import DOMPurify from 'dompurify';
  // element.innerHTML = DOMPurify.sanitize(comment);
}
```

**Reasoning**: Unsanitized user input in innerHTML can execute malicious scripts, compromising user security and privacy.

---

### 3. Hardcoded API Key
**File**: `src/api/client.ts:3`

**Issue**: API key is hardcoded in source code and will be exposed in version control.

**Current code**:
```typescript
const API_KEY = 'sk_live_1234567890abcdef';
```

**Recommended**:
```typescript
const API_KEY = process.env.API_KEY;

if (!API_KEY) {
  throw new Error('API_KEY environment variable is not set');
}
```

**Reasoning**: Hardcoded secrets in source code can be exposed through version control, logs, or bundled code. Always use environment variables for sensitive data.

---

### 4. Missing Error Handling in Async Function
**File**: `src/api/users.ts:23`

**Issue**: No error handling for network failures or invalid responses.

**Current code**:
```typescript
export async function fetchUser(id: string) {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}
```

**Recommended**:
```typescript
export async function fetchUser(id: string): Promise<User> {
  try {
    const response = await fetch(`/api/users/${id}`);

    if (!response.ok) {
      throw new Error(`Failed to fetch user: ${response.statusText}`);
    }

    const data = await response.json();

    if (!isUser(data)) {
      throw new Error('Invalid user data from API');
    }

    return data;
  } catch (error) {
    if (error instanceof Error) {
      console.error('Error fetching user:', error.message);
    }
    throw error;
  }
}
```

**Reasoning**: Network requests can fail for many reasons. Proper error handling prevents crashes and provides better user experience.

---

## Important Improvements 🟡

### 5. Using `any` Type Defeats TypeScript's Purpose
**File**: `src/utils/data.ts:8`

**Issue**: Using `any` disables all type checking.

**Current code**:
```typescript
export function processData(data: any) {
  return data.value * 2;
}
```

**Recommended**:
```typescript
interface DataInput {
  value: number;
}

function isValidDataInput(data: unknown): data is DataInput {
  return (
    typeof data === 'object' &&
    data !== null &&
    'value' in data &&
    typeof (data as DataInput).value === 'number'
  );
}

export function processData(data: unknown): number {
  if (!isValidDataInput(data)) {
    throw new Error('Invalid data input');
  }
  return data.value * 2;
}
```

**Reasoning**: `any` removes type safety. Use `unknown` with type guards to maintain type safety while handling unknown data.

---

### 6. Inefficient Algorithm (O(n²) Complexity)
**File**: `src/utils/arrays.ts:15`

**Issue**: Nested loops create quadratic time complexity, which doesn't scale well.

**Current code**:
```typescript
export function findCommonItems(list1: string[], list2: string[]) {
  const common = [];
  for (const item1 of list1) {
    for (const item2 of list2) {
      if (item1 === item2) {
        common.push(item1);
      }
    }
  }
  return common;
}
```

**Recommended**:
```typescript
export function findCommonItems(list1: string[], list2: string[]): string[] {
  const set2 = new Set(list2);
  return list1.filter(item => set2.has(item));
}
```

**Reasoning**: Using a Set reduces complexity from O(n²) to O(n), dramatically improving performance for large arrays.

---

### 7. Missing Return Type Annotation
**File**: `src/utils/calculate.ts:5`

**Issue**: Function lacks explicit return type, making it harder to catch errors.

**Current code**:
```typescript
export function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

**Recommended**:
```typescript
interface Item {
  price: number;
}

export function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

**Reasoning**: Explicit return types catch errors at function boundaries and improve code documentation.

---

### 8. Memory Leak - Event Listener Not Cleaned Up
**File**: `src/utils/resize.ts:7`

**Issue**: Event listener is added but never removed, causing a memory leak.

**Current code**:
```typescript
export function setupListener() {
  window.addEventListener('resize', handleResize);
}
```

**Recommended**:
```typescript
export function setupListener(): () => void {
  const handleResize = () => {
    console.log('Window resized');
  };

  window.addEventListener('resize', handleResize);

  // Return cleanup function
  return () => {
    window.removeEventListener('resize', handleResize);
  };
}

// Usage:
// const cleanup = setupListener();
// cleanup(); // Call when component unmounts
```

**Reasoning**: Event listeners that aren't cleaned up prevent garbage collection, causing memory leaks in long-running applications.

---

## Suggestions 🔵

### 9. Use Union Type Instead of Enum
**File**: `src/types/roles.ts:3`

**Issue**: Regular enums generate runtime code and can cause tree-shaking issues.

**Current code**:
```typescript
export enum UserRole {
  Admin,
  User,
  Guest,
}
```

**Recommended**:
```typescript
// Option 1: Simple union type
export type UserRole = 'admin' | 'user' | 'guest';

// Option 2: If you need both types and values
export const UserRole = {
  Admin: 'admin',
  User: 'user',
  Guest: 'guest',
} as const;

export type UserRole = typeof UserRole[keyof typeof UserRole];
```

**Reasoning**: Union types are lighter and tree-shake better. They're the modern TypeScript approach for literal values.

---

### 10. Use Const Assertion for Better Type Inference
**File**: `src/config/app.ts:1`

**Issue**: Object literals are widened to general types instead of specific literals.

**Current code**:
```typescript
export const CONFIG = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
};
// CONFIG.apiUrl has type: string
```

**Recommended**:
```typescript
export const CONFIG = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
} as const;
// CONFIG.apiUrl has type: 'https://api.example.com'
```

**Reasoning**: `as const` preserves literal types and makes objects readonly, improving type safety.

---

### 11. Mutating Input Parameters
**File**: `src/utils/arrays.ts:23`

**Issue**: Function mutates the input array, which can cause unexpected side effects.

**Current code**:
```typescript
export function addItem(items: string[], newItem: string) {
  items.push(newItem);
  return items;
}
```

**Recommended**:
```typescript
export function addItem(items: readonly string[], newItem: string): string[] {
  return [...items, newItem];
}
```

**Reasoning**: Immutable operations prevent unexpected side effects and make code easier to reason about. The `readonly` modifier prevents accidental mutations.

---

### 12. Sequential Awaits When Parallel Is Possible
**File**: `src/api/loader.ts:10`

**Issue**: Three independent API calls are made sequentially, wasting time.

**Current code**:
```typescript
export async function loadData() {
  const users = await fetchUsers();
  const posts = await fetchPosts();
  const comments = await fetchComments();
  return { users, posts, comments };
}
```

**Recommended**:
```typescript
export async function loadData(): Promise<{
  users: User[];
  posts: Post[];
  comments: Comment[];
}> {
  const [users, posts, comments] = await Promise.all([
    fetchUsers(),
    fetchPosts(),
    fetchComments(),
  ]);

  return { users, posts, comments };
}
```

**Reasoning**: Parallel execution with `Promise.all` significantly reduces total loading time when operations are independent.

---

## Positive Observations ✅

1. **Good use of interfaces**: The `User` and `Post` interfaces are well-defined with appropriate property types.

2. **Consistent naming**: Variable and function names follow clear camelCase conventions throughout the codebase.

3. **Modular structure**: Code is well-organized into logical modules (api/, utils/, types/).

4. **TypeScript strict mode**: `tsconfig.json` has `strict: true` enabled, which is excellent for type safety.

---

## Configuration Recommendations

### tsconfig.json
Consider adding these additional strict checks:

```json
{
  "compilerOptions": {
    "strict": true, // ✅ Already enabled
    "noUncheckedIndexedAccess": true, // Add: Makes array indices return T | undefined
    "noImplicitOverride": true, // Add: Requires override keyword
    "noFallthroughCasesInSwitch": true, // Add: Catches missing break statements
    "exactOptionalPropertyTypes": true // Add: Stricter optional property handling
  }
}
```

### Tooling Recommendations

1. **ESLint**: Add `@typescript-eslint/eslint-plugin` with recommended rules
2. **Prettier**: Add for consistent code formatting
3. **husky + lint-staged**: Run linting before commits
4. **npm audit**: Run regularly to check for dependency vulnerabilities

---

## Next Steps

### Immediate Actions (Critical Issues)
1. Fix SQL injection vulnerability in `getUserByEmail` (security risk)
2. Fix XSS vulnerability in `displayComment` (security risk)
3. Move API key to environment variables (security risk)
4. Add error handling to `fetchUser` (reliability)

### Short-term Improvements (Important)
5. Replace `any` types with proper type definitions
6. Optimize `findCommonItems` algorithm
7. Add explicit return types to all functions
8. Fix memory leak in event listener setup

### Long-term Enhancements (Suggestions)
9. Refactor enums to union types
10. Add const assertions where appropriate
11. Make array operations immutable
12. Parallelize independent async operations

---

## Summary Statistics

- **Total Issues Found**: 12
- **Critical**: 4 (Security: 3, Reliability: 1)
- **Important**: 4 (Type Safety: 2, Performance: 1, Memory: 1)
- **Suggestions**: 4 (Code Quality improvements)
- **Lines Reviewed**: ~250
- **Estimated Fix Time**: 4-6 hours
