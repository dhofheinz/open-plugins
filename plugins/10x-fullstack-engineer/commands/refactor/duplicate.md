# Code Duplication Elimination Operation

Detect and eliminate code duplication through extraction, parameterization, or templating.

## Parameters

**Received from $ARGUMENTS**: All arguments after "duplicate"

**Expected format**:
```
scope:"<path>" [threshold:"<percentage>"] [strategy:"<strategy-name>"]
```

**Parameter definitions**:
- `scope` (REQUIRED): Path to analyze (e.g., "src/", "src/components/")
- `threshold` (OPTIONAL): Similarity threshold percentage (default: 80)
  - 100: Exact duplicates only
  - 80-99: Near duplicates (recommended)
  - 50-79: Similar patterns
- `strategy` (OPTIONAL): Consolidation strategy (default: auto-detect)
  - `extract-function` - Extract to shared function
  - `extract-class` - Extract to shared class
  - `parameterize` - Add parameters to reduce duplication
  - `template` - Use template/component pattern

## Workflow

### 1. Detect Duplication

Use jsinspect or similar tools:

```bash
# Find duplicate code blocks
npx jsinspect <scope> \
  --threshold <threshold> \
  --min-instances 2 \
  --ignore "node_modules|dist|build|test" \
  --reporter json

# Or use script
./.scripts/detect-duplication.sh <scope> <threshold>
```

### 2. Analyze Duplication Patterns

Categorize duplicates:
- **Exact duplicates** (100% match): Copy-paste code
- **Near duplicates** (80-99% match): Similar with minor differences
- **Structural duplicates** (50-79% match): Same pattern, different data

### 3. Choose Consolidation Strategy

Based on duplication type:

## Strategy Examples

### Strategy 1: Extract Function

**When to use**:
- Exact or near duplicate code blocks
- Pure logic with clear inputs/outputs
- Used in 2+ places
- No complex state dependencies

**Before** (Duplicated validation):
```typescript
// UserForm.tsx
function validateForm() {
  const errors: Errors = {};

  if (!formData.email) {
    errors.email = "Email is required";
  } else {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(formData.email)) {
      errors.email = "Invalid email format";
    }
  }

  if (!formData.password) {
    errors.password = "Password is required";
  } else if (formData.password.length < 8) {
    errors.password = "Password must be at least 8 characters";
  } else {
    const hasUpper = /[A-Z]/.test(formData.password);
    const hasLower = /[a-z]/.test(formData.password);
    const hasNumber = /[0-9]/.test(formData.password);
    if (!hasUpper || !hasLower || !hasNumber) {
      errors.password = "Password must contain uppercase, lowercase, and number";
    }
  }

  return errors;
}

// ProfileForm.tsx - Same validation copied
function validateForm() {
  const errors: Errors = {};

  if (!formData.email) {
    errors.email = "Email is required";
  } else {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(formData.email)) {
      errors.email = "Invalid email format";
    }
  }

  if (!formData.password) {
    errors.password = "Password is required";
  } else if (formData.password.length < 8) {
    errors.password = "Password must be at least 8 characters";
  } else {
    const hasUpper = /[A-Z]/.test(formData.password);
    const hasLower = /[a-z]/.test(formData.password);
    const hasNumber = /[0-9]/.test(formData.password);
    if (!hasUpper || !hasLower || !hasNumber) {
      errors.password = "Password must contain uppercase, lowercase, and number";
    }
  }

  return errors;
}

// RegistrationForm.tsx - Same validation copied again
// SettingsForm.tsx - Same validation copied again
// AdminForm.tsx - Same validation copied again
```

**After** (Extracted to shared utilities):
```typescript
// utils/validation.ts
export interface ValidationResult {
  valid: boolean;
  errors: Record<string, string>;
}

export function validateEmail(email: string): string | null {
  if (!email) {
    return "Email is required";
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return "Invalid email format";
  }

  return null;
}

export function validatePassword(password: string): string | null {
  if (!password) {
    return "Password is required";
  }

  if (password.length < 8) {
    return "Password must be at least 8 characters";
  }

  const hasUpper = /[A-Z]/.test(password);
  const hasLower = /[a-z]/.test(password);
  const hasNumber = /[0-9]/.test(password);

  if (!hasUpper || !hasLower || !hasNumber) {
    return "Password must contain uppercase, lowercase, and number";
  }

  return null;
}

export function validateUserForm(data: {
  email: string;
  password: string;
}): ValidationResult {
  const errors: Record<string, string> = {};

  const emailError = validateEmail(data.email);
  if (emailError) errors.email = emailError;

  const passwordError = validatePassword(data.password);
  if (passwordError) errors.password = passwordError;

  return {
    valid: Object.keys(errors).length === 0,
    errors
  };
}

// All forms now use shared validation
// UserForm.tsx
import { validateUserForm } from '@/utils/validation';

function validateForm() {
  return validateUserForm(formData);
}

// ProfileForm.tsx
import { validateUserForm } from '@/utils/validation';

function validateForm() {
  return validateUserForm(formData);
}

// Same for RegistrationForm, SettingsForm, AdminForm
```

