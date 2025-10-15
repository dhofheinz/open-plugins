# Performance Analysis Operation

You are executing the **analyze** operation to perform comprehensive performance analysis and identify bottlenecks across all application layers.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'analyze' operation name)

Expected format: `target:"area" [scope:"frontend|backend|database|infrastructure|all"] [metrics:"baseline|compare"] [baseline:"version-or-timestamp"]`

**Parameter definitions**:
- `target` (required): Application or component to analyze (e.g., "user dashboard", "checkout flow", "production app")
- `scope` (optional): Layer to focus on - `frontend`, `backend`, `database`, `infrastructure`, or `all` (default: `all`)
- `metrics` (optional): Metrics mode - `baseline` (establish baseline), `compare` (compare against baseline) (default: `baseline`)
- `baseline` (optional): Baseline version or timestamp for comparison (e.g., "v1.2.0", "2025-10-01")

## Workflow

### 1. Define Analysis Scope

Based on the `target` and `scope` parameters, determine what to analyze:

**Scope: all** (comprehensive analysis):
- Frontend: Page load, rendering, bundle size
- Backend: API response times, throughput, error rates
- Database: Query performance, connection pools, cache hit rates
- Infrastructure: Resource utilization, scaling efficiency

**Scope: frontend**:
- Web Vitals (LCP, FID, CLS, INP, TTFB, FCP)
- Bundle sizes and composition
- Network waterfall analysis
- Runtime performance (memory, CPU)

**Scope: backend**:
- API endpoint response times (p50, p95, p99)
- Throughput and concurrency handling
- Error rates and types
- Dependency latency (database, external APIs)

**Scope: database**:
- Query execution times
- Index effectiveness
- Connection pool utilization
- Cache hit rates

**Scope: infrastructure**:
- CPU, memory, disk, network utilization
- Container/instance metrics
- Auto-scaling behavior
- CDN effectiveness

### 2. Establish Baseline Metrics

Run comprehensive performance profiling:

**Frontend Profiling**:
```bash
# Lighthouse audit
npx lighthouse [url] --output=json --output-path=./perf-baseline-lighthouse.json

# Bundle analysis
npm run build -- --stats
npx webpack-bundle-analyzer dist/stats.json --mode static --report ./perf-baseline-bundle.html

# Check for unused dependencies
npx depcheck > ./perf-baseline-deps.txt

# Runtime profiling (if applicable)
# Use browser DevTools Performance tab
```

**Backend Profiling**:
```bash
# API response times (if monitoring exists)
# Check APM dashboard or logs

# Profile Node.js application
node --prof app.js
# Then process the profile
node --prof-process isolate-*.log > perf-baseline-profile.txt

# Memory snapshot
node --inspect app.js
# Take heap snapshot via Chrome DevTools

# Load test to get baseline throughput
npx k6 run --duration 60s --vus 50 load-test.js
```

**Database Profiling**:
```sql
-- PostgreSQL: Enable pg_stat_statements
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Capture slow queries
SELECT
  query,
  calls,
  total_exec_time,
  mean_exec_time,
  max_exec_time,
  stddev_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 50;

-- Check index usage
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

-- Table statistics
SELECT
  schemaname,
  tablename,
  n_live_tup,
  n_dead_tup,
  last_vacuum,
  last_autovacuum
FROM pg_stat_user_tables;
```

**Infrastructure Profiling**:
```bash
# Container metrics (if using Docker/Kubernetes)
docker stats --no-stream

# Or for Kubernetes
kubectl top nodes
kubectl top pods

# Server resource utilization
top -b -n 1 | head -20
free -h
df -h
iostat -x 1 5
```

### 3. Identify Bottlenecks

Analyze collected metrics to identify performance bottlenecks:

**Bottleneck Detection Matrix**:

| Layer | Indicator | Severity | Common Causes |
|-------|-----------|----------|---------------|
| **Frontend** | LCP > 2.5s | High | Large images, render-blocking resources, slow TTFB |
| **Frontend** | Bundle > 1MB | Medium | Unused dependencies, no code splitting, large libraries |
| **Frontend** | CLS > 0.1 | Medium | Missing dimensions, dynamic content injection |
| **Frontend** | INP > 200ms | High | Long tasks, unoptimized event handlers |
| **Backend** | p95 > 1000ms | High | Slow queries, N+1 problems, synchronous I/O |
| **Backend** | p99 > 5000ms | Critical | Database locks, resource exhaustion, cascading failures |
| **Backend** | Error rate > 1% | High | Unhandled errors, timeout issues, dependency failures |
| **Database** | Query > 500ms | High | Missing indexes, full table scans, complex joins |
| **Database** | Cache hit < 80% | Medium | Insufficient cache size, poor cache strategy |
| **Database** | Connection pool exhaustion | Critical | Connection leaks, insufficient pool size |
| **Infrastructure** | CPU > 80% | High | Insufficient resources, inefficient algorithms |
| **Infrastructure** | Memory > 90% | Critical | Memory leaks, oversized caches, insufficient resources |

**Prioritization Framework**:

1. **Critical** - Immediate impact on user experience or system stability
2. **High** - Significant performance degradation
3. **Medium** - Noticeable but not blocking
4. **Low** - Minor optimization opportunity

### 4. Create Optimization Opportunity Matrix

For each identified bottleneck, assess:

**Impact Assessment**:
- Performance improvement potential (low/medium/high)
- Implementation effort (hours/days)
- Risk level (low/medium/high)
- Dependencies on other optimizations

**Optimization Opportunities**:

```markdown
## Opportunity Matrix

| ID | Layer | Issue | Impact | Effort | Priority | Recommendation |
|----|-------|-------|--------|--------|----------|----------------|
| 1 | Database | Missing index on users.email | High | 1h | Critical | Add index immediately |
| 2 | Frontend | Bundle size 2.5MB | High | 4h | High | Implement code splitting |
| 3 | Backend | N+1 query in /api/users | High | 2h | High | Add eager loading |
| 4 | Infrastructure | No CDN for static assets | Medium | 3h | Medium | Configure CloudFront |
| 5 | Frontend | Unoptimized images | Medium | 2h | Medium | Add next/image or similar |
```

### 5. Generate Performance Profile

Create a comprehensive performance profile:

**Performance Snapshot**:
```json
{
  "timestamp": "2025-10-14T12:00:00Z",
  "version": "v1.2.3",
  "environment": "production",
  "metrics": {
    "frontend": {
      "lcp": 3200,
      "fid": 150,
      "cls": 0.15,
      "ttfb": 800,
      "bundle_size": 2500000
    },
    "backend": {
      "p50_response_time": 120,
      "p95_response_time": 850,
      "p99_response_time": 2100,
      "throughput_rps": 450,
      "error_rate": 0.02
    },
    "database": {
      "avg_query_time": 45,
      "slow_query_count": 23,
      "cache_hit_rate": 0.72,
      "connection_pool_utilization": 0.85
    },
    "infrastructure": {
      "cpu_utilization": 0.68,
      "memory_utilization": 0.75,
      "disk_io_wait": 0.03
    }
  },
  "bottlenecks": [
    {
      "id": "BTL001",
      "layer": "frontend",
      "severity": "high",
      "issue": "Large LCP time",
      "metric": "lcp",
      "value": 3200,
      "threshold": 2500,
      "impact": "Poor user experience on initial page load"
    }
  ]
}
```

### 6. Recommend Next Steps

Based on analysis results, recommend:

**Immediate Actions** (Critical bottlenecks):
- List specific optimizations with highest ROI
- Estimated improvement for each
- Implementation order

**Short-term Actions** (High priority):
- Optimizations to tackle in current sprint
- Potential dependencies

**Long-term Actions** (Medium/Low priority):
- Architectural improvements
- Infrastructure upgrades
- Technical debt reduction

## Output Format

