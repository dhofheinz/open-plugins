# Performance Operation - Performance Debugging and Profiling

You are executing the **performance** operation to debug performance issues, profile application behavior, and optimize system performance.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'performance' operation name)

Expected format: `component:"component-name" [metric:"response-time|throughput|cpu|memory"] [threshold:"target-value"] [duration:"profile-duration"] [load:"concurrent-users"]`

## Workflow

### 1. Establish Performance Baseline

Measure current performance before optimization:

**Baseline Metrics to Capture**:
```bash
# Response time baseline
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:3000/api/endpoint

# Create curl-format.txt
cat > curl-format.txt <<'EOF'
    time_namelookup:  %{time_namelookup}\n
       time_connect:  %{time_connect}\n
    time_appconnect:  %{time_appconnect}\n
   time_pretransfer:  %{time_pretransfer}\n
      time_redirect:  %{time_redirect}\n
 time_starttransfer:  %{time_starttransfer}\n
                    ----------\n
         time_total:  %{time_total}\n
EOF

# Throughput baseline
ab -n 1000 -c 10 http://localhost:3000/api/endpoint

# Resource usage baseline
# CPU
mpstat 1 60 > baseline_cpu.txt

# Memory
free -m && ps aux --sort=-%mem | head -20

# Disk I/O
iostat -x 1 60 > baseline_io.txt
```

**Application Metrics**:
```javascript
// Add timing middleware
app.use((req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log({
      method: req.method,
      path: req.path,
      status: res.statusCode,
      duration: duration,
      timestamp: new Date().toISOString()
    });
  });

  next();
});

// Track key operations
const startTime = Date.now();
await operation();
const duration = Date.now() - startTime;
metrics.histogram('operation_duration', duration);
```

### 2. Identify Performance Bottlenecks

Use profiling to find slow components:

#### Application Profiling

**Node.js Profiling**:
```bash
# CPU profiling
node --prof app.js
# Run load test
ab -n 10000 -c 100 http://localhost:3000/
# Stop app, process profile
node --prof-process isolate-*-v8.log > processed.txt

# Chrome DevTools profiling
node --inspect app.js
# Open chrome://inspect
# Click "Open dedicated DevTools for Node"
# Go to Profiler tab, start profiling

# Clinic.js for comprehensive profiling
npm install -g clinic
clinic doctor -- node app.js
# Run load test
clinic doctor --visualize-only PID.clinic-doctor
```

**Python Profiling**:
```python
import cProfile
import pstats

# Profile a function
cProfile.run('my_function()', 'profile_stats')

# Analyze results
p = pstats.Stats('profile_stats')
p.sort_stats('cumulative')
p.print_stats(20)

# Line profiler for detailed profiling
from line_profiler import LineProfiler

profiler = LineProfiler()
profiler.add_function(my_function)
profiler.run('my_function()')
profiler.print_stats()

# Memory profiling
from memory_profiler import profile

@profile
def my_function():
    large_list = [i for i in range(1000000)]
    return sum(large_list)
```

**Use profiling utility script**:
```bash
# Run comprehensive profiling
./commands/debug/.scripts/profile.sh \
  --app node_app \
  --duration 60 \
  --endpoint http://localhost:3000/api/slow

# Output: CPU profile, memory profile, flamegraph
```

#### Database Profiling

**Query Performance**:
```sql
-- PostgreSQL: Enable query timing
\timing on

-- Analyze query plan
EXPLAIN ANALYZE
SELECT u.*, o.*
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.created_at > '2024-01-01';

-- Look for:
-- - Seq Scan (sequential scan - bad for large tables)
-- - High cost estimates
-- - Large number of rows processed
-- - Missing indexes

-- Check slow queries
SELECT
  query,
  calls,
  total_time,
  mean_time,
  max_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 20;

-- Find missing indexes
SELECT
  schemaname,
  tablename,
  seq_scan,
  seq_tup_read,
  idx_scan,
  seq_tup_read / seq_scan AS avg_seq_read
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_tup_read DESC
LIMIT 20;
```

**Connection Pool Analysis**:
```javascript
// Monitor connection pool
pool.on('acquire', (client) => {
  console.log('Client acquired:', {
    poolSize: pool.totalCount,
    idleCount: pool.idleCount,
    waitingCount: pool.waitingCount
  });
});

pool.on('remove', (client) => {
  console.log('Client removed from pool');
});

// Check pool stats periodically
setInterval(() => {
  console.log('Pool stats:', {
    total: pool.totalCount,
    idle: pool.idleCount,
    waiting: pool.waitingCount
  });
}, 10000);
```

