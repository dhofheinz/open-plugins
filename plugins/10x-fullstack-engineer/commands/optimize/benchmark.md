# Performance Benchmarking Operation

You are executing the **benchmark** operation to perform load testing, rendering benchmarks, query benchmarks, and regression detection.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'benchmark' operation name)

Expected format: `type:"load|rendering|query|integration|all" [baseline:"version-or-tag"] [duration:"seconds"] [concurrency:"number"] [target:"url-or-endpoint"]`

**Parameter definitions**:
- `type` (required): Benchmark type - `load`, `rendering`, `query`, `integration`, or `all`
- `baseline` (optional): Baseline version for comparison (e.g., "v1.2.0", "main", "baseline-2025-10-14")
- `duration` (optional): Test duration in seconds (default: 60s)
- `concurrency` (optional): Number of concurrent users/connections (default: 50)
- `target` (optional): Specific URL or endpoint to benchmark

## Workflow

### 1. Setup Benchmarking Environment

```bash
# Install benchmarking tools
npm install -g k6 lighthouse-ci autocannon

# For database benchmarking
npm install -g pg-bench

# Create benchmark results directory
mkdir -p benchmark-results/$(date +%Y-%m-%d)
```

### 2. Load Testing with k6

**Basic Load Test Script**:
```javascript
// loadtest.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '30s', target: 20 },   // Ramp up to 20 users
    { duration: '1m', target: 50 },    // Stay at 50 users
    { duration: '30s', target: 100 },  // Spike to 100 users
    { duration: '1m', target: 50 },    // Back to 50 users
    { duration: '30s', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'], // 95% < 500ms, 99% < 1s
    http_req_failed: ['rate<0.01'], // Error rate < 1%
    errors: ['rate<0.1'],
  },
};

export default function () {
  const responses = http.batch([
    ['GET', 'https://api.example.com/users'],
    ['GET', 'https://api.example.com/posts'],
    ['GET', 'https://api.example.com/comments'],
  ]);

  responses.forEach((res) => {
    const success = check(res, {
      'status is 200': (r) => r.status === 200,
      'response time < 500ms': (r) => r.timings.duration < 500,
    });

    errorRate.add(!success);
  });

  sleep(1);
}
```

**Run Load Test**:
```bash
# Basic load test
k6 run loadtest.js

# Custom configuration
k6 run --vus 100 --duration 300s loadtest.js

# Output to JSON for analysis
k6 run --out json=results.json loadtest.js

# Cloud run (for distributed testing)
k6 cloud run loadtest.js
```

**Advanced Load Test with Scenarios**:
```javascript
// advanced-loadtest.js
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  scenarios: {
    // Scenario 1: Constant load
    constant_load: {
      executor: 'constant-vus',
      vus: 50,
      duration: '5m',
      tags: { scenario: 'constant' },
    },
    // Scenario 2: Spike test
    spike_test: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '10s', target: 200 },
        { duration: '30s', target: 200 },
        { duration: '10s', target: 0 },
      ],
      startTime: '5m',
      tags: { scenario: 'spike' },
    },
    // Scenario 3: Stress test
    stress_test: {
      executor: 'ramping-arrival-rate',
      startRate: 50,
      timeUnit: '1s',
      stages: [
        { duration: '2m', target: 100 },
        { duration: '3m', target: 200 },
        { duration: '2m', target: 400 },
      ],
      startTime: '10m',
      tags: { scenario: 'stress' },
    },
  },
  thresholds: {
    'http_req_duration{scenario:constant}': ['p(95)<500'],
    'http_req_duration{scenario:spike}': ['p(95)<1000'],
    'http_req_failed': ['rate<0.05'],
  },
};

export default function () {
  const res = http.get('https://api.example.com/users');
  check(res, {
    'status is 200': (r) => r.status === 200,
  });
}
```

### 3. Frontend Rendering Benchmarks

**Lighthouse CI Configuration**:
```json
// lighthouserc.json
{
  "ci": {
    "collect": {
      "url": [
        "http://localhost:3000",
        "http://localhost:3000/dashboard",
        "http://localhost:3000/profile"
      ],
      "numberOfRuns": 3,
      "settings": {
        "preset": "desktop",
        "throttling": {
          "rttMs": 40,
          "throughputKbps": 10240,
          "cpuSlowdownMultiplier": 1
        }
      }
    },
    "assert": {
      "assertions": {
        "categories:performance": ["error", {"minScore": 0.9}],
        "categories:accessibility": ["error", {"minScore": 0.9}],
        "first-contentful-paint": ["error", {"maxNumericValue": 2000}],
        "largest-contentful-paint": ["error", {"maxNumericValue": 2500}],
        "cumulative-layout-shift": ["error", {"maxNumericValue": 0.1}],
        "total-blocking-time": ["error", {"maxNumericValue": 300}]
      }
    },
    "upload": {
      "target": "filesystem",
      "outputDir": "./benchmark-results"
    }
  }
}
```

