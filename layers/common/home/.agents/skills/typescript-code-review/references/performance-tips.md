# TypeScript Performance Tips

Performance optimization strategies for TypeScript applications, covering runtime performance, compilation speed, and bundle size.

## Runtime Performance

### Memoization and Caching

#### ✅ Memoize Expensive Computations
```typescript
// Bad - recalculating on every call
function fibonacci(n: number): number {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

// Good - memoized version
function createMemoizedFibonacci() {
  const cache = new Map<number, number>();

  return function fibonacci(n: number): number {
    if (cache.has(n)) {
      return cache.get(n)!;
    }

    const result = n <= 1 ? n : fibonacci(n - 1) + fibonacci(n - 2);
    cache.set(n, result);
    return result;
  };
}

const fibonacci = createMemoizedFibonacci();
```

#### ✅ Cache API Responses
```typescript
// Bad - fetching every time
async function getUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}

// Good - cache with TTL
class UserCache {
  private cache = new Map<string, { user: User; timestamp: number }>();
  private ttl = 5 * 60 * 1000; // 5 minutes

  async getUser(id: string): Promise<User> {
    const cached = this.cache.get(id);

    if (cached && Date.now() - cached.timestamp < this.ttl) {
      return cached.user;
    }

    const response = await fetch(`/api/users/${id}`);
    const user = await response.json();

    this.cache.set(id, { user, timestamp: Date.now() });
    return user;
  }

  clear() {
    this.cache.clear();
  }
}
```

---

### Algorithm Optimization

#### ✅ Use Appropriate Data Structures
```typescript
// Bad - O(n) lookup with array
const users: User[] = [...];

function findUser(id: string): User | undefined {
  return users.find(u => u.id === id); // O(n)
}

// Good - O(1) lookup with Map
const users = new Map<string, User>();

function findUser(id: string): User | undefined {
  return users.get(id); // O(1)
}

// Good - Set for membership testing
const activeUserIds = new Set<string>();

function isUserActive(id: string): boolean {
  return activeUserIds.has(id); // O(1)
}
```

#### ✅ Avoid Nested Loops
```typescript
// Bad - O(n²) complexity
function findCommonUsers(list1: User[], list2: User[]): User[] {
  const common: User[] = [];
  for (const user1 of list1) {
    for (const user2 of list2) {
      if (user1.id === user2.id) {
        common.push(user1);
      }
    }
  }
  return common;
}

// Good - O(n) complexity using Set
function findCommonUsers(list1: User[], list2: User[]): User[] {
  const ids2 = new Set(list2.map(u => u.id));
  return list1.filter(u => ids2.has(u.id));
}
```

---

### Array Operations

#### ✅ Avoid Unnecessary Array Iterations
```typescript
// Bad - multiple iterations
const active = users.filter(u => u.isActive);
const names = active.map(u => u.name);
const sorted = names.sort();

// Good - single iteration
const sorted = users
  .filter(u => u.isActive)
  .map(u => u.name)
  .sort();

// Better - early termination when possible
function findFirstActiveUser(users: User[]): User | undefined {
  return users.find(u => u.isActive); // Stops at first match
}
```

#### ✅ Use `for...of` for Early Termination
```typescript
// Bad - processes entire array
const hasActiveUser = users.some(u => u.isActive);

// Good for single check
const hasActiveUser = users.some(u => u.isActive);

// Good for complex logic with early exit
function validateUsers(users: User[]): boolean {
  for (const user of users) {
    if (user.age < 0) return false;
    if (!user.email.includes('@')) return false;
    if (user.name.length === 0) return false;
  }
  return true;
}
```

---

### Object Operations

#### ✅ Destructure Only What You Need
```typescript
// Bad - spreads entire large object
function updateUser(user: LargeUserObject, updates: Partial<LargeUserObject>) {
  return { ...user, ...updates };
}

// Good - only copy necessary fields
function updateUser(user: User, updates: Partial<User>): User {
  return {
    id: user.id,
    name: updates.name ?? user.name,
    email: updates.email ?? user.email,
    // ... only fields that exist
  };
}
```

