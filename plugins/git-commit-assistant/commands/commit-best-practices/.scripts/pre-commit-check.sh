#!/usr/bin/env bash
################################################################################
# Pre-Commit Validation Script
#
# Purpose: Run comprehensive pre-commit checks to ensure code quality
# Version: 1.0.0
# Usage: ./pre-commit-check.sh [quick:true|false]
# Returns: JSON with validation results
# Exit Codes:
#   0 = All checks passed
#   1 = One or more checks failed
#   2 = Script execution error
################################################################################

set -euo pipefail

# Default to full validation
QUICK_MODE="${1:-quick:false}"
QUICK_MODE="${QUICK_MODE#quick:}"

# Initialize results
OVERALL_STATUS="pass"
declare -A RESULTS

################################################################################
# Check if tests pass
################################################################################
check_tests() {
    local status="skip"
    local message="Tests skipped in quick mode"

    if [[ "$QUICK_MODE" != "true" ]]; then
        # Detect test framework and run tests
        if [[ -f "package.json" ]] && grep -q "\"test\":" package.json; then
            if npm test &>/dev/null; then
                status="pass"
                message="All tests passed"
            else
                status="fail"
                message="Tests failing"
                OVERALL_STATUS="fail"
            fi
        elif [[ -f "pytest.ini" ]] || [[ -f "setup.py" ]]; then
            if python -m pytest &>/dev/null; then
                status="pass"
                message="All tests passed"
            else
                status="fail"
                message="Tests failing"
                OVERALL_STATUS="fail"
            fi
        elif [[ -f "Cargo.toml" ]]; then
            if cargo test &>/dev/null; then
                status="pass"
                message="All tests passed"
            else
                status="fail"
                message="Tests failing"
                OVERALL_STATUS="fail"
            fi
        elif [[ -f "go.mod" ]]; then
            if go test ./... &>/dev/null; then
                status="pass"
                message="All tests passed"
            else
                status="fail"
                message="Tests failing"
                OVERALL_STATUS="fail"
            fi
        else
            status="skip"
            message="No test framework detected"
        fi
    fi

    echo "{\"status\": \"$status\", \"message\": \"$message\"}"
}

################################################################################
# Check if lint passes
################################################################################
check_lint() {
    local status="skip"
    local message="Linting skipped in quick mode"

    if [[ "$QUICK_MODE" != "true" ]]; then
        # Detect linter and run
        if [[ -f "package.json" ]] && (grep -q "eslint" package.json || [[ -f ".eslintrc.json" ]]); then
            if npx eslint . --max-warnings 0 &>/dev/null; then
                status="pass"
                message="Linting passed"
            else
                status="fail"
                message="Linting errors found"
                OVERALL_STATUS="fail"
            fi
        elif command -v pylint &>/dev/null; then
            if pylint $(git diff --cached --name-only --diff-filter=ACM | grep '\.py$') &>/dev/null; then
                status="pass"
                message="Linting passed"
            else
                status="fail"
                message="Linting errors found"
                OVERALL_STATUS="fail"
            fi
        elif command -v clippy &>/dev/null; then
            if cargo clippy -- -D warnings &>/dev/null; then
                status="pass"
                message="Linting passed"
            else
                status="fail"
                message="Linting errors found"
                OVERALL_STATUS="fail"
            fi
        else
            status="skip"
            message="No linter detected"
        fi
    fi

    echo "{\"status\": \"$status\", \"message\": \"$message\"}"
}

