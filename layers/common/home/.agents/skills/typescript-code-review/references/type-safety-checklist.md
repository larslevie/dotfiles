# TypeScript Type Safety Checklist

Comprehensive checklist for reviewing type safety in TypeScript code.

## Strict Mode Configuration

### Essential tsconfig.json Settings
```json
{
  "compilerOptions": {
    "strict": true,                              // Enables all strict checks
    "noUncheckedIndexedAccess": true,           // Index signatures return T | undefined
    "noImplicitOverride": true,                 // Require override keyword
    "noPropertyAccessFromIndexSignature": true, // Require bracket notation for index signatures
    "exactOptionalPropertyTypes": true,         // Optional properties can't be set to undefined
    "noFallthroughCasesInSwitch": true,        // Catch missing break statements
    "noImplicitReturns": true,                  // All code paths must return a value
    "noUnusedLocals": true,                     // Flag unused local variables
    "noUnusedParameters": true                  // Flag unused function parameters
  }
}
```

## Type Annotation Best Practices

### ✅ DO: Explicit Return Types
```typescript
// Good - explicit return type
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Avoid - implicit return type (harder to catch errors)
function calculateTotal(items: Item[]) {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

### ✅ DO: Avoid `any`
```typescript
// Bad - loses type safety
function processData(data: any): any {
  return data.value * 2;
}

// Good - use unknown for truly unknown types
function processData(data: unknown): number {
  if (typeof data === 'object' && data !== null && 'value' in data) {
    const obj = data as { value: unknown };
    if (typeof obj.value === 'number') {
      return obj.value * 2;
    }
  }
  throw new Error('Invalid data');
}

// Better - define the type
interface Data {
  value: number;
}

function processData(data: Data): number {
  return data.value * 2;
}
```

### ✅ DO: Use Type Guards
```typescript
// Type guard for custom types
interface Cat {
  meow(): void;
}

interface Dog {
  bark(): void;
}

type Animal = Cat | Dog;

// Type predicate
function isCat(animal: Animal): animal is Cat {
  return 'meow' in animal;
}

function makeSound(animal: Animal): void {
  if (isCat(animal)) {
    animal.meow(); // TypeScript knows this is Cat
  } else {
    animal.bark(); // TypeScript knows this is Dog
  }
}
```

### ✅ DO: Exhaustiveness Checking
```typescript
type Status = 'pending' | 'approved' | 'rejected';

function handleStatus(status: Status): string {
  switch (status) {
    case 'pending':
      return 'Processing...';
    case 'approved':
      return 'Approved!';
    case 'rejected':
      return 'Rejected!';
    default:
      // This will error if a new status is added but not handled
      const exhaustiveCheck: never = status;
      throw new Error(`Unhandled status: ${exhaustiveCheck}`);
  }
}
```

## Null and Undefined Handling

### ✅ DO: Optional Chaining
```typescript
// Good - safe navigation
const street = user?.address?.street;

// Avoid - manual null checks
const street = user && user.address && user.address.street;
```

### ✅ DO: Nullish Coalescing
```typescript
// Good - only replaces null/undefined
const displayName = user.name ?? 'Guest';

// Avoid - also replaces empty string, 0, false
const displayName = user.name || 'Guest';
```

### ✅ DO: Non-Null Assertion Sparingly
```typescript
// Avoid unless absolutely certain
const element = document.getElementById('myId')!;

// Better - handle the null case
const element = document.getElementById('myId');
if (!element) {
  throw new Error('Element not found');
}
```

## Generic Types

### ✅ DO: Constrain Generics
```typescript
// Bad - too permissive
function getProperty<T>(obj: T, key: string) {
  return obj[key]; // Error: obj is not indexable
}

// Good - constrain to objects with string keys
function getProperty<T extends Record<string, unknown>, K extends keyof T>(
  obj: T,
  key: K
): T[K] {
  return obj[key];
}
```

### ✅ DO: Use Generic Defaults
```typescript
interface ApiResponse<T = unknown> {
  data: T;
  status: number;
}

// Can be used without specifying type
const response: ApiResponse = await fetch('/api/data');

// Or with specific type
const response: ApiResponse<User> = await fetch('/api/user');
```

## Union and Intersection Types

### ✅ DO: Discriminated Unions
```typescript
interface Success {
  type: 'success';
  data: string;
}

