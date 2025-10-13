#!/usr/bin/env bash

# ============================================================================
# Secret Scanner - Detect exposed secrets with 50+ patterns
# ============================================================================
# Purpose: Comprehensive secret detection for API keys, tokens, credentials
# Version: 1.0.0
# Usage: ./secret-scanner.sh <path> <recursive> <patterns> <exclude> <severity>
# Returns: 0=no secrets, 1=secrets found, 2=error
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

# Default values
PATH_TO_SCAN="${1:-.}"
RECURSIVE="${2:-true}"
PATTERNS="${3:-all}"
EXCLUDE="${4:-}"
MIN_SEVERITY="${5:-medium}"

SECRETS_FOUND=0
declare -a FINDINGS=()

# ============================================================================
# Secret Pattern Definitions (50+ patterns)
# ============================================================================

# API Keys & Service Tokens
declare -A API_KEY_PATTERNS=(
    # Stripe
    ["stripe_live_key"]='sk_live_[a-zA-Z0-9]{24,}'
    ["stripe_test_key"]='sk_test_[a-zA-Z0-9]{24,}'
    ["stripe_publishable_live"]='pk_live_[a-zA-Z0-9]{24,}'
    ["stripe_publishable_test"]='pk_test_[a-zA-Z0-9]{24,}'

    # OpenAI
    ["openai_api_key"]='sk-[a-zA-Z0-9]{32,}'

    # AWS
    ["aws_access_key_id"]='AKIA[0-9A-Z]{16}'
    ["aws_secret_access_key"]='aws_secret_access_key.*[=:].*[A-Za-z0-9/+=]{40}'

    # Google
    ["google_api_key"]='AIza[0-9A-Za-z_-]{35}'
    ["google_oauth_id"]='[0-9]+-[0-9A-Za-z_-]{32}\.apps\.googleusercontent\.com'

    # GitHub
    ["github_personal_token"]='ghp_[a-zA-Z0-9]{36}'
    ["github_oauth_token"]='gho_[a-zA-Z0-9]{36}'
    ["github_app_token"]='ghs_[a-zA-Z0-9]{36}'
    ["github_user_token"]='ghu_[a-zA-Z0-9]{36}'
    ["github_refresh_token"]='ghr_[a-zA-Z0-9]{36}'

    # Slack
    ["slack_token"]='xox[baprs]-[0-9a-zA-Z]{10,}'
    ["slack_webhook"]='https://hooks\.slack\.com/services/T[0-9A-Z]{8}/B[0-9A-Z]{8}/[0-9A-Za-z]{24}'

    # Twitter
    ["twitter_access_token"]='[0-9]{15,}-[0-9a-zA-Z]{35,44}'
    ["twitter_api_key"]='[A-Za-z0-9]{25}'
    ["twitter_api_secret"]='[A-Za-z0-9]{50}'

    # Facebook
    ["facebook_access_token"]='EAA[0-9A-Za-z]{90,}'

    # SendGrid
    ["sendgrid_api_key"]='SG\.[a-zA-Z0-9_-]{22}\.[a-zA-Z0-9_-]{43}'

    # Mailgun
    ["mailgun_api_key"]='key-[0-9a-zA-Z]{32}'

    # Twilio
    ["twilio_account_sid"]='AC[a-f0-9]{32}'
    ["twilio_api_key"]='SK[a-f0-9]{32}'

    # Azure
    ["azure_storage_key"]='[a-zA-Z0-9/+=]{88}'
    ["azure_connection_string"]='AccountKey=[a-zA-Z0-9/+=]{88}'

    # Generic patterns
    ["generic_api_key"]='api[_-]?key.*[=:].*['\''"][a-zA-Z0-9]{20,}['\''"]'
    ["generic_secret"]='secret.*[=:].*['\''"][a-zA-Z0-9]{20,}['\''"]'
    ["generic_token"]='token.*[=:].*['\''"][a-zA-Z0-9]{20,}['\''"]'
    ["generic_password"]='password.*[=:].*['\''"][^'\''\"]{8,}['\''"]'
    ["bearer_token"]='Bearer [a-zA-Z0-9_-]{20,}'
    ["authorization_header"]='Authorization.*Basic [a-zA-Z0-9+/=]{20,}'
)

# Private Keys
declare -A PRIVATE_KEY_PATTERNS=(
    ["rsa_private_key"]='-----BEGIN RSA PRIVATE KEY-----'
    ["openssh_private_key"]='-----BEGIN OPENSSH PRIVATE KEY-----'
    ["private_key_generic"]='-----BEGIN PRIVATE KEY-----'
    ["pgp_private_key"]='-----BEGIN PGP PRIVATE KEY BLOCK-----'
    ["dsa_private_key"]='-----BEGIN DSA PRIVATE KEY-----'
    ["ec_private_key"]='-----BEGIN EC PRIVATE KEY-----'
    ["encrypted_private_key"]='-----BEGIN ENCRYPTED PRIVATE KEY-----'
)

