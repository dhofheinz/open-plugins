# Backend Optimization Operation

You are executing the **backend** operation to optimize backend API performance, algorithms, caching, and concurrency handling.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'backend' operation name)

Expected format: `target:"api|algorithms|caching|concurrency|all" [endpoints:"endpoint-list"] [load_profile:"low|medium|high"] [priority:"low|medium|high|critical"]`

**Parameter definitions**:
- `target` (required): What to optimize - `api`, `algorithms`, `caching`, `concurrency`, or `all`
- `endpoints` (optional): Specific API endpoints to optimize (comma-separated, e.g., "/api/users,/api/posts")
- `load_profile` (optional): Expected load level - `low`, `medium`, `high` (default: medium)
- `priority` (optional): Optimization priority - `low`, `medium`, `high`, `critical` (default: high)

## Workflow

### 1. Identify Backend Framework and Runtime

Detect backend technology:
```bash
# Check package.json for framework
grep -E "express|fastify|koa|nestjs|hapi" package.json 2>/dev/null

# Check for runtime
node --version 2>/dev/null || echo "No Node.js"
python --version 2>/dev/null || echo "No Python"
go version 2>/dev/null || echo "No Go"
ruby --version 2>/dev/null || echo "No Ruby"

# Check for web framework files
ls -la server.js app.js main.py app.py main.go 2>/dev/null
```

### 2. Profile API Performance

**Node.js Profiling**:
```bash
# Start application with profiling
node --prof app.js

# Or use clinic.js for comprehensive profiling
npx clinic doctor -- node app.js
# Then make requests to your API

# Process the profile
node --prof-process isolate-*.log > profile.txt

# Use clinic.js flame graph
npx clinic flame -- node app.js
```

**API Response Time Analysis**:
```bash
# Test endpoint response times
curl -w "@curl-format.txt" -o /dev/null -s "http://localhost:3000/api/users"

# curl-format.txt content:
# time_namelookup:  %{time_namelookup}\n
# time_connect:  %{time_connect}\n
# time_appconnect:  %{time_appconnect}\n
# time_pretransfer:  %{time_pretransfer}\n
# time_redirect:  %{time_redirect}\n
# time_starttransfer:  %{time_starttransfer}\n
# time_total:  %{time_total}\n

# Load test with k6
npx k6 run --vus 50 --duration 30s loadtest.js
```

**APM Tools** (if available):
- New Relic: Check transaction traces
- DataDog: Review APM dashboard
- Application Insights: Analyze dependencies

### 3. API Optimization

#### 3.1. Fix N+1 Query Problems

**Problem Detection**:
```javascript
// BEFORE (N+1 problem)
app.get('/api/users', async (req, res) => {
  const users = await User.findAll(); // 1 query

  for (const user of users) {
    // N additional queries (1 per user)
    user.posts = await Post.findAll({ where: { userId: user.id } });
  }

  res.json(users);
});
// Total: 1 + N queries for N users
```

**Solution - Eager Loading**:
```javascript
// AFTER (eager loading)
app.get('/api/users', async (req, res) => {
  const users = await User.findAll({
    include: [{ model: Post, as: 'posts' }] // Single query with JOIN
  });

  res.json(users);
});
// Total: 1 query
// Performance improvement: ~95% faster for 100 users
```

**Solution - DataLoader (for GraphQL or complex cases)**:
```javascript
const DataLoader = require('dataloader');

// Batch load posts by user IDs
const postLoader = new DataLoader(async (userIds) => {
  const posts = await Post.findAll({
    where: { userId: { $in: userIds } }
  });

  // Group posts by userId
  const postsByUserId = {};
  posts.forEach(post => {
    if (!postsByUserId[post.userId]) {
      postsByUserId[post.userId] = [];
    }
    postsByUserId[post.userId].push(post);
  });

  // Return posts in same order as userIds
  return userIds.map(id => postsByUserId[id] || []);
});

// Usage
app.get('/api/users', async (req, res) => {
  const users = await User.findAll();

  // Load posts in batch
  await Promise.all(
    users.map(async (user) => {
      user.posts = await postLoader.load(user.id);
    })
  );

  res.json(users);
});
// Total: 2 queries (users + batched posts)
```

