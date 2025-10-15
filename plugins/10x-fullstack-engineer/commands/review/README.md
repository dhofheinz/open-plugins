# Code Review Skill

Comprehensive code review system with specialized operations for different review types and focus areas. Provides structured, actionable feedback with priority levels and detailed analysis across security, performance, quality, accessibility, and PR reviews.

## Overview

The review skill orchestrates multi-category code reviews through a router-based architecture. Each operation targets specific review concerns while maintaining consistent output formats and depth levels.

## Architecture

```
review/
├── skill.md              # Router - orchestrates review operations
├── full.md               # Comprehensive multi-category review
├── security.md           # Security-focused review (OWASP Top 10)
├── performance.md        # Performance optimization review
├── quality.md            # Code quality and maintainability review
├── pr.md                 # Pull request review with git integration
└── accessibility.md      # Accessibility (a11y) compliance review
```

## Available Operations

### `/review full`
**Comprehensive Review** - All categories covered

Performs complete code review covering:
- Security (authentication, injection prevention, data protection)
- Performance (database, backend, frontend, network)
- Code Quality (organization, error handling, type safety)
- Architecture (design patterns, scalability, maintainability)
- Testing (coverage, quality, edge cases)
- Documentation (code comments, project docs)
- Accessibility (for frontend code)

**Best for**: Feature completeness reviews, pre-production audits, comprehensive assessment

---

### `/review security`
**Security-Focused Review** - OWASP Top 10 compliance

Deep security audit focusing on:
- Authentication & Authorization (JWT, session management, RBAC)
- Input Validation & Injection Prevention (SQL, XSS, CSRF, command injection)
- Data Protection (encryption, secrets management, PII handling)
- Security Headers (CSP, HSTS, X-Frame-Options)
- Dependency Vulnerabilities (npm audit, pip-audit)
- OWASP Top 10 comprehensive check

**Best for**: Payment systems, authentication modules, API endpoints, compliance audits

---

### `/review performance`
**Performance-Focused Review** - Optimization analysis

Performance optimization across:
- Database Performance (N+1 queries, indexes, connection pooling)
- Backend Performance (algorithms, async operations, caching)
- Frontend Performance (React optimization, bundle size, virtualization)
- Network Performance (API calls, compression, CDN)
- Scalability Assessment (horizontal/vertical scaling)

**Best for**: Dashboard components, API services, data-heavy features, production optimization

---

### `/review quality`
**Code Quality Review** - Maintainability and craftsmanship

Software craftsmanship review covering:
- Code Organization (naming, function size, structure)
- Error Handling (validation, meaningful errors, graceful degradation)
- Type Safety (TypeScript, proper types, no any)
- Testing (coverage, quality, edge cases)
- Documentation (comments, README, API docs)
- SOLID Principles (SRP, DI, OCP, LSP, ISP)
- Design Patterns (appropriate usage, anti-patterns)

**Best for**: Refactoring efforts, technical debt assessment, maintainability improvements

---

### `/review pr`
**Pull Request Review** - Git-integrated change analysis

PR-specific review with git context:
- PR metadata validation (title, description, size)
- Change scope assessment (no scope creep, aligned with description)
- Commit quality (meaningful messages, atomic commits)
- Impact analysis (risk assessment, backward compatibility)
- All review categories applied to changes only
- Test coverage for new/changed code
- Documentation updates

**Best for**: Code review collaboration, GitHub/GitLab workflows, team reviews

---

### `/review accessibility`
**Accessibility Review** - WCAG compliance (a11y)

Accessibility audit for inclusive design:
- Semantic HTML (proper elements, heading hierarchy)
- ARIA (roles, properties, labels, live regions)
- Keyboard Navigation (tab order, focus management, shortcuts)
- Screen Reader Compatibility (alt text, labels, announcements)
- Color & Contrast (WCAG AA/AAA ratios, color-blind friendly)
- Responsive Design (zoom support, touch targets)
- WCAG 2.1 compliance (Level A, AA, AAA)

**Best for**: UI components, checkout flows, forms, public-facing applications

---

## Usage

### Basic Usage

```bash
/review <operation> scope:"<what-to-review>" [depth:"<level>"] [focus:"<area>"]
```

### Parameters

| Parameter | Required | Values | Default | Description |
|-----------|----------|--------|---------|-------------|
| `operation` | Yes | `full`, `security`, `performance`, `quality`, `pr`, `accessibility` | - | Review type |
| `scope` | Yes | Any string | - | What to review (files, modules, features, PR) |
| `depth` | No | `quick`, `standard`, `deep` | `standard` | Review thoroughness |
| `focus` | No | Any string | - | Additional emphasis areas |

