# Fix Operation - Targeted Fix Implementation

You are executing the **fix** operation to implement targeted fixes with comprehensive verification and prevention measures.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'fix' operation name)

Expected format: `issue:"problem description" root_cause:"identified-cause" [verification:"test-strategy"] [scope:"affected-areas"] [rollback:"rollback-plan"]`

## Workflow

### 1. Understand the Fix Requirements

Clarify what needs to be fixed and constraints:

**Key Information**:
- **Root Cause**: Exact cause to address (from diagnosis)
- **Scope**: What code/config/infrastructure needs changing
- **Constraints**: Performance, backwards compatibility, security
- **Verification**: How to verify the fix works
- **Rollback**: Plan if fix causes problems

**Fix Strategy Questions**:
```markdown
- Is this a code fix, configuration fix, or infrastructure fix?
- Are there multiple ways to fix this? Which is best?
- What are the side effects of the fix?
- Can we fix just the symptom or must we fix the root cause?
- Is there existing code doing this correctly we can learn from?
- What is the blast radius if the fix goes wrong?
```

### 2. Design the Fix

Plan the implementation approach:

#### Fix Pattern Selection

**Code Fix Patterns**:

**1. Add Missing Error Handling**
```javascript
// Before (causes crashes)
async function processPayment(orderId) {
  const order = await db.orders.findById(orderId);
  return await paymentGateway.charge(order.amount);
}

// After (handles errors properly)
async function processPayment(orderId) {
  try {
    const order = await db.orders.findById(orderId);

    if (!order) {
      throw new Error(`Order ${orderId} not found`);
    }

    if (order.status !== 'pending') {
      throw new Error(`Order ${orderId} is not in pending status`);
    }

    const result = await paymentGateway.charge(order.amount);

    if (!result.success) {
      throw new Error(`Payment failed: ${result.error}`);
    }

    return result;
  } catch (error) {
    logger.error('Payment processing failed', {
      orderId,
      error: error.message,
      stack: error.stack
    });
    throw new PaymentError(`Failed to process payment for order ${orderId}`, error);
  }
}
```

**2. Fix Race Condition**
```javascript
// Before (race condition)
let cache = null;

async function getData() {
  if (!cache) {
    cache = await fetchFromDatabase();  // Multiple concurrent calls
  }
  return cache;
}

// After (properly synchronized)
let cache = null;
let cachePromise = null;

async function getData() {
  if (!cache) {
    if (!cachePromise) {
      cachePromise = fetchFromDatabase();
    }
    cache = await cachePromise;
    cachePromise = null;
  }
  return cache;
}

// Or use a proper caching library
const { promiseMemoize } = require('promise-memoize');
const getData = promiseMemoize(async () => {
  return await fetchFromDatabase();
}, { maxAge: 60000 });
```

**3. Fix Memory Leak**
```javascript
// Before (memory leak)
class Component extends React.Component {
  componentDidMount() {
    window.addEventListener('resize', this.handleResize);
    this.interval = setInterval(this.fetchData, 5000);
  }

  // componentWillUnmount missing - listeners never removed
}

// After (properly cleaned up)
class Component extends React.Component {
  componentDidMount() {
    window.addEventListener('resize', this.handleResize);
    this.interval = setInterval(this.fetchData, 5000);
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.handleResize);
    clearInterval(this.interval);
  }
}
```

**4. Add Missing Validation**
```javascript
// Before (no validation)
app.post('/api/users', async (req, res) => {
  const user = await db.users.create(req.body);
  res.json(user);
});

// After (proper validation)
const { body, validationResult } = require('express-validator');

app.post('/api/users',
  // Validation middleware
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }).matches(/[A-Z]/).matches(/[0-9]/),
  body('age').optional().isInt({ min: 0, max: 150 }),

  async (req, res) => {
    // Check validation results
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    try {
      const user = await db.users.create({
        email: req.body.email,
        password: await hashPassword(req.body.password),
        age: req.body.age
      });

      res.json(user);
    } catch (error) {
      logger.error('User creation failed', error);
      res.status(500).json({ error: 'Failed to create user' });
    }
  }
);
```

