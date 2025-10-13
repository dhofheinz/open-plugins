---
description: Suggest architectural patterns based on plugin complexity and requirements
---

# Recommend Architectural Patterns

## Parameters

**Required**:
- `complexity`: Plugin complexity level (format: low|moderate|high)
- `features`: Number of main features/operations (format: integer)

**Optional**:
- `state_management`: Whether state management is needed (format: true|false)
- `workflows`: Whether multi-step workflows are needed (format: true|false)
- `external_integration`: Whether external tools are involved (format: true|false)

## Workflow

### Step 1: Assess Complexity Level

**Complexity Classification**:

**Low Complexity**:
- 1-2 operations
- Stateless execution
- Simple input/output
- No external dependencies
- Direct functionality

**Moderate Complexity**:
- 3-5 operations
- Some state tracking
- Light orchestration needed
- Few external dependencies
- May have related operations

**High Complexity**:
- 6+ operations
- State management required
- Complex workflows
- Multiple external dependencies
- Operations compose together

### Step 2: Pattern Matching

**Pattern 1: Simple Plugin (Single Command)**

**When to Use**:
- Complexity: Low
- Features: 1-2
- State management: No
- Workflows: No

**Structure**:
```
plugin-name/
├── plugin.json
├── commands/
│   └── command.md
└── README.md
```

**Characteristics**:
- Single .md file in commands/
- No skill.md router
- Direct invocation: /{command-name}
- Straightforward implementation

**Example Use Cases**:
- Hello World plugin
- Simple formatters
- Basic converters
- Quick utilities

**Pattern 2: Namespace Plugin (Multiple Independent Commands)**

**When to Use**:
- Complexity: Low to Moderate
- Features: 3-5
- State management: No or minimal
- Workflows: Independent operations
- Commands don't need orchestration

**Structure**:
```
plugin-name/
├── plugin.json
├── commands/
│   ├── operation1.md
│   ├── operation2.md
│   ├── operation3.md
│   └── operation4.md
└── README.md
```

**Characteristics**:
- Multiple .md files, NO skill.md
- Each command independently invokable
- Namespace prefix: /{plugin-name}:operation
- Grouped by domain but independent

**Example Use Cases**:
- Multiple formatters (format-python, format-js, format-css)
- Independent utilities collection
- Toolbox plugins

**Pattern 3: Skill Plugin (Orchestrated Operations)**

**When to Use**:
- Complexity: Moderate to High
- Features: 5+
- State management: Yes
- Workflows: Operations share context
- Need intelligent routing

**Structure**:
```
plugin-name/
├── plugin.json
├── commands/
│   ├── skill.md (router)
│   ├── operation1.md
│   ├── operation2.md
│   ├── operation3.md
│   └── operation4.md
└── README.md
```

**Characteristics**:
- skill.md acts as intelligent router
- Sub-commands are instruction modules (not directly invokable)
- Single entry point: /{plugin-name} operation args
- Parses arguments and routes internally

**Example Use Cases**:
- Database management (backup, restore, migrate, verify)
- Deployment pipelines (build, test, deploy, rollback)
- Multi-step workflows

**Pattern 4: Script-Enhanced Plugin**

**When to Use**:
- Complexity: Moderate to High
- Features: Any number
- External tools: Yes
- Performance critical: Yes
- Complex logic better in scripts

**Structure**:
```
plugin-name/
├── plugin.json
├── commands/
│   ├── skill.md (if orchestrated)
│   ├── operation1.md
│   ├── operation2.md
│   └── .scripts/
│       ├── utility1.sh
│       ├── utility2.py
│       └── utility3.js
└── README.md
```

**Characteristics**:
- Commands leverage utility scripts
- Scripts handle complex/repeated logic
- Better performance for intensive tasks
- Reusable across operations

**Example Use Cases**:
- Database operations with connection pooling
- File processing pipelines
- External tool integrations

**Pattern 5: Agent-Enhanced Plugin**

**When to Use**:
- Complexity: Any
- Domain expertise needed: Yes
- Guidance beneficial: Yes
- Proactive behavior desired: Yes

**Structure**:
```
plugin-name/
├── plugin.json
├── commands/
│   └── {command files}
├── agents/
│   └── specialist.md
└── README.md
```

**Characteristics**:
- Agent provides domain expertise
- Proactive invocation based on context
- Conversational guidance
- Works alongside commands

**Example Use Cases**:
- Code review automation
- Security analysis
- Performance optimization
- Architecture guidance

