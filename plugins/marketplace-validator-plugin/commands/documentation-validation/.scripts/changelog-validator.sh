#!/usr/bin/env bash

# ============================================================================
# CHANGELOG Validator
# ============================================================================
# Purpose: Validate CHANGELOG.md format compliance (Keep a Changelog)
# Version: 1.0.0
# Usage: ./changelog-validator.sh <changelog-path> [--strict] [--json]
# Returns: 0=success, 1=error, JSON output to stdout if --json
# ============================================================================

set -euo pipefail

# Default values
STRICT_MODE=false
JSON_OUTPUT=false
REQUIRE_UNRELEASED=true

# Valid change categories per Keep a Changelog
VALID_CATEGORIES=("Added" "Changed" "Deprecated" "Removed" "Fixed" "Security")

# Parse arguments
CHANGELOG_PATH="${1:-CHANGELOG.md}"
shift || true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --strict)
            STRICT_MODE=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --no-unreleased)
            REQUIRE_UNRELEASED=false
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Initialize results
declare -a issues=()
declare -a version_entries=()
declare -a categories_used=()
has_title=false
has_unreleased=false
compliance_score=100

# Check if file exists
if [[ ! -f "$CHANGELOG_PATH" ]]; then
    if $JSON_OUTPUT; then
        cat <<EOF
{
  "error": "CHANGELOG not found",
  "path": "$CHANGELOG_PATH",
  "present": false,
  "score": 0,
  "status": "warning",
  "issues": ["CHANGELOG.md not found"]
}
EOF
    else
        echo "⚠️  WARNING: CHANGELOG not found at $CHANGELOG_PATH"
        echo "CHANGELOG is recommended but not required for initial submission."
    fi
    exit 1
fi

# Read content
content=$(<"$CHANGELOG_PATH")

# Check for title
if echo "$content" | grep -qiE "^#\s*(changelog|change.?log)"; then
    has_title=true
else
    issues+=("Missing title 'Changelog' or 'Change Log'")
    ((compliance_score-=10)) || true
fi

# Check for Unreleased section
if echo "$content" | grep -qE "^##\s*\[Unreleased\]"; then
    has_unreleased=true
else
    if $REQUIRE_UNRELEASED; then
        issues+=("Missing [Unreleased] section")
        ((compliance_score-=15)) || true
    fi
fi

# Extract version headers
while IFS= read -r line; do
    if [[ $line =~ ^##[[:space:]]*\[([0-9]+\.[0-9]+\.[0-9]+)\][[:space:]]*-[[:space:]]*([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
        version="${BASH_REMATCH[1]}"
        date="${BASH_REMATCH[2]}"
        version_entries+=("$version|$date")
    elif [[ $line =~ ^##[[:space:]]*\[?([0-9]+\.[0-9]+\.[0-9]+)\]? ]] && [[ ! $line =~ \[Unreleased\] ]]; then
        # Invalid format detected
        issues+=("Invalid version header format: '$line' (should be '## [X.Y.Z] - YYYY-MM-DD')")
        ((compliance_score-=10)) || true
    fi
done <<< "$content"

# Check for valid change categories
for category in "${VALID_CATEGORIES[@]}"; do
    if echo "$content" | grep -qE "^###[[:space:]]*$category"; then
        categories_used+=("$category")
    fi
done

# Detect invalid categories
while IFS= read -r line; do
    if [[ $line =~ ^###[[:space:]]+(.*) ]]; then
        cat_name="${BASH_REMATCH[1]}"
        is_valid=false
        for valid_cat in "${VALID_CATEGORIES[@]}"; do
            if [[ "$cat_name" == "$valid_cat" ]]; then
                is_valid=true
                break
            fi
        done

        if ! $is_valid; then
            issues+=("Non-standard category: '###  $cat_name' (should be one of: ${VALID_CATEGORIES[*]})")
            ((compliance_score-=5)) || true
        fi
    fi
done <<< "$content"

# Check date formats in version headers
for entry in "${version_entries[@]}"; do
    date_part="${entry#*|}"
    if [[ ! $date_part =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        issues+=("Invalid date format in version entry: $date_part (should be YYYY-MM-DD)")
        ((compliance_score-=5)) || true
    fi
done

# Ensure score doesn't go negative
if ((compliance_score < 0)); then
    compliance_score=0
fi

# Determine status
status="pass"
if ((compliance_score < 60)); then
    status="fail"
elif ((compliance_score < 80)); then
    status="warning"
fi

# Output results
if $JSON_OUTPUT; then
    # Build JSON output
    cat <<EOF
{
  "present": true,
  "path": "$CHANGELOG_PATH",
  "has_title": $has_title,
  "has_unreleased": $has_unreleased,
  "version_count": ${#version_entries[@]},
  "version_entries": [
$(IFS=,; for entry in "${version_entries[@]}"; do
    version="${entry%|*}"
    date="${entry#*|}"
    echo "    {\"version\": \"$version\", \"date\": \"$date\"}"
done | paste -sd, -)
  ],
  "categories_used": [
$(IFS=,; for cat in "${categories_used[@]}"; do
    echo "    \"$cat\""
done | paste -sd, -)
  ],
  "compliance_score": $compliance_score,
  "status": "$status",
  "issues": [
$(IFS=,; for issue in "${issues[@]}"; do
    # Escape quotes in issue text
    escaped_issue="${issue//\"/\\\"}"
    echo "    \"$escaped_issue\""
done | paste -sd, -)
  ]
}
EOF
else
    # Human-readable output
    echo ""
    echo "CHANGELOG Validation Results"
    echo "========================================"
    echo "File: $CHANGELOG_PATH"
    echo "Compliance Score: $compliance_score/100"
    echo ""

    if $has_title; then
        echo "✓ Title present"
    else
        echo "✗ Title missing"
    fi

    if $has_unreleased; then
        echo "✓ [Unreleased] section present"
    else
        if $REQUIRE_UNRELEASED; then
            echo "✗ [Unreleased] section missing"
        else
            echo "⚠  [Unreleased] section missing (not required)"
        fi
    fi

    echo ""
    echo "Version Entries: ${#version_entries[@]}"
    for entry in "${version_entries[@]}"; do
        version="${entry%|*}"
        date="${entry#*|}"
        echo "  • [$version] - $date"
    done

    if [[ ${#categories_used[@]} -gt 0 ]]; then
        echo ""
        echo "Change Categories Used:"
        for cat in "${categories_used[@]}"; do
            echo "  • $cat"
        done
    fi

    if [[ ${#issues[@]} -gt 0 ]]; then
        echo ""
        echo "Issues Found: ${#issues[@]}"
        for issue in "${issues[@]}"; do
            echo "  ✗ $issue"
        done
    fi

    echo ""
    if [[ "$status" == "pass" ]]; then
        echo "Overall: ✓ PASS"
    elif [[ "$status" == "warning" ]]; then
        echo "Overall: ⚠  WARNINGS"
    else
        echo "Overall: ✗ FAIL"
    fi
    echo ""
fi

# Exit with appropriate code
if [[ "$status" == "fail" ]]; then
    exit 1
else
    exit 0
fi
