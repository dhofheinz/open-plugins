#!/bin/bash
# Script: secret-scanner.sh
# Purpose: Scan plugin files for hardcoded secrets and credentials
# Version: 1.0.0
#
# Usage: ./secret-scanner.sh <plugin-path>
# Returns: 0 - No secrets found, 1 - Secrets detected

PLUGIN_PATH="$1"

if [ -z "$PLUGIN_PATH" ]; then
    echo "ERROR: Plugin path required"
    exit 2
fi

ISSUES_FOUND=0

# Patterns to search for
declare -a PATTERNS=(
    "api[_-]?key['\"]?\s*[:=]"
    "apikey['\"]?\s*[:=]"
    "secret[_-]?key['\"]?\s*[:=]"
    "password['\"]?\s*[:=]\s*['\"][^'\"]{8,}"
    "token['\"]?\s*[:=]\s*['\"][a-zA-Z0-9]{20,}"
    "AKIA[0-9A-Z]{16}"  # AWS Access Key
    "AIza[0-9A-Za-z\\-_]{35}"  # Google API Key
    "sk-[a-zA-Z0-9]{48}"  # OpenAI API Key
    "ghp_[a-zA-Z0-9]{36}"  # GitHub Personal Access Token
    "-----BEGIN.*PRIVATE KEY-----"  # Private keys
    "mongodb://.*:.*@"  # MongoDB connection strings
    "postgres://.*:.*@"  # PostgreSQL connection strings
)

echo "🔍 Scanning for hardcoded secrets..."
echo ""

for pattern in "${PATTERNS[@]}"; do
    matches=$(grep -r -i -E "$pattern" "$PLUGIN_PATH" --exclude-dir=.git --exclude="*.log" 2>/dev/null | grep -v "secret-scanner.sh" || true)
    if [ -n "$matches" ]; then
        echo "⚠️  Potential secret found matching pattern: $pattern"
        echo "$matches"
        echo ""
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done

if [ $ISSUES_FOUND -eq 0 ]; then
    echo "✅ No hardcoded secrets detected"
    exit 0
else
    echo "❌ Found $ISSUES_FOUND potential secret(s)"
    echo ""
    echo "Recommendations:"
    echo "  - Use environment variables for sensitive data"
    echo "  - Store secrets in .env files (add to .gitignore)"
    echo "  - Use secure credential management"
    exit 1
fi
