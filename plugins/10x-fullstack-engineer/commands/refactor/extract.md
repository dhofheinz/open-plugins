# Extract Method/Class/Module Operation

Extract methods, classes, modules, components, utilities, or interfaces to improve code organization and reduce complexity.

## Parameters

**Received from $ARGUMENTS**: All arguments after "extract"

**Expected format**:
```
scope:"<file-or-module>" type:"<extraction-type>" target:"<what-to-extract>" [reason:"<motivation>"]
```

**Parameter definitions**:
- `scope` (REQUIRED): File or module to refactor (e.g., "UserService.ts", "src/components/UserProfile.tsx")
- `type` (REQUIRED): Type of extraction
  - `method` - Extract method/function from long function
  - `class` - Extract class from large class or god object
  - `module` - Extract module from large file
  - `component` - Extract React/Vue component
  - `utility` - Extract utility function
  - `interface` - Extract TypeScript interface/type
- `target` (REQUIRED): What to extract (e.g., "email validation logic", "payment processing", "UserForm header")
- `reason` (OPTIONAL): Motivation for extraction (e.g., "reduce complexity", "reusability", "single responsibility")

## Workflow

### 1. Validation

Verify extraction prerequisites:

```bash
# File exists
test -f <scope> || echo "Error: File not found"

# File has adequate test coverage
npm test -- --coverage <scope>
# Check coverage > 70%

# Git status is clean
git status --short
# Should be empty or only show untracked files
```

**Stop if**:
- File doesn't exist
- Test coverage < 70%
- Uncommitted changes in working directory

### 2. Analyze Dependencies

Understand what the code depends on:

```bash
# Find imports in file
grep -E "^import" <scope>

# Find usages of target
grep -n "<target>" <scope>

# Check if target is exported
grep -E "^export.*<target>" <scope>
```

**Document**:
- What dependencies target uses
- What depends on target (callers)
- Potential side effects
- Shared state access

### 3. Choose Extraction Strategy

Based on extraction type:

#### Type: method

**When to use**:
- Function > 50 lines
- Function complexity > 10
- Code block has clear purpose
- Duplicated logic in same file

**Strategy**:
1. Identify self-contained code block
2. Identify parameters needed
3. Identify return value
4. Extract to private method first
5. Make public if needed elsewhere

#### Type: class

**When to use**:
- Class > 300 lines
- Class has multiple responsibilities
- Group of related methods
- Clear cohesion within subset

**Strategy**:
1. Identify cohesive group of methods/properties
2. Define interface for new class
3. Extract to separate class
4. Use composition or delegation
5. Update original class to use new class

#### Type: module

**When to use**:
- File > 500 lines
- Multiple unrelated functions
- Natural separation of concerns
- Different import patterns

**Strategy**:
1. Group related functions
2. Create new module file
3. Move functions and their dependencies
4. Update imports in original file
5. Re-export from original if needed for compatibility

#### Type: component

**When to use**:
- Component > 200 lines
- Reusable UI pattern
- Complex nested JSX
- Clear UI responsibility

**Strategy**:
1. Identify self-contained JSX block
2. Determine props needed
3. Extract event handlers
4. Extract local state if appropriate
5. Create new component file
6. Import and use in original

#### Type: utility

**When to use**:
- Pure function used in multiple places
- Business logic without side effects
- Validation, formatting, calculation
- Clear input/output contract

**Strategy**:
1. Ensure function is pure (no side effects)
2. Move to appropriate utils directory
3. Add comprehensive tests
4. Update imports in all usages
5. Export from utils index

#### Type: interface

**When to use**:
- Complex type used in multiple files
- API contract definition
- Shared data structures
- Type reusability

**Strategy**:
1. Identify shared type definitions
2. Create types file in appropriate location
3. Move interface/type definitions
4. Update imports in all files
5. Consider organizing in types directory

### 4. Execute Extraction

Perform the extraction following chosen strategy:

## Extraction Examples

### Example 1: Extract Method

