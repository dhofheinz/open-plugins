# Debug Skill - Comprehensive Debugging Toolkit

A professional-grade debugging skill for diagnosing, reproducing, fixing, analyzing, and optimizing complex issues across the entire application stack.

## Overview

The debug skill provides systematic debugging operations that work seamlessly with the **10x-fullstack-engineer** agent to deliver cross-stack debugging expertise, production-grade strategies, and prevention-focused solutions.

## Available Operations

### 1. **diagnose** - Comprehensive Diagnosis and Root Cause Analysis

Performs systematic diagnosis across all layers of the application stack to identify root causes of complex issues.

**Usage:**
```bash
/10x-fullstack-engineer:debug diagnose issue:"Users getting 500 errors on file upload" environment:"production" logs:"logs/app.log"
```

**Parameters:**
- `issue:"description"` (required) - Problem description
- `environment:"prod|staging|dev"` (optional) - Target environment
- `logs:"path"` (optional) - Log file location
- `reproduction:"steps"` (optional) - Steps to reproduce
- `impact:"severity"` (optional) - Issue severity

**What it does:**
- Collects diagnostic data from frontend, backend, database, and infrastructure
- Analyzes symptoms and patterns across all stack layers
- Forms and tests hypotheses systematically
- Identifies root cause with supporting evidence
- Provides actionable recommendations

**Output:**
- Executive summary of issue and root cause
- Detailed diagnostic data from each layer
- Hypothesis analysis with evidence
- Root cause explanation
- Recommended immediate actions and permanent fix
- Prevention measures (monitoring, testing, documentation)

---

### 2. **reproduce** - Create Reliable Reproduction Strategies

Develops reliable strategies to reproduce issues consistently, creating test cases and reproduction documentation.

**Usage:**
```bash
/10x-fullstack-engineer:debug reproduce issue:"Payment webhook fails intermittently" environment:"staging" data:"sample-webhook-payload.json"
```

**Parameters:**
- `issue:"description"` (required) - Issue to reproduce
- `environment:"prod|staging|dev"` (optional) - Environment context
- `data:"path"` (optional) - Test data location
- `steps:"description"` (optional) - Known reproduction steps
- `reliability:"percentage"` (optional) - Current reproduction rate

**What it does:**
- Gathers environment, data, and user context
- Creates local reproduction strategy
- Develops automated test cases (unit, integration, E2E)
- Tests scenario variations and edge cases
- Verifies reproduction reliability
- Documents comprehensive reproduction guide

**Output:**
- Reproduction reliability metrics
- Prerequisites and setup instructions
- Detailed reproduction steps (manual and automated)
- Automated test case code
- Scenario variations tested
- Troubleshooting guide for reproduction issues

---

### 3. **fix** - Implement Targeted Fixes with Verification

Implements targeted fixes with comprehensive verification, safeguards, and prevention measures.

**Usage:**
```bash
/10x-fullstack-engineer:debug fix issue:"Race condition in order processing" root_cause:"Missing transaction lock" verification:"run-integration-tests"
```

**Parameters:**
- `issue:"description"` (required) - Issue being fixed
- `root_cause:"cause"` (required) - Identified root cause
- `verification:"strategy"` (optional) - Verification approach
- `scope:"areas"` (optional) - Affected code areas
- `rollback:"plan"` (optional) - Rollback strategy

**What it does:**
- Designs appropriate fix pattern for the issue type
- Implements fix with safety measures
- Adds safeguards (validation, rate limiting, circuit breakers)
- Performs multi-level verification (unit, integration, load, production)
- Adds prevention measures (tests, monitoring, alerts)
- Documents fix and deployment plan

**Fix patterns supported:**
- Missing error handling
- Race conditions
- Memory leaks
- Missing validation
- N+1 query problems
- Configuration issues
- Infrastructure limits

**Output:**
- Detailed fix implementation with before/after code
- Safeguards added (validation, error handling, monitoring)
- Verification results at all levels
- Prevention measures (tests, alerts, documentation)
- Deployment plan with rollback strategy
- Files modified and commits made

---

### 4. **analyze-logs** - Deep Log Analysis with Pattern Detection

Performs deep log analysis with pattern detection, timeline correlation, and anomaly identification.

**Usage:**
```bash
/10x-fullstack-engineer:debug analyze-logs path:"logs/application.log" pattern:"ERROR.*timeout" timeframe:"last-24h"
```

**Parameters:**
- `path:"log-file-path"` (required) - Log file to analyze
- `pattern:"regex"` (optional) - Filter pattern
- `timeframe:"range"` (optional) - Time range to analyze
- `level:"error|warn|info"` (optional) - Log level filter
- `context:"lines"` (optional) - Context lines around matches

