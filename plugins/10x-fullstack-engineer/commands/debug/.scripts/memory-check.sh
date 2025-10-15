#!/bin/bash
# Purpose: Monitor memory usage and detect leaks
# Version: 1.0.0
# Usage: ./memory-check.sh --app <app-name> [options]
# Returns: 0=success, 1=error, 2=invalid params
# Dependencies: ps, awk, bc

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
APP_NAME=""
DURATION=300
INTERVAL=10
THRESHOLD=1024
OUTPUT_DIR="./memory-check-output"
ALERT_ON_GROWTH=true

# Help message
show_help() {
    cat << EOF
Memory Monitoring Utility

Usage: $0 --app <app-name> [options]

Options:
    --app NAME           Application/process name to monitor (required)
    --duration N         Monitoring duration in seconds (default: 300)
    --interval N         Sampling interval in seconds (default: 10)
    --threshold MB       Alert if memory exceeds threshold in MB (default: 1024)
    --output DIR         Output directory (default: ./memory-check-output)
    --no-alert           Disable growth alerts
    -h, --help           Show this help message

Examples:
    # Monitor Node.js app for 5 minutes
    $0 --app node --duration 300

    # Monitor with custom threshold
    $0 --app node --duration 600 --threshold 2048

    # Quick check (1 minute)
    $0 --app node --duration 60 --interval 5

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
        --threshold)
            THRESHOLD="$2"
            shift 2
            ;;
        --output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --no-alert)
            ALERT_ON_GROWTH=false
            shift
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

alert() {
    echo -e "${RED}[ALERT]${NC} $1"
}

# Create output directory
mkdir -p "$OUTPUT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log_info "Starting memory monitoring for: $APP_NAME"
log_info "Duration: ${DURATION}s, Interval: ${INTERVAL}s, Threshold: ${THRESHOLD}MB"
log_info "Output directory: $OUTPUT_DIR"

# Find process ID
PIDS=$(pgrep -f "$APP_NAME" || echo "")
if [ -z "$PIDS" ]; then
    log_error "No process found matching: $APP_NAME"
    exit 1
fi

PID=$(echo "$PIDS" | head -1)
log_info "Found process: PID $PID"

# Output files
MEMORY_LOG="$OUTPUT_DIR/memory-log-$TIMESTAMP.txt"
CHART_FILE="$OUTPUT_DIR/memory-chart-$TIMESTAMP.txt"
REPORT_FILE="$OUTPUT_DIR/memory-report-$TIMESTAMP.txt"

# Write header
echo "Timestamp,RSS_KB,VSZ_KB,Percent_MEM" > "$MEMORY_LOG"

log_info "Monitoring memory usage..."

# Track min/max
MIN_RSS=0
MAX_RSS=0
READINGS=()

# Collect memory samples
SAMPLES=$((DURATION / INTERVAL))
for i in $(seq 1 $SAMPLES); do
    # Get memory stats
    MEM_STATS=$(ps -p "$PID" -o rss=,vsz=,%mem= 2>/dev/null || echo "")

    if [ -z "$MEM_STATS" ]; then
        log_error "Process $PID not found. It may have terminated."
        break
    fi

    # Parse values
    RSS=$(echo "$MEM_STATS" | awk '{print $1}')
    VSZ=$(echo "$MEM_STATS" | awk '{print $2}')
    PMEM=$(echo "$MEM_STATS" | awk '{print $3}')
    TIMESTAMP_NOW=$(date '+%Y-%m-%d %H:%M:%S')

    # Update min/max
    if [ "$MIN_RSS" -eq 0 ] || [ "$RSS" -lt "$MIN_RSS" ]; then
        MIN_RSS=$RSS
    fi
    if [ "$RSS" -gt "$MAX_RSS" ]; then
        MAX_RSS=$RSS
    fi

    # Store reading
    READINGS+=($RSS)

    # Log to file
    echo "$TIMESTAMP_NOW,$RSS,$VSZ,$PMEM" >> "$MEMORY_LOG"

    # Convert to MB for display
    RSS_MB=$(echo "scale=2; $RSS/1024" | bc)
    VSZ_MB=$(echo "scale=2; $VSZ/1024" | bc)

    # Progress display
    echo -ne "\r  Sample $i/$SAMPLES: RSS=${RSS_MB}MB, VSZ=${VSZ_MB}MB, %MEM=${PMEM}%  "

    # Check threshold
    if (( $(echo "$RSS_MB > $THRESHOLD" | bc -l) )); then
        echo ""  # New line before alert
        alert "Memory threshold exceeded: ${RSS_MB}MB > ${THRESHOLD}MB"
    fi

    sleep "$INTERVAL"
