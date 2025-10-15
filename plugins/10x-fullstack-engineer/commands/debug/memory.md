# Memory Operation - Memory Leak Detection and Optimization

You are executing the **memory** operation to detect memory leaks, analyze memory usage patterns, and optimize memory consumption.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'memory' operation name)

Expected format: `component:"component-name" [symptom:"growing-heap|high-usage|oom"] [duration:"observation-period"] [threshold:"max-memory-mb"] [profile:"heap|allocation"]`

## Workflow

### 1. Identify Memory Symptoms

Recognize signs of memory issues:

**Common Memory Symptoms**:

**Growing Heap (Memory Leak)**:
```bash
# Monitor memory over time
while true; do
  ps aux | grep node | grep -v grep | awk '{print $6/1024 " MB"}'
  sleep 60
done

# If memory grows continuously → Memory leak
```

**High Memory Usage**:
```bash
# Check current memory usage
free -h
ps aux --sort=-%mem | head -20

# Container memory
docker stats container-name

# Kubernetes pod memory
kubectl top pods
```

**Out of Memory (OOM)**:
```bash
# Check for OOM kills in logs
dmesg | grep -i "out of memory"
dmesg | grep -i "killed process"

# Kubernetes OOM events
kubectl get events | grep OOMKilled

# Docker OOM
docker inspect container-name | grep OOMKilled
```

**Memory Usage Pattern Analysis**:
```javascript
// Log memory usage periodically
setInterval(() => {
  const usage = process.memoryUsage();
  console.log('[MEMORY]', {
    rss: Math.round(usage.rss / 1024 / 1024) + 'MB',
    heapTotal: Math.round(usage.heapTotal / 1024 / 1024) + 'MB',
    heapUsed: Math.round(usage.heapUsed / 1024 / 1024) + 'MB',
    external: Math.round(usage.external / 1024 / 1024) + 'MB',
    timestamp: new Date().toISOString()
  });
}, 10000);  // Every 10 seconds
```

### 2. Capture Memory Profiles

Use profiling tools to understand memory usage:

#### Node.js Memory Profiling

**Heap Snapshots**:
```javascript
// Take heap snapshot programmatically
const v8 = require('v8');
const fs = require('fs');

function takeHeapSnapshot(filename) {
  const snapshot = v8.writeHeapSnapshot(filename);
  console.log('Heap snapshot written to:', snapshot);
  return snapshot;
}

// Take snapshot before and after operation
takeHeapSnapshot('before.heapsnapshot');
await operationThatLeaks();
takeHeapSnapshot('after.heapsnapshot');

// Compare in Chrome DevTools > Memory > Load snapshots
```

**Chrome DevTools**:
```bash
# Start Node with inspector
node --inspect app.js

# Open chrome://inspect in Chrome
# Click "Open dedicated DevTools for Node"
# Go to Memory tab
# Take heap snapshots
# Compare snapshots to find leaks
```

**Clinic.js HeapProfiler**:
```bash
# Install
npm install -g clinic

# Profile heap
clinic heapprofiler -- node app.js

# Run operations that cause memory growth
# Stop app (Ctrl+C)

# View report
clinic heapprofiler --visualize-only <PID>.clinic-heapprofiler
```

**Use memory check utility script**:
```bash
# Run comprehensive memory analysis
./commands/debug/.scripts/memory-check.sh \
  --app node_app \
  --duration 300 \
  --interval 10 \
  --threshold 1024

# Output: Memory growth chart, leak report, heap snapshots
```

#### Python Memory Profiling

**Memory Profiler**:
```python
from memory_profiler import profile

@profile
def memory_intensive_function():
    large_list = []
    for i in range(1000000):
        large_list.append(i)
    return large_list

# Run with: python -m memory_profiler script.py
```