interface Error {
  type: 'error';
  message: string;
}

type Result = Success | Error;

function handleResult(result: Result): void {
  if (result.type === 'success') {
    console.log(result.data); // TypeScript knows this is Success
  } else {
    console.log(result.message); // TypeScript knows this is Error
  }
}
```

### ✅ DO: Intersection Types for Mixins
```typescript
interface Timestamped {
  createdAt: Date;
  updatedAt: Date;
}

interface User {
  id: string;
  name: string;
}

type TimestampedUser = User & Timestamped;

const user: TimestampedUser = {
  id: '1',
  name: 'Alice',
  createdAt: new Date(),
  updatedAt: new Date(),
};
```

## Array and Tuple Types

### ✅ DO: Proper Array Typing
```typescript
// Bad - implicit any[]
const numbers = [];

// Good - explicit type
const numbers: number[] = [];

// Also good - using Array generic
const numbers: Array<number> = [];
```

### ✅ DO: Use Tuples for Fixed-Length Arrays
```typescript
// Good - tuple with specific types
type Point = [number, number];
type NamedPoint = [x: number, y: number]; // With labels (TS 4.0+)

function distance(p1: Point, p2: Point): number {
  const [x1, y1] = p1;
  const [x2, y2] = p2;
  return Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2);
}
```

### ✅ DO: Handle Array Indices Safely
```typescript
// With noUncheckedIndexedAccess: true
const numbers: number[] = [1, 2, 3];
const first = numbers[0]; // Type: number | undefined

// Handle undefined case
if (first !== undefined) {
  console.log(first * 2);
}

// Or use optional chaining
console.log(numbers[0]?.toFixed(2));
```

## Object Types

### ✅ DO: Use Interfaces for Object Shapes
```typescript
// Good - interface for object structure
interface User {
  id: string;
  name: string;
  email: string;
}

// Good - type alias for unions/intersections
type UserOrGuest = User | { id: 'guest'; name: 'Guest' };
```

### ✅ DO: Index Signatures with Caution
```typescript
// Avoid - too loose
interface Config {
  [key: string]: string;
}

// Better - use Record utility type
type Config = Record<string, string>;

// Best - define known properties
interface Config {
  apiUrl: string;
  timeout: string;
  // Optional index signature for additional properties
  [key: string]: string;
}
```

### ✅ DO: Use Utility Types
```typescript
interface User {
  id: string;
  name: string;
  email: string;
  password: string;
}

// Pick only needed properties
type UserProfile = Pick<User, 'id' | 'name' | 'email'>;

// Omit sensitive properties
type PublicUser = Omit<User, 'password'>;

// Make all properties optional
type PartialUser = Partial<User>;

// Make all properties required
type RequiredUser = Required<Partial<User>>;

// Make all properties readonly
type ImmutableUser = Readonly<User>;
```

## Function Types

### ✅ DO: Proper Function Signatures
```typescript
// Good - explicit parameter and return types
function greet(name: string): string {
  return `Hello, ${name}`;
}

// Good - arrow function with types
const greet = (name: string): string => `Hello, ${name}`;

// Good - function type alias
type GreetFunction = (name: string) => string;
const greet: GreetFunction = (name) => `Hello, ${name}`;
```

### ✅ DO: Optional and Default Parameters
```typescript
// Optional parameters
function greet(name: string, title?: string): string {
  return title ? `Hello, ${title} ${name}` : `Hello, ${name}`;
}

// Default parameters (type inferred from default value)
function greet(name: string, title = 'Mr.'): string {
  return `Hello, ${title} ${name}`;
}
```

### ✅ DO: Rest Parameters
```typescript
function sum(...numbers: number[]): number {
  return numbers.reduce((acc, n) => acc + n, 0);
}

// With tuple types for varied parameters
function createUser(name: string, ...roles: string[]): User {
  return { name, roles };
}
```

## Async/Promise Types

### ✅ DO: Type Async Functions Properly
```typescript
// Good - explicit return type
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}

// Good - with error handling
async function fetchUser(id: string): Promise<User> {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      throw new Error('Failed to fetch user');
    }
    return response.json();
  } catch (error) {
    // Type-safe error handling
    if (error instanceof Error) {
      console.error(error.message);
    }
    throw error;
  }
}
```

## Class Types

### ✅ DO: Use Access Modifiers
```typescript
class User {
  // Public by default
  public id: string;

