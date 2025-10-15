# Architecture Health Assessment Operation

You are executing the **assess** operation using the 10x-fullstack-engineer agent to perform comprehensive architecture health assessment with scoring and trend analysis.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'assess' operation name)

Expected format: `[scope:"system|service|component"] [focus:"dimension"] [baseline:"reference"]`

Parse the arguments to extract:
- **scope** (optional): Assessment scope - "system" (entire architecture), "service" (specific service), "component" (specific component) - defaults to "system"
- **focus** (optional): Specific dimension to assess - "tech-debt", "security", "performance", "scalability", "maintainability", "cost", or "all" (default: "all")
- **baseline** (optional): Baseline for comparison - ADR number, date (YYYY-MM-DD), or "previous" for last assessment

## Workflow

### Phase 1: Baseline Discovery

Identify baseline for comparison if specified:

1. **Parse Baseline Reference**:
   - If `baseline:"ADR-XXXX"`: Read that ADR and extract metrics
   - If `baseline:"YYYY-MM-DD"`: Find assessment from that date
   - If `baseline:"previous"`: Find most recent assessment file
   - If not specified: This is the initial baseline assessment

2. **Locate Previous Assessments**:
   - Search for assessment files in `docs/assessments/`
   - Naming convention: `architecture-assessment-YYYY-MM-DD.md`
   - Read most recent assessment if baseline not specified

3. **Extract Baseline Metrics**:
   - Previous scores for each dimension
   - Identified issues and their resolution status
   - Recommendations and implementation status
   - Trends from previous assessments

Use available tools:
- `Glob` to find assessment files
- `Read` to examine previous assessments
- `Bash` to list and sort assessment files by date

### Phase 2: Dimensional Assessment

Assess architecture across six key dimensions:

#### Dimension 1: Technical Debt

**Assessment Areas**:
- Code quality and complexity
- Outdated dependencies and libraries
- Deprecated patterns and practices
- TODO comments and temporary workarounds
- Duplicated code and logic
- Missing tests and documentation
- Legacy code without clear ownership

**Metrics to Collect**:
- Code complexity (cyclomatic complexity average)
- Code duplication percentage
- Outdated dependency count and severity
- TODO/FIXME/HACK comment count
- Test coverage percentage
- Documentation completeness score
- Time to onboard new developers (survey data)

**Scoring Criteria** (0-10):
- **10**: No technical debt, excellent code quality, comprehensive tests and docs
- **8-9**: Minimal debt, well-maintained, minor improvements needed
- **6-7**: Moderate debt, manageable but growing, action needed soon
- **4-5**: Significant debt, impacting velocity, requires dedicated effort
- **2-3**: Severe debt, major maintainability issues, urgent action needed
- **0-1**: Critical debt, system nearly unmaintainable, major refactoring required

**Issues to Identify**:
- High-complexity functions (cyclomatic complexity > 10)
- Dependencies with known vulnerabilities
- Code duplication > 5%
- Test coverage < 70%
- Missing documentation for public APIs
- Components > 500 lines
- Files with > 10 TODO comments

#### Dimension 2: Security

**Assessment Areas**:
- Authentication and authorization mechanisms
- Data encryption (at rest and in transit)
- Input validation and sanitization
- Dependency vulnerabilities
- Security headers and configurations
- Secrets management
- Access control and permissions
- Audit logging and monitoring
- Compliance with security standards (OWASP Top 10)

**Metrics to Collect**:
- Critical/High/Medium/Low vulnerability count
- Outdated security-related dependencies
- Missing security headers count
- Hardcoded secrets found
- Endpoints without authentication
- Failed security scan count
- Time since last security audit
- Compliance gaps (GDPR, HIPAA, SOC2 as applicable)

**Scoring Criteria** (0-10):
- **10**: Zero vulnerabilities, security best practices throughout, regular audits
- **8-9**: Minor issues only, strong security posture, proactive monitoring
- **6-7**: Some gaps, no critical issues, improvements needed
- **4-5**: Notable vulnerabilities, security gaps, action required
- **2-3**: Critical vulnerabilities, major gaps, urgent remediation needed
- **0-1**: Severe security issues, imminent risk, immediate action required

**Issues to Identify**:
- Critical/High severity CVEs in dependencies
- Missing authentication on sensitive endpoints
- Hardcoded credentials or API keys
- SQL injection vulnerabilities
- XSS vulnerabilities
- Missing CSRF protection
- Insufficient input validation
- Weak password policies
- Missing encryption for sensitive data
- Overly permissive access controls

