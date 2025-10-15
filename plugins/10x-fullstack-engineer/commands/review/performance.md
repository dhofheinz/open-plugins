# Performance-Focused Code Review

Performs comprehensive performance analysis covering database optimization, backend efficiency, frontend rendering, network optimization, and scalability.

## Parameters

**Received from router**: `$ARGUMENTS` (after removing 'performance' operation)

Expected format: `scope:"review-scope" [depth:"quick|standard|deep"]`

## Workflow

### 1. Parse Parameters

Extract from $ARGUMENTS:
- **scope**: What to review (required) - API endpoints, database layer, frontend components, entire app
- **depth**: Performance analysis thoroughness (default: "standard")

### 2. Gather Context

**Understand Performance Baseline**:
```bash
# Check project structure and tech stack
ls -la
cat package.json 2>/dev/null || cat requirements.txt 2>/dev/null

# Identify performance-critical files
find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | xargs grep -l "query\|fetch\|map\|filter\|useEffect\|useState" | head -20

# Check for existing performance monitoring
grep -r "performance\|timing\|profil\|benchmark" --include="*.ts" --include="*.js" | head -10

# Look for database queries
grep -r "SELECT\|INSERT\|UPDATE\|DELETE\|query\|execute" --include="*.ts" --include="*.js" --include="*.py" | head -15

# Check bundle configuration
ls -la | grep -E "webpack|vite|rollup|esbuild"
```

### 3. Database Performance Review

**Query Optimization**:
- [ ] No N+1 query problems
- [ ] Efficient joins (avoid Cartesian products)
- [ ] Indexes on frequently queried columns
- [ ] Covering indexes for common queries
- [ ] Query plans analyzed (EXPLAIN ANALYZE)
- [ ] Avoid SELECT * (select only needed columns)
- [ ] Limit result sets appropriately

**Connection Management**:
- [ ] Connection pooling configured
- [ ] Pool size appropriate for load
- [ ] Connections properly released
- [ ] Connection timeouts configured
- [ ] No connection leaks

**Transaction Management**:
- [ ] Transactions scoped appropriately (not too large)
- [ ] Read vs write transactions differentiated
- [ ] Transaction isolation level appropriate
- [ ] Deadlock handling implemented
- [ ] Long-running transactions avoided

**Data Access Patterns**:
- [ ] Pagination for large datasets
- [ ] Cursor-based pagination for large tables
- [ ] Batch operations where possible
- [ ] Bulk inserts instead of individual
- [ ] Proper use of indexes
- [ ] Denormalization where appropriate for reads

**Caching Strategy**:
- [ ] Query result caching for expensive queries
- [ ] Cache invalidation strategy clear
- [ ] Redis/Memcached for distributed caching
- [ ] Application-level caching appropriate
- [ ] Cache hit rate monitored

**Code Examples - Database Performance**:

```typescript
// ❌ BAD: N+1 query problem
const users = await User.findAll();
for (const user of users) {
  user.posts = await Post.findAll({ where: { userId: user.id } });
  user.comments = await Comment.findAll({ where: { userId: user.id } });
}

// ✅ GOOD: Eager loading with includes
const users = await User.findAll({
  include: [
    { model: Post },
    { model: Comment }
  ]
});

// ✅ BETTER: Only load what's needed
const users = await User.findAll({
  attributes: ['id', 'name', 'email'], // Don't SELECT *
  include: [
    {
      model: Post,
      attributes: ['id', 'title', 'createdAt'],
      limit: 5 // Only recent posts
    }
  ]
});
```

```typescript
// ❌ BAD: Loading all records without pagination
const allUsers = await User.findAll(); // Could be millions of records!

// ✅ GOOD: Pagination
const page = parseInt(req.query.page) || 1;
const limit = 20;
const offset = (page - 1) * limit;

const { rows: users, count } = await User.findAndCountAll({
  limit,
  offset,
  order: [['createdAt', 'DESC']]
});

res.json({
  users,
  pagination: {
    page,
    limit,
    total: count,
    pages: Math.ceil(count / limit)
  }
});
```

