#!/usr/bin/env bash

# ============================================================================
# Permission Checker - Audit file permissions for security issues
# ============================================================================
# Purpose: Detect world-writable files, overly permissive scripts, and permission issues
# Version: 1.0.0
# Usage: ./permission-checker.sh <path> <strict> <check_executables> <report_all>
# Returns: 0=all permissions correct, 1=issues found, 2=error
# ============================================================================

set -euo pipefail

# Source shared validation library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

if [[ -f "${PLUGIN_ROOT}/scripts/validate-lib.sh" ]]; then
    source "${PLUGIN_ROOT}/scripts/validate-lib.sh"
fi

# ============================================================================
# Configuration
# ============================================================================

PATH_TO_SCAN="${1:-.}"
STRICT="${2:-false}"
CHECK_EXECUTABLES="${3:-true}"
REPORT_ALL="${4:-false}"

ISSUES_FOUND=0
declare -a FINDINGS=()

# ============================================================================
# Permission Classification
# ============================================================================

get_permission_octal() {
    local file="$1"
    stat -f "%Op" "${file}" 2>/dev/null | sed 's/.*\([0-7][0-7][0-7][0-7]\)$/\1/' || \
    stat -c "%a" "${file}" 2>/dev/null || echo "0644"
}

get_permission_symbolic() {
    local file="$1"
    ls -ld "${file}" 2>/dev/null | awk '{print $1}' | tail -c 10
}

is_world_writable() {
    local perms="$1"
    [[ "${perms: -1}" =~ [2367] ]]
}

is_world_readable() {
    local perms="$1"
    [[ "${perms: -1}" =~ [4567] ]]
}

is_executable() {
    local perms="$1"
    [[ "${perms}" =~ [1357] ]]
}

# ============================================================================
# Severity Classification
# ============================================================================

get_issue_severity() {
    local issue_type="$1"
    local perms="$2"

    case "${issue_type}" in
        world_writable_executable)
            echo "critical"
            ;;
        world_writable)
            echo "critical"
            ;;
        missing_shebang)
            echo "high"
            ;;
        overly_permissive_sensitive)
            echo "high"
            ;;
        wrong_directory_perms)
            echo "medium"
            ;;
        non_executable_script)
            echo "medium"
            ;;
        inconsistent_perms)
            echo "low"
            ;;
        *)
            echo "low"
            ;;
    esac
}

# ============================================================================
# Shebang Validation
# ============================================================================

has_shebang() {
    local file="$1"

    if [[ ! -f "${file}" ]]; then
        return 1
    fi

    local first_line
    first_line=$(head -n 1 "${file}" 2>/dev/null || echo "")

    [[ "${first_line}" =~ ^#! ]]
}

get_expected_shebang() {
    local file="$1"
    local basename
    basename=$(basename "${file}")

    case "${basename}" in
        *.sh|*.bash)
            echo "#!/usr/bin/env bash"
            ;;
        *.py)
            echo "#!/usr/bin/env python3"
            ;;
        *.js)
            echo "#!/usr/bin/env node"
            ;;
        *.rb)
            echo "#!/usr/bin/env ruby"
            ;;
        *)
            echo ""
            ;;
    esac
}

# ============================================================================
# Expected Permissions
# ============================================================================

get_expected_permissions() {
    local file="$1"
    local basename
    basename=$(basename "${file}")
    local is_exec

    # Check if currently executable
    if [[ -x "${file}" ]]; then
        is_exec="true"
    else
        is_exec="false"
    fi

    # Sensitive files
    if [[ "${basename}" =~ ^\.env || "${basename}" =~ credentials || "${basename}" =~ secrets ]]; then
        echo "600"
        return
    fi

    # SSH/GPG files
    if [[ "${file}" =~ \.ssh/id_ || "${file}" =~ \.gnupg/ ]]; then
        if [[ "${basename}" =~ \.pub$ ]]; then
            echo "644"
        else
            echo "600"
        fi
        return
    fi

    # Scripts
    if [[ "${basename}" =~ \.(sh|bash|py|js|rb)$ ]]; then
        if [[ "${is_exec}" == "true" ]] || has_shebang "${file}"; then
            echo "755"
        else
            echo "644"
        fi
        return
    fi

    # Directories
    if [[ -d "${file}" ]]; then
        if [[ "${basename}" =~ ^\.ssh$ || "${basename}" =~ ^\.gnupg$ ]]; then
            echo "700"
        else
            echo "755"
        fi
        return
    fi

    # Default
    echo "644"
}