#### ✅ Avoid Object.keys/values/entries When Not Needed
```typescript
// Bad - creates intermediate array
if (Object.keys(obj).length === 0) {
  // ...
}

// Good - no intermediate array
function isEmpty(obj: Record<string, unknown>): boolean {
  for (const key in obj) {
    if (obj.hasOwnProperty(key)) {
      return false;
    }
  }
  return true;
}

// Best - use Map if frequently checking size
const map = new Map();
if (map.size === 0) {
  // ...
}
```

---

### String Operations

#### ✅ Use Template Literals Efficiently
```typescript
// Bad - repeated concatenation
let result = '';
for (const item of items) {
  result += item.name + ', ';
}

// Good - array join
const result = items.map(item => item.name).join(', ');

// Good - for large strings, use array buffer
const parts: string[] = [];
for (const item of items) {
  parts.push(item.name);
}
const result = parts.join(', ');
```

---

## React/UI Performance

### Component Optimization

#### ✅ Use React.memo for Expensive Components
```typescript
// Bad - re-renders on every parent render
function UserCard({ user }: { user: User }) {
  return <div>{user.name}</div>;
}

// Good - memoized component
const UserCard = React.memo(({ user }: { user: User }) => {
  return <div>{user.name}</div>;
});

// Better - with custom comparison
const UserCard = React.memo(
  ({ user }: { user: User }) => {
    return <div>{user.name}</div>;
  },
  (prevProps, nextProps) => prevProps.user.id === nextProps.user.id
);
```

#### ✅ Optimize useEffect Dependencies
```typescript
// Bad - recreates object on every render
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    fetchUser({ id: userId }).then(setUser);
  }, [{ id: userId }]); // New object every render!

  return <div>{user?.name}</div>;
}

// Good - primitive dependencies only
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    fetchUser({ id: userId }).then(setUser);
  }, [userId]); // Primitive value

  return <div>{user?.name}</div>;
}
```

#### ✅ Use useCallback for Event Handlers
```typescript
// Bad - creates new function on every render
function UserList({ users }: { users: User[] }) {
  const [selected, setSelected] = useState<string[]>([]);

  return (
    <div>
      {users.map(user => (
        <UserCard
          key={user.id}
          user={user}
          onSelect={() => setSelected([...selected, user.id])}
        />
      ))}
    </div>
  );
}

// Good - memoized callback
function UserList({ users }: { users: User[] }) {
  const [selected, setSelected] = useState<string[]>([]);

  const handleSelect = useCallback((userId: string) => {
    setSelected(prev => [...prev, userId]);
  }, []);

  return (
    <div>
      {users.map(user => (
        <UserCard
          key={user.id}
          user={user}
          onSelect={() => handleSelect(user.id)}
        />
      ))}
    </div>
  );
}
```

#### ✅ Use useMemo for Expensive Calculations
```typescript
// Bad - recalculates on every render
function Analytics({ data }: { data: DataPoint[] }) {
  const stats = calculateComplexStats(data); // Expensive!
  return <div>{stats.average}</div>;
}

// Good - memoized calculation
function Analytics({ data }: { data: DataPoint[] }) {
  const stats = useMemo(() => calculateComplexStats(data), [data]);
  return <div>{stats.average}</div>;
}
```

---

### Virtual Scrolling for Large Lists

```typescript
// Bad - rendering thousands of items
function UserList({ users }: { users: User[] }) {
  return (
    <div>
      {users.map(user => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
}

// Good - virtual scrolling with react-window
import { FixedSizeList } from 'react-window';

function UserList({ users }: { users: User[] }) {
  const Row = ({ index, style }: { index: number; style: React.CSSProperties }) => (
    <div style={style}>
      <UserCard user={users[index]} />
    </div>
  );

  return (
    <FixedSizeList
      height={600}
      itemCount={users.length}
      itemSize={80}
      width="100%"
    >
      {Row}
    </FixedSizeList>
  );
}
```

---

## Bundle Size Optimization

### Tree Shaking

#### ✅ Import Only What You Need
```typescript
// Bad - imports entire library
import _ from 'lodash';
const result = _.debounce(fn, 100);

// Good - import specific function
import debounce from 'lodash/debounce';
const result = debounce(fn, 100);

// Better - use ES modules
import { debounce } from 'lodash-es';
```

