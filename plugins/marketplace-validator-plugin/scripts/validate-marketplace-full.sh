#!/usr/bin/env bash

# ============================================================================
# Marketplace Validator Plugin - Full Marketplace Validation
# ============================================================================
# Purpose: Comprehensive marketplace.json validation with quality scoring
# Version: 1.0.0
# License: MIT
# ============================================================================

set -o errexit
set -o nounset
set -o pipefail

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source validation library
# shellcheck source=validate-lib.sh
source "${SCRIPT_DIR}/validate-lib.sh"

# ====================
# Configuration
# ====================

MARKETPLACE_FILE="${1:-.claude-plugin/marketplace.json}"
ERRORS=0
WARNINGS=0
RECOMMENDATIONS=()
PLUGIN_SCORES=()
PLUGIN_RESULTS=()

# ====================
# Validation Functions
# ====================

validate_marketplace_structure() {
    print_section "Validating JSON Structure"

    if [[ ! -f "${MARKETPLACE_FILE}" ]]; then
        print_error "File not found: ${MARKETPLACE_FILE}"
        ((ERRORS++))
        return 1
    fi

    if ! validate_json_syntax "${MARKETPLACE_FILE}"; then
        print_error "Invalid JSON syntax"
        ((ERRORS++))

        # Show detailed error
        if command -v python3 &> /dev/null; then
            echo ""
            python3 -m json.tool "${MARKETPLACE_FILE}" 2>&1 | head -n 10 || true
        fi
        return 1
    fi

    print_success "JSON syntax valid"
    return 0
}

