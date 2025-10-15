# Architectural Decision Record (ADR) Operation

You are executing the **adr** operation using the 10x-fullstack-engineer agent to document significant architectural decisions in standard ADR format.

## Parameters

**Received**: `$ARGUMENTS` (after removing 'adr' operation name)

Expected format: `decision:"what-was-decided" [context:"background"] [alternatives:"other-options"] [status:"proposed|accepted|deprecated|superseded"]`

Parse the arguments to extract:
- **decision** (required): Brief summary of the architectural decision made
- **context** (optional): Background, problem being solved, forces at play
- **alternatives** (optional): Other options that were considered
- **status** (optional): Decision status - "proposed", "accepted", "deprecated", "superseded" (default: "proposed")

## Workflow

### Phase 1: Context Gathering

Collect comprehensive context about the decision:

1. **Understand the Decision**:
   - What is being decided?
   - What components or systems are affected?
   - What is the scope of this decision?
   - Who are the stakeholders?

2. **Gather Problem Context**:
   - What problem are we trying to solve?
   - What are the pain points with current approach?
   - What requirements drive this decision?
   - What constraints exist (technical, organizational, budget, timeline)?

3. **Identify Decision Drivers**:
   - **Technical Drivers**: Performance, scalability, maintainability, security
   - **Business Drivers**: Time-to-market, cost, competitive advantage
   - **Organizational Drivers**: Team skills, support, operational capability
   - **Regulatory Drivers**: Compliance requirements, industry standards

4. **Research Current State**:
   - Examine existing architecture
   - Review related ADRs in `docs/adr/`
   - Check current technology stack
   - Identify dependencies and integrations

Use available tools:
- `Glob` to find existing ADRs and related documentation
- `Read` to examine existing ADRs and documentation
- `Grep` to search for relevant code patterns and usage
- `Bash` to check directory structure and file counts

### Phase 2: Alternative Analysis

Document all alternatives considered:

1. **Identify Alternatives**:
   - List all viable options (aim for 3-5 alternatives)
   - Include status quo as an alternative
   - Research industry standard approaches
   - Consider hybrid approaches

2. **Analyze Each Alternative**:

For each alternative, document:

**Description**: What is this approach?

**Pros** (benefits):
- Performance characteristics
- Scalability implications
- Security benefits
- Developer experience improvements
- Cost advantages
- Time-to-implementation benefits

**Cons** (drawbacks):
- Performance concerns
- Scalability limitations
- Security risks
- Complexity additions
- Cost implications
- Learning curve
- Operational overhead

**Trade-offs**:
- What do we gain vs what do we lose?
- Short-term vs long-term implications
- Technical debt considerations

**Examples** (if applicable):
- Companies/projects using this approach
- Success stories and failure stories
- Lessons learned from others

3. **Compare Alternatives**:

Create comparison matrix:
| Criteria | Alternative 1 | Alternative 2 | Alternative 3 |
|----------|---------------|---------------|---------------|
| Performance | High | Medium | Low |
| Complexity | Low | Medium | High |
| Cost | $$ | $$$ | $ |
| Time to implement | 2 weeks | 4 weeks | 1 week |
| Scalability | Excellent | Good | Limited |
| Team familiarity | High | Medium | Low |
| Maintenance | Easy | Moderate | Difficult |

### Phase 3: Decision Rationale

Document why this decision was made:

1. **Primary Justification**:
   - Main reason for choosing this approach
   - How it solves the problem
   - Why it's better than alternatives

2. **Supporting Reasons**:
   - Secondary benefits
   - Alignment with architectural principles
   - Consistency with existing decisions
   - Team capability and expertise

3. **Risk Acceptance**:
   - Known risks being accepted
   - Why these risks are acceptable
   - Mitigation strategies for risks

4. **Decision Criteria**:
   - Weighted criteria used for decision
   - How each alternative scored
   - Stakeholder input and consensus

### Phase 4: Consequences Analysis

Document the implications of this decision:

1. **Positive Consequences**:
   - Performance improvements
   - Reduced complexity
   - Better developer experience
   - Cost savings
   - Improved scalability
   - Enhanced security

2. **Negative Consequences**:
   - Technical debt introduced
   - Migration effort required
   - Learning curve for team
   - Increased operational complexity
   - Cost increases
   - Vendor lock-in

3. **Neutral Consequences**:
   - Changes to development workflow
   - Tool or process changes
   - Documentation needs
   - Training requirements

4. **Impact Assessment**:
   - **Immediate Impact** (next sprint): [Changes needed right away]
   - **Short-term Impact** (1-3 months): [Effects in near future]
   - **Long-term Impact** (6+ months): [Strategic implications]

