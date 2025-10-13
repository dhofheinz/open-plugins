---
description: Assess plugin implementation complexity and estimate development effort
---

# Estimate Plugin Complexity

## Parameters

**Required**:
- `operations`: Number of operations/commands (format: integer)

**Optional**:
- `has_scripts`: Whether utility scripts are needed (format: true|false, default: false)
- `has_agents`: Whether agents are included (format: true|false, default: false)
- `has_hooks`: Whether hooks are included (format: true|false, default: false)
- `has_mcp`: Whether MCP servers are needed (format: true|false, default: false)
- `external_apis`: Number of external API integrations (format: integer, default: 0)

## Workflow

### Step 1: Calculate Base Complexity

**Operation Complexity Score**:
- 1-2 operations: Base score = 1 (Simple)
- 3-5 operations: Base score = 2 (Moderate)
- 6-8 operations: Base score = 3 (Complex)
- 9+ operations: Base score = 4 (Very Complex)

### Step 2: Apply Component Multipliers

**Complexity Multipliers**:

**Scripts** (+0.5 per script type):
- Shell scripts (.sh): +0.5
- Python scripts (.py): +0.5
- JavaScript scripts (.js): +0.5
- Average scripts needed: operations / 3 (rounded up)

**Agents** (+1.0 per agent):
- Agent design and prompting: +0.5
- Agent capabilities definition: +0.3
- Agent tool configuration: +0.2
- Testing and refinement: +0.3
- Total per agent: +1.3

**Hooks** (+0.5 per hook event):
- Hook configuration: +0.2
- Event matcher design: +0.2
- Hook script implementation: +0.3
- Testing hook triggers: +0.3
- Total per hook: +1.0

**MCP Servers** (+2.0 per server):
- Server design: +0.5
- Tool implementation: +0.8
- Configuration setup: +0.3
- Testing and debugging: +0.4
- Total per MCP server: +2.0

**External API Integrations** (+0.8 per API):
- Authentication setup: +0.3
- API wrapper implementation: +0.3
- Error handling: +0.2
- Total per API: +0.8

### Step 3: Calculate Total Complexity

**Formula**:
```
Total Complexity = Base Score
                  + (script_count * 0.5)
                  + (agent_count * 1.3)
                  + (hook_count * 1.0)
                  + (mcp_count * 2.0)
                  + (api_count * 0.8)
```

**Complexity Bands**:
- 0-2: Very Low
- 2.1-4: Low
- 4.1-6: Moderate
- 6.1-8: High
- 8+: Very High

### Step 4: Estimate Time Investment

**Time Per Complexity Band**:

**Very Low (0-2)**:
- Planning: 5-10 minutes
- Implementation: 10-15 minutes
- Testing: 5-10 minutes
- Documentation: 10-15 minutes
- Total: 30-50 minutes

**Low (2.1-4)**:
- Planning: 10-15 minutes
- Implementation: 20-30 minutes
- Testing: 10-15 minutes
- Documentation: 15-20 minutes
- Total: 55-80 minutes

**Moderate (4.1-6)**:
- Planning: 15-20 minutes
- Implementation: 40-60 minutes
- Testing: 20-30 minutes
- Documentation: 20-30 minutes
- Total: 95-140 minutes (1.5-2.5 hours)

**High (6.1-8)**:
- Planning: 20-30 minutes
- Implementation: 80-120 minutes
- Testing: 30-45 minutes
- Documentation: 30-40 minutes
- Total: 160-235 minutes (2.5-4 hours)

**Very High (8+)**:
- Planning: 30-45 minutes
- Implementation: 120-180+ minutes
- Testing: 45-60 minutes
- Documentation: 40-60 minutes
- Total: 235-345+ minutes (4-6+ hours)

### Step 5: Identify Complexity Drivers

**Major Complexity Drivers**:
- High operation count (6+)
- MCP server integration (highest impact)
- Complex state management
- Multiple external APIs
- Custom hooks with sophisticated matchers
- Agent with extensive capabilities

**Risk Factors**:
- First-time MCP server development: +50% time
- Complex authentication: +30% time
- Unfamiliar external APIs: +40% time
- Testing infrastructure setup: +20% time

### Step 6: Generate Estimate Report

Provide comprehensive estimate with:
- Complexity score and band
- Time estimate with breakdown
- Complexity drivers
- Risk factors
- Recommendations for scope management
- Phased implementation plan

