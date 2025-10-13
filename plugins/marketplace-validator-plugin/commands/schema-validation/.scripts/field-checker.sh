#!/usr/bin/env bash

# ============================================================================
# Field Checker Script
# ============================================================================
# Purpose: Verify required and recommended fields in plugin/marketplace configs
# Version: 1.0.0
# Usage: ./field-checker.sh <config-file> <type> [strict]
# Returns: 0=all required present, 1=missing required, 2=error
# ============================================================================

set -euo pipefail

# Source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../../scripts/validate-lib.sh"

# ====================
# Configuration
# ====================

readonly CONFIG_FILE="${1:-}"
readonly TYPE="${2:-}"
readonly STRICT="${3:-false}"

# ====================
# Field Definitions
# ====================

# Plugin required fields
PLUGIN_REQUIRED_FIELDS=(
    "name"
    "version"
    "description"
    "author"
    "license"
)

# Plugin recommended fields
PLUGIN_RECOMMENDED_FIELDS=(
    "repository"
    "homepage"
    "keywords"
    "category"
)

# Marketplace required fields
MARKETPLACE_REQUIRED_FIELDS=(
    "name"
    "owner"
    "owner.name"
    "owner.email"
    "plugins"
)

# Marketplace recommended fields
MARKETPLACE_RECOMMENDED_FIELDS=(
    "version"
    "metadata.description"
    "metadata.homepage"
    "metadata.repository"
)

# ====================
# Validation Functions
# ====================

check_field_exists() {
    local file="$1"
    local field="$2"
    local value

    # Use json_get from validate-lib.sh
    value=$(json_get "${file}" ".${field}")

    if [[ -n "${value}" && "${value}" != "null" ]]; then
        return 0
    else
        return 1
    fi
}

get_field_value() {
    local file="$1"
    local field="$2"

    json_get "${file}" ".${field}"
}

check_field_empty() {
    local value="$1"

    if [[ -z "${value}" || "${value}" == "null" || "${value}" == '""' || "${value}" == "[]" || "${value}" == "{}" ]]; then
        return 0  # Is empty
    else
        return 1  # Not empty
    fi
}

# ====================
# Plugin Validation
# ====================

validate_plugin_fields() {
    local file="$1"
    local strict="$2"
    local missing_required=0
    local missing_recommended=0

    print_section "Required Fields (${#PLUGIN_REQUIRED_FIELDS[@]})"

    for field in "${PLUGIN_REQUIRED_FIELDS[@]}"; do
        if check_field_exists "${file}" "${field}"; then
            local value
            value=$(get_field_value "${file}" "${field}")

            # Check if empty
            if check_field_empty "${value}"; then
                print_error "${field}: Present but empty (REQUIRED)"
                ((missing_required++))
            else
                # Truncate long values for display
                if [[ "${#value}" -gt 50 ]]; then
                    value="${value:0:47}..."
                fi
                print_success "${field}: \"${value}\""
            fi
        else
            print_error "${field}: Missing (REQUIRED)"
            ((missing_required++))
        fi
    done

    echo ""
    print_section "Recommended Fields (${#PLUGIN_RECOMMENDED_FIELDS[@]})"

    for field in "${PLUGIN_RECOMMENDED_FIELDS[@]}"; do
        if check_field_exists "${file}" "${field}"; then
            print_success "${field}: Present"
        else
            print_warning "${field}: Missing (improves quality)"
            ((missing_recommended++))
        fi
    done

    echo ""

    # Summary
    if [[ ${missing_required} -eq 0 ]]; then
        print_success "All required fields present"
    else
        print_error "Missing ${missing_required} required field(s)"
    fi

    if [[ ${missing_recommended} -gt 0 ]]; then
        print_info "Missing ${missing_recommended} recommended field(s)"
    fi

    # Determine exit code
    if [[ ${missing_required} -gt 0 ]]; then
        return 1
    elif [[ "${strict}" == "true" && ${missing_recommended} -gt 0 ]]; then
        print_warning "Strict mode: Recommended fields are required"
        return 1
    else
        return 0
    fi
}

# ====================
# Marketplace Validation
# ====================

