# Reproduce Operation - Issue Reproduction Strategies

You are executing the **reproduce** operation to create reliable reproduction strategies and test cases for debugging issues.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'reproduce' operation name)

Expected format: `issue:"problem description" [environment:"prod|staging|dev"] [data:"test-data-location"] [steps:"reproduction-steps"] [reliability:"percentage"]`

## Workflow

### 1. Understand Reproduction Requirements

Gather information about the issue's behavior:

**Key Questions**:
- How often does the issue occur? (100%, 50%, 5%, etc.)
- Under what conditions? (specific data, timing, load, etc.)
- In which environments? (prod only, all environments)
- What is the expected vs actual behavior?
- Are there known workarounds?

**Reproduction Challenges to Identify**:
- **Timing-dependent** (race conditions, timeouts)
- **Data-dependent** (specific user data, edge cases)
- **Environment-dependent** (prod-only config, specific infrastructure)
- **Load-dependent** (only under high load or concurrency)
- **State-dependent** (requires specific sequence of actions)

### 2. Gather Reproduction Context

Collect all information needed to reproduce:

#### Environment Context

**Application State**:
```bash
# Get application version
git log -1 --oneline
npm list  # Node dependencies
pip freeze  # Python dependencies

# Get configuration
cat .env.production
echo $ENVIRONMENT_VARS

# Get deployed version in production
kubectl get deployment app-name -o jsonpath='{.spec.template.spec.containers[0].image}'
```

**Infrastructure State**:
```bash
# System resources
free -m
df -h
ulimit -a

# Network configuration
ip addr show
cat /etc/resolv.conf

# Service status
systemctl status application-service
docker ps
kubectl get pods
```

#### Data Context

**Database State**:
```sql
-- Get relevant data schema
\d+ table_name

-- Get sample data that triggers issue
SELECT * FROM users WHERE id = 'problematic-user-id';

-- Get data statistics
SELECT count(*), min(created_at), max(created_at) FROM table_name;

-- Export test data
COPY (SELECT * FROM users WHERE id IN ('user1', 'user2')) TO '/tmp/test_data.csv' CSV HEADER;
```

**Request/Response Data**:
```bash
# Capture failing request
# Use browser DevTools > Network > Copy as cURL

curl 'https://api.example.com/endpoint' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Content-Type: application/json' \
  --data-raw '{"key":"value"}' \
  -v  # Verbose output

# Capture webhook payload
# Check logs for incoming webhook data
grep "webhook_payload" logs/application.log | jq .
```

#### User Context

**User Session**:
```javascript
// Browser state
console.log('LocalStorage:', localStorage);
console.log('SessionStorage:', sessionStorage);
console.log('Cookies:', document.cookie);
console.log('User Agent:', navigator.userAgent);

// Authentication state
console.log('Auth Token:', authToken);
console.log('Token Payload:', jwt.decode(authToken));
console.log('Session ID:', sessionId);
```

**User Actions**:
```markdown
1. User logs in as user@example.com
2. Navigates to /dashboard
3. Clicks "Upload File" button
4. Selects file > 10MB
5. Clicks "Submit"
6. Error occurs: "Request Entity Too Large"
```

### 3. Create Local Reproduction

Develop a strategy to reproduce the issue locally:

#### Strategy 1: Direct Reproduction

**For Simple Issues**:
```javascript
// Create minimal test case
function reproduceBug() {
  // Setup
  const testData = {
    userId: 'test-user',
    file: createLargeFile(15 * 1024 * 1024)  // 15MB
  };

  // Execute problematic operation
  const result = await uploadFile(testData);

  // Verify issue occurs
  assert(result.status === 413, 'Expected 413 error');
}
```

#### Strategy 2: Environment Simulation

**For Environment-Specific Issues**:
```bash
# Replicate production configuration locally
cp .env.production .env.local
sed -i 's/prod-database/localhost:5432/g' .env.local

# Use production data dump
psql local_db < production_data_dump.sql

# Run with production-like settings
NODE_ENV=production npm start
```

#### Strategy 3: Data-Driven Reproduction

