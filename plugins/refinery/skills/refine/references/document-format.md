# Reference: Document Format

Canonical definition of the universal artifact format used by every Refinery operation. This is the **single source of truth** for frontmatter schema, universal sections, tracked claim format, numbering conventions, and confidence tier definitions (per NFR-M-001). Mode files, stage files, templates, and agents reference this file rather than duplicating its content.

## 1. Universal Frontmatter Schema

Every artifact begins with YAML frontmatter containing the following fields. **R** = required, **O** = optional.

```yaml
---
artifact: principles | design | stack | spec | feature-spec | plan | tickets   # R
scope: system | subsystem | feature | component                                # R
feature: <name>                                                                # R (project name for system-scope; feature name for feature-scope)
stage: <current stage being executed>                                          # R
iteration: <integer ≥ 0>                                                       # R
last_updated: <ISO 8601 date or datetime>                                      # R
status: draft | iterating | reviewed | finalized | implemented | drifted |
        superseded | archived                                                  # R
parent: <relative path to parent artifact, or null>                            # R
children: [<relative paths to child artifacts>]                                # R (may be empty list)
references: [<relative paths to cross-referenced artifacts>]                   # O
convergence:                                                                   # R (R for spec/feature-spec/plan/principles/design/stack; O for tickets)
  questions_stable_count: <integer ≥ 0>
  open_questions_count: <integer ≥ 0>
  high_confidence_ratio: <float between 0.0 and 1.0>
source_documents:                                                              # O
  - id: <SD-NNN>
    path: <relative path>
    description: <one-line description>
superseded_by: <relative path to replacement artifact>                         # O (set by mode-archive --as=superseded)
plugin_version: <semver of Refinery that wrote this>                           # R
---
```

### Validation rules

- `artifact` must be one of the seven values
- `status` must be a value the artifact type can legally hold (per the §9.7 status compatibility matrix)
- `parent` must reference an artifact whose `children` list contains this artifact's path (bidirectional graph integrity, INV-001)
- `convergence.high_confidence_ratio` must equal the actual ratio computed from claim Confidence tags in the body (INV-002)
- `convergence.open_questions_count` must equal the count of OPEN-status entries in the Open Questions table (INV-003)
- `iteration ≥ 0`, `questions_stable_count ≥ 0`, `open_questions_count ≥ 0`

## 2. Universal Sections

Three sections appear in **every** artifact, in this order at the end of the document. They are present even when empty.

### 2.1 Open Questions

```markdown
## Open Questions

| ID | Question | Type | Added | Status |
|----|----------|------|-------|--------|
| OQ-001 | <question> | RESEARCHABLE \| HUMAN_NEEDED \| DERIVABLE \| OUT_OF_SCOPE | <date> | OPEN \| RESOLVED \| DEFERRED \| NEW |
```

Open Questions are the canonical surface for unresolved items. Inline `[OPEN]`, `[TODO]`, `[TBD]`, `[ARCHITECTURE]`, `[DECISION NEEDED]` markers in artifact bodies are permitted but **shall be promoted** to the Open Questions table during the next `iterate`, `review`, or `finalize` operation.

### 2.2 Iteration Log

```markdown
## Iteration Log

### Iteration 0 — Initial draft (YYYY-MM-DD)
- **Created via:** advance --stage=<name>
- **Source:** <input file or seed idea>
- **Initial state:** <N requirements, N open questions, etc.>

### Iteration N (YYYY-MM-DD)
- **Operation:** iterate | finalize | update | archive
- **Researched:** <topics investigated>
- **Resolved:** <N questions → High Confidence (FR-X, FR-Y, …)>
- **Added:** <N High, N Medium confidence items>
- **New questions:** <N discovered>
- **Still open:** <N questions remain>
- **Convergence:** stable_count=N, open=N, ratio=N.NN
```

The iteration log is **append-only**. Each entry records a discrete operation and its convergence delta. Iteration numbers are monotonic; iteration 0 is reserved for the initial draft.

### 2.3 Changelog

```markdown
## Changelog

| Date | Section | Change | Reason | Operation |
|------|---------|--------|--------|-----------|
| YYYY-MM-DD | (created) | Initial draft from <source> | <reason> | advance |
| YYYY-MM-DD | Requirements | Added FR-031: <title> | <reason> | iterate (i1) |
| YYYY-MM-DD | Requirements | Marked FR-007 [DELETED — superseded by FR-031] | Decomposed compound requirement | finalize |
```

Every modification gets a Changelog entry: date | affected section | change description | reason | source operation.

## 3. Per-Artifact Body Sections

The body sections between frontmatter and the universal trailing sections vary by artifact type. Templates in `${CLAUDE_SKILL_DIR}/templates/<artifact>.md` provide the full structural skeleton for each.

