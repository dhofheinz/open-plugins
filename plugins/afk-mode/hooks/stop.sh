#!/bin/bash
# AFK Mode - Stop Hook
# Evaluates whether Claude should continue planning or genuinely needs to stop
#
# Input: JSON via stdin with stop_hook_active flag
# Output: JSON with decision to block (continue) or allow (stop)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
STATE_SCRIPT="$PLUGIN_ROOT/skills/afk/scripts/state.sh"

# Read input from stdin
INPUT=$(cat)

# Check if AFK mode is enabled
if ! "$STATE_SCRIPT" is-enabled | grep -q "true"; then
    # Not in AFK mode - allow normal stop behavior
    exit 0
fi

# Check if we're already in a stop hook continuation (prevent infinite loop)
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_ACTIVE" = "true" ]; then
    # Already continuing from a stop hook - allow this stop
    exit 0
fi

# Get state info
MODE=$("$STATE_SCRIPT" get-mode)
MESSAGE=$("$STATE_SCRIPT" get-message)
STATE=$("$STATE_SCRIPT" get-state)
TOOLS_BLOCKED=$(echo "$STATE" | jq -r '.stats.tools_blocked // 0')
STOP_EVENTS=$(echo "$STATE" | jq -r '.stats.stop_events // 0')

# Log this stop event
"$STATE_SCRIPT" log-stop "Stop hook triggered (stop_events: $STOP_EVENTS)" 2>/dev/null || true

# After 5 stop events, allow stopping (user likely needs to check in)
if [ "$STOP_EVENTS" -ge 5 ]; then
    # Too many stops - let Claude stop and prompt user
    cat << EOF
{
  "continue": true,
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "[AFK MODE] Multiple planning cycles completed. Consider reviewing progress with /afk review or disabling with /afk off."
  }
}
EOF
    exit 0
fi

# Encourage Claude to continue planning
cat << EOF
{
  "decision": "block",
  "reason": "[AFK MODE: $MODE] User is away. Continue planning!\n\n$MESSAGE\n\nYou've been blocked $TOOLS_BLOCKED times. This is stop event #$((STOP_EVENTS + 1)).\n\nKeep going:\n1. Document your planned approach\n2. List files you would modify\n3. Outline the implementation steps\n4. Note any decisions that need user input\n5. Continue until you genuinely cannot proceed\n\nIf you've truly exhausted all planning, summarize what you've documented."
}
EOF
