#!/bin/bash
# AFK Mode - PostToolUse Hook
# Logs successful tool usage and provides context after allowed tools complete
#
# Input: JSON via stdin with tool_name, tool_input, tool_response
# Output: JSON with additionalContext for Claude

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
STATE_SCRIPT="$PLUGIN_ROOT/skills/afk/scripts/state.sh"

# Read input from stdin
INPUT=$(cat)

# Check if AFK mode is enabled
if ! "$STATE_SCRIPT" is-enabled | grep -q "true"; then
    # Not in AFK mode - no additional context
    exit 0
fi

# Get current state
MODE=$("$STATE_SCRIPT" get-mode)
STATE=$("$STATE_SCRIPT" get-state)
TOOLS_BLOCKED=$(echo "$STATE" | jq -r '.stats.tools_blocked // 0')

# Extract tool info
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')

# Log to session
SESSION_ID=$("$STATE_SCRIPT" get-session-id)
TIMESTAMP=$(date -Iseconds)
if [ -n "$SESSION_ID" ]; then
    SESSIONS_DIR="$HOME/.claude/afk-mode/sessions"
    if [ -f "$SESSIONS_DIR/$SESSION_ID.jsonl" ]; then
        echo "{\"event\":\"tool_allowed\",\"timestamp\":\"$TIMESTAMP\",\"tool\":\"$TOOL_NAME\"}" >> "$SESSIONS_DIR/$SESSION_ID.jsonl"
    fi
fi

# Provide reminder context after each tool use
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "[AFK MODE: $MODE] Tool '$TOOL_NAME' completed. Continue planning. $TOOLS_BLOCKED tools have been blocked this session. Remember: only stop when you genuinely need user input."
  }
}
EOF