**Improvements**:
- DRY: 5 duplicates → 1 implementation
- Lines saved: ~200 lines (40 lines × 5 copies)
- Single source of truth: Fix bugs once
- Testability: Test validation independently
- Consistency: All forms use same validation

---

### Strategy 2: Extract Class

**When to use**:
- Duplicated logic with state
- Related methods copied together
- Object-oriented patterns
- Multiple functions working on same data

**Before** (Duplicated error handling across services):
```typescript
// UserService.ts
class UserService {
  async createUser(data: any) {
    try {
      const user = await this.db.users.create(data);
      return { success: true, data: user };
    } catch (error) {
      if (error.code === '23505') {
        return {
          success: false,
          error: { code: 'DUPLICATE_EMAIL', message: 'Email already exists' }
        };
      }
      if (error.code === '23503') {
        return {
          success: false,
          error: { code: 'INVALID_REFERENCE', message: 'Invalid reference' }
        };
      }
      console.error('User creation error:', error);
      return {
        success: false,
        error: { code: 'INTERNAL_ERROR', message: 'Internal server error' }
      };
    }
  }
}

// PostService.ts - Same error handling copied
class PostService {
  async createPost(data: any) {
    try {
      const post = await this.db.posts.create(data);
      return { success: true, data: post };
    } catch (error) {
      if (error.code === '23505') {
        return {
          success: false,
          error: { code: 'DUPLICATE_TITLE', message: 'Title already exists' }
        };
      }
      if (error.code === '23503') {
        return {
          success: false,
          error: { code: 'INVALID_REFERENCE', message: 'Invalid reference' }
        };
      }
      console.error('Post creation error:', error);
      return {
        success: false,
        error: { code: 'INTERNAL_ERROR', message: 'Internal server error' }
        };
    }
  }
}

// CommentService.ts - Same pattern copied
// OrderService.ts - Same pattern copied
```

**After** (Extracted error handler class):
```typescript
// errors/DatabaseErrorHandler.ts
export interface ErrorResponse {
  code: string;
  message: string;
  details?: any;
}

export interface Result<T> {
  success: boolean;
  data?: T;
  error?: ErrorResponse;
}

export class DatabaseErrorHandler {
  private errorMappings: Map<string, (error: any) => ErrorResponse> = new Map([
    ['23505', this.handleDuplicateKey],
    ['23503', this.handleForeignKeyViolation],
    ['23502', this.handleNotNullViolation],
    ['23514', this.handleCheckViolation]
  ]);

  handleError(error: any, context: string = 'Database'): ErrorResponse {
    const handler = this.errorMappings.get(error.code);
    if (handler) {
      return handler.call(this, error);
    }

    console.error(`${context} error:`, error);
    return {
      code: 'INTERNAL_ERROR',
      message: 'Internal server error'
    };
  }

  private handleDuplicateKey(error: any): ErrorResponse {
    return {
      code: 'DUPLICATE_KEY',
      message: 'Resource with this identifier already exists',
      details: error.detail
    };
  }

  private handleForeignKeyViolation(error: any): ErrorResponse {
    return {
      code: 'INVALID_REFERENCE',
      message: 'Referenced resource does not exist',
      details: error.detail
    };
  }

  private handleNotNullViolation(error: any): ErrorResponse {
    return {
      code: 'MISSING_REQUIRED_FIELD',
      message: 'Required field is missing',
      details: error.column
    };
  }

  private handleCheckViolation(error: any): ErrorResponse {
    return {
      code: 'CONSTRAINT_VIOLATION',
      message: 'Data violates constraint',
      details: error.constraint
    };
  }

  async wrapOperation<T>(
    operation: () => Promise<T>,
    context?: string
  ): Promise<Result<T>> {
    try {
      const data = await operation();
      return { success: true, data };
    } catch (error) {
      return {
        success: false,
        error: this.handleError(error, context)
      };
    }
  }
}

// Services now use shared error handler
// UserService.ts
class UserService {
  constructor(
    private db: Database,
    private errorHandler: DatabaseErrorHandler
  ) {}

  async createUser(data: CreateUserInput): Promise<Result<User>> {
    return this.errorHandler.wrapOperation(
      () => this.db.users.create(data),
      'User creation'
    );
  }
}

// PostService.ts
class PostService {
  constructor(
    private db: Database,
    private errorHandler: DatabaseErrorHandler
  ) {}

  async createPost(data: CreatePostInput): Promise<Result<Post>> {
    return this.errorHandler.wrapOperation(
      () => this.db.posts.create(data),
      'Post creation'
    );
  }
}

// All services now use shared error handling
```

