# Database Optimization Operation

You are executing the **database** operation to optimize database queries, schema, indexes, and connection management.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'database' operation name)

Expected format: `target:"queries|schema|indexes|connections|all" [context:"specific-details"] [threshold:"time-in-ms"] [environment:"prod|staging|dev"]`

**Parameter definitions**:
- `target` (required): What to optimize - `queries`, `schema`, `indexes`, `connections`, or `all`
- `context` (optional): Specific context like table names, query patterns, or problem description
- `threshold` (optional): Time threshold for slow queries in milliseconds (default: 500ms)
- `environment` (optional): Target environment (default: development)

## Workflow

### 1. Identify Database Technology

Detect database type from codebase:
```bash
# Check for database configuration
grep -r "DATABASE_URL\|DB_CONNECTION\|database" .env* config/ 2>/dev/null | head -5

# Check package dependencies
grep -E "pg|mysql|mongodb|sqlite" package.json 2>/dev/null
```

Common patterns:
- **PostgreSQL**: `pg`, `pg_stat_statements`, `.pgpass`
- **MySQL**: `mysql2`, `mysql`, `.my.cnf`
- **MongoDB**: `mongoose`, `mongodb`
- **SQLite**: `sqlite3`, `.db` files

### 2. Enable Performance Monitoring

**PostgreSQL**:
```sql
-- Enable pg_stat_statements extension (if not already)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Reset statistics for fresh baseline
SELECT pg_stat_statements_reset();

-- Enable slow query logging
ALTER SYSTEM SET log_min_duration_statement = 500; -- 500ms threshold
SELECT pg_reload_conf();
```

**MySQL**:
```sql
-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 0.5; -- 500ms threshold
SET GLOBAL log_queries_not_using_indexes = 'ON';
```

**MongoDB**:
```javascript
// Enable profiling
db.setProfilingLevel(1, { slowms: 500 });

// View profiler status
db.getProfilingStatus();
```

### 3. Analyze Slow Queries

**PostgreSQL - Find Slow Queries**:
```sql
-- Top 20 slow queries by average time
SELECT
  substring(query, 1, 100) AS short_query,
  round(mean_exec_time::numeric, 2) AS avg_time_ms,
  calls,
  round(total_exec_time::numeric, 2) AS total_time_ms,
  round((100 * total_exec_time / sum(total_exec_time) OVER ())::numeric, 2) AS percentage_cpu
FROM pg_stat_statements
WHERE query NOT LIKE '%pg_stat_statements%'
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Queries with most calls (potential optimization targets)
SELECT
  substring(query, 1, 100) AS short_query,
  calls,
  round(mean_exec_time::numeric, 2) AS avg_time_ms,
  round(total_exec_time::numeric, 2) AS total_time_ms
FROM pg_stat_statements
WHERE query NOT LIKE '%pg_stat_statements%'
ORDER BY calls DESC
LIMIT 20;

-- Most time-consuming queries
SELECT
  substring(query, 1, 100) AS short_query,
  round(total_exec_time::numeric, 2) AS total_time_ms,
  calls,
  round(mean_exec_time::numeric, 2) AS avg_time_ms
FROM pg_stat_statements
WHERE query NOT LIKE '%pg_stat_statements%'
ORDER BY total_exec_time DESC
LIMIT 20;
```

**MySQL - Find Slow Queries**:
```sql
-- Analyze slow query log
SELECT
  DIGEST_TEXT AS query,
  COUNT_STAR AS exec_count,
  AVG_TIMER_WAIT/1000000000 AS avg_time_ms,
  SUM_TIMER_WAIT/1000000000 AS total_time_ms
FROM performance_schema.events_statements_summary_by_digest
ORDER BY AVG_TIMER_WAIT DESC
LIMIT 20;
```

**MongoDB - Find Slow Queries**:
```javascript
// View slow operations
db.system.profile.find({
  millis: { $gt: 500 }
}).sort({ ts: -1 }).limit(20).pretty();

// Aggregate slow operations by type
db.system.profile.aggregate([
  { $match: { millis: { $gt: 500 } } },
  { $group: {
    _id: "$command",
    count: { $sum: 1 },
    avgTime: { $avg: "$millis" }
  }},
  { $sort: { avgTime: -1 } }
]);
```