5. **Dependencies**:
   - Other decisions that depend on this one
   - Decisions this depends on
   - Systems or components affected

### Phase 5: ADR Structure Creation

Create the ADR document following standard format:

**ADR Numbering**:
- Find existing ADRs in `docs/adr/`
- Determine next sequential number
- Format: `ADR-NNNN-slug.md` (e.g., `ADR-0042-use-postgresql-for-primary-database.md`)

**Standard ADR Format**:
```markdown
# ADR-[NUMBER]: [Decision Title]

**Status**: [Proposed / Accepted / Deprecated / Superseded]

**Date**: [YYYY-MM-DD]

**Deciders**: [List of people involved in the decision]

**Technical Story**: [Ticket/issue URL if applicable]

## Context and Problem Statement

[Describe the context and problem statement, e.g., in free form using two to three sentences. You may want to articulate the problem in form of a question.]

[Explain the forces at play: technical, business, political, social, project local, etc.]

### Decision Drivers

* [driver 1, e.g., a force, facing concern, …]
* [driver 2, e.g., a force, facing concern, …]
* [driver 3, e.g., a force, facing concern, …]

## Considered Options

* [option 1]
* [option 2]
* [option 3]

## Decision Outcome

Chosen option: "[option 1]", because [justification. e.g., only option which meets k.o. criterion decision driver | which resolves force force | … | comes out best (see below)].

### Consequences

* Good, because [positive consequence 1]
* Good, because [positive consequence 2]
* Bad, because [negative consequence 1]
* Bad, because [negative consequence 2]
* Neutral, because [neutral consequence]

### Confirmation

[How/when will we know if this decision was correct? What metrics or outcomes will we use to evaluate?]

## Pros and Cons of the Options

### [option 1]

[Brief description of option 1]

* Good, because [argument a]
* Good, because [argument b]
* Bad, because [argument c]
* Bad, because [argument d]

### [option 2]

[Brief description of option 2]

* Good, because [argument a]
* Good, because [argument b]
* Bad, because [argument c]
* Bad, because [argument d]

### [option 3]

[Brief description of option 3]

* Good, because [argument a]
* Good, because [argument b]
* Bad, because [argument c]
* Bad, because [argument d]

## More Information

[Any additional information, references, links, or context that might be helpful.]

### Related Decisions

* [ADR-XXXX]: [Related decision]
* [ADR-YYYY]: [Related decision]

### References

* [Link to documentation]
* [Link to research]
* [Link to examples]
```

### Phase 6: Documentation and Storage

Save the ADR document:

1. **Ensure Directory Exists**:
   - Check if `docs/adr/` directory exists
   - Create if it doesn't exist
   - Maintain README.md in `docs/adr/` with ADR index

2. **Generate File Name**:
   - Format: `ADR-NNNN-slug.md`
   - Number: Next sequential number (4 digits with leading zeros)
   - Slug: Lowercase, hyphen-separated from decision title
   - Example: `ADR-0015-migrate-to-microservices.md`

3. **Write ADR File**:
   - Save to `docs/adr/ADR-NNNN-slug.md`
   - Ensure proper formatting
   - Include all required sections

4. **Update ADR Index**:
   - Update `docs/adr/README.md` with new ADR entry
   - Include: number, title, status, date
   - Maintain chronological order

5. **Link Related ADRs**:
   - Update related ADRs to reference this new ADR
   - Create bidirectional links
   - Document superseded relationships

## Output Format

Provide the complete ADR document and confirmation of storage:

```markdown
# ADR Created Successfully

**File**: `docs/adr/ADR-[NUMBER]-[slug].md`
**Status**: [Status]
**Date**: [Date]

---

[Full ADR content in standard format]

---

## ADR Saved

The architectural decision record has been saved to:
`docs/adr/ADR-[NUMBER]-[slug].md`

The ADR index has been updated in:
`docs/adr/README.md`

### Next Steps

1. **Review**: Share this ADR with stakeholders for review
2. **Update Status**: Change status from "Proposed" to "Accepted" once approved
3. **Implementation**: Begin implementing based on this decision
4. **Monitor**: Track the consequences and validate assumptions
5. **Update**: Revise if circumstances change or new information emerges

### Related ADRs

[List any related ADRs that should be reviewed together]

### Communication

Share this ADR with:
- Development team
- Architecture review board
- Product management
- Operations team
- [Other relevant stakeholders]
```

## Agent Invocation

This operation MUST invoke the **10x-fullstack-engineer** agent for expert architectural decision analysis.

**Agent context to provide**:
- Decision to be documented
- Gathered context and constraints
- Alternative approaches identified
- Current architecture state
- Related ADRs and decisions

