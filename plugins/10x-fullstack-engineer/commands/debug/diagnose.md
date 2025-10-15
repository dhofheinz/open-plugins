# Diagnose Operation - Comprehensive Diagnosis and Root Cause Analysis

You are executing the **diagnose** operation to perform comprehensive diagnosis and root cause analysis for complex issues spanning multiple layers of the application stack.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'diagnose' operation name)

Expected format: `issue:"problem description" [environment:"prod|staging|dev"] [logs:"log-location"] [reproduction:"steps"] [impact:"severity"]`

## Workflow

### 1. Issue Understanding

Gather and analyze comprehensive information about the issue:

**Information to Collect**:
- **Symptom**: What is the observable problem? What exactly is failing?
- **Impact**: Who is affected? How many users? Business impact?
- **Frequency**: Consistent, intermittent, or rare? Percentage of occurrences?
- **Environment**: Production, staging, or development? Specific regions/zones?
- **Timeline**: When did it start? Any correlation with deployments?
- **Recent Changes**: Deployments, config changes, infrastructure changes?
- **Error Messages**: Complete error messages, stack traces, error codes

**Questions to Answer**:
```markdown
- What is the user experiencing?
- What should be happening instead?
- How widespread is the issue?
- Is it getting worse over time?
- Are there any patterns (time of day, user types, specific actions)?
```

### 2. Data Collection Across All Layers

Systematically collect diagnostic data from each layer of the stack:

#### Frontend Diagnostics

**Browser Console Analysis**:
```javascript
// Check for JavaScript errors
console.error logs
console.warn logs

// Inspect unhandled promise rejections
window.addEventListener('unhandledrejection', event => {
  console.error('Unhandled promise rejection:', event.reason);
});

// Check for resource loading failures
performance.getEntriesByType('resource').filter(r => r.transferSize === 0)
```

**Network Request Analysis**:
```javascript
// Analyze failed requests
// Open DevTools > Network tab
// Filter: Status code 4xx, 5xx
// Check: Request headers, payload, response body, timing

// Performance timing
const perfEntries = performance.getEntriesByType('navigation')[0];
console.log('DNS lookup:', perfEntries.domainLookupEnd - perfEntries.domainLookupStart);
console.log('TCP connection:', perfEntries.connectEnd - perfEntries.connectStart);
console.log('Request time:', perfEntries.responseStart - perfEntries.requestStart);
console.log('Response time:', perfEntries.responseEnd - perfEntries.responseStart);
```

**State Inspection**:
```javascript
// React DevTools: Component state at error time
// Redux DevTools: Action history, state snapshots
// Vue DevTools: Vuex state, component hierarchy

// Add error boundary to capture React errors
class ErrorBoundary extends React.Component {
  componentDidCatch(error, errorInfo) {
    console.error('Component error:', {
      error: error.toString(),
      componentStack: errorInfo.componentStack,
      currentState: this.props.reduxState
    });
  }
}
```

#### Backend Diagnostics

**Application Logs**:
```bash
# Real-time application logs
tail -f logs/application.log

# Error logs with context
grep -i "error\|exception\|fatal" logs/*.log -A 10 -B 5

# Filter by request ID to trace single request
grep "request-id-12345" logs/*.log

# Find patterns in errors
awk '/ERROR/ {print $0}' logs/application.log | sort | uniq -c | sort -rn

# Time-based analysis
grep "2024-10-14 14:" logs/application.log | grep ERROR
```

**System Logs**:
```bash
# Service logs (systemd)
journalctl -u application-service.service -f
journalctl -u application-service.service --since "1 hour ago"

# Syslog
tail -f /var/log/syslog | grep application

# Kernel logs (for system-level issues)
dmesg -T | tail -50
```

**Application Metrics**:
```bash
# Request rate and response times
# Check APM tools: New Relic, Datadog, Elastic APM

# HTTP response codes over time
awk '{print $9}' /var/log/nginx/access.log | sort | uniq -c

# Slow requests
awk '$10 > 1000 {print $0}' /var/log/nginx/access.log

# Error rate calculation
errors=$(grep -c "ERROR" logs/application.log)
total=$(wc -l < logs/application.log)
echo "Error rate: $(echo "scale=4; $errors / $total * 100" | bc)%"
```

#### Database Diagnostics

