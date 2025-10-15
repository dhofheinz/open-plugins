# Code Refactoring Skill

Comprehensive code refactoring operations for improving code quality, maintainability, and architecture without changing external behavior.

## Overview

The refactor skill provides systematic, safety-first refactoring operations that follow industry best practices. It helps you identify code quality issues, eliminate technical debt, and modernize legacy code while maintaining test coverage and preserving external behavior.

**Key Principles:**
- **Preserve Behavior**: External behavior must remain unchanged
- **Safety First**: Verify test coverage before refactoring
- **Small Steps**: Incremental changes with frequent testing
- **Test-Driven**: Tests pass before, during, and after refactoring
- **One Thing at a Time**: Don't mix refactoring with feature development
- **Reversible**: Easy to revert if something goes wrong

## Available Operations

| Operation | Description | Use When |
|-----------|-------------|----------|
| **analyze** | Analyze code quality and identify opportunities | Starting refactoring session, need metrics |
| **extract** | Extract methods, classes, modules, components | Functions too long, repeated code |
| **patterns** | Introduce design patterns | Complex conditionals, tight coupling |
| **types** | Improve TypeScript type safety | Using 'any', weak types, no types |
| **duplicate** | Eliminate code duplication | Copy-paste code, DRY violations |
| **modernize** | Update legacy code patterns | Callbacks, var, jQuery, class components |

## Usage

### Basic Syntax

```bash
/refactor <operation> <parameters>
```

### Parameter Format

All operations use key:value parameter format:

```bash
/refactor analyze scope:"src/" metrics:"complexity,duplication" depth:"detailed"
/refactor extract scope:"UserService.ts" type:"method" target:"validateEmail"
/refactor patterns scope:"services/" pattern:"dependency-injection"
```

## Operations Guide

### 1. Analyze - Code Quality Analysis

Identify refactoring opportunities through comprehensive code analysis.

**Parameters:**
- `scope` (required): Path to analyze
- `metrics` (optional): Comma-separated metrics (default: all)
  - `complexity` - Cyclomatic complexity
  - `duplication` - Code duplication detection
  - `coverage` - Test coverage analysis
  - `dependencies` - Circular dependency detection
  - `types` - TypeScript type coverage
  - `smells` - Code smells detection
- `depth` (optional): `quick` | `standard` | `detailed` (default: standard)

**Example:**

```bash
/refactor analyze scope:"src/components" metrics:"complexity,duplication,coverage" depth:"detailed"
```

**What it measures:**
- **Complexity**: Functions with cyclomatic complexity > 10 (high risk)
- **Duplication**: Duplicate code blocks (exact and near matches)
- **Coverage**: Test coverage per file (target: >70%)
- **Dependencies**: Circular dependencies and tight coupling
- **Type Safety**: Usage of 'any' types in TypeScript
- **Code Smells**: Long methods, large classes, switch statements

**Output:** Comprehensive report with prioritized refactoring opportunities, metrics, and estimated effort.

---

### 2. Extract - Method/Class/Module Extraction

Extract code into smaller, focused units to reduce complexity.

**Parameters:**
- `scope` (required): File or module to refactor
- `type` (required): What to extract
  - `method` - Extract method/function
  - `class` - Extract class from large class
  - `module` - Extract module from large file
  - `component` - Extract React/Vue component
  - `utility` - Extract utility function
  - `interface` - Extract TypeScript interface/type
- `target` (required): What to extract (name or description)
- `reason` (optional): Motivation for extraction

**Examples:**

```bash
# Extract long method
/refactor extract scope:"UserService.ts" type:"method" target:"validateAndCreateUser" reason:"reduce complexity"

# Extract reusable component
/refactor extract scope:"UserProfile.tsx" type:"component" target:"ProfileHeader" reason:"reusability"

# Extract shared utility
/refactor extract scope:"formatters.js" type:"utility" target:"formatDate" reason:"used in multiple places"
```

**When to extract:**
- **Method**: Function >50 lines, complexity >10, duplicated logic
- **Class**: Class >300 lines, multiple responsibilities
- **Module**: File >500 lines, unrelated functions
- **Component**: Component >200 lines, reusable UI pattern
- **Utility**: Pure function used in multiple places
- **Interface**: Complex type used in multiple files