#### Dimension 3: Performance

**Assessment Areas**:
- API response times
- Database query performance
- Frontend load times and Web Vitals
- Resource utilization (CPU, memory, I/O)
- Caching effectiveness
- Network latency and optimization
- Bottleneck identification

**Metrics to Collect**:
- API response time (p50, p95, p99)
- Database query time (average, p95)
- Page load time
- Time to First Byte (TTFB)
- First Contentful Paint (FCP)
- Largest Contentful Paint (LCP)
- Time to Interactive (TTI)
- CPU utilization (average, peak)
- Memory utilization (average, peak)
- Cache hit rate
- Slow query count (> 100ms)
- Bundle size (JS, CSS)

**Scoring Criteria** (0-10):
- **10**: Exceptional performance, p95 < 100ms, Lighthouse score > 95
- **8-9**: Excellent performance, p95 < 200ms, minor optimization opportunities
- **6-7**: Good performance, p95 < 500ms, some bottlenecks identified
- **4-5**: Acceptable performance, p95 < 1s, notable improvements needed
- **2-3**: Poor performance, p95 > 1s, significant bottlenecks
- **0-1**: Unacceptable performance, frequent timeouts, critical issues

**Issues to Identify**:
- API endpoints with p95 > 500ms
- Database queries > 100ms
- N+1 query patterns
- Missing database indexes
- Large bundle sizes (> 500KB)
- Unoptimized images
- Lack of caching
- Synchronous blocking operations
- Memory leaks
- CPU-intensive operations on main thread

#### Dimension 4: Scalability

**Assessment Areas**:
- Horizontal scaling capability
- Stateless design principles
- Database scaling strategy
- Caching architecture
- Load balancing and distribution
- Auto-scaling configuration
- Resource limits and bottlenecks
- Geographic distribution capability

**Metrics to Collect**:
- Current concurrent user capacity
- Maximum requests per second
- Database connection pool utilization
- Cache memory utilization
- Auto-scaling trigger points and effectiveness
- Time to scale up/down
- Cost per user/transaction
- Geographic latency measurements

**Scoring Criteria** (0-10):
- **10**: Proven at scale, linear scaling, multi-region, excellent architecture
- **8-9**: Scales well, some limits identified, minimal refactoring needed
- **6-7**: Moderate scalability, known bottlenecks, improvements planned
- **4-5**: Limited scalability, approaching capacity, refactoring required
- **2-3**: Poor scalability, frequent capacity issues, major work needed
- **0-1**: Cannot scale, constant capacity problems, architectural redesign needed

**Issues to Identify**:
- Stateful services blocking horizontal scaling
- Database as single point of failure
- No read replica configuration
- Missing connection pooling
- No caching layer
- Hard-coded resource limits
- No auto-scaling configuration
- Single-threaded bottlenecks
- Shared state preventing distribution
- No sharding strategy for large datasets

#### Dimension 5: Maintainability

**Assessment Areas**:
- Code organization and structure
- Test coverage and quality
- Documentation completeness
- Development workflow efficiency
- Deployment frequency and success rate
- Debugging and troubleshooting ease
- Knowledge distribution across team
- Onboarding time for new developers

**Metrics to Collect**:
- Test coverage percentage
- Test execution time
- Cyclomatic complexity (average, max)
- Code duplication percentage
- Documentation pages/sections
- Time to deploy
- Deployment success rate
- Mean time to recovery (MTTR)
- Time to onboard new developer
- Number of known issues/bugs
- Average time to resolve bugs

**Scoring Criteria** (0-10):
- **10**: Excellent maintainability, comprehensive tests/docs, fast iterations
- **8-9**: Highly maintainable, good practices, minor improvements possible
- **6-7**: Maintainable, some technical debt, manageable complexity
- **4-5**: Moderate maintainability, growing complexity, refactoring needed
- **2-3**: Poor maintainability, high complexity, difficult to change
- **0-1**: Unmaintainable, cannot safely make changes, requires rewrite

**Issues to Identify**:
- Test coverage < 70%
- Functions with cyclomatic complexity > 10
- Code duplication > 5%
- Missing API documentation
- No architecture diagrams
- Inconsistent coding standards
- Long deployment times (> 30 minutes)
- Deployment failure rate > 5%
- Long MTTR (> 4 hours)
- Tribal knowledge (single person knows critical systems)

#### Dimension 6: Cost Efficiency

