#!/usr/bin/env bash

# ============================================================================
# Target Detector Script
# ============================================================================
# Purpose: Auto-detect if target is a marketplace, plugin, or both
# Version: 1.0.0
# Usage: ./target-detector.sh <path>
# Returns: 0=success, 1=error, 2=unknown_target
# ============================================================================

set -euo pipefail

# ====================
# Configuration
# ====================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TARGET_PATH="${1:-.}"

# ====================
# Output Functions
# ====================

print_json() {
    local target_type="$1"
    local confidence="$2"
    shift 2
    local files=("$@")

    cat <<EOF
{
  "target_type": "${target_type}",
  "path": "$(cd "${TARGET_PATH}" && pwd)",
  "files_found": [$(printf '"%s",' "${files[@]}" | sed 's/,$//')],
  "confidence": "${confidence}"
}
EOF
}

# ====================
# Detection Logic
# ====================

detect_target() {
    local path="$1"

    # Verify path exists
    if [[ ! -d "${path}" ]]; then
        echo "Error: Path does not exist: ${path}" >&2
        return 1
    fi

    # Check for .claude-plugin directory
    if [[ ! -d "${path}/.claude-plugin" ]]; then
        echo "Error: No .claude-plugin directory found at ${path}" >&2
        echo "This does not appear to be a plugin or marketplace." >&2
        return 2
    fi

    # Detect manifest files
    local marketplace_json="${path}/.claude-plugin/marketplace.json"
    local plugin_json="${path}/plugin.json"

    local has_marketplace=false
    local has_plugin=false
    local files_found=()

    if [[ -f "${marketplace_json}" ]]; then
        has_marketplace=true
        files_found+=("marketplace.json")
    fi

    if [[ -f "${plugin_json}" ]]; then
        has_plugin=true
        files_found+=("plugin.json")
    fi

    # Determine target type
    if [[ "${has_marketplace}" == "true" ]] && [[ "${has_plugin}" == "true" ]]; then
        print_json "multi-target" "high" "${files_found[@]}"
        return 0
    elif [[ "${has_marketplace}" == "true" ]]; then
        print_json "marketplace" "high" "${files_found[@]}"
        return 0
    elif [[ "${has_plugin}" == "true" ]]; then
        print_json "plugin" "high" "${files_found[@]}"
        return 0
    else
        print_json "unknown" "low" "${files_found[@]}"
        echo "Error: .claude-plugin directory exists but no manifest files found" >&2
        return 2
    fi
}

# ====================
# Main Execution
# ====================

main() {
    detect_target "${TARGET_PATH}"
}

# Run main function
main "$@"
