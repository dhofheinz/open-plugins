---
description: Comprehensive system architecture design, review, and documentation with ADR creation
---

# Architecture Skill Router

You are routing architecture operations using the **10x-fullstack-engineer** agent for expert architectural guidance.

## Request Parsing

**Received**: `$ARGUMENTS`

Parse the first word to determine the operation:
- `design` → Read and execute `.claude/commands/architect/design.md`
- `review` → Read and execute `.claude/commands/architect/review.md`
- `adr` → Read and execute `.claude/commands/architect/adr.md`
- `assess` → Read and execute `.claude/commands/architect/assess.md`

**Base directory**: `/home/danie/projects/plugins/architect/open-plugins/plugins/10x-fullstack-engineer/commands/architect`

Pass all remaining arguments (after the operation name) to the selected operation file.

## Operation Overview

### design - Design New Architecture
Create comprehensive system architecture for new features or projects. Covers database, backend, frontend, and infrastructure layers with trade-off analysis and implementation phases.

**When to use**: New features, new projects, major architectural changes, greenfield development

**Typical parameters**: `requirements:"description" [scope:"area"] [constraints:"limitations"] [scale:"load"]`

### review - Review Existing Architecture
Analyze existing architecture for quality, security, performance, scalability, and maintainability issues. Provides scored assessment and actionable recommendations.

**When to use**: Architecture health checks, pre-production reviews, security audits, refactoring planning

**Typical parameters**: `[path:"directory"] [focus:"security|performance|scalability"] [depth:"shallow|deep"]`

### adr - Create Architectural Decision Record
Document significant architectural decisions with context, alternatives, and rationale in standard ADR format.

**When to use**: After major design decisions, technology selections, pattern adoptions, architectural pivots

**Typical parameters**: `decision:"what-was-decided" [context:"background"] [alternatives:"other-options"] [status:"proposed|accepted|superseded"]`

### assess - Architecture Health Assessment
Comprehensive assessment across technical debt, security, performance, scalability, maintainability, and cost dimensions with scoring and trend analysis.

**When to use**: Quarterly reviews, baseline establishment, improvement tracking, executive reporting

**Typical parameters**: `[scope:"system|service|component"] [focus:"dimension"] [baseline:"ADR-number|date"]`

## Usage Examples

**Example 1 - Design Real-Time Notification System**:
```
/architect design requirements:"real-time notification system with WebSockets, push notifications, and email delivery" scale:"10,000 concurrent users" constraints:"must integrate with existing REST API, AWS infrastructure"
```

**Example 2 - Review Security Architecture**:
```
/architect review focus:"security" depth:"deep"
```

**Example 3 - Document Microservices Decision**:
```
/architect adr decision:"migrate from monolith to microservices architecture" context:"scaling challenges and deployment bottlenecks" alternatives:"modular monolith, service-oriented architecture" status:"accepted"
```

**Example 4 - Assess Architecture Health**:
```
/architect assess scope:"system" baseline:"2024-Q3"
```

**Example 5 - Design Multi-Tenant SaaS**:
```
/architect design requirements:"multi-tenant SaaS platform with real-time collaboration, file storage, and analytics" scale:"enterprise-level, 100k+ users" constraints:"TypeScript, Node.js, PostgreSQL, horizontal scaling"
```

**Example 6 - Review Performance Architecture**:
```
/architect review path:"src/services" focus:"performance" depth:"deep"
```

**Example 7 - Document Database Selection**:
```
/architect adr decision:"use PostgreSQL with JSONB for flexible schema" context:"need relational integrity plus document flexibility" alternatives:"MongoDB, DynamoDB, MySQL" status:"accepted"
```

**Example 8 - Focused Tech Debt Assessment**:
```
/architect assess scope:"service" focus:"tech-debt"
```

## Error Handling

### Unknown Operation
If the first argument doesn't match `design`, `review`, `adr`, or `assess`:

```
Unknown operation: "{operation}"

Available operations:
- design    Design new system architecture
- review    Review existing architecture
- adr       Create architectural decision record
- assess    Assess architecture health

Example: /architect design requirements:"real-time notifications" scale:"10k users"
```

### Missing Operation
If no operation is specified:

```
No operation specified. Please provide an operation as the first argument.

Available operations:
- design    Design new system architecture for features/projects
- review    Review existing architecture for quality/security
- adr       Create architectural decision records
- assess    Assess architecture health with scoring

Examples:
  /architect design requirements:"feature description" scale:"expected load"
  /architect review focus:"security" depth:"deep"
  /architect adr decision:"technology choice" alternatives:"other options"
  /architect assess scope:"system" baseline:"previous assessment"
```

### Invalid Arguments Format
If arguments are malformed, guide the user:

```
Invalid arguments format. Each operation expects specific parameters.

Design operation format:
  requirements:"description" [scope:"area"] [constraints:"limitations"] [scale:"load"]

Review operation format:
  [path:"directory"] [focus:"security|performance|scalability"] [depth:"shallow|deep"]

ADR operation format:
  decision:"what-was-decided" [context:"background"] [alternatives:"options"] [status:"proposed|accepted"]

Assess operation format:
  [scope:"system|service|component"] [focus:"dimension"] [baseline:"reference"]

See /architect for examples.
```

## Agent Integration

All operations MUST invoke the **10x-fullstack-engineer** agent for:
- 15+ years of architectural expertise
- Pattern recognition and best practices
- Trade-off analysis and decision guidance
- Production system experience
- Technology stack recommendations
- Scalability and performance insights
- Security and reliability patterns

Ensure the agent receives complete context including:
- Current operation and parameters
- Relevant codebase information
- Existing architecture if available
- Business and technical constraints
- Scale and performance requirements

## Routing Process

1. **Parse** `$ARGUMENTS` to extract operation name
2. **Validate** operation is one of: design, review, adr, assess
3. **Construct** file path: `{base-directory}/{operation}.md`
4. **Read** the operation file contents
5. **Execute** instructions with remaining arguments
6. **Invoke** 10x-fullstack-engineer agent with full context

## Notes

- Sub-operation files have NO frontmatter (not directly invokable)
- Only this router skill.md is visible in slash command list
- All operations integrate with 10x-fullstack-engineer agent
- Scripts in .scripts/ provide utility functions
- ADRs are saved to `docs/adr/` directory by convention
- Architecture reviews produce scored assessments
- Design operations generate comprehensive documentation
