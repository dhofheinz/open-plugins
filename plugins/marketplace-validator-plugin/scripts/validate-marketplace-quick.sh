#!/usr/bin/env bash

# ============================================================================
# Marketplace Validator Plugin - Quick Marketplace Validation
# ============================================================================
# Purpose: Fast essential checks for marketplace.json
# Version: 1.0.0
# License: MIT
# ============================================================================

set -o errexit
set -o nounset
set -o pipefail

# Get script directory and source library
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/validate-lib.sh"

# Configuration
MARKETPLACE_FILE="${1:-.claude-plugin/marketplace.json}"
CHECKS_PASSED=0
CHECKS_FAILED=0

# Quick validation
main() {
    print_header "🔍 Quick Validation: $(basename "${MARKETPLACE_FILE}")"

    # Check 1: JSON syntax
    echo -n "JSON syntax: "
    if [[ ! -f "${MARKETPLACE_FILE}" ]]; then
        echo "FAIL (file not found)"
        ((CHECKS_FAILED++))
    elif validate_json_syntax "${MARKETPLACE_FILE}"; then
        echo "PASS ✅"
        ((CHECKS_PASSED++))
    else
        echo "FAIL ❌"
        ((CHECKS_FAILED++))
    fi

    # Check 2: Required fields
    echo -n "Required fields: "
    local missing_fields=()

    if [[ -f "${MARKETPLACE_FILE}" ]] && validate_json_syntax "${MARKETPLACE_FILE}"; then
        local name owner_name description plugins

        name=$(json_get "${MARKETPLACE_FILE}" ".name")
        [[ -z "${name}" ]] && missing_fields+=("name")

        owner_name=$(json_get "${MARKETPLACE_FILE}" ".owner.name")
        [[ -z "${owner_name}" ]] && missing_fields+=("owner.name")

        description=$(json_get "${MARKETPLACE_FILE}" ".description")
        [[ -z "${description}" ]] && missing_fields+=("description")

        plugins=$(get_json_array_length "${MARKETPLACE_FILE}" ".plugins")
        [[ -z "${plugins}" ]] && missing_fields+=("plugins")

        if [[ ${#missing_fields[@]} -eq 0 ]]; then
            echo "PASS ✅"
            ((CHECKS_PASSED++))
        else
            echo "FAIL ❌"
            echo "   Missing: ${missing_fields[*]}"
            ((CHECKS_FAILED++))
        fi
    else
        echo "SKIP (invalid JSON)"
    fi

    # Check 3: Format compliance
    echo -n "Format compliance: "
    if [[ -f "${MARKETPLACE_FILE}" ]] && validate_json_syntax "${MARKETPLACE_FILE}"; then
        local format_issues=()

        local name
        name=$(json_get "${MARKETPLACE_FILE}" ".name")
        if [[ -n "${name}" ]] && ! validate_name_format "${name}"; then
            format_issues+=("name format")
        fi

        if [[ ${#format_issues[@]} -eq 0 ]]; then
            echo "PASS ✅"
            ((CHECKS_PASSED++))
        else
            echo "FAIL ❌"
            echo "   Issues: ${format_issues[*]}"
            ((CHECKS_FAILED++))
        fi
    else
        echo "SKIP (invalid JSON)"
    fi

    # Check 4: Security
    echo -n "Security check: "
    if [[ -f "${MARKETPLACE_FILE}" ]]; then
        if check_for_secrets "${MARKETPLACE_FILE}"; then
            echo "PASS ✅"
            ((CHECKS_PASSED++))
        else
            echo "FAIL ❌"
            echo "   Possible exposed secrets detected"
            ((CHECKS_FAILED++))
        fi
    else
        echo "SKIP (file not found)"
    fi

    # Summary
    echo ""
    if [[ ${CHECKS_FAILED} -eq 0 ]]; then
        print_success "Status: PASS ✅"
        echo ""
        echo "All essential checks passed. Run full validation for detailed quality assessment."
        exit 0
    else
        print_error "Status: FAIL ❌"
        echo ""
        echo "Fix critical issues above, then run full validation."
        exit 1
    fi
}

main "$@"
