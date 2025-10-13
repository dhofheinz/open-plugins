#!/usr/bin/env bash
# ================================================================
# Script: state-analyzer.sh
# Purpose: Analyze repository state (HEAD, branch, remote status)
# Version: 1.0.0
# Usage: ./state-analyzer.sh
# Returns: JSON with repository state information
# Exit Codes:
#   0 = Success
#   1 = Not a git repository
#   2 = Script error
# ================================================================

set -euo pipefail

# Function to check HEAD state
check_head_state() {
    if git symbolic-ref HEAD &>/dev/null; then
        echo "attached"
    else
        echo "detached"
    fi
}

# Function to get current branch
get_current_branch() {
    local branch
    branch=$(git branch --show-current 2>/dev/null)

    if [ -z "$branch" ]; then
        echo "null"
    else
        echo "\"$branch\""
    fi
}

# Function to get current commit SHA
get_current_commit() {
    git rev-parse --short HEAD 2>/dev/null || echo "unknown"
}

# Function to check remote status
check_remote_status() {
    # Check if remote exists
    if ! git remote &>/dev/null || [ -z "$(git remote)" ]; then
        echo "no_remote"
        return
    fi

    # Check if branch tracks remote
    if ! git rev-parse --abbrev-ref @{upstream} &>/dev/null; then
        echo "no_upstream"
        return
    fi

    # Compare with upstream
    local local_commit remote_commit
    local_commit=$(git rev-parse HEAD 2>/dev/null)
    remote_commit=$(git rev-parse @{upstream} 2>/dev/null)

    if [ "$local_commit" = "$remote_commit" ]; then
        echo "up_to_date"
    else
        # Check ahead/behind
        local ahead behind
        ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
        behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0")

        if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
            echo "diverged"
        elif [ "$ahead" -gt 0 ]; then
            echo "ahead"
        elif [ "$behind" -gt 0 ]; then
            echo "behind"
        else
            echo "up_to_date"
        fi
    fi
}

# Function to get ahead/behind counts
get_ahead_behind_counts() {
    if ! git rev-parse --abbrev-ref @{upstream} &>/dev/null; then
        echo "0" "0"
        return
    fi

    local ahead behind
    ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
    behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0")

    echo "$ahead" "$behind"
}

# Function to get remote name
get_remote_name() {
    local remote
    remote=$(git remote 2>/dev/null | head -1)

    if [ -z "$remote" ]; then
        echo "null"
    else
        echo "\"$remote\""
    fi
}

# Function to get remote URL
get_remote_url() {
    local remote_name
    remote_name=$(git remote 2>/dev/null | head -1)

    if [ -z "$remote_name" ]; then
        echo "null"
        return
    fi

    local url
    url=$(git remote get-url "$remote_name" 2>/dev/null)

    if [ -z "$url" ]; then
        echo "null"
    else
        echo "\"$url\""
    fi
}

# Function to check if working tree is clean
check_working_tree() {
    if git diff-index --quiet HEAD -- 2>/dev/null; then
        echo "clean"
    else
        echo "dirty"
    fi
}

# Main function
main() {
    # Verify we're in a git repository
    if ! git rev-parse --git-dir &>/dev/null; then
        cat <<EOF
{
  "error": "not a git repository",
  "is_repo": false
}
EOF
        exit 1
    fi

    # Collect all state information
    local head_state current_branch current_commit remote_status
    local ahead behind remote_name remote_url working_tree

    head_state=$(check_head_state)
    current_branch=$(get_current_branch)
    current_commit=$(get_current_commit)
    remote_status=$(check_remote_status)
    read -r ahead behind < <(get_ahead_behind_counts)
    remote_name=$(get_remote_name)
    remote_url=$(get_remote_url)
    working_tree=$(check_working_tree)

    # Output JSON
    cat <<EOF
{
  "is_repo": true,
  "head_state": "$head_state",
  "current_branch": $current_branch,
  "current_commit": "$current_commit",
  "remote_status": "$remote_status",
  "ahead_by": $ahead,
  "behind_by": $behind,
  "remote_name": $remote_name,
  "remote_url": $remote_url,
  "working_tree": "$working_tree",
  "checked_at": "$(date -Iseconds)"
}
EOF

    exit 0
}

# Run main function
main "$@"