**5. Fix N+1 Query Problem**
```javascript
// Before (N+1 queries)
async function getUsersWithOrders() {
  const users = await db.users.findAll();

  for (const user of users) {
    user.orders = await db.orders.findByUserId(user.id);  // N queries
  }

  return users;
}

// After (single query with join)
async function getUsersWithOrders() {
  const users = await db.users.findAll({
    include: [
      { model: db.orders, as: 'orders' }
    ]
  });

  return users;
}

// Or with eager loading
async function getUsersWithOrders() {
  const users = await db.users.findAll();
  const userIds = users.map(u => u.id);
  const orders = await db.orders.findAll({
    where: { userId: userIds }
  });

  // Group orders by userId
  const ordersByUser = orders.reduce((acc, order) => {
    if (!acc[order.userId]) acc[order.userId] = [];
    acc[order.userId].push(order);
    return acc;
  }, {});

  // Attach to users
  users.forEach(user => {
    user.orders = ordersByUser[user.id] || [];
  });

  return users;
}
```

**Configuration Fix Patterns**:

**1. Fix Missing Environment Variable**
```bash
# Before (hardcoded)
DATABASE_URL=postgresql://localhost/myapp

# After (environment-specific)
# .env.production
DATABASE_URL=postgresql://prod-db.example.com:5432/myapp_prod?sslmode=require

# Application code should validate required vars
const requiredEnvVars = ['DATABASE_URL', 'API_KEY', 'SECRET_KEY'];
for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    throw new Error(`Required environment variable ${envVar} is not set`);
  }
}
```

**2. Fix Resource Limits**
```yaml
# Before (no limits - causes OOM)
apiVersion: apps/v1
kind: Deployment
spec:
  containers:
    - name: app
      image: myapp:latest

# After (proper resource limits)
apiVersion: apps/v1
kind: Deployment
spec:
  containers:
    - name: app
      image: myapp:latest
      resources:
        requests:
          memory: "256Mi"
          cpu: "250m"
        limits:
          memory: "512Mi"
          cpu: "500m"
```

**Infrastructure Fix Patterns**:

**1. Fix Nginx Upload Size Limit**
```nginx
# Before (default 1MB limit)
server {
  listen 80;
  server_name example.com;

  location / {
    proxy_pass http://localhost:3000;
  }
}

# After (increased limit)
server {
  listen 80;
  server_name example.com;

  # Increase max body size
  client_max_body_size 50M;

  location / {
    proxy_pass http://localhost:3000;

    # Increase timeouts for large uploads
    proxy_read_timeout 300s;
    proxy_connect_timeout 75s;
  }
}
```

**2. Add Missing Database Index**
```sql
-- Before (slow query)
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';
-- Seq Scan on users  (cost=0.00..1234.56 rows=1 width=123) (actual time=45.123..45.124 rows=1 loops=1)

-- After (add index)
CREATE INDEX idx_users_email ON users(email);

EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';
-- Index Scan using idx_users_email on users  (cost=0.29..8.30 rows=1 width=123) (actual time=0.012..0.013 rows=1 loops=1)
```

### 3. Implement the Fix

Execute the implementation with safety measures:

#### Implementation Checklist

**Pre-Implementation**:
- [ ] Create feature branch from main
- [ ] Review related code for similar issues
- [ ] Identify all affected areas
- [ ] Plan rollback strategy
- [ ] Prepare monitoring queries

**During Implementation**:
```bash
# Create feature branch
git checkout -b fix/issue-description

# Make changes incrementally
# Test after each change

# Commit with clear messages
git add file1.js
git commit -m "fix: add error handling to payment processing"

git add file2.js
git commit -m "fix: add validation for order status"
```

**Code Changes with Safety**:
```javascript
// Add defensive checks
function processOrder(order) {
  // Validate inputs
  if (!order) {
    throw new Error('Order is required');
  }

  if (!order.id) {
    throw new Error('Order must have an id');
  }

  // Log for debugging
  logger.debug('Processing order', { orderId: order.id });

  try {
    // Main logic
    const result = doProcessing(order);

    // Validate output
    if (!result || !result.success) {
      throw new Error('Processing did not return success');
    }

    return result;
  } catch (error) {
    // Enhanced error context
    logger.error('Order processing failed', {
      orderId: order.id,
      error: error.message,
      stack: error.stack
    });

    // Re-throw with context
    throw new ProcessingError(`Failed to process order ${order.id}`, error);
  }
}
```