#### 3.2. Implement Response Caching

**In-Memory Caching (Simple)**:
```javascript
const cache = new Map();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

function cacheMiddleware(key, ttl = CACHE_TTL) {
  return (req, res, next) => {
    const cacheKey = typeof key === 'function' ? key(req) : key;
    const cached = cache.get(cacheKey);

    if (cached && Date.now() - cached.timestamp < ttl) {
      return res.json(cached.data);
    }

    // Override res.json to cache the response
    const originalJson = res.json.bind(res);
    res.json = (data) => {
      cache.set(cacheKey, { data, timestamp: Date.now() });
      return originalJson(data);
    };

    next();
  };
}

// Usage
app.get('/api/users',
  cacheMiddleware(req => `users:${req.query.page || 1}`),
  async (req, res) => {
    const users = await User.findAll();
    res.json(users);
  }
);
```

**Redis Caching (Production)**:
```javascript
const Redis = require('ioredis');
const redis = new Redis(process.env.REDIS_URL);

async function cacheMiddleware(keyFn, ttl = 300) {
  return async (req, res, next) => {
    const cacheKey = keyFn(req);

    try {
      const cached = await redis.get(cacheKey);
      if (cached) {
        return res.json(JSON.parse(cached));
      }

      const originalJson = res.json.bind(res);
      res.json = async (data) => {
        await redis.setex(cacheKey, ttl, JSON.stringify(data));
        return originalJson(data);
      };

      next();
    } catch (error) {
      console.error('Cache error:', error);
      next(); // Continue without cache on error
    }
  };
}

// Usage with cache invalidation
app.get('/api/posts/:id', cacheMiddleware(req => `post:${req.params.id}`, 600), async (req, res) => {
  const post = await Post.findByPk(req.params.id);
  res.json(post);
});

app.put('/api/posts/:id', async (req, res) => {
  const post = await Post.update(req.body, { where: { id: req.params.id } });

  // Invalidate cache
  await redis.del(`post:${req.params.id}`);

  res.json(post);
});
```

#### 3.3. Add Request Compression

```javascript
const compression = require('compression');

app.use(compression({
  // Compress responses > 1KB
  threshold: 1024,
  // Compression level (0-9, higher = better compression but slower)
  level: 6,
  // Only compress certain content types
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  }
}));

// Typical compression results:
// - JSON responses: 70-80% size reduction
// - Text responses: 60-70% size reduction
// - Already compressed (images, video): minimal effect
```

#### 3.4. Implement Rate Limiting

```javascript
const rateLimit = require('express-rate-limit');

// General API rate limit
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per window
  message: 'Too many requests from this IP, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
});

// Stricter limit for expensive endpoints
const strictLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: 'Too many requests for this resource'
});

app.use('/api/', apiLimiter);
app.use('/api/search', strictLimiter);
app.use('/api/export', strictLimiter);
```

#### 3.5. Optimize JSON Serialization

```javascript
// BEFORE (default JSON.stringify)
app.get('/api/users', async (req, res) => {
  const users = await User.findAll();
  res.json(users); // Uses JSON.stringify
});

// AFTER (fast-json-stringify for known schemas)
const fastJson = require('fast-json-stringify');

const userSchema = fastJson({
  type: 'array',
  items: {
    type: 'object',
    properties: {
      id: { type: 'integer' },
      name: { type: 'string' },
      email: { type: 'string' },
      createdAt: { type: 'string', format: 'date-time' }
    }
  }
});

app.get('/api/users', async (req, res) => {
  const users = await User.findAll();
  res.set('Content-Type', 'application/json');
  res.send(userSchema(users)); // 2-3x faster serialization
});
```

### 4. Algorithm Optimization

#### 4.1. Replace Inefficient Algorithms

**Example: Array Search Optimization**