```typescript
// ❌ BAD: Individual inserts
for (const item of items) {
  await Item.create(item); // Each is a separate query!
}

// ✅ GOOD: Bulk insert
await Item.bulkCreate(items);
```

```sql
-- ❌ BAD: Missing index on frequently queried column
SELECT * FROM orders WHERE user_id = 123 AND status = 'pending';
-- This could be slow without an index!

-- ✅ GOOD: Add composite index
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
```

### 4. Backend Performance Review

**Algorithm Efficiency**:
- [ ] Time complexity analyzed (avoid O(n²) where possible)
- [ ] Space complexity considered
- [ ] Efficient data structures used (Map vs Array for lookups)
- [ ] Sorting algorithms appropriate for data size
- [ ] Search algorithms optimized
- [ ] Recursion depth manageable (avoid stack overflow)

**Async Operations**:
- [ ] Async/await used properly
- [ ] No blocking operations on event loop
- [ ] Parallel execution where possible (Promise.all)
- [ ] Proper error handling in async code
- [ ] Timeouts on external calls
- [ ] Avoid awaiting in loops (use Promise.all)

**Caching Strategy**:
- [ ] In-memory caching for frequently accessed data
- [ ] Distributed caching (Redis) for scalability
- [ ] Cache TTL appropriate
- [ ] Cache warming strategy
- [ ] Cache invalidation correct
- [ ] Memoization for expensive calculations

**Resource Management**:
- [ ] Memory leaks prevented (event listeners cleaned up)
- [ ] File handles closed properly
- [ ] Streams used for large files
- [ ] Buffer sizes appropriate
- [ ] Garbage collection friendly code
- [ ] Object pooling for frequently created objects

**Rate Limiting & Throttling**:
- [ ] Rate limiting on API endpoints
- [ ] Exponential backoff for retries
- [ ] Circuit breakers for external services
- [ ] Request queuing for overload
- [ ] Graceful degradation under load

**Code Examples - Backend Performance**:

```typescript
// ❌ BAD: O(n²) complexity - nested loops
function findDuplicates(users) {
  const duplicates = [];
  for (let i = 0; i < users.length; i++) {
    for (let j = i + 1; j < users.length; j++) {
      if (users[i].email === users[j].email) {
        duplicates.push(users[i]);
      }
    }
  }
  return duplicates;
}

// ✅ GOOD: O(n) complexity - using Map
function findDuplicates(users) {
  const seen = new Map();
  const duplicates = [];

  for (const user of users) {
    if (seen.has(user.email)) {
      duplicates.push(user);
    } else {
      seen.set(user.email, user);
    }
  }

  return duplicates;
}
```

```typescript
// ❌ BAD: Sequential async operations
async function getUserData(userId) {
  const user = await fetchUser(userId);
  const posts = await fetchPosts(userId);
  const comments = await fetchComments(userId);
  return { user, posts, comments };
}

// ✅ GOOD: Parallel async operations
async function getUserData(userId) {
  const [user, posts, comments] = await Promise.all([
    fetchUser(userId),
    fetchPosts(userId),
    fetchComments(userId)
  ]);
  return { user, posts, comments };
}
```

```typescript
// ❌ BAD: Awaiting in loop
async function processUsers(userIds) {
  const results = [];
  for (const id of userIds) {
    const result = await processUser(id); // Sequential!
    results.push(result);
  }
  return results;
}

// ✅ GOOD: Parallel processing with Promise.all
async function processUsers(userIds) {
  return Promise.all(userIds.map(id => processUser(id)));
}

// ✅ BETTER: Parallel with concurrency limit
async function processUsers(userIds) {
  const concurrency = 5;
  const results = [];

  for (let i = 0; i < userIds.length; i += concurrency) {
    const batch = userIds.slice(i, i + concurrency);
    const batchResults = await Promise.all(batch.map(id => processUser(id)));
    results.push(...batchResults);
  }

  return results;
}
```