### 4. Analyze Query Execution Plans

For each slow query, analyze the execution plan:

**PostgreSQL - EXPLAIN ANALYZE**:
```sql
-- Replace [SLOW_QUERY] with actual query
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
[SLOW_QUERY];

-- Human-readable format
EXPLAIN (ANALYZE, BUFFERS)
SELECT u.id, u.email, COUNT(p.id) AS post_count
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
WHERE u.created_at > NOW() - INTERVAL '30 days'
GROUP BY u.id, u.email;
```

Look for these indicators:
- **Seq Scan** - Full table scan (bad for large tables, consider index)
- **Index Scan** - Using index (good)
- **Nested Loop** - Join method (may be slow for large datasets)
- **Hash Join** / **Merge Join** - Usually better for large datasets
- **High execution time** - Optimization opportunity

**MySQL - EXPLAIN**:
```sql
EXPLAIN FORMAT=JSON
SELECT u.id, u.email, COUNT(p.id) AS post_count
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
WHERE u.created_at > DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY u.id, u.email;
```

Look for:
- `type: ALL` - Full table scan (bad)
- `type: index` or `type: range` - Using index (good)
- `rows: high_number` - Large row count suggests optimization needed

**MongoDB - Explain**:
```javascript
db.users.find({
  createdAt: { $gte: new Date(Date.now() - 30*24*60*60*1000) }
}).explain("executionStats");
```

Look for:
- `COLLSCAN` - Collection scan (bad, add index)
- `IXSCAN` - Index scan (good)
- `executionTimeMillis` - Total execution time

### 5. Index Analysis and Optimization

**PostgreSQL - Missing Indexes**:
```sql
-- Find tables with missing indexes (frequent seq scans)
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

-- Find unused indexes (candidates for removal)
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan,
  pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexrelname NOT LIKE '%_pkey'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Check duplicate indexes
SELECT
  pg_size_pretty(SUM(pg_relation_size(idx))::BIGINT) AS total_size,
  (array_agg(idx))[1] AS idx1,
  (array_agg(idx))[2] AS idx2,
  (array_agg(idx))[3] AS idx3,
  (array_agg(idx))[4] AS idx4
FROM (
  SELECT
    indexrelid::regclass AS idx,
    (indrelid::text ||E'\n'|| indclass::text ||E'\n'|| indkey::text ||E'\n'|| COALESCE(indexprs::text,'')||E'\n' || COALESCE(indpred::text,'')) AS key
  FROM pg_index
) sub
GROUP BY key
HAVING COUNT(*) > 1
ORDER BY SUM(pg_relation_size(idx)) DESC;
```

**Index Creation Examples**:

```sql
-- Simple index (single column)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- Composite index (multiple columns) - order matters!
CREATE INDEX CONCURRENTLY idx_posts_user_created
ON posts(user_id, created_at DESC);

-- Partial index (filtered)
CREATE INDEX CONCURRENTLY idx_users_active_email
ON users(email)
WHERE status = 'active';

-- Expression index
CREATE INDEX CONCURRENTLY idx_users_lower_email
ON users(LOWER(email));

-- GiST index for full-text search
CREATE INDEX CONCURRENTLY idx_posts_search
ON posts USING GiST(to_tsvector('english', title || ' ' || content));
```

**MySQL - Index Analysis**:
```sql
-- Check indexes on a table
SHOW INDEXES FROM users;

-- Find unused indexes
SELECT
  TABLE_NAME,
  INDEX_NAME,
  CARDINALITY
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
GROUP BY TABLE_NAME, INDEX_NAME
HAVING SUM(CARDINALITY) = 0;

-- Create index
CREATE INDEX idx_users_email ON users(email);

-- Create composite index
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at);
```