| Artifact | Body sections (high level) | Tracked items |
|----------|---------------------------|---------------|
| principles | Prime Postulate, Core Concepts, Lifecycle Model, Authority & Trust, Core Principles, Hard Invariants, Separation of Concerns, Data Authority, Error Doctrine, Scope Boundaries, Minimal Viable State, Scaling Law | INV-NNN, P-NNN |
| design | Thesis, System Decomposition, Data Model & Authority, External Integrations, Security, Scalability, Reliability, Observability, Operational, Second-Order Failures, Pre-Implementation Validation | FM-NNN |
| stack | Language/Runtime/Build, Project Structure, Core Dependencies, Internal Communication, Serialization, Testing, Observability, Configuration, Deployment, Dependency Summary, Build vs Buy | (technology entries with confidence + justification + gotchas) |
| spec | Introduction, System Overview, Domain Model, Functional Requirements, Non-Functional Requirements, System Interfaces, Constraints, Resolved Decisions, Risk Register, Appendices (Traceability, Glossary) | FR-NNN, NFR-NNN, INV-NNN, RD-NNN, R-NNN |
| feature-spec | Overview, Context, Requirements (FR/NFR/Constraints), Acceptance Criteria, Data Model, API Contracts, Error Handling, Dependencies, Migration | FR-NNN, NFR-NNN, AC-* |
| plan | Document Conventions, System Architecture Overview, Current Implementation State, Phase Dependency Graph, Phases (one section per), Cross-Cutting Appendices | (phases with components, type signatures, AC, anti-patterns) |
| tickets | Summary, Dependency Graph, Waves (one section per), Appendices (Ticket Index, Blocked Tickets) | T-NN |

## 4. Tracked Claim Format

Every functional requirement, non-functional requirement, invariant, design decision, risk, or other tracked claim follows this structure:

```markdown
#### FR-NNN: <Title using verb-object pattern>

<EARS-formatted statement: "The <system> shall <action>" with appropriate trigger/condition.>

**Priority:** Must | Should | Could | Won't
**Confidence:** High | Medium | Low
**Evidence:** <file:line citations, OR upstream artifact references like "system-design.md §3.2", OR "user decision 2026-04-11">
**Source:** <provenance: which upstream artifact, codebase area, or decision created this requirement>
**Status:** Verified | Under Review | Inferred | Deferred
**Last validated:** <ISO date>
**Notes:** <Implementation hints, edge cases, cross-references — optional>
```

For acceptance criteria:

````markdown
##### AC-FR-NNN-M: <Brief scenario name>

```gherkin
Given <precondition>
  And <additional precondition>
When <action>
Then <observable outcome>
  And <additional outcome>
```
````

## 5. Numbering Conventions

| Type | Format | Scope | Reuse policy |
|------|--------|-------|--------------|
| Functional Requirement | `FR-NNN` | Per artifact | Never reuse (mark `[DELETED]`) |
| Non-Functional Requirement | `NFR-NNN` (with optional category prefix: `NFR-P` performance, `NFR-S` security, `NFR-SC` scalability, `NFR-R` reliability, `NFR-A` availability, `NFR-U` usability, `NFR-M` maintainability, `NFR-C` compatibility) | Per artifact | Never reuse |
| Invariant | `INV-NNN` | Per artifact | Never reuse |
| Resolved Design Decision | `RD-NNN` | Per artifact | Never reuse |
| Risk | `R-NNN` | Per artifact | Never reuse |
| Acceptance Criterion | `AC-<REQ-ID>-N` | Per parent requirement | Never reuse within parent |
| Open Question | `OQ-NNN` | Per artifact | Reusable after RESOLVED (closed); deferred questions retain ID |
| Failure Mode | `FM-NNN` | Per design artifact | Never reuse |
| Principle | `P-NNN` | Per principles artifact | Never reuse |
| Source Document | `SD-NNN` | Per artifact's source_documents list | Never reuse |
| Ticket | `T-NN` | Per tickets artifact | Never reuse |

## 6. Confidence Tier Definitions

| Tier | Criteria | Required evidence form |
|------|----------|------------------------|
| **High** | Direct codebase evidence with multiple consistent examples (≥3), OR explicit derivation from a finalized upstream artifact, OR an explicit user decision recorded in the Changelog | file:line citations OR upstream artifact reference OR user-decision Changelog entry |
| **Medium** | Single example found in codebase, OR inferred from related code, OR partially supported by an upstream artifact | file:line citation with explicit "single example" note OR upstream reference with explicit "inferred from" note |
| **Low** | No direct evidence, contradictory examples, or speculative | None required; item **must** appear in or cross-reference Open Questions |

The `convergence.high_confidence_ratio` is computed as:

```
high_confidence_ratio = high_count / (high_count + medium_count + open_questions_count)
```

where `high_count` and `medium_count` count tracked claims tagged at those tiers across the artifact body.

## 7. Status Field Compatibility Matrix

Not all status values apply to all artifact types. The following matrix specifies which status values are valid per type.

| Status | principles | design | stack | spec | feature-spec | plan | tickets |
|--------|------------|--------|-------|------|--------------|------|---------|
| draft | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| iterating | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ |
| reviewed | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✗ |
| finalized | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| implemented | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ |
| drifted | ✗ | ✗ | ✓ | ✓ | ✓ | ✓ | ✓ |
| superseded | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| archived | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

Tickets skip `iterating`/`reviewed` because tickets are derived (regenerable from plan); iteration happens at the plan level. Principles and design have no `implemented` or `drifted` because they are not directly executable.

## 8. Markdown Style

- **CommonMark** with YAML frontmatter. No HTML tags except `<br>` inside table cells where line breaks are needed.
- **Atomic file:** one artifact per `*.md` file.
- **Table-friendly:** prefer tables over bulleted lists when the content has a regular structure (item + 2+ attributes per item).
- **Encoding:** UTF-8 without BOM.
- **Line endings:** LF.
- **Headings:** ATX style (`#`, `##`, …). No skipping levels (don't go from `##` to `####`).