#### ✅ Use Dynamic Imports for Code Splitting
```typescript
// Bad - loads everything upfront
import { HeavyComponent } from './HeavyComponent';

function App() {
  return <HeavyComponent />;
}

// Good - lazy load heavy components
const HeavyComponent = React.lazy(() => import('./HeavyComponent'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <HeavyComponent />
    </Suspense>
  );
}

// Good - dynamic import for utilities
async function processData(data: Data) {
  const { processHeavyData } = await import('./heavyProcessing');
  return processHeavyData(data);
}
```

---

### Minimize Dependencies

```typescript
// Bad - large dependency for simple task
import moment from 'moment'; // ~300kb
const formatted = moment(date).format('YYYY-MM-DD');

// Good - use native Date API
const formatted = new Intl.DateTimeFormat('en-CA').format(date);

// Good - use smaller library
import { format } from 'date-fns'; // ~70kb with tree-shaking
const formatted = format(date, 'yyyy-MM-dd');
```

---

## TypeScript Compilation Performance

### Optimize tsconfig.json

```json
{
  "compilerOptions": {
    // Improve compilation speed
    "incremental": true,
    "skipLibCheck": true, // Skip type checking of declaration files

    // Improve IDE performance
    "moduleResolution": "bundler", // or "node16" for better module resolution
    "resolveJsonModule": true,

    // Reduce type checking scope if needed
    "noEmit": true, // If using a bundler
    "isolatedModules": true, // Faster transpilation

    // Avoid expensive type calculations
    "strict": true // But consider disabling specific checks if too slow
  },

  // Exclude unnecessary files
  "exclude": [
    "node_modules",
    "dist",
    "build",
    "**/*.spec.ts",
    "**/*.test.ts"
  ]
}
```

### Type Calculation Performance

#### ❌ Avoid Deeply Recursive Types
```typescript
// Bad - very slow compilation
type DeepPartial<T> = T extends object
  ? { [P in keyof T]?: DeepPartial<T[P]> }
  : T;

type HugeDeepPartial = DeepPartial<VeryNestedType>; // Slow!

// Good - limit recursion depth
type DeepPartial<T, Depth extends number = 5> = Depth extends 0
  ? T
  : T extends object
  ? { [P in keyof T]?: DeepPartial<T[P], Prev[Depth]> }
  : T;

type Prev = [never, 0, 1, 2, 3, 4, ...0[]];
```

#### ✅ Use Simpler Type Utilities
```typescript
// Bad - complex conditional type
type ComplexType<T> = T extends Array<infer U>
  ? U extends object
    ? { [K in keyof U]: ComplexType<U[K]> }
    : U
  : T;

// Good - simpler, faster type
type SimplerType<T> = T extends Array<infer U> ? U : T;
```

---

## Network Performance

### Request Optimization

#### ✅ Batch API Requests
```typescript
// Bad - multiple sequential requests
async function loadUserData(userId: string) {
  const user = await fetchUser(userId);
  const posts = await fetchPosts(userId);
  const comments = await fetchComments(userId);
  return { user, posts, comments };
}

// Good - parallel requests
async function loadUserData(userId: string) {
  const [user, posts, comments] = await Promise.all([
    fetchUser(userId),
    fetchPosts(userId),
    fetchComments(userId),
  ]);
  return { user, posts, comments };
}

// Better - single batched request
async function loadUserData(userId: string) {
  const response = await fetch(`/api/users/${userId}/full-profile`);
  return response.json();
}
```

#### ✅ Implement Request Deduplication
```typescript
// Good - deduplicate concurrent requests
class RequestCache {
  private pending = new Map<string, Promise<any>>();

  async fetch<T>(key: string, fetcher: () => Promise<T>): Promise<T> {
    if (this.pending.has(key)) {
      return this.pending.get(key);
    }

    const promise = fetcher().finally(() => {
      this.pending.delete(key);
    });

    this.pending.set(key, promise);
    return promise;
  }
}

const cache = new RequestCache();

// Multiple calls for same data only make one request
const user1 = cache.fetch('user:1', () => fetchUser('1'));
const user2 = cache.fetch('user:1', () => fetchUser('1')); // Reuses promise
```