**Before** (Complexity: 15, 73 lines):
```typescript
// UserService.ts
class UserService {
  async registerUser(userData: any) {
    // Validation (20 lines)
    if (!userData.email) throw new Error("Email required");
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(userData.email)) throw new Error("Invalid email");
    if (!userData.password || userData.password.length < 8) {
      throw new Error("Password must be at least 8 characters");
    }
    const hasUpper = /[A-Z]/.test(userData.password);
    const hasLower = /[a-z]/.test(userData.password);
    const hasNumber = /[0-9]/.test(userData.password);
    if (!hasUpper || !hasLower || !hasNumber) {
      throw new Error("Password must contain uppercase, lowercase, and number");
    }

    // Check existing user (5 lines)
    const existing = await this.db.users.findOne({ email: userData.email });
    if (existing) {
      throw new Error("Email already registered");
    }

    // Hash password (3 lines)
    const hashedPassword = await bcrypt.hash(userData.password, 10);

    // Create user (10 lines)
    const user = await this.db.users.create({
      email: userData.email,
      password: hashedPassword,
      name: userData.name,
      role: userData.role || 'user',
      status: 'active',
      createdAt: new Date(),
      updatedAt: new Date()
    });

    // Send emails (15 lines)
    await this.emailService.sendWelcomeEmail(user.email);
    await this.emailService.sendVerificationEmail(user.email, user.id);

    // Log activity (10 lines)
    await this.activityLogger.log({
      action: 'user_registered',
      userId: user.id,
      timestamp: new Date(),
      metadata: { source: 'web' }
    });

    // Return user (10 lines)
    return {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      createdAt: user.createdAt
    };
  }
}
```

**After** (Complexity: 3, 12 lines):
```typescript
// UserService.ts
class UserService {
  async registerUser(userData: RegisterUserInput): Promise<UserDTO> {
    await this.validateRegistration(userData);
    await this.checkEmailAvailability(userData.email);

    const hashedPassword = await this.hashPassword(userData.password);
    const user = await this.createUser({ ...userData, password: hashedPassword });

    await this.sendRegistrationEmails(user);
    await this.logRegistrationActivity(user);

    return this.mapToDTO(user);
  }

  private async validateRegistration(data: RegisterUserInput): Promise<void> {
    validateEmail(data.email);
    validatePassword(data.password);
  }

  private async checkEmailAvailability(email: string): Promise<void> {
    const existing = await this.db.users.findOne({ email });
    if (existing) {
      throw new UserAlreadyExistsError(email);
    }
  }

  private async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 10);
  }

  private async createUser(data: CreateUserData): Promise<User> {
    return this.db.users.create({
      ...data,
      role: data.role || 'user',
      status: 'active',
      createdAt: new Date(),
      updatedAt: new Date()
    });
  }

  private async sendRegistrationEmails(user: User): Promise<void> {
    await Promise.all([
      this.emailService.sendWelcomeEmail(user.email),
      this.emailService.sendVerificationEmail(user.email, user.id)
    ]);
  }

  private async logRegistrationActivity(user: User): Promise<void> {
    await this.activityLogger.log({
      action: 'user_registered',
      userId: user.id,
      timestamp: new Date(),
      metadata: { source: 'web' }
    });
  }

  private mapToDTO(user: User): UserDTO {
    return {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      createdAt: user.createdAt
    };
  }
}
```

**Improvements**:
- Complexity: 15 → 3 (80% reduction)
- Main function: 73 lines → 12 lines (84% reduction)
- Testability: Each method can be tested independently
- Readability: Clear intent, self-documenting
- Reusability: Methods can be reused in other contexts
- Type safety: Proper interfaces instead of 'any'

---

### Example 2: Extract Class

**Before** (812 lines, 5 responsibilities):
```typescript
// UserService.ts - God Object with too many responsibilities
class UserService {
  // CRUD operations (200 lines)
  async create(data: any) { /* ... */ }
  async findById(id: string) { /* ... */ }
  async update(id: string, data: any) { /* ... */ }
  async delete(id: string) { /* ... */ }
  async list(filters: any) { /* ... */ }

  // Validation (150 lines)
  validateEmail(email: string) { /* ... */ }
  validatePassword(password: string) { /* ... */ }
  validateName(name: string) { /* ... */ }
  validateRole(role: string) { /* ... */ }

  // Authentication (180 lines)
  async login(email: string, password: string) { /* ... */ }
  async logout(userId: string) { /* ... */ }
  async resetPassword(email: string) { /* ... */ }
  async changePassword(userId: string, oldPass: string, newPass: string) { /* ... */ }

  // Notifications (142 lines)
  async sendWelcomeEmail(userId: string) { /* ... */ }
  async sendPasswordResetEmail(userId: string) { /* ... */ }
  async sendAccountStatusEmail(userId: string, status: string) { /* ... */ }

  // Activity logging (140 lines)
  async logLogin(userId: string) { /* ... */ }
  async logLogout(userId: string) { /* ... */ }
  async logPasswordChange(userId: string) { /* ... */ }
  async getActivityHistory(userId: string) { /* ... */ }
}
```

