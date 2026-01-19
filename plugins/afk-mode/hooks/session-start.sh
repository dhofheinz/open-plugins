#!/bin/bash
# AFK Mode - SessionStart Hook
# Restores AFK state and provides context when session starts/resumes
#
# Input: JSON via stdin with source (startup, resume, clear, compact)
# Output: JSON with additionalContext for Claude

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
STATE_SCRIPT="$PLUGIN_ROOT/skills/afk/scripts/state.sh"

# Read input from stdin
INPUT=$(cat)
SOURCE=$(echo "$INPUT" | jq -r '.source // "startup"')

# Check if AFK mode is enabled
if ! "$STATE_SCRIPT" is-enabled | grep -q "true"; then
    # Not in AFK mode - no context needed
    exit 0
fi

# Get current state
MODE=$("$STATE_SCRIPT" get-mode)
MESSAGE=$("$STATE_SCRIPT" get-message)
STATE=$("$STATE_SCRIPT" get-state)

# Extract stats
TOOLS_BLOCKED=$(echo "$STATE" | jq -r '.stats.tools_blocked // 0')
STOP_EVENTS=$(echo "$STATE" | jq -r '.stats.stop_events // 0')
STARTED_AT=$(echo "$STATE" | jq -r '.started_at // "unknown"')

# Get allowed tools for this mode
ALLOWED_TOOLS=$("$STATE_SCRIPT" get-allowed)
if [ -z "$ALLOWED_TOOLS" ]; then
    ALLOWED_TOOLS="None (pure planning mode)"
fi

# Build context message
CONTEXT="## AFK Mode Active

**Mode**: $MODE
**Started**: $STARTED_AT
**Tools Blocked**: $TOOLS_BLOCKED
**Allowed Tools**: $ALLOWED_TOOLS

**User Message**: $MESSAGE

### Instructions
- Continue planning and reasoning
- Use allowed tools ($ALLOWED_TOOLS) for exploration
- Document what actions you would take
- Only stop when you genuinely need user input or permission
- Use /afk review to see your planning document

### Session Status
This is a $SOURCE event. AFK mode persists across sessions."

# Return context for Claude
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $(echo "$CONTEXT" | jq -Rs '.')
  }
}
EOF
