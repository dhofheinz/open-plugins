#!/bin/bash
# Purpose: Automated Lighthouse performance profiling for frontend pages
# Version: 1.0.0
# Usage: ./profile-frontend.sh <url> [output-dir]
# Returns: 0=success, 1=lighthouse failed, 2=invalid arguments
# Dependencies: Node.js, npm, lighthouse

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Arguments
URL="${1:-}"
OUTPUT_DIR="${2:-./lighthouse-reports}"

# Validate arguments
if [ -z "$URL" ]; then
    echo -e "${RED}Error: URL is required${NC}"
    echo "Usage: $0 <url> [output-dir]"
    echo "Example: $0 https://example.com ./reports"
    exit 2
fi

# Check if lighthouse is installed
if ! command -v lighthouse &> /dev/null; then
    echo -e "${YELLOW}Lighthouse not found. Installing...${NC}"
    npm install -g lighthouse
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo -e "${GREEN}Running Lighthouse audit for: $URL${NC}"
echo "Output directory: $OUTPUT_DIR"

# Run Lighthouse with various strategies
echo -e "\n${YELLOW}1. Desktop audit (fast connection)${NC}"
lighthouse "$URL" \
    --output=json \
    --output=html \
    --output-path="${OUTPUT_DIR}/desktop-${TIMESTAMP}" \
    --preset=desktop \
    --throttling.rttMs=40 \
    --throttling.throughputKbps=10240 \
    --throttling.cpuSlowdownMultiplier=1 \
    --chrome-flags="--headless --no-sandbox"

echo -e "\n${YELLOW}2. Mobile audit (3G connection)${NC}"
lighthouse "$URL" \
    --output=json \
    --output=html \
    --output-path="${OUTPUT_DIR}/mobile-${TIMESTAMP}" \
    --preset=mobile \
    --throttling.rttMs=150 \
    --throttling.throughputKbps=1600 \
    --throttling.cpuSlowdownMultiplier=4 \
    --chrome-flags="--headless --no-sandbox"

# Extract key metrics
echo -e "\n${GREEN}Extracting key metrics...${NC}"
node -e "
const fs = require('fs');
const desktop = JSON.parse(fs.readFileSync('${OUTPUT_DIR}/desktop-${TIMESTAMP}.report.json'));
const mobile = JSON.parse(fs.readFileSync('${OUTPUT_DIR}/mobile-${TIMESTAMP}.report.json'));

console.log('\n=== Performance Scores ===');
console.log('Desktop Performance:', Math.round(desktop.categories.performance.score * 100));
console.log('Mobile Performance:', Math.round(mobile.categories.performance.score * 100));

console.log('\n=== Web Vitals (Desktop) ===');
const dMetrics = desktop.audits;
console.log('LCP:', Math.round(dMetrics['largest-contentful-paint'].numericValue), 'ms');
console.log('FID:', Math.round(dMetrics['max-potential-fid'].numericValue), 'ms');
console.log('CLS:', dMetrics['cumulative-layout-shift'].numericValue.toFixed(3));
console.log('TTFB:', Math.round(dMetrics['server-response-time'].numericValue), 'ms');
console.log('TBT:', Math.round(dMetrics['total-blocking-time'].numericValue), 'ms');

console.log('\n=== Web Vitals (Mobile) ===');
const mMetrics = mobile.audits;
console.log('LCP:', Math.round(mMetrics['largest-contentful-paint'].numericValue), 'ms');
console.log('FID:', Math.round(mMetrics['max-potential-fid'].numericValue), 'ms');
console.log('CLS:', mMetrics['cumulative-layout-shift'].numericValue.toFixed(3));
console.log('TTFB:', Math.round(mMetrics['server-response-time'].numericValue), 'ms');
console.log('TBT:', Math.round(mMetrics['total-blocking-time'].numericValue), 'ms');

// Save summary
const summary = {
    timestamp: '${TIMESTAMP}',
    url: '${URL}',
    desktop: {
        performance: Math.round(desktop.categories.performance.score * 100),
        lcp: Math.round(dMetrics['largest-contentful-paint'].numericValue),
        fid: Math.round(dMetrics['max-potential-fid'].numericValue),
        cls: dMetrics['cumulative-layout-shift'].numericValue,
    },
    mobile: {
        performance: Math.round(mobile.categories.performance.score * 100),
        lcp: Math.round(mMetrics['largest-contentful-paint'].numericValue),
        fid: Math.round(mMetrics['max-potential-fid'].numericValue),
        cls: mMetrics['cumulative-layout-shift'].numericValue,
    }
};

fs.writeFileSync('${OUTPUT_DIR}/summary-${TIMESTAMP}.json', JSON.stringify(summary, null, 2));
console.log('\nSummary saved to: ${OUTPUT_DIR}/summary-${TIMESTAMP}.json');
"

echo -e "\n${GREEN}✓ Lighthouse audit complete${NC}"
echo "Reports saved to: $OUTPUT_DIR"
echo "  - desktop-${TIMESTAMP}.report.html"
echo "  - mobile-${TIMESTAMP}.report.html"
echo "  - summary-${TIMESTAMP}.json"

exit 0