```typescript
// ❌ BAD: No caching for expensive operation
function fibonacci(n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2); // Recalculates same values!
}

// ✅ GOOD: Memoization
const fibCache = new Map();
function fibonacci(n) {
  if (n <= 1) return n;
  if (fibCache.has(n)) return fibCache.get(n);

  const result = fibonacci(n - 1) + fibonacci(n - 2);
  fibCache.set(n, result);
  return result;
}

// ✅ BETTER: Iterative approach (faster)
function fibonacci(n) {
  if (n <= 1) return n;
  let prev = 0, curr = 1;
  for (let i = 2; i <= n; i++) {
    [prev, curr] = [curr, prev + curr];
  }
  return curr;
}
```

### 5. Frontend Performance Review

**React Component Optimization**:
- [ ] Components memoized where appropriate (React.memo)
- [ ] useMemo for expensive calculations
- [ ] useCallback for function props
- [ ] Unnecessary re-renders prevented
- [ ] Proper dependency arrays in hooks
- [ ] Key props correct for lists
- [ ] Code splitting at route level
- [ ] Lazy loading for heavy components

**List Rendering**:
- [ ] Large lists virtualized (react-window, react-virtualized)
- [ ] Pagination for very large datasets
- [ ] Infinite scroll implemented efficiently
- [ ] Window recycling for scrolling performance
- [ ] Avoid rendering off-screen items

**Image Optimization**:
- [ ] Images properly sized (responsive images)
- [ ] Lazy loading implemented
- [ ] Modern formats used (WebP, AVIF)
- [ ] Image compression applied
- [ ] Srcset for different screen sizes
- [ ] Loading placeholder or skeleton

**Bundle Optimization**:
- [ ] Code splitting implemented
- [ ] Tree shaking enabled
- [ ] Dead code eliminated
- [ ] Dynamic imports for large libraries
- [ ] Bundle size analyzed (webpack-bundle-analyzer)
- [ ] Moment.js replaced with date-fns or dayjs
- [ ] Lodash imports optimized (import specific functions)

**State Management**:
- [ ] State normalized (avoid nested updates)
- [ ] Global state minimized
- [ ] Computed values memoized
- [ ] State updates batched
- [ ] Context splits prevent unnecessary re-renders
- [ ] Use of local state preferred over global

**Web Vitals Optimization**:
- [ ] Largest Contentful Paint (LCP) < 2.5s
- [ ] First Input Delay (FID) < 100ms
- [ ] Cumulative Layout Shift (CLS) < 0.1
- [ ] Time to Interactive (TTI) optimized
- [ ] First Contentful Paint (FCP) optimized

**Code Examples - Frontend Performance**:

```typescript
// ❌ BAD: Unnecessary re-renders
function UserList({ users, onDelete }) {
  return users.map(user => (
    <UserCard
      key={user.id}
      user={user}
      onDelete={() => onDelete(user.id)} // New function every render!
    />
  ));
}

// ✅ GOOD: Memoized components
const UserCard = React.memo(({ user, onDelete }) => (
  <div onClick={() => onDelete(user.id)}>
    {user.name}
  </div>
));

function UserList({ users, onDelete }) {
  return users.map(user => (
    <UserCard key={user.id} user={user} onDelete={onDelete} />
  ));
}
```

```typescript
// ❌ BAD: Expensive calculation on every render
function ProductList({ products }) {
  const sortedProducts = products
    .sort((a, b) => b.rating - a.rating)
    .slice(0, 10); // Recalculated every render!

  return <div>{sortedProducts.map(p => <Product key={p.id} {...p} />)}</div>;
}

// ✅ GOOD: Memoized calculation
function ProductList({ products }) {
  const sortedProducts = useMemo(() =>
    products
      .sort((a, b) => b.rating - a.rating)
      .slice(0, 10),
    [products] // Only recalculate when products change
  );

  return <div>{sortedProducts.map(p => <Product key={p.id} {...p} />)}</div>;
}
```

