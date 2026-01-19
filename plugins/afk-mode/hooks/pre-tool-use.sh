#!/bin/bash
# AFK Mode - PreToolUse Hook
# Blocks or allows tools based on current AFK mode
#
# Input: JSON via stdin with tool_name, tool_input
# Output: JSON with hookSpecificOutput for permission decision

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
STATE_SCRIPT="$PLUGIN_ROOT/skills/afk/scripts/state.sh"

# Read input from stdin
INPUT=$(cat)

# Check if AFK mode is enabled
if ! "$STATE_SCRIPT" is-enabled | grep -q "true"; then
    # Not in AFK mode - allow everything
    exit 0
fi

# Get current mode and message
MODE=$("$STATE_SCRIPT" get-mode)
MESSAGE=$("$STATE_SCRIPT" get-message)

# Extract tool name from input
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
TOOL_INPUT=$(echo "$INPUT" | jq -c '.tool_input // {}')

# Check if tool is allowed in current mode
if "$STATE_SCRIPT" is-allowed "$TOOL_NAME" | grep -q "true"; then
    # Tool allowed - but add context about AFK mode
    cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "permissionDecisionReason": "[AFK MODE: $MODE] Tool allowed. $MESSAGE",
    "additionalContext": "AFK mode is active (mode: $MODE). You may use read-only tools. Continue planning - only stop when you genuinely need user input."
  }
}
EOF
    exit 0
fi

# Tool not allowed - log and block
"$STATE_SCRIPT" log-blocked "$TOOL_NAME" "$TOOL_INPUT" "Blocked by AFK mode ($MODE)" 2>/dev/null || true

# Return deny decision with contextual message
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "[AFK MODE: $MODE] $MESSAGE\n\nBlocked tool: $TOOL_NAME\n\nContinue planning without this tool. Document what you would do in your response. Only stop when you absolutely need user permission or input to proceed."
  }
}
EOF
