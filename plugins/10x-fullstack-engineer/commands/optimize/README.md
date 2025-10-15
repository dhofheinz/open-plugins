# Optimize Skill

Comprehensive performance optimization across database, backend, frontend, and infrastructure layers for full-stack applications.

## Overview

The `/10x-fullstack-engineer:optimize` skill provides systematic performance optimization capabilities covering all layers of a modern web application. It identifies bottlenecks, implements optimizations, and measures improvements across:

- **Database**: Query optimization, indexing, connection pooling, caching
- **Backend**: API performance, algorithm efficiency, concurrency, caching
- **Frontend**: Bundle size, rendering, Web Vitals, asset optimization
- **Infrastructure**: Auto-scaling, CDN, resource allocation, cost efficiency
- **Benchmarking**: Load testing, rendering benchmarks, regression detection

## Available Operations

### 1. analyze
**Purpose**: Comprehensive performance analysis with bottleneck identification

Performs deep analysis across all application layers, establishes baseline metrics, and creates prioritized optimization opportunity matrix.

**Usage**:
```bash
/10x-fullstack-engineer:optimize analyze target:"production app" scope:all metrics:"baseline"
```

**Parameters**:
- `target` (required): Application or component to analyze (e.g., "user dashboard", "checkout flow")
- `scope` (optional): Layer focus - `frontend`, `backend`, `database`, `infrastructure`, or `all` (default: `all`)
- `metrics` (optional): Metrics mode - `baseline` or `compare` (default: `baseline`)
- `baseline` (optional): Baseline version for comparison (e.g., "v1.2.0")

**What it does**:
- Runs Lighthouse audits for frontend performance
- Profiles backend API response times
- Analyzes database slow queries and index usage
- Checks infrastructure resource utilization
- Identifies bottlenecks using detection matrix
- Creates prioritized optimization opportunity matrix
- Generates comprehensive performance profile

**Example Output**:
- Performance snapshot with metrics across all layers
- Bottleneck identification with severity ratings
- Optimization opportunity matrix with ROI estimates
- Recommended action plan with phases

---

### 2. database
**Purpose**: Database query and schema optimization

Optimizes slow queries, adds missing indexes, fixes N+1 problems, and improves connection pool configuration.

**Usage**:
```bash
/10x-fullstack-engineer:optimize database target:queries context:"slow SELECT statements" threshold:500ms
```

**Parameters**:
- `target` (required): What to optimize - `queries`, `schema`, `indexes`, `connections`, or `all`
- `context` (optional): Specific details (table names, query patterns)
- `threshold` (optional): Time threshold for slow queries in milliseconds (default: 500ms)
- `environment` (optional): Target environment (default: development)

**Key Optimizations**:
- **Query Analysis**: Identifies slow queries using pg_stat_statements, MySQL performance schema, or MongoDB profiler
- **Index Creation**: Adds missing indexes based on query patterns and table scans
- **N+1 Query Fixes**: Converts sequential queries to eager loading or joins
- **Connection Pooling**: Optimizes pool size and configuration
- **Query Caching**: Implements Redis or materialized views for frequently accessed data
- **Schema Optimization**: Denormalization, partitioning, column type optimization

**Example Results**:
- User email lookup: 450ms → 8ms (98% faster) by adding index
- Posts with join: 820ms → 45ms (95% faster) by fixing N+1 problem
- Pagination: 1,200ms → 15ms (99% faster) with cursor-based approach

---

### 3. backend
**Purpose**: Backend API and algorithm optimization

Optimizes API response times, algorithm complexity, caching strategies, and concurrency handling.

**Usage**:
```bash
/10x-fullstack-engineer:optimize backend target:api endpoints:"/api/users,/api/products" load_profile:high
```

**Parameters**:
- `target` (required): What to optimize - `api`, `algorithms`, `caching`, `concurrency`, or `all`
- `endpoints` (optional): Specific API endpoints (comma-separated)
- `load_profile` (optional): Expected load - `low`, `medium`, `high` (default: medium)
- `priority` (optional): Optimization priority - `low`, `medium`, `high`, `critical` (default: high)

**Key Optimizations**:
- **N+1 Query Elimination**: Converts sequential database calls to eager loading or DataLoader batching
- **Response Caching**: Implements Redis caching with TTL and invalidation strategies
- **Compression**: Adds gzip/brotli compression (70-80% size reduction)
- **Algorithm Complexity**: Replaces O(n²) operations with O(n) using Map/Set
- **Parallelization**: Uses Promise.all for independent async operations
- **Request Batching**: Batches multiple requests into single database query
- **JSON Serialization**: Uses fast-json-stringify for known schemas (2-3x faster)
- **Middleware Optimization**: Applies middleware selectively to reduce overhead

