#!/usr/bin/env bash

# ============================================================================
# Marketplace Validator Plugin - Quick Plugin Validation
# ============================================================================
# Purpose: Fast essential checks for plugin
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
PLUGIN_DIR="${1:-.}"
PLUGIN_FILE="${PLUGIN_DIR}/.claude-plugin/plugin.json"
CHECKS_PASSED=0
CHECKS_FAILED=0

# Quick validation
main() {
    print_header "🔍 Quick Validation: $(basename "${PLUGIN_DIR}")"

    # Check 1: Plugin structure
    echo -n "Plugin structure: "
    if [[ -f "${PLUGIN_FILE}" ]]; then
        echo "PASS ✅"
        ((CHECKS_PASSED++))
    else
        echo "FAIL ❌"
        echo "   .claude-plugin/plugin.json not found"
        ((CHECKS_FAILED++))
    fi

    # Check 2: JSON syntax
    echo -n "JSON syntax: "
    if [[ -f "${PLUGIN_FILE}" ]]; then
        if validate_json_syntax "${PLUGIN_FILE}"; then
            echo "PASS ✅"
            ((CHECKS_PASSED++))
        else
            echo "FAIL ❌"
            ((CHECKS_FAILED++))
        fi
    else
        echo "SKIP (file not found)"
    fi

    # Check 3: Required fields
    echo -n "Required fields: "
    local missing_fields=()

    if [[ -f "${PLUGIN_FILE}" ]] && validate_json_syntax "${PLUGIN_FILE}"; then
        local name version description author license

        name=$(json_get "${PLUGIN_FILE}" ".name")
        [[ -z "${name}" ]] && missing_fields+=("name")

        version=$(json_get "${PLUGIN_FILE}" ".version")
        [[ -z "${version}" ]] && missing_fields+=("version")

        description=$(json_get "${PLUGIN_FILE}" ".description")
        [[ -z "${description}" ]] && missing_fields+=("description")

        author=$(json_get "${PLUGIN_FILE}" ".author")
        [[ -z "${author}" ]] && missing_fields+=("author")

        license=$(json_get "${PLUGIN_FILE}" ".license")
        [[ -z "${license}" ]] && missing_fields+=("license")

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

    # Check 4: Format compliance
    echo -n "Format compliance: "
    if [[ -f "${PLUGIN_FILE}" ]] && validate_json_syntax "${PLUGIN_FILE}"; then
        local format_issues=()

        local name version
        name=$(json_get "${PLUGIN_FILE}" ".name")
        version=$(json_get "${PLUGIN_FILE}" ".version")

        if [[ -n "${name}" ]] && ! validate_name_format "${name}"; then
            format_issues+=("name format")
        fi

        if [[ -n "${version}" ]] && ! validate_semver "${version}"; then
            format_issues+=("version format")
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

    # Check 5: Security
    echo -n "Security check: "
    local security_issues=()

    if [[ -f "${PLUGIN_FILE}" ]]; then
        if ! check_for_secrets "${PLUGIN_FILE}"; then
            security_issues+=("secrets in plugin.json")
        fi
    fi

    if [[ -f "${PLUGIN_DIR}/.env" ]]; then
        security_issues+=(".env file found")
    fi

    if [[ ${#security_issues[@]} -eq 0 ]]; then
        echo "PASS ✅"
        ((CHECKS_PASSED++))
    else
        echo "FAIL ❌"
        echo "   Issues: ${security_issues[*]}"
        ((CHECKS_FAILED++))
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
