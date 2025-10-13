#!/usr/bin/env bash

# ============================================================================
# Example Validator
# ============================================================================
# Purpose: Validate example quality and detect placeholder patterns
# Version: 1.0.0
# Usage: ./example-validator.sh <path> [--no-placeholders] [--recursive] [--json]
# Returns: 0=success, 1=warning, JSON output to stdout if --json
# ============================================================================

set -euo pipefail

# Default values
NO_PLACEHOLDERS=true
RECURSIVE=true
JSON_OUTPUT=false
EXTENSIONS="md,txt,json,sh,py,js,ts,yaml,yml"

# Parse arguments
TARGET_PATH="${1:-.}"
shift || true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --no-placeholders)
            NO_PLACEHOLDERS=true
            shift
            ;;
        --allow-placeholders)
            NO_PLACEHOLDERS=false
            shift
            ;;
        --recursive)
            RECURSIVE=true
            shift
            ;;
        --non-recursive)
            RECURSIVE=false
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --extensions)
            EXTENSIONS="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Initialize counters
files_checked=0
example_count=0
placeholder_count=0
todo_count=0
declare -a issues=()
declare -a files_with_issues=()

# Build find command based on recursiveness
if $RECURSIVE; then
    FIND_DEPTH=""
else
    FIND_DEPTH="-maxdepth 1"
fi

# Build extension pattern
ext_pattern=""
IFS=',' read -ra EXT_ARRAY <<< "$EXTENSIONS"
for ext in "${EXT_ARRAY[@]}"; do
    if [[ -z "$ext_pattern" ]]; then
        ext_pattern="-name '*.${ext}'"
    else
        ext_pattern="$ext_pattern -o -name '*.${ext}'"
    fi
done

# Find files to check
mapfile -t files < <(eval "find '$TARGET_PATH' $FIND_DEPTH -type f \( $ext_pattern \) 2>/dev/null" || true)

# Placeholder patterns to detect
declare -a PLACEHOLDER_PATTERNS=(
    'TODO[:\)]'
    'FIXME[:\)]'
    'XXX[:\)]'
    'HACK[:\)]'
    'placeholder'
    'PLACEHOLDER'
    'your-.*-here'
    '<your-'
    'INSERT.?HERE'
    'YOUR_[A-Z_]+'
)

# Generic dummy value patterns
declare -a GENERIC_PATTERNS=(
    '\bfoo\b'
    '\bbar\b'
    '\bbaz\b'
    '\bdummy\b'
)

# Acceptable patterns (don't count these)
declare -a ACCEPTABLE_PATTERNS=(
    '\{\{[^}]+\}\}'      # {{variable}} template syntax
    '\$\{[^}]+\}'        # ${variable} template syntax
    '\$[A-Z_]+'          # $VARIABLE environment variables
)

# Function to check if line contains acceptable pattern
is_acceptable_pattern() {
    local line="$1"

    for pattern in "${ACCEPTABLE_PATTERNS[@]}"; do
        if echo "$line" | grep -qE "$pattern"; then
            return 0  # Is acceptable
        fi
    done

    return 1  # Not acceptable
}

# Function to count code examples in markdown
count_code_examples() {
    local file="$1"

    if [[ ! "$file" =~ \.md$ ]]; then
        return 0
    fi

    # Count code blocks (```)
    local count
    count=$(grep -c '```' "$file" 2>/dev/null || echo "0")

    # Ensure count is numeric and divide by 2 since each code block has opening and closing
    if [[ "$count" =~ ^[0-9]+$ ]]; then
        count=$((count / 2))
    else
        count=0
    fi

    echo "$count"
}

