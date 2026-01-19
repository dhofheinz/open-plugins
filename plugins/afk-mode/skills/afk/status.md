# AFK Mode Status

Check current AFK mode status and session statistics.

## Instructions

1. Check if enabled:

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/afk/scripts/state.sh" is-enabled
```

2. If enabled, get full state:

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/afk/scripts/state.sh" get-state
```

3. Get allowed tools for current mode:

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/afk/scripts/state.sh" get-allowed
```

4. Report to user:

**If ENABLED:**
- Status: **ENABLED**
- Mode: (full/plan/research/monitor)
- Started: (timestamp)
- Message: (the AFK message)
- Allowed Tools: (list or "None")
- Stats: tools blocked, stop events
- Planning doc: (path)

**If DISABLED:**
- Status: **DISABLED**
- Normal operation active
- Previous sessions viewable with `/afk review`
