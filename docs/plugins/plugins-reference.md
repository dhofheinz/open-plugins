# Plugins reference

Complete technical reference for Claude Code plugin system, including schemas, CLI commands, and component specifications.

## Plugin components reference

### Commands

Plugins add custom slash commands that integrate seamlessly with Claude Code's command system.

**Location**: `commands/` directory in plugin root
**File format**: Markdown files with frontmatter

### Agents

Plugins can provide specialized subagents for specific tasks that Claude can invoke automatically.

**Location**: `agents/` directory in plugin root
**File format**: Markdown files describing agent capabilities

Example agent structure:

```markdown
---
description: What this agent specializes in
capabilities: ["task1", "task2", "task3"]
---

# Agent Name

Detailed description of the agent's role, expertise, and when Claude should invoke it.

## Capabilities
- Specific task the agent excels at
- Another specialized capability
- When to use this agent vs others

## Context and examples
Provide examples of when this agent should be used and what kinds of problems it solves.
```

### Hooks

Plugins can provide event handlers that respond to Claude Code events automatically.

**Location**: `hooks/hooks.json` in plugin root, or inline in plugin.json
**Format**: JSON configuration with event matchers and actions

Example hook configuration:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format-code.sh"
          }
        ]
      }
    ]
  }
}
```

### MCP servers

Plugins can bundle Model Context Protocol (MCP) servers to connect Claude Code with external tools and services.

**Location**: `.mcp.json` in plugin root, or inline in plugin.json
**Format**: Standard MCP server configuration

Example MCP server configuration:

```json
{
  "mcpServers": {
    "plugin-database": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"]
    }
  }
}
```

## Plugin.json schema

The `plugin.json` file is required at the root of every plugin and defines metadata, components, and dependencies.

### Core fields

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Brief description of what the plugin does",
  "author": "Your Name",
  "license": "MIT"
}
```

### Optional fields

- `dependencies`: Array of plugin names this plugin depends on
- `hooks`: Inline hook configuration (alternative to hooks/hooks.json)
- `mcpServers`: Inline MCP server configuration (alternative to .mcp.json)
- `repository`: URL to the plugin's source repository
- `homepage`: URL to plugin documentation or website

### Full schema example

```json
{
  "name": "example-plugin",
  "version": "1.0.0",
  "description": "Example plugin demonstrating all features",
  "author": "Claude Team",
  "license": "MIT",
  "repository": "https://github.com/username/example-plugin",
  "homepage": "https://example.com/plugin-docs",
  "dependencies": ["core-utils"],
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh"
          }
        ]
      }
    ]
  },
  "mcpServers": {
    "example-server": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/example",
      "args": ["--verbose"]
    }
  }
}
```

## CLI commands

### /plugin

Main command for managing plugins. Without arguments, opens an interactive menu.

**Usage**: `/plugin [subcommand] [args]`

### /plugin install

Install a plugin from a configured marketplace or URL.

**Usage**:
- `/plugin install <plugin-name>` - Install from default marketplace
- `/plugin install <url>` - Install from URL
- `/plugin install <path>` - Install from local directory

**Examples**:
```bash
/plugin install security-review
/plugin install https://github.com/user/my-plugin
/plugin install ~/my-local-plugin
```

### /plugin uninstall

Remove an installed plugin.

**Usage**: `/plugin uninstall <plugin-name>`

### /plugin enable

Enable a previously disabled plugin.

**Usage**: `/plugin enable <plugin-name>`

### /plugin disable

Temporarily disable a plugin without uninstalling it.

**Usage**: `/plugin disable <plugin-name>`

### /plugin list

Show all installed plugins and their status.

**Usage**: `/plugin list`

### /plugin marketplace

Manage plugin marketplaces.

**Subcommands**:
- `/plugin marketplace add <url-or-repo>` - Add a marketplace
- `/plugin marketplace remove <name>` - Remove a marketplace
- `/plugin marketplace list` - List configured marketplaces
- `/plugin marketplace update` - Refresh marketplace indexes

**Examples**:
```bash
/plugin marketplace add anthropics/claude-code
/plugin marketplace add https://example.com/plugins/marketplace.json
/plugin marketplace list
```

### /plugin info

Display detailed information about a plugin.

**Usage**: `/plugin info <plugin-name>`

Shows:
- Plugin metadata (name, version, author, description)
- Installed components (commands, agents, hooks, MCP servers)
- Dependencies
- Status (enabled/disabled)

## Environment variables

Plugins have access to these environment variables at runtime:

- `CLAUDE_PLUGIN_ROOT`: Absolute path to the plugin's installation directory
- `CLAUDE_PLUGIN_NAME`: Name of the currently executing plugin
- `CLAUDE_PLUGIN_VERSION`: Version of the currently executing plugin
- `CLAUDE_WORKING_DIR`: Current working directory in Claude Code session

## Best practices

1. **Version your plugins**: Use semantic versioning (major.minor.patch)
2. **Document dependencies**: Clearly state what your plugin requires
3. **Test before publishing**: Verify all components work in isolation
4. **Use relative paths**: Reference plugin files using `${CLAUDE_PLUGIN_ROOT}`
5. **Handle errors gracefully**: Provide clear error messages for users
6. **Keep plugins focused**: Each plugin should solve one problem well
7. **Update marketplace.json**: Keep your marketplace index current