**Assessment Areas**:
- Infrastructure cost optimization
- Resource utilization efficiency
- Over-provisioning identification
- Cost per user/transaction
- Serverless vs server cost analysis
- Database cost optimization
- Storage cost efficiency
- Monitoring and tooling costs

**Metrics to Collect**:
- Total monthly infrastructure cost
- Cost per user
- Cost per transaction
- Resource utilization rates (CPU, memory, storage)
- Idle resource costs
- Data transfer costs
- Third-party service costs
- Cost growth rate vs user growth rate

**Scoring Criteria** (0-10):
- **10**: Highly optimized, minimal waste, excellent cost/value ratio
- **8-9**: Well optimized, minor savings possible, good efficiency
- **6-7**: Reasonable costs, optimization opportunities identified
- **4-5**: Higher than optimal, notable waste, improvements needed
- **2-3**: Excessive costs, significant waste, urgent optimization required
- **0-1**: Unsustainable costs, severe waste, immediate action critical

**Issues to Identify**:
- Resources with < 30% utilization
- Over-provisioned databases
- Expensive queries/operations
- Inefficient data storage
- Unnecessary data retention
- Lack of resource right-sizing
- Missing reserved instance opportunities
- High data transfer costs
- Expensive third-party services
- Lack of cost monitoring/alerting

### Phase 3: Comparative Analysis

If baseline is available, compare current vs baseline:

1. **Score Comparison**:
   - Calculate score change for each dimension
   - Identify improvements (score increased)
   - Identify regressions (score decreased)
   - Calculate overall trend

2. **Issue Tracking**:
   - Match current issues to baseline issues
   - Identify resolved issues
   - Identify new issues
   - Track issue aging (how long unresolved)

3. **Recommendation Progress**:
   - Review baseline recommendations
   - Assess implementation status
   - Measure impact of implemented recommendations
   - Identify unaddressed recommendations

4. **Trend Analysis**:
   - Multi-assessment trend if multiple baselines exist
   - Velocity of improvement/degradation
   - Projected future state
   - Risk trajectory

**Trend Indicators**:
- ↑↑ Rapid improvement (> 2 points increase)
- ↑ Steady improvement (0.5-2 points increase)
- → Stable (< 0.5 points change)
- ↓ Degradation (-0.5 to -2 points decrease)
- ↓↓ Rapid degradation (> 2 points decrease)

### Phase 4: Recommendations and Roadmap

Generate prioritized recommendations:

1. **Quick Wins** (High Impact, Low Effort):
   - Issues fixable in < 1 week
   - Significant improvement to scores
   - Low risk changes

2. **Critical Fixes** (High Impact, Any Effort):
   - Security vulnerabilities
   - Performance bottlenecks affecting users
   - Scalability blockers
   - High-severity issues

3. **Strategic Improvements** (High Impact, High Effort):
   - Architectural refactoring
   - Major technology upgrades
   - Comprehensive test suite development
   - Large-scale optimization

4. **Technical Debt Paydown** (Medium Impact, Variable Effort):
   - Code quality improvements
   - Documentation updates
   - Dependency updates
   - Complexity reduction

5. **Future-Proofing** (Future Impact, Planning Required):
   - Capacity planning
   - Architecture evolution
   - Technology modernization
   - Team skill development

**Roadmap Timeline**:
- **Immediate (This Sprint)**: Critical fixes and quick wins
- **Short-Term (1-3 Months)**: Important improvements and security fixes
- **Medium-Term (3-6 Months)**: Strategic improvements and debt paydown
- **Long-Term (6-12 Months)**: Major refactoring and future-proofing

## Output Format

Provide a comprehensive architecture health assessment report:

```markdown
# Architecture Health Assessment

**Assessment Date**: [YYYY-MM-DD]
**Scope**: [System / Service / Component Name]
**Focus**: [All Dimensions / Specific Dimension]
**Baseline**: [Baseline Reference or "Initial Assessment"]
**Assessor**: 10x-fullstack-engineer agent

## Executive Summary

[2-3 paragraph summary of overall architecture health, key findings, trends, and critical recommendations]

**Overall Health Score**: [X.X]/10 ([Trend])

**Key Findings**:
- [Most significant finding 1]
- [Most significant finding 2]
- [Most significant finding 3]

**Critical Actions Required**:
1. [Top priority action with timeline]
2. [Second priority action with timeline]
3. [Third priority action with timeline]

**Health Trend**: [Improving / Stable / Degrading] ([Explanation])

## Architecture Health Scorecard

### Summary Scores

| Dimension | Score | Change | Trend | Status |
|-----------|-------|--------|-------|--------|
| Technical Debt | [X.X]/10 | [±X.X] | [↑↓→] | [Critical/Poor/Fair/Good/Excellent] |
| Security | [X.X]/10 | [±X.X] | [↑↓→] | [Critical/Poor/Fair/Good/Excellent] |
| Performance | [X.X]/10 | [±X.X] | [↑↓→] | [Critical/Poor/Fair/Good/Excellent] |
| Scalability | [X.X]/10 | [±X.X] | [↑↓→] | [Critical/Poor/Fair/Good/Excellent] |
| Maintainability | [X.X]/10 | [±X.X] | [↑↓→] | [Critical/Poor/Fair/Good/Excellent] |
| Cost Efficiency | [X.X]/10 | [±X.X] | [↑↓→] | [Critical/Poor/Fair/Good/Excellent] |
| **Overall** | **[X.X]/10** | **[±X.X]** | **[↑↓→]** | **[Status]** |

**Status Legend**:
- Excellent (9-10): Best practices, minimal improvements needed
- Good (7-8): Solid foundation, minor enhancements possible
- Fair (5-6): Acceptable but improvements needed
- Poor (3-4): Significant issues, action required
- Critical (0-2): Severe problems, urgent action needed

**Change** is compared to baseline: [Baseline Reference]

### Score Visualization

```
Technical Debt    [████████░░] 8.0/10  ↑ (+0.5)
Security          [██████░░░░] 6.0/10  → (0.0)
Performance       [███████░░░] 7.0/10  ↑ (+1.0)
Scalability       [█████░░░░░] 5.0/10  ↓ (-0.5)
Maintainability   [████████░░] 8.0/10  ↑ (+1.5)
Cost Efficiency   [██████░░░░] 6.0/10  → (+0.2)
                  ─────────────────────────────
