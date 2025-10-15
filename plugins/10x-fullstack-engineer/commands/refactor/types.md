# Type Safety Improvement Operation

Improve TypeScript type safety by adding types, strengthening existing types, migrating to TypeScript, eliminating 'any', or adding generics.

## Parameters

**Received from $ARGUMENTS**: All arguments after "types"

**Expected format**:
```
scope:"<path>" strategy:"<strategy-name>" [strict:"true|false"]
```

**Parameter definitions**:
- `scope` (REQUIRED): Path to improve (e.g., "src/api/", "utils/helpers.ts")
- `strategy` (REQUIRED): Type improvement strategy
  - `add-types` - Add missing type annotations
  - `strengthen-types` - Replace weak types with specific ones
  - `migrate-to-ts` - Convert JavaScript to TypeScript
  - `eliminate-any` - Remove 'any' types
  - `add-generics` - Add generic type parameters
- `strict` (OPTIONAL): Enable strict TypeScript mode (default: false)

## Workflow

### 1. TypeScript Configuration Check

Verify TypeScript setup:

```bash
# Check if TypeScript is configured
test -f tsconfig.json || echo "No tsconfig.json found"

# Check current strictness
cat tsconfig.json | grep -A5 "compilerOptions"

# Type check current state
npx tsc --noEmit
```

### 2. Analyze Type Coverage

Assess current type safety:

```bash
# Count 'any' usage
grep -r "any" <scope> --include="*.ts" --include="*.tsx" | wc -l

# Count implicit any
npx tsc --noEmit --noImplicitAny 2>&1 | grep "implicitly has an 'any' type" | wc -l

# Check for type assertions
grep -r "as any" <scope> --include="*.ts" --include="*.tsx"
```

## Strategy Examples

### Strategy 1: Add Missing Types

**Before** (Missing types):
```typescript
// utils/helpers.ts
export function formatDate(date) {
  return date.toISOString().split('T')[0];
}

export function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}

export async function fetchUser(id) {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}

export function createUser(name, email, age) {
  return {
    id: generateId(),
    name,
    email,
    age,
    createdAt: new Date()
  };
}
```

**After** (Full type annotations):
```typescript
// utils/helpers.ts
export function formatDate(date: Date): string {
  return date.toISOString().split('T')[0];
}

interface Item {
  price: number;
  name: string;
}

export function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

interface User {
  id: string;
  name: string;
  email: string;
  age: number;
  createdAt: Date;
}

export async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  return response.json() as User;
}

export function createUser(
  name: string,
  email: string,
  age: number
): User {
  return {
    id: generateId(),
    name,
    email,
    age,
    createdAt: new Date()
  };
}
```

**Improvements**:
- Catch type errors at compile time
- Better IDE autocomplete
- Self-documenting code
- Refactoring safety

---

### Strategy 2: Strengthen Types (Eliminate 'any')

**Before** (Weak 'any' types):
```typescript
// api/client.ts
class APIClient {
  async get(endpoint: string): Promise<any> {
    const response = await fetch(endpoint);
    return response.json();
  }

  async post(endpoint: string, data: any): Promise<any> {
    const response = await fetch(endpoint, {
      method: 'POST',
      body: JSON.stringify(data)
    });
    return response.json();
  }

  handleError(error: any) {
    console.error(error);
  }
}

// Usage - No type safety!
const user = await client.get('/users/1');
console.log(user.nameeee); // Typo not caught!
```

**After** (Strong specific types):
```typescript
// types/api.ts
export interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user';
}

export interface Post {
  id: string;
  title: string;
  content: string;
  authorId: string;
}

export interface APIError {
  code: string;
  message: string;
  details?: Record<string, string[]>;
}

// api/client.ts
class APIClient {
  async get<T>(endpoint: string): Promise<T> {
    const response = await fetch(endpoint);
    if (!response.ok) {
      throw await this.handleError(response);
    }
    return response.json() as T;
  }

  async post<TRequest, TResponse>(
    endpoint: string,
    data: TRequest
  ): Promise<TResponse> {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });

    if (!response.ok) {
      throw await this.handleError(response);
    }

    return response.json() as TResponse;
  }

  private async handleError(response: Response): Promise<APIError> {
    const error: APIError = await response.json();
    console.error('API Error:', error);
    return error;
  }
}

// Usage - Full type safety!
const user = await client.get<User>('/users/1');
console.log(user.name); // Autocomplete works!
console.log(user.nameeee); // Error: Property 'nameeee' does not exist

const newPost = await client.post<CreatePostInput, Post>('/posts', {
  title: 'Hello',
  content: 'World'
});
```

