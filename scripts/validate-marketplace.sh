#!/usr/bin/env bash

# ============================================================================
# OpenPlugins - Marketplace Validation Script
# ============================================================================
# Purpose: Comprehensive validation of marketplace.json structure and quality
# Version: 2.0.0
# License: MIT
# ============================================================================

# ====================
# Strict Error Handling
# ====================
set -o errexit   # Exit on error
set -o nounset   # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# ====================
# Configuration
# ====================
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly DEFAULT_MARKETPLACE_FILE=".claude-plugin/marketplace.json"

# Exit codes
readonly E_SUCCESS=0
readonly E_FILE_NOT_FOUND=1
readonly E_INVALID_JSON=2
readonly E_MISSING_REQUIRED=3
readonly E_VALIDATION_WARNING=4
readonly E_INVALID_FORMAT=5
readonly E_PREREQ_MISSING=6

# Validation strictness
STRICT_MODE=false
VERBOSE=false
JSON_OUTPUT=false
CHECK_URLS=false
MARKETPLACE_FILE="${DEFAULT_MARKETPLACE_FILE}"

# Counters
ERRORS=0
WARNINGS=0
INFO=0

# ====================
# Color Output
# ====================
if [[ -t 1 ]] && [[ "${JSON_OUTPUT}" != true ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly MAGENTA='\033[0;35m'
    readonly CYAN='\033[0;36m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m'
else
    readonly RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' BOLD='' NC=''
fi

# ====================
# Utility Functions
# ====================

print_header() {
    [[ "${JSON_OUTPUT}" == true ]] && return
    echo -e "${BOLD}${BLUE}======================================${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}======================================${NC}"
    echo ""
}

print_section() {
    [[ "${JSON_OUTPUT}" == true ]] && return
    echo -e "${BOLD}${CYAN}🔍 $1${NC}"
}

print_success() {
    [[ "${JSON_OUTPUT}" == true ]] && return
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    [[ "${JSON_OUTPUT}" == true ]] && return
    echo -e "${RED}❌ $1${NC}" >&2
    ((ERRORS++))
}

print_warning() {
    [[ "${JSON_OUTPUT}" == true ]] && return
    echo -e "${YELLOW}⚠️  $1${NC}" >&2
    ((WARNINGS++))
}

print_info() {
    [[ "${JSON_OUTPUT}" == true ]] && return
    echo -e "${BLUE}ℹ️  $1${NC}"
    ((INFO++))
}

print_verbose() {
    [[ "${VERBOSE}" != true ]] && return
    [[ "${JSON_OUTPUT}" == true ]] && return
    echo -e "${MAGENTA}[VERBOSE] $1${NC}" >&2
}

# JSON output helpers
json_start() {
    [[ "${JSON_OUTPUT}" != true ]] && return
    echo "{"
    echo "  \"validation\": {"
    echo "    \"file\": \"${MARKETPLACE_FILE}\","
    echo "    \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\","
}

json_end() {
    [[ "${JSON_OUTPUT}" != true ]] && return
    echo "    \"errors\": ${ERRORS},"
    echo "    \"warnings\": ${WARNINGS},"
    echo "    \"info\": ${INFO},"
    echo "    \"passed\": $([ ${ERRORS} -eq 0 ] && echo "true" || echo "false")"
    echo "  }"
    echo "}"
}

# ====================
# Validation Helpers
# ====================

# Detect available JSON tools
detect_json_tool() {
    if command -v jq &> /dev/null; then
        echo "jq"
    elif command -v python3 &> /dev/null; then
        echo "python3"
    elif command -v node &> /dev/null; then
        echo "node"
    else
        echo "none"
    fi
}

# Extract JSON value (supports multiple backends)
json_get() {
    local file="$1"
    local path="$2"
    local tool
    tool=$(detect_json_tool)

    case "${tool}" in
        jq)
            jq -r "${path}" "${file}" 2>/dev/null || echo ""
            ;;
        python3)
            python3 <<EOF 2>/dev/null || echo ""
import json
try:
    with open('${file}') as f:
        data = json.load(f)
    path = '${path}'.lstrip('.')
    if not path:
        print(data if isinstance(data, str) else '')
    else:
        result = data
        for key in path.split('.'):
            if '[' in key and ']' in key:
                arr_name, idx = key.split('[')
                idx = int(idx.rstrip(']'))
                result = result[arr_name][idx] if arr_name else result[idx]
            else:
                result = result.get(key) if isinstance(result, dict) else None
            if result is None:
                break
        print(result if isinstance(result, (str, int, float)) else '')
except:
    pass
EOF
            ;;
        node)
            node -e "try{const data=require('./${file}');const path='${path}'.split('.').filter(x=>x);let val=data;for(const p of path){if(p.includes('[')){const[name,idx]=p.split('[');val=name?val[name]:val;val=val[parseInt(idx)];}else{val=val?val[p]:null;}}console.log(val||'');}catch{}" 2>/dev/null || echo ""
            ;;
        *)
            print_error "No JSON parsing tool available (install jq, python3, or node)"
            return 1
            ;;
    esac
}