**Pattern 6: Full-Featured Plugin**

**When to Use**:
- Complexity: High
- Features: 6+
- All capabilities needed: Yes

**Structure**:
```
plugin-name/
├── plugin.json
├── commands/
│   ├── skill.md
│   ├── {operations}
│   └── .scripts/
│       └── {utilities}
├── agents/
│   └── specialist.md
├── hooks/
│   └── hooks.json
└── README.md
```

**Characteristics**:
- Complete plugin with all components
- Commands + Agent + Hooks + Scripts
- Maximum functionality
- Production-grade plugin

**Example Use Cases**:
- Comprehensive testing frameworks
- Full deployment automation
- Complete quality assurance systems

### Step 3: Template Mapping

**Map pattern to template**:

- **Simple Plugin** → No template needed (direct implementation)
- **Namespace Plugin** → No template needed (direct implementation)
- **Skill Plugin (CRUD-like)** → simple-crud template
- **Skill Plugin (Workflow)** → workflow-orchestration template
- **Script-Enhanced** → script-enhanced template
- **MCP Integration** → mcp-integration template

### Step 4: Provide Recommendations

Generate recommendations with:
- Recommended pattern with justification
- Alternative patterns with trade-offs
- Template to use (if applicable)
- Structure diagram
- Implementation guidance
- Example usage

## Output Format

```markdown
## Architectural Pattern Recommendations

### Analysis
**Complexity Level**: {low|moderate|high}
**Features Count**: {number}
**State Management**: {needed|not needed}
**Workflows**: {needed|not needed}
**External Integration**: {needed|not needed}

### Recommended Pattern: {Pattern Name}

**Why This Pattern**:
{Detailed justification based on requirements}

**Template**: {template-name or "Direct implementation"}

**Structure**:
```
{Directory structure diagram}
```

**Key Characteristics**:
- {characteristic 1}
- {characteristic 2}
- {characteristic 3}

**Implementation Steps**:
1. {step 1}
2. {step 2}
3. {step 3}

**Usage After Implementation**:
```bash
{Example commands}
```

### Alternative Patterns

#### Alternative 1: {Pattern Name}

**When to Consider**:
{Conditions where this might be better}

**Trade-offs**:
- Pros: {advantages}
- Cons: {disadvantages}

#### Alternative 2: {Pattern Name}

**When to Consider**:
{Conditions where this might be better}

**Trade-offs**:
- Pros: {advantages}
- Cons: {disadvantages}

### Pattern Comparison

| Aspect | Recommended | Alt 1 | Alt 2 |
|--------|------------|-------|-------|
| Complexity | {rating} | {rating} | {rating} |
| Maintainability | {rating} | {rating} | {rating} |
| Extensibility | {rating} | {rating} | {rating} |
| Learning Curve | {rating} | {rating} | {rating} |

### Migration Path

**If Requirements Change**:
- **Scale Up**: {How to add more features}
- **Scale Down**: {How to simplify}
- **Pivot**: {How to change direction}

### Best Practices for This Pattern

1. {Best practice 1}
2. {Best practice 2}
3. {Best practice 3}
```

## Error Handling

- **Invalid complexity level** → Request valid value: low|moderate|high
- **Features count unrealistic** → Clarify actual feature count
- **Conflicting parameters** → Highlight conflicts and suggest resolution
- **Unclear requirements** → Ask clarifying questions

## Examples

### Example 1: Low Complexity, Few Features

**Input**:
```
complexity:low features:2 state_management:false workflows:false
```

**Recommendation**:
- **Pattern**: Simple Plugin (Single Command) or Namespace
- **Template**: Direct implementation
- **Rationale**: Few features, no orchestration needed

### Example 2: Moderate Complexity, Workflow

**Input**:
```
complexity:moderate features:5 state_management:true workflows:true
```

**Recommendation**:
- **Pattern**: Skill Plugin with skill.md router
- **Template**: workflow-orchestration
- **Rationale**: Multiple operations sharing state, needs orchestration

### Example 3: High Complexity, External Tools

**Input**:
```
complexity:high features:7 external_integration:true workflows:true
```

**Recommendation**:
- **Pattern**: Full-Featured Plugin (Commands + Scripts + Agent)
- **Template**: script-enhanced + workflow-orchestration
- **Rationale**: Complex workflows with external integration needs utility scripts and expert guidance

**Request**: $ARGUMENTS
