# Code Quality Review

Performs comprehensive code quality analysis focusing on organization, maintainability, testing, documentation, and software craftsmanship best practices.

## Parameters

**Received from router**: `$ARGUMENTS` (after removing 'quality' operation)

Expected format: `scope:"review-scope" [depth:"quick|standard|deep"]`

## Workflow

### 1. Parse Parameters

Extract from $ARGUMENTS:
- **scope**: What to review (required) - files, modules, features
- **depth**: Quality analysis thoroughness (default: "standard")

### 2. Gather Context

**Understand Code Structure**:
```bash
# Check project structure
ls -la
cat package.json 2>/dev/null || cat requirements.txt 2>/dev/null

# Find test files
find . -name "*.test.*" -o -name "*.spec.*" -o -name "*_test.*" | head -20

# Check for linting configuration
ls -la | grep -E "eslint|prettier|pylint|flake8|golangci"

# Analyze code metrics (if tools available)
npx cloc . --exclude-dir=node_modules,dist,build 2>/dev/null || echo "Code analysis"

# Check for documentation
find . -name "README*" -o -name "*.md" | head -10
```

### 3. Code Organization Review

**Naming Conventions**:
- [ ] Variables have clear, descriptive names
- [ ] Functions/methods have verb-based names
- [ ] Classes have noun-based names
- [ ] Constants are UPPER_SNAKE_CASE
- [ ] Boolean variables use is/has/should prefix
- [ ] Names reveal intent (no cryptic abbreviations)

**Function Structure**:
- [ ] Functions focused on single responsibility
- [ ] Functions under 50 lines (ideally under 30)
- [ ] Function parameters limited (ideally 3 or fewer)
- [ ] Deep nesting avoided (max 3 levels)
- [ ] Early returns for guard clauses
- [ ] Pure functions where possible

**File Organization**:
- [ ] Related code grouped together
- [ ] Clear separation of concerns
- [ ] Logical folder structure
- [ ] Consistent file naming
- [ ] Import statements organized
- [ ] File length manageable (under 300 lines)

**Code Duplication**:
- [ ] DRY principle followed
- [ ] Repeated patterns extracted to functions
- [ ] Common utilities in shared modules
- [ ] Magic numbers replaced with named constants
- [ ] Similar code refactored to reusable components

**Code Examples - Organization**:

```typescript
// ❌ BAD: Poor naming and structure
function p(u, d) {
  if (u.r === 'a') {
    let result = [];
    for (let i = 0; i < d.length; i++) {
      if (d[i].o === u.i) {
        result.push(d[i]);
      }
    }
    return result;
  }
  return d;
}

// ✅ GOOD: Clear naming and structure
function filterDataByUserRole(user: User, data: DataItem[]): DataItem[] {
  if (user.role === 'admin') {
    return data.filter(item => item.ownerId === user.id);
  }
  return data;
}
```

```typescript
// ❌ BAD: Long function with multiple responsibilities
function processOrder(order) {
  // Validate order (20 lines)
  // Calculate totals (15 lines)
  // Apply discounts (25 lines)
  // Process payment (30 lines)
  // Send notifications (20 lines)
  // Update inventory (15 lines)
  // Log analytics (10 lines)
  // 135 lines total!
}

// ✅ GOOD: Decomposed into focused functions
function processOrder(order: Order): OrderResult {
  validateOrder(order);
  const totals = calculateOrderTotals(order);
  const finalPrice = applyDiscounts(totals, order.discountCode);
  const payment = processPayment(finalPrice, order.paymentMethod);
  sendOrderNotifications(order, payment);
  updateInventory(order.items);
  logOrderAnalytics(order, payment);

  return { order, payment, totals };
}
```

```typescript
// ❌ BAD: Code duplication
function formatUserName(user) {
  return user.firstName + ' ' + user.lastName;
}

function formatAuthorName(author) {
  return author.firstName + ' ' + author.lastName;
}

function formatCustomerName(customer) {
  return customer.firstName + ' ' + customer.lastName;
}

// ✅ GOOD: Extracted common logic
interface Person {
  firstName: string;
  lastName: string;
}

function formatFullName(person: Person): string {
  return `${person.firstName} ${person.lastName}`;
}

// Use for all person types
const userName = formatFullName(user);
const authorName = formatFullName(author);
const customerName = formatFullName(customer);
```