validate_marketplace_fields() {
    local file="$1"
    local strict="$2"
    local missing_required=0
    local missing_recommended=0

    print_section "Required Fields (${#MARKETPLACE_REQUIRED_FIELDS[@]})"

    for field in "${MARKETPLACE_REQUIRED_FIELDS[@]}"; do
        if check_field_exists "${file}" "${field}"; then
            local value
            value=$(get_field_value "${file}" "${field}")

            # Special handling for plugins array
            if [[ "${field}" == "plugins" ]]; then
                local count
                count=$(get_json_array_length "${file}" ".plugins")
                if [[ ${count} -gt 0 ]]; then
                    print_success "${field}: Array with ${count} entries"
                else
                    print_error "${field}: Present but empty (REQUIRED)"
                    ((missing_required++))
                fi
            elif check_field_empty "${value}"; then
                print_error "${field}: Present but empty (REQUIRED)"
                ((missing_required++))
            else
                # Truncate long values
                if [[ "${#value}" -gt 50 ]]; then
                    value="${value:0:47}..."
                fi
                print_success "${field}: \"${value}\""
            fi
        else
            print_error "${field}: Missing (REQUIRED)"
            ((missing_required++))
        fi
    done

    echo ""
    print_section "Recommended Fields (${#MARKETPLACE_RECOMMENDED_FIELDS[@]})"

    for field in "${MARKETPLACE_RECOMMENDED_FIELDS[@]}"; do
        if check_field_exists "${file}" "${field}"; then
            print_success "${field}: Present"
        else
            print_warning "${field}: Missing (improves quality)"
            ((missing_recommended++))
        fi
    done

    echo ""

    # Summary
    if [[ ${missing_required} -eq 0 ]]; then
        print_success "All required fields present"
    else
        print_error "Missing ${missing_required} required field(s)"
    fi

    if [[ ${missing_recommended} -gt 0 ]]; then
        print_info "Missing ${missing_recommended} recommended field(s)"
    fi

    # Determine exit code
    if [[ ${missing_required} -gt 0 ]]; then
        return 1
    elif [[ "${strict}" == "true" && ${missing_recommended} -gt 0 ]]; then
        print_warning "Strict mode: Recommended fields are required"
        return 1
    else
        return 0
    fi
}

# ====================
# Main Logic
# ====================

main() {
    # Validate arguments
    if [[ -z "${CONFIG_FILE}" ]]; then
        print_error "Usage: $0 <config-file> <type> [strict]"
        print_info "Types: plugin, marketplace"
        exit 2
    fi

    if [[ ! -f "${CONFIG_FILE}" ]]; then
        print_error "Configuration file not found: ${CONFIG_FILE}"
        exit 2
    fi

    if [[ -z "${TYPE}" ]]; then
        print_error "Type required: plugin or marketplace"
        exit 2
    fi

    # Validate JSON syntax first
    if ! validate_json_syntax "${CONFIG_FILE}"; then
        print_error "Invalid JSON syntax in ${CONFIG_FILE}"
        print_info "Run JSON validation first to fix syntax errors"
        exit 2
    fi

    # Print header
    print_header "Required Fields Validation"
    echo "Target: ${CONFIG_FILE}"
    echo "Type: ${TYPE}"
    echo "Strict Mode: ${STRICT}"
    echo ""

    # Validate based on type
    case "${TYPE}" in
        plugin)
            if validate_plugin_fields "${CONFIG_FILE}" "${STRICT}"; then
                echo ""
                print_header "✅ PASS: All required fields present"
                exit 0
            else
                echo ""
                print_header "❌ FAIL: Missing required fields"

                # Show remediation
                echo ""
                print_info "Action Required:"
                echo "  Add missing required fields to ${CONFIG_FILE}"
                echo "  Refer to plugin schema: .claude/docs/plugins/plugins-reference.md"

                exit 1
            fi
            ;;
        marketplace)
            if validate_marketplace_fields "${CONFIG_FILE}" "${STRICT}"; then
                echo ""
                print_header "✅ PASS: All required fields present"
                exit 0
            else
                echo ""
                print_header "❌ FAIL: Missing required fields"

                # Show remediation
                echo ""
                print_info "Action Required:"
                echo "  Add missing required fields to ${CONFIG_FILE}"
                echo "  Refer to marketplace schema: .claude/docs/plugins/plugin-marketplaces.md"

                exit 1
            fi
            ;;
        *)
            print_error "Unknown type: ${TYPE}"
            print_info "Valid types: plugin, marketplace"
            exit 2
            ;;
    esac
}

main "$@"
