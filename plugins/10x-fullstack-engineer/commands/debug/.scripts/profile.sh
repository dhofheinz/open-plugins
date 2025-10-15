#!/bin/bash
# Purpose: Profile application performance (CPU, memory, I/O)
# Version: 1.0.0
# Usage: ./profile.sh --app <app-name> [options]
# Returns: 0=success, 1=error, 2=invalid params
# Dependencies: ps, top, pidstat (optional)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
APP_NAME=""
DURATION=60
INTERVAL=1
OUTPUT_DIR="./profile-output"
PROFILE_TYPE="all"
ENDPOINT=""

# Help message
show_help() {
    cat << EOF
Application Profiling Utility

Usage: $0 --app <app-name> [options]

Options:
    --app NAME           Application/process name to profile (required)
    --duration N         Profile duration in seconds (default: 60)
    --interval N         Sampling interval in seconds (default: 1)
    --type TYPE          Profile type: cpu|memory|io|all (default: all)
    --endpoint URL       Optional: HTTP endpoint to load test during profiling
    --output DIR         Output directory (default: ./profile-output)
    -h, --help           Show this help message

Examples:
    # Profile Node.js app for 2 minutes
    $0 --app node --duration 120

    # Profile with load test
    $0 --app node --duration 60 --endpoint http://localhost:3000/api/test

    # Profile only CPU
    $0 --app node --duration 30 --type cpu

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --app)
            APP_NAME="$2"
            shift 2
            ;;
        --duration)
            DURATION="$2"
            shift 2
            ;;
        --interval)
            INTERVAL="$2"
            shift 2
            ;;
        --type)
            PROFILE_TYPE="$2"
            shift 2
            ;;
        --endpoint)
            ENDPOINT="$2"
            shift 2
            ;;
        --output)
            OUTPUT_DIR="$2"
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
if [ -z "$APP_NAME" ]; then
    echo -e "${RED}Error: --app is required${NC}" >&2
    echo "Use --help for usage information"
    exit 2
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

# Create output directory
mkdir -p "$OUTPUT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log_info "Starting profiling for: $APP_NAME"
log_info "Duration: ${DURATION}s, Interval: ${INTERVAL}s"
log_info "Output directory: $OUTPUT_DIR"

# Find process ID
PIDS=$(pgrep -f "$APP_NAME" || echo "")
if [ -z "$PIDS" ]; then
    log_error "No process found matching: $APP_NAME"
    exit 1
fi

PID=$(echo "$PIDS" | head -1)
log_info "Found process: PID $PID"

# Start load test if endpoint provided
LOAD_TEST_PID=""
if [ -n "$ENDPOINT" ]; then
    log_info "Starting load test on: $ENDPOINT"

    if command -v ab &> /dev/null; then
        # Use Apache Bench
        ab -n 100000 -c 10 "$ENDPOINT" > "$OUTPUT_DIR/load-test-$TIMESTAMP.log" 2>&1 &
        LOAD_TEST_PID=$!
        log_info "Load test started (PID: $LOAD_TEST_PID)"
    else
        log_warn "Apache Bench (ab) not found, skipping load test"
    fi
fi

# CPU Profiling
if [ "$PROFILE_TYPE" = "cpu" ] || [ "$PROFILE_TYPE" = "all" ]; then
    log_info "Profiling CPU usage..."

    CPU_OUTPUT="$OUTPUT_DIR/cpu-profile-$TIMESTAMP.txt"

    # Collect CPU samples
    for i in $(seq 1 $DURATION); do
        ps -p "$PID" -o %cpu,rss,vsz,cmd >> "$CPU_OUTPUT" 2>/dev/null || true
        sleep "$INTERVAL"
    done

    log_success "CPU profile saved to: $CPU_OUTPUT"

    # Calculate statistics
    AVG_CPU=$(awk 'NR>1 {sum+=$1; count++} END {if (count>0) print sum/count; else print 0}' "$CPU_OUTPUT")
    MAX_CPU=$(awk 'NR>1 {if ($1>max) max=$1} END {print max+0}' "$CPU_OUTPUT")

    echo "CPU Statistics:" > "$OUTPUT_DIR/cpu-summary-$TIMESTAMP.txt"
    echo "  Average CPU: $AVG_CPU%" >> "$OUTPUT_DIR/cpu-summary-$TIMESTAMP.txt"
    echo "  Peak CPU: $MAX_CPU%" >> "$OUTPUT_DIR/cpu-summary-$TIMESTAMP.txt"
fi