# Validate JSON syntax
validate_json_syntax() {
    local file="$1"
    local tool
    tool=$(detect_json_tool)

    case "${tool}" in
        jq)
            jq empty "${file}" 2>/dev/null
            ;;
        python3)
            python3 -m json.tool "${file}" > /dev/null 2>&1
            ;;
        node)
            node -e "require('./${file}')" > /dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# Validate semver format
validate_semver() {
    local version="$1"
    [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?(\+[a-zA-Z0-9.]+)?$ ]]
}

# Validate lowercase-hyphen format
validate_name_format() {
    local name="$1"
    [[ "${name}" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

# Validate email format (basic)
validate_email() {
    local email="$1"
    [[ "${email}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

# Validate URL format
validate_url() {
    local url="$1"
    [[ "${url}" =~ ^https?:// ]]
}

# Check if URL is accessible (optional, requires curl)
check_url_accessible() {
    local url="$1"
    [[ "${CHECK_URLS}" != true ]] && return 0

    if command -v curl &> /dev/null; then
        curl -s -f -L --head "${url}" > /dev/null 2>&1
    else
        print_verbose "curl not available, skipping URL accessibility check"
        return 0
    fi
}

# Validate license (known SPDX identifiers)
validate_license() {
    local license="$1"
    local known_licenses=(
        "MIT" "Apache-2.0" "GPL-3.0" "GPL-2.0" "BSD-2-Clause" "BSD-3-Clause"
        "ISC" "LGPL-3.0" "MPL-2.0" "AGPL-3.0" "Unlicense" "CC0-1.0"
    )

    for known in "${known_licenses[@]}"; do
        if [[ "${license}" == "${known}" ]]; then
            return 0
        fi
    done

    return 1
}

# ====================
# Core Validation Functions
# ====================

validate_file_exists() {
    print_section "Checking file existence..."

    if [[ ! -f "${MARKETPLACE_FILE}" ]]; then
        print_error "File not found: ${MARKETPLACE_FILE}"
        return ${E_FILE_NOT_FOUND}
    fi

    print_success "File exists: ${MARKETPLACE_FILE}"
    print_verbose "File size: $(wc -c < "${MARKETPLACE_FILE}") bytes"
    return 0
}

validate_json_structure() {
    print_section "Validating JSON syntax..."

    if ! validate_json_syntax "${MARKETPLACE_FILE}"; then
        print_error "Invalid JSON syntax"

        # Show detailed error if python3 available
        if command -v python3 &> /dev/null; then
            echo ""
            python3 -m json.tool "${MARKETPLACE_FILE}" 2>&1 | head -n 10
        fi

        return ${E_INVALID_JSON}
    fi

    print_success "JSON syntax is valid"
    print_verbose "JSON tool: $(detect_json_tool)"
    return 0
}

validate_required_fields() {
    print_section "Checking required fields..."

    local has_errors=false

    # Check name
    local name
    name=$(json_get "${MARKETPLACE_FILE}" ".name")
    if [[ -z "${name}" ]]; then
        print_error "Missing required field: 'name'"
        has_errors=true
    else
        print_success "name: ${name}"

        if ! validate_name_format "${name}"; then
            print_warning "Name '${name}' should use lowercase-hyphen format (e.g., 'my-marketplace')"
        fi
    fi

    # Check owner.name
    local owner_name
    owner_name=$(json_get "${MARKETPLACE_FILE}" ".owner.name")
    if [[ -z "${owner_name}" ]]; then
        print_error "Missing required field: 'owner.name'"
        has_errors=true
    else
        print_success "owner.name: ${owner_name}"
    fi

    # Check owner.email
    local owner_email
    owner_email=$(json_get "${MARKETPLACE_FILE}" ".owner.email")
    if [[ -z "${owner_email}" ]]; then
        print_error "Missing required field: 'owner.email'"
        has_errors=true
    else
        print_success "owner.email: ${owner_email}"

        if ! validate_email "${owner_email}"; then
            print_warning "Email '${owner_email}' may not be valid"
        fi
    fi

    # Check description
    local description
    description=$(json_get "${MARKETPLACE_FILE}" ".description")
    if [[ -z "${description}" ]]; then
        print_error "Missing required field: 'description'"
        has_errors=true
    else
        local desc_length=${#description}
        print_success "description: Present (${desc_length} characters)"

        if [[ ${desc_length} -lt 50 ]]; then
            print_warning "Description is short (< 50 chars). Consider adding more detail."
        fi

        if [[ ${desc_length} -gt 500 ]]; then
            print_warning "Description is long (> 500 chars). Consider being more concise."
        fi
    fi

    # Check plugins array
    local plugin_count
    plugin_count=$(json_get "${MARKETPLACE_FILE}" ".plugins | length")
    if [[ -z "${plugin_count}" ]] || [[ "${plugin_count}" == "null" ]]; then
        print_error "Missing or invalid 'plugins' array"
        has_errors=true
    else
        print_success "plugins: Array with ${plugin_count} entries"
    fi

    [[ "${has_errors}" == true ]] && return ${E_MISSING_REQUIRED}
    return 0
}

validate_optional_fields() {
    print_section "Checking optional fields..."

    # Check version
    local version
    version=$(json_get "${MARKETPLACE_FILE}" ".version")
    if [[ -z "${version}" ]] || [[ "${version}" == "null" ]]; then
        print_info "No 'version' field (optional but recommended)"
    else
        print_success "version: ${version}"

        if ! validate_semver "${version}"; then
            print_warning "Version '${version}' doesn't follow semver format (MAJOR.MINOR.PATCH)"
        fi
    fi

    # Check metadata fields
    local homepage
    homepage=$(json_get "${MARKETPLACE_FILE}" ".metadata.homepage")
    if [[ -n "${homepage}" ]] && [[ "${homepage}" != "null" ]]; then
        print_success "metadata.homepage: ${homepage}"

        if ! validate_url "${homepage}"; then
            print_warning "Homepage URL may be invalid: ${homepage}"
        elif [[ "${CHECK_URLS}" == true ]]; then
            if check_url_accessible "${homepage}"; then
                print_verbose "Homepage is accessible"
            else
                print_warning "Homepage may not be accessible: ${homepage}"
            fi
        fi
    else
        print_info "No 'metadata.homepage' (recommended)"
    fi

    local repository
    repository=$(json_get "${MARKETPLACE_FILE}" ".metadata.repository")
    if [[ -n "${repository}" ]] && [[ "${repository}" != "null" ]]; then
        print_success "metadata.repository: ${repository}"
    else
        print_info "No 'metadata.repository' (recommended)"
    fi

    # Check categories
    local category_count
    category_count=$(json_get "${MARKETPLACE_FILE}" ".categories | length")
    if [[ -n "${category_count}" ]] && [[ "${category_count}" != "null" ]] && [[ ${category_count} -gt 0 ]]; then
        print_success "categories: ${category_count} defined"
    else
        print_info "No 'categories' array (optional)"
    fi

    return 0
}

validate_plugin_entries() {
    local plugin_count
    plugin_count=$(json_get "${MARKETPLACE_FILE}" ".plugins | length")

    if [[ -z "${plugin_count}" ]] || [[ "${plugin_count}" == "null" ]] || [[ ${plugin_count} -eq 0 ]]; then
        print_info "No plugins to validate (marketplace is empty)"
        return 0
    fi

    print_section "Validating ${plugin_count} plugin entries..."

    local tool
    tool=$(detect_json_tool)

    local has_plugin_errors=false

    for ((i=0; i<plugin_count; i++)); do
        echo ""

        local plugin_name
        plugin_name=$(json_get "${MARKETPLACE_FILE}" ".plugins[${i}].name")

        if [[ -z "${plugin_name}" ]] || [[ "${plugin_name}" == "null" ]]; then
            print_error "Plugin #$((i+1)): Missing 'name' field"
            has_plugin_errors=true
            continue
        fi

        print_info "Plugin #$((i+1)): ${plugin_name}"

        # Required fields
        local required_fields=("name" "version" "description" "author" "source" "license")
        local plugin_has_errors=false

        for field in "${required_fields[@]}"; do
            local value
            value=$(json_get "${MARKETPLACE_FILE}" ".plugins[${i}].${field}")

            if [[ -z "${value}" ]] || [[ "${value}" == "null" ]]; then
                print_error "  Missing required field: '${field}'"
                plugin_has_errors=true
                has_plugin_errors=true
            else
                print_verbose "  ${field}: Present"

                # Field-specific validation
                case "${field}" in
                    name)
                        if ! validate_name_format "${value}"; then
                            print_warning "  Plugin name '${value}' should use lowercase-hyphen format"
                        fi
                        ;;
                    version)
                        if ! validate_semver "${value}"; then
                            print_warning "  Version '${value}' doesn't follow semver format"
                        fi
                        ;;
                    license)
                        if ! validate_license "${value}"; then
                            print_info "  License '${value}' is not a known SPDX identifier"
                        fi
                        ;;
                    source)
                        if [[ "${value}" =~ ^https?:// ]]; then
                            if ! validate_url "${value}"; then
                                print_warning "  Source URL may be invalid: ${value}"
                            fi
                        elif [[ ! "${value}" =~ ^github: ]]; then
                            print_warning "  Source format not recognized: ${value}"
                        fi
                        ;;
                esac
            fi
        done

        if [[ "${plugin_has_errors}" == false ]]; then
            print_success "  All required fields present"
        fi

        # Optional but recommended fields
        local category
        category=$(json_get "${MARKETPLACE_FILE}" ".plugins[${i}].category")
        if [[ -z "${category}" ]] || [[ "${category}" == "null" ]]; then
            print_info "  No 'category' (recommended for organization)"
        fi

        local keywords_count
        keywords_count=$(json_get "${MARKETPLACE_FILE}" ".plugins[${i}].keywords | length")
        if [[ -z "${keywords_count}" ]] || [[ "${keywords_count}" == "null" ]] || [[ ${keywords_count} -eq 0 ]]; then
            print_info "  No 'keywords' (recommended for discoverability)"
        fi
    done

    [[ "${has_plugin_errors}" == true ]] && return ${E_VALIDATION_WARNING}
    return 0
}

# ====================
# Summary & Report
# ====================

show_summary() {
    echo ""
    print_header "Validation Summary"

    local status_color="${GREEN}"
    local status_icon="✅"
    local status_text="PASSED"

    if [[ ${ERRORS} -gt 0 ]]; then
        status_color="${RED}"
        status_icon="❌"
        status_text="FAILED"
    elif [[ ${WARNINGS} -gt 0 ]] && [[ "${STRICT_MODE}" == true ]]; then
        status_color="${YELLOW}"
        status_icon="⚠️"
        status_text="PASSED WITH WARNINGS"
    fi

    echo -e "${status_color}${status_icon} Status: ${status_text}${NC}"
    echo ""
    echo "Results:"
    echo "  Errors:   ${ERRORS}"
    echo "  Warnings: ${WARNINGS}"
    echo "  Info:     ${INFO}"
    echo ""

    if [[ ${ERRORS} -gt 0 ]]; then
        echo "Fix all errors before publishing."
    elif [[ ${WARNINGS} -gt 0 ]]; then
        echo "Consider addressing warnings for better quality."
    else
        echo "Marketplace is ready for publication!"
    fi

    echo ""
}

# ====================
# Main Workflow
# ====================

main() {
    # JSON output mode
    if [[ "${JSON_OUTPUT}" == true ]]; then
        json_start
    else
        print_header "OpenPlugins Marketplace Validation"
    fi

    # Change to project root
    cd "${PROJECT_ROOT}" || {
        print_error "Failed to change to project root: ${PROJECT_ROOT}"
        exit ${E_FILE_NOT_FOUND}
    }

    print_verbose "Project root: ${PROJECT_ROOT}"
    print_verbose "Marketplace file: ${MARKETPLACE_FILE}"
    print_verbose "Strict mode: ${STRICT_MODE}"

    # Run validation steps
    local exit_code=0

    validate_file_exists || exit_code=$?
    [[ ${exit_code} -ne 0 ]] && exit ${exit_code}

    validate_json_structure || exit_code=$?
    [[ ${exit_code} -ne 0 ]] && exit ${exit_code}

    validate_required_fields || exit_code=$?
    validate_optional_fields
    validate_plugin_entries || {
        local plugin_exit=$?
        [[ ${exit_code} -eq 0 ]] && exit_code=${plugin_exit}
    }

    # Show summary
    if [[ "${JSON_OUTPUT}" == true ]]; then
        json_end
    else
        show_summary
    fi

    # Determine final exit code
    if [[ ${ERRORS} -gt 0 ]]; then
        exit ${E_MISSING_REQUIRED}
    elif [[ ${WARNINGS} -gt 0 ]] && [[ "${STRICT_MODE}" == true ]]; then
        exit ${E_VALIDATION_WARNING}
    else
        exit ${E_SUCCESS}
    fi
}

# ====================
# Usage & Help
# ====================

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Comprehensive validation of Claude Code marketplace.json files.

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    -s, --strict            Treat warnings as errors
    -j, --json              Output results in JSON format
    -f, --file FILE         Marketplace file to validate (default: ${DEFAULT_MARKETPLACE_FILE})
    -u, --check-urls        Check URL accessibility (requires curl)

EXAMPLES:
    # Basic validation
    $(basename "$0")

    # Strict mode (warnings = errors)
    $(basename "$0") --strict

    # JSON output for CI/CD
    $(basename "$0") --json

    # Validate specific file
    $(basename "$0") --file custom-marketplace.json

    # Verbose with URL checking
    $(basename "$0") --verbose --check-urls

EXIT CODES:
    0   Success (all validation passed)
    1   File not found
    2   Invalid JSON syntax
    3   Missing required fields
    4   Validation warnings (strict mode only)
    5   Invalid format
    6   Prerequisites missing

VALIDATION LEVELS:
    - Errors: Critical issues that must be fixed
    - Warnings: Issues that should be addressed
    - Info: Suggestions for improvement

BACKENDS:
    Supports multiple JSON parsing tools (auto-detected):
    - jq (preferred)
    - python3
    - node.js

EOF
}

# ====================
# Argument Parsing
# ====================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit ${E_SUCCESS}
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -s|--strict)
                STRICT_MODE=true
                shift
                ;;
            -j|--json)
                JSON_OUTPUT=true
                shift
                ;;
            -f|--file)
                MARKETPLACE_FILE="$2"
                shift 2
                ;;
            -u|--check-urls)
                CHECK_URLS=true
                shift
                ;;
            *)
                echo "Error: Unknown option: $1" >&2
                show_usage
                exit ${E_INVALID_FORMAT}
                ;;
        esac
    done
}

# ====================
# Entry Point
# ====================

parse_arguments "$@"
main
exit $?
