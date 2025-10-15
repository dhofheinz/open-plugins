# Pull Request Review

Performs comprehensive pull request review with git integration, analyzing changes, assessing impact, and providing structured feedback for code review collaboration.

## Parameters

**Received from router**: `$ARGUMENTS` (after removing 'pr' operation)

Expected format: `scope:"PR #123" [depth:"quick|standard|deep"]`

## Workflow

### 1. Parse Parameters

Extract from $ARGUMENTS:
- **scope**: PR number or description (required) - "PR #123", "pull request 456", "current branch"
- **depth**: Review thoroughness (default: "standard")

### 2. Gather PR Context

**Extract PR Information**:
```bash
# Get PR details if PR number provided
# Example: scope:"PR #123" → extract "123"
PR_NUMBER=$(echo "$SCOPE" | grep -oP '#?\K\d+' || echo "")

if [ -n "$PR_NUMBER" ]; then
  # Get PR info via GitHub CLI
  gh pr view $PR_NUMBER --json title,body,author,labels,assignees,reviewDecision

  # Get PR changes
  gh pr diff $PR_NUMBER
else
  # Review current branch changes
  git diff $(git merge-base HEAD main)..HEAD
fi

# Get commit history
git log main..HEAD --oneline

# Get changed files
git diff --name-only $(git merge-base HEAD main)..HEAD

# Get file change stats
git diff --stat $(git merge-base HEAD main)..HEAD
```

### 3. Analyze Change Context

**Understand the Changes**:
```bash
# Categorize changed files
git diff --name-only $(git merge-base HEAD main)..HEAD | grep -E '\.(ts|tsx|js|jsx)$' | head -20

# Check for new files
git diff --name-status $(git merge-base HEAD main)..HEAD | grep "^A"

# Check for deleted files
git diff --name-status $(git merge-base HEAD main)..HEAD | grep "^D"

# Check for renamed/moved files
git diff --name-status $(git merge-base HEAD main)..HEAD | grep "^R"

# Look for test changes
git diff --name-only $(git merge-base HEAD main)..HEAD | grep -E '\.(test|spec)\.'

# Check for documentation changes
git diff --name-only $(git merge-base HEAD main)..HEAD | grep -E '\.(md|txt)$'
```

### 4. PR-Specific Review Checklist

**PR Metadata Review**:
- [ ] PR title is clear and descriptive
- [ ] PR description explains what and why
- [ ] PR size is manageable (< 400 lines changed)
- [ ] PR has appropriate labels
- [ ] PR is linked to issue/ticket
- [ ] PR has reviewers assigned
- [ ] PR targets correct branch

**Change Scope Assessment**:
- [ ] Changes align with PR description
- [ ] No unrelated changes included
- [ ] Scope creep avoided
- [ ] Breaking changes clearly documented
- [ ] Migration path provided for breaking changes

**Commit Quality**:
- [ ] Commit messages are meaningful
- [ ] Commits are logically organized
- [ ] No "fix typo" or "wip" commits in history
- [ ] Commits could be atomic (optional: suggest squash)
- [ ] No merge commits (if using rebase workflow)

**Branch Strategy**:
- [ ] Branch name follows conventions
- [ ] Branch is up to date with base branch
- [ ] No conflicts with base branch
- [ ] Branch focused on single feature/fix

### 5. Impact Analysis

**Risk Assessment**:
```bash
# Check if changes affect critical files
git diff --name-only $(git merge-base HEAD main)..HEAD | grep -E '(auth|payment|security|config)'

# Check for database changes
git diff $(git merge-base HEAD main)..HEAD | grep -E '(migration|schema|ALTER|CREATE TABLE)'

# Check for dependency changes
git diff $(git merge-base HEAD main)..HEAD -- package.json requirements.txt go.mod

# Check for configuration changes
git diff $(git merge-base HEAD main)..HEAD -- '*.config.*' '.env.example'
```

**Impact Categories**:
- [ ] **Critical**: Auth, payment, data integrity, security
- [ ] **High**: Core business logic, public APIs, database schema
- [ ] **Medium**: Feature additions, UI changes, internal APIs
- [ ] **Low**: Documentation, tests, minor refactors

**Backward Compatibility**:
- [ ] API changes are backward compatible
- [ ] Database migrations are reversible
- [ ] Feature flags used for risky changes
- [ ] Deprecation warnings for removed features

### 6. Code Review Categories

**Security Review** (Critical for all PRs):
- [ ] No hardcoded secrets or credentials
- [ ] Input validation for user data
- [ ] Authentication/authorization checks
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] CSRF protection where needed
- [ ] Dependency vulnerabilities checked