```javascript
// BEFORE (O(n) lookup for each iteration = O(n²))
function enrichUsers(users, userData) {
  return users.map(user => ({
    ...user,
    data: userData.find(d => d.userId === user.id) // O(n) search
  }));
}
// Time complexity: O(n²) for n users

// AFTER (O(n) with Map)
function enrichUsers(users, userData) {
  const dataMap = new Map(
    userData.map(d => [d.userId, d])
  ); // O(n) to build map

  return users.map(user => ({
    ...user,
    data: dataMap.get(user.id) // O(1) lookup
  }));
}
// Time complexity: O(n)
// Performance improvement: 100x for 1000 users
```

**Example: Sorting Optimization**

```javascript
// BEFORE (multiple array iterations)
function getTopUsers(users) {
  return users
    .filter(u => u.isActive) // O(n)
    .map(u => ({ ...u, score: calculateScore(u) })) // O(n)
    .sort((a, b) => b.score - a.score) // O(n log n)
    .slice(0, 10); // O(1)
}
// Total: O(n log n)

// AFTER (single pass + partial sort)
function getTopUsers(users) {
  const scored = [];

  for (const user of users) {
    if (!user.isActive) continue;

    const score = calculateScore(user);
    scored.push({ ...user, score });

    // Keep only top 10 (partial sort)
    if (scored.length > 10) {
      scored.sort((a, b) => b.score - a.score);
      scored.length = 10;
    }
  }

  return scored.sort((a, b) => b.score - a.score);
}
// Total: O(n) average case
// Performance improvement: 10x for 10,000 users
```

#### 4.2. Memoization for Expensive Computations

```javascript
// Memoization decorator
function memoize(fn, keyFn = (...args) => JSON.stringify(args)) {
  const cache = new Map();

  return function(...args) {
    const key = keyFn(...args);

    if (cache.has(key)) {
      return cache.get(key);
    }

    const result = fn.apply(this, args);
    cache.set(key, result);
    return result;
  };
}

// BEFORE (recalculates every time)
function calculateUserScore(user) {
  // Expensive calculation
  let score = 0;
  score += user.posts * 10;
  score += user.comments * 5;
  score += user.likes * 2;
  score += complexAlgorithm(user.activity);
  return score;
}

// AFTER (memoized)
const calculateUserScore = memoize(
  (user) => {
    let score = 0;
    score += user.posts * 10;
    score += user.comments * 5;
    score += user.likes * 2;
    score += complexAlgorithm(user.activity);
    return score;
  },
  (user) => user.id // Cache key
);

// Subsequent calls with same user.id return cached result
```

### 5. Concurrency Optimization

#### 5.1. Async/Await Parallelization

```javascript
// BEFORE (sequential - slow)
async function getUserData(userId) {
  const user = await User.findByPk(userId); // 50ms
  const posts = await Post.findAll({ where: { userId } }); // 80ms
  const comments = await Comment.findAll({ where: { userId } }); // 60ms

  return { user, posts, comments };
}
// Total time: 50 + 80 + 60 = 190ms

// AFTER (parallel - fast)
async function getUserData(userId) {
  const [user, posts, comments] = await Promise.all([
    User.findByPk(userId), // 50ms
    Post.findAll({ where: { userId } }), // 80ms
    Comment.findAll({ where: { userId } }) // 60ms
  ]);

  return { user, posts, comments };
}
// Total time: max(50, 80, 60) = 80ms
// Performance improvement: 2.4x faster
```

#### 5.2. Worker Threads for CPU-Intensive Tasks