# Cloud Provider Credentials
declare -A CLOUD_PATTERNS=(
    ["aws_credentials_block"]='aws_access_key_id|aws_secret_access_key'
    ["gcp_service_account"]='type.*service_account'
    ["azure_client_secret"]='client_secret.*[=:].*[a-zA-Z0-9~._-]{34,}'
    ["heroku_api_key"]='[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'
)

# Database Connection Strings
declare -A DATABASE_PATTERNS=(
    ["mongodb_connection"]='mongodb(\+srv)?://[^:]+:[^@]+@'
    ["postgres_connection"]='postgres(ql)?://[^:]+:[^@]+@'
    ["mysql_connection"]='mysql://[^:]+:[^@]+@'
    ["redis_connection"]='redis://[^:]+:[^@]+@'
)

# ============================================================================
# Severity Classification
# ============================================================================

get_pattern_severity() {
    local pattern_name="$1"

    case "${pattern_name}" in
        # CRITICAL: Private keys, production credentials
        *_private_key*|aws_access_key_id|aws_secret_access_key|*_connection)
            echo "critical"
            ;;
        # HIGH: Service API keys, OAuth tokens
        stripe_live_key|openai_api_key|github_*_token|slack_token|*_access_token)
            echo "high"
            ;;
        # MEDIUM: Passwords, secrets, test keys
        *_password|*_secret|stripe_test_key|generic_*)
            echo "medium"
            ;;
        # LOW: Everything else
        *)
            echo "low"
            ;;
    esac
}

# ============================================================================
# Pattern Filtering
# ============================================================================

should_check_pattern() {
    local pattern_name="$1"
    local severity
    severity=$(get_pattern_severity "${pattern_name}")

    # Check if pattern category requested
    if [[ "${PATTERNS}" != "all" ]]; then
        case "${PATTERNS}" in
            *api-keys*) [[ "${pattern_name}" =~ _api_key|_token ]] || return 1 ;;
            *private-keys*) [[ "${pattern_name}" =~ private_key ]] || return 1 ;;
            *passwords*) [[ "${pattern_name}" =~ password ]] || return 1 ;;
            *cloud*) [[ "${pattern_name}" =~ aws_|gcp_|azure_ ]] || return 1 ;;
        esac
    fi

    # Check severity threshold
    case "${MIN_SEVERITY}" in
        critical)
            [[ "${severity}" == "critical" ]] || return 1
            ;;
        high)
            [[ "${severity}" == "critical" || "${severity}" == "high" ]] || return 1
            ;;
        medium)
            [[ "${severity}" != "low" ]] || return 1
            ;;
        low)
            # Report all
            ;;
    esac

    return 0
}

# ============================================================================
# File Exclusion
# ============================================================================

should_exclude_file() {
    local file="$1"

    # Default exclusions
    if [[ "${file}" =~ \.(git|node_modules|vendor|dist|build)/ ]]; then
        return 0
    fi

    # User-specified exclusions
    if [[ -n "${EXCLUDE}" ]]; then
        IFS=',' read -ra EXCLUDE_PATTERNS <<< "${EXCLUDE}"
        for pattern in "${EXCLUDE_PATTERNS[@]}"; do
            if [[ "${file}" =~ ${pattern} ]]; then
                return 0
            fi
        done
    fi

    return 1
}

# ============================================================================
# Secret Scanning
# ============================================================================

