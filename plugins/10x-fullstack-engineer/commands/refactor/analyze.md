# Code Quality Analysis Operation

Analyze code quality, identify code smells, calculate metrics, and prioritize refactoring opportunities.

## Parameters

**Received from $ARGUMENTS**: All arguments after "analyze"

**Expected format**:
```
scope:"<path-or-description>" [metrics:"<metric1,metric2>"] [depth:"quick|standard|detailed"]
```

**Parameter definitions**:
- `scope` (REQUIRED): Path to analyze or description (e.g., "user-service/", "authentication module", "src/components/UserProfile.tsx")
- `metrics` (OPTIONAL): Comma-separated metrics to analyze (default: all)
  - `complexity` - Cyclomatic complexity
  - `duplication` - Code duplication detection
  - `coverage` - Test coverage analysis
  - `dependencies` - Dependency analysis and circular dependencies
  - `types` - Type coverage (TypeScript projects)
  - `smells` - Code smells detection
- `depth` (OPTIONAL): Analysis depth (default: standard)
  - `quick` - Fast scan, high-level metrics only
  - `standard` - Balanced analysis with key metrics
  - `detailed` - Comprehensive deep analysis with recommendations

## Workflow

### 1. Pre-Analysis Verification

Before analyzing, verify:

```bash
# Check if scope exists
test -e <scope> || echo "Error: Scope path does not exist"

# Check if project has package.json
test -f package.json || echo "Warning: No package.json found"

# Verify analysis tools availability
command -v npx >/dev/null 2>&1 || echo "Warning: npm/npx not available"
```

### 2. Complexity Analysis

**Measure cyclomatic complexity** using ESLint:

```bash
# Run complexity analysis
npx eslint <scope> \
  --ext .js,.jsx,.ts,.tsx \
  --rule 'complexity: [error, { max: 10 }]' \
  --rule 'max-depth: [error, 3]' \
  --rule 'max-lines-per-function: [error, { max: 50 }]' \
  --rule 'max-params: [error, 4]' \
  --format json > complexity-report.json

# Or use script
./.scripts/analyze-complexity.sh <scope>
```

**Identify**:
- Functions with complexity > 10 (high risk)
- Functions with complexity 6-10 (moderate risk)
- Deep nesting (>3 levels)
- Long functions (>50 lines)
- Long parameter lists (>4 parameters)

**Report format**:
```markdown
### Complexity Analysis

**Critical Issues** (Complexity > 10):
1. `UserService.validateAndCreateUser()` - Complexity: 18 (45 lines)
   - Location: src/services/UserService.ts:127
   - Impact: High - Used in 8 places
   - Recommendation: Extract validation logic into separate functions

2. `OrderProcessor.processPayment()` - Complexity: 15 (38 lines)
   - Location: src/services/OrderProcessor.ts:89
   - Impact: Medium - Payment critical path
   - Recommendation: Use strategy pattern for payment methods

**Moderate Issues** (Complexity 6-10):
- 12 functions identified
- Average complexity: 7.3
- Recommendation: Monitor, refactor opportunistically
```

### 3. Duplication Detection

**Detect duplicate code** using jsinspect:

```bash
# Find duplicated code blocks
npx jsinspect <scope> \
  --threshold 30 \
  --min-instances 2 \
  --ignore "node_modules|dist|build" \
  --reporter json > duplication-report.json

# Or use script
./.scripts/detect-duplication.sh <scope>
```

**Identify**:
- Exact duplicates (100% match)
- Near duplicates (>80% similar)
- Copy-paste patterns
- Repeated logic across files

**Report format**:
```markdown
### Code Duplication

**Exact Duplicates** (100% match):
1. Validation logic (42 lines) - 5 instances
   - src/components/UserForm.tsx:45-87
   - src/components/ProfileForm.tsx:32-74
   - src/components/RegistrationForm.tsx:56-98
   - src/components/SettingsForm.tsx:23-65
   - src/components/AdminForm.tsx:89-131
   - **Recommendation**: Extract to shared validator utility
   - **Estimated savings**: 168 lines (4 duplicates × 42 lines)

**Near Duplicates** (>80% similar):
2. API error handling (18 lines) - 8 instances
   - Average similarity: 87%
   - **Recommendation**: Create centralized error handler
   - **Estimated savings**: 126 lines

**Total Duplication**:
- Duplicate lines: 542 / 8,234 (6.6%)
- Target: < 3%
- **Priority**: HIGH - Significant duplication found
```

### 4. Test Coverage Analysis

**Calculate test coverage**:

```bash
# Run tests with coverage
npm test -- --coverage --watchAll=false

# Generate coverage report
npx nyc report --reporter=json > coverage-report.json

# Or use script
./.scripts/verify-tests.sh <scope>
```