**Example Results**:
- API feed endpoint: 850ms → 95ms (89% faster) by fixing N+1 queries
- Response caching: 82% cache hit rate, 82% database load reduction
- Algorithm optimization: 2,400ms → 12ms (99.5% faster) for O(n²) → O(n) conversion
- Parallelization: 190ms → 80ms (58% faster) for independent queries

---

### 4. frontend
**Purpose**: Frontend bundle and rendering optimization

Reduces bundle size, optimizes rendering performance, improves Web Vitals, and optimizes asset loading.

**Usage**:
```bash
/10x-fullstack-engineer:optimize frontend target:all pages:"checkout,dashboard" framework:react
```

**Parameters**:
- `target` (required): What to optimize - `bundles`, `rendering`, `assets`, `images`, `fonts`, or `all`
- `pages` (optional): Specific pages (comma-separated)
- `metrics_target` (optional): Target Lighthouse score (e.g., "lighthouse>90")
- `framework` (optional): Framework - `react`, `vue`, `angular`, `svelte` (auto-detected)

**Key Optimizations**:
- **Code Splitting**: Lazy load routes and components (70-80% smaller initial bundle)
- **Tree Shaking**: Remove unused code with proper imports (90%+ reduction for lodash/moment)
- **Dependency Optimization**: Replace heavy libraries (moment → date-fns: 95% smaller)
- **React Memoization**: Use React.memo, useMemo, useCallback to prevent re-renders
- **Virtual Scrolling**: Render only visible items (98% faster for large lists)
- **Image Optimization**: Modern formats (WebP/AVIF: 80-85% smaller), lazy loading, responsive srcset
- **Font Optimization**: Variable fonts, font-display: swap, preload critical fonts
- **Critical CSS**: Inline above-the-fold CSS, defer non-critical
- **Web Vitals**: Optimize LCP, FID/INP, CLS

**Example Results**:
- Bundle size: 2.5MB → 650KB (74% smaller)
- Initial load: 3.8s → 1.2s (68% faster)
- LCP: 4.2s → 1.8s (57% faster)
- Virtual scrolling: 2,500ms → 45ms (98% faster) for 10,000 items
- Hero image: 1.2MB → 180KB (85% smaller) with AVIF

---

### 5. infrastructure
**Purpose**: Infrastructure and deployment optimization

Optimizes auto-scaling, CDN configuration, resource allocation, deployment strategies, and cost efficiency.

**Usage**:
```bash
/10x-fullstack-engineer:optimize infrastructure target:scaling environment:production provider:aws
```

**Parameters**:
- `target` (required): What to optimize - `scaling`, `cdn`, `resources`, `deployment`, `costs`, or `all`
- `environment` (optional): Target environment (default: production)
- `provider` (optional): Cloud provider - `aws`, `azure`, `gcp`, `vercel` (auto-detected)
- `budget_constraint` (optional): Prioritize cost reduction (default: false)

**Key Optimizations**:
- **Auto-Scaling**: Horizontal/vertical pod autoscaling (HPA/VPA), AWS Auto Scaling Groups
- **CDN Configuration**: CloudFront, cache headers, compression, immutable assets
- **Resource Right-Sizing**: Optimize CPU/memory requests based on actual usage (50-60% savings)
- **Container Optimization**: Multi-stage builds, Alpine base images (85% smaller)
- **Blue-Green Deployment**: Zero-downtime deployments with instant rollback
- **Spot Instances**: Use for batch jobs (70-90% cost savings)
- **Storage Lifecycle**: Auto-archive to Glacier (80%+ cost reduction)
- **Reserved Instances**: Convert stable workloads (37% savings)

**Example Results**:
- Auto-scaling: Off-peak 8 pods (47% reduction), peak 25 pods (67% increase)
- Resource right-sizing: 62% CPU reduction, 61% memory reduction per pod
- CDN: 85% origin request reduction, 84% faster TTFB (750ms → 120ms)
- Container images: 1.2GB → 180MB (85% smaller)
- Total cost: $7,100/month → $4,113/month (42% reduction, $35,844/year savings)

---

### 6. benchmark
**Purpose**: Performance benchmarking and regression testing

