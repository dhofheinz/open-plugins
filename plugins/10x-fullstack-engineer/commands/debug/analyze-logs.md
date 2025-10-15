# Analyze Logs Operation - Deep Log Analysis

You are executing the **analyze-logs** operation to perform deep log analysis with pattern detection, timeline correlation, and anomaly identification.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'analyze-logs' operation name)

Expected format: `path:"log-file-path" [pattern:"regex-pattern"] [timeframe:"time-range"] [level:"error|warn|info"] [context:"lines-before-after"]`

## Workflow

### 1. Discover and Locate Logs

Identify all relevant log sources:

**Application Logs**:
```bash
# Common log locations
ls -lh /var/log/application/
ls -lh logs/
ls -lh ~/.pm2/logs/

# Find log files
find /var/log -name "*.log" -type f
find . -name "*.log" -mtime -1  # Modified in last 24 hours

# Check log rotation
ls -lh /var/log/application/*.log*
zcat /var/log/application/app.log.*.gz  # Read rotated logs
```

**System Logs**:
```bash
# Systemd service logs
journalctl -u application.service --since "1 hour ago"
journalctl -u application.service --since "2024-10-14 14:00:00"

# Syslog
tail -f /var/log/syslog
tail -f /var/log/messages

# Kernel logs
dmesg -T
```

**Container Logs**:
```bash
# Docker
docker logs container-name --since 1h
docker logs container-name --timestamps
docker logs --tail 1000 container-name > container-logs.txt

# Kubernetes
kubectl logs pod-name -c container-name
kubectl logs pod-name --previous  # Previous container
kubectl logs -l app=myapp --all-containers=true
```

**Web Server Logs**:
```bash
# Nginx
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# Apache
tail -f /var/log/apache2/access.log
tail -f /var/log/apache2/error.log
```

**Database Logs**:
```bash
# PostgreSQL
tail -f /var/log/postgresql/postgresql-*.log

# MySQL
tail -f /var/log/mysql/error.log
tail -f /var/log/mysql/slow-query.log

# MongoDB
tail -f /var/log/mongodb/mongod.log
```

### 2. Filter and Extract Relevant Logs

Use the `.scripts/analyze-logs.sh` utility to extract relevant log entries:

**Basic Extraction**:
```bash
# Extract errors from last hour
./commands/debug/.scripts/analyze-logs.sh \
  --file logs/application.log \
  --level ERROR \
  --since "1 hour ago"

# Extract with pattern matching
./commands/debug/.scripts/analyze-logs.sh \
  --file logs/application.log \
  --pattern "timeout|connection.*refused" \
  --context 5

# Extract specific timeframe
./commands/debug/.scripts/analyze-logs.sh \
  --file logs/application.log \
  --start "2024-10-14 14:00:00" \
  --end "2024-10-14 15:00:00"
```

**Manual Filtering**:
```bash
# Find errors with context
grep -i "error" logs/application.log -A 5 -B 5

# Find specific error patterns
grep -E "(timeout|refused|failed)" logs/application.log

# Find errors in timeframe
awk '/2024-10-14 14:/ && /ERROR/ {print}' logs/application.log

# Count errors by type
grep "ERROR" logs/application.log | awk '{print $5}' | sort | uniq -c | sort -rn

# Extract JSON logs with jq
cat logs/application.log | jq 'select(.level == "error")'
cat logs/application.log | jq 'select(.message | contains("timeout"))'
```

### 3. Pattern Detection

Identify patterns in log data:

#### Error Patterns

**Frequency Analysis**:
```bash
# Error frequency over time
grep "ERROR" logs/application.log | \
  awk '{print $1, $2}' | \
  cut -d: -f1 | \
  uniq -c

# Most common errors
grep "ERROR" logs/application.log | \
  awk -F'ERROR' '{print $2}' | \
  sort | uniq -c | sort -rn | head -20

# Error rate calculation
total_lines=$(wc -l < logs/application.log)
error_lines=$(grep -c "ERROR" logs/application.log)
echo "Error rate: $(echo "scale=4; $error_lines / $total_lines * 100" | bc)%"
```

**Error Clustering**:
```python
# Group similar errors
import re
from collections import Counter

def normalize_error(error_msg):
    # Remove numbers, IDs, timestamps
    error_msg = re.sub(r'\d+', 'N', error_msg)
    error_msg = re.sub(r'[a-f0-9-]{36}', 'UUID', error_msg)
    error_msg = re.sub(r'\d{4}-\d{2}-\d{2}', 'DATE', error_msg)
    return error_msg

errors = []
with open('logs/application.log') as f:
    for line in f:
        if 'ERROR' in line:
            normalized = normalize_error(line)
            errors.append(normalized)

# Count error types
error_counts = Counter(errors)
for error, count in error_counts.most_common(10):
    print(f"{count}: {error}")
```