**Improvements**:
- Centralized error handling
- Consistent error responses
- Easier to extend (add new error types)
- Better logging and monitoring
- DRY: One error handler for all services

---

### Strategy 3: Parameterize

**When to use**:
- Functions differ only in values/configuration
- Similar structure, different data
- Can be unified with parameters
- Limited number of variations

**Before** (Similar functions with hard-coded values):
```typescript
// formatters.ts
function formatUserName(user: User): string {
  return `${user.firstName} ${user.lastName}`;
}

function formatAdminName(admin: Admin): string {
  return `${admin.firstName} ${admin.lastName} (Admin)`;
}

function formatModeratorName(moderator: Moderator): string {
  return `${moderator.firstName} ${moderator.lastName} (Moderator)`;
}

function formatGuestName(guest: Guest): string {
  return `Guest: ${guest.firstName} ${guest.lastName}`;
}

// Similar for emails
function formatUserEmail(user: User): string {
  return user.email.toLowerCase();
}

function formatAdminEmail(admin: Admin): string {
  return `admin-${admin.email.toLowerCase()}`;
}

function formatModeratorEmail(moderator: Moderator): string {
  return `mod-${moderator.email.toLowerCase()}`;
}
```

**After** (Parameterized):
```typescript
// formatters.ts
interface Person {
  firstName: string;
  lastName: string;
  email: string;
}

type NameFormat = {
  prefix?: string;
  suffix?: string;
  template?: (person: Person) => string;
};

function formatName(person: Person, format: NameFormat = {}): string {
  if (format.template) {
    return format.template(person);
  }

  const base = `${person.firstName} ${person.lastName}`;
  const prefix = format.prefix ? `${format.prefix}: ` : '';
  const suffix = format.suffix ? ` (${format.suffix})` : '';

  return `${prefix}${base}${suffix}`;
}

type EmailFormat = {
  prefix?: string;
  domain?: string;
  transform?: (email: string) => string;
};

function formatEmail(person: Person, format: EmailFormat = {}): string {
  let email = person.email.toLowerCase();

  if (format.transform) {
    email = format.transform(email);
  }

  if (format.prefix) {
    const [local, domain] = email.split('@');
    email = `${format.prefix}-${local}@${domain}`;
  }

  if (format.domain) {
    const [local] = email.split('@');
    email = `${local}@${format.domain}`;
  }

  return email;
}

// Usage - Much more flexible
const userName = formatName(user);
const adminName = formatName(admin, { suffix: 'Admin' });
const modName = formatName(moderator, { suffix: 'Moderator' });
const guestName = formatName(guest, { prefix: 'Guest' });

const userEmail = formatEmail(user);
const adminEmail = formatEmail(admin, { prefix: 'admin' });
const modEmail = formatEmail(moderator, { prefix: 'mod' });

// Easy to add new formats without new functions
const vipName = formatName(vip, { suffix: 'VIP', prefix: 'Special' });
const customEmail = formatEmail(user, {
  transform: (email) => email.toUpperCase()
});
```

**Improvements**:
- 7 functions → 2 parameterized functions
- More flexible: Infinite combinations possible
- Easier to maintain: One function to update
- Easier to test: Test parameters instead of functions
- Extensible: Add new formats without new code

---

### Strategy 4: Template/Component Pattern

**When to use**:
- Repeated UI patterns
- Similar component structures
- Variations in content, not structure
- React/Vue component duplication

**Before** (Duplicated card components):
```typescript
// UserCard.tsx
function UserCard({ user }: { user: User }) {
  return (
    <div className="card">
      <div className="card-header">
        <img src={user.avatar} alt={user.name} />
        <h3>{user.name}</h3>
      </div>
      <div className="card-body">
        <p>{user.email}</p>
        <p>{user.role}</p>
      </div>
      <div className="card-footer">
        <button onClick={() => viewUser(user.id)}>View</button>
        <button onClick={() => editUser(user.id)}>Edit</button>
      </div>
    </div>
  );
}

// PostCard.tsx - Same structure copied
function PostCard({ post }: { post: Post }) {
  return (
    <div className="card">
      <div className="card-header">
        <img src={post.thumbnail} alt={post.title} />
        <h3>{post.title}</h3>
      </div>
      <div className="card-body">
        <p>{post.excerpt}</p>
        <p>By {post.author}</p>
      </div>
      <div className="card-footer">
        <button onClick={() => viewPost(post.id)}>View</button>
        <button onClick={() => editPost(post.id)}>Edit</button>
      </div>
    </div>
  );
}

// ProductCard.tsx - Same structure copied
// CommentCard.tsx - Same structure copied
```

