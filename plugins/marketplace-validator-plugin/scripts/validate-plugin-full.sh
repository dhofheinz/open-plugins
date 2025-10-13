#!/usr/bin/env bash

# ============================================================================
# Marketplace Validator Plugin - Full Plugin Validation
# ============================================================================
# Purpose: Comprehensive plugin validation with quality scoring
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

PLUGIN_DIR="${1:-.}"
PLUGIN_FILE="${PLUGIN_DIR}/.claude-plugin/plugin.json"
ERRORS=0
WARNINGS=0
MISSING_RECOMMENDED=0
RECOMMENDATIONS=()

# ====================
# Validation Functions
# ====================

validate_plugin_structure() {
    print_section "Validating Plugin Structure"

    # Check .claude-plugin directory
    if ! check_dir_exists "${PLUGIN_DIR}/.claude-plugin"; then
        print_error ".claude-plugin directory not found"
        print_info "  Expected: ${PLUGIN_DIR}/.claude-plugin/"
        ((ERRORS++))
        return 1
    fi
    print_success ".claude-plugin directory exists"

    # Check plugin.json
    if ! check_file_exists "${PLUGIN_FILE}"; then
        print_error "plugin.json not found"
        print_info "  Expected: ${PLUGIN_FILE}"
        ((ERRORS++))
        return 1
    fi
    print_success "plugin.json exists"

    # Validate JSON syntax
    if ! validate_json_syntax "${PLUGIN_FILE}"; then
        print_error "Invalid JSON syntax in plugin.json"
        ((ERRORS++))

        if command -v python3 &> /dev/null; then
            echo ""
            python3 -m json.tool "${PLUGIN_FILE}" 2>&1 | head -n 10 || true
        fi
        return 1
    fi
    print_success "plugin.json has valid JSON syntax"

    # Check component directories
    if check_dir_exists "${PLUGIN_DIR}/commands"; then
        local cmd_count
        cmd_count=$(find "${PLUGIN_DIR}/commands" -name "*.md" -type f 2>/dev/null | wc -l)
        print_success "commands directory present (${cmd_count} commands)"
    else
        print_info "No commands directory (optional)"
    fi

    if check_dir_exists "${PLUGIN_DIR}/agents"; then
        local agent_count
        agent_count=$(find "${PLUGIN_DIR}/agents" -name "*.md" -type f 2>/dev/null | wc -l)
        print_success "agents directory present (${agent_count} agents)"
    else
        print_info "No agents directory (optional)"
    fi

    if check_dir_exists "${PLUGIN_DIR}/hooks"; then
        print_success "hooks directory present"
    else
        print_info "No hooks directory (optional)"
    fi

    # Check README
    if check_file_exists "${PLUGIN_DIR}/README.md"; then
        local readme_size
        readme_size=$(get_file_size "${PLUGIN_DIR}/README.md")
        if [[ ${readme_size} -lt 500 ]]; then
            print_warning "README.md is very short (< 500 bytes)"
            RECOMMENDATIONS+=("Expand README with usage examples and documentation")
            ((WARNINGS++))
        else
            print_success "README.md present and substantial"
        fi
    else
        print_error "README.md missing (required)"
        RECOMMENDATIONS+=("Create comprehensive README.md")
        ((ERRORS++))
    fi

    # Check LICENSE
    if check_file_exists "${PLUGIN_DIR}/LICENSE"; then
        print_success "LICENSE file present"
    else
        print_error "LICENSE file missing (required)"
        RECOMMENDATIONS+=("Add LICENSE file (MIT recommended)")
        ((ERRORS++))
    fi

    # Check CHANGELOG
    if check_file_exists "${PLUGIN_DIR}/CHANGELOG.md"; then
        print_success "CHANGELOG.md present"
    else
        print_info "No CHANGELOG.md (recommended)"
        RECOMMENDATIONS+=("Add CHANGELOG.md for version tracking")
        ((MISSING_RECOMMENDED++))
    fi

    return 0
}