#### Network Profiling

**API Call Analysis**:
```bash
# Trace network calls
strace -c -p PID  # System call tracing

# Detailed network timing
tcpdump -i any -w capture.pcap port 3000
# Analyze with Wireshark

# HTTP request tracing
curl -w "@curl-format.txt" -v http://localhost:3000/api/endpoint

# Check DNS resolution
time nslookup api.example.com

# Check network latency
ping -c 10 api.example.com
```

**Browser Performance**:
```javascript
// Use Performance API
performance.mark('start-operation');
await operation();
performance.mark('end-operation');
performance.measure('operation', 'start-operation', 'end-operation');

const measure = performance.getEntriesByName('operation')[0];
console.log('Operation took:', measure.duration, 'ms');

// Navigation timing
const perfData = performance.getEntriesByType('navigation')[0];
console.log({
  dns: perfData.domainLookupEnd - perfData.domainLookupStart,
  tcp: perfData.connectEnd - perfData.connectStart,
  ttfb: perfData.responseStart - perfData.requestStart,
  download: perfData.responseEnd - perfData.responseStart,
  domReady: perfData.domContentLoadedEventEnd - perfData.domContentLoadedEventStart,
  load: perfData.loadEventEnd - perfData.loadEventStart
});

// Resource timing
performance.getEntriesByType('resource').forEach(resource => {
  console.log(resource.name, resource.duration);
});
```

### 3. Analyze Bottlenecks

Understand why components are slow:

#### CPU Bottlenecks

**Identify CPU-intensive operations**:
```javascript
// Find CPU-heavy code
const { performance } = require('perf_hooks');

function analyzePerformance() {
  const start = performance.now();

  // Suspect operation
  const result = expensiveOperation();

  const duration = performance.now() - start;
  if (duration > 100) {  // More than 100ms
    console.warn('CPU-intensive operation detected:', {
      operation: 'expensiveOperation',
      duration: duration
    });
  }

  return result;
}
```

**Common CPU bottlenecks**:
- Complex regex operations
- Large array/object operations
- JSON parsing/stringifying large objects
- Synchronous file operations
- Cryptographic operations
- Image processing

**Solutions**:
```javascript
// Before: Synchronous blocking
const data = JSON.parse(largeJsonString);

// After: Async in worker thread
const { Worker } = require('worker_threads');

function parseJsonAsync(jsonString) {
  return new Promise((resolve, reject) => {
    const worker = new Worker(`
      const { parentPort } = require('worker_threads');
      parentPort.on('message', (data) => {
        const parsed = JSON.parse(data);
        parentPort.postMessage(parsed);
      });
    `, { eval: true });

    worker.on('message', resolve);
    worker.on('error', reject);
    worker.postMessage(jsonString);
  });
}
```

#### I/O Bottlenecks

**Identify I/O-bound operations**:
```javascript
// Monitor I/O operations
const fs = require('fs').promises;

async function monitoredFileRead(path) {
  const start = Date.now();
  try {
    const data = await fs.readFile(path);
    const duration = Date.now() - start;

    console.log('File read:', { path, duration, size: data.length });

    if (duration > 50) {
      console.warn('Slow file read detected:', path);
    }

    return data;
  } catch (error) {
    console.error('File read failed:', { path, error });
    throw error;
  }
}
```

**Common I/O bottlenecks**:
- Multiple database queries in sequence (N+1 problem)
- Synchronous file operations
- External API calls in sequence
- Large file uploads/downloads

**Solutions**:
```javascript
// Before: Sequential queries (N+1)
const users = await User.findAll();
for (const user of users) {
  user.posts = await Post.findByUserId(user.id);  // N queries
}

// After: Single query with join
const users = await User.findAll({
  include: [{ model: Post }]
});

// Before: Sequential API calls
const user = await fetchUser(userId);
const orders = await fetchOrders(userId);
const profile = await fetchProfile(userId);

// After: Parallel execution
const [user, orders, profile] = await Promise.all([
  fetchUser(userId),
  fetchOrders(userId),
  fetchProfile(userId)
]);
```

#### Memory Bottlenecks