  // Protected - accessible in subclasses
  protected createdAt: Date;

  // Private - only accessible in this class
  private password: string;

  // Readonly - cannot be modified after initialization
  readonly email: string;

  constructor(id: string, email: string, password: string) {
    this.id = id;
    this.email = email;
    this.password = password;
    this.createdAt = new Date();
  }

  // Parameter properties shorthand
  // constructor(
  //   public id: string,
  //   readonly email: string,
  //   private password: string
  // ) {
  //   this.createdAt = new Date();
  // }
}
```

### ✅ DO: Use Abstract Classes
```typescript
abstract class Animal {
  abstract makeSound(): void;

  move(): void {
    console.log('Moving...');
  }
}

class Cat extends Animal {
  makeSound(): void {
    console.log('Meow');
  }
}
```

## Type Assertions

### ⚠️ AVOID: Unnecessary Type Assertions
```typescript
// Bad - unnecessary assertion
const user = getUser() as User;

// Good - assertion only when necessary
const element = document.getElementById('myId') as HTMLInputElement;

// Better - use type guards
if (element instanceof HTMLInputElement) {
  element.value = 'text';
}
```

### ✅ DO: Use `satisfies` Operator (TS 4.9+)
```typescript
// Bad - loses literal types
const config: Record<string, string> = {
  apiUrl: 'https://api.example.com',
  timeout: '5000',
};
// config.apiUrl has type string, not the literal

// Good - preserves literal types while validating structure
const config = {
  apiUrl: 'https://api.example.com',
  timeout: '5000',
} satisfies Record<string, string>;
// config.apiUrl has type 'https://api.example.com'
```

## Literal Types

### ✅ DO: Use Const Assertions
```typescript
// Without const assertion
const colors = ['red', 'green', 'blue']; // Type: string[]

// With const assertion
const colors = ['red', 'green', 'blue'] as const; // Type: readonly ["red", "green", "blue"]

// Use in type definitions
type Color = typeof colors[number]; // Type: "red" | "green" | "blue"
```

## Template Literal Types

### ✅ DO: Use Template Literal Types (TS 4.1+)
```typescript
type Vertical = 'top' | 'middle' | 'bottom';
type Horizontal = 'left' | 'center' | 'right';

// Combine with template literals
type Position = `${Vertical}-${Horizontal}`;
// Type: "top-left" | "top-center" | "top-right" | "middle-left" | ...
```

## Common Type Safety Issues

### ❌ Implicit Any
```typescript
// Bad
function process(data) { // Implicit any
  return data.value;
}

// Good
function process(data: { value: number }): number {
  return data.value;
}
```

### ❌ Type Widening
```typescript
// Bad - type widened to string
let status = 'pending';
status = 'approved'; // OK, but loses specificity

// Good - explicit literal type
let status: 'pending' | 'approved' | 'rejected' = 'pending';

// Good - const assertion
const status = 'pending' as const; // Type: 'pending'
```

### ❌ Unsafe Type Coercion
```typescript
// Bad - unsafe conversion
const value: number = someValue as number;

// Good - validate before converting
function toNumber(value: unknown): number {
  if (typeof value === 'number') {
    return value;
  }
  throw new Error('Value is not a number');
}
```

## Key Review Points

- [ ] All functions have explicit return types
- [ ] No implicit `any` types (check with `noImplicitAny`)
- [ ] Proper null/undefined handling with `?.` and `??`
- [ ] Type guards used for narrowing unions
- [ ] Exhaustiveness checking for discriminated unions
- [ ] Generics are properly constrained
- [ ] Array indices handled safely (with `noUncheckedIndexedAccess`)
- [ ] Type assertions used only when necessary
- [ ] Proper async/Promise typing
- [ ] Utility types used where appropriate (`Pick`, `Omit`, `Partial`, etc.)
- [ ] `satisfies` operator used instead of type assertions where possible
- [ ] Const assertions for literal types
- [ ] Template literal types for string combinations
- [ ] Readonly modifiers for immutable data
- [ ] Strict mode enabled in `tsconfig.json`
