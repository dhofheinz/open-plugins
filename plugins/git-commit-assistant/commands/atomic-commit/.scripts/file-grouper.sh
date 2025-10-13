#!/bin/bash
# File Grouper - Group changed files by type, scope, or feature
#
# Purpose: Group git changed files using different strategies
# Version: 1.0.0
# Usage: ./file-grouper.sh <strategy> [options]
#   strategy: type|scope|feature
#   options: --verbose, --format json|text
# Returns:
#   Exit 0: Success
#   Exit 1: No changes
#   Exit 2: Invalid parameters
#
# Dependencies: git, bash 4.0+

set -euo pipefail

# Configuration
STRATEGY="${1:-type}"
VERBOSE=false
FORMAT="text"

# Parse arguments
shift || true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --format)
            FORMAT="${2:-text}"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 2
            ;;
    esac
done

# Logging function
log() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "[DEBUG] $*" >&2
    fi
}

# Get changed files
get_changed_files() {
    local files=()

    # Staged files
    while IFS= read -r file; do
        [[ -n "$file" ]] && files+=("$file")
    done < <(git diff --cached --name-only)

    # Unstaged files
    while IFS= read -r file; do
        [[ -n "$file" ]] && files+=("$file")
    done < <(git diff --name-only)

    # Remove duplicates
    printf '%s\n' "${files[@]}" | sort -u
}

# Detect commit type from file
detect_type() {
    local file="$1"
    local diff

    # Get diff for analysis
    diff=$(git diff --cached "$file" 2>/dev/null || git diff "$file" 2>/dev/null || echo "")

    # Documentation files
    if [[ "$file" =~ \.(md|txt|rst|adoc)$ ]]; then
        echo "docs"
        return
    fi

    # Test files
    if [[ "$file" =~ (test|spec|__tests__)/ ]] || [[ "$file" =~ \.(test|spec)\. ]]; then
        echo "test"
        return
    fi

    # CI/CD files
    if [[ "$file" =~ \.github/|\.gitlab-ci|jenkins|\.circleci ]]; then
        echo "ci"
        return
    fi

    # Build files
    if [[ "$file" =~ (package\.json|pom\.xml|build\.gradle|Makefile|CMakeLists\.txt)$ ]]; then
        echo "build"
        return
    fi

    # Analyze diff content
    if [[ -z "$diff" ]]; then
        echo "chore"
        return
    fi

    # Check for new functionality
    if echo "$diff" | grep -q "^+.*\(function\|class\|def\|const\|let\)"; then
        if echo "$diff" | grep -iq "^+.*\(new\|add\|implement\|create\)"; then
            echo "feat"
            return
        fi
    fi

    # Check for bug fixes
    if echo "$diff" | grep -iq "^+.*\(fix\|bug\|error\|issue\|null\|undefined\)"; then
        echo "fix"
        return
    fi

    # Check for refactoring
    if echo "$diff" | grep -iq "^+.*\(refactor\|rename\|move\|extract\)"; then
        echo "refactor"
        return
    fi

    # Check for performance
    if echo "$diff" | grep -iq "^+.*\(performance\|optimize\|cache\|memoize\)"; then
        echo "perf"
        return
    fi

    # Default to chore
    echo "chore"
}

# Extract scope from file path
extract_scope() {
    local file="$1"
    local scope

    # Remove leading ./
    file="${file#./}"

    # Split path
    IFS='/' read -ra parts <<< "$file"

    # Skip common prefixes
    for part in "${parts[@]}"; do
        case "$part" in
            src|lib|app|packages|tests|test|.)
                continue
                ;;
            *)
                # Remove file extension
                scope="${part%%.*}"
                echo "$scope"
                return
                ;;
        esac
    done

    echo "root"
}

# Group by type
group_by_type() {
    log "Grouping by type..."

    declare -A groups
    local files
    mapfile -t files < <(get_changed_files)

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No changes detected" >&2
        exit 1
    fi

    # Group files by type
    for file in "${files[@]}"; do
        local type
        type=$(detect_type "$file")
        log "  $file -> type:$type"

        if [[ -z "${groups[$type]:-}" ]]; then
            groups[$type]="$file"
        else
            groups[$type]="${groups[$type]},$file"
        fi
    done

    # Output results
    if [[ "$FORMAT" == "json" ]]; then
        echo "{"
        echo "  \"strategy\": \"type\","
        echo "  \"groups\": {"
        local first=true
        for type in "${!groups[@]}"; do
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo ","
            fi
            IFS=',' read -ra file_list <<< "${groups[$type]}"
            echo -n "    \"$type\": ["
            local first_file=true
            for f in "${file_list[@]}"; do
                if [[ "$first_file" == "true" ]]; then
                    first_file=false
                else
                    echo -n ", "
                fi
                echo -n "\"$f\""
            done
            echo -n "]"
        done
        echo ""
        echo "  }"
        echo "}"
    else
        echo "=== FILE GROUPS (strategy: type) ==="
        echo ""
        local group_num=1
        for type in "${!groups[@]}"; do
            IFS=',' read -ra file_list <<< "${groups[$type]}"
            echo "Group $group_num: $type (${#file_list[@]} files)"
            for file in "${file_list[@]}"; do
                echo "  $file"
            done
            echo ""
            ((group_num++))
        done
    fi
}