**Configuration Changes with Rollback**:
```bash
# Backup current config
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.$(date +%Y%m%d)

# Make changes
sudo vim /etc/nginx/nginx.conf

# Test configuration before applying
sudo nginx -t

# If test passes, reload
sudo nginx -s reload

# If issues occur, rollback
# sudo cp /etc/nginx/nginx.conf.backup.YYYYMMDD /etc/nginx/nginx.conf
# sudo nginx -s reload
```

**Database Changes with Safety**:
```sql
-- Start transaction
BEGIN;

-- Create index concurrently (doesn't lock table)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- Verify index was created
\d users

-- Test query with new index
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- If all looks good, commit
COMMIT;

-- If issues, rollback
-- ROLLBACK;
-- DROP INDEX idx_users_email;
```

### 4. Add Safeguards

Implement safeguards to prevent recurrence:

**Safeguard Types**:

**1. Input Validation**
```javascript
// Add schema validation
const Joi = require('joi');

const orderSchema = Joi.object({
  id: Joi.string().uuid().required(),
  userId: Joi.string().uuid().required(),
  amount: Joi.number().positive().required(),
  currency: Joi.string().length(3).required(),
  status: Joi.string().valid('pending', 'processing', 'completed', 'failed').required()
});

function validateOrder(order) {
  const { error, value } = orderSchema.validate(order);
  if (error) {
    throw new ValidationError(`Invalid order: ${error.message}`);
  }
  return value;
}
```

**2. Rate Limiting**
```javascript
const rateLimit = require('express-rate-limit');

// Prevent abuse
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP'
});

app.use('/api/', limiter);
```

**3. Circuit Breaker**
```javascript
const CircuitBreaker = require('opossum');

// Protect against cascading failures
const breaker = new CircuitBreaker(externalApiCall, {
  timeout: 3000, // 3 seconds
  errorThresholdPercentage: 50,
  resetTimeout: 30000 // 30 seconds
});

breaker.fallback(() => {
  return { cached: true, data: getCachedData() };
});

async function callExternalApi(params) {
  return await breaker.fire(params);
}
```

**4. Retry Logic**
```javascript
const retry = require('async-retry');

async function robustApiCall(params) {
  return await retry(
    async (bail) => {
      try {
        return await apiCall(params);
      } catch (error) {
        // Don't retry client errors
        if (error.statusCode >= 400 && error.statusCode < 500) {
          bail(error);
          return;
        }
        // Retry server errors
        throw error;
      }
    },
    {
      retries: 3,
      minTimeout: 1000,
      maxTimeout: 5000,
      factor: 2
    }
  );
}
```

**5. Graceful Degradation**
```javascript
async function getRecommendations(userId) {
  try {
    // Try ML-based recommendations
    return await mlRecommendationService.getRecommendations(userId);
  } catch (error) {
    logger.warn('ML recommendations failed, falling back to rule-based', error);

    try {
      // Fallback to rule-based
      return await ruleBasedRecommendations(userId);
    } catch (error2) {
      logger.error('All recommendation methods failed', error2);

      // Final fallback to popular items
      return await getPopularItems();
    }
  }
}
```

### 5. Verification

Thoroughly verify the fix works:

**Verification Levels**:

**Level 1: Unit Tests**
```javascript
describe('processPayment', () => {
  it('should handle missing order gracefully', async () => {
    await expect(processPayment('nonexistent-id'))
      .rejects
      .toThrow('Order nonexistent-id not found');
  });

  it('should reject orders not in pending status', async () => {
    const completedOrder = await createTestOrder({ status: 'completed' });

    await expect(processPayment(completedOrder.id))
      .rejects
      .toThrow('is not in pending status');
  });

  it('should process valid pending orders', async () => {
    const order = await createTestOrder({ status: 'pending', amount: 100 });

    const result = await processPayment(order.id);

    expect(result.success).toBe(true);
    expect(result.transactionId).toBeDefined();
  });
});
```

