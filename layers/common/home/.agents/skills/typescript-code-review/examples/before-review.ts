// Example TypeScript file with common issues
// This demonstrates various problems that a code review should catch

// Issue 1: Using 'any' type
export function processData(data: any) {
  return data.value * 2;
}

// Issue 2: No explicit return type
export function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Issue 3: Not handling null/undefined properly
export function getUserName(user: User | undefined) {
  return user.name.toUpperCase(); // Will crash if user is undefined
}

// Issue 4: Inefficient algorithm (nested loops - O(n²))
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

// Issue 5: Using regular enum (generates runtime code)
export enum UserRole {
  Admin,
  User,
  Guest,
}

// Issue 6: Mutating input parameters
export function addItem(items: string[], newItem: string) {
  items.push(newItem);
  return items;
}

// Issue 7: No discriminated union
export type ApiResponse =
  | { data: string }
  | { error: string };

export function handleResponse(response: ApiResponse) {
  if ('data' in response) {
    return response.data;
  }
  throw new Error(response.error);
}

// Issue 8: Missing error handling in async function
export async function fetchUser(id: string) {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}

// Issue 9: Sequential awaits when parallel is possible
export async function loadData() {
  const users = await fetchUsers();
  const posts = await fetchPosts();
  const comments = await fetchComments();
  return { users, posts, comments };
}

// Issue 10: Type assertion instead of type guard
export function getElement(id: string) {
  return document.getElementById(id) as HTMLInputElement;
}

// Issue 11: Not using const assertion for literal types
export const CONFIG = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
};

// Issue 12: Hardcoded sensitive data
const API_KEY = 'sk_live_1234567890abcdef';

export function callApi(endpoint: string) {
  return fetch(`https://api.example.com${endpoint}`, {
    headers: {
      'Authorization': `Bearer ${API_KEY}`,
    },
  });
}

// Issue 13: SQL injection vulnerability
export function getUserByEmail(email: string) {
  return db.query(`SELECT * FROM users WHERE email = '${email}'`);
}

// Issue 14: XSS vulnerability
export function displayComment(comment: string) {
  document.getElementById('comment')!.innerHTML = comment;
}

// Issue 15: Missing interface for object shape
export function createUser(data) {
  return {
    id: generateId(),
    name: data.name,
    email: data.email,
  };
}

// Issue 16: Not using utility types
export interface User {
  id: string;
  name: string;
  email: string;
  password: string;
}

export function getPublicUser(user: User) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
  };
}

// Issue 17: Optional parameters before required ones
export function greet(title?: string, name: string) {
  return `Hello, ${title} ${name}`;
}

// Issue 18: Not handling array index safely
export function getFirstItem(items: string[]) {
  return items[0].toUpperCase(); // Will crash if array is empty
}

// Issue 19: Using delete operator
export function removePassword(user: User) {
  const result = { ...user };
  delete result.password;
  return result;
}

// Issue 20: Memory leak - not cleaning up event listener
export function setupListener() {
  window.addEventListener('resize', handleResize);
}

function handleResize() {
  console.log('Window resized');
}

// Helper types (incomplete definitions for the example)
interface User {
  name: string;
  id: string;
  email: string;
  password: string;
}

declare const db: any;
declare function generateId(): string;
declare function fetchUsers(): Promise<any[]>;
declare function fetchPosts(): Promise<any[]>;
declare function fetchComments(): Promise<any[]>;