Overall           [██████░░░░] 6.7/10  ↑ (+0.5)
```

## Dimension 1: Technical Debt ([X.X]/10)

### Summary
[Brief assessment of technical debt state]

**Trend**: [Trend symbol and explanation]

### Key Metrics

| Metric | Current | Baseline | Target | Status |
|--------|---------|----------|--------|--------|
| Code Complexity (avg) | [X.X] | [X.X] | < 5 | [✅/⚠️/❌] |
| Code Duplication | [X]% | [X]% | < 3% | [✅/⚠️/❌] |
| Test Coverage | [X]% | [X]% | > 80% | [✅/⚠️/❌] |
| Outdated Dependencies | [X] | [X] | 0 | [✅/⚠️/❌] |
| TODO Comments | [X] | [X] | < 20 | [✅/⚠️/❌] |

### Issues Identified

**Critical Issues** (affecting score significantly):
1. **[Issue Name]**
   - **Location**: [Component/file]
   - **Impact**: [Description of impact]
   - **Effort**: [Estimate]
   - **Priority**: [High/Medium/Low]

**Notable Issues**:
- [Issue description with severity]
- [Issue description with severity]

### Recommendations
1. [Top recommendation with expected improvement]
2. [Second recommendation]
3. [Third recommendation]

## Dimension 2: Security ([X.X]/10)

### Summary
[Brief security assessment]

**Trend**: [Trend symbol and explanation]

### Key Metrics

| Metric | Current | Baseline | Target | Status |
|--------|---------|----------|--------|--------|
| Critical Vulnerabilities | [X] | [X] | 0 | [✅/⚠️/❌] |
| High Vulnerabilities | [X] | [X] | 0 | [✅/⚠️/❌] |
| Medium Vulnerabilities | [X] | [X] | < 5 | [✅/⚠️/❌] |
| Hardcoded Secrets | [X] | [X] | 0 | [✅/⚠️/❌] |
| Unprotected Endpoints | [X] | [X] | 0 | [✅/⚠️/❌] |
| Days Since Security Audit | [X] | [X] | < 90 | [✅/⚠️/❌] |

### Security Posture

**OWASP Top 10 Compliance**:
- A01: Broken Access Control: [✅/⚠️/❌] [Notes]
- A02: Cryptographic Failures: [✅/⚠️/❌] [Notes]
- A03: Injection: [✅/⚠️/❌] [Notes]
- A04: Insecure Design: [✅/⚠️/❌] [Notes]
- A05: Security Misconfiguration: [✅/⚠️/❌] [Notes]
- A06: Vulnerable Components: [✅/⚠️/❌] [Notes]
- A07: Authentication Failures: [✅/⚠️/❌] [Notes]
- A08: Data Integrity Failures: [✅/⚠️/❌] [Notes]
- A09: Logging Failures: [✅/⚠️/❌] [Notes]
- A10: SSRF: [✅/⚠️/❌] [Notes]

### Critical Security Issues

1. **[Vulnerability Name]**
   - **Severity**: Critical/High/Medium
   - **Location**: [Where found]
   - **CVE**: [If applicable]
   - **Exploit Risk**: [Assessment]
   - **Remediation**: [How to fix]
   - **Effort**: [Estimate]

### Recommendations
1. [Critical security recommendation]
2. [Important security recommendation]
3. [Security hardening recommendation]

## Dimension 3: Performance ([X.X]/10)

### Summary
[Brief performance assessment]

**Trend**: [Trend symbol and explanation]

### Key Metrics

| Metric | Current | Baseline | Target | Status |
|--------|---------|----------|--------|--------|
| API Response (p50) | [X]ms | [X]ms | < 100ms | [✅/⚠️/❌] |
| API Response (p95) | [X]ms | [X]ms | < 200ms | [✅/⚠️/❌] |
| API Response (p99) | [X]ms | [X]ms | < 500ms | [✅/⚠️/❌] |
| DB Query Time (avg) | [X]ms | [X]ms | < 50ms | [✅/⚠️/❌] |
| Page Load Time | [X]s | [X]s | < 2s | [✅/⚠️/❌] |
| LCP | [X]s | [X]s | < 2.5s | [✅/⚠️/❌] |
| FCP | [X]s | [X]s | < 1.5s | [✅/⚠️/❌] |
| Bundle Size | [X]KB | [X]KB | < 300KB | [✅/⚠️/❌] |

### Performance Bottlenecks

1. **[Bottleneck Description]**
   - **Impact**: [User experience / throughput impact]
   - **Current Performance**: [Measurement]
   - **Target Performance**: [Goal]
   - **Root Cause**: [Analysis]
   - **Solution**: [Optimization approach]
   - **Expected Improvement**: [Estimate]
   - **Effort**: [Estimate]

### Slow Operations

Top 10 slowest operations:
1. [Operation]: [Time] - [Frequency] - [Impact]
2. [Operation]: [Time] - [Frequency] - [Impact]
[...]

### Recommendations
1. [Performance optimization with highest impact]
2. [Second optimization]
3. [Third optimization]

## Dimension 4: Scalability ([X.X]/10)

### Summary
[Brief scalability assessment]

**Trend**: [Trend symbol and explanation]

### Key Metrics

| Metric | Current | Baseline | Target | Status |
|--------|---------|----------|--------|--------|
| Concurrent Users | [X] | [X] | [X] | [✅/⚠️/❌] |
| Requests/Second | [X] | [X] | [X] | [✅/⚠️/❌] |
| DB Connections Used | [X]% | [X]% | < 70% | [✅/⚠️/❌] |
| Cache Hit Rate | [X]% | [X]% | > 80% | [✅/⚠️/❌] |
| Auto-scaling Effectiveness | [X]% | [X]% | > 90% | [✅/⚠️/❌] |
| Cost per User | $[X] | $[X] | < $[X] | [✅/⚠️/❌] |

### Scalability Limits

**Current Capacity**:
- Maximum concurrent users: [X] (utilization: [X]%)
- Maximum requests/second: [X] (utilization: [X]%)
- Database capacity: [X]% utilized

**Scaling Bottlenecks**:
1. **[Bottleneck Name]**
   - **Current Limit**: [What breaks and when]
   - **Impact**: [Failure mode]
   - **Solution**: [How to scale past this]
   - **Effort**: [Estimate]

### Scalability Readiness

- ✅ Stateless application design
- ✅ Horizontal auto-scaling configured
- ❌ Database read replicas not configured
- ❌ No caching layer
- ⚠️ Limited connection pooling
- ✅ CDN for static assets

### Recommendations
1. [Top scalability improvement]
2. [Second scalability improvement]
3. [Third scalability improvement]

## Dimension 5: Maintainability ([X.X]/10)

### Summary
[Brief maintainability assessment]

**Trend**: [Trend symbol and explanation]

### Key Metrics

| Metric | Current | Baseline | Target | Status |
|--------|---------|----------|--------|--------|
| Test Coverage | [X]% | [X]% | > 80% | [✅/⚠️/❌] |
| Cyclomatic Complexity (avg) | [X.X] | [X.X] | < 5 | [✅/⚠️/❌] |
| Code Duplication | [X]% | [X]% | < 3% | [✅/⚠️/❌] |
| Deployment Success Rate | [X]% | [X]% | > 95% | [✅/⚠️/❌] |
| MTTR | [X]h | [X]h | < 2h | [✅/⚠️/❌] |
| Time to Deploy | [X]min | [X]min | < 15min | [✅/⚠️/❌] |
| Onboarding Time | [X]days | [X]days | < 7days | [✅/⚠️/❌] |

### Code Quality Issues

**High Complexity Components**:
1. [Component]: Complexity [X] (target: < 10)
2. [Component]: Complexity [X]
3. [Component]: Complexity [X]

**Code Duplication Hotspots**:
- [Location]: [X]% duplication
- [Location]: [X]% duplication

**Testing Gaps**:
- [Component]: [X]% coverage (below target)
- [Component]: No integration tests
- [Component]: No E2E tests

### Recommendations
1. [Maintainability improvement with highest impact]
2. [Second improvement]
3. [Third improvement]

## Dimension 6: Cost Efficiency ([X.X]/10)

### Summary
[Brief cost efficiency assessment]

**Trend**: [Trend symbol and explanation]

### Key Metrics

| Metric | Current | Baseline | Target | Status |
|--------|---------|----------|--------|--------|
| Monthly Infrastructure Cost | $[X] | $[X] | $[X] | [✅/⚠️/❌] |
| Cost per User | $[X] | $[X] | < $[X] | [✅/⚠️/❌] |
| Cost per Transaction | $[X] | $[X] | < $[X] | [✅/⚠️/❌] |
| CPU Utilization | [X]% | [X]% | 60-80% | [✅/⚠️/❌] |
| Memory Utilization | [X]% | [X]% | 60-80% | [✅/⚠️/❌] |
| Storage Utilization | [X]% | [X]% | < 80% | [✅/⚠️/❌] |
| Cost Growth Rate | [X]% | [X]% | < User Growth | [✅/⚠️/❌] |

### Cost Breakdown

| Category | Monthly Cost | % of Total | Trend |
|----------|--------------|------------|-------|
| Compute | $[X] | [X]% | [↑↓→] |
| Database | $[X] | [X]% | [↑↓→] |
| Storage | $[X] | [X]% | [↑↓→] |
| Network/CDN | $[X] | [X]% | [↑↓→] |
| Third-party Services | $[X] | [X]% | [↑↓→] |
| Monitoring/Tools | $[X] | [X]% | [↑↓→] |
| **Total** | **$[X]** | **100%** | **[↑↓→]** |

### Cost Optimization Opportunities

1. **[Optimization Opportunity]**
   - **Current Cost**: $[X]/month
   - **Potential Savings**: $[X]/month ([X]%)
   - **Approach**: [How to optimize]
   - **Risk**: [Low/Medium/High]
   - **Effort**: [Estimate]

### Waste Identified

- **Idle Resources**: $[X]/month
- **Over-provisioned Resources**: $[X]/month
- **Unnecessary Services**: $[X]/month
- **Inefficient Operations**: $[X]/month
- **Total Potential Savings**: $[X]/month ([X]% of total)

### Recommendations
1. [Cost optimization with highest ROI]
2. [Second optimization]
3. [Third optimization]

## Trend Analysis

[If multiple assessments exist, show historical trend]

### Score History

| Date | Overall | Tech Debt | Security | Performance | Scalability | Maintainability | Cost |
|------|---------|-----------|----------|-------------|-------------|-----------------|------|
| [Date] | [X.X] | [X.X] | [X.X] | [X.X] | [X.X] | [X.X] | [X.X] |
| [Date] | [X.X] | [X.X] | [X.X] | [X.X] | [X.X] | [X.X] | [X.X] |
| [Date] | [X.X] | [X.X] | [X.X] | [X.X] | [X.X] | [X.X] | [X.X] |

### Trend Visualization

```
Overall Score Trend
10 ┤
9  ┤
8  ┤      ●───●
7  ┤     ╱     ╲
6  ┤    ●       ●───●
5  ┤   ╱             ╲
4  ┤  ●               ●
3  ┤
   └────────────────────────────────────────
   Q1   Q2   Q3   Q4   Q1   Q2   Q3   Q4
