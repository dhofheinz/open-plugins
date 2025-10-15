#!/bin/bash

# Purpose: Analyze code complexity using ESLint
# Version: 1.0.0
# Usage: ./analyze-complexity.sh <scope> [max-complexity]
# Returns: 0 on success, 1 on error
# Dependencies: npx, eslint

set -euo pipefail

# Configuration
SCOPE="${1:-.}"
MAX_COMPLEXITY="${2:-10}"
MAX_DEPTH="${3:-3}"
MAX_LINES="${4:-50}"
MAX_PARAMS="${5:-4}"
OUTPUT_FILE="complexity-report.json"

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

echo "Analyzing complexity for: $SCOPE"
echo "Max complexity: $MAX_COMPLEXITY"
echo "Max depth: $MAX_DEPTH"
echo "Max lines per function: $MAX_LINES"
echo "Max parameters: $MAX_PARAMS"
echo ""

# Check if eslint is available
if ! command -v npx &> /dev/null; then
  echo -e "${RED}Error: npx not found. Please install Node.js and npm.${NC}" >&2
  exit 1
fi

# Create ESLint config for complexity analysis
ESLINT_CONFIG=$(cat <<EOF
{
  "parserOptions": {
    "ecmaVersion": 2020,
    "sourceType": "module",
    "ecmaFeatures": {
      "jsx": true
    }
  },
  "parser": "@typescript-eslint/parser",
  "rules": {
    "complexity": ["error", { "max": ${MAX_COMPLEXITY} }],
    "max-depth": ["error", ${MAX_DEPTH}],
    "max-lines-per-function": ["error", { "max": ${MAX_LINES}, "skipBlankLines": true, "skipComments": true }],
    "max-params": ["error", ${MAX_PARAMS}],
    "max-nested-callbacks": ["error", 3],
    "max-statements": ["error", 20]
  }
}
EOF
)

# Write temp config
TEMP_CONFIG=$(mktemp)
echo "$ESLINT_CONFIG" > "$TEMP_CONFIG"

# Run ESLint complexity analysis
echo "Running complexity analysis..."

npx eslint "$SCOPE" \
  --ext .js,.jsx,.ts,.tsx \
  --config "$TEMP_CONFIG" \
  --format json \
  --output-file "$OUTPUT_FILE" \
  2>&1 || true

# Parse results
if [ -f "$OUTPUT_FILE" ]; then
  TOTAL_FILES=$(jq 'length' "$OUTPUT_FILE")
  TOTAL_WARNINGS=$(jq '[.[].warningCount] | add // 0' "$OUTPUT_FILE")
  TOTAL_ERRORS=$(jq '[.[].errorCount] | add // 0' "$OUTPUT_FILE")

  echo ""
  echo "=== Complexity Analysis Results ==="
  echo "Files analyzed: $TOTAL_FILES"
  echo "Warnings: $TOTAL_WARNINGS"
  echo "Errors: $TOTAL_ERRORS"
  echo ""

  # Show critical issues (complexity > max)
  CRITICAL_ISSUES=$(jq -r '
    .[] |
    select(.messages | length > 0) |
    .filePath as $file |
    .messages[] |
    select(.ruleId == "complexity" and .severity == 2) |
    "\($file):\(.line):\(.column) - \(.message)"
  ' "$OUTPUT_FILE" | head -20)

  if [ -n "$CRITICAL_ISSUES" ]; then
    echo -e "${RED}Critical Complexity Issues:${NC}"
    echo "$CRITICAL_ISSUES"
    echo ""
  fi

  # Show files with most issues
  echo -e "${YELLOW}Files with Most Issues:${NC}"
  jq -r '
    sort_by(-.errorCount - .warningCount) |
    .[:5] |
    .[] |
    "\(.filePath): \(.errorCount) errors, \(.warningCount) warnings"
  ' "$OUTPUT_FILE"

  echo ""
  echo "Full report saved to: $OUTPUT_FILE"

  # Summary
  if [ "$TOTAL_ERRORS" -gt 0 ]; then
    echo -e "${RED}Status: FAILED - $TOTAL_ERRORS functions exceed complexity threshold${NC}"
    exit 0  # Don't fail, just report
  elif [ "$TOTAL_WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}Status: WARNING - $TOTAL_WARNINGS potential complexity issues${NC}"
  else
    echo -e "${GREEN}Status: PASSED - All functions within complexity limits${NC}"
  fi
else
  echo -e "${RED}Error: Failed to generate complexity report${NC}" >&2
  exit 1
fi

# Cleanup
rm -f "$TEMP_CONFIG"

exit 0