**Agent responsibilities**:
- Apply 15+ years of architectural decision-making experience
- Identify additional alternatives to consider
- Analyze trade-offs comprehensively
- Provide industry best practices and examples
- Validate decision rationale
- Highlight potential blind spots
- Suggest consequences that may not be obvious
- Ensure decision is well-documented

**Agent invocation approach**:
Present the decision context and explicitly request:
"Using your 15+ years of full-stack architecture experience, help document this architectural decision. Analyze the alternatives, validate the rationale, identify consequences (both obvious and subtle), and ensure this ADR captures the full context for future reference. Draw on your experience with similar decisions in production systems."

## ADR Templates

### Template 1: Technology Selection
```markdown
# ADR-[NUMBER]: Choose [Technology] for [Purpose]

**Status**: Proposed
**Date**: [Date]
**Deciders**: [Names]

## Context and Problem Statement

We need to select [technology category] for [specific use case]. Current approach [describe current state or lack thereof]. This decision affects [scope of impact].

### Decision Drivers

* Performance requirements: [specifics]
* Scalability needs: [specifics]
* Team expertise: [current skills]
* Budget constraints: [limitations]
* Time to implement: [timeline]

## Considered Options

* [Technology 1]
* [Technology 2]
* [Technology 3]
* Status quo (if applicable)

## Decision Outcome

Chosen option: "[Technology]", because it best meets our requirements for [primary reasons].

### Consequences

* Good, because [benefit 1]
* Good, because [benefit 2]
* Bad, because [drawback 1]
* Bad, because [drawback 2]

### Confirmation

We will validate this decision by [metrics/outcomes] after [timeframe].

## Pros and Cons of the Options

### [Technology 1]

[Description]

* Good, because [performance/scalability/cost benefit]
* Good, because [team knows it / easy to learn]
* Bad, because [complexity / cost / limitation]
* Bad, because [vendor lock-in / compatibility issue]

[Repeat for each option]

## More Information

### References
* [Official documentation]
* [Case studies]
* [Comparison articles]

### Related Decisions
* [ADR-XXXX]: [Related decision]
```

### Template 2: Architecture Pattern
```markdown
# ADR-[NUMBER]: Adopt [Pattern] for [Component/System]

**Status**: Proposed
**Date**: [Date]
**Deciders**: [Names]

## Context and Problem Statement

We need to address [architectural challenge] in [system/component]. Current architecture [describe limitations]. This pattern will affect [scope].

### Decision Drivers

* Scalability requirements
* Maintainability concerns
* Team experience
* Performance needs
* Development velocity

## Considered Options

* [Pattern 1]: [Brief description]
* [Pattern 2]: [Brief description]
* [Pattern 3]: [Brief description]

## Decision Outcome

Chosen option: "[Pattern]", because [architectural benefits and trade-off justification].

### Consequences

* Good, because [improved architecture quality]
* Good, because [better scalability/maintainability]
* Bad, because [increased complexity in area]
* Bad, because [migration effort required]

## Implementation Notes

* Phase 1: [Initial steps]
* Phase 2: [Migration approach]
* Phase 3: [Completion]

## Pros and Cons of the Options

[Detailed analysis of each pattern option]

## More Information

### Examples
* [Company/project using this pattern]
* [Success story and lessons learned]

### Related Decisions
* [ADR-XXXX]: [Related architectural decision]
```

### Template 3: Migration Decision
```markdown
# ADR-[NUMBER]: Migrate from [Old] to [New]

**Status**: Proposed
**Date**: [Date]
**Deciders**: [Names]

## Context and Problem Statement

Current [system/technology] has [limitations/problems]. We need to migrate to [new approach] to address [specific issues].

### Decision Drivers

* Current pain points: [list]
* Future requirements: [list]
* Technical debt: [assessment]
* Cost considerations
* Risk tolerance

## Considered Options

* Migrate to [Option 1]
* Migrate to [Option 2]
* Stay with current approach (improved)
* Hybrid approach

## Decision Outcome

Chosen option: "Migrate to [New]", because [clear justification for migration].

### Migration Strategy

* Approach: [Big bang / Phased / Strangler pattern]
* Timeline: [Duration]
* Risk mitigation: [Strategies]
* Rollback plan: [If things go wrong]

### Consequences

* Good, because [benefits of new approach]
* Good, because [problems solved]
* Bad, because [migration cost and effort]
* Bad, because [temporary complexity]
* Neutral, because [team retraining needed]

### Confirmation

Migration success will be measured by:
* [Metric 1]: [Target]
* [Metric 2]: [Target]
* [Metric 3]: [Target]

## Pros and Cons of the Options

[Detailed analysis including migration effort and risk for each option]

## More Information

### Migration Plan
[Link to detailed migration plan]

### Related Decisions
* [ADR-XXXX]: [Original decision being superseded]
```