**MongoDB - Index Analysis**:
```javascript
// List all indexes on collection
db.users.getIndexes();

// Check index usage
db.users.aggregate([
  { $indexStats: {} }
]);

// Create single field index
db.users.createIndex({ email: 1 });

// Create compound index
db.posts.createIndex({ userId: 1, createdAt: -1 });

// Create text index for search
db.posts.createIndex({ title: "text", content: "text" });

// Create partial index
db.users.createIndex(
  { email: 1 },
  { partialFilterExpression: { status: "active" } }
);
```

### 6. Query Optimization Examples

**Example 1: N+1 Query Problem**

```javascript
// BEFORE (N+1 problem)
async function getUsersWithPosts() {
  const users = await User.findAll(); // 1 query
  for (const user of users) {
    user.posts = await Post.findAll({ // N queries (one per user)
      where: { userId: user.id }
    });
  }
  return users;
}

// AFTER (eager loading)
async function getUsersWithPosts() {
  const users = await User.findAll({ // 1 query with join
    include: [{ model: Post, as: 'posts' }]
  });
  return users;
}

// SQL generated:
// SELECT u.*, p.* FROM users u LEFT JOIN posts p ON p.user_id = u.id;
```

**Example 2: SELECT * Optimization**

```sql
-- BEFORE (fetches all columns)
SELECT * FROM users WHERE email = 'user@example.com';

-- AFTER (fetch only needed columns)
SELECT id, email, name, created_at FROM users WHERE email = 'user@example.com';
```

**Example 3: Inefficient JOIN**

```sql
-- BEFORE (subquery for each row)
SELECT
  u.id,
  u.name,
  (SELECT COUNT(*) FROM posts WHERE user_id = u.id) AS post_count
FROM users u;

-- AFTER (single join with aggregation)
SELECT
  u.id,
  u.name,
  COUNT(p.id) AS post_count
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
GROUP BY u.id, u.name;
```

**Example 4: Pagination with OFFSET**

```sql
-- BEFORE (inefficient for large offsets)
SELECT * FROM posts ORDER BY created_at DESC LIMIT 20 OFFSET 10000;

-- AFTER (cursor-based pagination)
SELECT * FROM posts
WHERE created_at < '2025-10-01T00:00:00Z' -- cursor from last result
ORDER BY created_at DESC
LIMIT 20;
```

**Example 5: OR to UNION Optimization**

```sql
-- BEFORE (prevents index usage)
SELECT * FROM users WHERE email = 'test@example.com' OR username = 'testuser';

-- AFTER (allows index usage on both columns)
SELECT * FROM users WHERE email = 'test@example.com'
UNION
SELECT * FROM users WHERE username = 'testuser';
```

### 7. Schema Optimization

**Normalization vs. Denormalization**:

```sql
-- Normalized (3NF) - reduces redundancy but requires joins
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255)
);

CREATE TABLE user_profiles (
  user_id INTEGER PRIMARY KEY REFERENCES users(id),
  bio TEXT,
  avatar_url VARCHAR(500)
);

-- Denormalized - faster reads, some redundancy
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255),
  bio TEXT,
  avatar_url VARCHAR(500)
);
```

**Partitioning Large Tables**:

```sql
-- PostgreSQL table partitioning by date
CREATE TABLE posts (
  id BIGSERIAL,
  user_id INTEGER,
  content TEXT,
  created_at TIMESTAMP NOT NULL,
  PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- Create partitions
CREATE TABLE posts_2025_q1 PARTITION OF posts
  FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');

CREATE TABLE posts_2025_q2 PARTITION OF posts
  FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');
```

**Column Type Optimization**:

```sql
-- BEFORE (inefficient types)
CREATE TABLE users (
  id BIGSERIAL,
  email VARCHAR(500),
  status VARCHAR(50),
  age NUMERIC,
  is_verified CHAR(1)
);

-- AFTER (optimized types)
CREATE TABLE users (
  id SERIAL, -- Use SERIAL if < 2 billion records
  email VARCHAR(255), -- Right-sized
  status VARCHAR(20) CHECK (status IN ('active', 'inactive', 'suspended')), -- Constrained
  age SMALLINT CHECK (age >= 0 AND age <= 150), -- Appropriate int size
  is_verified BOOLEAN -- Native boolean
);
```

