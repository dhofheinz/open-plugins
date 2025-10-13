# Plugins

Extend Claude Code with custom commands, agents, hooks, and MCP servers through the plugin system.

## Quickstart

### Prerequisites
- Claude Code installed
- Basic command-line tool familiarity

### Create Your First Plugin

1. Create marketplace structure:
```bash
mkdir test-marketplace
cd test-marketplace
```

2. Create plugin directory:
```bash
mkdir my-first-plugin
cd my-first-plugin
```

3. Create plugin manifest (`plugin.json`):
```json
{
  "name": "my-first-plugin",
  "description": "A simple greeting plugin to learn the basics",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
```

4. Add a custom command (`commands/hello.md`):
```markdown
---
description: Greet the user with a personalized message
---

# Hello Command

Greet the user warmly and ask how you can help them today. Make the greeting personal and encouraging.
```

5. Create marketplace manifest:
```json
{
  "name": "test-marketplace",
  "owner": {
    "name": "Test User"
  },
  "plugins": [
    {
      "name": "my-first-plugin",
      "source": "./my-first-plugin",
      "description": "My first test plugin"
    }
  ]
}
```

6. Install and test:
```bash
claude
/plugin marketplace add ./test-marketplace
/plugin install my-first-plugin@test-marketplace
/hello
```

## Plugin Structure Overview

```
my-first-plugin/
├── plugin.json               # Plugin metadata (required)
├── commands/                 # Custom slash commands (optional)
│   └── hello.md
├── agents/                   # Custom agents (optional)
│   └── helper.md
└── hooks/                    # Event handlers (optional)
    └── hooks.json
```

## Install and Manage Plugins

### Add Marketplaces
```bash
/plugin marketplace add your-org/claude-plugins
/plugin marketplace add https://example.com/marketplace.json
/plugin marketplace add ./local-marketplace
```

### Install Plugins
```bash
/plugin install plugin-name
/plugin install plugin-name@marketplace-name
/plugin install https://github.com/user/repo
/plugin install ./local-plugin-path
```

### Manage Installed Plugins
```bash
/plugin list                    # View all plugins
/plugin info plugin-name        # See plugin details
/plugin enable plugin-name      # Enable a plugin
/plugin disable plugin-name     # Disable without uninstalling
/plugin uninstall plugin-name   # Remove completely
```

## Building Plugin Components

### Commands

Commands add new slash commands to Claude Code.

**File location**: `commands/command-name.md`

**Basic command structure**:
```markdown
---
description: Brief description of what this command does
---

# Command Name

Detailed instructions for Claude on how to execute this command.
Include specific steps, expected behavior, and any important context.
```

**Example - Code Review Command**:
```markdown
---
description: Review code changes with security and performance focus
---

# Code Review

Perform a comprehensive code review focusing on:

1. Security vulnerabilities and best practices
2. Performance implications
3. Code maintainability and readability
4. Test coverage
5. Documentation quality

For each finding, provide:
- Severity level (critical/high/medium/low)
- Specific line references
- Explanation of the issue
- Suggested fix with code example

Conclude with an overall assessment and priority recommendations.
```

### Agents

Agents are specialized assistants that Claude can invoke for specific tasks.

**File location**: `agents/agent-name.md`

**Agent structure**:
```markdown
---
description: What this agent specializes in
capabilities: ["capability1", "capability2"]
---

# Agent Name

## Role
Define the agent's primary purpose and expertise area.

## When to Invoke
Describe scenarios where Claude should use this agent.

## Capabilities
- Specific task 1
- Specific task 2
- Specific task 3

## Examples
Provide concrete examples of tasks this agent handles.
```

**Example - Database Migration Agent**:
```markdown
---
description: Database schema migration and data transformation specialist
capabilities: ["schema-design", "migration-scripts", "data-validation"]
---

# Database Migration Agent

## Role
Expert in database migrations, schema changes, and data transformations across various database systems (PostgreSQL, MySQL, MongoDB, etc.).

## When to Invoke
Use this agent when:
- Creating or modifying database schemas
- Writing migration scripts
- Planning data transformations
- Validating data integrity
- Optimizing database queries

## Capabilities
- Design normalized database schemas
- Write safe, reversible migrations
- Generate seed data
- Validate data constraints
- Optimize query performance
- Handle complex data transformations

## Examples
- "Create a migration to add user roles and permissions"
- "Refactor the orders table to support multiple currencies"
- "Write a script to migrate legacy data to new schema"
```

### Hooks

Hooks let you run code in response to Claude Code events.

**File location**: `hooks/hooks.json`

**Hook configuration structure**:
```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "pattern",
        "hooks": [
          {
            "type": "command",
            "command": "path/to/script.sh",
            "args": ["arg1", "arg2"]
          }
        ]
      }
    ]
  }
}
```

**Available events**:
- `PostToolUse`: After Claude uses a tool (Write, Edit, Bash, etc.)
- `PreToolUse`: Before Claude uses a tool
- `SessionStart`: When a new session begins
- `SessionEnd`: When a session ends

**Example - Auto-format on file changes**:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format.sh",
            "args": ["${TOOL_RESULT_PATH}"]
          }
        ]
      }
    ]
  }
}
```

**Example - Git commit validation**:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash.*git commit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate-commit.sh"
          }
        ]
      }
    ]
  }
}
```

### MCP Servers

Bundle Model Context Protocol servers to connect Claude Code with external tools.

**File location**: `.mcp.json` in plugin root, or inline in `plugin.json`

**MCP server configuration**:
```json
{
  "mcpServers": {
    "server-name": {
      "command": "path/to/server",
      "args": ["--option", "value"],
      "env": {
        "VAR_NAME": "value"
      }
    }
  }
}
```

