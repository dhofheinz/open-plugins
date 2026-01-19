# Enable AFK Mode

Enable AFK mode with the specified tier and optional custom message.

## Parameters

- `MODE` - The AFK mode: `full`, `plan`, `research`, or `monitor` (passed from router)
- `MESSAGE` - Optional custom message (remaining arguments)

## Modes

| Mode | Allowed Tools | Use Case |
|------|---------------|----------|
| `full` | None | Pure planning, no tool access |
| `plan` | Read, Glob, Grep | Read-only codebase exploration |
| `research` | Read, Glob, Grep, WebFetch, WebSearch | Online research |
| `monitor` | Read, Glob, Grep, Bash | Status checks and monitoring |

## Instructions

1. Run the state script to enable AFK mode:

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/afk/scripts/state.sh" enable "<MODE>" "<MESSAGE>"
```

Where `<MODE>` is the mode from routing and `<MESSAGE>` is the remaining arguments or default.

2. Confirm to user:
   - AFK mode is now **ENABLED**
   - Mode: `<MODE>`
   - Allowed tools for this mode
   - The message that will be shown when tools are blocked
   - Commands: `/afk off` to disable, `/afk status` to check, `/afk review` to see plans

3. Mention the `afk-planner` agent is available for comprehensive planning tasks.
