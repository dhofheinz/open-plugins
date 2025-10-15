# Architecture Skill

**Comprehensive system architecture design, review, and documentation with ADR creation**

The Architecture skill provides expert-level architectural guidance through four specialized operations: design new architectures, review existing systems, document architectural decisions, and assess architecture health. All operations leverage the **10x-fullstack-engineer** agent for 15+ years of architectural expertise.

---

## Table of Contents

- [Overview](#overview)
- [Operations](#operations)
  - [Design](#design---design-new-architecture)
  - [Review](#review---review-existing-architecture)
  - [ADR](#adr---create-architectural-decision-records)
  - [Assess](#assess---architecture-health-assessment)
- [Utility Scripts](#utility-scripts)
- [Usage Examples](#usage-examples)
- [Integration](#integration)
- [Best Practices](#best-practices)

---

## Overview

The Architecture skill operates through a router pattern where the main skill file (`skill.md`) parses arguments and routes to specialized operation files. This modular approach enables:

- **Focused Operations**: Each architectural task has dedicated logic and workflows
- **Agent Integration**: All operations invoke the 10x-fullstack-engineer agent for expert guidance
- **Utility Scripts**: Automated analysis tools for dependencies, complexity, and diagrams
- **Structured Output**: Consistent, comprehensive documentation for all architectural artifacts

**Base Directory**: `.claude/commands/architect/` (or plugin equivalent)

**Agent**: All operations require and invoke the **10x-fullstack-engineer** agent

---

## Operations

### Design - Design New Architecture

Create comprehensive system architecture for new features, projects, or major changes.

**Use When**:
- Starting new projects or features
- Major architectural refactoring
- Greenfield development
- Architecture modernization

**Parameters**:
```
requirements:"description"    (required) Feature or system description
scope:"area"                  (optional) Specific focus area (backend, frontend, full-stack)
constraints:"limitations"     (optional) Technical constraints, existing systems, team expertise
scale:"expected-load"         (optional) Expected load, user count, data volume, growth
```

**What It Does**:

1. **Requirements Analysis** - Parses requirements, identifies stakeholders, extracts non-functional requirements
2. **Context Gathering** - Examines existing codebase, technology stack, infrastructure, documentation
3. **Architecture Design** - Creates comprehensive design across all layers:
   - **Database Layer**: Schema design, query optimization, migration strategy, data consistency
   - **Backend Layer**: API design, service architecture, business logic, auth/authz, caching, message queuing
   - **Frontend Layer**: Component architecture, state management, routing, data fetching, performance
   - **Infrastructure Layer**: Deployment architecture, scaling strategy, CI/CD, monitoring, security, disaster recovery
4. **Trade-off Analysis** - Documents decisions with pros/cons/alternatives for major choices
5. **Deliverables** - Produces architecture diagrams, component breakdown, data flow, technology stack, implementation phases, risk assessment, success metrics
6. **ADR Creation** - Documents significant decisions as ADRs

**Output**: Comprehensive architecture design document with executive summary, detailed layer designs, technology justifications, implementation roadmap, and risk mitigation strategies.

**Example**:
```bash
/architect design requirements:"real-time notification system with WebSockets, push notifications, and email delivery" scale:"10,000 concurrent users" constraints:"must integrate with existing REST API, AWS infrastructure"
```

---

### Review - Review Existing Architecture

Analyze existing architecture for quality, security, performance, scalability, and maintainability issues.

**Use When**:
- Architecture health checks
- Pre-production reviews
- Security audits
- Refactoring planning
- Technical debt assessment

**Parameters**:
```
path:"directory"              (optional) Specific directory or component to review (default: entire codebase)
focus:"dimension"             (optional) Primary concern area - security, performance, scalability, maintainability, or "all"
depth:"shallow|deep"          (optional) Review depth - "shallow" for quick assessment, "deep" for comprehensive analysis (default: "deep")
```

**What It Does**:

1. **Context Discovery** - Analyzes directory structure, technology stack, configuration, documentation, testing infrastructure
2. **Layer-by-Layer Analysis**:
   - **Database Layer**: Schema quality, performance, scalability, security
   - **Backend Layer**: API design, code organization, business logic, auth/authz, performance, security, maintainability
   - **Frontend Layer**: Component architecture, state management, performance, UX, security, build/deployment
   - **Infrastructure Layer**: Deployment architecture, scalability, monitoring, CI/CD, security, disaster recovery
3. **Cross-Cutting Concerns**: Security audit (OWASP Top 10), performance analysis, scalability assessment, maintainability review
4. **Issue Identification** - Categorizes issues by severity (Critical/High/Medium/Low) with location, impact, recommendation, effort
5. **Scoring** - Provides 0-10 scores for each dimension with status and trend indicators
6. **Recommendations** - Prioritized roadmap of quick wins, important improvements, strategic initiatives, technical debt

**Output**: Comprehensive architecture review report with health scores, detailed findings by dimension, comparison to industry standards, dependency analysis, and prioritized recommendations roadmap.

**Example**:
```bash
/architect review focus:"security" depth:"deep"
```

---

### ADR - Create Architectural Decision Records

Document significant architectural decisions with context, alternatives, and rationale in standard ADR format.

**Use When**:
- After major design decisions
- Technology selections
- Pattern adoptions
- Architectural pivots
- Documenting trade-offs

**Parameters**:
```
decision:"what-was-decided"   (required) Brief summary of the architectural decision
context:"background"          (optional) Background, problem being solved, forces at play
alternatives:"other-options"  (optional) Other options that were considered
status:"status"               (optional) Decision status - "proposed", "accepted", "deprecated", "superseded" (default: "proposed")
```

**What It Does**:

1. **Context Gathering** - Understands decision scope, problem context, decision drivers, researches current state
2. **Alternative Analysis** - Identifies 3-5 alternatives, analyzes pros/cons/trade-offs for each, creates comparison matrix
3. **Decision Rationale** - Documents primary justification, supporting reasons, risk acceptance, decision criteria
4. **Consequences Analysis** - Identifies positive, negative, and neutral consequences, impact assessment (immediate/short-term/long-term), dependencies
5. **ADR Creation** - Generates standard ADR format with proper numbering, saves to `docs/adr/`, updates ADR index
6. **Documentation** - Links related ADRs, provides implementation guidance

**Output**: Complete ADR document saved to `docs/adr/ADR-NNNN-slug.md` with status, date, deciders, context, considered options, decision outcome, consequences, pros/cons analysis, and references.

**ADR Templates Available**:
- Technology Selection
- Architecture Pattern
- Migration Decision

**Example**:
```bash
/architect adr decision:"use PostgreSQL with JSONB for flexible schema" context:"need relational integrity plus document flexibility" alternatives:"MongoDB, DynamoDB, MySQL" status:"accepted"
```

---

### Assess - Architecture Health Assessment

Comprehensive assessment across technical debt, security, performance, scalability, maintainability, and cost dimensions with scoring and trend analysis.

**Use When**:
- Quarterly reviews
- Baseline establishment
- Improvement tracking
- Executive reporting
- Planning refactoring initiatives

**Parameters**:
```
scope:"level"                 (optional) Assessment scope - "system" (entire architecture), "service", "component" (default: "system")
focus:"dimension"             (optional) Specific dimension - "tech-debt", "security", "performance", "scalability", "maintainability", "cost", or "all" (default: "all")
baseline:"reference"          (optional) Baseline for comparison - ADR number, date (YYYY-MM-DD), or "previous" for last assessment
```

**What It Does**:

1. **Baseline Discovery** - Finds previous assessments, extracts baseline metrics, tracks issue resolution
2. **Dimensional Assessment** - Scores 0-10 across six dimensions:
   - **Technical Debt**: Code quality, outdated dependencies, deprecated patterns, documentation
   - **Security**: Authentication, data protection, vulnerability scanning, OWASP Top 10 compliance
   - **Performance**: API response times, database queries, frontend load times, resource utilization
   - **Scalability**: Horizontal scaling capability, database scaling, auto-scaling, capacity limits
   - **Maintainability**: Code organization, test coverage, documentation, deployment frequency
   - **Cost Efficiency**: Infrastructure costs, resource utilization, optimization opportunities
3. **Comparative Analysis** - Compares to baseline, tracks resolved/new/persistent issues, analyzes trends, projects future state
4. **Recommendations** - Prioritized roadmap:
   - **Immediate Actions** (This Sprint): Critical fixes
   - **Quick Wins** (2-4 weeks): High impact, low effort
   - **Important Improvements** (1-3 months): Significant value, moderate effort
   - **Strategic Initiatives** (3-6 months): Long-term value, high effort
5. **Implementation Roadmap** - Sprint planning, milestone timeline, success metrics, risk assessment

**Output**: Architecture health assessment report with overall health score, dimension-specific scores with trends, detailed findings by category, comparison to baseline, trend analysis, issue tracking, and prioritized recommendations with implementation roadmap.

**Scoring Guide**:
- **9-10 (Excellent)**: Best practices, minimal improvements needed
- **7-8 (Good)**: Solid foundation, minor enhancements possible
- **5-6 (Fair)**: Acceptable but improvements needed
- **3-4 (Poor)**: Significant issues, action required
- **0-2 (Critical)**: Severe problems, urgent action needed

**Example**:
```bash
/architect assess baseline:"previous"
```

---

## Utility Scripts

The Architecture skill includes three utility scripts in the `.scripts/` directory:

### 1. analyze-dependencies.sh

**Purpose**: Analyze project dependencies for security, versioning, and usage

**Usage**:
```bash
./.scripts/analyze-dependencies.sh [path] [json|text]
```

**Features**:
- Detects package manager (npm, pip, pipenv, poetry, bundler, go, cargo, composer)
- Counts direct and development dependencies
- Checks for outdated packages
- Scans for security vulnerabilities (critical/high/medium/low)
- Analyzes dependency tree depth
- Finds unused dependencies
- Detects duplicate dependencies
- Calculates health score (0-10)
- Generates prioritized recommendations

**Output**: JSON or text report with dependency analysis, vulnerability summary, health score, and recommendations

**Exit Codes**:
- 0: Success
- 1: Error during analysis
- 2: Invalid input

---

### 2. complexity-metrics.py

**Purpose**: Calculate code complexity metrics for architecture assessment

**Usage**:
```bash
python3 ./.scripts/complexity-metrics.py [path] [--format json|text]
```

**Features**:
- Analyzes cyclomatic complexity (uses `radon` library if available, falls back to simplified metrics)
- Calculates maintainability index
- Classifies functions: simple (1-5), moderate (6-10), complex (11-20), very complex (>20)
- Tracks average and maximum complexity
- Analyzes maintainability distribution (high/medium/low)
- Calculates overall health score (0-10)
- Generates recommendations for refactoring

**Supported Languages**: Python, JavaScript, TypeScript, Java, Go, Ruby, PHP, C, C++, C#

**Output**: JSON or text report with complexity metrics, maintainability scores, health score, and refactoring recommendations

**Dependencies**: Optional `radon` library (install with `pip install radon`) for enhanced metrics

**Exit Codes**:
- 0: Success
- 1: Error during analysis
- 2: Invalid input

---

### 3. diagram-generator.sh

**Purpose**: Generate ASCII architecture diagrams from system descriptions

**Usage**:
```bash
./.scripts/diagram-generator.sh <type> [--title "Title"] [--color]
```

**Diagram Types**:
- `layered`: Layered architecture diagram (Presentation → Business → Persistence → Database)
- `microservices`: Microservices architecture with API gateway, services, databases, message queue
- `database`: Database architecture with read/write pools, replicas, caching
- `network`: Network topology with CDN, WAF, load balancers, availability zones
- `component`: Component interaction diagram showing client → frontend → backend → data storage
- `dataflow`: Data flow diagram showing step-by-step data movement

**Features**:
- Unicode box drawing characters for clean diagrams
- Optional colored output
- Customizable titles
- Pre-built templates for common architecture patterns

**Output**: ASCII diagram suitable for markdown documentation or terminal display

**Exit Codes**:
- 0: Success
- 1: Error during execution
- 2: Invalid input

---

## Usage Examples

### Complete Architecture Design Workflow

```bash
# 1. Design architecture for new feature
/architect design requirements:"multi-tenant SaaS platform with real-time collaboration, file storage, and analytics" scale:"enterprise-level, 100k+ users" constraints:"TypeScript, Node.js, PostgreSQL, horizontal scaling"

# 2. Document key architectural decisions
/architect adr decision:"use PostgreSQL with row-level security for multi-tenancy" alternatives:"separate databases per tenant, schema-based isolation" status:"accepted"

/architect adr decision:"implement CQRS pattern for read-heavy analytics" alternatives:"standard CRUD, event sourcing, materialized views" status:"accepted"

# 3. Assess baseline architecture health
/architect assess

# 4. Review specific component security
/architect review path:"src/services/auth" focus:"security" depth:"deep"
```

### Quarterly Architecture Review

```bash
# Run comprehensive assessment against last quarter
/architect assess baseline:"2024-01-15"

# Focus on areas that degraded
/architect review focus:"performance" depth:"deep"

# Document improvement initiatives
/architect adr decision:"implement Redis caching layer to improve performance" context:"assessment showed performance degradation, response times increased 40%" status:"accepted"
```

### Pre-Production Architecture Validation

```bash
# Comprehensive review before launch
/architect review focus:"all" depth:"deep"

# Security audit
/architect review focus:"security" depth:"deep"

# Performance validation
/architect review focus:"performance" depth:"deep"

# Document production readiness decisions
/architect adr decision:"deploy with blue-green strategy for zero-downtime releases" alternatives:"rolling deployment, canary releases" status:"accepted"
```

### Technical Debt Assessment

```bash
# Assess technical debt
/architect assess focus:"tech-debt"

# Review code quality
/architect review focus:"maintainability" depth:"deep"

# Run complexity analysis
python3 .scripts/complexity-metrics.py . --format json

# Analyze dependencies
./.scripts/analyze-dependencies.sh . json
```

### Architecture Documentation Sprint

```bash
# Document existing system design
/architect design requirements:"document existing order processing system" scope:"backend" constraints:"Node.js, PostgreSQL, AWS, existing production system"

# Create ADRs for historical decisions
/architect adr decision:"chose microservices architecture for order processing" context:"monolith scalability limitations" alternatives:"modular monolith, serverless" status:"accepted"

# Generate architecture diagrams
./.scripts/diagram-generator.sh microservices --title "Order Processing Architecture"
./.scripts/diagram-generator.sh database --title "Order Database Architecture"

# Baseline current health
/architect assess
```

---

## Integration

### With Other Skills/Commands

The Architecture skill integrates seamlessly with other development workflows:

**Design Phase**:
- `/architect design` → Design system architecture
- Document decisions with `/architect adr`
- Generate diagrams with `diagram-generator.sh`

**Development Phase**:
- Run `/architect review` on new components
- Check complexity with `complexity-metrics.py`
- Validate dependencies with `analyze-dependencies.sh`

**Testing Phase**:
- `/architect review focus:"performance"` for performance validation
- `/architect assess` for quality gates

**Deployment Phase**:
- `/architect review focus:"security"` before production
- Document deployment decisions with `/architect adr`

**Maintenance Phase**:
- Quarterly `/architect assess` against baseline
- `/architect review focus:"tech-debt"` for refactoring planning
- Update ADRs when superseding decisions

### With Agent System

All operations invoke the **10x-fullstack-engineer** agent, which provides:
- 15+ years of architectural expertise
- Pattern recognition and best practices
- Trade-off analysis and decision guidance
- Production system experience
- Technology stack recommendations
- Scalability and performance insights
- Security and reliability patterns

The agent receives comprehensive context including operation parameters, codebase information, existing architecture, constraints, and scale requirements.

### Continuous Architecture Governance

Integrate architecture operations into your development lifecycle:

**Sprint Planning**:
```bash
# Review technical debt before planning
/architect assess focus:"tech-debt"

# Design new features architecturally
/architect design requirements:"sprint feature description"
```

**Code Review**:
```bash
# Review new components
/architect review path:"src/new-component" depth:"shallow"

# Check complexity
python3 .scripts/complexity-metrics.py src/new-component
```

**Release Process**:
```bash
# Pre-release validation
/architect review focus:"security" depth:"deep"
/architect review focus:"performance" depth:"shallow"

# Document release decisions
/architect adr decision:"release decision"
```

**Quarterly Reviews**:
```bash
# Comprehensive health assessment
/architect assess baseline:"previous"

# Trend analysis and planning
/architect review focus:"all" depth:"deep"
```

---

## Best Practices

### When to Use Each Operation

**Use Design When**:
- Starting new projects or major features
- Need comprehensive architecture documentation
- Evaluating technology stack options
- Planning multi-phase implementation
- Establishing architectural patterns

**Use Review When**:
- Conducting architecture health checks
- Pre-production validation
- Security audits
- Identifying refactoring opportunities
- Onboarding new team members to architecture

**Use ADR When**:
- Making significant architectural decisions
- Choosing technologies or patterns
- Resolving architectural trade-offs
- Documenting rationale for future reference
- Creating decision audit trail

**Use Assess When**:
- Quarterly architecture reviews
- Establishing baseline metrics
- Tracking improvement progress
- Executive reporting on tech health
- Planning major refactoring initiatives

### Architecture Documentation Workflow

1. **Design First**: Start with `/architect design` for new systems
2. **Document Decisions**: Create ADRs for significant choices
3. **Establish Baseline**: Run initial `/architect assess`
4. **Regular Reviews**: Schedule quarterly `/architect assess baseline:"previous"`
5. **Component Reviews**: Review new components with `/architect review`
6. **Update ADRs**: Supersede decisions when architecture evolves
7. **Track Trends**: Monitor health scores over time

### Optimization Tips

**For Design Operations**:
- Provide detailed requirements and constraints upfront
- Specify scale expectations explicitly
- Leverage existing ADRs for consistency
- Use utility scripts for current state analysis
- Review generated architecture with team before implementation

**For Review Operations**:
- Start with shallow reviews for quick feedback
- Use focused reviews (security, performance) for specific concerns
- Run deep reviews before major releases
- Combine with utility scripts for comprehensive analysis
- Address critical issues before continuing to lower priority

**For ADR Creation**:
- Create ADRs immediately after decisions, not retrospectively
- Include alternatives considered, not just chosen option
- Document trade-offs explicitly
- Link related ADRs for context
- Update status as decisions evolve

**For Assessment Operations**:
- Establish baseline early in project lifecycle
- Run assessments consistently (e.g., quarterly)
- Compare to baselines to track trends
- Focus on dimensions with declining scores
- Use assessment output for sprint planning

### Common Workflows

**New Project Setup**:
```bash
/architect design requirements:"project description" constraints:"tech stack"
/architect adr decision:"technology choices"
./.scripts/diagram-generator.sh layered --title "Project Architecture"
/architect assess  # Establish baseline
```

**Pre-Production Checklist**:
```bash
/architect review focus:"security" depth:"deep"
/architect review focus:"performance" depth:"deep"
/architect assess
./.scripts/analyze-dependencies.sh . json
```

**Technical Debt Paydown**:
```bash
/architect assess focus:"tech-debt"
python3 .scripts/complexity-metrics.py . --format json
/architect review focus:"maintainability" depth:"deep"
# Address top recommendations
/architect assess baseline:"previous"  # Verify improvement
```

**Architecture Modernization**:
```bash
/architect review focus:"all" depth:"deep"  # Understand current state
/architect design requirements:"modernization goals" constraints:"existing system"
/architect adr decision:"modernization approach"
# Implement incrementally
/architect assess baseline:"pre-modernization"  # Track progress
```

---

## File Structure

```
architect/
├── skill.md                           # Router (invokable via /architect)
├── design.md                          # Design operation (not directly invokable)
├── review.md                          # Review operation (not directly invokable)
├── adr.md                             # ADR operation (not directly invokable)
├── assess.md                          # Assess operation (not directly invokable)
├── .scripts/
│   ├── analyze-dependencies.sh        # Dependency analysis utility
│   ├── complexity-metrics.py          # Code complexity analysis utility
│   └── diagram-generator.sh           # ASCII diagram generation utility
└── README.md                          # This file
```

**Note**: Only `skill.md` is directly invokable via `/architect`. Sub-operations are instruction modules read and executed by the router.

---

## Error Handling

All operations include comprehensive error handling:

- **Unknown Operation**: Lists available operations with examples
- **Missing Required Parameters**: Provides parameter format guidance
- **Invalid Parameters**: Suggests correct parameter values
- **File/Directory Not Found**: Lists available paths or creates directories as needed
- **Insufficient Context**: Documents assumptions and requests clarification

Operations gracefully handle missing metrics, incomplete information, and edge cases by providing clear guidance to the user.

---

## Output Locations

**Architecture Designs**: Generated as markdown in operation response, can be saved manually or integrated with documentation system

**ADRs**: Automatically saved to `docs/adr/ADR-NNNN-slug.md` with index updates

**Assessments**: Generated as markdown in operation response, recommended to save to `docs/assessments/architecture-assessment-YYYY-MM-DD.md`

**Reviews**: Generated as markdown in operation response, can be saved for historical reference

**Utility Script Outputs**: JSON or text format, typically piped or redirected as needed

---

## Getting Started

1. **Initial Architecture Design**:
   ```bash
   /architect design requirements:"your project description" scale:"expected scale" constraints:"technical constraints"
   ```

2. **Document Key Decisions**:
   ```bash
   /architect adr decision:"decision summary" alternatives:"other options" status:"accepted"
   ```

3. **Establish Baseline**:
   ```bash
   /architect assess
   ```

4. **Regular Health Checks**:
   ```bash
   /architect assess baseline:"previous"
   /architect review focus:"security"
   ```

5. **Use Utility Scripts**:
   ```bash
   ./.scripts/analyze-dependencies.sh . json
   python3 .scripts/complexity-metrics.py . --format json
   ./.scripts/diagram-generator.sh microservices --title "System Architecture"
   ```

---

## Additional Resources

- **ADR Format**: Based on [Michael Nygard's ADR template](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- **OWASP Top 10**: [https://owasp.org/www-project-top-ten/](https://owasp.org/www-project-top-ten/)
- **Cyclomatic Complexity**: [https://en.wikipedia.org/wiki/Cyclomatic_complexity](https://en.wikipedia.org/wiki/Cyclomatic_complexity)
- **Architecture Assessment**: Based on industry best practices for architecture health metrics

---

## Support and Contribution

This skill is part of the **10x-fullstack-engineer** plugin. For issues, improvements, or questions:

1. Review the operation documentation in individual `.md` files
2. Examine utility script comments for detailed usage
3. Refer to the 10x-fullstack-engineer agent capabilities
4. Check ADR templates in `adr.md` for decision documentation patterns

---

**Version**: 1.0.0
**Last Updated**: 2025-10-14
**Agent Integration**: 10x-fullstack-engineer (required)