```javascript
const { Worker } = require('worker_threads');

// cpu-intensive-worker.js
const { parentPort, workerData } = require('worker_threads');

function cpuIntensiveTask(data) {
  // Complex computation
  let result = 0;
  for (let i = 0; i < data.iterations; i++) {
    result += Math.sqrt(i) * Math.sin(i);
  }
  return result;
}

parentPort.postMessage(cpuIntensiveTask(workerData));

// Main application
function runWorker(workerData) {
  return new Promise((resolve, reject) => {
    const worker = new Worker('./cpu-intensive-worker.js', { workerData });

    worker.on('message', resolve);
    worker.on('error', reject);
    worker.on('exit', (code) => {
      if (code !== 0) {
        reject(new Error(`Worker stopped with exit code ${code}`));
      }
    });
  });
}

// BEFORE (blocks event loop)
app.post('/api/process', async (req, res) => {
  const result = cpuIntensiveTask(req.body); // Blocks for 500ms
  res.json({ result });
});

// AFTER (offloaded to worker)
app.post('/api/process', async (req, res) => {
  const result = await runWorker(req.body); // Non-blocking
  res.json({ result });
});
// Main thread remains responsive
```

#### 5.3. Request Batching and Debouncing

```javascript
// Batch multiple requests into single database query
class BatchLoader {
  constructor(loadFn, delay = 10) {
    this.loadFn = loadFn;
    this.delay = delay;
    this.queue = [];
    this.timer = null;
  }

  load(key) {
    return new Promise((resolve, reject) => {
      this.queue.push({ key, resolve, reject });

      if (!this.timer) {
        this.timer = setTimeout(() => this.flush(), this.delay);
      }
    });
  }

  async flush() {
    const queue = this.queue;
    this.queue = [];
    this.timer = null;

    try {
      const keys = queue.map(item => item.key);
      const results = await this.loadFn(keys);

      queue.forEach((item, index) => {
        item.resolve(results[index]);
      });
    } catch (error) {
      queue.forEach(item => item.reject(error));
    }
  }
}

// Usage
const userLoader = new BatchLoader(async (userIds) => {
  // Single query for all user IDs
  const users = await User.findAll({
    where: { id: { $in: userIds } }
  });

  // Return in same order as requested
  return userIds.map(id => users.find(u => u.id === id));
});

// BEFORE (N separate queries)
app.get('/api/feed', async (req, res) => {
  const posts = await Post.findAll({ limit: 50 });

  for (const post of posts) {
    post.author = await User.findByPk(post.userId); // N queries
  }

  res.json(posts);
});

// AFTER (batched into 1 query)
app.get('/api/feed', async (req, res) => {
  const posts = await Post.findAll({ limit: 50 });

  await Promise.all(
    posts.map(async (post) => {
      post.author = await userLoader.load(post.userId); // Batched
    })
  );

  res.json(posts);
});
// Improvement: 50 queries → 2 queries (posts + batched users)
```

### 6. Response Streaming for Large Datasets

```javascript
const { Transform } = require('stream');

// BEFORE (loads entire dataset into memory)
app.get('/api/export/users', async (req, res) => {
  const users = await User.findAll(); // Loads all users into memory
  res.json(users); // May cause OOM for large datasets
});

// AFTER (streams data)
app.get('/api/export/users', async (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.write('[');

  let first = true;
  const stream = User.findAll({ stream: true }); // Database stream

  for await (const user of stream) {
    if (!first) res.write(',');
    res.write(JSON.stringify(user));
    first = false;
  }

  res.write(']');
  res.end();
});
// Memory usage: O(1) instead of O(n)
// Can handle millions of records
```

### 7. Optimize Middleware Stack

```javascript
// BEFORE (all middleware runs for all routes)
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(session({ /* config */ }));
app.use(passport.initialize());
app.use(passport.session());
app.use(cors());

app.get('/api/public/health', (req, res) => {
  res.json({ status: 'ok' });
  // Still parsed body, cookies, session unnecessarily
});

// AFTER (selective middleware)
const publicRouter = express.Router();
publicRouter.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

const apiRouter = express.Router();
apiRouter.use(bodyParser.json());
apiRouter.use(authenticate);
apiRouter.get('/users', async (req, res) => { /* ... */ });

app.use('/api/public', publicRouter);
app.use('/api', apiRouter);
// Health check endpoint has minimal overhead
```

### 8. Database Connection Management

