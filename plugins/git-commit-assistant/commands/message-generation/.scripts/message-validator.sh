#!/usr/bin/env bash
# Script: message-validator.sh
# Purpose: Validate commit message against conventional commits standard
# Author: Git Commit Assistant Plugin
# Version: 1.0.0
#
# Usage:
#   export MESSAGE="feat: add feature"
#   export STRICT_MODE=false
#   export MAX_SUBJECT=50
#   export MAX_LINE=72
#   ./message-validator.sh
#
# Environment Variables:
#   MESSAGE - Commit message to validate (required)
#   STRICT_MODE - Enable strict validation (default: false)
#   MAX_SUBJECT - Maximum subject length (default: 50)
#   MAX_LINE - Maximum body line length (default: 72)
#
# Returns:
#   Validation report to stdout
#   Exit code indicates validation status
#
# Exit Codes:
#   0 - Valid message
#   1 - Invalid message (warnings in normal mode, any issue in strict mode)
#   2 - Error (missing input, malformed message)

set -euo pipefail

# Default values
STRICT_MODE="${STRICT_MODE:-false}"
MAX_SUBJECT="${MAX_SUBJECT:-50}"
MAX_LINE="${MAX_LINE:-72}"

# Validation counters
declare -a ERRORS=()
declare -a WARNINGS=()
declare -a SUGGESTIONS=()

# Score tracking
SCORE=100

# Validate MESSAGE is provided
if [ -z "${MESSAGE:-}" ]; then
  echo "ERROR: MESSAGE environment variable is required" >&2
  exit 2
fi

# Valid commit types
VALID_TYPES="feat fix docs style refactor perf test build ci chore revert"

# Function to check commit type
validate_type() {
  local subject="$1"

  # Extract type (before colon or parenthesis)
  local type=$(echo "$subject" | grep -oP '^[a-z]+' || echo "")

  if [ -z "$type" ]; then
    ERRORS+=("No commit type found")
    SCORE=$((SCORE - 20))
    return 1
  fi

  # Check if type is valid
  if ! echo "$VALID_TYPES" | grep -qw "$type"; then
    ERRORS+=("Invalid commit type: '$type'")
    ERRORS+=("Valid types: $VALID_TYPES")
    SCORE=$((SCORE - 20))
    return 1
  fi

  return 0
}

# Function to check scope format
validate_scope() {
  local subject="$1"

  # Check if scope exists
  if echo "$subject" | grep -qP '^\w+\([^)]+\):'; then
    local scope=$(echo "$subject" | grep -oP '^\w+\(\K[^)]+')

    # Scope should be lowercase alphanumeric with hyphens
    if ! echo "$scope" | grep -qP '^[a-z0-9-]+$'; then
      WARNINGS+=("Scope should be lowercase alphanumeric with hyphens: '$scope'")
      SCORE=$((SCORE - 5))
    fi
  fi
}