#### Request Patterns

**Request Analysis**:
```bash
# Requests per minute
awk '{print $1}' /var/log/nginx/access.log | \
  cut -d: -f1-2 | \
  uniq -c

# Most requested endpoints
awk '{print $7}' /var/log/nginx/access.log | \
  sort | uniq -c | sort -rn | head -20

# Response code distribution
awk '{print $9}' /var/log/nginx/access.log | \
  sort | uniq -c | sort -rn

# Slow requests (>1 second)
awk '$10 > 1.0 {print $0}' /var/log/nginx/access.log

# Top user agents
awk -F'"' '{print $6}' /var/log/nginx/access.log | \
  sort | uniq -c | sort -rn | head -10
```

#### Performance Patterns

**Response Time Analysis**:
```bash
# Average response time
awk '{sum+=$10; count++} END {print "Average:", sum/count}' \
  /var/log/nginx/access.log

# Response time percentiles
awk '{print $10}' /var/log/nginx/access.log | \
  sort -n | \
  awk '{
    times[NR] = $1
  }
  END {
    print "P50:", times[int(NR*0.5)]
    print "P95:", times[int(NR*0.95)]
    print "P99:", times[int(NR*0.99)]
  }'

# Response time over time
awk '{print $4, $10}' /var/log/nginx/access.log | \
  awk -F'[:]' '{print $1":"$2, $NF}' | \
  awk '{sum[$1]+=$2; count[$1]++} END {
    for (time in sum) print time, sum[time]/count[time]
  }' | sort
```

### 4. Timeline Analysis

Create timeline of events:

**Timeline Construction**:
```bash
# Merge multiple log sources by timestamp
sort -m -k1,2 \
  logs/application.log \
  logs/database.log \
  logs/nginx.log \
  > merged-timeline.log

# Extract timeline around specific event
event_time="2024-10-14 14:30:15"
grep "$event_time" logs/application.log -B 100 -A 100

# Timeline with multiple sources
for log in logs/*.log; do
  echo "=== $(basename $log) ==="
  grep "$event_time" "$log" -B 10 -A 10
  echo ""
done
```

**Event Correlation**:
```python
# Correlate events across log sources
import re
from datetime import datetime, timedelta

def parse_log_line(line):
    # Extract timestamp and message
    match = re.match(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})', line)
    if match:
        timestamp = datetime.strptime(match.group(1), '%Y-%m-%d %H:%M:%S')
        return timestamp, line
    return None, None

# Load events from multiple logs
events = []
for log_file in ['app.log', 'db.log', 'nginx.log']:
    with open(f'logs/{log_file}') as f:
        for line in f:
            timestamp, message = parse_log_line(line)
            if timestamp:
                events.append((timestamp, log_file, message))

# Sort by timestamp
events.sort(key=lambda x: x[0])

# Find events within time window
def find_related_events(target_time, window_seconds=10):
    window = timedelta(seconds=window_seconds)
    start_time = target_time - window
    end_time = target_time + window

    related = [
        event for event in events
        if start_time <= event[0] <= end_time
    ]

    return related

# Analyze error event
error_time = datetime(2024, 10, 14, 14, 30, 15)
related = find_related_events(error_time)

for timestamp, source, message in related:
    print(f"[{source}] {timestamp}: {message.strip()}")
```

### 5. Request Tracing

Trace individual requests across services:

**Request ID Tracing**:
```bash
# Extract request ID from error
error_line=$(grep "ERROR" logs/application.log | head -1)
request_id=$(echo "$error_line" | grep -oP 'request_id=\K[a-f0-9-]+')

echo "Tracing request: $request_id"

# Find all log entries for this request
grep "$request_id" logs/application.log

# Across multiple services
for log in logs/*.log; do
  echo "=== $(basename $log) ==="
  grep "$request_id" "$log"
done

# With timestamps for timeline
grep "$request_id" logs/*.log | sort -k1,2
```

**Distributed Tracing Correlation**:
```bash
# Extract trace ID from logs
trace_id=$(grep "ERROR" logs/application.log | \
  head -1 | \
  grep -oP 'trace_id=\K[a-f0-9]+')

# Query distributed tracing system
# Jaeger
curl "http://jaeger:16686/api/traces/$trace_id"

# Zipkin
curl "http://zipkin:9411/api/v2/trace/$trace_id"
```