```javascript
// BEFORE (creates new connection per request)
app.get('/api/users', async (req, res) => {
  const client = await pool.connect(); // Slow
  const result = await client.query('SELECT * FROM users');
  client.release();
  res.json(result.rows);
});

// AFTER (uses connection pool efficiently)
const { Pool } = require('pg');
const pool = new Pool({
  max: 20,
  min: 5,
  idleTimeoutMillis: 30000
});

app.get('/api/users', async (req, res) => {
  const result = await pool.query('SELECT * FROM users'); // Reuses connection
  res.json(result.rows);
});
// Connection acquisition: 50ms → 0.5ms
```

## Output Format

```markdown
# Backend Optimization Report: [Context]

**Optimization Date**: [Date]
**Backend**: [Framework and version]
**Runtime**: [Node.js/Python/Go version]
**Load Profile**: [low/medium/high]

## Executive Summary

[2-3 paragraphs summarizing findings and optimizations]

## Baseline Metrics

### API Performance

| Endpoint | p50 | p95 | p99 | RPS | Error Rate |
|----------|-----|-----|-----|-----|------------|
| GET /api/users | 120ms | 450ms | 980ms | 45 | 0.5% |
| POST /api/posts | 230ms | 780ms | 1800ms | 20 | 1.2% |
| GET /api/feed | 850ms | 2100ms | 4500ms | 12 | 2.3% |

### Resource Utilization
- **CPU**: 68% average
- **Memory**: 1.2GB / 2GB (60%)
- **Event Loop Lag**: 45ms average

## Optimizations Implemented

### 1. Fixed N+1 Query Problem in /api/feed

**Before**:
```javascript
const posts = await Post.findAll();
for (const post of posts) {
  post.author = await User.findByPk(post.userId); // N queries
}
// Result: 1 + 50 = 51 queries for 50 posts
```

**After**:
```javascript
const posts = await Post.findAll({
  include: [{ model: User, as: 'author' }]
});
// Result: 1 query with JOIN
```

**Impact**:
- **Before**: 850ms p50 response time
- **After**: 95ms p50 response time
- **Improvement**: 88.8% faster

### 2. Implemented Redis Caching

**Implementation**:
```javascript
const cacheMiddleware = (key, ttl) => async (req, res, next) => {
  const cached = await redis.get(key(req));
  if (cached) return res.json(JSON.parse(cached));

  const originalJson = res.json.bind(res);
  res.json = async (data) => {
    await redis.setex(key(req), ttl, JSON.stringify(data));
    return originalJson(data);
  };
  next();
};

