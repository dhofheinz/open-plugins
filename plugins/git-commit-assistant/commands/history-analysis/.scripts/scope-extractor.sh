#!/bin/bash

# ============================================================================
# SCRIPT: scope-extractor.sh
# PURPOSE: Extract and analyze scopes from commit messages
# VERSION: 1.0.0
# USAGE: ./scope-extractor.sh --count N --branch BRANCH [--min-frequency N]
# RETURNS: JSON format with scope analysis results
# EXIT CODES:
#   0 - Success
#   1 - Not a git repository
#   2 - No commit history
#   3 - Git command failed
# DEPENDENCIES: git, jq (optional)
# ============================================================================

# Parse command line arguments
COUNT=50
BRANCH="HEAD"
MIN_FREQUENCY=2

while [[ $# -gt 0 ]]; do
    case $1 in
        --count)
            COUNT="$2"
            shift 2
            ;;
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        --min-frequency)
            MIN_FREQUENCY="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

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

# Create temporary files for processing
TEMP_SCOPES=$(mktemp)
TEMP_RESULTS=$(mktemp)

# Clean up temp files on exit
trap "rm -f $TEMP_SCOPES $TEMP_RESULTS" EXIT

# Extract scopes from conventional commit format: type(scope): subject
# Also handle nested scopes: type(parent/child): subject
# And multi-scopes: type(scope1,scope2): subject

TOTAL_COMMITS=$(echo "$SUBJECTS" | wc -l)
SCOPED_COMMITS=0

while IFS= read -r subject; do
    [ -z "$subject" ] && continue

    # Match conventional commit with scope: type(scope): subject
    if echo "$subject" | grep -qE '^[a-z]+\([^)]+\): '; then
        ((SCOPED_COMMITS++))

        # Extract scope(s) - everything between parentheses
        SCOPE_PART=$(echo "$subject" | sed -E 's/^[a-z]+\(([^)]+)\): .*/\1/')

        # Handle multiple scopes (comma or space separated)
        # Split by comma and/or space
        echo "$SCOPE_PART" | tr ',' '\n' | tr ' ' '\n' | while read -r scope; do
            scope=$(echo "$scope" | xargs)  # Trim whitespace
            [ -n "$scope" ] && echo "$scope" >> "$TEMP_SCOPES"
        done
    fi
done <<< "$SUBJECTS"

# Count scope frequencies
if [ ! -s "$TEMP_SCOPES" ]; then
    # No scopes found
    cat << EOF
{
  "total_scopes": 0,
  "scoped_commits": 0,
  "scoped_percentage": 0,
  "scopes": [],
  "message": "No scopes detected in commit history"
}
EOF
    exit 0
fi

# Sort and count unique scopes
SCOPE_COUNTS=$(sort "$TEMP_SCOPES" | uniq -c | sort -rn)

# Calculate scoped percentage
SCOPED_PCT=$(echo "scale=1; $SCOPED_COMMITS * 100 / $TOTAL_COMMITS" | bc -l)

# Build JSON output
echo "{" > "$TEMP_RESULTS"
echo "  \"commits_analyzed\": $TOTAL_COMMITS," >> "$TEMP_RESULTS"
echo "  \"scoped_commits\": $SCOPED_COMMITS," >> "$TEMP_RESULTS"
echo "  \"scoped_percentage\": $SCOPED_PCT," >> "$TEMP_RESULTS"
echo "  \"branch\": \"$BRANCH\"," >> "$TEMP_RESULTS"

# Count unique scopes
UNIQUE_SCOPES=$(echo "$SCOPE_COUNTS" | wc -l)
echo "  \"total_scopes\": $UNIQUE_SCOPES," >> "$TEMP_RESULTS"

# Build scopes array
echo "  \"scopes\": [" >> "$TEMP_RESULTS"

FIRST=true
while read -r count scope; do
    # Skip if below min frequency
    [ "$count" -lt "$MIN_FREQUENCY" ] && continue

    # Calculate percentage
    PCT=$(echo "scale=1; $count * 100 / $SCOPED_COMMITS" | bc -l)

    # Determine if hierarchical (contains /)
    HIERARCHY="null"
    PARENT=""
    CHILD=""
    if echo "$scope" | grep -q '/'; then
        PARENT=$(echo "$scope" | cut -d'/' -f1)
        CHILD=$(echo "$scope" | cut -d'/' -f2)
        HIERARCHY="\"$PARENT/$CHILD\""
    fi

    # Categorize scope
    CATEGORY="other"
    DESCRIPTION="Other"

    case "$scope" in
        auth|security|login|oauth|session)
            CATEGORY="feature"
            DESCRIPTION="Authentication and authorization"
            ;;
        api|endpoint|backend|server|middleware)
            CATEGORY="backend"
            DESCRIPTION="API and backend services"
            ;;
        ui|component|style|frontend|view)
            CATEGORY="ui"
            DESCRIPTION="User interface"
            ;;
        db|database|schema|migration|query)
            CATEGORY="backend"
            DESCRIPTION="Database operations"
            ;;
        docs|readme|changelog|guide)
            CATEGORY="documentation"
            DESCRIPTION="Documentation"
            ;;
        test|e2e|unit|integration|spec)
            CATEGORY="testing"
            DESCRIPTION="Testing"
            ;;
        ci|cd|deploy|docker|k8s|pipeline)
            CATEGORY="infrastructure"
            DESCRIPTION="Infrastructure and deployment"
            ;;
        config|settings|env)
            CATEGORY="configuration"
            DESCRIPTION="Configuration"
            ;;
        core|utils|lib|common)
            CATEGORY="core"
            DESCRIPTION="Core functionality"
            ;;
    esac

    # Check if active (used in recent commits - last 10)
    RECENT_USAGE=$(git log --format='%s' -10 "$BRANCH" 2>/dev/null | grep -c "($scope)" || echo "0")
    ACTIVE="true"
    [ "$RECENT_USAGE" -eq 0 ] && ACTIVE="false"

    # Get example commits
    EXAMPLES=$(git log --format='%s' --grep="($scope)" -3 "$BRANCH" 2>/dev/null | \
               awk '{printf "\"%s\",", $0}' | sed 's/,$//')
    [ -z "$EXAMPLES" ] && EXAMPLES=""

    # Add comma if not first
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo "    ," >> "$TEMP_RESULTS"
    fi

    # Write scope entry
    cat << EOF >> "$TEMP_RESULTS"
    {
      "name": "$scope",
      "count": $count,
      "percentage": $PCT,
      "category": "$CATEGORY",
      "description": "$DESCRIPTION",
      "hierarchy": $HIERARCHY,
      "active": $ACTIVE,
      "recent_usage": $RECENT_USAGE,
      "examples": [$EXAMPLES]
    }
EOF

done <<< "$SCOPE_COUNTS"

echo "  ]" >> "$TEMP_RESULTS"
echo "}" >> "$TEMP_RESULTS"

# Output result
cat "$TEMP_RESULTS"

exit 0
