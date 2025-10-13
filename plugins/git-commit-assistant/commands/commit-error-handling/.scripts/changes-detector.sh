#!/usr/bin/env bash
# ================================================================
# Script: changes-detector.sh
# Purpose: Check for changes to commit (staged, unstaged, untracked)
# Version: 1.0.0
# Usage: ./changes-detector.sh
# Returns: JSON with change counts
# Exit Codes:
#   0 = Success (with or without changes)
#   1 = Not a git repository
#   2 = Script error
# ================================================================

set -euo pipefail

# Function to output JSON
output_json() {
    local has_changes=$1
    local staged=$2
    local unstaged=$3
    local untracked=$4
    local total=$5

    cat <<EOF
{
  "has_changes": $has_changes,
  "staged_count": $staged,
  "unstaged_count": $unstaged,
  "untracked_count": $untracked,
  "total_changes": $total,
  "checked_at": "$(date -Iseconds)"
}
EOF
}

# Main logic
main() {
    # Verify we're in a git repository
    if ! git rev-parse --git-dir &>/dev/null; then
        output_json false 0 0 0 0
        exit 1
    fi

    # Count staged changes (added to index)
    STAGED_COUNT=$(git diff --cached --numstat | wc -l)

    # Count unstaged changes (modified but not staged)
    UNSTAGED_COUNT=$(git diff --numstat | wc -l)

    # Count untracked files
    UNTRACKED_COUNT=$(git ls-files --others --exclude-standard | wc -l)

    # Total changes
    TOTAL=$((STAGED_COUNT + UNSTAGED_COUNT + UNTRACKED_COUNT))

    # Determine if there are any changes
    if [ "$TOTAL" -gt 0 ]; then
        HAS_CHANGES=true
    else
        HAS_CHANGES=false
    fi

    # Output JSON
    output_json "$HAS_CHANGES" "$STAGED_COUNT" "$UNSTAGED_COUNT" "$UNTRACKED_COUNT" "$TOTAL"

    exit 0
}

# Run main function
main "$@"