**Level 2: Integration Tests**
```javascript
describe('Payment Integration', () => {
  it('should handle full payment flow', async () => {
    // Create order
    const order = await createOrder({ amount: 100 });
    expect(order.status).toBe('pending');

    // Process payment
    const result = await processPayment(order.id);
    expect(result.success).toBe(true);

    // Verify order updated
    const updatedOrder = await getOrder(order.id);
    expect(updatedOrder.status).toBe('completed');

    // Verify transaction recorded
    const transaction = await getTransaction(result.transactionId);
    expect(transaction.orderId).toBe(order.id);
  });
});
```

**Level 3: Manual Testing**
```bash
# Test the fix manually
npm start

# In another terminal, reproduce the original issue
curl -X POST http://localhost:3000/api/orders/12345/payment

# Verify fix
# - Check response is successful
# - Check logs for proper error handling
# - Check database state is consistent
```

**Level 4: Load Testing**
```javascript
// Use k6 for load testing
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 }, // Ramp up to 100 users
    { duration: '5m', target: 100 }, // Stay at 100 users
    { duration: '2m', target: 0 },   // Ramp down
  ],
};

export default function () {
  let response = http.post('http://localhost:3000/api/orders/payment', {
    orderId: '12345'
  });

  check(response, {
    'status is 200': (r) => r.status === 200,
    'no errors': (r) => !r.json('error')
  });

  sleep(1);
}
```

**Level 5: Production Smoke Test**
```bash
# After deployment, test in production
# Use feature flag if possible

# Test with low traffic
curl https://api.production.com/health
curl https://api.production.com/api/test-endpoint

# Monitor metrics
# - Error rate
# - Response time
# - Resource usage

# If issues detected, rollback immediately
```

### 6. Prevention Measures

Add measures to prevent similar issues:

**Prevention Strategies**:

**1. Add Regression Tests**
```javascript
// This test would have caught the bug
describe('Regression: Order Processing Bug #1234', () => {
  it('should not crash when order is missing', async () => {
    // This used to cause a crash
    await expect(processPayment('missing-order'))
      .rejects
      .toThrow('Order missing-order not found');
      // No crash, proper error thrown
  });
});
```

**2. Add Monitoring**
```javascript
// Add custom metrics
const { Counter, Histogram } = require('prom-client');

const paymentErrors = new Counter({
  name: 'payment_processing_errors_total',
  help: 'Total payment processing errors',
  labelNames: ['error_type']
});

const paymentDuration = new Histogram({
  name: 'payment_processing_duration_seconds',
  help: 'Payment processing duration'
});

async function processPayment(orderId) {
  const end = paymentDuration.startTimer();

  try {
    const result = await _processPayment(orderId);
    end({ status: 'success' });
    return result;
  } catch (error) {
    paymentErrors.inc({ error_type: error.constructor.name });
    end({ status: 'error' });
    throw error;
  }
}
```

**3. Add Alerting**
```yaml
# Prometheus alert rules
groups:
  - name: payment_processing
    rules:
      - alert: HighPaymentErrorRate
        expr: rate(payment_processing_errors_total[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High payment error rate detected"
          description: "Payment error rate is {{ $value }} errors/sec"
```

**4. Improve Logging**
```javascript
// Add structured logging
logger.info('Processing payment', {
  orderId: order.id,
  amount: order.amount,
  userId: order.userId,
  timestamp: new Date().toISOString()
});

// Log key decision points
logger.debug('Order validation passed', { orderId });
logger.debug('Calling payment gateway', { orderId, amount });
logger.debug('Payment gateway responded', { orderId, success: result.success });
```

**5. Update Documentation**
```markdown
# Common Issues and Solutions

## Issue: Payment Processing Fails Silently

**Symptoms**: Orders stuck in pending status

**Root Cause**: Missing error handling in payment processor

**Solution**: Added comprehensive error handling and logging

**Prevention**:
- All payment operations now have try-catch blocks
- Errors are logged with full context
- Alerts trigger on error rate > 10%

**Related Code**: src/services/payment-processor.js
**Tests**: tests/integration/payment-processing.test.js
**Monitoring**: Grafana dashboard "Payment Processing"
```

