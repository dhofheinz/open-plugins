#!/usr/bin/env bash

# ============================================================================
# Schema Differ Script
# ============================================================================
# Purpose: Compare configuration against reference schemas and validate plugin entries
# Version: 1.0.0
# Usage: ./schema-differ.sh <marketplace-file> [index]
# Returns: 0=all valid, 1=validation errors, 2=error
# ============================================================================

set -euo pipefail

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../scripts/validate-lib.sh"

# ====================
# Configuration
# ====================

readonly MARKETPLACE_FILE="${1:-}"
readonly INDEX="${2:-all}"

# ====================
# Plugin Entry Validation
# ====================

validate_plugin_entry() {
    local index=$1
    local entry_json=$2
    local strict=${3:-false}

    local has_errors=0
    local has_warnings=0

    # Extract fields using json_get would be complex here, so use jq/python inline
    local name version source description author keywords license

    name=$(echo "${entry_json}" | jq -r '.name // empty' 2>/dev/null || echo "")
    version=$(echo "${entry_json}" | jq -r '.version // empty' 2>/dev/null || echo "")
    source=$(echo "${entry_json}" | jq -r '.source // empty' 2>/dev/null || echo "")
    description=$(echo "${entry_json}" | jq -r '.description // empty' 2>/dev/null || echo "")
    author=$(echo "${entry_json}" | jq -r '.author // empty' 2>/dev/null || echo "")
    keywords=$(echo "${entry_json}" | jq -r '.keywords // empty' 2>/dev/null || echo "")
    license=$(echo "${entry_json}" | jq -r '.license // empty' 2>/dev/null || echo "")

    echo ""
    print_section "Entry ${index}: ${name:-<unnamed>}"

    # Required fields
    echo "  Required (3):"

    # name (required, lowercase-hyphen)
    if [[ -z "${name}" ]]; then
        print_error "  name: Missing (REQUIRED)"
        ((has_errors++))
    elif ! validate_name_format "${name}"; then
        print_error "  name: \"${name}\" - Invalid format"
        print_info "       Expected: lowercase-hyphen (my-plugin)"
        ((has_errors++))
    else
        print_success "  name: \"${name}\""
    fi

    # source (required, valid format)
    if [[ -z "${source}" ]]; then
        print_error "  source: Missing (REQUIRED)"
        ((has_errors++))
    elif ! validate_source_format "${source}"; then
        print_error "  source: \"${source}\" - Invalid format"
        print_info "       Valid: ./path, github:user/repo, https://url"
        ((has_errors++))
    else
        print_success "  source: \"${source}\""
    fi

    # description (required, non-empty)
    if [[ -z "${description}" ]]; then
        print_error "  description: Missing (REQUIRED)"
        ((has_errors++))
    else
        # Truncate for display
        local desc_display="${description}"
        if [[ ${#description} -gt 50 ]]; then
            desc_display="${description:0:47}..."
        fi
        print_success "  description: \"${desc_display}\""
    fi

    echo ""
    echo "  Recommended (4):"

    # version (recommended, semver)
    if [[ -z "${version}" ]]; then
        print_warning "  version: Missing"
        ((has_warnings++))
    elif ! validate_semver "${version}"; then
        print_warning "  version: \"${version}\" - Invalid semver"
        ((has_warnings++))
    else
        print_success "  version: \"${version}\""
    fi

    # author (recommended)
    if [[ -z "${author}" || "${author}" == "null" ]]; then
        print_warning "  author: Missing"
        ((has_warnings++))
    else
        print_success "  author: Present"
    fi

    # keywords (recommended)
    if [[ -z "${keywords}" || "${keywords}" == "null" || "${keywords}" == "[]" ]]; then
        print_warning "  keywords: Missing"
        ((has_warnings++))
    else
        local keyword_count
        keyword_count=$(echo "${entry_json}" | jq '.keywords | length' 2>/dev/null || echo "0")
        print_success "  keywords: ${keyword_count} items"
    fi

    # license (recommended, SPDX)
    if [[ -z "${license}" ]]; then
        print_warning "  license: Missing"
        ((has_warnings++))
    elif ! validate_license "${license}"; then
        print_warning "  license: \"${license}\" - Unknown SPDX identifier"
        ((has_warnings++))
    else
        print_success "  license: \"${license}\""
    fi

    # Entry status
    echo ""
    if [[ ${has_errors} -eq 0 ]]; then
        if [[ ${has_warnings} -eq 0 ]]; then
            print_success "Status: PASS (no issues)"
        else
            print_info "Status: PASS with ${has_warnings} warning(s)"
        fi
        return 0
    else
        print_error "Status: FAIL (${has_errors} critical issues, ${has_warnings} warnings)"
        return 1
    fi
}

# ====================
# Main Logic
# ====================

main() {
    # Validate arguments
    if [[ -z "${MARKETPLACE_FILE}" ]]; then
        print_error "Usage: $0 <marketplace-file> [index]"
        exit 2
    fi

    if [[ ! -f "${MARKETPLACE_FILE}" ]]; then
        print_error "Marketplace file not found: ${MARKETPLACE_FILE}"
        exit 2
    fi

    # Validate JSON syntax
    if ! validate_json_syntax "${MARKETPLACE_FILE}"; then
        print_error "Invalid JSON in ${MARKETPLACE_FILE}"
        print_info "Run JSON validation first to fix syntax errors"
        exit 2
    fi

    # Print header
    print_header "Plugin Entries Validation"
    echo "Marketplace: ${MARKETPLACE_FILE}"
    echo ""

    # Get plugins array length
    local plugin_count
    plugin_count=$(get_json_array_length "${MARKETPLACE_FILE}" ".plugins")

    if [[ ${plugin_count} -eq 0 ]]; then
        print_warning "No plugin entries found in marketplace"
        print_info "The plugins array is empty"
        exit 0
    fi

    echo "Total Entries: ${plugin_count}"

    # Determine which entries to validate
    local entries_to_check=()
    if [[ "${INDEX}" == "all" ]]; then
        for ((i=0; i<plugin_count; i++)); do
            entries_to_check+=("$i")
        done
    elif [[ "${INDEX}" =~ ^[0-9]+$ ]]; then
        if [[ ${INDEX} -ge ${plugin_count} ]]; then
            print_error "Invalid index: ${INDEX} (valid range: 0-$((plugin_count-1)))"
            exit 2
        fi
        entries_to_check=("${INDEX}")
    else
        print_error "Invalid index: ${INDEX} (must be number or 'all')"
        exit 2
    fi

    # Validate each entry
    local failed_count=0
    local total_errors=0
    local total_warnings=0

    for idx in "${entries_to_check[@]}"; do
        # Extract plugin entry
        local entry_json
        if command -v jq &> /dev/null; then
            entry_json=$(jq ".plugins[${idx}]" "${MARKETPLACE_FILE}" 2>/dev/null)
        else
            # Fallback to python
            entry_json=$(python3 <<EOF 2>/dev/null
import json
with open('${MARKETPLACE_FILE}') as f:
    data = json.load(f)
    print(json.dumps(data['plugins'][${idx}]))
EOF
)
        fi

        # Validate entry
        if ! validate_plugin_entry "${idx}" "${entry_json}" "false"; then
            ((failed_count++))
        fi
    done

    # Summary
    echo ""
    print_header "Summary"

    local passed_count=$((${#entries_to_check[@]} - failed_count))
    local pass_percentage=$((passed_count * 100 / ${#entries_to_check[@]}))

    echo "Total Entries: ${#entries_to_check[@]}"
    if [[ ${passed_count} -gt 0 ]]; then
        print_success "Passed: ${passed_count} (${pass_percentage}%)"
    fi

    if [[ ${failed_count} -gt 0 ]]; then
        print_error "Failed: ${failed_count} ($((100 - pass_percentage))%)"
    fi

    echo ""

    if [[ ${failed_count} -eq 0 ]]; then
        print_header "✅ PASS: All plugin entries valid"
        exit 0
    else
        print_header "❌ FAIL: ${failed_count} plugin entries have errors"
        echo ""
        print_info "Action Required:"
        echo "  Fix validation errors in plugin entries"
        echo "  Ensure all required fields are present"
        echo "  Use correct formats for names, versions, and sources"
        exit 1
    fi
}

main "$@"
