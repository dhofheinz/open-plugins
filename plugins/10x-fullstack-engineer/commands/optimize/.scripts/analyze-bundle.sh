#!/bin/bash
# Purpose: Analyze webpack/vite bundle size and composition
# Version: 1.0.0
# Usage: ./analyze-bundle.sh [build-dir] [output-dir]
# Returns: 0=success, 1=analysis failed, 2=invalid arguments
# Dependencies: Node.js, npm, webpack-bundle-analyzer or vite-bundle-visualizer

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Arguments
BUILD_DIR="${1:-./dist}"
OUTPUT_DIR="${2:-./bundle-analysis}"

# Validate build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}Error: Build directory not found: $BUILD_DIR${NC}"
    echo "Please run 'npm run build' first"
    exit 2
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo -e "${GREEN}Analyzing bundle in: $BUILD_DIR${NC}"
echo "Output directory: $OUTPUT_DIR"

# Detect build tool
if [ -f "stats.json" ] || [ -f "$BUILD_DIR/stats.json" ]; then
    BUILD_TOOL="webpack"
elif [ -f "vite.config.js" ] || [ -f "vite.config.ts" ]; then
    BUILD_TOOL="vite"
elif [ -f "next.config.js" ]; then
    BUILD_TOOL="nextjs"
else
    BUILD_TOOL="unknown"
fi

echo "Detected build tool: $BUILD_TOOL"

# Analyze bundle based on build tool
case $BUILD_TOOL in
    webpack)
        echo -e "\n${YELLOW}Running webpack-bundle-analyzer...${NC}"

        # Check if webpack-bundle-analyzer is installed
        if ! npm list webpack-bundle-analyzer &> /dev/null; then
            echo "Installing webpack-bundle-analyzer..."
            npm install --save-dev webpack-bundle-analyzer
        fi

        # Find stats.json
        STATS_FILE="stats.json"
        if [ -f "$BUILD_DIR/stats.json" ]; then
            STATS_FILE="$BUILD_DIR/stats.json"
        fi

        # Generate report
        npx webpack-bundle-analyzer "$STATS_FILE" \
            --mode static \
            --report "${OUTPUT_DIR}/bundle-report-${TIMESTAMP}.html" \
            --no-open

        echo -e "${GREEN}✓ Bundle analysis complete${NC}"
        echo "Report: ${OUTPUT_DIR}/bundle-report-${TIMESTAMP}.html"
        ;;

    vite)
        echo -e "\n${YELLOW}Running vite bundle analysis...${NC}"

        # Check if vite-bundle-visualizer is installed
        if ! npm list rollup-plugin-visualizer &> /dev/null; then
            echo "Installing rollup-plugin-visualizer..."
            npm install --save-dev rollup-plugin-visualizer
        fi

        # Use rollup-plugin-visualizer
        npx vite-bundle-visualizer \
            --output "${OUTPUT_DIR}/bundle-report-${TIMESTAMP}.html"

        echo -e "${GREEN}✓ Bundle analysis complete${NC}"
        ;;

    nextjs)
        echo -e "\n${YELLOW}Running Next.js bundle analysis...${NC}"

        # Check if @next/bundle-analyzer is installed
        if ! npm list @next/bundle-analyzer &> /dev/null; then
            echo "Installing @next/bundle-analyzer..."
            npm install --save-dev @next/bundle-analyzer
        fi

        # Rebuild with analyzer
        ANALYZE=true npm run build

        echo -e "${GREEN}✓ Bundle analysis complete${NC}"
        ;;

    *)
        echo -e "${YELLOW}Unknown build tool. Performing generic analysis...${NC}"
        ;;
esac

# Calculate bundle sizes
echo -e "\n${YELLOW}Calculating bundle sizes...${NC}"

# Find all JS/CSS files
find "$BUILD_DIR" -type f \( -name "*.js" -o -name "*.css" \) -exec ls -lh {} \; | \
    awk '{print $9, $5}' > "${OUTPUT_DIR}/file-sizes-${TIMESTAMP}.txt"

# Calculate totals
TOTAL_JS=$(find "$BUILD_DIR" -type f -name "*.js" -exec du -ch {} + | grep total | awk '{print $1}')
TOTAL_CSS=$(find "$BUILD_DIR" -type f -name "*.css" -exec du -ch {} + | grep total | awk '{print $1}')
TOTAL_ALL=$(du -sh "$BUILD_DIR" | awk '{print $1}')

echo -e "\n=== Bundle Size Summary ==="
echo "Total JavaScript: $TOTAL_JS"
echo "Total CSS: $TOTAL_CSS"
echo "Total Build Size: $TOTAL_ALL"

# Identify large files (>500KB)
echo -e "\n=== Large Files (>500KB) ==="
find "$BUILD_DIR" -type f -size +500k -exec ls -lh {} \; | \
    awk '{print $5, $9}' | sort -hr

# Check for common issues
echo -e "\n${YELLOW}Checking for common issues...${NC}"

# Check for source maps in production
SOURCEMAPS=$(find "$BUILD_DIR" -type f -name "*.map" | wc -l)
if [ "$SOURCEMAPS" -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found $SOURCEMAPS source map files in build${NC}"
    echo "  Consider disabling source maps for production"
fi

# Check for unminified files
UNMINIFIED=$(find "$BUILD_DIR" -type f -name "*.js" ! -name "*.min.js" -exec grep -l "function " {} \; 2>/dev/null | wc -l)
if [ "$UNMINIFIED" -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found potential unminified files${NC}"
    echo "  Verify minification is enabled"
fi

# Generate JSON summary
cat > "${OUTPUT_DIR}/summary-${TIMESTAMP}.json" <<EOF
{
    "timestamp": "${TIMESTAMP}",
    "buildTool": "${BUILD_TOOL}",
    "buildDir": "${BUILD_DIR}",
    "totalJS": "${TOTAL_JS}",
    "totalCSS": "${TOTAL_CSS}",
    "totalSize": "${TOTAL_ALL}",
    "sourceMaps": ${SOURCEMAPS},
    "issues": {
        "sourceMapsInProduction": $([ "$SOURCEMAPS" -gt 0 ] && echo "true" || echo "false"),
        "potentiallyUnminified": $([ "$UNMINIFIED" -gt 0 ] && echo "true" || echo "false")
    }
}
EOF

echo -e "\n${GREEN}✓ Bundle analysis complete${NC}"
echo "Results saved to:"
echo "  - ${OUTPUT_DIR}/bundle-report-${TIMESTAMP}.html"
echo "  - ${OUTPUT_DIR}/file-sizes-${TIMESTAMP}.txt"
echo "  - ${OUTPUT_DIR}/summary-${TIMESTAMP}.json"

exit 0
