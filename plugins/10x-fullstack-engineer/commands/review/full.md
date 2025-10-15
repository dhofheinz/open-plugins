# Comprehensive Code Review

Performs a complete, multi-category code review covering security, performance, code quality, architecture, testing, documentation, and accessibility.

## Parameters

**Received from router**: `$ARGUMENTS` (after removing 'full' operation)

Expected format: `scope:"review-scope" [depth:"quick|standard|deep"]`

## Workflow

### 1. Parse Parameters

Extract from $ARGUMENTS:
- **scope**: What to review (required)
- **depth**: Review thoroughness (default: "standard")

### 2. Gather Context

Before reviewing, understand the codebase:

**Project Structure**:
```bash
# Identify project type and structure
ls -la
cat package.json 2>/dev/null || cat requirements.txt 2>/dev/null || cat go.mod 2>/dev/null || echo "Check for other project files"

# Find configuration files
find . -maxdepth 2 -name "*.config.*" -o -name ".*rc" -o -name "*.json" | grep -E "(tsconfig|eslint|prettier|jest|vite|webpack)" | head -10

# Check testing patterns
find . -name "*.test.*" -o -name "*.spec.*" | head -5

# Review recent changes
git log --oneline -20
git status
```

**Technology Stack Detection**:
- Frontend: React/Vue/Angular/Svelte
- Backend: Node.js/Python/Go/Java
- Database: PostgreSQL/MySQL/MongoDB
- Testing: Jest/Pytest/Go test
- Build tools: Vite/Webpack/Rollup

### 3. Define Review Scope

Based on scope parameter, determine files to review:

```bash
# If scope is a directory
find [scope] -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" \) | head -20

# If scope is "recent changes"
git diff --name-only HEAD~5..HEAD

# If scope is specific files
# List the specified files
```

### 4. Security Review

**Authentication & Authorization**:
- [ ] Authentication checks on protected routes/endpoints
- [ ] Authorization checks for resource access
- [ ] JWT/session token handling secure
- [ ] No hardcoded credentials or API keys
- [ ] Password hashing with salt (bcrypt, argon2)
- [ ] Rate limiting on auth endpoints

**Input Validation & Injection Prevention**:
- [ ] All user inputs validated and sanitized
- [ ] SQL injection prevented (parameterized queries, ORM)
- [ ] XSS prevention (output encoding, CSP headers)
- [ ] CSRF protection implemented
- [ ] Command injection prevention
- [ ] Path traversal prevention
- [ ] File upload validation (type, size, content)

**Data Protection**:
- [ ] Sensitive data encrypted at rest
- [ ] TLS/HTTPS for data in transit
- [ ] No sensitive data in logs or error messages
- [ ] Secrets management (environment variables, vault)
- [ ] PII compliance (GDPR, CCPA)
- [ ] Secure session management

**Dependencies & Configuration**:
- [ ] No known vulnerable dependencies (check with npm audit, pip-audit)
- [ ] Dependencies up to date
- [ ] Security headers configured (CSP, HSTS, X-Frame-Options, X-Content-Type-Options)
- [ ] CORS properly configured
- [ ] Error messages don't leak stack traces or internals

**Common Vulnerabilities (OWASP Top 10)**:
- [ ] A01: Broken Access Control
- [ ] A02: Cryptographic Failures
- [ ] A03: Injection
- [ ] A04: Insecure Design
- [ ] A05: Security Misconfiguration
- [ ] A06: Vulnerable and Outdated Components
- [ ] A07: Identification and Authentication Failures
- [ ] A08: Software and Data Integrity Failures
- [ ] A09: Security Logging and Monitoring Failures
- [ ] A10: Server-Side Request Forgery (SSRF)

**Security Code Examples**:

```typescript
// ❌ BAD: SQL Injection vulnerability
const query = `SELECT * FROM users WHERE email = '${userEmail}'`;

// ✅ GOOD: Parameterized query
const query = 'SELECT * FROM users WHERE email = ?';
const result = await db.query(query, [userEmail]);
```

```typescript
// ❌ BAD: Hardcoded credentials
const apiKey = "sk_live_51A2B3C4D5E6F7G8";

// ✅ GOOD: Environment variables
const apiKey = process.env.STRIPE_API_KEY;
```

```typescript
// ❌ BAD: No authentication check
app.get('/api/admin/users', async (req, res) => {
  const users = await getAllUsers();
  res.json(users);
});

// ✅ GOOD: Authentication and authorization
app.get('/api/admin/users', requireAuth, requireAdmin, async (req, res) => {
  const users = await getAllUsers();
  res.json(users);
});
```

### 5. Performance Review