**Identify**:
- Files with < 70% coverage (inadequate)
- Files with 70-80% coverage (acceptable)
- Files with > 80% coverage (good)
- Untested code paths
- Missing edge case tests

**Report format**:
```markdown
### Test Coverage

**Overall Coverage**:
- Statements: 78.5% (Target: 80%)
- Branches: 72.3% (Target: 75%)
- Functions: 81.2% (Target: 80%)
- Lines: 77.8% (Target: 80%)

**Critical Gaps** (< 70% coverage):
1. `src/services/PaymentService.ts` - 45% coverage
   - Missing: Error handling paths
   - Missing: Edge cases (negative amounts, invalid cards)
   - **Risk**: HIGH - Financial logic

2. `src/utils/validation.ts` - 62% coverage
   - Missing: Boundary conditions
   - Missing: Invalid input handling
   - **Risk**: MEDIUM - Used in 15 components

**Recommendation**: Add tests before refactoring these areas.
```

### 5. Dependency Analysis

**Analyze module dependencies**:

```bash
# Check for circular dependencies
npx madge --circular --extensions ts,tsx,js,jsx <scope>

# Generate dependency graph
npx madge --image deps.png <scope>

# Find orphaned files
npx madge --orphans <scope>
```

**Identify**:
- Circular dependencies (breaks modularity)
- Highly coupled modules
- God objects (too many dependencies)
- Orphaned files (unused)
- Deep dependency chains

**Report format**:
```markdown
### Dependency Analysis

**Circular Dependencies** (CRITICAL):
1. UserService ↔ AuthService ↔ SessionService
   - **Impact**: Cannot test in isolation
   - **Recommendation**: Introduce interface/abstraction layer

2. OrderModel ↔ PaymentModel ↔ CustomerModel
   - **Impact**: Tight coupling, difficult to change
   - **Recommendation**: Use repository pattern

**High Coupling**:
- `UserService.ts` - 23 dependencies (Target: < 10)
- `AppConfig.ts` - 18 dependencies (Target: < 10)
- **Recommendation**: Split into smaller, focused modules

**Orphaned Files**: 5 files unused
- src/utils/old-validator.ts (can be deleted)
- src/helpers/deprecated.ts (can be deleted)
```

### 6. Type Coverage Analysis (TypeScript)

**Analyze TypeScript type safety**:

```bash
# Type check with strict mode
npx tsc --noEmit --strict

# Count 'any' usage
grep -r "any" <scope> --include="*.ts" --include="*.tsx" | wc -l

# Check for implicit any
npx tsc --noEmit --noImplicitAny
```

**Identify**:
- Usage of `any` type
- Implicit any declarations
- Missing return type annotations
- Weak type definitions
- Type assertion overuse

**Report format**:
```markdown
### Type Safety Analysis (TypeScript)

**Type Coverage**:
- Files with types: 145 / 167 (87%)
- Any usage: 42 instances (Target: 0)
- Implicit any: 18 instances
- **Rating**: MODERATE - Room for improvement

**Critical Issues**:
1. `src/api/client.ts` - 12 'any' types
   - Functions without return types
   - Untyped API responses
   - **Recommendation**: Add proper interfaces for API contracts

2. `src/utils/helpers.ts` - 8 'any' types
   - Generic utility functions
   - **Recommendation**: Use generics instead of 'any'

**Opportunity**: Eliminate 'any' types for 23% improvement
```

### 7. Code Smells Detection

**Identify common code smells**:

**Long Method** (>50 lines):
- Difficult to understand
- Hard to test
- Often doing too much
- **Fix**: Extract smaller methods

**Long Parameter List** (>4 parameters):
- Difficult to use
- Hard to remember order
- Often indicates missing abstraction
- **Fix**: Introduce parameter object

**Duplicate Code**:
- Maintenance nightmare
- Bug multiplication
- **Fix**: Extract to shared function/component

**Large Class** (>300 lines):
- Too many responsibilities
- Hard to understand
- Difficult to test
- **Fix**: Split into smaller classes

**Switch Statements** (complex conditionals):
- Hard to extend
- Violates Open/Closed Principle
- **Fix**: Use polymorphism or strategy pattern