```

### Velocity of Change

- **Improving**: [List dimensions improving and rate]
- **Stable**: [List stable dimensions]
- **Degrading**: [List degrading dimensions and rate]

### Projected Future State

Based on current trends, in 6 months:
- Overall Score: [X.X]/10 (projected)
- Key Risks: [Risks if trends continue]
- Key Opportunities: [Opportunities if improvements continue]

## Issue Tracking

### Resolved Since Last Assessment

✅ [Issue description] - Resolved on [date]
✅ [Issue description] - Resolved on [date]
✅ [Issue description] - Resolved on [date]

### Persistent Issues

⚠️ [Issue description] - Open for [X] days
⚠️ [Issue description] - Open for [X] days
⚠️ [Issue description] - Open for [X] days

### New Issues Identified

🆕 [Issue description] - [Severity]
🆕 [Issue description] - [Severity]
🆕 [Issue description] - [Severity]

## Recommendation Implementation Status

### From Previous Assessment

| Recommendation | Status | Impact | Notes |
|----------------|--------|--------|-------|
| [Rec 1] | ✅ Completed | [Positive/Negative/Neutral] | [Outcome] |
| [Rec 2] | 🔄 In Progress | [Expected impact] | [Progress notes] |
| [Rec 3] | ❌ Not Started | [Why not started] | [Plan] |

## Prioritized Recommendations

### Immediate Actions (This Sprint)

**Priority**: CRITICAL - Must address immediately

1. **[Action Item]**
   - **Dimension**: [Affected dimension]
   - **Current Score Impact**: [X.X points]
   - **Effort**: [Time estimate]
   - **Risk if Not Addressed**: [Description]
   - **Expected Improvement**: [Score increase expected]

### Quick Wins (Next 2-4 Weeks)

**Priority**: HIGH - High impact, low effort

1. **[Action Item]**
   - **Dimension**: [Affected dimension]
   - **Impact**: [Benefit description]
   - **Effort**: [Time estimate]
   - **Expected Improvement**: [Score increase]

### Important Improvements (1-3 Months)

**Priority**: HIGH - Significant value, moderate effort

1. **[Action Item]**
   - **Dimension**: [Affected dimension]
   - **Impact**: [Benefit description]
   - **Effort**: [Time estimate]
   - **Dependencies**: [Prerequisites]
   - **Expected Improvement**: [Score increase]

### Strategic Initiatives (3-6 Months)

**Priority**: MEDIUM - Long-term value, high effort

1. **[Action Item]**
   - **Dimension**: [Affected dimension]
   - **Impact**: [Strategic benefit]
   - **Effort**: [Time estimate]
   - **ROI**: [Return on investment]
   - **Expected Improvement**: [Score increase]

### Ongoing Maintenance

**Priority**: CONTINUOUS - Regular activities

1. [Maintenance activity with frequency]
2. [Maintenance activity with frequency]
3. [Maintenance activity with frequency]

## Implementation Roadmap

### Sprint Planning

**Current Sprint**:
- [ ] [Critical action 1]
- [ ] [Critical action 2]
- [ ] [Quick win 1]
- [ ] [Quick win 2]

**Next Sprint**:
- [ ] [Quick win 3]
- [ ] [Quick win 4]
- [ ] [Important improvement 1]

**Following Sprints** (prioritized backlog):
1. [Important improvement 2]
2. [Important improvement 3]
3. [Strategic initiative 1]
4. [Strategic initiative 2]

### Milestone Timeline

- **Month 1**: [Key deliverables]
  - Target overall score: [X.X]/10
  - Critical dimensions: [Focus areas]

- **Month 3**: [Key deliverables]
  - Target overall score: [X.X]/10
  - Expected improvements: [Areas of improvement]

- **Month 6**: [Key deliverables]
  - Target overall score: [X.X]/10
  - Strategic goals achieved: [List]

### Success Metrics

Track progress with these metrics:
- Overall health score: [Current] → [Target in 6mo]
- [Specific dimension]: [Current] → [Target]
- [Critical metric]: [Current] → [Target]
- [Business metric]: [Current] → [Target]

## Risk Assessment

### Risks If Recommendations Not Implemented

1. **[Risk Description]**
   - **Likelihood**: High/Medium/Low
   - **Impact**: Critical/High/Medium/Low
   - **Timeline**: [When risk materializes]
   - **Mitigation**: [If we do nothing, what's the fallback]

### Risks in Implementing Recommendations

1. **[Risk Description]**
   - **Likelihood**: High/Medium/Low
   - **Impact**: [Potential negative impact]
   - **Mitigation Strategy**: [How to manage risk]

## Conclusion

[Summary paragraph on overall architecture health state]

**Overall Assessment**: [Narrative assessment with trend context]

**Critical Success Factors for Improvement**:
1. [What needs to happen for health improvement]
2. [Key factor 2]
3. [Key factor 3]

**Next Assessment**: Recommended in [timeframe] to track progress

**Immediate Next Steps**:
1. [First action to take]
2. [Second action to take]
3. [Third action to take]

## Appendices

### Appendix A: Detailed Metrics
[Raw data and detailed measurements]

### Appendix B: Comparison to Industry Benchmarks
[How this architecture compares to similar systems]

### Appendix C: Methodology
[How assessment was conducted, tools used]

### Appendix D: References
- [Related ADRs]
- [Previous assessments]
- [Industry standards referenced]
- [Tools and frameworks used]
```