**Database Performance**:
- [ ] No N+1 query problems
- [ ] Proper indexes on frequently queried columns
- [ ] Connection pooling configured
- [ ] Transactions scoped appropriately
- [ ] Pagination for large datasets
- [ ] Query optimization (EXPLAIN ANALYZE)
- [ ] Caching for expensive queries

**Backend Performance**:
- [ ] Efficient algorithms (avoid O(n²) where possible)
- [ ] Async/await used properly (no blocking operations)
- [ ] Caching strategy implemented (Redis, in-memory)
- [ ] Rate limiting to prevent abuse
- [ ] Batch operations where applicable
- [ ] Stream processing for large data
- [ ] Background jobs for heavy tasks

**Frontend Performance**:
- [ ] Components memoized appropriately (React.memo, useMemo, useCallback)
- [ ] Large lists virtualized (react-window, react-virtualized)
- [ ] Images optimized and lazy-loaded
- [ ] Code splitting implemented
- [ ] Bundle size optimized (tree shaking, minification)
- [ ] Unnecessary re-renders prevented
- [ ] Debouncing/throttling for expensive operations
- [ ] Web Vitals considerations (LCP, FID, CLS)

**Network Performance**:
- [ ] API calls minimized (batching, GraphQL)
- [ ] Response compression enabled (gzip, brotli)
- [ ] CDN for static assets
- [ ] HTTP caching headers configured
- [ ] Prefetching/preloading for critical resources
- [ ] Service worker for offline support

**Performance Code Examples**:

```typescript
// ❌ BAD: N+1 query problem
const users = await User.findAll();
for (const user of users) {
  user.posts = await Post.findAll({ where: { userId: user.id } });
}

// ✅ GOOD: Eager loading
const users = await User.findAll({
  include: [{ model: Post }]
});
```

```typescript
// ❌ BAD: Unnecessary re-renders
function UserList({ users }) {
  return users.map(user => <UserCard key={user.id} user={user} />);
}

// ✅ GOOD: Memoization
const UserCard = React.memo(({ user }) => (
  <div>{user.name}</div>
));

function UserList({ users }) {
  return users.map(user => <UserCard key={user.id} user={user} />);
}
```

### 6. Code Quality Review

**Code Organization**:
- [ ] Clear, descriptive naming (variables, functions, classes)
- [ ] Functions focused and under 50 lines
- [ ] Single Responsibility Principle followed
- [ ] DRY principle applied (no code duplication)
- [ ] Proper separation of concerns
- [ ] Consistent code style
- [ ] Logical file structure

**Error Handling**:
- [ ] All errors caught and handled properly
- [ ] Meaningful error messages
- [ ] Proper error logging
- [ ] Errors don't expose sensitive information
- [ ] Graceful degradation
- [ ] User-friendly error messages in UI
- [ ] Error boundaries (React) or equivalent

**Type Safety** (TypeScript/typed languages):
- [ ] No `any` types (or justified exceptions)
- [ ] Proper type definitions for functions
- [ ] Interfaces/types for complex objects
- [ ] Type guards for runtime validation
- [ ] Generics used appropriately
- [ ] Strict mode enabled

**Testing**:
- [ ] Unit tests for business logic
- [ ] Integration tests for APIs
- [ ] Component tests for UI
- [ ] E2E tests for critical paths
- [ ] Tests are meaningful (not just for coverage)
- [ ] Edge cases covered
- [ ] Mocks/stubs used appropriately
- [ ] Test coverage >80% for critical code

**Documentation**:
- [ ] Complex logic explained with comments
- [ ] JSDoc/docstrings for public APIs
- [ ] README accurate and up to date
- [ ] API documentation complete
- [ ] Architectural decisions documented (ADRs)
- [ ] Setup instructions clear

**Quality Code Examples**:

```typescript
// ❌ BAD: Poor naming and structure
function p(u, d) {
  if (u.r === 'a') {
    return d.filter(x => x.o === u.i);
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
// ❌ BAD: No error handling
async function fetchUser(id: string) {
  const response = await fetch(`/api/users/${id}`);
  const user = await response.json();
  return user;
}

// ✅ GOOD: Proper error handling
async function fetchUser(id: string): Promise<User> {
  try {
    const response = await fetch(`/api/users/${id}`);

    if (!response.ok) {
      throw new Error(`Failed to fetch user: ${response.statusText}`);
    }

    const user = await response.json();
    return user;
  } catch (error) {
    logger.error('Error fetching user', { id, error });
    throw new UserFetchError(`Unable to retrieve user ${id}`, { cause: error });
  }
}
```

### 7. Architecture Review

**Design Patterns**:
- [ ] Appropriate patterns used (Factory, Strategy, Observer, etc.)
- [ ] No anti-patterns (God Object, Spaghetti Code, etc.)
- [ ] Consistent with existing architecture
- [ ] SOLID principles followed
- [ ] Dependency injection where appropriate