### 8. Connection Pool Optimization

**Node.js (pg) Example**:

```javascript
// BEFORE (default settings)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

// AFTER (optimized for application)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20, // Maximum pool size (based on workload)
  min: 5,  // Minimum idle connections
  idleTimeoutMillis: 30000, // Remove idle connections after 30s
  connectionTimeoutMillis: 2000, // Fail fast if no connection available
  statement_timeout: 5000, // Query timeout (5s)
  query_timeout: 5000
});

// Monitor pool health
pool.on('connect', () => {
  console.log('Database connection established');
});

pool.on('error', (err) => {
  console.error('Unexpected database error', err);
});

// Check pool status
setInterval(() => {
  console.log({
    total: pool.totalCount,
    idle: pool.idleCount,
    waiting: pool.waitingCount
  });
}, 60000);
```

**Connection Pool Sizing Formula**:
```
Optimal Pool Size = (Core Count × 2) + Effective Spindle Count

Example for 4-core server with SSD:
Pool Size = (4 × 2) + 1 = 9 connections
```

### 9. Query Caching

**Application-Level Caching (Redis)**:

```javascript
// BEFORE (no caching)
async function getUser(userId) {
  return await User.findByPk(userId);
}

// AFTER (with Redis cache)
async function getUser(userId) {
  const cacheKey = `user:${userId}`;

  // Try cache first
  const cached = await redis.get(cacheKey);
  if (cached) {
    return JSON.parse(cached);
  }

  // Cache miss - query database
  const user = await User.findByPk(userId);

  // Store in cache (TTL: 5 minutes)
  await redis.setex(cacheKey, 300, JSON.stringify(user));

  return user;
}

// Invalidate cache on update
async function updateUser(userId, data) {
  const user = await User.update(data, { where: { id: userId } });

  // Invalidate cache
  await redis.del(`user:${userId}`);

  return user;
}
```

**Database-Level Caching**:

```sql
-- PostgreSQL materialized view (cached aggregate)
CREATE MATERIALIZED VIEW user_stats AS
SELECT
  user_id,
  COUNT(*) AS post_count,
  MAX(created_at) AS last_post_at
FROM posts
GROUP BY user_id;

-- Create index on materialized view
CREATE INDEX idx_user_stats_user_id ON user_stats(user_id);

-- Refresh periodically (in cron job)
REFRESH MATERIALIZED VIEW CONCURRENTLY user_stats;
```

### 10. Measure Impact

After implementing optimizations:

```sql
-- PostgreSQL: Compare before/after query times
SELECT
  query,
  calls,
  mean_exec_time,
  total_exec_time
FROM pg_stat_statements
WHERE query LIKE '%[your_query_pattern]%'
ORDER BY mean_exec_time DESC;

-- Check index usage after creating indexes
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
WHERE indexname IN ('idx_users_email', 'idx_posts_user_created')
ORDER BY idx_scan DESC;
```

## Output Format

```markdown
# Database Optimization Report: [Context]

**Optimization Date**: [Date]
**Database**: [PostgreSQL/MySQL/MongoDB version]
**Environment**: [production/staging/development]
**Threshold**: [X]ms for slow queries

## Executive Summary

[2-3 paragraph summary of findings and optimizations applied]

## Baseline Metrics

### Slow Queries Identified

| Query Pattern | Avg Time | Calls | Total Time | % CPU |
|---------------|----------|-------|------------|-------|
| SELECT users WHERE email = ... | 450ms | 1,250 | 562s | 12.3% |
| SELECT posts with user JOIN | 820ms | 450 | 369s | 8.1% |
| SELECT COUNT(*) FROM activity_logs | 2,100ms | 120 | 252s | 5.5% |

### Index Analysis

**Missing Indexes**: 3 tables with frequent sequential scans
**Unused Indexes**: 2 indexes with 0 scans (candidates for removal)
**Duplicate Indexes**: 1 set of duplicate indexes found

### Connection Pool Metrics

- **Total Connections**: 15
- **Idle Connections**: 3
- **Active Connections**: 12
- **Waiting Requests**: 5 (indicates pool exhaustion)

## Optimizations Implemented

### 1. Added Missing Indexes

#### Index: idx_users_email
```sql
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```

**Impact**:
- **Before**: 450ms avg, 1,250 calls, Seq Scan on 500K rows
- **After**: 8ms avg, 1,250 calls, Index Scan
- **Improvement**: 98.2% faster (442ms saved per query)
- **Total Time Saved**: 552s per analysis period

**Execution Plan Comparison**:
```
BEFORE:
Seq Scan on users (cost=0.00..15234.50 rows=1 width=124) (actual time=442.231..448.891 rows=1)
  Filter: (email = 'user@example.com')
  Rows Removed by Filter: 499999