**Active Queries and Locks**:
```sql
-- PostgreSQL: Active queries
SELECT
  pid,
  now() - query_start AS duration,
  state,
  query
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY duration DESC;

-- Long-running queries
SELECT
  pid,
  now() - query_start AS duration,
  query
FROM pg_stat_activity
WHERE state = 'active'
  AND now() - query_start > interval '1 minute';

-- Blocking queries
SELECT
  blocked_locks.pid AS blocked_pid,
  blocked_activity.usename AS blocked_user,
  blocking_locks.pid AS blocking_pid,
  blocking_activity.usename AS blocking_user,
  blocked_activity.query AS blocked_statement,
  blocking_activity.query AS blocking_statement
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks
  ON blocking_locks.locktype = blocked_locks.locktype
  AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
  AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
  AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
  AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
  AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
  AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
  AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
  AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
  AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
  AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;

-- Deadlock information (from logs)
-- Look for "deadlock detected" in PostgreSQL logs
```

**Database Performance**:
```sql
-- Table statistics
SELECT
  schemaname,
  tablename,
  n_live_tup AS live_rows,
  n_dead_tup AS dead_rows,
  last_vacuum,
  last_autovacuum
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;

-- Index usage
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

-- Connection count
SELECT
  count(*) AS connections,
  state,
  usename
FROM pg_stat_activity
GROUP BY state, usename;

-- Cache hit ratio
SELECT
  sum(heap_blks_read) AS heap_read,
  sum(heap_blks_hit) AS heap_hit,
  sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) AS cache_hit_ratio
FROM pg_statio_user_tables;
```

**Slow Query Log Analysis**:
```bash
# PostgreSQL: Enable log_min_duration_statement
# Check postgresql.conf: log_min_duration_statement = 1000 (1 second)

# Analyze slow queries
grep "duration:" /var/log/postgresql/postgresql.log | awk '{print $3, $6}' | sort -rn | head -20
```

#### Infrastructure Diagnostics

**Resource Usage**:
```bash
# CPU usage
top -bn1 | head -20
mpstat 1 5  # CPU stats every 1 second, 5 times

# Memory usage
free -h
vmstat 1 5

# Disk I/O
iostat -x 1 5
iotop -o  # Only show processes doing I/O

# Disk space
df -h
du -sh /* | sort -rh | head -10

# Network connections
netstat -an | grep ESTABLISHED | wc -l
ss -s  # Socket statistics

# Open files
lsof | wc -l
lsof -u application-user | wc -l
```

**Container Diagnostics (Docker/Kubernetes)**:
```bash
# Docker container logs
docker logs container-name --tail 100 -f
docker stats container-name

# Docker container inspection
docker inspect container-name
docker exec container-name ps aux
docker exec container-name df -h

# Kubernetes pod logs
kubectl logs pod-name -f
kubectl logs pod-name --previous  # Previous container logs

# Kubernetes pod resource usage
kubectl top pods
kubectl describe pod pod-name

# Kubernetes events
kubectl get events --sort-by='.lastTimestamp'
```

**Cloud Provider Metrics**:
```bash
# AWS CloudWatch
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
  --start-time 2024-10-14T00:00:00Z \
  --end-time 2024-10-14T23:59:59Z \
  --period 3600 \
  --statistics Average

# Check application logs
aws logs tail /aws/application/logs --follow

# GCP Stackdriver
gcloud logging read "resource.type=gce_instance AND severity>=ERROR" --limit 50

# Azure Monitor
az monitor metrics list --resource <resource-id> --metric "Percentage CPU"
```

### 3. Hypothesis Formation

Based on collected data, form testable hypotheses about the root cause:

**Common Issue Patterns to Consider**:

#### Race Conditions
**Symptoms**:
- Intermittent failures
- Works sometimes, fails other times
- Timing-dependent behavior
- "Cannot read property of undefined" on objects that should exist

**What to Check**:
```javascript
// Look for async operations without proper waiting
async function problematic() {
  let data;
  fetchData().then(result => data = result);  // ❌ Race condition
  return processData(data);  // May execute before data is set
}

// Proper async/await
async function correct() {
  const data = await fetchData();  // ✅ Wait for data
  return processData(data);
}

// Multiple parallel operations
Promise.all([op1(), op2(), op3()])  // Check for interdependencies
```

#### Memory Leaks
**Symptoms**:
- Degrading performance over time
- Increasing memory usage
- Eventually crashes with OOM errors
- Slow garbage collection

**What to Check**:
```javascript
// Event listeners not removed
componentDidMount() {
  window.addEventListener('resize', this.handleResize);
  // ❌ Missing removeEventListener in componentWillUnmount
}

// Closures holding references
function createLeak() {
  const largeData = new Array(1000000);
  return () => console.log(largeData[0]);  // Holds entire array
}

// Timers not cleared
setInterval(() => fetchData(), 1000);  // ❌ Never cleared

// Cache without eviction
const cache = {};
cache[key] = value;  // ❌ Grows indefinitely
```

#### Database Issues
**Symptoms**:
- Slow queries
- Timeouts
- Deadlocks
- Connection pool exhausted

