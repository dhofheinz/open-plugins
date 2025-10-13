#!/bin/bash

# ============================================================================
# SCRIPT: style-analyzer.sh
# PURPOSE: Analyze git commit history for style patterns and conventions
# VERSION: 1.0.0
# USAGE: ./style-analyzer.sh [count] [branch]
# RETURNS: JSON format with style analysis results
# EXIT CODES:
#   0 - Success
#   1 - Not a git repository
#   2 - No commit history
#   3 - Git command failed
# DEPENDENCIES: git, jq (optional for pretty JSON)
# ============================================================================

# Default parameters
COUNT="${1:-50}"
BRANCH="${2:-HEAD}"

# Validate git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo '{"error": "Not in a git repository"}' >&2
    exit 1
fi

# Check if commits exist
if ! git log -1 >/dev/null 2>&1; then
    echo '{"error": "No commit history found"}' >&2
    exit 2
fi

# Get commit subjects
SUBJECTS=$(git log --format='%s' -"$COUNT" "$BRANCH" 2>/dev/null)
if [ $? -ne 0 ]; then
    echo '{"error": "Failed to fetch git log"}' >&2
    exit 3
fi

# Get full commit messages (subject + body)
FULL_MESSAGES=$(git log --format='%B%n---COMMIT_SEPARATOR---' -"$COUNT" "$BRANCH" 2>/dev/null)

# Count total commits analyzed
TOTAL_COMMITS=$(echo "$SUBJECTS" | wc -l)

# Initialize counters
CONVENTIONAL_COUNT=0
IMPERATIVE_COUNT=0
HAS_BODY_COUNT=0
REFERENCES_ISSUES_COUNT=0
CAPITALIZED_COUNT=0
NO_PERIOD_COUNT=0

# Arrays for type and scope counting
declare -A TYPE_COUNT
declare -A SCOPE_COUNT

# Calculate subject line lengths
LENGTHS=""
TOTAL_LENGTH=0

