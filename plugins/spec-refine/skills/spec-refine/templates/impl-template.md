---
feature: {{FEATURE_NAME}}
phase: how-auto
iteration: 0
last_updated: {{TIMESTAMP}}
convergence:
  questions_stable_count: 0
  open_questions_count: 0
  high_confidence_ratio: 0.0
source_spec: ./spec.md
---

# Implementation Specification: {{FEATURE_NAME}}

## Overview

### What Spec Reference
See [spec.md](./spec.md) for requirements and problem definition.

### Implementation Approach
{{High-level approach to implementing the requirements}}

### Key Technical Decisions
- {{Decision 1}}: {{Rationale}}
- {{Decision 2}}: {{Rationale}}

---

## Implementation Details

### High Confidence
*Implementation details verified against codebase patterns.*

- {{None yet - will be populated during refinement}}

### Medium Confidence
*Implementation approaches that seem reasonable but need verification.*

- {{None yet - will be populated during refinement}}

---

## Open Questions

*Technical questions requiring research or decision.*

- [ ] {{Initial question}}

---

## Component Breakdown

### New Components to Create

#### {{Component Name}}
- **Type**: {{Service | Controller | Component | Model | Utility}}
- **Location**: {{Suggested file path}}
- **Purpose**: {{What it does}}
- **Dependencies**: {{What it depends on}}

### Existing Components to Modify

#### {{Existing Component}}
- **Location**: {{File path}}
- **Changes Needed**: {{Description of modifications}}
- **Reason**: {{Why modification is needed}}

---

## Data Model Changes

### New Tables/Collections
- {{None identified yet}}

### Schema Modifications
- {{None identified yet}}

### Migrations Needed
- {{None identified yet}}

---

## API Changes

### New Endpoints
- {{None identified yet}}

### Modified Endpoints
- {{None identified yet}}

---

## Integration Points

### Internal Dependencies
*Other parts of the system this feature integrates with.*

- {{To be discovered}}

### External Dependencies
*Third-party services, APIs, or libraries.*

- {{To be discovered}}

---

## Testing Strategy

### Unit Tests
- {{Key areas needing unit test coverage}}

### Integration Tests
- {{Integration points requiring tests}}

### Manual Testing
- {{Scenarios for manual QA}}

---

## Rollout Considerations

### Feature Flags
- {{Any feature flags needed}}

### Migration Steps
- {{Steps for deploying to production}}

### Rollback Plan
- {{How to rollback if issues arise}}

---

## Iteration Log

*Record of refinement iterations.*

### Initial Seed ({{DATE}})
- Created implementation spec from finalized requirements
- Open Questions: {{count}}
- Ready for: how-auto phase
