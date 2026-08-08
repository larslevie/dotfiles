// Example TypeScript file after code review fixes
// This demonstrates best practices and proper implementations

// Fix 1: Proper type definition with validation
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

// Fix 2: Explicit types for parameters and return value
interface Item {
  price: number;
}

export function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Fix 3: Proper null/undefined handling with optional chaining
export function getUserName(user: User | undefined): string {
  return user?.name.toUpperCase() ?? 'Unknown';
}

// Fix 4: Optimized algorithm using Set (O(n) instead of O(n²))
export function findCommonItems(list1: string[], list2: string[]): string[] {
  const set2 = new Set(list2);
  return list1.filter(item => set2.has(item));
}

// Fix 5: Use union type instead of enum (no runtime code)
export type UserRole = 'admin' | 'user' | 'guest';

// Or if you need both types and values:
export const UserRole = {
  Admin: 'admin',
  User: 'user',
  Guest: 'guest',
} as const;

export type UserRoleType = typeof UserRole[keyof typeof UserRole];

// Fix 6: Immutable operations (create new array)
export function addItem(items: readonly string[], newItem: string): string[] {
  return [...items, newItem];
}

// Fix 7: Discriminated union with type property
export type ApiResponse =
  | { type: 'success'; data: string }
  | { type: 'error'; error: string };

export function handleResponse(response: ApiResponse): string {
  if (response.type === 'success') {
    return response.data;
  }
  throw new Error(response.error);
}

// Fix 8: Proper error handling in async function
export async function fetchUser(id: string): Promise<User> {
  try {
    const response = await fetch(`/api/users/${id}`);

    if (!response.ok) {
      throw new Error(`Failed to fetch user: ${response.statusText}`);
    }

    return response.json();
  } catch (error) {
    if (error instanceof Error) {
      console.error('Error fetching user:', error.message);
    }
    throw error;
  }
}

// Fix 9: Parallel requests with Promise.all
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

// Fix 10: Type guard instead of type assertion
export function getElement(id: string): HTMLInputElement | null {
  const element = document.getElementById(id);

  if (element instanceof HTMLInputElement) {
    return element;
  }

  return null;
}

// Or throw error if element must exist:
export function getRequiredElement(id: string): HTMLInputElement {
  const element = document.getElementById(id);

  if (!(element instanceof HTMLInputElement)) {
    throw new Error(`Element ${id} is not an input element`);
  }

  return element;
}

// Fix 11: Use const assertion for literal types
export const CONFIG = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
} as const;

// Now CONFIG.apiUrl has type 'https://api.example.com' instead of string
type ConfigType = typeof CONFIG;
// ConfigType = { readonly apiUrl: 'https://api.example.com'; readonly timeout: 5000 }

// Fix 12: Use environment variables for sensitive data
const API_KEY = process.env.API_KEY;

export function callApi(endpoint: string): Promise<Response> {
  if (!API_KEY) {
    throw new Error('API_KEY environment variable is not set');
  }

  return fetch(`https://api.example.com${endpoint}`, {
    headers: {
      'Authorization': `Bearer ${API_KEY}`,
    },
  });
}

// Fix 13: Use parameterized queries to prevent SQL injection
export function getUserByEmail(email: string): Promise<User | null> {
  // Using parameterized query
  return db.query('SELECT * FROM users WHERE email = $1', [email]);
}

// Fix 14: Sanitize HTML to prevent XSS
import DOMPurify from 'dompurify';

export function displayComment(comment: string): void {
  const element = document.getElementById('comment');

  if (!element) {
    throw new Error('Comment element not found');
  }

  // Safe: use textContent for plain text
  element.textContent = comment;

  // Or if HTML is needed, sanitize it:
  // const sanitized = DOMPurify.sanitize(comment);
  // element.innerHTML = sanitized;
}

// Fix 15: Proper interface definition
interface CreateUserInput {
  name: string;
  email: string;
}

interface UserEntity {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

export function createUser(data: CreateUserInput): UserEntity {
  return {
    id: generateId(),
    name: data.name,
    email: data.email,
    createdAt: new Date(),
  };
}

// Fix 16: Use utility types (Omit) for type transformations
export interface User {
  id: string;
  name: string;
  email: string;
  password: string;
  createdAt: Date;
}

export type PublicUser = Omit<User, 'password'>;

export function getPublicUser(user: User): PublicUser {
  const { password, ...publicUser } = user;
  return publicUser;
}

// Fix 17: Required parameters before optional ones
export function greet(name: string, title?: string): string {
  return title ? `Hello, ${title} ${name}` : `Hello, ${name}`;
}

// Or use object parameter for better clarity:
interface GreetOptions {
  name: string;
  title?: string;
}

export function greetWithOptions({ name, title }: GreetOptions): string {
  return title ? `Hello, ${title} ${name}` : `Hello, ${name}`;
}

// Fix 18: Safe array access (handling empty arrays)
export function getFirstItem(items: string[]): string {
  const first = items[0];

  if (first === undefined) {
    throw new Error('Array is empty');
  }

  return first.toUpperCase();
}

// Or return undefined:
export function getFirstItemSafe(items: string[]): string | undefined {
  return items[0]?.toUpperCase();
}

// Fix 19: Use destructuring instead of delete
export function removePassword(user: User): PublicUser {
  const { password, ...publicUser } = user;
  return publicUser;
}

// Fix 20: Cleanup event listeners to prevent memory leaks
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
// cleanup(); // Call when done

// Or in React:
// useEffect(() => {
//   return setupListener();
// }, []);

// Additional best practices:

// Use readonly for immutable data
export interface Config {
  readonly apiUrl: string;
  readonly timeout: number;
}

// Use satisfies operator (TypeScript 4.9+) to validate types while preserving literals
export const routes = {
  home: '/',
  about: '/about',
  contact: '/contact',
} satisfies Record<string, string>;
// routes.home has type '/' not string

// Use branded types for stronger type safety
type UserId = string & { readonly __brand: 'UserId' };
type PostId = string & { readonly __brand: 'PostId' };

function createUserId(id: string): UserId {
  return id as UserId;
}

function getUserById(id: UserId): Promise<User> {
  // This function only accepts UserId, not plain string
  return db.query('SELECT * FROM users WHERE id = $1', [id]);
}

// Use unknown instead of any for truly unknown types
export function parseJson(json: string): unknown {
  return JSON.parse(json);
}

// Then validate:
export function getUser(json: string): User {
  const data = parseJson(json);

  if (!isUser(data)) {
    throw new Error('Invalid user data');
  }

  return data;
}

function isUser(data: unknown): data is User {
  return (
    typeof data === 'object' &&
    data !== null &&
    'id' in data &&
    'name' in data &&
    'email' in data &&
    typeof (data as User).id === 'string' &&
    typeof (data as User).name === 'string' &&
    typeof (data as User).email === 'string'
  );
}

// Helper types and declarations
interface Post {
  id: string;
  title: string;
  content: string;
}

interface Comment {
  id: string;
  postId: string;
  content: string;
}

declare const db: {
  query<T>(sql: string, params?: unknown[]): Promise<T>;
};

declare function generateId(): string;
declare function fetchUsers(): Promise<User[]>;
declare function fetchPosts(): Promise<Post[]>;
declare function fetchComments(): Promise<Comment[]>;
