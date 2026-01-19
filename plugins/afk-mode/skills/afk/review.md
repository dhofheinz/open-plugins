# Review AFK Session

Review planning documents and session logs from AFK sessions.

## Parameters

- `SESSION_ID` - Optional. If omitted, reviews current or most recent session.

## Instructions

1. Determine session to review:

```bash
# If session ID provided as argument, use it
# Otherwise get current session
"${CLAUDE_PLUGIN_ROOT}/skills/afk/scripts/state.sh" get-session-id

# If no current session, list available:
ls -t ~/.claude/afk-mode/plans/*.md 2>/dev/null | head -5
```

2. Get planning document path:

```bash
# For current session:
"${CLAUDE_PLUGIN_ROOT}/skills/afk/scripts/state.sh" get-plan-path

# Or construct from session ID:
# ~/.claude/afk-mode/plans/<SESSION_ID>.md
```

3. Read and display the planning document

4. Summarize session log if exists:

```bash
# Session log at:
# ~/.claude/afk-mode/sessions/<SESSION_ID>.jsonl
```

Count events by type (tool_blocked, tool_allowed, stop, etc.)

5. Report to user:
   - Session ID and timestamps
   - Planning document contents
   - Statistics (tools blocked by name, stop events)
   - Highlight any "NEEDS USER INPUT" items
   - Suggest next actions based on plans