Performs load testing, rendering benchmarks, database query benchmarks, and detects performance regressions.

**Usage**:
```bash
/10x-fullstack-engineer:optimize benchmark type:load baseline:"v1.2.0" duration:300s concurrency:100
```

**Parameters**:
- `type` (required): Benchmark type - `load`, `rendering`, `query`, `integration`, or `all`
- `baseline` (optional): Baseline version for comparison (e.g., "v1.2.0")
- `duration` (optional): Test duration in seconds (default: 60s)
- `concurrency` (optional): Concurrent users/connections (default: 50)
- `target` (optional): Specific URL or endpoint

**Key Capabilities**:
- **Load Testing**: k6-based load tests with configurable scenarios (constant, spike, stress)
- **Rendering Benchmarks**: Lighthouse CI for Web Vitals and performance scores
- **Query Benchmarks**: pg_bench or custom scripts for database performance
- **E2E Benchmarks**: Playwright/Puppeteer for user flow performance
- **Baseline Management**: Save and compare performance across versions
- **Regression Detection**: Automated detection with configurable thresholds
- **CI/CD Integration**: GitHub Actions workflow for continuous monitoring

**Example Results**:
- Load test: 150.77 req/s, p95: 245ms, 0.02% errors
- Lighthouse: Performance score 94 (+32 from baseline)
- Query benchmark: User lookup 8ms avg (98% faster than baseline)
- Regression detection: 12 metrics improved, 0 regressions

---

## Common Workflows

### 1. Full Application Optimization

```bash
# Step 1: Analyze overall performance
/10x-fullstack-engineer:optimize analyze target:"production app" scope:all metrics:"baseline"

# Step 2: Optimize based on analysis priorities
/10x-fullstack-engineer:optimize database target:all context:"queries from analysis" threshold:200ms
/10x-fullstack-engineer:optimize backend target:api endpoints:"/api/search,/api/feed" priority:high
/10x-fullstack-engineer:optimize frontend target:all pages:"checkout,dashboard" framework:react

# Step 3: Benchmark improvements
/10x-fullstack-engineer:optimize benchmark type:all baseline:"pre-optimization" duration:600s

# Step 4: Optimize infrastructure for efficiency
/10x-fullstack-engineer:optimize infrastructure target:costs environment:production budget_constraint:true
```

### 2. Frontend Performance Sprint

```bash
# Analyze frontend baseline
/10x-fullstack-engineer:optimize analyze target:"web app" scope:frontend metrics:"baseline"

# Optimize bundles and rendering
/10x-fullstack-engineer:optimize frontend target:bundles pages:"home,dashboard,profile" framework:react
/10x-fullstack-engineer:optimize frontend target:rendering pages:"dashboard" framework:react

# Optimize assets
/10x-fullstack-engineer:optimize frontend target:images pages:"home,product"
/10x-fullstack-engineer:optimize frontend target:fonts pages:"all"

# Benchmark results
/10x-fullstack-engineer:optimize benchmark type:rendering baseline:"pre-sprint" duration:60s
```

### 3. Backend API Performance

```bash
# Analyze backend performance
/10x-fullstack-engineer:optimize analyze target:"REST API" scope:backend metrics:"baseline"

# Fix slow queries first
/10x-fullstack-engineer:optimize database target:queries threshold:200ms context:"from analysis"

# Optimize API layer
/10x-fullstack-engineer:optimize backend target:api endpoints:"/api/users,/api/posts" load_profile:high

# Add caching
/10x-fullstack-engineer:optimize backend target:caching endpoints:"/api/users,/api/posts"

# Benchmark under load
/10x-fullstack-engineer:optimize benchmark type:load baseline:"pre-optimization" duration:300s concurrency:200
```

### 4. Cost Optimization

```bash
# Analyze infrastructure costs
/10x-fullstack-engineer:optimize analyze target:"production" scope:infrastructure metrics:"baseline"

# Right-size resources
/10x-fullstack-engineer:optimize infrastructure target:resources environment:production budget_constraint:true

# Optimize scaling
/10x-fullstack-engineer:optimize infrastructure target:scaling environment:production

# Configure CDN to reduce bandwidth
/10x-fullstack-engineer:optimize infrastructure target:cdn environment:production

# Optimize storage costs
/10x-fullstack-engineer:optimize infrastructure target:costs environment:production budget_constraint:true
```

### 5. Regression Testing