**Run Lighthouse CI**:
```bash
# Single run
lhci autorun

# Compare with baseline
lhci autorun --config=lighthouserc.json

# Upload results for comparison
lhci upload --target=temporary-public-storage
```

**Custom Rendering Benchmark**:
```javascript
// rendering-benchmark.js
const puppeteer = require('puppeteer');

async function benchmarkRendering(url, iterations = 10) {
  const browser = await puppeteer.launch();
  const results = [];

  for (let i = 0; i < iterations; i++) {
    const page = await browser.newPage();

    // Start performance measurement
    await page.goto(url, { waitUntil: 'networkidle2' });

    const metrics = await page.evaluate(() => {
      const navigation = performance.getEntriesByType('navigation')[0];
      const paint = performance.getEntriesByType('paint');

      return {
        domContentLoaded: navigation.domContentLoadedEventEnd - navigation.domContentLoadedEventStart,
        loadComplete: navigation.loadEventEnd - navigation.loadEventStart,
        firstPaint: paint.find(p => p.name === 'first-paint')?.startTime,
        firstContentfulPaint: paint.find(p => p.name === 'first-contentful-paint')?.startTime,
        domInteractive: navigation.domInteractive,
      };
    });

    results.push(metrics);
    await page.close();
  }

  await browser.close();

  // Calculate averages
  const avg = (key) => results.reduce((sum, r) => sum + r[key], 0) / results.length;

  return {
    avgDOMContentLoaded: avg('domContentLoaded'),
    avgLoadComplete: avg('loadComplete'),
    avgFirstPaint: avg('firstPaint'),
    avgFirstContentfulPaint: avg('firstContentfulPaint'),
    avgDOMInteractive: avg('domInteractive'),
  };
}

// Run benchmark
benchmarkRendering('http://localhost:3000').then(console.log);
```

### 4. Database Query Benchmarks

**PostgreSQL - pg_bench**:
```bash
# Initialize benchmark database
pgbench -i -s 50 benchmark_db

# Run benchmark (50 clients, 1000 transactions each)
pgbench -c 50 -t 1000 benchmark_db

# Custom SQL script benchmark
cat > custom-queries.sql <<'EOF'
SELECT * FROM users WHERE email = 'test@example.com';
SELECT p.*, u.name FROM posts p JOIN users u ON p.user_id = u.id LIMIT 100;
EOF

pgbench -c 10 -t 100 -f custom-queries.sql benchmark_db

# Output JSON results
pgbench -c 50 -t 1000 --log --log-prefix=benchmark benchmark_db
```

**Custom Query Benchmark Script**:
```javascript
// query-benchmark.js
const { Pool } = require('pg');
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

async function benchmarkQuery(query, params = [], iterations = 1000) {
  const times = [];

  for (let i = 0; i < iterations; i++) {
    const start = process.hrtime.bigint();
    await pool.query(query, params);
    const end = process.hrtime.bigint();

    times.push(Number(end - start) / 1_000_000); // Convert to ms
  }

  times.sort((a, b) => a - b);

  return {
    iterations,
    min: times[0].toFixed(2),
    max: times[times.length - 1].toFixed(2),
    avg: (times.reduce((a, b) => a + b, 0) / times.length).toFixed(2),
    p50: times[Math.floor(times.length * 0.50)].toFixed(2),
    p95: times[Math.floor(times.length * 0.95)].toFixed(2),
    p99: times[Math.floor(times.length * 0.99)].toFixed(2),
  };
}

// Run benchmarks
async function runBenchmarks() {
  console.log('Benchmarking user lookup by email...');
  const userLookup = await benchmarkQuery(
    'SELECT * FROM users WHERE email = $1',
    ['test@example.com']
  );
  console.log(userLookup);

  console.log('\nBenchmarking posts with user join...');
  const postsJoin = await benchmarkQuery(
    'SELECT p.*, u.name FROM posts p JOIN users u ON p.user_id = u.id LIMIT 100'
  );
  console.log(postsJoin);

  await pool.end();
}

runBenchmarks();
```

### 5. Integration/E2E Benchmarks