```markdown
# Performance Analysis Report: [Target]

**Analysis Date**: [Date and time]
**Analyzed Version**: [Version or commit]
**Environment**: [production/staging/development]
**Scope**: [all/frontend/backend/database/infrastructure]

## Executive Summary

[2-3 paragraph summary of overall findings, critical issues, and recommended priorities]

## Baseline Metrics

### Frontend Performance
| Metric | Value | Status | Threshold |
|--------|-------|--------|-----------|
| LCP (Largest Contentful Paint) | 3.2s | ⚠️ Needs Improvement | < 2.5s |
| FID (First Input Delay) | 150ms | ✅ Good | < 100ms |
| CLS (Cumulative Layout Shift) | 0.15 | ⚠️ Needs Improvement | < 0.1 |
| TTFB (Time to First Byte) | 800ms | ⚠️ Needs Improvement | < 600ms |
| Bundle Size (gzipped) | 2.5MB | ❌ Poor | < 500KB |

### Backend Performance
| Metric | Value | Status | Threshold |
|--------|-------|--------|-----------|
| P50 Response Time | 120ms | ✅ Good | < 200ms |
| P95 Response Time | 850ms | ⚠️ Needs Improvement | < 500ms |
| P99 Response Time | 2100ms | ❌ Poor | < 1000ms |
| Throughput | 450 req/s | ✅ Good | > 400 req/s |
| Error Rate | 2% | ⚠️ Needs Improvement | < 1% |

### Database Performance
| Metric | Value | Status | Threshold |
|--------|-------|--------|-----------|
| Avg Query Time | 45ms | ✅ Good | < 100ms |
| Slow Query Count (>500ms) | 23 queries | ❌ Poor | 0 queries |
| Cache Hit Rate | 72% | ⚠️ Needs Improvement | > 85% |
| Connection Pool Utilization | 85% | ⚠️ Needs Improvement | < 75% |

### Infrastructure Performance
| Metric | Value | Status | Threshold |
|--------|-------|--------|-----------|
| CPU Utilization | 68% | ✅ Good | < 75% |
| Memory Utilization | 75% | ⚠️ Needs Improvement | < 70% |
| Disk I/O Wait | 3% | ✅ Good | < 5% |

## Bottlenecks Identified

### Critical Priority

#### BTL001: Frontend - Large LCP Time (3.2s)
**Impact**: High - Users experience slow initial page load
**Cause**:
- Large hero image (1.2MB) loaded synchronously
- Render-blocking CSS and JavaScript
- No image optimization

**Recommendation**:
1. Optimize and lazy-load hero image (reduce to <200KB)
2. Defer non-critical CSS/JS
3. Implement resource hints (preload critical assets)
**Expected Improvement**: LCP reduction to ~1.8s (44% improvement)

#### BTL002: Database - Missing Index on users.email
**Impact**: High - Slow user lookup queries affecting multiple endpoints
**Queries Affected**:
```sql
SELECT * FROM users WHERE email = $1;  -- 450ms avg
```
**Recommendation**:
```sql
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```
**Expected Improvement**: Query time reduction to <10ms (95% improvement)

### High Priority

#### BTL003: Backend - N+1 Query Problem in /api/users Endpoint
**Impact**: High - p95 response time of 850ms
**Cause**:
```javascript
// Current (N+1 problem)
const users = await User.findAll();
for (const user of users) {
  user.posts = await Post.findAll({ where: { userId: user.id } });
}
```
**Recommendation**:
```javascript
// Optimized (eager loading)
const users = await User.findAll({
  include: [{ model: Post, as: 'posts' }]
});
```
**Expected Improvement**: Response time reduction to ~200ms (75% improvement)

#### BTL004: Frontend - Bundle Size 2.5MB
**Impact**: High - Slow initial load especially on mobile
**Cause**:
- No code splitting
- Unused dependencies (moment.js, lodash full import)
- No tree shaking

**Recommendation**:
1. Implement code splitting by route
2. Replace moment.js with date-fns (92% smaller)
3. Use tree-shakeable imports
```javascript
// Before
import _ from 'lodash';
import moment from 'moment';