### 4. Error Handling Review

**Error Handling Patterns**:
- [ ] All errors caught and handled
- [ ] Error messages are meaningful
- [ ] Errors logged with context
- [ ] Errors don't expose sensitive data
- [ ] Graceful degradation implemented
- [ ] User-friendly error messages in UI
- [ ] Error boundaries in React (or equivalent)

**Validation**:
- [ ] Input validation at boundaries
- [ ] Type checking for dynamic data
- [ ] Null/undefined checks where needed
- [ ] Range and boundary checks
- [ ] Business rule validation
- [ ] Validation errors clearly communicated

**Code Examples - Error Handling**:

```typescript
// ❌ BAD: Silent failure
async function fetchUser(id: string) {
  try {
    const response = await fetch(`/api/users/${id}`);
    return await response.json();
  } catch (error) {
    return null; // Silent failure!
  }
}

// ✅ GOOD: Proper error handling
async function fetchUser(id: string): Promise<User> {
  try {
    const response = await fetch(`/api/users/${id}`);

    if (!response.ok) {
      throw new Error(`Failed to fetch user: ${response.statusText}`);
    }

    return await response.json();
  } catch (error) {
    logger.error('Error fetching user', { id, error });
    throw new UserFetchError(`Unable to retrieve user ${id}`, { cause: error });
  }
}
```

```typescript
// ❌ BAD: No validation
function calculateDiscount(price, discountPercent) {
  return price * (discountPercent / 100);
}

// ✅ GOOD: Input validation
function calculateDiscount(price: number, discountPercent: number): number {
  if (price < 0) {
    throw new Error('Price cannot be negative');
  }

  if (discountPercent < 0 || discountPercent > 100) {
    throw new Error('Discount must be between 0 and 100');
  }

  return price * (discountPercent / 100);
}
```

### 5. Type Safety Review (TypeScript/Typed Languages)

**Type Usage**:
- [ ] No `any` types (or justified with comments)
- [ ] Explicit return types on functions
- [ ] Interface/type definitions for objects
- [ ] Enums for fixed sets of values
- [ ] Union types for multiple possibilities
- [ ] Type guards for runtime validation
- [ ] Generics used appropriately

**Type Quality**:
- [ ] Types are precise (not overly broad)
- [ ] Types are DRY (shared interfaces)
- [ ] Complex types have descriptive names
- [ ] Type assertions justified and minimal
- [ ] Non-null assertions avoided

**Code Examples - Type Safety**:

```typescript
// ❌ BAD: Using any
function processData(data: any) {
  return data.map((item: any) => item.value);
}

// ✅ GOOD: Proper types
interface DataItem {
  id: string;
  value: number;
  metadata?: Record<string, unknown>;
}

function processData(data: DataItem[]): number[] {
  return data.map(item => item.value);
}
```

```typescript
// ❌ BAD: Overly broad type
function getConfig(): object {
  return { apiUrl: 'https://api.example.com', timeout: 5000 };
}

// ✅ GOOD: Specific type
interface AppConfig {
  apiUrl: string;
  timeout: number;
  retries?: number;
}

function getConfig(): AppConfig {
  return { apiUrl: 'https://api.example.com', timeout: 5000 };
}
```

### 6. Testing Review

**Test Coverage**:
- [ ] Unit tests for business logic
- [ ] Integration tests for APIs
- [ ] Component tests for UI
- [ ] E2E tests for critical paths
- [ ] Coverage >80% for critical code
- [ ] Edge cases tested
- [ ] Error paths tested

**Test Quality**:
- [ ] Tests are readable and maintainable
- [ ] Tests are isolated (no interdependencies)
- [ ] Tests use meaningful assertions
- [ ] Tests focus on behavior, not implementation
- [ ] Test names describe what they test
- [ ] Mocks/stubs used appropriately
- [ ] Test data is clear and minimal

**Test Organization**:
- [ ] Tests colocated with source (or parallel structure)
- [ ] Test setup/teardown handled properly
- [ ] Shared test utilities extracted
- [ ] Test factories for complex objects
- [ ] Consistent test patterns across codebase

**Code Examples - Testing**:

```typescript
// ❌ BAD: Testing implementation details
it('should update state', () => {
  const component = mount(<Counter />);
  component.instance().incrementCount(); // Implementation detail!
  expect(component.state('count')).toBe(1);
});

// ✅ GOOD: Testing behavior
it('should increment counter when button is clicked', () => {
  render(<Counter />);
  const button = screen.getByRole('button', { name: /increment/i });

  fireEvent.click(button);

  expect(screen.getByText('Count: 1')).toBeInTheDocument();
});
```

```typescript
// ❌ BAD: Unclear test name and setup
it('works', async () => {
  const result = await func(123, true, 'test', null, undefined);
  expect(result).toBe(true);
});

// ✅ GOOD: Descriptive name and clear test
it('should return true when user is authenticated and has admin role', async () => {
  const user = createTestUser({ role: 'admin', isAuthenticated: true });

  const result = await canAccessAdminPanel(user);

  expect(result).toBe(true);
});
```

### 7. Documentation Review

**Code Documentation**:
- [ ] Complex logic explained with comments
- [ ] JSDoc/docstrings for public APIs
- [ ] "Why" comments, not "what" comments
- [ ] TODO/FIXME comments tracked
- [ ] Outdated comments removed
- [ ] Type definitions documented

**Project Documentation**:
- [ ] README comprehensive and up to date
- [ ] Setup instructions accurate
- [ ] API documentation complete
- [ ] Architecture documented (ADRs)
- [ ] Contributing guidelines present
- [ ] Changelog maintained

**Code Examples - Documentation**:

```typescript
// ❌ BAD: Obvious comment
// Increment the counter
count++;

// ❌ BAD: Outdated comment
// TODO: Add validation (already done!)
function saveUser(user: User) {
  validateUser(user);
  return db.users.save(user);
}

// ✅ GOOD: Explains why
// Using exponential backoff to handle rate limiting from external API
await retryWithBackoff(() => externalApi.call());

// ✅ GOOD: JSDoc for public API
/**
 * Calculates the total price including discounts and taxes.
 *
 * @param items - Array of cart items
 * @param discountCode - Optional discount code to apply
 * @returns Total price with applied discounts and taxes
 * @throws {InvalidDiscountError} If discount code is invalid
 *
 * @example
 * ```ts
 * const total = calculateTotal(cartItems, 'SAVE10');
 * ```
 */
function calculateTotal(items: CartItem[], discountCode?: string): number {
  // Implementation
}
```

### 8. SOLID Principles Review

**Single Responsibility Principle**:
- [ ] Each class/function has one reason to change
- [ ] Responsibilities clearly defined
- [ ] Cohesion is high

**Open/Closed Principle**:
- [ ] Open for extension, closed for modification
- [ ] New features don't require changing existing code
- [ ] Abstractions used appropriately

**Liskov Substitution Principle**:
- [ ] Subtypes can replace base types
- [ ] Inheritance used correctly
- [ ] No broken hierarchies

**Interface Segregation Principle**:
- [ ] Interfaces are focused
- [ ] Clients don't depend on unused methods
- [ ] Small, cohesive interfaces

**Dependency Inversion Principle**:
- [ ] Depend on abstractions, not concretions
- [ ] Dependency injection used
- [ ] High-level modules independent of low-level

**Code Examples - SOLID**:

```typescript
// ❌ BAD: Violates Single Responsibility
class User {
  saveToDatabase() { /* ... */ }
  sendEmail() { /* ... */ }
  generateReport() { /* ... */ }
  validateData() { /* ... */ }
}

// ✅ GOOD: Single Responsibility
class User {
  constructor(public name: string, public email: string) {}
}

class UserRepository {
  save(user: User) { /* ... */ }
}

class EmailService {
  sendWelcomeEmail(user: User) { /* ... */ }
}
```

```typescript
// ❌ BAD: Violates Dependency Inversion
class OrderService {
  processOrder(order: Order) {
    const stripe = new StripePayment(); // Tight coupling!
    stripe.charge(order.amount);
  }
}

// ✅ GOOD: Dependency Inversion
interface PaymentGateway {
  charge(amount: number): Promise<PaymentResult>;
}

class OrderService {
  constructor(private paymentGateway: PaymentGateway) {}

  processOrder(order: Order) {
    return this.paymentGateway.charge(order.amount);
  }
}

// Can now use any payment gateway
const orderService = new OrderService(new StripePayment());
// or
const orderService = new OrderService(new PayPalPayment());
```

### 9. Design Patterns Review

