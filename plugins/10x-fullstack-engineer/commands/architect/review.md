# Architecture Review Operation

You are executing the **review** operation using the 10x-fullstack-engineer agent to assess existing architecture quality, security, performance, and maintainability.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'review' operation name)

Expected format: `[path:"directory"] [focus:"security|performance|scalability|maintainability"] [depth:"shallow|deep"]`

Parse the arguments to extract:
- **path** (optional): Specific directory or component to review (defaults to entire codebase)
- **focus** (optional): Primary concern area - security, performance, scalability, maintainability, or "all"
- **depth** (optional): Review depth - "shallow" for quick assessment, "deep" for comprehensive analysis (default: "deep")

## Workflow

### Phase 1: Context Discovery

Discover and understand the existing architecture:

1. **Directory Structure Analysis**:
   - Examine project organization
   - Identify major components and layers
   - Detect framework and patterns used
   - Map file relationships and dependencies

2. **Technology Stack Identification**:
   - Frontend: Framework, state management, build tools
   - Backend: Language, framework, libraries
   - Database: Type, ORM/query builder, migrations
   - Infrastructure: Deployment, orchestration, monitoring
   - Dependencies: Third-party packages and versions

3. **Configuration Review**:
   - Environment configuration
   - Build and deployment configurations
   - Database connection and pooling
   - Caching configuration
   - Logging and monitoring setup

4. **Documentation Assessment**:
   - README quality and completeness
   - API documentation
   - Architecture diagrams if available
   - ADRs in `docs/adr/`
   - Code comments and inline documentation

5. **Testing Infrastructure**:
   - Unit test coverage
   - Integration test presence
   - E2E test setup
   - Testing frameworks and patterns

Use available tools:
- `Glob` to find relevant files by patterns
- `Read` to examine key architectural files
- `Grep` to search for patterns, anti-patterns, and security issues
- `Bash` to run analysis scripts (e.g., `analyze-dependencies.sh`, `complexity-metrics.py`)

### Phase 2: Layer-by-Layer Analysis

Analyze each architectural layer systematically:

#### Database Layer Review

**Schema Quality**:
- Table design and normalization
- Index coverage for common queries
- Foreign key relationships and referential integrity
- Constraint usage (unique, not null, check)
- Data types appropriateness

**Performance**:
- Index effectiveness (check for missing or unused indexes)
- Query patterns (N+1 queries, table scans)
- Connection pooling configuration
- Transaction isolation levels
- Read replica usage if applicable

**Scalability**:
- Sharding readiness
- Data volume handling
- Migration patterns
- Backup and recovery strategy

**Security**:
- SQL injection protection
- Encryption at rest
- Access control and permissions
- Audit logging
- PII handling

**Issues to Flag**:
- Missing indexes on frequently queried columns
- Lack of foreign key constraints
- Unoptimized queries (SELECT *, missing WHERE clauses)
- Missing migration strategy
- Hardcoded credentials
- Insufficient connection pooling

#### Backend Layer Review

**API Design Quality**:
- RESTful principles adherence
- Consistent naming conventions
- Versioning strategy
- Error response formats
- HTTP status code usage
- Request/response validation

**Code Organization**:
- Separation of concerns
- Layer isolation (controller/service/repository)
- Dependency injection usage
- Module boundaries
- Code duplication

**Business Logic**:
- Complexity and readability
- Error handling completeness
- Input validation and sanitization
- Transaction management
- Domain modeling quality

**Authentication & Authorization**:
- Token management (JWT, OAuth)
- Session handling
- Authorization checks at appropriate layers
- RBAC/ABAC implementation
- Password hashing (bcrypt, argon2)

**Performance**:
- Response time profiling
- Database query efficiency
- Caching effectiveness
- Async/await usage
- Connection pooling
- Rate limiting

**Security**:
- Input validation and sanitization
- SQL injection prevention
- XSS prevention
- CSRF protection
- Secrets management
- Security headers
- Dependency vulnerabilities

**Maintainability**:
- Code complexity metrics
- Test coverage
- Code comments
- Consistent error handling
- Logging completeness
- Dead code elimination

**Issues to Flag**:
- Synchronous blocking operations in async contexts
- Missing error handling
- Hardcoded secrets or credentials
- Insufficient input validation
- Missing authentication/authorization checks
- Poor error messages
- Excessive code complexity
- Lack of logging
- Dependency vulnerabilities