**Identify memory issues**:
```javascript
// Monitor memory usage
function logMemoryUsage(label) {
  const usage = process.memoryUsage();
  console.log(`[${label}] Memory:`, {
    rss: Math.round(usage.rss / 1024 / 1024) + 'MB',
    heapTotal: Math.round(usage.heapTotal / 1024 / 1024) + 'MB',
    heapUsed: Math.round(usage.heapUsed / 1024 / 1024) + 'MB',
    external: Math.round(usage.external / 1024 / 1024) + 'MB'
  });
}

logMemoryUsage('before-operation');
await operation();
logMemoryUsage('after-operation');
```

**Common memory bottlenecks**:
- Loading large datasets into memory
- Caching without size limits
- Memory leaks (event listeners, closures)
- Large object allocations

**Solutions**:
```javascript
// Before: Load entire file into memory
const data = await fs.readFile('large-file.csv', 'utf8');
const lines = data.split('\n');

// After: Stream processing
const readline = require('readline');
const stream = fs.createReadStream('large-file.csv');
const rl = readline.createInterface({ input: stream });

for await (const line of rl) {
  processLine(line);  // Process one line at a time
}

// Before: Unbounded cache
const cache = {};
cache[key] = value;  // Grows forever

// After: LRU cache with size limit
const LRU = require('lru-cache');
const cache = new LRU({
  max: 1000,  // Max items
  maxSize: 50 * 1024 * 1024,  // 50MB
  sizeCalculation: (value) => JSON.stringify(value).length
});
```

### 4. Implement Optimizations

Apply targeted optimizations:

#### Query Optimization

**Add Indexes**:
```sql
-- Before: Slow query
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 123;
-- Seq Scan on orders  (cost=0.00..1234.56 rows=10 width=100) (actual time=45.123..45.456 rows=10 loops=1)

-- After: Add index
CREATE INDEX idx_orders_user_id ON orders(user_id);

EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 123;
-- Index Scan using idx_orders_user_id on orders  (cost=0.29..8.30 rows=10 width=100) (actual time=0.012..0.015 rows=10 loops=1)
```

**Optimize Queries**:
```sql
-- Before: Inefficient
SELECT * FROM orders o
LEFT JOIN users u ON o.user_id = u.id
WHERE o.created_at > NOW() - INTERVAL '7 days';

-- After: Select only needed columns, add index
CREATE INDEX idx_orders_created_at ON orders(created_at);

SELECT o.id, o.amount, u.name
FROM orders o
INNER JOIN users u ON o.user_id = u.id
WHERE o.created_at > NOW() - INTERVAL '7 days';
```

#### Caching

**Application-level caching**:
```javascript
const cache = new Map();

async function getCachedData(key) {
  // Check cache first
  if (cache.has(key)) {
    console.log('Cache hit:', key);
    return cache.get(key);
  }

  // Cache miss - fetch from database
  console.log('Cache miss:', key);
  const data = await fetchFromDatabase(key);

  // Store in cache
  cache.set(key, data);

  // Expire after 5 minutes
  setTimeout(() => cache.delete(key), 5 * 60 * 1000);

  return data;
}

// Redis caching
const redis = require('redis');
const client = redis.createClient();

async function getCachedDataRedis(key) {
  // Try cache
  const cached = await client.get(key);
  if (cached) {
    return JSON.parse(cached);
  }

  // Fetch and cache
  const data = await fetchFromDatabase(key);
  await client.setEx(key, 300, JSON.stringify(data));  // 5 min TTL

  return data;
}
```

#### Code Optimization

**Optimize algorithms**:
```javascript
// Before: O(n²) - slow for large arrays
function findDuplicates(arr) {
  const duplicates = [];
  for (let i = 0; i < arr.length; i++) {
    for (let j = i + 1; j < arr.length; j++) {
      if (arr[i] === arr[j]) {
        duplicates.push(arr[i]);
      }
    }
  }
  return duplicates;
}

// After: O(n) - much faster
function findDuplicates(arr) {
  const seen = new Set();
  const duplicates = new Set();

  for (const item of arr) {
    if (seen.has(item)) {
      duplicates.add(item);
    } else {
      seen.add(item);
    }
  }

  return Array.from(duplicates);
}
```

**Lazy loading**:
```javascript
// Before: Load all data upfront
const allUsers = await User.findAll();
const allPosts = await Post.findAll();

// After: Load on demand
async function getUserWithPosts(userId) {
  const user = await User.findById(userId);
  // Only load posts when needed
  if (needsPosts) {
    user.posts = await Post.findByUserId(userId);
  }
  return user;
}
```