**For Data-Specific Issues**:
```javascript
// Load production data that triggers issue
const testData = require('./test-data/problematic-user-data.json');

// Seed database with specific data
await db.users.insert(testData.user);
await db.orders.insertMany(testData.orders);

// Execute operation
const result = await processOrder(testData.orders[0].id);
```

#### Strategy 4: Timing-Based Reproduction

**For Race Conditions**:
```javascript
// Add delays to expose race condition
async function reproduceRaceCondition() {
  // Start two operations simultaneously
  const [result1, result2] = await Promise.all([
    operation1(),
    operation2()
  ]);

  // Or use setTimeout to control timing
  setTimeout(() => operation1(), 0);
  setTimeout(() => operation2(), 1);  // 1ms delay
}

// Add intentional delays to expose timing issues
async function operation() {
  await fetchData();
  await sleep(100);  // Artificial delay
  await processData();  // May fail if timing-dependent
}
```

#### Strategy 5: Load-Based Reproduction

**For Performance/Concurrency Issues**:
```javascript
// Simulate concurrent requests
async function reproduceUnderLoad() {
  const concurrentRequests = 100;
  const requests = Array(concurrentRequests)
    .fill(null)
    .map(() => makeRequest());

  const results = await Promise.allSettled(requests);
  const failures = results.filter(r => r.status === 'rejected');

  console.log(`Failure rate: ${failures.length}/${concurrentRequests}`);
}
```

```bash
# Use load testing tools
ab -n 1000 -c 100 http://localhost:3000/api/endpoint

# Use k6 for more complex scenarios
k6 run load-test.js

# Monitor during load test
watch -n 1 'ps aux | grep node'
```

### 4. Verify Reproduction Reliability

Test that reproduction is reliable:

**Reliability Testing**:
```javascript
async function testReproductionReliability() {
  const iterations = 50;
  let failures = 0;

  for (let i = 0; i < iterations; i++) {
    try {
      await reproduceIssue();
      failures++;  // Issue reproduced
    } catch (error) {
      // Issue did not reproduce
    }
  }

  const reliability = (failures / iterations) * 100;
  console.log(`Reproduction reliability: ${reliability}%`);

  if (reliability < 80) {
    console.warn('Reproduction is not reliable enough. Need to refine.');
  }
}
```

**Improve Reliability**:
```javascript
// If reliability is low, add more constraints
async function improvedReproduction() {
  // 1. Reset state between attempts
  await resetDatabase();
  await clearCache();

  // 2. Add specific data constraints
  const testUser = await createUserWithSpecificProfile({
    accountAge: 30,  // days
    orderCount: 5,
    subscriptionTier: 'premium'
  });

  // 3. Control timing precisely
  await sleep(100);  // Ensure service is ready

  // 4. Set specific environment conditions
  process.env.FEATURE_FLAG_X = 'true';

  // Execute
  await reproduceIssue();
}
```

### 5. Create Automated Test Case

Convert reproduction into automated test:

**Unit Test Example**:
```javascript
describe('File Upload Bug', () => {
  beforeEach(async () => {
    // Setup test environment
    await resetTestDatabase();
    await clearUploadDirectory();
  });

  it('should handle files larger than 10MB', async () => {
    // Arrange
    const largeFile = createTestFile(15 * 1024 * 1024);
    const user = await createTestUser();

    // Act
    const response = await uploadFile(user.id, largeFile);

    // Assert
    expect(response.status).toBe(413);
    expect(response.body.error).toContain('File too large');
  });

  it('should succeed with files under 10MB', async () => {
    // Verify issue is specifically about size
    const smallFile = createTestFile(5 * 1024 * 1024);
    const user = await createTestUser();

    const response = await uploadFile(user.id, smallFile);

    expect(response.status).toBe(200);
  });
});
```

**Integration Test Example**:
```javascript
describe('Order Processing Race Condition', () => {
  it('should handle concurrent order updates safely', async () => {
    // Setup
    const order = await createTestOrder({ status: 'pending' });

    // Simulate race condition
    const updatePromises = [
      updateOrderStatus(order.id, 'processing'),
      updateOrderStatus(order.id, 'confirmed')
    ];

    // Both should complete without error
    await Promise.all(updatePromises);

    // Verify final state is consistent
    const finalOrder = await getOrder(order.id);
    expect(['processing', 'confirmed']).toContain(finalOrder.status);

    // Verify no data corruption
    const auditLogs = await getOrderAuditLogs(order.id);
    expect(auditLogs).toHaveLength(2);
  });
});
```

