#!/usr/bin/env bash

# ============================================================================
# File Scanner - Detect dangerous files and sensitive configurations
# ============================================================================
# Purpose: Identify files that should not be committed to version control
# Version: 1.0.0
# Usage: ./file-scanner.sh <path> <patterns> <include_hidden> <check_gitignore>
# Returns: 0=no dangerous files, 1=dangerous files found, 2=error
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
PATTERNS="${2:-all}"
INCLUDE_HIDDEN="${3:-true}"
CHECK_GITIGNORE="${4:-true}"

DANGEROUS_FILES_FOUND=0
declare -a FINDINGS=()

# ============================================================================
# Dangerous File Pattern Definitions
# ============================================================================

# Environment Files (CRITICAL)
declare -a ENV_PATTERNS=(
    ".env"
    ".env.local"
    ".env.production"
    ".env.development"
    ".env.staging"
    ".env.test"
    "env.sh"
    "setenv.sh"
    ".envrc"
)

# Credential Files (CRITICAL)
declare -a CREDENTIAL_PATTERNS=(
    "*credentials*"
    "*secrets*"
    "*password*"
    ".aws/credentials"
    ".azure/credentials"
    ".gcp/credentials.json"
    "gcloud/credentials"
    "service-account*.json"
)

# Private Keys (CRITICAL)
declare -a KEY_PATTERNS=(
    "id_rsa"
    "id_dsa"
    "id_ed25519"
    "id_ecdsa"
    "*.pem"
    "*.key"
    "*.p12"
    "*.pfx"
    "*.jks"
    "*.keystore"
    ".gnupg/*"
    ".ssh/id_*"
)

# Database Files (HIGH)
declare -a DATABASE_PATTERNS=(
    "*.db"
    "*.sqlite"
    "*.sqlite3"
    "dump.sql"
    "*backup*.sql"
    "*.mdb"
    "*.accdb"
)

# Configuration Files (MEDIUM)
declare -a CONFIG_PATTERNS=(
    "config/database.yml"
    "appsettings.json"
    "wp-config.php"
    "settings.py"
    ".htpasswd"
)

# Backup Files (MEDIUM)
declare -a BACKUP_PATTERNS=(
    "*.bak"
    "*.backup"
    "*.old"
    "*.orig"
    "*.copy"
    "*~"
    "*.swp"
    "*.swo"
)

# Log Files (LOW)
declare -a LOG_PATTERNS=(
    "*.log"
    "debug.log"
    "error.log"
)

# ============================================================================
# Severity Classification
# ============================================================================

