---
name: afk
description: AFK (Away From Keyboard) mode - enable tiered modes, check status, review sessions. Use /afk [operation] where operation is full|plan|research|monitor|off|status|review
allowed-tools: Read, Bash
---

# AFK Mode Skill

Manage AFK (Away From Keyboard) mode with tiered tool access and session tracking.

## Operations

- [Enable AFK mode](enable.md) - Activate AFK with tiered tool access (full/plan/research/monitor)
- [Disable AFK mode](off.md) - Turn off AFK and resume normal operation
- [Check status](status.md) - View current AFK status and statistics
- [Review session](review.md) - Review planning documents and blocked actions

## Routing

Parse `$ARGUMENTS` to determine the operation:

| First Word | Operation | Description |
|------------|-----------|-------------|
| `full` | [enable.md](enable.md) | No tools allowed |
| `plan` | [enable.md](enable.md) | Read-only tools (Read, Glob, Grep) |
| `research` | [enable.md](enable.md) | Read + web (WebFetch, WebSearch) |
| `monitor` | [enable.md](enable.md) | Read + Bash |
| `off` | [off.md](off.md) | Disable AFK mode |
| `status` | [status.md](status.md) | Show current status |
| `review` | [review.md](review.md) | Review planning session |
| *(empty/other)* | [enable.md](enable.md) | Default to full mode |

## Usage Examples

```
/afk                           → full mode, default message
/afk full "In a meeting"       → full mode, custom message
/afk plan "Explore codebase"   → plan mode (read-only)
/afk research                  → research mode (read + web)
/afk off                       → disable
/afk status                    → check status
/afk review                    → review current/last session
/afk review 20240115_103000    → review specific session
```

## State Management

All state operations use the script at `scripts/state.sh`:

```bash
"${CLAUDE_PLUGIN_ROOT}/skills/afk/scripts/state.sh" <command> [args]
```

Commands: `enable`, `disable`, `is-enabled`, `get-state`, `get-mode`, `get-message`, `get-allowed`, `is-allowed`, `get-plan-path`, `get-log-path`
