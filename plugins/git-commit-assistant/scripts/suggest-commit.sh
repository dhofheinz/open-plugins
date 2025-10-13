#!/bin/bash
#
# suggest-commit.sh - Proactive commit suggestions after file changes
#
# Purpose: Suggest running /commit when significant changes accumulate
# Version: 1.0.0
# Usage: Called automatically by PostToolUse hook after Write/Edit operations
# Returns: 0 (always, non-intrusive)
#
# Environment Variables:
#   CLAUDE_PLUGIN_ROOT    - Plugin root directory
#   CLAUDE_WORKING_DIR    - Current working directory
#   TOOL_RESULT_PATH      - Path to tool result (if applicable)

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  # Not a git repo, silently exit
  exit 0
fi

# Count unstaged changes
unstaged=$(git status --short 2>/dev/null | wc -l)

# Suggest commit if 5 or more files changed
if [ "$unstaged" -ge 5 ]; then
  echo ""
  echo "💡 TIP: You have $unstaged modified files. Consider running /commit to save your progress."
  echo "   Or run /commit-review to analyze your changes first."
fi

# Check for large number of changes (warning threshold)
if [ "$unstaged" -ge 15 ]; then
  echo ""
  echo "⚠️  WARNING: $unstaged files changed - this is a lot!"
  echo "   Consider running /commit-review to check if you should split commits."
fi

# Always exit successfully (non-intrusive)
exit 0