# Memory Profiling
if [ "$PROFILE_TYPE" = "memory" ] || [ "$PROFILE_TYPE" = "all" ]; then
    log_info "Profiling memory usage..."

    MEM_OUTPUT="$OUTPUT_DIR/memory-profile-$TIMESTAMP.txt"

    # Collect memory samples
    for i in $(seq 1 $DURATION); do
        ps -p "$PID" -o rss,vsz,%mem,cmd >> "$MEM_OUTPUT" 2>/dev/null || true
        sleep "$INTERVAL"
    done

    log_success "Memory profile saved to: $MEM_OUTPUT"

    # Calculate statistics
    AVG_RSS=$(awk 'NR>1 {sum+=$1; count++} END {if (count>0) print sum/count; else print 0}' "$MEM_OUTPUT")
    MAX_RSS=$(awk 'NR>1 {if ($1>max) max=$1} END {print max+0}' "$MEM_OUTPUT")
    MIN_RSS=$(awk 'NR>1 {if (min=="") min=$1; if ($1<min) min=$1} END {print min+0}' "$MEM_OUTPUT")

    echo "Memory Statistics:" > "$OUTPUT_DIR/memory-summary-$TIMESTAMP.txt"
    echo "  Average RSS: $(echo "scale=2; $AVG_RSS/1024" | bc) MB" >> "$OUTPUT_DIR/memory-summary-$TIMESTAMP.txt"
    echo "  Peak RSS: $(echo "scale=2; $MAX_RSS/1024" | bc) MB" >> "$OUTPUT_DIR/memory-summary-$TIMESTAMP.txt"
    echo "  Min RSS: $(echo "scale=2; $MIN_RSS/1024" | bc) MB" >> "$OUTPUT_DIR/memory-summary-$TIMESTAMP.txt"
    echo "  Memory Growth: $(echo "scale=2; ($MAX_RSS-$MIN_RSS)/1024" | bc) MB" >> "$OUTPUT_DIR/memory-summary-$TIMESTAMP.txt"
fi

# I/O Profiling
if [ "$PROFILE_TYPE" = "io" ] || [ "$PROFILE_TYPE" = "all" ]; then
    log_info "Profiling I/O usage..."

    IO_OUTPUT="$OUTPUT_DIR/io-profile-$TIMESTAMP.txt"

    # Check if process has I/O stats available
    if [ -f "/proc/$PID/io" ]; then
        # Collect I/O samples
        for i in $(seq 1 $DURATION); do
            echo "=== Sample $i ===" >> "$IO_OUTPUT"
            cat "/proc/$PID/io" >> "$IO_OUTPUT" 2>/dev/null || true
            sleep "$INTERVAL"
        done

        log_success "I/O profile saved to: $IO_OUTPUT"
    else
        log_warn "I/O profiling not available for this process"
    fi
fi

# Stop load test if running
if [ -n "$LOAD_TEST_PID" ]; then
    log_info "Stopping load test..."
    kill "$LOAD_TEST_PID" 2>/dev/null || true
    wait "$LOAD_TEST_PID" 2>/dev/null || true
fi

# Generate summary report
REPORT_FILE="$OUTPUT_DIR/profile-report-$TIMESTAMP.txt"

cat > "$REPORT_FILE" << EOF
═══════════════════════════════════════════════════════════
              PERFORMANCE PROFILE REPORT
═══════════════════════════════════════════════════════════

Application: $APP_NAME
PID: $PID
Duration: ${DURATION}s
Interval: ${INTERVAL}s
Timestamp: $TIMESTAMP

EOF

# Add CPU summary if available
if [ -f "$OUTPUT_DIR/cpu-summary-$TIMESTAMP.txt" ]; then
    cat "$OUTPUT_DIR/cpu-summary-$TIMESTAMP.txt" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

# Add memory summary if available
if [ -f "$OUTPUT_DIR/memory-summary-$TIMESTAMP.txt" ]; then
    cat "$OUTPUT_DIR/memory-summary-$TIMESTAMP.txt" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

# Add recommendations
cat >> "$REPORT_FILE" << EOF
Recommendations:
─────────────────────────────────────────────────────────

EOF

if [ -f "$OUTPUT_DIR/cpu-summary-$TIMESTAMP.txt" ]; then
    MAX_CPU=$(awk '/Peak CPU:/ {print $3}' "$OUTPUT_DIR/cpu-summary-$TIMESTAMP.txt" | sed 's/%//')
    if [ -n "$MAX_CPU" ] && (( $(echo "$MAX_CPU > 80" | bc -l) )); then
        echo "  ⚠ High CPU usage detected (${MAX_CPU}%)" >> "$REPORT_FILE"
        echo "    - Consider optimizing CPU-intensive operations" >> "$REPORT_FILE"
        echo "    - Profile with flame graphs for detailed analysis" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    fi
fi

if [ -f "$OUTPUT_DIR/memory-summary-$TIMESTAMP.txt" ]; then
    GROWTH=$(awk '/Memory Growth:/ {print $3}' "$OUTPUT_DIR/memory-summary-$TIMESTAMP.txt")
    if [ -n "$GROWTH" ] && (( $(echo "$GROWTH > 100" | bc -l) )); then
        echo "  ⚠ Significant memory growth detected (${GROWTH} MB)" >> "$REPORT_FILE"
        echo "    - Possible memory leak" >> "$REPORT_FILE"
        echo "    - Use heap profiling to identify leak sources" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    fi
fi

cat >> "$REPORT_FILE" << EOF
Output Files:
─────────────────────────────────────────────────────────
EOF

ls -lh "$OUTPUT_DIR"/*-$TIMESTAMP.* >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "═══════════════════════════════════════════════════════════" >> "$REPORT_FILE"

log_success "Profile complete!"
log_info "Report saved to: $REPORT_FILE"

# Display summary
cat "$REPORT_FILE"

exit 0