## Assessment Storage

Save the assessment document:

1. **Ensure Directory Exists**: Create `docs/assessments/` if needed
2. **Generate File Name**: `architecture-assessment-YYYY-MM-DD.md`
3. **Write File**: Save complete assessment
4. **Update Index**: Update `docs/assessments/README.md` with new assessment entry

## Agent Invocation

This operation MUST invoke the **10x-fullstack-engineer** agent for expert architecture assessment.

**Agent context to provide**:
- Assessment scope and focus
- Baseline comparison if available
- Collected metrics and measurements
- Identified issues across dimensions
- Current architecture state

**Agent responsibilities**:
- Apply 15+ years of architectural assessment experience
- Provide industry benchmark comparisons
- Identify subtle issues and patterns
- Score dimensions accurately and consistently
- Generate actionable, prioritized recommendations
- Assess trends and project future state
- Consider business context in recommendations

**Agent invocation approach**:
Present comprehensive assessment data and explicitly request:
"Using your 15+ years of full-stack architecture experience, assess this system's architecture health across all dimensions. Score each dimension 0-10, identify critical issues, analyze trends if baseline exists, and provide prioritized recommendations for improvement. Consider both technical excellence and business value."

## Error Handling

### Invalid Scope
```
Error: Invalid scope: [scope]

Valid scopes:
- system      Entire architecture (default)
- service     Specific service or microservice
- component   Specific component or module

Example: /architect assess scope:"system"
```