### Review Depth Levels

| Depth | Time | Coverage | Use Case |
|-------|------|----------|----------|
| **Quick** | 5-15 min | High-level scan, critical issues only, obvious bugs | Quick checks, initial assessment, time-constrained |
| **Standard** | 20-40 min | All major categories, thorough review, actionable feedback | Regular code reviews, PR reviews, feature reviews |
| **Deep** | 45-90+ min | Comprehensive analysis, architecture review, complete audit | Pre-production, security audits, technical debt assessment |

### Examples

#### Comprehensive Feature Review
```bash
/review full scope:"authentication feature" depth:"deep"
```
Reviews all security, performance, quality, testing, and documentation aspects of the auth feature.

---

#### Security Audit for Critical Module
```bash
/review security scope:"payment processing module" depth:"deep"
```
Deep security audit focusing on OWASP Top 10, PCI DSS considerations, and vulnerability scanning.

---

#### Performance Analysis
```bash
/review performance scope:"dashboard rendering and data loading" depth:"standard"
```
Analyzes database queries, rendering optimization, bundle size, and API call efficiency.

---

#### Code Quality Check
```bash
/review quality scope:"src/utils and src/helpers" depth:"quick"
```
Quick scan for code organization, duplication, naming, and obvious quality issues.

---

#### Pull Request Review
```bash
/review pr scope:"PR #456 - Add user permissions" depth:"standard"
```
Reviews PR changes with git integration, assesses impact, checks tests, and provides GitHub-compatible feedback.

---

#### Accessibility Compliance
```bash
/review accessibility scope:"checkout flow components" depth:"deep" level:"AA"
```
Comprehensive WCAG 2.1 Level AA compliance review with screen reader testing recommendations.

---

#### Quick Security Scan
```bash
/review security scope:"recent changes in API layer" depth:"quick"
```
Fast security scan for obvious vulnerabilities in recent changes.

---

#### Performance Hot Spot
```bash
/review performance scope:"UserList component" depth:"standard" focus:"rendering and memory"
```
Standard performance review with extra focus on rendering performance and memory leaks.

---

## Review Categories

All operations assess findings across these categories:

### Security 🔒
- Authentication & authorization
- Input validation & sanitization
- Injection prevention (SQL, XSS, command)
- Secrets management
- Data protection (encryption, PII)
- OWASP Top 10 vulnerabilities

### Performance ⚡
- Database optimization (queries, indexes, N+1)
- Backend efficiency (algorithms, async, caching)
- Frontend optimization (React, bundle, rendering)
- Network optimization (API calls, compression)
- Scalability considerations

### Code Quality 📝
- Organization & naming
- Function size & complexity
- Error handling
- Type safety (TypeScript)
- Code duplication (DRY)
- SOLID principles

### Testing 🧪
- Unit test coverage
- Integration tests
- Component/E2E tests
- Test quality & meaningfulness
- Edge case coverage

### Documentation 📚
- Code comments
- JSDoc/docstrings
- README accuracy
- API documentation
- Architecture docs (ADRs)

### Accessibility ♿
- Semantic HTML
- ARIA usage
- Keyboard navigation
- Screen reader compatibility
- WCAG compliance

## Priority Levels

Reviews classify findings by priority:

| Priority | Symbol | Meaning | Action Required |
|----------|--------|---------|-----------------|
| **Critical** | 🚨 | Security vulnerabilities, data integrity issues, breaking bugs | Must fix before merge/deploy |
| **High** | ⚠️ | Performance bottlenecks, major quality issues, missing tests | Should fix before merge |
| **Medium** | ℹ️ | Code quality improvements, refactoring opportunities, minor issues | Consider fixing |
| **Low** | 💡 | Nice-to-have improvements, style suggestions, optimizations | Optional |

## Output Format

All review operations produce structured feedback:

```markdown
# [Review Type]: [Scope]

## Executive Summary
- Overall assessment and rating
- Key metrics (coverage, performance, quality)
- Recommendation (Approve/Request Changes/Needs Info)
- Priority actions

## Critical Issues 🚨
- File paths and line numbers
- Clear problem description
- Risk/impact explanation
- Code examples (current vs. suggested)
- Testing recommendations

## High Priority Issues ⚠️
- Similar structure to critical
- Actionable suggestions

## Medium Priority Issues ℹ️
- Improvement opportunities
- Refactoring suggestions

## Low Priority Issues 💡
- Nice-to-have enhancements
- Style improvements

## Positive Observations ✅
- Good practices to maintain
- Strengths in the code

## Detailed Review by Category
- Category-specific analysis
- Metrics and scoring
- Specific recommendations

## Recommendations
- Immediate actions (this week)
- Short-term improvements (this month)
- Long-term enhancements (this quarter)

## Review Metadata
- Reviewer, date, depth, time spent
- Issue counts by priority
```

## Review Focus Areas

### Security Focus Areas
- **Authentication**: JWT validation, session management, MFA
- **Authorization**: RBAC, permission checks, resource access
- **Input Validation**: All user inputs validated and sanitized
- **Injection Prevention**: SQL, XSS, CSRF, command, path traversal
- **Secrets Management**: No hardcoded credentials, environment variables
- **Data Protection**: Encryption at rest/transit, PII handling
- **Dependencies**: Vulnerability scanning (npm audit, pip-audit)

### Performance Focus Areas
- **Database**: Query optimization, N+1 prevention, indexes, connection pooling
- **Backend**: Algorithm complexity, async operations, caching, rate limiting
- **Frontend**: React optimization (memo, useMemo, useCallback), virtualization, bundle size
- **Network**: API batching, compression, CDN, prefetching

### Quality Focus Areas
- **Organization**: Clear naming, function size (<50 lines), DRY principle
- **Error Handling**: All errors caught, meaningful messages, proper logging
- **Type Safety**: No `any` types, explicit return types, proper interfaces
- **Testing**: >80% coverage for critical code, meaningful tests, edge cases
- **Documentation**: Complex logic explained, public APIs documented, README current

### Accessibility Focus Areas
- **Semantic HTML**: Proper elements, heading hierarchy, landmarks
- **ARIA**: Correct roles, properties, labels, live regions
- **Keyboard**: Full keyboard access, logical tab order, visible focus
- **Screen Reader**: Alt text, form labels, announcements, reading order
- **Contrast**: WCAG AA (4.5:1 text, 3:1 UI), AAA (7:1 text, 4.5:1 large text)

## Common Review Workflows

### Pre-Merge PR Review
```bash
# 1. Standard PR review
/review pr scope:"PR #123" depth:"standard"

# 2. If security-sensitive changes detected, follow up with:
/review security scope:"payment module changes" depth:"deep"

# 3. If performance-critical changes, analyze:
/review performance scope:"database query changes" depth:"standard"
```

### Pre-Production Audit
```bash
# 1. Comprehensive review of feature
/review full scope:"new checkout feature" depth:"deep"

# 2. Dedicated security audit
/review security scope:"checkout feature" depth:"deep"

# 3. Accessibility compliance (if user-facing)
/review accessibility scope:"checkout UI" depth:"deep" level:"AA"
```

### Technical Debt Assessment
```bash
# 1. Quality review to identify debt
/review quality scope:"legacy auth module" depth:"deep"

# 2. Performance assessment
/review performance scope:"legacy auth module" depth:"standard"

# 3. Security review (critical for old code)
/review security scope:"legacy auth module" depth:"deep"
```

### Quick Daily Reviews
```bash
# Quick review of recent changes
/review quality scope:"today's commits" depth:"quick"

# Fast security scan
/review security scope:"API changes today" depth:"quick"
```

## Integration with 10x-fullstack-engineer Agent

All review operations leverage the **10x-fullstack-engineer** agent for:
- Cross-stack expertise (frontend, backend, database, infrastructure)
- Pattern recognition across different tech stacks
- Best practices knowledge (React, Node.js, Python, Go, etc.)
- Constructive, actionable feedback
- Architectural understanding
- Security awareness (OWASP, common vulnerabilities)
- Performance optimization techniques

## Review Best Practices

### For Reviewers
1. **Be Specific**: Always include file paths and line numbers
2. **Be Constructive**: Suggest solutions, not just problems
3. **Explain Why**: Help understand reasoning behind recommendations
4. **Provide Examples**: Show both problematic and corrected code
5. **Acknowledge Good Work**: Recognize strengths and good practices
6. **Prioritize by Impact**: Security and data integrity first
7. **Be Actionable**: Every issue should have clear next steps
8. **Ask Questions**: When intent is unclear, ask rather than assume