**Tracemalloc**:
```python
import tracemalloc

# Start tracing
tracemalloc.start()

# Code to profile
result = memory_intensive_operation()

# Get current memory usage
current, peak = tracemalloc.get_traced_memory()
print(f"Current: {current / 1024 / 1024:.1f}MB")
print(f"Peak: {peak / 1024 / 1024:.1f}MB")

# Get top memory allocations
snapshot = tracemalloc.take_snapshot()
top_stats = snapshot.statistics('lineno')

for stat in top_stats[:10]:
    print(stat)

tracemalloc.stop()
```

**Objgraph**:
```python
import objgraph

# Show most common types
objgraph.show_most_common_types()

# Find objects that might be leaking
objgraph.show_growth()

# Run operation
do_operation()

# Show growth
objgraph.show_growth()

# Generate reference graph
objgraph.show_refs([obj], filename='refs.png')
```

### 3. Analyze Memory Leaks

Identify sources of memory leaks:

#### Common Memory Leak Patterns

**1. Event Listeners Not Removed**:
```javascript
// LEAK: Event listener never removed
class Component {
  constructor() {
    window.addEventListener('resize', this.handleResize);
  }

  handleResize() {
    // Handle resize
  }

  // Missing cleanup!
}

// FIX: Remove event listener
class Component {
  constructor() {
    this.handleResize = this.handleResize.bind(this);
    window.addEventListener('resize', this.handleResize);
  }

  handleResize() {
    // Handle resize
  }

  destroy() {
    window.removeEventListener('resize', this.handleResize);
  }
}
```

**2. Timers Not Cleared**:
```javascript
// LEAK: Timer keeps running
class DataPoller {
  start() {
    setInterval(() => {
      this.fetchData();
    }, 5000);
  }

  // No way to stop!
}

// FIX: Store timer reference and clear
class DataPoller {
  start() {
    this.intervalId = setInterval(() => {
      this.fetchData();
    }, 5000);
  }

  stop() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }
}
```

**3. Closures Holding References**:
```javascript
// LEAK: Closure holds large object
function createLeak() {
  const largeData = new Array(1000000).fill('data');

  return function() {
    console.log(largeData[0]);  // Holds entire array
  };
}

// FIX: Only capture what's needed
function noLeak() {
  const largeData = new Array(1000000).fill('data');
  const firstItem = largeData[0];  // Capture only what's needed

  return function() {
    console.log(firstItem);  // Only holds one item
  };
}
```

**4. Unbounded Caches**:
```javascript
// LEAK: Cache grows without limit
const cache = {};

function cacheData(key, value) {
  cache[key] = value;  // Never evicted
}

// FIX: Use LRU cache with size limit
const LRU = require('lru-cache');

const cache = new LRU({
  max: 1000,  // Max 1000 items
  maxAge: 1000 * 60 * 60,  // 1 hour TTL
  updateAgeOnGet: true
});

function cacheData(key, value) {
  cache.set(key, value);
}
```

**5. Global Variables**:
```javascript
// LEAK: Global accumulates data
global.userData = [];

function addUser(user) {
  global.userData.push(user);  // Never cleaned up
}

// FIX: Use scoped storage with cleanup
class UserStore {
  constructor() {
    this.users = new Map();
  }

  addUser(user) {
    this.users.set(user.id, user);
  }

  removeUser(userId) {
    this.users.delete(userId);
  }

  clear() {
    this.users.clear();
  }
}
```

**6. Detached DOM Nodes**:
```javascript
// LEAK: DOM nodes referenced after removal
const elements = [];

function createElements() {
  const div = document.createElement('div');
  document.body.appendChild(div);
  elements.push(div);  // Holds reference
}

function removeElements() {
  elements.forEach(el => el.remove());
  // elements array still holds references!
}

// FIX: Clear references
function removeElements() {
  elements.forEach(el => el.remove());
  elements.length = 0;  // Clear array
}
```