**Appropriate Patterns**:
- [ ] Patterns used where beneficial
- [ ] Patterns not overused
- [ ] Patterns implemented correctly
- [ ] Patterns consistent with codebase

**Common Patterns to Look For**:
- Factory Pattern: Object creation
- Strategy Pattern: Algorithm selection
- Observer Pattern: Event handling
- Decorator Pattern: Adding functionality
- Singleton Pattern: Single instance (use sparingly)
- Repository Pattern: Data access
- Dependency Injection: Loose coupling

**Anti-Patterns to Avoid**:
- [ ] God Object (class doing too much)
- [ ] Spaghetti Code (tangled logic)
- [ ] Copy-Paste Programming
- [ ] Golden Hammer (overusing one solution)
- [ ] Premature Optimization
- [ ] Magic Numbers/Strings

### 10. Code Metrics Analysis

**Complexity Metrics**:
```bash
# Cyclomatic complexity (if tools available)
npx eslint . --ext .ts,.tsx --format json | grep complexity

# Lines of code per file
find . -name "*.ts" -exec wc -l {} \; | sort -rn | head -10

# Function length analysis
# (Manual review of longest functions)
```

**Quality Indicators**:
- [ ] Low cyclomatic complexity (< 10)
- [ ] Limited function parameters (< 4)
- [ ] Reasonable file length (< 300 lines)
- [ ] Low code duplication
- [ ] High cohesion, low coupling

## Review Depth Implementation

**Quick Depth** (10-15 min):
- Focus on obvious quality issues
- Check function length and complexity
- Review naming conventions
- Check for code duplication
- Verify basic error handling

**Standard Depth** (30-40 min):
- All quality categories reviewed
- Test coverage analysis
- Documentation review
- SOLID principles check
- Design pattern review
- Code organization assessment

**Deep Depth** (60-90+ min):
- Comprehensive quality audit
- Detailed metrics analysis
- Complete test quality review
- Architecture pattern review
- Refactoring recommendations
- Technical debt assessment
- Maintainability scoring

## Output Format

```markdown
# Code Quality Review: [Scope]

## Executive Summary

**Reviewed**: [What was reviewed]
**Depth**: [Quick|Standard|Deep]
**Quality Rating**: [Excellent|Good|Fair|Needs Improvement]

### Overall Quality Assessment
**[High|Medium|Low] Maintainability**

[Brief explanation]

### Code Metrics
- **Total Lines**: [X]
- **Average Function Length**: [X lines]
- **Cyclomatic Complexity**: [Average: X]
- **Test Coverage**: [X%]
- **Code Duplication**: [Low|Medium|High]

### Priority Actions
1. [Critical quality issue 1]
2. [Critical quality issue 2]

---

## Critical Quality Issues 🚨

### [Issue 1 Title]
**File**: `path/to/file.ts:42`
**Category**: Organization|Error Handling|Type Safety|Testing|Documentation
**Issue**: [Description of quality problem]
**Impact**: [Why this matters for maintainability]
**Refactoring**: [Specific improvement]

```typescript
// Current code
[problematic code]

