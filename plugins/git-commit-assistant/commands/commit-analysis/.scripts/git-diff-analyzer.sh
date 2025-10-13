#!/bin/bash
# Script: git-diff-analyzer.sh
# Purpose: Parse git diff output for detailed file and line change analysis
# Author: Git Commit Assistant Plugin
# Version: 1.0.0
#
# Usage:
#   git diff HEAD | ./git-diff-analyzer.sh
#
# Returns:
#   JSON with file details, line counts, and change summaries
#
# Exit Codes:
#   0 - Success
#   1 - No input
#   2 - Analysis error

# Read diff from stdin
diff_content=$(cat)

if [ -z "$diff_content" ]; then
    echo '{"error": "No diff content provided"}'
    exit 1
fi

# Initialize counters
total_files=0
total_additions=0
total_deletions=0
declare -A file_stats

# Parse diff output
current_file=""
while IFS= read -r line; do
    # File headers
    if [[ "$line" =~ ^\+\+\+\ b/(.+)$ ]]; then
        current_file="${BASH_REMATCH[1]}"
        ((total_files++))
        file_stats["$current_file,additions"]=0
        file_stats["$current_file,deletions"]=0
        file_stats["$current_file,status"]="M"

    # New file
    elif [[ "$line" =~ ^\+\+\+\ b/(.+)$ ]] && [[ "$diff_content" == *"--- /dev/null"* ]]; then
        file_stats["$current_file,status"]="A"

    # Deleted file
    elif [[ "$line" =~ ^---\ a/(.+)$ ]] && [[ "$diff_content" == *"+++ /dev/null"* ]]; then
        current_file="${BASH_REMATCH[1]}"
        file_stats["$current_file,status"]="D"

    # Count additions
    elif [[ "$line" =~ ^\+[^+] ]] && [ -n "$current_file" ]; then
        ((total_additions++))
        ((file_stats["$current_file,additions"]++))

    # Count deletions
    elif [[ "$line" =~ ^-[^-] ]] && [ -n "$current_file" ]; then
        ((total_deletions++))
        ((file_stats["$current_file,deletions"]++))
    fi
done <<< "$diff_content"

# Build JSON output
echo "{"
echo "  \"summary\": {"
echo "    \"total_files\": $total_files,"
echo "    \"total_additions\": $total_additions,"
echo "    \"total_deletions\": $total_deletions,"
echo "    \"net_change\": $((total_additions - total_deletions))"
echo "  },"
echo "  \"files\": ["

# Output file stats
first=true
for key in "${!file_stats[@]}"; do
    if [[ "$key" == *",status" ]]; then
        file="${key%,status}"
        status="${file_stats[$key]}"
        additions=${file_stats["$file,additions"]:-0}
        deletions=${file_stats["$file,deletions"]:-0}

        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi

        echo -n "    {"
        echo -n "\"file\": \"$file\", "
        echo -n "\"status\": \"$status\", "
        echo -n "\"additions\": $additions, "
        echo -n "\"deletions\": $deletions, "
        echo -n "\"net\": $((additions - deletions))"
        echo -n "}"
    fi
done

echo ""
echo "  ]"
echo "}"

exit 0