**After** (Clean separation of concerns):
```typescript
// users/UserRepository.ts - Data access only (200 lines)
export class UserRepository {
  constructor(private db: Database) {}

  async create(data: CreateUserData): Promise<User> {
    return this.db.users.create(data);
  }

  async findById(id: string): Promise<User | null> {
    return this.db.users.findOne({ id });
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.db.users.findOne({ email });
  }

  async update(id: string, data: Partial<User>): Promise<User> {
    return this.db.users.update({ id }, data);
  }

  async delete(id: string): Promise<void> {
    await this.db.users.delete({ id });
  }

  async list(filters: UserFilters): Promise<User[]> {
    return this.db.users.find(filters);
  }
}

// users/UserValidator.ts - Validation only (150 lines)
export class UserValidator {
  validateEmail(email: string): void {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      throw new ValidationError("Invalid email format");
    }
  }

  validatePassword(password: string): void {
    if (password.length < 8) {
      throw new ValidationError("Password must be at least 8 characters");
    }

    const hasUpper = /[A-Z]/.test(password);
    const hasLower = /[a-z]/.test(password);
    const hasNumber = /[0-9]/.test(password);

    if (!hasUpper || !hasLower || !hasNumber) {
      throw new ValidationError(
        "Password must contain uppercase, lowercase, and number"
      );
    }
  }

  validateName(name: string): void {
    if (!name || name.trim().length < 2) {
      throw new ValidationError("Name must be at least 2 characters");
    }
  }

  validateRole(role: string): void {
    const validRoles = ['admin', 'user', 'moderator'];
    if (!validRoles.includes(role)) {
      throw new ValidationError(`Role must be one of: ${validRoles.join(', ')}`);
    }
  }
}

// auth/AuthenticationService.ts - Authentication only (180 lines)
export class AuthenticationService {
  constructor(
    private userRepository: UserRepository,
    private tokenService: TokenService
  ) {}

  async login(email: string, password: string): Promise<AuthToken> {
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      throw new AuthenticationError("Invalid credentials");
    }

    const passwordMatch = await bcrypt.compare(password, user.password);
    if (!passwordMatch) {
      throw new AuthenticationError("Invalid credentials");
    }

    return this.tokenService.generateToken(user);
  }

  async logout(userId: string): Promise<void> {
    await this.tokenService.revokeTokens(userId);
  }

  async resetPassword(email: string): Promise<void> {
    const user = await this.userRepository.findByEmail(email);
    if (!user) {
      // Don't reveal if email exists
      return;
    }

    const resetToken = await this.tokenService.generateResetToken(user);
    await this.notificationService.sendPasswordResetEmail(user.email, resetToken);
  }

  async changePassword(
    userId: string,
    oldPassword: string,
    newPassword: string
  ): Promise<void> {
    const user = await this.userRepository.findById(userId);
    if (!user) {
      throw new NotFoundError("User not found");
    }

    const passwordMatch = await bcrypt.compare(oldPassword, user.password);
    if (!passwordMatch) {
      throw new AuthenticationError("Current password is incorrect");
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await this.userRepository.update(userId, { password: hashedPassword });
  }
}

// notifications/UserNotificationService.ts - Notifications only (142 lines)
export class UserNotificationService {
  constructor(private emailService: EmailService) {}

  async sendWelcomeEmail(user: User): Promise<void> {
    await this.emailService.send({
      to: user.email,
      subject: "Welcome to Our Platform!",
      template: "welcome",
      data: { name: user.name }
    });
  }

  async sendPasswordResetEmail(email: string, token: string): Promise<void> {
    await this.emailService.send({
      to: email,
      subject: "Reset Your Password",
      template: "password-reset",
      data: { resetLink: `https://app.com/reset/${token}` }
    });
  }

  async sendAccountStatusEmail(user: User, status: string): Promise<void> {
    await this.emailService.send({
      to: user.email,
      subject: `Account Status: ${status}`,
      template: "account-status",
      data: { name: user.name, status }
    });
  }
}