**What it does:**
- Discovers and filters relevant logs across all sources
- Detects error patterns and clusters similar errors
- Performs timeline analysis and event correlation
- Traces individual requests across services
- Identifies statistical anomalies and spikes
- Analyzes performance, user impact, and security issues

**Utility script:**
```bash
./commands/debug/.scripts/analyze-logs.sh \
  --file logs/application.log \
  --level ERROR \
  --since "1 hour ago" \
  --context 5
```

**Output:**
- Summary of findings with key statistics
- Top errors with frequency and patterns
- Timeline of critical events
- Request tracing through distributed system
- Anomaly detection (spikes, new errors)
- Performance analysis from logs
- User impact assessment
- Root cause analysis based on log patterns
- Recommendations for fixes and monitoring

---

### 5. **performance** - Performance Debugging and Optimization

Debugs performance issues through profiling, bottleneck identification, and targeted optimization.

**Usage:**
```bash
/10x-fullstack-engineer:debug performance component:"api-endpoint:/orders" metric:"response-time" threshold:"200ms"
```

**Parameters:**
- `component:"name"` (required) - Component to profile
- `metric:"type"` (optional) - Metric to measure (response-time, throughput, cpu, memory)
- `threshold:"value"` (optional) - Target performance threshold
- `duration:"period"` (optional) - Profiling duration
- `load:"users"` (optional) - Concurrent users for load testing

**What it does:**
- Establishes performance baseline
- Profiles application, database, and network
- Identifies bottlenecks (CPU, I/O, memory, network)
- Implements targeted optimizations (queries, caching, algorithms, async)
- Performs load testing to verify improvements
- Sets up performance monitoring

**Profiling utility script:**
```bash
./commands/debug/.scripts/profile.sh \
  --app node_app \
  --duration 60 \
  --endpoint http://localhost:3000/api/slow
```

**Optimization strategies:**
- Query optimization (indexes, query rewriting)
- Caching (application-level, Redis)
- Code optimization (algorithms, lazy loading, pagination)
- Async optimization (parallel execution, batching)

**Output:**
- Performance baseline and after-optimization metrics
- Bottlenecks identified with evidence
- Optimizations implemented with code changes
- Load testing results
- Performance improvement percentages
- Monitoring setup (metrics, dashboards, alerts)
- Recommendations for additional optimizations

---

### 6. **memory** - Memory Leak Detection and Optimization

Detects memory leaks, analyzes memory usage patterns, and optimizes memory consumption.

**Usage:**
```bash
/10x-fullstack-engineer:debug memory component:"background-worker" symptom:"growing-heap" duration:"6h"
```

**Parameters:**
- `component:"name"` (required) - Component to analyze
- `symptom:"type"` (optional) - Memory symptom (growing-heap, high-usage, oom)
- `duration:"period"` (optional) - Observation period
- `threshold:"max-mb"` (optional) - Memory threshold in MB
- `profile:"type"` (optional) - Profile type (heap, allocation)

**What it does:**
- Identifies memory symptoms (leaks, high usage, OOM)
- Captures memory profiles (heap snapshots, allocation tracking)
- Analyzes common leak patterns
- Implements memory optimizations
- Performs leak verification under load
- Tunes garbage collection

**Memory check utility script:**
```bash
./commands/debug/.scripts/memory-check.sh \
  --app node_app \
  --duration 300 \
  --interval 10 \
  --threshold 1024
```

**Common leak patterns detected:**
- Event listeners not removed
- Timers not cleared
- Closures holding references
- Unbounded caches
- Global variable accumulation
- Detached DOM nodes
- Infinite promise chains

**Optimization techniques:**
- Stream large data instead of loading into memory
- Use efficient data structures (Map vs Array)
- Paginate database queries
- Implement LRU caches with size limits
- Use weak references where appropriate
- Object pooling for frequently created objects

**Output:**
- Memory symptoms and baseline metrics
- Heap snapshot analysis
- Memory leaks identified with evidence
- Fixes implemented with before/after code
- Memory after fixes with improvement percentages
- Memory stability test results
- Garbage collection metrics
- Monitoring setup and alerts
- Recommendations for memory limits and future monitoring

---

## Utility Scripts

The debug skill includes three utility scripts in `.scripts/` directory:

### analyze-logs.sh
**Purpose:** Analyze log files for patterns, errors, and anomalies

**Features:**
- Pattern matching with regex
- Log level filtering
- Time-based filtering
- Context lines around matches
- Error statistics and top errors
- Time distribution analysis
- JSON output support

### profile.sh
**Purpose:** Profile application performance (CPU, memory, I/O)

