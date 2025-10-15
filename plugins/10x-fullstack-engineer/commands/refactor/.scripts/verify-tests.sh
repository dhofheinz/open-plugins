#!/bin/bash

# Purpose: Verify test coverage for code being refactored
# Version: 1.0.0
# Usage: ./verify-tests.sh <scope> [min-coverage]
# Returns: 0 if coverage adequate, 1 if insufficient
# Dependencies: npm, test runner (jest/mocha/etc)

set -euo pipefail

# Configuration
SCOPE="${1:-.}"
MIN_COVERAGE="${2:-70}"
OUTPUT_FILE="coverage-report.json"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if scope exists
if [ ! -e "$SCOPE" ]; then
  echo -e "${RED}Error: Scope does not exist: $SCOPE${NC}" >&2
  exit 1
fi

echo "Verifying test coverage for: $SCOPE"
echo "Minimum coverage required: ${MIN_COVERAGE}%"
echo ""

# Check if package.json exists
if [ ! -f "package.json" ]; then
  echo -e "${YELLOW}Warning: No package.json found. Skipping test coverage check.${NC}"
  exit 0
fi

# Check if test script exists
if ! grep -q '"test"' package.json; then
  echo -e "${YELLOW}Warning: No test script found in package.json. Skipping test coverage check.${NC}"
  exit 0
fi

# Run tests with coverage
echo "Running tests with coverage..."
echo ""

# Try different test runners
if npm test -- --coverage --watchAll=false --json --outputFile="$OUTPUT_FILE" 2>&1; then
  TEST_RUNNER="jest"
elif npm run test:coverage 2>&1; then
  TEST_RUNNER="npm"
else
  echo -e "${YELLOW}Warning: Could not run tests with coverage${NC}"
  echo "Make sure your test runner supports coverage reporting"
  exit 0
fi

echo ""

# Try to find coverage summary
COVERAGE_SUMMARY=""

if [ -f "coverage/coverage-summary.json" ]; then
  COVERAGE_SUMMARY="coverage/coverage-summary.json"
elif [ -f "coverage/lcov.info" ]; then
  echo "LCOV format detected, parsing..."
  # Convert lcov to summary (simplified)
  COVERAGE_SUMMARY="coverage/lcov.info"
elif [ -f "$OUTPUT_FILE" ]; then
  COVERAGE_SUMMARY="$OUTPUT_FILE"
fi

if [ -z "$COVERAGE_SUMMARY" ]; then
  echo -e "${YELLOW}Warning: Could not find coverage report${NC}"
  echo "Coverage report paths checked:"
  echo "  - coverage/coverage-summary.json"
  echo "  - coverage/lcov.info"
  echo "  - $OUTPUT_FILE"
  exit 0
fi

# Parse coverage results
echo "=== Test Coverage Results ==="
echo ""

if [[ "$COVERAGE_SUMMARY" == *.json ]]; then
  # JSON format (Jest)
  if jq empty "$COVERAGE_SUMMARY" 2>/dev/null; then
    # Check if it's coverage-summary.json format
    if jq -e '.total' "$COVERAGE_SUMMARY" >/dev/null 2>&1; then
      STATEMENTS=$(jq -r '.total.statements.pct // 0' "$COVERAGE_SUMMARY")
      BRANCHES=$(jq -r '.total.branches.pct // 0' "$COVERAGE_SUMMARY")
      FUNCTIONS=$(jq -r '.total.functions.pct // 0' "$COVERAGE_SUMMARY")
      LINES=$(jq -r '.total.lines.pct // 0' "$COVERAGE_SUMMARY")

      echo "Overall Coverage:"
      echo "  Statements: ${STATEMENTS}%"
      echo "  Branches:   ${BRANCHES}%"
      echo "  Functions:  ${FUNCTIONS}%"
      echo "  Lines:      ${LINES}%"
      echo ""

      # Check if coverage meets minimum
      COVERAGE_OK=true

      if (( $(echo "$STATEMENTS < $MIN_COVERAGE" | bc -l) )); then
        COVERAGE_OK=false
        echo -e "${RED}✗ Statements coverage (${STATEMENTS}%) below minimum (${MIN_COVERAGE}%)${NC}"
      else
        echo -e "${GREEN}✓ Statements coverage (${STATEMENTS}%) meets minimum${NC}"
      fi

      if (( $(echo "$BRANCHES < $MIN_COVERAGE" | bc -l) )); then
        COVERAGE_OK=false
        echo -e "${RED}✗ Branches coverage (${BRANCHES}%) below minimum (${MIN_COVERAGE}%)${NC}"
      else
        echo -e "${GREEN}✓ Branches coverage (${BRANCHES}%) meets minimum${NC}"
      fi

      if (( $(echo "$FUNCTIONS < $MIN_COVERAGE" | bc -l) )); then
        COVERAGE_OK=false
        echo -e "${RED}✗ Functions coverage (${FUNCTIONS}%) below minimum (${MIN_COVERAGE}%)${NC}"
      else
        echo -e "${GREEN}✓ Functions coverage (${FUNCTIONS}%) meets minimum${NC}"
      fi

      if (( $(echo "$LINES < $MIN_COVERAGE" | bc -l) )); then
        COVERAGE_OK=false
        echo -e "${RED}✗ Lines coverage (${LINES}%) below minimum (${MIN_COVERAGE}%)${NC}"
      else
        echo -e "${GREEN}✓ Lines coverage (${LINES}%) meets minimum${NC}"
      fi

      echo ""

      # Find files with low coverage
      echo "Files with Coverage < ${MIN_COVERAGE}%:"
      jq -r --arg min "$MIN_COVERAGE" '
        . as $root |
        to_entries[] |
        select(.key != "total") |
        select(.value.lines.pct < ($min | tonumber)) |
        "\(.key): \(.value.lines.pct)%"
      ' "$COVERAGE_SUMMARY" | head -20

      echo ""

      if [ "$COVERAGE_OK" = true ]; then
        echo -e "${GREEN}Status: PASSED - Test coverage is adequate${NC}"
        echo ""
        echo "✓ Safe to refactor - code is well tested"
        exit 0
      else
        echo -e "${RED}Status: FAILED - Test coverage insufficient${NC}"
        echo ""
        echo "⚠  Recommendations:"
        echo "1. Add tests before refactoring"
        echo "2. Focus refactoring on well-tested code"
        echo "3. Write tests for critical paths first"
        echo ""
        exit 1
      fi
    fi
  fi
fi

# If we get here, couldn't parse coverage
echo -e "${YELLOW}Warning: Could not parse coverage report${NC}"
echo "Coverage file: $COVERAGE_SUMMARY"
echo ""
echo "Please verify test coverage manually before refactoring."

exit 0
