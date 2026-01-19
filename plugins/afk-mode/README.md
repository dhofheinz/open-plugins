# AFK Mode Plugin v1.0

Advanced "Away From Keyboard" mode for Claude Code with tiered tool access, session recording, and autonomous planning support.

## Features

- **Tiered AFK Modes**: Choose how much tool access Claude has while you're away
- **Multi-Hook State Machine**: Intelligent session management across SessionStart, PreToolUse, PostToolUse, and Stop events
- **Session Recording**: Every blocked action is logged for later review
- **Planning Documents**: Auto-generated markdown documents capture Claude's plans
- **AFK Planner Agent**: Specialized agent optimized for autonomous planning
- **Persistence**: AFK state survives across Claude Code sessions

## Installation

### Via OpenPlugins Marketplace

```bash
# Add the marketplace (one-time)
/plugin_marketplace_add https://github.com/dhofheinz/open-plugins

# Install the plugin
/plugin_install afk-mode@open-plugins

# Restart Claude Code
```

### Manual Installation

Copy the `afk-mode` directory to `~/.claude/plugins/`

## Usage

### Quick Start

```bash
# Enable full AFK mode (blocks all tools)
/afk

# Enable with custom message
/afk "I'm in a meeting. Plan the authentication feature."

# Disable AFK mode
/afk off
```

### Tiered Modes

| Mode | Command | Allowed Tools | Use Case |
|------|---------|---------------|----------|
| **full** | `/afk full` | None | Pure planning, no tool access |
| **plan** | `/afk plan` | Read, Glob, Grep | Read-only codebase exploration |
| **research** | `/afk research` | Read, Glob, Grep, WebFetch, WebSearch | Online research while planning |
| **monitor** | `/afk monitor` | Read, Glob, Grep, Bash | Status checks and monitoring |

### Examples

```bash
# Full AFK - pure planning
/afk full "Design the API architecture. I'll review when back."

# Plan mode - can read files
/afk plan "Explore the codebase and document the structure."

# Research mode - can search web
/afk research "Research best practices for caching strategies."

# Monitor mode - can run read-only commands
/afk monitor "Check build status and test results."

# Check status
/afk status

# Review session
/afk review

# Disable
/afk off
```

## Commands

All operations through the `/afk` skill:

| Command | Description |
|---------|-------------|
| `/afk [message]` | Enable full AFK mode (default) |
| `/afk full [message]` | Enable full mode - no tools allowed |
| `/afk plan [message]` | Enable plan mode - read-only tools |
| `/afk research [message]` | Enable research mode - read + web |
| `/afk monitor [message]` | Enable monitor mode - read + bash |
| `/afk off` | Disable AFK mode and show session summary |
| `/afk status` | Check current AFK status and statistics |
| `/afk review [session-id]` | Review planning documents and blocked actions |

## Architecture

### Multi-Hook State Machine

```
┌─────────────────┐
│  SessionStart   │ → Restores AFK state, shows summary
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   PreToolUse    │ → Blocks/allows tools based on mode
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  PostToolUse    │ → Logs allowed tool usage
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│      Stop       │ → Evaluates if Claude should continue
└─────────────────┘
```

### Hook Behaviors

1. **SessionStart**: When Claude Code starts or resumes, checks if AFK mode was active and restores context
2. **PreToolUse**: Intercepts every tool call, blocks based on mode, logs blocked attempts
3. **PostToolUse**: After allowed tools complete, adds context reminders
4. **Stop**: When Claude would stop, evaluates if planning should continue (up to 5 cycles)

### AFK Planner Agent

A specialized agent optimized for planning without tools:
- Automatically suggested during AFK mode
- Creates structured implementation plans
- Documents decisions that need user input
- Outputs to standard planning format

Invoke explicitly:
```
Use the afk-planner agent to create a detailed implementation plan for [task]
```

## State & Session Files

### State File
`~/.claude/afk-mode/state.json`
```json
{
  "enabled": true,
  "mode": "plan",
  "message": "Custom AFK message",
  "session_id": "20240115_103000",
  "started_at": "2024-01-15T10:30:00Z",
  "stats": {
    "tools_blocked": 12,
    "tools_allowed": 5,
    "stop_events": 2
  }
}
```

### Session Logs
`~/.claude/afk-mode/sessions/{session_id}.jsonl`
```jsonl
{"event":"session_start","timestamp":"...","mode":"plan"}
{"event":"tool_blocked","timestamp":"...","tool":"Write","input":{...}}
{"event":"tool_allowed","timestamp":"...","tool":"Read"}
{"event":"stop","timestamp":"...","reason":"Stop hook triggered"}
{"event":"session_end","timestamp":"..."}
```

### Planning Documents
`~/.claude/afk-mode/plans/{session_id}.md`

Auto-generated markdown capturing:
- Session metadata
- Planned actions
- Blocked tool calls with details
- Decisions needing user input
- Claude's notes and analysis

## Plugin Structure

```
afk-mode/
├── .claude-plugin/
│   └── plugin.json              # Manifest with all hooks
├── skills/
│   └── afk/
│       ├── SKILL.md             # Skill router for /afk
│       ├── enable.md            # Enable operation
│       ├── off.md               # Disable operation
│       ├── status.md            # Status operation
│       ├── review.md            # Review operation
│       └── scripts/
│           └── state.sh         # State management utilities
├── agents/
│   └── afk-planner.md           # Planning specialist agent
├── hooks/
│   ├── session-start.sh         # SessionStart hook
│   ├── pre-tool-use.sh          # PreToolUse hook (main blocker)
│   ├── post-tool-use.sh         # PostToolUse hook (logging)
│   └── stop.sh                  # Stop hook (continue planning)
└── README.md
```

## How It Works

### When You Enable AFK Mode

1. State file created with mode, message, session ID
2. Session log initialized
3. Planning document created
4. All hooks become active

### While You're Away

1. **PreToolUse** intercepts every tool call
2. Checks if tool is allowed for current mode
3. If blocked: logs to session, updates planning doc, returns deny with your message
4. If allowed: adds context reminder, logs usage
5. **Stop** hook encourages Claude to continue planning (up to 5 times)

### When You Return

1. Run `/afk off` to disable
2. See session statistics
3. Run `/afk review` to see full planning document
4. Execute planned actions or provide needed decisions

## Best Practices

1. **Use specific messages**: Tell Claude what to focus on
   ```bash
   /afk plan "Focus on the authentication module. Document the token flow."
   ```

2. **Choose appropriate mode**:
   - `full` for deep thinking without distractions
   - `plan` when codebase exploration helps
   - `research` when external info needed
   - `monitor` when status checks useful

3. **Review regularly**: Check `/afk review` to see progress

4. **Use the planner agent**: For complex tasks, explicitly invoke `afk-planner`

## Troubleshooting

### AFK mode not blocking tools
- Check state file exists: `cat ~/.claude/afk-mode/state.json`
- Verify plugin is installed: `/plugin_list`
- Restart Claude Code after installation

### Hooks not firing
- Check hook scripts are executable: `ls -la ~/.claude/plugins/afk-mode/hooks/`
- Run scripts manually to test: `echo '{}' | ~/.claude/plugins/afk-mode/hooks/pre-tool-use.sh`

### State not persisting
- Ensure `~/.claude/afk-mode/` directory exists and is writable
- Check for JSON syntax errors in state file

## License

MIT
