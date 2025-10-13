#!/usr/bin/env bash

# ============================================================================
# Issue Prioritization Script
# ============================================================================
# Purpose: Categorize and prioritize validation issues into P0/P1/P2 tiers
# Version: 1.0.0
# Usage: ./issue-prioritizer.sh <issues-json-file> [criteria]
# Returns: 0=success, 1=error
# Dependencies: jq, bash 4.0+
# ============================================================================

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Priority definitions
declare -A PRIORITY_NAMES=(
    [0]="Critical - Must Fix"
    [1]="Important - Should Fix"
    [2]="Recommended - Nice to Have"
)

declare -A PRIORITY_ICONS=(
    [0]="❌"
    [1]="⚠️ "
    [2]="💡"
)

# Effort labels
declare -A EFFORT_LABELS=(
    [low]="Low"
    [medium]="Medium"
    [high]="High"
)

# Effort time estimates
declare -A EFFORT_TIMES=(
    [low]="5-15 minutes"
    [medium]="30-60 minutes"
    [high]="2+ hours"
)

# ============================================================================
# Functions
# ============================================================================

usage() {
    cat <<EOF
Usage: $0 <issues-json-file> [criteria]

Arguments:
  issues-json-file    Path to JSON file with validation issues
  criteria           Prioritization criteria: severity|impact|effort (default: severity)

Examples:
  $0 validation-results.json
  $0 results.json impact
  $0 results.json severity

JSON Structure:
{
  "errors": [{"type": "...", "severity": "critical", ...}],
  "warnings": [{"type": "...", "severity": "important", ...}],
  "recommendations": [{"type": "...", "severity": "recommended", ...}]
}
EOF
    exit 1
}

check_dependencies() {
    local missing_deps=()

    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Error: Missing dependencies: ${missing_deps[*]}" >&2
        echo "Install with: sudo apt-get install ${missing_deps[*]}" >&2
        return 1
    fi

    return 0
}

determine_priority() {
    local severity="$1"
    local type="$2"

    # P0 (Critical) - Blocking issues
    if [[ "$severity" == "critical" ]] || \
       [[ "$type" =~ ^(missing_required|invalid_json|security_vulnerability|format_violation)$ ]]; then
        echo "0"
        return
    fi

    # P1 (Important) - Should fix
    if [[ "$severity" == "important" ]] || \
       [[ "$type" =~ ^(missing_recommended|documentation_gap|convention_violation|performance)$ ]]; then
        echo "1"
        return
    fi

    # P2 (Recommended) - Nice to have
    echo "2"
}

get_effort_estimate() {
    local type="$1"

    # High effort
    if [[ "$type" =~ ^(security_vulnerability|performance|architecture)$ ]]; then
        echo "high"
        return
    fi

    # Medium effort
    if [[ "$type" =~ ^(documentation_gap|convention_violation|missing_recommended)$ ]]; then
        echo "medium"
        return
    fi

    # Low effort (default)
    echo "low"
}

format_issue() {
    local priority="$1"
    local message="$2"
    local impact="${3:-Unknown impact}"
    local effort="${4:-low}"
    local fix="${5:-No fix suggestion available}"

    local icon="${PRIORITY_ICONS[$priority]}"
    local effort_label="${EFFORT_LABELS[$effort]}"
    local effort_time="${EFFORT_TIMES[$effort]}"

    cat <<EOF
${icon} ${message}
   Impact: ${impact}
   Effort: ${effort_label} (${effort_time})
   Fix: ${fix}

EOF
}