## Error Handling

### Missing Decision
If no decision is provided:

```
Error: No decision specified.

Please provide the architectural decision to document.

Format: /architect adr decision:"what-was-decided" [context:"background"] [alternatives:"options"]

Examples:
  /architect adr decision:"use PostgreSQL for primary database" alternatives:"MySQL, MongoDB"
  /architect adr decision:"adopt microservices architecture" context:"scaling challenges with monolith"
  /architect adr decision:"implement CQRS pattern for read-heavy workflows"
```

### Invalid Status
If status is not a valid ADR status:

```
Error: Invalid status: [status]

Valid ADR statuses:
- proposed    Decision is proposed and under review
- accepted    Decision has been approved and is in effect
- deprecated  Decision is no longer recommended but still in use
- superseded  Decision has been replaced by a newer ADR

Example: /architect adr decision:"use Redis for caching" status:"accepted"
```

### Directory Creation Failed
If cannot create ADR directory:

```
Error: Unable to create ADR directory at docs/adr/

This may be due to:
- Insufficient permissions
- Read-only filesystem
- Invalid path

Please ensure the directory can be created or specify an alternate location.
```

### File Write Failed
If cannot write ADR file:

```
Error: Unable to write ADR file

Attempted to write to: docs/adr/ADR-[NUMBER]-[slug].md

This may be due to:
- Insufficient permissions
- Disk space issues
- File already exists

Please check permissions and try again.
```

## Examples

**Example 1 - Database Technology Selection**:
```
/architect adr decision:"use PostgreSQL with JSONB for flexible schema requirements" context:"need relational integrity plus document flexibility for user-defined fields" alternatives:"MongoDB for pure document model, MySQL with JSON columns, DynamoDB for serverless" status:"accepted"
```

**Example 2 - Architecture Pattern**:
```
/architect adr decision:"migrate from monolith to microservices architecture" context:"scaling bottlenecks and deployment coupling slowing feature delivery" alternatives:"modular monolith with clear boundaries, service-oriented architecture, serverless functions" status:"proposed"
```

**Example 3 - Frontend Framework**:
```
/architect adr decision:"adopt React with TypeScript for frontend" context:"rebuilding legacy jQuery application" alternatives:"Vue.js, Angular, Svelte, continue with jQuery" status:"accepted"
```

**Example 4 - Authentication Strategy**:
```
/architect adr decision:"implement JWT-based authentication with refresh tokens" alternatives:"session-based auth, OAuth 2.0 only, SAML for enterprise SSO" status:"accepted"
```

**Example 5 - Caching Strategy**:
```
/architect adr decision:"implement multi-tier caching with Redis and CDN" context:"database load is causing performance issues under traffic spikes" alternatives:"database query caching only, in-memory application cache, no caching" status:"accepted"
```

**Example 6 - Deployment Strategy**:
```
/architect adr decision:"use blue-green deployment for zero-downtime releases" alternatives:"rolling deployment, canary releases, recreate deployment" status:"proposed"
```

**Example 7 - Superseding Previous Decision**:
```
/architect adr decision:"supersede ADR-0023: migrate from REST to GraphQL for public API" context:"GraphQL complexity and client confusion outweigh benefits" alternatives:"improve REST API versioning, hybrid approach, maintain status quo" status:"accepted"
```

**Example 8 - Minimal ADR (will prompt for more detail)**:
```
/architect adr decision:"implement event sourcing for audit trail"
```
This will trigger the agent to ask clarifying questions about context, alternatives, and rationale.

## Best Practices

### When to Create an ADR

Create an ADR for decisions that:
- Affect system architecture or structure
- Have significant long-term consequences
- Involve trade-offs between multiple approaches
- Impact multiple teams or components
- Require significant effort to reverse
- Set precedent for future decisions

### When NOT to Create an ADR

Don't create ADRs for:
- Minor implementation details
- Obvious technology choices with no alternatives
- Temporary workarounds
- Decisions easily reversed
- Team process decisions (use different document)

### ADR Writing Tips

1. **Be Specific**: Don't just say "improve performance" - specify metrics and targets
2. **Include Context**: Future readers need to understand why this mattered
3. **Document Alternatives**: Show you considered options, not just the chosen one
4. **Acknowledge Trade-offs**: No decision is perfect - document the downsides
5. **Keep It Concise**: Aim for 2-3 pages; link to external docs for details
6. **Update Status**: Keep status current as decisions evolve
7. **Link Related ADRs**: Show how decisions build on each other
8. **Use Examples**: Concrete examples clarify abstract decisions
9. **Define Success**: How will you know if this was the right decision?
10. **Review Regularly**: Revisit ADRs periodically to validate or supersede