**Before/After Example:**

```typescript
// Before: 73 lines, complexity 15
async registerUser(userData: any) {
  // 20 lines of validation
  // 5 lines of existence check
  // 3 lines of password hashing
  // 10 lines of user creation
  // 15 lines of email sending
  // 10 lines of activity logging
  // 10 lines of result mapping
}

// After: 12 lines, complexity 3
async registerUser(userData: RegisterUserInput): Promise<UserDTO> {
  await this.validateRegistration(userData);
  await this.checkEmailAvailability(userData.email);

  const hashedPassword = await this.hashPassword(userData.password);
  const user = await this.createUser({ ...userData, password: hashedPassword });

  await this.sendRegistrationEmails(user);
  await this.logRegistrationActivity(user);

  return this.mapToDTO(user);
}
```

---

### 3. Patterns - Design Pattern Introduction

Introduce proven design patterns to solve recurring design problems.

**Parameters:**
- `scope` (required): Path to apply pattern
- `pattern` (required): Pattern to introduce
  - `factory` - Create objects without specifying exact class
  - `strategy` - Encapsulate interchangeable algorithms
  - `observer` - Publish-subscribe event system
  - `decorator` - Add behavior dynamically
  - `adapter` - Make incompatible interfaces work together
  - `repository` - Abstract data access layer
  - `dependency-injection` - Invert control, improve testability
  - `singleton` - Ensure single instance (use sparingly)
  - `command` - Encapsulate requests as objects
  - `facade` - Simplified interface to complex subsystem
- `reason` (optional): Why introducing this pattern

**Examples:**

```bash
# Eliminate complex switch statement
/refactor patterns scope:"PaymentProcessor.ts" pattern:"strategy" reason:"eliminate switch statement"

# Improve testability
/refactor patterns scope:"services/" pattern:"dependency-injection" reason:"improve testability"

# Decouple event handling
/refactor patterns scope:"UserService.ts" pattern:"observer" reason:"loose coupling"
```

**Pattern Selection Guide:**

| Problem | Pattern | Benefit |
|---------|---------|---------|
| Complex switch/conditionals | Strategy, State | Eliminate conditionals |
| Tight coupling | Dependency Injection, Observer | Loose coupling |
| Complex object creation | Factory, Builder | Centralize creation |
| Can't extend without modifying | Strategy, Decorator | Open/Closed Principle |
| Complex subsystem interface | Facade, Adapter | Simplify interface |
| Data access scattered | Repository | Abstract persistence |

**Before/After Example:**

```typescript
// Before: 180 lines, switch statement with 5 cases
async processPayment(order: Order, method: string) {
  switch (method) {
    case 'credit_card': /* 40 lines */ break;
    case 'paypal': /* 40 lines */ break;
    case 'bank_transfer': /* 40 lines */ break;
    case 'crypto': /* 40 lines */ break;
  }
}

// After: Strategy Pattern, ~30 lines
async processPayment(order: Order, method: string): Promise<PaymentResult> {
  const strategy = this.strategies.get(method);
  if (!strategy) throw new UnsupportedPaymentMethodError(method);

  const result = await strategy.process(order);
  await this.transactionRepo.record(order.id, result);
  await this.notificationService.sendReceipt(order.customer, result);

  return result;
}
```

---

### 4. Types - TypeScript Type Safety

Improve TypeScript type safety by eliminating 'any', adding types, and enabling strict mode.

**Parameters:**
- `scope` (required): Path to improve
- `strategy` (required): Type improvement strategy
  - `add-types` - Add missing type annotations
  - `strengthen-types` - Replace weak types with specific ones
  - `migrate-to-ts` - Convert JavaScript to TypeScript
  - `eliminate-any` - Remove 'any' types
  - `add-generics` - Add generic type parameters
- `strict` (optional): Enable strict TypeScript mode (default: false)

**Examples:**

```bash
# Add missing types
/refactor types scope:"utils/helpers.js" strategy:"add-types"

# Eliminate all 'any' types
/refactor types scope:"api/" strategy:"eliminate-any" strict:"true"

# Migrate JavaScript to TypeScript
/refactor types scope:"src/legacy/" strategy:"migrate-to-ts"

# Add generics for reusability
/refactor types scope:"Repository.ts" strategy:"add-generics"
```