## Output Format

```markdown
## Plugin Complexity Estimate

### Input Parameters
- **Operations**: {count}
- **Scripts**: {yes/no} ({estimated count})
- **Agents**: {yes/no} ({count})
- **Hooks**: {yes/no} ({count})
- **MCP Servers**: {yes/no} ({count})
- **External APIs**: {count}

### Complexity Analysis

**Base Complexity**: {score} ({Simple|Moderate|Complex|Very Complex})

**Component Adjustments**:
- Scripts: +{score} ({count} scripts)
- Agents: +{score} ({count} agents)
- Hooks: +{score} ({count} hooks)
- MCP Servers: +{score} ({count} servers)
- External APIs: +{score} ({count} APIs)

**Total Complexity Score**: {total} / 10

**Complexity Band**: {Very Low|Low|Moderate|High|Very High}

### Time Estimate

**Breakdown**:
- Planning & Design: {time range}
- Implementation: {time range}
- Testing & Debugging: {time range}
- Documentation: {time range}

**Total Estimated Time**: {time range}

**Confidence Level**: {High|Medium|Low}
(Based on requirements clarity and risk factors)

### Complexity Drivers

**Major Drivers** (Highest Impact):
1. {driver 1}: {impact explanation}
2. {driver 2}: {impact explanation}
3. {driver 3}: {impact explanation}

**Minor Drivers**:
- {driver}: {impact}

### Risk Factors

**Technical Risks**:
- {risk 1}: {mitigation strategy}
- {risk 2}: {mitigation strategy}

**Time Risks**:
- {risk}: Potential +{percentage}% time increase

### Recommendations

**Scope Management**:
{Recommendations for managing complexity}

**Simplification Opportunities**:
- {opportunity 1}: Could reduce complexity by {amount}
- {opportunity 2}: Could reduce complexity by {amount}

**Phased Implementation**:

**Phase 1 (MVP)**: {time estimate}
- {core component 1}
- {core component 2}
- {core component 3}

**Phase 2 (Enhanced)**: {time estimate}
- {enhancement 1}
- {enhancement 2}

**Phase 3 (Full-Featured)**: {time estimate}
- {advanced feature 1}
- {advanced feature 2}

### Comparison to Similar Plugins

**Similar Complexity**:
- {example plugin 1}: {comparison}
- {example plugin 2}: {comparison}

**Reference Implementation Time**:
- Simple plugin (e.g., hello-world): 30-45 minutes
- Moderate plugin (e.g., code-formatter): 1-2 hours
- Complex plugin (e.g., deployment-automation): 3-5 hours
- Very complex plugin (e.g., test-framework): 5-8+ hours

### Success Factors

**To Stay On Track**:
1. {factor 1}
2. {factor 2}
3. {factor 3}

**Red Flags to Watch**:
- {warning sign 1}
- {warning sign 2}
```

## Error Handling

- **Invalid operation count** → Request valid positive integer
- **Unrealistic parameters** → Clarify actual requirements
- **Missing critical info** → Ask about components planned
- **Scope creep indicators** → Warn about complexity explosion

## Examples

### Example 1: Simple Plugin

**Input**:
```
operations:2 has_scripts:false has_agents:false has_hooks:false has_mcp:false
```

**Estimate**:
- Complexity: 1.0 (Very Low)
- Time: 30-50 minutes
- Band: Very Low
- Confidence: High

### Example 2: Moderate Plugin

**Input**:
```
operations:5 has_scripts:true has_agents:true has_hooks:false has_mcp:false
```

**Estimate**:
- Base: 2.0
- Scripts: +1.5 (3 scripts estimated)
- Agents: +1.3 (1 agent)
- Total: 4.8 (Moderate)
- Time: 90-120 minutes
- Confidence: Medium

### Example 3: Complex Plugin

**Input**:
```
operations:7 has_scripts:true has_agents:true has_hooks:true has_mcp:true external_apis:2
```

**Estimate**:
- Base: 3.0
- Scripts: +2.0 (4 scripts)
- Agents: +1.3 (1 agent)
- Hooks: +1.0 (1 hook)
- MCP: +2.0 (1 server)
- APIs: +1.6 (2 APIs)
- Total: 10.9 (Very High)
- Time: 4-6+ hours
- Confidence: Medium-Low (high complexity)

**Recommendation**: Consider phased approach, starting with core 3-4 operations

**Request**: $ARGUMENTS