**Performance Review**:
- [ ] No obvious performance regressions
- [ ] Database queries optimized
- [ ] No N+1 query problems introduced
- [ ] Caching strategy appropriate
- [ ] Bundle size impact considered

**Code Quality Review**:
- [ ] Code follows project conventions
- [ ] Functions are focused and manageable
- [ ] Naming is clear and consistent
- [ ] No code duplication
- [ ] Error handling appropriate
- [ ] Type safety maintained

**Testing Review**:
- [ ] New features have tests
- [ ] Bug fixes have regression tests
- [ ] Tests are meaningful
- [ ] Test coverage maintained or improved
- [ ] Tests pass locally

**Documentation Review**:
- [ ] Public APIs documented
- [ ] Complex logic explained
- [ ] README updated if needed
- [ ] CHANGELOG updated
- [ ] Migration guide for breaking changes

### 7. Test Coverage Analysis

**Check Test Changes**:
```bash
# Find test files in PR
git diff --name-only $(git merge-base HEAD main)..HEAD | grep -E '\.(test|spec)\.'

# Check test coverage (if available)
npm test -- --coverage --changedSince=main 2>/dev/null || echo "Run tests to check coverage"

# Look for untested code
# (Manual review of changed files vs test files)
```

**Test Quality Questions**:
- Are tests testing behavior or implementation?
- Are edge cases covered?
- Are error paths tested?
- Are tests isolated and independent?
- Are test names descriptive?

### 8. Review Changed Files

**For Each Changed File**:
1. Understand the purpose of changes
2. Check for security issues
3. Check for performance issues
4. Check for quality issues
5. Verify tests exist
6. Look for potential bugs

**Focus Areas by File Type**:
- **Backend code**: Auth, validation, queries, error handling
- **Frontend code**: Rendering, state management, accessibility
- **Database migrations**: Reversibility, data safety, indexes
- **Configuration**: Security, environment-specific values
- **Dependencies**: Vulnerability check, license compatibility

### 9. PR Review Template

Structure feedback for GitHub PR review:

```markdown
## Summary

[High-level assessment of the PR]

**Overall Assessment**: ✅ Approve | 💬 Approve with Comments | 🔄 Request Changes

**Change Type**: [Feature | Bug Fix | Refactor | Documentation | Performance]
**Risk Level**: [Low | Medium | High | Critical]
**Estimated Review Time**: [X minutes]

---

## Critical Issues 🚨

**[Must be fixed before merge]**

### Security Issue: [Title]
**File**: `path/to/file.ts` (line X)
**Issue**: [Description]
**Risk**: [Why this is critical]
**Suggestion**:
```typescript
// Current
[problematic code]

// Suggested
[fixed code]
```

[Repeat for each critical issue]

---

## High Priority Comments ⚠️

**[Should be addressed before merge]**

### [Issue Title]
**File**: `path/to/file.ts` (line X)
**Comment**: [Description and suggestion]

[Repeat for each high priority issue]

---

## Medium Priority Suggestions 💡

**[Consider addressing]**

### [Suggestion Title]
**File**: `path/to/file.ts` (line X)
**Suggestion**: [Description]

[Repeat for each medium priority suggestion]

---

## Low Priority / Nits 📝

**[Optional improvements]**

- [File]: [Minor suggestion]
- [File]: [Style nit]

---

## Positive Observations ✅

Things done well in this PR:

- ✅ [Good practice 1]
- ✅ [Good practice 2]
- ✅ [Good practice 3]

---

## Testing

**Test Coverage**: [Adequate | Needs Improvement | Insufficient]

- [✅ | ❌] Unit tests for new/changed logic
- [✅ | ❌] Integration tests for API changes
- [✅ | ❌] Component tests for UI changes
- [✅ | ❌] E2E tests for critical paths

**Missing Tests**:
- [Area 1 that needs tests]
- [Area 2 that needs tests]

---

## Documentation

- [✅ | ❌] Code is well-commented
- [✅ | ❌] Public APIs documented
- [✅ | ❌] README updated
- [✅ | ❌] CHANGELOG updated
- [✅ | ❌] Migration guide (if breaking changes)

---

## Questions for Author

1. [Question 1 about design decision]
2. [Question 2 about implementation choice]
3. [Question 3 about future plans]

---

## Review Checklist

- [✅ | ❌] PR title and description clear
- [✅ | ❌] Changes align with description
- [✅ | ❌] No unrelated changes
- [✅ | ❌] Tests added/updated
- [✅ | ❌] Documentation updated
- [✅ | ❌] No security issues
- [✅ | ❌] No performance regressions
- [✅ | ❌] Code quality maintained
- [✅ | ❌] Branch up to date with base

---

## Next Steps

**For Author**:
- [ ] Address critical issues
- [ ] Respond to comments
- [ ] Add missing tests
- [ ] Update documentation
- [ ] Request re-review

**For Reviewers**:
- [ ] Additional reviewers needed?
- [ ] Security review needed?
- [ ] Performance testing needed?

---

## Approval Status

**Recommendation**: [Approve | Request Changes | Needs More Info]

[Explanation of recommendation]
```

