#!/usr/bin/env bash

# ============================================================================
# Marketplace Validator Plugin - Shared Validation Library
# ============================================================================
# Purpose: Reusable validation functions for marketplace and plugin validation
# Version: 1.0.0
# License: MIT
# ============================================================================

# ====================
# Color Output
# ====================
if [[ -t 1 ]]; then
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
# Output Functions
# ====================

print_header() {
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_section() {
    echo -e "${BOLD}${CYAN}🔍 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_star_rating() {
    local score=$1
    local stars=""

    if [[ $score -ge 90 ]]; then
        stars="⭐⭐⭐⭐⭐"
    elif [[ $score -ge 75 ]]; then
        stars="⭐⭐⭐⭐"
    elif [[ $score -ge 60 ]]; then
        stars="⭐⭐⭐"
    elif [[ $score -ge 40 ]]; then
        stars="⭐⭐"
    else
        stars="⭐"
    fi

    echo "$stars"
}

print_quality_rating() {
    local score=$1

    if [[ $score -ge 90 ]]; then
        echo "Excellent"
    elif [[ $score -ge 75 ]]; then
        echo "Good"
    elif [[ $score -ge 60 ]]; then
        echo "Fair"
    elif [[ $score -ge 40 ]]; then
        echo "Needs Improvement"
    else
        echo "Poor"
    fi
}

# ====================
# JSON Tool Detection
# ====================

detect_json_tool() {
    if command -v jq &> /dev/null; then
        echo "jq"
    elif command -v python3 &> /dev/null; then
        echo "python3"
    else
        echo "none"
    fi
}

# ====================
# JSON Operations
# ====================

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
import sys
try:
    with open('${file}') as f:
        data = json.load(f)

    # Parse jq-style path
    path = '${path}'.lstrip('.')
    if not path:
        result = data
    else:
        result = data
        for segment in path.split('.'):
            if '[' in segment and ']' in segment:
                # Handle array access like "plugins[0]"
                parts = segment.split('[')
                if parts[0]:
                    result = result[parts[0]]
                idx = int(parts[1].rstrip(']'))
                result = result[idx]
            elif segment == 'length':
                result = len(result) if isinstance(result, (list, dict)) else 0
            else:
                result = result.get(segment) if isinstance(result, dict) else None

            if result is None:
                print('')
                sys.exit(0)

    if isinstance(result, (str, int, float, bool)):
        print(result)
    elif result is None:
        print('')
    else:
        print('')
except Exception as e:
    print('', file=sys.stderr)
EOF
            ;;
        *)
            echo "" >&2
            return 1
            ;;
    esac
}

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
        *)
            return 1
            ;;
    esac
}

get_json_array_length() {
    local file="$1"
    local path="$2"
    local tool
    tool=$(detect_json_tool)

    case "${tool}" in
        jq)
            jq -r "${path} | length" "${file}" 2>/dev/null || echo "0"
            ;;
        python3)
            python3 <<EOF 2>/dev/null || echo "0"
import json
try:
    with open('${file}') as f:
        data = json.load(f)

    path = '${path}'.lstrip('.')
    result = data
    for segment in path.split('.'):
        if segment:
            result = result.get(segment) if isinstance(result, dict) else None
            if result is None:
                break

    print(len(result) if isinstance(result, (list, dict)) else 0)
except:
    print(0)
EOF
            ;;
        *)
            echo "0"
            ;;
    esac
}

# ====================
# Validation Functions
# ====================