# ============================================================================
# Permission Checking
# ============================================================================

check_file_permissions() {
    local file="$1"
    local perms
    perms=$(get_permission_octal "${file}")
    local symbolic
    symbolic=$(get_permission_symbolic "${file}")
    local expected
    expected=$(get_expected_permissions "${file}")
    local basename
    basename=$(basename "${file}")

    # Skip certain directories
    if [[ "${file}" =~ (\.git|node_modules|vendor|dist|build)/ ]]; then
        return
    fi

    # CRITICAL: Check for 777 (world-writable and executable)
    if [[ "${perms}" == "0777" || "${perms}" == "777" ]]; then
        local issue_type="world_writable_executable"
        local severity
        severity=$(get_issue_severity "${issue_type}" "${perms}")
        FINDINGS+=("${severity}|${file}|${perms}|${symbolic}|${expected}|World-writable and executable|Anyone can modify and execute|chmod ${expected} \"${file}\"")
        ((ISSUES_FOUND++))
        return
    fi

    # CRITICAL: Check for 666 (world-writable)
    if [[ "${perms}" == "0666" || "${perms}" == "666" ]]; then
        local issue_type="world_writable"
        local severity
        severity=$(get_issue_severity "${issue_type}" "${perms}")
        FINDINGS+=("${severity}|${file}|${perms}|${symbolic}|${expected}|World-writable file|Anyone can modify content|chmod ${expected} \"${file}\"")
        ((ISSUES_FOUND++))
        return
    fi

    # Check if executable but missing shebang
    if [[ -f "${file}" && -x "${file}" && "${CHECK_EXECUTABLES}" == "true" ]]; then
        if [[ "${basename}" =~ \.(sh|bash|py|js|rb)$ ]]; then
            if ! has_shebang "${file}"; then
                local expected_shebang
                expected_shebang=$(get_expected_shebang "${file}")
                FINDINGS+=("high|${file}|${perms}|${symbolic}|${perms}|Executable without shebang|May not execute correctly|Add ${expected_shebang} to first line")
                ((ISSUES_FOUND++))
            fi
        fi
    fi

    # Check sensitive files
    if [[ "${basename}" =~ ^\.env || "${basename}" =~ credentials || "${basename}" =~ secrets ]]; then
        if is_world_readable "${perms}"; then
            FINDINGS+=("high|${file}|${perms}|${symbolic}|600|Sensitive file world-readable|Secrets visible to all users|chmod 600 \"${file}\"")
            ((ISSUES_FOUND++))
            return
        fi
        if [[ "${perms}" != "0600" && "${perms}" != "600" && "${STRICT}" == "true" ]]; then
            FINDINGS+=("medium|${file}|${perms}|${symbolic}|600|Sensitive file should be 600|Reduce permissions|chmod 600 \"${file}\"")
            ((ISSUES_FOUND++))
            return
        fi
    fi

    # Strict mode: Check for any discrepancies
    if [[ "${STRICT}" == "true" ]]; then
        if [[ "${perms}" != "0${expected}" && "${perms}" != "${expected}" ]]; then
            # Check if it's a minor discrepancy
            if [[ "${perms}" =~ ^0?775$ && "${expected}" == "755" ]]; then
                FINDINGS+=("medium|${file}|${perms}|${symbolic}|${expected}|Group-writable (strict mode)|Remove group write|chmod ${expected} \"${file}\"")
                ((ISSUES_FOUND++))
            elif [[ "${perms}" =~ ^0?755$ && "${expected}" == "644" ]]; then
                FINDINGS+=("low|${file}|${perms}|${symbolic}|${expected}|Executable but should not be|Remove executable bit|chmod ${expected} \"${file}\"")
                ((ISSUES_FOUND++))
            fi
        fi
    fi

    # Report all mode
    if [[ "${REPORT_ALL}" == "true" ]]; then
        if [[ "${perms}" == "0${expected}" || "${perms}" == "${expected}" ]]; then
            FINDINGS+=("info|${file}|${perms}|${symbolic}|${expected}|Permissions correct|N/A|N/A")
        fi
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    # Validate path
    if [[ ! -e "${PATH_TO_SCAN}" ]]; then
        echo "ERROR: Path does not exist: ${PATH_TO_SCAN}" >&2
        exit 2
    fi

    echo "File Permission Audit Results"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Path: ${PATH_TO_SCAN}"
    echo "Strict Mode: ${STRICT}"
    echo "Check Executables: ${CHECK_EXECUTABLES}"
    echo ""

    # Scan files
    local files_checked=0

    if [[ -f "${PATH_TO_SCAN}" ]]; then
        check_file_permissions "${PATH_TO_SCAN}"
        ((files_checked++))
    elif [[ -d "${PATH_TO_SCAN}" ]]; then
        while IFS= read -r -d '' file; do
            check_file_permissions "${file}"
            ((files_checked++))
        done < <(find "${PATH_TO_SCAN}" -print0 2>/dev/null)
    fi

    echo "Files Checked: ${files_checked}"
    echo ""

    # Report findings
    if [[ ${ISSUES_FOUND} -eq 0 ]]; then
        echo "✅ SUCCESS: All file permissions correct"
        echo "No permission issues detected"
        exit 0
    fi

    echo "⚠️  PERMISSION ISSUES DETECTED: ${ISSUES_FOUND}"
    echo ""

    # Group by severity
    local critical_count=0
    local high_count=0
    local medium_count=0
    local low_count=0

    for finding in "${FINDINGS[@]}"; do
        IFS='|' read -r severity file perms symbolic expected issue risk fix <<< "${finding}"
        case "${severity}" in
            critical) ((critical_count++)) ;;
            high) ((high_count++)) ;;
            medium) ((medium_count++)) ;;
            low) ((low_count++)) ;;
            info) ;; # Don't count info
        esac
    done

    # Print findings by severity
    if [[ ${critical_count} -gt 0 ]]; then
        echo "CRITICAL Issues (${critical_count}):"
        for finding in "${FINDINGS[@]}"; do
            IFS='|' read -r severity file perms symbolic expected issue risk fix <<< "${finding}"
            if [[ "${severity}" == "critical" ]]; then
                echo "  ❌ ${file} (${perms})"
                echo "     Current: ${symbolic} (${perms})"
                echo "     Issue: ${issue}"
                echo "     Risk: ${risk}"
                echo "     Fix: ${fix}"
                echo ""
            fi
        done
    fi

    if [[ ${high_count} -gt 0 ]]; then
        echo "HIGH Issues (${high_count}):"
        for finding in "${FINDINGS[@]}"; do
            IFS='|' read -r severity file perms symbolic expected issue risk fix <<< "${finding}"
            if [[ "${severity}" == "high" ]]; then
                echo "  ⚠️  ${file} (${perms})"
                echo "     Issue: ${issue}"
                echo "     Fix: ${fix}"
                echo ""
            fi
        done
    fi

    if [[ ${medium_count} -gt 0 ]]; then
        echo "MEDIUM Issues (${medium_count}):"
        for finding in "${FINDINGS[@]}"; do
            IFS='|' read -r severity file perms symbolic expected issue risk fix <<< "${finding}"
            if [[ "${severity}" == "medium" ]]; then
                echo "  💡 ${file} (${perms})"
                echo "     Recommendation: ${issue}"
                echo "     Fix: ${fix}"
                echo ""
            fi
        done
    fi

    echo "Summary:"
    echo "  Critical: ${critical_count}"
    echo "  High: ${high_count}"
    echo "  Medium: ${medium_count}"
    echo "  Low: ${low_count}"
    echo ""

    if [[ ${critical_count} -gt 0 ]]; then
        echo "Action Required: FIX IMMEDIATELY"
    elif [[ ${high_count} -gt 0 ]]; then
        echo "Action Required: YES"
    else
        echo "Action Required: REVIEW"
    fi

    exit 1
}

main "$@"
