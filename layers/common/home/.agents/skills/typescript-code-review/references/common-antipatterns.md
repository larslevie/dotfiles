# TypeScript Common Anti-Patterns

Common mistakes and anti-patterns to avoid in TypeScript code, with explanations and better alternatives.

## Type System Anti-Patterns

### ❌ Using `any` as an Escape Hatch
```typescript
// Bad - defeats the purpose of TypeScript
function processData(data: any): any {
  return data.value * 2;
}

// Good - use unknown for truly unknown types
function processData(data: unknown): number {
  if (isValidData(data)) {
    return data.value * 2;
  }
  throw new Error('Invalid data');
}

function isValidData(data: unknown): data is { value: number } {
  return (
    typeof data === 'object' &&
    data !== null &&
    'value' in data &&
    typeof (data as { value: unknown }).value === 'number'
  );
}
```

**Why it's bad**: `any` disables type checking entirely, making TypeScript no better than JavaScript.

---

### ❌ Excessive Type Assertions
```typescript
// Bad - forcing types without validation
const user = data as User;
const name = user.name as string;
const age = user.age as number;

// Good - validate structure
function isUser(data: unknown): data is User {
  return (
    typeof data === 'object' &&
    data !== null &&
    'name' in data &&
    typeof (data as User).name === 'string' &&
    'age' in data &&
    typeof (data as User).age === 'number'
  );
}

if (isUser(data)) {
  const user = data; // Type is User
}
```

**Why it's bad**: Type assertions bypass type checking and can lead to runtime errors.

---

### ❌ Using Enums Incorrectly
```typescript
// Bad - regular enum (generates extra code and can cause issues)
enum Status {
  Pending,
  Approved,
  Rejected,
}

// Good - const enum (inlined at compile time)
const enum Status {
  Pending = 'PENDING',
  Approved = 'APPROVED',
  Rejected = 'REJECTED',
}

// Better - union type (no runtime code, better tree-shaking)
type Status = 'PENDING' | 'APPROVED' | 'REJECTED';

// Best - with const object for both types and values
const Status = {
  Pending: 'PENDING',
  Approved: 'APPROVED',
  Rejected: 'REJECTED',
} as const;

type Status = typeof Status[keyof typeof Status];
```

**Why it's bad**: Regular enums generate runtime code and can cause issues with module systems and tree-shaking.

---

### ❌ Not Handling Discriminated Unions Properly
```typescript
// Bad - no discriminator property
type Result =
  | { data: string }
  | { error: string };

function handle(result: Result) {
  if ('data' in result) {
    // TypeScript can't narrow this properly in all cases
    return result.data;
  }
}

// Good - use discriminator property
type Result =
  | { type: 'success'; data: string }
  | { type: 'error'; error: string };

function handle(result: Result) {
  if (result.type === 'success') {
    return result.data; // TypeScript knows this is success
  } else {
    throw new Error(result.error);
  }
}
```

**Why it's bad**: Without a discriminator, TypeScript can't reliably narrow the type.

---

## Async/Promise Anti-Patterns

### ❌ Mixing Callbacks and Promises
```typescript
// Bad - confusing mix of async styles
function fetchData(callback: (data: Data) => void): Promise<void> {
  return fetch('/api/data')
    .then(response => response.json())
    .then(data => callback(data));
}

// Good - use async/await consistently
async function fetchData(): Promise<Data> {
  const response = await fetch('/api/data');
  return response.json();
}
```

**Why it's bad**: Mixing async patterns makes code harder to understand and maintain.

---

### ❌ Not Handling Promise Rejections
```typescript
// Bad - unhandled promise rejection
async function loadUser() {
  const user = await fetchUser(); // May throw, but not handled
  return user;
}

// Good - proper error handling
async function loadUser(): Promise<User> {
  try {
    const user = await fetchUser();
    return user;
  } catch (error) {
    if (error instanceof Error) {
      console.error('Failed to load user:', error.message);
    }
    throw error; // Re-throw or handle appropriately
  }
}
```