**Type Safety Improvements:**

| Strategy | Before | After | Benefit |
|----------|--------|-------|---------|
| add-types | `function process(data) { }` | `function process(data: Input): Output { }` | Compile-time checks |
| eliminate-any | `async get(): Promise<any>` | `async get<T>(): Promise<T>` | Type safety |
| migrate-to-ts | `.js` with no types | `.ts` with full types | Modern TypeScript |
| add-generics | Separate class per type | `Repository<T>` | DRY, reusable |
| strengthen-types | Weak 'any' types | Strong specific types | Catch errors early |

**Before/After Example:**

```typescript
// Before: Weak 'any' types
async get(endpoint: string): Promise<any> {
  return fetch(endpoint).then(r => r.json());
}

// After: Strong generic types
async get<T>(endpoint: string): Promise<T> {
  const response = await fetch(endpoint);
  if (!response.ok) throw await this.handleError(response);
  return response.json() as T;
}

// Usage with full type safety
const user = await client.get<User>('/users/1');
console.log(user.name); // Autocomplete works!
```

---

### 5. Duplicate - Code Duplication Elimination

Detect and eliminate code duplication through extraction, parameterization, or templating.

**Parameters:**
- `scope` (required): Path to analyze
- `threshold` (optional): Similarity percentage (default: 80)
  - 100: Exact duplicates only
  - 80-99: Near duplicates (recommended)
  - 50-79: Similar patterns
- `strategy` (optional): Consolidation strategy (default: auto-detect)
  - `extract-function` - Extract to shared function
  - `extract-class` - Extract to shared class
  - `parameterize` - Add parameters to reduce duplication
  - `template` - Use template/component pattern

**Examples:**

```bash
# Find and eliminate duplicates
/refactor duplicate scope:"src/validators" threshold:"80" strategy:"extract-function"

# Find exact duplicates only
/refactor duplicate scope:"src/components" threshold:"100"

# Use parameterization
/refactor duplicate scope:"formatters.ts" strategy:"parameterize"
```

**Duplication Metrics:**
- **Target**: < 3% code duplication
- **Exact Duplicates**: 100% match (copy-paste code)
- **Near Duplicates**: 80-99% similar (minor variations)
- **Structural Duplicates**: 50-79% similar (same pattern)

**Before/After Example:**

```typescript
// Before: 5 copies of validation (210 lines duplicated)
// UserForm.tsx, ProfileForm.tsx, RegistrationForm.tsx, SettingsForm.tsx, AdminForm.tsx
function validateForm() {
  const errors: Errors = {};
  // 42 lines of validation logic copied in each file
  return errors;
}

// After: Single implementation (168 lines saved)
// utils/validation.ts
export function validateUserForm(data: FormData): ValidationResult {
  const errors: Record<string, string> = {};

  const emailError = validateEmail(data.email);
  if (emailError) errors.email = emailError;

  const passwordError = validatePassword(data.password);
  if (passwordError) errors.password = passwordError;

  return { valid: Object.keys(errors).length === 0, errors };
}

// All forms import and use shared validation
import { validateUserForm } from '@/utils/validation';
```

---

### 6. Modernize - Legacy Code Modernization

Update legacy code patterns to modern JavaScript/TypeScript standards.

**Parameters:**
- `scope` (required): Path to modernize
- `targets` (required): Comma-separated modernization targets
  - `callbacks-to-async` - Convert callbacks to async/await
  - `var-to-const` - Replace var with const/let
  - `prototypes-to-classes` - Convert prototypes to ES6 classes
  - `commonjs-to-esm` - Convert CommonJS to ES modules
  - `jquery-to-vanilla` - Replace jQuery with vanilla JS
  - `classes-to-hooks` - Convert React class components to hooks
  - `legacy-api` - Update deprecated API usage
- `compatibility` (optional): Target environment (e.g., "node14+", "es2020")

**Examples:**

```bash
# Modernize callback hell
/refactor modernize scope:"legacy-api/" targets:"callbacks-to-async" compatibility:"node14+"

# Update all legacy patterns
/refactor modernize scope:"src/old/" targets:"var-to-const,prototypes-to-classes,commonjs-to-esm"

# Remove jQuery dependency
/refactor modernize scope:"public/js/" targets:"jquery-to-vanilla"

# Convert to React hooks
/refactor modernize scope:"components/" targets:"classes-to-hooks"
```