```bash
# Save baseline before changes
/10x-fullstack-engineer:optimize benchmark type:all baseline:"v1.5.0" duration:300s

# After implementing changes, compare
/10x-fullstack-engineer:optimize benchmark type:all baseline:"v1.5.0" duration:300s

# Analyze specific regressions
/10x-fullstack-engineer:optimize analyze target:"changed endpoints" scope:backend metrics:"compare" baseline:"v1.5.0"
```

---

## Performance Metrics and Thresholds

### Frontend (Web Vitals)
- **LCP** (Largest Contentful Paint): Good < 2.5s, Needs Improvement 2.5-4s, Poor > 4s
- **FID/INP** (First Input Delay / Interaction to Next Paint): Good < 100ms, Needs Improvement 100-300ms, Poor > 300ms
- **CLS** (Cumulative Layout Shift): Good < 0.1, Needs Improvement 0.1-0.25, Poor > 0.25
- **TTFB** (Time to First Byte): Good < 600ms, Needs Improvement 600-1000ms, Poor > 1000ms
- **Bundle Size**: Target < 500KB initial (gzipped)

### Backend (API Performance)
- **p50 Response Time**: Target < 200ms
- **p95 Response Time**: Target < 500ms
- **p99 Response Time**: Target < 1000ms
- **Throughput**: Varies by application, track baseline
- **Error Rate**: Target < 1%

### Database (Query Performance)
- **Average Query Time**: Target < 100ms
- **Slow Query Count**: Target 0 queries > 500ms
- **Cache Hit Rate**: Target > 85%
- **Connection Pool Utilization**: Target < 75%

### Infrastructure (Resource Utilization)
- **CPU Utilization**: Target 50-75% (allows headroom)
- **Memory Utilization**: Target < 70%
- **Disk I/O Wait**: Target < 5%
- **Network Utilization**: Track baseline

---

## Layer-Specific Guidance

### Database Optimization Priorities
1. **Add missing indexes** - Highest ROI for slow queries
2. **Fix N+1 query problems** - Often 90%+ improvement
3. **Implement caching** - Reduce database load by 70-90%
4. **Optimize connection pool** - Eliminate connection timeouts
5. **Schema optimization** - Denormalization, partitioning for scale

### Backend Optimization Priorities
1. **Cache frequently accessed data** - 80%+ reduction in database calls
2. **Fix N+1 problems** - Replace sequential queries with batch operations
3. **Parallelize independent operations** - 50%+ improvement for I/O-bound work
4. **Add response compression** - 70-80% bandwidth reduction
5. **Optimize algorithms** - Replace O(n²) with O(n) for large datasets

### Frontend Optimization Priorities
1. **Code splitting by route** - 70-80% smaller initial bundle
2. **Replace heavy dependencies** - Often 90%+ savings (moment → date-fns)
3. **Optimize images** - 80-85% smaller with modern formats
4. **Implement lazy loading** - Images, components, routes
5. **Optimize rendering** - Memoization, virtual scrolling for lists

### Infrastructure Optimization Priorities
1. **Enable auto-scaling** - 30-50% cost savings with same performance
2. **Right-size resources** - 50-60% savings on over-provisioned workloads
3. **Configure CDN** - 80%+ origin request reduction
4. **Use reserved instances** - 30-40% savings for stable workloads
5. **Optimize storage lifecycle** - 70-80% savings for old data

---

## Typical Performance Improvements

Based on real-world optimizations, expect:

### Database
- **Index addition**: 95-98% query speedup (450ms → 8ms)
- **N+1 fix**: 90-95% improvement (2,100ms → 180ms)
- **Caching**: 70-90% database load reduction
- **Connection pooling**: Eliminate timeout errors

### Backend
- **N+1 elimination**: 85-95% faster (850ms → 95ms)
- **Caching**: 80%+ cache hit rates, 80% load reduction
- **Compression**: 70-80% bandwidth savings
- **Algorithm optimization**: 99%+ for O(n²) → O(n) (2,400ms → 12ms)
- **Parallelization**: 50-60% faster (190ms → 80ms)

### Frontend
- **Code splitting**: 70-80% smaller initial bundle (2.5MB → 650KB)
- **Dependency optimization**: 90-95% savings (moment → date-fns)
- **Image optimization**: 80-85% smaller (1.2MB → 180KB)
- **Virtual scrolling**: 98% faster (2,500ms → 45ms)
- **Load time**: 60-70% faster (3.8s → 1.2s)