**Report format**:
```markdown
### Code Smells Detected

**Long Methods**: 23 functions > 50 lines
- Worst: `OrderService.processOrder()` (247 lines)
- **Impact**: Extremely difficult to understand and maintain
- **Priority**: CRITICAL

**Long Parameter Lists**: 18 functions > 4 parameters
- Worst: `createUser(name, email, age, address, phone, role, settings)` (7 params)
- **Fix**: Use `CreateUserParams` object

**Large Classes**: 8 classes > 300 lines
- Worst: `UserService.ts` (842 lines)
- **Responsibilities**: Validation, CRUD, Auth, Notifications, Logging
- **Fix**: Split into focused services

**Switch Statements**: 12 complex conditionals
- `src/services/PaymentProcessor.ts` - Switch on payment method (5 cases, 180 lines)
- **Fix**: Use strategy pattern for payment methods
```

### 8. Generate Prioritized Report

**Priority calculation** based on:
- **Severity**: Critical > High > Medium > Low
- **Impact**: How many files/components affected
- **Risk**: Test coverage, complexity, usage frequency
- **Effort**: Estimated time to fix (hours)
- **Value**: Improvement in maintainability

**Report format**:
```markdown
## Code Quality Analysis Report

### Executive Summary

**Scope Analyzed**: <scope>
**Analysis Date**: <date>
**Total Files**: <count>
**Total Lines**: <count>

**Overall Health Score**: 6.5 / 10 (Needs Improvement)

**Top Priorities**:
1. Eliminate critical code duplication (HIGH)
2. Refactor high-complexity functions (HIGH)
3. Improve test coverage for critical paths (HIGH)
4. Remove circular dependencies (MEDIUM)
5. Strengthen TypeScript type safety (MEDIUM)

---

### Metrics Summary

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Cyclomatic Complexity (avg) | 8.3 | < 6 | ⚠️ Above target |
| Code Duplication | 6.6% | < 3% | ⚠️ Above target |
| Test Coverage | 78.5% | > 80% | ⚠️ Below target |
| Type Coverage | 87% | > 95% | ⚠️ Below target |
| Circular Dependencies | 3 | 0 | ❌ Critical |

---

### Priority 1: Critical Issues (Fix Immediately)

#### 1.1 Circular Dependencies
**Severity**: CRITICAL
**Impact**: Cannot test modules in isolation, tight coupling
**Files Affected**: 8

**Dependencies**:
- UserService ↔ AuthService ↔ SessionService
- OrderModel ↔ PaymentModel ↔ CustomerModel
- ComponentA ↔ ComponentB ↔ ComponentC

**Recommendation**: Introduce dependency injection and interface abstractions
**Estimated Effort**: 8 hours
**Value**: HIGH - Enables independent testing and deployment

#### 1.2 Extremely High Complexity Functions
**Severity**: CRITICAL
**Impact**: Very difficult to understand, test, maintain
**Functions**: 4

**Functions**:
1. `UserService.validateAndCreateUser()` - Complexity: 18
2. `OrderProcessor.processPayment()` - Complexity: 15
3. `ReportGenerator.generateQuarterly()` - Complexity: 14
4. `DataTransformer.transform()` - Complexity: 13

**Recommendation**: Extract smaller functions, use early returns
**Estimated Effort**: 6 hours
**Value**: HIGH - Dramatic readability improvement

---

### Priority 2: High Issues (Fix Soon)

#### 2.1 Significant Code Duplication
**Severity**: HIGH
**Impact**: Maintenance burden, bug multiplication

**Duplicate Code**:
- Validation logic: 5 exact copies (210 lines duplicated)
- Error handling: 8 similar copies (144 lines duplicated)
- Data formatting: 6 copies (96 lines duplicated)

**Recommendation**: Extract to shared utilities
**Estimated Effort**: 4 hours
**Value**: HIGH - 450 lines reduction, single source of truth

#### 2.2 Inadequate Test Coverage
**Severity**: HIGH
**Impact**: High risk of regressions during refactoring

**Critical Gaps**:
- `PaymentService.ts` - 45% coverage (Financial logic!)
- `AuthService.ts` - 58% coverage (Security logic!)
- `validation.ts` - 62% coverage (Used everywhere!)

**Recommendation**: Add comprehensive tests before ANY refactoring
**Estimated Effort**: 8 hours
**Value**: CRITICAL - Enables safe refactoring

---

### Priority 3: Medium Issues (Plan to Fix)

#### 3.1 TypeScript Type Safety
**Severity**: MEDIUM
**Impact**: Runtime errors, poor IDE support

**Issues**:
- 42 usages of 'any' type
- 18 implicit any declarations
- Missing return type annotations

**Recommendation**: Eliminate 'any', add proper types
**Estimated Effort**: 6 hours
**Value**: MEDIUM - Catch errors at compile time

#### 3.2 Long Methods and Large Classes
**Severity**: MEDIUM
**Impact**: Difficult to understand and maintain

**Issues**:
- 23 long methods (>50 lines)
- 8 large classes (>300 lines)
- Single Responsibility Principle violations

**Recommendation**: Extract methods and split classes
**Estimated Effort**: 12 hours
**Value**: MEDIUM - Improved maintainability

---

### Priority 4: Low Issues (Opportunistic)

- Rename unclear variables (quick wins)
- Add missing JSDoc comments
- Consolidate similar utility functions
- Remove unused imports and variables

---

### Recommended Refactoring Sequence

**Week 1**:
1. Add missing tests for critical paths (8 hrs)
2. Fix circular dependencies (8 hrs)

**Week 2**:
3. Eliminate critical code duplication (4 hrs)
4. Refactor highest complexity functions (6 hrs)

**Week 3**:
5. Strengthen TypeScript types (6 hrs)
6. Extract long methods (6 hrs)

**Week 4**:
7. Split large classes (6 hrs)
8. Address remaining medium priority issues

**Total Estimated Effort**: ~54 hours

---

### Code Examples

#### Example 1: High Complexity Function

**Before** (Complexity: 18):
```typescript
async validateAndCreateUser(userData: any) {
  if (!userData.email) {
    throw new Error("Email required");
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(userData.email)) {
    throw new Error("Invalid email");
  }

  if (!userData.password || userData.password.length < 8) {
    throw new Error("Password must be at least 8 characters");
  }

  const hasUpper = /[A-Z]/.test(userData.password);
  const hasLower = /[a-z]/.test(userData.password);
  const hasNumber = /[0-9]/.test(userData.password);

  if (!hasUpper || !hasLower || !hasNumber) {
    throw new Error("Password must contain uppercase, lowercase, and number");
  }

  const existing = await this.db.users.findOne({ email: userData.email });
  if (existing) {
    throw new Error("Email already registered");
  }

  const hashedPassword = await bcrypt.hash(userData.password, 10);

  const user = await this.db.users.create({
    email: userData.email,
    password: hashedPassword,
    name: userData.name,
    createdAt: new Date()
  });

  await this.emailService.sendWelcomeEmail(user.email);

  return user;
}
```

**After** (Complexity: 3):
```typescript
async validateAndCreateUser(userData: CreateUserInput): Promise<User> {
  this.validateUserInput(userData);
  await this.checkEmailAvailability(userData.email);

  const hashedPassword = await this.hashPassword(userData.password);
  const user = await this.createUser({ ...userData, password: hashedPassword });

  await this.sendWelcomeEmail(user);

  return user;
}