**Modernization Impact:**

| Target | Improvement | Benefit |
|--------|-------------|---------|
| callbacks-to-async | Flat code vs callback hell | Readability, error handling |
| var-to-const | Block scope vs function scope | Prevent bugs, clarity |
| prototypes-to-classes | ES6 class syntax | Modern, better IDE support |
| commonjs-to-esm | import/export vs require() | Tree-shaking, standard |
| jquery-to-vanilla | Native APIs vs jQuery | -30KB bundle, performance |
| classes-to-hooks | Function components vs classes | Simpler, composable |

**Before/After Example:**

```javascript
// Before: Callback hell (25+ lines, nested 4 levels)
function getUser(userId, callback) {
  db.query('SELECT * FROM users WHERE id = ?', [userId], function(err, user) {
    if (err) return callback(err);
    db.query('SELECT * FROM posts WHERE author_id = ?', [userId], function(err, posts) {
      if (err) return callback(err);
      db.query('SELECT * FROM comments WHERE user_id = ?', [userId], function(err, comments) {
        if (err) return callback(err);
        callback(null, { user, posts, comments });
      });
    });
  });
}

// After: Async/await (8 lines, flat structure)
async function getUser(userId: number): Promise<UserWithContent> {
  const [user, posts, comments] = await Promise.all([
    query<User>('SELECT * FROM users WHERE id = ?', [userId]),
    query<Post[]>('SELECT * FROM posts WHERE author_id = ?', [userId]),
    query<Comment[]>('SELECT * FROM comments WHERE user_id = ?', [userId])
  ]);

  return { user, posts, comments };
}
```

## Pre-Refactoring Safety Checklist

**CRITICAL**: Before ANY refactoring operation, verify:

### ✓ Test Coverage
- [ ] Existing test coverage is adequate (>70% for code being refactored)
- [ ] All tests currently passing
- [ ] Tests are meaningful (test behavior, not implementation)

### ✓ Version Control
- [ ] All changes committed to version control
- [ ] Working on a feature branch (not main/master)
- [ ] Clean working directory (no uncommitted changes)

### ✓ Backup
- [ ] Current state committed with clear message
- [ ] Can easily revert if needed
- [ ] Branch created specifically for this refactoring

### ✓ Scope Definition
- [ ] Clearly defined boundaries of what to refactor
- [ ] No mixing of refactoring with new features
- [ ] Reasonable size for one refactoring session

### ✓ Risk Assessment
- [ ] Understand dependencies and impact
- [ ] Identify potential breaking changes
- [ ] Have rollback plan ready

## Utility Scripts

The refactor skill includes three utility scripts for automated analysis:

### analyze-complexity.sh

Analyzes cyclomatic complexity using ESLint.

```bash
./.scripts/analyze-complexity.sh <scope> [max-complexity]
```

**Features:**
- Detects functions with complexity > threshold
- Identifies deep nesting (>3 levels)
- Finds long functions (>50 lines)
- Checks parameter counts (>4 parameters)
- Generates JSON report with violations

**Output:** `complexity-report.json`

### detect-duplication.sh

Detects code duplication using jsinspect.

```bash
./.scripts/detect-duplication.sh <scope> [threshold]
```

**Features:**
- Finds exact duplicates (100% match)
- Detects near duplicates (>80% similar)
- Identifies structural duplicates
- Calculates duplication statistics
- Provides remediation recommendations

**Output:** `duplication-report.json`

### verify-tests.sh

Verifies test coverage before refactoring.

```bash
./.scripts/verify-tests.sh <scope> [min-coverage]
```

**Features:**
- Runs tests with coverage
- Validates coverage meets minimum threshold
- Identifies files with low coverage
- Prevents unsafe refactoring
- Supports Jest, Mocha, NYC

**Output:** `coverage-report.json`

**Exit codes:**
- 0: Coverage adequate, safe to refactor
- 1: Insufficient coverage, add tests first

## Refactoring Techniques

### Code Smells and Solutions