**Scalability**:
- [ ] Design scales with increased load
- [ ] No bottlenecks introduced
- [ ] Stateless design where appropriate
- [ ] Horizontal scaling possible
- [ ] Resource usage reasonable
- [ ] Caching strategy for scale

**Maintainability**:
- [ ] Code is readable and understandable
- [ ] Low coupling, high cohesion
- [ ] Easy to test
- [ ] Easy to extend
- [ ] No technical debt introduced
- [ ] Consistent patterns across codebase

**Architecture Code Examples**:

```typescript
// ❌ BAD: Tight coupling
class OrderService {
  processPayment(order: Order) {
    const stripe = new StripeClient(process.env.STRIPE_KEY);
    return stripe.charge(order.amount);
  }
}

// ✅ GOOD: Dependency injection
interface PaymentGateway {
  charge(amount: number): Promise<PaymentResult>;
}

class OrderService {
  constructor(private paymentGateway: PaymentGateway) {}

  processPayment(order: Order) {
    return this.paymentGateway.charge(order.amount);
  }
}
```

### 8. Frontend-Specific Review

**Accessibility (a11y)**:
- [ ] Semantic HTML elements used
- [ ] ARIA labels and roles where needed
- [ ] Keyboard navigation functional
- [ ] Screen reader compatible
- [ ] Color contrast meets WCAG AA standards
- [ ] Focus management proper
- [ ] Alt text for images
- [ ] Form labels associated with inputs

**User Experience**:
- [ ] Loading states shown
- [ ] Error states handled gracefully
- [ ] Forms have validation feedback
- [ ] Responsive design implemented
- [ ] Optimistic updates where appropriate
- [ ] Smooth animations and transitions
- [ ] Empty states handled

**Browser Compatibility**:
- [ ] Polyfills for required features
- [ ] Tested in target browsers
- [ ] Graceful degradation
- [ ] Progressive enhancement

### 9. Testing Review

**Coverage Analysis**:
```bash
# Check test coverage
npm test -- --coverage || pytest --cov || go test -cover ./...
```

**Test Quality**:
- [ ] Tests are readable and maintainable
- [ ] Tests are isolated and independent
- [ ] Tests use meaningful assertions
- [ ] Tests cover happy path and edge cases
- [ ] Tests avoid implementation details
- [ ] Integration tests cover API contracts
- [ ] E2E tests cover critical user flows

### 10. Documentation Review

**Code Documentation**:
- [ ] Complex algorithms explained
- [ ] Public APIs documented
- [ ] Inline comments for unclear code
- [ ] Type annotations present

**Project Documentation**:
- [ ] README comprehensive
- [ ] Setup instructions work
- [ ] API documentation accurate
- [ ] Architecture diagrams present
- [ ] Contributing guidelines clear

## Review Depth Implementation

**Quick Depth** (5-10 min):
- Focus only on security critical issues and obvious bugs
- Skip detailed architecture review
- High-level scan of each category
- Prioritize critical and high priority findings

**Standard Depth** (20-30 min):
- Review all categories with moderate detail
- Check security, performance, and quality thoroughly
- Review test coverage
- Provide actionable recommendations

**Deep Depth** (45-60+ min):
- Comprehensive analysis of all categories
- Detailed architecture and design review
- Complete security audit
- Performance profiling recommendations
- Test quality assessment
- Documentation completeness check

## Output Format

Provide structured feedback:

```markdown
# Comprehensive Code Review: [Scope]

## Executive Summary

**Reviewed**: [What was reviewed]
**Depth**: [Quick|Standard|Deep]
**Date**: [Current date]

### Overall Assessment
- **Quality**: [Excellent|Good|Fair|Needs Improvement]
- **Security**: [Secure|Minor Issues|Major Concerns]
- **Performance**: [Optimized|Acceptable|Needs Optimization]
- **Maintainability**: [High|Medium|Low]
- **Test Coverage**: [%]

### Recommendation
**[Approve|Approve with Comments|Request Changes]**

[Brief explanation of recommendation]

---

## Critical Issues (Must Fix) 🚨

### [Issue 1 Title]
**File**: `path/to/file.ts:42`
**Category**: Security|Performance|Quality
**Issue**: [Clear description of the problem]
**Risk**: [Why this is critical - impact on security, data, users]
**Fix**: [Specific, actionable recommendation]

```typescript
// Current code (problematic)
[show problematic code]

