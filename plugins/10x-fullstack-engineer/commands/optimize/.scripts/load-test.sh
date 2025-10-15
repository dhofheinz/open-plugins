#!/bin/bash
# Purpose: Run k6 load testing with various scenarios
# Version: 1.0.0
# Usage: ./load-test.sh <url> [scenario] [duration] [vus]
# Returns: 0=success, 1=test failed, 2=invalid arguments
# Dependencies: k6

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Arguments
URL="${1:-}"
SCENARIO="${2:-smoke}"
DURATION="${3:-60s}"
VUS="${4:-50}"

# Validate arguments
if [ -z "$URL" ]; then
    echo -e "${RED}Error: URL is required${NC}"
    echo "Usage: $0 <url> [scenario] [duration] [vus]"
    echo ""
    echo "Scenarios:"
    echo "  smoke      - Quick test with few users (default)"
    echo "  load       - Normal load test"
    echo "  stress     - Gradually increasing load"
    echo "  spike      - Sudden traffic spike"
    echo "  soak       - Long-duration test"
    echo ""
    echo "Example: $0 https://api.example.com/health load 300s 100"
    exit 2
fi

# Check if k6 is installed
if ! command -v k6 &> /dev/null; then
    echo -e "${YELLOW}k6 not found. Installing...${NC}"
    # Installation instructions
    echo "Please install k6:"
    echo "  macOS: brew install k6"
    echo "  Linux: sudo apt-get install k6 or snap install k6"
    echo "  Windows: choco install k6"
    exit 2
fi

# Create output directory
OUTPUT_DIR="./load-test-results"
mkdir -p "$OUTPUT_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo -e "${GREEN}Running k6 load test${NC}"
echo "URL: $URL"
echo "Scenario: $SCENARIO"
echo "Duration: $DURATION"
echo "VUs: $VUS"

# Generate k6 test script based on scenario
TEST_SCRIPT="${OUTPUT_DIR}/test-${SCENARIO}-${TIMESTAMP}.js"

case $SCENARIO in
    smoke)
        cat > "$TEST_SCRIPT" <<'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
    vus: 1,
    duration: '30s',
    thresholds: {
        http_req_duration: ['p(95)<1000'],
        http_req_failed: ['rate<0.01'],
    },
};

export default function () {
    const res = http.get(__ENV.TARGET_URL);

    const success = check(res, {
        'status is 200': (r) => r.status === 200,
        'response time OK': (r) => r.timings.duration < 1000,
    });

    errorRate.add(!success);
    sleep(1);
}
EOF
        ;;

    load)
        cat > "$TEST_SCRIPT" <<'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
    stages: [
        { duration: '30s', target: __ENV.VUS / 2 },
        { duration: __ENV.DURATION, target: __ENV.VUS },
        { duration: '30s', target: 0 },
    ],
    thresholds: {
        http_req_duration: ['p(95)<500', 'p(99)<1000'],
        http_req_failed: ['rate<0.01'],
        errors: ['rate<0.1'],
    },
};

export default function () {
    const res = http.get(__ENV.TARGET_URL);

    const success = check(res, {
        'status is 200': (r) => r.status === 200,
        'response time < 500ms': (r) => r.timings.duration < 500,
    });

    errorRate.add(!success);
    sleep(1);
}
EOF
        ;;

    stress)
        cat > "$TEST_SCRIPT" <<'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
    stages: [
        { duration: '1m', target: __ENV.VUS / 4 },
        { duration: '2m', target: __ENV.VUS / 2 },
        { duration: '2m', target: __ENV.VUS },
        { duration: '2m', target: __ENV.VUS * 1.5 },
        { duration: '2m', target: __ENV.VUS * 2 },
        { duration: '1m', target: 0 },
    ],
    thresholds: {
        http_req_duration: ['p(95)<1000'],
        http_req_failed: ['rate<0.05'],
    },
};

export default function () {
    const res = http.get(__ENV.TARGET_URL);

    const success = check(res, {
        'status is 200': (r) => r.status === 200,
    });

    errorRate.add(!success);
    sleep(1);
}
EOF
        ;;

    spike)
        cat > "$TEST_SCRIPT" <<'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
    stages: [
        { duration: '1m', target: __ENV.VUS / 2 },
        { duration: '30s', target: __ENV.VUS * 5 },
        { duration: '1m', target: __ENV.VUS / 2 },
        { duration: '30s', target: 0 },
    ],
    thresholds: {
        http_req_duration: ['p(95)<2000'],
        http_req_failed: ['rate<0.1'],
    },
};