done

echo ""  # New line after progress

log_success "Memory monitoring complete"

# Calculate statistics
MIN_MB=$(echo "scale=2; $MIN_RSS/1024" | bc)
MAX_MB=$(echo "scale=2; $MAX_RSS/1024" | bc)
GROWTH_MB=$(echo "scale=2; ($MAX_RSS-$MIN_RSS)/1024" | bc)

# Calculate average
TOTAL_RSS=0
for rss in "${READINGS[@]}"; do
    TOTAL_RSS=$((TOTAL_RSS + rss))
done
AVG_RSS=$((TOTAL_RSS / ${#READINGS[@]}))
AVG_MB=$(echo "scale=2; $AVG_RSS/1024" | bc)

# Detect leak (memory consistently growing)
LEAK_DETECTED=false
if (( $(echo "$GROWTH_MB > 50" | bc -l) )); then
    # Check if growth is consistent (not just spike)
    FIRST_HALF_AVG=0
    SECOND_HALF_AVG=0
    MID_POINT=$((${#READINGS[@]} / 2))

    for i in $(seq 0 $((MID_POINT - 1))); do
        FIRST_HALF_AVG=$((FIRST_HALF_AVG + READINGS[$i]))
    done
    FIRST_HALF_AVG=$((FIRST_HALF_AVG / MID_POINT))

    for i in $(seq $MID_POINT $((${#READINGS[@]} - 1))); do
        SECOND_HALF_AVG=$((SECOND_HALF_AVG + READINGS[$i]))
    done
    SECOND_HALF_AVG=$((SECOND_HALF_AVG / (${#READINGS[@]} - MID_POINT)))

    CONSISTENT_GROWTH=$((SECOND_HALF_AVG - FIRST_HALF_AVG))
    CONSISTENT_GROWTH_MB=$(echo "scale=2; $CONSISTENT_GROWTH/1024" | bc)

    if (( $(echo "$CONSISTENT_GROWTH_MB > 25" | bc -l) )); then
        LEAK_DETECTED=true
    fi
fi

# Generate ASCII chart
log_info "Generating memory chart..."

cat > "$CHART_FILE" << EOF
Memory Usage Over Time
═══════════════════════════════════════════════════════════

RSS (Resident Set Size) in MB

EOF

# Simple ASCII chart (40 rows, scale based on max)
CHART_HEIGHT=20
SCALE_FACTOR=$(echo "scale=2; $MAX_RSS / $CHART_HEIGHT" | bc)

for row in $(seq $CHART_HEIGHT -1 0); do
    THRESHOLD_LINE=$(echo "scale=0; $row * $SCALE_FACTOR / 1024" | bc)
    printf "%4d MB |" "$THRESHOLD_LINE"

    for reading in "${READINGS[@]}"; do
        READING_ROW=$(echo "scale=0; $reading / $SCALE_FACTOR" | bc)

        if [ "$READING_ROW" -ge "$row" ]; then
            printf "█"
        else
            printf " "
        fi
    done

    echo ""
done

printf "       +"
for i in $(seq 1 ${#READINGS[@]}); do printf "─"; done
echo ""

printf "        "
for i in $(seq 1 ${#READINGS[@]}); do
    if [ $((i % 10)) -eq 0 ]; then
        printf "|"
    else
        printf " "
    fi
done
echo ""

cat >> "$CHART_FILE" << EOF

Legend: Each column = ${INTERVAL}s interval
Total duration: ${DURATION}s
EOF

cat "$CHART_FILE"

# Generate report
log_info "Generating memory report..."

cat > "$REPORT_FILE" << EOF
═══════════════════════════════════════════════════════════
              MEMORY MONITORING REPORT
═══════════════════════════════════════════════════════════

Application: $APP_NAME
PID: $PID
Duration: ${DURATION}s (${SAMPLES} samples)
Interval: ${INTERVAL}s
Timestamp: $TIMESTAMP

Memory Statistics:
─────────────────────────────────────────────────────────
  Minimum RSS:     ${MIN_MB} MB
  Maximum RSS:     ${MAX_MB} MB
  Average RSS:     ${AVG_MB} MB
  Memory Growth:   ${GROWTH_MB} MB
  Threshold:       ${THRESHOLD} MB

EOF

# Leak analysis
if [ "$LEAK_DETECTED" = true ]; then
    cat >> "$REPORT_FILE" << EOF
⚠ MEMORY LEAK DETECTED
─────────────────────────────────────────────────────────
  Memory grew consistently by ${CONSISTENT_GROWTH_MB} MB
  First half average: $(echo "scale=2; $FIRST_HALF_AVG/1024" | bc) MB
  Second half average: $(echo "scale=2; $SECOND_HALF_AVG/1024" | bc) MB

  Recommendations:
    1. Take heap snapshots for detailed analysis
    2. Check for:
       - Event listeners not removed
       - Timers not cleared (setInterval, setTimeout)
       - Unbounded caches or arrays
       - Circular references
       - Closures holding large objects
    3. Use memory profiling tools:
       - Node.js: node --inspect, heap snapshots
       - Python: memory_profiler, tracemalloc
    4. Consider using /debug memory operation for deeper analysis

EOF

    if [ "$ALERT_ON_GROWTH" = true ]; then
        alert "MEMORY LEAK DETECTED! Growth: ${CONSISTENT_GROWTH_MB} MB"
    fi
else
    cat >> "$REPORT_FILE" << EOF
✓ NO MEMORY LEAK DETECTED
─────────────────────────────────────────────────────────
  Memory usage is stable
  Growth of ${GROWTH_MB} MB is within acceptable range

EOF
    log_success "No memory leak detected"
fi

# Threshold warnings
if (( $(echo "$MAX_MB > $THRESHOLD" | bc -l) )); then
    cat >> "$REPORT_FILE" << EOF
⚠ THRESHOLD EXCEEDED
─────────────────────────────────────────────────────────
  Peak memory (${MAX_MB} MB) exceeded threshold (${THRESHOLD} MB)

  Recommendations:
    1. Increase memory allocation if necessary
    2. Optimize memory usage:
       - Use streaming for large data
       - Implement pagination
       - Use efficient data structures
       - Clear unused objects
    3. Set appropriate container/VM memory limits

EOF
fi

# Output files
cat >> "$REPORT_FILE" << EOF
Output Files:
─────────────────────────────────────────────────────────
  Memory Log:   $MEMORY_LOG
  Memory Chart: $CHART_FILE
  This Report:  $REPORT_FILE

Next Steps:
─────────────────────────────────────────────────────────
EOF

if [ "$LEAK_DETECTED" = true ]; then
    cat >> "$REPORT_FILE" << EOF
  1. Use /debug memory for heap profiling
  2. Take heap snapshots before and after operations
  3. Review code for common leak patterns
  4. Monitor production with these findings
EOF
else
    cat >> "$REPORT_FILE" << EOF
  1. Continue monitoring in production
  2. Set up alerts for memory threshold
  3. Schedule periodic memory checks
EOF
fi

echo "" >> "$REPORT_FILE"
echo "═══════════════════════════════════════════════════════════" >> "$REPORT_FILE"

log_success "Report saved to: $REPORT_FILE"

# Display report
cat "$REPORT_FILE"

# Exit with appropriate code
if [ "$LEAK_DETECTED" = true ]; then
    exit 1
else
    exit 0
fi