// After
import { debounce, throttle } from 'lodash-es';
import { format, parseISO } from 'date-fns';
```
**Expected Improvement**: Bundle reduction to ~800KB (68% improvement)

### Medium Priority

[Additional bottlenecks with similar format]

## Optimization Opportunity Matrix

| ID | Layer | Issue | Impact | Effort | Priority | Est. Improvement |
|----|-------|-------|--------|--------|----------|------------------|
| BTL001 | Frontend | Large LCP | High | 4h | Critical | 44% LCP reduction |
| BTL002 | Database | Missing index | High | 1h | Critical | 95% query speedup |
| BTL003 | Backend | N+1 queries | High | 2h | High | 75% response time reduction |
| BTL004 | Frontend | Bundle size | High | 6h | High | 68% bundle reduction |
| BTL005 | Infrastructure | No CDN | Medium | 3h | Medium | 30% TTFB reduction |
| BTL006 | Database | Low cache hit | Medium | 4h | Medium | 15% query improvement |

## Profiling Data

### Frontend Profiling Results
[Include relevant Lighthouse report summary, bundle analysis, etc.]

### Backend Profiling Results
[Include relevant API response time distribution, slow endpoint list, etc.]

### Database Profiling Results
[Include slow query details, table scan frequency, etc.]

### Infrastructure Profiling Results
[Include resource utilization charts, scaling behavior, etc.]

## Recommended Action Plan

### Phase 1: Critical Fixes (Immediate - 1-2 days)
1. **Add missing database indexes** (BTL002) - 1 hour
   - Estimated improvement: 95% reduction in user lookup queries
2. **Optimize hero image and implement lazy loading** (BTL001) - 4 hours
   - Estimated improvement: 44% LCP reduction

### Phase 2: High-Priority Optimizations (This week - 3-5 days)
1. **Fix N+1 query problems** (BTL003) - 2 hours
   - Estimated improvement: 75% response time reduction on affected endpoints
2. **Implement bundle optimization** (BTL004) - 6 hours
   - Estimated improvement: 68% bundle size reduction

### Phase 3: Infrastructure Improvements (Next sprint - 1-2 weeks)
1. **Configure CDN for static assets** (BTL005) - 3 hours
   - Estimated improvement: 30% TTFB reduction
2. **Optimize database caching strategy** (BTL006) - 4 hours
   - Estimated improvement: 15% overall query performance

## Expected Overall Impact

If all critical and high-priority optimizations are implemented:

| Metric | Current | Expected | Improvement |
|--------|---------|----------|-------------|
| LCP | 3.2s | 1.5s | 53% faster |
| Bundle Size | 2.5MB | 650KB | 74% smaller |
| P95 Response Time | 850ms | 250ms | 71% faster |
| User Lookup Query | 450ms | 8ms | 98% faster |
| Overall Performance Score | 62/100 | 88/100 | +26 points |

## Monitoring Recommendations

After implementing optimizations, monitor these key metrics:

**Frontend**:
- Real User Monitoring (RUM) for Web Vitals
- Bundle size in CI/CD pipeline
- Lighthouse CI for regression detection

**Backend**:
- APM for endpoint response times
- Error rate monitoring
- Database query performance

**Database**:
- Slow query log monitoring
- Index hit rate
- Connection pool metrics

**Infrastructure**:
- Resource utilization alerts
- Auto-scaling triggers
- CDN cache hit rates

## Testing Instructions

### Before Optimization
1. Run Lighthouse audit: `npx lighthouse [url] --output=json --output-path=baseline.json`
2. Capture API metrics: [specify how]
3. Profile database: [SQL queries above]
4. Save baseline for comparison

### After Optimization
1. Repeat all baseline measurements
2. Compare metrics using provided scripts
3. Verify no functionality regressions
4. Monitor for 24-48 hours in production

## Next Steps

1. Review and prioritize optimizations with team
2. Create tasks for Phase 1 critical fixes
3. Implement optimizations using `/optimize [layer]` operations
4. Benchmark improvements using `/optimize benchmark`
5. Document lessons learned and update performance budget