**Why it's bad**: Unhandled promise rejections can crash your application or cause unexpected behavior.

---

### ❌ Sequential Awaits When Parallel Is Possible
```typescript
// Bad - sequential execution (slow)
async function getData() {
  const users = await fetchUsers();
  const posts = await fetchPosts();
  const comments = await fetchComments();
  return { users, posts, comments };
}

// Good - parallel execution (fast)
async function getData() {
  const [users, posts, comments] = await Promise.all([
    fetchUsers(),
    fetchPosts(),
    fetchComments(),
  ]);
  return { users, posts, comments };
}
```

**Why it's bad**: Sequential awaits waste time when operations could run concurrently.

---

## Function Anti-Patterns

### ❌ Optional Parameters Before Required Ones
```typescript
// Bad - optional before required
function createUser(name?: string, id: string) {
  // ...
}

// Good - required before optional
function createUser(id: string, name?: string) {
  // ...
}

// Or use object parameter
function createUser(params: { id: string; name?: string }) {
  // ...
}
```

**Why it's bad**: Optional parameters must come after required ones in JavaScript.

---

### ❌ Too Many Parameters
```typescript
// Bad - too many parameters
function createUser(
  id: string,
  name: string,
  email: string,
  age: number,
  address: string,
  phone: string,
  role: string
) {
  // ...
}

// Good - use object parameter
interface CreateUserParams {
  id: string;
  name: string;
  email: string;
  age: number;
  address: string;
  phone: string;
  role: string;
}

function createUser(params: CreateUserParams) {
  // ...
}
```

**Why it's bad**: Many parameters are hard to remember and prone to mistakes. Object parameters with named properties are clearer.

---

### ❌ Boolean Flags for Behavior
```typescript
// Bad - boolean flag changes behavior
function getUsers(includeInactive: boolean) {
  if (includeInactive) {
    return allUsers;
  }
  return activeUsers;
}

// Good - separate functions with clear names
function getAllUsers() {
  return allUsers;
}

function getActiveUsers() {
  return activeUsers;
}

// Or use discriminated union for complex cases
type UserFilter =
  | { type: 'all' }
  | { type: 'active' }
  | { type: 'byRole'; role: string };

function getUsers(filter: UserFilter) {
  switch (filter.type) {
    case 'all': return allUsers;
    case 'active': return activeUsers;
    case 'byRole': return allUsers.filter(u => u.role === filter.role);
  }
}
```

**Why it's bad**: Boolean flags make function behavior unclear and harder to extend.

---

## Array Anti-Patterns

### ❌ Mutating Arrays Instead of Creating New Ones
```typescript
// Bad - mutates original array
function addUser(users: User[], newUser: User) {
  users.push(newUser);
  return users;
}

// Good - creates new array
function addUser(users: User[], newUser: User): User[] {
  return [...users, newUser];
}

// Or use readonly arrays to prevent mutation
function addUser(users: readonly User[], newUser: User): User[] {
  return [...users, newUser];
}
```

**Why it's bad**: Mutations can cause unexpected side effects and make code harder to reason about.

---

### ❌ Using `Array.forEach` When Other Methods Are Better
```typescript
// Bad - forEach for mapping
const names: string[] = [];
users.forEach(user => {
  names.push(user.name);
});

// Good - use map
const names = users.map(user => user.name);

// Bad - forEach for filtering
const active: User[] = [];
users.forEach(user => {
  if (user.isActive) {
    active.push(user);
  }
});

// Good - use filter
const active = users.filter(user => user.isActive);
```

**Why it's bad**: `map`, `filter`, and `reduce` are more declarative and better express intent.

---

## Object Anti-Patterns