validate_required_marketplace_fields() {
    print_section "Checking Required Fields"

    local has_errors=false

    # Validate name
    local name
    name=$(json_get "${MARKETPLACE_FILE}" ".name")
    if [[ -z "${name}" ]]; then
        print_error "Missing required field: 'name'"
        has_errors=true
        ((ERRORS++))
    else
        print_success "name: ${name}"

        if ! validate_name_format "${name}"; then
            print_warning "Name should use lowercase-hyphen format"
            RECOMMENDATIONS+=("Use lowercase-hyphen format for marketplace name")
            ((WARNINGS++))
        fi
    fi

    # Validate owner.name
    local owner_name
    owner_name=$(json_get "${MARKETPLACE_FILE}" ".owner.name")
    if [[ -z "${owner_name}" ]]; then
        print_error "Missing required field: 'owner.name'"
        has_errors=true
        ((ERRORS++))
    else
        print_success "owner.name: ${owner_name}"
    fi

    # Validate owner.email
    local owner_email
    owner_email=$(json_get "${MARKETPLACE_FILE}" ".owner.email")
    if [[ -z "${owner_email}" ]]; then
        print_warning "Missing recommended field: 'owner.email'"
        RECOMMENDATIONS+=("Add owner email for contact")
        ((WARNINGS++))
    else
        print_success "owner.email: ${owner_email}"

        if ! validate_email "${owner_email}"; then
            print_warning "Email format may be invalid: ${owner_email}"
            ((WARNINGS++))
        fi
    fi

    # Validate description
    local description
    description=$(json_get "${MARKETPLACE_FILE}" ".description")
    if [[ -z "${description}" ]]; then
        print_error "Missing required field: 'description'"
        has_errors=true
        ((ERRORS++))
    else
        local desc_length=${#description}
        print_success "description: Present (${desc_length} characters)"

        if [[ ${desc_length} -lt 50 ]]; then
            print_warning "Description is short (< 50 chars)"
            RECOMMENDATIONS+=("Expand marketplace description to at least 50 characters")
            ((WARNINGS++))
        fi

        if [[ ${desc_length} -gt 500 ]]; then
            print_warning "Description is long (> 500 chars)"
            RECOMMENDATIONS+=("Consider condensing marketplace description")
            ((WARNINGS++))
        fi
    fi

    # Validate plugins array
    local plugin_count
    plugin_count=$(get_json_array_length "${MARKETPLACE_FILE}" ".plugins")
    if [[ -z "${plugin_count}" ]] || [[ "${plugin_count}" == "null" ]]; then
        print_error "Missing or invalid 'plugins' array"
        has_errors=true
        ((ERRORS++))
    else
        print_success "plugins: Array with ${plugin_count} entries"
    fi

    [[ "${has_errors}" == true ]] && return 1
    return 0
}

validate_optional_marketplace_fields() {
    print_section "Checking Optional Fields"

    # Check version
    local version
    version=$(json_get "${MARKETPLACE_FILE}" ".version")
    if [[ -z "${version}" ]] || [[ "${version}" == "null" ]]; then
        print_info "No 'version' field (recommended)"
        RECOMMENDATIONS+=("Add version field for marketplace tracking")
    else
        print_success "version: ${version}"

        if ! validate_semver "${version}"; then
            print_warning "Version doesn't follow semver format: ${version}"
            RECOMMENDATIONS+=("Use semantic versioning (X.Y.Z) for marketplace version")
            ((WARNINGS++))
        fi
    fi

    # Check metadata.homepage
    local homepage
    homepage=$(json_get "${MARKETPLACE_FILE}" ".metadata.homepage")
    if [[ -n "${homepage}" ]] && [[ "${homepage}" != "null" ]]; then
        print_success "metadata.homepage: ${homepage}"

        if ! validate_url "${homepage}"; then
            print_warning "Homepage URL may be invalid"
            ((WARNINGS++))
        fi
    else
        print_info "No 'metadata.homepage' (recommended)"
        RECOMMENDATIONS+=("Add metadata.homepage for marketplace website")
    fi

    # Check metadata.repository
    local repository
    repository=$(json_get "${MARKETPLACE_FILE}" ".metadata.repository")
    if [[ -n "${repository}" ]] && [[ "${repository}" != "null" ]]; then
        print_success "metadata.repository: ${repository}"
    else
        print_info "No 'metadata.repository' (recommended)"
        RECOMMENDATIONS+=("Add metadata.repository for source code")
    fi

    # Check categories
    local category_count
    category_count=$(get_json_array_length "${MARKETPLACE_FILE}" ".categories")
    if [[ ${category_count} -gt 0 ]]; then
        print_success "categories: ${category_count} defined"
    else
        print_info "No 'categories' array (optional)"
    fi

    return 0
}

validate_plugin_entry() {
    local index=$1
    local plugin_name
    plugin_name=$(json_get "${MARKETPLACE_FILE}" ".plugins[${index}].name")

    local plugin_errors=0
    local plugin_warnings=0
    local plugin_missing=0
    local issues=()

    if [[ -z "${plugin_name}" ]]; then
        print_error "Plugin #$((index+1)): Missing 'name' field"
        PLUGIN_RESULTS+=("Plugin #$((index+1)): Missing name - Poor ⭐")
        PLUGIN_SCORES+=(0)
        ((ERRORS++))
        return 1
    fi

    echo ""
    print_info "Plugin #$((index+1)): ${plugin_name}"

    # Required fields
    local required_fields=("name" "version" "description" "source" "license")

    for field in "${required_fields[@]}"; do
        local value
        value=$(json_get "${MARKETPLACE_FILE}" ".plugins[${index}].${field}")

        if [[ -z "${value}" ]] || [[ "${value}" == "null" ]]; then
            print_error "  Missing required field: '${field}'"
            issues+=("Missing required: ${field}")
            ((plugin_errors++))
        else
            # Field-specific validation
            case "${field}" in
                name)
                    if ! validate_name_format "${value}"; then
                        print_warning "  Name should use lowercase-hyphen format"
                        issues+=("Invalid name format")
                        ((plugin_warnings++))
                    fi
                    ;;
                version)
                    if ! validate_semver "${value}"; then
                        print_warning "  Version doesn't follow semver: ${value}"
                        issues+=("Invalid version format")
                        ((plugin_warnings++))
                    fi
                    ;;
                description)
                    local desc_len=${#value}
                    if [[ ${desc_len} -lt 50 ]]; then
                        print_warning "  Description too short (< 50 chars)"
                        issues+=("Description too short")
                        ((plugin_warnings++))
                    fi
                    if [[ ${desc_len} -gt 200 ]]; then
                        print_warning "  Description too long (> 200 chars)"
                        issues+=("Description too long")
                        ((plugin_warnings++))
                    fi
                    ;;
                source)
                    if ! validate_source_format "${value}"; then
                        print_warning "  Unusual source format: ${value}"
                        issues+=("Unusual source format")
                        ((plugin_warnings++))
                    fi
                    ;;
                license)
                    if ! validate_license "${value}"; then
                        print_info "  License '${value}' is not a known SPDX identifier"
                    fi
                    ;;
            esac
        fi
    done

    # Check author
    local author_name
    author_name=$(json_get "${MARKETPLACE_FILE}" ".plugins[${index}].author.name")
    if [[ -z "${author_name}" ]]; then
        # Try string format
        author_name=$(json_get "${MARKETPLACE_FILE}" ".plugins[${index}].author")
        if [[ -z "${author_name}" ]]; then
            print_error "  Missing required field: 'author'"
            issues+=("Missing required: author")
            ((plugin_errors++))
        fi
    fi

    # Optional but recommended
    local keywords_count
    keywords_count=$(get_json_array_length "${MARKETPLACE_FILE}" ".plugins[${index}].keywords")
    if [[ ${keywords_count} -eq 0 ]]; then
        print_info "  No 'keywords' (recommended)"
        issues+=("Missing keywords")
        ((plugin_missing++))
    elif [[ ${keywords_count} -lt 3 ]]; then
        print_warning "  Few keywords (< 3)"
        issues+=("Few keywords")
        ((plugin_warnings++))
    elif [[ ${keywords_count} -gt 7 ]]; then
        print_warning "  Many keywords (> 7)"
        issues+=("Too many keywords")
        ((plugin_warnings++))
    fi

    local category
    category=$(json_get "${MARKETPLACE_FILE}" ".plugins[${index}].category")
    if [[ -z "${category}" ]] || [[ "${category}" == "null" ]]; then
        print_info "  No 'category' (recommended)"
        issues+=("Missing category")
        ((plugin_missing++))
    else
        if ! validate_category "${category}"; then
            print_warning "  Invalid category: ${category}"
            issues+=("Invalid category")
            ((plugin_warnings++))
        fi
    fi

    # Security checks
    if ! check_for_secrets "${MARKETPLACE_FILE}"; then
        print_error "  SECURITY: Possible exposed secrets detected"
        issues+=("Security: possible secrets")
        ((plugin_errors+=3))
    fi

    # Calculate score
    local score
    score=$(calculate_quality_score ${plugin_errors} ${plugin_warnings} ${plugin_missing})
    local rating
    rating=$(print_quality_rating ${score})
    local stars
    stars=$(print_star_rating ${score})

    PLUGIN_SCORES+=(${score})

    if [[ ${plugin_errors} -eq 0 ]]; then
        print_success "  Quality: ${rating} ${stars} (${score}/100)"
        PLUGIN_RESULTS+=("${plugin_name} (${rating} ${stars})")
    else
        print_error "  Quality: ${rating} ${stars} (${score}/100)"
        PLUGIN_RESULTS+=("${plugin_name} (${rating} ${stars})")
    fi

    # Show issues
    if [[ ${#issues[@]} -gt 0 ]]; then
        for issue in "${issues[@]}"; do
            echo "     - ${issue}"
        done
    fi

    ((ERRORS+=plugin_errors))
    ((WARNINGS+=plugin_warnings))

    return 0
}

validate_all_plugins() {
    local plugin_count
    plugin_count=$(get_json_array_length "${MARKETPLACE_FILE}" ".plugins")

    if [[ ${plugin_count} -eq 0 ]]; then
        print_info "No plugins to validate (marketplace is empty)"
        return 0
    fi

    print_section "Validating ${plugin_count} Plugin Entries"

    for ((i=0; i<plugin_count; i++)); do
        validate_plugin_entry ${i}
    done

    return 0
}

# ====================
# Reporting
# ====================

show_summary() {
    echo ""
    print_header "Validation Summary"

    # Calculate overall score
    local total_score=0
    local score_count=${#PLUGIN_SCORES[@]}

    if [[ ${score_count} -gt 0 ]]; then
        for score in "${PLUGIN_SCORES[@]}"; do
            total_score=$((total_score + score))
        done
        local avg_score=$((total_score / score_count))
    else
        local avg_score=100
    fi

    # Adjust for marketplace-level errors
    if [[ ${ERRORS} -gt ${#PLUGIN_SCORES[@]} ]]; then
        local marketplace_errors=$((ERRORS - score_count))
        avg_score=$((avg_score - (marketplace_errors * 10)))
        if [[ ${avg_score} -lt 0 ]]; then
            avg_score=0
        fi
    fi

    local rating
    rating=$(print_quality_rating ${avg_score})
    local stars
    stars=$(print_star_rating ${avg_score})

    echo "Overall Quality Score: ${avg_score}/100 - ${rating} ${stars}"
    echo ""
    echo "Results:"
    echo "  Errors:   ${ERRORS}"
    echo "  Warnings: ${WARNINGS}"
    echo ""

    if [[ ${#PLUGIN_RESULTS[@]} -gt 0 ]]; then
        echo "Plugin Summary:"
        for result in "${PLUGIN_RESULTS[@]}"; do
            echo "  - ${result}"
        done
        echo ""
    fi

    if [[ ${#RECOMMENDATIONS[@]} -gt 0 ]]; then
        echo "Recommendations:"
        local i=1
        for rec in "${RECOMMENDATIONS[@]}"; do
            echo "  ${i}. ${rec}"
            ((i++))
        done
        echo ""
    fi

    # Final verdict
    if [[ ${ERRORS} -gt 0 ]]; then
        print_error "Status: FAILED - Fix critical issues before publication"
        return 1
    elif [[ ${WARNINGS} -gt 5 ]]; then
        print_warning "Status: PASSED with warnings - Address issues for better quality"
        return 0
    else
        print_success "Status: EXCELLENT - Ready for publication"
        return 0
    fi
}

# ====================
# Main
# ====================

main() {
    print_header "🔍 Validating Marketplace: $(basename "${MARKETPLACE_FILE}")"

    # Check if JSON tool is available
    local tool
    tool=$(detect_json_tool)
    if [[ "${tool}" == "none" ]]; then
        print_error "No JSON parsing tool available (install jq or python3)"
        exit 1
    fi

    # Run validations
    validate_marketplace_structure || exit 1
    validate_required_marketplace_fields || true
    validate_optional_marketplace_fields
    validate_all_plugins

    # Show summary
    show_summary
    exit $?
}

main "$@"