### 6. Anomaly Detection

Identify unusual patterns:

**Statistical Anomalies**:
```python
import statistics
from collections import defaultdict

# Analyze error rates per hour
hourly_errors = defaultdict(int)

with open('logs/application.log') as f:
    for line in f:
        if 'ERROR' in line:
            # Extract hour
            hour = line[:13]  # YYYY-MM-DD HH
            hourly_errors[hour] += 1

# Calculate statistics
error_counts = list(hourly_errors.values())
mean = statistics.mean(error_counts)
stdev = statistics.stdev(error_counts)

# Find anomalies (>2 standard deviations)
print("Anomalous hours (>2 std dev from mean):")
for hour, count in sorted(hourly_errors.items()):
    z_score = (count - mean) / stdev
    if abs(z_score) > 2:
        print(f"{hour}: {count} errors (z-score: {z_score:.2f})")
```

**New Error Types**:
```bash
# Compare today's errors with baseline
grep "ERROR" logs/application.log.1 | \
  awk -F'ERROR' '{print $2}' | \
  sort -u > baseline_errors.txt

grep "ERROR" logs/application.log | \
  awk -F'ERROR' '{print $2}' | \
  sort -u > current_errors.txt

# Find new error types
comm -13 baseline_errors.txt current_errors.txt > new_errors.txt

echo "New error types detected:"
cat new_errors.txt
```

**Spike Detection**:
```python
# Detect sudden spikes in error rate
from collections import deque

def detect_spikes(values, window_size=10, threshold=3):
    """Detect values that are >threshold times the rolling average"""
    window = deque(maxlen=window_size)
    spikes = []

    for i, value in enumerate(values):
        if len(window) == window_size:
            avg = sum(window) / len(window)
            if value > avg * threshold:
                spikes.append((i, value, avg))

        window.append(value)

    return spikes

# Analyze minute-by-minute error counts
minute_errors = {}  # {minute: error_count}

with open('logs/application.log') as f:
    for line in f:
        if 'ERROR' in line:
            minute = line[:16]  # YYYY-MM-DD HH:MM
            minute_errors[minute] = minute_errors.get(minute, 0) + 1

# Detect spikes
error_counts = [minute_errors.get(m, 0) for m in sorted(minute_errors.keys())]
spikes = detect_spikes(error_counts, window_size=10, threshold=3)

print("Error spikes detected:")
for idx, value, avg in spikes:
    print(f"Minute {idx}: {value} errors (avg was {avg:.1f})")
```

### 7. Performance Analysis

Analyze performance from logs:

**Slow Query Analysis**:
```bash
# PostgreSQL slow query log
cat /var/log/postgresql/postgresql.log | \
  grep "duration:" | \
  awk '{print $13, $0}' | \
  sort -rn | \
  head -20

# Extract slow queries
awk '/duration:/ && $13 > 1000 {print $0}' \
  /var/log/postgresql/postgresql.log
```

**Endpoint Performance**:
```bash
# Average response time per endpoint
awk '{endpoint[$7] += $10; count[$7]++}
END {
  for (e in endpoint) {
    printf "%s: %.2fms\n", e, endpoint[e]/count[e]
  }
}' /var/log/nginx/access.log | sort -t: -k2 -rn

# Slowest endpoints
awk '{print $10, $7}' /var/log/nginx/access.log | \
  sort -rn | \
  head -20
```

### 8. User Impact Analysis

Assess user-facing impact:

**Affected Users**:
```bash
# Extract unique users experiencing errors
grep "ERROR" logs/application.log | \
  grep -oP 'user_id=\K[a-zA-Z0-9]+' | \
  sort -u | \
  wc -l

# Error rate by user
grep "ERROR" logs/application.log | \
  grep -oP 'user_id=\K[a-zA-Z0-9]+' | \
  sort | uniq -c | sort -rn | head -20

# Users with most errors
grep "user_id=" logs/application.log | \
  awk '{
    total[$0]++
    if (/ERROR/) errors[$0]++
  }
  END {
    for (user in total) {
      print user, errors[user]/total[user]*100"%"
    }
  }' | sort -t% -k2 -rn
```

**Failed Requests**:
```bash
# 5xx errors
grep " 5[0-9][0-9] " /var/log/nginx/access.log

# Failed endpoints
awk '$9 >= 500 {print $7}' /var/log/nginx/access.log | \
  sort | uniq -c | sort -rn

# Failed request details
awk '$9 >= 500 {print $4, $7, $9, $10}' \
  /var/log/nginx/access.log
```