get_file_severity() {
    local filename="$1"

    # CRITICAL: Environment, credentials, keys
    for pattern in "${ENV_PATTERNS[@]}" "${CREDENTIAL_PATTERNS[@]}" "${KEY_PATTERNS[@]}"; do
        if [[ "${filename}" == ${pattern} ]] || [[ "${filename}" =~ ${pattern//\*/.*} ]]; then
            echo "critical"
            return
        fi
    done

    # HIGH: Databases
    for pattern in "${DATABASE_PATTERNS[@]}"; do
        if [[ "${filename}" == ${pattern} ]] || [[ "${filename}" =~ ${pattern//\*/.*} ]]; then
            echo "high"
            return
        fi
    done

    # MEDIUM: Config, backups
    for pattern in "${CONFIG_PATTERNS[@]}" "${BACKUP_PATTERNS[@]}"; do
        if [[ "${filename}" == ${pattern} ]] || [[ "${filename}" =~ ${pattern//\*/.*} ]]; then
            echo "medium"
            return
        fi
    done

    # LOW: Logs
    for pattern in "${LOG_PATTERNS[@]}"; do
        if [[ "${filename}" == ${pattern} ]] || [[ "${filename}" =~ ${pattern//\*/.*} ]]; then
            echo "low"
            return
        fi
    done

    echo "unknown"
}

get_file_type() {
    local filename="$1"

    for pattern in "${ENV_PATTERNS[@]}"; do
        if [[ "${filename}" == ${pattern} ]] || [[ "${filename}" =~ ${pattern//\*/.*} ]]; then
            echo "Environment File"
            return
        fi
    done

    for pattern in "${CREDENTIAL_PATTERNS[@]}"; do
        if [[ "${filename}" == ${pattern} ]] || [[ "${filename}" =~ ${pattern//\*/.*} ]]; then
            echo "Credential File"
            return
        fi
    done

    for pattern in "${KEY_PATTERNS[@]}"; do
        if [[ "${filename}" == ${pattern} ]] || [[ "${filename}" =~ ${pattern//\*/.*} ]]; then
            echo "Private Key"
            return
        fi
    done

    for pattern in "${DATABASE_PATTERNS[@]}"; do
        if [[ "${filename}" == ${pattern} ]] || [[ "${filename}" =~ ${pattern//\*/.*} ]]; then
            echo "Database File"
            return
        fi
    done

    for pattern in "${CONFIG_PATTERNS[@]}"; do
        if [[ "${filename}" == ${pattern} ]] || [[ "${filename}" =~ ${pattern//\*/.*} ]]; then
            echo "Configuration File"
            return
        fi
    done

    for pattern in "${BACKUP_PATTERNS[@]}"; do
        if [[ "${filename}" == ${pattern} ]] || [[ "${filename}" =~ ${pattern//\*/.*} ]]; then
            echo "Backup File"
            return
        fi
    done

    for pattern in "${LOG_PATTERNS[@]}"; do
        if [[ "${filename}" == ${pattern} ]] || [[ "${filename}" =~ ${pattern//\*/.*} ]]; then
            echo "Log File"
            return
        fi
    done

    echo "Unknown"
}

get_risk_description() {
    local file_type="$1"

    case "${file_type}" in
        "Environment File")
            echo "Contains secrets, API keys, and configuration"
            ;;
        "Credential File")
            echo "Direct access credentials"
            ;;
        "Private Key")
            echo "Authentication keys"
            ;;
        "Database File")
            echo "May contain sensitive user data"
            ;;
        "Configuration File")
            echo "May contain hardcoded secrets"
            ;;
        "Backup File")
            echo "May contain previous versions with secrets"
            ;;
        "Log File")
            echo "May contain leaked sensitive information"
            ;;
        *)
            echo "Unknown risk"
            ;;
    esac
}

get_remediation() {
    local file_type="$1"
    local in_gitignore="$2"

    if [[ "${in_gitignore}" == "false" ]]; then
        echo "Add to .gitignore, remove from git history, rotate credentials"
    else
        echo "Verify .gitignore is working, review if file should exist"
    fi
}

# ============================================================================
# .gitignore Checking
# ============================================================================

is_in_gitignore() {
    local file="$1"
    local gitignore="${PATH_TO_SCAN}/.gitignore"

    if [[ ! -f "${gitignore}" ]]; then
        echo "false"
        return
    fi

    # Simple check - does not handle all gitignore patterns perfectly
    local basename
    basename=$(basename "${file}")
    local dirname
    dirname=$(dirname "${file}")

    if grep -qF "${basename}" "${gitignore}" 2>/dev/null; then
        echo "true"
        return
    fi

    if grep -qF "${file}" "${gitignore}" 2>/dev/null; then
        echo "true"
        return
    fi

    # Check pattern matches
    while IFS= read -r pattern; do
        # Skip comments and empty lines
        [[ "${pattern}" =~ ^#.*$ || -z "${pattern}" ]] && continue

        # Simple pattern matching (not complete gitignore spec)
        if [[ "${basename}" == ${pattern} ]]; then
            echo "true"
            return
        fi
    done < "${gitignore}"

    echo "false"
}

# ============================================================================
# File Scanning
# ============================================================================

should_check_pattern() {
    local filename="$1"

    if [[ "${PATTERNS}" == "all" ]]; then
        return 0
    fi

    case "${PATTERNS}" in
        *env*)
            for pattern in "${ENV_PATTERNS[@]}"; do
                [[ "${filename}" == ${pattern} ]] && return 0
            done
            ;;
        *credentials*)
            for pattern in "${CREDENTIAL_PATTERNS[@]}"; do
                [[ "${filename}" == ${pattern} ]] && return 0
            done
            ;;
        *keys*)
            for pattern in "${KEY_PATTERNS[@]}"; do
                [[ "${filename}" == ${pattern} ]] && return 0
            done
            ;;
    esac

    return 1
}

scan_file() {
    local filepath="$1"
    local filename
    filename=$(basename "${filepath}")

    # Check if hidden file (skip if not including hidden)
    if [[ "${filename}" =~ ^\. && "${INCLUDE_HIDDEN}" != "true" ]]; then
        return
    fi

    # Skip certain directories
    if [[ "${filepath}" =~ (\.git|node_modules|vendor|dist|build)/ ]]; then
        return
    fi

    # Check if file matches dangerous patterns
    local severity
    severity=$(get_file_severity "${filename}")

    if [[ "${severity}" == "unknown" ]]; then
        return
    fi

    if ! should_check_pattern "${filename}"; then
        return
    fi

    # Get file details
    local file_type
    file_type=$(get_file_type "${filename}")
    local size
    size=$(stat -f%z "${filepath}" 2>/dev/null || stat -c%s "${filepath}" 2>/dev/null || echo "0")
    local in_gitignore="false"

    if [[ "${CHECK_GITIGNORE}" == "true" ]]; then
        in_gitignore=$(is_in_gitignore "${filepath}")
    fi

    local risk
    risk=$(get_risk_description "${file_type}")
    local remediation
    remediation=$(get_remediation "${file_type}" "${in_gitignore}")

    FINDINGS+=("${severity}|${filepath}|${file_type}|${size}|${in_gitignore}|${risk}|${remediation}")
    ((DANGEROUS_FILES_FOUND++))
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    # Validate path
    if [[ ! -d "${PATH_TO_SCAN}" ]]; then
        echo "ERROR: Path is not a directory: ${PATH_TO_SCAN}" >&2
        exit 2
    fi

    echo "Dangerous Files Scan Results"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Path: ${PATH_TO_SCAN}"
    echo "Include Hidden: ${INCLUDE_HIDDEN}"
    echo "Check .gitignore: ${CHECK_GITIGNORE}"
    echo ""

    # Scan files
    local files_scanned=0

    if [[ "${INCLUDE_HIDDEN}" == "true" ]]; then
        while IFS= read -r -d '' file; do
            scan_file "${file}"
            ((files_scanned++))
        done < <(find "${PATH_TO_SCAN}" -type f -print0 2>/dev/null)
    else
        while IFS= read -r -d '' file; do
            scan_file "${file}"
            ((files_scanned++))
        done < <(find "${PATH_TO_SCAN}" -type f -not -path '*/.*' -print0 2>/dev/null)
    fi

    echo "Files Scanned: ${files_scanned}"
    echo ""

    # Report findings
    if [[ ${DANGEROUS_FILES_FOUND} -eq 0 ]]; then
        echo "✅ SUCCESS: No dangerous files detected"
        echo "All files safe"
        exit 0
    fi

    echo "⚠️  DANGEROUS FILES DETECTED: ${DANGEROUS_FILES_FOUND}"
    echo ""

    # Check .gitignore status
    if [[ "${CHECK_GITIGNORE}" == "true" && ! -f "${PATH_TO_SCAN}/.gitignore" ]]; then
        echo "⚠️  WARNING: No .gitignore file found"
        echo "   Recommendation: Create .gitignore to prevent committing sensitive files"
        echo ""
    fi

    # Group by severity
    local critical_count=0
    local high_count=0
    local medium_count=0
    local low_count=0
    local not_in_gitignore=0

    for finding in "${FINDINGS[@]}"; do
        IFS='|' read -r severity filepath file_type size in_gitignore risk remediation <<< "${finding}"
        case "${severity}" in
            critical) ((critical_count++)) ;;
            high) ((high_count++)) ;;
            medium) ((medium_count++)) ;;
            low) ((low_count++)) ;;
        esac
        [[ "${in_gitignore}" == "false" ]] && ((not_in_gitignore++))
    done

    # Print findings by severity
    if [[ ${critical_count} -gt 0 ]]; then
        echo "CRITICAL Files (${critical_count}):"
        for finding in "${FINDINGS[@]}"; do
            IFS='|' read -r severity filepath file_type size in_gitignore risk remediation <<< "${finding}"
            if [[ "${severity}" == "critical" ]]; then
                # Convert size to human readable
                local size_human
                if [[ ${size} -ge 1048576 ]]; then
                    size_human="$(( size / 1048576 )) MB"
                elif [[ ${size} -ge 1024 ]]; then
                    size_human="$(( size / 1024 )) KB"
                else
                    size_human="${size} bytes"
                fi

                echo "  ❌ ${filepath} (${size_human})"
                echo "     Type: ${file_type}"
                echo "     Risk: ${risk}"
                if [[ "${CHECK_GITIGNORE}" == "true" ]]; then
                    if [[ "${in_gitignore}" == "true" ]]; then
                        echo "     Status: In .gitignore ✓"
                    else
                        echo "     Status: NOT in .gitignore ⚠️"
                    fi
                fi
                echo "     Remediation: ${remediation}"
                echo ""
            fi
        done
    fi

    if [[ ${high_count} -gt 0 ]]; then
        echo "HIGH Files (${high_count}):"
        for finding in "${FINDINGS[@]}"; do
            IFS='|' read -r severity filepath file_type size in_gitignore risk remediation <<< "${finding}"
            if [[ "${severity}" == "high" ]]; then
                local size_human
                if [[ ${size} -ge 1048576 ]]; then
                    size_human="$(( size / 1048576 )) MB"
                elif [[ ${size} -ge 1024 ]]; then
                    size_human="$(( size / 1024 )) KB"
                else
                    size_human="${size} bytes"
                fi

                echo "  ⚠️  ${filepath} (${size_human})"
                echo "     Type: ${file_type}"
                if [[ "${CHECK_GITIGNORE}" == "true" ]]; then
                    echo "     Status: $([ "${in_gitignore}" == "true" ] && echo "In .gitignore ✓" || echo "NOT in .gitignore ⚠️")"
                fi
                echo ""
            fi
        done
    fi

    if [[ ${medium_count} -gt 0 ]]; then
        echo "MEDIUM Files (${medium_count}):"
        for finding in "${FINDINGS[@]}"; do
            IFS='|' read -r severity filepath file_type size in_gitignore risk remediation <<< "${finding}"
            if [[ "${severity}" == "medium" ]]; then
                echo "  💡 ${filepath}"
                echo "     Type: ${file_type}"
                echo ""
            fi
        done
    fi

    echo "Summary:"
    echo "  Critical: ${critical_count}"
    echo "  High: ${high_count}"
    echo "  Medium: ${medium_count}"
    echo "  Low: ${low_count}"
    if [[ "${CHECK_GITIGNORE}" == "true" ]]; then
        echo "  Not in .gitignore: ${not_in_gitignore}"
    fi
    echo ""
    echo "Action Required: $([ ${critical_count} -gt 0 ] || [ ${not_in_gitignore} -gt 0 ] && echo "YES" || echo "REVIEW")"

    exit 1
}

main "$@"