# Group by scope
group_by_scope() {
    log "Grouping by scope..."

    declare -A groups
    local files
    mapfile -t files < <(get_changed_files)

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No changes detected" >&2
        exit 1
    fi

    # Group files by scope
    for file in "${files[@]}"; do
        local scope
        scope=$(extract_scope "$file")
        log "  $file -> scope:$scope"

        if [[ -z "${groups[$scope]:-}" ]]; then
            groups[$scope]="$file"
        else
            groups[$scope]="${groups[$scope]},$file"
        fi
    done

    # Output results
    if [[ "$FORMAT" == "json" ]]; then
        echo "{"
        echo "  \"strategy\": \"scope\","
        echo "  \"groups\": {"
        local first=true
        for scope in "${!groups[@]}"; do
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo ","
            fi
            IFS=',' read -ra file_list <<< "${groups[$scope]}"
            echo -n "    \"$scope\": ["
            local first_file=true
            for f in "${file_list[@]}"; do
                if [[ "$first_file" == "true" ]]; then
                    first_file=false
                else
                    echo -n ", "
                fi
                echo -n "\"$f\""
            done
            echo -n "]"
        done
        echo ""
        echo "  }"
        echo "}"
    else
        echo "=== FILE GROUPS (strategy: scope) ==="
        echo ""
        local group_num=1
        for scope in "${!groups[@]}"; do
            IFS=',' read -ra file_list <<< "${groups[$scope]}"
            echo "Group $group_num: $scope (${#file_list[@]} files)"
            for file in "${file_list[@]}"; do
                echo "  $file"
            done
            echo ""
            ((group_num++))
        done
    fi
}

# Group by feature (simplified - uses type and scope combination)
group_by_feature() {
    log "Grouping by feature..."

    declare -A groups
    local files
    mapfile -t files < <(get_changed_files)

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "No changes detected" >&2
        exit 1
    fi

    # Group files by type+scope combination
    for file in "${files[@]}"; do
        local type scope feature
        type=$(detect_type "$file")
        scope=$(extract_scope "$file")
        feature="${type}_${scope}"
        log "  $file -> feature:$feature"

        if [[ -z "${groups[$feature]:-}" ]]; then
            groups[$feature]="$file"
        else
            groups[$feature]="${groups[$feature]},$file"
        fi
    done

    # Output results
    if [[ "$FORMAT" == "json" ]]; then
        echo "{"
        echo "  \"strategy\": \"feature\","
        echo "  \"groups\": {"
        local first=true
        for feature in "${!groups[@]}"; do
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo ","
            fi
            IFS=',' read -ra file_list <<< "${groups[$feature]}"
            echo -n "    \"$feature\": ["
            local first_file=true
            for f in "${file_list[@]}"; do
                if [[ "$first_file" == "true" ]]; then
                    first_file=false
                else
                    echo -n ", "
                fi
                echo -n "\"$f\""
            done
            echo -n "]"
        done
        echo ""
        echo "  }"
        echo "}"
    else
        echo "=== FILE GROUPS (strategy: feature) ==="
        echo ""
        local group_num=1
        for feature in "${!groups[@]}"; do
            IFS=',' read -ra file_list <<< "${groups[$feature]}"
            IFS='_' read -ra feature_parts <<< "$feature"
            local type="${feature_parts[0]}"
            local scope="${feature_parts[1]}"
            echo "Group $group_num: $type($scope) (${#file_list[@]} files)"
            for file in "${file_list[@]}"; do
                echo "  $file"
            done
            echo ""
            ((group_num++))
        done
    fi
}

# Main execution
case "$STRATEGY" in
    type)
        group_by_type
        ;;
    scope)
        group_by_scope
        ;;
    feature)
        group_by_feature
        ;;
    *)
        echo "Invalid strategy: $STRATEGY" >&2
        echo "Valid strategies: type, scope, feature" >&2
        exit 2
        ;;
esac