**Improvements**:
- Eliminate all 'any' types
- Generic type parameters for flexibility
- Catch typos at compile time
- Better developer experience

---

### Strategy 3: Add Generics

**Before** (Type repetition, limited reusability):
```typescript
// Without generics - Need separate class for each type
class UserRepository {
  private users: User[] = [];

  add(user: User): void {
    this.users.push(user);
  }

  findById(id: string): User | undefined {
    return this.users.find(u => u.id === id);
  }

  findAll(): User[] {
    return [...this.users];
  }

  remove(id: string): boolean {
    const index = this.users.findIndex(u => u.id === id);
    if (index > -1) {
      this.users.splice(index, 1);
      return true;
    }
    return false;
  }
}

class PostRepository {
  private posts: Post[] = [];

  add(post: Post): void {
    this.posts.push(post);
  }

  findById(id: string): Post | undefined {
    return this.posts.find(p => p.id === id);
  }

  findAll(): Post[] {
    return [...this.posts];
  }

  remove(id: string): boolean {
    const index = this.posts.findIndex(p => p.id === id);
    if (index > -1) {
      this.posts.splice(index, 1);
      return true;
    }
    return false;
  }
}

// Need duplicate class for each entity type!
```

**After** (Generic repository - DRY):
```typescript
// Generic base repository
interface Entity {
  id: string;
}

class Repository<T extends Entity> {
  private items: Map<string, T> = new Map();

  add(item: T): void {
    this.items.set(item.id, item);
  }

  findById(id: string): T | undefined {
    return this.items.get(id);
  }

  findAll(): T[] {
    return Array.from(this.items.values());
  }

  findBy(predicate: (item: T) => boolean): T[] {
    return this.findAll().filter(predicate);
  }

  update(id: string, updates: Partial<T>): T | undefined {
    const item = this.items.get(id);
    if (item) {
      const updated = { ...item, ...updates };
      this.items.set(id, updated);
      return updated;
    }
    return undefined;
  }

  remove(id: string): boolean {
    return this.items.delete(id);
  }

  count(): number {
    return this.items.size;
  }
}

// Usage with specific types
interface User extends Entity {
  name: string;
  email: string;
}

interface Post extends Entity {
  title: string;
  content: string;
  authorId: string;
}

const userRepo = new Repository<User>();
const postRepo = new Repository<Post>();

// Full type safety
userRepo.add({ id: '1', name: 'John', email: 'john@example.com' });
const user = userRepo.findById('1'); // Type: User | undefined
const admins = userRepo.findBy(u => u.email.endsWith('@admin.com')); // Type: User[]

postRepo.add({ id: '1', title: 'Hello', content: 'World', authorId: '1' });
const post = postRepo.findById('1'); // Type: Post | undefined
```

**More generic examples**:
```typescript
// Generic API response wrapper
interface APIResponse<T> {
  data: T;
  status: number;
  message: string;
}

async function fetchData<T>(url: string): Promise<APIResponse<T>> {
  const response = await fetch(url);
  return response.json();
}

// Usage
const userResponse = await fetchData<User>('/api/user');
const users = userResponse.data; // Type: User

// Generic event emitter
class EventEmitter<TEvents extends Record<string, any>> {
  private handlers: Partial<{
    [K in keyof TEvents]: Array<(data: TEvents[K]) => void>;
  }> = {};

  on<K extends keyof TEvents>(
    event: K,
    handler: (data: TEvents[K]) => void
  ): void {
    if (!this.handlers[event]) {
      this.handlers[event] = [];
    }
    this.handlers[event]!.push(handler);
  }

  emit<K extends keyof TEvents>(event: K, data: TEvents[K]): void {
    const handlers = this.handlers[event] || [];
    handlers.forEach(handler => handler(data));
  }
}

// Usage with typed events
interface AppEvents {
  'user:login': { userId: string; timestamp: Date };
  'user:logout': { userId: string };
  'post:created': { postId: string; authorId: string };
}

const emitter = new EventEmitter<AppEvents>();

emitter.on('user:login', (data) => {
  // data is typed as { userId: string; timestamp: Date }
  console.log(`User ${data.userId} logged in at ${data.timestamp}`);
});

emitter.emit('user:login', {
  userId: '123',
  timestamp: new Date()
}); // Type safe!

// This would error:
// emitter.emit('user:login', { userId: 123 }); // Error: number not assignable to string
```

