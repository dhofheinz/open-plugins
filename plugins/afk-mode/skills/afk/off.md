# Disable AFK Mode

Disable AFK mode and resume normal operation.

## Instructions

1. Get current state before disabling (for summary):

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/afk/scripts/state.sh" get-state
```

2. Get planning document path:

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/afk/scripts/state.sh" get-plan-path
```

3. Disable AFK mode:

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/afk/scripts/state.sh" disable
```

4. Report to user:
   - AFK mode is now **DISABLED**
   - Session statistics (tools blocked, stop events)
   - Planning document location (if exists)
   - Suggest `/afk review` to see what was planned
   - All tools now available
