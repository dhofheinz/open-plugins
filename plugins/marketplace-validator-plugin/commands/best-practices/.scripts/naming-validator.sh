#!/usr/bin/env bash

# ============================================================================
# Naming Convention Validator
# ============================================================================
# Purpose: Validate plugin names against OpenPlugins lowercase-hyphen convention
# Version: 1.0.0
# Usage: ./naming-validator.sh <name> [--suggest]
# Returns: 0=valid, 1=invalid, 2=missing params
# ============================================================================

set -euo pipefail

# OpenPlugins naming pattern
NAMING_PATTERN='^[a-z0-9]+(-[a-z0-9]+)*$'

# Generic terms to avoid
GENERIC_TERMS=("plugin" "tool" "utility" "helper" "app" "code" "software")

# ============================================================================
# Functions
# ============================================================================

usage() {
    cat <<EOF
Usage: $0 <name> [--suggest]

Validate plugin name against OpenPlugins naming convention.

Arguments:
  name        Plugin name to validate (required)
  --suggest   Auto-suggest corrected name if invalid

Pattern: ^[a-z0-9]+(-[a-z0-9]+)*$

Valid examples:
  - code-formatter
  - test-runner
  - api-client

Invalid examples:
  - Code-Formatter (uppercase)
  - test_runner (underscore)
  - -helper (leading hyphen)

Exit codes:
  0 - Valid naming convention
  1 - Invalid naming convention
  2 - Missing required parameters
EOF
    exit 2
}

# Convert to lowercase-hyphen format
suggest_correction() {
    local name="$1"
    local corrected="$name"

    # Convert to lowercase
    corrected="${corrected,,}"

    # Replace underscores with hyphens
    corrected="${corrected//_/-}"

    # Replace spaces with hyphens
    corrected="${corrected// /-}"

    # Remove non-alphanumeric except hyphens
    corrected="$(echo "$corrected" | sed 's/[^a-z0-9-]//g')"

    # Remove leading/trailing hyphens
    corrected="$(echo "$corrected" | sed 's/^-*//;s/-*$//')"

    # Replace multiple consecutive hyphens with single
    corrected="$(echo "$corrected" | sed 's/-\+/-/g')"

    echo "$corrected"
}

# Check for generic terms
check_generic_terms() {
    local name="$1"
    local found_generic=()

    for term in "${GENERIC_TERMS[@]}"; do
        if [[ "$name" == "$term" ]] || [[ "$name" == *"-$term" ]] || [[ "$name" == "$term-"* ]] || [[ "$name" == *"-$term-"* ]]; then
            found_generic+=("$term")
        fi
    done

    if [ ${#found_generic[@]} -gt 0 ]; then
        echo "Warning: Contains generic term(s): ${found_generic[*]}"
        return 1
    fi
    return 0
}

# Find specific issues in the name
find_issues() {
    local name="$1"
    local issues=()

    # Check for uppercase
    if [[ "$name" =~ [A-Z] ]]; then
        local uppercase=$(echo "$name" | grep -o '[A-Z]' | tr '\n' ',' | sed 's/,$//')
        issues+=("Contains uppercase characters: $uppercase")
    fi

    # Check for underscores
    if [[ "$name" =~ _ ]]; then
        issues+=("Contains underscores instead of hyphens")
    fi

    # Check for spaces
    if [[ "$name" =~ \  ]]; then
        issues+=("Contains spaces")
    fi

    # Check for leading hyphen
    if [[ "$name" =~ ^- ]]; then
        issues+=("Starts with hyphen")
    fi

    # Check for trailing hyphen
    if [[ "$name" =~ -$ ]]; then
        issues+=("Ends with hyphen")
    fi

    # Check for consecutive hyphens
    if [[ "$name" =~ -- ]]; then
        issues+=("Contains consecutive hyphens")
    fi

    # Check for special characters
    if [[ "$name" =~ [^a-zA-Z0-9_\ -] ]]; then
        issues+=("Contains special characters")
    fi

    # Check for empty or too short
    if [ ${#name} -eq 0 ]; then
        issues+=("Name is empty")
    elif [ ${#name} -eq 1 ]; then
        issues+=("Name is too short (single character)")
    fi

    # Print issues
    if [ ${#issues[@]} -gt 0 ]; then
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
        return 1
    fi
    return 0
}

# ============================================================================
# Main
# ============================================================================

main() {
    # Check for help flag
    if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        usage
    fi

    local name="$1"
    local suggest=false

    if [ $# -gt 1 ] && [ "$2" = "--suggest" ]; then
        suggest=true
    fi

    # Check if name is provided
    if [ -z "$name" ]; then
        echo "ERROR: Name cannot be empty"
        exit 2
    fi

    # Validate against pattern
    if [[ "$name" =~ $NAMING_PATTERN ]]; then
        echo "✅ PASS: Valid naming convention"
        echo "Name: $name"
        echo "Format: lowercase-hyphen"

        # Check for generic terms (warning only)
        if ! check_generic_terms "$name"; then
            echo ""
            echo "Recommendation: Use more descriptive, functionality-specific names"
        fi

        exit 0
    else
        echo "❌ FAIL: Invalid naming convention"
        echo "Name: $name"
        echo ""
        echo "Issues Found:"
        find_issues "$name"

        if [ "$suggest" = true ]; then
            local correction=$(suggest_correction "$name")
            echo ""
            echo "Suggested Correction: $correction"

            # Validate the suggestion
            if [[ "$correction" =~ $NAMING_PATTERN ]]; then
                echo "✓ Suggestion is valid"
            else
                echo "⚠ Manual correction may be needed"
            fi
        fi

        echo ""
        echo "Required Pattern: ^[a-z0-9]+(-[a-z0-9]+)*$"
        echo ""
        echo "Valid Examples:"
        echo "  - code-formatter"
        echo "  - test-runner"
        echo "  - api-client"

        exit 1
    fi
}

main "$@"
