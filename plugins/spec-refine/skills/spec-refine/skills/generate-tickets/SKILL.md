---
name: generate-tickets
description: Generate actionable implementation tickets from the finalized How (implementation) specification.
context: fork
allowed-tools: Read, Write
user-invocable: false
agent: ticket-architect
---

# Generate Tickets - Implementation Task Creator

You are generating implementation tickets from the finalized implementation specification.

**Input**: $ARGUMENTS contains path to the impl.md (How spec)

## Step 1: Read Implementation Spec

Read the impl.md document and extract:
- All High Confidence implementation items
- Medium Confidence items (may need tickets with caveats)
- Any remaining Open Questions (may block tickets)
- Technical decisions made
- File/component mapping if present

## Step 2: Identify Ticket Candidates

Group implementation items into logical work units:

### Ticket Granularity Guidelines
- **Too Big**: "Implement authentication" → Split into smaller tickets
- **Too Small**: "Add import statement" → Combine with related work
- **Just Right**: "Create login form component with validation"

### Natural Boundaries
- Single file or closely related files
- One API endpoint with its tests
- One UI component with its styles
- Database migration + model update
- Configuration change across environments

## Step 3: Establish Dependencies

Map dependencies between tickets:
- Which tickets must complete before others can start?
- Which tickets can be done in parallel?
- Are there any blocking external dependencies?

Create dependency waves:
```
Wave 1: Independent foundation tickets (can start immediately)
Wave 2: Tickets depending on Wave 1
Wave 3: Tickets depending on Wave 2
...
```

## Step 4: Generate Ticket Content

For each ticket, create:

```markdown
## T-{number}: {Concise Title}

**Wave**: {1|2|3|...}
**Depends On**: {T-X, T-Y | None}
**Estimated Scope**: {Small|Medium|Large}

### Description
{What needs to be done and why}

### Acceptance Criteria
- [ ] {Specific, testable criterion}
- [ ] {Another criterion}
- [ ] {Tests pass}

### Technical Notes
- Files to create/modify: {list}
- Patterns to follow: {reference existing code}
- Considerations: {edge cases, gotchas}

### Open Items
{Any unresolved questions that may affect this ticket}
```

## Step 5: Create Tickets Document

Write to `docs/specs/{feature_name}/tickets.md`:

```markdown
---
feature: {feature_name}
generated: {ISO timestamp}
total_tickets: {n}
waves: {n}
---

# Implementation Tickets: {Feature Name}

## Summary
- **Total Tickets**: {n}
- **Waves**: {n}
- **Blocked Tickets**: {n} (awaiting open questions)

## Dependency Graph
```
Wave 1: T-1, T-2, T-3
    ↓
Wave 2: T-4, T-5
    ↓
Wave 3: T-6
```

## Wave 1: Foundation
{Tickets that can start immediately}

## Wave 2: Core Implementation
{Tickets depending on Wave 1}

## Wave 3: Integration
{Tickets depending on Wave 2}

## Blocked Tickets
{Tickets that cannot be fully specified due to open questions}

---

## All Tickets

{Full ticket details in T-number order}
```

## Ticket Quality Checks

Before finalizing, verify:

### Each Ticket Has
- [ ] Clear, actionable title
- [ ] Specific acceptance criteria
- [ ] Identified dependencies
- [ ] Referenced files/patterns
- [ ] Realistic scope estimate

### Overall Ticket Set Has
- [ ] Complete coverage of impl.md items
- [ ] No circular dependencies
- [ ] Reasonable wave structure
- [ ] Blocked items clearly identified

## Step 6: Output Summary

```
TICKETS GENERATED
Feature: {feature_name}
Output: docs/specs/{feature_name}/tickets.md

## Statistics
- Total Tickets: {n}
- Waves: {n}
- Ready to Start (Wave 1): {n}
- Blocked by Open Questions: {n}

## Wave Breakdown
- Wave 1: {n} tickets (foundation)
- Wave 2: {n} tickets (core)
- Wave 3: {n} tickets (integration)

## Blocked Items
{List any tickets blocked by unresolved questions}

## Recommended Starting Point
Start with: {T-X: title} - {reason this is a good starting point}
```

## Special Cases

### Medium Confidence Items
- Include in tickets but flag uncertainty
- Add to Technical Notes: "Implementation may vary based on {uncertainty}"

### Open Questions Affecting Implementation
- Create "blocked" ticket that documents what's needed
- Link to the specific open question
- Don't estimate scope for blocked tickets

### Large Scope Items
- Split into multiple tickets
- First ticket establishes foundation
- Subsequent tickets build on it
- Document the split rationale