**E2E Test Example**:
```javascript
describe('Dashboard Load Performance', () => {
  it('should load dashboard under 2 seconds', async () => {
    // Setup user with large dataset
    const user = await createUserWithLargeDataset({
      orders: 1000,
      documents: 500
    });

    // Login
    await page.goto('/login');
    await page.fill('#email', user.email);
    await page.fill('#password', 'testpass123');
    await page.click('#login-button');

    // Navigate to dashboard and measure time
    const startTime = Date.now();
    await page.goto('/dashboard');
    await page.waitForSelector('.dashboard-loaded');
    const loadTime = Date.now() - startTime;

    // Assert performance
    expect(loadTime).toBeLessThan(2000);
  });
});
```

### 6. Document Reproduction Steps

Create comprehensive reproduction documentation:

**Reproduction Guide Template**:
```markdown
# Reproduction Guide: [Issue Name]

## Prerequisites
- Node.js v18.x
- PostgreSQL 14+
- Docker (optional)
- Test account credentials

## Environment Setup

### 1. Clone and Install
\`\`\`bash
git clone https://github.com/org/repo.git
cd repo
npm install
\`\`\`

### 2. Database Setup
\`\`\`bash
# Create test database
createdb test_app

# Load test data
psql test_app < test-data/problematic_data.sql
\`\`\`

### 3. Configuration
\`\`\`bash
# Copy test environment file
cp .env.test .env

# Update with test database URL
echo "DATABASE_URL=postgresql://localhost/test_app" >> .env
\`\`\`

## Reproduction Steps

### Manual Reproduction
1. Start the application:
   \`\`\`bash
   npm start
   \`\`\`

2. Login with test user:
   - Email: test@example.com
   - Password: testpass123

3. Navigate to Dashboard: http://localhost:3000/dashboard

4. Click "Upload File" button

5. Select file larger than 10MB from test-data/

6. Click "Submit"

7. **Expected**: File uploads successfully
   **Actual**: 413 Request Entity Too Large error

### Automated Reproduction
\`\`\`bash
# Run reproduction test
npm test -- tests/reproduction/file-upload-bug.test.js

# Expected output:
# ✓ reproduces 413 error with files > 10MB
# ✓ succeeds with files < 10MB
\`\`\`

## Reproduction Reliability
- **Success Rate**: 100% (fails every time)
- **Environment**: All environments
- **Conditions**: File size > 10MB

## Key Observations
- Issue occurs consistently with files > 10MB
- Works fine with files ≤ 10MB
- Error comes from Nginx, not application
- Content-Length header shows correct size

## Debugging Hints
- Check Nginx configuration: `/etc/nginx/nginx.conf`
- Look for `client_max_body_size` directive
- Application code may be fine, infrastructure issue

## Related Files
- test-data/large-file.bin (15MB test file)
- test-data/problematic_data.sql (test database dump)
- tests/reproduction/file-upload-bug.test.js (automated test)
```

### 7. Validate Different Scenarios

Test edge cases and variations:

**Scenario Matrix**:
```javascript
const testScenarios = [
  // Vary file sizes
  { fileSize: '1MB', expected: 'success' },
  { fileSize: '10MB', expected: 'success' },
  { fileSize: '11MB', expected: 'failure' },
  { fileSize: '50MB', expected: 'failure' },

  // Vary file types
  { fileType: 'image/jpeg', expected: 'success' },
  { fileType: 'application/pdf', expected: 'success' },
  { fileType: 'video/mp4', expected: 'failure' },

  // Vary user types
  { userType: 'free', expected: 'failure' },
  { userType: 'premium', expected: 'success' },

  // Vary environments
  { environment: 'local', expected: 'success' },
  { environment: 'staging', expected: 'failure' },
  { environment: 'production', expected: 'failure' }
];

for (const scenario of testScenarios) {
  const result = await testScenario(scenario);
  console.log(`Scenario ${JSON.stringify(scenario)}: ${result}`);
}
```