**Pagination**:
```javascript
// Before: Load all results
const results = await db.query('SELECT * FROM large_table');

// After: Paginate
const page = 1;
const pageSize = 100;
const results = await db.query(
  'SELECT * FROM large_table LIMIT $1 OFFSET $2',
  [pageSize, (page - 1) * pageSize]
);
```

#### Async Optimization

**Parallel execution**:
```javascript
// Before: Sequential (slow)
const user = await fetchUser();
const orders = await fetchOrders();
const payments = await fetchPayments();
// Total time: time(user) + time(orders) + time(payments)

// After: Parallel (fast)
const [user, orders, payments] = await Promise.all([
  fetchUser(),
  fetchOrders(),
  fetchPayments()
]);
// Total time: max(time(user), time(orders), time(payments))
```

**Batch processing**:
```javascript
// Before: Process one at a time
for (const item of items) {
  await processItem(item);  // Slow for many items
}

// After: Process in batches
const batchSize = 10;
for (let i = 0; i < items.length; i += batchSize) {
  const batch = items.slice(i, i + batchSize);
  await Promise.all(batch.map(item => processItem(item)));
}
```

### 5. Load Testing

Verify optimizations under load:

**Load Testing Tools**:

**Apache Bench**:
```bash
# Simple load test
ab -n 10000 -c 100 http://localhost:3000/api/endpoint

# With keep-alive
ab -n 10000 -c 100 -k http://localhost:3000/api/endpoint

# POST with data
ab -n 1000 -c 10 -p data.json -T application/json http://localhost:3000/api/endpoint
```

**k6 (recommended)**:
```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },   // Ramp up to 100 users
    { duration: '5m', target: 100 },   // Stay at 100 users
    { duration: '2m', target: 200 },   // Ramp up to 200 users
    { duration: '5m', target: 200 },   // Stay at 200 users
    { duration: '2m', target: 0 },     // Ramp down to 0
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% of requests < 500ms
    http_req_failed: ['rate<0.01'],    // Error rate < 1%
  },
};

export default function () {
  const response = http.get('http://localhost:3000/api/endpoint');

  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  sleep(1);
}
```

```bash
# Run load test
k6 run load-test.js

# With real-time monitoring
k6 run --out influxdb=http://localhost:8086/k6 load-test.js
```

**Artillery**:
```yaml
# load-test.yml
config:
  target: 'http://localhost:3000'
  phases:
    - duration: 120
      arrivalRate: 10
      name: "Warm up"
    - duration: 300
      arrivalRate: 50
      name: "Sustained load"
    - duration: 120
      arrivalRate: 100
      name: "Peak load"

scenarios:
  - name: "API endpoints"
    flow:
      - get:
          url: "/api/users"
      - get:
          url: "/api/orders"
      - post:
          url: "/api/orders"
          json:
            userId: 123
            amount: 100
```

```bash
# Run test
artillery run load-test.yml

# With report
artillery run --output report.json load-test.yml
artillery report report.json
```

### 6. Monitor Performance Improvements

Compare before and after:

**Metrics to Compare**:
```markdown
## Before Optimization
- Response time P50: 200ms
- Response time P95: 800ms
- Response time P99: 2000ms
- Throughput: 100 req/s
- Error rate: 2%
- CPU usage: 80%
- Memory usage: 1.5GB

## After Optimization
- Response time P50: 50ms ✅ 75% improvement
- Response time P95: 200ms ✅ 75% improvement
- Response time P99: 500ms ✅ 75% improvement
- Throughput: 400 req/s ✅ 4x improvement
- Error rate: 0.1% ✅ 20x improvement
- CPU usage: 40% ✅ 50% reduction
- Memory usage: 800MB ✅ 47% reduction
```

**Monitoring Dashboard**:
```javascript
// Expose metrics for Prometheus
const promClient = require('prom-client');

// Response time histogram
const httpDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 2, 5]
});

// Throughput counter
const httpRequests = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

// Middleware to track metrics
app.use((req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;

    httpDuration.observe(
      { method: req.method, route: req.route?.path || req.path, status_code: res.statusCode },
      duration
    );

    httpRequests.inc({
      method: req.method,
      route: req.route?.path || req.path,
      status_code: res.statusCode
    });
  });

  next();
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', promClient.register.contentType);
  res.end(await promClient.register.metrics());
});
```