private validateUserInput(userData: CreateUserInput): void {
  validateEmail(userData.email);
  validatePassword(userData.password);
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
    createdAt: new Date()
  });
}

private async sendWelcomeEmail(user: User): Promise<void> {
  await this.emailService.sendWelcomeEmail(user.email);
}
```

**Improvements**:
- Complexity: 18 → 3 (83% reduction)
- Lines per function: 37 → 5 (86% reduction)
- Testability: Each function can be tested independently
- Readability: Clear intent, self-documenting code
- Type safety: Proper interfaces instead of 'any'

---

### Next Steps

Based on this analysis, consider:

1. **Immediate Actions**:
   - Add tests for PaymentService, AuthService, validation.ts
   - Fix circular dependencies
   - Review and approve refactoring priorities

2. **Use Refactoring Operations**:
   - `/refactor extract` - For long methods
   - `/refactor duplicate` - For code duplication
   - `/refactor patterns` - For circular dependencies (DI pattern)
   - `/refactor types` - For TypeScript improvements

3. **Continuous Monitoring**:
   - Set up automated complexity checks in CI/CD
   - Track duplication metrics over time
   - Monitor test coverage trends
   - Review code quality in pull requests

---

**Analysis Complete**: Refactoring priorities identified and prioritized by impact and effort.
```

## Output Format

Provide a comprehensive analysis report with:
- Executive summary with health score
- Metrics table (current vs target)
- Prioritized issues (Critical → High → Medium → Low)
- Code examples showing before/after improvements
- Estimated effort and value for each issue
- Recommended refactoring sequence
- Next steps and monitoring recommendations

## Error Handling

**Scope not found**:
```
Error: Specified scope does not exist: <scope>

Please provide a valid path or description:
- Relative path: "src/components/"
- Absolute path: "/full/path/to/code"
- Module description: "user authentication module"
```

**No metrics requested**:
```
Using default metrics: complexity, duplication, coverage, dependencies

To specify metrics: metrics:"complexity,duplication"
```

**Analysis tools not available**:
```
Warning: Some analysis tools not available:
- eslint: Install with 'npm install -D eslint'
- jsinspect: Install with 'npm install -g jsinspect'

Proceeding with available tools...
```