#### Frontend Layer Review

**Component Architecture**:
- Component size and complexity
- Reusability and composition
- Smart vs presentational separation
- Component communication patterns
- Prop drilling issues

**State Management**:
- State organization and structure
- Global vs local state balance
- State update patterns
- Performance implications
- Redux/MobX/Context usage quality

**Performance**:
- Bundle size analysis
- Code splitting effectiveness
- Lazy loading usage
- Rendering optimization (memoization, virtualization)
- Image optimization
- Web Vitals compliance

**User Experience**:
- Loading states
- Error boundaries
- Accessibility (WCAG compliance)
- Responsive design
- Progressive enhancement
- Offline support

**Security**:
- XSS prevention
- Content Security Policy
- Secure cookies
- Token storage
- Sensitive data exposure

**Build & Deployment**:
- Build configuration
- Asset optimization
- Source maps
- Environment configuration
- CI/CD integration

**Issues to Flag**:
- Large bundle sizes (> 500KB)
- Missing code splitting
- Prop drilling through multiple levels
- Unnecessary re-renders
- Missing loading/error states
- Accessibility violations
- Insecure token storage (localStorage for sensitive tokens)
- Missing error boundaries
- Large components (> 300 lines)
- Unused dependencies

#### Infrastructure Layer Review

**Deployment Architecture**:
- Containerization quality
- Orchestration configuration
- Service discovery
- Load balancing
- Auto-scaling configuration

**Scalability**:
- Horizontal scaling readiness
- Stateless service design
- Session management
- Database scaling strategy
- CDN usage

**Monitoring & Observability**:
- Application monitoring
- Infrastructure monitoring
- Log aggregation
- Distributed tracing
- Alerting configuration
- SLO/SLA definition

**CI/CD Pipeline**:
- Build automation
- Test automation
- Deployment automation
- Rollback procedures
- Blue-green or canary deployment

**Security**:
- Network segmentation
- Firewall rules
- WAF configuration
- DDoS protection
- Encryption in transit and at rest
- Secrets management
- Vulnerability scanning

**Disaster Recovery**:
- Backup strategy
- Recovery procedures
- RTO and RPO targets
- Failover mechanisms

**Issues to Flag**:
- Single point of failure
- Missing monitoring/alerting
- No rollback strategy
- Insufficient logging
- Missing backups
- Insecure network configuration
- Hardcoded secrets in deployment configs
- No health checks
- Missing auto-scaling
- Lack of disaster recovery plan

### Phase 3: Cross-Cutting Concerns Analysis

#### Security Audit

**Authentication**:
- Strong password requirements
- Multi-factor authentication
- Token expiration and rotation
- Session management

**Authorization**:
- Proper access control checks
- Principle of least privilege
- Resource-level permissions

**Data Protection**:
- Encryption at rest and in transit
- PII handling and anonymization
- Data retention policies
- GDPR/CCPA compliance

**Dependency Security**:
- Known vulnerabilities in dependencies
- Outdated packages
- License compliance

**Common Vulnerabilities**:
- OWASP Top 10 coverage
- Injection attacks
- Broken authentication
- Sensitive data exposure
- XML external entities
- Broken access control
- Security misconfiguration
- Cross-site scripting
- Insecure deserialization
- Insufficient logging

#### Performance Analysis

**Response Times**:
- API endpoint latency
- Database query performance
- External API call times
- Cache hit rates

**Resource Utilization**:
- CPU usage patterns
- Memory consumption
- Database connections
- Network bandwidth

**Bottlenecks**:
- Slow database queries
- Synchronous blocking calls
- Unoptimized algorithms
- Missing caching

**Frontend Performance**:
- Page load times
- Time to interactive
- Bundle sizes
- Asset optimization

#### Scalability Assessment

**Current Limits**:
- Concurrent user capacity
- Request throughput
- Data volume limits
- Connection pool sizes

**Scaling Strategy**:
- Horizontal scaling readiness
- Database scaling approach
- Stateless design
- Caching layers

**Potential Bottlenecks**:
- Database write contention
- Shared state
- Single-threaded processing
- Synchronous dependencies

#### Maintainability Review

**Code Quality**:
- Cyclomatic complexity
- Code duplication
- Consistent naming conventions
- Code organization

**Testing**:
- Test coverage percentage
- Test quality and effectiveness
- Testing pyramid balance
- Flaky tests

