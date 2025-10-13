---
description: Determine which plugin components to use based on functionality requirements
---

# Select Plugin Components

## Parameters

**Required**:
- `purpose`: Plugin's primary purpose (format: quoted string)
- `features`: Comma-separated list of features (format: "feat1,feat2,feat3")

**Optional**:
- `automation`: Whether proactive behavior is needed (format: true|false, default: false)
- `external_tools`: External tools/APIs needed (format: "tool1,tool2")

## Workflow

### Step 1: Feature Analysis

Parse the features list and categorize each feature:
- **User-Initiated Actions**: Operations triggered by explicit user command
- **Proactive Behaviors**: Actions that should happen automatically
- **Background Tasks**: Long-running or scheduled operations
- **Interactive Workflows**: Multi-step conversational processes

### Step 2: Commands Assessment

**Evaluate Need for Commands**:

Commands are appropriate when:
- Users need explicit control over when operations execute
- Functionality is invoked via slash commands
- Operations are discrete and independent
- Simple input/output pattern

**Command Organization**:
- **Single Command**: 1-2 simple operations
- **Namespace**: 3-5 independent operations
- **Skill with skill.md**: 5+ operations needing intelligent routing

**Recommendation Logic**:
```
IF features_count <= 2 AND simple_operations:
  RECOMMEND: Single command
ELSE IF features_count <= 5 AND independent_operations:
  RECOMMEND: Namespace (commands directory without skill.md)
ELSE:
  RECOMMEND: Skill with skill.md router
```

### Step 3: Agents Assessment

**Evaluate Need for Agents**:

Agents are appropriate when:
- Domain expertise would benefit users
- Automatic invocation based on context is valuable
- Guidance and recommendations are needed
- Analysis and decision-making support users

**Agent Design Questions**:
1. Does the plugin domain require specialized knowledge?
2. Would users benefit from conversational guidance?
3. Should the plugin proactively suggest actions?
4. Is there a workflow that needs expert orchestration?

**Recommendation**:
- **Yes to 2+ questions** → Include agent
- **Yes to 1 question** → Consider optional agent
- **No to all** → Commands only sufficient

**Agent Capabilities Mapping**:
Map features to agent capabilities:
- Code analysis → code-review, security-analysis
- Testing → test-generation, coverage-analysis
- Deployment → deployment-orchestration, rollback-management
- Documentation → doc-generation, api-documentation

### Step 4: Hooks Assessment

**Evaluate Need for Hooks**:

Hooks are appropriate when:
- Automation should trigger on specific events
- Workflow enforcement is needed
- Actions should happen transparently
- Quality gates need to be enforced

**Hook Event Mapping**:
- **PostToolUse**: After Write, Edit, Bash, etc.
- **PreToolUse**: Before Write, Edit, etc. (for validation)
- **SessionStart**: Plugin initialization
- **SessionEnd**: Cleanup and reporting

**Common Hook Patterns**:
- **Auto-format on Write**: PostToolUse with Write matcher
- **Lint before commit**: PreToolUse with Bash(git commit) matcher
- **Auto-test on code change**: PostToolUse with Edit matcher
- **Session report**: SessionEnd hook

**Recommendation Logic**:
```
IF automation == true OR workflow_enforcement_needed:
  IDENTIFY triggering events
  RECOMMEND appropriate hooks
ELSE:
  RECOMMEND: Hooks not needed
```

### Step 5: MCP Servers Assessment

**Evaluate Need for MCP Servers**:

MCP servers are appropriate when:
- Plugin needs to integrate external tools not available in Claude Code
- Custom data sources must be accessed
- Specialized APIs need to be wrapped
- Real-time data or streaming is required
- Complex state management across sessions

**MCP Use Cases**:
- **Database Operations**: Dedicated database MCP server
- **Cloud Services**: AWS, GCP, Azure API wrappers
- **Custom Tools**: Internal tools integration
- **Data Processing**: Specialized data pipelines
- **Monitoring**: Metrics and logging services