```typescript
// ❌ BAD: No virtualization for large list
function MessageList({ messages }) {
  return (
    <div>
      {messages.map(msg => (
        <MessageItem key={msg.id} message={msg} />
      ))}
    </div>
  ); // Renders ALL messages, even off-screen!
}

// ✅ GOOD: Virtualized list
import { FixedSizeList } from 'react-window';

function MessageList({ messages }) {
  const Row = ({ index, style }) => (
    <div style={style}>
      <MessageItem message={messages[index]} />
    </div>
  );

  return (
    <FixedSizeList
      height={600}
      itemCount={messages.length}
      itemSize={80}
      width="100%"
    >
      {Row}
    </FixedSizeList>
  ); // Only renders visible items!
}
```

```typescript
// ❌ BAD: Entire library imported
import moment from 'moment'; // Imports entire 70KB library!

// ✅ GOOD: Lightweight alternative
import { format } from 'date-fns'; // Tree-shakeable, smaller

// ❌ BAD: Lodash imported entirely
import _ from 'lodash';

// ✅ GOOD: Specific imports
import debounce from 'lodash/debounce';
import throttle from 'lodash/throttle';
```

### 6. Network Performance Review

**API Optimization**:
- [ ] API calls minimized
- [ ] GraphQL for flexible data fetching
- [ ] Batch API requests where possible
- [ ] Debouncing for search/autocomplete
- [ ] Prefetching for predictable navigation
- [ ] Optimistic updates for better UX
- [ ] Request deduplication

**Caching & CDN**:
- [ ] HTTP caching headers configured
- [ ] Cache-Control directives appropriate
- [ ] ETag for conditional requests
- [ ] Service Worker for offline caching
- [ ] CDN for static assets
- [ ] Edge caching where applicable

**Compression**:
- [ ] Gzip or Brotli compression enabled
- [ ] Appropriate compression levels
- [ ] Assets minified
- [ ] JSON responses compressed

**Resource Loading**:
- [ ] Critical CSS inlined
- [ ] Non-critical CSS loaded async
- [ ] JavaScript loaded with async/defer
- [ ] DNS prefetch for external domains
- [ ] Preload for critical resources
- [ ] Preconnect for required origins

**Code Examples - Network Performance**:

```typescript
// ❌ BAD: No debouncing for search
function SearchBox() {
  const [query, setQuery] = useState('');

  const handleChange = async (e) => {
    setQuery(e.target.value);
    await fetchResults(e.target.value); // API call on every keystroke!
  };

  return <input value={query} onChange={handleChange} />;
}

// ✅ GOOD: Debounced search
import { debounce } from 'lodash';

function SearchBox() {
  const [query, setQuery] = useState('');

  const fetchResultsDebounced = useMemo(
    () => debounce((q) => fetchResults(q), 300),
    []
  );

  const handleChange = (e) => {
    setQuery(e.target.value);
    fetchResultsDebounced(e.target.value);
  };

  return <input value={query} onChange={handleChange} />;
}
```

```typescript
// ❌ BAD: Multiple API calls
const user = await fetch('/api/user/123').then(r => r.json());
const posts = await fetch('/api/user/123/posts').then(r => r.json());
const followers = await fetch('/api/user/123/followers').then(r => r.json());

// ✅ GOOD: Single API call with all data
const userData = await fetch('/api/user/123?include=posts,followers')
  .then(r => r.json());

// ✅ BETTER: GraphQL for flexible data fetching
const userData = await graphqlClient.query({
  query: gql`
    query GetUser($id: ID!) {
      user(id: $id) {
        name
        email
        posts(limit: 10) { title }
        followers(limit: 5) { name }
      }
    }
  `,
  variables: { id: '123' }
});
```

### 7. Performance Monitoring & Profiling

**Monitoring Tools**:
```bash
# Check bundle size
npm run build
ls -lh dist/ # Check output sizes

# Analyze bundle composition
npm install --save-dev webpack-bundle-analyzer
# Add to webpack config and analyze

# Run Lighthouse audit
npx lighthouse https://your-site.com --view

# Check Core Web Vitals
# Use Chrome DevTools -> Performance
# Use Lighthouse or WebPageTest
```

