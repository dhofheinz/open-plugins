#!/usr/bin/env bash

# ============================================================================
# Category Validator
# ============================================================================
# Purpose: Validate category against OpenPlugins approved category list
# Version: 1.0.0
# Usage: ./category-validator.sh <category> [--suggest]
# Returns: 0=valid, 1=invalid, 2=missing params
# ============================================================================

set -euo pipefail

# OpenPlugins approved categories (exactly 10)
APPROVED_CATEGORIES=(
    "development"
    "testing"
    "deployment"
    "documentation"
    "security"
    "database"
    "monitoring"
    "productivity"
    "quality"
    "collaboration"
)

# Category descriptions
declare -A CATEGORY_DESCRIPTIONS=(
    ["development"]="Code generation, scaffolding, refactoring"
    ["testing"]="Test generation, coverage, quality assurance"
    ["deployment"]="CI/CD, infrastructure, release automation"
    ["documentation"]="Docs generation, API documentation"
    ["security"]="Vulnerability scanning, secret detection"
    ["database"]="Schema design, migrations, queries"
    ["monitoring"]="Performance analysis, logging"
    ["productivity"]="Workflow automation, task management"
    ["quality"]="Linting, formatting, code review"
    ["collaboration"]="Team tools, communication"
)

# ============================================================================
# Functions
# ============================================================================

usage() {
    cat <<EOF
Usage: $0 <category> [--suggest]

Validate category against OpenPlugins approved category list.

Arguments:
  category    Category name to validate (required)
  --suggest   Show similar categories if invalid

Approved Categories (exactly 10):
  1.  development    - Code generation, scaffolding
  2.  testing        - Test generation, coverage
  3.  deployment     - CI/CD, infrastructure
  4.  documentation  - Docs generation, API docs
  5.  security       - Vulnerability scanning
  6.  database       - Schema design, migrations
  7.  monitoring     - Performance analysis
  8.  productivity   - Workflow automation
  9.  quality        - Linting, formatting
  10. collaboration  - Team tools, communication

Exit codes:
  0 - Valid category
  1 - Invalid category
  2 - Missing required parameters
EOF
    exit 2
}

# Calculate Levenshtein distance for similarity
levenshtein_distance() {
    local s1="$1"
    local s2="$2"
    local len1=${#s1}
    local len2=${#s2}

    # Simple implementation
    if [ "$s1" = "$s2" ]; then
        echo 0
        return
    fi

    # Rough approximation: count different characters
    local diff=0
    local max_len=$((len1 > len2 ? len1 : len2))

    for ((i=0; i<max_len; i++)); do
        if [ "${s1:i:1}" != "${s2:i:1}" ]; then
            ((diff++))
        fi
    done

    echo $diff
}

# Find similar categories
find_similar() {
    local category="$1"
    local suggestions=()

    # Check for common misspellings and variations
    case "${category,,}" in
        *develop*|*dev*)
            suggestions+=("development")
            ;;
        *test*)
            suggestions+=("testing")
            ;;
        *deploy*|*devops*|*ci*|*cd*)
            suggestions+=("deployment")
            ;;
        *doc*|*docs*)
            suggestions+=("documentation")
            ;;
        *secur*|*safe*)
            suggestions+=("security")
            ;;
        *data*|*db*|*sql*)
            suggestions+=("database")
            ;;
        *monitor*|*observ*|*log*)
            suggestions+=("monitoring")
            ;;
        *product*|*work*|*auto*)
            suggestions+=("productivity")
            ;;
        *qual*|*lint*|*format*)
            suggestions+=("quality")
            ;;
        *collab*|*team*|*comm*)
            suggestions+=("collaboration")
            ;;
    esac

    # If no keyword matches, use similarity
    if [ ${#suggestions[@]} -eq 0 ]; then
        # Find categories with lowest distance
        local best_dist=999
        for cat in "${APPROVED_CATEGORIES[@]}"; do
            local dist=$(levenshtein_distance "${category,,}" "$cat")
            if [ "$dist" -lt "$best_dist" ]; then
                best_dist=$dist
                suggestions=("$cat")
            elif [ "$dist" -eq "$best_dist" ]; then
                suggestions+=("$cat")
            fi
        done
    fi

    # Remove duplicates
    local unique_suggestions=($(printf "%s\n" "${suggestions[@]}" | sort -u))

    # Print suggestions
    if [ ${#unique_suggestions[@]} -gt 0 ]; then
        echo "Did you mean?"
        local count=1
        for suggestion in "${unique_suggestions[@]}"; do
            echo "  $count. $suggestion - ${CATEGORY_DESCRIPTIONS[$suggestion]}"
            ((count++))
        done
    fi
}

# List all approved categories
list_all_categories() {
    cat <<EOF

All Approved Categories:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

    local count=1
    for category in "${APPROVED_CATEGORIES[@]}"; do
        printf "%-2d. %-15s - %s\n" "$count" "$category" "${CATEGORY_DESCRIPTIONS[$category]}"
        ((count++))
    done
}

# ============================================================================
# Main
# ============================================================================

main() {
    # Check for help flag
    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        usage
    fi

    local category="$1"
    local suggest=false

    if [ $# -gt 1 ] && [ "$2" = "--suggest" ]; then
        suggest=true
    fi

    # Check if category is provided
    if [ -z "$category" ]; then
        echo "ERROR: Category cannot be empty"
        echo ""
        list_all_categories
        exit 2
    fi

    # Normalize to lowercase for comparison
    category_lower="${category,,}"

    # Check if category is in approved list
    for approved in "${APPROVED_CATEGORIES[@]}"; do
        if [ "$category_lower" = "$approved" ]; then
            echo "✅ PASS: Valid OpenPlugins category"
            echo ""
            echo "Category: $approved"
            echo "Valid: Yes"
            echo ""
            echo "Description: ${CATEGORY_DESCRIPTIONS[$approved]}"
            echo ""
            echo "Quality Score Impact: +5 points"
            echo ""
            echo "The category is approved for OpenPlugins marketplace."
            exit 0
        fi
    done

    # Category not found
    echo "❌ FAIL: Invalid category"
    echo ""
    echo "Category: $category"
    echo "Valid: No"
    echo ""
    echo "This category is not in the OpenPlugins approved list."
    echo ""

    if [ "$suggest" = true ]; then
        find_similar "$category"
        echo ""
    fi

    list_all_categories

    echo ""
    echo "Quality Score Impact: 0 points (fix to gain +5)"
    echo ""
    echo "Choose the most appropriate category from the approved list."

    exit 1
}

main "$@"
