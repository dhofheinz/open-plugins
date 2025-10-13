#!/usr/bin/env bash

# ============================================================================
# Marketplace Validator Plugin - Auto-Validate Plugin Hook
# ============================================================================
# Purpose: Automatic plugin validation on plugin.json edits
# Version: 1.0.0
# License: MIT
# Trigger: PostToolUse (Write/Edit plugin.json)
# ============================================================================

set -o errexit
set -o nounset
set -o pipefail

# Get script directory and source library
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/validate-lib.sh"

# Get the file that was edited from hook context
EDITED_FILE="${TOOL_RESULT_PATH:-}"
PLUGIN_FILE=""
PLUGIN_DIR=""

# Find plugin.json based on edited file
if [[ -n "${EDITED_FILE}" ]] && [[ -f "${EDITED_FILE}" ]]; then
    # If edited file is plugin.json, validate it
    if [[ $(basename "${EDITED_FILE}") == "plugin.json" ]]; then
        PLUGIN_FILE="${EDITED_FILE}"
        PLUGIN_DIR=$(dirname "$(dirname "${EDITED_FILE}")")
    fi
fi

# If we couldn't determine the file, look for it
if [[ -z "${PLUGIN_FILE}" ]]; then
    if [[ -f ".claude-plugin/plugin.json" ]]; then
        PLUGIN_FILE=".claude-plugin/plugin.json"
        PLUGIN_DIR="."
    else
        # Not a plugin edit, skip
        exit 0
    fi
fi

# Run quick validation
echo ""
print_info "📝 Plugin manifest edited - Running automatic validation..."
echo ""

if ! validate_json_syntax "${PLUGIN_FILE}"; then
    print_error "⚠️  Invalid JSON syntax detected in plugin.json"
    print_info "Run: /validate-plugin for detailed error information"
    exit 0  # Don't fail the edit, just warn
fi

# Check critical fields
local missing_critical=()

local name version description author license

name=$(json_get "${PLUGIN_FILE}" ".name")
[[ -z "${name}" ]] && missing_critical+=("name")

version=$(json_get "${PLUGIN_FILE}" ".version")
[[ -z "${version}" ]] && missing_critical+=("version")

description=$(json_get "${PLUGIN_FILE}" ".description")
[[ -z "${description}" ]] && missing_critical+=("description")

author=$(json_get "${PLUGIN_FILE}" ".author")
[[ -z "${author}" ]] && missing_critical+=("author")

license=$(json_get "${PLUGIN_FILE}" ".license")
[[ -z "${license}" ]] && missing_critical+=("license")

if [[ ${#missing_critical[@]} -gt 0 ]]; then
    print_warning "⚠️  Missing required fields: ${missing_critical[*]}"
    print_info "Run: /validate-plugin for complete validation"
else
    # Quick format checks
    local format_issues=()

    if [[ -n "${name}" ]] && ! validate_name_format "${name}"; then
        format_issues+=("name format")
    fi

    if [[ -n "${version}" ]] && ! validate_semver "${version}"; then
        format_issues+=("version format")
    fi

    if [[ ${#format_issues[@]} -gt 0 ]]; then
        print_warning "⚠️  Format issues: ${format_issues[*]}"
        print_info "Run: /validate-plugin for details"
    else
        print_success "✅ Basic validation passed"
        print_info "Tip: Run /validate-plugin for comprehensive quality scoring"
    fi
fi

echo ""
exit 0  # Always succeed (non-blocking)