**What to Check**:
```sql
-- Missing indexes
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';
-- Look for "Seq Scan" on large tables

-- N+1 queries
-- Check if ORM is making one query per item in a loop

-- Long transactions
-- Find transactions open for extended periods

-- Lock contention
-- Check for blocking queries and deadlocks
```

#### Network Issues
**Symptoms**:
- Timeouts
- Intermittent connectivity
- DNS resolution failures
- SSL/TLS handshake errors

**What to Check**:
```bash
# DNS resolution
dig api.example.com
nslookup api.example.com

# Network latency
ping api.example.com
traceroute api.example.com

# TCP connection
telnet api.example.com 443
nc -zv api.example.com 443

# SSL/TLS verification
openssl s_client -connect api.example.com:443 -servername api.example.com
```

#### Authentication/Authorization
**Symptoms**:
- 401 Unauthorized errors
- 403 Forbidden errors
- Intermittent authentication failures
- Session expired errors

**What to Check**:
```javascript
// Token expiration
const token = jwt.decode(authToken);
console.log('Token expires:', new Date(token.exp * 1000));

// Session state
console.log('Session:', sessionStorage, localStorage);

// Cookie issues
console.log('Cookies:', document.cookie);

// CORS issues (browser console)
// Look for: "CORS policy: No 'Access-Control-Allow-Origin' header"
```

#### Configuration Issues
**Symptoms**:
- Works locally, fails in environment
- "Environment variable not set" errors
- Connection refused errors
- Permission denied errors

**What to Check**:
```bash
# Environment variables
printenv | grep APPLICATION
env | sort

# Configuration files
cat config/production.json
diff config/development.json config/production.json

# File permissions
ls -la config/
ls -la /var/application/

# Network configuration
cat /etc/hosts
cat /etc/resolv.conf
```

### 4. Hypothesis Testing

Systematically test each hypothesis:

**Testing Strategy**:

1. **Isolation**: Test each component in isolation
2. **Instrumentation**: Add detailed logging around suspected areas
3. **Reproduction**: Create minimal reproduction case
4. **Elimination**: Rule out hypotheses systematically

**Add Diagnostic Instrumentation**:
```javascript
// Detailed logging with context
console.log('[DIAG] Before operation:', {
  timestamp: new Date().toISOString(),
  user: currentUser,
  state: JSON.stringify(currentState),
  params: params
});

try {
  const result = await operation(params);
  console.log('[DIAG] Operation success:', {
    timestamp: new Date().toISOString(),
    result: result,
    duration: Date.now() - startTime
  });
} catch (error) {
  console.error('[DIAG] Operation failed:', {
    timestamp: new Date().toISOString(),
    error: error.message,
    stack: error.stack,
    context: { user, state, params }
  });
  throw error;
}

// Performance timing
console.time('operation');
await operation();
console.timeEnd('operation');

// Memory usage tracking
if (global.gc) {
  global.gc();
  const usage = process.memoryUsage();
  console.log('[MEMORY]', {
    heapUsed: Math.round(usage.heapUsed / 1024 / 1024) + 'MB',
    heapTotal: Math.round(usage.heapTotal / 1024 / 1024) + 'MB',
    external: Math.round(usage.external / 1024 / 1024) + 'MB'
  });
}
```

**Binary Search Debugging**:
```javascript
// Comment out half the code
// Determine which half has the bug
// Repeat until isolated

// Example: Large function with error
function complexOperation() {
  // Part 1: Data fetching
  const data = fetchData();

  // Part 2: Data processing
  const processed = processData(data);

  // Part 3: Data validation
  const validated = validateData(processed);

  // Part 4: Data saving
  return saveData(validated);
}

// Test each part independently
const data = fetchData();
console.log('[TEST] Data fetched:', data);  // ✅ Works

const processed = processData(testData);
console.log('[TEST] Data processed:', processed);  // ❌ Fails here
// Now investigate processData() specifically
```

### 5. Root Cause Identification

Once hypotheses are tested and narrowed down:

**Confirm Root Cause**:
1. Can you consistently reproduce the issue?
2. Does fixing this cause resolve the symptom?
3. Are there other instances of the same issue?
4. Does the fix have any side effects?

**Document Evidence**:
- Specific code/config that causes the issue
- Exact conditions required for issue to manifest
- Why this causes the observed symptom
- Related code that might have same issue

### 6. Impact Assessment

Evaluate the full impact:

**User Impact**:
- Number of users affected
- Severity of impact (blocking, degraded, minor)
- User actions affected
- Business metrics impacted

**System Impact**:
- Performance degradation
- Resource consumption
- Downstream service effects
- Data integrity concerns