**7. Promise Chains**:
```javascript
// LEAK: Long promise chain holds memory
let chain = Promise.resolve();

function addToChain(task) {
  chain = chain.then(() => task());  // Chain grows indefinitely
}

// FIX: Don't chain indefinitely
const queue = [];
let processing = false;

async function addToQueue(task) {
  queue.push(task);

  if (!processing) {
    processing = true;
    while (queue.length > 0) {
      const task = queue.shift();
      await task();
    }
    processing = false;
  }
}
```

#### Finding Leaks with Heap Diff

**Compare Heap Snapshots**:
```javascript
// Take snapshots over time
const v8 = require('v8');

// Baseline
global.gc();  // Force garbage collection
const baseline = v8.writeHeapSnapshot('baseline.heapsnapshot');

// After some operations
await performOperations();

global.gc();
const after = v8.writeHeapSnapshot('after.heapsnapshot');

// Load both in Chrome DevTools
// Select "Comparison" view
// Look for objects that increased significantly
```

**Automated Leak Detection**:
```javascript
const memwatch = require('memwatch-next');

memwatch.on('leak', (info) => {
  console.error('Memory leak detected:', info);
  // info contains:
  // - growth: bytes
  // - reason: description
});

memwatch.on('stats', (stats) => {
  console.log('Memory stats:', {
    current_base: stats.current_base,
    estimated_base: stats.estimated_base,
    min: stats.min,
    max: stats.max
  });
});
```

### 4. Optimize Memory Usage

Implement memory optimizations:

#### Reduce Memory Footprint

**1. Stream Large Data**:
```javascript
// BEFORE: Load entire file into memory
const fs = require('fs').promises;

async function processFile(path) {
  const content = await fs.readFile(path, 'utf8');  // Entire file in memory
  const lines = content.split('\n');

  for (const line of lines) {
    processLine(line);
  }
}

// AFTER: Stream line by line
const fs = require('fs');
const readline = require('readline');

async function processFile(path) {
  const fileStream = fs.createReadStream(path);
  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  for await (const line of rl) {
    processLine(line);  // Process one line at a time
  }
}
```

**2. Use Efficient Data Structures**:
```javascript
// BEFORE: Array for lookups (slow and memory-inefficient)
const users = [
  { id: 1, name: 'Alice' },
  { id: 2, name: 'Bob' },
  // ... thousands more
];

function findUser(id) {
  return users.find(u => u.id === id);  // O(n) lookup
}

// AFTER: Map for O(1) lookups
const users = new Map([
  [1, { id: 1, name: 'Alice' }],
  [2, { id: 2, name: 'Bob' }],
  // ... thousands more
]);

function findUser(id) {
  return users.get(id);  // O(1) lookup
}
```

**3. Paginate Database Queries**:
```javascript
// BEFORE: Load all records
const allUsers = await db.users.findAll();  // Could be millions
processUsers(allUsers);

// AFTER: Process in batches
const batchSize = 1000;
let offset = 0;

while (true) {
  const users = await db.users.findAll({
    limit: batchSize,
    offset: offset
  });

  if (users.length === 0) break;

  processUsers(users);  // Process batch
  offset += batchSize;

  // Allow GC between batches
  await new Promise(resolve => setImmediate(resolve));
}
```

**4. Weak References for Caches**:
```javascript
// BEFORE: Strong references prevent GC
const cache = new Map();

function cacheObject(key, obj) {
  cache.set(key, obj);  // Prevents GC even if obj unused elsewhere
}

// AFTER: Weak references allow GC
const cache = new WeakMap();

function cacheObject(key, obj) {
  cache.set(key, obj);  // Allows GC if obj has no other references
}
```

