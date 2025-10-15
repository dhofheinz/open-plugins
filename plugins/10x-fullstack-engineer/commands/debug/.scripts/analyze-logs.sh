#!/bin/bash
# Purpose: Analyze log files for patterns, errors, and anomalies
# Version: 1.0.0
# Usage: ./analyze-logs.sh --file <log-file> [options]
# Returns: 0=success, 1=error, 2=invalid params
# Dependencies: awk, grep, sed, jq (optional for JSON logs)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
LOG_FILE=""
PATTERN=""
LEVEL=""
CONTEXT_LINES=5
START_TIME=""
END_TIME=""
OUTPUT_FORMAT="text"
SINCE=""

# Help message
show_help() {
    cat << EOF
Log Analysis Utility

Usage: $0 --file <log-file> [options]

Options:
    --file FILE          Log file to analyze (required)
    --pattern REGEX      Filter by regex pattern
    --level LEVEL        Filter by log level (ERROR|WARN|INFO|DEBUG)
    --context N          Show N lines before and after matches (default: 5)
    --start TIME         Start time (format: "YYYY-MM-DD HH:MM:SS")
    --end TIME           End time (format: "YYYY-MM-DD HH:MM:SS")
    --since DURATION     Time ago (e.g., "1 hour ago", "30 minutes ago")
    --format FORMAT      Output format: text|json (default: text)
    -h, --help           Show this help message

Examples:
    # Find all errors in last hour
    $0 --file app.log --level ERROR --since "1 hour ago"

    # Find timeout errors with context
    $0 --file app.log --pattern "timeout" --context 10

    # Analyze specific timeframe
    $0 --file app.log --start "2024-10-14 14:00:00" --end "2024-10-14 15:00:00"

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --file)
            LOG_FILE="$2"
            shift 2
            ;;
        --pattern)
            PATTERN="$2"
            shift 2
            ;;
        --level)
            LEVEL="$2"
            shift 2
            ;;
        --context)
            CONTEXT_LINES="$2"
            shift 2
            ;;
        --start)
            START_TIME="$2"
            shift 2
            ;;
        --end)
            END_TIME="$2"
            shift 2
            ;;
        --since)
            SINCE="$2"
            shift 2
            ;;
        --format)
            OUTPUT_FORMAT="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}" >&2
            exit 2
            ;;
    esac
done

# Validate required parameters
if [ -z "$LOG_FILE" ]; then
    echo -e "${RED}Error: --file is required${NC}" >&2
    echo "Use --help for usage information"
    exit 2
fi

if [ ! -f "$LOG_FILE" ]; then
    echo -e "${RED}Error: Log file not found: $LOG_FILE${NC}" >&2
    exit 1
fi

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Convert "since" to start time
if [ -n "$SINCE" ]; then
    if command -v date &> /dev/null; then
        START_TIME=$(date -d "$SINCE" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -v -1H '+%Y-%m-%d %H:%M:%S')
    fi
fi

log_info "Analyzing log file: $LOG_FILE"

# Build grep command
GREP_CMD="cat '$LOG_FILE'"

# Time filtering
if [ -n "$START_TIME" ]; then
    log_info "Filtering from: $START_TIME"
    GREP_CMD="$GREP_CMD | awk '\$0 >= \"$START_TIME\"'"
fi

if [ -n "$END_TIME" ]; then
    log_info "Filtering to: $END_TIME"
    GREP_CMD="$GREP_CMD | awk '\$0 <= \"$END_TIME\"'"
fi

# Level filtering
if [ -n "$LEVEL" ]; then
    log_info "Filtering by level: $LEVEL"
    GREP_CMD="$GREP_CMD | grep -i '$LEVEL'"
fi

# Pattern filtering
if [ -n "$PATTERN" ]; then
    log_info "Filtering by pattern: $PATTERN"
    GREP_CMD="$GREP_CMD | grep -E '$PATTERN' -A $CONTEXT_LINES -B $CONTEXT_LINES"
fi

# Execute filtering
FILTERED_OUTPUT=$(eval "$GREP_CMD")

if [ -z "$FILTERED_OUTPUT" ]; then
    log_warn "No matching log entries found"
    exit 0
fi

# Count results
MATCH_COUNT=$(echo "$FILTERED_OUTPUT" | wc -l)
log_info "Found $MATCH_COUNT matching lines"

# Analysis
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "                    LOG ANALYSIS RESULTS"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Error statistics
echo "Error Statistics:"
echo "─────────────────────────────────────────────────────────"
ERROR_COUNT=$(echo "$FILTERED_OUTPUT" | grep -i "ERROR" | wc -l || echo "0")
WARN_COUNT=$(echo "$FILTERED_OUTPUT" | grep -i "WARN" | wc -l || echo "0")
INFO_COUNT=$(echo "$FILTERED_OUTPUT" | grep -i "INFO" | wc -l || echo "0")

echo "  ERROR: $ERROR_COUNT"
echo "  WARN:  $WARN_COUNT"
echo "  INFO:  $INFO_COUNT"
echo ""

# Top errors
echo "Top Error Messages (Top 10):"
echo "─────────────────────────────────────────────────────────"
echo "$FILTERED_OUTPUT" | grep -i "ERROR" | awk -F'ERROR' '{print $2}' | sort | uniq -c | sort -rn | head -10 || echo "  No errors found"
echo ""

# Time distribution (if timestamps present)
echo "Time Distribution:"
echo "─────────────────────────────────────────────────────────"
echo "$FILTERED_OUTPUT" | awk '{print substr($0, 1, 13)}' | sort | uniq -c | tail -20 || echo "  No timestamp pattern detected"
echo ""

# Output filtered results
if [ "$OUTPUT_FORMAT" = "json" ]; then
    log_info "Generating JSON output..."
    # Simple JSON array of log lines
    echo "{"
    echo "  \"file\": \"$LOG_FILE\","
    echo "  \"matches\": $MATCH_COUNT,"
    echo "  \"entries\": ["
    echo "$FILTERED_OUTPUT" | awk '{printf "    \"%s\",\n", $0}' | sed '$ s/,$//'
    echo "  ]"
    echo "}"
else
    echo "Matching Log Entries:"
    echo "─────────────────────────────────────────────────────────"
    echo "$FILTERED_OUTPUT"
fi

echo ""
log_success "Analysis complete"
exit 0