// Refactored code
[improved code]
```

[Repeat for each critical issue]

---

## High Priority Issues ⚠️

[Similar format for high priority issues]

---

## Medium Priority Issues ℹ️

[Similar format for medium priority issues]

---

## Low Priority Issues 💡

[Similar format for low priority issues]

---

## Quality Strengths ✅

- ✅ [Good practice 1 with examples]
- ✅ [Good practice 2 with examples]
- ✅ [Good practice 3 with examples]

---

## Detailed Quality Analysis

### 📂 Code Organization

**Structure**: [Assessment]

**Strengths**:
- ✅ [Well-organized aspects]

**Improvements Needed**:
- ⚠️ [Organization issues with file references]

**Naming Quality**: [Excellent|Good|Needs Improvement]
**Function Size**: Average [X] lines (Target: <30)
**File Size**: Average [X] lines (Target: <300)

### 🛡️ Error Handling

**Coverage**: [Comprehensive|Partial|Insufficient]

**Strengths**:
- ✅ [Good error handling practices]

**Improvements Needed**:
- ⚠️ [Missing or poor error handling with file references]

### 🔷 Type Safety (TypeScript)

**Type Coverage**: [X%]
**Any Types Found**: [Count and locations]

**Strengths**:
- ✅ [Good type usage]

**Improvements Needed**:
- ⚠️ [Type safety issues with file references]

### 🧪 Testing

**Test Coverage**: [X%]

**Coverage by Type**:
- Unit Tests: [X%]
- Integration Tests: [X%]
- E2E Tests: [X%]

**Test Quality**: [High|Medium|Low]

**Strengths**:
- ✅ [Well-tested areas]

**Gaps**:
- ⚠️ [Missing test coverage]
- ⚠️ [Test quality issues]

**Untested Code**:
- [File/function 1 - why important]
- [File/function 2 - why important]

### 📚 Documentation

**Documentation Level**: [Comprehensive|Adequate|Insufficient]

**Strengths**:
- ✅ [Well-documented areas]

**Gaps**:
- ⚠️ [Missing or inadequate documentation]

**README Quality**: [Excellent|Good|Needs Work]
**API Documentation**: [Complete|Partial|Missing]
**Code Comments**: [Appropriate|Excessive|Insufficient]

### 🏗️ SOLID Principles

| Principle | Adherence | Issues |
|-----------|-----------|--------|
| Single Responsibility | ✅ Good / ⚠️ Some Issues / ❌ Violated | [Details] |
| Open/Closed | ✅ Good / ⚠️ Some Issues / ❌ Violated | [Details] |
| Liskov Substitution | ✅ Good / ⚠️ Some Issues / ❌ Violated | [Details] |
| Interface Segregation | ✅ Good / ⚠️ Some Issues / ❌ Violated | [Details] |
| Dependency Inversion | ✅ Good / ⚠️ Some Issues / ❌ Violated | [Details] |

### 🎨 Design Patterns

**Patterns Identified**:
- [Pattern 1]: [Where used, appropriateness]
- [Pattern 2]: [Where used, appropriateness]

**Anti-Patterns Found**:
- ⚠️ [Anti-pattern 1 with location]
- ⚠️ [Anti-pattern 2 with location]

### 📊 Code Metrics

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Avg Function Length | [X] lines | <30 | ✅ / ⚠️ / ❌ |
| Max Function Length | [X] lines | <50 | ✅ / ⚠️ / ❌ |
| Avg Cyclomatic Complexity | [X] | <10 | ✅ / ⚠️ / ❌ |
| Max Cyclomatic Complexity | [X] | <15 | ✅ / ⚠️ / ❌ |
| Test Coverage | [X%] | >80% | ✅ / ⚠️ / ❌ |
| Code Duplication | [Low/Med/High] | Low | ✅ / ⚠️ / ❌ |

---

## Refactoring Recommendations

### Immediate (This Week)
1. [Refactoring 1 - estimated effort, impact]
2. [Refactoring 2 - estimated effort, impact]

### Short-term (This Month)
1. [Refactoring 1 - estimated effort, impact]
2. [Refactoring 2 - estimated effort, impact]

### Long-term (This Quarter)
1. [Strategic improvement 1]
2. [Strategic improvement 2]

---

## Technical Debt Assessment

**Debt Level**: [Low|Medium|High]

**Key Debt Items**:
1. [Debt item 1 - why it exists, impact, remediation]
2. [Debt item 2 - why it exists, impact, remediation]

**Debt Payoff Strategy**: [Recommendation]

---

## Maintainability Score

**Overall Score**: [X/10]

**Component Scores**:
- Organization: [X/10]
- Error Handling: [X/10]
- Type Safety: [X/10]
- Testing: [X/10]
- Documentation: [X/10]
- Design: [X/10]

---

## Best Practices Compliance

**Followed**:
- ✅ [Practice 1]
- ✅ [Practice 2]

**Not Followed**:
- ❌ [Practice 1 with remediation]
- ❌ [Practice 2 with remediation]

---

## Review Metadata

- **Reviewer**: 10x Fullstack Engineer (Quality Focus)
- **Review Date**: [Date]
- **Quality Issues**: Critical: X, High: X, Medium: X, Low: X
- **Maintainability**: [High|Medium|Low]
```

## Agent Invocation

This operation MUST leverage the **10x-fullstack-engineer** agent with code quality expertise.

## Best Practices

1. **Readability First**: Code is read more than written
2. **Consistency**: Follow established patterns
3. **Simplicity**: Simple code is maintainable code
4. **Test Coverage**: Tests document and protect behavior
5. **Meaningful Names**: Names should reveal intent
6. **Small Functions**: Functions should do one thing well