**5. Object Pooling**:
```javascript
// BEFORE: Create new objects frequently
function processRequests(requests) {
  for (const req of requests) {
    const processor = new RequestProcessor();  // New object each time
    processor.process(req);
  }
}

// AFTER: Reuse objects with pool
class ObjectPool {
  constructor(factory, size) {
    this.factory = factory;
    this.pool = Array(size).fill(null).map(() => factory());
    this.available = [...this.pool];
  }

  acquire() {
    if (this.available.length === 0) {
      return this.factory();  // Create new if pool empty
    }
    return this.available.pop();
  }

  release(obj) {
    obj.reset();  // Reset state
    this.available.push(obj);
  }
}

const processorPool = new ObjectPool(() => new RequestProcessor(), 10);

function processRequests(requests) {
  for (const req of requests) {
    const processor = processorPool.acquire();
    processor.process(req);
    processorPool.release(processor);
  }
}
```

#### Memory Limits and Monitoring

**Set Memory Limits**:
```bash
# Node.js: Increase max old space size
node --max-old-space-size=4096 app.js  # 4GB

# Container: Set memory limit
docker run --memory="2g" app:latest

# Kubernetes: Set resource limits
resources:
  limits:
    memory: "2Gi"
  requests:
    memory: "1Gi"
```

**Monitor Memory Usage**:
```javascript
const promClient = require('prom-client');

// Memory usage gauge
const memoryGauge = new promClient.Gauge({
  name: 'nodejs_memory_usage_bytes',
  help: 'Memory usage in bytes',
  labelNames: ['type']
});

// Update memory metrics periodically
setInterval(() => {
  const usage = process.memoryUsage();

  memoryGauge.set({ type: 'rss' }, usage.rss);
  memoryGauge.set({ type: 'heap_total' }, usage.heapTotal);
  memoryGauge.set({ type: 'heap_used' }, usage.heapUsed);
  memoryGauge.set({ type: 'external' }, usage.external);
}, 10000);

// Alert on high memory
if (process.memoryUsage().heapUsed / process.memoryUsage().heapTotal > 0.9) {
  console.error('ALERT: Heap usage above 90%');
}
```

### 5. Garbage Collection Tuning

Optimize garbage collection behavior:

**Monitor GC Activity**:
```bash
# Node.js: Enable GC logging
node --trace-gc app.js

# More detailed GC logging
node --trace-gc --trace-gc-verbose app.js

# Log GC to file
node --trace-gc app.js 2> gc.log
```

**Analyze GC Logs**:
```javascript
// Parse GC logs
const gcLog = `
[12345] Scavenge 150.2 (153.4) -> 145.8 (158.4) MB, 2.3 / 0.0 ms
[12346] Mark-sweep 158.4 (165.4) -> 152.1 (165.4) MB, 15.2 / 0.0 ms
`;

// Look for:
// - Frequent GC (every few seconds)
// - Long GC pauses (> 100ms)
// - Growing heap after GC
```

**Force GC (for testing)**:
```javascript
// Expose GC to code
// Start with: node --expose-gc app.js

if (global.gc) {
  console.log('Before GC:', process.memoryUsage().heapUsed);
  global.gc();
  console.log('After GC:', process.memoryUsage().heapUsed);
}
```

**GC-Friendly Code Patterns**:
```javascript
// AVOID: Creating many short-lived objects
function process(data) {
  for (let i = 0; i < data.length; i++) {
    const temp = { value: data[i] * 2 };  // New object each iteration
    doSomething(temp);
  }
}

// PREFER: Reuse objects or use primitives
function process(data) {
  const temp = { value: 0 };  // Single object
  for (let i = 0; i < data.length; i++) {
    temp.value = data[i] * 2;  // Reuse
    doSomething(temp);
  }
}
```

### 6. Verify Memory Fixes

Test that memory issues are resolved:

**Memory Leak Test**:
```javascript
// Run operation repeatedly and check memory
async function testForMemoryLeak() {
  const iterations = 100;
  const measurements = [];

  for (let i = 0; i < iterations; i++) {
    // Force GC before measurement
    if (global.gc) global.gc();

    const before = process.memoryUsage().heapUsed;

    // Run operation that might leak
    await operationToTest();

    // Force GC after operation
    if (global.gc) global.gc();

    const after = process.memoryUsage().heapUsed;
    const growth = after - before;

    measurements.push({ iteration: i, growth });

    console.log(`Iteration ${i}: ${growth} bytes growth`);
  }

  // Analyze trend
  const avgGrowth = measurements.reduce((sum, m) => sum + m.growth, 0) / iterations;

  if (avgGrowth > 1024 * 1024) {  // > 1MB per iteration
    console.error('LEAK DETECTED: Average growth', avgGrowth, 'bytes per iteration');
  } else {
    console.log('NO LEAK: Average growth', avgGrowth, 'bytes per iteration');
  }
}
```

**Load Test with Memory Monitoring**:
```javascript
// Monitor memory during load test
const startMemory = process.memoryUsage();
const memoryReadings = [];

const interval = setInterval(() => {
  const usage = process.memoryUsage();
  memoryReadings.push({
    timestamp: Date.now(),
    heapUsed: usage.heapUsed,
    rss: usage.rss
  });
}, 1000);

// Run load test
await runLoadTest(10000);  // 10,000 requests

clearInterval(interval);

// Analyze memory trend
const trend = calculateTrend(memoryReadings);
if (trend.slope > 0) {
  console.warn('Memory trending upward:', trend);
} else {
  console.log('Memory stable or decreasing');
}
```

## Output Format