**Documentation**:
- README completeness
- API documentation
- Architecture diagrams
- Onboarding guides
- Runbooks

**Technical Debt**:
- TODO comments
- Deprecated code
- Workarounds and hacks
- Outdated dependencies

### Phase 4: Issue Identification and Scoring

For each issue found, document:

**Issue Template**:
```
**Issue**: [Brief description]
**Category**: [Security/Performance/Scalability/Maintainability]
**Severity**: [Critical/High/Medium/Low]
**Location**: [File and line number or component]
**Impact**: [Detailed explanation of consequences]
**Recommendation**: [How to fix]
**Effort**: [Estimated effort to fix]
**Priority**: [Immediate/High/Medium/Low]
```

**Severity Levels**:
- **Critical**: Security vulnerability, data loss risk, production outage risk
- **High**: Significant performance impact, major security concern, scalability blocker
- **Medium**: Performance degradation, maintainability issues, minor security concerns
- **Low**: Code quality issues, minor optimizations, documentation gaps

**Scoring System** (0-10 scale):

Score each dimension:
- **Security**: 0 (critical vulnerabilities) to 10 (best practices throughout)
- **Performance**: 0 (unacceptably slow) to 10 (optimized)
- **Scalability**: 0 (won't scale) to 10 (proven scalable architecture)
- **Maintainability**: 0 (unmaintainable) to 10 (excellent code quality)
- **Reliability**: 0 (frequent failures) to 10 (highly reliable)

**Overall Architecture Health**: Average of all dimensions

### Phase 5: Recommendations and Roadmap

Provide actionable recommendations prioritized by impact and effort:

**Quick Wins** (High Impact, Low Effort):
- Issues that can be fixed quickly with significant benefit
- Typically security fixes, configuration changes, missing indexes

**Important Improvements** (High Impact, Medium Effort):
- Architectural changes with significant value
- Performance optimizations requiring code changes
- Security hardening requiring moderate work

**Strategic Initiatives** (High Impact, High Effort):
- Major architectural refactoring
- Technology migrations
- Comprehensive test suite development

**Technical Debt Paydown** (Medium Impact, Variable Effort):
- Code quality improvements
- Documentation updates
- Dependency updates
- Test coverage improvements

**Nice-to-Haves** (Low-Medium Impact, Any Effort):
- Minor optimizations
- Code style improvements
- Additional monitoring

## Output Format

Provide a comprehensive architecture review report:

```markdown
# Architecture Review Report

**Review Date**: [Date]
**Scope**: [Full system / specific component]
**Focus**: [All / Security / Performance / Scalability / Maintainability]
**Depth**: [Shallow / Deep]
**Reviewer**: 10x-fullstack-engineer agent

## Executive Summary

[2-3 paragraph summary of findings, overall health, and key recommendations]

**Overall Architecture Health**: [Score]/10

**Key Findings**:
- [Most critical finding]
- [Second most critical finding]
- [Third most critical finding]

**Recommended Priority Actions**:
1. [Top priority action]
2. [Second priority action]
3. [Third priority action]

## Architecture Health Scores

| Dimension | Score | Status | Trend |
|-----------|-------|--------|-------|
| Security | [0-10] | [Critical/Poor/Fair/Good/Excellent] | [↑↓→] |
| Performance | [0-10] | [Critical/Poor/Fair/Good/Excellent] | [↑↓→] |
| Scalability | [0-10] | [Critical/Poor/Fair/Good/Excellent] | [↑↓→] |
| Maintainability | [0-10] | [Critical/Poor/Fair/Good/Excellent] | [↑↓→] |
| Reliability | [0-10] | [Critical/Poor/Fair/Good/Excellent] | [↑↓→] |
| **Overall** | **[0-10]** | **[Status]** | **[Trend]** |

**Score Interpretation**:
- 9-10: Excellent - Industry best practices
- 7-8: Good - Minor improvements needed
- 5-6: Fair - Moderate improvements needed
- 3-4: Poor - Significant issues to address
- 0-2: Critical - Urgent action required

## System Overview

### Technology Stack
**Frontend**: [Technologies]
**Backend**: [Technologies]
**Database**: [Technologies]
**Infrastructure**: [Technologies]
**Monitoring**: [Technologies]

### Architecture Pattern
[Monolith / Microservices / Serverless / Hybrid]

### Key Characteristics
- [Characteristic 1]
- [Characteristic 2]
- [Characteristic 3]

## Detailed Findings

### Security Analysis (Score: [X]/10)

**Strengths**:
- [Positive security practices]
- [What's done well]

**Issues Identified**:

**CRITICAL Issues**:
1. **[Issue Name]**
   - **Location**: [File/component]
   - **Impact**: [Security risk description]
   - **Recommendation**: [How to fix]
   - **Effort**: [Time estimate]

**HIGH Severity Issues**:
1. **[Issue Name]**
   - **Location**: [File/component]
   - **Impact**: [Security risk description]
   - **Recommendation**: [How to fix]
   - **Effort**: [Time estimate]

**MEDIUM Severity Issues**:
[List of medium issues with brief descriptions]

**LOW Severity Issues**:
[List of low issues with brief descriptions]

**Security Best Practices Compliance**:
- ✅ [Practice followed]
- ✅ [Practice followed]
- ❌ [Practice missing]
- ❌ [Practice missing]

**Recommendations**:
1. [Top security recommendation]
2. [Second security recommendation]
3. [Third security recommendation]

### Performance Analysis (Score: [X]/10)

**Strengths**:
- [What performs well]
- [Good performance practices]

**Performance Metrics** (if available):
- API Response Time (p50): [Xms]
- API Response Time (p95): [Xms]
- API Response Time (p99): [Xms]
- Database Query Time (avg): [Xms]
- Page Load Time: [Xs]
- Bundle Size: [XKB]

**Issues Identified**:

**CRITICAL Issues**:
1. **[Performance bottleneck]**
   - **Location**: [File/component]
   - **Impact**: [Performance impact - response times, throughput]
   - **Current**: [Current performance]
   - **Target**: [Target performance]
   - **Recommendation**: [Optimization approach]
   - **Expected Improvement**: [Performance gain estimate]
   - **Effort**: [Time estimate]

**HIGH Severity Issues**:
[Similar format as critical]

**MEDIUM Severity Issues**:
[List with brief descriptions]

**Optimization Opportunities**:
- [Opportunity 1]: [Potential gain]
- [Opportunity 2]: [Potential gain]
- [Opportunity 3]: [Potential gain]

**Recommendations**:
1. [Top performance recommendation]
2. [Second performance recommendation]
3. [Third performance recommendation]

### Scalability Analysis (Score: [X]/10)

**Current Scale**:
- Users: [Estimated current users]
- Requests: [Current request volume]
- Data: [Current data volume]

**Scaling Capabilities**:
- **Horizontal Scaling**: [Yes/No/Limited] - [Explanation]
- **Vertical Scaling**: [Current headroom]
- **Database Scaling**: [Current approach]

**Strengths**:
- [Scalable design elements]
- [Good scaling practices]

**Limitations**:
1. **[Scalability bottleneck]**
   - **Current Limit**: [When this breaks]
   - **Impact**: [What happens at scale]
   - **Recommendation**: [How to scale past this]
   - **Effort**: [Time estimate]

**Scaling Readiness Assessment**:
- ✅ Stateless application design
- ✅ Connection pooling configured
- ❌ Database sharding not implemented
- ❌ No caching layer
- ✅ Horizontal auto-scaling configured
- ❌ No rate limiting

**Projected Capacity**:
- Maximum concurrent users: [Estimate]
- Maximum requests/second: [Estimate]
- Bottleneck at: [What fails first]

**Recommendations**:
1. [Top scalability recommendation]
2. [Second scalability recommendation]
3. [Third scalability recommendation]

### Maintainability Analysis (Score: [X]/10)

**Code Quality Metrics** (if available):
- Test Coverage: [X]%
- Average Cyclomatic Complexity: [X]
- Code Duplication: [X]%
- Lines of Code: [X]
- Technical Debt Ratio: [X]%

**Strengths**:
- [Good maintainability practices]
- [What makes code maintainable]

**Issues Identified**:

**HIGH Impact Issues**:
1. **[Maintainability issue]**
   - **Location**: [Component/file]
   - **Impact**: [How this affects maintenance]
   - **Recommendation**: [Improvement approach]
   - **Effort**: [Time estimate]

**MEDIUM Impact Issues**:
[List with brief descriptions]

**Technical Debt Items**:
- [Debt item 1]: [Impact]
- [Debt item 2]: [Impact]
- [Debt item 3]: [Impact]

**Documentation Assessment**:
- ✅ [Documentation present]
- ✅ [Documentation present]
- ❌ [Documentation missing]
- ❌ [Documentation missing]

**Testing Assessment**:
- Unit Tests: [X]% coverage - [Quality assessment]
- Integration Tests: [Present/Missing] - [Assessment]
- E2E Tests: [Present/Missing] - [Assessment]
- Test Quality: [Assessment]

**Recommendations**:
1. [Top maintainability recommendation]
2. [Second maintainability recommendation]
3. [Third maintainability recommendation]

### Reliability Analysis (Score: [X]/10)

**Strengths**:
- [Reliability features]
- [Good practices]

**Issues Identified**:
1. **[Reliability concern]**
   - **Impact**: [Potential for failure]
   - **Likelihood**: [How likely]
   - **Recommendation**: [Mitigation]
   - **Effort**: [Time estimate]

**Monitoring & Observability**:
- Application Monitoring: [Present/Missing]
- Error Tracking: [Present/Missing]
- Logging: [Assessment]
- Alerting: [Assessment]
- Health Checks: [Present/Missing]

**Error Handling**:
- Error handling coverage: [Assessment]
- Graceful degradation: [Yes/No]
- Circuit breakers: [Present/Missing]
- Retry logic: [Present/Missing]

**Disaster Recovery**:
- Backup strategy: [Assessment]
- Recovery procedures: [Documented/Missing]
- RTO target: [X hours/unknown]
- RPO target: [X hours/unknown]

**Recommendations**:
1. [Top reliability recommendation]
2. [Second reliability recommendation]
3. [Third reliability recommendation]

## Architecture Patterns Analysis

### Positive Patterns Identified
- **[Pattern Name]**: [Where used] - [Benefits]
- **[Pattern Name]**: [Where used] - [Benefits]

### Anti-Patterns Identified
- **[Anti-Pattern Name]**: [Where found] - [Issues] - [Recommendation]
- **[Anti-Pattern Name]**: [Where found] - [Issues] - [Recommendation]

### Recommended Patterns to Adopt
- **[Pattern Name]**: [Use case] - [Benefits] - [Implementation approach]
- **[Pattern Name]**: [Use case] - [Benefits] - [Implementation approach]

## Dependency Analysis

### Security Vulnerabilities
| Package | Severity | Vulnerability | Recommendation |
|---------|----------|---------------|----------------|
| [package] | Critical | [CVE/description] | Update to [version] |
| [package] | High | [CVE/description] | Update to [version] |

### Outdated Dependencies
| Package | Current | Latest | Breaking Changes |
|---------|---------|--------|------------------|
| [package] | [version] | [version] | Yes/No |

### Unused Dependencies
- [package]: [reason it's unused]
- [package]: [reason it's unused]

## Recommendations Roadmap

### Immediate Actions (This Sprint)
**Priority**: CRITICAL - Address immediately

1. **[Action Item]**
   - **Category**: [Security/Performance/etc.]
   - **Impact**: [What improves]
   - **Effort**: [Time estimate]
   - **Owner**: [Team/person]

2. **[Action Item]**
   [Same format]

### Short-Term Improvements (Next 1-2 Months)
**Priority**: HIGH - Schedule soon

1. **[Action Item]**
   [Same format as above]

### Medium-Term Initiatives (Next 3-6 Months)
**Priority**: MEDIUM - Plan and schedule

1. **[Action Item]**
   [Same format]

### Long-Term Strategic Changes (6+ Months)
**Priority**: STRATEGIC - Begin planning

1. **[Action Item]**
   [Same format]

## Cost-Benefit Analysis

| Recommendation | Impact | Effort | Cost | ROI | Priority |
|----------------|--------|--------|------|-----|----------|
| [Item 1] | High | Low | $X | High | 1 |
| [Item 2] | High | Medium | $X | Medium | 2 |
| [Item 3] | Medium | Low | $X | High | 3 |

## Risk Assessment

### Current Risks
1. **[Risk Description]**
   - **Likelihood**: High/Medium/Low
   - **Impact**: Critical/High/Medium/Low
   - **Mitigation**: [Recommendation]
   - **Timeline**: [When to address]

### Risks If Recommendations Not Implemented
1. **[Risk Description]**
   - **Likelihood**: [Assessment]
   - **Impact**: [Assessment]
   - **Timeline**: [When risk materializes]

## Comparison to Industry Standards

| Aspect | Current State | Industry Standard | Gap |
|--------|---------------|-------------------|-----|
| Security | [Assessment] | [Standard] | [Gap] |
| Performance | [Assessment] | [Standard] | [Gap] |
| Scalability | [Assessment] | [Standard] | [Gap] |
| Test Coverage | [X]% | 80%+ | [Gap] |
| Monitoring | [Assessment] | [Standard] | [Gap] |

## Conclusion

[Summary of overall architecture state, key findings, and recommended next steps]

**Overall Assessment**: [Narrative assessment of architecture health]

**Critical Success Factors**:
1. [What needs to happen for success]
2. [Key factor 2]
3. [Key factor 3]

**Next Steps**:
1. [Immediate next step]
2. [Following step]
3. [Third step]

## Appendices

### Appendix A: Detailed Issue List
[Comprehensive list of all issues with full details]

### Appendix B: Performance Profiling Results
[Detailed performance data if available]

### Appendix C: Security Audit Details
[Comprehensive security findings]

### Appendix D: Code Quality Metrics
[Detailed code quality measurements]

### Appendix E: References
- [Related ADRs]
- [Industry standards referenced]
- [Tools used for analysis]
```

## Agent Invocation

This operation MUST invoke the **10x-fullstack-engineer** agent for expert architecture review.

**Agent context to provide**:
- Parsed parameters (path, focus, depth)
- Discovered technology stack
- Current architecture patterns
- Issues found during analysis
- Performance metrics if available
- Security concerns identified

**Agent responsibilities**:
- Apply 15+ years of architectural review experience
- Identify subtle issues and anti-patterns
- Assess architecture health across all dimensions
- Provide actionable recommendations
- Prioritize findings by impact and effort
- Suggest industry best practices
- Compare to similar production systems

**Agent invocation approach**:
Present comprehensive architecture analysis and explicitly request:
"Using your 15+ years of full-stack architecture experience, review this system architecture. Assess security, performance, scalability, maintainability, and reliability. Provide scored assessment, identify critical issues, and recommend prioritized improvements. Consider both immediate risks and long-term technical debt."

## Error Handling

### Path Not Found
If specified path doesn't exist:

```
Error: Path not found: [path]

Available paths to review:
- [directory 1]
- [directory 2]
- [directory 3]

Would you like to:
a) Review the entire codebase (no path specified)
b) Specify a different path
c) List available directories

Please specify a valid path or choose an option.
```

### Insufficient Permissions
If cannot read files:

```
Error: Insufficient permissions to read files in [path]

I need read access to:
- Source code files
- Configuration files
- Documentation

Please ensure the files are readable or specify a different path.
```

### Unknown Focus Area
If focus parameter is invalid:

```
Error: Unknown focus area: [focus]

Valid focus areas:
- security       Focus on security vulnerabilities and best practices
- performance    Focus on response times, throughput, and optimization
- scalability    Focus on scaling capabilities and limitations
- maintainability Focus on code quality, testing, and documentation
- all            Comprehensive review across all areas (default)

Example: /architect review focus:"security" depth:"deep"
```

### Empty Codebase
If no code found to review:

```
Error: No code found to review in [path]

The specified path appears empty or contains no reviewable files.

Please specify a path containing:
- Source code files
- Configuration files
- Application logic

Or I can search for code in the current directory.
```

## Examples

**Example 1 - Comprehensive System Review**:
```
/architect review
```
Reviews entire codebase across all dimensions with deep analysis.

**Example 2 - Security-Focused Review**:
```
/architect review focus:"security" depth:"deep"
```
Deep security audit covering OWASP Top 10, dependency vulnerabilities, and security best practices.

**Example 3 - Quick Performance Assessment**:
```
/architect review focus:"performance" depth:"shallow"
```
Quick performance review identifying obvious bottlenecks and optimization opportunities.

**Example 4 - Specific Component Review**:
```
/architect review path:"src/services/payment" focus:"security"
```
Focused security review of payment service component.

**Example 5 - Pre-Production Review**:
```
/architect review focus:"all" depth:"deep"
```
Comprehensive production-readiness review before deployment.

**Example 6 - Scalability Assessment**:
```
/architect review focus:"scalability" depth:"deep"
```
Detailed analysis of scaling capabilities and limitations for capacity planning.

**Example 7 - Code Quality Review**:
```
/architect review path:"src/api" focus:"maintainability"
```
Maintainability review of API layer for technical debt and refactoring opportunities.
