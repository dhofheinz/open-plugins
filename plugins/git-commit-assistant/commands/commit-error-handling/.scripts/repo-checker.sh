#!/usr/bin/env bash
# ================================================================
# Script: repo-checker.sh
# Purpose: Verify git repository validity
# Version: 1.0.0
# Usage: ./repo-checker.sh
# Returns: JSON with repository status
# Exit Codes:
#   0 = Valid repository
#   1 = Not a repository
#   2 = Script error
# ================================================================

set -euo pipefail

# Function to output JSON
output_json() {
    local is_repo=$1
    local git_dir=$2
    local error=$3

    cat <<EOF
{
  "is_repo": $is_repo,
  "git_dir": $git_dir,
  "error": "$error",
  "checked_at": "$(date -Iseconds)"
}
EOF
}

# Main logic
main() {
    # Check if git is installed
    if ! command -v git &>/dev/null; then
        output_json false "null" "git not installed"
        exit 2
    fi

    # Try to get git directory
    if GIT_DIR=$(git rev-parse --git-dir 2>/dev/null); then
        # Valid repository
        ABSOLUTE_GIT_DIR=$(cd "$GIT_DIR" && pwd)
        output_json true "\"$ABSOLUTE_GIT_DIR\"" ""
        exit 0
    else
        # Not a repository
        output_json false "null" "not a git repository"
        exit 1
    fi
}

# Run main function
main "$@"
