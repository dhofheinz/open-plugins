#!/bin/bash
# Script: scope-identifier.sh
# Purpose: Identify primary scope (module/component) from file paths
# Author: Git Commit Assistant Plugin
# Version: 1.0.0
#
# Usage:
#   git diff HEAD --name-only | ./scope-identifier.sh
#   ./scope-identifier.sh < files.txt
#
# Returns:
#   JSON: {"scope": "auth", "confidence": "high", "affected_areas": {...}}
#
# Exit Codes:
#   0 - Success
#   1 - No input
#   2 - Analysis error

# Read file paths from stdin
files=()
while IFS= read -r line; do
    files+=("$line")
done

if [ ${#files[@]} -eq 0 ]; then
    echo '{"error": "No files provided", "scope": null}'
    exit 1
fi

# Scope counters
declare -A scope_counts
declare -A scope_files

# Analyze each file path
for file in "${files[@]}"; do
    # Skip empty lines
    [ -z "$file" ] && continue

    # Extract scope from path patterns
    scope=""

    # Pattern 1: src/<scope>/*
    if [[ "$file" =~ ^src/([^/]+)/ ]]; then
        scope="${BASH_REMATCH[1]}"
    # Pattern 2: components/<Component>
    elif [[ "$file" =~ components/([^/]+) ]]; then
        # Convert PascalCase to kebab-case
        component="${BASH_REMATCH[1]}"
        scope=$(echo "$component" | sed 's/\([A-Z]\)/-\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//')
    # Pattern 3: tests/<module>
    elif [[ "$file" =~ tests?/([^/]+) ]]; then
        scope="${BASH_REMATCH[1]}"
        scope=$(echo "$scope" | sed 's/\.test.*$//' | sed 's/\.spec.*$//')
    # Pattern 4: docs/*
    elif [[ "$file" =~ ^docs?/ ]]; then
        scope="docs"
    # Pattern 5: .github/workflows
    elif [[ "$file" =~ \.github/workflows ]]; then
        scope="ci"
    # Pattern 6: config files
    elif [[ "$file" =~ (package\.json|tsconfig\.json|.*\.config\.(js|ts|json)) ]]; then
        scope="config"
    # Pattern 7: root README
    elif [[ "$file" == "README.md" ]]; then
        scope="docs"
    fi

    # Count scopes
    if [ -n "$scope" ]; then
        ((scope_counts[$scope]++))
        scope_files[$scope]="${scope_files[$scope]}$file\n"
    fi
done

# Find primary scope (most files)
primary_scope=""
max_count=0
for scope in "${!scope_counts[@]}"; do
    count=${scope_counts[$scope]}
    if [ $count -gt $max_count ]; then
        max_count=$count
        primary_scope="$scope"
    fi
done

# Determine confidence
confidence="low"
total_files=${#files[@]}
if [ -n "$primary_scope" ]; then
    primary_percentage=$((max_count * 100 / total_files))
    if [ $primary_percentage -ge 80 ]; then
        confidence="high"
    elif [ $primary_percentage -ge 50 ]; then
        confidence="medium"
    fi
fi

# Build affected areas JSON
affected_areas="{"
first=true
for scope in "${!scope_counts[@]}"; do
    if [ "$first" = true ]; then
        first=false
    else
        affected_areas+=","
    fi
    affected_areas+="\"$scope\":${scope_counts[$scope]}"
done
affected_areas+="}"

# Build reasoning
if [ -n "$primary_scope" ]; then
    reasoning="Primary scope '$primary_scope' identified from $max_count of $total_files files ($primary_percentage%)."
else
    reasoning="Unable to identify clear scope. Files span multiple unrelated areas."
fi

# Output JSON
cat <<EOF
{
  "scope": ${primary_scope:+\"$primary_scope\"},
  "confidence": "$confidence",
  "reasoning": "$reasoning",
  "affected_areas": $affected_areas,
  "total_files": $total_files,
  "primary_file_count": $max_count,
  "primary_percentage": ${primary_percentage:-0}
}
EOF

exit 0
