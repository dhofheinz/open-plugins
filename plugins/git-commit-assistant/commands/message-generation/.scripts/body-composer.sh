#!/usr/bin/env bash
# Script: body-composer.sh
# Purpose: Compose commit message body with proper formatting and wrapping
# Author: Git Commit Assistant Plugin
# Version: 1.0.0
#
# Usage:
#   export CHANGES="change1,change2,change3"
#   export WRAP_LENGTH=72
#   export FORMAT=bullets
#   ./body-composer.sh
#
# Environment Variables:
#   CHANGES - Comma-separated list of changes or file paths
#   WRAP_LENGTH - Line wrap length (default: 72)
#   FORMAT - Output format: bullets or paragraphs (default: bullets)
#   WHY_CONTEXT - Optional context about why changes were made
#
# Returns:
#   Formatted body text to stdout
#   JSON summary to stderr (optional)
#
# Exit Codes:
#   0 - Success
#   1 - Invalid input
#   2 - Processing error

set -euo pipefail

# Default values
WRAP_LENGTH="${WRAP_LENGTH:-72}"
FORMAT="${FORMAT:-bullets}"
WHY_CONTEXT="${WHY_CONTEXT:-}"

# Validate CHANGES is provided
if [ -z "${CHANGES:-}" ]; then
  echo "ERROR: CHANGES environment variable is required" >&2
  exit 1
fi

# Validate FORMAT
if [ "$FORMAT" != "bullets" ] && [ "$FORMAT" != "paragraphs" ]; then
  echo "ERROR: FORMAT must be 'bullets' or 'paragraphs'" >&2
  exit 1
fi

# Validate WRAP_LENGTH
if ! [[ "$WRAP_LENGTH" =~ ^[0-9]+$ ]]; then
  echo "ERROR: WRAP_LENGTH must be a positive integer" >&2
  exit 1
fi

# Function to convert to imperative mood
convert_to_imperative() {
  local text="$1"

  # Common past tense -> imperative
  text=$(echo "$text" | sed -E 's/\b(added|adds)\b/add/gi')
  text=$(echo "$text" | sed -E 's/\b(fixed|fixes)\b/fix/gi')
  text=$(echo "$text" | sed -E 's/\b(updated|updates)\b/update/gi')
  text=$(echo "$text" | sed -E 's/\b(removed|removes)\b/remove/gi')
  text=$(echo "$text" | sed -E 's/\b(changed|changes)\b/change/gi')
  text=$(echo "$text" | sed -E 's/\b(improved|improves)\b/improve/gi')
  text=$(echo "$text" | sed -E 's/\b(refactored|refactors)\b/refactor/gi')
  text=$(echo "$text" | sed -E 's/\b(implemented|implements)\b/implement/gi')
  text=$(echo "$text" | sed -E 's/\b(created|creates)\b/create/gi')
  text=$(echo "$text" | sed -E 's/\b(deleted|deletes)\b/delete/gi')

  # Lowercase first letter
  text="$(echo "${text:0:1}" | tr '[:upper:]' '[:lower:]')${text:1}"

  echo "$text"
}

# Function to wrap text at specified length
wrap_text() {
  local text="$1"
  local width="$2"

  echo "$text" | fold -s -w "$width"
}

# Function to format file path as readable change
format_file_path() {
  local filepath="$1"

  # Extract filename and directory
  local filename=$(basename "$filepath")
  local dirname=$(dirname "$filepath")

  # Remove extension
  local name_no_ext="${filename%.*}"

  # Convert to readable format
  # Example: src/auth/oauth.js -> "add OAuth authentication module"
  # Example: tests/unit/user.test.js -> "add user unit tests"

  if [[ "$filepath" == *"/test/"* ]] || [[ "$filepath" == *"/tests/"* ]] || [[ "$filename" == *".test."* ]] || [[ "$filename" == *".spec."* ]]; then
    echo "add ${name_no_ext} tests"
  elif [[ "$dirname" == "." ]]; then
    echo "update ${name_no_ext}"
  else
    # Extract meaningful part from path
    local component=$(echo "$dirname" | sed 's|.*/||')
    echo "update ${component} ${name_no_ext}"
  fi
}