**After** (Generic Card template):
```typescript
// components/Card.tsx
interface CardProps {
  header: {
    image: string;
    title: string;
    imageAlt?: string;
  };
  body: React.ReactNode;
  footer?: {
    actions: Array<{
      label: string;
      onClick: () => void;
      variant?: 'primary' | 'secondary';
    }>;
  };
  className?: string;
}

export function Card({ header, body, footer, className = '' }: CardProps) {
  return (
    <div className={`card ${className}`}>
      <div className="card-header">
        <img
          src={header.image}
          alt={header.imageAlt || header.title}
          className="card-image"
        />
        <h3 className="card-title">{header.title}</h3>
      </div>
      <div className="card-body">{body}</div>
      {footer && (
        <div className="card-footer">
          {footer.actions.map((action, index) => (
            <button
              key={index}
              onClick={action.onClick}
              className={`btn btn-${action.variant || 'primary'}`}
            >
              {action.label}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

// Usage - Much cleaner
// UserCard.tsx
function UserCard({ user }: { user: User }) {
  return (
    <Card
      header={{
        image: user.avatar,
        title: user.name,
        imageAlt: `${user.name}'s avatar`
      }}
      body={
        <>
          <p>{user.email}</p>
          <p className="user-role">{user.role}</p>
        </>
      }
      footer={{
        actions: [
          { label: 'View', onClick: () => viewUser(user.id) },
          { label: 'Edit', onClick: () => editUser(user.id), variant: 'secondary' }
        ]
      }}
    />
  );
}

// PostCard.tsx
function PostCard({ post }: { post: Post }) {
  return (
    <Card
      header={{
        image: post.thumbnail,
        title: post.title
      }}
      body={
        <>
          <p>{post.excerpt}</p>
          <p className="post-author">By {post.author}</p>
        </>
      }
      footer={{
        actions: [
          { label: 'Read More', onClick: () => viewPost(post.id) },
          { label: 'Edit', onClick: () => editPost(post.id), variant: 'secondary' }
        ]
      }}
    />
  );
}
```

**Improvements**:
- Reusable Card component
- Consistent UI across cards
- Easy to change card structure globally
- Less code duplication
- Compose with different content

---

## Measurement

Calculate duplication savings:

```bash
# Before
Total lines: 10,000
Duplicate lines: 800 (8%)

# After
Total lines: 9,200
Duplicate lines: 100 (1.1%)

# Savings
Lines removed: 800
Duplication reduced: 8% → 1.1% (87.5% improvement)
```

## Output Format

```markdown
# Code Duplication Elimination Report

## Analysis

**Scope**: <path>
**Threshold**: <percentage>%

**Duplicates Found**:
- Exact duplicates: <count> instances
- Near duplicates: <count> instances
- Total duplicate lines: <count> / <total> (<percentage>%)

## Duplication Examples

### Duplicate 1: <description>

**Instances**: <count> copies

**Locations**:
1. <file1>:<line-range>
2. <file2>:<line-range>
3. <file3>:<line-range>

**Strategy**: <extract-function | extract-class | parameterize | template>

**Before** (<lines> lines duplicated):
```typescript
<duplicated-code>
```

**After** (Single implementation):
```typescript
<consolidated-code>
```

**Savings**: <lines> lines removed

## Total Impact

**Before**:
- Total lines: <count>
- Duplicate lines: <count> (<percentage>%)

**After**:
- Total lines: <count>
- Duplicate lines: <count> (<percentage>%)

**Improvement**:
- Lines removed: <count>
- Duplication reduced: <before>% → <after>% (<percentage>% improvement)
- Maintainability: Significantly improved

## Files Changed

**Created**:
- <new-shared-file-1>
- <new-shared-file-2>

**Modified**:
- <file-1>: Replaced with shared implementation
- <file-2>: Replaced with shared implementation

## Testing

**Tests Updated**:
- <test-file-1>: Updated to test shared code
- <test-file-2>: Removed duplicate tests

**Coverage**:
- Before: <percentage>%
- After: <percentage>%

## Next Steps

**Remaining Duplication**:
1. <duplicate-pattern-1>: <count> instances
2. <duplicate-pattern-2>: <count> instances

**Recommendations**:
- Continue eliminating duplicates
- Set up automated duplication detection in CI/CD
- Code review for new duplicates

---

**Duplication Eliminated**: Code is now DRY and maintainable.
```

## Error Handling

**No duplicates found**:
```
Success: No significant code duplication found (threshold: <percentage>%)

**Duplication**: <percentage>% (Target: < 3%)

The codebase is already DRY. Great work!
```

**Threshold too low**:
```
Warning: Threshold <percentage>% is very low. Found <count> potential duplicates.

Many may be false positives (similar structure but different purpose).

Recommendation: Use threshold 80-90% for meaningful duplicates.
```