**Recommendation Logic**:
```
IF external_tools specified:
  FOR each tool:
    CHECK if native Claude Code tool exists
    IF not:
      RECOMMEND MCP server
ELSE IF complex_external_integration:
  RECOMMEND MCP server design
ELSE:
  RECOMMEND: MCP servers not needed
```

### Step 6: Generate Component Recommendations

Create comprehensive component selection report with:
- Recommended components with justification
- Component interaction diagram
- Implementation priority
- Alternative approaches
- Trade-offs and considerations

## Output Format

```markdown
## Component Selection Recommendations

### Plugin Purpose
**Primary Goal**: {purpose}
**Features**: {features list}
**Automation Needed**: {yes/no}
**External Tools**: {tools list}

### Recommended Components

#### Commands ✅ Recommended / ❌ Not Needed

**Decision**: {Recommended|Not Needed}

**Rationale**: {explanation}

**Organization**:
- {Single Command|Namespace|Skill with Router}

**Operations**:
1. **{operation-name}**: {description}
   - Invocation: `/{plugin-name} {operation} {args}`
   - Complexity: {low|medium|high}

#### Agents ✅ Recommended / ⚠️ Optional / ❌ Not Needed

**Decision**: {Recommended|Optional|Not Needed}

**Rationale**: {explanation}

**Agent Design**:
- **Name**: {agent-name}
- **Description**: {when to invoke description}
- **Capabilities**: {capabilities list}
- **Proactive Triggers**: {trigger conditions}

#### Hooks ✅ Recommended / ❌ Not Needed

**Decision**: {Recommended|Not Needed}

**Rationale**: {explanation}

**Hook Configuration**:
- **Event**: {PostToolUse|PreToolUse|SessionStart|SessionEnd}
- **Matcher**: {regex pattern}
- **Action**: {what happens}

#### MCP Servers ✅ Recommended / ❌ Not Needed

**Decision**: {Recommended|Not Needed}

**Rationale**: {explanation}

**Server Design**:
- **Server Name**: {server-name}
- **Purpose**: {what it provides}
- **Tools Exposed**: {tool list}

### Component Interaction Flow

```
{Describe how components interact}

Example:
1. User invokes /{plugin-name} {operation}
2. Command validates input
3. Agent provides guidance if complex
4. Hook triggers on completion
5. MCP server performs external integration
```

### Implementation Priority

1. **Phase 1**: {Core components to build first}
2. **Phase 2**: {Enhancement components}
3. **Phase 3**: {Optional components}

### Alternative Approaches

**If simpler**: {simpler alternative}
**If more robust**: {more complex alternative}

### Trade-offs

**Pros**:
- {advantage 1}
- {advantage 2}

**Cons**:
- {consideration 1}
- {consideration 2}
```

## Error Handling

- **Unclear purpose** → Request clearer description of plugin goal
- **Feature list too broad** → Suggest focusing on core functionality
- **Conflicting requirements** → Highlight conflicts and suggest resolution
- **Missing critical info** → Ask targeted questions

## Examples

### Example 1: Code Quality Plugin

**Input**:
```
purpose:"Automated code quality enforcement"
features:"lint,format,security-scan,complexity-analysis"
automation:true
```

**Recommendations**:
- **Commands**: Yes (Skill with skill.md router, 4 operations)
- **Agents**: Yes (code-reviewer agent for proactive analysis)
- **Hooks**: Yes (PostToolUse on Write/Edit for auto-lint)
- **MCP Servers**: No (native tools sufficient)

### Example 2: Simple Greeting Plugin

**Input**:
```
purpose:"Greet users with personalized messages"
features:"greet"
automation:false
```

**Recommendations**:
- **Commands**: Yes (Single command)
- **Agents**: No (too simple)
- **Hooks**: No (user-initiated only)
- **MCP Servers**: No (no external integration)

**Request**: $ARGUMENTS