# Function to generate bullet points
generate_bullets() {
  local changes_list="$1"

  # Split by comma
  IFS=',' read -ra items <<< "$changes_list"

  local body=""
  local bullet_count=0

  for item in "${items[@]}"; do
    # Trim whitespace
    item=$(echo "$item" | xargs)

    if [ -z "$item" ]; then
      continue
    fi

    # Check if it's a file path
    if [[ "$item" == *"/"* ]] || [[ "$item" == *"."* ]]; then
      # Format as file path
      item=$(format_file_path "$item")
    fi

    # Convert to imperative mood
    item=$(convert_to_imperative "$item")

    # Ensure first letter is capitalized for bullet
    item="$(echo "${item:0:1}" | tr '[:lower:]' '[:upper:]')${item:1}"

    # Wrap if needed (account for "- " prefix)
    local max_width=$((WRAP_LENGTH - 2))
    local wrapped=$(wrap_text "$item" "$max_width")

    # Add bullet point
    echo "$wrapped" | while IFS= read -r line; do
      if [ "$bullet_count" -eq 0 ] || [ -z "$line" ]; then
        body="${body}- ${line}\n"
      else
        body="${body}  ${line}\n"  # Indent continuation lines
      fi
    done

    bullet_count=$((bullet_count + 1))
  done

  # Output body (remove trailing newline)
  echo -ne "$body"
}

# Function to generate paragraphs
generate_paragraphs() {
  local changes_list="$1"

  # Split by comma and join into sentences
  IFS=',' read -ra items <<< "$changes_list"

  local body=""

  for item in "${items[@]}"; do
    # Trim whitespace
    item=$(echo "$item" | xargs)

    if [ -z "$item" ]; then
      continue
    fi

    # Check if it's a file path
    if [[ "$item" == *"/"* ]] || [[ "$item" == *"."* ]]; then
      item=$(format_file_path "$item")
    fi

    # Convert to imperative mood
    item=$(convert_to_imperative "$item")

    # Ensure first letter is capitalized
    item="$(echo "${item:0:1}" | tr '[:lower:]' '[:upper:]')${item:1}"

    # Add to body
    if [ -z "$body" ]; then
      body="$item"
    else
      body="${body}. ${item}"
    fi
  done

  # Add period at end if not present
  if [[ ! "$body" =~ \.$ ]]; then
    body="${body}."
  fi

  # Wrap text
  wrapped=$(wrap_text "$body" "$WRAP_LENGTH")

  echo "$wrapped"
}

# Function to add context (why)
add_context() {
  local body="$1"
  local context="$2"

  if [ -z "$context" ]; then
    echo "$body"
    return
  fi

  # Ensure first letter is capitalized
  context="$(echo "${context:0:1}" | tr '[:lower:]' '[:upper:]')${context:1}"

  # Add period if not present
  if [[ ! "$context" =~ \.$ ]]; then
    context="${context}."
  fi

  # Wrap context
  wrapped_context=$(wrap_text "$context" "$WRAP_LENGTH")

  # Combine with blank line
  echo -e "${body}\n\n${wrapped_context}"
}

# Main composition logic
compose_body() {
  local body=""

  # Generate based on format
  if [ "$FORMAT" = "bullets" ]; then
    body=$(generate_bullets "$CHANGES")
  else
    body=$(generate_paragraphs "$CHANGES")
  fi

  # Add context if provided
  if [ -n "$WHY_CONTEXT" ]; then
    body=$(add_context "$body" "$WHY_CONTEXT")
  fi

  echo "$body"
}

# Validate body
validate_body() {
  local body="$1"

  local line_count=$(echo "$body" | wc -l)
  local longest_line=$(echo "$body" | awk '{ print length }' | sort -rn | head -1)
  local bullet_count=$(echo "$body" | grep -c '^- ' || true)

  local warnings=()

  # Check longest line
  if [ "$longest_line" -gt "$WRAP_LENGTH" ]; then
    warnings+=("Line exceeds $WRAP_LENGTH characters ($longest_line chars)")
  fi

  # Check for empty lines at start
  if echo "$body" | head -1 | grep -q '^$'; then
    warnings+=("Body starts with empty line")
  fi

  # Output validation summary to stderr
  {
    echo "{"
    echo "  \"line_count\": $line_count,"
    echo "  \"longest_line\": $longest_line,"
    echo "  \"wrap_length\": $WRAP_LENGTH,"
    echo "  \"bullet_count\": $bullet_count,"
    echo "  \"format\": \"$FORMAT\","
    echo "  \"has_context\": $([ -n "$WHY_CONTEXT" ] && echo "true" || echo "false"),"
    echo "  \"warnings\": ["
    for i in "${!warnings[@]}"; do
      echo "    \"${warnings[$i]}\"$([ $i -lt $((${#warnings[@]} - 1)) ] && echo "," || echo "")"
    done
    echo "  ],"
    echo "  \"valid\": $([ ${#warnings[@]} -eq 0 ] && echo "true" || echo "false")"
    echo "}"
  } >&2
}

# Main execution
main() {
  # Compose body
  body=$(compose_body)

  # Validate
  validate_body "$body"

  # Output body to stdout
  echo "$body"

  exit 0
}

# Run main
main