### ❌ Mutating Objects Instead of Spreading
```typescript
// Bad - mutates original object
function updateUser(user: User, updates: Partial<User>): User {
  Object.assign(user, updates);
  return user;
}

// Good - creates new object
function updateUser(user: User, updates: Partial<User>): User {
  return { ...user, ...updates };
}
```

**Why it's bad**: Mutations can cause unexpected side effects.

---

### ❌ Using `delete` to Remove Properties
```typescript
// Bad - delete is slow and mutable
function removePassword(user: User): PublicUser {
  const result = { ...user };
  delete result.password;
  return result;
}

// Good - use destructuring and rest
function removePassword(user: User): PublicUser {
  const { password, ...publicUser } = user;
  return publicUser;
}

// Better - use Omit utility type
type PublicUser = Omit<User, 'password'>;

function removePassword(user: User): PublicUser {
  const { password, ...publicUser } = user;
  return publicUser;
}
```

**Why it's bad**: `delete` is slow, mutable, and can confuse type inference.

---

## Class Anti-Patterns

### ❌ Using Classes When Interfaces Would Suffice
```typescript
// Bad - unnecessary class for data structure
class User {
  id: string;
  name: string;
  email: string;

  constructor(id: string, name: string, email: string) {
    this.id = id;
    this.name = name;
    this.email = email;
  }
}

// Good - simple interface
interface User {
  id: string;
  name: string;
  email: string;
}

// Create with object literal
const user: User = {
  id: '1',
  name: 'Alice',
  email: 'alice@example.com',
};

// Or factory function if needed
function createUser(id: string, name: string, email: string): User {
  return { id, name, email };
}
```

**Why it's bad**: Classes add unnecessary complexity for simple data structures.

---

### ❌ Not Using Parameter Properties
```typescript
// Bad - verbose constructor
class User {
  id: string;
  name: string;
  email: string;

  constructor(id: string, name: string, email: string) {
    this.id = id;
    this.name = name;
    this.email = email;
  }
}

// Good - parameter properties
class User {
  constructor(
    public id: string,
    public name: string,
    public email: string
  ) {}
}
```

**Why it's bad**: Parameter properties are more concise and reduce boilerplate.

---

## Import/Export Anti-Patterns

### ❌ Barrel Exports with Side Effects
```typescript
// Bad - index.ts barrel export
export * from './module1';
export * from './module2';
export * from './module3';
// ...100 more modules

// Problem: importing one thing loads everything
import { oneFunction } from './modules'; // Loads all 100+ modules
```

**Why it's bad**: Barrel exports can hurt performance by forcing unnecessary code to load.

**Solution**: Import directly from the module you need:
```typescript
import { oneFunction } from './modules/module1';
```

---

### ❌ Not Using Type-Only Imports
```typescript
// Bad - imports type as value (may be bundled in JS)
import { User } from './types';

function greet(user: User) {
  console.log(`Hello, ${user.name}`);
}

// Good - type-only import
import type { User } from './types';

function greet(user: User) {
  console.log(`Hello, ${user.name}`);
}
```

**Why it's bad**: Without `import type`, bundlers may include unnecessary code in the output.

---

### ❌ Circular Dependencies
```typescript
// Bad - file1.ts
import { functionB } from './file2';

export function functionA() {
  return functionB();
}

// Bad - file2.ts
import { functionA } from './file1';

export function functionB() {
  return functionA();
}
```

**Why it's bad**: Circular dependencies can cause initialization issues and make code harder to understand.

**Solution**: Extract shared code to a third module or refactor to remove the cycle.

---

## Error Handling Anti-Patterns

### ❌ Catching Errors Without Proper Typing
```typescript
// Bad - error is unknown type
try {
  await fetchData();
} catch (error) {
  console.log(error.message); // Error: 'error' is of type 'unknown'
}

// Good - check error type before using
try {
  await fetchData();
} catch (error) {
  if (error instanceof Error) {
    console.log(error.message);
  } else {
    console.log('An unknown error occurred');
  }
}
```