**Performance Metrics**:
- [ ] Response time monitoring
- [ ] Database query times logged
- [ ] API endpoint performance tracked
- [ ] Error rates monitored
- [ ] Memory usage tracked
- [ ] CPU usage monitored

**Profiling**:
- [ ] Node.js profiling for CPU hotspots
- [ ] Memory profiling for leaks
- [ ] Chrome DevTools performance profiling
- [ ] React DevTools Profiler used

### 8. Scalability Review

**Horizontal Scalability**:
- [ ] Stateless application design
- [ ] Session data in external store (Redis)
- [ ] No local file system dependencies
- [ ] Load balancer compatible
- [ ] Health check endpoints

**Vertical Scalability**:
- [ ] Memory usage efficient
- [ ] CPU usage optimized
- [ ] Can handle increased load per instance

**Database Scalability**:
- [ ] Read replicas for read-heavy loads
- [ ] Write scaling strategy (sharding, partitioning)
- [ ] Connection pooling configured
- [ ] Query performance at scale considered

**Caching for Scale**:
- [ ] Distributed caching (Redis cluster)
- [ ] Cache warming strategy
- [ ] Cache hit rate optimization
- [ ] Cache invalidation across instances

## Review Depth Implementation

**Quick Depth** (10-15 min):
- Focus on obvious performance issues
- Check for N+1 queries
- Review large data fetching without pagination
- Check bundle size
- Identify blocking operations

**Standard Depth** (30-40 min):
- All performance categories reviewed
- Database query analysis
- Frontend rendering optimization
- Network request analysis
- Caching strategy review
- Basic profiling recommendations

**Deep Depth** (60-90+ min):
- Comprehensive performance audit
- Detailed query plan analysis
- Algorithm complexity review
- Memory profiling
- Complete bundle analysis
- Load testing recommendations
- Scalability assessment
- Performance monitoring setup

## Output Format

```markdown
# Performance Review: [Scope]

## Executive Summary

**Reviewed**: [What was reviewed]
**Depth**: [Quick|Standard|Deep]
**Performance Rating**: [Excellent|Good|Needs Optimization|Critical Issues]

### Overall Performance Assessment
**[Optimized|Acceptable|Needs Improvement|Poor]**

[Brief explanation]

### Key Performance Metrics
- **Average Response Time**: [Xms]
- **Database Query Time**: [Xms]
- **Bundle Size**: [XKB]
- **Largest Contentful Paint**: [Xs]
- **Time to Interactive**: [Xs]

### Priority Actions
1. [Critical performance fix 1]
2. [Critical performance fix 2]

---

## Critical Performance Issues 🚨

### [Issue 1 Title]
**File**: `path/to/file.ts:42`
**Category**: Database|Backend|Frontend|Network
**Impact**: [Severe slowdown, timeout, memory leak, etc.]
**Current Performance**: [Xms, XKB, etc.]
**Expected Performance**: [Target]
**Root Cause**: [Why this is slow]
**Optimization**: [Specific fix]

```typescript
// Current code (slow)
[slow code]

// Optimized implementation
[fast code]

