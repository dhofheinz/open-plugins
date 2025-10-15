#!/bin/bash
# Purpose: Profile database queries and identify slow operations
# Version: 1.0.0
# Usage: ./query-profiler.sh <database-url> [threshold-ms] [output-dir]
# Returns: 0=success, 1=profiling failed, 2=invalid arguments
# Dependencies: psql (PostgreSQL) or mysql (MySQL)

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Arguments
DATABASE_URL="${1:-}"
THRESHOLD_MS="${2:-500}"
OUTPUT_DIR="${3:-./query-profiles}"

# Validate arguments
if [ -z "$DATABASE_URL" ]; then
    echo -e "${RED}Error: Database URL is required${NC}"
    echo "Usage: $0 <database-url> [threshold-ms] [output-dir]"
    echo "Example: $0 postgresql://user:pass@localhost:5432/dbname 500 ./reports"
    exit 2
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo -e "${GREEN}Starting database query profiling${NC}"
echo "Threshold: ${THRESHOLD_MS}ms"
echo "Output directory: $OUTPUT_DIR"

# Detect database type
if [[ "$DATABASE_URL" == postgresql://* ]] || [[ "$DATABASE_URL" == postgres://* ]]; then
    DB_TYPE="postgresql"
elif [[ "$DATABASE_URL" == mysql://* ]]; then
    DB_TYPE="mysql"
else
    echo -e "${YELLOW}Warning: Could not detect database type from URL${NC}"
    DB_TYPE="unknown"
fi

echo "Database type: $DB_TYPE"

# PostgreSQL profiling
if [ "$DB_TYPE" = "postgresql" ]; then
    echo -e "\n${YELLOW}Running PostgreSQL query analysis...${NC}"

    # Enable pg_stat_statements if not already enabled
    psql "$DATABASE_URL" -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;" 2>/dev/null || true

    # Get slow queries
    echo "Finding slow queries (>${THRESHOLD_MS}ms)..."
    psql "$DATABASE_URL" -t -A -F"," > "${OUTPUT_DIR}/slow-queries-${TIMESTAMP}.csv" <<EOF
SELECT
    substring(query, 1, 100) AS short_query,
    calls,
    round(mean_exec_time::numeric, 2) AS avg_time_ms,
    round(max_exec_time::numeric, 2) AS max_time_ms,
    round(total_exec_time::numeric, 2) AS total_time_ms,
    round((100 * total_exec_time / sum(total_exec_time) OVER ())::numeric, 2) AS pct_total_time
FROM pg_stat_statements
WHERE mean_exec_time > ${THRESHOLD_MS}
    AND query NOT LIKE '%pg_stat_statements%'
ORDER BY mean_exec_time DESC
LIMIT 50;
EOF

    # Get most called queries
    echo "Finding most frequently called queries..."
    psql "$DATABASE_URL" -t -A -F"," > "${OUTPUT_DIR}/frequent-queries-${TIMESTAMP}.csv" <<EOF
SELECT
    substring(query, 1, 100) AS short_query,
    calls,
    round(mean_exec_time::numeric, 2) AS avg_time_ms,
    round(total_exec_time::numeric, 2) AS total_time_ms
FROM pg_stat_statements
WHERE query NOT LIKE '%pg_stat_statements%'
ORDER BY calls DESC
LIMIT 50;
EOF

    # Get index usage statistics
    echo "Analyzing index usage..."
    psql "$DATABASE_URL" -t -A -F"," > "${OUTPUT_DIR}/index-usage-${TIMESTAMP}.csv" <<EOF
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC
LIMIT 50;
EOF

    # Find missing indexes (tables with sequential scans)
    echo "Finding potential missing indexes..."
    psql "$DATABASE_URL" -t -A -F"," > "${OUTPUT_DIR}/missing-indexes-${TIMESTAMP}.csv" <<EOF
SELECT
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    CASE WHEN seq_scan > 0 THEN seq_tup_read / seq_scan ELSE 0 END AS avg_seq_read,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS table_size
FROM pg_stat_user_tables
WHERE seq_scan > 1000
    AND (idx_scan = 0 OR seq_scan > idx_scan)
ORDER BY seq_tup_read DESC
LIMIT 30;
EOF

    # Table statistics
    echo "Gathering table statistics..."
    psql "$DATABASE_URL" -t -A -F"," > "${OUTPUT_DIR}/table-stats-${TIMESTAMP}.csv" <<EOF
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    n_live_tup,
    n_dead_tup,
    CASE WHEN n_live_tup > 0 THEN round((n_dead_tup::float / n_live_tup::float) * 100, 2) ELSE 0 END AS dead_pct,
    last_vacuum,
    last_autovacuum
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 30;
EOF

    # Generate text report
    echo -e "\n${GREEN}=== Slow Queries Summary ===${NC}"
    echo "Queries slower than ${THRESHOLD_MS}ms:"
    head -10 "${OUTPUT_DIR}/slow-queries-${TIMESTAMP}.csv" | column -t -s','

    echo -e "\n${GREEN}=== Most Frequent Queries ===${NC}"
    head -10 "${OUTPUT_DIR}/frequent-queries-${TIMESTAMP}.csv" | column -t -s','

    echo -e "\n${GREEN}=== Potential Missing Indexes ===${NC}"
    head -10 "${OUTPUT_DIR}/missing-indexes-${TIMESTAMP}.csv" | column -t -s','

    echo -e "\n${YELLOW}=== Recommendations ===${NC}"

    # Check for unused indexes
    UNUSED_INDEXES=$(awk -F',' '$4 == 0' "${OUTPUT_DIR}/index-usage-${TIMESTAMP}.csv" | wc -l)
    if [ "$UNUSED_INDEXES" -gt 0 ]; then
        echo -e "${YELLOW}⚠ Found $UNUSED_INDEXES unused indexes (0 scans)${NC}"
        echo "  Consider removing to save space and improve write performance"
    fi

    # Check for missing indexes
    MISSING_INDEXES=$(wc -l < "${OUTPUT_DIR}/missing-indexes-${TIMESTAMP}.csv")
    if [ "$MISSING_INDEXES" -gt 1 ]; then
        echo -e "${YELLOW}⚠ Found $((MISSING_INDEXES - 1)) tables with high sequential scans${NC}"
        echo "  Consider adding indexes on frequently queried columns"
    fi

    # Check for bloated tables
    BLOATED_TABLES=$(awk -F',' '$6 > 20' "${OUTPUT_DIR}/table-stats-${TIMESTAMP}.csv" | wc -l)
    if [ "$BLOATED_TABLES" -gt 0 ]; then
        echo -e "${YELLOW}⚠ Found $BLOATED_TABLES tables with >20% dead tuples${NC}"
        echo "  Run VACUUM ANALYZE on these tables"
    fi

# MySQL profiling
elif [ "$DB_TYPE" = "mysql" ]; then
    echo -e "\n${YELLOW}Running MySQL query analysis...${NC}"

    # Enable slow query log temporarily
    mysql "$DATABASE_URL" -e "SET GLOBAL slow_query_log = 'ON';" 2>/dev/null || true
    mysql "$DATABASE_URL" -e "SET GLOBAL long_query_time = $(echo "scale=3; $THRESHOLD_MS/1000" | bc);" 2>/dev/null || true

    echo "Analyzing query performance..."
    mysql "$DATABASE_URL" -e "
    SELECT
        DIGEST_TEXT AS query,
        COUNT_STAR AS exec_count,
        ROUND(AVG_TIMER_WAIT/1000000000, 2) AS avg_time_ms,
        ROUND(MAX_TIMER_WAIT/1000000000, 2) AS max_time_ms,
        ROUND(SUM_TIMER_WAIT/1000000000, 2) AS total_time_ms
    FROM performance_schema.events_statements_summary_by_digest
    WHERE AVG_TIMER_WAIT/1000000000 > ${THRESHOLD_MS}
    ORDER BY AVG_TIMER_WAIT DESC
    LIMIT 50;
    " > "${OUTPUT_DIR}/slow-queries-${TIMESTAMP}.txt"

    echo -e "${GREEN}Query analysis complete${NC}"
    cat "${OUTPUT_DIR}/slow-queries-${TIMESTAMP}.txt"

else
    echo -e "${RED}Error: Unsupported database type${NC}"
    exit 1
fi

# Generate JSON summary
SLOW_QUERY_COUNT=$([ -f "${OUTPUT_DIR}/slow-queries-${TIMESTAMP}.csv" ] && tail -n +1 "${OUTPUT_DIR}/slow-queries-${TIMESTAMP}.csv" | wc -l || echo "0")

cat > "${OUTPUT_DIR}/summary-${TIMESTAMP}.json" <<EOF
{
    "timestamp": "${TIMESTAMP}",
    "databaseType": "${DB_TYPE}",
    "thresholdMs": ${THRESHOLD_MS},
    "slowQueryCount": ${SLOW_QUERY_COUNT},
    "unusedIndexes": ${UNUSED_INDEXES:-0},
    "potentialMissingIndexes": $((${MISSING_INDEXES:-1} - 1)),
    "bloatedTables": ${BLOATED_TABLES:-0}
}
EOF

echo -e "\n${GREEN}✓ Query profiling complete${NC}"
echo "Results saved to:"
echo "  - ${OUTPUT_DIR}/slow-queries-${TIMESTAMP}.csv"
echo "  - ${OUTPUT_DIR}/frequent-queries-${TIMESTAMP}.csv"
echo "  - ${OUTPUT_DIR}/index-usage-${TIMESTAMP}.csv"
echo "  - ${OUTPUT_DIR}/missing-indexes-${TIMESTAMP}.csv"
echo "  - ${OUTPUT_DIR}/table-stats-${TIMESTAMP}.csv"
echo "  - ${OUTPUT_DIR}/summary-${TIMESTAMP}.json"

exit 0
