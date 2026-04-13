---
name: specification-writing
description: >-
  Core reference for EARS requirement patterns, Given/When/Then acceptance criteria,
  RFC 2119 language, requirement ID conventions, and specification quality checklists.
  Background knowledge for the spec-writer agent. Preloaded by spec-writer via the skills
  frontmatter field; not user-invocable.
user-invocable: false
---

# Specification Writing — Core Reference

This skill is **preloaded** by the `refinery:spec-writer` agent via its `skills:` frontmatter field. Its content becomes part of spec-writer's system context at agent startup. This skill is **not user-invocable** — it has no behavior on its own; it is reference material consulted by the agent during synthesis.

The same content (in a slightly different rendering for mode/stage files) lives in `${CLAUDE_SKILL_DIR}/../refine/references/requirement-syntax.md`. The two files MUST stay in sync (per NFR-M-001 single-source-of-truth discipline). When updating one, update the other.

## 1. EARS — Easy Approach to Requirements Syntax

EARS provides six patterns for unambiguous functional requirements. Every functional requirement (`FR-NNN`) MUST use one of the six patterns.

### 1.1 Ubiquitous (always active)

```
The <system> shall <required behavior>.
```

When to use: a behavior that holds at all times.

Example: "The system shall maintain audit logs for all administrative actions."

### 1.2 Event-Driven (responds to a trigger)

```
When <trigger>, the <system> shall <required behavior>.
```

When to use: a behavior that responds to a discrete event.

Example: "When a user submits a login form, the system shall validate the credentials within 200ms."

### 1.3 State-Driven (active during a state)

```
While <state>, the <system> shall <required behavior>.
```

When to use: a behavior that holds during a specific operational state.

Example: "While the database is in maintenance mode, the system shall reject all write requests with HTTP 503."

### 1.4 Unwanted Behavior (defensive)

```
If <unwanted condition>, then the <system> shall <required behavior>.
```

When to use: a behavior that handles error or exceptional conditions.

Example: "If the upstream API returns a 5xx response, then the system shall retry up to three times with exponential backoff."

### 1.5 Optional Feature (conditional capability)

```
Where <feature is included>, the <system> shall <required behavior>.
```

When to use: a behavior that exists only when a feature is enabled.

Example: "Where the multi-tenant feature is enabled, the system shall scope all queries by tenant_id."

### 1.6 Complex (multiple triggers)

```
When <trigger1> and while <state> and if <condition>, the <system> shall <behavior>.
```

When to use: a behavior with compound preconditions. Use sparingly — prefer decomposition into multiple atomic requirements when possible.

Example: "When a payment is submitted and while the merchant account is verified and if the amount exceeds the daily limit, the system shall require additional authentication."

### 1.7 EARS anti-patterns (avoid)

| Anti-pattern | Why it fails | Fix |
|--------------|--------------|-----|
| "The system should…" | "Should" = preference, not requirement | Use "shall" for mandatory; "may" for optional |
| "The system handles X" | Not testable | Specify the observable behavior: "logs", "rejects", "retries", "returns" |
| Compound: "validate AND store AND notify…" | Three requirements masquerading as one | Split into atomic FRs |
| "The system shall be fast" | Unmeasurable | Specify the threshold: "within 200ms p95" |
| "The system shall support many users" | Unmeasurable | Specify the scale: "shall support 10,000 concurrent users" |

## 2. Given/When/Then (Gherkin) — Acceptance Criteria

Every functional requirement (`FR-NNN`) MUST have at least one acceptance criterion (`AC-FR-NNN-N`) in Given/When/Then format.

### 2.1 Structure

```gherkin
Given <precondition>
  And <additional precondition>     # optional
When <action>
Then <observable outcome>
  And <additional outcome>          # optional
```

### 2.2 Rules

- **Atomic:** one clear action per scenario; multiple `When`s = multiple scenarios
- **Deterministic:** same Given+When → same Then
- **Observable:** testable from outside the system
- **Concrete:** specific values, not vague qualifiers
- **Independent:** each AC stands alone

### 2.3 Example

```gherkin
Given a user with role "admin" and a valid session token
When the user submits POST /api/users with valid payload
Then the response status is 201
  And the response body contains the new user's id
  And the new user appears in GET /api/users within 1 second
```

### 2.4 Edge case patterns

For every primary AC ("happy path"), consider:

- **Negative case:** preconditions fail
- **Boundary case:** edge of valid input ranges
- **Concurrent case:** races between operations
- **Error case:** upstream failures

## 3. RFC 2119 (System-Level Specs)

System-level `spec` artifacts (`scope: system`) use RFC 2119 keywords. Feature-level specs use EARS exclusively.

| Keyword | Meaning |
|---------|---------|
| MUST / SHALL / REQUIRED | Absolute requirement |
| MUST NOT / SHALL NOT | Absolute prohibition |
| SHOULD / RECOMMENDED | Strong recommendation |
| SHOULD NOT | Strong recommendation against |
| MAY / OPTIONAL | Truly optional |

Use **uppercase** for RFC 2119 keywords. Use lowercase `shall` inside EARS patterns.

## 4. Numbering Conventions

| Type | Format | Notes |
|------|--------|-------|
| Functional Requirement | `FR-NNN` | Per artifact, never reused |
| Non-Functional Requirement | `NFR-<CAT>-NNN` (categories: P, S, SC, R, A, U, M, C) | Per artifact |
| Acceptance Criterion | `AC-<REQ-ID>-N` | Per parent requirement |
| Invariant | `INV-NNN` | Per artifact |
| Resolved Design Decision | `RD-NNN` | Per artifact |
| Risk | `R-NNN` | Per artifact |
| Failure Mode | `FM-NNN` | Per design artifact |
| Principle | `P-NNN` | Per principles artifact |
| Open Question | `OQ-NNN` | Per artifact |
| Source Document | `SD-NNN` | Per source list |
| Ticket | `T-NN` | Per tickets artifact |

## 5. Quality Checklist (pre-finalize)

Before any artifact transitions to `finalized`:

- [ ] Atomicity: one requirement per FR; no compound items with implicit AND
- [ ] EARS or RFC 2119 compliance per artifact scope
- [ ] Specificity: no weasel words; concrete thresholds with units
- [ ] Testability: every requirement verifiable
- [ ] Necessity: every requirement traces to a stated need
- [ ] AC coverage: every FR has ≥1 AC; each AC atomic, deterministic, observable
- [ ] Confidence + Evidence: every tracked claim has Confidence; High items have file:line; Low items in Open Questions
- [ ] No orphans: no FR without AC, no AC without parent, no dangling cross-references
- [ ] No dangling deletes: `[DELETED]` items either reference replacement or are themselves obsolete
- [ ] Glossary discipline: every domain term defined

## 6. Confidence Discipline

| Tier | Required evidence |
|------|-------------------|
| High | file:line citations OR upstream artifact reference OR user-decision Changelog entry |
| Medium | file:line with "single example" note OR upstream reference with "inferred from" note |
| Low | Item must appear in Open Questions; no evidence required |

The artifact's `convergence.high_confidence_ratio` = `high_count / (high_count + medium_count + open_questions_count)`.

## 7. Document Format Compliance

Every artifact written by the spec-writer agent MUST conform to:

- **Universal frontmatter** per `references/document-format.md §1`
- **Universal sections** (Open Questions, Iteration Log, Changelog) per §2
- **Per-artifact body sections** per §3 / template
- **Tracked claim format** per §4
- **Numbering conventions** per §5
- **Confidence tiers** per §6
- **Status compatibility** per §7

When generating an artifact, fill the corresponding template; do not deviate from required sections.