**Features:**
- CPU profiling with statistics
- Memory profiling with growth detection
- I/O profiling
- Concurrent load testing
- Automated recommendations
- Comprehensive reports

### memory-check.sh
**Purpose:** Monitor memory usage and detect leaks

**Features:**
- Real-time memory monitoring
- Memory growth detection
- Leak detection with trend analysis
- ASCII memory usage charts
- Threshold alerts
- Detailed memory reports

---

## Common Debugging Workflows

### Workflow 1: Production Error Investigation

```bash
# Step 1: Diagnose the issue
/10x-fullstack-engineer:debug diagnose issue:"500 errors on checkout" environment:"production" logs:"logs/app.log"

# Step 2: Analyze logs for patterns
/10x-fullstack-engineer:debug analyze-logs path:"logs/app.log" pattern:"checkout.*ERROR" timeframe:"last-1h"

# Step 3: Reproduce locally
/10x-fullstack-engineer:debug reproduce issue:"Checkout fails with 500" environment:"staging" data:"test-checkout.json"

# Step 4: Implement fix
/10x-fullstack-engineer:debug fix issue:"Database timeout on checkout" root_cause:"Missing connection pool configuration"
```

### Workflow 2: Performance Degradation

```bash
# Step 1: Profile performance
/10x-fullstack-engineer:debug performance component:"api-endpoint:/checkout" metric:"response-time" threshold:"500ms"

# Step 2: Analyze slow queries
/10x-fullstack-engineer:debug analyze-logs path:"logs/postgresql.log" pattern:"duration:.*[0-9]{4,}"

# Step 3: Implement optimization
/10x-fullstack-engineer:debug fix issue:"Slow checkout API" root_cause:"N+1 query on order items"
```

### Workflow 3: Memory Leak Investigation

```bash
# Step 1: Diagnose memory symptoms
/10x-fullstack-engineer:debug diagnose issue:"Memory grows over time" environment:"production"

# Step 2: Profile memory usage
/10x-fullstack-engineer:debug memory component:"background-processor" symptom:"growing-heap" duration:"1h"

# Step 3: Implement fix
/10x-fullstack-engineer:debug fix issue:"Memory leak in event handlers" root_cause:"Event listeners not removed"
```

### Workflow 4: Intermittent Failure

```bash
# Step 1: Reproduce reliably
/10x-fullstack-engineer:debug reproduce issue:"Random payment failures" environment:"staging"

# Step 2: Diagnose with reproduction
/10x-fullstack-engineer:debug diagnose issue:"Payment webhook fails intermittently" reproduction:"steps-from-reproduce"

# Step 3: Analyze timing
/10x-fullstack-engineer:debug analyze-logs path:"logs/webhooks.log" pattern:"payment.*fail" context:10

# Step 4: Fix race condition
/10x-fullstack-engineer:debug fix issue:"Race condition in webhook handler" root_cause:"Concurrent webhook processing"
```

---

## Integration with 10x-fullstack-engineer Agent

All debugging operations are designed to work with the **10x-fullstack-engineer** agent, which provides:

- **Cross-stack debugging expertise** - Systematic analysis across frontend, backend, database, and infrastructure
- **Systematic root cause analysis** - Hypothesis formation, testing, and evidence-based conclusions
- **Production-grade debugging strategies** - Safe, reliable approaches suitable for production environments
- **Performance and security awareness** - Considers performance impact and security implications
- **Prevention-focused mindset** - Not just fixing issues, but preventing future occurrences

The agent brings deep expertise in:
- Full-stack architecture patterns
- Performance optimization techniques
- Memory management and leak detection
- Database query optimization
- Distributed systems debugging
- Production safety and deployment strategies

---

## Debugging Best Practices

### 1. Start with Diagnosis
Always begin with `/debug diagnose` to understand the full scope of the issue before attempting fixes.

### 2. Reproduce Reliably
Use `/debug reproduce` to create reproducible test cases. A bug that can't be reliably reproduced is hard to fix and verify.

### 3. Analyze Logs Systematically
Use `/debug analyze-logs` to find patterns and correlations. Look for:
- Error frequency and distribution
- Timeline correlation with deployments
- Anomalies and spikes
- Request tracing across services

### 4. Profile Before Optimizing
Use `/debug performance` and `/debug memory` to identify actual bottlenecks. Don't optimize based on assumptions.

### 5. Fix with Verification
Use `/debug fix` which includes:
- Proper error handling
- Comprehensive testing
- Monitoring and alerts
- Documentation

### 6. Add Prevention Measures
Every fix should include:
- Regression tests
- Monitoring metrics
- Alerts on thresholds
- Documentation updates

---

## Output Documentation

Each operation generates comprehensive reports in markdown format:

- **Executive summaries** for stakeholders
- **Detailed technical analysis** for engineers
- **Code snippets** with before/after comparisons
- **Evidence and metrics** supporting conclusions
- **Actionable recommendations** with priorities
- **Next steps** with clear instructions

Reports include:
- Issue description and symptoms
- Analysis methodology and findings
- Root cause explanation with evidence
- Fixes implemented with code
- Verification results
- Prevention measures added
- Files modified and commits
- Monitoring and alerting setup

---

## Error Handling

All operations include robust error handling:

- **Insufficient information** - Lists what's needed and how to gather it
- **Cannot reproduce** - Suggests alternative debugging approaches
- **Fix verification fails** - Provides re-diagnosis steps
- **Optimization degrades performance** - Includes rollback procedures
- **Environment differences** - Helps bridge local vs production gaps

---

## Common Debugging Scenarios

### Database Performance Issues
1. Use `/debug performance` to establish baseline
2. Use `/debug analyze-logs` on database slow query logs
3. Identify missing indexes or inefficient queries
4. Use `/debug fix` to implement optimization
5. Verify with load testing

### Memory Leaks
1. Use `/debug diagnose` to identify symptoms
2. Use `/debug memory` to capture heap profiles
3. Identify leak patterns (event listeners, timers, caches)
4. Use `/debug fix` to implement cleanup
5. Verify with sustained load testing

### Intermittent Errors
1. Use `/debug analyze-logs` to find error patterns
2. Use `/debug reproduce` to create reliable reproduction
3. Use `/debug diagnose` with reproduction steps
4. Identify timing or concurrency issues
5. Use `/debug fix` to implement proper synchronization

### Production Incidents
1. Use `/debug diagnose` for rapid root cause analysis
2. Use `/debug analyze-logs` for recent time period
3. Implement immediate mitigation (rollback, circuit breaker)
4. Use `/debug reproduce` to prevent recurrence
5. Use `/debug fix` for permanent solution

### Performance Degradation
1. Use `/debug performance` to compare against baseline
2. Identify bottlenecks (CPU, I/O, memory, network)
3. Use `/debug analyze-logs` for slow operations
4. Implement targeted optimizations
5. Verify improvements with load testing

---

## Tips and Tricks

### Effective Log Analysis
- Use pattern matching to find related errors
- Look for request IDs to trace across services
- Check timestamps for correlation with deployments
- Compare error rates before and after changes
- Use context lines to understand error conditions

### Performance Profiling
- Profile production-like workloads
- Use realistic data sizes
- Test under sustained load, not just peak
- Profile both CPU and memory together
- Use flame graphs for visual analysis

### Memory Debugging
- Force GC between measurements for accuracy
- Take multiple heap snapshots over time
- Look for objects that never get collected
- Check for consistent growth, not just spikes
- Verify fixes with extended monitoring

### Reproduction Strategies
- Minimize reproduction to essential steps
- Control timing with explicit delays
- Use specific test data that triggers issue
- Document environment differences
- Aim for >80% reproduction reliability

---

## File Locations

```
plugins/10x-fullstack-engineer/commands/debug/
├── skill.md                 # Router/orchestrator
├── diagnose.md             # Diagnosis operation
├── reproduce.md            # Reproduction operation
├── fix.md                  # Fix implementation operation
├── analyze-logs.md         # Log analysis operation
├── performance.md          # Performance debugging operation
├── memory.md               # Memory debugging operation
├── .scripts/
│   ├── analyze-logs.sh     # Log analysis utility
│   ├── profile.sh          # Performance profiling utility
│   └── memory-check.sh     # Memory monitoring utility
└── README.md               # This file
```

---

## Requirements

- **Node.js operations**: Node.js runtime with `--inspect` or `--prof` flags for profiling
- **Log analysis**: Standard Unix tools (awk, grep, sed), optional jq for JSON logs
- **Performance profiling**: Apache Bench (ab), k6, or Artillery for load testing
- **Memory profiling**: Chrome DevTools, clinic.js, or memwatch for Node.js
- **Database profiling**: Access to database query logs and EXPLAIN ANALYZE capability

---

## Support and Troubleshooting

If operations fail:
1. Check that required parameters are provided
2. Verify file paths and permissions
3. Ensure utility scripts are executable (`chmod +x .scripts/*.sh`)
4. Check that prerequisite tools are installed
5. Review error messages for specific issues

For complex debugging scenarios:
- Start with `/debug diagnose` for systematic analysis
- Use multiple operations in sequence for comprehensive investigation
- Leverage the 10x-fullstack-engineer agent's expertise
- Document findings and share with team

---

## Version

Debug Skill v1.0.0

---

## License

Part of the 10x-fullstack-engineer plugin for Claude Code.