**Improvements**:
- DRY: Single implementation for all types
- Type safety: Generic constraints ensure correctness
- Reusability: Works with any type that extends Entity
- Maintainability: Fix bugs once, benefits all uses

---

### Strategy 4: Migrate JavaScript to TypeScript

**Before** (JavaScript with no types):
```javascript
// user-service.js
const bcrypt = require('bcrypt');

class UserService {
  constructor(database, emailService) {
    this.db = database;
    this.emailService = emailService;
  }

  async registerUser(userData) {
    // Validate email
    if (!userData.email || !userData.email.includes('@')) {
      throw new Error('Invalid email');
    }

    // Check if user exists
    const existing = await this.db.users.findOne({ email: userData.email });
    if (existing) {
      throw new Error('User already exists');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(userData.password, 10);

    // Create user
    const user = await this.db.users.create({
      email: userData.email,
      password: hashedPassword,
      name: userData.name,
      createdAt: new Date()
    });

    // Send welcome email
    await this.emailService.sendWelcome(user.email);

    return {
      id: user.id,
      email: user.email,
      name: user.name
    };
  }

  async login(email, password) {
    const user = await this.db.users.findOne({ email });
    if (!user) {
      throw new Error('Invalid credentials');
    }

    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      throw new Error('Invalid credentials');
    }

    return {
      id: user.id,
      email: user.email,
      name: user.name
    };
  }
}

module.exports = UserService;
```

**After** (TypeScript with full types):
```typescript
// types/user.ts
export interface User {
  id: string;
  email: string;
  password: string;
  name: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserInput {
  email: string;
  password: string;
  name: string;
}

export interface UserDTO {
  id: string;
  email: string;
  name: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

// types/database.ts
export interface IDatabase {
  users: {
    findOne(query: { email: string }): Promise<User | null>;
    create(data: Omit<User, 'id' | 'updatedAt'>): Promise<User>;
  };
}

// types/email.ts
export interface IEmailService {
  sendWelcome(email: string): Promise<void>;
}

// user-service.ts
import * as bcrypt from 'bcrypt';
import {
  User,
  CreateUserInput,
  UserDTO,
  LoginCredentials
} from './types/user';
import { IDatabase } from './types/database';
import { IEmailService } from './types/email';

export class UserService {
  constructor(
    private readonly db: IDatabase,
    private readonly emailService: IEmailService
  ) {}

  async registerUser(userData: CreateUserInput): Promise<UserDTO> {
    // Validate email
    this.validateEmail(userData.email);

    // Check if user exists
    const existing = await this.db.users.findOne({ email: userData.email });
    if (existing) {
      throw new UserAlreadyExistsError(userData.email);
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(userData.password, 10);

    // Create user
    const user = await this.db.users.create({
      email: userData.email,
      password: hashedPassword,
      name: userData.name,
      createdAt: new Date()
    });

    // Send welcome email
    await this.emailService.sendWelcome(user.email);

    return this.toDTO(user);
  }

  async login(credentials: LoginCredentials): Promise<UserDTO> {
    const user = await this.db.users.findOne({ email: credentials.email });
    if (!user) {
      throw new InvalidCredentialsError();
    }

    const passwordMatch = await bcrypt.compare(
      credentials.password,
      user.password
    );
    if (!passwordMatch) {
      throw new InvalidCredentialsError();
    }

    return this.toDTO(user);
  }

  private validateEmail(email: string): void {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      throw new InvalidEmailError(email);
    }
  }

  private toDTO(user: User): UserDTO {
    return {
      id: user.id,
      email: user.email,
      name: user.name
    };
  }
}

// Custom error classes with types
export class UserAlreadyExistsError extends Error {
  constructor(email: string) {
    super(`User with email ${email} already exists`);
    this.name = 'UserAlreadyExistsError';
  }
}

export class InvalidCredentialsError extends Error {
  constructor() {
    super('Invalid credentials');
    this.name = 'InvalidCredentialsError';
  }
}

export class InvalidEmailError extends Error {
  constructor(email: string) {
    super(`Invalid email format: ${email}`);
    this.name = 'InvalidEmailError';
  }
}
```