## Output Format

```markdown
# Fix Report: [Issue Summary]

## Summary
[Brief description of the fix implemented]

## Root Cause Addressed
[Detailed explanation of what root cause this fix addresses]

## Changes Made

### Code Changes

#### File: [path/to/file1]
**Purpose**: [Why this file was changed]

\`\`\`[language]
// Before
[original code]

// After
[fixed code]

// Why this works
[explanation]
\`\`\`

#### File: [path/to/file2]
**Purpose**: [Why this file was changed]

\`\`\`[language]
[changes with before/after]
\`\`\`

### Configuration Changes

#### File: [config/file]
\`\`\`
[configuration changes]
\`\`\`
**Impact**: [What this configuration change affects]

### Infrastructure Changes

#### Component: [infrastructure component]
\`\`\`
[infrastructure changes]
\`\`\`
**Impact**: [What this infrastructure change affects]

## Safeguards Added

### Input Validation
[Validation added to prevent bad inputs]

### Error Handling
[Error handling added for failure scenarios]

### Rate Limiting
[Rate limiting or throttling added]

### Monitoring
[Monitoring/metrics added]

### Alerting
[Alerts configured]

## Verification Results

### Unit Tests
\`\`\`
[test results]
\`\`\`
**Status**: ✅ All tests passing

### Integration Tests
\`\`\`
[test results]
\`\`\`
**Status**: ✅ All tests passing

### Manual Testing
[Description of manual testing performed]
**Status**: ✅ Issue no longer reproduces

### Load Testing
[Results of load testing]
**Status**: ✅ Performs well under load

## Prevention Measures

### Tests Added
- [Test 1]: Prevents regression
- [Test 2]: Covers edge case

### Monitoring Added
- [Metric 1]: Tracks error rate
- [Metric 2]: Tracks performance

### Alerts Configured
- [Alert 1]: Fires when error rate exceeds threshold
- [Alert 2]: Fires when performance degrades

### Documentation Updated
- [Doc 1]: Troubleshooting guide
- [Doc 2]: Runbook for oncall

## Deployment Plan

### Pre-Deployment
1. [Step 1]
2. [Step 2]

### Deployment
1. [Step 1]
2. [Step 2]

### Post-Deployment
1. [Step 1 - monitoring]
2. [Step 2 - verification]

### Rollback Plan
\`\`\`bash
[commands to rollback if needed]
\`\`\`

## Verification Steps

### How to Verify the Fix
1. [Verification step 1]
2. [Verification step 2]

### Expected Behavior After Fix
[Description of expected behavior]

### Monitoring Queries
\`\`\`
[queries to monitor fix effectiveness]
\`\`\`

## Related Issues

### Similar Issues Fixed
- [Related issue 1]
- [Related issue 2]

### Potential Similar Issues
- [Potential issue 1 to check]
- [Potential issue 2 to check]

## Lessons Learned
[Key insights from implementing this fix]

## Files Modified
- [file1]
- [file2]
- [file3]

## Commits
\`\`\`
[git log output showing fix commits]
\`\`\`
```

## Error Handling

**Fix Fails Verification**:
If fix doesn't resolve the issue:
1. Re-examine root cause analysis
2. Check if multiple issues present
3. Verify fix was implemented correctly
4. Add more diagnostic logging

**Fix Causes New Issues**:
If fix introduces side effects:
1. Rollback immediately
2. Analyze side effect cause
3. Redesign fix to avoid side effect
4. Add tests for side effect scenario

**Cannot Deploy Fix**:
If deployment blocked:
1. Implement workaround if possible
2. Document deployment blockers
3. Create deployment plan to address blockers
4. Consider feature flag for gradual rollout

## Integration with Other Operations

- **Before**: Use `/debug diagnose` to identify root cause
- **Before**: Use `/debug reproduce` to create test case
- **After**: Use `/debug performance` if fix affects performance
- **After**: Use `/debug memory` if fix affects memory usage

## Agent Utilization

This operation leverages the **10x-fullstack-engineer** agent for:
- Designing robust fixes that address root causes
- Implementing comprehensive safeguards
- Creating thorough verification strategies
- Considering performance and security implications
- Planning prevention measures