app.get('/api/users',
  cacheMiddleware(req => `users:${req.query.page}`, 300),
  handler
);
```

**Impact**:
- **Cache Hit Rate**: 82% (after 24 hours)
- **Cached Response Time**: 5ms
- **Database Load Reduction**: 82%

### 3. Parallelized Independent Queries

**Before**:
```javascript
const user = await User.findByPk(userId); // 50ms
const posts = await Post.findAll({ where: { userId } }); // 80ms
const comments = await Comment.findAll({ where: { userId } }); // 60ms
// Total: 190ms
```

**After**:
```javascript
const [user, posts, comments] = await Promise.all([
  User.findByPk(userId),
  Post.findAll({ where: { userId } }),
  Comment.findAll({ where: { userId } })
]);
// Total: 80ms (max of parallel operations)
```

**Impact**: 57.9% faster (190ms → 80ms)

### 4. Added Response Compression

**Implementation**:
```javascript
app.use(compression({ level: 6, threshold: 1024 }));
```

**Impact**:
- **JSON Response Size**: 450KB → 95KB (78.9% reduction)
- **Network Transfer Time**: 180ms → 38ms (on 20Mbps connection)
- **Bandwidth Savings**: 79%

### 5. Optimized Algorithm Complexity

**Before (O(n²) lookup)**:
```javascript
users.map(user => ({
  ...user,
  data: userData.find(d => d.userId === user.id) // O(n) per iteration
}));
// Time: 2,400ms for 1,000 users
```

**After (O(n) with Map)**:
```javascript
const dataMap = new Map(userData.map(d => [d.userId, d]));
users.map(user => ({
  ...user,
  data: dataMap.get(user.id) // O(1) lookup
}));
// Time: 12ms for 1,000 users
```

**Impact**: 99.5% faster (2,400ms → 12ms)

## Results Summary

### Overall API Performance

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Avg Response Time (p50) | 285ms | 65ms | 77.2% faster |
| p95 Response Time | 1,100ms | 180ms | 83.6% faster |
| p99 Response Time | 3,200ms | 450ms | 85.9% faster |
| Throughput | 85 RPS | 320 RPS | 276% increase |
| Error Rate | 1.5% | 0.1% | 93.3% reduction |

### Endpoint-Specific Improvements

| Endpoint | Before (p50) | After (p50) | Improvement |
|----------|--------------|-------------|-------------|
| GET /api/users | 120ms | 8ms | 93.3% |
| GET /api/feed | 850ms | 95ms | 88.8% |
| POST /api/posts | 230ms | 65ms | 71.7% |

### Resource Utilization

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| CPU Usage | 68% | 32% | -53% |
| Memory Usage | 60% | 45% | -25% |
| Event Loop Lag | 45ms | 8ms | -82.2% |

## Load Testing Results

**Before Optimization**:
```
Requests: 5,000
Duration: 58.8s
RPS: 85
p95: 1,100ms
p99: 3,200ms
Errors: 75 (1.5%)
```

**After Optimization**:
```
Requests: 5,000
Duration: 15.6s
RPS: 320
p95: 180ms
p99: 450ms
Errors: 5 (0.1%)
```

**Improvement**: 276% more throughput, 83.6% faster p95

## Trade-offs and Considerations

**Caching Strategy**:
- **Benefit**: 82% reduction in database load
- **Trade-off**: Cache invalidation complexity, eventual consistency
- **Mitigation**: TTL-based expiration (5 minutes) acceptable for this use case

**Response Compression**:
- **Benefit**: 79% bandwidth savings
- **Trade-off**: ~5ms CPU overhead per request
- **Conclusion**: Worth it for responses > 1KB

**Algorithm Optimization**:
- **Benefit**: 99.5% faster for large datasets
- **Trade-off**: Increased memory usage (Map storage)
- **Conclusion**: Negligible memory increase, massive performance gain

## Monitoring Recommendations

**Key Metrics to Track**:

1. **Response Times**:
   ```javascript
   // Use middleware to track
   app.use((req, res, next) => {
     const start = Date.now();
     res.on('finish', () => {
       const duration = Date.now() - start;
       metrics.histogram('response_time', duration, {
         endpoint: req.path,
         method: req.method,
         status: res.statusCode
       });
     });
     next();
   });
   ```

2. **Cache Hit Rates**:
   ```javascript
   // Track Redis cache effectiveness
   const cacheStats = {
     hits: 0,
     misses: 0,
     hitRate: () => cacheStats.hits / (cacheStats.hits + cacheStats.misses)
   };
   ```

3. **Event Loop Lag**:
   ```javascript
   const { monitorEventLoopDelay } = require('perf_hooks');
   const h = monitorEventLoopDelay({ resolution: 20 });
   h.enable();

   setInterval(() => {
     console.log('Event loop delay:', h.mean / 1000000, 'ms');
   }, 60000);
   ```

4. **Memory Leaks**:
   ```javascript
   // Track memory usage trends
   setInterval(() => {
     const usage = process.memoryUsage();
     metrics.gauge('memory.heap_used', usage.heapUsed);
     metrics.gauge('memory.heap_total', usage.heapTotal);
   }, 60000);
   ```

### Alerts to Configure

- Response time p95 > 500ms
- Error rate > 1%
- Cache hit rate < 70%
- Event loop lag > 50ms
- Memory usage > 80%

## Next Steps

1. **Implement** worker threads for CPU-intensive report generation
2. **Consider** horizontal scaling with load balancer
3. **Evaluate** GraphQL migration for flexible data fetching
4. **Monitor** cache invalidation patterns for optimization
5. **Review** remaining slow endpoints for optimization opportunities