### 9. Resource Usage from Logs

Extract resource usage patterns:

**Memory Usage**:
```bash
# Extract memory logs
grep -i "memory\|heap\|oom" logs/application.log

# Parse memory usage
grep "heap_used" logs/application.log | \
  awk '{print $1, $2, $NF}' | \
  sed 's/MB$//'
```

**Connection Pool**:
```bash
# Database connection logs
grep "connection" logs/application.log | \
  grep -oP 'pool_size=\K\d+|active=\K\d+|idle=\K\d+'

# Connection exhaustion
grep "connection.*timeout\|pool.*exhausted" logs/application.log -A 5
```

### 10. Security Analysis

Look for security-related issues:

**Authentication Failures**:
```bash
# Failed login attempts
grep -i "authentication.*failed\|login.*failed" logs/application.log

# By IP address
grep "authentication.*failed" logs/application.log | \
  grep -oP 'ip=\K[\d.]+' | \
  sort | uniq -c | sort -rn

# Brute force detection
grep "authentication.*failed" logs/application.log | \
  grep -oP 'ip=\K[\d.]+' | \
  uniq -c | \
  awk '$1 > 10 {print $2, $1 " attempts"}'
```

**Suspicious Patterns**:
```bash
# SQL injection attempts
grep -iE "union.*select|drop.*table|; --" /var/log/nginx/access.log

# Path traversal attempts
grep -E "\.\./|\.\.%2F" /var/log/nginx/access.log

# XSS attempts
grep -iE "<script|javascript:|onerror=" /var/log/nginx/access.log

# Command injection attempts
grep -E ";\s*(cat|ls|wget|curl)" /var/log/nginx/access.log
```

## Output Format