**Playwright Performance Testing**:
```javascript
// e2e-benchmark.js
const { chromium } = require('playwright');

async function benchmarkUserFlow(iterations = 10) {
  const results = [];

  for (let i = 0; i < iterations; i++) {
    const browser = await chromium.launch();
    const context = await browser.newContext();
    const page = await context.newPage();

    const startTime = Date.now();

    // User flow
    await page.goto('http://localhost:3000');
    await page.fill('input[name="email"]', 'user@example.com');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await page.waitForSelector('.dashboard');
    await page.click('a[href="/profile"]');
    await page.waitForSelector('.profile-page');

    const endTime = Date.now();
    results.push(endTime - startTime);

    await browser.close();
  }

  const avg = results.reduce((a, b) => a + b, 0) / results.length;
  const min = Math.min(...results);
  const max = Math.max(...results);

  return { avg, min, max, results };
}

benchmarkUserFlow().then(console.log);
```

### 6. Baseline Management and Comparison

**Save Baseline**:
```bash
# Save current performance as baseline
mkdir -p baselines/

# k6 results
k6 run --out json=baselines/baseline-$(date +%Y-%m-%d)-load.json loadtest.js

# Lighthouse results
lhci autorun --config=lighthouserc.json
cp -r .lighthouseci/ baselines/baseline-$(date +%Y-%m-%d)-lighthouse/

# Query benchmarks
node query-benchmark.js > baselines/baseline-$(date +%Y-%m-%d)-queries.json
```

**Compare with Baseline**:
```javascript
// compare-benchmarks.js
const fs = require('fs');

function compareBenchmarks(currentFile, baselineFile) {
  const current = JSON.parse(fs.readFileSync(currentFile));
  const baseline = JSON.parse(fs.readFileSync(baselineFile));

  const metrics = ['p50', 'p95', 'p99', 'avg'];
  const comparison = {};

  metrics.forEach(metric => {
    const currentValue = parseFloat(current[metric]);
    const baselineValue = parseFloat(baseline[metric]);
    const diff = currentValue - baselineValue;
    const percentChange = (diff / baselineValue) * 100;

    comparison[metric] = {
      current: currentValue,
      baseline: baselineValue,
      diff: diff.toFixed(2),
      percentChange: percentChange.toFixed(2),
      regression: diff > 0,
    };
  });

  return comparison;
}

// Usage
const comparison = compareBenchmarks(
  'results/current-queries.json',
  'baselines/baseline-2025-10-01-queries.json'
);

console.log('Performance Comparison:');
Object.entries(comparison).forEach(([metric, data]) => {
  const emoji = data.regression ? '⚠️' : '✅';
  console.log(`${emoji} ${metric}: ${data.percentChange}% change`);
});
```

### 7. Regression Detection

**Automated Regression Detection**:
```javascript
// detect-regression.js
function detectRegression(comparison, thresholds = {
  p50: 10,  // 10% increase is regression
  p95: 15,
  p99: 20,
}) {
  const regressions = [];

  Object.entries(comparison).forEach(([metric, data]) => {
    const threshold = thresholds[metric] || 10;

    if (data.percentChange > threshold) {
      regressions.push({
        metric,
        change: data.percentChange,
        threshold,
        current: data.current,
        baseline: data.baseline,
      });
    }
  });

  return {
    hasRegression: regressions.length > 0,
    regressions,
  };
}

// Usage in CI/CD
const comparison = compareBenchmarks('current.json', 'baseline.json');
const regression = detectRegression(comparison);

if (regression.hasRegression) {
  console.error('Performance regression detected!');
  regression.regressions.forEach(r => {
    console.error(`${r.metric}: ${r.change}% increase (threshold: ${r.threshold}%)`);
  });
  process.exit(1); // Fail CI build
}
```

### 8. Continuous Performance Monitoring

**GitHub Actions Workflow**:
```yaml
# .github/workflows/performance.yml
name: Performance Benchmarks

on:
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight

jobs:
  benchmark:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: |
          npm ci
          npm install -g k6 @lhci/cli

      - name: Build application
        run: npm run build

      - name: Start server
        run: npm start &
        env:
          NODE_ENV: production

      - name: Wait for server
        run: npx wait-on http://localhost:3000

      - name: Run Lighthouse CI
        run: lhci autorun --config=lighthouserc.json

      - name: Run load tests
        run: k6 run --out json=results-load.json loadtest.js

      - name: Compare with baseline
        run: node scripts/compare-benchmarks.js

      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: benchmark-results
          path: benchmark-results/

      - name: Comment PR with results
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const results = JSON.parse(fs.readFileSync('benchmark-results/summary.json'));
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Performance Benchmark Results\n\n${results.summary}`
            });