validate_plugin_metadata() {
    print_section "Validating Plugin Metadata"

    local has_errors=false

    # Required: name
    local name
    name=$(json_get "${PLUGIN_FILE}" ".name")
    if [[ -z "${name}" ]]; then
        print_error "Missing required field: 'name'"
        has_errors=true
        ((ERRORS++))
    else
        print_success "name: ${name}"

        if ! validate_name_format "${name}"; then
            print_warning "Name should use lowercase-hyphen format"
            RECOMMENDATIONS+=("Rename plugin to use lowercase-hyphen format")
            ((WARNINGS++))
        fi
    fi

    # Required: version
    local version
    version=$(json_get "${PLUGIN_FILE}" ".version")
    if [[ -z "${version}" ]]; then
        print_error "Missing required field: 'version'"
        has_errors=true
        ((ERRORS++))
    else
        print_success "version: ${version}"

        if ! validate_semver "${version}"; then
            print_error "Version doesn't follow semver format (X.Y.Z)"
            RECOMMENDATIONS+=("Fix version to use semantic versioning (e.g., 1.0.0)")
            ((ERRORS++))
        fi
    fi

    # Required: description
    local description
    description=$(json_get "${PLUGIN_FILE}" ".description")
    if [[ -z "${description}" ]]; then
        print_error "Missing required field: 'description'"
        has_errors=true
        ((ERRORS++))
    else
        local desc_length=${#description}
        print_success "description: Present (${desc_length} characters)"

        if [[ ${desc_length} -lt 50 ]]; then
            print_warning "Description is short (< 50 chars)"
            RECOMMENDATIONS+=("Expand description to at least 50 characters")
            ((WARNINGS++))
        fi

        if [[ ${desc_length} -gt 200 ]]; then
            print_warning "Description is long (> 200 chars)"
            RECOMMENDATIONS+=("Condense description to under 200 characters")
            ((WARNINGS++))
        fi
    fi

    # Required: author
    local author_name
    author_name=$(json_get "${PLUGIN_FILE}" ".author.name")
    if [[ -z "${author_name}" ]]; then
        # Try string format
        author_name=$(json_get "${PLUGIN_FILE}" ".author")
        if [[ -z "${author_name}" ]]; then
            print_error "Missing required field: 'author'"
            has_errors=true
            ((ERRORS++))
        else
            print_success "author: ${author_name}"
        fi
    else
        print_success "author.name: ${author_name}"

        # Check author.email
        local author_email
        author_email=$(json_get "${PLUGIN_FILE}" ".author.email")
        if [[ -n "${author_email}" ]]; then
            if validate_email "${author_email}"; then
                print_success "author.email: ${author_email}"
            else
                print_warning "author.email format may be invalid"
                ((WARNINGS++))
            fi
        fi
    fi

    # Required: license
    local license
    license=$(json_get "${PLUGIN_FILE}" ".license")
    if [[ -z "${license}" ]]; then
        print_error "Missing required field: 'license'"
        has_errors=true
        ((ERRORS++))
    else
        print_success "license: ${license}"

        if ! validate_license "${license}"; then
            print_info "License '${license}' is not a known SPDX identifier"
        fi
    fi

    # Optional but recommended: keywords
    local keywords_count
    keywords_count=$(get_json_array_length "${PLUGIN_FILE}" ".keywords")
    if [[ ${keywords_count} -eq 0 ]]; then
        print_info "No 'keywords' (recommended for discoverability)"
        RECOMMENDATIONS+=("Add 3-7 keywords for better discoverability")
        ((MISSING_RECOMMENDED++))
    elif [[ ${keywords_count} -lt 3 ]]; then
        print_warning "Few keywords (< 3)"
        RECOMMENDATIONS+=("Add more keywords (recommended: 3-7)")
        ((WARNINGS++))
    elif [[ ${keywords_count} -gt 7 ]]; then
        print_warning "Many keywords (> 7)"
        RECOMMENDATIONS+=("Reduce keywords to 3-7 most relevant")
        ((WARNINGS++))
    else
        print_success "keywords: ${keywords_count} (good)"
    fi

    # Optional: repository
    local repository
    repository=$(json_get "${PLUGIN_FILE}" ".repository.url")
    if [[ -z "${repository}" ]]; then
        print_info "No 'repository.url' (recommended)"
        RECOMMENDATIONS+=("Add repository.url for source code link")
        ((MISSING_RECOMMENDED++))
    else
        print_success "repository.url: ${repository}"

        if ! validate_url "${repository}"; then
            print_warning "Repository URL may be invalid"
            ((WARNINGS++))
        fi
    fi

    # Optional: homepage
    local homepage
    homepage=$(json_get "${PLUGIN_FILE}" ".homepage")
    if [[ -z "${homepage}" ]]; then
        print_info "No 'homepage' (recommended)"
        RECOMMENDATIONS+=("Add homepage for plugin documentation")
        ((MISSING_RECOMMENDED++))
    else
        print_success "homepage: ${homepage}"

        if ! validate_url "${homepage}"; then
            print_warning "Homepage URL may be invalid"
            ((WARNINGS++))
        fi
    fi

    [[ "${has_errors}" == true ]] && return 1
    return 0
}

validate_commands() {
    if ! check_dir_exists "${PLUGIN_DIR}/commands"; then
        return 0
    fi

    print_section "Validating Commands"

    local command_files
    command_files=$(find "${PLUGIN_DIR}/commands" -name "*.md" -type f 2>/dev/null || true)

    if [[ -z "${command_files}" ]]; then
        print_info "No command files found"
        return 0
    fi

    while IFS= read -r cmd_file; do
        local cmd_name
        cmd_name=$(basename "${cmd_file}")

        # Check frontmatter
        if validate_markdown_frontmatter "${cmd_file}"; then
            # Check for description
            local description
            description=$(extract_frontmatter_field "${cmd_file}" "description")

            if [[ -n "${description}" ]]; then
                print_success "${cmd_name}: valid frontmatter with description"
            else
                print_warning "${cmd_name}: missing 'description' in frontmatter"
                RECOMMENDATIONS+=("Add description to ${cmd_name} frontmatter")
                ((WARNINGS++))
            fi
        else
            print_error "${cmd_name}: invalid or missing frontmatter"
            RECOMMENDATIONS+=("Fix frontmatter in ${cmd_name}")
            ((ERRORS++))
        fi
    done <<< "${command_files}"

    return 0
}

validate_agents() {
    if ! check_dir_exists "${PLUGIN_DIR}/agents"; then
        return 0
    fi

    print_section "Validating Agents"

    local agent_files
    agent_files=$(find "${PLUGIN_DIR}/agents" -name "*.md" -type f 2>/dev/null || true)

    if [[ -z "${agent_files}" ]]; then
        print_info "No agent files found"
        return 0
    fi

    while IFS= read -r agent_file; do
        local agent_name
        agent_name=$(basename "${agent_file}")

        # Check frontmatter
        if validate_markdown_frontmatter "${agent_file}"; then
            # Check required fields
            local name_field
            name_field=$(extract_frontmatter_field "${agent_file}" "name")
            local desc_field
            desc_field=$(extract_frontmatter_field "${agent_file}" "description")

            if [[ -n "${name_field}" ]] && [[ -n "${desc_field}" ]]; then
                print_success "${agent_name}: valid (name: ${name_field})"
            else
                print_error "${agent_name}: missing required fields (name, description)"
                RECOMMENDATIONS+=("Add name and description to ${agent_name}")
                ((ERRORS++))
            fi
        else
            print_error "${agent_name}: invalid or missing frontmatter"
            RECOMMENDATIONS+=("Fix frontmatter in ${agent_name}")
            ((ERRORS++))
        fi
    done <<< "${agent_files}"

    return 0
}

validate_hooks() {
    if ! check_file_exists "${PLUGIN_DIR}/hooks/hooks.json"; then
        return 0
    fi

    print_section "Validating Hooks"

    local hooks_file="${PLUGIN_DIR}/hooks/hooks.json"

    # Check JSON syntax
    if ! validate_json_syntax "${hooks_file}"; then
        print_error "Invalid JSON syntax in hooks.json"
        ((ERRORS++))
        return 1
    fi

    print_success "hooks.json: valid JSON syntax"

    # Check for referenced scripts
    local hook_events=("PostToolUse" "PreToolUse" "SessionStart" "SessionEnd")
    for event in "${hook_events[@]}"; do
        local hook_count
        hook_count=$(get_json_array_length "${hooks_file}" ".${event}")

        if [[ ${hook_count} -gt 0 ]]; then
            print_info "${event}: ${hook_count} hooks configured"

            # Validate hook scripts exist
            for ((i=0; i<hook_count; i++)); do
                local hook_matcher_count
                hook_matcher_count=$(get_json_array_length "${hooks_file}" ".${event}[${i}].hooks")

                for ((j=0; j<hook_matcher_count; j++)); do
                    local command
                    command=$(json_get "${hooks_file}" ".${event}[${i}].hooks[${j}].command")

                    if [[ -n "${command}" ]] && [[ "${command}" != "null" ]]; then
                        # Expand ${CLAUDE_PLUGIN_ROOT} variable
                        command="${command//\$\{CLAUDE_PLUGIN_ROOT\}/${PLUGIN_DIR}}"

                        if check_file_exists "${command}"; then
                            if check_file_executable "${command}"; then
                                print_success "  Hook script exists and executable: $(basename "${command}")"
                            else
                                print_warning "  Hook script not executable: ${command}"
                                RECOMMENDATIONS+=("Make hook script executable: chmod +x ${command}")
                                ((WARNINGS++))
                            fi
                        else
                            print_error "  Hook script not found: ${command}"
                            ((ERRORS++))
                        fi
                    fi
                done
            done
        fi
    done

    return 0
}

validate_security() {
    print_section "Validating Security"

    # Check for .env files
    if check_file_exists "${PLUGIN_DIR}/.env"; then
        print_warning ".env file found (ensure no real credentials)"
        RECOMMENDATIONS+=("Remove .env file or ensure it contains only examples")
        ((WARNINGS++))
    fi

    if check_file_exists "${PLUGIN_DIR}/.env.example"; then
        print_info ".env.example found (verify no real values)"
    fi

    # Check for secrets in JSON files
    local json_files
    json_files=$(find "${PLUGIN_DIR}" -name "*.json" -type f 2>/dev/null || true)

    local secrets_found=false
    while IFS= read -r json_file; do
        if [[ -n "${json_file}" ]]; then
            if ! check_for_secrets "${json_file}"; then
                print_error "Possible secrets detected in: $(basename "${json_file}")"
                RECOMMENDATIONS+=("Remove secrets from ${json_file}")
                secrets_found=true
                ((ERRORS++))
            fi
        fi
    done <<< "${json_files}"

    if [[ "${secrets_found}" == false ]]; then
        print_success "No exposed secrets detected"
    fi

    # Check for suspicious permissions
    local executable_files
    executable_files=$(find "${PLUGIN_DIR}" -type f -executable 2>/dev/null || true)

    if [[ -n "${executable_files}" ]]; then
        print_info "Executable files found (verify permissions are intentional)"
    fi

    return 0
}

# ====================
# Reporting
# ====================

show_summary() {
    echo ""
    print_header "Validation Summary"

    # Calculate quality score
    local score
    score=$(calculate_quality_score ${ERRORS} ${WARNINGS} ${MISSING_RECOMMENDED})
    local rating
    rating=$(print_quality_rating ${score})
    local stars
    stars=$(print_star_rating ${score})

    echo "Quality Score: ${score}/100 - ${rating} ${stars}"
    echo ""
    echo "Results:"
    echo "  Errors:   ${ERRORS}"
    echo "  Warnings: ${WARNINGS}"
    echo ""

    if [[ ${ERRORS} -gt 0 ]]; then
        echo "Critical Issues (must fix):"
        local i=1
        for rec in "${RECOMMENDATIONS[@]}"; do
            if [[ $i -le ${ERRORS} ]]; then
                echo "  ${i}. ${rec}"
                ((i++))
            fi
        done
        echo ""
    fi

    if [[ ${#RECOMMENDATIONS[@]} -gt ${ERRORS} ]]; then
        echo "Recommendations:"
        local i=$((ERRORS + 1))
        for rec in "${RECOMMENDATIONS[@]:${ERRORS}}"; do
            echo "  ${i}. ${rec}"
            ((i++))
        done
        echo ""
    fi

    # Final status
    if [[ ${ERRORS} -gt 0 ]]; then
        print_error "Status: NEEDS FIXES - Address critical issues before publication"
        return 1
    elif [[ ${WARNINGS} -gt 5 ]]; then
        print_warning "Status: READY with warnings - Consider addressing for better quality"
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
    print_header "🔍 Validating Plugin: $(basename "${PLUGIN_DIR}")"

    # Check if JSON tool is available
    local tool
    tool=$(detect_json_tool)
    if [[ "${tool}" == "none" ]]; then
        print_error "No JSON parsing tool available (install jq or python3)"
        exit 1
    fi

    # Run validations
    validate_plugin_structure || true
    validate_plugin_metadata || true
    validate_commands
    validate_agents
    validate_hooks
    validate_security

    # Show summary
    show_summary
    exit $?
}

main "$@"