validate_semver() {
    local version="$1"
    [[ "${version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?(\+[a-zA-Z0-9.]+)?$ ]]
}

validate_name_format() {
    local name="$1"
    [[ "${name}" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

validate_email() {
    local email="$1"
    [[ "${email}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

validate_url() {
    local url="$1"
    [[ "${url}" =~ ^https?:// ]]
}

validate_https_url() {
    local url="$1"
    [[ "${url}" =~ ^https:// ]]
}

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

validate_category() {
    local category="$1"
    local valid_categories=(
        "development" "testing" "deployment" "documentation" "security"
        "database" "monitoring" "productivity" "quality" "collaboration"
    )

    for valid in "${valid_categories[@]}"; do
        if [[ "${category}" == "${valid}" ]]; then
            return 0
        fi
    done

    return 1
}

validate_source_format() {
    # Validate a plugin entry source provided as a STRING.
    # Per current plugin-marketplaces spec, only relative paths starting with
    # "./" are canonical string sources. Legacy shorthand strings (github:,
    # https://...git, https://...zip) are accepted with a warning for
    # migration.
    local source="$1"

    # Canonical: relative path starting with ./
    if [[ "${source}" == ./* ]]; then
        return 0
    fi

    # Legacy shorthands — still parseable but no longer in the docs.
    if [[ "${source}" =~ ^github: ]]; then
        return 0
    fi
    if [[ "${source}" =~ ^(https?|git):// ]] && [[ "${source}" =~ \.git$ ]]; then
        return 0
    fi
    if [[ "${source}" =~ ^https?:// ]] && [[ "${source}" =~ \.(zip|tar\.gz|tgz)$ ]]; then
        return 0
    fi

    return 1
}

validate_source_object() {
    # Validate a plugin entry source provided as a JSON OBJECT.
    # Accepts: {source: "github"|"url"|"git-subdir"|"npm", ...type-specific fields}
    # Required fields per type:
    #   github    -> repo
    #   url       -> url
    #   git-subdir -> url, path
    #   npm       -> package
    local source_json="$1"

    if ! command -v jq &>/dev/null; then
        # Without jq we can't reliably parse; fail closed.
        return 1
    fi

    local src_type
    src_type=$(echo "${source_json}" | jq -r '.source // empty' 2>/dev/null || echo "")

    case "${src_type}" in
        github)
            local repo
            repo=$(echo "${source_json}" | jq -r '.repo // empty' 2>/dev/null || echo "")
            [[ -n "${repo}" ]]
            return $?
            ;;
        url)
            local url
            url=$(echo "${source_json}" | jq -r '.url // empty' 2>/dev/null || echo "")
            [[ -n "${url}" ]]
            return $?
            ;;
        git-subdir)
            local url path
            url=$(echo "${source_json}" | jq -r '.url // empty' 2>/dev/null || echo "")
            path=$(echo "${source_json}" | jq -r '.path // empty' 2>/dev/null || echo "")
            [[ -n "${url}" && -n "${path}" ]]
            return $?
            ;;
        npm)
            local package
            package=$(echo "${source_json}" | jq -r '.package // empty' 2>/dev/null || echo "")
            [[ -n "${package}" ]]
            return $?
            ;;
        *)
            return 1
            ;;
    esac
}

validate_repository_field() {
    # Validate a repository field. Must be a string URL; the legacy {type,url}
    # object form is rejected by the current Claude Code plugin loader.
    local repo_json="$1"

    if ! command -v jq &>/dev/null; then
        # Best effort: treat as string
        [[ "${repo_json}" =~ ^https?:// ]]
        return $?
    fi

    local field_type
    field_type=$(echo "${repo_json}" | jq -r 'type' 2>/dev/null || echo "null")

    if [[ "${field_type}" == "string" ]]; then
        local url
        url=$(echo "${repo_json}" | jq -r '.' 2>/dev/null)
        validate_url "${url}"
        return $?
    fi

    # Anything else (object, array, null) — invalid per current schema.
    return 1
}

validate_userconfig_entry() {
    # Validate a single userConfig entry. Takes the JSON object.
    # Required: type (string|number|boolean|directory|file), title (non-empty string)
    local entry_json="$1"

    if ! command -v jq &>/dev/null; then
        return 1
    fi

    local entry_type entry_title
    entry_type=$(echo "${entry_json}" | jq -r '.type // empty' 2>/dev/null || echo "")
    entry_title=$(echo "${entry_json}" | jq -r '.title // empty' 2>/dev/null || echo "")

    case "${entry_type}" in
        string|number|boolean|directory|file) ;;
        *) return 1 ;;
    esac

    [[ -n "${entry_title}" ]]
}

# ====================
# Security Checks
# ====================

check_for_secrets() {
    local file="$1"
    local suspicious_patterns=(
        "password.*=.*['\"].*['\"]"
        "api[_-]?key.*=.*['\"].*['\"]"
        "secret.*=.*['\"].*['\"]"
        "token.*=.*['\"].*['\"]"
        "-----BEGIN.*PRIVATE KEY-----"
    )

    for pattern in "${suspicious_patterns[@]}"; do
        if grep -iE "${pattern}" "${file}" &>/dev/null; then
            return 1
        fi
    done

    return 0
}

check_for_malicious_urls() {
    local url="$1"
    local suspicious_patterns=(
        "eval\("
        "exec\("
        "rm -rf"
        "curl.*\|.*sh"
        "wget.*\|.*sh"
    )

    for pattern in "${suspicious_patterns[@]}"; do
        if [[ "${url}" =~ ${pattern} ]]; then
            return 1
        fi
    done

    return 0
}

# ====================
# Quality Scoring
# ====================

calculate_quality_score() {
    local score=100
    local errors=$1
    local warnings=$2
    local missing_recommended=$3

    # Deduct for errors
    score=$((score - (errors * 20)))

    # Deduct for warnings
    score=$((score - (warnings * 10)))

    # Deduct for missing recommended fields
    score=$((score - (missing_recommended * 5)))

    # Ensure score doesn't go below 0
    if [[ $score -lt 0 ]]; then
        score=0
    fi

    echo "$score"
}

# ====================
# File Checks
# ====================

check_file_exists() {
    local file="$1"
    [[ -f "${file}" ]]
}

check_dir_exists() {
    local dir="$1"
    [[ -d "${dir}" ]]
}

check_file_executable() {
    local file="$1"
    [[ -x "${file}" ]]
}

get_file_size() {
    local file="$1"
    if [[ -f "${file}" ]]; then
        wc -c < "${file}"
    else
        echo "0"
    fi
}

# ====================
# Markdown Validation
# ====================

validate_markdown_frontmatter() {
    local file="$1"

    # Check if file starts with ---
    if ! head -n 1 "${file}" | grep -q "^---$"; then
        return 1
    fi

    # Check if there's a closing ---
    if ! tail -n +2 "${file}" | grep -q "^---$"; then
        return 1
    fi

    return 0
}

extract_frontmatter_field() {
    local file="$1"
    local field="$2"

    # Extract frontmatter section
    awk '/^---$/{if(++count==2) exit; next} count==1' "${file}" | \
        grep "^${field}:" | \
        sed "s/^${field}:[[:space:]]*//"
}

# ====================
# Export Functions
# ====================

# Make functions available to scripts that source this file
export -f print_header print_section print_success print_error print_warning print_info
export -f print_star_rating print_quality_rating
export -f detect_json_tool json_get validate_json_syntax get_json_array_length
export -f validate_semver validate_name_format validate_email validate_url validate_https_url
export -f validate_license validate_category validate_source_format
export -f validate_source_object validate_repository_field validate_userconfig_entry
export -f check_for_secrets check_for_malicious_urls
export -f calculate_quality_score
export -f check_file_exists check_dir_exists check_file_executable get_file_size
export -f validate_markdown_frontmatter extract_frontmatter_field
