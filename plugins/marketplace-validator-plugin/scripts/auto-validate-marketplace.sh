#!/usr/bin/env bash

# ============================================================================
# Marketplace Validator Plugin - Auto-Validate Marketplace Hook
# ============================================================================
# Purpose: Automatic marketplace validation on marketplace.json edits
# Version: 1.0.0
# License: MIT
# Trigger: PostToolUse (Write/Edit marketplace.json)
# ============================================================================

set -o errexit
set -o nounset
set -o pipefail

# Get script directory and source library
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/validate-lib.sh"

# Get the file that was edited from hook context
EDITED_FILE="${TOOL_RESULT_PATH:-}"
MARKETPLACE_FILE=""

# Find marketplace.json based on edited file
if [[ -n "${EDITED_FILE}" ]] && [[ -f "${EDITED_FILE}" ]]; then
    # Extract directory containing the edited file
    MARKETPLACE_DIR=$(dirname "${EDITED_FILE}")

    # If edited file is marketplace.json, validate it
    if [[ $(basename "${EDITED_FILE}") == "marketplace.json" ]]; then
        MARKETPLACE_FILE="${EDITED_FILE}"
    fi
fi

# If we couldn't determine the file, look for it
if [[ -z "${MARKETPLACE_FILE}" ]]; then
    if [[ -f ".claude-plugin/marketplace.json" ]]; then
        MARKETPLACE_FILE=".claude-plugin/marketplace.json"
    else
        # Not a marketplace edit, skip
        exit 0
    fi
fi

# Run quick validation
echo ""
print_info "📝 Marketplace edited - Running automatic validation..."
echo ""

if ! validate_json_syntax "${MARKETPLACE_FILE}"; then
    print_error "⚠️  Invalid JSON syntax detected in marketplace.json"
    print_info "Run: /validate-marketplace for detailed error information"
    exit 0  # Don't fail the edit, just warn
fi

# Check critical fields
local missing_critical=()

local name
name=$(json_get "${MARKETPLACE_FILE}" ".name")
[[ -z "${name}" ]] && missing_critical+=("name")

local owner_name
owner_name=$(json_get "${MARKETPLACE_FILE}" ".owner.name")
[[ -z "${owner_name}" ]] && missing_critical+=("owner.name")

if [[ ${#missing_critical[@]} -gt 0 ]]; then
    print_warning "⚠️  Missing critical fields: ${missing_critical[*]}"
    print_info "Run: /validate-marketplace for complete validation"
else
    print_success "✅ Basic validation passed"
    print_info "Tip: Run /validate-marketplace for comprehensive quality scoring"
fi

echo ""
exit 0  # Always succeed (non-blocking)