// Suggested fix
[show corrected code with explanation]
```

[Repeat for each critical issue]

---

## High Priority Issues (Should Fix) ⚠️

### [Issue 1 Title]
**File**: `path/to/file.ts:103`
**Category**: Security|Performance|Quality
**Issue**: [Description]
**Impact**: [Why this should be fixed]
**Suggestion**: [Recommendation]

[Code example if applicable]

[Repeat for each high priority issue]

---

## Medium Priority Issues (Consider Fixing) ℹ️

### [Issue 1 Title]
**File**: `path/to/file.ts:205`
**Category**: Security|Performance|Quality
**Issue**: [Description]
**Suggestion**: [Recommendation]

[Repeat for each medium priority issue]

---

## Low Priority Issues (Nice to Have) 💡

### [Issue 1 Title]
**File**: `path/to/file.ts:308`
**Suggestion**: [Recommendation for improvement]

[Repeat for each low priority issue]

---

## Positive Observations ✅

Things done well that should be maintained:

- ✅ [Good practice 1 with specific example]
- ✅ [Good practice 2 with specific example]
- ✅ [Good practice 3 with specific example]

---

## Detailed Review by Category

### 🔒 Security Review

**Summary**: [Overall security posture]

**Strengths**:
- ✅ [What's done well]
- ✅ [What's done well]

**Concerns**:
- ⚠️ [What needs attention with file references]
- ⚠️ [What needs attention with file references]

**OWASP Top 10 Assessment**:
- A01 Broken Access Control: [Pass|Fail] - [Details]
- A03 Injection: [Pass|Fail] - [Details]
- [Other relevant items]

### ⚡ Performance Review

**Summary**: [Overall performance assessment]

**Strengths**:
- ✅ [Optimizations already in place]

**Concerns**:
- ⚠️ [Performance issues with specific file references]
- ⚠️ [Bottlenecks identified]

**Recommendations**:
1. [Specific performance improvement]
2. [Specific performance improvement]

### 📝 Code Quality Review

**Summary**: [Overall code quality]

**Strengths**:
- ✅ [Quality aspects done well]

**Areas for Improvement**:
- ⚠️ [Quality issues with file references]

**Code Metrics**:
- Average function length: [X lines]
- Code duplication: [Low|Medium|High]
- Cyclomatic complexity: [Assessment]

### 🧪 Testing Review

**Summary**: [Test coverage and quality]

**Coverage**: [X%]

**Strengths**:
- ✅ [Well-tested areas]

**Gaps**:
- ⚠️ [Missing test coverage]
- ⚠️ [Test quality issues]

### 📚 Documentation Review

**Summary**: [Documentation completeness]

**Strengths**:
- ✅ [Well-documented areas]

**Gaps**:
- ⚠️ [Missing or incomplete documentation]

### 🏗️ Architecture Review

**Summary**: [Architectural assessment]

**Patterns Observed**:
- [Design pattern 1]
- [Design pattern 2]

**Strengths**:
- ✅ [Good architectural decisions]

**Concerns**:
- ⚠️ [Architectural issues]

**Scalability Assessment**: [Can this scale?]

---

## Recommendations for Improvement

### Immediate Actions (This Week)
1. [Critical fix 1]
2. [Critical fix 2]

### Short-term Improvements (This Month)
1. [High priority improvement 1]
2. [High priority improvement 2]

### Long-term Enhancements (This Quarter)
1. [Strategic improvement 1]
2. [Strategic improvement 2]

---

## Questions for Team

1. [Question about design decision or requirement]
2. [Question about trade-offs]
3. [Question about future plans]

---

## Next Steps

- [ ] Address all critical issues
- [ ] Fix high priority issues
- [ ] Review and discuss medium priority suggestions
- [ ] Update tests to cover identified gaps
- [ ] Update documentation as needed
- [ ] Schedule follow-up review after fixes

---

## Review Metadata

- **Reviewer**: 10x Fullstack Engineer Agent
- **Review Date**: [Date]
- **Review Depth**: [Quick|Standard|Deep]
- **Time Spent**: [Estimated time]
- **Files Reviewed**: [Count]
- **Issues Found**: Critical: X, High: X, Medium: X, Low: X
```

## Agent Invocation

This operation MUST leverage the **10x-fullstack-engineer** agent for comprehensive review expertise.

## Best Practices

1. **Be Specific**: Always include file paths and line numbers
2. **Be Constructive**: Frame feedback positively with clear improvements
3. **Explain Why**: Help understand the reasoning behind each recommendation
4. **Provide Examples**: Show both problematic and corrected code
5. **Acknowledge Good Work**: Recognize strengths and good practices
6. **Prioritize**: Focus on impact - security and data integrity first
7. **Be Actionable**: Every issue should have a clear next step
8. **Ask Questions**: When design intent is unclear, ask rather than assume

## Error Handling

**Scope Too Large**:
- Suggest breaking into smaller focused reviews
- Provide high-level assessment with sampling
- Recommend incremental review approach

**Missing Context**:
- Request additional information about requirements
- Ask about design decisions
- Clarify technical constraints

**Insufficient Depth Time**:
- Recommend appropriate depth level for scope
- Suggest focusing on specific categories
- Provide sampling approach for large codebases
