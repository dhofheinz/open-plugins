---
description: Analyze user requirements and suggest optimal plugin architecture with component recommendations
---

# Analyze Plugin Requirements

## Parameters

**Required**:
- `requirements`: Description of what the plugin should do (format: quoted string)

**Optional**:
- `target_users`: Who will use this plugin (default: "developers")
- `use_case`: Primary use case category (default: "general")

## Workflow

### Step 1: Parse Requirements

Extract key information from the requirements string:
- **Core Functionality**: What is the primary purpose?
- **Operations Needed**: What specific actions will users perform?
- **Automation vs Manual**: Does it need proactive behavior or on-demand invocation?
- **External Dependencies**: Does it need external tools or APIs?
- **Complexity Indicators**: How many operations? State management needed?

### Step 2: Domain Classification

Classify the plugin into one of the OpenPlugins categories:
- `development`: Code generation, scaffolding, refactoring
- `testing`: Test generation, coverage analysis, quality assurance
- `deployment`: CI/CD, infrastructure, release automation
- `documentation`: Documentation generation, API docs
- `security`: Vulnerability scanning, secret detection
- `database`: Schema design, migrations, queries
- `monitoring`: Performance analysis, logging, observability
- `productivity`: Workflow automation, task management
- `quality`: Linting, formatting, code review
- `collaboration`: Team tools, communication integration

### Step 3: Component Analysis

Determine which components are needed:

**Commands Needed If**:
- Users need on-demand functionality
- Operations are explicitly invoked
- Simple slash command interface is sufficient

**Agents Needed If**:
- Domain expertise is required
- Automatic invocation based on context is desired
- Specialized analysis or decision-making is needed
- Conversational guidance would help users

**Hooks Needed If**:
- Automation on specific events is required
- Workflow enforcement is desired
- Actions should trigger on tool usage (Write, Edit, Bash, etc.)
- Session lifecycle management is beneficial

**MCP Servers Needed If**:
- External tool integration is required
- Custom data sources must be accessed
- API wrappers are needed
- Real-time data streaming is beneficial

### Step 4: Pattern Recognition

Match requirements to architectural patterns:

**Simple Pattern** (Single command, no orchestration):
- 1-2 operations
- Stateless execution
- No complex workflows
- Direct functionality

**Moderate Pattern** (Multiple related commands):
- 3-5 operations
- Some shared context
- Light orchestration
- May benefit from namespace organization

**Complex Pattern** (Orchestrated workflow with skill.md):
- 5+ operations
- Shared state management
- Complex argument parsing needed
- Workflows that compose multiple operations
- Benefits from intelligent routing

### Step 5: Template Selection

Recommend appropriate template:

**simple-crud Template**:
- Operations: create, read, update, delete, list
- Stateless resource management
- Minimal external dependencies

**workflow-orchestration Template**:
- Operations: start, execute, monitor, pause/resume, complete, rollback
- State machine with transitions
- Multi-step processes

**script-enhanced Template**:
- Complex logic better expressed in Python/Bash
- Performance-critical operations
- Integration with external CLI tools

**mcp-integration Template**:
- Primary purpose is exposing MCP server capabilities
- Thin wrapper with convenience arguments
- Direct mapping to MCP tools

### Step 6: Generate Analysis Report

Provide comprehensive analysis with:
- Recommended architecture pattern
- Component breakdown with rationale
- Suggested operations list
- MCP tool dependencies
- Script requirements
- Complexity assessment
- Implementation effort estimate
- Example usage patterns

## Output Format

```markdown
## Plugin Architecture Analysis

### Requirements Summary
**Core Purpose**: {extracted purpose}
**Primary Operations**: {list of operations}
**Target Category**: {OpenPlugins category}

### Recommended Architecture

**Pattern**: {Simple|Moderate|Complex}
**Template**: {template name}

### Component Breakdown

**Commands** (Required/Optional):
- {command-name}: {rationale}

**Agents** (Required/Optional):
- {agent-name}: {rationale}

**Hooks** (Required/Optional):
- {hook-event}: {rationale}

**MCP Servers** (Required/Optional):
- {server-name}: {rationale}

### Operations Design

1. **{operation-name}**: {description}
   - Parameters: {params}
   - Complexity: {low|medium|high}

### Script Requirements

**Utility Scripts Needed**:
- {script-name}.{ext}: {purpose}

### Implementation Estimate

- **Complexity**: {Low|Medium|High}
- **Estimated Time**: {time range}
- **Operations Count**: {number}
- **Scripts Needed**: {number}

### Next Steps

1. {actionable step 1}
2. {actionable step 2}
3. {actionable step 3}

### Example Usage After Creation

```bash
/{plugin-name} {example operation}
```
```

## Error Handling

- **Missing requirements** → Request detailed description of plugin purpose
- **Vague requirements** → Ask clarifying questions about specific functionality
- **Conflicting requirements** → Highlight conflicts and suggest resolution
- **Too broad scope** → Suggest breaking into multiple focused plugins

## Examples

### Example 1: Database Backup Plugin

**Input**:
```
requirements:"Need to automate PostgreSQL database backups with compression, encryption, and restore capabilities"
```

**Analysis**:
- Category: database
- Pattern: Complex (workflow orchestration)
- Template: workflow-orchestration
- Components: Commands (4 ops), Scripts (3 utilities)
- Operations: backup, restore, list, verify
- Scripts: connection-test.sh, compress-encrypt.py, integrity-check.sh
- Complexity: Medium
- Time: 20-30 minutes

### Example 2: Code Formatter Plugin

**Input**:
```
requirements:"Simple code formatting for Python and JavaScript files"
```

**Analysis**:
- Category: quality
- Pattern: Simple
- Template: simple-crud (adapted)
- Components: Commands (2 ops)
- Operations: format, check
- Scripts: None needed
- Complexity: Low
- Time: 10-15 minutes

**Request**: $ARGUMENTS