# Check each file
for file in "${files[@]}"; do
    ((files_checked++)) || true

    # Count examples in markdown files
    if [[ "$file" =~ \.md$ ]]; then
        file_examples=$(count_code_examples "$file")
        ((example_count += file_examples)) || true
    fi

    file_issues=0

    # Check for placeholder patterns
    for pattern in "${PLACEHOLDER_PATTERNS[@]}"; do
        while IFS=: read -r line_num line_content; do
            # Skip if it's an acceptable pattern
            if is_acceptable_pattern "$line_content"; then
                continue
            fi

            ((placeholder_count++)) || true
            ((file_issues++)) || true

            issue="$file:$line_num: Placeholder pattern detected"
            issues+=("$issue")

            # Track TODO/FIXME separately
            if echo "$pattern" | grep -qE 'TODO|FIXME|XXX'; then
                ((todo_count++)) || true
            fi
        done < <(grep -inE "$pattern" "$file" 2>/dev/null || true)
    done

    # Check for generic dummy values (only in non-test files)
    if [[ ! "$file" =~ test ]] && [[ ! "$file" =~ example ]] && [[ ! "$file" =~ spec ]]; then
        for pattern in "${GENERIC_PATTERNS[@]}"; do
            while IFS=: read -r line_num line_content; do
                # Skip code comments explaining these terms
                if echo "$line_content" | grep -qE '(#|//|/\*).*'"$pattern"; then
                    continue
                fi

                # Skip if in an acceptable context
                if is_acceptable_pattern "$line_content"; then
                    continue
                fi

                ((file_issues++)) || true
                issue="$file:$line_num: Generic placeholder value detected"
                issues+=("$issue")
            done < <(grep -inE "$pattern" "$file" 2>/dev/null || true)
        done
    fi

    # Track files with issues
    if ((file_issues > 0)); then
        files_with_issues+=("$file:$file_issues")
    fi
done

# Calculate quality score
quality_score=100
((quality_score -= placeholder_count * 10)) || true
((quality_score -= todo_count * 5)) || true

if ((example_count < 2)); then
    ((quality_score -= 20)) || true
fi

# Ensure score doesn't go negative
if ((quality_score < 0)); then
    quality_score=0
fi

# Determine status
status="pass"
if ((quality_score < 60)); then
    status="fail"
elif ((quality_score < 80)); then
    status="warning"
fi

# Output results
if $JSON_OUTPUT; then
    # Build JSON output
    cat <<EOF
{
  "files_checked": $files_checked,
  "example_count": $example_count,
  "placeholder_count": $placeholder_count,
  "todo_count": $todo_count,
  "files_with_issues": ${#files_with_issues[@]},
  "quality_score": $quality_score,
  "status": "$status",
  "issues": [
$(IFS=; for issue in "${issues[@]:0:20}"; do  # Limit to first 20 issues
    # Escape quotes in issue text
    escaped_issue="${issue//\"/\\\"}"
    echo "    \"$escaped_issue\","
done | sed '$ s/,$//')
  ],
  "files_with_issues_list": [
$(IFS=; for file_info in "${files_with_issues[@]:0:10}"; do  # Limit to first 10 files
    file_path="${file_info%:*}"
    file_count="${file_info#*:}"
    echo "    {\"file\": \"$file_path\", \"issue_count\": $file_count},"
done | sed '$ s/,$//')
  ]
}
EOF
else
    # Human-readable output
    echo ""
    echo "Example Quality Validation"
    echo "========================================"
    echo "Files Checked: $files_checked"
    echo "Code Examples Found: $example_count"
    echo "Quality Score: $quality_score/100"
    echo ""

    if ((placeholder_count > 0)) || ((todo_count > 0)); then
        echo "Issues Detected:"
        echo "  • Placeholder patterns: $placeholder_count"
        echo "  • TODO/FIXME markers: $todo_count"
        echo "  • Files with issues: ${#files_with_issues[@]}"
        echo ""

        if ((${#files_with_issues[@]} > 0)); then
            echo "Files with issues:"
            for file_info in "${files_with_issues[@]:0:5}"; do  # Show first 5
                file_path="${file_info%:*}"
                file_count="${file_info#*:}"
                echo "  • $file_path ($file_count issues)"
            done

            if ((${#files_with_issues[@]} > 5)); then
                echo "  ... and $((${#files_with_issues[@]} - 5)) more files"
            fi
        fi

        echo ""
        echo "Sample Issues:"
        for issue in "${issues[@]:0:5}"; do  # Show first 5
            echo "  • $issue"
        done

        if ((${#issues[@]} > 5)); then
            echo "  ... and $((${#issues[@]} - 5)) more issues"
        fi
    else
        echo "✓ No placeholder patterns detected"
    fi

    if ((example_count < 2)); then
        echo ""
        echo "⚠  Recommendation: Add more code examples (found: $example_count, recommended: 3+)"
    fi

    echo ""
    if [[ "$status" == "pass" ]]; then
        echo "Overall: ✓ PASS"
    elif [[ "$status" == "warning" ]]; then
        echo "Overall: ⚠  WARNINGS"
    else
        echo "Overall: ✗ FAIL"
    fi
    echo ""
fi

# Exit with appropriate code
if [[ "$status" == "fail" ]]; then
    exit 1
elif [[ "$status" == "warning" ]]; then
    exit 0  # Warning is not a failure
else
    exit 0
fi