### Infrastructure
- **Auto-scaling**: 30-50% cost reduction
- **Right-sizing**: 50-60% savings per resource
- **CDN**: 80-85% origin request reduction
- **Reserved instances**: 30-40% savings
- **Overall**: 40-45% total infrastructure cost reduction

---

## Tools and Technologies

### Profiling and Analysis
- **Lighthouse**: Frontend performance audits
- **Chrome DevTools**: Performance profiling, network waterfall
- **pg_stat_statements**: PostgreSQL query analysis
- **clinic.js**: Node.js profiling (doctor, flame, bubbleprof)
- **k6**: Load testing and benchmarking
- **CloudWatch/Prometheus**: Infrastructure metrics

### Optimization Tools
- **webpack-bundle-analyzer**: Bundle size analysis
- **depcheck**: Find unused dependencies
- **React DevTools Profiler**: React rendering analysis
- **redis**: Caching layer
- **ImageOptim/Sharp**: Image optimization
- **Lighthouse CI**: Continuous performance monitoring

### Benchmarking Tools
- **k6**: Load testing with scenarios
- **Lighthouse CI**: Rendering benchmarks
- **pg_bench**: Database benchmarking
- **autocannon**: HTTP load testing
- **Playwright**: E2E performance testing

---

## Integration with 10x-Fullstack-Engineer Agent

All optimization operations leverage the **10x-fullstack-engineer** agent for:

- **Expert performance analysis** across all layers
- **Industry best practices** for optimization
- **Trade-off analysis** between performance and maintainability
- **Scalability considerations** for future growth
- **Production-ready implementation** guidance
- **Security considerations** for optimizations
- **Cost-benefit analysis** for infrastructure changes

The agent ensures optimizations are:
- Safe for production deployment
- Maintainable and well-documented
- Aligned with architectural patterns
- Balanced between performance and complexity

---

## Best Practices

### Before Optimizing
1. **Measure first**: Always establish baseline metrics
2. **Identify bottlenecks**: Use profiling to find actual problems
3. **Prioritize**: Focus on high-impact, low-effort optimizations first
4. **Set targets**: Define clear performance goals

### During Optimization
1. **One change at a time**: Measure impact of each optimization
2. **Preserve functionality**: Ensure tests pass after changes
3. **Document trade-offs**: Record decisions and rationale
4. **Monitor closely**: Watch for unexpected side effects

### After Optimization
1. **Benchmark improvements**: Quantify performance gains
2. **Monitor in production**: Track real-world impact
3. **Set up alerts**: Detect future regressions
4. **Update baselines**: Use new metrics as baseline for future work

### Continuous Monitoring
1. **Automated benchmarks**: Run in CI/CD pipeline
2. **Performance budgets**: Fail builds that exceed thresholds
3. **Real user monitoring**: Track actual user experience
4. **Regular reviews**: Quarterly performance audits

---

## Troubleshooting

### Optimization Not Showing Expected Results

**Issue**: Applied optimization but metrics didn't improve

**Possible causes**:
- Caching not clearing properly (invalidate cache)
- Different bottleneck than expected (re-profile)
- Configuration not applied (verify deployment)
- Measurement methodology issue (check profiling setup)

**Solution**: Re-run analysis to verify bottleneck, ensure optimization is deployed, measure with multiple tools

### Performance Regression After Deployment

**Issue**: Performance worse after optimization

**Possible causes**:
- Optimization introduced bug or inefficiency
- Cache warming needed
- Auto-scaling not configured properly
- Unexpected load pattern

**Solution**: Compare metrics before/after, rollback if critical, investigate with profiling tools

### Benchmarks Not Matching Production

**Issue**: Benchmark shows improvements but production doesn't

**Possible causes**:
- Different load patterns
- Network latency in production
- Database size differences
- Cache cold in production

**Solution**: Use production-like data, run benchmarks under realistic conditions, allow cache warming time

---

## Related Skills

- `/test` - Ensure optimizations don't break functionality
- `/deploy` - Deploy optimizations safely to production
- `/monitor` - Track performance metrics over time
- `/architect` - Design scalable architectures from the start

---

## Contributing

When adding new optimizations to this skill:

1. Document the optimization technique
2. Provide before/after examples
3. Include expected performance improvements
4. Add profiling/measurement instructions
5. Document trade-offs and considerations

---

## License

Part of the 10x-fullstack-engineer plugin. See plugin.json for licensing details.