### For Code Authors
1. **Provide Context**: Explain design decisions in PR descriptions
2. **Address Critical Issues First**: Focus on 🚨 and ⚠️ items
3. **Ask for Clarification**: If feedback is unclear, ask
4. **Update Tests**: Add tests for issues found
5. **Document Decisions**: Update docs based on feedback
6. **Iterative Improvement**: Don't try to fix everything at once

## Testing & Validation

Reviews recommend testing approaches:

### Security Testing
- Dependency vulnerability scanning (npm audit, pip-audit)
- Manual penetration testing for critical areas
- OWASP ZAP or Burp Suite for web apps
- Security unit tests (auth, validation)

### Performance Testing
- Load testing (k6, Artillery, Locust)
- Profiling (Chrome DevTools, clinic.js)
- Bundle analysis (webpack-bundle-analyzer)
- Lighthouse audits

### Accessibility Testing
- Automated tools (axe-core, pa11y, Lighthouse)
- Manual keyboard navigation testing
- Screen reader testing (NVDA, JAWS, VoiceOver)
- Color contrast analyzers

## Customization

### Adding Focus Areas
```bash
# Add custom focus to any review
/review full scope:"API layer" depth:"standard" focus:"error handling and logging"
```

### Adjusting Depth
- **Quick**: Time-constrained, pre-commit hooks, CI/CD gates
- **Standard**: Regular PR reviews, feature completeness checks
- **Deep**: Pre-production, security audits, architecture reviews

### Combining Operations
For complex reviews, run multiple operations:
```bash
# 1. Full review for baseline
/review full scope:"feature" depth:"standard"

# 2. Deep dive on specific concern
/review security scope:"feature auth logic" depth:"deep"

# 3. Performance analysis
/review performance scope:"feature data loading" depth:"standard"
```

## Tools & Resources

### Recommended Tools
- **Linting**: ESLint (eslint-plugin-jsx-a11y), Pylint, golangci-lint
- **Security**: npm audit, pip-audit, Snyk, OWASP Dependency-Check
- **Performance**: Lighthouse, Chrome DevTools, webpack-bundle-analyzer
- **Accessibility**: axe DevTools, WAVE, Lighthouse, pa11y
- **Testing**: Jest, Pytest, Go test, Cypress, Playwright

### Documentation References
- **Security**: OWASP Top 10, CWE Top 25, SANS Top 25
- **Performance**: Web Vitals, Core Web Vitals, Performance Best Practices
- **Quality**: Clean Code, SOLID Principles, Design Patterns
- **Accessibility**: WCAG 2.1, ARIA Authoring Practices

## Troubleshooting

### "Review scope too large"
**Solution**: Break into smaller reviews
```bash
# Instead of:
/review full scope:"entire application" depth:"deep"

# Do:
/review full scope:"authentication module" depth:"deep"
/review full scope:"payment module" depth:"deep"
/review full scope:"user management" depth:"deep"
```

### "Not enough context provided"
**Solution**: Be more specific about scope
```bash
# Instead of:
/review security scope:"code" depth:"standard"

# Do:
/review security scope:"src/auth module - JWT validation and session management" depth:"standard"
```

### "Need faster reviews"
**Solution**: Use quick depth for initial pass
```bash
# Quick pass first
/review quality scope:"new feature" depth:"quick"

# Then deep dive on issues found
/review security scope:"authentication logic" depth:"deep"
```

## Contributing

To extend or customize review operations:

1. Review operations are in `/commands/review/*.md`
2. Router logic is in `/commands/review/skill.md`
3. Each operation follows a consistent structure:
   - Parse parameters from `$ARGUMENTS`
   - Gather context (git, project structure)
   - Execute category-specific checklists
   - Provide structured output

---

## Quick Reference

| Command | Best For | Time | Focus |
|---------|----------|------|-------|
| `/review full` | Complete assessment | 45-60 min | All categories |
| `/review security` | Security audit | 30-90 min | OWASP Top 10, vulnerabilities |
| `/review performance` | Optimization | 30-90 min | Speed, scalability, efficiency |
| `/review quality` | Maintainability | 30-90 min | Clean code, SOLID, patterns |
| `/review pr` | Pull requests | 20-30 min | Changes, impact, tests |
| `/review accessibility` | WCAG compliance | 30-90 min | a11y, ARIA, keyboard, screen readers |

---

**Created by**: 10x Fullstack Engineer Plugin
**Version**: 1.0.0
**Last Updated**: 2025-10-14