### 10. PR Size Considerations

**PR Too Large** (>400 lines):
- Suggest breaking into smaller PRs
- Review in phases (architecture first, then details)
- Focus on high-risk areas
- Note areas that need detailed review later

**PR Too Small** (<10 lines):
- Quick review appropriate
- Still check for edge cases
- Verify tests exist

### 11. Special PR Types

**Bug Fix PRs**:
- [ ] Root cause identified and documented
- [ ] Regression test added
- [ ] Fix is minimal and focused
- [ ] No unrelated refactoring
- [ ] Backward compatible

**Refactoring PRs**:
- [ ] Behavior unchanged (tests prove this)
- [ ] Motivation clear
- [ ] Refactoring scope reasonable
- [ ] No functional changes mixed in

**Feature PRs**:
- [ ] Feature complete (no half-done work)
- [ ] Feature flag used if risky
- [ ] Tests comprehensive
- [ ] Documentation complete
- [ ] Backward compatible

**Hotfix PRs**:
- [ ] Minimal changes only
- [ ] High test coverage
- [ ] Rollback plan documented
- [ ] Can be deployed independently

## Review Depth Implementation

**Quick Depth** (5-10 min):
- PR metadata and description review
- Security critical issues only
- Obvious bugs
- Test presence check
- High-level change assessment

**Standard Depth** (20-30 min):
- Complete PR review
- All categories covered (security, performance, quality)
- Test coverage reviewed
- Documentation checked
- Detailed inline comments

**Deep Depth** (45-60+ min):
- Comprehensive PR analysis
- Architecture implications
- Performance impact analysis
- Complete test review
- Documentation thoroughness
- Deployment considerations
- Backward compatibility analysis

## Output Format

Provide a GitHub-compatible PR review following the template above, formatted for posting as PR comments.

## Code Examples - Common PR Issues

```typescript
// ❌ COMMON PR ISSUE: Unrelated changes
// PR says "Fix login bug" but also includes:
function LoginForm() {
  // Login fix
  validateCredentials(email, password);

  // UNRELATED: Random formatting change in different feature
  const userProfile = formatUserProfile(user);
  return <div>{userProfile}</div>;
}

// ✅ GOOD: Focused changes only
// PR says "Fix login bug" and only includes:
function LoginForm() {
  // Only the login validation fix
  validateCredentials(email, password);
  return <div>...</div>;
}
```

```typescript
// ❌ COMMON PR ISSUE: No tests for new feature
// PR adds new feature without tests
export function calculateDiscount(price: number, code: string): number {
  if (code === 'SAVE10') return price * 0.9;
  if (code === 'SAVE20') return price * 0.8;
  return price;
}

// ✅ GOOD: New feature with tests
export function calculateDiscount(price: number, code: string): number {
  if (code === 'SAVE10') return price * 0.9;
  if (code === 'SAVE20') return price * 0.8;
  return price;
}

// In test file:
describe('calculateDiscount', () => {
  it('should apply 10% discount for SAVE10 code', () => {
    expect(calculateDiscount(100, 'SAVE10')).toBe(90);
  });

  it('should apply 20% discount for SAVE20 code', () => {
    expect(calculateDiscount(100, 'SAVE20')).toBe(80);
  });

  it('should return original price for invalid code', () => {
    expect(calculateDiscount(100, 'INVALID')).toBe(100);
  });
});
```

```typescript
// ❌ COMMON PR ISSUE: Breaking change without migration
// Removes field without deprecation period
export interface User {
  id: string;
  name: string;
  // 'email' field removed - BREAKING!
}

// ✅ GOOD: Deprecation with migration guide
export interface User {
  id: string;
  name: string;
  /**
   * @deprecated Use primaryEmail instead. Will be removed in v2.0.0
   */
  email?: string;
  primaryEmail: string; // New field
}
```

## Agent Invocation

This operation MUST leverage the **10x-fullstack-engineer** agent for comprehensive PR review expertise.

## Best Practices

1. **Be Timely**: Review PRs promptly to unblock teammates
2. **Be Thorough**: But don't let perfect be enemy of good
3. **Be Constructive**: Suggest solutions, not just problems
4. **Ask Questions**: Understand intent before criticizing
5. **Acknowledge Good Work**: Positive feedback matters
6. **Focus on Impact**: Prioritize issues by importance
7. **Be Specific**: Reference exact files and lines
8. **Consider Context**: Understand constraints and trade-offs