```markdown
# Log Analysis Report: [Issue/Time Period]

## Summary
[High-level summary of findings]

## Analysis Period
- **Start**: [start timestamp]
- **End**: [end timestamp]
- **Duration**: [duration]
- **Log Sources**: [list of logs analyzed]
- **Total Lines**: [number of log lines]

## Key Findings

### Error Analysis
- **Total Errors**: [count]
- **Error Rate**: [percentage]%
- **Error Types**: [number of unique error types]
- **Most Common Error**: [error type] ([count] occurrences)

### Top Errors

1. **[Error Type 1]** - [count] occurrences
   ```
   [sample log line]
   ```
   - First seen: [timestamp]
   - Last seen: [timestamp]
   - Peak: [timestamp with highest frequency]

2. **[Error Type 2]** - [count] occurrences
   ```
   [sample log line]
   ```
   - [similar details]

### Patterns Detected

#### Pattern 1: [Pattern Name]
- **Description**: [what pattern is]
- **Frequency**: [how often it occurs]
- **Impact**: [user/system impact]
- **Example**:
  ```
  [log excerpt showing pattern]
  ```

#### Pattern 2: [Pattern Name]
[similar structure]

## Timeline Analysis

### Critical Events Timeline

\`\`\`
14:25:30 [APP] Normal operation, avg response time 50ms
14:28:45 [APP] Response time increasing to 150ms
14:29:10 [DB] Connection pool usage at 90%
14:29:30 [APP] First timeout errors appear
14:29:45 [DB] Connection pool exhausted
14:30:00 [APP] Error rate spikes to 25%
14:30:15 [APP] Circuit breaker opens
14:30:30 [OPS] Auto-scaling triggers
14:32:00 [APP] New instances online
14:33:00 [APP] Error rate decreases to 5%
14:35:00 [APP] Full recovery, normal operation
\`\`\`

### Event Correlation

**Root Event**: Database connection pool exhaustion at 14:29:45

**Contributing Factors**:
- High traffic spike (+300% at 14:28:00)
- Long-running queries (>5s queries detected)
- Insufficient connection pool size (max: 20)

**Cascading Effects**:
- API timeouts (starting 14:29:30)
- Cache misses due to timeouts
- Increased load from retries
- Circuit breaker activation

## Request Tracing

### Example Failed Request

**Request ID**: req_abc123def456

**Timeline**:
\`\`\`
14:30:15.123 [NGINX] Request received: POST /api/orders
14:30:15.125 [APP] Request processing started
14:30:15.130 [APP] Database query started: SELECT orders...
14:30:20.131 [DB] Query timeout after 5s
14:30:20.135 [APP] Error: Database timeout
14:30:20.137 [APP] Response: 500 Internal Server Error
14:30:20.140 [NGINX] Response sent (5017ms)
\`\`\`

**User Impact**: Order creation failed for user_123

## Anomalies Detected

### Anomaly 1: Error Rate Spike
- **Time**: 14:30:00 - 14:35:00
- **Severity**: High
- **Details**: Error rate jumped from 0.1% to 25%
- **Affected Users**: ~500 users
- **Root Cause**: Database connection pool exhaustion

### Anomaly 2: New Error Type
- **Error**: "ConnectionPoolExhausted"
- **First Seen**: 14:29:45
- **Frequency**: 1,234 occurrences in 5 minutes
- **Status**: Previously unseen in baseline

## Performance Analysis

### Response Time Statistics
- **Average**: 150ms (baseline: 50ms)
- **P50**: 80ms
- **P95**: 500ms
- **P99**: 2000ms
- **Max**: 5000ms

### Slowest Endpoints
1. `/api/orders` - avg 450ms (1,200 requests)
2. `/api/users/profile` - avg 380ms (800 requests)
3. `/api/reports` - avg 320ms (200 requests)

### Database Performance
- **Slow Queries**: 45 queries >1s
- **Slowest Query**: 5.2s (SELECT with missing index)
- **Average Query Time**: 85ms (baseline: 25ms)

## User Impact

### Affected Users
- **Total Affected**: ~500 users
- **Error Rate by User Type**:
  - Premium users: 5% error rate
  - Free users: 30% error rate
- **Most Affected User**: user_789 (25 errors)

### Failed Operations
- **Order Creation**: 234 failures
- **Payment Processing**: 89 failures
- **Profile Updates**: 45 failures

## Resource Analysis

### Connection Pool
- **Max Size**: 20 connections
- **Peak Usage**: 20/20 (100%)
- **Average Wait Time**: 2.5s
- **Recommendation**: Increase to 50 connections

### Memory Usage
- **Average**: 450MB
- **Peak**: 890MB
- **Trend**: Stable (no leak detected)

## Security Findings

### Authentication
- **Failed Logins**: 12
- **Suspicious IPs**: 2 IPs with >5 failed attempts
- **Brute Force Attempts**: None detected

### Attack Patterns
- **SQL Injection Attempts**: 0
- **XSS Attempts**: 0
- **Path Traversal**: 0

## Root Cause Analysis

Based on log analysis:

**Primary Cause**: Database connection pool too small for traffic volume

**Contributing Factors**:
1. Traffic spike (+300%)
2. Slow queries consuming connections
3. No connection timeout configured

**Evidence**:
- Connection pool exhausted at 14:29:45
- Immediate correlation with error spike
- Recovery after auto-scaling added capacity

## Recommendations

### Immediate Actions
1. Increase database connection pool to 50
2. Add connection timeout (30s)
3. Optimize slow queries identified

### Monitoring Improvements
1. Alert on connection pool usage >80%
2. Track query duration P95
3. Monitor error rate per endpoint

### Code Changes
1. Add query timeouts to all database calls
2. Implement connection retry logic
3. Add circuit breaker for database calls

## Next Steps

1. **Fix**: Use `/debug fix` to implement connection pool increase
2. **Performance**: Use `/debug performance` to optimize slow queries
3. **Monitoring**: Add alerts for connection pool usage

## Appendices

### A. Full Error Log Excerpt
\`\`\`
[Relevant log excerpts]
\`\`\`

### B. Query Performance Data
\`\`\`sql
[Slow query details]
\`\`\`

### C. Traffic Pattern Graph
\`\`\`
[ASCII graph or description of traffic pattern]
\`\`\`
```

## Error Handling

**Logs Not Found**:
If specified log files don't exist:
1. List available log files
2. Suggest alternative log locations
3. Provide commands to locate logs

**Logs Too Large**:
If logs are too large to analyze:
1. Focus on most recent data
2. Use sampling techniques
3. Analyze specific time windows
4. Suggest log aggregation tools

**Insufficient Context**:
If logs lack necessary information:
1. Document what information is missing
2. Suggest additional logging
3. Recommend structured logging format
4. Propose log enrichment strategies

## Integration with Other Operations

- **Before**: Use `/debug diagnose` to identify time period to analyze
- **After**: Use `/debug fix` to address issues found in logs
- **Related**: Use `/debug performance` for performance issues
- **Related**: Use `/debug reproduce` to recreate issues found in logs

## Agent Utilization

This operation leverages the **10x-fullstack-engineer** agent for:
- Pattern recognition across large log volumes
- Correlating events across multiple log sources
- Statistical analysis and anomaly detection
- Root cause inference from log patterns
- Actionable recommendations based on findings