#### ✅ Use HTTP/2 and Compression
```typescript
// Good - enable compression
import compression from 'compression';
app.use(compression());

// Good - set proper cache headers
app.get('/api/users/:id', (req, res) => {
  res.setHeader('Cache-Control', 'public, max-age=300'); // 5 min cache
  res.json(user);
});

// Good - use ETags for conditional requests
app.get('/api/users/:id', async (req, res) => {
  const user = await getUser(req.params.id);
  const etag = generateETag(user);

  if (req.headers['if-none-match'] === etag) {
    return res.status(304).end();
  }

  res.setHeader('ETag', etag);
  res.json(user);
});
```

---

## Memory Management

### Avoid Memory Leaks

#### ✅ Clean Up Event Listeners
```typescript
// Bad - memory leak
function Component() {
  useEffect(() => {
    window.addEventListener('resize', handleResize);
  }, []);

  return <div>...</div>;
}

// Good - cleanup
function Component() {
  useEffect(() => {
    window.addEventListener('resize', handleResize);
    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  return <div>...</div>;
}
```

#### ✅ Clear Timers and Intervals
```typescript
// Bad - timer leak
function Component() {
  useEffect(() => {
    setInterval(() => {
      console.log('tick');
    }, 1000);
  }, []);

  return <div>...</div>;
}

// Good - cleanup timer
function Component() {
  useEffect(() => {
    const intervalId = setInterval(() => {
      console.log('tick');
    }, 1000);

    return () => clearInterval(intervalId);
  }, []);

  return <div>...</div>;
}
```

#### ✅ Unsubscribe from Observables
```typescript
// Bad - subscription leak
function Component() {
  useEffect(() => {
    dataStream$.subscribe(data => {
      console.log(data);
    });
  }, []);

  return <div>...</div>;
}

// Good - unsubscribe on cleanup
function Component() {
  useEffect(() => {
    const subscription = dataStream$.subscribe(data => {
      console.log(data);
    });

    return () => subscription.unsubscribe();
  }, []);

  return <div>...</div>;
}
```

---

## Performance Monitoring

### Measure Performance

```typescript
// Good - measure function performance
function measurePerformance<T>(
  name: string,
  fn: () => T
): T {
  const start = performance.now();
  const result = fn();
  const end = performance.now();

  console.log(`${name} took ${end - start}ms`);
  return result;
}

// Usage
const result = measurePerformance('processData', () => {
  return processLargeDataset(data);
});

// Good - async version
async function measureAsyncPerformance<T>(
  name: string,
  fn: () => Promise<T>
): Promise<T> {
  const start = performance.now();
  const result = await fn();
  const end = performance.now();

  console.log(`${name} took ${end - start}ms`);
  return result;
}
```

---

## Performance Review Checklist

### Runtime Performance
- [ ] No nested loops with O(n²) or worse complexity
- [ ] Appropriate data structures (Map/Set instead of Array for lookups)
- [ ] Memoization for expensive calculations
- [ ] Cache frequently accessed data
- [ ] Avoid unnecessary array iterations

### React/UI Performance
- [ ] React.memo for components that re-render often
- [ ] useMemo for expensive calculations
- [ ] useCallback for event handlers passed to child components
- [ ] Virtual scrolling for large lists
- [ ] Lazy loading for heavy components

### Bundle Size
- [ ] Tree-shaking enabled (ES modules)
- [ ] Dynamic imports for code splitting
- [ ] Import only needed functions from libraries
- [ ] Minimal dependencies
- [ ] Consider bundle size when adding new dependencies

### Network Performance
- [ ] Parallel API requests where possible
- [ ] Request deduplication
- [ ] Proper HTTP caching headers
- [ ] Compression enabled
- [ ] Batch requests when feasible

### Memory Management
- [ ] Event listeners cleaned up
- [ ] Timers/intervals cleared
- [ ] Observables unsubscribed
- [ ] No circular references preventing GC
- [ ] WeakMap/WeakSet for object caching

### TypeScript Compilation
- [ ] `incremental: true` in tsconfig.json
- [ ] `skipLibCheck: true` for faster compilation
- [ ] Exclude test files from compilation
- [ ] Avoid deeply recursive types
- [ ] Use project references for large monorepos