// Performance improvement: [X% faster, XKB smaller, etc.]
```

[Repeat for each critical issue]

---

## High Impact Optimizations ⚠️

[Similar format for high impact issues]

---

## Medium Impact Optimizations ℹ️

[Similar format for medium impact issues]

---

## Low Impact Optimizations 💡

[Similar format for low impact issues]

---

## Performance Strengths ✅

- ✅ [Optimization already in place]
- ✅ [Good performance practice]

---

## Detailed Performance Analysis

### 🗄️ Database Performance

**Query Performance**:
- Average query time: [Xms]
- Slowest queries: [List with times]
- N+1 queries found: [Count and locations]
- Missing indexes: [List]

**Optimization Recommendations**:
1. [Specific database optimization]
2. [Specific database optimization]

### ⚙️ Backend Performance

**Algorithm Complexity**:
- O(n²) operations found: [Count and locations]
- Memory-intensive operations: [List]

**Async Performance**:
- Sequential operations that could be parallel: [Count]
- Blocking operations: [List]

**Optimization Recommendations**:
1. [Specific backend optimization]
2. [Specific backend optimization]

### 🎨 Frontend Performance

**Bundle Analysis**:
- Total bundle size: [XKB]
- Largest dependencies: [List with sizes]
- Code splitting: [Enabled/Not enabled]
- Tree shaking: [Effective/Ineffective]

**Rendering Performance**:
- Unnecessary re-renders: [Count and components]
- Large lists without virtualization: [List]
- Unoptimized images: [Count]

**Web Vitals**:
| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| LCP | [Xs] | < 2.5s | ✅ / ⚠️ / ❌ |
| FID | [Xms] | < 100ms | ✅ / ⚠️ / ❌ |
| CLS | [X] | < 0.1 | ✅ / ⚠️ / ❌ |
| TTI | [Xs] | < 3.8s | ✅ / ⚠️ / ❌ |

**Optimization Recommendations**:
1. [Specific frontend optimization]
2. [Specific frontend optimization]

### 🌐 Network Performance

**API Performance**:
- Average API response time: [Xms]
- Slowest endpoints: [List with times]
- API calls that could be batched: [Count]
- Missing caching: [List]

**Resource Loading**:
- Total page size: [XMB]
- Number of requests: [X]
- Compression enabled: [Yes/No]
- CDN usage: [Yes/No/Partial]

**Optimization Recommendations**:
1. [Specific network optimization]
2. [Specific network optimization]

---

## Scalability Assessment

**Current Load Capacity**: [X requests/second]
**Bottlenecks for Scaling**:
1. [Bottleneck 1]
2. [Bottleneck 2]

**Horizontal Scaling**: [Ready|Needs Work|Not Possible]
**Vertical Scaling**: [Efficient|Acceptable|Memory/CPU intensive]

**Recommendations for Scale**:
1. [Scaling recommendation 1]
2. [Scaling recommendation 2]

---

## Performance Optimization Roadmap

### Immediate (This Week) - Quick Wins
- [ ] [Quick optimization 1 - estimated Xms improvement]
- [ ] [Quick optimization 2 - estimated XKB reduction]

### Short-term (This Month) - High Impact
- [ ] [Optimization 1 - estimated impact]
- [ ] [Optimization 2 - estimated impact]

### Long-term (This Quarter) - Strategic
- [ ] [Strategic improvement 1]
- [ ] [Strategic improvement 2]

**Expected Overall Improvement**: [X% faster, XKB smaller, etc.]

---

## Performance Testing Recommendations

1. **Load Testing**: [Specific scenarios to test]
2. **Stress Testing**: [Peak load scenarios]
3. **Profiling**: [Areas to profile with tools]
4. **Monitoring**: [Metrics to track continuously]

---

## Tools & Resources

**Profiling Tools**:
- Chrome DevTools Performance tab
- React DevTools Profiler
- Node.js --prof for CPU profiling
- clinic.js for Node.js diagnostics

**Monitoring Tools**:
- [Recommended monitoring setup]
- [Metrics to track]

---

## Review Metadata

- **Reviewer**: 10x Fullstack Engineer (Performance Focus)
- **Review Date**: [Date]
- **Performance Issues**: Critical: X, High: X, Medium: X, Low: X
- **Estimated Total Performance Gain**: [X% improvement]
```

## Agent Invocation

This operation MUST leverage the **10x-fullstack-engineer** agent with performance expertise.

## Best Practices

1. **Measure First**: Use profiling data, not assumptions
2. **Optimize Hotspots**: Focus on code that runs frequently
3. **Balance Trade-offs**: Consider readability vs performance
4. **Think Scale**: How will this perform with 10x, 100x data?
5. **User-Centric**: Optimize for perceived performance
6. **Incremental Optimization**: Make measurable improvements iteratively