export default function () {
    const res = http.get(__ENV.TARGET_URL);

    const success = check(res, {
        'status is 200': (r) => r.status === 200,
    });

    errorRate.add(!success);
    sleep(1);
}
EOF
        ;;

    soak)
        cat > "$TEST_SCRIPT" <<'EOF'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
    stages: [
        { duration: '2m', target: __ENV.VUS },
        { duration: '3h', target: __ENV.VUS },
        { duration: '2m', target: 0 },
    ],
    thresholds: {
        http_req_duration: ['p(95)<500'],
        http_req_failed: ['rate<0.01'],
    },
};

export default function () {
    const res = http.get(__ENV.TARGET_URL);

    const success = check(res, {
        'status is 200': (r) => r.status === 200,
    });

    errorRate.add(!success);
    sleep(1);
}
EOF
        ;;

    *)
        echo -e "${RED}Error: Unknown scenario: $SCENARIO${NC}"
        exit 2
        ;;
esac

# Run k6 test
echo -e "\n${YELLOW}Starting load test...${NC}"
k6 run \
    --out json="${OUTPUT_DIR}/results-${SCENARIO}-${TIMESTAMP}.json" \
    --summary-export="${OUTPUT_DIR}/summary-${SCENARIO}-${TIMESTAMP}.json" \
    --env TARGET_URL="$URL" \
    --env DURATION="$DURATION" \
    --env VUS="$VUS" \
    "$TEST_SCRIPT"

# Check if test passed
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✓ Load test passed${NC}"
    TEST_STATUS="passed"
else
    echo -e "\n${RED}✗ Load test failed (thresholds not met)${NC}"
    TEST_STATUS="failed"
fi

# Parse results
echo -e "\n${YELLOW}Parsing results...${NC}"
node -e "
const fs = require('fs');
const summary = JSON.parse(fs.readFileSync('${OUTPUT_DIR}/summary-${SCENARIO}-${TIMESTAMP}.json'));

console.log('\n=== Load Test Results ===');
console.log('Scenario:', '${SCENARIO}');
console.log('Status:', '${TEST_STATUS}'.toUpperCase());

const metrics = summary.metrics;

if (metrics.http_reqs) {
    console.log('\n=== Request Statistics ===');
    console.log('Total Requests:', metrics.http_reqs.count);
    console.log('Request Rate:', metrics.http_reqs.rate.toFixed(2), 'req/s');
}

if (metrics.http_req_duration) {
    console.log('\n=== Response Time ===');
    console.log('Average:', metrics.http_req_duration.avg.toFixed(2), 'ms');
    console.log('Min:', metrics.http_req_duration.min.toFixed(2), 'ms');
    console.log('Max:', metrics.http_req_duration.max.toFixed(2), 'ms');
    console.log('p50:', metrics.http_req_duration.p50.toFixed(2), 'ms');
    console.log('p95:', metrics.http_req_duration.p95.toFixed(2), 'ms');
    console.log('p99:', metrics.http_req_duration.p99.toFixed(2), 'ms');
}

if (metrics.http_req_failed) {
    console.log('\n=== Error Rate ===');
    console.log('Failed Requests:', (metrics.http_req_failed.rate * 100).toFixed(2), '%');
}

if (metrics.vus) {
    console.log('\n=== Virtual Users ===');
    console.log('Max VUs:', metrics.vus.max);
}

// Check thresholds
console.log('\n=== Threshold Results ===');
Object.entries(summary.root_group.checks || {}).forEach(([name, check]) => {
    const status = check.passes === check.fails ? '✓' : '✗';
    console.log(status, name);
});
"

echo -e "\n${GREEN}✓ Load test complete${NC}"
echo "Results saved to:"
echo "  - ${OUTPUT_DIR}/results-${SCENARIO}-${TIMESTAMP}.json"
echo "  - ${OUTPUT_DIR}/summary-${SCENARIO}-${TIMESTAMP}.json"
echo "  - ${OUTPUT_DIR}/test-${SCENARIO}-${TIMESTAMP}.js"

if [ "$TEST_STATUS" = "failed" ]; then
    exit 1
fi

exit 0
