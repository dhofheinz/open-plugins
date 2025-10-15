#!/bin/bash

# Purpose: Detect code duplication using jsinspect
# Version: 1.0.0
# Usage: ./detect-duplication.sh <scope> [threshold]
# Returns: 0 on success, 1 on error
# Dependencies: npx, jsinspect

set -euo pipefail

# Configuration
SCOPE="${1:-.}"
THRESHOLD="${2:-80}"
MIN_INSTANCES="${3:-2}"
OUTPUT_FILE="duplication-report.json"

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

echo "Detecting code duplication in: $SCOPE"
echo "Similarity threshold: ${THRESHOLD}%"
echo "Minimum instances: $MIN_INSTANCES"
echo ""

# Check if npx is available
if ! command -v npx &> /dev/null; then
  echo -e "${RED}Error: npx not found. Please install Node.js and npm.${NC}" >&2
  exit 1
fi

# Run jsinspect
echo "Analyzing code for duplicates..."

npx jsinspect "$SCOPE" \
  --threshold "$THRESHOLD" \
  --min-instances "$MIN_INSTANCES" \
  --ignore "node_modules|dist|build|coverage|test|__tests__|*.spec.*|*.test.*" \
  --reporter json \
  > "$OUTPUT_FILE" 2>&1 || true

# Parse results
if [ -f "$OUTPUT_FILE" ]; then
  # Check if output is valid JSON
  if ! jq empty "$OUTPUT_FILE" 2>/dev/null; then
    # Not JSON, probably text output or error
    if [ -s "$OUTPUT_FILE" ]; then
      echo -e "${YELLOW}Warning: Output is not JSON format${NC}"
      cat "$OUTPUT_FILE"
    else
      echo -e "${GREEN}No duplicates found!${NC}"
      echo "Duplication threshold: ${THRESHOLD}%"
      echo "Status: PASSED"
      rm -f "$OUTPUT_FILE"
      exit 0
    fi
  else
    # Valid JSON output
    DUPLICATE_COUNT=$(jq 'length' "$OUTPUT_FILE")

    if [ "$DUPLICATE_COUNT" -eq 0 ]; then
      echo -e "${GREEN}No duplicates found!${NC}"
      echo "Duplication threshold: ${THRESHOLD}%"
      echo "Status: PASSED"
      rm -f "$OUTPUT_FILE"
      exit 0
    fi

    echo ""
    echo "=== Duplication Analysis Results ==="
    echo "Duplicate blocks found: $DUPLICATE_COUNT"
    echo ""

    # Show duplicate details
    echo -e "${RED}Duplicate Code Blocks:${NC}"
    echo ""

    jq -r '
      .[] |
      "Block \(.id // "N/A"):",
      "  Lines: \(.lines)",
      "  Instances: \(.instances | length)",
      "  Locations:",
      (.instances[] | "    - \(.path):\(.lines[0])-\(.lines[1])"),
      ""
    ' "$OUTPUT_FILE" | head -100

    echo ""
    echo "Full report saved to: $OUTPUT_FILE"

    # Calculate statistics
    TOTAL_INSTANCES=$(jq '[.[].instances | length] | add' "$OUTPUT_FILE")
    AVG_LINES=$(jq '[.[].lines] | add / length | floor' "$OUTPUT_FILE")

    echo ""
    echo "=== Statistics ==="
    echo "Total duplicate instances: $TOTAL_INSTANCES"
    echo "Average duplicate size: $AVG_LINES lines"
    echo ""

    if [ "$DUPLICATE_COUNT" -gt 10 ]; then
      echo -e "${RED}Status: HIGH DUPLICATION - $DUPLICATE_COUNT blocks found${NC}"
    elif [ "$DUPLICATE_COUNT" -gt 5 ]; then
      echo -e "${YELLOW}Status: MODERATE DUPLICATION - $DUPLICATE_COUNT blocks found${NC}"
    else
      echo -e "${YELLOW}Status: LOW DUPLICATION - $DUPLICATE_COUNT blocks found${NC}"
    fi

    echo ""
    echo "Recommendations:"
    echo "1. Extract duplicate code to shared functions/components"
    echo "2. Use parameterization to reduce duplication"
    echo "3. Consider design patterns (Strategy, Template Method)"
  fi
else
  echo -e "${RED}Error: Failed to generate duplication report${NC}" >&2
  exit 1
fi

exit 0