################################################################################
# Check for debug code in staged files
################################################################################
check_debug_code() {
    local count=0
    local locations=()

    # Get staged diff
    local diff_output
    diff_output=$(git diff --cached)

    # Search for debug patterns in added lines only
    local debug_patterns=(
        'console\.log'
        'console\.debug'
        'console\.error'
        'debugger'
        'print\('
        'println!'
        'pdb\.set_trace'
        'binding\.pry'
        'byebug'
        'Debug\.Log'
    )

    for pattern in "${debug_patterns[@]}"; do
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                ((count++))
                locations+=("\"$line\"")
            fi
        done < <(echo "$diff_output" | grep "^+" | grep -v "^+++" | grep -E "$pattern" || true)
    done

    local status="pass"
    local message="No debug code found"

    if [[ $count -gt 0 ]]; then
        status="fail"
        message="Found $count debug statement(s)"
        OVERALL_STATUS="fail"
    fi

    # Format locations array
    local locations_json="[]"
    if [[ ${#locations[@]} -gt 0 ]]; then
        locations_json="[$(IFS=,; echo "${locations[*]}")]"
    fi

    echo "{\"status\": \"$status\", \"message\": \"$message\", \"count\": $count, \"locations\": $locations_json}"
}

################################################################################
# Check for TODOs in staged files
################################################################################
check_todos() {
    local count=0
    local locations=()

    # Get staged diff
    local diff_output
    diff_output=$(git diff --cached)

    # Search for TODO patterns in added lines only
    local todo_patterns=(
        'TODO'
        'FIXME'
        'XXX'
        'HACK'
    )

    for pattern in "${todo_patterns[@]}"; do
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                ((count++))
                locations+=("\"$line\"")
            fi
        done < <(echo "$diff_output" | grep "^+" | grep -v "^+++" | grep -E "$pattern" || true)
    done

    local status="pass"
    local message="No TODOs in staged code"

    if [[ $count -gt 0 ]]; then
        status="warn"
        message="Found $count TODO/FIXME comment(s)"
        # TODOs are warning, not failure (project decision)
    fi

    # Format locations array
    local locations_json="[]"
    if [[ ${#locations[@]} -gt 0 ]]; then
        locations_json="[$(IFS=,; echo "${locations[*]}")]"
    fi

    echo "{\"status\": \"$status\", \"message\": \"$message\", \"count\": $count, \"locations\": $locations_json}"
}

################################################################################
# Check for merge conflict markers
################################################################################
check_merge_markers() {
    local count=0
    local locations=()

    # Get staged files
    local staged_files
    staged_files=$(git diff --cached --name-only --diff-filter=ACM || true)

    if [[ -n "$staged_files" ]]; then
        # Search for conflict markers in staged files
        while IFS= read -r file; do
            if [[ -f "$file" ]]; then
                local markers
                markers=$(grep -n -E '^(<<<<<<<|=======|>>>>>>>)' "$file" || true)
                if [[ -n "$markers" ]]; then
                    while IFS= read -r marker; do
                        ((count++))
                        locations+=("\"$file:$marker\"")
                    done <<< "$markers"
                fi
            fi
        done <<< "$staged_files"
    fi

    local status="pass"
    local message="No merge markers found"

    if [[ $count -gt 0 ]]; then
        status="fail"
        message="Found $count merge conflict marker(s)"
        OVERALL_STATUS="fail"
    fi

    # Format locations array
    local locations_json="[]"
    if [[ ${#locations[@]} -gt 0 ]]; then
        locations_json="[$(IFS=,; echo "${locations[*]}")]"
    fi

    echo "{\"status\": \"$status\", \"message\": \"$message\", \"count\": $count, \"locations\": $locations_json}"
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

    # Check if there are staged changes
    if ! git diff --cached --quiet 2>/dev/null; then
        : # Has staged changes, continue
    else
        echo "{\"error\": \"No staged changes to validate\"}"
        exit 2
    fi

    # Run all checks
    local tests_result
    local lint_result
    local debug_result
    local todos_result
    local markers_result

    tests_result=$(check_tests)
    lint_result=$(check_lint)
    debug_result=$(check_debug_code)
    todos_result=$(check_todos)
    markers_result=$(check_merge_markers)

    # Build JSON output
    cat <<EOF
{
  "status": "$OVERALL_STATUS",
  "quick_mode": $([[ "$QUICK_MODE" == "true" ]] && echo "true" || echo "false"),
  "checks": {
    "tests": $tests_result,
    "lint": $lint_result,
    "debug_code": $debug_result,
    "todos": $todos_result,
    "merge_markers": $markers_result
  }
}
EOF

    # Exit with appropriate code
    if [[ "$OVERALL_STATUS" == "fail" ]]; then
        exit 1
    else
        exit 0
    fi
}

# Execute main function
main "$@"
