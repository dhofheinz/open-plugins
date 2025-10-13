---
description: Guide users through plugin architecture decisions and component selection for Claude Code plugins
---

# Plugin Design Skill

Expert guidance for designing Claude Code plugin architecture with optimal component selection and pattern recommendations.

## Operations

- **analyze** - Analyze requirements and suggest optimal architecture
- **select-components** - Determine which components to use (commands, agents, hooks, MCP)
- **recommend** - Suggest architectural patterns based on complexity
- **estimate** - Assess implementation complexity and effort

## Usage Examples

```bash
# Analyze requirements
/plugin-design analyze requirements:"Need to automate database backups with scheduling"

# Get component recommendations
/plugin-design select-components purpose:"Code quality automation" features:"lint,format,review"

# Get pattern recommendations
/plugin-design recommend complexity:moderate features:3

# Estimate implementation effort
/plugin-design estimate operations:5 has_scripts:true has_agents:true
```

## Router Logic

Parse the first word of $ARGUMENTS to determine the requested operation:

1. Extract operation from first word of $ARGUMENTS
2. Parse remaining arguments as key:value parameters
3. Route to appropriate operation file:
   - "analyze" → Read and execute `{plugin-path}/commands/plugin-design/analyze-requirements.md`
   - "select-components" → Read and execute `{plugin-path}/commands/plugin-design/select-components.md`
   - "recommend" → Read and execute `{plugin-path}/commands/plugin-design/recommend-patterns.md`
   - "estimate" → Read and execute `{plugin-path}/commands/plugin-design/estimate-complexity.md`

**Error Handling**:
- If operation unknown → List available operations with usage examples
- If parameters missing → Request parameters with expected format
- If requirements unclear → Ask clarifying questions

**Base directory**: Plugin commands directory
**Current request**: $ARGUMENTS

Parse operation and route to appropriate instruction file now.