// activity/UserActivityLogger.ts - Logging only (140 lines)
export class UserActivityLogger {
  constructor(private activityRepository: ActivityRepository) {}

  async logLogin(userId: string): Promise<void> {
    await this.activityRepository.create({
      userId,
      action: 'login',
      timestamp: new Date(),
      metadata: { ip: '...' }
    });
  }

  async logLogout(userId: string): Promise<void> {
    await this.activityRepository.create({
      userId,
      action: 'logout',
      timestamp: new Date()
    });
  }

  async logPasswordChange(userId: string): Promise<void> {
    await this.activityRepository.create({
      userId,
      action: 'password_change',
      timestamp: new Date()
    });
  }

  async getActivityHistory(userId: string): Promise<Activity[]> {
    return this.activityRepository.findByUser(userId);
  }
}

// users/UserService.ts - Orchestrator (120 lines)
export class UserService {
  constructor(
    private repository: UserRepository,
    private validator: UserValidator,
    private authService: AuthenticationService,
    private notificationService: UserNotificationService,
    private activityLogger: UserActivityLogger
  ) {}

  async registerUser(data: RegisterUserInput): Promise<User> {
    // Validate
    this.validator.validateEmail(data.email);
    this.validator.validatePassword(data.password);
    this.validator.validateName(data.name);

    // Check availability
    const existing = await this.repository.findByEmail(data.email);
    if (existing) {
      throw new ConflictError("Email already registered");
    }

    // Create user
    const hashedPassword = await bcrypt.hash(data.password, 10);
    const user = await this.repository.create({
      ...data,
      password: hashedPassword
    });

    // Send notifications
    await this.notificationService.sendWelcomeEmail(user);

    // Log activity
    await this.activityLogger.logLogin(user.id);

    return user;
  }

  // Other orchestration methods...
}
```

**Improvements**:
- Single file: 812 lines → 6 focused files (~150 lines each)
- Single Responsibility Principle: Each class has one job
- Testability: Each class can be tested independently
- Dependency Injection: Loose coupling, easy to mock
- Reusability: Components can be reused in different contexts
- Maintainability: Changes isolated to specific files

---

### Example 3: Extract Module

**Before** (src/utils/helpers.ts - 623 lines):
```typescript
// All utilities in one giant file
export function formatDate(date: Date) { /* ... */ }
export function parseDate(str: string) { /* ... */ }
export function addDays(date: Date, days: number) { /* ... */ }
export function formatCurrency(amount: number) { /* ... */ }
export function parseCurrency(str: string) { /* ... */ }
export function validateEmail(email: string) { /* ... */ }
export function validatePhone(phone: string) { /* ... */ }
export function sanitizeHtml(html: string) { /* ... */ }
export function escapeRegex(str: string) { /* ... */ }
export function debounce(fn: Function, ms: number) { /* ... */ }
export function throttle(fn: Function, ms: number) { /* ... */ }
// ... 50+ more functions
```

**After** (Organized by domain):
```typescript
// src/utils/date.ts
export function formatDate(date: Date, format: string): string { /* ... */ }
export function parseDate(str: string): Date { /* ... */ }
export function addDays(date: Date, days: number): Date { /* ... */ }
export function subtractDays(date: Date, days: number): Date { /* ... */ }
export function diffDays(date1: Date, date2: Date): number { /* ... */ }
export function isWeekend(date: Date): boolean { /* ... */ }

// src/utils/currency.ts
export function formatCurrency(amount: number, currency: string): string { /* ... */ }
export function parseCurrency(str: string): number { /* ... */ }
export function convertCurrency(amount: number, from: string, to: string): number { /* ... */ }

// src/utils/validation.ts
export function validateEmail(email: string): boolean { /* ... */ }
export function validatePhone(phone: string): boolean { /* ... */ }
export function validateUrl(url: string): boolean { /* ... */ }
export function validateCreditCard(cardNumber: string): boolean { /* ... */ }

// src/utils/string.ts
export function sanitizeHtml(html: string): string { /* ... */ }
export function escapeRegex(str: string): string { /* ... */ }
export function truncate(str: string, length: number): string { /* ... */ }
export function slugify(str: string): string { /* ... */ }