AFTER:
Index Scan using idx_users_email on users (cost=0.42..8.44 rows=1 width=124) (actual time=0.031..0.033 rows=1)
  Index Cond: (email = 'user@example.com')
```

#### Index: idx_posts_user_created
```sql
CREATE INDEX CONCURRENTLY idx_posts_user_created ON posts(user_id, created_at DESC);
```

**Impact**:
- **Before**: 820ms avg, Nested Loop + Seq Scan
- **After**: 45ms avg, Index Scan with sorted results
- **Improvement**: 94.5% faster (775ms saved per query)

### 2. Query Optimizations

#### Optimization: Fixed N+1 Query in User Posts Endpoint

**Before**:
```javascript
const users = await User.findAll();
for (const user of users) {
  user.posts = await Post.findAll({ where: { userId: user.id } });
}
// Result: 1 + N queries (251 queries for 250 users)
```

**After**:
```javascript
const users = await User.findAll({
  include: [{ model: Post, as: 'posts' }]
});
// Result: 1 query with JOIN
```

**Impact**:
- **Before**: 2,100ms for 250 users (1 + 250 queries)
- **After**: 180ms for 250 users (1 query)
- **Improvement**: 91.4% faster

#### Optimization: Cursor-Based Pagination

**Before**:
```sql
SELECT * FROM posts ORDER BY created_at DESC LIMIT 20 OFFSET 10000;
-- Execution time: 1,200ms (must scan and skip 10,000 rows)
```

**After**:
```sql
SELECT * FROM posts
WHERE created_at < '2025-09-01T12:00:00Z'
ORDER BY created_at DESC
LIMIT 20;
-- Execution time: 15ms (index seek directly to position)
```

**Impact**: 98.8% faster pagination for deep pages

### 3. Schema Optimizations

#### Denormalized User Activity Counts

**Before**:
```sql
-- Expensive aggregation on every query
SELECT u.*, COUNT(p.id) AS post_count
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
GROUP BY u.id;
```

**After**:
```sql
-- Added cached column with trigger updates
ALTER TABLE users ADD COLUMN post_count INTEGER DEFAULT 0;

-- Trigger to maintain count
CREATE OR REPLACE FUNCTION update_user_post_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE users SET post_count = post_count + 1 WHERE id = NEW.user_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE users SET post_count = post_count - 1 WHERE id = OLD.user_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_post_count
AFTER INSERT OR DELETE ON posts
FOR EACH ROW EXECUTE FUNCTION update_user_post_count();

