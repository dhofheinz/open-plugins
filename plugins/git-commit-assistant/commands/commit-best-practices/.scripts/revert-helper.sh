#!/usr/bin/env bash
################################################################################
# Revert Helper Script
#
# Purpose: Generate proper revert commit message and analyze safety
# Version: 1.0.0
# Usage: ./revert-helper.sh <commit-sha>
# Returns: JSON with revert information
# Exit Codes:
#   0 = Success
#   1 = Commit not found
#   2 = Script execution error
################################################################################

set -euo pipefail

################################################################################
# Parse conventional commit message
################################################################################
parse_commit_message() {
    local subject="$1"

    local type=""
    local scope=""
    local description=""

    # Try to match conventional format: type(scope): description
    if [[ "$subject" =~ ^([a-z]+)(\([a-z0-9\-]+\)):[[:space:]](.+)$ ]]; then
        type="${BASH_REMATCH[1]}"
        scope="${BASH_REMATCH[2]}"  # includes parentheses
        scope="${scope#(}"           # remove leading (
        scope="${scope%)}"           # remove trailing )
        description="${BASH_REMATCH[3]}"
    # Try to match without scope: type: description
    elif [[ "$subject" =~ ^([a-z]+):[[:space:]](.+)$ ]]; then
        type="${BASH_REMATCH[1]}"
        scope=""
        description="${BASH_REMATCH[2]}"
    else
        # Non-conventional format
        type=""
        scope=""
        description="$subject"
    fi

    echo "$type|$scope|$description"
}

################################################################################
# Generate revert commit message
################################################################################
generate_revert_message() {
    local commit_sha="$1"
    local original_subject="$2"

    # Parse original message
    local parsed
    parsed=$(parse_commit_message "$original_subject")

    local type
    local scope
    local description

    IFS='|' read -r type scope description <<< "$parsed"

    # Build revert message
    local revert_subject
    if [[ -n "$type" ]]; then
        # Conventional format
        if [[ -n "$scope" ]]; then
            revert_subject="revert: $type($scope): $description"
        else
            revert_subject="revert: $type: $description"
        fi
    else
        # Non-conventional format
        revert_subject="revert: $original_subject"
    fi

    # Build full message (subject + body + footer)
    local revert_message
    revert_message=$(cat <<EOF
$revert_subject

This reverts commit $commit_sha.

Reason: [Provide reason for revert here]
EOF
    )

    echo "$revert_message"
}

################################################################################
# Analyze revert safety
################################################################################
analyze_revert_safety() {
    local commit_sha="$1"

    local safe_to_revert="true"
    local warnings=()

    # Check for dependent commits (commits that touch same files after this one)
    local files_changed
    files_changed=$(git show --name-only --format= "$commit_sha")

    local dependent_count=0
    local dependent_commits=()

    if [[ -n "$files_changed" ]]; then
        # Get commits after this one
        local later_commits
        later_commits=$(git log "$commit_sha"..HEAD --oneline --format='%h %s' || echo "")

        if [[ -n "$later_commits" ]]; then
            while IFS= read -r commit_line; do
                local later_sha
                later_sha=$(echo "$commit_line" | awk '{print $1}')

                # Check if any files overlap
                local later_files
                later_files=$(git show --name-only --format= "$later_sha" 2>/dev/null || echo "")

                # Check for file overlap
                while IFS= read -r file; do
                    if [[ -n "$file" ]] && echo "$files_changed" | grep -qxF "$file"; then
                        dependent_commits+=("$commit_line")
                        ((dependent_count++))
                        break
                    fi
                done <<< "$later_files"
            done <<< "$later_commits"

            if [[ $dependent_count -gt 0 ]]; then
                safe_to_revert="false"
                warnings+=("\"$dependent_count commit(s) depend on this change\"")
            fi
        fi
    fi

    # Check if files still exist (if deleted, might be harder to revert)
    local deleted_files=0
    while IFS= read -r file; do
        if [[ -n "$file" ]] && [[ ! -f "$file" ]]; then
            ((deleted_files++))
        fi
    done <<< "$files_changed"

    if [[ $deleted_files -gt 0 ]]; then
        warnings+=("\"$deleted_files file(s) from commit no longer exist\"")
    fi

    # Check for potential merge conflicts (files modified since commit)
    local modified_files=0
    while IFS= read -r file; do
        if [[ -n "$file" ]] && [[ -f "$file" ]]; then
            # Check if file has been modified since this commit
            local file_changed
            file_changed=$(git log "$commit_sha"..HEAD --oneline -- "$file" | wc -l)
            if [[ $file_changed -gt 0 ]]; then
                ((modified_files++))
            fi
        fi
    done <<< "$files_changed"

    if [[ $modified_files -gt 0 ]]; then
        warnings+=("\"$modified_files file(s) modified since commit - potential conflicts\"")
    fi

    # Format warnings array
    local warnings_json="[]"
    if [[ ${#warnings[@]} -gt 0 ]]; then
        warnings_json="[$(IFS=,; echo "${warnings[*]}")]"
    fi

    echo "{\"safe_to_revert\": $safe_to_revert, \"warnings\": $warnings_json, \"dependent_count\": $dependent_count}"
}

################################################################################
# Main execution
################################################################################
main() {
    # Check arguments
    if [[ $# -lt 1 ]]; then
        echo "{\"error\": \"Usage: revert-helper.sh <commit-sha>\"}"
        exit 2
    fi

    local commit_sha="$1"

    # Verify we're in a git repository
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "{\"error\": \"Not a git repository\"}"
        exit 2
    fi

    # Verify commit exists
    if ! git rev-parse --verify "$commit_sha" &>/dev/null 2>&1; then
        echo "{\"error\": \"Commit not found: $commit_sha\"}"
        exit 1
    fi

    # Get full commit SHA
    local full_sha
    full_sha=$(git rev-parse "$commit_sha")

    local short_sha
    short_sha=$(git rev-parse --short "$commit_sha")

    # Get commit information
    local original_subject
    local original_author
    local commit_date
    local files_affected

    original_subject=$(git log -1 --format='%s' "$commit_sha")
    original_author=$(git log -1 --format='%an <%ae>' "$commit_sha")
    commit_date=$(git log -1 --format='%ad' --date=short "$commit_sha")
    files_affected=$(git show --name-only --format= "$commit_sha" | wc -l)

    # Parse commit type and scope
    local parsed
    parsed=$(parse_commit_message "$original_subject")

    local type
    local scope
    local description

    IFS='|' read -r type scope description <<< "$parsed"

    # Generate revert message
    local revert_message
    revert_message=$(generate_revert_message "$short_sha" "$original_subject")

    # Analyze safety
    local safety_analysis
    safety_analysis=$(analyze_revert_safety "$commit_sha")

    # Build JSON output
    cat <<EOF
{
  "commit": "$short_sha",
  "full_sha": "$full_sha",
  "original_message": "$original_subject",
  "original_author": "$original_author",
  "commit_date": "$commit_date",
  "type": ${type:+\"$type\"},
  "scope": ${scope:+\"$scope\"},
  "files_affected": $files_affected,
  "revert_message": $(echo "$revert_message" | jq -Rs .),
  "safety": $safety_analysis
}
EOF

    exit 0
}

# Execute main function
main "$@"