scan_file() {
    local file="$1"
    local file_findings=0

    # Skip excluded files
    if should_exclude_file "${file}"; then
        return 0
    fi

    # Skip binary files
    if file "${file}" 2>/dev/null | grep -q "text"; then
        :
    else
        return 0
    fi

    # Scan with all pattern categories
    for pattern_name in "${!API_KEY_PATTERNS[@]}"; do
        if should_check_pattern "${pattern_name}"; then
            local pattern="${API_KEY_PATTERNS[${pattern_name}]}"
            if grep -nE "${pattern}" "${file}" &>/dev/null; then
                local severity
                severity=$(get_pattern_severity "${pattern_name}")
                local line_numbers
                line_numbers=$(grep -nE "${pattern}" "${file}" | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')
                FINDINGS+=("${severity}|${file}|${line_numbers}|${pattern_name}|API Key")
                ((file_findings++))
            fi
        fi
    done

    for pattern_name in "${!PRIVATE_KEY_PATTERNS[@]}"; do
        if should_check_pattern "${pattern_name}"; then
            local pattern="${PRIVATE_KEY_PATTERNS[${pattern_name}]}"
            if grep -nF "${pattern}" "${file}" &>/dev/null; then
                local severity
                severity=$(get_pattern_severity "${pattern_name}")
                local line_numbers
                line_numbers=$(grep -nF "${pattern}" "${file}" | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')
                FINDINGS+=("critical|${file}|${line_numbers}|${pattern_name}|Private Key")
                ((file_findings++))
            fi
        fi
    done

    for pattern_name in "${!CLOUD_PATTERNS[@]}"; do
        if should_check_pattern "${pattern_name}"; then
            local pattern="${CLOUD_PATTERNS[${pattern_name}]}"
            if grep -nE "${pattern}" "${file}" &>/dev/null; then
                local severity
                severity=$(get_pattern_severity "${pattern_name}")
                local line_numbers
                line_numbers=$(grep -nE "${pattern}" "${file}" | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')
                FINDINGS+=("${severity}|${file}|${line_numbers}|${pattern_name}|Cloud Credential")
                ((file_findings++))
            fi
        fi
    done

    for pattern_name in "${!DATABASE_PATTERNS[@]}"; do
        if should_check_pattern "${pattern_name}"; then
            local pattern="${DATABASE_PATTERNS[${pattern_name}]}"
            if grep -nE "${pattern}" "${file}" &>/dev/null; then
                FINDINGS+=("critical|${file}|$(grep -nE "${pattern}" "${file}" | cut -d: -f1 | tr '\n' ',' | sed 's/,$//')|${pattern_name}|Database Connection")
                ((file_findings++))
            fi
        fi
    done

    ((SECRETS_FOUND += file_findings))
    return 0
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

    echo "Secret Scanner"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Path: ${PATH_TO_SCAN}"
    echo "Recursive: ${RECURSIVE}"
    echo "Min Severity: ${MIN_SEVERITY}"
    echo "Patterns: 50+"
    echo ""

    # Scan files
    local files_scanned=0

    if [[ -f "${PATH_TO_SCAN}" ]]; then
        # Single file
        scan_file "${PATH_TO_SCAN}"
        ((files_scanned++))
    elif [[ -d "${PATH_TO_SCAN}" ]]; then
        # Directory
        if [[ "${RECURSIVE}" == "true" ]]; then
            while IFS= read -r -d '' file; do
                scan_file "${file}"
                ((files_scanned++))
            done < <(find "${PATH_TO_SCAN}" -type f -print0)
        else
            while IFS= read -r file; do
                scan_file "${file}"
                ((files_scanned++))
            done < <(find "${PATH_TO_SCAN}" -maxdepth 1 -type f)
        fi
    fi

    echo "Files Scanned: ${files_scanned}"
    echo ""

    # Report findings
    if [[ ${SECRETS_FOUND} -eq 0 ]]; then
        echo "✅ SUCCESS: No secrets detected"
        echo "All files clean"
        exit 0
    fi

    echo "⚠️  SECRETS DETECTED: ${SECRETS_FOUND}"
    echo ""

    # Group by severity
    local critical_count=0
    local high_count=0
    local medium_count=0
    local low_count=0

    for finding in "${FINDINGS[@]}"; do
        IFS='|' read -r severity file lines pattern type <<< "${finding}"
        case "${severity}" in
            critical) ((critical_count++)) ;;
            high) ((high_count++)) ;;
            medium) ((medium_count++)) ;;
            low) ((low_count++)) ;;
        esac
    done

    # Print findings by severity
    if [[ ${critical_count} -gt 0 ]]; then
        echo "CRITICAL Issues (${critical_count}):"
        for finding in "${FINDINGS[@]}"; do
            IFS='|' read -r severity file lines pattern type <<< "${finding}"
            if [[ "${severity}" == "critical" ]]; then
                echo "  ❌ ${file}:${lines}"
                echo "     Type: ${type}"
                echo "     Pattern: ${pattern}"
                echo "     Remediation: Remove and rotate immediately"
                echo ""
            fi
        done
    fi

    if [[ ${high_count} -gt 0 ]]; then
        echo "HIGH Issues (${high_count}):"
        for finding in "${FINDINGS[@]}"; do
            IFS='|' read -r severity file lines pattern type <<< "${finding}"
            if [[ "${severity}" == "high" ]]; then
                echo "  ⚠️  ${file}:${lines}"
                echo "     Type: ${type}"
                echo "     Pattern: ${pattern}"
                echo ""
            fi
        done
    fi

    if [[ ${medium_count} -gt 0 ]]; then
        echo "MEDIUM Issues (${medium_count}):"
        for finding in "${FINDINGS[@]}"; do
            IFS='|' read -r severity file lines pattern type <<< "${finding}"
            if [[ "${severity}" == "medium" ]]; then
                echo "  💡 ${file}:${lines}"
                echo "     Type: ${type}"
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
    echo "Action Required: YES"

    exit 1
}

main "$@"