process_issues() {
    local json_file="$1"
    local criteria="${2:-severity}"

    # Validate JSON file exists
    if [[ ! -f "$json_file" ]]; then
        echo "Error: File not found: $json_file" >&2
        return 1
    fi

    # Validate JSON syntax
    if ! jq empty "$json_file" 2>/dev/null; then
        echo "Error: Invalid JSON in $json_file" >&2
        return 1
    fi

    # Count total issues
    local total_errors=$(jq '.errors // [] | length' "$json_file")
    local total_warnings=$(jq '.warnings // [] | length' "$json_file")
    local total_recommendations=$(jq '.recommendations // [] | length' "$json_file")
    local total_issues=$((total_errors + total_warnings + total_recommendations))

    if [[ $total_issues -eq 0 ]]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "ISSUE PRIORITIZATION"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "No issues found! Quality score is perfect."
        return 0
    fi

    # Initialize priority counters
    declare -A priority_counts=([0]=0 [1]=0 [2]=0)
    declare -A priority_issues=([0]="" [1]="" [2]="")

    # Process errors
    while IFS= read -r issue; do
        local type=$(echo "$issue" | jq -r '.type // "unknown"')
        local severity=$(echo "$issue" | jq -r '.severity // "critical"')
        local message=$(echo "$issue" | jq -r '.message // "Unknown error"')
        local impact=$(echo "$issue" | jq -r '.impact // "Unknown impact"')
        local fix=$(echo "$issue" | jq -r '.fix // "No fix available"')
        local score_impact=$(echo "$issue" | jq -r '.score_impact // 0')

        local priority=$(determine_priority "$severity" "$type")
        local effort=$(get_effort_estimate "$type")

        priority_counts[$priority]=$((priority_counts[$priority] + 1))

        local formatted_issue=$(format_issue "$priority" "$message" "$impact" "$effort" "$fix")
        priority_issues[$priority]+="$formatted_issue"
    done < <(jq -c '.errors // [] | .[]' "$json_file")

    # Process warnings
    while IFS= read -r issue; do
        local type=$(echo "$issue" | jq -r '.type // "unknown"')
        local severity=$(echo "$issue" | jq -r '.severity // "important"')
        local message=$(echo "$issue" | jq -r '.message // "Unknown warning"')
        local impact=$(echo "$issue" | jq -r '.impact // "Unknown impact"')
        local fix=$(echo "$issue" | jq -r '.fix // "No fix available"')

        local priority=$(determine_priority "$severity" "$type")
        local effort=$(get_effort_estimate "$type")

        priority_counts[$priority]=$((priority_counts[$priority] + 1))

        local formatted_issue=$(format_issue "$priority" "$message" "$impact" "$effort" "$fix")
        priority_issues[$priority]+="$formatted_issue"
    done < <(jq -c '.warnings // [] | .[]' "$json_file")

    # Process recommendations
    while IFS= read -r issue; do
        local type=$(echo "$issue" | jq -r '.type // "unknown"')
        local severity=$(echo "$issue" | jq -r '.severity // "recommended"')
        local message=$(echo "$issue" | jq -r '.message // "Recommendation"')
        local impact=$(echo "$issue" | jq -r '.impact // "Minor quality improvement"')
        local fix=$(echo "$issue" | jq -r '.fix // "No fix available"')

        local priority=$(determine_priority "$severity" "$type")
        local effort=$(get_effort_estimate "$type")

        priority_counts[$priority]=$((priority_counts[$priority] + 1))

        local formatted_issue=$(format_issue "$priority" "$message" "$impact" "$effort" "$fix")
        priority_issues[$priority]+="$formatted_issue"
    done < <(jq -c '.recommendations // [] | .[]' "$json_file")

    # Display results
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ISSUE PRIORITIZATION"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Total Issues: $total_issues"
    echo ""

    # Display each priority tier
    for priority in 0 1 2; do
        local count=${priority_counts[$priority]}
        local name="${PRIORITY_NAMES[$priority]}"

        if [[ $count -gt 0 ]]; then
            echo "Priority $priority ($name): $count"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo -e "${priority_issues[$priority]}"
        fi
    done

    # Summary
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Summary:"
    echo "- Fix P0 issues first (blocking publication)"
    echo "- Address P1 issues for quality improvement"
    echo "- Consider P2 improvements for excellence"

    if [[ ${priority_counts[0]} -gt 0 ]]; then
        echo ""
        echo "⚠️  WARNING: ${priority_counts[0]} blocking issue(s) must be fixed before publication"
    fi

    return 0
}

# ============================================================================
# Main
# ============================================================================

main() {
    # Check arguments
    if [[ $# -lt 1 ]]; then
        usage
    fi

    local json_file="$1"
    local criteria="${2:-severity}"

    # Check dependencies
    if ! check_dependencies; then
        return 1
    fi

    # Validate criteria
    if [[ ! "$criteria" =~ ^(severity|impact|effort)$ ]]; then
        echo "Error: Invalid criteria '$criteria'. Use: severity|impact|effort" >&2
        return 1
    fi

    # Process issues
    process_issues "$json_file" "$criteria"

    return 0
}

main "$@"