// src/utils/function.ts
export function debounce<T extends Function>(fn: T, ms: number): T { /* ... */ }
export function throttle<T extends Function>(fn: T, ms: number): T { /* ... */ }
export function memoize<T extends Function>(fn: T): T { /* ... */ }

// src/utils/index.ts - Convenience exports
export * from './date';
export * from './currency';
export * from './validation';
export * from './string';
export * from './function';
```

**Improvements**:
- Organization: Functions grouped by domain
- Discoverability: Easier to find related functions
- Testing: Each module can have focused test file
- Bundle size: Tree-shaking works better
- Maintainability: Changes isolated to specific modules

---

### Example 4: Extract Component (React)

**Before** (UserProfile.tsx - 347 lines):
```typescript
export function UserProfile({ userId }: Props) {
  const [user, setUser] = useState<User | null>(null);
  const [editing, setEditing] = useState(false);
  const [formData, setFormData] = useState<FormData>({});
  const [errors, setErrors] = useState<Errors>({});
  const [loading, setLoading] = useState(false);

  // Load user (20 lines)
  useEffect(() => { /* ... */ }, [userId]);

  // Form handlers (30 lines)
  const handleChange = (e: ChangeEvent) => { /* ... */ };
  const handleSubmit = async (e: FormEvent) => { /* ... */ };
  const handleCancel = () => { /* ... */ };

  // Validation (40 lines)
  const validateForm = () => { /* ... */ };
  const validateEmail = (email: string) => { /* ... */ };
  const validatePhone = (phone: string) => { /* ... */ };

  if (loading) return <LoadingSpinner />;
  if (!user) return <NotFound />;

  return (
    <div className="user-profile">
      {/* Header section (60 lines of JSX) */}
      <div className="profile-header">
        <img src={user.avatar} alt={user.name} />
        <h1>{user.name}</h1>
        <p>{user.email}</p>
        <div className="profile-stats">
          <div className="stat">
            <span className="stat-value">{user.posts}</span>
            <span className="stat-label">Posts</span>
          </div>
          <div className="stat">
            <span className="stat-value">{user.followers}</span>
            <span className="stat-label">Followers</span>
          </div>
          <div className="stat">
            <span className="stat-value">{user.following}</span>
            <span className="stat-label">Following</span>
          </div>
        </div>
        <button onClick={() => setEditing(true)}>Edit Profile</button>
      </div>

      {/* Edit form section (80 lines of JSX) */}
      {editing && (
        <div className="edit-form">
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label>Name</label>
              <input
                type="text"
                value={formData.name}
                onChange={handleChange}
                name="name"
              />
              {errors.name && <span className="error">{errors.name}</span>}
            </div>
            {/* Many more form fields... */}
            <div className="form-actions">
              <button type="submit">Save</button>
              <button type="button" onClick={handleCancel}>Cancel</button>
            </div>
          </form>
        </div>
      )}

      {/* Activity section (70 lines of JSX) */}
      <div className="profile-activity">
        <h2>Recent Activity</h2>
        <div className="activity-list">
          {user.activities.map(activity => (
            <div key={activity.id} className="activity-item">
              <div className="activity-icon">
                {/* Activity icon logic */}
              </div>
              <div className="activity-content">
                <p>{activity.description}</p>
                <span className="activity-time">
                  {formatDate(activity.timestamp)}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Settings section (60 lines of JSX) */}
      <div className="profile-settings">
        {/* Settings UI */}
      </div>
    </div>
  );
}
```

**After** (Extracted into focused components):
```typescript
// UserProfile.tsx - Main orchestrator (80 lines)
export function UserProfile({ userId }: Props) {
  const { user, loading, error } = useUser(userId);
  const [editing, setEditing] = useState(false);

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;
  if (!user) return <NotFound />;

  return (
    <div className="user-profile">
      <ProfileHeader
        user={user}
        onEdit={() => setEditing(true)}
      />

      {editing && (
        <ProfileEditForm
          user={user}
          onSave={() => setEditing(false)}
          onCancel={() => setEditing(false)}
        />
      )}

      <ProfileActivity activities={user.activities} />
      <ProfileSettings user={user} />
    </div>
  );
}

// components/ProfileHeader.tsx (60 lines)
interface ProfileHeaderProps {
  user: User;
  onEdit: () => void;
}

export function ProfileHeader({ user, onEdit }: ProfileHeaderProps) {
  return (
    <div className="profile-header">
      <Avatar src={user.avatar} alt={user.name} size="large" />
      <h1>{user.name}</h1>
      <p>{user.email}</p>
      <ProfileStats
        posts={user.posts}
        followers={user.followers}
        following={user.following}
      />
      <Button onClick={onEdit}>Edit Profile</Button>
    </div>
  );
}

// components/ProfileStats.tsx (30 lines)
interface ProfileStatsProps {
  posts: number;
  followers: number;
  following: number;
}

export function ProfileStats({ posts, followers, following }: ProfileStatsProps) {
  return (
    <div className="profile-stats">
      <StatItem value={posts} label="Posts" />
      <StatItem value={followers} label="Followers" />
      <StatItem value={following} label="Following" />
    </div>
  );
}

function StatItem({ value, label }: { value: number; label: string }) {
  return (
    <div className="stat">
      <span className="stat-value">{value}</span>
      <span className="stat-label">{label}</span>
    </div>
  );
}

// components/ProfileEditForm.tsx (90 lines)
interface ProfileEditFormProps {
  user: User;
  onSave: (data: UserUpdateData) => void;
  onCancel: () => void;
}

export function ProfileEditForm({ user, onSave, onCancel }: ProfileEditFormProps) {
  const { formData, errors, handleChange, handleSubmit } = useProfileForm(user, onSave);

  return (
    <div className="edit-form">
      <form onSubmit={handleSubmit}>
        <FormField
          label="Name"
          name="name"
          value={formData.name}
          error={errors.name}
          onChange={handleChange}
        />
        <FormField
          label="Email"
          name="email"
          type="email"
          value={formData.email}
          error={errors.email}
          onChange={handleChange}
        />
        {/* More fields... */}
        <FormActions onSave={handleSubmit} onCancel={onCancel} />
      </form>
    </div>
  );
}

// components/ProfileActivity.tsx (70 lines)
interface ProfileActivityProps {
  activities: Activity[];
}

export function ProfileActivity({ activities }: ProfileActivityProps) {
  return (
    <div className="profile-activity">
      <h2>Recent Activity</h2>
      <ActivityList activities={activities} />
    </div>
  );
}

function ActivityList({ activities }: { activities: Activity[] }) {
  return (
    <div className="activity-list">
      {activities.map(activity => (
        <ActivityItem key={activity.id} activity={activity} />
      ))}
    </div>
  );
}

function ActivityItem({ activity }: { activity: Activity }) {
  return (
    <div className="activity-item">
      <ActivityIcon type={activity.type} />
      <div className="activity-content">
        <p>{activity.description}</p>
        <span className="activity-time">
          {formatDate(activity.timestamp)}
        </span>
      </div>
    </div>
  );
}
```

**Improvements**:
- Single file: 347 lines → Multiple focused components (~60 lines each)
- Reusability: Components like ProfileStats, ActivityItem can be reused
- Testability: Each component easily tested in isolation
- Readability: Clear component boundaries and responsibilities
- Maintainability: Changes isolated to specific components
- Performance: Components can be memoized independently

---

### Example 5: Extract Utility

**Before** (Validation duplicated across components):
```typescript
// UserForm.tsx
function validateEmail(email: string): boolean {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}

// ProfileForm.tsx
function validateEmail(email: string): boolean {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}

// RegistrationForm.tsx
function validateEmail(email: string): boolean {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}

// SettingsForm.tsx
function validateEmail(email: string): boolean {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}
```

**After** (Single source of truth):
```typescript
// utils/validation.ts
export function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

export function validatePassword(password: string): ValidationResult {
  const errors: string[] = [];

  if (password.length < 8) {
    errors.push("Password must be at least 8 characters");
  }

  if (!/[A-Z]/.test(password)) {
    errors.push("Password must contain uppercase letter");
  }

  if (!/[a-z]/.test(password)) {
    errors.push("Password must contain lowercase letter");
  }

  if (!/[0-9]/.test(password)) {
    errors.push("Password must contain number");
  }

  return {
    valid: errors.length === 0,
    errors
  };
}

export function validatePhone(phone: string): boolean {
  const phoneRegex = /^\+?[1-9]\d{1,14}$/;
  return phoneRegex.test(phone.replace(/[\s-]/g, ''));
}

// All forms now import
import { validateEmail, validatePassword, validatePhone } from '@/utils/validation';
```

**Improvements**:
- DRY: Single source of truth for validation
- Testability: Validation logic tested once
- Consistency: All forms use same validation
- Maintainability: Update validation in one place
- Reusability: Can be used in backend validation too

---

### Example 6: Extract Interface

**Before** (Type definitions scattered):
```typescript
// UserService.ts
export class UserService {
  async getUser(id: string): Promise<{ id: string; name: string; email: string }> {
    // ...
  }
}

// UserComponent.tsx
function UserComponent({ user }: { user: { id: string; name: string; email: string } }) {
  // ...
}

// UserRepository.ts
export class UserRepository {
  async findById(id: string): Promise<{ id: string; name: string; email: string } | null> {
    // ...
  }
}
```

**After** (Centralized type definitions):
```typescript
// types/user.ts
export interface User {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  createdAt: Date;
  updatedAt: Date;
}

export type UserRole = 'admin' | 'user' | 'moderator';

export interface CreateUserInput {
  name: string;
  email: string;
  password: string;
  role?: UserRole;
}

export interface UpdateUserInput {
  name?: string;
  email?: string;
  role?: UserRole;
}

export interface UserDTO {
  id: string;
  name: string;
  email: string;
  role: UserRole;
}

// All files now import
import { User, UserDTO, CreateUserInput, UpdateUserInput } from '@/types/user';

// UserService.ts
export class UserService {
  async getUser(id: string): Promise<User> {
    // ...
  }
}

// UserComponent.tsx
function UserComponent({ user }: { user: UserDTO }) {
  // ...
}

// UserRepository.ts
export class UserRepository {
  async findById(id: string): Promise<User | null> {
    // ...
  }
}
```

**Improvements**:
- Consistency: Same types used everywhere
- Type safety: Catch type mismatches at compile time
- Maintainability: Update types in one place
- Documentation: Types serve as API contracts
- Intellisense: Better IDE autocomplete

---

## Output Format

```markdown
# Extraction Report: <target>

## Overview
**Scope**: <file>
**Type**: <extraction-type>
**Target**: <what-was-extracted>
**Reason**: <motivation>

## Before Extraction

**Metrics**:
- File size: <lines>
- Function complexity: <value>
- Test coverage: <percentage>

**Issues**:
- <issue 1>
- <issue 2>

## Extraction Performed

**Created**:
- <new-file-1>
- <new-file-2>

**Modified**:
- <original-file>
- <other-affected-files>

**Code Changes**:
[Include before/after examples]

## After Extraction

**Metrics**:
- Original file: <lines> → <lines> (<percentage> reduction)
- New files: <count> files, <lines> total
- Complexity: <before> → <after> (<percentage> improvement)
- Test coverage: <before%> → <after%>

**Improvements**:
1. <improvement 1>
2. <improvement 2>
3. <improvement 3>

## Testing

**Tests Updated**:
- <test-file-1>: Updated to test extracted code
- <test-file-2>: New tests for extracted module

**Coverage**:
- Before: <percentage>
- After: <percentage>
- Change: <delta>

## Migration Notes

**Breaking Changes**: <none-or-description>

**How to Use New Code**:
```typescript
// Old usage
<old-code>

// New usage
<new-code>
```

## Next Steps

**Recommendations**:
1. <next-refactoring-opportunity>
2. <another-opportunity>

---

**Extraction Complete**: Code successfully extracted and verified.
```

## Error Handling

**File not found**:
```
Error: Cannot find file: <scope>

Please verify the file path and try again.
```

**Insufficient test coverage**:
```
Warning: Test coverage for <scope> is only <percentage>%.

Extracting code with low test coverage is risky. Recommendations:
1. Add tests before extraction
2. Reduce extraction scope
3. Proceed with caution (not recommended)
```

**Unclear target**:
```
Error: Cannot identify what to extract from target: "<target>"

Please provide specific:
- Function name: "validateEmail"
- Class name: "PaymentProcessor"
- Component name: "UserForm"
- Code description: "validation logic on lines 45-87"
```

**Complex dependencies**:
```
Warning: Target has complex dependencies that may be difficult to extract:
- Accesses 8 different instance variables
- Calls 12 different methods
- Has side effects (mutates state, makes API calls)

Recommendations:
1. Simplify dependencies first
2. Use dependency injection
3. Extract smaller pieces iteratively
```