**Example - Database MCP Server**:
```json
{
  "mcpServers": {
    "database": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--db-path", "${HOME}/.local/app.db"],
      "env": {
        "DB_READONLY": "true"
      }
    }
  }
}
```

## Plugin.json Reference

Complete plugin manifest with all options:

```json
{
  "name": "comprehensive-plugin",
  "version": "1.0.0",
  "description": "A fully-featured example plugin",
  "author": {
    "name": "Your Name",
    "email": "you@example.com",
    "url": "https://example.com"
  },
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "https://github.com/user/repo"
  },
  "homepage": "https://example.com/plugin-docs",
  "keywords": ["productivity", "automation"],
  "dependencies": {
    "required-plugin": "^1.0.0"
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/validate.sh"
          }
        ]
      }
    ]
  },
  "mcpServers": {
    "my-server": {
      "command": "${CLAUDE_PLUGIN_ROOT}/server",
      "args": ["--config", "config.json"]
    }
  }
}
```

## Publishing Plugins

### To GitHub

1. Create repository for your plugin
2. Add `plugin.json` at the plugin root
3. Add plugin components (commands, agents, hooks)
4. Push to GitHub
5. Users can install with: `/plugin install github-user/repo-name`

### To a Marketplace

1. Create or update `marketplace.json`
2. Add your plugin to the plugins array:
```json
{
  "name": "my-marketplace",
  "owner": {
    "name": "Marketplace Owner"
  },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "https://github.com/user/my-plugin",
      "description": "What the plugin does",
      "version": "1.0.0"
    }
  ]
}
```
3. Host the marketplace.json (GitHub, web server, etc.)
4. Users add with: `/plugin marketplace add your-marketplace-url`

## Best Practices

### Design
- **Single responsibility**: Each plugin should do one thing well
- **Clear naming**: Use descriptive, action-oriented command names
- **Good documentation**: Write clear command descriptions and examples
- **Version properly**: Use semantic versioning (major.minor.patch)

### Development
- **Test thoroughly**: Try all commands and edge cases
- **Handle errors**: Provide helpful error messages
- **Use variables**: Leverage `${CLAUDE_PLUGIN_ROOT}` for paths
- **Stay focused**: Keep plugins small and composable

### Distribution
- **Document dependencies**: List required plugins and tools
- **Provide examples**: Show real usage scenarios
- **Maintain changelog**: Document what changes in each version
- **License clearly**: Choose an appropriate open source license

## Environment Variables

Available in plugin scripts and hooks:

- `CLAUDE_PLUGIN_ROOT`: Absolute path to plugin directory
- `CLAUDE_PLUGIN_NAME`: Name of the executing plugin
- `CLAUDE_PLUGIN_VERSION`: Version of the executing plugin
- `CLAUDE_WORKING_DIR`: Current working directory
- `TOOL_RESULT_PATH`: (In hooks) Path to file affected by tool use

## Common Patterns

### Multi-step Workflows

Create a command that orchestrates multiple operations:

```markdown
---
description: Set up a new React component with tests and stories
---

# Component Scaffold

Create a new React component with:
1. Component file with TypeScript
2. Test file with React Testing Library
3. Storybook story file
4. Export from index.ts

Ask for the component name and purpose, then:
- Generate component with proper TypeScript types
- Create comprehensive test suite
- Add Storybook stories for all states
- Update index.ts with new export
```

### Context-Aware Commands

Use agents to provide specialized context:

```markdown
---
description: Security-focused code reviewer
capabilities: ["security-audit", "vulnerability-detection"]
---

# Security Reviewer Agent

Specialized in identifying security vulnerabilities:
- SQL injection risks
- XSS vulnerabilities
- Authentication/authorization issues
- Secrets in code
- Insecure dependencies
- CSRF vulnerabilities

When reviewing code, check against OWASP Top 10 and provide:
- Risk rating
- Exploitation scenario
- Remediation steps
- Secure code example
```

### Automation with Hooks

Auto-run checks after file changes:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write.*\\.ts$|Edit.*\\.ts$",
        "hooks": [
          {
            "type": "command",
            "command": "npx",
            "args": ["tsc", "--noEmit", "${TOOL_RESULT_PATH}"]
          }
        ]
      }
    ]
  }
}
```

## Troubleshooting

### Plugin Won't Install
- Check `plugin.json` syntax (must be valid JSON)
- Verify all required fields are present (name, version, description)
- Ensure marketplace URL or path is accessible

### Command Not Working
- Verify command file is in `commands/` directory
- Check filename matches command name (hello.md → /hello)
- Ensure frontmatter has description field
- Review command instructions for clarity

### Hook Not Triggering
- Verify event name matches available events
- Check matcher pattern syntax (uses regex)
- Ensure script has execute permissions
- Test script independently first

### Agent Not Being Used
- Make description and capabilities very specific
- Provide clear examples of when to use
- Test by explicitly asking Claude to use the agent
- Verify agent file is in `agents/` directory

## Example Plugins

### PR Review Plugin
```
pr-review-plugin/
├── plugin.json
├── commands/
│   ├── review-pr.md
│   └── review-security.md
└── agents/
    └── security-reviewer.md
```

### Testing Plugin
```
testing-plugin/
├── plugin.json
├── commands/
│   ├── generate-tests.md
│   └── run-coverage.md
└── hooks/
    └── hooks.json
```

### DevOps Plugin
```
devops-plugin/
├── plugin.json
├── commands/
│   ├── deploy.md
│   └── rollback.md
├── agents/
│   └── infrastructure.md
└── .mcp.json
```