**Migration steps**:
1. Rename `.js` to `.ts`
2. Add interface definitions
3. Add type annotations to parameters and return types
4. Replace `require()` with `import`
5. Replace `module.exports` with `export`
6. Add custom error classes with types
7. Extract utility functions with proper types
8. Fix all TypeScript errors
9. Enable strict mode gradually

**Improvements**:
- Full compile-time type checking
- Better refactoring support
- Self-documenting code
- Catch errors before runtime
- Modern ES6+ features

---

### Strategy 5: Enable Strict Mode

**Before** (tsconfig.json - Lenient):
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "strict": false,
    "esModuleInterop": true
  }
}
```

**After** (tsconfig.json - Strict):
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",

    /* Strict Type-Checking Options */
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,

    /* Additional Checks */
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,

    /* Module Resolution */
    "esModuleInterop": true,
    "skipLibCheck": false,
    "forceConsistentCasingInFileNames": true
  }
}
```

**Impact of strict mode**:

```typescript
// Before: Implicit any allowed
function process(data) { // No error
  return data.value;
}

// After: Must specify types
function process(data: DataInput): number { // Required
  return data.value;
}

// Before: Null not checked
function getUser(id: string): User {
  return database.findById(id); // Could be null!
}

// After: Must handle null
function getUser(id: string): User | null {
  return database.findById(id);
}

const user = getUser('123');
console.log(user.name); // Error: Object is possibly 'null'

// Must check:
if (user) {
  console.log(user.name); // OK
}

// Or use optional chaining:
console.log(user?.name); // OK

// Before: Array access unchecked
const users: User[] = [];
const first = users[0]; // Type: User (wrong! could be undefined)
first.email; // Runtime error if array is empty

// After: Array access checked
const users: User[] = [];
const first = users[0]; // Type: User | undefined (correct!)
first.email; // Error: Object is possibly 'undefined'

// Must check:
if (first) {
  first.email; // OK
}
```

**Improvements**:
- Catch more errors at compile time
- Safer null/undefined handling
- No implicit any types
- More robust code
- Better IDE support

---

## Output Format

```markdown
# Type Safety Improvement Report

## Strategy Applied: <strategy-name>

**Scope**: <path>
**Strict Mode**: <enabled/disabled>

## Before

**Type Coverage**:
- Files with types: <count> / <total> (<percentage>%)
- 'any' usage: <count> instances
- Implicit any: <count> instances
- Type errors: <count>

**Issues**:
- <issue 1>
- <issue 2>

## Changes Made

### Files Modified
- <file-1>: Added type annotations
- <file-2>: Eliminated 'any' types
- <file-3>: Migrated JS to TS

### Type Definitions Added
```typescript
<new-interfaces-and-types>
```

### Code Examples

**Before**:
```typescript
<code-without-types>
```

**After**:
```typescript
<code-with-types>
```

## After

**Type Coverage**:
- Files with types: <count> / <total> (<percentage>%)
- 'any' usage: <count> instances (<percentage>% reduction)
- Implicit any: 0 (eliminated)
- Type errors: 0 (all fixed)

**Improvements**:
- Type safety: <before>% → <after>%
- Compile-time error detection: +<count> errors caught
- IDE autocomplete: Significantly improved
- Refactoring safety: Enhanced

## Verification

**Type Check**:
```bash
npx tsc --noEmit
# No errors
```

**Tests**:
- All tests passing: YES
- Coverage: <before>% → <after>%

## Migration Guide

**For Consumers**:
```typescript
// Old usage (if breaking changes)
<old-usage>

// New usage
<new-usage>
```

## Next Steps

**Additional Improvements**:
1. Enable stricter compiler options
2. Add runtime type validation (Zod, io-ts)
3. Generate types from API schemas
4. Add JSDoc for better documentation

---

**Type Safety Improved**: Code is now safer and more maintainable.
```

## Error Handling

**No TypeScript configuration**:
```
Error: No tsconfig.json found in project

To use this operation, initialize TypeScript:
1. npm install -D typescript
2. npx tsc --init
3. Configure tsconfig.json
4. Retry operation
```

**Too many type errors**:
```
Warning: Found <count> type errors. This is a large migration.

Recommendation: Gradual migration approach:
1. Start with strict: false
2. Fix implicit any errors first
3. Enable strictNullChecks
4. Enable other strict options one by one
5. Fix errors incrementally
```
