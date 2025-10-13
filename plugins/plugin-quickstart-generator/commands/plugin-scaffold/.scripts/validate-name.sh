#!/bin/bash
# Script: validate-name.sh
# Purpose: Validate plugin name follows Claude Code conventions
# Version: 1.0.0
# Last Modified: 2025-10-13
#
# Usage:
#   ./validate-name.sh <plugin-name>
#
# Arguments:
#   plugin-name: Name to validate
#
# Returns:
#   0 - Valid name
#   1 - Invalid name format
#   2 - Missing argument
#
# Dependencies:
#   - grep (for regex matching)

# Check for argument
if [ $# -eq 0 ]; then
    echo "ERROR: Plugin name required"
    echo "Usage: $0 <plugin-name>"
    exit 2
fi

PLUGIN_NAME="$1"

# Validation pattern: lowercase letters, numbers, hyphens
# Must start with letter, cannot end with hyphen
VALID_PATTERN='^[a-z][a-z0-9-]*[a-z0-9]$|^[a-z]$'

# Check pattern match
if echo "$PLUGIN_NAME" | grep -Eq "$VALID_PATTERN"; then
    # Additional checks

    # Check for consecutive hyphens
    if echo "$PLUGIN_NAME" | grep -q '\-\-'; then
        echo "ERROR: Plugin name cannot contain consecutive hyphens"
        echo "Invalid: $PLUGIN_NAME"
        echo "Try: $(echo "$PLUGIN_NAME" | sed 's/--/-/g')"
        exit 1
    fi

    # Check length (reasonable limit)
    NAME_LENGTH=${#PLUGIN_NAME}
    if [ $NAME_LENGTH -gt 50 ]; then
        echo "ERROR: Plugin name too long ($NAME_LENGTH characters, max 50)"
        echo "Consider a shorter name"
        exit 1
    fi

    if [ $NAME_LENGTH -lt 3 ]; then
        echo "ERROR: Plugin name too short ($NAME_LENGTH characters, min 3)"
        echo "Use a more descriptive name"
        exit 1
    fi

    # Check for common mistakes
    if echo "$PLUGIN_NAME" | grep -iq 'plugin$'; then
        echo "WARNING: Plugin name ends with 'plugin' - this is redundant"
        echo "Consider: $(echo "$PLUGIN_NAME" | sed 's/-plugin$//' | sed 's/plugin$//')"
    fi

    # Success
    echo "✅ Valid plugin name: $PLUGIN_NAME"
    exit 0
else
    # Invalid format
    echo "ERROR: Invalid plugin name format: $PLUGIN_NAME"
    echo ""
    echo "Plugin names must:"
    echo "  - Start with a lowercase letter"
    echo "  - Contain only lowercase letters, numbers, and hyphens"
    echo "  - Not end with a hyphen"
    echo "  - Be between 3-50 characters"
    echo ""
    echo "Valid examples:"
    echo "  - code-formatter"
    echo "  - test-generator"
    echo "  - deploy-automation"
    echo ""
    echo "Invalid examples:"
    echo "  - CodeFormatter (uppercase)"
    echo "  - test_generator (underscores)"
    echo "  - -my-plugin (starts with hyphen)"
    echo "  - plugin- (ends with hyphen)"

    exit 1
fi
