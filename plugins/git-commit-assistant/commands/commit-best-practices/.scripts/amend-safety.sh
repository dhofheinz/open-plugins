#!/usr/bin/env bash
################################################################################
# Amend Safety Checker Script
#
# Purpose: Check if it's safe to amend the last commit
# Version: 1.0.0
# Usage: ./amend-safety.sh
# Returns: JSON with safety analysis
# Exit Codes:
#   0 = Safe to amend
#   1 = Unsafe to amend
#   2 = Warning (proceed with caution)
################################################################################

set -euo pipefail

################################################################################
# Check if commit is pushed to remote
################################################################################
check_not_pushed() {
    local status="fail"
    local message=""

    # Check if we have upstream tracking
    if ! git rev-parse --abbrev-ref --symbolic-full-name @{upstream} &>/dev/null; then
        status="pass"
        message="No upstream branch (commit is local only)"
    else
        # Check if HEAD commit exists on upstream
        local upstream_branch
        upstream_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream})

        # Get commits that are local only
        local local_commits
        local_commits=$(git log "$upstream_branch"..HEAD --oneline 2>/dev/null || echo "")

        if [[ -n "$local_commits" ]]; then
            status="pass"
            message="Commit not pushed to $upstream_branch"
        else
            status="fail"
            message="Commit already pushed to $upstream_branch"
        fi
    fi

    echo "{\"status\": \"$status\", \"message\": \"$message\"}"
}

################################################################################
# Check if current user is the commit author
################################################################################
check_same_author() {
    local status="fail"
    local message=""

    # Get current user email
    local current_user
    current_user=$(git config user.email)

    # Get last commit author email
    local commit_author
    commit_author=$(git log -1 --format='%ae')

    if [[ "$current_user" == "$commit_author" ]]; then
        status="pass"
        message="You are the commit author"
    else
        status="fail"
        message="Different author: $commit_author (you are $current_user)"
    fi

    echo "{\"status\": \"$status\", \"message\": \"$message\"}"
}

################################################################################
# Check if on a safe branch (not main/master)
################################################################################
check_safe_branch() {
    local status="pass"
    local message=""

    # Get current branch
    local branch
    branch=$(git branch --show-current)

    # List of protected branches
    local protected_branches=("main" "master" "develop" "production" "release")

    for protected in "${protected_branches[@]}"; do
        if [[ "$branch" == "$protected" ]]; then
            status="warn"
            message="On protected branch: $branch (amending discouraged)"
            break
        fi
    done

    if [[ "$status" == "pass" ]]; then
        message="On feature branch: $branch"
    fi

    echo "{\"status\": \"$status\", \"message\": \"$message\"}"
}

################################################################################
# Check if collaborators might have this commit
################################################################################
check_collaborators() {
    local status="pass"
    local message="Solo work on branch"

    # This is a heuristic check - actual collaboration is hard to detect
    # We check if:
    # 1. Remote branch exists
    # 2. There are other commits on the remote not in local

    if git rev-parse --abbrev-ref --symbolic-full-name @{upstream} &>/dev/null; then
        local upstream_branch
        upstream_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream})

        # Check if there are remote commits we don't have
        local remote_commits
        remote_commits=$(git log HEAD.."$upstream_branch" --oneline 2>/dev/null || echo "")

        if [[ -n "$remote_commits" ]]; then
            status="warn"
            message="Remote has commits you don't have - possible collaboration"
        else
            # Check if branch is shared (exists on remote)
            local remote_name
            remote_name=$(echo "$upstream_branch" | cut -d/ -f1)

            local branch_name
            branch_name=$(git branch --show-current)

            if git ls-remote --heads "$remote_name" "$branch_name" | grep -q "$branch_name"; then
                status="warn"
                message="Branch exists on remote - collaborators may have pulled"
            fi
        fi
    fi

    echo "{\"status\": \"$status\", \"message\": \"$message\"}"
}

################################################################################
# Determine overall recommendation
################################################################################
determine_recommendation() {
    local not_pushed="$1"
    local same_author="$2"
    local safe_branch="$3"
    local collaborators="$4"

    # UNSAFE conditions (critical failures)
    if [[ "$not_pushed" == "fail" ]] || [[ "$same_author" == "fail" ]]; then
        echo "unsafe"
        return
    fi

    # WARNING conditions (proceed with caution)
    if [[ "$safe_branch" == "warn" ]] || [[ "$collaborators" == "warn" ]]; then
        echo "warning"
        return
    fi

    # SAFE (all checks pass)
    echo "safe"
}

################################################################################
# Main execution
################################################################################
main() {
    # Verify we're in a git repository
    if ! git rev-parse --git-dir &>/dev/null; then
        echo "{\"error\": \"Not a git repository\"}"
        exit 2
    fi

    # Check if there are any commits
    if ! git rev-parse HEAD &>/dev/null 2>&1; then
        echo "{\"error\": \"No commits to amend (empty repository)\"}"
        exit 2
    fi

    # Run all checks
    local not_pushed_result
    local same_author_result
    local safe_branch_result
    local collaborators_result

    not_pushed_result=$(check_not_pushed)
    same_author_result=$(check_same_author)
    safe_branch_result=$(check_safe_branch)
    collaborators_result=$(check_collaborators)

    # Extract status values for recommendation
    local not_pushed_status
    local same_author_status
    local safe_branch_status
    local collaborators_status

    not_pushed_status=$(echo "$not_pushed_result" | grep -o '"status": "[^"]*"' | cut -d'"' -f4)
    same_author_status=$(echo "$same_author_result" | grep -o '"status": "[^"]*"' | cut -d'"' -f4)
    safe_branch_status=$(echo "$safe_branch_result" | grep -o '"status": "[^"]*"' | cut -d'"' -f4)
    collaborators_status=$(echo "$collaborators_result" | grep -o '"status": "[^"]*"' | cut -d'"' -f4)

    # Determine overall recommendation
    local recommendation
    recommendation=$(determine_recommendation "$not_pushed_status" "$same_author_status" "$safe_branch_status" "$collaborators_status")

    # Determine safe boolean
    local safe="false"
    if [[ "$recommendation" == "safe" ]]; then
        safe="true"
    fi

    # Get commit info
    local commit_sha
    local commit_author
    local branch

    commit_sha=$(git rev-parse --short HEAD)
    commit_author=$(git log -1 --format='%an <%ae>')
    branch=$(git branch --show-current)

    # Build JSON output
    cat <<EOF
{
  "safe": $safe,
  "recommendation": "$recommendation",
  "commit": "$commit_sha",
  "author": "$commit_author",
  "branch": "$branch",
  "checks": {
    "not_pushed": $not_pushed_result,
    "same_author": $same_author_result,
    "safe_branch": $safe_branch_result,
    "collaborators": $collaborators_result
  }
}
EOF

    # Exit with appropriate code
    case "$recommendation" in
        safe)
            exit 0
            ;;
        warning)
            exit 2
            ;;
        unsafe)
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