# Function to validate subject line
validate_subject() {
  local subject="$1"

  # Check format: type(scope): description or type: description
  if ! echo "$subject" | grep -qP '^[a-z]+(\([a-z0-9-]+\))?: .+'; then
    ERRORS+=("Subject does not match conventional commits format")
    ERRORS+=("Expected: <type>(<scope>): <description> or <type>: <description>")
    SCORE=$((SCORE - 30))
    return 1
  fi

  # Validate type
  validate_type "$subject"

  # Validate scope if present
  validate_scope "$subject"

  # Extract description (after ": ")
  local description=$(echo "$subject" | sed 's/^[^:]*: //')

  # Check length
  local length=${#subject}
  if [ "$length" -gt "$MAX_SUBJECT" ]; then
    if [ "$length" -gt 72 ]; then
      ERRORS+=("Subject exceeds hard limit of 72 characters ($length chars)")
      SCORE=$((SCORE - 30))
    else
      WARNINGS+=("Subject exceeds recommended $MAX_SUBJECT characters ($length chars)")
      SUGGESTIONS+=("Consider shortening subject or moving details to body")
      SCORE=$((SCORE - 10))
    fi
  fi

  # Check for capital letter after colon
  if echo "$description" | grep -qP '^[A-Z]'; then
    WARNINGS+=("Description should not start with capital letter")
    SUGGESTIONS+=("Use lowercase after colon: '$(echo "${description:0:1}" | tr '[:upper:]' '[:lower:]')${description:1}'")
    SCORE=$((SCORE - 5))
  fi

  # Check for period at end
  if [[ "$description" =~ \.$ ]]; then
    WARNINGS+=("Subject should not end with period")
    SUGGESTIONS+=("Remove period at end")
    SCORE=$((SCORE - 3))
  fi

  # Check for imperative mood (simple heuristics)
  if echo "$description" | grep -qP '\b(added|fixed|updated|removed|changed|improved|created|deleted)\b'; then
    WARNINGS+=("Use imperative mood (add, fix, update) not past tense")
    SCORE=$((SCORE - 5))
  fi

  if echo "$description" | grep -qP '\b(adds|fixes|updates|removes|changes|improves|creates|deletes)\b'; then
    WARNINGS+=("Use imperative mood (add, fix, update) not present tense")
    SCORE=$((SCORE - 5))
  fi

  # Check for vague descriptions
  if echo "$description" | grep -qiP '\b(update|change|fix|improve)\s+(code|file|stuff|thing)\b'; then
    SUGGESTIONS+=("Be more specific in description")
    SCORE=$((SCORE - 5))
  fi

  return 0
}

# Function to validate body
validate_body() {
  local body="$1"

  if [ -z "$body" ]; then
    return 0  # Body is optional
  fi

  # Check line lengths
  while IFS= read -r line; do
    local length=${#line}
    if [ "$length" -gt "$MAX_LINE" ]; then
      WARNINGS+=("Body line exceeds $MAX_LINE characters ($length chars)")
      SCORE=$((SCORE - 3))
    fi
  done <<< "$body"

  # Check for imperative mood in body
  if echo "$body" | grep -qP '\b(added|fixed|updated|removed|changed|improved|created|deleted)\b'; then
    SUGGESTIONS+=("Consider using imperative mood in body")
  fi

  return 0
}

# Function to validate footer
validate_footer() {
  local footer="$1"

  if [ -z "$footer" ]; then
    return 0  # Footer is optional
  fi

  # Check for BREAKING CHANGE format
  if echo "$footer" | grep -qi "breaking change"; then
    if ! echo "$footer" | grep -q "^BREAKING CHANGE:"; then
      ERRORS+=("Use 'BREAKING CHANGE:' (uppercase, singular) not 'breaking change'")
      SCORE=$((SCORE - 15))
    fi
  fi

  # Check for issue references
  if echo "$footer" | grep -qiP '\b(close|fix|resolve)[sd]?\b'; then
    # Check format
    if ! echo "$footer" | grep -qP '^(Closes|Fixes|Resolves|Refs) #[0-9]'; then
      WARNINGS+=("Issue references should use proper format: 'Closes #123'")
      SUGGESTIONS+=("Capitalize keyword and use # prefix for issue numbers")
      SCORE=$((SCORE - 5))
    fi
  fi

  return 0
}

# Function to check overall structure
validate_structure() {
  local message="$1"

  # Count lines
  local line_count=$(echo "$message" | wc -l)

  # Split message into parts
  local subject=$(echo "$message" | head -1)
  local rest=$(echo "$message" | tail -n +2)

  # Validate subject
  validate_subject "$subject"

  # If multi-line, check for blank line after subject
  if [ "$line_count" -gt 1 ]; then
    local second_line=$(echo "$message" | sed -n '2p')

    if [ -n "$second_line" ]; then
      ERRORS+=("Blank line required between subject and body")
      SCORE=$((SCORE - 10))
    fi

    # Extract body (after blank line, before footer)
    local body=""
    local footer=""
    local in_footer=false

    while IFS= read -r line; do
      # Check if line is footer token
      if echo "$line" | grep -qP '^(BREAKING CHANGE:|Closes|Fixes|Resolves|Refs|Reviewed-by|Signed-off-by)'; then
        in_footer=true
      fi

      if [ "$in_footer" = true ]; then
        footer="${footer}${line}\n"
      else
        body="${body}${line}\n"
      fi
    done <<< "$rest"

    # Remove leading blank line from body
    body=$(echo -e "$body" | sed '1{/^$/d;}')

    # Validate body and footer
    validate_body "$body"
    validate_footer "$footer"
  fi
}

# Main validation logic
main() {
  echo "COMMIT MESSAGE VALIDATION"
  echo "═══════════════════════════════════════════════"
  echo ""

  echo "MESSAGE:"
  echo "───────────────────────────────────────────────"
  echo "$MESSAGE"
  echo ""

  # Perform validation
  validate_structure "$MESSAGE"

  # Calculate final status
  local status="VALID"
  if [ "${#ERRORS[@]}" -gt 0 ]; then
    status="INVALID"
  elif [ "$STRICT_MODE" = "true" ] && [ "${#WARNINGS[@]}" -gt 0 ]; then
    status="INVALID"
  fi

  # Display results
  echo "VALIDATION RESULTS:"
  echo "───────────────────────────────────────────────"

  if [ "${#ERRORS[@]}" -gt 0 ]; then
    echo "✗ ERRORS:"
    for error in "${ERRORS[@]}"; do
      echo "  - $error"
    done
    echo ""
  fi

  if [ "${#WARNINGS[@]}" -gt 0 ]; then
    echo "⚠ WARNINGS:"
    for warning in "${WARNINGS[@]}"; do
      echo "  - $warning"
    done
    echo ""
  fi

  if [ "${#SUGGESTIONS[@]}" -gt 0 ]; then
    echo "💡 SUGGESTIONS:"
    for suggestion in "${SUGGESTIONS[@]}"; do
      echo "  - $suggestion"
    done
    echo ""
  fi

  if [ "${#ERRORS[@]}" -eq 0 ] && [ "${#WARNINGS[@]}" -eq 0 ]; then
    echo "✓ All checks passed"
    echo ""
  fi

  echo "STATUS: $status"
  echo "SCORE: $SCORE/100"
  echo "STRICT MODE: $STRICT_MODE"
  echo ""
  echo "═══════════════════════════════════════════════"

  # Exit based on status
  if [ "$status" = "INVALID" ]; then
    exit 1
  else
    exit 0
  fi
}

# Run main
main