```markdown
# Memory Analysis Report: [Component Name]

## Summary
[Brief summary of memory issues found and fixes applied]

## Memory Symptoms

### Initial Observations
- **Symptom**: [growing-heap|high-usage|oom|other]
- **Severity**: [critical|high|medium|low]
- **Duration**: [how long issue has been occurring]
- **Impact**: [user-facing impact]

### Memory Baseline
- **RSS**: [value]MB
- **Heap Total**: [value]MB
- **Heap Used**: [value]MB
- **External**: [value]MB
- **Timestamp**: [when measured]

## Memory Profile Analysis

### Heap Snapshots
- **Snapshot 1** (baseline): [filename]
  - Heap size: [value]MB
  - Object count: [number]

- **Snapshot 2** (after operations): [filename]
  - Heap size: [value]MB
  - Object count: [number]
  - Growth: +[value]MB (+[%])

### Top Memory Consumers
1. **[Object Type 1]**: [size]MB ([count] objects)
   - Location: [file:line]
   - Reason: [why consuming memory]

2. **[Object Type 2]**: [size]MB ([count] objects)
   - Location: [file:line]
   - Reason: [why consuming memory]

## Memory Leaks Identified

### Leak 1: [Leak Name]
**Type**: [event-listeners|timers|closures|cache|globals|dom|promises]

**Location**:
\`\`\`[language]:[file]:[line]
[code snippet showing leak]
\`\`\`

**Evidence**:
- Memory grows by [amount] per [operation/time]
- [Number] objects retained incorrectly
- Heap diff shows [specific objects] accumulating

**Root Cause**: [detailed explanation]

### Leak 2: [Leak Name]
[similar structure]

## Fixes Implemented

### Fix 1: [Fix Name]
**Problem**: [what was leaking]

**Solution**: [what was done]

**Code Changes**:
\`\`\`[language]
// Before (leaking)
[original code]

// After (fixed)
[fixed code]
\`\`\`

**Impact**:
- Memory reduction: [before]MB → [after]MB ([%] improvement)
- Objects freed: [number]
- Leak rate: [before] → [after]

### Fix 2: [Fix Name]
[similar structure]

## Memory Optimizations

### Optimization 1: [Name]
**Approach**: [stream|efficient-data-structure|pagination|weak-refs|pooling]

**Implementation**:
\`\`\`[language]
[optimized code]
\`\`\`

**Results**:
- Memory usage: [before]MB → [after]MB ([%] reduction)
- GC frequency: [before] → [after]
- GC pause time: [before]ms → [after]ms

### Optimization 2: [Name]
[similar structure]

## Memory After Fixes

### Current Memory Profile
- **RSS**: [value]MB ✅ [%] reduction
- **Heap Total**: [value]MB ✅ [%] reduction
- **Heap Used**: [value]MB ✅ [%] reduction
- **External**: [value]MB ✅ [%] reduction

### Memory Stability Test
- **Test Duration**: [duration]
- **Operations**: [number] operations performed
- **Memory Growth**: [value]MB ([acceptable|concerning])
- **Leak Rate**: [value]MB/hour
- **Conclusion**: [leak resolved|leak reduced|no leak]

### Garbage Collection Metrics
- **GC Frequency**: [value] per minute
- **Average GC Pause**: [value]ms
- **Max GC Pause**: [value]ms
- **GC Impact**: [acceptable|needs tuning]

## Load Test Results

### Test Configuration
- **Duration**: [duration]
- **Load**: [number] concurrent users
- **Operations**: [number] total operations

### Memory Behavior Under Load
[Description of how memory behaved during load test]

### Peak Memory Usage
- **Peak RSS**: [value]MB
- **Peak Heap**: [value]MB
- **When**: [time during test]
- **Recovery**: [how memory returned to baseline]

## Monitoring Setup

### Memory Metrics Added
- **Metric 1**: [name] - tracks [what]
- **Metric 2**: [name] - tracks [what]

### Alerts Configured
- **Alert 1**: Memory usage > [threshold]MB
- **Alert 2**: Heap growth > [rate]MB/hour
- **Alert 3**: GC pause > [duration]ms

### Dashboard Created
- **URL**: [dashboard URL]
- **Metrics**: [list of metrics displayed]

## Recommendations

### Immediate Actions
1. [Action 1]
2. [Action 2]

### Memory Limits
- **Recommended heap size**: [value]MB
- **Container memory limit**: [value]MB
- **Rationale**: [why this size]

### Future Monitoring
1. [What to monitor]
2. [What thresholds to set]

### Additional Optimizations
1. [Optimization 1]: [expected benefit]
2. [Optimization 2]: [expected benefit]

## Files Modified
- [file1]: [what was changed]
- [file2]: [what was changed]

## Verification Steps

### How to Verify Fix
1. [Step 1]
2. [Step 2]

### Expected Behavior
[What should be observed after fix]

### How to Monitor
\`\`\`bash
[commands to monitor memory]
\`\`\`

## Appendices

### A. Memory Profile Files
- [baseline.heapsnapshot]
- [after-fix.heapsnapshot]

### B. GC Logs
\`\`\`
[relevant GC log excerpts]
\`\`\`

### C. Memory Growth Chart
\`\`\`
[ASCII chart or description of memory growth over time]
\`\`\`
```

## Error Handling

**Cannot Reproduce Leak**:
If leak doesn't reproduce in testing:
1. Check if leak is load-dependent
2. Verify test duration is sufficient
3. Check if production data is different
4. Consider environment differences

**Fix Doesn't Resolve Leak**:
If leak persists after fix:
1. Re-profile to identify remaining leaks
2. Check if multiple leak sources exist
3. Verify fix was applied correctly
4. Consider if leak is in dependency

**Performance Degrades After Fix**:
If memory fix hurts performance:
1. Profile performance impact
2. Consider trade-offs
3. Look for alternative optimizations
4. Test with realistic workload

## Integration with Other Operations

- **Before**: Use `/debug diagnose` to identify memory symptoms
- **Before**: Use `/debug analyze-logs` to find OOM events
- **After**: Use `/debug fix` to implement memory fixes
- **Related**: Use `/debug performance` to ensure fixes don't hurt performance

## Agent Utilization

This operation leverages the **10x-fullstack-engineer** agent for:
- Identifying memory leak patterns
- Analyzing heap snapshots
- Suggesting memory optimizations
- Implementing efficient data structures
- GC tuning recommendations