# Process each subject line
while IFS= read -r subject; do
    [ -z "$subject" ] && continue

    # Length analysis
    LENGTH=${#subject}
    LENGTHS="$LENGTHS $LENGTH"
    TOTAL_LENGTH=$((TOTAL_LENGTH + LENGTH))

    # Check conventional commits format: type(scope): subject
    if echo "$subject" | grep -qE '^[a-z]+(\([^)]+\))?: '; then
        ((CONVENTIONAL_COUNT++))

        # Extract type
        TYPE=$(echo "$subject" | sed -E 's/^([a-z]+)(\([^)]+\))?: .*/\1/')
        TYPE_COUNT[$TYPE]=$((${TYPE_COUNT[$TYPE]:-0} + 1))

        # Extract scope if present
        if echo "$subject" | grep -qE '^[a-z]+\([^)]+\): '; then
            SCOPE=$(echo "$subject" | sed -E 's/^[a-z]+\(([^)]+)\): .*/\1/')
            SCOPE_COUNT[$SCOPE]=$((${SCOPE_COUNT[$SCOPE]:-0} + 1))
        fi
    fi

    # Check imperative mood (simple heuristic - starts with verb in base form)
    # Common imperative verbs
    if echo "$subject" | grep -qiE '^(add|fix|update|remove|refactor|implement|create|delete|change|improve|optimize|enhance|correct|resolve|merge|bump|revert|feat|docs|style|test|chore|perf|build|ci)[:(]'; then
        ((IMPERATIVE_COUNT++))
    fi

    # Check capitalization (first letter after type/scope)
    if echo "$subject" | grep -qE ': [A-Z]'; then
        ((CAPITALIZED_COUNT++))
    fi

    # Check no period at end
    if ! echo "$subject" | grep -qE '\.$'; then
        ((NO_PERIOD_COUNT++))
    fi

done <<< "$SUBJECTS"

# Analyze full messages for body and issue references
COMMIT_NUM=0
while IFS= read -r line; do
    if [ "$line" = "---COMMIT_SEPARATOR---" ]; then
        if [ $HAS_BODY = true ]; then
            ((HAS_BODY_COUNT++))
        fi
        if [ $HAS_ISSUE_REF = true ]; then
            ((REFERENCES_ISSUES_COUNT++))
        fi
        HAS_BODY=false
        HAS_ISSUE_REF=false
        IN_SUBJECT=true
        COMMIT_NUM=$((COMMIT_NUM + 1))
        continue
    fi

    if [ "$IN_SUBJECT" = true ]; then
        IN_SUBJECT=false
        continue
    fi

    # Check if has body (non-empty line after subject)
    if [ -n "$line" ] && [ "$line" != "" ]; then
        HAS_BODY=true
    fi

    # Check for issue references
    if echo "$line" | grep -qE '#[0-9]+|[Cc]loses|[Ff]ixes|[Rr]efs'; then
        HAS_ISSUE_REF=true
    fi
done <<< "$FULL_MESSAGES"

# Calculate average subject length
if [ $TOTAL_COMMITS -gt 0 ]; then
    AVG_LENGTH=$((TOTAL_LENGTH / TOTAL_COMMITS))
else
    AVG_LENGTH=0
fi

# Calculate standard deviation (simplified)
SUM_SQUARED_DIFF=0
for length in $LENGTHS; do
    DIFF=$((length - AVG_LENGTH))
    SUM_SQUARED_DIFF=$((SUM_SQUARED_DIFF + DIFF * DIFF))
done
if [ $TOTAL_COMMITS -gt 0 ]; then
    STDDEV=$(echo "scale=1; sqrt($SUM_SQUARED_DIFF / $TOTAL_COMMITS)" | bc -l 2>/dev/null || echo "0")
else
    STDDEV=0
fi

# Calculate percentages
calc_percentage() {
    if [ $TOTAL_COMMITS -gt 0 ]; then
        echo "scale=1; $1 * 100 / $TOTAL_COMMITS" | bc -l
    else
        echo "0"
    fi
}

CONVENTIONAL_PCT=$(calc_percentage $CONVENTIONAL_COUNT)
IMPERATIVE_PCT=$(calc_percentage $IMPERATIVE_COUNT)
HAS_BODY_PCT=$(calc_percentage $HAS_BODY_COUNT)
REFERENCES_ISSUES_PCT=$(calc_percentage $REFERENCES_ISSUES_COUNT)
CAPITALIZED_PCT=$(calc_percentage $CAPITALIZED_COUNT)
NO_PERIOD_PCT=$(calc_percentage $NO_PERIOD_COUNT)

# Build common_types JSON array
COMMON_TYPES_JSON="["
FIRST=true
for type in "${!TYPE_COUNT[@]}"; do
    count=${TYPE_COUNT[$type]}
    pct=$(calc_percentage $count)
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        COMMON_TYPES_JSON="$COMMON_TYPES_JSON,"
    fi
    COMMON_TYPES_JSON="$COMMON_TYPES_JSON{\"type\":\"$type\",\"count\":$count,\"percentage\":$pct}"
done
COMMON_TYPES_JSON="$COMMON_TYPES_JSON]"

# Build common_scopes JSON array
COMMON_SCOPES_JSON="["
FIRST=true
for scope in "${!SCOPE_COUNT[@]}"; do
    count=${SCOPE_COUNT[$scope]}
    pct=$(calc_percentage $count)
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        COMMON_SCOPES_JSON="$COMMON_SCOPES_JSON,"
    fi
    COMMON_SCOPES_JSON="$COMMON_SCOPES_JSON{\"scope\":\"$scope\",\"count\":$count,\"percentage\":$pct}"
done
COMMON_SCOPES_JSON="$COMMON_SCOPES_JSON]"

# Get sample commits (first 3)
SAMPLE_COMMITS=$(git log --format='%s' -3 "$BRANCH" 2>/dev/null | awk '{printf "\"%s\",", $0}' | sed 's/,$//')

# Calculate consistency score (weighted average)
# Weights: conventional(30), imperative(25), capitalized(15), no_period(15), body(10), issues(5)
CONSISTENCY_SCORE=$(echo "scale=0; ($CONVENTIONAL_PCT * 0.3 + $IMPERATIVE_PCT * 0.25 + $CAPITALIZED_PCT * 0.15 + $NO_PERIOD_PCT * 0.15 + $HAS_BODY_PCT * 0.1 + $REFERENCES_ISSUES_PCT * 0.05)" | bc -l)

# Output JSON
cat << EOF
{
  "project_style": {
    "commits_analyzed": $TOTAL_COMMITS,
    "branch": "$BRANCH",
    "uses_conventional_commits": $([ $CONVENTIONAL_COUNT -gt $((TOTAL_COMMITS / 2)) ] && echo "true" || echo "false"),
    "conventional_commits_percentage": $CONVENTIONAL_PCT,
    "average_subject_length": $AVG_LENGTH,
    "subject_length_stddev": $STDDEV,
    "common_types": $COMMON_TYPES_JSON,
    "common_scopes": $COMMON_SCOPES_JSON,
    "imperative_mood_percentage": $IMPERATIVE_PCT,
    "capitalized_subject_percentage": $CAPITALIZED_PCT,
    "no_period_end_percentage": $NO_PERIOD_PCT,
    "has_body_percentage": $HAS_BODY_PCT,
    "references_issues_percentage": $REFERENCES_ISSUES_PCT,
    "consistency_score": $CONSISTENCY_SCORE,
    "sample_commits": [$SAMPLE_COMMITS]
  }
}
EOF

exit 0