**Risk Assessment**:
- Can it cause data loss?
- Can it cause security issues?
- Can it cause cascading failures?
- Is it getting worse over time?

## Output Format

```markdown
# Diagnosis Report: [Issue Summary]

## Executive Summary
[One-paragraph summary of issue, root cause, and recommended action]

## Issue Description

### Symptoms
- [Observable symptom 1]
- [Observable symptom 2]
- [Observable symptom 3]

### Impact
- **Affected Users**: [number/percentage of users]
- **Severity**: [critical|high|medium|low]
- **Frequency**: [always|often|sometimes|rarely - with percentage]
- **Business Impact**: [revenue loss, user experience, etc.]

### Environment
- **Environment**: [production|staging|development]
- **Version**: [application version]
- **Infrastructure**: [relevant infrastructure details]
- **Region**: [if applicable]

### Timeline
- **First Observed**: [date/time]
- **Recent Changes**: [deployments, config changes]
- **Pattern**: [time-based, load-based, user-based]

## Diagnostic Data Collected

### Frontend Analysis
[Console errors, network requests, performance data, state inspection results]

### Backend Analysis
[Application logs, error traces, system metrics, request patterns]

### Database Analysis
[Query logs, lock information, performance metrics, connection pool status]

### Infrastructure Analysis
[Resource usage, container logs, cloud metrics, network diagnostics]

## Hypothesis Analysis

### Hypotheses Considered
1. **[Hypothesis 1]**: [Description]
   - **Evidence For**: [supporting evidence]
   - **Evidence Against**: [contradicting evidence]
   - **Conclusion**: [Ruled out|Confirmed|Needs more investigation]

2. **[Hypothesis 2]**: [Description]
   - **Evidence For**: [supporting evidence]
   - **Evidence Against**: [contradicting evidence]
   - **Conclusion**: [Ruled out|Confirmed|Needs more investigation]

3. **[Hypothesis 3]**: [Description]
   - **Evidence For**: [supporting evidence]
   - **Evidence Against**: [contradicting evidence]
   - **Conclusion**: [Ruled out|Confirmed|Needs more investigation]

## Root Cause

### Root Cause Identified
[Detailed explanation of the root cause with specific code/config references]

### Why It Causes the Symptom
[Technical explanation of how the root cause leads to the observed behavior]

### Why It Wasn't Caught Earlier
[Explanation of why tests/monitoring didn't catch this]

### Related Issues
[Any similar issues that might exist or could be fixed with similar approach]

## Evidence

### Code/Configuration
```[language]
[Specific code or configuration causing the issue]
```

### Reproduction
[Exact steps to reproduce the issue consistently]

### Verification
[Steps taken to confirm this is the root cause]

## Recommended Actions

### Immediate Actions
1. [Immediate action 1 - e.g., rollback, circuit breaker]
2. [Immediate action 2]

### Permanent Fix
[Description of the permanent fix needed]

### Prevention
- **Monitoring**: [What monitoring to add]
- **Testing**: [What tests to add]
- **Code Review**: [What to look for in code reviews]
- **Documentation**: [What to document]

## Next Steps

1. **Fix Implementation**: [Use /debug fix operation]
2. **Verification**: [Testing strategy]
3. **Deployment**: [Rollout plan]
4. **Monitoring**: [What to watch]

## Appendices

### A. Detailed Logs
[Relevant log excerpts with context]

### B. Metrics and Graphs
[Performance metrics, error rates, resource usage]

### C. Related Tickets
[Links to related issues or tickets]
```

## Error Handling

**Insufficient Information**:
If diagnosis cannot be completed due to missing information:
1. List specific information needed
2. Explain why each piece is important
3. Provide instructions for gathering data
4. Suggest interim monitoring

**Cannot Reproduce**:
If issue cannot be reproduced:
1. Document reproduction attempts
2. Request more detailed reproduction steps
3. Suggest environment comparison
4. Propose production debugging approach

**Multiple Root Causes**:
If multiple root causes are identified:
1. Prioritize by impact
2. Explain interdependencies
3. Provide fix sequence
4. Suggest monitoring between fixes

## Integration with Other Operations

After diagnosis is complete:
- **For fixes**: Use `/debug fix` with identified root cause
- **For reproduction**: Use `/debug reproduce` to create reliable test case
- **For log analysis**: Use `/debug analyze-logs` for deeper log investigation
- **For performance**: Use `/debug performance` if performance-related
- **For memory**: Use `/debug memory` if memory-related

## Agent Utilization

This operation leverages the **10x-fullstack-engineer** agent for:
- Systematic cross-layer analysis
- Pattern recognition across stack
- Hypothesis formation and testing
- Production debugging expertise
- Prevention-focused thinking