## Output Format

```markdown
# Reproduction Report: [Issue Name]

## Summary
[Brief description of reproduction strategy and success]

## Reproduction Reliability
- **Success Rate**: [percentage]%
- **Environment**: [local|staging|production|all]
- **Conditions**: [specific conditions needed]
- **Timing**: [immediate|delayed|intermittent]

## Prerequisites

### Environment Requirements
- [Software requirement 1]
- [Software requirement 2]
- [Configuration requirement 1]

### Data Requirements
- [Test data 1]
- [Test data 2]
- [Database state]

### Access Requirements
- [Credentials needed]
- [Permissions needed]
- [Resources needed]

## Reproduction Steps

### Quick Reproduction
\`\`\`bash
# Fastest way to reproduce
[commands to quickly reproduce the issue]
\`\`\`

### Detailed Reproduction

#### Step 1: [Setup]
\`\`\`bash
[detailed commands]
\`\`\`
[Expected result]

#### Step 2: [Preparation]
\`\`\`bash
[detailed commands]
\`\`\`
[Expected result]

#### Step 3: [Trigger Issue]
\`\`\`bash
[detailed commands]
\`\`\`
**Expected**: [expected behavior]
**Actual**: [actual behavior with issue]

## Automated Test Case

### Test Code
\`\`\`[language]
[Complete automated test that reproduces the issue]
\`\`\`

### Running the Test
\`\`\`bash
[command to run the test]
\`\`\`

### Expected Output
\`\`\`
[what the test output should show]
\`\`\`

## Scenario Variations

### Variation 1: [Description]
- **Conditions**: [conditions]
- **Result**: [occurs|does not occur]
- **Notes**: [observations]

### Variation 2: [Description]
- **Conditions**: [conditions]
- **Result**: [occurs|does not occur]
- **Notes**: [observations]

## Key Observations

### What Triggers the Issue
- [Trigger 1]
- [Trigger 2]
- [Trigger 3]

### What Prevents the Issue
- [Prevention 1]
- [Prevention 2]

### Minimal Reproduction
[Simplest possible way to reproduce]

## Test Data Files

### File 1: [filename]
**Location**: [path]
**Purpose**: [what this file is for]
**Contents**: [brief description]

### File 2: [filename]
**Location**: [path]
**Purpose**: [what this file is for]
**Contents**: [brief description]

## Troubleshooting Reproduction

### If Reproduction Fails
1. [Check 1]
2. [Check 2]
3. [Check 3]

### Common Issues
- **Issue**: [problem with reproduction]
  **Solution**: [how to fix]

- **Issue**: [problem with reproduction]
  **Solution**: [how to fix]

## Next Steps

1. **Diagnosis**: Use `/debug diagnose` with reproduction steps
2. **Fix**: Use `/debug fix` once root cause is identified
3. **Verification**: Re-run reproduction after fix to verify resolution

## Appendices

### A. Test Data
[Links to or contents of test data files]

### B. Environment Configuration
[Complete environment configuration needed]

### C. Video/Screenshots
[If applicable, links to recordings showing the issue]
```

## Error Handling

**Cannot Reproduce Locally**:
If issue cannot be reproduced in local environment:
1. Document what was tried
2. List environment differences
3. Suggest production debugging approach
4. Create monitoring to capture more data

**Unreliable Reproduction**:
If reproduction is intermittent:
1. Identify factors affecting reliability
2. Add more constraints to increase reliability
3. Document reliability percentage
4. Suggest statistical testing approach

**Missing Prerequisites**:
If prerequisites are unavailable:
1. List what's missing
2. Suggest alternatives
3. Propose workaround strategies
4. Document assumptions

## Integration with Other Operations

- **Before**: Use `/debug diagnose` to understand the issue first
- **After**: Use `/debug fix` to implement the fix
- **Related**: Use `/debug analyze-logs` to gather more reproduction context

## Agent Utilization

This operation leverages the **10x-fullstack-engineer** agent for:
- Creating reliable reproduction strategies
- Designing comprehensive test cases
- Identifying edge cases and variations
- Documenting reproduction steps clearly