## Output Format

```markdown
# Performance Optimization Report: [Component Name]

## Summary
[Brief summary of optimization results]

## Performance Baseline

### Before Optimization
- **Response Time P50**: [value]ms
- **Response Time P95**: [value]ms
- **Response Time P99**: [value]ms
- **Throughput**: [value] req/s
- **Error Rate**: [value]%
- **CPU Usage**: [value]%
- **Memory Usage**: [value]MB

## Bottlenecks Identified

### Bottleneck 1: [Name]
- **Type**: [CPU|I/O|Memory|Network]
- **Location**: [file:line or component]
- **Impact**: [% of total time or resource usage]
- **Evidence**:
  \`\`\`
  [profiling data or logs showing bottleneck]
  \`\`\`

### Bottleneck 2: [Name]
[similar structure]

## Optimizations Implemented

### Optimization 1: [Name]
**Problem**: [what was slow]

**Solution**: [what was done]

**Code Changes**:
\`\`\`[language]
// Before
[original slow code]

// After
[optimized code]
\`\`\`

**Impact**:
- Response time: [before]ms → [after]ms ([%] improvement)
- Resource usage: [before] → [after] ([%] improvement)

### Optimization 2: [Name]
[similar structure]

## Performance After Optimization

### After Optimization
- **Response Time P50**: [value]ms ✅ [%] improvement
- **Response Time P95**: [value]ms ✅ [%] improvement
- **Response Time P99**: [value]ms ✅ [%] improvement
- **Throughput**: [value] req/s ✅ [x]x improvement
- **Error Rate**: [value]% ✅ [%] improvement
- **CPU Usage**: [value]% ✅ [%] reduction
- **Memory Usage**: [value]MB ✅ [%] reduction

## Load Testing Results

### Test Configuration
- **Tool**: [k6|artillery|ab]
- **Duration**: [duration]
- **Peak Load**: [number] concurrent users
- **Total Requests**: [number]

### Results
\`\`\`
[load test output]
\`\`\`

### Performance Under Load
[Description of how system performed under sustained load]

## Profiling Data

### CPU Profile
[Flame graph or top CPU-consuming functions]

### Memory Profile
[Heap snapshots or memory allocation patterns]

### Query Performance
[Database query analysis results]

## Monitoring Setup

### Metrics Added
- [Metric 1]: Tracks [what]
- [Metric 2]: Tracks [what]

### Dashboards Created
- [Dashboard 1]: [URL and description]
- [Dashboard 2]: [URL and description]

### Alerts Configured
- [Alert 1]: Triggers when [condition]
- [Alert 2]: Triggers when [condition]

## Recommendations

### Additional Optimizations
1. [Optimization 1]: [Expected impact]
2. [Optimization 2]: [Expected impact]

### Monitoring
1. [What to monitor]
2. [What thresholds to set]

### Future Improvements
1. [Long-term improvement 1]
2. [Long-term improvement 2]

## Files Modified
- [file1]: [what was changed]
- [file2]: [what was changed]

## Verification Steps

### How to Verify
1. [Step 1]
2. [Step 2]

### Expected Behavior
[What should be observed]

## Next Steps
1. [Next step 1]
2. [Next step 2]
```

## Error Handling

**Optimization Degrades Performance**:
If optimization makes things slower:
1. Rollback immediately
2. Re-profile to understand why
3. Check for introduced overhead
4. Verify test methodology

**Cannot Reproduce Performance Issue**:
If issue only occurs in production:
1. Compare production vs test environment
2. Check production load patterns
3. Analyze production metrics
4. Consider production data characteristics

**Optimization Introduces Bugs**:
If optimization causes errors:
1. Rollback optimization
2. Add comprehensive tests
3. Implement optimization incrementally
4. Verify correctness at each step

## Integration with Other Operations

- **Before**: Use `/debug diagnose` to identify performance issues
- **Before**: Use `/debug analyze-logs` to understand performance patterns
- **After**: Use `/debug fix` to implement optimizations
- **Related**: Use `/debug memory` for memory-specific optimization

## Agent Utilization

This operation leverages the **10x-fullstack-engineer** agent for:
- Identifying performance bottlenecks across the stack
- Suggesting appropriate optimization strategies
- Implementing code optimizations
- Designing comprehensive load tests
- Interpreting profiling data