```

## Output Format

```markdown
# Performance Benchmark Report

**Benchmark Date**: [Date]
**Benchmark Type**: [load/rendering/query/integration/all]
**Baseline**: [version or "none"]
**Duration**: [test duration]
**Concurrency**: [concurrent users/connections]

## Executive Summary

[Summary of benchmark results and any regressions detected]

## Load Testing Results (k6)

### Test Configuration
- **Virtual Users**: 50 (ramped from 0 to 100)
- **Duration**: 5 minutes
- **Scenarios**: Constant load, spike test, stress test

### Results

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Total Requests | 45,230 | - | - |
| Request Rate | 150.77/s | - | - |
| Request Duration (p50) | 85ms | <200ms | ✅ Pass |
| Request Duration (p95) | 245ms | <500ms | ✅ Pass |
| Request Duration (p99) | 680ms | <1000ms | ✅ Pass |
| Failed Requests | 0.02% | <1% | ✅ Pass |

### Comparison with Baseline

| Metric | Current | Baseline (v1.2.0) | Change |
|--------|---------|-------------------|--------|
| p50 | 85ms | 120ms | -29% ✅ |
| p95 | 245ms | 450ms | -46% ✅ |
| p99 | 680ms | 980ms | -31% ✅ |
| Request Rate | 150.77/s | 85/s | +77% ✅ |

**Overall**: 46% improvement in p95 response time

## Frontend Rendering Benchmarks (Lighthouse)

### Home Page

| Metric | Score | Value | Baseline | Change |
|--------|-------|-------|----------|--------|
| Performance | 94 | - | 62 | +32 ✅ |
| FCP | - | 0.8s | 2.1s | -62% ✅ |
| LCP | - | 1.8s | 4.2s | -57% ✅ |
| TBT | - | 45ms | 280ms | -84% ✅ |
| CLS | - | 0.02 | 0.18 | -89% ✅ |

### Dashboard Page

| Metric | Score | Value | Baseline | Change |
|--------|-------|-------|----------|--------|
| Performance | 89 | - | 48 | +41 ✅ |
| LCP | - | 2.1s | 5.8s | -64% ✅ |
| TBT | - | 65ms | 420ms | -85% ✅ |

## Database Query Benchmarks

### User Lookup by Email (1000 iterations)

| Metric | Current | Baseline | Change |
|--------|---------|----------|--------|
| Min | 6ms | 380ms | -98% ✅ |
| Avg | 8ms | 450ms | -98% ✅ |
| p50 | 7ms | 445ms | -98% ✅ |
| p95 | 12ms | 520ms | -98% ✅ |
| p99 | 18ms | 680ms | -97% ✅ |

**Optimization**: Added index on users.email

### Posts with User Join (1000 iterations)

| Metric | Current | Baseline | Change |
|--------|---------|----------|--------|
| Avg | 45ms | 820ms | -95% ✅ |
| p95 | 68ms | 1200ms | -94% ✅ |
| p99 | 95ms | 2100ms | -95% ✅ |

**Optimization**: Fixed N+1 query with eager loading

## Integration/E2E Benchmarks

### User Login Flow (10 iterations)

| Metric | Value | Baseline | Change |
|--------|-------|----------|--------|
| Average | 1,245ms | 3,850ms | -68% ✅ |
| Min | 1,120ms | 3,200ms | -65% ✅ |
| Max | 1,420ms | 4,500ms | -68% ✅ |

**Flow**: Home → Login → Dashboard → Profile

## Regression Analysis

**Regressions Detected**: None

**Performance Improvements**: 12 metrics improved
- Load testing: 46% faster p95 response time
- Frontend rendering: 57% faster LCP
- Database queries: 98% faster average query time
- E2E flows: 68% faster completion time

## Recommendations

1. **Continue Monitoring**: Set up daily benchmarks to catch regressions early
2. **Performance Budget**: Establish budgets based on current metrics
   - p95 response time < 300ms
   - LCP < 2.5s
   - Database queries < 100ms average
3. **Optimize Further**: Investigate remaining slow queries in analytics module

## Testing Instructions

### Run Load Tests
```bash
k6 run --vus 50 --duration 60s loadtest.js
```

### Run Rendering Benchmarks
```bash
lhci autorun --config=lighthouserc.json
```

### Run Query Benchmarks
```bash
node query-benchmark.js
```

### Compare with Baseline
```bash
node scripts/compare-benchmarks.js results/current.json baselines/baseline-2025-10-01.json
```