### Invalid Focus
```
Error: Invalid focus: [focus]

Valid focus dimensions:
- all              All dimensions (default)
- tech-debt        Technical debt assessment only
- security         Security assessment only
- performance      Performance assessment only
- scalability      Scalability assessment only
- maintainability  Maintainability assessment only
- cost             Cost efficiency assessment only

Example: /architect assess focus:"security"
```

### Baseline Not Found
```
Error: Baseline not found: [baseline]

Could not find assessment for baseline: [baseline]

Available baselines:
- [Date 1]: architecture-assessment-YYYY-MM-DD.md
- [Date 2]: architecture-assessment-YYYY-MM-DD.md

Or omit baseline for initial assessment.
```

### No Metrics Available
```
Warning: Limited metrics available for comprehensive assessment.

To improve assessment quality, consider:
- Setting up application monitoring (APM)
- Enabling performance profiling
- Running security scans
- Collecting usage metrics
- Implementing logging and tracing

Proceeding with code-based assessment only.
```

## Examples

**Example 1 - Initial Comprehensive Assessment**:
```
/architect assess
```
Full system assessment across all dimensions, establishing baseline.

**Example 2 - Focused Security Assessment**:
```
/architect assess focus:"security"
```
Deep dive into security posture only.

**Example 3 - Comparison to Previous Assessment**:
```
/architect assess baseline:"previous"
```
Compare to most recent assessment, show trends and progress.

**Example 4 - Quarterly Review**:
```
/architect assess baseline:"2024-01-15"
```
Compare to Q1 assessment to track quarterly progress.

**Example 5 - Service-Specific Assessment**:
```
/architect assess scope:"service" focus:"performance"
```
Assess specific service's performance characteristics.

**Example 6 - Cost Optimization Focus**:
```
/architect assess focus:"cost" baseline:"previous"
```
Focus on cost efficiency, compare to previous to track savings.

**Example 7 - Technical Debt Review**:
```
/architect assess focus:"tech-debt"
```
Assess technical debt accumulation for planning debt paydown sprint.
