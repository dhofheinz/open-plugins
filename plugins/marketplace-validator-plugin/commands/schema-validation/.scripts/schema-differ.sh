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

    # Extract fields. Note: `source` may be a string OR an object, so we
    # extract raw JSON for source and detect the type at validation time.
    local name version source source_type description author keywords license

    name=$(echo "${entry_json}" | jq -r '.name // empty' 2>/dev/null || echo "")
    version=$(echo "${entry_json}" | jq -r '.version // empty' 2>/dev/null || echo "")
    source=$(echo "${entry_json}" | jq -c '.source // empty' 2>/dev/null || echo "")
    source_type=$(echo "${entry_json}" | jq -r '.source | type' 2>/dev/null || echo "null")
    description=$(echo "${entry_json}" | jq -r '.description // empty' 2>/dev/null || echo "")
    author=$(echo "${entry_json}" | jq -r '.author // empty' 2>/dev/null || echo "")
    keywords=$(echo "${entry_json}" | jq -r '.keywords // empty' 2>/dev/null || echo "")
    license=$(echo "${entry_json}" | jq -r '.license // empty' 2>/dev/null || echo "")

    echo ""
    print_section "Entry ${index}: ${name:-<unnamed>}"

    # Required fields (per plugin-marketplaces spec: name + source only)
    echo "  Required (2):"

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

    # source (required, string relative path OR object with valid source type)
    if [[ -z "${source}" || "${source_type}" == "null" ]]; then
        print_error "  source: Missing (REQUIRED)"
        ((has_errors++))
    elif [[ "${source_type}" == "string" ]]; then
        # Strip surrounding quotes from jq -c output
        local source_str="${source%\"}"
        source_str="${source_str#\"}"
        if [[ "${source_str}" == ./* ]]; then
            print_success "  source: \"${source_str}\" (relative path)"
        elif [[ "${source_str}" == github:* ]]; then
            print_warning "  source: \"${source_str}\" - legacy github: shorthand"
            print_info "       Migrate to: {\"source\": \"github\", \"repo\": \"owner/repo\"}"
            ((has_warnings++))
        elif [[ "${source_str}" =~ ^https?:// ]]; then
            print_warning "  source: \"${source_str}\" - legacy URL string"
            print_info "       Migrate to: {\"source\": \"url\", \"url\": \"...\"}"
            ((has_warnings++))
        else
            print_error "  source: \"${source_str}\" - Invalid format"
            print_info "       Valid string: ./relative/path"
            print_info "       Valid object: {\"source\": \"github\"|\"url\"|\"git-subdir\"|\"npm\", ...}"
            ((has_errors++))
        fi
    elif [[ "${source_type}" == "object" ]]; then
        if ! validate_source_object "${source}"; then
            print_error "  source: Invalid source object"
            ((has_errors++))
        else
            local src_kind
            src_kind=$(echo "${source}" | jq -r '.source // empty' 2>/dev/null || echo "")
            print_success "  source: ${src_kind} object"
        fi
    else
        print_error "  source: Invalid type '${source_type}' (must be string or object)"
        ((has_errors++))
    fi

    echo ""
    echo "  Recommended (5):"

    # description (recommended but strongly encouraged)
    if [[ -z "${description}" ]]; then
        print_warning "  description: Missing"
        ((has_warnings++))
    else
        local desc_display="${description}"
        if [[ ${#description} -gt 50 ]]; then
            desc_display="${description:0:47}..."
        fi
        print_success "  description: \"${desc_display}\""
    fi

    # version (recommended, semver; can also live in plugin.json)
    if [[ -z "${version}" ]]; then
        print_warning "  version: Missing (can be set in plugin.json instead)"
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