-- Simple query now
SELECT * FROM users;
```

**Impact**:
- **Before**: 340ms (aggregation query)
- **After**: 12ms (simple select)
- **Improvement**: 96.5% faster

### 4. Connection Pool Optimization

**Before**:
```javascript
const pool = new Pool(); // Default settings
// Max: 10, Min: 0
// Frequent connection exhaustion under load
```

**After**:
```javascript
const pool = new Pool({
  max: 20,              // Increased for higher concurrency
  min: 5,               // Keep warm connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
  statement_timeout: 5000
});
```

**Impact**:
- **Before**: 45 connection timeout errors per hour under load
- **After**: 0 connection timeout errors
- **Improvement**: Eliminated connection pool exhaustion

### 5. Query Result Caching

**Implementation**:
```javascript
async function getUserProfile(userId) {
  const cacheKey = `user:${userId}:profile`;
  const cached = await redis.get(cacheKey);

  if (cached) return JSON.parse(cached);

  const profile = await User.findByPk(userId, {
    include: ['profile', 'settings']
  });

  await redis.setex(cacheKey, 300, JSON.stringify(profile));
  return profile;
}
```

**Impact**:
- **Cache Hit Rate**: 87% (after 24 hours)
- **Avg Response Time (cached)**: 3ms
- **Avg Response Time (uncached)**: 45ms
- **Database Load Reduction**: 87%

## Results Summary

### Overall Performance Improvements

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Avg Query Time | 285ms | 34ms | 88% faster |
| Slow Query Count (>500ms) | 23 queries | 2 queries | 91% reduction |
| Database CPU Usage | 68% | 32% | 53% reduction |
| Connection Pool Timeouts | 45/hour | 0/hour | 100% elimination |
| Cache Hit Rate | N/A | 87% | New capability |

### Query-Specific Improvements

| Query | Before | After | Improvement |
|-------|--------|-------|-------------|
| User lookup by email | 450ms | 8ms | 98.2% |
| User posts listing | 820ms | 45ms | 94.5% |
| User activity with posts | 2,100ms | 180ms | 91.4% |
| Deep pagination | 1,200ms | 15ms | 98.8% |

### Index Impact

| Index | Scans | Rows Read | Impact |
|-------|-------|-----------|--------|
| idx_users_email | 1,250 | 1,250 | Direct lookups |
| idx_posts_user_created | 450 | 9,000 | User posts queries |

## Monitoring Recommendations

### Key Metrics to Track

1. **Query Performance**:
   ```sql
   -- Weekly query performance review
   SELECT
     substring(query, 1, 100) AS query,
     calls,
     mean_exec_time,
     total_exec_time
   FROM pg_stat_statements
   WHERE mean_exec_time > 100
   ORDER BY mean_exec_time DESC
   LIMIT 20;
   ```

2. **Index Usage**:
   ```sql
   -- Monitor new index effectiveness
   SELECT * FROM pg_stat_user_indexes
   WHERE indexname LIKE 'idx_%'
   ORDER BY idx_scan DESC;
   ```

3. **Connection Pool Health**:
   ```javascript
   // Log pool metrics every minute
   setInterval(() => {
     console.log('Pool:', pool.totalCount, 'Idle:', pool.idleCount);
   }, 60000);
   ```

4. **Cache Hit Rates**:
   ```javascript
   // Track Redis cache effectiveness
   const stats = await redis.info('stats');
   // Monitor keyspace_hits vs keyspace_misses
   ```

### Alerts to Configure

- Slow query count > 10 per hour
- Connection pool utilization > 85%
- Cache hit rate < 70%
- Database CPU > 80%

## Trade-offs and Considerations

**Denormalization Trade-offs**:
- **Benefit**: Faster reads (96.5% improvement)
- **Cost**: Increased storage (minimal), trigger overhead on writes
- **Conclusion**: Worth it for read-heavy workloads

**Connection Pool Size**:
- **Benefit**: Eliminated timeouts
- **Cost**: Increased memory usage (~20MB)
- **Consideration**: Monitor database connection limits

**Caching Strategy**:
- **Benefit**: 87% reduction in database load
- **Cost**: Cache invalidation complexity, Redis dependency
- **Consideration**: Implement cache warming for critical data

## Next Steps

1. **Monitor** new indexes and query performance for 1 week
2. **Implement** additional caching for frequently accessed data
3. **Consider** table partitioning for `activity_logs` (2M+ rows)
4. **Schedule** VACUUM ANALYZE for optimized tables
5. **Review** remaining 2 slow queries for further optimization

## Maintenance Recommendations

**Weekly**:
- Review pg_stat_statements for new slow queries
- Check index usage statistics

**Monthly**:
- Analyze table statistics: `VACUUM ANALYZE`
- Review and remove unused indexes
- Check for table bloat

**Quarterly**:
- Review schema design for optimization opportunities
- Evaluate partitioning strategy for large tables
- Update connection pool settings based on usage patterns