**Why it's bad**: TypeScript 4.4+ made catch clause variables `unknown` by default for safety.

---

### ❌ Throwing Non-Error Objects
```typescript
// Bad - throwing string
if (!user) {
  throw 'User not found';
}

// Bad - throwing plain object
if (!user) {
  throw { message: 'User not found', code: 404 };
}

// Good - throw Error objects
if (!user) {
  throw new Error('User not found');
}

// Better - custom error class
class UserNotFoundError extends Error {
  constructor(public userId: string) {
    super(`User not found: ${userId}`);
    this.name = 'UserNotFoundError';
  }
}

if (!user) {
  throw new UserNotFoundError(userId);
}
```

**Why it's bad**: Non-Error objects don't have stack traces and aren't handled well by error monitoring tools.

---

## Type Inference Anti-Patterns

### ❌ Over-Specifying Types
```typescript
// Bad - unnecessary type annotations
const name: string = 'Alice';
const age: number = 30;
const isActive: boolean = true;

// Good - let TypeScript infer
const name = 'Alice';
const age = 30;
const isActive = true;
```

**Why it's bad**: TypeScript can infer these types, adding annotations adds noise.

**Note**: Still annotate function parameters and return types!

---

### ❌ Not Using Type Narrowing
```typescript
// Bad - repeated type guards
function processValue(value: string | number) {
  if (typeof value === 'string') {
    return value.toUpperCase();
  }

  if (typeof value === 'number') {
    return value.toFixed(2);
  }
}

// Good - exhaustive check with else
function processValue(value: string | number): string {
  if (typeof value === 'string') {
    return value.toUpperCase();
  } else {
    // TypeScript knows value is number here
    return value.toFixed(2);
  }
}
```

**Why it's bad**: TypeScript can narrow types based on control flow; use it!

---

## Performance Anti-Patterns

### ❌ Expensive Type Calculations
```typescript
// Bad - deeply recursive type that slows compilation
type DeepPartial<T> = T extends object
  ? { [P in keyof T]?: DeepPartial<T[P]> }
  : T;

// Use on very nested objects (slow)
type Config = DeepPartial<VeryNestedConfig>;

// Good - limit recursion depth or use simpler types
type PartialConfig = Partial<VeryNestedConfig>;
```

**Why it's bad**: Complex type calculations can significantly slow down TypeScript compilation.

---

### ❌ Not Using `const` Assertions for Literal Types
```typescript
// Bad - loses literal types
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
};
// config.apiUrl is type 'string'

// Good - preserves literal types
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
} as const;
// config.apiUrl is type 'https://api.example.com'
```

**Why it's bad**: Without `as const`, literal types are widened to their base types.

---

## Testing Anti-Patterns

### ❌ Using `any` in Tests
```typescript
// Bad - defeats type safety in tests
const mockUser: any = {
  name: 'Alice',
};

// Good - proper typing
const mockUser: User = {
  id: '1',
  name: 'Alice',
  email: 'alice@example.com',
  createdAt: new Date(),
};
```

**Why it's bad**: Tests should verify types too; `any` hides potential type errors.

---

### ❌ Not Testing Type Failures
```typescript
// Good - use @ts-expect-error to test invalid usage
// @ts-expect-error - should not accept number
createUser(123);

// @ts-expect-error - should require email
createUser({ name: 'Alice' });
```

**Why it's good**: Ensures your types prevent invalid usage as expected.

---

## Key Takeaways

- Avoid `any`; use `unknown` for truly unknown types
- Use discriminated unions with type narrowing
- Prefer immutability and functional patterns
- Use type-only imports for better tree-shaking
- Throw Error objects, not strings or plain objects
- Let TypeScript infer types when possible, but always annotate functions
- Use const assertions for literal types
- Avoid circular dependencies
- Use utility types (`Partial`, `Pick`, `Omit`) instead of manual type manipulation
- Handle async operations consistently with async/await
- Test your types, not just your logic