| Code Smell | Detection | Solution | Operation |
|------------|-----------|----------|-----------|
| **Long Method** | >50 lines | Extract smaller methods | extract |
| **Long Parameter List** | >4 parameters | Introduce parameter object | extract |
| **Duplicate Code** | >3% duplication | Extract to shared function | duplicate |
| **Large Class** | >300 lines | Split into focused classes | extract |
| **Switch Statements** | Complex conditionals | Use polymorphism/strategy | patterns |
| **Feature Envy** | Method uses another class heavily | Move method to that class | extract |
| **Data Clumps** | Same data grouped together | Introduce class/interface | extract |
| **Primitive Obsession** | Primitives instead of objects | Introduce value objects | patterns |

### Refactoring Workflows

#### Workflow 1: High Complexity Function

```bash
# 1. Analyze complexity
/refactor analyze scope:"UserService.ts" metrics:"complexity"

# 2. Identify function with complexity >10
# Result: validateAndCreateUser() has complexity 18

# 3. Extract methods
/refactor extract scope:"UserService.ts" type:"method" target:"validateAndCreateUser"

# 4. Verify improvement
/refactor analyze scope:"UserService.ts" metrics:"complexity"
# Result: Complexity reduced from 18 to 3
```

#### Workflow 2: Code Duplication

```bash
# 1. Detect duplication
/refactor duplicate scope:"src/components" threshold:"80"

# 2. Review duplicate blocks
# Result: Validation logic duplicated in 5 files

# 3. Extract to shared utility
/refactor duplicate scope:"src/components" strategy:"extract-function"

# 4. Verify elimination
/refactor duplicate scope:"src/components" threshold:"80"
# Result: Duplication reduced from 6.6% to 1.1%
```

#### Workflow 3: Legacy Code Modernization

```bash
# 1. Identify legacy patterns
/refactor analyze scope:"src/legacy/" metrics:"all"

# 2. Modernize callbacks to async/await
/refactor modernize scope:"src/legacy/" targets:"callbacks-to-async"

# 3. Update var to const/let
/refactor modernize scope:"src/legacy/" targets:"var-to-const"

# 4. Convert to ES modules
/refactor modernize scope:"src/legacy/" targets:"commonjs-to-esm"

# 5. Verify all tests pass
npm test
```

## Best Practices

### Do's

✅ **Start Small**: Begin with low-risk, high-value refactorings
✅ **Test Continuously**: Run tests after each change
✅ **Commit Frequently**: Small commits with clear messages
✅ **Pair Review**: Have someone review refactored code
✅ **Measure Impact**: Track metrics before and after
✅ **Document Why**: Explain reasoning in commits and comments
✅ **Avoid Scope Creep**: Stay focused on defined scope
✅ **Time Box**: Set time limits for refactoring sessions

### Don'ts

❌ **Mix with Features**: Don't add features while refactoring
❌ **Skip Tests**: Never refactor code with <70% coverage
❌ **Big Bang**: Avoid massive refactorings
❌ **Change Behavior**: External behavior must stay the same
❌ **Uncommitted Changes**: Always commit before refactoring
❌ **Ignore Warnings**: Address all compiler/linter warnings
❌ **Over-Engineer**: Apply patterns only when truly needed
❌ **Rush**: Take time to refactor properly

## Metrics and Goals

### Code Quality Targets

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| Cyclomatic Complexity | <6 | 6-10 | >10 |
| Function Length | <50 lines | 50-100 | >100 |
| Class Length | <300 lines | 300-500 | >500 |
| Parameter Count | <4 | 4-6 | >6 |
| Code Duplication | <3% | 3-8% | >8% |
| Test Coverage | >80% | 70-80% | <70% |
| Type Coverage (TS) | >95% | 90-95% | <90% |

### Refactoring Impact

Track these metrics before and after refactoring:

- **Complexity Reduction**: Cyclomatic complexity decrease
- **Lines of Code**: Reduction through extraction and DRY
- **Test Coverage**: Improvement in coverage percentage
- **Type Safety**: Reduction in 'any' usage
- **Duplication**: Percentage of duplicate code eliminated
- **Bundle Size**: Reduction (e.g., removing jQuery)

## Integration with 10x-fullstack-engineer Agent

All refactoring operations leverage the **10x-fullstack-engineer** agent for:

- Expert code quality analysis
- Best practice application
- Pattern recognition and recommendation
- Consistency with project standards
- Risk assessment and mitigation
- Test-driven refactoring approach

The agent applies **SOLID principles**, **DRY**, **YAGNI**, and follows the **Boy Scout Rule** (leave code better than you found it).

## Common Issues and Solutions

### Issue: "Insufficient test coverage"

**Solution:**
```bash
# 1. Check current coverage
/refactor analyze scope:"UserService.ts" metrics:"coverage"

# 2. Add tests before refactoring
# Write tests for the code you're about to refactor

# 3. Verify coverage improved
npm test -- --coverage

# 4. Retry refactoring
/refactor extract scope:"UserService.ts" type:"method" target:"validateUser"
```

### Issue: "Uncommitted changes detected"

**Solution:**
```bash
# 1. Check git status
git status

# 2. Commit or stash changes
git add .
git commit -m "chore: prepare for refactoring"

# 3. Create refactoring branch
git checkout -b refactor/improve-user-service

# 4. Retry refactoring
/refactor extract scope:"UserService.ts" type:"method" target:"validateUser"
```

### Issue: "Too many duplicates found"

**Solution:**
```bash
# 1. Increase threshold to focus on exact duplicates
/refactor duplicate scope:"src/" threshold:"95"

# 2. Tackle highest impact duplicates first
# Extract most duplicated code blocks

# 3. Gradually lower threshold
/refactor duplicate scope:"src/" threshold:"85"

# 4. Continue until <3% duplication
/refactor duplicate scope:"src/" threshold:"80"
```

## Examples

### Complete Refactoring Session

```bash
# Session: Refactor UserService for better maintainability

# Step 1: Analyze current state
/refactor analyze scope:"src/services/UserService.ts" depth:"detailed"
# Results:
# - Complexity: 18 (CRITICAL)
# - Duplication: 6.6% (HIGH)
# - Coverage: 65% (INADEQUATE)

# Step 2: Add tests to reach >70% coverage
# (Write tests for critical paths)

# Step 3: Verify coverage improved
npm test -- --coverage
# Coverage: 78% ✓

# Step 4: Extract complex method
/refactor extract scope:"src/services/UserService.ts" type:"method" target:"validateAndCreateUser"
# Complexity: 18 → 3 (83% improvement)

# Step 5: Introduce dependency injection pattern
/refactor patterns scope:"src/services/UserService.ts" pattern:"dependency-injection"
# Testability: Greatly improved

# Step 6: Eliminate duplicate validation
/refactor duplicate scope:"src/services/" threshold:"80" strategy:"extract-function"
# Duplication: 6.6% → 1.1% (87.5% improvement)

# Step 7: Strengthen types
/refactor types scope:"src/services/UserService.ts" strategy:"eliminate-any"
# Type safety: 100% (0 'any' types remaining)

# Step 8: Final analysis
/refactor analyze scope:"src/services/UserService.ts" depth:"detailed"
# Results:
# - Complexity: 3 (EXCELLENT)
# - Duplication: 1.1% (EXCELLENT)
# - Coverage: 85% (GOOD)
# - Type Safety: 100% (EXCELLENT)

# Step 9: Run all tests
npm test
# All tests passing ✓

# Step 10: Commit refactoring
git add .
git commit -m "refactor(UserService): improve maintainability and testability

- Reduced complexity from 18 to 3
- Eliminated 87.5% of code duplication
- Improved test coverage from 65% to 85%
- Removed all 'any' types
- Introduced dependency injection pattern"
```

## Related Skills

- `/test` - Test generation and coverage improvement
- `/review` - Code review and quality checks
- `/debug` - Debugging and issue diagnosis
- `/optimize` - Performance optimization

## Further Reading

- **Refactoring (Martin Fowler)**: Definitive guide to refactoring
- **Clean Code (Robert C. Martin)**: Code quality principles
- **Design Patterns (Gang of Four)**: Pattern catalog
- **Working Effectively with Legacy Code (Michael Feathers)**: Legacy modernization
- **Refactoring UI (Adam Wathan)**: Component extraction patterns

---

**Remember**: Refactoring is not about making code perfect—it's about making code better, more maintainable, and easier to change in the future. Refactor continuously, in small steps, with confidence provided by comprehensive test coverage.
